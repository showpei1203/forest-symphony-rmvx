"""A34 two authentic FS actor01_1 battle-view keyframe inputs (PixelLab transfer requires >=2).
The preceding 1-frame job was HTTP 422 (not charged) and locked as rejected.
"""
from pathlib import Path
from PIL import Image
import sys,io,time,base64,json,hashlib,shutil
B=Path(r"E:\GameAssetToolLab_20261023");R=B/"A34_FS_BATTLE45_F0_CORRECTION_20261101"
S=Path(r"E:\RPG MAKER\260724桌面\rpg maker 2024\RPG MAKER\綠曲-V2.9\Graphics\Characters\$actor01_1.png")
APP=B/"A31_FS_ORIGINAL_MOTION_TRANSFER_20261101"/"A31_SE45_ORIGINAL_POLICY_STATIC_IDLE.png"
sys.path.insert(0,str(B/"A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST"))
from a23_one_paid_spritesheet_trial import api,key,balance
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def write(p,v):p.write_text(json.dumps(v,indent=2,ensure_ascii=False),encoding='utf8')
L=R/"A34_R2_TWONATIVE_SUBMISSION_LOCK.json"
if L.exists():print("LOCK_EXISTS_NO_POST");sys.exit(0)
prior=json.loads((R/"A34_VIEW_MASTER_SUBMISSION_LOCK.json").read_text(encoding="utf8"))
assert prior["http"]==422 and prior["status"]=="REJECTED_NO_RETRY"
src=Image.open(S).convert("RGBA");assert src.size==(96,128)
files=[]
for i,row in enumerate([1,2]):
 tile=src.crop((32,row*32,64,(row+1)*32))
 pad=Image.new("RGBA",(40,40));pad.alpha_composite(tile,(4,6))
 path=R/f"A34_NATIVE_ACTOR01_1_ROW{row}_C1_ORIGINAL_40.png";pad.save(path);files.append(path)
def pic(path):return {"image":{"type":"base64","base64":"data:image/png;base64,"+base64.b64encode(path.read_bytes()).decode(),"format":"png"},"size":{"width":40,"height":40}}
prompt=("AUTHORITY: both frames are genuine pixel positions from the original Forest Symphony $actor01_1 "
"front diagonal battle action, not the prior side-view A33 dodge. KEEP EXACT camera facing of the input face with "
"two visible eye planes, clear frontal face plane AND nearer shoulder depth. Keep each input body pose as reference. "
"Transfer character appearance ONLY from reference: white spiky chibi hair, white-haired same identity, "
"dark teal-green rich armor, gold accents, short 1:1 head/body ratio. "
"STRIP all baked-in weapons, glowing blue effect sprites, sword, scabbard, hilt, shield and bow. "
"Empty hands as paper-doll SBS weapon system. No new poses. Transparent 40x40 native pixel output. "
"Never rotate face back toward full 90-degree side profile or morph to a 1:3-tall character.")
(R/"A34_R2_TWONATIVE_PROMPT.txt").write_text(prompt,encoding="utf8")
before=balance(key());assert before["status"]=="active" and float(before["generations"])>20
req={"reference_image":pic(APP),"frames":[pic(p) for p in files],"image_size":{"width":40,"height":40},
     "additional_instructions":prompt,"seed":34110112,"no_background":True}
log={"stage":"A34","status":"PREPOST_LOCK","http_previous":422,"input_source_sha256":sha(S),
 "native_frame_sha256":[sha(p) for p in files],"identity_sha256":sha(APP),
 "source_faces":"$actor01_1 r1 c1 and r2 c1 as actual pixel-art view refs",
 "before":before,"attempts":1};write(L,log)
s,o=api(key(),"/transfer-outfit-v2",req)
job=o.get("background_job_id") if isinstance(o,dict) else None
log.update({"http":s,"job_id":job})
if s not in (200,201,202) or not job:
 log.update({"status":"REJECTED_NO_RETRY","error":str(o)[:550]});write(L,log);print("REJECTED",s,str(o)[:240]);sys.exit(0)
log["status"]="ACCEPTED";write(L,log)
print("REAL_PIXELLAB_A34_R2_JOB",job,flush=True)
for t in range(90):
 time.sleep(4)
 c,d=api(key(),"/background-jobs/"+job)
 if c!=200:continue
 st=d.get("status")
 if t%6==0:print("POLL",t,st,flush=True)
 if st in ("failed","error","canceled"):
  log.update({"status":"FAILED_NO_RETRY","remote_status":st});write(L,log);sys.exit(0)
 if st not in ("completed","success","succeeded"):continue
 last=d.get("last_response") or {}
 arr=last.get("images") or d.get("images")
 if not isinstance(arr,list) or len(arr)!=2:
  log.update({"status":"BAD_IMAGES_NO_RETRY","count":len(arr) if isinstance(arr,list) else -1});write(L,log);sys.exit(0)
 frames=[]
 for j,obj in enumerate(arr):
  v=obj.get("image",obj) if isinstance(obj,dict) else obj
  if isinstance(v,dict):v=v.get("base64")
  if v.startswith("data:"):v=v.split(",",1)[1]
  im=Image.open(io.BytesIO(base64.b64decode(v))).convert("RGBA")
  assert im.size==(40,40)
  p=R/f"A34_REAL_BATTLE_45_REFERENCE_MASTER_{j:02}.png";im.save(p);frames.append(im)
 strip=Image.new("RGBA",(80,40))
 for i,im in enumerate(frames):strip.alpha_composite(im,(i*40,0))
 strip.save(R/"A34_REAL_NATIVE_BATTLE_REFERENCE_MASTERS_2FRAME.png")
 after=balance(key())
 log.update({"status":"REAL_PIXELLAB_BATTLE_MASTERS_ART_REVIEW_PENDING","after":after,
             "bboxes":[f.getbbox() for f in frames],"billing":last.get("billing_usage"),
             "sheet_sha256":sha(R/"A34_REAL_NATIVE_BATTLE_REFERENCE_MASTERS_2FRAME.png")})
 write(L,log)
 print("DONE",log["bboxes"],"BILL",log["billing"],"BALANCE",after["generations"],flush=True);sys.exit(0)
log["status"]="POLL_LIMIT_NO_RETRY";write(L,log)
