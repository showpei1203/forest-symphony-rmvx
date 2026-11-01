"""A28 FS approved 1:1 chibi sword-battle pose-driven Pixellab v3.
Single paid request, no automatic retries. Uses original A26 approved 40x40 sprite.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import json,hashlib,io,base64,sys,time,shutil
A23=Path(r"E:\GameAssetToolLab_20261023\A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST")
A26=Path(r"E:\GameAssetToolLab_20261023\A26_PMD0001_APPROVED_SHEETS_FS_RATIO_REPAIR_20261101")
A27=Path(r"E:\GameAssetToolLab_20261023\A27_PMD6_FS_CHIBI_ACTIONS_20261101")
ROOT=Path(r"E:\GameAssetToolLab_20261023\A28_FS_SKELETON_BATTLE_AND_FOUR_ACTIONS_20261101")
ROOT.mkdir(exist_ok=True)
SRC=A26/"FS_NATIVE_PIXEN_RATIO_FIX"/"PIXEL_LAB_FS_NATIVE_RATIO_CANDIDATE_40.png"
KEYPOINTS=A27/"FS_SKELETON_CONTROL_TEST"/"estimated_keypoints.json"
assert Image.open(SRC).size==(40,40) and KEYPOINTS.exists()
sys.path.insert(0,str(A23))
from a23_one_paid_spritesheet_trial import key,balance,api
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(p,obj):p.write_text(json.dumps(obj,ensure_ascii=False,indent=2),encoding='utf-8')
def encoded(p):
 return {"type":"base64","base64":base64.b64encode(p.read_bytes()).decode(),"format":"png"}
def kp(template,shift):
 o=[]
 for q in template:
  label=q['label']
  dx,dy=shift.get(label,(0,0))
  z=max(-20,min(20,int(round(q.get('z_index',0)))))
  o.append(dict(label=label,x=round(max(0,min(1,q['x']+dx)),5),
                y=round(max(0,min(1,q['y']+dy)),5),z_index=z))
 return o
original=json.loads(KEYPOINTS.read_text(encoding="utf8"))
assert len(original)==18 and len(set(a['label'] for a in original))==18
# This hero holds his sword on viewer's right side; pixelLab LEFT ARM is that screen-right weapon arm.
phases=[
 {"LEFT ELBOW":(-0.025,-0.05),"LEFT ARM":(-0.035,-0.10)},
 {"LEFT ELBOW":(-0.06,-0.10),"LEFT ARM":(-0.12,-0.19),"LEFT SHOULDER":(-0.01,0)},
 {"LEFT ELBOW":(0.08,-0.09),"LEFT ARM":(0.18,-0.18),"LEFT SHOULDER":(0.00,-0.01)},
 {"LEFT ELBOW":(0.13,0.02),"LEFT ARM":(0.25,0.04)},
 {"LEFT ELBOW":(0.07,0.03),"LEFT ARM":(0.16,0.12)},
 {"LEFT ELBOW":(0.00,0.00),"LEFT ARM":(0.00,0.00)},
]
poses=[kp(original,phase) for phase in phases]
target=ROOT/"FS_SKELETON_ATTACK";target.mkdir(exist_ok=True)
lock=target/"SUBMISSION_LOCK.json"
if lock.exists():
 print("EXISTING_LOCK_NO_RESEND");sys.exit(0)
shutil.copy2(SRC,target/"USER_APPROVED_CHIBI_SOURCE_40.png")
save(target/"POSES.json",{"source_estimated_pose":original,"frames":poses,"side_screen_right_weapon_arm":"LEFT ARM"})
b=balance(key());assert b['status']=='active' and b['generations']>30
request={
 "description":"white-haired large-head chibi fantasy sword fighter, small teal armor, dark brown leather gloves and short steel sword held in screen-right hand, tiny cape, 1:1 head to body ratio, refined consistent pixel art",
 "action":"short sword slash attack, windup overhead, powerful visible diagonal slash forward to screen right, recover",
 "direction":"south-east","view":"low top-down","first_frame":encoded(SRC),
 "first_frame_keypoints":kp(original,{}),"keypoints":poses,"template_id":"mannequin",
 "seed":28110105,"no_background":True}
record={"stage":"A28","route":"/animate-with-skeleton-v3","status":"SUBMISSION_LOCK_BEFORE_POST",
 "source":str(SRC),"sha256":sha(SRC),"baseline_user_approved":True,
 "first_frame_estimated_18_joints":True,"six_generated_pose_frames":len(poses),
 "balance_before":b,"attempt_count":1}
save(lock,record)
print("SUBMIT_SKELETON",flush=True)
s,d=api(key(),"/animate-with-skeleton-v3",request)
job=d.get("background_job_id")
record.update({"http_status":s,"job_id":job,"usage":d.get('usage')})
if not (s in (200,201,202) and job):
 record.update({"status":"REQUEST_REJECTED_UNCERTAIN_NO_RETRY","error":str(d)[:550]})
 save(lock,record);print("REJECTED",s,str(d)[:300]);sys.exit(0)
record['status']='ACCEPTED_POLLING';save(lock,record)
print('SKELETON_JOB_ACCEPTED',job,flush=True)
for i in range(80):
 time.sleep(4)
 stat,data=api(key(),"/background-jobs/"+job)
 if stat!=200:continue
 if i%5==0:print("POLL",i,data.get('status'),flush=True)
 if data.get('status') in ('failed','error','canceled'):
  record.update({"status":"FAILED_NO_RETRY","provider_status":data.get('status')});save(lock,record);sys.exit(0)
 if data.get('status') not in ('completed','succeeded','success'):continue
 last=data.get('last_response',{})
 array=last.get('images') or data.get('images')
 if not array or not isinstance(array,list):
  record.update({"status":"NO_IMAGES_NO_RETRY","response_keys":list(last)})
  save(lock,record);sys.exit(0)
 ims=[]
 for i,obj in enumerate(array):
  data=obj.get("image",obj) if isinstance(obj,dict) else obj
  if isinstance(data,dict):data=data.get('base64','')
  if data.startswith('data:'):data=data.split(',',1)[1]
  im=Image.open(io.BytesIO(base64.b64decode(data))).convert('RGBA')
  ims.append(im)
  im.save(target/f"SKELETON_FRAME_{i:02}.png")
 if any(im.size!=(40,40) for im in ims):
  record.update({"status":"UNEXPECTED_DIMS","dims":[list(im.size) for im in ims]});save(lock,record);sys.exit(0)
 sheet=Image.new("RGBA",(40*len(ims),40))
 for j,im in enumerate(ims):sheet.alpha_composite(im,(j*40,0))
 sheet.save(target/"PIXELLAB_SKELETON_ATTACK_40_SHEET.png")
 preview=Image.new("RGB",(240*len(ims),240),(235,238,242))
 for j,im in enumerate(ims):
  bg=Image.new("RGBA",(40,40),(235,238,242,255));bg.alpha_composite(im)
  preview.paste(bg.convert("RGB").resize((240,240),Image.Resampling.NEAREST),(j*240,0))
 preview.save(target/"PIXELLAB_SKELETON_ATTACK_6X.png")
 after=balance(key())
 stats={"bbox":[im.getbbox() for im in ims],
   "edge_bottom_opaque":[sum(im.getpixel((x,39))[3]>0 for x in range(40)) for im in ims],
   "frames":len(ims),"pixel_change":[sum(a!=b for a,b in zip(Image.open(SRC).convert('RGBA').getdata(),im.getdata())) for im in ims]}
 record.update({"status":"PROVIDER_IMAGES_SAVED_REVIEW_PENDING","stats":stats,"balance_after":after,
 "generation_usage":data.get('usage'),"sheet_sha256":sha(target/"PIXELLAB_SKELETON_ATTACK_40_SHEET.png")})
 save(lock,record)
 print("FINISHED",json.dumps(stats),"BALANCE",after['generations'],flush=True)
 sys.exit(0)
record['status']='POLL_LIMIT_NO_REPOST';save(lock,record)
print("POLL_LIMIT",flush=True)
