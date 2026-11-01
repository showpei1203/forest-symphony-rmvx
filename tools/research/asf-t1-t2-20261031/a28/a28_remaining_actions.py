"""A28: Remaining four FS chibi motions from SAME approved 40x40 Pixen base.
One PixelLab call per motion. No new character design. No source overwrites.
"""
from pathlib import Path
import sys,time,base64,io,hashlib,json,shutil
from PIL import Image
ROOT=Path(r"E:\GameAssetToolLab_20261023\A28_FS_SKELETON_BATTLE_AND_FOUR_ACTIONS_20261101")
A23=Path(r"E:\GameAssetToolLab_20261023\A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST")
A26=Path(r"E:\GameAssetToolLab_20261023\A26_PMD0001_APPROVED_SHEETS_FS_RATIO_REPAIR_20261101")
SRC=A26/"FS_NATIVE_PIXEN_RATIO_FIX"/"PIXEL_LAB_FS_NATIVE_RATIO_CANDIDATE_40.png"
sys.path.insert(0,str(A23))
from a23_one_paid_spritesheet_trial import key,api,balance
PROMPTS={
"WALK":"The SAME white-haired chibi Forest Symphony swordsman marches four short steps in place, facing south-east 45 degrees. Tiny feet alternate naturally, body bounces a single pixel, cloak and short sword gently follow. Preserve original pixel-art identity, specific teal/bronze shoulder armor, thick white hair, one short sword. Strict head to body 1:1 proportions: same huge head and short chibi legs each frame, character height around 34px centered inside 40x40. No extra arms, no sword duplicates, no background, no limb stretching.",
"CAST":"The SAME Forest Symphony white-haired chibi 1:1-head/body short armored swordsman performs a clear magical casting action. The free hand rises briefly in front of his chest while the sword remains in his other hand, small cyan glow attached to casting palm, then resets. Same oversized white spiky head, tiny 16px lower body, detailed green-teal armor and short sword in each frame. No long legs, no face replacement, no giant detached particle cloud, no background. One 40x40 pixel-art character.",
"HURT":"The exact same white-haired teal-armored short-sword chibi receives a small hit, clearly flinches a few pixels backward, briefly squints, then returns to combat stance. Keep 1:1 large head-to-tiny-body ratio, fully attached small sword and detailed armor each frame. Entire character remains inside transparent 40x40 canvas. No alternate face, no shrinking head, no changing weapons, no falling off canvas, no long legs.",
"DEATH":"The SAME white-haired tiny Forest Symphony 1:1-head/body armored swordsman performs a short clear collapse/faint: head droops, knees buckle, then he falls down on his side, resting on the ground with eyes closed. Preserve the huge white hair/head and teal layered armor, one short sword stays in hand or lies directly beside body. Compact chibi sprite on transparent 40x40 pixel canvas; no drawn floor, no smoke, no disintegration, no duplicate characters, no new costume. Keep all body parts inside frame."
}
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(p,obj):p.write_text(json.dumps(obj,ensure_ascii=False,indent=2),encoding='utf8')
def parse(d):
 l=d.get('last_response') or {}
 arr=l.get('images') or d.get('images') or []
 out=[]
 for q in arr:
  data=q.get('image',q) if isinstance(q,dict) else q
  if isinstance(data,dict):data=data.get('base64','')
  if data.startswith('data:'):data=data.split(',',1)[1]
  im=Image.open(io.BytesIO(base64.b64decode(data))).convert('RGBA')
  out.append(im)
 return out
def run(name,k):
 folder=ROOT/("FS_"+name)
 folder.mkdir(parents=True,exist_ok=True)
 lock=folder/"SUBMISSION_LOCK.json"
 if lock.exists():
  print("EXISTING_LOCK_SKIP",name);return False
 before=balance(k)
 if before['status']!='active' or before['generations']<20:
  print("NO_QUOTA",before);return False
 shutil.copy2(SRC,folder/"USER_APPROVED_FS_CHIBI_SOURCE_40.png")
 (folder/"PROMPT.txt").write_text(PROMPTS[name],encoding='utf8')
 req={"first_frame":{"type":"base64","base64":base64.b64encode(SRC.read_bytes()).decode(),"format":"png"},
 "action":PROMPTS[name],"frame_count":4,"no_background":True,
 "seed":28110210+list(PROMPTS).index(name),"enhance_prompt":False}
 log={"stage":"A28","name":name,"status":"PREPOST_LOCK","source_sha256":sha(SRC),
   "baseline_approved":True,"before":before,"requests":1}
 save(lock,log)
 st,d=api(k,"/animate-with-text-v3",req)
 job=d.get('background_job_id')
 log.update({"http":st,"job_id":job,"submit_usage":d.get('usage')})
 if st not in (200,201,202) or not job:
  log['status']='REJECTED_NO_REPOST';log['short_error']=str(d)[:400]
  save(lock,log);print(name,'REJECTED',st);return False
 log['status']='JOB_ACCEPTED';save(lock,log)
 print(name,'JOB',job,flush=True)
 for j in range(85):
  time.sleep(4)
  rc,obj=api(k,"/background-jobs/"+job)
  if rc!=200:continue
  remote=obj.get('status')
  if j%5==0:print(name,"POLL",j,remote,flush=True)
  if remote in ('error','failed','canceled'):
   log.update({'status':'PROVIDER_FAILED','reason':remote});save(lock,log);return False
  if remote not in ('completed','succeeded','success'):continue
  try:images=parse(obj)
  except Exception as e:
   log.update({'status':'PARSE_FAILED','detail':str(e)});save(lock,log);return False
  if len(images)<4 or any(im.size!=(40,40) for im in images):
   log.update({'status':'INVALID_FRAMES','dims':[im.size for im in images]});save(lock,log);return False
  for i,im in enumerate(images):im.save(folder/f"FRAME_{i:02}.png")
  strip=Image.new('RGBA',(40*len(images),40))
  for i,im in enumerate(images):strip.alpha_composite(im,(40*i,0))
  strip.save(folder/"PIXELLAB_SPRITESHEET_40x5.png")
  stat={'boxes':[im.getbbox() for im in images],
    'bottom_opaque':[sum(im.getpixel((x,39))[3]>0 for x in range(40)) for im in images],
    'diffs':[sum(a!=b for a,b in zip(Image.open(SRC).convert('RGBA').getdata(),im.getdata())) for im in images]}
  log.update({'status':'RENDERED_ART_REVIEW_PENDING','provider_reported_usage':obj.get('usage'),
  'actual_frames':len(images),'stats':stat,'sheet_sha256':sha(folder/"PIXELLAB_SPRITESHEET_40x5.png"),'after':balance(k)})
  save(lock,log)
  print(name,'DONE',stat,'BALANCE',log['after']['generations'],flush=True)
  return True
 log['status']='POLL_LIMIT_NO_RETRY';save(lock,log);return False
def main():
 k=key()
 for name in PROMPTS:
  if not run(name,k):
   print('STOP_AFTER_ACTION',name,flush=True);break
if __name__=='__main__':main()
