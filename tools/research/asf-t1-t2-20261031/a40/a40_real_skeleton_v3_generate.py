"""A40 REAL PixelLab /animate-with-skeleton-v3, exactly 3 output frames.
First frame = original A34 true native battle view.
All 18 keypoints estimated by genuine PixelLab /estimate-skeleton (cost 0.1 gen).
Three controlled skeletons source-derived, each has 18 labeled joints.
Strong whole-body critical stagger with camera explicit south-east.
One paid animation job max, pre-submit lock, never duplicate POST.
"""
from pathlib import Path
from PIL import Image
import json,base64,hashlib,sys,io,time
B=Path(r"E:\GameAssetToolLab_20261023");R=B/"A40_CRITICAL_DAMAGE_SKELETON_CONTROL_20261101"
SRC=B/"A34_FS_BATTLE45_F0_CORRECTION_20261101"/"A34_REAL_BATTLE_45_REFERENCE_MASTER_00.png"
sys.path.insert(0,str(B/"A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST"))
from a23_one_paid_spritesheet_trial import key,api,balance
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def wr(p,d):p.write_text(json.dumps(d,ensure_ascii=False,indent=2),encoding="utf8")
data=json.loads((R/"A40_CRITICAL_3POSE_18JOINT_CONTROL.json").read_text(encoding='utf8'))
original=data["keyframes"];assert len(original)==3 and all(len(k)==18 for k in original)
assert Image.open(SRC).size==(40,40)
lock=R/"A40_CRITICAL_V3_SUBMISSION_LOCK.json"
if lock.exists():print("LOCK_EXISTS_DO_NOT_REPEAT");sys.exit(0)
begin=balance(key());assert begin.get("status")=="active" and begin["generations"]>20
description=("white-haired spiky big-headed 1:1 chibi fantasy fighter with rich dark-teal and gold "
"armor, empty hands without weapons, tiny short legs and original pixel-art character face")
action="critical damage recoil"
payload={"description":description,"action":action,"direction":"south-east","view":"low top-down",
"first_frame":{"type":"base64","base64":base64.b64encode(SRC.read_bytes()).decode("ascii"),"format":"png"},
"first_frame_keypoints":original[0],"keypoints":original,"template_id":"mannequin",
"seed":40110101,"no_background":True}
report={"stage":"A40","status":"PRE_SUBMISSION_LOCK","endpoint":"/animate-with-skeleton-v3",
"source_sha256":sha(SRC),"skeleton_json_sha256":sha(R/"A40_CRITICAL_3POSE_18JOINT_CONTROL.json"),
"first_frame_keypoint_count":18,"output_frame_keypoint_counts":[len(k) for k in original],
"requested_frames":3,"direction":"south-east","view":"low top-down",
"description":description,"action":action,"before":begin,"retries":0}
wr(lock,report)
s,resp=api(key(),"/animate-with-skeleton-v3",payload)
job=resp.get("background_job_id") if isinstance(resp,dict) else None
report.update({"http":s,"job_id":job})
if s not in (200,201,202) or not job:
 report.update({"status":"REJECTED_NO_RESEND","error":str(resp)[:750]});wr(lock,report)
 print("A40_NOT_ACCEPTED",s,str(resp)[:500],flush=True);sys.exit(0)
report["status"]="PROVIDER_JOB_ACCEPTED";wr(lock,report)
print("A40_REAL_SKELETON_JOB",job,flush=True)
for i in range(90):
 time.sleep(4)
 code,data=api(key(),"/background-jobs/"+job)
 if code!=200:continue
 st=data.get("status")
 if i%5==0:print("POLL",i,st,flush=True)
 if st in ("failed","error","canceled"):
  report.update({"status":"JOB_FAILED_NO_RESEND","provider_status":st});wr(lock,report);sys.exit(0)
 if st not in ("completed","succeeded","success"):continue
 last=data.get("last_response") or {}
 arr=last.get("images") or data.get("images")
 if not isinstance(arr,list) or len(arr)!=3:
  report.update({"status":"BAD_RESULT_COUNT","result_keys":list(last),"frame_count":len(arr) if isinstance(arr,list) else None});wr(lock,report)
  print("BAD_FRAME_COUNT",report["frame_count"],flush=True);sys.exit(0)
 frames=[]
 for j,x in enumerate(arr):
  v=x.get("image",x) if isinstance(x,dict) else x
  if isinstance(v,dict):v=v.get("base64")
  if not isinstance(v,str):
   report.update({"status":"BAD_FRAME_DATA","index":j});wr(lock,report);sys.exit(0)
  if v.startswith("data:"):v=v.split(",",1)[1]
  im=Image.open(io.BytesIO(base64.b64decode(v))).convert("RGBA")
  if im.size!=(40,40):
   report.update({"status":"WRONG_FRAME_SIZE","index":j,"size":list(im.size)});wr(lock,report);sys.exit(0)
  name=R/f"A40_REAL_SKELETON_V3_FRAME_{j:02}.png";im.save(name);frames.append(im)
 strip=Image.new("RGBA",(120,40))
 for j,f in enumerate(frames):strip.alpha_composite(f,(j*40,0))
 sheet=R/"A40_RAW_REAL_PIXELLAB_3FRAME_120x40.png";strip.save(sheet)
 after=balance(key())
 report.update({"status":"THREE_REAL_PROVIDER_FRAMES_READY_ART_QA_PENDING","after":after,
  "frame_bboxes":[f.getbbox() for f in frames],"provider_billing":last.get("billing_usage"),
  "sheet_sha256":sha(sheet)})
 wr(lock,report)
 print("A40_REAL_SKELETON_GENERATION_DONE","BBOX",report["frame_bboxes"],
 "BILL",report["provider_billing"],"BALANCE",after["generations"],flush=True)
 sys.exit(0)
report["status"]="POLL_LIMIT_NO_RESEND";wr(lock,report)
