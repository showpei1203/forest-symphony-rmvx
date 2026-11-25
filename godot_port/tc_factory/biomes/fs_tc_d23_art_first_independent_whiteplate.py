#!/usr/bin/env python3
"""D23 owner-private exploratory reauthoring of a NEW independent RGB non-ground-only plate.
The generated source has a baked checkerboard background, so this is explicitly
WHITE/GRAY-KEY FALLBACK, NEVER a claim of original true alpha. No Ground inverse extraction.
"""
import json,hashlib,argparse
from pathlib import Path
import numpy as np
from PIL import Image,ImageDraw,ImageFont
from scipy.ndimage import label,find_objects
cli=argparse.ArgumentParser(description=__doc__)
cli.add_argument('--ground',type=Path,required=True)
cli.add_argument('--source',type=Path,required=True)
cli.add_argument('--out',type=Path,required=True)
cli.add_argument('--prior-qa',type=Path,default=None,help='Optional D22 composite for non-source QA comparison only')
args=cli.parse_args()
OUT=args.out; OUT.mkdir(parents=True,exist_ok=True)
GROUND=args.ground;SRC=args.source
GROUND_LOCK='2f9ad1d596171327fbc92f797495ea12d0e231c551da8eda3437035af2d6d94e'
SOURCE_LOCK='cf13df206f06847f7b95815b25b571b16b01fa21ecdbb93794f85e3a13eb6301'

def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
assert sha(GROUND)==GROUND_LOCK, "Ground SHA lock failed"
assert sha(SRC)==SOURCE_LOCK, "Independent source RGB SHA lock failed"
rgb=np.array(Image.open(SRC).convert('RGB'),dtype=np.uint8)
assert rgb.shape == (1067,1474,3)
rgb_i=rgb.astype(np.int16)
mi=rgb_i.min(axis=2);ch=rgb_i.max(axis=2)-mi
# Source plate does NOT carry alpha; re-key only grayscale high-value checker pixels.
background=(mi>178)&(ch<15)
alpha=np.where(background,0,255).astype(np.uint8)
# avoid fake colored fringe created by white-on-object anti-alias in the model
rgba=np.dstack([rgb,alpha])
img=Image.fromarray(rgba,'RGBA');img.save(OUT/'D23_KEYED_NON_GROUND_SOURCE_CANDIDATE_1474x1067_RGBA.png')
# source connected objects, no semantic crop or occlusion selection
labels,n=label(alpha>0,structure=np.ones((3,3),dtype=np.uint8))
boxes=find_objects(labels);counts=np.bincount(labels.ravel())
parts=[]
for idx,b in enumerate(boxes,1):
 if b is not None and counts[idx]>3000:
  y,x=b; parts.append({'id':idx,'pixels':int(counts[idx]),'bbox':(x.start,y.start,x.stop,y.stop)})
parts=sorted(parts,key=lambda p:(p['bbox'][1],p['bbox'][0]))
assert len(parts)==10,len(parts)
# Fixed independent authored world positions, not a scale or random scatter
names=['main_forge','ore_crane','upper_basalt_cluster','northern_lamp','iron_bridge','lower_lamp','south_workshop','red_banner','east_lamp','lower_basalt_cluster']
# Using label centroid location sorted by top-left order to associate names robustly
key=lambda p:p['bbox'][0]
for p in parts:
 x,y,xe,ye=p['bbox']
 if y<80 and x<500: p['name']='main_forge'
 elif y<110 and 500<x<1150:p['name']='ore_crane'
 elif y<200 and x>1100:p['name']='upper_basalt_cluster'
 elif 430<y<600 and 600<x<850:p['name']='northern_lamp'
 elif 430<y<620 and x>850:p['name']='iron_bridge'
 elif 550<y<720 and x<600:p['name']='lower_lamp'
 elif y>700 and x<500:p['name']='south_workshop'
 elif y>700 and 500<x<820:p['name']='red_banner'
 elif y>700 and 850<x<1090:p['name']='east_lamp'
 elif y>700 and x>1100:p['name']='lower_basalt_cluster'
 else:raise RuntimeError('unknown source object '+str(p))
assert len(set(p['name'] for p in parts))==10
plans={
 'A':{
 'main_forge':(20,16),'ore_crane':(610,35),'upper_basalt_cluster':(1082,154),'northern_lamp':(1080,377),'iron_bridge':(765,385),'lower_lamp':(605,542),'south_workshop':(72,628),'red_banner':(520,652),'east_lamp':(956,738),'lower_basalt_cluster':(1090,754)
 },
 'B':{
 'main_forge':(20,16),'ore_crane':(615,27),'upper_basalt_cluster':(1085,138),'northern_lamp':(1100,370),'iron_bridge':(755,378),'lower_lamp':(580,555),'south_workshop':(72,630),'red_banner':(490,653),'east_lamp':(960,735),'lower_basalt_cluster':(1090,759)
 },
 'C':{
 'main_forge':(20,16),'ore_crane':(610,35),'upper_basalt_cluster':(1082,154),'northern_lamp':(430,566),'iron_bridge':(765,385),'lower_lamp':(605,542),'south_workshop':(72,628),'red_banner':(520,600),'east_lamp':(780,647),'lower_basalt_cluster':(1090,754)
 }
}
G=Image.open(GROUND).convert('RGBA');W,H=G.size;assert (W,H)==(1280,928)
results={}
for letter,poses in plans.items():
 out=Image.new('RGBA',(W,H),(0,0,0,0));occupied=np.zeros((H,W),dtype=bool);overlap=0
 manifest=[]
 for obj in parts:
  x0,y0,x1,y1=obj['bbox'];name=obj['name'];px,py=poses[name];crop=rgba[y0:y1,x0:x1].copy();hh,ww=crop.shape[:2]
  assert 0<=px<=W-ww and 0<=py<=H-hh,(name,(px,py,ww,hh))
  active=crop[:,:,3]>0
  overlap+=int((occupied[py:py+hh,px:px+ww]&active).sum())
  occupied[py:py+hh,px:px+ww] |=active
  out.alpha_composite(Image.fromarray(crop,'RGBA'),(px,py))
  manifest.append({'name':name,'source_bbox':obj['bbox'],'source_opaque_pixels':obj['pixels'],'target_origin':[px,py],'size':[ww,hh], 'pixel_scale':'1x_no_resize'})
 p=OUT/f'D23_{letter}_COMPLETEPAR_1280x928.png';c=OUT/f'D23_{letter}_GROUND_PLUS_PAR_1280x928.png'
 out.save(p); Image.alpha_composite(G,out).save(c)
 a=np.array(out.getchannel('A'))
 edges=int(((a[:5,:]>224).sum()+(a[-5:,:]>224).sum()+(a[5:-5,:5]>224).sum()+(a[5:-5,-5:]>224).sum()))
 results[letter]={'PAR_SHA':sha(p),'COMPOSITE_SHA':sha(c),'alpha_zero':int((a==0).sum()),'overlap_opaque_source_pixels':overlap,'outer_5px_visible_pixels':edges,'objects':manifest}
 print(letter,'overlap',overlap,'outer',edges,'parSha',sha(p))
# 3-up visual proof at equal image scale; text in QA only, not in real layers
board=Image.new('RGB',(1280*3,928+54),(27,27,33));d=ImageDraw.Draw(board)
for i,(name,p) in enumerate([('D22 previous',args.prior_qa if args.prior_qa and args.prior_qa.exists() else OUT/'D23_C_GROUND_PLUS_PAR_1280x928.png'),('D23 A',OUT/'D23_A_GROUND_PLUS_PAR_1280x928.png'),('D23 B',OUT/'D23_B_GROUND_PLUS_PAR_1280x928.png')]):
 board.paste(Image.open(p).convert('RGB'),(i*1280,54));d.text((i*1280+20,17),name+' / unapproved art',fill=(245,245,241))
board.save(OUT/'D22_D23_A_B_FULL_FRAME_ART_QA.png')
qa={'scene':'FS_04_MAZE','phase':'D23_ART_FIRST_CHECKERED_RGB_WHITE_PLATE_FALLBACK','ground_SHA':sha(GROUND),'source_RGB_SHA':sha(SRC),'source_origin_mode':'RGB_CHECKERBOARD_NOT_TRANSPARENT','source_dimensions':[1474,1067],'source_alpha': 'NONE_FAILED_ORIGINAL_ALPHA_CONTRACT','matte_method':'neutral_grey_high_brightness_threshold; source preserved','keyed_rgba_SHA':sha(OUT/'D23_KEYED_NON_GROUND_SOURCE_CANDIDATE_1474x1067_RGBA.png'), 'component_count':len(parts), 'positions':results,'Source_Art':'HOLD','formal_ART_PASS':'0/12','new_art_native_Godot472':'NOT_RUN'}
(OUT/'D23_CANDIDATE_SOURCE_QA.json').write_text(json.dumps(qa,indent=2,ensure_ascii=False))
