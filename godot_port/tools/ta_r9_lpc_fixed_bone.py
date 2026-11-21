#!/usr/bin/env python3
"""Forest Symphony R9 fixed-length IK LPC-inspired ACTOR01 ATTACK12 candidate.

NOT final art; SOURCE-LOCKED. Bans stretching/resizing any limb or blade.
Uses original A52 appearance, pixel palette and sword; LPC authentic pose graph is
reference only. Fixed lengths upper=10px, lower=10px; foot pivot remains source.
"""
from __future__ import annotations
import hashlib, math, json, io, zipfile, os, sys
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw
def label(mask, _neighborhood=None):
 labels=np.zeros(mask.shape,dtype=np.int16)
 index=0
 for y in range(mask.shape[0]):
  for x in range(mask.shape[1]):
   if not mask[y,x] or labels[y,x]: continue
   index+=1;stack=[(y,x)];labels[y,x]=index
   while stack:
    cy,cx=stack.pop()
    for ny in range(max(0,cy-1),min(mask.shape[0],cy+2)):
     for nx in range(max(0,cx-1),min(mask.shape[1],cx+2)):
      if mask[ny,nx] and not labels[ny,nx]:
       labels[ny,nx]=index;stack.append((ny,nx))
 return labels,index
ROOT=Path(os.environ.get('TA_R9_SOURCE_DIR','/mnt/data')); OUT=Path(os.environ.get('TA_R9_OUTPUT_DIR',str(ROOT/'TA_R9_FIXED_ARM')))
BODY=ROOT/'actor01_a52_body_12frames.png'; WEAPON=ROOT/'actor01_a52_weapon_12frames.png'; FX=ROOT/'actor01_a52_fx_12frames.png'
LPC=ROOT/'TSG_P1C_LIBRESPRITE_LPC_11L_24F_EDITOR_20261024.zip'
KNOWN={
 BODY:'a10ea14eddd3173c48a87a31227a6a017ba8092713f6d56f95cc5d82a46fd12f',
 WEAPON:'6d274e0b1c410d1427059abe5cd4e72ae1a75a0bd43a28fc7664afe68c4a560b',
 FX:'46f02a3c06958a380e8333e86929a69cea7cfd6c7eec55fe616de0b6d9bec73c',
 LPC:'5fbfc15c36e122d7bd38dcaafe2ca03f53e83330bd72338c1d6be18a2f3de582',
}
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def assert_sources():
 for p,v in KNOWN.items():
  if sha(p)!=v:raise RuntimeError(f'LOCKED ORIGINAL SOURCE HASH MISMATCH: {p}')
def frame(at,i):return at.crop((i%4*64,(i//4)*64,(i%4+1)*64,((i//4)+1)*64))
# Private original files are loaded inside main(), NOT imported into public CI self-test.
# In each 12f stage, 4-dir LPC supplies stance/action order, not falsely claimed
# 45deg original. Hand targets are deliberately constrained by rigid blade reach.
STAGES=[
 ('idle',0,None,None,0,(0,0),'neutral','0'),
 ('brace',3,(42,42),(46,58),-2,(-1,0),'focus','slash_right_f0'),
 ('load',3,(43,33),(39,13),-3,(-2,1),'focus','slash_right_f1'),
 ('raise',4,(44,25),(34,6),-4,(-3,1),'clench','slash_right_f2'),
 ('guard',4,(44,22),(35,5),-5,(-4,2),'clench','slash_right_f3'),
 ('hip_drive',5,(47,27),(60,14),0,(-1,1),'exert','slash_right_f3'),
 ('accelerate',6,(45,34),(60,23),3,(2,1),'exert','slash_right_f4'),
 ('contact',7,(43,40),(62,43),4,(4,2),'shout','slash_right_f4'),
 ('follow',8,(42,42),(55,57),3,(3,2),'shout','slash_right_f5'),
 ('recover',9,(42,43),(51,58),1,(1,0),'recover','slash_right_f5'),
 ('settle',10,(42,42),(50,58),0,(0,0),'recover','slash_right_f1'),
 ('idle',0,None,None,0,(0,0),'neutral','slash_right_f0'),
]
L_UP=10.0;L_LOW=10.0
INK=(6,8,11,255);SLEEVE_DARK=(11,32,30,255);SLEEVE=(17,65,61,255);SLEEVE_LIT=(25,90,82,255)
SKIN=(216,173,126,255)
def ik(shoulder,hand,wanted):
 ax,ay=shoulder; bx,by=hand; d=math.hypot(bx-ax,by-ay)
 if d>L_UP+L_LOW or d<abs(L_UP-L_LOW) or d<1e-6:
  raise ValueError(f'IK unreachable shoulder={shoulder}, hand={hand}, distance={d:.2f}')
 midx=(ax+bx)/2;midy=(ay+by)/2
 height=math.sqrt(max(0.0,L_UP*L_UP-(d/2)**2))
 perp=(-(by-ay)/d,(bx-ax)/d)
 sols=[(midx+sign*height*perp[0],midy+sign*height*perp[1]) for sign in (-1,+1)]
 return min(sols,key=lambda p:math.dist(p,wanted))
def sleeve_segment(draw,start,end,width=4):
 # Capsule drawn from two RIGID constant length bones; no stretching source tiles.
 ax,ay=start;bx,by=end
 length=math.dist(start,end)
 vx=(bx-ax)/length;vy=(by-ay)/length
 px,py=-vy,vx
 def polygon(w):
  r=w/2.
  return [(round(ax+px*r),round(ay+py*r)),(round(bx+px*r),round(by+py*r)),
          (round(bx-px*r),round(by-py*r)),(round(ax-px*r),round(ay-py*r))]
 draw.polygon(polygon(width+2),fill=INK)
 draw.polygon(polygon(width),fill=SLEEVE_DARK)
 draw.polygon(polygon(2),fill=SLEEVE)
 # restrained highlight follows actual sleeve length, not a circular badge.
 draw.line((round(ax+px),round(ay+py),round(bx+px),round(by+py)),fill=SLEEVE_LIT,width=1)
def face_act(d,xoff,yoff,expr):
 # All face pixels remain isolated in original skin area and never add logos.
 if expr=='neutral':return
 if expr in ('focus','clench'):
  d.point((32+xoff,28+yoff),fill=INK)
 if expr in ('clench','exert'):
  d.line((34+xoff,33+yoff,36+xoff,33+yoff),fill=INK,width=1)
 if expr=='shout':
  d.rectangle((34+xoff,32+yoff,35+xoff,33+yoff),fill=INK)
 if expr=='recover': d.point((35+xoff,33+yoff),fill=(95,65,56,255))
def body_pose(i,row):
 stage,base,hand,tip,chest,head,expr,lpc=row
 if hand is None: return frame(orig,0), None, None, None
 src=np.asarray(frame(orig,base)).copy()
 arr=np.zeros_like(src)
 dx,dy=head
 # R8 body core provides source approved original armor/hair, *never* warped arm.
 for y in range(64):
  for x in range(64):
   pix=src[y,x]
   if not pix[3]:continue
   if y<=32: tx,ty=x+dx,y+dy
   elif y<49:
    t=(49-y)/16.0;tx,ty=x+round(chest*t),y+round(dy*t)
   else:tx,ty=x,y
   if 0<=tx<64 and 0<=ty<64:arr[int(ty),int(tx)]=pix
 # Clean source-arm zone using row-specific arm-only right edge. DO NOT erase face.
 # A52 extra lower arm is to right of the real torso. Special outer-arm removal.
 for y in range(33,51):
  for x in range(43,64):
   arr[y,x]=0
 canvas=Image.fromarray(arr,'RGBA')
 # Rebuild an exact original source head occlusion layer. Arm draws BELOW hair/face,
 # so arm never appears pasted ON TOP of white hair and cannot create icons.
 head_rgba=np.zeros_like(src)
 head_rgba[:33]=src[:33]
 head_image=Image.new('RGBA',(64,64))
 head_image.paste(Image.fromarray(head_rgba,'RGBA'),(dx,dy))
 draw=ImageDraw.Draw(canvas)
 sx=39+round(chest*.5);sy=36+round(dy*.3)
 shoulder=(float(sx),float(sy)); wrist=(float(hand[0]),float(hand[1]))
 wanted={1:(39,46),2:(38,34),3:(38,28),4:(36,27),5:(43,28),6:(45,29),7:(45,45),8:(39,45),9:(38,46),10:(39,47)}[i]
 elbow=ik(shoulder,wrist,wanted)
 # Back arm upper segment first, forearm next, no added gold ring/symbol.
 sleeve_segment(draw,shoulder,elbow)
 sleeve_segment(draw,elbow,wrist)
 ex,ey=(round(elbow[0]),round(elbow[1])); hx,hy=hand
 # Pixel glove uses same source palette, no square cross/mark at elbow.
 draw.rectangle((hx-2,hy-2,hx+1,hy+1),fill=INK)
 draw.rectangle((hx-1,hy-2,hx,hy),fill=SLEEVE_LIT)
 # Original face/hair frontmost: layered occlusion avoids a sleeve over face.
 canvas.alpha_composite(head_image)
 draw=ImageDraw.Draw(canvas)
 face_act(draw,dx,dy,expr)
 return canvas, shoulder, elbow, wrist

def rigid_blade(hand,tip):
 # Original sword F1 original author pixel count is 82. R9 only 1:1 rotation,
 # NO length or width scaling. Every last stray marks are reported by components.
 origin=(41.,41.);src_vec=(-1.,-17.)
 dst_vec=(tip[0]-hand[0],tip[1]-hand[1])
 turn=math.degrees(math.atan2(dst_vec[1],dst_vec[0])-math.atan2(src_vec[1],src_vec[0]))
 rotated=sword_src.rotate(-turn,resample=Image.Resampling.NEAREST,expand=False,center=origin)
 result=Image.new('RGBA',(64,64))
 result.paste(rotated,(int(hand[0]-41),int(hand[1]-41)))
 p=np.array(result)
 mask=p[:,:,3]>0
 components,n=label(mask,np.ones((3,3),dtype=int)); sizes=[]
 for j in range(1,n+1): sizes.append((j,int((components==j).sum())))
 if not sizes:raise RuntimeError('weapon disappeared')
 main=max(sizes,key=lambda x:x[1])[0]
 removed=int(np.sum(mask & (components!=main)))
 p[(mask)&(components!=main)]=0
 result=Image.fromarray(p,'RGBA')
 if result.getbbox():
  x0,y0,x1,y1=result.getbbox()
  if x0<=0 or y0<=0 or x1>=64 or y1>=64:
   raise RuntimeError('weapon source crops frame at edge; use safer wrist + angle'+str((hand,tip,result.getbbox())))
 return result,{'angle_deg':round(turn,3),'source_pixels':82,'visible_pixels':int((np.asarray(result)[:,:,3]>0).sum()),'stray_removed':removed,'alpha_bbox':result.getbbox()}

def compose(frameb, framew, framefx):
 out=Image.new('RGBA',(64,64))
 for v in [frameb,framew,framefx]:out.alpha_composite(v)
 return out

def main():
 global orig,sword_src,orig_fx
 assert_sources()
 OUT.mkdir(parents=True,exist_ok=True)
 orig=Image.open(BODY).convert('RGBA')
 sword_src=frame(Image.open(WEAPON).convert('RGBA'),1)
 orig_fx=Image.open(FX).convert('RGBA')
 B=Image.new('RGBA',(256,192));W=Image.new('RGBA',(256,192));F=Image.new('RGBA',(256,192))
 report=[];render=[]
 for i,row in enumerate(STAGES):
  b,shoulder,elbow,wrist=body_pose(i,row)
  if wrist is None:w=Image.new('RGBA',(64,64));weapon_info=None
  else:w,weapon_info=rigid_blade(row[2],row[3])
  # Original A52 FX is a detached curved glyph (bbox x50..62 y26..39)
  # relative to the R9 swing. It is NOT usable as an effect for this pose.
  # Preserve source original hash, keep the FX layer empty until authored FX
  # is proved to attach to the blade. 0.63s visual marker remains in Godot.
  f=Image.new('RGBA',(64,64))
  x=i%4*64;y=i//4*64
  B.alpha_composite(b,(x,y));W.alpha_composite(w,(x,y));F.alpha_composite(f,(x,y))
  render.append(compose(b,w,f))
  report.append({'frame':i,'stage':row[0],'lpc_reference':row[-1],
   'shoulder':shoulder,'elbow':elbow,'wrist':wrist,
   'upper_length_px':round(math.dist(shoulder,elbow),4) if wrist else None,
   'forearm_length_px':round(math.dist(elbow,wrist),4) if wrist else None,
   'blade':weapon_info,'symbol_or_logo_added':False})
 paths=[OUT/'R9_ACTOR01_ATTACK12_BODY_FIXED_BONE.png',OUT/'R9_ACTOR01_ATTACK12_WEAPON_RIGID_BLADE.png',OUT/'R9_ACTOR01_ATTACK12_FX_DISABLED_DETACHED_ARC.png']
 for im,p in zip((B,W,F),paths):im.save(p)
 # negative guards on rigid upper/lower and legitimate effect only; no source layers borrowed from LPC art.
 assert all(abs(f['upper_length_px']-10.)<.01 and abs(f['forearm_length_px']-10.)<.01 for f in report if f['wrist'])
 assert all(frame(F,i).getbbox() is None for i in range(12))
 # Original A52 F7 FX source untouched and stored; deliberately not borrowed.
 assert frame(orig_fx,7).getbbox() == (50,26,63,40)
 assert all(not f['symbol_or_logo_added'] for f in report)
 assert B.size==W.size==F.size==(256,192)
 meta={'status':'R9_SOURCE_REFERENCED_FIXED_BONES__ART_HOLD',
       'model_generation':'NONE; deterministic Python retarget, source original LPC pose map',
       'provenance':{str(p):h for p,h in KNOWN.items()},
       'failure_fixed':'R8 variable length sleeve (rubber arm); gold ring generated marks; nonrigid scaled sword; detached original FX arc disabled pending authored proper effect',
       'bone_length_px':{'upper':L_UP,'forearm':L_LOW},
       'original_a52_attack_timing':{'frame':7,'contact_second':0.630,'legacy_fx_original_unchanged_but_disabled_as_detached_mark':True},
       'limitations':'IK landmark inferred from 4-cardinal LPC, not verified actual 45deg, no native PixelLab output; human ART HOLD',
       'atlas_sha256':{p.name:sha(p) for p in paths},'frames':report}
 (OUT/'R9_MANIFEST_AND_FAILURE_GATES.json').write_text(json.dumps(meta,ensure_ascii=False,indent=2)+'\n',encoding='utf8')
 # 12-shot gallery at 1x/4x + R8 comparison with NO overprints on game atlas.
 prevB=Image.open(ROOT/'TA_R8_LPC/R8_ACTOR01_ATTACK12_BODY_LPC_POSE_CANDIDATE.png').convert('RGBA')
 prevW=Image.open(ROOT/'TA_R8_LPC/R8_ACTOR01_ATTACK12_WEAPON_A52_SOURCE_RETARGET.png').convert('RGBA')
 prevF=Image.open(ROOT/'TA_R8_LPC/R8_ACTOR01_ATTACK12_FX_A52_F7_PRESERVED.png').convert('RGBA')
 for mult in (1,4):
  sw=64*mult; top=22; gap=14;cw=sw*6;ch=(sw*2+top)*2+gap
  contact=Image.new('RGB',(cw,ch),(25,28,32));d=ImageDraw.Draw(contact)
  for i in range(12):
   px=i%6*sw; py=i//6*(sw+top)
   for variant in (0,1):
    if variant==0:a=compose(frame(prevB,i),frame(prevW,i),frame(prevF,i))
    else:a=render[i]
    im=a.resize((sw,sw),Image.Resampling.NEAREST)
    y0=py+variant*(sw*2+top+gap)+top
    contact.paste(im,(px,y0),im)
    d.text((px+2,y0-19),f'F{i:02d} {"R8 bad" if variant==0 else "R9 fixed"}',fill=(245,245,245))
  dest=OUT/f'R8_VS_R9_FIXED_BONE_NO_SYMBOL_QA_{mult}X.png';contact.save(dest)
 gif_frames=[im.resize((256,256),Image.Resampling.NEAREST) for im in render]
 gif_frames[0].save(OUT/'R9_FIXED_BONE_ATTACK12_PREVIEW.gif',save_all=True,append_images=gif_frames[1:],duration=[100,90,90,90,110,90,80,120,90,90,90,110],loop=0,disposal=2)
 print('R9 REPRO SUCCESS',json.dumps({'atlas_sha':meta['atlas_sha256'],'arms':[(f['upper_length_px'],f['forearm_length_px']) for f in report if f['wrist']],'stray_pixels_removed':sum(f['blade']['stray_removed'] for f in report if f['blade'])}))
 return meta
def self_test():
 # This is public synthetic geometry only, NOT actual artist-source native QA.
 for target in [(45.,23.),(45.,43.),(40.,47.),(49.,32.)]:
  shoulder=(39.,36.);e=ik(shoulder,target,(41.,29.))
  assert abs(math.dist(shoulder,e)-L_UP)<0.001
  assert abs(math.dist(e,target)-L_LOW)<0.001
  assert all(0<=v<64 for v in e)
 try:
  ik((35.,35.),(63.,63.),(40.,30.))
  raise AssertionError('impossible arm reach was not rejected')
 except ValueError:pass
 print('R9_FIXED_10_10_BONE_IK_NEGATIVE_REACH_TEST_PASS (synthetic source-free)')
if __name__=='__main__':
 if '--self-test' in sys.argv:self_test()
 else:main()
