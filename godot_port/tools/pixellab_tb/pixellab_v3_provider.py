#!/usr/bin/env python3
"""T-B PMD0001 source-locked PixelLab Skeleton v3 - genuine provider generation.
Transitory Windows temp staging only; private outputs transferred to Drive before deletion.
No user token is logged or saved.
"""
import os, json, base64, urllib.request, urllib.error, argparse, pathlib, hashlib, io, time
from PIL import Image

a=argparse.ArgumentParser();a.add_argument('--source',required=True);a.add_argument('--out-dir',required=True);a.add_argument('--job-id');a.add_argument('--submit',action='store_true');a.add_argument('--poll',action='store_true');args=a.parse_args()
API='https://api.pixellab.ai/v2'; TOKEN=os.getenv('PIXELLAB_API_TOKEN')
if not TOKEN: raise RuntimeError('Missing PixelLab API credential')
OUT=pathlib.Path(args.out_dir); OUT.mkdir(exist_ok=True,parents=True)
EXPECTED='e0b01e658d2659fa5c9a01c60c29a4e07cf525a0d5987aa677d09c7a0ed73c72'
assert hashlib.sha256(pathlib.Path(args.source).read_bytes()).hexdigest()==EXPECTED,'Source mismatch: unauthorized source'

def request(url, payload=None):
  req=urllib.request.Request(url,headers={'Authorization':'Bearer '+TOKEN,'Content-Type':'application/json'},data=None if payload is None else json.dumps(payload).encode())
  try:
    with urllib.request.urlopen(req,timeout=75) as r: return json.load(r)
  except urllib.error.HTTPError as e:
    error=e.read().decode('utf8','replace');print('PIXELLAB_HTTP_FAIL',e.code,error[:1600]);raise

src=[(18,45),(31,44),(43,42),(34,47),(22,35),(20,46),(19,50),(18,54),(29,47),(29,52),(29,56),(44,46),(45,50),(46,53)]
rig=[
('body',None,'mid'),('shell','body','mid'),('neck','body','mid'),('nose','neck','mid'),('jaw','neck','near'),
('rear hip','body','far'),('rear knee','rear hip','far'),('rear paw','rear knee','far'),
('near shoulder','body','near'),('near elbow','near shoulder','near'),('near paw','near elbow','near'),
('far shoulder','body','far'),('far elbow','far shoulder','far'),('far paw','far elbow','far')]
# Explicit 11 true positions: no whole-body warp; every paw and hinge is authored independently.
pose=[
((0,0), ((0,0),(0,0),(0,0)), ((19,50),(29,52),(45,50)),0),
((-1,2),((-2,1),(1,1),(0,1)), ((16,51),(27,54),(43,51)),0),
((3,-2),((-5,3),(4,-5),(6,-4)), ((16,48),(33,44),(51,43)),0),
((7,-6),((-8,2),(12,-5),(14,-4)), ((16,48),(42,40),(58,39)),0),
((9,-6),((-9,2),(14,-7),(16,-7)), ((16,47),(45,38),(62,38)),3),
((11,-5),((-10,2),(15,-5),(17,-5)), ((16,49),(49,40),(64,40)),7),
((9,-3),((-7,2),(13,-2),(13,-1)), ((18,50),(45,45),(58,44)),4),
((5,-1),((-3,1),(7,0),(7,0)), ((18,50),(39,49),(52,47)),1),
((3,1),((-1,1),(3,2),(3,1)), ((20,52),(32,52),(47,52)),0),
((1,0),((0,0),(1,0),(1,0)), ((20,50),(30,52),(46,50)),0),
((0,0),((0,0),(0,0),(0,0)), ((19,50),(29,52),(45,50)),0)]

def get_frame(p):
 root,toes,knees,gape=p
 pos={
'body':(31+root[0],44+root[1]),'shell':(23+root[0],35+root[1]),
'neck':(43+root[0],42+root[1]),'nose':(50+root[0],42+root[1]),'jaw':(44+root[0]+gape*.2,48+root[1]+gape),
'rear hip':(20+root[0],46+root[1]),'rear knee':knees[0],
'rear paw':(18+root[0]+toes[0][0],54+root[1]+toes[0][1]),
'near shoulder':(29+root[0],47+root[1]),'near elbow':knees[1],
'near paw':(29+root[0]+toes[1][0],56+root[1]+toes[1][1]),
'far shoulder':(44+root[0],46+root[1]),'far elbow':knees[2],
'far paw':(46+root[0]+toes[2][0],53+root[1]+toes[2][1]),
 }
 out=[]
 for name,parent,side in rig:
   x,y=pos[name]
   out.append({'label':name,'x':round(max(0.02,min(.98,(16+x)/96)),5),'y':round(max(0.02,min(.98,(24+y)/96)),5),
               'z_index': {'near':12,'mid':8,'far':4}[side]})
 return out

if args.submit:
 with open(args.source,'rb') as fh: b64=base64.b64encode(fh.read()).decode()
 body={
 'description':'Small stocky four-legged volcanic lava frog, identical dark basalt armor shell and orange glowing magma fissures to the supplied source, one large golden amber eye, brick red skin, amber underside, four orange clawed feet',
 'action':'physical forward jumping lunge and open jaw bite attack with four articulated legs, crouch, leap, snap bite, land, recover, no fire projectile',
 'direction':'south-east', 'view':'low top-down',
 'template_id':'dog','no_background':True,'seed':210621,
 'first_frame':{'type':'base64','format':'png','base64':b64},
 'rig':[{'name':name,'parent':parent,'side':side} for name,parent,side in rig],
 'first_frame_keypoints':get_frame(pose[0]),
 'keypoints':[get_frame(p) for p in pose],
 }
 clean=body.copy();clean['first_frame']={'type':'base64','format':'png','sha256':EXPECTED}; (OUT/'SUBMITTED_POSE_CONTRACT.json').write_text(json.dumps(clean,indent=2),encoding='utf8')
 resp=request(API+'/animate-with-skeleton-v3',body)
 jid=resp.get('background_job_id');print('JOB',jid,'STATUS',resp.get('status'),'USAGE',resp.get('usage'))
 (OUT/'JOB_ID.txt').write_text(jid or '',encoding='utf8')
 if not jid: raise RuntimeError('PixelLab did not return job ID')

if args.poll:
 if not args.job_id:raise RuntimeError('--job-id required')
 resp=request(API+'/background-jobs/'+args.job_id)
 print('JOB',args.job_id,'STATUS',resp.get('status'),'USAGE',resp.get('usage'))
 if resp.get('status')!='completed':
  print('RESPONSE_KEYS', list(resp.get('last_response') or {}));exit(2 if resp.get('status')=='failed' else 3)
 last=resp.get('last_response') or {}
 print('RESULT_KEYS',list(last));print('USAGE',json.dumps(resp.get('usage')))
 frames=[]
 def handle_image(data):
  if isinstance(data,dict):
   if 'base64' in data: data=data['base64']
   elif 'image' in data:return handle_image(data['image'])
   else:return None
  if isinstance(data,str) and data.startswith('data:'):data=data.split(',',1)[1]
  if not isinstance(data,str):return None
  try: return Image.open(io.BytesIO(base64.b64decode(data))).convert('RGBA')
  except Exception:return None
 for fld in ['images','frames','output_images']:
  for img in last.get(fld,[]) or []:
   p=handle_image(img)
   if p:frames.append(p)
 if not frames:
  for fld in ['image','spritesheet','sprite_sheet']:
   p=handle_image(last.get(fld))
   if p:frames.append(p)
 print('PARSED_FRAMES',len(frames),[(x.width,x.height) for x in frames][:15])
 if not frames: print('RAW_NON_IMAGE_FIELDS',{k:str(v)[:200] for k,v in last.items() if k!='images'});raise RuntimeError('Could not decode PixelLab response')
 sheet=Image.new('RGBA',(384,288))
 for i,im in enumerate(frames):
  im.save(OUT/f'PIXELLAB_ATTACK_F{i:02}.png')
  if i<11:sheet.alpha_composite(im.resize((96,96),Image.Resampling.NEAREST),((i%4)*96,(i//4)*96))
 sheet.save(OUT/'PMD0001_ATTACK_V6_PIXELLAB_11F_384x288.png')
 report={'job_id':args.job_id,'status':'completed','usage':resp.get('usage'),'provider_frame_count':len(frames),
         'provider_frame_sizes':[list(im.size) for im in frames], 'sheet_sha256':hashlib.sha256((OUT/'PMD0001_ATTACK_V6_PIXELLAB_11F_384x288.png').read_bytes()).hexdigest()}
 (OUT/'RESULT.json').write_text(json.dumps(report,indent=2),encoding='utf8');print('FINAL',report)
