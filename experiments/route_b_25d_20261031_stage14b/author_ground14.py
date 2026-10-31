#!/usr/bin/env python3
"""Deterministic texture quilting of independent old Stage12 user-private Ground.
Derived layout, NOT new AI-painted artwork. No screenshot/completed map segmentation."""
from pathlib import Path
from PIL import Image
import numpy as np, hashlib, json
ROOT=Path(__file__).resolve().parent
P=ROOT/'source';P.mkdir(exist_ok=True)
source=P/'ground_stage12_source.png'
assert source.is_file(),'Missing private original independent source Ground'
img=np.asarray(Image.open(source).convert('RGB'),dtype=np.uint8)
H,W=img.shape[:2]
assert (W,H)==(544,576)
r,g,b=np.moveaxis(img.astype('float32'),-1,0)
dirt=(r>1.14*g)&(r>1.80*b)&(r>105)&(g>70)
PATCH=64;STRIDE=44;STEP=4
candidates={'grass':[],'earth':[]}
for y in range(0,H-PATCH+1,STEP):
 for x in range(0,W-PATCH+1,STEP):
  frac=dirt[y:y+PATCH,x:x+PATCH].mean()
  if frac<.020:candidates['grass'].append((x,y))
  if frac>.950:candidates['earth'].append((x,y))
assert len(candidates['grass'])>60 and len(candidates['earth'])>20
def quilt(label,seed):
 rng=np.random.default_rng(seed)
 out=np.zeros_like(img)
 count=np.zeros((H,W),dtype=np.int16)
 for yy in range(0,H,STRIDE):
  for xx in range(0,W,STRIDE):
   sx,sy=candidates[label][int(rng.integers(0,len(candidates[label])))]
   h=min(PATCH,H-yy);w=min(PATCH,W-xx)
   patch=img[sy:sy+PATCH,sx:sx+PATCH]
   patch=patch[:h,:w].copy()
   tgt=out[yy:yy+h,xx:xx+w]
   covered=count[yy:yy+h,xx:xx+w]>0
   if covered.any():
    v=np.arange(h)[:,None];u=np.arange(w)[None,:]
    jitter=rng.integers(-3,4,size=(h,w))
    border_keep=((u+jitter)<8)|((v+jitter)<8)
    accept=~covered|(~border_keep)
    tgt[accept]=patch[accept]
   else:tgt[:]=patch
   count[yy:yy+h,xx:xx+w]+=1
 assert np.all(count>0)
 return out
grass=quilt('grass',14720)
soil=quilt('earth',14729)
y,x=np.indices((H,W),dtype=float)
center=210+49*np.sin(y/97+0.55)+19*np.sin(y/31+1.3)
width=36+6*np.cos(y/69)+4*np.sin(y/28)
noise=np.random.default_rng(14800).normal(0,1,(H,W))
main=np.abs(x-center)<width+2.4*noise
branch_y=(y>190)&(y<475)
branch_center=center+np.clip((y-190)*.57,0,133)
branch=np.abs(x-branch_center)<(12+2*np.sin(y/33)+2*noise)
road=main|(branch_y&branch)
rim=np.abs(np.abs(x-center)-width)<6
edge_mix=rim & (np.random.default_rng(14801).random((H,W))>.70)
road |= edge_mix
out=np.where(road[:,:,None],soil,grass).astype('uint8')
Image.fromarray(out,'RGB').save(P/'ground_long.png')
Image.fromarray(road.astype('uint8')*255,'L').save(P/'PATH_SEMANTIC_MASK.png')
Image.fromarray(np.full((H,W),255,np.uint8),'L').save(P/'WALKABLE_MASK.png')
info={'source_type':'DERIVED_FROM_PRIVATE_STAGE12_INDEPENDENT_GROUND_WITH_NEW_ROAD_LAYOUT','not_ai_new_art':True,
'author_script':'author_ground14.py','source_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),
'output_sha256':hashlib.sha256((P/'ground_long.png').read_bytes()).hexdigest(),'new_geometry_road':True,
'resolution':[W,H],'native_pixel_art':True,'semantic_masks_authored':True,
'path_ratio':round(100*road.mean(),2),'donor_patches':{key:len(val) for key,val in candidates.items()},
'copyright':'user-private source, no public raw PNG distribution',
'art_gate':'AWAITING_USER_ACCEPTANCE','formal_seal':'NO'}
(ROOT/'STAGE14_SOURCE_LEDGER.json').write_text(json.dumps(info,indent=2,ensure_ascii=False),encoding='utf8')
print(json.dumps(info,indent=2))