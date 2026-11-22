#!/usr/bin/env python3
"""FS T-B TB11: independent PMD0002/0003 source-locked lava frog evolution animations.
PixelLab Skeleton v3, temporary Windows API execution; never store private sprites
or API token in public GitHub. Re-uses approved PMD0001 V6 14-joint morphology.
"""
import argparse,os,base64,json,hashlib,io,pathlib,time,urllib.request,urllib.error
from PIL import Image
ap=argparse.ArgumentParser();ap.add_argument('--work',required=True);ap.add_argument('--tasks',default='2:idle,2:attack,3:idle,3:attack');ap.add_argument('--submit',action='store_true');ap.add_argument('--poll',action='store_true');ap.add_argument('--rounds',type=int,default=45)
a=ap.parse_args();w=pathlib.Path(a.work);w.mkdir(parents=True,exist_ok=True)
TOKEN=os.getenv('PIXELLAB_API_TOKEN');assert TOKEN,'Connected PixelLab credential missing'
SOURCES={1:'fc7be3a93d4940a3a9c6d0fb19ffeaa7715a6b98c2e549e37b92b774df73f46c',2:'b862486cb5a6039b6afdf78dba33f60ba4f632562a0a5294867df2bf0dff699f',3:'787c895b294e35c93de94dbcc786d9e3291a7083de5997673c8ab10b592893bb'}
RIG=[('body',None,'mid'),('shell','body','mid'),('neck','body','mid'),('nose','neck','mid'),('jaw','neck','near'),('rear hip','body','far'),('rear knee','rear hip','far'),('rear paw','rear knee','far'),('near shoulder','body','near'),('near elbow','near shoulder','near'),('near paw','near elbow','near'),('far shoulder','body','far'),('far elbow','far shoulder','far'),('far paw','far elbow','far')]
BASE={'body':(31,44),'shell':(23,35),'neck':(43,42),'nose':(50,42),'jaw':(44,48),'rear hip':(20,46),'rear knee':(19,50),'rear paw':(18,54),'near shoulder':(29,47),'near elbow':(29,52),'near paw':(29,56),'far shoulder':(44,46),'far elbow':(45,50),'far paw':(46,53)}
# Per-frame absolute root shifts and true jaw, paw, knee articulations. No global warped "animation".
def P(dx=0,dy=0,gape=0,rpa=(0,0),npa=(0,0),fpa=(0,0),head=(0,0),leg=0):return (dx,dy,gape,rpa,npa,fpa,head,leg)
IDLE=[P(),P(dy=-1,npa=(1,0)),P(dy=-2,npa=(1,-1),head=(0,-1)),P(dy=-1),P(dy=1,rpa=(0,1)),P(dy=2,npa=(-1,0),head=(0,1)),P(dy=1),P()]
ATTACK=[P(),P(dx=-2,dy=2,leg=2),P(dx=3,dy=-3,rpa=(-2,-2),npa=(4,-4),fpa=(4,-4)),P(dx=7,dy=-7,rpa=(-4,-3),npa=(9,-7),fpa=(9,-7)),P(dx=10,dy=-8,gape=4,rpa=(-5,-3),npa=(10,-8),fpa=(11,-8)),P(dx=13,dy=-7,gape=9,rpa=(-5,-2),npa=(11,-7),fpa=(12,-8)),P(dx=10,dy=-4,gape=5,npa=(9,-5),fpa=(11,-5)),P(dx=6,dy=-1,gape=1,npa=(5,-2),fpa=(6,-2)),P(dx=3,dy=1),P(dx=1),P()]
HURT=[P(),P(dx=-3,dy=2,head=(-3,2),leg=1),P(dx=-6,dy=4,head=(-5,4),leg=4),P(dx=-5,dy=5,head=(-3,3),leg=3),P(dx=-2,dy=2,head=(-1,1)),P()]
KO=[P(),P(dx=-2,dy=2,leg=2),P(dx=-4,dy=4,head=(-3,2),leg=3),P(dx=-7,dy=8,head=(-6,4),leg=5),P(dx=-9,dy=12,head=(-7,7),leg=7),P(dx=-9,dy=12,head=(-7,8),leg=7),P(dx=-9,dy=12,head=(-7,8),leg=7),P(dx=-9,dy=12,head=(-7,8),leg=7)]
MOVES={'idle':IDLE,'attack':ATTACK,'hurt':HURT,'ko':KO}
PROMPTS={
'idle':'stationary breathing and subtle shell-rise idle, weight shifting over four frog feet, lava fissures glowing softly. Keep one head and four connected legs.',
'attack':'physical quadruped crouch then jump toward SE, snap an OPEN JAW BITE with visible dark mouth, all FOUR articulated frog feet push off, land and recover; no new limbs, no magic fireball.',
'hurt':'sharp recoil after impact then recovery; four feet stay attached, head ducks and molten back shell remains same, no splitting or disappearing.',
'ko':'collapse into defeated four-legged crouch then remain down, eyelid closes and shell sinks, all 4 limbs connected, no flames/projectiles or extra creatures.'}

def sha(data):return hashlib.sha256(data).hexdigest()
def call(path,body=None):
 req=urllib.request.Request('https://api.pixellab.ai/v2'+path,data=json.dumps(body).encode() if body is not None else None,headers={'Authorization':'Bearer '+TOKEN,'Content-Type':'application/json'})
 try:
  with urllib.request.urlopen(req,timeout=90) as f:return json.load(f)
 except urllib.error.HTTPError as e:raise RuntimeError('HTTP '+str(e.code)+' '+e.read().decode('utf8','replace')[:600])

def load_source(stage):
 name=f'PMD000{stage}_STATIC_64.png';src=w/name;assert src.exists();assert sha(src.read_bytes())==SOURCES[stage]
 orig=Image.open(src).convert('RGBA');assert orig.size==(64,64)
 pad=Image.new('RGBA',(128,128));pad.alpha_composite(orig,(32,32))
 dest=w/f'PMD000{stage}_PAD128_SOURCE.png';pad.save(dest);return dest

def joints(p):
 dx,dy,gape,rpa,npa,fpa,head,leg=p;d={}
 for name,parent,side in RIG:
  x,y=BASE[name];x+=dx;y+=dy
  if name in ('neck','nose','jaw'):x+=head[0];y+=head[1]
  if name=='jaw':y+=gape
  if name=='rear knee':x+=rpa[0]//2;y+=rpa[1]//2+leg
  if name=='rear paw':x+=rpa[0];y+=rpa[1]+leg
  if name=='near elbow':x+=npa[0]//2;y+=npa[1]//2
  if name=='near paw':x+=npa[0];y+=npa[1]
  if name=='far elbow':x+=fpa[0]//2;y+=fpa[1]//2
  if name=='far paw':x+=fpa[0];y+=fpa[1]
  x+=32;y+=32;assert 2<=x<=126 and 2<=y<=126,(name,x,y)
  d[name]={'label':name,'x':round(x/128,5),'y':round(y/128,5),'z_index':{'near':12,'mid':8,'far':4}[side]}
 return list(d.values())

def unpack(v):
 if isinstance(v,dict):
  for k in ('base64','image','data'):
   if k in v:return unpack(v[k])
 if isinstance(v,str):
  if v.startswith('data:'):v=v.split(',',1)[1]
  try:return Image.open(io.BytesIO(base64.b64decode(v))).convert('RGBA')
  except Exception:return None
 return None
jobsfile=w/'TB11_PROVIDER_JOBS.json';jobs=json.loads(jobsfile.read_text()) if jobsfile.exists() else {}
tasks=[(int(i.split(':')[0]),i.split(':')[1]) for i in a.tasks.split(',')];assert all(st in SOURCES and action in MOVES for st,action in tasks)
if a.submit:
 for stage,action in tasks:
  key=f'{stage}_{action}'
  if key in jobs:continue
  src=load_source(stage);moves=MOVES[action]
  body={'description':f'SAME original molten rock LAVA FROG STAGE {stage}: black volcanic armor shell, vivid orange glowing molten cracks, brick-red skin, orange clawed feet, golden amber eyes, short wide low quadruped. Original south-east 3/4 camera, not a bat, one creature, transparent background.',
       'action':PROMPTS[action], 'direction':'south-east','view':'low top-down','template_id':'dog','seed':202611900+stage*10+list(MOVES).index(action),'no_background':True,
       'first_frame':{'type':'base64','format':'png','base64':base64.b64encode(src.read_bytes()).decode()},
       'rig':[{'name':n,'parent':par,'side':side} for n,par,side in RIG],
       'first_frame_keypoints':joints(moves[0]),'keypoints':[joints(p) for p in moves]}
  rec={'stage':stage,'action':action,'source_sha256':SOURCES[stage],'input_sha256':sha(src.read_bytes()),'prompt':PROMPTS[action],'seed':body['seed'],'frames':len(moves),'cell':[128,128],'status':'submitting'}
  jobs[key]=rec;jobsfile.write_text(json.dumps(jobs,ensure_ascii=False,indent=2))
  try:
   ret=call('/animate-with-skeleton-v3',body)
   rec.update({'job_id':ret.get('background_job_id'),'status':ret.get('status','submitted'),'submitted_usage':ret.get('usage')});assert rec['job_id']
   print('SUBMITTED',key,rec['job_id'],flush=True)
  except Exception as ex:
   rec.update({'status':'submit_failed','error':str(ex)[:500]});print('SUBMIT_FAIL',key,str(ex)[:200],flush=True)
  jobsfile.write_text(json.dumps(jobs,ensure_ascii=False,indent=2))
if a.poll:
 for n in range(a.rounds):
  for stage,action in tasks:
   key=f'{stage}_{action}';rec=jobs.get(key,{})
   if rec.get('status') in ('completed','failed','qa_failed','submit_failed'):continue
   jid=rec.get('job_id')
   if not jid:continue
   try:r=call('/background-jobs/'+jid)
   except Exception as ex:print('POLL_EXCEPTION',key,str(ex)[:100],flush=True);continue
   last=r.get('last_response') or {};status=r.get('status')
   print('POLL',n,key,status,last.get('progress'),'usage',r.get('usage'),flush=True)
   if status=='failed':rec.update({'status':'failed','error':str({k:v for k,v in last.items() if k!='images'})[:400],'usage':r.get('usage')});continue
   if status!='completed':continue
   ims=[]
   for fld in ('images','frames','output_images'):
    for v in last.get(fld,[]) or []:
     im=unpack(v)
     if im is not None:ims.append(im)
   if len(ims)!=rec['frames'] or any(i.size!=(128,128) for i in ims):
    rec.update({'status':'qa_failed','got_frames':len(ims),'frame_sizes':[list(i.size) for i in ims]});continue
   atlas=Image.new('RGBA',(512,128*((len(ims)+3)//4)));borders=[];uniques=[]
   for i,im in enumerate(ims):
    atlas.alpha_composite(im,((i%4)*128,(i//4)*128))
    im.save(w/f'PMD000{stage}_{action.upper()}_F{i:02}.png')
    alpha=im.getchannel('A');edge=sum(alpha.getpixel((x,y))>0 for x in range(128) for y in (0,127))+sum(alpha.getpixel((x,y))>0 for y in range(1,127) for x in (0,127));borders.append(edge)
    uniques.append(sha(im.tobytes()))
   name=f'PMD000{stage}_{action.upper()}_{len(ims)}F_128px.png';atlas.save(w/name)
   qa='PASS' if all(x==0 for x in borders) and len(set(uniques))>=3 else 'HOLD'
   rec.update({'status':'completed','atlas_name':name,'generation_id':last.get('generation_id'),'usage':r.get('usage'),'sheet_sha256':sha((w/name).read_bytes()),'border_counts':borders,'unique_frames':len(set(uniques)),'qa':qa})
   print('COMPLETE',key,name,'QA',qa,'BORDERS',borders,'USAGE',r.get('usage'),flush=True)
  jobsfile.write_text(json.dumps(jobs,ensure_ascii=False,indent=2))
  if all(jobs.get(f'{stage}_{action}',{}).get('status') in ('completed','failed','qa_failed','submit_failed') for stage,action in tasks):break
  time.sleep(9)
 print('FINAL',json.dumps({k:{j:v for j,v in m.items() if j in ('job_id','status','qa','sheet_sha256','usage','border_counts')} for k,m in jobs.items()}),flush=True)
