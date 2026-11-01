"""A41-R2 normal damage restricted 18-joint pose trial.
A41-R1 F1 failed semantically: arms extended like attack. This trial explicitly bounds wrists
inside the shoulder span and confines elbows. Exactly 3 real PixelLab V3 frames.
"""
from pathlib import Path
from PIL import Image
import base64,io,json,hashlib,sys,time
B=Path(r"E:\GameAssetToolLab_20261023")
ROOT=B/"A41_NORMAL_DAMAGE_SKELETON_3F_20261101"
R=ROOT/"R2_HANDS_IN_GUARD";R.mkdir(exist_ok=True)
A40=B/"A40_CRITICAL_DAMAGE_SKELETON_CONTROL_20261101"
SRC=B/"A34_FS_BATTLE45_F0_CORRECTION_20261101"/"A34_REAL_BATTLE_45_REFERENCE_MASTER_00.png"
sys.path.insert(0,str(B/"A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST"))
from a23_one_paid_spritesheet_trial import key,api,balance
def save(p,v):p.write_text(json.dumps(v,indent=2,ensure_ascii=False),encoding='utf8')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
base=json.loads((A40/"A40_CRITICAL_3POSE_18JOINT_CONTROL.json").read_text(encoding="utf8"))["keyframes"][0]
assert len(base)==18
def stage(i):
 p={q["label"]:dict(q) for q in base}
 def edit(l,dx=0,dy=0,x=None,y=None):
  q=p[l]
  q["x"]=round(max(.02,min(.98,dx+q["x"] if x is None else x)),5)
  q["y"]=round(max(.02,min(.98,dy+q["y"] if y is None else y)),5)
 if i==1:
  for label in ("NOSE","LEFT EYE","RIGHT EYE","LEFT EAR","RIGHT EAR"):edit(label,dx=-.034,dy=.016)
  for label in ("NECK","LEFT SHOULDER","RIGHT SHOULDER"):edit(label,dx=-.040,dy=.024)
  for label in ("LEFT HIP","RIGHT HIP"):edit(label,dy=.022)
  edit("LEFT ELBOW",x=.64,y=.703)
  edit("RIGHT ELBOW",x=.416,y=.692)
  edit("LEFT ARM",x=.571,y=.712)
  edit("RIGHT ARM",x=.480,y=.717)
  edit("LEFT KNEE",dx=.024,dy=.013)
  edit("RIGHT KNEE",dx=-.020,dy=.013)
 return [p[q["label"]] for q in base]
frames=[stage(i) for i in range(3)]
assert len(frames)==3 and frames[0]==frames[2]
get=lambda d,n:next(x for x in d if x["label"]==n)
for hand in ["LEFT ARM","RIGHT ARM"]:
 x=get(frames[1],hand)["x"]
 assert .45<=x<=.60,(hand,x)
def vec(l):return [(get(f,l)["x"],get(f,l)["y"]) for f in frames]
control={"stage":"A41-R2","reason":"R1 arms extended horizontally like attack; preserve empty hands near torso",
 "frames":frames,"input_sha":sha(SRC),"joints_each":18,"exact3":True,
 "left_arm_xy":vec("LEFT ARM"),"right_arm_xy":vec("RIGHT ARM"),
 "neck_xy":vec("NECK"),"hips_xy":[vec("LEFT HIP"),vec("RIGHT HIP")],
 "camera":"south-east","source":"A34 actual native FS battle master and A40 real 18-joint PixelLab estimate"}
save(R/"A41_R2_RESTRICTED_GUARD_18JOINT.json",control)
lock=R/"SUBMISSION_LOCK.json"
if lock.exists():print("R2_LOCK_EXISTS_NO_REPOST");sys.exit(0)
bal=balance(key());assert bal.get("status")=="active" and bal["generations"]>20
payload={"description":"same original white-spiky-haired chibi 1:1 big-head small-body adventurer, richly shaded dark teal green gold armor, empty hands, no weapons",
 "action":"damage hit flinch, hands held near torso","direction":"south-east","view":"low top-down",
 "first_frame":{"type":"base64","base64":base64.b64encode(SRC.read_bytes()).decode(),"format":"png"},
 "first_frame_keypoints":frames[0],"keypoints":frames,"template_id":"mannequin",
 "seed":41110112,"no_background":True}
rec={"stage":"A41-R2","status":"LOCK_BEFORE_POST","endpoint":"/animate-with-skeleton-v3",
"source_sha":sha(SRC),"18_joint_pose_sha":sha(R/"A41_R2_RESTRICTED_GUARD_18JOINT.json"),
"frames":3,"retries":0,"before":bal}
save(lock,rec)
status,rs=api(key(),"/animate-with-skeleton-v3",payload)
job=rs.get("background_job_id") if isinstance(rs,dict) else None
rec.update({"http":status,"job_id":job})
if status not in (200,201,202) or not job:
 rec.update({"status":"REJECTED_NO_REPEAT","provider_error":str(rs)[:700]});save(lock,rec);print("REJECT",status,str(rs)[:300]);sys.exit(0)
rec["status"]="ACCEPTED";save(lock,rec)
print("A41_R2_REAL_SKELETON_JOB",job,flush=True)
for i in range(95):
 time.sleep(4)
 code,obj=api(key(),"/background-jobs/"+job)
 if code!=200:continue
 st=obj.get("status")
 if i%5==0:print("POLL",i,st,flush=True)
 if st in ("error","failed","canceled"):
  rec.update({"status":"REMOTE_FAILED","remote":st});save(lock,rec);sys.exit(0)
 if st not in ("completed","succeeded","success"):continue
 last=obj.get("last_response") or {}
 arr=last.get("images") or obj.get("images")
 if not isinstance(arr,list) or len(arr)!=3:
  rec.update({"status":"INVALID_FRAME_COUNT","count":len(arr) if isinstance(arr,list) else None});save(lock,rec);sys.exit(0)
 images=[]
 for j,x in enumerate(arr):
  item=x.get("image",x) if isinstance(x,dict) else x
  if isinstance(item,dict):item=item.get("base64")
  if item.startswith("data:"):item=item.split(",",1)[1]
  img=Image.open(io.BytesIO(base64.b64decode(item))).convert("RGBA")
  assert img.size==(40,40)
  img.save(R/f"PIXELLAB_R2_DAMAGE_F{j}.png");images.append(img)
 sheet=Image.new("RGBA",(120,40))
 for j,img in enumerate(images):sheet.alpha_composite(img,(40*j,0))
 out=R/"PIXELLAB_R2_RAW_DAMAGE_3FRAME.png";sheet.save(out)
 end=balance(key())
 rec.update({"status":"REAL_THREE_FRAMES_RETURNED_ART_QA_PENDING","frames":3,"bbox":[im.getbbox() for im in images],
 "provider_billing":last.get("billing_usage"),"balance_after":end,"output_sha":sha(out)})
 save(lock,rec)
 print("R2_REAL_FRAMES_READY",rec["bbox"],"BAL",end["generations"],"BILL",rec["provider_billing"],flush=True);sys.exit(0)
rec["status"]="POLL_LIMIT_NO_REPOST";save(lock,rec)
