"""A39 one true PixelLab image-to-image /edit-images-v2 DAMAGE F1 trial.
Input is ORIGINAL battle-facing FS-derived A34 PixelLab sprite, never 90-deg A37 result.
No retrial on unknown status. Preserve 3 frame official delivery separately.
"""
from pathlib import Path
from PIL import Image
import sys,hashlib,json,base64,io,time,shutil
B=Path(r"E:\GameAssetToolLab_20261023")
R=B/"A39_CRITICAL_DAMAGE_NATIVE45_20261101"
R.mkdir(exist_ok=True)
S=B/"A34_FS_BATTLE45_F0_CORRECTION_20261101"/"A34_REAL_BATTLE_45_REFERENCE_MASTER_00.png"
A37=B/"A37_FS_T4_DODGE_AND_DAMAGE_20261101"
sys.path.insert(0,str(B/"A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST"))
from a23_one_paid_spritesheet_trial import key,api,balance
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def put(p,x):p.write_text(json.dumps(x,ensure_ascii=False,indent=2),encoding="utf8")
assert S.exists() and Image.open(S).size==(40,40)
shutil.copy2(S,R/"A39_AUTHORITY_NATIVE_BATTLE_45_UNARMED_F0.png")
txt=("ONE SINGULAR SEVERE CRITICAL DAMAGE HIT FRAME, use the PROVIDED genuine Forest Symphony "
"white-haired 1:1 chibi 45-degree SE three-quarter battle-facing sprite as the exact design authority. "
"Show a dramatically stronger whole-body stagger than ordinary Damage: knees collapse much deeper, "
"hips sink, torso recoils backward diagonally and curls, both EMPTY hands rise defensively around chest, "
"head tilts BACK while retaining BOTH visible eye and face planes in the SAME 45 degree camera, "
"eyes tightly shut and mouth open in pain. Keep the character centered and boots near the original "
"ground line; no sideways translation or magical floating. This is the MOMENT OF HEAVY IMPACT. "
"Same detailed white spiky hair, same dark teal gold-accent armor, small 1:1 body, leg/shoulder "
"proportions, no new body parts. Explicitly forbid pure SIDE profile, no 90-degree single-eye face; "
"shoulders, chest and hips must stay aligned to diagonal camera. No sword, hilt, sheath, shield, "
"bow, projectile, glow, spell effect or text. ONE transparent native 40x40 pixel-art character, "
"crisp grid and coherent anatomy. Do not pose as Idle, Walking or Dodging.")
(R/"A39_DAMAGE_F1_EDIT_PROMPT.txt").write_text(txt,encoding="utf8")
lock=R/"A39_F1_EDIT_SUBMISSION_LOCK.json"
if lock.exists():
 print("PREEXISTING_LOCK_NO_REPOST");sys.exit(0)
before=balance(key())
assert before["status"]=="active" and float(before["generations"])>20
p={"method":"edit_with_text",
"edit_images":[{"image":{"type":"base64","base64":"data:image/png;base64,"+base64.b64encode(S.read_bytes()).decode("ascii"),"format":"png"},"width":40,"height":40}],
"image_size":{"width":40,"height":40},"description":txt,"no_background":True,"seed":39110106}
record={"stage":"A39","action":"CRITICAL_DAMAGE","frame":"F1","method":"/edit-images-v2",
"status":"LOCKED_BEFORE_API","input_file":str(S),"input_sha256":sha(S),
"comparison":"A37 C F1 90deg FAIL; A38 normal Damage reference, critical should be stronger",
"before":before,"attempts":1}
put(lock,record)
status,resp=api(key(),"/edit-images-v2",p)
job=resp.get("background_job_id") if isinstance(resp,dict) else None
record.update({"http_status":status,"job_id":job})
if status not in (200,201,202) or not job:
 record.update({"status":"REJECTED_OR_UNKNOWN_DO_NOT_REPOST","error":str(resp)[:660]});put(lock,record)
 print("API_NOT_ACCEPTED",status,str(resp)[:450],flush=True);sys.exit(0)
record["status"]="JOB_ACCEPTED";put(lock,record)
print("A39_REAL_PIXEL_LAB_IMAGE_EDIT_JOB",job,flush=True)
for k in range(110):
 time.sleep(4)
 s,o=api(key(),"/background-jobs/"+job)
 if s!=200:continue
 st=o.get("status")
 if k%5==0:print("PIXELLAB_STATUS",k,st,flush=True)
 if st in ("failed","error","canceled"):
  record.update({"status":"JOB_FAILED_DO_NOT_REPOST","provider_status":st});put(lock,record);sys.exit(0)
 if st not in ("completed","success","succeeded"):continue
 last=o.get("last_response") or {}
 arr=last.get("images") or last.get("edited_images") or o.get("images")
 if not isinstance(arr,list) or not arr:
  record.update({"status":"PROVIDER_RESPONSE_MISSING_IMAGES","returned_keys":list(last)});put(lock,record);sys.exit(0)
 v=arr[0]
 if isinstance(v,dict):v=v.get("image",v)
 if isinstance(v,dict):v=v.get("base64")
 if not isinstance(v,str):
  record.update({"status":"IMAGE_DATA_MISSING"});put(lock,record);sys.exit(0)
 if v.startswith("data:"):v=v.split(",",1)[1]
 im=Image.open(io.BytesIO(base64.b64decode(v))).convert("RGBA")
 if im.size!=(40,40):
  record.update({"status":"WRONG_OUTPUT_DIMENSIONS","size":list(im.size)});put(lock,record);sys.exit(0)
 file=R/"A39_PIXELLAB_NATIVE_BATTLE_DAMAGE_F1_REAL_40.png"
 im.save(file)
 after=balance(key())
 record.update({"status":"ONE_REAL_FRAME_READY_ART_CAMERA_GATE_PENDING","bbox":im.getbbox(),
 "after":after,"bill":last.get("billing_usage"),"output_sha256":sha(file)})
 put(lock,record)
 print("A39_REAL_FRAME_SAVED",file,"BBOX",im.getbbox(),"BILL",record["bill"],"BALANCE",after["generations"],flush=True)
 sys.exit(0)
record.update({"status":"POLL_LIMIT_DO_NOT_REPOST"});put(lock,record)
