"""A41 source-first NORMAL DAMAGE via true PixelLab 18-joint skeleton, exactly 3.
Contrast with A40 CRITICAL DAMAGE: moderate *brief* torso recoil then full return to guard.
No 90° source and no paid estimate repeat; reuse 18 real A40 estimated joints.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import base64,hashlib,io,json,sys,time
B=Path(r"E:\GameAssetToolLab_20261023")
R=B/"A41_NORMAL_DAMAGE_SKELETON_3F_20261101";R.mkdir(exist_ok=True)
A40=B/"A40_CRITICAL_DAMAGE_SKELETON_CONTROL_20261101"
SRC=B/"A34_FS_BATTLE45_F0_CORRECTION_20261101"/"A34_REAL_BATTLE_45_REFERENCE_MASTER_00.png"
sys.path.insert(0,str(B/"A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST"))
from a23_one_paid_spritesheet_trial import api,key,balance
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def put(p,x):p.write_text(json.dumps(x,ensure_ascii=False,indent=2),encoding="utf8")
assert SRC.exists() and Image.open(SRC).size==(40,40)
prior=json.loads((A40/"A40_CRITICAL_3POSE_18JOINT_CONTROL.json").read_text(encoding="utf8"))
orig=prior["keyframes"][0]
assert len(orig)==18
def stage(idx):
 p={e["label"]:dict(e) for e in orig}
 def shift(l,x=0,y=0):
  v=p[l];v["x"]=round(min(.98,max(.02,v["x"]+x)),5);v["y"]=round(min(.98,max(.02,v["y"]+y)),5)
 if idx==1:
  # moderate hit, shift shoulders with visible bracing, boots anchored.
  for l in ("NOSE","RIGHT EYE","LEFT EYE","RIGHT EAR","LEFT EAR"):shift(l,x=-.034,y=.021)
  for l in ("NECK","RIGHT SHOULDER","LEFT SHOULDER"):shift(l,x=-.043,y=.032)
  for l in ("LEFT HIP","RIGHT HIP"):shift(l,x=.003,y=.016)
  shift("LEFT ELBOW",x=-.037,y=-.018);shift("RIGHT ELBOW",x=.003,y=-.029)
  shift("LEFT ARM",x=-.083,y=-.075);shift("RIGHT ARM",x=.052,y=-.063)
  shift("LEFT KNEE",x=.020,y=.014);shift("RIGHT KNEE",x=-.021,y=.016)
 if idx==2:
  # F2 precisely the same skeletal stance as source F0.
  pass
 return [p[e["label"]] for e in orig]
poses=[stage(i) for i in range(3)]
assert all(len(p)==18 for p in poses)
assert poses[0]==poses[2]
def axis(frame,label):
 return next(x for x in frame if x["label"]==label)
assert -.05 < axis(poses[1],"NECK")["x"]-axis(poses[0],"NECK")["x"] < -.03
assert 0 < axis(poses[1],"LEFT HIP")["y"]-axis(poses[0],"LEFT HIP")["y"] < .025
control={"stage":"A41","goal":"Normal damage three frames distinct from A40 severe damage",
"authoritative_source":str(SRC),"authoritative_sha256":sha(SRC),
"from_real_pixelLab_skeleton":"A40 /estimate-skeleton verified 18 labeled joints",
"poses":poses,"source_cam":"south-east", "frames_requested":3,
"camera_view":"low top-down","no_weapon":True,
"animation":"F0 guard, F1 moderate recoil (torso neck -.043x, hip +.016y), F2 exact guard recovery",
"comparison_A40":"A40 severe frame2 has collapse, knee spread, and lower shoulders; A41 F2 recovers fully"}
put(R/"A41_NORMAL_DAMAGE_18JOINT_CONTROL.json",control)
# Strict source provenance before real cost.
lock=R/"A41_DAMAGE_SKELETON_V3_SUBMISSION_LOCK.json"
if lock.exists():print("LOCK_EXISTS_NO_REPOST");sys.exit(0)
start=balance(key())
assert start["status"]=="active" and float(start["generations"])>20
payload={"description":"white-haired spiky Q-chibi 1:1 head-body ratio fantasy warrior, teal green detailed gold-trim armor, two empty hands, no weapons",
"action":"damage recoil and recover","direction":"south-east","view":"low top-down",
"first_frame":{"type":"base64","base64":base64.b64encode(SRC.read_bytes()).decode("ascii"),"format":"png"},
"first_frame_keypoints":poses[0],"keypoints":poses,"template_id":"mannequin","seed":41110101,"no_background":True}
rec={"stage":"A41","status":"LOCKED_BEFORE_POST","endpoint":"/animate-with-skeleton-v3",
"source_sha":sha(SRC),"skeleton_sha":sha(R/"A41_NORMAL_DAMAGE_18JOINT_CONTROL.json"),
"frame_count":3,"joints_each":18,"angle":"south-east","before":start,"attempts":1}
put(lock,rec)
status,response=api(key(),"/animate-with-skeleton-v3",payload)
job=response.get("background_job_id") if isinstance(response,dict) else None
rec.update({"http":status,"job_id":job})
if status not in (200,201,202) or not job:
 rec.update({"status":"REJECTED_NO_RETRY","error":str(response)[:600]});put(lock,rec)
 print("A41_REJECTED",status,str(response)[:420],flush=True);sys.exit(0)
rec["status"]="JOB_ACCEPTED";put(lock,rec)
print("A41_REAL_PIXEL_LAB_NORMAL_DAMAGE_JOB",job,flush=True)
for i in range(100):
 time.sleep(4)
 code,data=api(key(),"/background-jobs/"+job)
 if code!=200:continue
 state=data.get("status")
 if i%5==0:print("POLL",i,state,flush=True)
 if state in ("error","failed","canceled"):
  rec.update({"status":"PROVIDER_JOB_FAILED_DO_NOT_RESUBMIT","provider_state":state});put(lock,rec);sys.exit(0)
 if state not in ("completed","succeeded","success"):continue
 last=data.get("last_response") or {}
 arr=last.get("images") or data.get("images")
 if not isinstance(arr,list) or len(arr)!=3:
  rec.update({"status":"WRONG_RETURN_COUNT","count":len(arr) if isinstance(arr,list) else None});put(lock,rec)
  print("WRONG_COUNT",rec["count"]);sys.exit(0)
 imgs=[]
 for j,item in enumerate(arr):
  v=item.get("image",item) if isinstance(item,dict) else item
  if isinstance(v,dict):v=v.get("base64")
  if not isinstance(v,str):
   rec.update({"status":"INVALID_IMAGE_DATA","index":j});put(lock,rec);sys.exit(0)
  if v.startswith("data:"):v=v.split(",",1)[1]
  f=Image.open(io.BytesIO(base64.b64decode(v))).convert("RGBA")
  if f.size!=(40,40):
   rec.update({"status":"WRONG_IMAGE_SIZE","index":j,"size":list(f.size)});put(lock,rec);sys.exit(0)
  f.save(R/f"A41_REAL_SKELETON_V3_DAMAGE_FRAME_{j:02}.png");imgs.append(f)
 sheet=Image.new("RGBA",(120,40))
 for j,f in enumerate(imgs):sheet.alpha_composite(f,(j*40,0))
 p=R/"A41_REAL_PIXEL_LAB_RAW_DAMAGE_3FRAME_120x40.png";sheet.save(p)
 after=balance(key())
 rec.update({"status":"PROVIDER_REAL_3_FRAMES_READY_VISUAL_QA","bboxes":[f.getbbox() for f in imgs],
 "provider_billing":last.get("billing_usage"),"after":after,"output_sha":sha(p)})
 put(lock,rec)
 print("A41_REAL_FRAMES_SAVED",rec["bboxes"],"COST",rec["provider_billing"],"BAL",after["generations"],flush=True);sys.exit(0)
rec["status"]="POLL_LIMIT_DO_NOT_REPOST";put(lock,rec)
