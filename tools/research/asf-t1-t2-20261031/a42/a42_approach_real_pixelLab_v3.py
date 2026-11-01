"""A42 Moving to Close Attack 3-frame in-place battle motion.
PixelLab real /animate-with-skeleton-v3 with 18 real joints from FS battle sprite.
SBS engine owns x/y travel toward target; DO NOT bake worldspace walking translation into cells.
Each frame 40x40, character Q 1:1, empty hands, south-east 45 camera.
"""
from pathlib import Path
from PIL import Image
import json,base64,io,hashlib,time,sys
B=Path(r"E:\GameAssetToolLab_20261023")
R=B/"A42_APPROACH_CLOSE_ATTACK_SKELETON_3F_20261101";R.mkdir(exist_ok=True)
A40=B/"A40_CRITICAL_DAMAGE_SKELETON_CONTROL_20261101"
SRC=B/"A34_FS_BATTLE45_F0_CORRECTION_20261101"/"A34_REAL_BATTLE_45_REFERENCE_MASTER_00.png"
sys.path.insert(0,str(B/"A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST"))
from a23_one_paid_spritesheet_trial import api,key,balance
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def put(p,o):p.write_text(json.dumps(o,ensure_ascii=False,indent=2),encoding='utf8')
base=json.loads((A40/"A40_CRITICAL_3POSE_18JOINT_CONTROL.json").read_text(encoding='utf8'))["keyframes"][0]
assert len(base)==18
def frame(stage):
 p={x["label"]:dict(x) for x in base}
 def edit(label,dx=0,dy=0,x=None,y=None):
  v=p[label]
  v["x"]=round(max(.02,min(.98,v["x"]+dx if x is None else x)),5)
  v["y"]=round(max(.02,min(.98,v["y"]+dy if y is None else y)),5)
 if stage==1: # Step begins, head/hips lean in toward southeast, foot loads
  for l in ("NOSE","LEFT EYE","RIGHT EYE","LEFT EAR","RIGHT EAR"):edit(l,dx=.012,dy=.014)
  for l in ("NECK","LEFT SHOULDER","RIGHT SHOULDER"):edit(l,dx=.022,dy=.016)
  for l in ("LEFT HIP","RIGHT HIP"):edit(l,dx=.024,dy=.014)
  edit("LEFT KNEE",dx=.04,dy=-.036);edit("LEFT LEG",dx=.060,dy=-.039)
  edit("RIGHT KNEE",dx=-.020,dy=.010)
  edit("LEFT ELBOW",x=.664,y=.700);edit("LEFT ARM",x=.595,y=.710)
  edit("RIGHT ELBOW",x=.430,y=.698);edit("RIGHT ARM",x=.475,y=.720)
 if stage==2: # planted end of approach, weapon still separate SBS overlay
  for l in ("NOSE","LEFT EYE","RIGHT EYE","LEFT EAR","RIGHT EAR"):edit(l,dx=.033,dy=.012)
  for l in ("NECK","LEFT SHOULDER","RIGHT SHOULDER"):edit(l,dx=.040,dy=.024)
  for l in ("LEFT HIP","RIGHT HIP"):edit(l,dx=.038,dy=.022)
  edit("LEFT KNEE",dx=.065,dy=.010);edit("LEFT LEG",dx=.080,dy=.016)
  edit("RIGHT KNEE",dx=-.015,dy=.038);edit("RIGHT LEG",dx=-.013,dy=.010)
  edit("LEFT ELBOW",x=.695,y=.698);edit("LEFT ARM",x=.62,y=.705)
  edit("RIGHT ELBOW",x=.444,y=.681);edit("RIGHT ARM",x=.51,y=.694)
 return [p[x["label"]] for x in base]
poses=[frame(0),frame(1),frame(2)]
assert all(len(p)==18 for p in poses)
def point(fr,l):return next(x for x in fr if x["label"]==l)
for fr in poses:
 assert .35<=point(fr,"LEFT ARM")["x"]<=.75
 assert .35<=point(fr,"RIGHT ARM")["x"]<=.75
 assert all(0<=v["x"]<=1 and 0<=v["y"]<=1 for v in fr)
plan={"stage":"A42","action":"Moving to Close Attack","frames":3,
"source_native_FS_angle":"A34 battle actor01_1 45deg source, 18 joints from A40 real PixelLab estimate",
"sbs_worldspace":"SBS script controls movement towards target, pixels depict local run/lunge only",
"pose_phases":["F0 neutral in-place","F1 weight shift one boot raised","F2 step plant/ready at close range"],
"keypoints":poses,"camera":"south-east","unarmed":True,"source_sha256":sha(SRC)}
put(R/"A42_APPROACH_18JOINT_3F_SPEC.json",plan)
lock=R/"A42_PROVIDER_SUBMISSION_LOCK.json"
if lock.exists():print("A42_LOCK_EXISTS_SKIP");sys.exit(0)
before=balance(key());assert before.get("status")=="active" and before["generations"]>20
payload={"description":"same white-haired spiky Q chibi 1:1 big-head fantasy fighter, detailed teal gold armor, both hands empty no built-in weapon",
 "action":"moving to close attack, in-place short approach step","direction":"south-east","view":"low top-down",
 "first_frame":{"type":"base64","base64":base64.b64encode(SRC.read_bytes()).decode(),"format":"png"},
 "first_frame_keypoints":poses[0],"keypoints":poses,"template_id":"mannequin","seed":42110101,"no_background":True}
rec={"stage":"A42","status":"LOCK_BEFORE_API","endpoint":"/animate-with-skeleton-v3","before":before,
"source_sha":sha(SRC),"pose_plan_sha":sha(R/"A42_APPROACH_18JOINT_3F_SPEC.json"),"total_frames":3,"direction":"south-east","attempts":1}
put(lock,rec)
status,resp=api(key(),"/animate-with-skeleton-v3",payload)
job=resp.get("background_job_id") if isinstance(resp,dict) else None
rec.update({"http":status,"job_id":job})
if status not in (200,201,202) or not job:
 rec.update({"status":"REJECTED_NO_RESEND","error":str(resp)[:700]});put(lock,rec);print("A42_REJECT",status,str(resp)[:350]);sys.exit(0)
rec["status"]="ACCEPTED";put(lock,rec)
print("A42_REAL_PIXEL_LAB_APPROACH_JOB",job,flush=True)
for i in range(95):
 time.sleep(4)
 code,obj=api(key(),"/background-jobs/"+job)
 if code!=200:continue
 st=obj.get("status")
 if i%5==0:print("POLL",i,st,flush=True)
 if st in ("error","failed","canceled"):
  rec.update({"status":"JOB_FAILED_NO_RESEND","provider_status":st});put(lock,rec);sys.exit(0)
 if st not in ("completed","succeeded","success"):continue
 last=obj.get("last_response") or {}
 arr=last.get("images") or obj.get("images")
 if not isinstance(arr,list) or len(arr)!=3:
  rec.update({"status":"WRONG_FRAME_COUNT","count":len(arr) if isinstance(arr,list) else None});put(lock,rec);sys.exit(0)
 images=[]
 for j,x in enumerate(arr):
  q=x.get("image",x) if isinstance(x,dict) else x
  if isinstance(q,dict):q=q.get("base64")
  if q.startswith("data:"):q=q.split(",",1)[1]
  im=Image.open(io.BytesIO(base64.b64decode(q))).convert("RGBA")
  assert im.size==(40,40)
  im.save(R/f"A42_REAL_PIXELLAB_APPROACH_F{j:02}.png");images.append(im)
 sheet=Image.new("RGBA",(120,40))
 for j,img in enumerate(images):sheet.alpha_composite(img,(j*40,0))
 out=R/"A42_PROVIDER_REAL_3F_APPROACH_120x40.png";sheet.save(out)
 after=balance(key())
 rec.update({"status":"THREE_REAL_FRAMES_RETURNED_ART_QA_PENDING","provider_billing":last.get("billing_usage"),
 "bbox":[im.getbbox() for im in images],"output_sha":sha(out),"after":after})
 put(lock,rec)
 print("A42_REAL_APPROACH_DONE",rec["bbox"],"BAL",after["generations"],"BILL",rec["provider_billing"],flush=True);sys.exit(0)
rec["status"]="POLL_LIMIT_NO_RESEND";put(lock,rec)
