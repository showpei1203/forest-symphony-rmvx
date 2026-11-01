"""A29 Pilot: PixelLab Pixen edits already-approved native chibi source to SE 45 deg + UNARMED.
One paid concept-only request. No source overwrites, no fake image generation. 
"""
from pathlib import Path
from PIL import Image
from io import BytesIO
import sys,base64,json,time,hashlib,shutil
BASE=Path(r"E:\GameAssetToolLab_20261023")
A23=BASE/"A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST"
APPROVED=BASE/"A26_PMD0001_APPROVED_SHEETS_FS_RATIO_REPAIR_20261101"/"FS_NATIVE_PIXEN_RATIO_FIX"/"PIXEL_LAB_FS_NATIVE_RATIO_CANDIDATE_40.png"
ROOT=BASE/"A29_FS45_UNARMED_PIXELLAB_LOOP_20261101"
ROOT.mkdir(exist_ok=True)
sys.path.insert(0,str(A23))
from a23_one_paid_spritesheet_trial import key,balance,api
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def record(x): (ROOT/"CONCEPT_JOB.json").write_text(json.dumps(x,ensure_ascii=False,indent=2),encoding="utf8")
src=Image.open(APPROVED).convert('RGBA')
assert src.size==(40,40) and src.getbbox()==(9,4,32,38)
source_file=ROOT/"USER_APPROVED_A26_40x40_SOURCE.png"
shutil.copy2(APPROVED,source_file)
prompt=("Turn this SAME white-haired chibi into 45-degree southeast-facing 3/4 RPG battle pose: head, chest, hips and feet visibly diagonal down-right, not a side profile. "
"Remove ALL weapons entirely: both EMPTY clenched fists, no sword, blade, hilt, scabbard, sheath or shield. "
"Preserve exact face, 1:1 BIG HEAD/tiny body proportions, ~32px total height, detailed teal/brown layered armor, cape, clean transparent 40x40 pixels and feet margins. No cast shadow.")
assert len(prompt)<=500,(len(prompt),prompt)
(ROOT/"PIXELLAB_FINAL_PROMPT.txt").write_text(prompt,encoding="utf8")
lock=ROOT/"CONCEPT_JOB.json"
if lock.exists():
 print("EXISTING_LOCK_NO_REPOST");sys.exit(0)
b=balance(key());assert b['status']=='active' and float(b['generations'])>=15
payload={"image":{"type":"base64","base64":"data:image/png;base64,"+base64.b64encode(source_file.read_bytes()).decode(),"format":"png"},
"description":prompt,"width":40,"height":40,"seed":29110145,"no_background":True}
log={"status":"PRE_POST_LOCK_NO_RETRY","stage":"A29","source_sha256":sha(source_file),
"source_status":"A26 user-approved native 1:1 chibi","expected_geometry":[40,40],
"target":"SOUTHEAST 45-degree / NO WEAPON / same 1:1 head-body","before":b,"attempt_count":1}
record(log)
status,resp=api(key(),"/edit-image-pixen",payload)
job=resp.get("background_job_id")
log.update({"http":status,"job_id":job,"submit_usage":resp.get("usage")})
if status not in (200,201,202) or not job:
 log.update({"status":"REJECTED_OR_UNCERTAIN_NO_REPOST","error":str(resp)[:500]});record(log)
 print("POST_FAILED",status,flush=True);sys.exit(0)
log["status"]="ACCEPTED";record(log)
print("PIXELLAB_A29_CONCEPT_JOB",job,flush=True)
for i in range(95):
 time.sleep(4)
 s,r=api(key(),"/background-jobs/"+job)
 if s!=200:continue
 st=r.get("status")
 if i%5==0:print("POLL",i,st,flush=True)
 if st in ("failed","error","canceled"):
  log.update({"status":"FAILED_NO_RETRY","remote_status":st});record(log);sys.exit(0)
 if st in ("completed","succeeded","success"):
  last=r.get("last_response") or r
  image_obj=last.get("image")
  if not image_obj:
   images=last.get("images") or []
   image_obj=images[0].get("image",images[0]) if images else None
  if isinstance(image_obj,dict):image_obj=image_obj.get("base64")
  if not isinstance(image_obj,str):
   log.update({"status":"UNREADABLE_PNG_NO_RETRY","last_keys":list(last)});record(log);sys.exit(0)
  if image_obj.startswith("data:"):image_obj=image_obj.split(",",1)[1]
  im=Image.open(BytesIO(base64.b64decode(image_obj))).convert("RGBA")
  if im.size!=(40,40):
   log.update({"status":"INVALID_SIZE","size":list(im.size)});record(log);sys.exit(0)
  output=ROOT/"A29_PIXELLAB_45_UNARMED_CONCEPT_40.png";im.save(output)
  after=balance(key())
  log.update({"status":"PIXELLAB_CONCEPT_RETURNED_USER_ART_GATE_PENDING","bbox":im.getbbox(),
   "bottom_alpha":sum(im.getpixel((x,39))[3]>0 for x in range(40)),
   "source_changed_pixels":sum(a!=c for a,c in zip(src.getdata(),im.getdata())),
   "output_sha256":sha(output),"after":after,"bill_usage":last.get("billing_usage")})
  record(log)
  print("PIXELLAB_CONCEPT_DONE","BBOX",im.getbbox(),"BILL",last.get("billing_usage"),"BALANCE",after["generations"],flush=True)
  sys.exit(0)
log["status"]="POLL_LIMIT_NO_REPOST";record(log)
print("POLL_LIMIT",flush=True)
