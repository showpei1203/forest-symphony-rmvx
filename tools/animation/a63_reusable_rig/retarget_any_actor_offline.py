"""Forest Symphony A63 approved full-body action retarget (offline, free).
Usage:
 python retarget_any_actor_offline.py --action run|waiting --target-png NEW_F0.png --target-skeleton NEW_18_POINTS.json --output NEW_ACTION_POSE.json
 New character supplies *its own* 3/4 SE F0 PNG + checked 18-joint baseline. Do not use actor01 pixels for new actors.
 No API calls; refuses if source view/body topology mismatches, never silently submits credits.
"""
from pathlib import Path
from PIL import Image
import argparse,json,hashlib,math
HERE=Path(__file__).resolve().parent
ALL_JOINTS={"NOSE","LEFT EYE","RIGHT EYE","LEFT EAR","RIGHT EAR","NECK",
"LEFT SHOULDER","RIGHT SHOULDER","LEFT ELBOW","RIGHT ELBOW","LEFT ARM","RIGHT ARM",
"LEFT HIP","RIGHT HIP","LEFT KNEE","RIGHT KNEE","LEFT LEG","RIGHT LEG"}
def load_points(path):
 obj=json.loads(Path(path).read_text("utf8"))
 if isinstance(obj,dict):
  obj=obj.get("points",obj.get("first_frame_keypoints",obj.get("keypoints",obj)))
  if isinstance(obj,list) and obj and isinstance(obj[0],list):obj=obj[0]
 if not isinstance(obj,list)or len(obj)!=18 or {x.get("label")for x in obj}!=ALL_JOINTS:
  raise ValueError("Expected exactly 18 unique humanoid keypoints")
 if any(not (0<=p["x"]<=1 and 0<=p["y"]<=1) for p in obj):
  raise ValueError("Target baseline has out-of-range joints")
 return obj
def retarget(action,first_frame,landmarks):
 if action not in ("run","waiting"):raise ValueError(action)
 p=Path(first_frame);img=Image.open(p).convert("RGBA")
 w,h=img.size
 if w!=h or w not in(32,40,48,64):raise ValueError("Target must be a square 32/40/48/64 native chibi pixel reference")
 bbox=img.getbbox()
 if bbox is None:raise ValueError("Empty reference image")
 physical_h=bbox[3]-bbox[1]
 if physical_h<18:raise ValueError("Reference figure too small to retarget")
 if any(p["label"]not in ALL_JOINTS for p in landmarks):raise ValueError("Invalid landmarks")
 recipefile=HERE/("A62_APPROVED_RUN_MOTION_RECIPE.json"if action=="run"else"A63_WAITING_BREATH_MOTION_RECIPE.json")
 recipe=json.loads(recipefile.read_text("utf8"))
 deltas=recipe["three_pose_joint_offset_recipes"]if action=="run"else recipe["height_normalized_pose_deltas"]
 target0={x["label"]:x for x in landmarks}
 result=[]
 for f,delta in enumerate(deltas):
  frame=[]
  for raw in landmarks:
   label=raw["label"]
   dx=delta[label]["dx_relative_to_height"]*physical_h
   dy=delta[label]["dy_relative_to_height"]*physical_h
   x=raw["x"]+dx/w;y=raw["y"]+dy/h
   if not (.02<x<.98 and .02<y<.98):
    raise ValueError(f"Frame {f} keypoint {label} would clip, manually reduce amplitude")
   frame.append({"label":label,"x":round(x,6),"y":round(y,6),"z_index":int(raw.get("z_index",0))})
  result.append(frame)
 # source first frame must be EXACT baseline target skeleton, no changes.
 assert all(abs(result[0][i][v]-landmarks[i][v])<.000002 for i in range(18)for v in("x","y"))
 if action=="waiting":
  for f in(1,2):
   for label in("LEFT LEG","RIGHT LEG"):
    a=target0[label];b=next(z for z in result[f] if z["label"]==label)
    if abs(a["x"]-b["x"])>.000002 or abs(a["y"]-b["y"])>.000002:
     raise ValueError("Waiting feet must stay planted")
 else:
  left_right=lambda fr: (next(z for z in fr if z["label"]=="LEFT LEG")["y"]-next(z for z in fr if z["label"]=="RIGHT LEG")["y"])*h
  a,b=left_right(result[1]),left_right(result[2])
  if not a>2.2 or not b< -2.2:
   raise ValueError(f"Opposite-foot gate failed for target anatomy: F1={a:.2f}, F2={b:.2f}")
 seq=recipe["playback"]
 return {"action":recipe.get("action","Moving to Close Attack"),
         "source_accepted_template":"FS A62 user approved",
         "target_png":str(p),"target_sha256":hashlib.sha256(p.read_bytes()).hexdigest(),
         "target_size":[w,h],"target_bbox":bbox,
         "keypoints":result,"first_frame_keypoints":result[0],
         "direction":"south-east","view":"low top-down","playback":seq,
         "requested_three_stored_frames":3,
         "view_and_identity_human_QA":"REQUIRED for every new character",
         "paid_generation_submitted":False,
         "status":"OFFLINE_RIG_DRAFT_NEEDS_VISUAL_CHECK",
         "source_recipe":recipefile.name}
if __name__=="__main__":
 ap=argparse.ArgumentParser()
 ap.add_argument("--action",required=True,choices=["run","waiting"])
 ap.add_argument("--target-png",required=True,type=Path)
 ap.add_argument("--target-skeleton",required=True,type=Path)
 ap.add_argument("--output",required=True,type=Path)
 opt=ap.parse_args()
 model=retarget(opt.action,opt.target_png,load_points(opt.target_skeleton))
 opt.output.parent.mkdir(parents=True,exist_ok=True)
 opt.output.write_text(json.dumps(model,ensure_ascii=False,indent=2),encoding="utf8")
 print("OFFLINE_REUSABLE_RIG_DRAFT_SAVED",opt.action,str(opt.output))