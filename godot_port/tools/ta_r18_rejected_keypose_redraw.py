#!/usr/bin/env python3
"""R18 HAND-KEYED PIXEL-ART TEST, not production-approved.
Original A62 head: unmodified pixels; new body, arms and closed fists in 64px.
Each frame uses an explicit visual pose, not rotated source walks.
"""
from pathlib import Path
from PIL import Image, ImageDraw
import json, hashlib, zipfile, math
ROOT=Path(r'E:\LPC_Original_20261121')
OUT=ROOT/'FS_R18_ACTOR01_HANDDRAWN_BOXING_45'
OUT.mkdir(exist_ok=True,parents=True)
SOURCE=ROOT/'FS_ACTOR01_A62_APPROVED_REFERENCE_64.png'
assert hashlib.sha256(SOURCE.read_bytes()).hexdigest()=='70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e'
FACE=Image.open(SOURCE).convert('RGBA').crop((17,15,48,37))
# 12 fully keyed silhouette poses: contact is F07.
# head, shoulder, hip x-shifts and near/far elbow & fist centers, rear/front foot offsets
P=[
 {'h':(0,0),'c':0,'hip':0,'farE':(26,38),'farF':(27,34),'nearE':(40,38),'nearF':(39,34),'feet':(0,0),'phase':'guard'},
 {'h':(0,0),'c':-1,'hip':-1,'farE':(25,38),'farF':(27,33),'nearE':(39,38),'nearF':(39,34),'feet':(-1,-1),'phase':'brace'},
 {'h':(-1,0),'c':-2,'hip':-1,'farE':(24,37),'farF':(27,33),'nearE':(37,39),'nearF':(35,38),'feet':(-1,-1),'phase':'load'},
 {'h':(-1,1),'c':-3,'hip':-2,'farE':(24,38),'farF':(26,33),'nearE':(36,39),'nearF':(33,39),'feet':(-1,-1),'phase':'coil'},
 {'h':(-1,1),'c':-3,'hip':-2,'farE':(25,38),'farF':(27,33),'nearE':(37,40),'nearF':(35,39),'feet':(-1,-1),'phase':'max_load'},
 {'h':(0,1),'c':-1,'hip':-1,'farE':(26,38),'farF':(28,33),'nearE':(42,38),'nearF':(44,36),'feet':(0,0),'phase':'drive'},
 {'h':(1,0),'c':1,'hip':1,'farE':(29,38),'farF':(31,34),'nearE':(44,36),'nearF':(49,33),'feet':(0,2),'phase':'accelerate'},
 {'h':(2,-1),'c':3,'hip':2,'farE':(30,38),'farF':(32,34),'nearE':(46,35),'nearF':(54,31),'feet':(-1,3),'phase':'contact'},
 {'h':(1,0),'c':1,'hip':1,'farE':(28,38),'farF':(30,34),'nearE':(43,38),'nearF':(48,33),'feet':(0,2),'phase':'recoil'},
 {'h':(0,0),'c':0,'hip':0,'farE':(26,38),'farF':(28,34),'nearE':(41,38),'nearF':(41,35),'feet':(0,1),'phase':'retract'},
 {'h':(0,0),'c':0,'hip':0,'farE':(26,37),'farF':(27,34),'nearE':(40,38),'nearF':(39,34),'feet':(0,0),'phase':'recover'},
 {'h':(0,0),'c':0,'hip':0,'farE':(26,38),'farF':(27,34),'nearE':(40,38),'nearF':(39,34),'feet':(0,0),'phase':'guard'}]
# Colors sampled/matched from approved A62 palette. No weapon and no extraneous FX.
OUTLINE=(6,8,11,255); DEEP=(14,33,33,255); FABRIC=(25,60,53,255)
LIT=(46,74,65,255); THREAD=(25,67,67,255); PANTS=(69,65,57,255)
PANT_SHADE=(46,41,38,255); BOOT=(89,70,56,255); BOOT_LIGHT=(125,95,72,255)
SKIN=(196,151,114,255); SKIN_HI=(234,201,158,255); SKIN_SHADOW=(125,95,72,255)
GLOVE=(103,72,53,255); WRAP=(74,55,43,255)
def poly(d, points,fill,outline=OUTLINE): d.polygon(points,fill=fill);d.line(points+[points[0]],fill=outline,width=1)
def edge_bar(d,a,b,fill,width=3,outline_w=5):
 d.line([a,b],fill=OUTLINE,width=outline_w,joint='curve')
 d.line([a,b],fill=fill,width=width,joint='curve')
 # Preserve a purposeful elbow joint at corner, not a long rubber strip.
def fist(d,xy,contact=False,far=False):
 x,y=xy
 # A 5x5 CLOSED FIST: dark square/round silhouette, skin knuckle plane,
 # shaded thumb and 1-pixel knuckle ridge. NEVER open palm or hand-shaped blob.
 w,h=(5,5) if contact else (5,5)
 d.rectangle((x-2,y-2,x+2,y+2),fill=OUTLINE)
 d.rectangle((x-1,y-1,x+1,y+1),fill=SKIN if not far else SKIN_SHADOW)
 d.line((x-1,y-1,x+1,y-1),fill=SKIN_HI,width=1)
 d.point((x-1,y+1),fill=SKIN_SHADOW)
 d.point((x+1,y+1),fill=WRAP)
 # finger separations visible at 4x, subtle at native
 d.point((x,y-1),fill=SKIN)
 if contact:
  d.point((x+2,y),fill=SKIN_HI)
  d.point((x-2,y+1),fill=SKIN_SHADOW)
def frame(i,p):
 im=Image.new('RGBA',(64,64));d=ImageDraw.Draw(im)
 c=p['c'];hip=p['hip']; rear=p['feet'][0];front=p['feet'][1]
 # Rear foot and shins: deliberately redraw stepping and ankle pivot per pose.
 backfoot=25+rear + (0 if i<5 or i>=10 else -1)
 frontfoot=37+front
 poly(d,[(29+hip,42),(34+hip,42),(33+rear,46),(33+rear,49),(backfoot,49),(backfoot,47),(27+rear,45)],PANT_SHADE)
 poly(d,[(34+hip,43),(39+hip,42),(41+front,45),(42+front,48),(frontfoot+6,49),(frontfoot,49),(frontfoot,46)],PANTS)
 poly(d,[(backfoot,47),(32+rear,47),(34+rear,50),(backfoot-1,50)],BOOT)
 d.line((backfoot+1,48,backfoot+4,48),fill=BOOT_LIGHT,width=1)
 poly(d,[(frontfoot,47),(frontfoot+5,47),(frontfoot+7,50),(frontfoot-1,50)],BOOT)
 d.line((frontfoot+1,48,frontfoot+4,48),fill=BOOT_LIGHT,width=1)
 # Behind body, rear side true bending sleeve + forearm; no head/hair contact trick.
 farShoulder=(27+c,34)
 edge_bar(d,farShoulder,p['farE'],FABRIC,3,5)
 d.line([p['farE'],p['farF']],fill=OUTLINE,width=4)
 d.line([p['farE'],p['farF']],fill=SKIN_SHADOW,width=2)
 fist(d,p['farF'],far=True)
 # Torso with discernible shifted upper chest, fixed visual waist connection.
 poly(d,[(27+c,32),(38+c,32),(42+c,35),(41+c,41),(37+hip,43),(29+hip,43),(25+c,40),(25+c,35)],FABRIC)
 d.line((28+c,34,30+c,37),fill=LIT,width=2)
 d.line((39+c,34,39+c,39),fill=DEEP,width=2)
 d.line((28+hip,41,39+hip,41),fill=OUTLINE,width=2)
 d.line((30+hip,40,38+hip,40),fill=BOOT,width=1)
 d.rectangle((34+hip,40,35+hip,42),fill=BOOT_LIGHT)
 # Approved A62 head pixels copied unaltered and repositioned at most 2 px.
 dx,dy=p['h'];im.alpha_composite(FACE,(17+dx,15+dy));d=ImageDraw.Draw(im)
 # Near punch layered IN FRONT of correct right hair boundary.
 nearShoulder=(39+c,35)
 edge_bar(d,nearShoulder,p['nearE'],FABRIC,4,6)
 # Green cuff anchors the distinct elbow at a visibly supported anatomical bend
 d.ellipse((p['nearE'][0]-2,p['nearE'][1]-2,p['nearE'][0]+1,p['nearE'][1]+1),fill=THREAD,outline=OUTLINE)
 # Distal forearm from elbow to wrist terminates BEHIND distinct closed fist.
 dest=(p['nearF'][0]-2 if p['nearF'][0]>p['nearE'][0]+3 else p['nearF'][0],p['nearF'][1])
 d.line([p['nearE'],dest],fill=OUTLINE,width=4)
 d.line([p['nearE'],dest],fill=SKIN_SHADOW,width=2)
 d.line([p['nearE'],dest],fill=SKIN,width=1)
 fist(d,p['nearF'],contact=i==7)
 return im
frames=[frame(i,p) for i,p in enumerate(P)]
assert frames[0].tobytes()==frames[11].tobytes()
assert len({f.tobytes() for f in frames})==11
atlas=Image.new('RGBA',(256,192))
for i,f in enumerate(frames):atlas.alpha_composite(f,((i%4)*64,(i//4)*64))
png=OUT/'R18_ACTOR01_BODY_12X64.png';atlas.save(png)
for layer in ['WEAPON','FX']:Image.new('RGBA',(256,192)).save(OUT/f'R18_ACTOR01_{layer}_ALPHA_ZERO.png')
# Contact board true 1x and 4x, same canvas 4x3 each 64px.
for scale in [1,4]:
 sz=64*scale;canvas=Image.new('RGBA',(4*sz,3*(sz+14)),(18,22,25,255));paint=ImageDraw.Draw(canvas)
 for i,f in enumerate(frames):
  x=i%4*sz;y=i//4*(sz+14)
  canvas.alpha_composite(f.resize((sz,sz),Image.Resampling.NEAREST),(x,y+14))
  paint.text((x+2,y+1),f'R18 F{i:02d}',fill=(240,243,241,255))
 canvas.convert('RGB').save(OUT/f'R18_NATIVE_KEYPOSES_{scale}X.png')
gif=[]
for f in frames:
 bg=Image.new('RGBA',(256,256),(18,22,25,255));bg.alpha_composite(f.resize((256,256),Image.Resampling.NEAREST))
 gif.append(bg.convert('RGB'))
gif[0].save(OUT/'R18_KEYPOSE_PREVIEW.gif',save_all=True,append_images=gif[1:],duration=[145,85,90,90,85,65,65,100,80,95,110,140],loop=0,optimize=True)
sha=lambda path:hashlib.sha256(path.read_bytes()).hexdigest()
manifest={'version':'R18-artist-keypose-draft','status':'ART_HOLD_UNAPPROVED','source_a62_sha256':sha(SOURCE),'body_sha256':sha(png),'frame_count':12,'unique_frames':11,'F0_matches_F11':True,'weapon_pixels':0,'fx_pixels':0,'source_8dir_walk_was_not_source_attack':True,'body_source':'independent keyed pixel redraw; ORIGINAL A62 HEAD PIXELS preserved without modifications','pose_keyframes':P,'qa_scope':'Source generation only. Native Godot must be run before any claim of engine PASS','art_scope':'Needs real visual human approval; absolutely not production-ready'}
(OUT/'R18_MANIFEST.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8')
print('R18_GENERATED',json.dumps({'atlas':str(png),'body_sha':sha(png),'source_sha':sha(SOURCE),'frames':12},ensure_ascii=False))
