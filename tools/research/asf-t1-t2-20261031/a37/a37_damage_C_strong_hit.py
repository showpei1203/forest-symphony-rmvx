"""A37 Damage C single targeted genuine PixelLab edit-animation-v2.
Fix weak hit F1 of prior real B output, don't regenerate idle/walk.
Three frames only. Source direction from A34 battle master. One charge at most.
"""
from pathlib import Path
from PIL import Image
import base64,hashlib,io,json,sys,time
B=Path(r"E:\GameAssetToolLab_20261023")
R=B/"A37_FS_T4_DODGE_AND_DAMAGE_20261101";D=R/"DAMAGE_C_STRONG_HIT"
SRC=R/"DAMAGE_B_NATIVE_FACING";D.mkdir(exist_ok=True)
sys.path.insert(0,str(B/"A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST"))
from a23_one_paid_spritesheet_trial import api,key,balance
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def wr(p,x):p.write_text(json.dumps(x,ensure_ascii=False,indent=2),encoding="utf8")
frames=[SRC/f"PIXELLAB_REAL_DAMAGE_F{i}.png" for i in range(3)]
assert all(p.exists() and Image.open(p).size==(40,40) for p in frames)
lock=D/"SUBMISSION_LOCK.json"
if lock.exists():print("LOCK_EXISTS_NO_REPEAT");sys.exit(0)
prompt=("Three actual DAMAGE HIT one-shot sprite poses, already same approved FS white-haired "
"teal-gold armored 1:1 chibi, all southeast 45-degree face and upper torso. "
"Keep frame0 alert guard, visibly STRONGER frame1 recoil: head/shoulders lean BACK and "
"sideways, bend knees and pull hands up to protect chest, entire torso/hip reacts to a hit "
"(not a bow, walk, cast, idle, duck or dodge), frame2 settles to same original guarded facing. "
"Make this read clearly in just THREE distinct frames, keep same hair/armor and the "
"original 45-degree three-quarter battle camera in ALL frames. NO 90-degree side profile, "
"NO weapon, hilt, sheath, bow, shield, wand or VFX, empty fists. "
"Maintain a 40x40 transparent pixel canvas, no body clipping, no extra limbs.")
(D/"ACTION_PROMPT.txt").write_text(prompt,encoding='utf8')
def enc(p):return {"image":{"type":"base64","base64":"data:image/png;base64,"+base64.b64encode(p.read_bytes()).decode(),"format":"png"},"size":{"width":40,"height":40}}
before=balance(key());assert before.get("status")=="active" and before["generations"]>15
payload={"frames":[enc(p) for p in frames],"description":prompt,
 "image_size":{"width":40,"height":40},"seed":37110106,"no_background":True}
rec={"stage":"A37","action":"Damage","trial":"C_targeted_recoil_v1","status":"LOCKED_BEFORE_API","input_sha256":[sha(p) for p in frames],
"endpoint":"/edit-animation-v2","before":before,"attempts":1,"expected_three_frames":True}
wr(lock,rec)
status,res=api(key(),"/edit-animation-v2",payload)
jid=res.get("background_job_id") if isinstance(res,dict) else None
rec.update({"http":status,"job_id":jid})
if status not in (200,201,202) or not jid:
 rec.update({"status":"HTTP_REJECTED_OR_UNCERTAIN_NO_RETRY","error":str(res)[:550]});wr(lock,rec)
 print("REJECTED",status,str(res)[:350]);sys.exit(0)
rec["status"]="JOB_ACCEPTED";wr(lock,rec)
print("DAMAGE_C_REAL_JOB",jid,flush=True)
for t in range(100):
 time.sleep(4)
 code,o=api(key(),"/background-jobs/"+jid)
 if code!=200:continue
 s=o.get("status")
 if t%5==0:print("POLL",t,s,flush=True)
 if s in ("error","failed","canceled"):
  rec.update({"status":"FAILED_NO_RETRY","remote_status":s});wr(lock,rec);sys.exit(0)
 if s not in ("completed","success","succeeded"):continue
 last=o.get("last_response") or {}
 arr=last.get("images") or o.get("images")
 if not isinstance(arr,list) or len(arr)!=3:
  rec.update({"status":"WRONG_FRAMES","frame_count":len(arr) if isinstance(arr,list) else None});wr(lock,rec);sys.exit(0)
 out=[]
 for i,x in enumerate(arr):
  val=x.get("image",x) if isinstance(x,dict) else x
  if isinstance(val,dict):val=val.get("base64")
  if val.startswith("data:"):val=val.split(",",1)[1]
  im=Image.open(io.BytesIO(base64.b64decode(val))).convert("RGBA")
  if im.size!=(40,40):
   rec.update({"status":"INVALID_SIZE","size":list(im.size)});wr(lock,rec);sys.exit(0)
  im.save(D/f"PIXELLAB_DAMAGE_C_REAL_F{i}.png");out.append(im)
 strip=Image.new("RGBA",(120,40))
 for i,im in enumerate(out):strip.alpha_composite(im,(40*i,0))
 p=D/"PIXELLAB_DAMAGE_C_REAL_3FRAME_SHEET.png";strip.save(p)
 after=balance(key())
 rec.update({"status":"THREE_REAL_C_FRAMES_READY_ART_REVIEW","after":after,
  "provider_billing":last.get("billing_usage"),"output_bboxes":[im.getbbox() for im in out],
  "sheet_sha256":sha(p)})
 wr(lock,rec)
 print("DONE","BALANCE",after["generations"],"BILL",rec["provider_billing"],flush=True);sys.exit(0)
rec["status"]="POLL_LIMIT_NO_RETRY";wr(lock,rec)
