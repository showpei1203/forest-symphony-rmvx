"""A34 F0-fix Dodging trial. REF frame0+frame2 are an actual PixelLab rendering
of *native FS battle-view* original actor01_1. Middle pose is exact user screenshot
Dodging crouch after removing ONLY connected 44px prior-row debris.
One paid 3-frame PixelLab transfer-outfit-v2 with a battle-view identity reference.
"""
from pathlib import Path
from PIL import Image
from collections import deque
import sys,json,hashlib,shutil,base64,io,time
B=Path(r"E:\GameAssetToolLab_20261023");R=B/"A34_FS_BATTLE45_F0_CORRECTION_20261101"
A33=B/"A33_HUMANOID_DIRECT_POSE_20261101"
OUT=R/"B2_DODGE_NATIVE_VIEW_POSES";OUT.mkdir(exist_ok=True)
SRC=R/"A34_REAL_BATTLE_45_REFERENCE_MASTER_00.png"
sys.path.insert(0,str(B/"A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST"))
from a23_one_paid_spritesheet_trial import api,key,balance
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(p,obj):p.write_text(json.dumps(obj,indent=2,ensure_ascii=False),encoding='utf8')
def pic(p):return {"image":{"type":"base64","base64":"data:image/png;base64,"+base64.b64encode(p.read_bytes()).decode(),"format":"png"},"size":{"width":40,"height":40}}
assert SRC.exists() and Image.open(SRC).size==(40,40)
src=Image.open(A33/"REFERENCE_SOURCE"/"DODGE1.png").convert("RGBA")
assert src.size==(32,32)
# Remove ONLY fully disconnected, objectively foreign row fragment (44 pixels).
alpha=src.getchannel("A")
white={(x,y) for y in range(32) for x in range(32) if alpha.getpixel((x,y))>0}
components=[]
while white:
 start=min(white,key=lambda p:(p[1],p[0]));white.remove(start)
 stack=[start];pts=[]
 while stack:
  x,y=stack.pop();pts.append((x,y))
  for dy in (-1,0,1):
   for dx in (-1,0,1):
    q=(x+dx,y+dy)
    if q in white: white.remove(q);stack.append(q)
 components.append(pts)
comps=sorted(components,key=len,reverse=True)
assert len(comps)==2 and len(comps[0])==509 and len(comps[1])==44
assert max(y for x,y in comps[1])<min(y for x,y in comps[0])
clean=Image.new("RGBA",(32,32))
for x,y in comps[0]:clean.putpixel((x,y),src.getpixel((x,y)))
clean.save(OUT/"USER_DODGE_F1_CROUCH_CLEANED_32.png")
pad=Image.new("RGBA",(40,40));pad.alpha_composite(clean,(4,6))
P=OUT/"USER_DODGE_F1_CROUCH_CLEANED_40.png";pad.save(P)
shutil.copy2(SRC,OUT/"CORRECT_F0_FROM_NATIVE_PIXELLAB_40.png")
F0=OUT/"CORRECT_F0_FROM_NATIVE_PIXELLAB_40.png"
framefiles=[F0,P,F0]
prompt=("A real 3-frame DODGING action. Frames 0 and 2 are the EXACT same correct original "
"Forest Symphony 45 degree three-quarter battle view and teal-armored white-haired Q-chibi character. "
"KEEP frame 0 and frame 2 FACE and EYE directions EXACTLY as supplied: both eyes readable, "
"small near/far eye perspective, same head facing as the original $actor01_1 reference; NOT a one-eye "
"90-degree sideways face. Frame 1 is the supplied actual crouching/dodge KEY POSE, with knees bent, "
"body lowered and full-body weight transfer. Transfer approved character's white hair and finely "
"detailed teal/bronze armor consistently to the crouch middle. "
"Do not copy the old screenshot character's colors or blue eyes. "
"EVERY frame has empty hands, no sword, hilt, sheath, bow, shield or VFX, SBS weapon paper-doll separate. "
"Keep native 40x40, transparent, Q 1:1 head/body, intact limbs. "
"Do NOT invent a walk cycle or a shoulder twitch; three keyposes only.")
(OUT/"A34_B2_PROMPT.txt").write_text(prompt,encoding='utf8')
L=OUT/"SUBMISSION_LOCK.json"
if L.exists():print("LOCK_EXISTS_NO_REPOST");sys.exit(0)
before=balance(key())
assert before["status"]=="active" and before["generations"]>12
req={"reference_image":pic(SRC),"frames":[pic(p) for p in framefiles],
     "image_size":{"width":40,"height":40},"additional_instructions":prompt,
     "seed":34110121,"no_background":True}
log={"stage":"A34_B2","status":"PREPOST_LOCK","source_native_identity":sha(SRC),
"source_pose":sha(P),"prior_source_noise_removed":44,"frames_input_sha256":[sha(x) for x in framefiles],
"F0_and_F2_same_correct_native_view":True,"before":before,"attempts":1}
save(L,log)
s,d=api(key(),"/transfer-outfit-v2",req)
jid=d.get("background_job_id") if isinstance(d,dict) else None
log.update({"http":s,"job_id":jid})
if s not in (200,201,202) or not jid:
 log.update({"status":"REJECTED_NO_RETRY","error":str(d)[:500]});save(L,log);print("REJECTED",s,str(d)[:250],flush=True);sys.exit(0)
log["status"]="ACCEPTED";save(L,log)
print("A34_B2_PIXELLAB_JOB",jid,flush=True)
for i in range(90):
 time.sleep(4)
 c,res=api(key(),"/background-jobs/"+jid)
 if c!=200:continue
 st=res.get("status")
 if i%6==0:print("POLL",i,st,flush=True)
 if st in ("failed","error","canceled"):
  log.update({"status":"FAILED","remote_status":st});save(L,log);sys.exit(0)
 if st not in ("completed","success","succeeded"):continue
 last=res.get("last_response") or {}
 arr=last.get("images") or res.get("images")
 if not isinstance(arr,list) or len(arr)!=3:
  log.update({"status":"WRONG_FRAME_COUNT","frames":len(arr) if isinstance(arr,list) else -1});save(L,log);sys.exit(0)
 images=[]
 for j,x in enumerate(arr):
  v=x.get("image",x) if isinstance(x,dict) else x
  if isinstance(v,dict):v=v.get("base64")
  if v.startswith("data:"):v=v.split(",",1)[1]
  im=Image.open(io.BytesIO(base64.b64decode(v))).convert("RGBA")
  assert im.size==(40,40)
  im.save(OUT/f"A34_B2_REAL_PROVIDER_{j:02}.png");images.append(im)
 sheet=Image.new("RGBA",(120,40))
 for j,im in enumerate(images):sheet.alpha_composite(im,(j*40,0))
 sheet.save(OUT/"A34_B2_REAL_PIXELLAB_3FRAMES.png")
 after=balance(key())
 log.update({"status":"B2_REAL_THREE_FRAMES_RETURNED_QA_PENDING","bboxes":[im.getbbox() for im in images],
  "output_sha":sha(OUT/"A34_B2_REAL_PIXELLAB_3FRAMES.png"),
  "bill":last.get("billing_usage"),"after":after})
 save(L,log);print("A34_B2_DONE","BILL",log["bill"],"BALANCE",after["generations"],flush=True);sys.exit(0)
log["status"]="POLL_LIMIT_NO_RETRY";save(L,log)
