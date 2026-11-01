"""A35 REAL PixelLab interpolation test: approved FS native battle F0 -> real PixelLab
reference-driven F1 Dodge roll. This is ONLY one transition, not a full action.
Never re-submit an accepted job. No generated artwork used in place of source.
"""
from pathlib import Path
from PIL import Image
import base64,io,json,hashlib,sys,time,shutil
B=Path(r"E:\GameAssetToolLab_20261023")
R=B/"A35_DODGE_NATIVE45_MOTION_CONTINUITY_20261101"
A34=B/"A34_FS_BATTLE45_F0_CORRECTION_20261101"
SRC0=A34/"A34_REAL_BATTLE_45_REFERENCE_MASTER_00.png"
SRC1=A34/"B2_DODGE_NATIVE_VIEW_POSES"/"A34_B2_REAL_PROVIDER_01.png"
sys.path.insert(0,str(B/"A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST"))
from a23_one_paid_spritesheet_trial import key,api,balance
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(p,o):p.write_text(json.dumps(o,ensure_ascii=False,indent=2),encoding='utf8')
def raw(p):return {"image":{"type":"base64","base64":"data:image/png;base64,"+base64.b64encode(p.read_bytes()).decode(),"format":"png"},"size":{"width":40,"height":40}}
assert Image.open(SRC0).size==Image.open(SRC1).size==(40,40)
OUT=R/"SEGMENT_A_GUARD_TO_ROLL";OUT.mkdir(exist_ok=True)
lock=OUT/"SUBMISSION_LOCK.json"
if lock.exists():print("A35_INTERPOLATION_EXISTING_LOCK_NO_REPEAT");sys.exit(0)
shutil.copy2(SRC0,OUT/"SOURCE_BEGIN_NATIVE45_REAL_PROVIDER.png")
shutil.copy2(SRC1,OUT/"SOURCE_END_DODGE_F1_REAL_PROVIDER.png")
action=("One continuous stylized humanoid evasive forward roll from the FIRST fixed native Forest Symphony "
"battle-ready 45-degree SE angle toward the SECOND upside-down crouched dodge pose. "
"Animate the entire body in physically plausible in-between frames: bend knees, lower center of gravity, "
"tuck chin and shoulders, roll head and torso together, arms brace with EMPTY fists, "
"then approach the inverted target pose. Preserve white spiky chibi 1:1 head size, same teal detailed armor "
"and exact original camera direction; no jump to side profile or changes in character identity. "
"40px transparent pixel-art, no swords, bows, shields, hilts or separate particles.")
(OUT/"PIXELLAB_INTERPOLATION_PROMPT.txt").write_text(action,encoding="utf8")
before=balance(key())
assert before["status"]=="active" and before["generations"]>15
args={"start_image":raw(SRC0),"end_image":raw(SRC1),"action":action,
 "image_size":{"width":40,"height":40},"seed":35110115,"no_background":True}
rec={"stage":"A35","segment":"native45_guard_to_real_F1_dodge","endpoint":"/interpolation-v2",
 "status":"PREPOST_LOCK","start_sha":sha(SRC0),"end_sha":sha(SRC1),
 "start_source":"A34 real PixelLab native $actor01_1 view",
 "end_source":"A34 real reference-controlled F1", "before":before,
 "attempts":1}
save(lock,rec)
s,obj=api(key(),"/interpolation-v2",args)
job=obj.get("background_job_id") if isinstance(obj,dict) else None
rec.update({"http":s,"job_id":job})
if s not in (200,201,202) or not job:
 rec.update({"status":"REQUEST_REJECTED_NO_RETRY","error":str(obj)[:700]});save(lock,rec)
 print("REJECT",s,str(obj)[:550],flush=True);sys.exit(0)
rec["status"]="ACCEPTED";save(lock,rec)
print("REAL_PIXEL_LAB_INTERPOLATION_JOB",job,flush=True)
for i in range(95):
 time.sleep(4)
 code,out=api(key(),"/background-jobs/"+job)
 if code!=200:continue
 st=out.get("status")
 if i%5==0:print("POLL",i,st,flush=True)
 if st in ("failed","error","canceled"):
  rec.update({"status":"PROVIDER_FAILED_NO_RETRY","provider_status":st});save(lock,rec);sys.exit(0)
 if st not in ("completed","success","succeeded"):continue
 response=out.get("last_response") or {}
 arr=response.get("images") or out.get("images")
 if not isinstance(arr,list) or not arr:
  rec.update({"status":"UNEXPECTED_EMPTY_RESULT_NO_RETRY","keys":list(response)});save(lock,rec);sys.exit(0)
 frames=[]
 for j,v in enumerate(arr):
  imdata=v.get("image",v) if isinstance(v,dict) else v
  if isinstance(imdata,dict):imdata=imdata.get("base64")
  if not isinstance(imdata,str):
   rec.update({"status":"IMAGE_SCHEMA_INVALID","idx":j});save(lock,rec);sys.exit(0)
  if imdata.startswith("data:"):imdata=imdata.split(",",1)[1]
  im=Image.open(io.BytesIO(base64.b64decode(imdata))).convert("RGBA")
  if im.size!=(40,40):
   rec.update({"status":"INVALID_FRAME_GEOMETRY","size":list(im.size)});save(lock,rec);sys.exit(0)
  p=OUT/f"PIXELLAB_INTERPOLATION_RAW_{j:02}.png";im.save(p);frames.append(im)
 sheet=Image.new("RGBA",(40*len(frames),40))
 for i,f in enumerate(frames):sheet.alpha_composite(f,(i*40,0))
 sheet.save(OUT/"PIXELLAB_INTERPOLATION_RAW_SHEET.png")
 after=balance(key())
 rec.update({"status":"PROVIDER_FRAMES_RETURNED_ART_QA_PENDING","frame_count":len(frames),
  "bboxes":[f.getbbox() for f in frames],"bill":response.get("billing_usage"),
  "after":after,"sheet_sha256":sha(OUT/"PIXELLAB_INTERPOLATION_RAW_SHEET.png")})
 save(lock,rec)
 print("RESULT_FRAME_COUNT",len(frames),"BBOX",rec["bboxes"],
 "BILL",rec["bill"],"BALANCE",after["generations"],flush=True);sys.exit(0)
rec["status"]="POLL_LIMIT_DO_NOT_RESUBMIT";save(lock,rec)
