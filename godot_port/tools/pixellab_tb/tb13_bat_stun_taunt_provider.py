#!/usr/bin/env python3
"""Forest Symphony T-B R13: per-evolution-stage PixelLab 2D anatomy-locked motions.
Real provider v2/animate-with-skeleton-v3. No private images or tokens in repo.
Only run in ephemeral work dir; assets must be archived in private Drive.
"""
import argparse,base64,hashlib,io,json,os,pathlib,time,urllib.request,urllib.error
from PIL import Image

ap=argparse.ArgumentParser()
ap.add_argument('--work',required=True)
ap.add_argument('--tasks',default='1:stun,1:taunt,2:stun,2:taunt,3:stun,3:taunt')
ap.add_argument('--submit',action='store_true')
ap.add_argument('--poll',action='store_true')
ap.add_argument('--rounds',type=int,default=55)
a=ap.parse_args();root=pathlib.Path(a.work);root.mkdir(exist_ok=True,parents=True)
api='https://api.pixellab.ai/v2'
expected={
 1:('208e28e4f7732233c75456e9e5de671f5616fb68ef735165219a4b3aa2a959a2',96),
 2:('1b98c93ab8827b07d3b1c4ba7a92063fb800054d23a3256beab81e226864faac',128),
 3:('13491e632d9ed453e2c77c4799a3d63bd382b4433cf6135a1afdb0ed2a8d00f3',160),
}
tasklist=[]
for spec in a.tasks.split(','):
 stage,action=spec.strip().split(':');stage=int(stage)
 assert stage in expected and action in ('stun','taunt'),spec
 tasklist.append((stage,action))
token=os.environ.get('PIXELLAB_API_TOKEN')
if not token:raise RuntimeError('Missing connected PixelLab API credential')

def sha(b):return hashlib.sha256(b).hexdigest()
def call(path,payload=None):
 req=urllib.request.Request(api+path, data=json.dumps(payload).encode() if payload is not None else None,
   headers={'Authorization':'Bearer '+token,'Content-Type':'application/json'})
 try:
  with urllib.request.urlopen(req,timeout=110) as f:return json.load(f)
 except urllib.error.HTTPError as e:raise RuntimeError('PixelLab HTTP '+str(e.code)+' '+e.read().decode('utf8','replace')[:700])

def source(stage):
 p=root/('BAT_STAGE%d.png'%stage)
 assert p.is_file(),p
 assert sha(p.read_bytes())==expected[stage][0],('stage source mismatch',stage,sha(p.read_bytes()))
 im=Image.open(p).convert('RGBA');assert im.size==(expected[stage][1],)*2
 # All stages have 16px safe margin on a larger transparent tile so wings do not crop.
 pad=32 if stage==3 else 16
 canvas=Image.new('RGBA',(im.width+2*pad,im.height+2*pad));canvas.alpha_composite(im,(pad,pad))
 dest=root/('BAT_STAGE%d_PAD%d.png'%(stage,pad))
 canvas.save(dest)
 return canvas,dest

# local anatomy keypoints in source's ORIGINAL square, not its transparent pad.
# Real stage 2 has tall ears and a leaf-tail. Stage 3 has crown horns and chest orb.
BASE={
1:{'body':(48,53),'head':(48,35),'upper jaw':(48,44),'lower jaw':(48,48),
'left ear':(39,23),'right ear':(56,23),'left wing root':(35,46),'left wing elbow':(23,36),'left wing tip':(5,28),
'right wing root':(61,46),'right wing elbow':(74,36),'right wing tip':(91,28),'tail':(48,77)},
2:{'body':(64,79),'head':(64,53),'upper jaw':(64,64),'lower jaw':(64,68),
'left ear':(52,34),'right ear':(76,34),'left wing root':(48,62),'left wing elbow':(30,48),'left wing tip':(6,40),
'right wing root':(81,62),'right wing elbow':(99,48),'right wing tip':(123,40),'tail':(56,94)},
3:{'body':(80,92),'head':(80,68),'upper jaw':(80,80),'lower jaw':(80,84),
'left ear':(61,42),'right ear':(98,42),'left wing root':(60,75),'left wing elbow':(37,61),'left wing tip':(5,53),
'right wing root':(100,75),'right wing elbow':(121,61),'right wing tip':(155,53),'tail':(73,108)}
}
RIG=[('body',None,'mid'),('head','body','mid'),('upper jaw','head','mid'),('lower jaw','head','near'),
 ('left ear','head','far'),('right ear','head','near'),
 ('left wing root','body','far'),('left wing elbow','left wing root','far'),('left wing tip','left wing elbow','far'),
 ('right wing root','body','near'),('right wing elbow','right wing root','near'),('right wing tip','right wing elbow','near'),
 ('tail','body','mid')]

def P(dx=0,dy=0,hx=0,hy=0,lower=0,upper=0,wing=0,fold=0,tail=0):return (dx,dy,hx,hy,lower,upper,wing,fold,tail)
IDLE=[P(),P(dy=-1,wing=-4),P(dy=-2,wing=-10),P(dy=-1,wing=-5),
 P(dy=1,wing=5),P(dy=2,wing=10),P(dy=1,wing=5),P()]
ATTACK=[P(),P(dx=-1,dy=2,wing=4),P(dx=2,dy=-2,hx=1,hy=-1,wing=2),
 P(dx=4,dy=-4,hx=2,hy=-3,lower=5,upper=-1,wing=-2),
 P(dx=6,dy=-5,hx=3,hy=-3,lower=9,upper=-1,wing=-3),
 P(dx=8,dy=-4,hx=4,hy=-2,lower=10,upper=-2,wing=-2),
 P(dx=6,dy=-3,hx=3,hy=-2,lower=5,wing=1),
 P(dx=4,dy=-1,hx=2,wing=2),P(dx=2,wing=0),P(dx=1),P()]
HURT=[P(),P(dx=-3,dy=3,hx=-3,hy=2,wing=3,fold=2),
 P(dx=-7,dy=6,hx=-6,hy=3,wing=6,fold=5),
 P(dx=-5,dy=5,hx=-3,hy=2,wing=2,fold=2),P(dx=-2,dy=2,wing=-2),P()]
KO=[P(),P(dx=-2,dy=4,hx=-3,hy=2,wing=6,fold=4),P(dx=-5,dy=8,hx=-5,hy=5,wing=11,fold=8),
 P(dx=-7,dy=14,hx=-7,hy=9,wing=14,fold=14),P(dx=-7,dy=21,hx=-8,hy=11,wing=17,fold=17),
 P(dx=-7,dy=24,hx=-8,hy=12,wing=18,fold=18),P(dx=-7,dy=24,hx=-8,hy=12,wing=18,fold=18),
 P(dx=-7,dy=24,hx=-8,hy=12,wing=18,fold=18)]
GUARD=[P(),P(dx=-1,dy=2,wing=6,fold=5),P(dx=-2,dy=3,wing=10,fold=12),P(dx=-2,dy=3,wing=10,fold=12),
 P(dx=-2,dy=3,wing=9,fold=10),P(dx=-1,dy=1,wing=4,fold=3),P()]
SKILL=[P(),P(dx=-2,dy=-2,wing=-3),P(dx=-3,dy=-6,wing=-9),P(dx=-3,dy=-9,wing=-13),
 P(dx=-1,dy=-10,wing=-11,lower=2),P(dx=1,dy=-6,wing=-5,lower=3),P(dx=1,dy=-2,wing=2),P()]
FLY=[P(),P(dx=1,dy=-1,wing=-8),P(dx=2,dy=-2,wing=-13),P(dx=3,dy=-1,wing=-5),
 P(dx=4,dy=1,wing=8),P(dx=5,dy=2,wing=14),P(dx=6,dy=1,wing=6),P(dx=7,dy=0,wing=0)]
# R13: distinct neurologic stagger and threat-display, all three original morphologies source-locked.
STUN=[P(),P(dx=-1,dy=2,hx=2,hy=1,wing=6,fold=2),P(dx=2,dy=-2,hx=-2,hy=-1,wing=-5,fold=4),
 P(dx=-2,dy=3,hx=3,hy=2,wing=9,fold=7),P(dx=1,dy=1,hx=-2,hy=-1,wing=-4,fold=5),
 P(dx=-1,dy=2,hx=2,hy=2,wing=5,fold=2),P(dy=1,wing=2),P()]
TAUNT=[P(),P(dx=-1,dy=2,hy=2,wing=2),P(dy=-2,hy=-2,lower=3,wing=-5),
 P(dy=-4,hx=1,hy=-3,lower=7,wing=-10),P(dy=-5,hx=2,hy=-3,lower=10,wing=-15),
 P(dy=-3,lower=8,wing=-12),P(dy=-1,lower=3,wing=-3),P()]
SETS={'stun':STUN,'taunt':TAUNT,'idle':IDLE,'attack':ATTACK,'hurt':HURT,'ko':KO,'guard':GUARD,'skill':SKILL,'fly':FLY}
ACTION={
'stun':'STUNNED DIZZY bat, briefly loses flight balance and rocks head side to side, wings wobble asymmetrically while still attached, eyes blink in confusion, then steadies and regains hover; NEVER create extra arms or legs.',
'taunt':'INTIMIDATING BAT CRY: spread both ORIGINAL leaf-vein wings wide, open dark fanged MOUTH and tilt head upward to screech, full visible jaws, then close mouth and resume hover; wings stay attached, NO claw strike.',
'idle':'gentle wing FLAP hovering in the air, body gently bobbing, wing membranes fold and unfold while remaining attached to the shoulders, normal closed mouth, same bat species',
'attack':'MOUTH BITE ONLY: recoil, short SE head-first dive, wide open dark mouth showing two white fangs, snap jaws on frame 5, recover; wings are only balance; no hand or claw strikes',
'hurt':'HURT FLINCH: a visible hit shakes and recoils head and body backward and wings fold defensively, then rebounds to hover; no new appendages, no explosions',
'ko':'KNOCK OUT / DEFEAT: wings lose lift and fold downward as the bat droops and slumps, eyes close, remains collapsed motionless on final frames; no disappearing, splitting, extra objects',
'guard':'DEFEND: bat folds both broad leaf wings inward around chest and bends head down as a defensive shield, then unfolds to hover; no attack, arm or hands',
'skill':'SPELL CAST: levitate slightly with a raised head and spread leaf wings, inner emerald veins pulse softly then return to idle. No detached or external projectiles, retain same body and chest core',
'fly':'FLIGHT: cyclic wing power stroke with small forward drift, bat stays 3/4 southeast, legs tucked, two wings attached to shoulders, no camera turnaround'
}

def rig_keypoints(stage,motion):
 pad=32 if stage==3 else 16
 n=expected[stage][1]+2*pad;scale=expected[stage][1]/128.0
 dx,dy,hx,hy,lower,upper,wing,fold,tail=motion
 poses=[]
 for label,parent,side in RIG:
  x,y=BASE[stage][label];px=x+pad;py=y+pad
  px+=int(dx*scale);py+=int(dy*scale)
  if label in ('head','upper jaw','lower jaw','left ear','right ear'):
   px+=int(hx*scale);py+=int(hy*scale)
  if label=='upper jaw':py+=int(upper*scale)
  if label=='lower jaw':py+=int(lower*scale)
  if label in ('left wing tip','right wing tip'):
   py+=int(wing*scale)
   px+=int((fold if 'left' in label else -fold)*scale)
  if label in ('left wing elbow','right wing elbow'):
   py+=int(wing*scale/2)
   px+=int((fold if 'left' in label else -fold)*scale/2)
  if label=='tail':py+=int(tail*scale)
  assert 2<=px<n-2 and 2<=py<n-2, ('joint outside',stage,label,px,py,n)
  poses.append({'label':label,'x':round(px/n,5),'y':round(py/n,5),'z_index':{'far':4,'mid':8,'near':12}[side]})
 return poses

def unpack(obj):
 if isinstance(obj,dict):
  for k in ('base64','image','data'):
   if k in obj:return unpack(obj[k])
 if isinstance(obj,str):
  if obj.startswith('data:'):obj=obj.split(',',1)[1]
  try:return Image.open(io.BytesIO(base64.b64decode(obj))).convert('RGBA')
  except Exception:return None
 return None

jobsfile=root/'R13_BAT_PROVIDER_JOBS.json'
jobs=json.loads(jobsfile.read_text(encoding='utf8')) if jobsfile.exists() else {}
if a.submit:
 for stage,action in tasklist:
  key='%d_%s'%(stage,action)
  if key in jobs:
   print('SKIP_EXISTING_JOB',key,jobs[key].get('job_id'),flush=True);continue
  im,imgfile=source(stage)
  frames=SETS[action]
  desc=('SAME SINGLE FOREST LEAF BAT, stage %d of 3, plum violet body, paired emerald leaf-vein wings, gold eyes, two pointed ears, SE 3/4 view; no background or extra character. '%stage)
  if stage==3:desc+='Preserve tall leaf-horn crown and glowing emerald chest crystal. '
  if stage==2:desc+='Preserve leaf crest and curled tail with green leaf bud. '
  req={'description':desc[:380],
   'action':(ACTION[action]+'; preserve EXACT original identity, attached wings, two short tucked legs, no human arms, no hands, no dismemberment.').strip(),
   'direction':'south-east','view':'low top-down','template_id':'mannequin','no_background':True,
   'seed':202613300+stage*17+list(SETS).index(action),
   'first_frame':{'type':'base64','format':'png','base64':base64.b64encode(imgfile.read_bytes()).decode()},
   'rig':[{'name':x,'parent':p,'side':s} for x,p,s in RIG],
   'first_frame_keypoints':rig_keypoints(stage,frames[0]),
   'keypoints':[rig_keypoints(stage,f) for f in frames]}
  record={'stage':stage,'action':action,'source_sha256':expected[stage][0],
    'source_padded_sha256':sha(imgfile.read_bytes()),'cell':[im.width,im.height],
    'expected_frames':len(frames),'frames_sha_lock':None,
    'endpoint':'animate-with-skeleton-v3','seed':req['seed'],'model':'PixelLab Skeleton v3',
    'action_prompt':req['action'],'description':desc,'status':'submitting'}
  jobs[key]=record;jobsfile.write_text(json.dumps(jobs,indent=2,ensure_ascii=False),encoding='utf8')
  try:
   ret=call('/animate-with-skeleton-v3',req)
   if not ret.get('background_job_id'):raise RuntimeError('Provider returned no background_job_id')
   record.update({'job_id':ret['background_job_id'],'status':ret.get('status','submitted'),'submit_usage':ret.get('usage')})
   print('SUBMITTED',key,ret['background_job_id'],ret.get('usage'),flush=True)
  except Exception as e:
   record.update({'status':'submit_failed','error':str(e)[:600]})
   print('SUBMIT_FAILED',key,str(e)[:350],flush=True)
  jobsfile.write_text(json.dumps(jobs,indent=2,ensure_ascii=False),encoding='utf8')
if a.poll:
 for t in range(a.rounds):
  pending=0
  for stage,action in tasklist:
   key='%d_%s'%(stage,action)
   job=jobs.get(key)
   if job is None:continue
   if job.get('status') in ('completed','failed','submit_failed'):continue
   pending+=1
   jid=job.get('job_id')
   if not jid:continue
   try:res=call('/background-jobs/'+jid)
   except Exception as e:print('POLL_ERR',key,str(e)[:120],flush=True);continue
   status=res.get('status');last=res.get('last_response') or {}
   print('POLL',t,key,status,last.get('progress'),'usage',res.get('usage'),flush=True)
   if status=='failed':
    job.update({'status':'failed','error':str({k:v for k,v in last.items() if k not in ('images','image','frames')})[:650],'usage':res.get('usage')});continue
   if status!='completed':continue
   frames=[]
   for field in ('images','frames','output_images'):
    for item in last.get(field,[]) or []:
     pic=unpack(item)
     if pic is not None:frames.append(pic)
   dim=job['cell'][0]
   if len(frames)!=job['expected_frames'] or any(x.size!=(dim,dim) for x in frames):
    job.update({'status':'qa_failed','error':'frame count/size mismatch','count':len(frames),'sizes':[x.size for x in frames]});continue
   atlas=Image.new('RGBA',(4*dim,dim*((len(frames)+3)//4)))
   border=[];unique=[];nontransparent=[]
   for i,pic in enumerate(frames):
    pic.save(root/(f'BAT_STAGE{stage}_{action.upper()}_F{i:02d}.png'))
    atlas.alpha_composite(pic,((i%4)*dim,(i//4)*dim))
    alpha=pic.getchannel('A')
    edge=sum(alpha.getpixel((k,p))>0 for k in range(dim) for p in (0,dim-1)) + sum(alpha.getpixel((k,p))>0 for p in range(1,dim-1) for k in (0,dim-1))
    border.append(edge);unique.append(sha(pic.tobytes()));nontransparent.append(sum(x>0 for x in alpha.getdata()))
   name=f'BAT_STAGE{stage}_{action.upper()}_{len(frames)}F_{dim}px.png'
   output=root/name;atlas.save(output)
   job.update({'status':'completed','atlas_name':name,'sheet_sha256':sha(output.read_bytes()),
    'generation_id':last.get('generation_id'),'usage':res.get('usage'),
    'border_counts':border,'unique_frames':len(set(unique)),'opaque_area':nontransparent,
    'no_clipping':all(x==0 for x in border),
    'technical_qa':('PASS' if all(x==0 for x in border) and len(set(unique))>=min(3,len(frames)) else 'HOLD')})
   print('COMPLETE',key,name,'QA',job['technical_qa'],'BORDERS',border,'CHANGED',len(set(unique)),'USAGE',res.get('usage'),flush=True)
  jobsfile.write_text(json.dumps(jobs,indent=2,ensure_ascii=False),encoding='utf8')
  if pending==0 or all(jobs.get('%d_%s'%(st,ac),{}).get('status') in ('completed','failed','qa_failed','submit_failed') for st,ac in tasklist):break
  time.sleep(9)
 print('SUMMARY',json.dumps({k:{j:v for j,v in d.items() if j in ('job_id','generation_id','status','atlas_name','technical_qa','no_clipping','unique_frames','usage','error')} for k,d in jobs.items()},ensure_ascii=False),flush=True)
