from pathlib import Path
import json,glob,shutil,hashlib
from PIL import Image
p=Path(glob.glob('G:/*/FS_AI_ASSET_FACTORY_Restricted_Binaries/FS_A47_MOTION_LINKED_ATTACK_20261115')[0])
a=p/'assets';q=p/'qa'
metrics=json.loads((q/'A47_VARIANT_VISUAL_GEOMETRY_QA.json').read_text(encoding='utf8'))['candidates']
assert not metrics['R1']['technical_pass'] and not metrics['R2']['technical_pass']
assert metrics['R3']['technical_pass']
for layer in ['weapon','fx']:
 shutil.copyfile(a/('actor01_a46_'+layer+'_12frames.png'),a/('actor01_a47_'+layer+'_12frames.png'))
shutil.copyfile(a/'actor01_a47_body_R3_12frames.png',a/'actor01_a47_body_12frames.png')
source=json.loads((a/'actor01_a46_attack_anchors.json').read_text(encoding='utf8'))
source['stage']='A47'
source['source']='Unmodified verified A46 sword and tip path, compatible with A47 body wrist IK lock'
(a/'actor01_a47_attack_anchors.json').write_text(json.dumps(source,indent=2,ensure_ascii=False),encoding='utf8')
comp=Image.new('RGBA',(256,192))
for name in ['body','weapon','fx']:
 comp.alpha_composite(Image.open(a/('actor01_a47_'+name+'_12frames.png')).convert('RGBA'))
comp.save(a/'actor01_a47_composite_reference.png')
manifest=a/'actor01_animation_manifest.json'
data=json.loads(manifest.read_text(encoding='utf8'))
prof=data['animation_profiles']['attack_weighted']
prof['sprite_sheet']='res://assets/actor01_a47_body_12frames.png'
prof['provenance']='A47 R3 continuous 2D inverse warp; A57 18-joint/A65 scanline negatives; A46 wrist-locked weapon'
prof['art_gate']='A47 technical natural-body QA pass; aesthetic ART HOLD, user has not accepted action'
for part in ['body','weapon','fx']:
 data['layering'][part]='res://assets/actor01_a47_'+part+'_12frames.png'
data['layering']['geometry']='res://assets/actor01_a47_attack_anchors.json'
manifest.write_text(json.dumps(data,ensure_ascii=False,indent=2),encoding='utf8')
anim=p/'scripts/fs_actor_animator.gd'; t=anim.read_text(encoding='utf8')
for kind in ['weapon_12frames.png','fx_12frames.png','attack_anchors.json']:
 old='actor01_a46_'+kind
 if old in t:
  assert t.count(old)==1,(old,t.count(old))
  t=t.replace(old,'actor01_a47_'+kind)
 else:
  assert ('actor01_a47_'+kind) in t,'unexpected animator asset path'
anim.write_text(t,encoding='utf8')
for name in ['native_gpu_runtime_qa.gd','contact_damage_native_qa.gd']:
 original=q/('a46_'+name)
 t=original.read_text(encoding='utf8')
 t=t.replace('A46','A47').replace('a46','a47')
 (q/('a47_'+name)).write_text(t,encoding='utf8')
project=p/'project.godot'
project.write_text(project.read_text(encoding='utf8').replace('FS A46 Coherent Spine Lean Attack Prototype','FS A47 Continuous Joint-Constrained Sword Attack'),encoding='utf8')
# A57 prompt specification: 18 human joint names. Coordinates below are
# a reproducible manual approximate design rig, NOT PixelLab output.
approx={'NOSE':[33,31],'LEFT EYE':[30,30],'RIGHT EYE':[36,30],
'LEFT EAR':[28,29],'RIGHT EAR':[38,29],'NECK':[34,34],
'LEFT SHOULDER':[29,36],'RIGHT SHOULDER':[39,36],
'LEFT ELBOW':[27,40],'RIGHT ELBOW':[43,39],
'LEFT ARM':[28,43],'RIGHT ARM':[45,42],
'LEFT HIP':[31,44],'RIGHT HIP':[38,44],
'LEFT KNEE':[30,47],'RIGHT KNEE':[41,47],
'LEFT LEG':[30,49],'RIGHT LEG':[43,49]}
plan=json.loads((q/'A47_MOTION_SPEC.json').read_text(encoding='utf8'))
motion=plan['12_frame_profile']
import math
def g(x,y,cx,cy,sx,sy):return math.exp(-.5*((x-cx)/sx)**2-.5*((y-cy)/sy)**2)
def displaced(i,x,y):
 L=motion[i]['load'];T=motion[i]['twist'];R=motion[i]['recoil']
 dx=L*(.62*g(x,y,34,25,11,9)+.94*g(x,y,35,36,15,6)+.62*g(x,y,34,40,13,5)+.17*g(x,y,34,44,11,4))
 dy=T*((x-34)/11.)*g(x,y,34,36,15,6)+R*g(x,y,34,42,11,5)
 wrist=source['pose_anchors'][i]['wrist_px']
 if wrist:
  w=g(x,y,wrist[0],wrist[1],4.2,4.)
  dx*=1.-min(1.,w*1.05);dy*=1.-min(1.,w*1.05)
 lock=max(0,min(1,(y-43)/4.))
 return [round(x+1.43*dx,2),round(y+1.43*dy,2)] if lock<1 else [x,y]
joints=[]
for i in range(12):
 pts={key:displaced(i,*p0) for key,p0 in approx.items()}
 pts['RIGHT ARM']=source['pose_anchors'][i]['wrist_px'] or approx['RIGHT ARM']
 joints.append({'frame':i,'phase':motion[i]['phase'],'pose_18_joint_design':pts,
  'virtual_chest_center':displaced(i,34,39),'virtual_pelvis_center':[34,44],
  'sword_tip_px':source['pose_anchors'][i]['sword_tip_px']})
rig={'stage':'A47','derived_from':'A57 18-joint skill-style / A65 negative scanline',
'source_joint_coordinates':'Manual approximate pixel anchors measured from A62/A46 45deg pose; NOT paid PixelLab estimate',
'constraint_method':'spatial Gaussian inverse warp anchored pelvis, knees, boots, wrist; whole body resampled once',
'frames':joints,'human_approval':'PENDING'}
(q/'A47_18JOINT_DESIGN_NOT_PROVIDER.json').write_text(json.dumps(rig,ensure_ascii=False,indent=2),encoding='utf8')
print('A47_R3_PROMOTED_AS_CANDIDATE',hashlib.sha256((a/'actor01_a47_body_12frames.png').read_bytes()).hexdigest(),flush=True)
