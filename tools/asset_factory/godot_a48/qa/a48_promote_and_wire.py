from pathlib import Path
from PIL import Image
import glob,json,shutil,hashlib
p=Path(__file__).resolve().parents[1];a=p/'assets';q=p/'qa'
assert json.loads((q/'A48_CONNECTION_QA.json').read_text(encoding='utf8'))['structural_pass']
shutil.copyfile(a/'actor01_a48_body_R1_12frames.png',a/'actor01_a48_body_12frames.png')
for name in ['weapon','fx']:
 shutil.copyfile(a/('actor01_a47_'+name+'_12frames.png'),a/('actor01_a48_'+name+'_12frames.png'))
com=Image.new('RGBA',(256,192))
for layer in ['body','weapon','fx']:
 com.alpha_composite(Image.open(a/('actor01_a48_'+layer+'_12frames.png')).convert('RGBA'))
com.save(a/'actor01_a48_composite_reference.png')
rig=json.loads((a/'actor01_a47_attack_anchors.json').read_text(encoding='utf8'))
rig['stage']='A48'
rig['source']='A47 exact sword frames and F6 geometry, deterministic 3-joint connected arm drawn over original A62 complete body'
(a/'actor01_a48_attack_anchors.json').write_text(json.dumps(rig,indent=2),encoding='utf8')
manifest=a/'actor01_animation_manifest.json';m=json.loads(manifest.read_text(encoding='utf8'))
m['animation_profiles']['attack_weighted']['sprite_sheet']='res://assets/actor01_a48_body_12frames.png'
m['animation_profiles']['attack_weighted']['art_gate']='A48 connected-body proof PASS; aesthetic HOLD until user review'
for name in ['body','weapon','fx']:m['layering'][name]='res://assets/actor01_a48_'+name+'_12frames.png'
m['layering']['geometry']='res://assets/actor01_a48_attack_anchors.json'
manifest.write_text(json.dumps(m,indent=2,ensure_ascii=False),encoding='utf8')
anim=p/'scripts/fs_actor_animator.gd';t=anim.read_text(encoding='utf8')
for suffix in ['weapon_12frames.png','fx_12frames.png','attack_anchors.json']:
 old='actor01_a47_'+suffix; new='actor01_a48_'+suffix
 assert t.count(old)==1,(old,t.count(old))
 t=t.replace(old,new)
anim.write_text(t,encoding='utf8')
for suffix in ['native_gpu_runtime_qa.gd','contact_damage_native_qa.gd']:
 src=(q/('a47_'+suffix)).read_text(encoding='utf8')
 (q/('a48_'+suffix)).write_text(src.replace('A47','A48').replace('a47','a48'),encoding='utf8')
gate=(q/'a47_waist_gate.py').read_text(encoding='utf8').replace('A47_NATIVE_F%02d.png','A48_NATIVE_F%02d.png').replace('A47_WAIST_GATE','A48_WAIST_GATE')
(q/'a48_waist_gate.py').write_text(gate,encoding='utf8')
runner=(q/'a47_cold_native.py').read_text(encoding='utf8').replace('FS_A47_MOTION_LINKED_ATTACK_20261115','FS_A48_CONNECTED_ARM_PIXEL_POSES_20261115').replace('A47','A48').replace('a47','a48')
(q/'a48_cold_native.py').write_text(runner,encoding='utf8')
project=p/'project.godot'
project.write_text(project.read_text(encoding='utf8').replace('FS A47 Continuous Joint-Constrained Sword Attack','FS A48 Canonical Connected-Sleeve Sword Action'),encoding='utf8')
print('A48_GODOT_WIRED',hashlib.sha256((a/'actor01_a48_body_12frames.png').read_bytes()).hexdigest(),flush=True)
