"""A37 Damage: exactly THREE key poses, no new animation frame count.
Real PixelLab outfit transfer with native battle-facing FS $actor01_1-derived
identity master on F0 and F2; F1 = true user Damage row reference controlled
PixelLab A33 frame01. All 40x40 source PNGs, one paid job, guarded lock.
"""
from pathlib import Path
from PIL import Image
import sys,base64,hashlib,json,time,io,shutil
B=Path(r"E:\GameAssetToolLab_20261023")
R=B/"A37_FS_T4_DODGE_AND_DAMAGE_20261101"
A34=B/"A34_FS_BATTLE45_F0_CORRECTION_20261101"
A33=B/"A33_HUMANOID_DIRECT_POSE_20261101"
MASTER=A34/"A34_REAL_BATTLE_45_REFERENCE_MASTER_00.png"
REF=A33/"B_DAMAGE_DIRECT_POSES"/"PIXELLAB_B_DAMAGE_FRAME_01.png"
sys.path.insert(0,str(B/"A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST"))
from a23_one_paid_spritesheet_trial import key,api,balance
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(p,obj):p.write_text(json.dumps(obj,ensure_ascii=False,indent=2),encoding="utf8")
def enc(p):
 return {"image":{"type":"base64","base64":"data:image/png;base64,"+base64.b64encode(p.read_bytes()).decode(),"format":"png"},
         "size":{"width":40,"height":40}}
assert MASTER.exists() and REF.exists()
assert Image.open(MASTER).size==Image.open(REF).size==(40,40)
OUT=R/"DAMAGE_B_NATIVE_FACING";OUT.mkdir(exist_ok=True)
lock=OUT/"SUBMISSION_LOCK.json"
if lock.exists():
 print("EXISTING_LOCK_SKIP_NO_NEW_CHARGE");sys.exit(0)
shutil.copy2(MASTER,OUT/"INPUT_CORRECT_F0_45_BATTLE.png")
shutil.copy2(REF,OUT/"INPUT_DAMAGE_F1_FROM_A33_REAL_PROVIDER.png")
shutil.copy2(MASTER,OUT/"INPUT_CORRECT_F2_45_BATTLE.png")
frames=[MASTER,REF,MASTER]
prompt=("EXACTLY THREE HUMANOID DAMAGE / HIT REACTION frames. F0 native southeast 45-degree "
"battle-ready white-haired dark-teal/gold armored chibi, F1 real hit-reactive recoil: "
"upper torso staggers, knees absorb impact, arms defend, F2 returns to initial standing "
"battle camera. Preserve all frames' facial camera from the real native FS $actor01_1 "
"battle-facing identity reference. Front/side face planes BOTH visible, do not revert "
"to pure sideways 90-degree face. Preserve 1:1 oversized head, tiny body, same teal armor, "
"empty hands only. NO sword, sword hilt, sheath, bow, gun, shield, wand or separate VFX. "
"Transparent pixel-art 40x40, no fourth frame, no blurred interpolation or extra limbs.")
(OUT/"PIXELLAB_ACTION_PROMPT.txt").write_text(prompt,encoding="utf8")
before=balance(key());assert before.get('status')=='active' and float(before['generations'])>20,before
request={"reference_image":enc(MASTER),"frames":[enc(p) for p in frames],
"image_size":{"width":40,"height":40},"seed":37110105,
"no_background":True,"additional_instructions":prompt}
rec={"stage":"A37","action":"DAMAGE","endpoint":"/transfer-outfit-v2",
"frame_limit":3,"status":"PRE_POST_LOCK_NO_RETRY","attempt":1,
"source_refs":[sha(x) for x in frames],"identity_sha256":sha(MASTER),
"before":before,"user_approved_dodging":"T4, separate action untouched"}
save(lock,rec)
s,dat=api(key(),"/transfer-outfit-v2",request)
job=dat.get("background_job_id") if isinstance(dat,dict) else None
rec.update({"http":s,"job_id":job})
if s not in (200,201,202) or not job:
 rec.update({"status":"REJECTED_OR_UNCERTAIN_NO_RETRY","error":str(dat)[:650]});save(lock,rec)
 print("REJECT",s,str(dat)[:450],flush=True);sys.exit(0)
rec["status"]="JOB_ACCEPTED";save(lock,rec)
print("REAL_PIXEL_LAB_DAMAGE_JOB",job,flush=True)
for poll in range(100):
 time.sleep(4)
 status,data=api(key(),"/background-jobs/"+job)
 if status!=200:continue
 st=data.get("status")
 if poll%5==0:print("POLL",poll,st,flush=True)
 if st in ("failed","error","canceled"):
  rec.update({"status":"FAILED_NO_RETRY","provider_status":st});save(lock,rec);sys.exit(0)
 if st not in ("completed","success","succeeded"):continue
 last=data.get("last_response") or {}
 arr=last.get("images") or data.get("images")
 if not isinstance(arr,list) or len(arr)!=3:
  rec.update({"status":"INVALID_FRAME_COUNT","returned_count":len(arr) if isinstance(arr,list) else None});save(lock,rec)
  print("BAD_COUNT",len(arr) if isinstance(arr,list) else None,flush=True);sys.exit(0)
 result=[]
 for i,x in enumerate(arr):
  value=x.get("image",x) if isinstance(x,dict) else x
  if isinstance(value,dict):value=value.get("base64")
  if not isinstance(value,str):
   rec.update({"status":"BAD_IMAGE_SCHEMA","idx":i});save(lock,rec);sys.exit(0)
  if value.startswith("data:"):value=value.split(",",1)[1]
  img=Image.open(io.BytesIO(base64.b64decode(value))).convert("RGBA")
  if img.size!=(40,40):
   rec.update({"status":"BAD_GEOMETRY","idx":i,"size":list(img.size)});save(lock,rec);sys.exit(0)
  img.save(OUT/f"PIXELLAB_REAL_DAMAGE_F{i}.png");result.append(img)
 strip=Image.new("RGBA",(120,40))
 for i,img in enumerate(result):strip.alpha_composite(img,(40*i,0))
 sheet=OUT/"PIXELLAB_REAL_DAMAGE_3FRAMES_120x40.png";strip.save(sheet)
 after=balance(key())
 rec.update({"status":"PROVIDER_3_REAL_FRAMES_ART_REVIEW_PENDING","provider_billing":last.get("billing_usage"),
 "after":after,"frame_bboxes":[f.getbbox() for f in result],"sheet_sha256":sha(sheet)})
 save(lock,rec)
 print("PROVIDER_3_FRAMES_COMPLETE","BILL",rec["provider_billing"],"BALANCE",after['generations'],flush=True)
 sys.exit(0)
rec["status"]="POLL_LIMIT_NO_REPOST";save(lock,rec)
