#!/usr/bin/env python3
"""Forest Symphony TB02 R8: source-locked mouth-only bite, not claws/arm punch.

PixelLab v2/animate-with-skeleton-v3. This is a REAL provider job; the exact
source identity must match approved R7 stage1 bat RGBA pixels. Keep the original
R7 sprites, Idle and evolution assets unchanged. This script is used solely
for a transient execution on the authorized remote PC, then deleted.
"""
import argparse, base64, hashlib, io, json, os, pathlib, time
import urllib.request, urllib.error
from PIL import Image

ap=argparse.ArgumentParser()
ap.add_argument('--work',required=True)
ap.add_argument('--submit',action='store_true')
ap.add_argument('--poll',action='store_true')
ap.add_argument('--job-id',default='')
args=ap.parse_args()
root=pathlib.Path(args.work);root.mkdir(exist_ok=True,parents=True)
source=root/'BAT_STAGE1_PAD128.png'
assert source.exists(), 'Missing source PNG'
source_img=Image.open(source).convert('RGBA')
assert source_img.size==(128,128)
# Verify exact pixel content, independent of zlib re-encoding.
orig=Image.open(root/'BAT_STAGE1.png').convert('RGBA')
assert orig.size==(96,96)
pad=Image.new('RGBA',(128,128));pad.alpha_composite(orig,(16,16))
assert pad.tobytes()==source_img.tobytes(), 'Source has been changed'
assert hashlib.sha256((root/'BAT_STAGE1.png').read_bytes()).hexdigest()=='208e28e4f7732233c75456e9e5de671f5616fb68ef735165219a4b3aa2a959a2', 'Wrong species/source'
TOKEN=os.getenv('PIXELLAB_API_TOKEN')
if not TOKEN:raise RuntimeError('Missing authorized PixelLab token; never log it')
API='https://api.pixellab.ai/v2'
def call(path,data=None):
 h={'Authorization':'Bearer '+TOKEN,'Content-Type':'application/json'}
 req=urllib.request.Request(API+path,headers=h,data=None if data is None else json.dumps(data).encode())
 try:
  with urllib.request.urlopen(req,timeout=85) as r:return json.load(r)
 except urllib.error.HTTPError as e:raise RuntimeError('PIXELLAB '+str(e.code)+' '+e.read().decode('utf8','replace')[:500])

# Custom skeleton deliberately EXCLUDES legs, arms, talons, wrists and hands.
# Wings attach directly to shoulders; no 'claw', 'strike', 'punch', 'swipe' poses.
rig=[
 ('body',None,'mid'),('head','body','mid'),
 ('upper jaw','head','mid'),('lower jaw','head','near'),
 ('left ear','head','far'),('right ear','head','near'),
 ('left wing root','body','far'),('left wing elbow','left wing root','far'),('left wing tip','left wing elbow','far'),
 ('right wing root','body','near'),('right wing elbow','right wing root','near'),('right wing tip','right wing elbow','near'),
 ('tail','body','mid')]
# Coordinates on 128x128 fully padded original sprite; mouth is in the head.
base={'body':(64,70),'head':(64,52),'upper jaw':(64,63),'lower jaw':(64,67),
      'left ear':(55,38),'right ear':(73,38),
      'left wing root':(51,61),'left wing elbow':(39,49),'left wing tip':(19,43),
      'right wing root':(78,61),'right wing elbow':(90,49),'right wing tip':(108,43),
      'tail':(64,88)}
# Phases: anticipation -> body lunge -> jaw widely opens -> BITE @ F5 -> jaw shuts -> recover.
# Root and wings move modestly, while upper/lower jaw separation is the primary action.
poses=[ # dx,dy, head_dx,head_dy, lowerjaw_delta, upperjaw_delta, wing_tip_dy
(0,0, 0,0, 0,0, 0),
(-1,2, 0,0, 0,0, 4),
(2,-2, 1,-1, 1,-1, 1),
(4,-4, 2,-3, 5,-1, -2),
(6,-6, 3,-3, 9,-1, -3),
(8,-4, 4,-2, 10,-2, -2),
(6,-3, 3,-2, 5,0, 1),
(4,-1, 2,0, 0,0, 2),
(2,0, 1,0, 0,0, 0),
(1,0, 0,0, 0,0, 0),
(0,0, 0,0, 0,0, 0)]

def joints(p):
 dx,dy,hx,hy,lower,upper,wing=p
 ans=[]
 for name,parent,side in rig:
  x,y=base[name];x+=dx;y+=dy
  if name in ('head','upper jaw','lower jaw','left ear','right ear'):
   x+=hx;y+=hy
  if name=='upper jaw':y+=upper
  if name=='lower jaw':y+=lower
  if name=='left wing tip' or name=='right wing tip':y+=wing
  if name=='left wing elbow' or name=='right wing elbow':y+=round(wing/2)
  if not 2<=x<=126 or not 2<=y<=126:raise AssertionError('Joint outside safe region: '+name)
  ans.append({'label':name,'x':round(x/128,5),'y':round(y/128,5),'z_index':{'far':4,'mid':8,'near':12}[side]})
 return ans
if args.submit:
 request={'description':'The SAME single tiny plum-purple forest BAT with 2 green membrane wings, pointed ears, amber eyes, and small tucked legs; no other limbs',
 'action':'MOUTH BITE ONLY: head recoils, then lunges diagonally southeast and opens mouth VERY WIDE, clearly showing a dark inner mouth and two sharp WHITE FANGS. Snap jaws shut onto the target at hit frame 5, then recover into original hovering pose. Wings only FLAP SLIGHTLY to balance. Two tiny legs stay motionless tucked under torso. STRICT ANATOMY: NO ARMS, NO HANDS, NO CLAWS striking, NO PAWS, NO EXTRA APPENDAGES, NO GROWING BODY PARTS, NO PROJECTILES. Animate lips and jaw, NOT an arm swing.',
 'direction':'south-east','view':'low top-down','template_id':'mannequin','no_background':True,'seed':202611258,
 'first_frame':{'type':'base64','format':'png','base64':base64.b64encode(source.read_bytes()).decode()},
 'rig':[{'name':n,'parent':pa,'side':s} for n,pa,s in rig],
 'first_frame_keypoints':joints(poses[0]),'keypoints':[joints(p) for p in poses]}
 (root/'TB02_R8_REQUEST_MANIFEST.json').write_text(json.dumps({k:v for k,v in request.items() if k not in ('first_frame','first_frame_keypoints','keypoints')}|{'source_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'expected_frames':len(poses),'joints':len(rig),'no_punch':True,'frame_events':{'rush':2,'bite_hit':5,'recover':7}},ensure_ascii=False,indent=2),encoding='utf8')
 r=call('/animate-with-skeleton-v3',request)
 jid=r.get('background_job_id')
 if not jid:raise RuntimeError('Provider returned no job')
 (root/'TB02_R8_JOB.txt').write_text(jid,encoding='utf8')
 print('SUBMITTED_R8_BITE',jid,'STATUS',r.get('status'),'PRE_USAGE',r.get('usage'),flush=True)
if args.poll:
 jid=args.job_id or (root/'TB02_R8_JOB.txt').read_text().strip()
 for i in range(40):
  r=call('/background-jobs/'+jid);last=r.get('last_response') or {}; status=r.get('status')
  if i%3==0 or status in ('failed','completed'):print('R8_POLL',jid,status,last.get('progress'),'BILLED',r.get('usage'),flush=True)
  if status=='failed':raise RuntimeError('Provider failed: '+str({k:v for k,v in last.items() if k not in ('images','image')})[:600])
  if status=='completed':break
  time.sleep(8)
 else:raise RuntimeError('Provider not finished within this run')
 def unpack(obj):
  if isinstance(obj,dict):
   for k in ('base64','image','data'):
    if k in obj:return unpack(obj[k])
  if isinstance(obj,str):
   if obj.startswith('data:'):obj=obj.split(',',1)[1]
   try:return Image.open(io.BytesIO(base64.b64decode(obj))).convert('RGBA')
   except Exception:return None
  return None
 frames=[]
 for field in ('images','frames','output_images'):
  for item in last.get(field,[]) or []:
   im=unpack(item)
   if im is not None:frames.append(im)
 if len(frames)!=11:raise RuntimeError('Expected 11 true provider frames got '+str(len(frames)))
 atlas=Image.new('RGBA',(4*128,3*128))
 borders=[]
 for i,img in enumerate(frames):
  assert img.size==(128,128),'Unexpected frame size'
  img.save(root/f'TB02_R8_BITE_PROVIDER_F{i:02}.png')
  atlas.alpha_composite(img,((i%4)*128,(i//4)*128))
  alpha=img.getchannel('A');border=sum(alpha.getpixel((x,y))>0 for x in range(128) for y in (0,127))+sum(alpha.getpixel((x,y))>0 for y in range(1,127) for x in (0,127))
  borders.append(border)
 path=root/'TB02_R8_BITE_PROVIDER_11F_512x384.png';atlas.save(path)
 info={'job_id':jid,'generation_id':last.get('generation_id'),'status':'completed','frames':11,'cell_size':[128,128],'sprite_sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'usage':r.get('usage'),'border_counts':borders,'no_clip':all(n==0 for n in borders),'art_status':'REVIEW_PENDING', 'provider':'PixelLab animate-with-skeleton-v3'}
 (root/'TB02_R8_RESULT.json').write_text(json.dumps(info,ensure_ascii=False,indent=2),encoding='utf8')
 print('R8_DONE',json.dumps(info),flush=True)
