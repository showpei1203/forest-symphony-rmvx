"""A32 humanoid action vocabulary semantic prompt A/B: PixelLab DODGING actual real API test.
Based on user-provided reference row 09 semantics, with approved FS A31 unarmed source.
Source sprite unchanged, screenshot is taxonomy/pose reference (not direct API pixels).
"""
from pathlib import Path
from PIL import Image
import sys,json,hashlib,base64,time,io
B=Path(r"E:\GameAssetToolLab_20261023")
R=B/"A32_FS_BATTLE45_NATIVE_REFERENCES_20261101"
R.mkdir(exist_ok=True)
src=B/"A31_FS_ORIGINAL_MOTION_TRANSFER_20261101"/"A31_SE45_ORIGINAL_POLICY_STATIC_IDLE.png"
assert src.exists() and Image.open(src).size==(40,40)
sys.path.insert(0,str(B/"A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST"))
from a23_one_paid_spritesheet_trial import key,api,balance
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(p,d):p.write_text(json.dumps(d,ensure_ascii=False,indent=2),encoding="utf8")
OUT=R/"ACTION_09_DODGE_PIXEL_LAB_TEST";OUT.mkdir(exist_ok=True)
lock=OUT/"SUBMISSION_LOCK.json"
if lock.exists():
 print("EXISTING_LOCK_NO_DUPLICATE_PAYMENT");sys.exit(0)
prompt=("HUMANOID DODGING ACTION: preserve the exact approved white-haired, big-headed 1:1 chibi, "
"teal gold armor with EMPTY HANDS, diagonal southeast 45 degree battle view (not 90 degree profile). "
"Follow three reference poses from action taxonomy 'Dodging': "
"1) combat-ready neutral with feet planted, "
"2) knees flex while hips drop and torso leans to screen-left, arms guard head, "
"3) clear sideways dodge displacement with controlled hip/shoulder lean, "
"then return deliberately to original neutral stance. "
"The head and chest must move WITH hips, not isolated shoulder twitch. "
"Feet show actual push-off and landing; body must not float during rooted phases. "
"One character only, no added feet/arms, no sword, blade, hilt, scabbard, bow, shield, projectile, or magical particles. "
"Retain original costume colors, face shape, 40x40 transparent native pixel-art, no resampling. "
"This action is ONE SHOT, not a Walk or Idle loop; keep final recovery pose readable.")
(OUT/"ACTION_PROMPT.txt").write_text(prompt,encoding="utf8")
original=Image.open(src).convert("RGBA")
payload={"first_frame":{"type":"base64","base64":base64.b64encode(src.read_bytes()).decode(),"format":"png"},
"action":prompt,"frame_count":4,"no_background":True,"seed":32110109,"enhance_prompt":False}
before=balance(key())
assert before["status"]=="active" and float(before["generations"])>8
rec={"stage":"A32_REFERENCE_TEST","action_id":"09","name":"Dodging",
"reference_type":"user screenshot three pose semantics, source image not supplied as Pixellab image",
"source":str(src),"source_sha256":sha(src),"status":"PRE_POST_LOCK_ONE_REQUEST",
"requested_frames":4,"before":before}
save(lock,rec)
s,data=api(key(),"/animate-with-text-v3",payload)
job=data.get("background_job_id")
rec.update({"http_status":s,"job_id":job,"submission_usage":data.get("usage")})
if s not in (200,201,202) or not job:
 rec.update({"status":"REJECTED_NO_REPOST","error":str(data)[:600]});save(lock,rec)
 print("API_REJECTED",s,str(data)[:380],flush=True);sys.exit(0)
rec["status"]="JOB_ACCEPTED";save(lock,rec)
print("A32_REAL_PIXELLAB_DODGE_JOB",job,flush=True)
for i in range(100):
 time.sleep(4)
 status,obj=api(key(),"/background-jobs/"+job)
 if status!=200:continue
 state=obj.get("status")
 if i%5==0:print("PIXELLAB_POLL",i,state,flush=True)
 if state in ("error","failed","canceled"):
  rec.update({"status":"PROVIDER_FAILED","last_state":state});save(lock,rec);sys.exit(0)
 if state not in ("completed","succeeded","success"):continue
 out=obj.get("last_response") or {}
 imgs=out.get("images") or obj.get("images")
 if not isinstance(imgs,list) or not imgs:
  rec.update({"status":"NO_IMAGE_RESULTS","keys":list(out)});save(lock,rec);sys.exit(0)
 frames=[]
 for j,x in enumerate(imgs):
  v=x.get("image",x) if isinstance(x,dict) else x
  if isinstance(v,dict):v=v.get("base64")
  if v.startswith("data:"):v=v.split(",",1)[1]
  im=Image.open(io.BytesIO(base64.b64decode(v))).convert("RGBA")
  im.save(OUT/f"PIXELLAB_DODGE_FRAME_{j:02}.png")
  frames.append(im)
 if any(f.size!=(40,40) for f in frames):
  rec.update({"status":"NON_NATIVE_SIZE","sizes":[list(f.size) for f in frames]});save(lock,rec);sys.exit(0)
 strip=Image.new("RGBA",(40*len(frames),40))
 for j,f in enumerate(frames):strip.alpha_composite(f,(40*j,0))
 strip.save(OUT/"PIXELLAB_DODGE_REAL_40xN.png")
 frames[0].save(OUT/"PIXELLAB_DODGE_REAL_ONE_SHOT.gif",save_all=True,append_images=frames[1:],
 duration=165,loop=1,disposal=2,optimize=False)
 after=balance(key())
 rec.update({"status":"REAL_FRAMES_RECEIVED_VISUAL_ART_GATE_PENDING","provider_billing":out.get("billing_usage"),
 "frames":len(frames),"bbox_by_frame":[f.getbbox() for f in frames],
 "exact_source_first_frame":frames[0].tobytes()==original.tobytes(),
 "last_return_diff":sum(a!=b for a,b in zip(frames[-1].getdata(),original.getdata())),
 "source_checksum":sha(src),"sheet_sha":sha(OUT/"PIXELLAB_DODGE_REAL_40xN.png"),"after":after})
 save(lock,rec)
 print("REAL_PIXELLAB_DONE",len(frames),"BOXES",rec["bbox_by_frame"],"BILL",out.get("billing_usage"),"BAL",after["generations"],flush=True)
 sys.exit(0)
rec.update({"status":"POLL_LIMIT_DO_NOT_RESUBMIT"});save(lock,rec)
