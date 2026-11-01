"""A29 true eight-direction PixelLab Rotate V3 on UNARMED approved 1:1 chibi.
Select South-East native ordinal 45° only AFTER provider output and visual QA.
"""
from pathlib import Path
from PIL import Image
import sys,io,base64,json,time,hashlib
BASE=Path(r"E:\GameAssetToolLab_20261023")
R=BASE/"A29_FS45_UNARMED_PIXELLAB_LOOP_20261101"
SRC=R/"A29_PIXELLAB_45_UNARMED_CONCEPT_40.png"
OUT=R/"PIXELLAB_8_DIRECTIONS_V3"
OUT.mkdir(exist_ok=True)
sys.path.insert(0,str(BASE/"A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST"))
from a23_one_paid_spritesheet_trial import api,key,balance
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(log): (OUT/"SUBMISSION_LOCK.json").write_text(json.dumps(log,ensure_ascii=False,indent=2),encoding='utf8')
lock=OUT/"SUBMISSION_LOCK.json"
if lock.exists():print("EXISTING_LOCK_NO_REPOST");sys.exit(0)
im=Image.open(SRC).convert('RGBA')
assert im.size==(40,40)
pad=Image.new("RGBA",(64,64))
pad.alpha_composite(im,(12,12))
new=OUT/"A29_UNARMED_CHARACTER_PAD_64.png";pad.save(new)
prompt=("Same white-haired Q-style 1:1 head/body Forest Symphony chibi in detailed teal and gold armor. "
"Both fists completely EMPTY and clearly bare, with NO sword, hilt, sheath, shield, or weapon in any direction. "
"Preserve same 32-pixel-tall miniature body, white hair, cape, short legs, face and palette. "
"South-east means diagonal down-right three-quarter view; never front-on or side profile.")
before=balance(key());assert before['status']=='active' and before['generations']>15
body={"first_frame":{"type":"base64","base64":base64.b64encode(new.read_bytes()).decode(),"format":"png"},
"description":prompt,"no_background":True,"seed":29110168}
log={"stage":"A29","status":"PRE_POST_LOCK","route":"/generate-8-rotations-v3",
"source_sha256":sha(SRC),"padded_sha256":sha(new),"attempts":1,"before":before}
save(log)
status,resp=api(key(),"/generate-8-rotations-v3",body)
job=resp.get("background_job_id")
log.update({"http":status,"job_id":job,"submit_usage":resp.get("usage")})
if status not in (200,201,202) or not job:
 log.update({"status":"REQUEST_REJECTED_OR_UNKNOWN_NO_RETRY","error":str(resp)[:600]});save(log)
 print("REJECTED",status,str(resp)[:300],flush=True);sys.exit(0)
log["status"]="ACCEPTED";save(log)
print("PIXELLAB_REAL_8_DIRECTION_JOB",job,flush=True)
for n in range(95):
 time.sleep(4)
 s,data=api(key(),"/background-jobs/"+job)
 if s!=200:continue
 st=data.get("status")
 if n%5==0:print("POLL",n,st,flush=True)
 if st in ("failed","error","canceled"):
  log.update({"status":"PROVIDER_FAILED_NO_RETRY","provider_status":st});save(log);sys.exit(0)
 if st not in ("completed","success","succeeded"):continue
 last=data.get("last_response") or {}
 arr=last.get("images") or last.get("rotations") or data.get("images") or data.get("rotations")
 print("RESPONSE_KEYS",list(last), "TYPE_ARR",type(arr).__name__,flush=True)
 if isinstance(arr,dict):print("DICT_KEYS",list(arr),flush=True)
 if isinstance(arr,dict): arr=list(arr.values())
 if not isinstance(arr,list) or len(arr)<8:
  log.update({"status":"UNEXPECTED_DIRECTION_RESULT","keys":list(last),"arr_repr":str(arr)[:200]});save(log);sys.exit(0)
 direction=["south","south-west","west","north-west","north","north-east","east","south-east"]
 result={}
 for j,(name,item) in enumerate(zip(direction,arr[:8])):
  x=item.get("image",item) if isinstance(item,dict) else item
  if isinstance(x,dict):x=x.get("base64")
  if not isinstance(x,str):continue
  if x.startswith("data:"):x=x.split(",",1)[1]
  o=Image.open(io.BytesIO(base64.b64decode(x))).convert('RGBA')
  p=OUT/f"{j:02}_{name.upper()}_64.png";o.save(p)
  result[name]={"size":list(o.size),"bbox":o.getbbox(),"sha":sha(p)}
 if "south-east" not in result:
  log.update({"status":"SE_OUTPUT_UNAVAILABLE","outputs":result});save(log);sys.exit(0)
 se=Image.open(OUT/"07_SOUTH-EAST_64.png").convert("RGBA")
 box=se.getbbox();valid_crop=box and box[0]>=12 and box[1]>=12 and box[2]<=52 and box[3]<=52
 if valid_crop:se.crop((12,12,52,52)).save(R/"A29_PIXEL_LAB_8WAY_SE_40_SOURCE_CANDIDATE.png")
 after=balance(key())
 log.update({"status":"EIGHT_DIRECTION_PNGS_RETURNED_ART_GATE_PENDING","outputs":result,
 "SE_40_LOSSLESS":bool(valid_crop),"after":after,"billing":last.get("billing_usage")})
 save(log)
 print("COMPLETE_8_ROTATIONS","SE_BOX",box,"CROP40",valid_crop,
   "COST",last.get("billing_usage"),"BALANCE",after["generations"],flush=True)
 sys.exit(0)
log["status"]="POLL_LIMIT_NO_REPOST";save(log)
