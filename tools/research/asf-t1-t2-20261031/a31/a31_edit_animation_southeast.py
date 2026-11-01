"""A31 preserve REAL Forest Symphony native WALK frame choreography, rotate ALL frames together via PixelLab edit-animation-v2.
Input is the TRUE original 4-pose walk processed with approved costume transfer. One coherent paid call, no duplicated posts.
"""
from pathlib import Path
from PIL import Image
import sys,json,hashlib,base64,time,io
B=Path(r"E:\GameAssetToolLab_20261023")
R=B/"A31_FS_ORIGINAL_MOTION_TRANSFER_20261101"
sys.path.insert(0,str(B/"A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST"))
from a23_one_paid_spritesheet_trial import key,api,balance
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(path,x):path.write_text(json.dumps(x,ensure_ascii=False,indent=2),encoding='utf8')
source=R/"A31_FS_OUTFIT_TRANSFER_NATIVE_4_FRAME_LOOP.png"
im=Image.open(source).convert('RGBA');assert im.size==(160,40)
frames=[]
for i in range(4):
 p=R/f"A31_TRANSFERED_FRAME_{i:02}.png"
 im.crop((40*i,0,40*(i+1),40)).save(p)
 frames.append(p)
lock=R/"A31_SE45_EDIT_ANIMATION_SUBMISSION_LOCK.json"
if lock.exists():print("ALREADY_LOCKED_DO_NOT_RESUBMIT");sys.exit(0)
before=balance(key());assert before["status"]=="active" and before["generations"]>=20
req={"description":(
 "Correct ONLY camera facing of the ENTIRE existing 4-frame native source choreography. "
 "Current views are direct right side profile; turn all four frames together to the same clear low-top-down 3/4 SOUTHEAST 45-DEGREE diagonal facing down-right. "
 "Preserve the exact underlying Forest Symphony walk sequence: near-foot step, center neutral, far-foot step, SAME center neutral. "
 "This is a CHARACTER WALK ANIMATION, not a new illustration. Keep all poses and foot placement visible and the same ground contact. "
 "Maintain oversized 1:1 white-haired chibi head/body proportions, teal armor gold trims, short boots and coat, consistent face and hands. "
 "Character must be completely UNARMED in every frame: no sword, hilt, scabbard, gun or shield. "
 "Do not create random leg positions, jumping, floating, weapon artifacts, head shrinkage, deformation, blur or a background."),
 "frames":[{"image":{"type":"base64","base64":"data:image/png;base64,"+base64.b64encode(p.read_bytes()).decode(),"format":"png"},
            "size":{"width":40,"height":40}} for p in frames],
 "image_size":{"width":40,"height":40},"seed":31110199,"no_background":True}
log={"stage":"A31","status":"PREPOST_LOCK_NO_RETRY","route":"/edit-animation-v2",
 "source_original_FS":"$actor01.png row2 c0,c1,c2,c1",
 "input_transferred_strip_sha256":sha(source),"before":before,"attempt_count":1}
save(lock,log)
status,data=api(key(),"/edit-animation-v2",req)
job=data.get("background_job_id")
log.update({"http":status,"job_id":job,"submitted_usage":data.get("usage")})
if status not in (200,201,202) or not job:
 log.update({"status":"REQUEST_REJECTED_OR_UNCERTAIN_NO_RETRY","error":str(data)[:600]});save(lock,log)
 print("REJECTED",status,str(data)[:400]);sys.exit(0)
log["status"]="ACCEPTED";save(lock,log)
print("A31_ORIGINAL_MOTION_SE_45_JOB",job,flush=True)
for i in range(100):
 time.sleep(4)
 s,resp=api(key(),"/background-jobs/"+job)
 if s!=200:continue
 st=resp.get('status')
 if i%5==0:print("POLL",i,st,flush=True)
 if st in ("error","failed","canceled"):
  log.update({"status":"PROVIDER_FAILED_NO_RETRY","remote_status":st});save(lock,log);sys.exit(0)
 if st not in ("completed","succeeded","success"):continue
 last=resp.get('last_response') or {}
 arr=last.get("images") or last.get("edited_images") or resp.get("images")
 if not isinstance(arr,list):
  log.update({"status":"UNREADABLE_RESULT","keys":list(last)});save(lock,log);sys.exit(0)
 imgs=[]
 for j,x in enumerate(arr):
  v=x.get('image',x) if isinstance(x,dict) else x
  if isinstance(v,dict):v=v.get("base64")
  if not isinstance(v,str):
   log.update({"status":"UNEXPECTED_IMAGE","idx":j});save(lock,log);sys.exit(0)
  if v.startswith("data:"):v=v.split(",",1)[1]
  frame=Image.open(io.BytesIO(base64.b64decode(v))).convert("RGBA")
  if frame.size!=(40,40):
   log.update({"status":"WRONG_SIZE","size":frame.size});save(lock,log);sys.exit(0)
  frame.save(R/f"A31_SECOND_PASS_SE45_FRAME_{j:02}.png");imgs.append(frame)
 if len(imgs)!=4:
  log.update({"status":"WRONG_COUNT","length":len(imgs)});save(lock,log);sys.exit(0)
 sheet=Image.new("RGBA",(160,40))
 for j,frame in enumerate(imgs):sheet.alpha_composite(frame,(j*40,0))
 sheet.save(R/"A31_SECOND_PASS_SE45_4F_PROVIDER_RAW.png")
 log.update({"status":"SECOND_PASS_REAL_FRAMES_READY_ART_REVIEW","frame_bboxes":[i.getbbox() for i in imgs],
 "after":balance(key()),"billing":last.get("billing_usage"),
 "sheet_sha256":sha(R/"A31_SECOND_PASS_SE45_4F_PROVIDER_RAW.png")})
 save(lock,log)
 print("PASS_DONE",log["frame_bboxes"],"BILL",log["billing"],"BALANCE",log["after"]["generations"],flush=True);sys.exit(0)
log["status"]="POLL_LIMIT_NO_RETRY";save(lock,log)
