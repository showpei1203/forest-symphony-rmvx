"""A28 v2: Fix 40px sword clipping via native pixels on transparent 64x64 battle canvas.
Keep 40px original art embedded at 1:1 scale (NO resampling), transform 18 bone positions to 64px normalized coordinates.
Single PixelLab pose-driven animation request; no duplicate paid submission.
"""
from pathlib import Path
from PIL import Image
import json,sys,io,base64,hashlib,time,shutil
A23=Path(r"E:\GameAssetToolLab_20261023\A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST")
A26=Path(r"E:\GameAssetToolLab_20261023\A26_PMD0001_APPROVED_SHEETS_FS_RATIO_REPAIR_20261101")
A27=Path(r"E:\GameAssetToolLab_20261023\A27_PMD6_FS_CHIBI_ACTIONS_20261101")
R=Path(r"E:\GameAssetToolLab_20261023\A28_FS_SKELETON_BATTLE_AND_FOUR_ACTIONS_20261101\FS_SKELETON_ATTACK_64_PAD")
R.mkdir(exist_ok=True)
sys.path.insert(0,str(A23))
from a23_one_paid_spritesheet_trial import api,key,balance
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(p,d):p.write_text(json.dumps(d,ensure_ascii=False,indent=2),encoding='utf8')
src=A26/"FS_NATIVE_PIXEN_RATIO_FIX"/"PIXEL_LAB_FS_NATIVE_RATIO_CANDIDATE_40.png"
original=Image.open(src).convert('RGBA')
assert original.size==(40,40) and original.getbbox()==(9,4,32,38)
pad=Image.new('RGBA',(64,64))
pad.alpha_composite(original,(12,12))
png=R/"APPROVED_40_ON_PAD64.png";pad.save(png)
pts=json.loads((A27/"FS_SKELETON_CONTROL_TEST"/"estimated_keypoints.json").read_text(encoding='utf8'))
assert len(pts)==18
moves=[
 {"LEFT ELBOW":(-.025,-.05),"LEFT ARM":(-.035,-.10)},
 {"LEFT ELBOW":(-.06,-.10),"LEFT ARM":(-.12,-.19)},
 {"LEFT ELBOW":(.08,-.09),"LEFT ARM":(.18,-.18)},
 {"LEFT ELBOW":(.13,.02),"LEFT ARM":(.25,.04)},
 {"LEFT ELBOW":(.07,.03),"LEFT ARM":(.16,.12)},
 {"LEFT ELBOW":(0,0),"LEFT ARM":(0,0)}
]
def keypoints(shift):
 o=[]
 for p in pts:
  dx,dy=shift.get(p['label'],(0,0))
  X=(12+40*(p['x']+dx))/64
  Y=(12+40*(p['y']+dy))/64
  o.append({"x":round(min(1,max(0,X)),5),"y":round(min(1,max(0,Y)),5),"label":p['label'],
            "z_index":round(p.get('z_index',0))})
 return o
bones=[keypoints(s) for s in moves]
save(R/"KEYPOINTS64.json",{"base":keypoints({}),"steps":bones})
lock=R/"SUBMISSION_LOCK.json"
if lock.exists():
 print("ALREADY_REQUESTED_NO_RETRY");sys.exit(0)
b=balance(key())
assert b['status']=='active' and b['generations']>25
req={"description":"white-haired oversized-head chibi sword fighter, tiny compact teal-and-bronze armor with one short steel sword, big head as tall as tiny lower body, visible intact white hair, dark green cape",
"action":"highly readable south-east slash, draw short blade up on wind-up, extend sword to right, sweep sword downward and recover",
"direction":"south-east","view":"low top-down","first_frame":{"type":"base64","base64":base64.b64encode(png.read_bytes()).decode(),"format":"png"},
"first_frame_keypoints":keypoints({}),"keypoints":bones,"seed":28110166,"template_id":"mannequin","no_background":True}
rec={"stage":"A28_FS_SWORD_SKELETON_V2_64_PADDED","status":"PREPOST_LOCK","attempts":1,
 "source_original_sha256":sha(src),"padded_source_sha256":sha(png),"source_native_pixels_unscaled":True,
 "padding":[12,12],"before":b}
save(lock,rec)
s,d=api(key(),"/animate-with-skeleton-v3",req)
job=d.get('background_job_id');rec.update({"http":s,"job_id":job})
if s not in (200,201,202) or not job:
 rec["status"]="REJECTED_NO_RETRY";rec["error"]=str(d)[:600];save(lock,rec)
 print("ERROR",s,str(d)[:300]);sys.exit(0)
rec["status"]="ACCEPTED";save(lock,rec)
print("SKELETON64_ACCEPTED",job,flush=True)
for n in range(90):
 time.sleep(4)
 c,data=api(key(),"/background-jobs/"+job)
 if c!=200:continue
 if n%5==0:print("POLL64",n,data.get('status'),flush=True)
 if data.get('status') in ('failed','canceled','error'):
  rec['status']='FAILED_NO_RETRY';save(lock,rec);sys.exit(0)
 if data.get('status') not in ('completed','succeeded','success'):continue
 last=data.get('last_response') or {}
 images=last.get('images') or data.get('images') or []
 if not images:
  rec['status']='NO_IMAGES_NO_RETRY';rec['last_response_keys']=list(last);save(lock,rec);sys.exit(0)
 results=[]
 for i,obj in enumerate(images):
  v=obj.get("image",obj) if isinstance(obj,dict) else obj
  if isinstance(v,dict):v=v.get('base64')
  if v.startswith('data:'):v=v.split(',',1)[1]
  im=Image.open(io.BytesIO(base64.b64decode(v))).convert('RGBA')
  assert im.size==(64,64)
  results.append(im);im.save(R/f"FRAME64_{i:02}.png")
 sheet=Image.new('RGBA',(64*len(results),64))
 for i,im in enumerate(results):sheet.alpha_composite(im,(64*i,0))
 sheet.save(R/"FS_SKELETON_SWORD64_SHEET.png")
 page=Image.new('RGB',(320*len(results),320),(235,238,241))
 for i,im in enumerate(results):
  bg=Image.new('RGBA',(64,64),(235,238,241,255));bg.alpha_composite(im)
  page.paste(bg.convert('RGB').resize((320,320),Image.Resampling.NEAREST),(i*320,0))
 page.save(R/"FS_SKELETON_SWORD64_REVIEW_5X.png")
 rec.update({'status':'REAL_64_PADDED_SWORD_FRAMES','frames':len(results),
    'boxes':[im.getbbox() for im in results],
    'edges':[sum(im.getpixel((x,63))[3]>0 for x in range(64)) for im in results],
    'right_edges':[sum(im.getpixel((63,y))[3]>0 for y in range(64)) for im in results],
    'provider_usage':data.get('usage'),'billing':last.get('billing_usage'),
    'sheet_sha256':sha(R/"FS_SKELETON_SWORD64_SHEET.png"),
    'after':balance(key())})
 save(lock,rec);print('SKELETON64_DONE',json.dumps(rec['boxes']), 'right_edge',rec['right_edges'],
    'BILLING',rec['billing'],flush=True);sys.exit(0)
rec['status']='POLL_LIMIT';save(lock,rec)
