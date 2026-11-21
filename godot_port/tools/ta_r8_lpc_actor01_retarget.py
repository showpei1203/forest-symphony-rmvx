#!/usr/bin/env python3
"""FS T-A R8 whole-action LPC pose-driven ACTOR01 candidate.

Authoritative pose reference: actual 2026-10-24 LPC Military zip, 4-dir slash,
NOT a true 45-degree LPC source. Exact A52 approved art is recolored by NONE.
Outputs separately layered 256x192 12-frame atlas for Godot 4.7.2.

This script creates a PROCEDURAL concept/ART HOLD. It is not PixelLab V3
nor independent production-quality hand-painted animation. Do not report as ART PASS.
"""
from pathlib import Path
from math import atan2,pi,cos,sin,ceil
from collections import Counter
import hashlib,io,json,zipfile,argparse,os
import numpy as np
from PIL import Image, ImageDraw
import cv2

ROOT=Path(os.environ.get('TA_R8_INPUT_ROOT','/mnt/data'))
OUT=Path(os.environ.get('TA_R8_OUTPUT_DIR',str(ROOT/'TA_R8_LPC')))
OUT.mkdir(parents=True, exist_ok=True)
SOURCE=ROOT/'TSG_P1C_LIBRESPRITE_LPC_11L_24F_EDITOR_20261024.zip'
SOURCE18=ROOT/'TSG_P1_LPC_MILITARY_18ACTION_3PRESET_RECIPE_V1_20261024.zip'
BODYP=ROOT/'actor01_a52_body_12frames.png'
WEAPONP=ROOT/'actor01_a52_weapon_12frames.png'
FXP=ROOT/'actor01_a52_fx_12frames.png'
IDLEP=ROOT/'actor01_a62_approved_idle_source_64.png'
KNOWN={
 str(SOURCE): '5fbfc15c36e122d7bd38dcaafe2ca03f53e83330bd72338c1d6be18a2f3de582',
 str(SOURCE18): 'e6d57dbb38e86a80001edd676754b4b432d710fd481841d531c181a97f9de0c7',
 str(BODYP): 'a10ea14eddd3173c48a87a31227a6a017ba8092713f6d56f95cc5d82a46fd12f',
 str(WEAPONP): '6d274e0b1c410d1427059abe5cd4e72ae1a75a0bd43a28fc7664afe68c4a560b',
 str(FXP): '46f02a3c06958a380e8333e86929a69cea7cfd6c7eec55fe616de0b6d9bec73c',
 str(IDLEP): '70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e',
}

def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def assert_sources():
 for p,h in KNOWN.items():
  got=sha(Path(p))
  if got!=h: raise RuntimeError('SOURCE SHA MISMATCH '+p+': '+got)

def get_frame(img,i): return img.crop((i%4*64,i//4*64,i%4*64+64,i//4*64+64))
def get_raw_src(z,term):
 q=[n for n in z.namelist() if n.endswith(term)]
 if len(q)!=1: raise RuntimeError('ambiguous LPC source '+term)
 return Image.open(io.BytesIO(z.read(q[0]))).convert('RGBA')

def lpc_anchors(img,dirrow=3):
 array=np.asarray(img)
 out=[]
 for i in range(6):
  f=array[dirrow*64:dirrow*64+64,i*64:i*64+64]
  yy,xx=np.where(f[:,:,3]>0)
  yy2,xx2=np.where((f[:,:,3]>0)&(np.indices((64,64))[0]<38))
  lo=xx[yy>=38]
  out.append({'lpc_frame':i,'rightmost_upper_x':int(max(xx2)),
              'rightmost_upper_y':int(yy2[xx2.argmax()]),
              'feet_span_px':int(lo.max()-lo.min()),'silhouette_foot_y':int(max(yy))})
 return out

# R8 12-pose storyboard sourced from verified LPC right/down slash morphology;
# manually author 45deg/high guard bridge (LPC does NOT have a 45deg overhead frame).
POSES=[
 {'stage':'neutral','lpc':0,'base':0,'head':(0,0),'chest':0,'hand':None,'elbow':None,'foot':'neutral','expression':'neutral'},
 {'stage':'set_step','lpc':0,'base':3,'head':(-1,0),'chest':-2,'hand':(44,39),'elbow':(43,37),'foot':'prepare','expression':'focus'},
 {'stage':'coil','lpc':1,'base':3,'head':(-2,1),'chest':-3,'hand':(46,32),'elbow':(44,34),'foot':'prepare','expression':'focus'},
 {'stage':'raise_guard','lpc':2,'base':4,'head':(-3,1),'chest':-4,'hand':(46,24),'elbow':(45,30),'foot':'windup','expression':'clench'},
 {'stage':'high_guard','lpc':3,'base':4,'head':(-4,2),'chest':-5,'hand':(48,21),'elbow':(47,27),'foot':'windup','expression':'clench'},
 {'stage':'hip_drive','lpc':3,'base':5,'head':(-1,1),'chest':0,'hand':(51,28),'elbow':(46,31),'foot':'step','expression':'exert'},
 {'stage':'accelerate','lpc':4,'base':6,'head':(2,1),'chest':3,'hand':(53,34),'elbow':(49,36),'foot':'lunge','expression':'exert'},
 {'stage':'contact','lpc':4,'base':7,'head':(4,2),'chest':4,'hand':(54,43),'elbow':(50,39),'foot':'lunge','expression':'shout'},
 {'stage':'follow_through','lpc':5,'base':8,'head':(3,2),'chest':3,'hand':(48,46),'elbow':(46,43),'foot':'lunge','expression':'shout'},
 {'stage':'recovery','lpc':5,'base':9,'head':(1,0),'chest':1,'hand':(44,44),'elbow':(45,40),'foot':'recover','expression':'recover'},
 {'stage':'settle','lpc':1,'base':10,'head':(0,0),'chest':0,'hand':(43,44),'elbow':(43,39),'foot':'settle','expression':'recover'},
 {'stage':'neutral','lpc':0,'base':11,'head':(0,0),'chest':0,'hand':None,'elbow':None,'foot':'neutral','expression':'neutral'}
]
# Blade tips reauthored by following the LPC full swing arc rather than the R7 wrist rotation.
TIPS=[None,(47,56),(41,15),(35,4),(36,3),(60,12),(62,22),(62,49),(38,58),(43,59),(45,59),None]

SLEEVE=(17,65,61,255); SLEEVE_LIT=(25,90,82,255); SLEEVE_DARK=(11,32,30,255)
GOLD=(170,141,60,255); BOOT=(82,72,61,255); INK=(6,8,11,255)
SKIN=(216,173,126,255)

def animated_body(original,idx,pose,hand,end):
 # Pull approved Actor01 original material, select original dynamic-leg stance.
 src=get_frame(original,pose['base'])
 if idx in (0,11):return get_frame(original,0)  # exact approved A52 neutral
 srcarr=np.asarray(src).copy()
 arr=np.zeros_like(srcarr)
 head_dx,head_dy=pose['head']
 shoulder=pose['chest']
 for sy in range(64):
  for sx in range(64):
   a=srcarr[sy,sx]
   if a[3]==0:continue
   if sy<=32:
    # shift whole head incl real white hair and facial identity as a rigid part
    tx=sx+head_dx; ty=sy+head_dy
   elif sy<49:
    t=(49-sy)/16.
    tx=sx+int(round(shoulder*t));ty=sy+int(round(head_dy*t))
   else:
    tx=sx;ty=sy
   if 0<=tx<64 and 0<=ty<64:
    arr[ty,tx]=a
 frame=Image.fromarray(arr,'RGBA')
 # Blank the obsolete forearm from inherited A52; restore from SOURCE-AUTHORED arm geometry below.
 p=np.asarray(frame).copy()
 # A52 lower arm occupies right edge; keep underlying torso (x <= 40) intact.
 p[35:49,43:62,:]=0
 frame=Image.fromarray(p,'RGBA')
 d=ImageDraw.Draw(frame)
 shoulder_xy=(40+int(round(shoulder*.60)),36+int(round(head_dy*.3)))
 ex,ey=pose['elbow'];hx,hy=hand
 # Rig skeleton-driven entire arm: shoulder -> bent elbow -> glove follows LPC temporal hand extension.
 for a,b in [(shoulder_xy,(ex,ey)),((ex,ey),(hx,hy))]:
  d.line((a,b),fill=INK,width=7,joint='curve')
  d.line((a,b),fill=SLEEVE_DARK,width=5,joint='curve')
  d.line((a,b),fill=SLEEVE,width=3,joint='curve')
 # shoulder / upper sleeve original palette, hide mechanical seam
 sx,sy=shoulder_xy
 d.ellipse((sx-3,sy-3,sx+3,sy+3),fill=INK)
 d.ellipse((sx-2,sy-2,sx+2,sy+2),fill=GOLD)
 d.ellipse((sx-1,sy-1,sx+1,sy+1),fill=SLEEVE)
 d.rectangle((ex-1,ey-1,ex+1,ey+1),fill=SLEEVE_LIT)
 # original sword hilt enters right-hand glove; dark wrist outline
 d.rectangle((hx-2,hy-2,hx+1,hy+1),fill=INK)
 d.rectangle((hx-1,hy-2,hx,hy),fill=SLEEVE_LIT)
 # pixels of expressive face, never recolor white hair
 expression=pose['expression']
 dx,dy=pose['head']
 if expression in ('focus','clench','exert','shout'):
  # original eyebrow tilts, shallow 1px forehead line
  d.point((32+dx,27+dy),fill=INK)
  d.point((33+dx,27+dy),fill=INK)
 if expression in ('clench','exert'):
  d.line((34+dx,33+dy,36+dx,33+dy),fill=INK,width=1)
 if expression=='shout':
  d.rectangle((34+dx,32+dy,35+dx,33+dy),fill=INK)
  d.point((35+dx,34+dy),fill=(164,72,66,255))
 if expression=='recover':
  d.point((35+dx,33+dy),fill=(95,65,56,255))
 return frame

# A52 artist-original sword source: F1 gold hilt and steel blade, no LPC sword pixels reused.
def reorient_sword(src_sword,origin,target,tip):
 a=np.asarray(src_sword)
 org=np.array([41.,41.])
 base=np.array([1.,-17.])
 dest=np.array([tip[0]-target[0],tip[1]-target[1]],float)
 # 1-to-1 rotation + small scale preserving artist's material and shape
 bl=np.linalg.norm(base);dl=np.linalg.norm(dest)
 if dl==0:raise ValueError('sword tip must move')
 b=base/bl; v=dest/dl; perp_b=np.array([-b[1],b[0]]);perp_v=np.array([-v[1],v[0]])
 mat=(np.outer(v,b)+np.outer(perp_v,perp_b)) * (dl/bl)
 inverse=np.linalg.inv(mat)
 yy,xx=np.indices((64,64)); coords=np.stack([xx-target[0],yy-target[1]],axis=0)
 rr=np.einsum('ab,bxy->axy',inverse,coords)
 mapx=(rr[0]+org[0]).astype('float32');mapy=(rr[1]+org[1]).astype('float32')
 transformed=cv2.remap(a,mapx,mapy,interpolation=cv2.INTER_NEAREST,borderMode=cv2.BORDER_CONSTANT,borderValue=(0,0,0,0))
 return Image.fromarray(transformed,'RGBA')

def main():
 assert_sources()
 with zipfile.ZipFile(SOURCE) as z:
  exact_lpc=get_raw_src(z,'/source_slots/body_slash_64.png')
  slash=get_raw_src(z,'/T17D3B_REF_SLASH_COMPOSITE.png')
  anchors=lpc_anchors(exact_lpc,3)
 with zipfile.ZipFile(SOURCE18) as z:
  backslash_dir=get_raw_src(z,'/output/steel_original/custom_backslash_128/right.png')
  if backslash_dir.size[0]<6*128: raise RuntimeError('Reference 128px backslash missing')
 body=Image.open(BODYP).convert('RGBA');w=Image.open(WEAPONP).convert('RGBA');fx=Image.open(FXP).convert('RGBA')
 assert body.size==w.size==fx.size==(256,192)
 sword=get_frame(w,1)
 bo=Image.new('RGBA',(256,192));we=Image.new('RGBA',(256,192));eff=Image.new('RGBA',(256,192))
 rows=[]
 for i,p in enumerate(POSES):
  hand=p['hand']
  if hand:
   b=animated_body(body,i,p,hand,p['elbow'])
   weapon=reorient_sword(sword,(41,41),hand,TIPS[i])
  else:
   b=get_frame(body,0);weapon=Image.new('RGBA',(64,64))
  effect=get_frame(fx,i) if i in (6,7,8) else Image.new('RGBA',(64,64))
  assert b.getbbox() and (weapon.getbbox() if hand else True)
  x=i%4*64;y=i//4*64
  bo.alpha_composite(b,(x,y));we.alpha_composite(weapon,(x,y));eff.alpha_composite(effect,(x,y))
  # alpha footprint should not be all blank or touch border; weapon might touch edge if invalid
  overlap=np.count_nonzero((np.asarray(b)[:,:,3]>0)&(np.asarray(weapon)[:,:,3]>0))
  bbox=weapon.getbbox()
  rows.append({'frame':i,'phase':p['stage'],'lpc_original_frame':p['lpc'],
               'lpc_right_64_hand_pixel_max_x':anchors[p['lpc']]['rightmost_upper_x'],
               'lpc_right_64_feet_span_px':anchors[p['lpc']]['feet_span_px'],
               '45deg_target_hand':hand,'sword_tip_target':TIPS[i],'chest_turn_px':p['chest'],
               'head_shift_xy':p['head'],'expression':p['expression'],
               'body_weapon_overlap_pixels':int(overlap),'weapon_pixel_bbox':bbox})
 bo.save(OUT/'R8_ACTOR01_ATTACK12_BODY_LPC_POSE_CANDIDATE.png')
 we.save(OUT/'R8_ACTOR01_ATTACK12_WEAPON_A52_SOURCE_RETARGET.png')
 eff.save(OUT/'R8_ACTOR01_ATTACK12_FX_A52_F7_PRESERVED.png')
 # pixel-level identity: original A52 neutral preserved; original FX frame7 exact
 assert np.array_equal(np.asarray(get_frame(bo,0)),np.asarray(get_frame(body,0)))
 assert np.array_equal(np.asarray(get_frame(bo,11)),np.asarray(get_frame(body,0)))
 assert np.array_equal(np.asarray(get_frame(eff,7)),np.asarray(get_frame(fx,7)))
 # Source-frame provenance and geometric QA; NOT ART PASS.
 report={'status':'R8_SOURCE_PROVEN_SKELETON_RETARGET_CANDIDATE__ART_HOLD',
         'source_zips':{p:v for p,v in KNOWN.items() if '.zip' in p},
         'source_actors':{p:v for p,v in KNOWN.items() if '.png' in p},
         'LPC_reference_direction':'right cardinal 6 frames (NOT a literal 45-degree sprite)',
         'LPC_reference_frames':anchors,'preserve_a52_f7_hit_second':0.630,
         'Fx_F7_sha_exact':True,'new_paid_pixellab_job':'NOT_RUN',
         'method':'source-derived LPC motion pose chart -> 45degree artistic retarget + A52 original palette/sword; polygon sleeve reconstruction',
         'art':'ART_HOLD: polygon elbows and pose perspective require user review; no artwork acceptance',
         'outputs':{
           'Body_SHA256':sha(OUT/'R8_ACTOR01_ATTACK12_BODY_LPC_POSE_CANDIDATE.png'),
           'Weapon_SHA256':sha(OUT/'R8_ACTOR01_ATTACK12_WEAPON_A52_SOURCE_RETARGET.png'),
           'FX_SHA256':sha(OUT/'R8_ACTOR01_ATTACK12_FX_A52_F7_PRESERVED.png')},
         'frames':rows}
 (OUT/'R8_SOURCE_POSE_MAP_AND_FAIL_GATES.json').write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
 # 2x 1x 4x storyboard real pixel composite
 for factor in (1,4):
  tw=64*factor*6;th=(64*factor+24)*2
  montage=Image.new('RGBA',(tw,th),(30,32,36,255));draw=ImageDraw.Draw(montage)
  for i in range(12):
   x=i%4*64;y=i//4*64
   b=bo.crop((x,y,x+64,y+64));w=we.crop((x,y,x+64,y+64));fxi=eff.crop((x,y,x+64,y+64))
   final=Image.new('RGBA',(64,64));final.alpha_composite(b);final.alpha_composite(w);final.alpha_composite(fxi)
   ox=(i%6)*64*factor;oy=(i//6)*(64*factor+24)+24
   montage.alpha_composite(final.resize((64*factor,64*factor),Image.Resampling.NEAREST),(ox,oy))
   draw.text((ox+5,oy-20),f'F{i:02d} {POSES[i]["stage"]}',fill=(240,243,240,255))
  montage.convert('RGB').save(OUT/f'R8_ACTOR01_LPC_POSE_CANDIDATE_QA_{factor}X.png')
 # source LPC 6 poses + 12 actor candidate custom gallery thumbnail
 return report
if __name__=='__main__':
 try:
  r=main()
  print('R8_SOURCE_CONTRACT_AND_CANDIDATE_PASS_12_FRAMES__ART_HOLD')
  print(json.dumps({'outputs':r['outputs'],'hand_overlap':[f['body_weapon_overlap_pixels'] for f in r['frames']]},indent=2))
 except Exception as e:
  print(type(e).__name__+': '+str(e))
  raise
