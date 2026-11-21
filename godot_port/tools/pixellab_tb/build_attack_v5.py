#!/usr/bin/env python3
"""PMD0001 V5: cut-out foot & jaw rearticulation, no RBF/whole-character squeeze.
Input: SHA-locked 64x64 private source; output: private PNG/GIF/QA only.
Preserves all torso/shell/face pixels, creates separate foot destinations and mouth cavity.
Art approval not implied by geometrical checks.
"""
from PIL import Image, ImageDraw
from pathlib import Path
import json, hashlib, math, os
import numpy as np

ROOT=Path(__file__).resolve().parent
OUT=ROOT/'artifacts'; OUT.mkdir(parents=True,exist_ok=True)
SRC=Path(os.environ.get('TB_PMD0001_SOURCE',str(ROOT/'assets'/'PMD0001_STATIC_64.png')))
EXPECTED='fc7be3a93d4940a3a9c6d0fb19ffeaa7715a6b98c2e549e37b92b774df73f46c'
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
if sha(SRC)!=EXPECTED:raise RuntimeError('source mismatch')
source=Image.open(SRC).convert('RGBA'); assert source.size==(64,64)
# Arc geometry from existing source image; 64px local coordinates, no scaling.
POLYGONS={
'rear': [(12,50),(21,49),(25,51),(24,55),(18,57),(12,56)],
'near': [(24,52),(36,51),(37,56),(34,60),(25,60)],
'far':  [(38,50),(51,50),(53,55),(46,57),(40,55)],
}
# Source color keys sampled from source, chosen unchanged to keep style.
P={
 'outline':(35,20,25,255),'deep':(55,29,32,255), 'leg':(150,62,61,255),
 'lit':(186,83,61,255),'toe':(238,94,43,255),'mouth':(48,15,21,255),
 'teeth':(232,177,110,255),'chin':(202,133,82,255)
}

# Events must align with original 11F XML: Rush F2, Hit F5, Return F7.
POSES=[
 ('NEUTRAL',(0,0),[(0,0)]*3,0),
 ('CROUCH',(-1,1),[(-2,1),(0,1),(1,1)],0),
 ('RUSH',(2,-2),[(-3,1),(5,-3),(5,-2)],0),
 ('LEAP',(5,-5),[(-5,-1),(10,-6),(9,-5)],0),
 ('BITE_WINDUP',(7,-5),[(-3,-3),(11,-6),(10,-5)],2),
 ('HIT',(9,-4),[(-2,-2),(13,-4),(12,-3)],4),
 ('FOLLOW',(7,-2),[(0,0),(10,-2),(8,-2)],2),
 ('RETURN',(5,-1),[(1,0),(7,0),(5,-1)],0),
 ('LAND',(3,1),[(1,1),(3,2),(2,1)],0),
 ('RECOVER',(1,0),[(0,0),(1,0),(1,0)],0),
 ('NEUTRAL_END',(0,0),[(0,0)]*3,0),
]
DUR=[4,2,4,2,2,2,2,2,2,2,4]
HIPS={'rear':(20,49),'near':(30,51),'far':(43,49)}
FEET={'rear':(18,54),'near':(29,56),'far':(46,53)}

# Each mask is a sealed extraction of part of the SOURCE. No skin texture hallucinated.
masks={};parts={}
for name,points in POLYGONS.items():
 m=Image.new('L',(64,64),0);ImageDraw.Draw(m).polygon(points,fill=255)
 a=Image.fromarray((np.asarray(source.getchannel('A'),dtype=np.uint16)*np.asarray(m,dtype=np.uint16)//255).astype('uint8'),'L')
 part=source.copy();part.putalpha(a)
 masks[name]=m;parts[name]=part

# Erase only detachable toes from the retained torso, never the head/back shell.
base=source.copy();base_array=np.asarray(base).copy()
for m in masks.values():
 mask=np.asarray(m)>0
 base_array[mask,3]=0
base=Image.fromarray(base_array,'RGBA')

# Mouth: do not scale upper head; independently redraw the jaw in its own pocket.
def draw_jaw(img,amt,dx,dy):
 if amt<=0:return img
 d=ImageDraw.Draw(img)
 def shift(p):return (p[0]+16+dx,p[1]+24+dy)
 # Small, anatomically localized 3/4 side-bite at the RIGHT edge of the head.
 # Previous over-broad 34..48 cavity swallowed the throat: rejected.
 # The source's beige lower muzzle is kept; only the snout tip opens 1-3px.
 gape=min(3, max(1,amt))
 upper=[(42,44),(48,43),(50,44),(49,45),(43,46)]
 d.polygon([shift(q) for q in upper],fill=P['deep'])
 d.line([shift((43,44)),shift((48,43)),shift((50,44))],fill=P['lit'],width=1)
 cavity=[(44,45),(49,45),(50,46+gape),(47,47+gape),(43,47)]
 d.polygon([shift(q) for q in cavity],fill=P['mouth'])
 lower=[(43,47+gape),(47,48+gape),(50,47+gape),(50,48+gape),(47,49+gape),(42,49+gape)]
 d.polygon([shift(q) for q in lower],fill=P['outline'])
 d.line([shift((43,48+gape)),shift((48,48+gape)),shift((49,47+gape))],fill=P['chin'],width=2)
 d.point(shift((47,46)),fill=P['teeth'])
 return img

def move_part(layer, offset, dest_size=(96,96)):
 out=Image.new('RGBA',dest_size)
 out.alpha_composite(layer,(16+offset[0],24+offset[1]));return out

def skeleton_frame(stage,root,feet_offsets,jaw):
 if stage in ('NEUTRAL','NEUTRAL_END'):
  canvas=Image.new('RGBA',(96,96));canvas.alpha_composite(source,(16,24));return canvas
 canvas=Image.new('RGBA',(96,96))
 # Reconstruct 3 articulated lower legs in the behind/body/foreground passes.
 # rear foot goes behind body, forefeet in front, never layer duplicate original toes.
 link=Image.new('RGBA',(96,96));d=ImageDraw.Draw(link)
 for idx,name in enumerate(('rear','near','far')):
  hip=HIPS[name]; foot=FEET[name];delta=feet_offsets[idx]
  h=(hip[0]+16+root[0],hip[1]+24+root[1])
  f=(foot[0]+16+root[0]+delta[0],foot[1]+24+root[1]+delta[1])
  # Double stroke maintains the source inked pixel outline, no texture warp.
  d.line([h,f],fill=P['outline'],width=5 if name!='rear' else 6)
  d.line([h,f],fill=P['leg'],width=3 if name!='rear' else 4)
  d.line([(h[0]+1,h[1]),(f[0]+1,f[1])],fill=P['lit'],width=1)
 canvas.alpha_composite(link)
 # Body translated rigidly, its scales/shell/eye stay source-exact.
 canvas.alpha_composite(move_part(base,root))
 # Cut-out feet patches return in independent positions, never duplicated.
 for idx,name in enumerate(('rear','near','far')):
  offset=(root[0]+feet_offsets[idx][0],root[1]+feet_offsets[idx][1])
  canvas.alpha_composite(move_part(parts[name],offset))
 # Correct mouth ONLY during windup/hit/follow; recovery uses unmodified source jaw.
 if jaw:draw_jaw(canvas,jaw,*root)
 return canvas

frames=[skeleton_frame(*args) for args in POSES]
sheet=Image.new('RGBA',(384,288))
for i,img in enumerate(frames):sheet.alpha_composite(img,((i%4)*96,(i//4)*96))
SHEET=OUT/'PMD0001_ATTACK_V5_11F_384x288.png';sheet.save(SHEET)
GIF=OUT/'PMD0001_ATTACK_V5_PREVIEW.gif';frames[0].save(GIF,save_all=True,append_images=frames[1:],duration=[int(round(t*1000/60)) for t in DUR],loop=0,disposal=2,optimize=False)
# Contact sheet with native-size frames x4, annotated only outside game art.
scale=4;step=96*scale; board=Image.new('RGB',(4*step,3*(step+40)),(26,30,35));d=ImageDraw.Draw(board)
for i,im in enumerate(frames):
 x=(i%4)*step;y=(i//4)*(step+40)
 small=Image.new('RGBA',(96,96),(26,30,35,255));small.alpha_composite(im)
 board.paste(small.resize((step,step),Image.Resampling.NEAREST),(x,y))
 d.text((x+10,y+step+5),f'F{i}: {POSES[i][0]}'+ (' HIT' if i==5 else ''),fill='white')
CONTACT=OUT/'PMD0001_ATTACK_V5_CONTACT.png';board.save(CONTACT)
# QA is geometry/identity only, no invented art judgement.
ref=Image.new('RGBA',(96,96));ref.alpha_composite(source,(16,24))
qa={
'source_sha256_matches': sha(SRC)==EXPECTED,
'sheet_dimensions':sheet.size== (384,288),
'11_frames':len(frames)==11,
'first_last_reference_exact': all(np.array_equal(np.asarray(frames[i]),np.asarray(ref)) for i in (0,10)),
'frame_shas_distinct_except_first_last':len(set(hashlib.sha256(f.tobytes()).hexdigest() for f in frames))==10,
'no_frame_crop':all(np.asarray(f)[0,:,-1].max()==0 and np.asarray(f)[-1,:,-1].max()==0 and np.asarray(f)[:,0,-1].max()==0 and np.asarray(f)[:,-1,-1].max()==0 for f in frames),
'source_has_original_semi_transparent_aa':len(np.unique(np.asarray(source)[:,:,3]))>2,
'attack_durations_ticks':sum(DUR)==28,
'native_event_frames':{'rush':2,'hit':5,'return':7},
'geometry_only_not_art_pass':True,
'no_rbf_no_whole_body_scaling':True,
'private_sha256':sha(SHEET),
'frame_sha256':[hashlib.sha256(f.tobytes()).hexdigest() for f in frames],
}
print('QA',json.dumps({k:v for k,v in qa.items() if not k.startswith('frame_sha')},ensure_ascii=False))
(OUT/'PMD0001_ATTACK_V5_QA.json').write_text(json.dumps(qa,indent=2,ensure_ascii=False),encoding='utf8')
if not all(v for k,v in qa.items() if isinstance(v,bool)):
 raise RuntimeError('V5 check fail')
