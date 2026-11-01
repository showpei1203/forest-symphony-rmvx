"""FS original native-sized constrained 40x40 PixelLab Pixen edit to preserve true chibi proportions."""
from PIL import Image
from pathlib import Path
from io import BytesIO
import sys,base64,json,time,hashlib,shutil
A23=Path(r"E:\GameAssetToolLab_20261023\A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST")
ROOT=Path(r"E:\GameAssetToolLab_20261023\A26_PMD0001_APPROVED_SHEETS_FS_RATIO_REPAIR_20261101")
OUT=ROOT/"FS_NATIVE_PIXEN_RATIO_FIX"
OUT.mkdir(exist_ok=True)
sys.path.insert(0,str(A23))
from a23_one_paid_spritesheet_trial import key,balance,api
def save(p,obj):p.write_text(json.dumps(obj,ensure_ascii=False,indent=2),encoding='utf-8')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
source=Image.open(A23/"PIXELLAB_INPUTS"/"FS_ACTOR01_SOURCE_BASE_RIGHT_64.png").convert('RGBA')
frame=source.crop((16,19,48,51))
print('ORIG_FRAME_BBOX',frame.getbbox(),flush=True)
padded=Image.new('RGBA',(40,40))
padded.alpha_composite(frame,(4,4))
inputfile=OUT/"ORIGINAL_1TO1_CHIBI_40x40.png"
padded.save(inputfile)
prompt="""Keep exact original Forest Symphony white-haired chibi proportions: HUGE spiky head 16px tall, tiny torso+legs 16px tall, 1:1 ratio, total character height 32px. Transparent 40x40 canvas with 4px margins and full feet visible. Redesign clothing only into detailed teal/brown traveler armour: tiny multi-tone shaded shoulders, fitted vest, belt, gloves, boots, short cape and ONE short sword. Match original pixel detail. NO long legs, small head, cropped feet, particles or background."""
print('PROMPT_LEN',len(prompt),flush=True)
assert len(prompt)<=500
(OUT/"PROMPT.txt").write_text(prompt,encoding='utf-8')
lock=OUT/"SUBMISSION_LOCK.json"
if lock.exists():
 print('EXISTING_LOCK_NO_RESUBMIT',flush=True);sys.exit(0)
k=key();b=balance(k)
assert b['status']=='active' and float(b['generations'])>20
raw=inputfile.read_bytes()
body={'image':{'type':'base64','base64':'data:image/png;base64,'+base64.b64encode(raw).decode(),'format':'png'},
 'description':prompt,'width':40,'height':40,'seed':26110121,'no_background':True}
log={'status':'PREPOST_LOCK_NO_RETRY','route':'/edit-image-pixen',
 'src_sha256':sha(inputfile),'before':b,'attempts':1,'expected_max_cost':10}
save(lock,log)
status,obj=api(k,'/edit-image-pixen',body)
job=obj.get('background_job_id')
log.update({'http':status,'job_id':job})
if status not in (200,201,202) or not job:
 log['status']='REJECTED_OR_UNKNOWN_NO_RETRY';log['error']=str(obj)[:500]
 save(lock,log);print('REJECT',status,flush=True);sys.exit(0)
log['status']='ACCEPTED';save(lock,log)
print('PIXEN_JOB_ACCEPTED',job,flush=True)
for n in range(75):
 time.sleep(4)
 c,p=api(k,'/background-jobs/'+job)
 if c!=200:continue
 st=p.get('status')
 if n%5==0:print('PIXEN_STATUS',n,st,flush=True)
 if st in ('failed','error','canceled'):
  log.update({'status':'FAILED_NO_RETRY','remote_status':st});save(lock,log);sys.exit(0)
 if st in ('completed','succeeded','success'):
  v=p.get('last_response',p)
  ims=v.get('images') if isinstance(v,dict) else None
  if not isinstance(ims,list) or not ims:
   log.update({'status':'NO_OUTPUT','keys':list(v) if isinstance(v,dict) else None});save(lock,log);sys.exit(0)
  item=ims[0];data=item.get('image',item) if isinstance(item,dict) else item
  if isinstance(data,dict):data=data.get('base64')
  if data.startswith('data:'):data=data.split(',',1)[1]
  im=Image.open(BytesIO(base64.b64decode(data))).convert('RGBA')
  im.save(OUT/'PIXEL_LAB_FS_NATIVE_RATIO_CANDIDATE_40.png')
  box=im.getbbox()
  out64=Image.new('RGBA',(64,64))
  # transfer unmodified 40x40 image into the source frame's region with 4px padding
  out64.alpha_composite(im,(12,15))
  out64.save(OUT/'FS_NATIVE_RATIO_PIXEN_64_PREVIEW.png')
  after=balance(k);delta=float(b['generations'])-float(after['generations'])
  log.update({'status':'PROVIDER_RETURNED_USER_ART_GATE_PENDING','size':im.size,'bbox':box,
    'delta':delta,'after':after,
    'bottom_alpha':sum(im.getpixel((x,39))[3]>0 for x in range(40)),
    'source_ratio':'about 1:1, full-size 32px in 40px canvas',
    'preview64':str(OUT/'FS_NATIVE_RATIO_PIXEN_64_PREVIEW.png')})
  save(lock,log)
  print('PIXEN_DONE','BBOX',box,'COST',delta,'BOTTOM_ALPHA',log['bottom_alpha'],flush=True)
  sys.exit(0)
log['status']='POLL_LIMIT_NO_RETRY';save(lock,log)
