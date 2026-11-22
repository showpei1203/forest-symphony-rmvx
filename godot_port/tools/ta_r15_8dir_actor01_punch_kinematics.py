#!/usr/bin/env python3
"""FS T-A R15, based on authentic LPC eight-direction diagonal body.
Fix R14 head-hair-attached fist at contact by constrained two-joint punch trajectory.
Original approved Actor01 visual ID; no weapon, no FX; ART HOLD pending review.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import hashlib,zipfile,io,math,json
from collections import deque
ROOT=Path(r"E:\LPC_Original_20261121")
ORI=ROOT/"LPC_8DIR_ORIGINAL_DIAGONAL"/"extracted"/"LPC_male_diagonal_walkcycle.ora"
OWNER=ROOT/"FS_ACTOR01_A62_APPROVED_REFERENCE_64.png"
OUT=ROOT/"FS_R15_ACTOR01_EIGHTDIR_TWO_JOINT_UNARMED_45"
OUT.mkdir(exist_ok=True,parents=True)
def sha(file):
 h=hashlib.sha256()
 with open(file,"rb") as f:
  for b in iter(lambda:f.read(1<<20),b""):h.update(b)
 return h.hexdigest()
assert sha(ORI)=="63c990cbf5c882415414a67819de6350a094d130477ac3533c938306483b349c"
assert sha(OWNER)=="70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e"
with zipfile.ZipFile(ORI) as z:
 assert z.testzip() is None
 original=[Image.open(io.BytesIO(z.read("data/layer%d.png"%i))).convert("RGBA") for i in range(3)]
assert all(im.size==(576,512) for im in original)
a62=Image.open(OWNER).convert("RGBA")
DIR=7
# All torso and feet shapes are from actual eight-direction diagonal walk.
WALK_SRC=[0,1,2,3,4,6,7,8,7,5,2,0]
FRONT_UPPER=[0,-5,-12,-20,-6,10,32,50,30,14,2,0]
FRONT_ELBOW=[0,-22,-32,-60,-64,-18,12,10,25,-3,-12,0]
BACK_UPPER=[0,-5,-12,-24,-25,-18,-10,-4,4,6,0,0]
BACK_ELBOW=[0,8,15,20,22,16,10,8,4,0,0,0]
TORSO_SHIFT_X=[0,0,-1,-1,-1,0,1,2,1,0,0,0]
TORSO_SHIFT_Y=[0,0,0,0,-1,-1,-1,0,0,0,0,0]
HEAD_X=[0,0,0,0,-1,-1,0,0,0,0,0,0]
HEAD_Y=[0,0,0,-1,-1,0,0,0,0,0,0,0]
PHASE=["guard","anticipate","draw_back","coil","brace","drive","accelerate","contact","recoil","withdraw","guard","guard"]
EMOTION=["neutral","focus","focus","focus","grit","grit","shout","shout","shout","breath","breath","neutral"]
def copy_frame(sheet,f):
 return sheet.crop((f*64,DIR*64,f*64+64,DIR*64+64))
def tint(image,kind):
 out=Image.new("RGBA",image.size)
 result=[]
 for y in range(64):
  for x in range(64):
   r,g,b,a=image.getpixel((x,y))
   if not a:result.append((0,0,0,0));continue
   luminance=(.2126*r+.7152*g+.0722*b)/255
   if kind=="torso":
    # Approved Actor01 dark-green top, charcoal trousers and brown boots,
    # preserves ORIGINAL eight-direction LPC silhouette and relative shades.
    if y<=41:base=(30,71,61)
    elif y<=52:base=(39,44,42)
    else:base=(87,63,43)
    fac=.48+.68*luminance
    color=tuple(max(0,min(255,int(c*fac))) for c in base)
   else:
    # upper sleeve green, skin fist/forearm below native elbow cut
    if y<=42:
     base=(31,70,61);fac=.55+.72*luminance
     color=tuple(int(c*fac) for c in base)
    else:
     base=(198,152,120);fac=.53+.65*luminance
     color=tuple(max(0,min(255,int(c*fac))) for c in base)
   result.append((*color,a))
 out.putdata(result)
 return out
def shift(im,dx,dy):
 target=Image.new("RGBA",(64,64))
 target.alpha_composite(im,(int(dx),int(dy)))
 return target
def angle_elbow_point(shoulder,elbow,theta):
 rad=math.radians(theta)
 dx=elbow[0]-shoulder[0];dy=elbow[1]-shoulder[1]
 # Pillow rotates positive counter-clockwise in SCREEN y-down coordinates.
 return (shoulder[0]+dx*math.cos(rad)+dy*math.sin(rad),
         shoulder[1]-dx*math.sin(rad)+dy*math.cos(rad))
def limb_segment_pivot(original_arm,side,up_deg,bend_deg):
 # Extract source existing entire arms. Segment into two rigid sprite parts,
 # around real shoulder + elbow; never scale a bone.
 pix=original_arm.load()
 which_front=(side=="front")
 shoulder=(39,35) if which_front else (25,34)
 elbow=(39,43) if which_front else (25,42)
 upper=Image.new("RGBA",(64,64))
 lower=Image.new("RGBA",(64,64))
 up=upper.load();lo=lower.load()
 for y in range(64):
  for x in range(64):
   if (x>=32)!=which_front:continue
   rgba=pix[x,y]
   if rgba[3]==0:continue
   if y<=elbow[1]+1:up[x,y]=rgba
   if y>=elbow[1]-1:lo[x,y]=rgba
 rigid_upper=upper.rotate(up_deg,Image.Resampling.NEAREST,expand=False,center=shoulder)
 # Forearm has its OWN bend, built from source original lower arm pixel shape.
 rigid_forearm=lower.rotate(up_deg+bend_deg,Image.Resampling.NEAREST,expand=False,center=elbow)
 target_elbow=angle_elbow_point(shoulder,elbow,up_deg)
 off_x=round(target_elbow[0]-elbow[0])
 off_y=round(target_elbow[1]-elbow[1])
 rigid_forearm=shift(rigid_forearm,off_x,off_y)
 # Place upper first, lower second, 3 px source overlap creates actual rigid elbow.
 result=rigid_upper.copy()
 result.alpha_composite(rigid_forearm)
 return result,{"shoulder":shoulder,"elbow_original":elbow,"elbow_target":[round(c,2) for c in target_elbow],
 "elbow_offset":[off_x,off_y],"upper_deg":up_deg,"forearm_deg":up_deg+bend_deg,
 "upper_len":round(math.dist(shoulder,elbow),2),"elbow_bend":bend_deg}
def face(i):
 original=a62.crop((17,15,48,36)).copy()
 pixels=original.load()
 # Redraw only real approved ORIGINAL 3/4 face skin pixels.
 skin=(234,201,158)
 dark=(71,43,34)
 if EMOTION[i] in ["focus","grit","shout"]:
  for x,y in [(34,30),(35,30)]:
   xx,yy=x-17,y-15
   pix=pixels[xx,yy]
   if pix[3] and pix[0]>180 and pix[0]>pix[2]:
    pixels[xx,yy]=(*dark,pix[3])
 if EMOTION[i]=="grit":
  for x,y in [(34,32),(35,32)]:
   xx,yy=x-17,y-15
   pix=pixels[xx,yy]
   if pix[3] and pix[0]>180 and pix[0]>pix[2]:
    pixels[xx,yy]=(110,65,49,pix[3])
 if EMOTION[i]=="shout":
  for x,y in [(34,32),(34,33),(35,32)]:
   xx,yy=x-17,y-15
   pix=pixels[xx,yy]
   if pix[3] and pix[0]>165 and pix[0]>pix[2]:
    pixels[xx,yy]=(45,29,26,pix[3])
 if EMOTION[i]=="breath":
  for x,y in [(34,32)]:
   xx,yy=x-17,y-15
   pix=pixels[xx,yy]
   if pix[3] and pix[0]>165:
    pixels[xx,yy]=(135,85,61,pix[3])
 original_ref=a62.crop((17,15,48,36))
 diff=sum(a!=b for a,b in zip(original.getdata(),original_ref.getdata()))
 return original,diff
def groups(image):
 p=image.load()
 remaining={(x,y) for y in range(64) for x in range(64) if p[x,y][3]>0}
 components=[]
 while remaining:
  origin=remaining.pop();queue=[origin];component=[origin]
  while queue:
   x,y=queue.pop()
   for dx in [-1,0,1]:
    for dy in [-1,0,1]:
     other=(x+dx,y+dy)
     if other in remaining:
      remaining.remove(other);queue.append(other);component.append(other)
  components.append(component)
 return sorted(components,key=len,reverse=True)
def projected_wrist(side,upper,bend,dx,dy):
    """Frame 45° screen-space kinematics, not drawn debug marks.
    Original source LPC upper-arm shoulder->elbow=8px, elbow->wrist=6px.
    Keep y below the actor hair for F7 and move fist towards frame-right.
    """
    shoulder=(39,35) if side=="front" else (25,34)
    elbow=(39,43) if side=="front" else (25,42)
    projected=angle_elbow_point(shoulder,elbow,upper)
    rad=math.radians(upper+bend)
    wrist=(projected[0]+6*math.sin(rad),projected[1]+6*math.cos(rad))
    return [round(wrist[0]+dx,3),round(wrist[1]+dy-12,3)]

frames=[];details=[];cleaned=[]
fist_path=[]

for i,walk in enumerate(WALK_SRC):
 torso=tint(copy_frame(original[0],walk),"torso")
 arms=tint(copy_frame(original[1],walk),"arms")
 back,meta_back=limb_segment_pivot(arms,"back",BACK_UPPER[i],BACK_ELBOW[i])
 front,meta_front=limb_segment_pivot(arms,"front",FRONT_UPPER[i],FRONT_ELBOW[i])
 scene=Image.new("RGBA",(64,64))
 scene.alpha_composite(back)
 scene.alpha_composite(torso)
 scene.alpha_composite(front)
 scene=shift(scene,TORSO_SHIFT_X[i],TORSO_SHIFT_Y[i]-12)
 expression,change=face(i)
 scene.alpha_composite(expression,(17+HEAD_X[i],15+HEAD_Y[i]))
 connectivity=groups(scene)
 # Never erase separated arms to make component check pass.
 bad=[len(c) for c in connectivity[1:] if len(c)>3]
 if bad:raise RuntimeError(f"R15 pose F{i} detached limb component sizes {bad}")
 removed=0
 if len(connectivity)>1:
  pixel=scene.load()
  for fragment in connectivity[1:]:
   if len(fragment)>3:raise RuntimeError("major disconnected")
   removed+=len(fragment)
   for x,y in fragment:pixel[x,y]=(0,0,0,0)
 final=groups(scene)
 if len(final)!=1 or len(final[0])<250:
  raise RuntimeError(f"F{i} invalid body count {list(map(len,final))}")
 front_wrist=projected_wrist("front",FRONT_UPPER[i],FRONT_ELBOW[i],TORSO_SHIFT_X[i],TORSO_SHIFT_Y[i])
 back_wrist=projected_wrist("back",BACK_UPPER[i],BACK_ELBOW[i],TORSO_SHIFT_X[i],TORSO_SHIFT_Y[i])
 fist_path.append(front_wrist)
 frames.append(scene);cleaned.append(removed)
 details.append({"frame":i,"source_walk_frame":walk,"phase":PHASE[i],"emotion":EMOTION[i],
  "face_changed_pixels":change,"body_pixels":len(final[0]),"debris_removed":removed,
  "front":meta_front,"back":meta_back,"front_wrist_projected":front_wrist,"back_wrist_projected":back_wrist})
# R15 hard-fail motion laws: punch must travel FORWARD through drive to contact,
# below the hairline (not R14's head-level upward flying fist).
assert fist_path[5][0]+3<=fist_path[6][0] and fist_path[6][0]+2<=fist_path[7][0],("punch trajectory too short",fist_path)
assert 49.0 <= fist_path[7][0] <= 55.0 and 29.0 <= fist_path[7][1] <= 35.0,("contact hits hair or extends off anatomy",fist_path[7])
assert fist_path[8][0]<fist_path[7][0] and fist_path[9][0]<fist_path[8][0],"recoil must retract, not fly farther forward"
assert 28.0<=fist_path[7][1]<=35.0 and fist_path[7][1]>fist_path[6][1]-5.0, "fist flew into hair"
assert frames[0].tobytes()==frames[11].tobytes(),"R15 exact ready-loop seam FAIL"
assert len({f.tobytes() for f in frames})==11,"R15 redundant nonloop poses"
assert all(x["face_changed_pixels"]>0 for x in details[1:11]),"R15 no meaningful face acting"
atlas=Image.new("RGBA",(256,192))
for i,f in enumerate(frames):atlas.alpha_composite(f,((i%4)*64,(i//4)*64))
body=OUT/"R15_ACTOR01_8DIR_TWO_JOINT_UNARMED_BODY.png"
weapon=OUT/"R15_WEAPON_ALPHA_ZERO.png"
fx=OUT/"R15_FX_ALPHA_ZERO.png"
atlas.save(body)
Image.new("RGBA",(256,192)).save(weapon)
Image.new("RGBA",(256,192)).save(fx)
strip=Image.new("RGBA",(12*256,285),(22,25,29,255))
d=ImageDraw.Draw(strip)
for i,f in enumerate(frames):
 strip.alpha_composite(f.resize((256,256),Image.Resampling.NEAREST),(i*256,29))
 d.text((i*256+4,5),f"R15 F{i:02d} {PHASE[i]}",fill=(244,245,246))
strip.save(OUT/"R15_12KEY_ART_CONTACT_4X.png")
gif=[]
for f in frames:
 bg=Image.new("RGBA",(256,256),(22,25,29,255))
 bg.alpha_composite(f.resize((256,256),Image.Resampling.NEAREST))
 gif.append(bg.convert("RGB"))
gif[0].save(OUT/"R15_TWO_JOINT_UNARMED_ART_PREVIEW.gif",save_all=True,append_images=gif[1:],duration=[125,90,85,85,70,60,55,95,85,100,110,165],loop=0,optimize=False)
meta={"version":"FS-T-A-R15","status":"ART_HOLD_TWO_JOINT_SOURCE_BASED_REDRAW","source_native_attack":False,
 "source_original_8dir_anatomy":True,"source_directions":8,"source_original_ora_sha":sha(ORI),
 "source_approved_A62_sha":sha(OWNER),"eight_direction_source_row":DIR,"12x64":True,
 "frame_count":12,"unique_poses":11,"contact_visual_time":0.630,"weapon_pixels":0,"fx_pixels":0,
 "front_upper_length":8.0,"back_upper_length":8.0,
 "animation":details,"front_wrist_screen_trajectory":fist_path,"punch_direction":"diagonal forward right at jaw/upper chest level, no hairline collision","geometry_check":"F5..F7 project forward, F8..F9 recoil and F7 29<=y<=35; upper bone invariant", "sprite_sha256":sha(body),"weapon_sha256":sha(weapon),"fx_sha256":sha(fx),
 "remaining":["Original LPC is 8-dir WALK, attack is NEW procedural two-joint REDRAW, not original diagonal attack",
 "Human visual inspection of wrist/elbow and expression required","Not real FS battle integrated"]}
(OUT/"R15_SOURCE_AND_ART_QA_MANIFEST.json").write_text(json.dumps(meta,ensure_ascii=False,indent=2),encoding="utf-8")
print("R15_GENERATED",json.dumps({"body_sha":sha(body),"weapon":0,"fx":0,"pose_count":12,"unique":11,
"face_changed": [p["face_changed_pixels"] for p in details],"debris":cleaned,"wrist_path":fist_path},ensure_ascii=True))
