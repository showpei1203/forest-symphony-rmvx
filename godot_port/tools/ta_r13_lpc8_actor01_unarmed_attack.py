#!/usr/bin/env python3
"""Forest Symphony R13: source-locked real eight-direction LPC anatomical
UNARMED 45-degree attack RE-AUTHORING study. Not source-native attack!
Original 8-dir LPC ORA layers provide authentic torso/2 arms, poses authored
as rigid shoulder pivots and original diagonal footstep frames. Body only.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import json,hashlib,zipfile,io,math
from collections import deque
ROOT=Path(r"E:\LPC_Original_20261121")
ORI=ROOT/"LPC_8DIR_ORIGINAL_DIAGONAL/extracted/LPC_male_diagonal_walkcycle.ora"
OWNER=ROOT/"FS_ACTOR01_A62_APPROVED_REFERENCE_64.png"
OUT=ROOT/"FS_R13_ACTOR01_EIGHTDIR_UNARMED_45_ART"
OUT.mkdir(parents=True,exist_ok=True)
def sha(p):
 h=hashlib.sha256()
 with open(p,"rb") as f:
  for c in iter(lambda:f.read(1<<20),b""): h.update(c)
 return h.hexdigest()
assert sha(OWNER)=="70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e"
with zipfile.ZipFile(ORI) as z:
 assert z.testzip() is None
 layers=[Image.open(io.BytesIO(z.read("data/layer%d.png"%i))).convert("RGBA") for i in range(3)]
assert all(l.size==(576,512) for l in layers)
a62=Image.open(OWNER).convert("RGBA")
# True original LPC diagonal forward-right facing row.
DIR=7
SOURCE_FRAMES=[0,1,2,3,4,6,7,8,7,5,2,0]
# Rigid sleeve/forearm around native 45-degree shoulder pivots; NO limb scaling.
FRONT_ARM_ANGLES=[0,8,28,48,70,83,96,108,70,35,12,0]
BACK_ARM_ANGLES=[0,-7,-20,-36,-45,-30,-14,10,22,7,-5,0]
# Forward lunge and return; all pelvis/feet remain native diagonal source motion.
BODY_DX=[0,0,0,0,1,1,2,2,2,1,0,0]
BODY_DY=[0,0,0,-1,-1,-1,0,0,0,0,0,0]
HEAD_DX=[0,0,-1,-1,0,0,-1,-1,0,0,0,0]
HEAD_DY=[0,0,-1,-1,-1,0,1,1,0,0,0,0]
PHASE=["ready","anticipation","wind_up","load","drive","accelerate",
       "extend","contact","follow_through","return","recover","ready"]
STATE=["neutral","focus","focus","focus","grit","grit","exert",
       "exert","exert","recovery","recovery","neutral"]
def sample_layer(layer,frame):
 return layer.crop((frame*64,DIR*64,frame*64+64,DIR*64+64))
def tint(orig,part):
 img=Image.new("RGBA",(64,64));out=[]
 for y in range(64):
  for x in range(64):
   r,g,b,a=orig.getpixel((x,y))
   if not a:out.append((0,0,0,0));continue
   lum=(.2126*r+.7152*g+.0722*b)/255
   # LPC torso source y33..62. Authentic outline/shading retained by luma.
   if part=="torso":
    palette=(12,29,27) if y<=42 else (23,26,25) if y<=54 else (61,48,36)
   elif part=="arm":
    palette=(17,42,35) if y<=43 else (188,143,110)
   else: palette=(r,g,b)
   if part in ("torso","arm"):
    factor=.56+.70*lum
    rgb=tuple(max(0,min(255,round(c*factor))) for c in palette)
   else:rgb=palette
   out.append((*rgb,a))
 img.putdata(out)
 return img
def rotate_arm_segment(full,side,angle,frame):
 part=Image.new("RGBA",(64,64))
 raw=full.load();px=part.load()
 for y in range(64):
  for x in range(64):
   if (x>=32)==(side=="front"):
    px[x,y]=raw[x,y]
 shoulder=(39,35) if side=="front" else (25,34)
 # True rigid nearest-neighbour source-pixel shoulder pivot, no nonuniform scale.
 return part.rotate(angle,resample=Image.Resampling.NEAREST,expand=False,center=shoulder)
def translate(img,x,y):
 out=Image.new("RGBA",(64,64))
 out.alpha_composite(img,(int(x),int(y)))
 return out
def face(step):
 head=a62.crop((17,15,48,36)).copy()
 p=head.load();phase=STATE[step]
 # Act only inside actually opaque skin pixels of original approved face.
 edits={"focus":[(37,31,(74,48,35))],
  "grit":[(37,31,(54,37,30)),(38,31,(54,37,30))],
  "exert":[(37,31,(25,23,22)),(37,32,(25,23,22)),(38,32,(35,27,23))],
  "recovery":[(37,32,(110,69,54))]}.get(phase,[])
 for wx,wy,rgb in edits:
  x,y=wx-17,wy-15
  current=p[x,y]
  if current[3] and current[0]>95 and current[0]>current[2] and current[1]>55:
   p[x,y]=(*rgb,current[3])
 return head
def components(sprite):
 pix=sprite.load()
 remaining={(x,y) for y in range(64) for x in range(64) if pix[x,y][3]>0}
 groups=[]
 while remaining:
  start=remaining.pop();stack=[start];grp=[start]
  while stack:
   x,y=stack.pop()
   for dx in (-1,0,1):
    for dy in (-1,0,1):
     nbr=(x+dx,y+dy)
     if nbr in remaining:
      remaining.remove(nbr);stack.append(nbr);grp.append(nbr)
  groups.append(grp)
 return sorted(groups,key=len,reverse=True)
frames=[]
frame_details=[]
for n,src_frame in enumerate(SOURCE_FRAMES):
 torso=tint(sample_layer(layers[0],src_frame),"torso")
 arms=tint(sample_layer(layers[1],src_frame),"arm")
 # Source 8-dir authentic near/far arm pixels split by native 45 shoulder position.
 far=rotate_arm_segment(arms,"back",BACK_ARM_ANGLES[n],src_frame)
 near=rotate_arm_segment(arms,"front",FRONT_ARM_ANGLES[n],src_frame)
 # Back arm, body, front arm ensures 3/4 occlusion of shoulder and hands.
 posed=Image.new("RGBA",(64,64))
 posed.alpha_composite(far)
 posed.alpha_composite(torso)
 posed.alpha_composite(near)
 # Match approved A62 64px character vertical anchor.
 posed=translate(posed,BODY_DX[n],BODY_DY[n]-12)
 # A62 genuine white hair / eyes, same original crop in every frame.
 posed.alpha_composite(face(n),(17+HEAD_DX[n],15+HEAD_DY[n]))
 groups=components(posed)
 isolated=sum(len(g) for g in groups[1:] if len(g)<=3)
 if any(len(g)>3 for g in groups[1:]):
  raise RuntimeError(f"FRAME {n}: detached real limb {[(len(g)) for g in groups]} — ART HOLD; do not delete")
 if isolated:
  pix=posed.load()
  for group in groups[1:]:
   for x,y in group:pix[x,y]=(0,0,0,0)
 groups2=components(posed)
 if len(groups2)!=1 or len(groups2[0])<300:
  raise RuntimeError(f"FRAME {n}: multiple components after cleanup {list(map(len,groups2))}")
 frames.append(posed)
 frame_details.append({"f":n,"source_lpc_row":DIR,"source_walk_frame":src_frame,"angle_front":FRONT_ARM_ANGLES[n],
  "angle_back":BACK_ARM_ANGLES[n],"pose":PHASE[n],"face":STATE[n],"cleaned_isolated_px":isolated,
  "connected_body_px":len(groups2[0])})
assert list(frames[0].getdata())==list(frames[11].getdata()),"wrong F0/F11 seam"
assert len({f.tobytes() for f in frames})==11,"repeated attack pose hidden as new"
atlas=Image.new("RGBA",(256,192))
for n,frame in enumerate(frames):
 atlas.alpha_composite(frame,((n%4)*64,(n//4)*64))
body=OUT/"R13_ACTOR01_REAL_8DIR_BASE_UNARMED_ATTACK_BODY.png"
weapon=OUT/"R13_WEAPON_ALPHA_ZERO.png"
fx=OUT/"R13_FX_ALPHA_ZERO.png"
atlas.save(body)
blank=Image.new("RGBA",(256,192));blank.save(weapon);blank.save(fx)
sheet=Image.new("RGBA",(12*256,282),(22,25,29,255))
d=ImageDraw.Draw(sheet)
for n,frame in enumerate(frames):
 sheet.alpha_composite(frame.resize((256,256),Image.Resampling.NEAREST),(n*256,26))
 d.text((n*256+4,5),f"F{n} {PHASE[n]}",fill=(244,245,246))
sheet.save(OUT/"R13_NATIVE_8DIR_BASE_12FRAME_ATTACK_CONTACT_4X.png")
gif=[]
for frame in frames:
 bg=Image.new("RGBA",(256,256),(22,25,29,255))
 bg.alpha_composite(frame.resize((256,256),Image.Resampling.NEAREST))
 gif.append(bg.convert("RGB"))
gif[0].save(OUT/"R13_UNARMED_8DIR_BASE_12FRAME_LOOP.gif",save_all=True,append_images=gif[1:],duration=[120,90,80,70,55,55,55,90,75,95,110,150],loop=0,optimize=False)
manifest={"project":"FS T-A R13 true-eight-direction-anatomy attack REDRAW study",
"verified_original_8dir_attack_sprite":False,
"explicitly_reauthored_attack":True,"art_gate":"ART_HOLD",
"source_diagonal_ora":"LPC_male_diagonal_walkcycle.ora",
"source_ora_sha":sha(ORI),"source_character_a62_sha":sha(OWNER),
"source_original_animation":"DIAGONAL WALK (9x8), ATTACK ARM PIVOTS REAUTHORED",
"source_diagonal_direction_row":DIR,"source_original_frames":SOURCE_FRAMES,
"frame_count":12,"sheet_size":[256,192],"tile":[64,64],"no_weapon":True,
"weapon_opaque_pixels":0,"fx_opaque_pixels":0,"isolated_px_cleaned":sum(x["cleaned_isolated_px"] for x in frame_details),
"frame_details":frame_details,"sprite_sha":sha(body),"weapon_sha":sha(weapon),"fx_sha":sha(fx),
"visual_contact_local_seconds":0.63,
"remaining_gates":["source is 8dir walk, action poses intentionally reauthored, not genuine source attack",
"real 1x face/body 3/4 aesthetic review","true native Godot playback before integration",
"do not call ART PASS without human approval"]}
(OUT/"R13_UNARMED_EIGHT_DIRECTION_SOURCE_MANIFEST.json").write_text(json.dumps(manifest,indent=2,ensure_ascii=False),encoding="utf-8")
print("R13_SPRITE_GENERATED",json.dumps({"body_sha":sha(body),"frames":len(frames),"unique":len({f.tobytes() for f in frames}),
"removed":manifest["isolated_px_cleaned"],"source_row":DIR,"weapon":0,"fx":0,"status":"ART_HOLD"},ensure_ascii=True))
