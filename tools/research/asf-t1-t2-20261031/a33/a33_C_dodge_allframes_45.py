"""A33 R1-C coherent 45-degree battle-view correction of true screenshot-pose Outfit Transfer.
Do not redraw new pose sequence. Edit all three PixelLab B frames TOGETHER.
"""
from pathlib import Path
from PIL import Image
import json,hashlib,base64,time,io,sys
BASE=Path(r"E:\GameAssetToolLab_20261023")
R=BASE/"A33_HUMANOID_DIRECT_POSE_20261101"
B=R/"B_DODGING_DIRECT_POSES"
OUT=R/"C_DODGE_45_CORRECTION"
OUT.mkdir(parents=True,exist_ok=True)
sys.path.insert(0,str(BASE/"A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST"))
from a23_one_paid_spritesheet_trial import api,key,balance
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(p,d):p.write_text(json.dumps(d,ensure_ascii=False,indent=2),encoding="utf8")
files=[B/f"PIXELLAB_B_DODGE_FRAME_{i:02}.png" for i in range(3)]
assert all(x.exists() for x in files)
last=json.loads((B/"SUBMISSION_LOCK.json").read_text(encoding="utf8"))
assert last["status"]=="THREE_REAL_FRAMES_RECEIVED_AWAITING_VISUAL_GATES"
lock=OUT/"SUBMISSION_LOCK.json"
if lock.exists():
 print("EXISTING_C_LOCK_SKIP");sys.exit(0)
before=balance(key());assert before["status"]=="active" and before["generations"]>15
description=(
 "Edit these EXACT THREE key pose frames as ONE coherent animation. "
 "The motion already works: first frame knees bend and torso leans, middle frame the whole body deeply crouches and ducks sideways, final frame rises into guard. "
 "DO NOT change the poses, leg and arm position sequence, crouching amplitude, animation timing or silhouette. "
 "ONLY normalize a consistent 45-degree SOUTHEAST three-quarter battle-facing view across face, head, both shoulder armor plates, chest and hips. "
 "We MUST see the front face plane and the side plane, not a 90 degree profile or full frontal face. "
 "Maintain same very big WHITE spiky head, tiny chibi 1:1 proportions and teal/bronze finely shaded armor. "
 "EVERY frame UNARMED and empty-handed with no weapon, blade, hilt, sheath, shield, bow, VFX or projectiles. "
 "Native transparent 40x40, no extra limbs, no detached pixels; do not add any fourth frame."
)
(OUT/"C_PROMPT.txt").write_text(description,encoding="utf8")
def enc(p):
 return {"image":{"type":"base64","base64":"data:image/png;base64,"+base64.b64encode(p.read_bytes()).decode(),"format":"png"},
         "size":{"width":40,"height":40}}
payload={"frames":[enc(x) for x in files],
 "description":description,"image_size":{"width":40,"height":40},"seed":33110110,"no_background":True}
log={"stage":"A33-R1-C","source_jobs":{"B":last["job_id"]},"source_sha256":[sha(x) for x in files],
 "endpoint":"/edit-animation-v2","status":"LOCKED_BEFORE_POST","attempts":1,"before":before}
save(lock,log)
print("C_SUBMIT 3 real B poses coherent view correction",flush=True)
s,resp=api(key(),"/edit-animation-v2",payload)
job=resp.get("background_job_id")
log.update({"http":s,"job_id":job})
if s not in (200,201,202) or not job:
 log.update({"status":"REJECTED_NO_RETRY","detail":str(resp)[:550]});save(lock,log)
 print("C_REJECT",s,str(resp)[:250],flush=True);sys.exit(0)
log["status"]="JOB_ACCEPTED";save(lock,log)
print("C_ACCEPTED_JOB",job,flush=True)
for poll in range(90):
 time.sleep(3)
 status,rs=api(key(),"/background-jobs/"+job)
 if status!=200:continue
 st=rs.get("status")
 if poll%5==0:print("POLL",poll,st,flush=True)
 if st in ("error","failed","canceled"):
  log.update({"status":"JOB_FAILED","state":st});save(lock,log);sys.exit(0)
 if st not in ("completed","success","succeeded"):continue
 last_response=rs.get("last_response") or {}
 arr=last_response.get("images") or last_response.get("edited_images") or rs.get("images")
 if not isinstance(arr,list) or len(arr)!=3:
  log.update({"status":"BAD_RESULT","keys":list(last_response)});save(lock,log);sys.exit(0)
 frames=[]
 for j,obj in enumerate(arr):
  v=obj.get("image",obj) if isinstance(obj,dict) else obj
  if isinstance(v,dict):v=v.get("base64")
  assert isinstance(v,str)
  if v.startswith("data:"):v=v.split(",",1)[1]
  im=Image.open(io.BytesIO(base64.b64decode(v))).convert("RGBA")
  assert im.size==(40,40)
  im.save(OUT/f"PIXELLAB_C_FRAME_{j:02}.png")
  frames.append(im)
 sheet=Image.new("RGBA",(120,40))
 for i,im in enumerate(frames):sheet.alpha_composite(im,(40*i,0))
 sheet.save(OUT/"PIXELLAB_C_DODGE_REAL_3F.png")
 frames[0].save(OUT/"PIXELLAB_C_DODGE_ONE_SHOT.gif",save_all=True,append_images=frames[1:],
 duration=[170,250,450],loop=1,disposal=2,optimize=False)
 after=balance(key())
 log.update({"status":"PROVIDER_REAL_C_FRAMES_ART_GATE_PENDING","after":after,
 "bboxes":[f.getbbox() for f in frames],"provider_billing":last_response.get("billing_usage"),
 "sha256":sha(OUT/"PIXELLAB_C_DODGE_REAL_3F.png")})
 save(lock,log)
 print("C_DONE",log["bboxes"],"BALANCE",after["generations"],"BILL",log["provider_billing"],flush=True)
 sys.exit(0)
log["status"]="POLL_LIMIT_DO_NOT_RESUBMIT";save(lock,log)
