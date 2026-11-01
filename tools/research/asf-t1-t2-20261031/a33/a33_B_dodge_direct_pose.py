"""A33 R1-B: REAL reference pixels from user 16-action image, three Dodging keyframes.
Single paid PixelLab /transfer-outfit-v2, source-first, one charge at most.
"""
from pathlib import Path
from PIL import Image
import hashlib,base64,json,time,io,sys,shutil
BASE=Path(r"E:\GameAssetToolLab_20261023")
ROOT=BASE/"A33_HUMANOID_DIRECT_POSE_20261101"
REF=ROOT/"REFERENCE_SOURCE"
OUT=ROOT/"B_DODGING_DIRECT_POSES"
OUT.mkdir(parents=True,exist_ok=True)
sys.path.insert(0,str(BASE/"A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST"))
from a23_one_paid_spritesheet_trial import api,key,balance
ACTOR=BASE/"A31_FS_ORIGINAL_MOTION_TRANSFER_20261101"/"A31_SE45_ORIGINAL_POLICY_STATIC_IDLE.png"
assert ACTOR.exists()
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(p,obj):p.write_text(json.dumps(obj,ensure_ascii=False,indent=2),encoding="utf8")
def img_ref(p):
 data=p.read_bytes()
 return {"image":{"type":"base64","base64":"data:image/png;base64,"+base64.b64encode(data).decode(),"format":"png"},"size":{"width":40,"height":40}}
posefiles=[]
for idx in range(3):
 source=Image.open(REF/f"DODGE{idx}.png").convert("RGBA")
 assert source.size==(32,32)
 target=Image.new("RGBA",(40,40));target.alpha_composite(source,(4,6))
 q=OUT/f"DODGE_POSE_FROM_USER_{idx}.png";target.save(q)
 posefiles.append(q)
shutil.copy2(ACTOR,OUT/"APPROVED_FS_CHARACTER_40.png")
frame0=Image.open(ACTOR).convert("RGBA")
assert frame0.size==(40,40)
lock=OUT/"SUBMISSION_LOCK.json"
if lock.exists():print("EXISTING_LOCK_STOP_NO_DUPLICATE");sys.exit(0)
before=balance(key())
assert before["status"]=="active" and float(before["generations"])>=15, before
instructions=(
 "The THREE FRAME PIXELS are the authoritative humanoid DODGING KEY POSES, in order. "
 "Frame 0: low defensive lean to screen-left, knees bent; Frame 1: full deep lateral crouch/evade to left, "
 "torso and head clearly lowered and hip shifted; Frame 2: rise to guarded recovery. "
 "Keep distinct frame poses: never turn it into ordinary walking or shoulder shaking. "
 "Only transfer approved WHITE SPIKY HAIR, same face, teal/gold intricate armor and small chibi 1:1 head/body proportions "
 "from the reference portrait. The reference portrait is the CHARACTER IDENTITY, never copy its static stance instead of input poses. "
 "Exactly ONE human with empty fists: NO weapon, hilt, sheath, bow, shield, projectile or VFX in any frame. "
 "Consistent southeast 45 degree battle view, face AND chest/hips rotated, not pure 90 degree profile. "
 "Each frame transparent native 40x40 pixels. No redraw of pose sequence, no extra limbs."
)
(OUT/"B_PROMPT.txt").write_text(instructions,encoding="utf8")
request={"reference_image":img_ref(ACTOR),"frames":[img_ref(p) for p in posefiles],
         "image_size":{"width":40,"height":40},"seed":33110109,
         "no_background":True,"additional_instructions":instructions}
log={"phase":"A33-R1-B","action":"DODGING","source":"user screenshot 3 exact pixel poses, palette-preserved",
     "posed_sha256":[sha(p) for p in posefiles],"character_sha256":sha(ACTOR),
     "endpoint":"/transfer-outfit-v2","status":"LOCKED_BEFORE_API","max_submissions":1,"before":before}
save(lock,log)
print("SUBMIT real 3 screenshot poses",flush=True)
status,obj=api(key(),"/transfer-outfit-v2",request)
job=obj.get("background_job_id") if isinstance(obj,dict) else None
log.update({"http":status,"job_id":job,"usage":obj.get("usage") if isinstance(obj,dict) else None})
if status not in (200,201,202) or not job:
 log.update({"status":"API_REJECTED_NO_RETRY","brief":str(obj)[:550]});save(lock,log)
 print("POST_REJECT",status,str(obj)[:320],flush=True);sys.exit(0)
log["status"]="PROVIDER_ACCEPTED";save(lock,log)
print("ACCEPTED_JOB",job,flush=True)
for n in range(100):
 time.sleep(3)
 s,data=api(key(),"/background-jobs/"+job)
 if s!=200:continue
 st=data.get("status")
 if n%5==0:print("POLL",n,st,flush=True)
 if st in ("failed","error","canceled"):
  log.update({"status":"JOB_FAILED_NO_RETRY","provider_status":st});save(lock,log);sys.exit(0)
 if st not in ("completed","success","succeeded"):continue
 last=data.get("last_response") or {}
 arr=last.get("images") or last.get("edited_images") or data.get("images")
 if not isinstance(arr,list) or len(arr)!=3:
  log.update({"status":"UNEXPECTED_RESULT_NO_RETRY","last_keys":list(last),"count":len(arr) if isinstance(arr,list) else None});save(lock,log);sys.exit(0)
 ims=[]
 for i,x in enumerate(arr):
  val=x.get("image",x) if isinstance(x,dict) else x
  if isinstance(val,dict):val=val.get("base64")
  assert isinstance(val,str)
  if val.startswith("data:"):val=val.split(",",1)[1]
  im=Image.open(io.BytesIO(base64.b64decode(val))).convert("RGBA")
  if im.size!=(40,40):
   log.update({"status":"BAD_NATIVE_FRAME_SIZE","size":im.size});save(lock,log);sys.exit(0)
  im.save(OUT/f"PIXELLAB_B_DODGE_FRAME_{i:02}.png");ims.append(im)
 strip=Image.new("RGBA",(120,40))
 for i,im in enumerate(ims):strip.alpha_composite(im,(i*40,0))
 strip.save(OUT/"PIXELLAB_B_DODGE_REAL_3POSE_SHEET.png")
 ims[0].save(OUT/"PIXELLAB_B_DODGE_ONESHOT.gif",save_all=True,append_images=ims[1:],duration=[170,250,450],
            loop=1,disposal=2,optimize=False)
 after=balance(key())
 log.update({"status":"THREE_REAL_FRAMES_RECEIVED_AWAITING_VISUAL_GATES","after":after,
  "provider_billing":last.get("billing_usage"),"bboxes":[im.getbbox() for im in ims],
  "spritesheet_sha256":sha(OUT/"PIXELLAB_B_DODGE_REAL_3POSE_SHEET.png")})
 save(lock,log)
 print("B_COMPLETE",log["bboxes"],"billing",log["provider_billing"],"balance",after["generations"],flush=True)
 sys.exit(0)
log["status"]="POLL_LIMIT_DO_NOT_REPOST";save(lock,log)
