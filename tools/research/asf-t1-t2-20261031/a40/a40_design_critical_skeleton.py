"""A40 source-first 18-joint 3-pose skeleton plan.
All pose points derive from actual PixelLab /estimate-skeleton of the genuine FS 45deg
A34 40px sprite. Only pose coordinates are manipulated; no raster sprite is painted.
Frame count fixed to 3. Heavy hit ends with staggers/holds, not a normal stand-up recovery.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json,hashlib
B=Path(r"E:\GameAssetToolLab_20261023")
R=B/"A40_CRITICAL_DAMAGE_SKELETON_CONTROL_20261101"
d=json.loads((R/"A40_ESTIMATED_NATIVE_BATTLE_SKELETON.json").read_text(encoding="utf8"))
src=Image.open(B/"A34_FS_BATTLE45_F0_CORRECTION_20261101"/"A34_REAL_BATTLE_45_REFERENCE_MASTER_00.png").convert("RGBA")
base={x["label"]:{"label":x["label"],"x":round(x["x"],5),"y":round(x["y"],5),"z_index":round(x["z_index"])} for x in d["points"]}
assert len(base)==18
labels=list(base)
def pose(stage):
 p={k:dict(v) for k,v in base.items()}
 def change(label,dx=0,dy=0,x=None,y=None):
  v=p[label];v["x"]=round(min(.98,max(.02,(v["x"]+dx if x is None else x))),5)
  v["y"]=round(min(.98,max(.02,(v["y"]+dy if y is None else y))),5)
 head={"NOSE","LEFT EYE","RIGHT EYE","LEFT EAR","RIGHT EAR"}
 shoulders={"NECK","LEFT SHOULDER","RIGHT SHOULDER"}
 hips={"LEFT HIP","RIGHT HIP"}
 if stage==1: # winded: slight recoil with shoulders and forearms raised; feet steady
  for label in head:change(label,dx=-.025,dy=.017)
  for label in shoulders:change(label,dx=-.03,dy=.028)
  for label in hips:change(label,dx=.018,dy=.022)
  for label in ["LEFT ELBOW","RIGHT ELBOW"]:change(label,dx=-.03,dy=-.03)
  change("LEFT ARM",dx=-.065,dy=-.070)
  change("RIGHT ARM",dx=.065,dy=-.075)
  change("LEFT KNEE",dx=.025,dy=.02)
  change("RIGHT KNEE",dx=-.025,dy=.025)
 if stage==2: # CRITICAL severity: full trunk leftward tilt and buckled knees, both boots planted
  for label in head:change(label,dx=-.083,dy=.068)
  for label in shoulders:change(label,dx=-.082,dy=.065)
  for label in hips:change(label,dx=.02,dy=.052)
  change("LEFT ELBOW",dx=-.07,dy=.014)
  change("RIGHT ELBOW",dx=.005,dy=-.035)
  change("LEFT ARM",dx=-.065,dy=-.070)
  change("RIGHT ARM",dx=.07,dy=-.070)
  change("LEFT KNEE",dx=.07,dy=.018)
  change("RIGHT KNEE",dx=-.070,dy=.043)
  change("LEFT LEG",dx=.035,dy=0)
  change("RIGHT LEG",dx=-.04,dy=0)
 return [p[label] for label in labels]
arr=[pose(i) for i in range(3)]
# Check feet remain stable & torso really tilts, not just face/emotion.
pos=lambda frame,key:next(x for x in frame if x["label"]==key)
assert abs(pos(arr[2],"LEFT LEG")["y"]-pos(arr[0],"LEFT LEG")["y"])<.00001
assert pos(arr[2],"LEFT HIP")["y"]-pos(arr[0],"LEFT HIP")["y"]>.04
assert pos(arr[2],"NECK")["x"]-pos(arr[0],"NECK")["x"]<-.07
assert all(0<=x["x"]<=1 and 0<=x["y"]<=1 for fr in arr for x in fr)
def line(image,points,color):
 d=ImageDraw.Draw(image)
 lab={p["label"]:p for p in points}
 segments=[("LEFT EYE","NOSE"),("RIGHT EYE","NOSE"),("NOSE","NECK"),("NECK","LEFT SHOULDER"),("NECK","RIGHT SHOULDER"),
 ("LEFT SHOULDER","LEFT ELBOW"),("LEFT ELBOW","LEFT ARM"),("RIGHT SHOULDER","RIGHT ELBOW"),("RIGHT ELBOW","RIGHT ARM"),
 ("LEFT SHOULDER","LEFT HIP"),("RIGHT SHOULDER","RIGHT HIP"),("LEFT HIP","RIGHT HIP"),("LEFT HIP","LEFT KNEE"),("LEFT KNEE","LEFT LEG"),
 ("RIGHT HIP","RIGHT KNEE"),("RIGHT KNEE","RIGHT LEG")]
 for u,v in segments:
  a=lab[u];b=lab[v]
  d.line([(a["x"]*40,a["y"]*40),(b["x"]*40,b["y"]*40)],fill=color,width=1)
 for p in points:
  x=round(p["x"]*40);y=round(p["y"]*40);d.ellipse((x-1,y-1,x+1,y+1),fill=color)
try:F=ImageFont.truetype(r"C:\Windows\Fonts\arial.ttf",19)
except:F=ImageFont.load_default()
canvas=Image.new("RGB",(3*320,370),(239,242,246))
d=ImageDraw.Draw(canvas)
for k,name in enumerate(["F0 ORIGINAL STANCE","F1 INITIAL RECOIL","F2 CRITICAL COLLAPSE"]):
 q=Image.new("RGBA",(40,40),(239,242,246,255));q.alpha_composite(src)
 line(q,arr[k],[(30,130,225,255),(230,120,20,255),(185,60,48,255)][k])
 canvas.paste(q.convert("RGB").resize((292,292),Image.Resampling.NEAREST),(320*k+12,42))
 d.text((320*k+12,10),name,font=F,fill=(20,35,54))
canvas.save(R/"A40_ACTUAL_18JOINT_CRITICAL_POSE_QA.png",optimize=True)
rec={"source":str(B/"A34_FS_BATTLE45_F0_CORRECTION_20261101"/"A34_REAL_BATTLE_45_REFERENCE_MASTER_00.png"),"joint_labels":labels,"keyframes":arr,
 "geometry":[40,40],"real_estimation_count":len(base),
 "source":"A34 actual PixelLab battle-facing character plus PixelLab /estimate-skeleton 18 points",
 "direction":"south-east","view":"low top-down",
 "frames_requested":3,"need_foot_contact":True,
 "critical_differences":"F2 shoulder x shifts -.082 and y+.065; hips shift y+.052, knees bend/spread, boots planted; not merely facial change",
 "renderer_note":"skeleton overlay is a diagnostic visualization ONLY; the intended sprite art must come from real PixelLab"}
(R/"A40_CRITICAL_3POSE_18JOINT_CONTROL.json").write_text(json.dumps(rec,ensure_ascii=False,indent=2),encoding="utf8")
print("POSE_CONTROL_DONE",len(arr),"Joints",len(labels),"PREVIEW",R/"A40_ACTUAL_18JOINT_CRITICAL_POSE_QA.png")
