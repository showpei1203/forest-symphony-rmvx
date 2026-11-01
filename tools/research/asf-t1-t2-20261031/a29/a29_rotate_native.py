"""A29 genuine PixelLab Rotate API: front-facing unarmed chibi -> southeast 45 degrees.
No edits to approved original; exact 64x64 transparent canvas with 40px pixels embedded unscaled.
"""
from pathlib import Path
from PIL import Image
from io import BytesIO
import base64,sys,json,hashlib,io
BASE=Path(r"E:\GameAssetToolLab_20261023")
ROOT=BASE/"A29_FS45_UNARMED_PIXELLAB_LOOP_20261101"
sys.path.insert(0,str(BASE/"A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST"))
from a23_one_paid_spritesheet_trial import key,balance,api
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def js(f,o):f.write_text(json.dumps(o,ensure_ascii=False,indent=2),encoding="utf8")
src=Image.open(ROOT/"A29_PIXELLAB_45_UNARMED_CONCEPT_40.png").convert("RGBA")
assert src.size==(40,40) and src.getbbox()
canvas=Image.new("RGBA",(64,64));canvas.alpha_composite(src,(12,12))
inp=ROOT/"A29_UNARMED_FRONT_PAD64_FOR_ROTATE.png";canvas.save(inp)
lock=ROOT/"ROTATE_JOB.json"
if lock.exists():
 print("ALREADY_LOCKED_STOP");sys.exit(0)
before=balance(key());assert before['status']=='active' and before['generations']>10
req={"from_image":{"type":"base64","base64":base64.b64encode(inp.read_bytes()).decode(),"format":"png"},
 "image_size":{"width":64,"height":64},
 "from_view":"low top-down","to_view":"low top-down",
 "from_direction":"south","to_direction":"south-east",
 "direction_change":45,
 "image_guidance_scale":5.0,
 "seed":29110146,
 "isometric":False,"oblique_projection":False}
log={"stage":"A29","route":"/rotate","status":"PREPOST_LOCK","source_file":str(inp),
 "source_sha256":sha(inp),"target":"front/south -> southeast/45-degree low top-down",
 "before":before,"attempts":1}
js(lock,log)
status,resp=api(key(),"/rotate",req)
log["http"]=status
if status!=200:
 log.update({"status":"ROTATE_REJECTED_NO_RETRY","error":str(resp)[:650]})
 js(lock,log);print("ROTATE_FAILED",status,str(resp)[:400]);sys.exit(0)
res=resp.get("image")
if isinstance(res,dict):res=res.get("base64")
if not isinstance(res,str):
 log.update({"status":"ROTATE_UNREADABLE","response_keys":list(resp)});js(lock,log)
 print("ROTATE_UNREADABLE",list(resp));sys.exit(0)
if res.startswith("data:"):res=res.split(",",1)[1]
rot=Image.open(BytesIO(base64.b64decode(res))).convert("RGBA")
assert rot.size==(64,64),rot.size
rot64=ROOT/"A29_PIXEL_LAB_ROTATE_SOUTHEAST_64.png"
rot.save(rot64)
box=rot.getbbox()
# Crop to 40x40 only if all opaque pixels fit in 12..52. No silent crop.
can_crop=box is not None and box[0]>=12 and box[1]>=12 and box[2]<=52 and box[3]<=52
if can_crop:
 crop=rot.crop((12,12,52,52));crop.save(ROOT/"A29_PIXEL_LAB_ROTATE_SE_40_SOURCE_CANDIDATE.png")
after=balance(key())
log.update({"status":"ROTATE_COMPLETED_TECHNICALLY_45_VIEW_ART_GATE_PENDING","bbox":box,
 "crop40_lossless":can_crop,"rotated_png_sha256":sha(rot64),"after":after,"reported_usage":resp.get("usage")})
js(lock,log)
print("ROTATE_DONE","BBOX",box,"CROP40_LOSSLESS",can_crop,"BILL",resp.get("usage"),"BALANCE",after["generations"],flush=True)
