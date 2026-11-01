"""A31 use original FS actor01 RIGHT-facing native walk keyframes as the animation data.
True original four-phase walk: step-A, neutral, step-B, neutral; original Idle=neutral STATIC.
Apply approved A29 empty-handed teal outfit through PixelLab official TRANSFER OUTFIT v2
to all actual source frames in one correlated job. No invented bone movement.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import sys,json,hashlib,base64,io,time,shutil
B=Path(r"E:\GameAssetToolLab_20261023")
R=B/"A31_FS_ORIGINAL_MOTION_TRANSFER_20261101"
R.mkdir(exist_ok=True)
SRC=Path(r"E:\RPG MAKER\260724桌面\rpg maker 2024\RPG MAKER\綠曲-V2.9\Graphics\Characters\$actor01.png")
REF=B/"A29_FS45_UNARMED_PIXELLAB_LOOP_20261101"/"A29_SELECTED_SE_VISUAL_45_UNARMED_40.png"
A30=B/"A30_FS_SOURCE_MOTION_RIG_LOOP_20261101"
sys.path.insert(0,str(B/"A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST"))
from a23_one_paid_spritesheet_trial import api,key,balance
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(p,obj):p.write_text(json.dumps(obj,ensure_ascii=False,indent=2),encoding="utf8")
def image_obj(p):
 raw=Path(p).read_bytes()
 return {"image":{"type":"base64","base64":"data:image/png;base64,"+base64.b64encode(raw).decode(),"format":"png"},
 "size":{"width":40,"height":40}}
assert sha(SRC)=="df6abaa888dc4ffcaf5351daf26d678bace121e277f21b4651eb69884591a2a5"
assert Image.open(REF).size==(40,40)
ori=Image.open(SRC).convert('RGBA');assert ori.size==(96,128)
# Four EXACT source frames. 0 c0 left step; 1 c1 neutral; 2 c2 right step; 3 c1 neutral (duplicated exact).
order=[0,1,2,1]
root_frames=[]
for i,c in enumerate(order):
 crop=ori.crop((32*c,2*32,32*(c+1),3*32))
 assert crop.size==(32,32)
 pad=Image.new("RGBA",(40,40));pad.alpha_composite(crop,(4,6))
 p=R/f"ORIGINAL_WALK_FRAME_{i:02}_C{c}.png";pad.save(p);root_frames.append(p)
assert root_frames[1].read_bytes()==root_frames[3].read_bytes()
# Native Idle is a static center image; do not synthesize repeated trembling frames.
shutil.copy2(root_frames[1],R/"ORIGINAL_NATIVE_STATIC_IDLE.png")
src_info={"source_path":str(SRC),"source_sha256":sha(SRC),
 "outfit_reference_sha256":sha(REF),"original_direction":"right row2",
 "native_walk_cycle_columns":order,"native_idle_center_column":1,
 "pads":{"left":4,"top":6},"frame_size":[40,40],
 "original_walk_motion":"EXACT 32x32 source pixels, zero edits, four phases A-neutral-B-neutral",
 "original_idle_motion":"STATIC neutral center frame, NOT a breathing/shoulder movement animation",
 "frame_hashes":[sha(p) for p in root_frames]}
save(R/"A31_NATIVE_SOURCE_CYCLE_MANIFEST.json",src_info)
lock=R/"TRANSFER_OUTFIT_SUBMISSION_LOCK.json"
if lock.exists():
 print("A31_LOCK_EXISTS_DO_NOT_RESUBMIT");sys.exit(0)
b=balance(key());assert b['status']=='active' and b["generations"]>25
request={
 "reference_image":image_obj(REF),
 "frames":[image_obj(p) for p in root_frames],
 "image_size":{"width":40,"height":40},
 "seed":31110101,"no_background":True,
 "additional_instructions":(
  "KEEP EXACT source sprite skeletal motion from all 4 original Forest Symphony actor01 RIGHT-facing r2 frames! "
  "They form one native walk cycle: near foot step, neutral, far foot step, neutral. Preserve same feet baselines, "
  "full big spiky white hair and 1:1 head-to-body ratio, knee orientation, hip movement and arm swings. "
  "Only TRANSFER the reference character's teal/bronze armor clothing and white-hair identity into source poses. "
  "The reference has unarmed empty fists; ALL FOUR FRAMES must be UNARMED: no sword, shield, dagger, hilt, scabbard. "
  "Reference is the intended roughly southeast 3/4 battle-facing character; do not switch facing across frames. "
  "No new invented frames, vertical bouncing, shoulder jitter, blurred pixels or scene backdrop."
 )}
record={"stage":"A31","status":"PREPOST_LOCK_NO_RETRY","method":"REAL_FS_FOUR_ORIGINAL_POSES_PLUS_A29_REFERENCE",
 "source_sha256":sha(SRC),"reference_sha256":sha(REF),"frame_hashes":src_info["frame_hashes"],
 "before":b,"attempt_count":1,"route":"/transfer-outfit-v2"}
save(lock,record)
print("A31_PUT_REAL_NATIVE_FRAMES",flush=True)
s,d=api(key(),"/transfer-outfit-v2",request)
job=d.get('background_job_id')
record.update({"http":s,"job_id":job,"usage":d.get("usage")})
if s not in (200,201,202) or not job:
 record.update({"status":"REJECTED_OR_UNCERTAIN_NO_REPOST","error":str(d)[:700]});save(lock,record)
 print("REJECTED",s,str(d)[:500],flush=True);sys.exit(0)
record["status"]="JOB_ACCEPTED";save(lock,record)
print("A31_PIXELLAB_TRANSFER_JOB",job,flush=True)
for i in range(95):
 time.sleep(4)
 status,response=api(key(),"/background-jobs/"+job)
 if status!=200:continue
 state=response.get('status')
 if i%5==0:print("POLL",i,state,flush=True)
 if state in ("failed","error","canceled"):
  record.update({"status":"PROVIDER_FAILED_NO_RETRY","remote_status":state});save(lock,record);sys.exit(0)
 if state not in ("completed","succeeded","success"):continue
 last=response.get('last_response') or {}
 arr=last.get('images') or last.get("edited_images") or response.get('images')
 if not isinstance(arr,list):
  record.update({"status":"UNREADABLE_RESULT_NO_RETRY","keys":list(last)});save(lock,record)
  print("UNREADABLE",list(last),flush=True);sys.exit(0)
 result=[]
 for j,x in enumerate(arr):
  q=x.get('image',x) if isinstance(x,dict) else x
  if isinstance(q,dict):q=q.get("base64")
  if not isinstance(q,str):
   record.update({"status":"BAD_IMAGE_FORMAT","idx":j});save(lock,record);sys.exit(0)
  if q.startswith('data:'):q=q.split(",",1)[1]
  im=Image.open(io.BytesIO(base64.b64decode(q))).convert("RGBA")
  if im.size!=(40,40):
   record.update({"status":"OUTPUT_GEOMETRY_FAIL","size":list(im.size)});save(lock,record);sys.exit(0)
  im.save(R/f"A31_PROVIDER_TRANSFER_FRAME_{j:02}.png");result.append(im)
 if len(result)!=4:
  record.update({"status":"UNEXPECTED_FRAME_COUNT","count":len(result)});save(lock,record);sys.exit(0)
 atl=Image.new("RGBA",(40*4,40))
 for j,im in enumerate(result):atl.alpha_composite(im,(j*40,0))
 atl.save(R/"A31_PIXELLAB_ACTUAL_ORIGINAL_MOTION_STYLE_TRANSFER_4F.png")
 after=balance(key())
 record.update({"status":"ACTUAL_OUTFIT_TRANSFER_COMPLETE_AWAITING_ART_QA",
 "frames":len(result),"frame_bboxes":[im.getbbox() for im in result],
 "after":after,"billing":last.get("billing_usage"),"output_sheet_sha256":sha(R/"A31_PIXELLAB_ACTUAL_ORIGINAL_MOTION_STYLE_TRANSFER_4F.png")})
 save(lock,record)
 print("TRANSFER_DONE","BBOX",record["frame_bboxes"],"BILL",record["billing"],"BALANCE",after["generations"],flush=True);sys.exit(0)
record["status"]="POLL_LIMIT_NO_REPOST";save(lock,record)
print("POLL_LIMIT",flush=True)
