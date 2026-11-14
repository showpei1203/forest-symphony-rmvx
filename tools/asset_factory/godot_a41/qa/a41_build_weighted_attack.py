"""A41 weighted overhead-to-diagonal sword strike, palette-locked 12-frame RGBA source atlas.
Preserves A62 approved pixels and re-rigs pixel body pieces; source never modified.
This is controlled pixel manipulation on private Drive (not AI regeneration).
"""
from pathlib import Path
from PIL import Image, ImageDraw
import hashlib,json,math
ROOT=Path(__file__).resolve().parent.parent
SRC=ROOT/'assets'/'actor01_a62_approved_idle_source_64.png'
sha=hashlib.sha256(SRC.read_bytes()).hexdigest()
assert sha=='70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e',sha
orig=Image.open(SRC).convert('RGBA')
assert orig.size==(64,64)
INK=(2,3,5,255);SHADE=(6,8,11,255);DARK=(20,44,43,255)
GREEN=(25,67,67,255);GREENLIGHT=(46,74,65,255)
STEEL=(212,211,214,255);HILITE=(252,253,250,255)
GREY=(163,160,156,255);GOLD=(245,237,68,255)
LEATHER=(125,95,72,255);CYAN=(20,127,134,255)
PALETTE=set(orig.getdata())-{(0,0,0,0)}
assert all(c in PALETTE for c in [INK,SHADE,DARK,GREEN,GREENLIGHT,STEEL,HILITE,GREY,GOLD,LEATHER,CYAN])
# Pose: torso lean and crouch, left & right foot stride, weapon wrist and tip.
# At F6 (500ms) the sword passes the target-facing strike point: actor-right/down.
poses=[
 ( 0, 0,  0, 0,  0, 0, None,None,0),  # exact approved starting stance
 (-1, 1, -1, 0,  1, 0,(42,43),(44,31),0),  # weight backward
 (-2, 1, -2, 0,  1, 0,(44,40),(46,25),0),  # load to rear foot
 (-2, 0, -2,-1,  1, 0,(44,37),(48,22),0),  # high windup
 (-1,-1, -1,-1,  1, 1,(46,35),(52,21),0),  # shoulder rotation
 ( 1,-1,  1, 0, -1,-1,(48,37),(59,26),0),  # accelerate
 ( 3, 0,  3, 1, -2,-1,(50,41),(59,41),1),  # impact marker / slash effect
 ( 3, 0,  3, 1, -2,-1,(49,44),(56,52),1),  # follow through
 ( 2, 1,  2, 1, -1, 0,(47,45),(55,57),0),  # recovery
 ( 1, 1,  1, 0,  0, 0,(44,44),(49,55),0),  # settle
 ( 0, 0,  0, 0,  0, 0,(42,44),(44,53),0),  # sheath
 ( 0, 0,  0, 0,  0, 0,None,None,0), # exact original
]
assert len(poses)==12
def part_by_mask(predicate):
 out=Image.new('RGBA',(64,64))
 for y in range(64):
  for x in range(64):
   if predicate(x,y):
    c=orig.getpixel((x,y))
    if c[3]:out.putpixel((x,y),c)
 return out
# Background body layering
HEAD=part_by_mask(lambda x,y:y<35)
TORSO=part_by_mask(lambda x,y:35<=y<45 and not (x>=38 and y>=38))
LEGS_L=part_by_mask(lambda x,y:y>=43 and x<35)
LEGS_R=part_by_mask(lambda x,y:y>=43 and x>=35)
SHOULDER=part_by_mask(lambda x,y:35<=y<=42 and x>=37)
def stamp(canvas,layer,dx,dy):
 canvas.alpha_composite(layer,(dx,dy))
def sword(draw, wrist, tip, phase):
 # Sword points toward camera-right. Native-pixel nearest lines, no filters.
 wx,wy=wrist;tx,ty=tip
 # Blade begins 3px away from hand; spine/outlines first.
 vx,vy=tx-wx,ty-wy
 norm=max(0.1,math.hypot(vx,vy))
 ux,uy=vx/norm,vy/norm
 base=(round(wx+ux*3),round(wy+uy*3))
 edge=(round(tx-ux*1),round(ty-uy*1))
 draw.line([base,tip],fill=INK,width=4,joint='curve')
 draw.line([base,edge],fill=STEEL,width=2,joint='curve')
 # Bright steel ridge offset one pixel to separate it from grey hair
 nx,ny=-uy,ux
 draw.line([(round(base[0]+nx),round(base[1]+ny)),(round(edge[0]+nx),round(edge[1]+ny))],fill=HILITE,width=1)
 draw.point(tip,fill=HILITE)
 # Golden 4px crossguard at actual wrist
 guard=(round(wx+nx*3),round(wy+ny*3))
 guard2=(round(wx-nx*3),round(wy-ny*3))
 draw.line([guard,guard2],fill=INK,width=3)
 draw.line([guard,guard2],fill=GOLD,width=1)
 draw.line([(round(wx-ux*3),round(wy-uy*3)),(wx,wy)],fill=LEATHER,width=2)
 draw.point((wx,wy),fill=STEEL)
 # Add a small segmented arc at impact, all with A62 existing palette.
 if phase:
  if phase==1:
   pts=[(53,29),(56,33),(59,38),(58,43),(54,48),(51,51)]
   draw.line(pts,fill=STEEL,width=2,joint='curve')
   for x,y in pts[1:-1]: draw.point((x,y),fill=HILITE)
   draw.point((54,31),fill=CYAN)
def draw_arm(canvas, shoulder,wrist,torso_dx):
 draw=ImageDraw.Draw(canvas)
 sx,sy=shoulder
 wx,wy=wrist
 mid=(round((sx+wx)/2),round((sy+wy)/2+1))
 # Classic green sleeve / black silhouette to connect shoulder to gauntlet.
 draw.line([shoulder,mid,wrist],fill=INK,width=6,joint='curve')
 draw.line([shoulder,mid,wrist],fill=DARK,width=4,joint='curve')
 draw.line([shoulder,mid,wrist],fill=GREEN,width=2,joint='curve')
 draw.ellipse((wx-2,wy-2,wx+2,wy+2),fill=INK)
 draw.point((wx-1,wy),fill=GOLD)
 draw.point((wx,wy-1),fill=LEATHER)
def clip_opaque(p):
 return tuple(max(0,min(255,int(a))) for a in p)
frames=[]
for i,(lean,bob,lsx,lsy,rsx,rsy,wrist,tip,effect) in enumerate(poses):
 if i in (0,11):
  frames.append(orig.copy());continue
 fr=Image.new('RGBA',(64,64),(0,0,0,0))
 # To avoid dislocated legs, keep hip contact at y43 and only start stride below knee.
 # Foot groups are separately offset: opposite-foot counter-balance.
 stamp(fr,LEGS_L,lsx,lsy)
 stamp(fr,LEGS_R,rsx,rsy)
 # New pelvis link with existing native source colors, never paint on top of boots.
 dr=ImageDraw.Draw(fr)
 dr.polygon([(31+lean,41+bob),(39+lean,41+bob),(38+lean,44+bob),(32+lean,44+bob)],fill=DARK)
 dr.line([(32+lean,43+bob),(35+lean,45+bob)],fill=GREEN,width=3)
 # Body and neck/head move together as a rigid unit, retaining exact face pixels.
 stamp(fr,TORSO,lean,bob)
 stamp(fr,HEAD,lean,bob)
 # Existing left arm/cape is bound to torso, only right weapon arm reconstructed.
 sx,sy=(40+lean,38+bob)
 draw_arm(fr,(sx,sy),wrist,lean)
 draw=ImageDraw.Draw(fr)
 sword(draw,wrist,tip,effect)
 frames.append(fr)
assert len(frames)==12
assert frames[0].tobytes()==orig.tobytes() and frames[-1].tobytes()==orig.tobytes()
allowed=PALETTE|{(0,0,0,0)}
for i,fr in enumerate(frames):
 assert fr.size==(64,64)
 assert all(c in allowed for c in set(fr.getdata())),f'out of palette {i}'
 assert all(c[3] in (0,255) for c in set(fr.getdata())),'antialias found'
 # face copied from source via exact integer transform, so no AI head replacement
 if i not in (0,11):
  lean,bob=poses[i][:2]
  for y in range(17,34):
   for x in range(22,43):
    if 0<=x+lean<64 and 0<=y+bob<64:
     o=orig.getpixel((x,y))
     if o[3] and y<34 and 26<=x<=39:
      v=fr.getpixel((x+lean,y+bob))
      assert v==o,(i,x,y,o,v)
 # At least one foot pixel in native y>=45 region, keep actor grounded.
 assert any(fr.getpixel((x,y))[3] for y in range(46,53) for x in range(24,48)),f'no feet frame {i}'
OUT=ROOT/'assets'/'actor01_attack_weighted_sword_12frames.png'
sheet=Image.new('RGBA',(64*4,64*3),(0,0,0,0))
for i,im in enumerate(frames):
 sheet.alpha_composite(im,((i%4)*64,(i//4)*64))
sheet.save(OUT)
contact=Image.new('RGB',(4*512,3*512),(38,51,61))
for i,im in enumerate(frames):
 b=Image.new('RGBA',(64,64),(38,51,61,255));b.alpha_composite(im)
 contact.paste(b.convert('RGB').resize((512,512),Image.Resampling.NEAREST),((i%4)*512,(i//4)*512))
contact.save(ROOT/'qa'/'A41_SOURCE_KEYPOSES_8X.png')
digest=hashlib.sha256(OUT.read_bytes()).hexdigest()
unique=len({im.tobytes() for im in frames})
data={'stage':'A41','source_sha256':sha,'atlas_sha256':digest,'size':[256,192],'frame_size':[64,64],'frames':12,'unique_frames':unique,'fps':12,'hit_time':0.5,'hit_frame':6,'contact_anchor_px':[60,43],'contact_anchor_local':[28,11],'palette_source_only':True,'alpha_binary':True,'art_status':'HOLD pending 1x review and original character visual acceptance'}
(ROOT/'qa'/'A41_ART_DATA.json').write_text(json.dumps(data,ensure_ascii=False,indent=2),encoding='utf-8')
print('A41_ART_SOURCE_GENERATED',json.dumps(data))