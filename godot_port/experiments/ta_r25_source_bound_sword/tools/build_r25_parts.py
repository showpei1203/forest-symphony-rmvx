#!/usr/bin/env python3
"""Extract approved ORIGINAL A52 visible pixels into honest bone-bound samples.
Never invent source garment underpaint or silently repaint torso RGB.
The seven R23 masks are visible owners, not native LPC donor layers.
"""
import hashlib,json,zipfile
from pathlib import Path
from PIL import Image

BASE=Path(__file__).resolve().parent
ROOT=BASE.parent if BASE.name=='source' else BASE
SRC=ROOT/'godot_project/assets'
OUT=SRC
OUT.mkdir(parents=True,exist_ok=True)
F0_SHA='70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e'
A52_SHA='a10ea14eddd3173c48a87a31227a6a017ba8092713f6d56f95cc5d82a46fd12f'
assert hashlib.sha256((OUT/'actor01_a62_approved_F0_64.png').read_bytes()).hexdigest()==F0_SHA
atlas=Image.open(SRC/'a52_true_source_12.png').convert('RGBA')
assert hashlib.sha256((SRC/'a52_true_source_12.png').read_bytes()).hexdigest()==A52_SHA
f0=Image.open(OUT/'actor01_a62_approved_F0_64.png').convert('RGBA')
assert f0.tobytes()==atlas.crop((0,0,64,64)).tobytes()
roles=['head_hair','torso_coat_belly','near_arm_sleeve','far_arm_sleeve','belt_waist','pants','boots']
masks={k:Image.open(SRC/f'R23_{k}_visible_12x64.png').convert('RGBA') for k in roles}
parts={}
for k in roles:
 im=masks[k].crop((0,0,64,64)); path=OUT/f'r25_orig_F00_{k}.png';im.save(path);parts[k]=str(path.name)
# Source F0 seven parts are an exact per-pixel disjoint partition (not independent source underpaint).
recomposed=Image.new('RGBA',(64,64),(0,0,0,0));seen=set()
for k in roles:
 im=masks[k].crop((0,0,64,64))
 for y in range(64):
  for x in range(64):
   px=im.getpixel((x,y))
   if px[3]:
    assert (x,y) not in seen, ('source owner overlap',k,x,y)
    seen.add((x,y));assert px==f0.getpixel((x,y))
    recomposed.putpixel((x,y),px)
assert recomposed.tobytes()==f0.tobytes()
# Cut real original A52 painted near-arm sleeves into three original-coordinate
# source chips; never draw synthetic skin/belly or fill hidden pixels.
chips={}
for source_idx in (4,5):
 yy=(source_idx//4)*64;xx=(source_idx%4)*64
 donor=masks['near_arm_sleeve'].crop((xx,yy,xx+64,yy+64))
 full=Image.new('RGBA',(64,64),(0,0,0,0))
 for name,predicate in [('upper',lambda x:x<43),('forearm',lambda x:43<=x<46),('hand',lambda x:x>=46)]:
  part=Image.new('RGBA',(64,64),(0,0,0,0));count=0
  for y in range(64):
   for x in range(64):
    col=donor.getpixel((x,y))
    if col[3] and predicate(x):part.putpixel((x,y),col);full.putpixel((x,y),col);count+=1
  filename=f'r25_A52_F{source_idx:02}_near_{name}.png';part.save(OUT/filename)
  chips[f'F{source_idx:02}_{name}']={'name':filename,'visible_pixels':count,'sha256':hashlib.sha256((OUT/filename).read_bytes()).hexdigest()}
 assert full.tobytes()==donor.tobytes(), 'donor source not exactly partitioned'
 assert sum(chips[f'F{source_idx:02}_{name}']['visible_pixels'] for name in ('upper','forearm','hand'))==sum(1 for x in list(donor.getdata()) if x[3])
q={'source':'A52 exact R23 verified 7 visible owner source masks','approved_A62_sha256':F0_SHA,'A52_body_sha256':A52_SHA,
   'source_F0_recombined_exact_rgba':True,'source_F0_opaque_pixels':len(seen),
   'donor_source_frames':[4,5],'chips':chips,
   'parts':{k:{'file':v,'sha256':hashlib.sha256((OUT/v).read_bytes()).hexdigest()} for k,v in parts.items()},
   'new_art_pixels':0,'source_native_LPC_hidden_underpaint':'MISSING','fully_skinned_LPC':'FALSE',
   'art_approved':False,'torso_RGBA_repainted':False}
(OUT/'R25_SOURCE_MANIFEST.json').write_text(json.dumps(q,indent=2)+'\n')
print(json.dumps({'status':'R25_SOURCE_PASS','source_recombined':True,'pieces':len(roles),'donor_chips':chips,'original_pixels':len(seen)}))
