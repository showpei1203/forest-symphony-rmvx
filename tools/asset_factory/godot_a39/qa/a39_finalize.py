from pathlib import Path
import hashlib,json,zipfile,datetime
root=Path(__file__).resolve().parent.parent
private=root.parent
assert (root/'project.godot').exists()
required=[
 'project.godot','README.md','qa/A39_FAILURE_LOG.md',
 'scenes/actor01_breath_rig.tscn','scenes/actor01.tscn','scenes/battle_animation_preview.tscn',
 'shaders/chest_breath.gdshader',
 'scripts/fs_actor_breath_rig.gd','scripts/fs_actor_animator.gd','scripts/battle_animation_preview.gd',
 'assets/actor01_a62_approved_idle_source_64.png','assets/actor01_run_a35_8frames.png',
 'qa/a39_rig_gpu_qa.gd','qa/a39_integrated_runtime_qa.gd',
 'qa/output/A39_GODOT_GPU_BREATH_8_FRAME_CONTACT_7X.png',
 'qa/output/A39_GODOT_GPU_BREATH_8_PHASE_LOOP.gif',
 'qa/output/A39_VERIFIED_LOCAL_SHADER_GPU.log',
 'qa/output/A39_VERIFIED_BATTLE_RUNTIME_GPU.log',
 'qa/output/A39_GODOT_REAL_GPU_RUN_AND_RIG_IDLE.png'
]
for file in required:assert (root/file).is_file(),file
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
assert sha(root/'assets/actor01_a62_approved_idle_source_64.png')=='70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e'
assert sha(root/'assets/actor01_run_a35_8frames.png')=='ec0c7a59fb5983f13b1b3385323218edf0e77c23890db074c18c6e114e74408b'
logs=[(root/'qa/output/A39_VERIFIED_LOCAL_SHADER_GPU.log').read_text('utf-8-sig'),(root/'qa/output/A39_VERIFIED_BATTLE_RUNTIME_GPU.log').read_text('utf-8-sig')]
assert 'A39_GPU_LOCAL_BREATH_PASS' in logs[0]
assert 'A39_GPU_OUTSIDE_MASK_CHANGED=[0,0,0,0,0,0,0,0]' in logs[0]
assert 'A39_GPU_ALPHA_CHANGED=[0,0,0,0,0,0,0,0]' in logs[0]
assert 'A39_GODOT_INTEGRATED_RUNTIME_PASS' in logs[1]
assert 'A39_IDLE_RIG_TO_RUN_AND_BACK_PASS=true' in logs[1]
state={
 'stage':'A39','date':'2026-11-14',
 'technical_result':'PASS', 'art_result':'HOLD','FS_main_battle_integration':'NOT_RUN',
 'provider_calls_this_stage':0,
 'engine':'Godot 4.7.2, native real OpenGL AMD RX 6700XT',
 'source_sha256':sha(root/'assets/actor01_a62_approved_idle_source_64.png'),
 'original_run_sheet_sha256':sha(root/'assets/actor01_run_a35_8frames.png'),
 'animation':'AnimationPlayer --> ShaderMaterial chest_breath local native pixel UV sampling',
 'loop_seconds':3.2,'phase_slots':8,'unique_gpu_poses':4,
 'gpu_changed_pixels':[0,14,45,37,37,45,14,0],
 'non_torso_changed_pixels':[0]*8,
 'alpha_changed_pixels':[0]*8,
 'actual_engine_tests':['qa/a39_rig_gpu_qa.gd','qa/a39_integrated_runtime_qa.gd'],
 'run_to_idle_rig_to_run':'PASS','original_a38_profiles':'UNCHANGED',
 'actor_ground_foot_alignment':'battle preview Y=416; floor Y=479',
 'owner_only_drive':True,'original_E_FS_untouched':True,'github_main_untouched':True,
 'open_art_issues':['Chest pixel change is intentionally subtle; 4 genuine GPU poses, not 8 individually generated pictures','Further character art sign-off needed'],
 'cold_repro':'PASS, independent G: cold extract Godot editor import and both real RX6700XT GPU scripts EXIT=0'
}
(root/'qa/A39_QA_FINAL.json').write_text(json.dumps(state,ensure_ascii=False,indent=2),encoding='utf-8')
# Exclude Godot's cache/imports; include only portable source, verified art, QA, proof screenshots.
items=[]
for p in root.rglob('*'):
 if not p.is_file():continue
 rel=p.relative_to(root)
 if any(x=='.godot' for x in rel.parts):continue
 if p.suffix in ('.import','.uid'):continue
 if rel.parts[0] not in ('assets','scripts','shaders','scenes','qa') and str(rel) not in ('README.md','project.godot'):continue
 if p.name=='A39_FILE_MANIFEST_SHA256.json':continue
 items.append(p)
items.sort(key=lambda f:str(f.relative_to(root)))
manifest={str(p.relative_to(root)).replace('\\','/'):dict(bytes=p.stat().st_size,sha256=sha(p)) for p in items}
manifest_path=root/'qa/A39_FILE_MANIFEST_SHA256.json'
manifest_path.write_text(json.dumps(manifest,indent=2),encoding='utf-8')
items.append(manifest_path)
archive=private/'FS_A39_GODOT_CONTROLLED_BREATH_RIG_PRIVATE_20261114.zip'
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED,compresslevel=9) as z:
 for p in sorted(items):z.write(p,str(p.relative_to(root)).replace('\\','/'))
with zipfile.ZipFile(archive) as z:
 assert z.testzip() is None
 assert all(n in z.namelist() for n in required)
 assert len(z.namelist())==len(items)
result={'archive':archive.name,'bytes':archive.stat().st_size,'sha256':sha(archive),'files':len(items),'crc':'PASS','source_png_sha256':state['source_sha256'],'run_png_sha256':state['original_run_sheet_sha256']}
(root/'qa/A39_ARCHIVE_QA.json').write_text(json.dumps(result,indent=2),encoding='utf-8')
for k,v in result.items():print('A39_FINAL',k,v)
print('A39_FINAL_ENGINE_AND_BUNDLE_TECH_PASS=true')
