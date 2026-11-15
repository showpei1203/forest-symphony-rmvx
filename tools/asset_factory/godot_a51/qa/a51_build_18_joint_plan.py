from pathlib import Path
from PIL import Image,ImageDraw
import json,glob,math,hashlib
root=Path(glob.glob('G:/*/FS_AI_ASSET_FACTORY_Restricted_Binaries')[0])
p=root/'FS_A51_ATTACK_ANTICIPATION_TRUE_PIXELLAB_20261116'
p.mkdir(exist_ok=True)
parent=root/'FS_A50_TRUE_PIXELLAB_SWORD_CONTACT_R3_20261116'
request=json.loads((parent/'head_lock_R4/A50_R4_IDENTITY_LOCK_REAL_PIXELLAB_REQUEST_NO_TOKEN.json').read_text(encoding='utf8'))
assert len(request['keypoints'])==10
# True new model generation, 18-joint posture edit, not pixel-cut body.
# Frame-specific: plant both feet, preserve approved head six joints and contact/recovery wrist F6-F10.
# columns: shoulder, elbow, wrist, opposite shoulder, counter elbow, hips/knees
D=[
 {"ls":(-.3,0),"le":(-.7,-.1),"lw":(-.8,0),"rs":(.1,0),"re":(.2,0),"lh":(.2,.1),"rh":(-.1,0)},
 {"ls":(-1.0,-.3),"le":(-1.2,-.7),"lw":(-1.2,-.8),"rs":(.6,-.2),"re":(.8,-.6),"lh":(.7,.2),"rh":(-.4,-.1)},
 {"ls":(-1.7,-.7),"le":(-1.8,-1.0),"lw":(-1.6,-1.2),"rs":(1.0,-.4),"re":(1.1,-.7),"lh":(.9,.3),"rh":(-.5,-.2)},
 {"ls":(-1.6,-.8),"le":(-1.5,-1.2),"lw":(-1.8,-1.3),"rs":(1.1,-.5),"re":(1.0,-.6),"lh":(1.0,.2),"rh":(-.6,-.2)},
 {"ls":(-.5,-.4),"le":(-.9,-.5),"lw":(-.7,-.5),"rs":(.3,-.2),"re":(.5,-.3),"lh":(.4,.1),"rh":(-.3,0)},
 {"ls":(.5,.3),"le":(.3,.2),"lw":(0,0),"rs":(-.5,-.2),"re":(-.2,0),"lh":(-.3,0),"rh":(.4,-.1)},
 {"ls":(.8,.4),"le":(.4,.1),"lw":(0,0),"rs":(-.5,-.2),"re":(-.4,.2),"lh":(-.5,0),"rh":(.4,0)},
 {"ls":(.4,.2),"le":(.3,.1),"lw":(0,0),"rs":(-.2,0),"re":(-.2,.1),"lh":(-.2,0),"rh":(.2,0)},
 {"ls":(.2,0),"le":(0,0),"lw":(0,0),"rs":(0,0),"re":(0,0),"lh":(0,0),"rh":(0,0)},
 {"ls":(0,0),"le":(0,0),"lw":(0,0),"rs":(0,0),"re":(0,0),"lh":(0,0),"rh":(0,0)}
]
J={"ls":"LEFT SHOULDER","le":"LEFT ELBOW","lw":"LEFT ARM","rs":"RIGHT SHOULDER","re":"RIGHT ELBOW","lh":"LEFT HIP","rh":"RIGHT HIP"}
for i,delta in enumerate(D):
 frame=request['keypoints'][i]
 names={x['label']:x for x in frame}
 for short,(dx,dy) in delta.items():
  q=names[J[short]]
  q['x']=round(q['x']+dx/64,6);q['y']=round(q['y']+dy/64,6)
 # hips bend knees slightly to suggest grounded weight transfer, boots never slide.
 if i in (1,2,3,4,5,6):
  for key in ['LEFT KNEE','RIGHT KNEE']:
   q=names[key];q['y']=round(q['y']+(.30 if i in (2,3) else .16)/64,6)
 assert len(names)==18
 for item in frame:assert 0<item['x']<1 and 0<item['y']<1
 for key in ['LEFT LEG','RIGHT LEG','NOSE','LEFT EYE','RIGHT EYE','LEFT EAR','RIGHT EAR','NECK']:
  original={x['label']:x for x in json.loads((parent/'head_lock_R4/A50_R4_IDENTITY_LOCK_REAL_PIXELLAB_REQUEST_NO_TOKEN.json').read_text(encoding='utf8'))['keypoints'][i]}
  assert names[key]==original[key]
 for a,b in [('LEFT SHOULDER','LEFT ELBOW'),('LEFT ELBOW','LEFT ARM'),('RIGHT SHOULDER','RIGHT ELBOW'),('RIGHT ELBOW','RIGHT ARM')]:
  dist=64*math.dist((names[a]['x'],names[a]['y']),(names[b]['x'],names[b]['y']))
  assert 1.0<dist<8.0,(i+1,a,b,dist)
# Make dynamic action clear to the model without weapons/FX baked into Body.
request['action']='full body grounded overhand slash, pronounced shoulder and hip coil before strong forward release, invisible sword exercise, complete connected arms and stable planted boots'
request['description']='same approved 64px anime chibi white-haired fantasy swordsman with teal green gold trimmed armor, consistent facial identity, full connected human body, dynamic shoulder and hip counter-turn, empty bare glove holding invisible weapon, NO sword visible, transparent background, crisp clean pixel art, stable silhouette'
request['seed']=171119
rp=p/'A51_REAL_PIXEL_LAB_ANTICIPATION_REQUEST_NO_TOKEN.json'
rp.write_text(json.dumps(request,indent=2),encoding='utf8')
ref=Image.open(parent/'R2_ORIGINAL_PIXEL_LAB_PROVENANCE/A49_ACTOR01_A62_CANONICAL_F0_64.png').convert('RGBA')
layout=Image.new('RGB',(320*5,320*2),(31,35,40))
draw=ImageDraw.Draw(layout)
for i,frame in enumerate(request['keypoints']):
 idx=i+1;xx=i%5*320;yy=i//5*320
 bg=Image.new('RGBA',(64,64),(31,35,40,255));bg.alpha_composite(ref)
 layout.paste(bg.convert('RGB').resize((320,320),Image.Resampling.NEAREST),(xx,yy))
 pts={j['label']:(xx+round(j['x']*320), yy+round(j['y']*320)) for j in frame}
 for a,b in [('NECK','LEFT SHOULDER'),('NECK','RIGHT SHOULDER'),('LEFT SHOULDER','LEFT ELBOW'),
 ('LEFT ELBOW','LEFT ARM'),('RIGHT SHOULDER','RIGHT ELBOW'),('RIGHT ELBOW','RIGHT ARM'),
 ('LEFT SHOULDER','LEFT HIP'),('RIGHT SHOULDER','RIGHT HIP'),('LEFT HIP','RIGHT HIP'),
 ('LEFT HIP','LEFT KNEE'),('RIGHT HIP','RIGHT KNEE'),('LEFT KNEE','LEFT LEG'),('RIGHT KNEE','RIGHT LEG')]:
  draw.line([pts[a],pts[b]],fill=(248,183,69) if a.startswith('LEFT') else (72,201,219),width=2)
 draw.text((xx+5,yy+5),'A51 F%02d %s'%(idx,'COIL' if idx<5 else 'STRIKE' if idx<8 else 'RECOVER'),fill=(255,255,255))
layout.save(p/'A51_18JOINT_ANTICIPATION_POSE_PLAN_5X.png')
quality={'stage':'A51','source':'A50 R4 PixelLab true fullbody','source_approved_actor':'A62 64px',
 'R4_18_joint_head_and_feet_exact':True,'provider_paid_new_call':False,
 'planned_new_frames':10,'max_single_post_generations_estimate':3.0,
 'preflight_reproducible':True,'request_sha256':hashlib.sha256(rp.read_bytes()).hexdigest(),
 'purpose':'create visually stronger sword preparation and torso transfer; no image body cut, no face drift, contact remains 0.63s F7'}
(p/'A51_PREFLIGHT_QA.json').write_text(json.dumps(quality,indent=2),encoding='utf8')
print('A51_18JOINT_TRUE_PIXEL_LAB_PREFLIGHT_PASS',quality['request_sha256'],'10 frames, head lock, feet lock, phase-specific coil and followthrough',flush=True)