from pathlib import Path
from PIL import Image
import json,glob,shutil,hashlib,math
root=Path(glob.glob('G:/*/FS_AI_ASSET_FACTORY_Restricted_Binaries')[0])
base=root/'FS_A50_TRUE_PIXELLAB_SWORD_CONTACT_R3_20261116'
p=root/'FS_A51_ATTACK_ANTICIPATION_TRUE_PIXELLAB_20261116'
source=base/'godot_a50_r4'
dst=p/'godot_a51'
assert not dst.exists(),'Do not overwrite an already generated A51 Godot candidate'
shutil.copytree(source,dst,ignore=shutil.ignore_patterns('.godot','*.import','__pycache__'))
a=dst/'assets'
body=Image.open(p/'model_outputs/A51_REAL_PIXELLAB_BODY_12FRAME_256x192.png').convert('RGBA')
oldW=Image.open(a/'actor01_a50_r4_weapon_12frames.png').convert('RGBA')
oldFX=Image.open(a/'actor01_a50_r4_fx_12frames.png').convert('RGBA')
anchors=json.loads((a/'actor01_a50_r4_attack_anchors.json').read_text(encoding='utf8'))
baseplan=json.loads((base/'head_lock_R4/A50_R4_IDENTITY_LOCK_REAL_PIXELLAB_REQUEST_NO_TOKEN.json').read_text(encoding='utf8'))
newplan=json.loads((p/'A51_REAL_PIXEL_LAB_ANTICIPATION_REQUEST_NO_TOKEN.json').read_text(encoding='utf8'))
newW=Image.new('RGBA',(256,192))
newFX=Image.new('RGBA',(256,192))
def cell(img,fi):
 x=fi%4*64;y=fi//4*64
 return img.crop((x,y,x+64,y+64))
def components(im):
 pts={(x,y) for y in range(64)for x in range(64)if im.getpixel((x,y))[3]>0}
 sizes=[]
 while pts:
  root=pts.pop();pending=[root];size=1
  while pending:
   x,y=pending.pop()
   for xx in range(x-1,x+2):
    for yy in range(y-1,y+2):
     if (xx,yy) in pts:
      pts.remove((xx,yy));pending.append((xx,yy));size+=1
  sizes.append(size)
 return sorted(sizes,reverse=True)
def pose_wrist(plan,i):
 z={j['label']:j for j in plan['keypoints'][i-1]}
 return (64*z['LEFT ARM']['x'],64*z['LEFT ARM']['y'])
moves=[]
for fi in range(12):
 b=cell(body,fi);w=cell(oldW,fi);fx=cell(oldFX,fi)
 if fi in [0,11]:
  selected=(0,0);allconnected=True;wrist=(0,0)
 else:
  old=pose_wrist(baseplan,fi);new=pose_wrist(newplan,fi)
  preferred=(int(round(new[0]-old[0])),int(round(new[1]-old[1])))
  # Find lowest-cost rigid weapon move, never deform full-body model.
  options=[]
  raw_alpha=sum(p[3]>0 for p in w.get_flattened_data())
  for dx in range(-3,4):
   for dy in range(-3,4):
    sample=Image.new('RGBA',(64,64))
    sample.paste(w,(dx,dy))
    if sum(p[3]>0 for p in sample.get_flattened_data())!=raw_alpha:continue
    union=b.copy();union.alpha_composite(sample)
    connected=len(components(union))==1
    # The sword base should be in the R5 model-glove neighbourhood,
    # not merely touching a detached patch somewhere else.
    near=0
    for yy in range(max(0,int(new[1])-3),min(64,int(new[1])+4)):
     for xx in range(max(0,int(new[0])-3),min(64,int(new[0])+4)):
      if sample.getpixel((xx,yy))[3] and b.getpixel((xx,yy))[3]:near+=1
    if connected:
     score=abs(dx-preferred[0])*4+abs(dy-preferred[1])*4+abs(dx)+abs(dy)-min(near,3)*.1
     options.append((score,dx,dy,near))
  if not options:
   # Don't fabricate a disconnected weapon to make a demo PASS.
   raise RuntimeError('A51 F%02d weapon cannot connect to real model body with <=3px rigid move'%fi)
  best=min(options)
  selected=(best[1],best[2]);allconnected=True;wrist=(round(new[0],2),round(new[1],2))
 destW=Image.new('RGBA',(64,64));destW.paste(w,selected)
 destFX=Image.new('RGBA',(64,64));destFX.paste(fx,selected)
 assert destW.getbbox()==None or len(components((lambda im: (im.alpha_composite(destW),im)[1])(b.copy())))==1
 newW.alpha_composite(destW,(fi%4*64,fi//4*64))
 newFX.alpha_composite(destFX,(fi%4*64,fi//4*64))
 record=anchors['pose_anchors'][fi]
 for key in ['wrist_px','sword_tip_px','hit_marker_local_px']:
  if key in record:
   point=record[key]
   record[key]=[point[0]+selected[0],point[1]+selected[1]]
 moves.append({'frame':fi,'rigid_weapon_dx_dy':list(selected),'wrist_target':wrist,
               'body_plus_weapon_single_component':allconnected})
assert all(r['body_plus_weapon_single_component'] for r in moves)
contact=anchors['pose_anchors'][7]['hit_marker_local_px']
assert len(contact)==2
body_file=a/'actor01_a51_body_12frames.png'
weapon_file=a/'actor01_a51_weapon_12frames.png'
fx_file=a/'actor01_a51_fx_12frames.png'
body.save(body_file);newW.save(weapon_file);newFX.save(fx_file)
anchors['stage']='A51'
anchors['source']='Actual PixelLab A51 true fullbody job b997be06-c1fa-4741-8fb9-bcedf6fc9a39, genuine PixelLab R2 independent sword (R4 base); original generated body unchanged'
(a/'actor01_a51_attack_anchors.json').write_text(json.dumps(anchors,indent=2),encoding='utf8')
comp=body.copy();comp.alpha_composite(newW);comp.alpha_composite(newFX)
comp.save(a/'actor01_a51_composite_reference.png')
manfile=a/'actor01_animation_manifest.json'
manifest=json.loads(manfile.read_text(encoding='utf8'))
manifest['animation_profiles']['attack_weighted']['sprite_sheet']='res://assets/actor01_a51_body_12frames.png'
manifest['animation_profiles']['attack_weighted']['provenance']='10 new real PixelLab Skeleton V3 fullbody frames, original A62 F0/F11, separate proven model sword, rigidly retargeted sword only'
manifest['animation_profiles']['attack_weighted']['art_gate']='ART HOLD: R5 head drift higher; A50 R4 remains fallback'
for key in ['body','weapon','fx']:
 if key in manifest.get('layering',{}):manifest['layering'][key]='res://assets/actor01_a51_'+key+'_12frames.png'
if 'geometry' in manifest.get('layering',{}):manifest['layering']['geometry']='res://assets/actor01_a51_attack_anchors.json'
manfile.write_text(json.dumps(manifest,indent=2),encoding='utf8')
animfile=dst/'scripts/fs_actor_animator.gd'
code=animfile.read_text(encoding='utf8')
for suffix in ['attack_anchors.json','weapon_12frames.png','fx_12frames.png']:
 old='actor01_a50_r4_'+suffix;assert code.count(old)==1,(old,code.count(old))
 code=code.replace(old,'actor01_a51_'+suffix)
assert code.count('var at: float = float(i) / 12.0')==1
code=code.replace('var at: float = float(i) / 12.0','var at: float = ATTACK_FRAME_KEY_SECONDS[i]')
needle='const ATTACK_HIT_SECOND: float = 0.63'
assert code.count(needle)==1
keys=[0.000,0.100,0.190,0.275,0.350,0.455,0.560,0.620,0.735,0.830,0.910,0.980]
code=code.replace(needle,needle+'\nconst ATTACK_FRAME_KEY_SECONDS := '+str(keys))
animfile.write_text(code,encoding='utf8')
oldgpu=dst/'qa/a50_r4_native_gpu_runtime_qa.gd'
gpu=oldgpu.read_text(encoding='utf8')
for name in ['body_12frames.png','weapon_12frames.png','fx_12frames.png','composite_reference.png']:
 gpu=gpu.replace('actor01_a50_r4_'+name,'actor01_a51_'+name)
gpu=gpu.replace('A50_','A51_').replace('a50_','a51_')
# This QA verifies exact 0.63 F7, no old .55 premature hit, and new atlas.
oldmarker='Vector2(29,7)'
newmarker=f'Vector2({contact[0]},{contact[1]})'
# GPU does not assert marker directly; contact QA does.
(dst/'qa/a51_native_gpu_runtime_qa.gd').write_text(gpu,encoding='utf8')
c=(dst/'qa/a50_r4_contact_damage_native_qa.gd').read_text(encoding='utf8')
c=c.replace('A50_','A51_').replace('a50_','a51_')
if oldmarker in c:c=c.replace(oldmarker,newmarker)
(dst/'qa/a51_contact_damage_native_qa.gd').write_text(c,encoding='utf8')
# Pure timing regression gate, not a visual art proof.
qa={'stage':'A51','PixelLab_REAL_job':'b997be06-c1fa-4741-8fb9-bcedf6fc9a39',
 'R4_original_project_unmodified':True,'raw_provider_body_sha256':hashlib.sha256(body_file.read_bytes()).hexdigest(),
 'moving_frame_sword_connection':moves,'contact_at_F7_time':.63,'contact_local':contact,
 'timing_per_frame_key_seconds':keys,'engine':'Godot 4.7.2','native':'PENDING','overall_art':'HOLD'}
(p/'A51_GODOT_INTEGRATION_SOURCE_QA.json').write_text(json.dumps(qa,indent=2),encoding='utf8')
print('A51_REAL_BODY_INDEPENDENT_SWORD_GODOT_WIRED','F7 marker',contact,
      'shifts',[r['rigid_weapon_dx_dy']for r in moves], 'F6_to_F7_acceleration_seconds',round(keys[7]-keys[6],3),
      'source_Body_SHA',qa['raw_provider_body_sha256'],flush=True)