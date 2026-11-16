from PIL import Image,ImageDraw
from pathlib import Path
import json,math,hashlib,io
p=Path(__file__).resolve().parents[1]
a=p/'assets'
canonical=Image.open(a/'actor01_a62_approved_idle_source_64.png').convert('RGBA')
prev=Image.open(a/'actor01_a47_body_12frames.png').convert('RGBA')
weapon=Image.open(a/'actor01_a47_weapon_12frames.png').convert('RGBA')
fx=Image.open(a/'actor01_a47_fx_12frames.png').convert('RGBA')
rig=json.loads((a/'actor01_a47_attack_anchors.json').read_text(encoding='utf8'))
palette={
 'outline':(2,3,5,255),'deep':(6,8,11,255),
 'shade':(20,44,43,255),'mid':(25,60,53,255),
 'highlight':(46,74,65,255),'edge':(25,67,67,255),
 'gold':(145,120,63,255),'gold_hi':(163,143,40,255),
 'glove':(89,70,56,255),'glove_hi':(125,95,72,255)}
# ONE unchanged whole torso, pelvis, legs, head and offhand A62 base.
# Only the sword arm is edited; shoulder->elbow->wrist drawn as one continuously
# connected, chibi-proportioned structure. No whole-body independent warp.
elbows=[
 (41,40),(41,40),(41,37),(41,35),(42,35),(43,35),
 (44,39),(43,42),(43,43),(42,42),(41,41),(41,40)
]
shoulders=[(39,36)]*12
def tile(img,i):
 return img.crop((i%4*64,i//4*64,(i%4+1)*64,(i//4+1)*64))
def put(img,frame,i):img.alpha_composite(frame,(i%4*64,i//4*64))
def draw_connected_arm(base,i):
 if i in (0,11):
  return base.copy()
 arm=Image.new('RGBA',(64,64))
 ad=ImageDraw.Draw(arm)
 # first draw underlying shoulder roll, then whole sleeve, then glove;
 # each stroke overlaps the preceding anatomical joint by >=2 pixels.
 s=shoulders[i];e=elbows[i];w=tuple(rig['pose_anchors'][i]['wrist_px'])
 # Arm bone lengths are all constrained to chibi style. The outer shoulder
 # dark patch overlaps original collar and torso (x38-40 y35-39).
 ad.ellipse((s[0]-3,s[1]-2,s[0]+3,s[1]+3),fill=palette['outline'])
 ad.ellipse((s[0]-2,s[1]-1,s[0]+2,s[1]+2),fill=palette['shade'])
 ad.line([s,e,w],fill=palette['outline'],width=6,joint='curve')
 ad.line([s,e,w],fill=palette['shade'],width=4,joint='curve')
 ad.line([(s[0]-1,s[1]),e,w],fill=palette['mid'],width=2,joint='curve')
 ad.line([s,e],fill=palette['highlight'],width=1)
 # Distinct gold metal pauldron still tied to its actual shoulder, not a copy
 # from the previous warped portrait or a detached pixel blob.
 ad.line([(s[0]-2,s[1]-2),(s[0]+2,s[1]-1)],fill=palette['gold'],width=2)
 ad.point((s[0]+1,s[1]-2),fill=palette['gold_hi'])
 # Glove and wrist joint explicitly share the same anchor as sword pivot.
 ad.ellipse((w[0]-2,w[1]-2,w[0]+2,w[1]+2),fill=palette['outline'])
 ad.rectangle((w[0]-1,w[1]-1,w[0]+1,w[1]+1),fill=palette['glove'])
 ad.point((w[0]+1,w[1]-1),fill=palette['glove_hi'])
 # Erase only the canonical resting sword arm *inside its precise semantic
 # area* and redraw a continuous sleeve. Never touch waist, hips or legs.
 result=base.copy()
 for y in range(36,46):
  for x in range(41,49):
   if x>=42 or (x==41 and y>=39):
    result.putpixel((x,y),(0,0,0,0))
 result.alpha_composite(arm)
 # maintain contact between the original chest and the new shoulder: a dark
 # connective underarm fold attaches to original torso at x37..40.
 d=ImageDraw.Draw(result)
 d.line([(37,38),(39,39),(40,38)],fill=palette['shade'],width=2,joint='curve')
 # Slight shoulder-led rib cage folds (not wholesale joint displacements).
 # Keep all silhouette geometry attached and original character facial identity.
 if i in (2,3,4):
  d.line([(32,40),(35,41),(37,40)],fill=palette['highlight'],width=1)
 elif i in (5,6,7):
  d.line([(33,39),(36,40),(38,41)],fill=palette['highlight'],width=1)
 elif i in (8,9):
  d.line([(33,40),(36,41)],fill=palette['edge'],width=1)
 # Two real physical constraints, not a vague apparent visual match:
 # white-haired face/hair must stay in front of the weapon arm when raised;
 # all feet + hip base must stay EXACTLY canonical (even when glove is low).
 for y in list(range(0,34))+list(range(47,64)):
  for x in range(64):
   result.putpixel((x,y),base.getpixel((x,y)))
 return result
body=Image.new('RGBA',(256,192))
comparison=Image.new('RGBA',(768,128))
report={'source':'A62 64x64 canonical entire person','stage':'A48_R1','pose_nodes':[]}
for i in range(12):
 fresh=draw_connected_arm(canonical,i)
 put(body,fresh,i)
 put(comparison,tile(prev,i),i)
 put(comparison,fresh,i+12) if False else None
 comparison.alpha_composite(fresh,(i*64,64))
 wrist=rig['pose_anchors'][i]['wrist_px']
 report['pose_nodes'].append({'frame':i,'shoulder':list(shoulders[i]),'elbow':list(elbows[i]),
  'wrist':wrist,'weapon_tip':rig['pose_anchors'][i]['sword_tip_px']})
body.save(a/'actor01_a48_body_R1_12frames.png')
full=Image.new('RGBA',(256,192))
for layer in [body,weapon,fx]:full.alpha_composite(layer)
full.save(a/'actor01_a48_composite_R1.png')
comparison.resize((2304,384),Image.Resampling.NEAREST).save(p/'A48_R1_A47_VS_CONNECTED_ARM_3X.png')
frames=[tile(full,i).resize((256,256),Image.Resampling.NEAREST) for i in range(12)]
buffer=io.BytesIO()
frames[0].save(buffer,format='GIF',save_all=True,append_images=frames[1:],
 duration=[115,100,85,85,75,70,160,95,100,100,110,115],loop=0,disposal=2)
(p/'A48_R1_SPRITE_ART_PREVIEW_4X.gif').write_bytes(buffer.getvalue())
(p/'qa/A48_ARM_JOINT_GEOMETRY.json').write_text(json.dumps(report,indent=2),encoding='utf8')
print('A48_R1_BUILT',hashlib.sha256((a/'actor01_a48_body_R1_12frames.png').read_bytes()).hexdigest(),flush=True)
