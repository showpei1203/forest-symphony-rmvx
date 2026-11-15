from pathlib import Path
from PIL import Image
import shutil,glob,json,hashlib
root=Path(glob.glob('G:/*/FS_AI_ASSET_FACTORY_Restricted_Binaries')[0])
p=root/'FS_A51_ATTACK_ANTICIPATION_TRUE_PIXELLAB_20261116'
parent=root/'FS_A50_TRUE_PIXELLAB_SWORD_CONTACT_R3_20261116'
orig=parent/'godot_a50_r4'
dst=p/'godot_a51_r4_stable_fx'
assert orig.exists()
if dst.exists():
 assert not (p/'A51_STABLE_R4_FX_INTEGRATION_MANIFEST.json').exists(),'Protect finished stable build'
 shutil.rmtree(dst)
shutil.copytree(orig,dst,ignore=shutil.ignore_patterns('.godot','*.import','__pycache__'))
a=dst/'assets'
basebody=a/'actor01_a50_r4_body_12frames.png'
baseweapon=a/'actor01_a50_r4_weapon_12frames.png'
basefx=a/'actor01_a50_r4_fx_12frames.png'
newfx=p/'godot_a51_swordtrail/assets/actor01_a51_fx_swordtrail_12frames.png'
assert all(x.exists() for x in [basebody,baseweapon,basefx,newfx])
body=Image.open(basebody).convert('RGBA')
weapon=Image.open(baseweapon).convert('RGBA')
fx=Image.open(newfx).convert('RGBA')
assert body.size==weapon.size==fx.size==(256,192)
dest=a/'actor01_a51_r4_stable_fx_12frames.png'
shutil.copyfile(newfx,dest)
composite=body.copy()
composite.alpha_composite(weapon)
composite.alpha_composite(fx)
composite_file=a/'actor01_a51_r4_stable_composite_reference.png'
composite.save(composite_file)
mfile=a/'actor01_animation_manifest.json'
manifest=json.loads(mfile.read_text(encoding='utf8'))
manifest['layering']['fx']='res://assets/actor01_a51_r4_stable_fx_12frames.png'
manifest['animation_profiles']['attack_weighted']['provenance']='R4 original genuine PixelLab Body and true original model sword unmodified, A51 beam arc FX on separate layer, dynamic anticipation clock'
manifest['animation_profiles']['attack_weighted']['art_gate']='ART HOLD pending actual gameplay-scale review, but avoids A51 stronger pose head drift'
mfile.write_text(json.dumps(manifest,indent=2),encoding='utf8')
anim=dst/'scripts/fs_actor_animator.gd'
code=anim.read_text(encoding='utf8')
assert code.count('actor01_a50_r4_fx_12frames.png')==1
code=code.replace('actor01_a50_r4_fx_12frames.png','actor01_a51_r4_stable_fx_12frames.png')
assert code.count('var at: float = float(i) / 12.0')==1
code=code.replace('var at: float = float(i) / 12.0','var at: float = ATTACK_FRAME_KEY_SECONDS[i]')
lines='const ATTACK_HIT_SECOND: float = 0.63'
keys=[0.000,0.100,0.190,0.275,0.350,0.455,0.560,0.620,0.735,0.830,0.910,0.980]
assert code.count(lines)==1
code=code.replace(lines,lines+'\nconst ATTACK_FRAME_KEY_SECONDS := '+str(keys))
anim.write_text(code,encoding='utf8')
s=(dst/'qa/a50_r4_native_gpu_runtime_qa.gd').read_text(encoding='utf8')
s=s.replace('actor01_a50_r4_fx_12frames.png','actor01_a51_r4_stable_fx_12frames.png')
s=s.replace('actor01_a50_r4_composite_reference.png','actor01_a51_r4_stable_composite_reference.png')
s=s.replace('A50_','A51_SAFE_').replace('a50_','a51_safe_')
s=s.replace('res://qa/output/a50','res://qa/output/a51safe')
s=s.replace('actor01_a51_safe_r4_body_12frames.png','actor01_a50_r4_body_12frames.png')
s=s.replace('actor01_a51_safe_r4_weapon_12frames.png','actor01_a50_r4_weapon_12frames.png')
assert 'A51_SAFE_QA_RESULT' in s
(dst/'qa/a51_safe_native_gpu_runtime_qa.gd').write_text(s,encoding='utf8')
c=(dst/'qa/a50_r4_contact_damage_native_qa.gd').read_text(encoding='utf8')
c=c.replace('A50_','A51_SAFE_').replace('a50_','a51_safe_')
c=c.replace('res://qa/output/a50','res://qa/output/a51safe')
assert 'A51_SAFE_CONTACT_QA_RESULT' in c
(dst/'qa/a51_safe_contact_damage_native_qa.gd').write_text(c,encoding='utf8')
proj=dst/'project.godot'
proj.write_text(proj.read_text(encoding='utf8').replace('FS A49 R2 Real PixelLab Full-Torso Sword Candidate',
 'FS A51 SAFE Stable A50 R4 PixelLab Body + True Sword Trail FX'),encoding='utf8')
r={'stage':'A51_SAFE','R4_PixelLab_fullbody_preserved_SHA256':hashlib.sha256(basebody.read_bytes()).hexdigest(),
 'R4_stable_Body_matching_original':basebody.read_bytes()==(orig/'assets/actor01_a50_r4_body_12frames.png').read_bytes(),
 'R4_original_real_model_weapon_unchanged':baseweapon.read_bytes()==(orig/'assets/actor01_a50_r4_weapon_12frames.png').read_bytes(),
 'A51_new_swordtrail_FX_only':True,
 'new_FX_RGBA_sha256':hashlib.sha256(dest.read_bytes()).hexdigest(),
 'nonlinear_attack_keys':keys,'F7_0_63_contact':True,
 'native':'PENDING','art':'HOLD'}
assert r['R4_stable_Body_matching_original'] and r['R4_original_real_model_weapon_unchanged']
(p/'A51_STABLE_R4_FX_INTEGRATION_MANIFEST.json').write_text(json.dumps(r,indent=2),encoding='utf8')
print('A51_STABLE_R4_FULL_BODY_TOTALLY_UNCHANGED','body',r['R4_PixelLab_fullbody_preserved_SHA256'],
 'FX',r['new_FX_RGBA_sha256'],'nonlinear_F6_to_F7',keys[7]-keys[6],flush=True)