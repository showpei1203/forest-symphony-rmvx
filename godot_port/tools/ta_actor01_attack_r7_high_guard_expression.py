#!/usr/bin/env python3
"""Forest Symphony ACTOR01 R7: referenced high guard + facial acting, A52 source preserved.
Animation study: HEMA Roof / Vom Tag high guard; Kendo men backswing; pixel art anticipation/impact/followthrough.
Candidate only. Procedurally reposes approved pixel source; NOT a new PixelLab generation.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import numpy as np, cv2, math, json, hashlib, os
ROOT=Path(os.environ.get('TA_R7_SOURCE_DIR','/mnt/data'))
R6_DIR=Path(os.environ.get('TA_R7_R6_DIR',str(ROOT/'TA_R6_attack_fullbody')))
OUT=Path(os.environ.get('TA_R7_OUTPUT_DIR',str(ROOT/'TA_R7_HIGH_GUARD')));OUT.mkdir(parents=True,exist_ok=True)
A52={k:Image.open(ROOT/f'actor01_a52_{k}_12frames.png').convert('RGBA') for k in ['body','weapon','fx']}
R6={k:Image.open(R6_DIR/f'ACTOR01_ATTACK12_R6_{k.upper()}_ARTICULATED_CANDIDATE.png').convert('RGBA') for k in ['body','weapon','fx']}
BASE_SHA={'body':'a10ea14eddd3173c48a87a31227a6a017ba8092713f6d56f95cc5d82a46fd12f','weapon':'6d274e0b1c410d1427059abe5cd4e72ae1a75a0bd43a28fc7664afe68c4a560b','fx':'46f02a3c06958a380e8333e86929a69cea7cfd6c7eec55fe616de0b6d9bec73c'}
for k in A52:
 assert hashlib.sha256((ROOT/f'actor01_a52_{k}_12frames.png').read_bytes()).hexdigest()==BASE_SHA[k]
R6_SHA={'body':'573a1a707bee819408e3e75c24a07387dbb56e56ab172a04f9d36943c3b3e53d',
'weapon':'47d0623084372068f38f30ceedf3cefe232b8a41927f90c38604af43b54755b6',
'fx':'ab805496de7fdab088a01458e4825f28afae868ba9e4650464086a29cbdf196a'}
for k in R6:
 source=R6_DIR/f'ACTOR01_ATTACK12_R6_{k.upper()}_ARTICULATED_CANDIDATE.png'
 assert hashlib.sha256(source.read_bytes()).hexdigest()==R6_SHA[k], 'R6 source changed '+k

def frame(atlas,i):return atlas.crop(((i%4)*64,(i//4)*64,(i%4+1)*64,(i//4+1)*64))

def paste_frame(atlas,im,i):atlas.paste(im,((i%4)*64,(i//4)*64))

# Original A52 F4 bright silver blade has distinct silhouette/approved colors.
# We rotate around its wrist, then position at raised hand. The sword is still an independent layer.
ORIGINAL_SWORD_FRAME=4
REF_HILT=(44,37) # from original A52 hand position
ref_sword=frame(A52['weapon'],ORIGINAL_SWORD_FRAME)
# Reference blade apex direction is approximately (+8,-20) from source hilt.
reference_tip=(52,17)
# Explicit pixel-art animation keyposes for overhead preparation. 64px means the full sword
# must incline across/above the white hair to fit: do NOT fake larger reach by cropping.
KEY={
 1:{'hand':(45,36),'tip':(49,16),'elbow':(48,34)},
 2:{'hand':(47,27),'tip':(54,7),'elbow':(50,32)},
 3:{'hand':(48,21),'tip':(39,3),'elbow':(51,27)},
 4:{'hand':(50,19),'tip':(36,5),'elbow':(53,28)},
 5:{'hand':(49,29),'tip':(57,11),'elbow':(51,33)},
}
# Near-neighbor pixel rotation with source-origin guard + hilt. Rotation is only on authored blade pixels,
# never on face, and never used to claim human-posed model output.
def place_sword_to_tip(sword,hilt_src,tip_src,hilt_dst,tip_dst):
 old=np.array(tip_src,dtype=float)-np.array(hilt_src,dtype=float)
 new=np.array(tip_dst,dtype=float)-np.array(hilt_dst,dtype=float)
 angle=math.atan2(old[0]*new[1]-old[1]*new[0],float(np.dot(old,new)))
 c,s=math.cos(angle),math.sin(angle)
 ratio=float(np.linalg.norm(new)/np.linalg.norm(old))
 # Preserve reference length. Endpoints are guides, not an unauthorized extra length increase.
 scale=min(1.04,max(.93,ratio))
 matrix=np.array([[scale*c,-scale*s,0],[scale*s,scale*c,0]],dtype=np.float32)
 src=np.array(hilt_src,dtype=float); dst=np.array(hilt_dst,dtype=float)
 matrix[:,2]=dst-matrix[:,:2]@src
 result=cv2.warpAffine(np.asarray(sword),matrix,(64,64),flags=cv2.INTER_NEAREST,borderMode=cv2.BORDER_CONSTANT,borderValue=(0,0,0,0))
 return Image.fromarray(result,'RGBA'),round(math.degrees(angle),2),round(scale,3)

# Pixel colors sampled from A52 base palette; avoid introducing a new costume.
OUTLINE=(6,8,11,255)
SLEEVE=(25,60,53,255)
SLEEVE_SHADE=(13,45,42,255)
SLEEVE_LIGHT=(34,81,69,255)
CUFF=(190,148,22,255)
GLOVE=(125,95,72,255)
DARK_FACE=(48,38,33,255)
MOUTH=(65,37,30,255)
TEETH=(232,218,195,255)
SKIN={(234,201,158),(221,202,180),(216,173,126),(198,125,97)}


def change_expression(body,i):
 if i in (0,11):return body,'neutral'
 pixels=body.load(); skin=[]
 for y in range(23,36):
  for x in range(24,49):
   p=pixels[x,y]
   if p[3]>0 and p[:3] in SKIN:skin.append((x,y))
 if not skin:return body,'skipped_no_skin'
 minx,maxx=min(x for x,y in skin),max(x for x,y in skin)
 miny,maxy=min(y for x,y in skin),max(y for x,y in skin)
 # Local face is only ~8x9 pixels. We edit eyebrows, eye tension and mouth
 # inside the actual skin mask so white hair/costume are not repainted.
 cx=minx+4
 focus='focus' if i<4 else ('grit' if i<6 else ('shout' if i<9 else 'breath'))
 changes=[]
 def ink(x,y,color,allow_dark=False):
  if x<minx or x>maxx or y<miny or y>maxy:return
  r,g,b,a=pixels[x,y]
  if a==0:return
  if ((r,g,b) in SKIN) or (allow_dark and r<90 and g<90 and b<90):
   pixels[x,y]=color;changes.append([x,y])
 # The brow is intentionally placed just ABOVE the existing eyes.
 by=miny+2
 ink(cx-2,by,DARK_FACE);ink(cx-1,by,DARK_FACE)
 ink(cx+1,by+1,DARK_FACE)
 if focus=='focus':
  ink(cx+1,min(maxy,miny+7),MOUTH)
 if focus=='grit':
  ink(cx,min(maxy,miny+7),MOUTH)
  ink(cx+1,min(maxy,miny+7),TEETH)
  ink(cx+2,min(maxy,miny+7),MOUTH)
 if focus=='shout':
  for yy in [miny+6,miny+7]:
   for xx in [cx,cx+1]:ink(xx,yy,MOUTH,allow_dark=False)
  ink(cx+1,miny+8,(198,125,97,255))
 if focus=='breath':
  ink(cx,min(maxy,miny+7),DARK_FACE)
 return body,focus+':'+str(len(changes))

frames={'body':[],'weapon':[],'fx':[]};report=[]
for i in range(12):
 body=frame(R6['body'],i)
 weapon=frame(R6['weapon'],i)
 fx=frame(R6['fx'],i)
 hand=None;angle=None;sc=None
 if i in KEY:
  cfg=KEY[i];hand=tuple(cfg['hand']);elbow=tuple(cfg['elbow'])
  # Original A52 F1-F5 forearm is down near lower-right; remove exposed
  # original glove only outside shoulder silhouette, and repaint sleeve.
  # Do not erase torso/head: preserve identity and approved costume pattern.
  if i in (2,3,4,5):
   aa=np.array(body)
   for yy in range(35,44):
    for xx in range(46,54):
     # This mask removes only old free forearm projections in clear space.
     if xx>44+int((yy-34)*.25): aa[yy,xx]=[0,0,0,0]
   body=Image.fromarray(aa,'RGBA')
  d=ImageDraw.Draw(body)
  shoulder=(42,35) if i<4 else (43,36)
  # Anatomical elbow bends: upper arm follows shoulder, forearm goes UP.
  # Solid black silhouette and inset colored cloth; gold cuff + brown fist.
  arm_path=[shoulder,elbow,hand]
  d.line(arm_path,fill=OUTLINE,width=6,joint='curve')
  d.line(arm_path,fill=SLEEVE,width=4,joint='curve')
  d.line([shoulder,elbow],fill=SLEEVE_LIGHT,width=2)
  d.line([elbow,hand],fill=SLEEVE_SHADE,width=2)
  # Independent sword anchor is at hand; hand rendered underneath weapon guard.
  d.rectangle((hand[0]-2,hand[1]-2,hand[0]+2,hand[1]+2),fill=OUTLINE)
  d.rectangle((hand[0]-1,hand[1]-1,hand[0]+1,hand[1]+1),fill=GLOVE)
  d.line((hand[0]-2,hand[1]+2,hand[0]+2,hand[1]+2),fill=CUFF,width=1)
  weapon,angle,sc=place_sword_to_tip(ref_sword,REF_HILT,reference_tip,hand,cfg['tip'])
  # Anticipation must remain readable: do not add a sweeping FX across the white hair.
  # A52 hit FX at original F7 is unchanged; no fake trail at the held high-guard pose.
 body,expression=change_expression(body,i)
 # Avoid crop: don't accept sword/arm bleeding at image bounds.
 for label,im in [('body',body),('weapon',weapon),('fx',fx)]:
  arr=np.asarray(im);assert not np.any(arr[0,:,3]) and not np.any(arr[63,:,3]) and not np.any(arr[:,0,3]) and not np.any(arr[:,63,3]),f'{i} {label} crop'
 frames['body'].append(body);frames['weapon'].append(weapon);frames['fx'].append(fx)
 # For raised guard, overlap between body and independent sword layer must be near wrist.
 body_alpha=np.asarray(body)[:,:,3]>0;weap_alpha=np.asarray(weapon)[:,:,3]>0
 overlap=int(np.sum(body_alpha&weap_alpha))
 if i in KEY:assert overlap>0, f'F{i} sword detached'
 report.append({'frame':i,'expression':expression,'raised_hand':hand,'target_tip':KEY[i]['tip'] if i in KEY else None,
 'sword_rotation_deg':angle,'sword_scale':sc,'body_weapon_alpha_overlap_px':overlap,
 'weapon_visible_px':int(weap_alpha.sum()),'face_changed_from_R6_px':int(np.any(np.asarray(body)[24:36,25:50,:]!=np.asarray(frame(R6['body'],i))[24:36,25:50,:],axis=2).sum())})

outputs={}
for key in frames:
 a=Image.new('RGBA',(256,192))
 for i,im in enumerate(frames[key]):paste_frame(a,im,i)
 p=OUT/f'ACTOR01_ATTACK12_R7_{key.upper()}_EXPRESSIVE_HIGH_GUARD_CANDIDATE.png';a.save(p)
 outputs[key]={'filename':p.name,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}

def comp(i,which='r7'):
 c=Image.new('RGBA',(64,64));layers=[frame(R6[k],i) for k in ('body','weapon','fx')] if which=='r6' else [frames[k][i] for k in ('body','weapon','fx')]
 for fr in layers:c.alpha_composite(fr)
 return c
font=ImageFont.load_default()
for scale in (1,4):
 pad=8;tw=64*scale;th=tw+22
 canvas=Image.new('RGB',(4*(tw+pad)+10,6*th+10),(22,24,28));d=ImageDraw.Draw(canvas)
 for i in range(12):
  for variant in range(2):
   row=i//4*2+variant;col=i%4;im=comp(i,'r7' if variant else 'r6'); enlarged=im.resize((tw,tw),Image.Resampling.NEAREST)
   x=5+col*(tw+pad);y=row*th+20
   canvas.paste(enlarged,(x,y),enlarged)
   d.text((x,y-16),f'{"R7 NEW" if variant else "R6 OLD"} F{i:02}',fill='white',font=font)
 canvas.save(OUT/f'ACTOR01_ATTACK12_R6_VS_R7_EXPRESSIVE_HIGH_GUARD_{scale}X_QA.png')

# Motion comparison at native 1x data, displayed 4x, NOT Godot GPU until separate test.
seq=[]
for i in range(12):
 a=Image.new('RGB',(64*10+20,64*5+20),(22,24,28));d=ImageDraw.Draw(a)
 for idx,label in enumerate(('R6 Before','R7 High Guard')):
  sub=comp(i,'r6' if idx==0 else 'r7').resize((320,320),Image.Resampling.NEAREST)
  a.paste(sub,(idx*330,20),sub);d.text((idx*330+5,4),label,fill='white')
 seq.append(a)
seq[0].save(OUT/'ACTOR01_ATTACK12_R6_VS_R7_OFFLINE_MOTION.gif',save_all=True,append_images=seq[1:],duration=[100,100,90,85,120,75,70,120,80,100,100,140],loop=0)
manifest={'status':'ART_HOLD','model':'NO NEW PIXELLAB JOB','source_original_A52_sha256':BASE_SHA,
'previous_R6_sha256':{k:hashlib.sha256((R6_DIR/f'ACTOR01_ATTACK12_R6_{k.upper()}_ARTICULATED_CANDIDATE.png').read_bytes()).hexdigest() for k in A52},
'R7_outputs':outputs,'references':['https://www.hema101.com/post/beginner-s-guide-to-fencing-with-the-longsword','https://kendojidai.com/2021/02/01/shinzato-chikano/','https://www.slynyrd.com/blog/2018/9/8/pixelblog-9-melee-attacks','https://www.gamedeveloper.com/production/the-12-principles-of-animation-in-video-games'],
'contact_sec':0.63,'contact_frame':7,'hitstop_sec':0.07,'frame_size':[64,64],'atlas_size':[256,192],
'frames':report,'known_limits':['High guard done by pixel articulation, not newly authored Skeleton V3','Expression details at 64px need human art sign-off','64px canvas imposes reduced vertical reach versus full-size sword','R6 A52 source preserved and unchanged']}
(OUT/'ACTOR01_ATTACK12_R7_EXPRESSION_HIGH_GUARD_MANIFEST.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf8')
print('R7 written',json.dumps(outputs,indent=2))
