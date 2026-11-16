"""Seal independently runnable A38 Godot project and PixelLab provider evidence to owner-only G: Drive."""
from pathlib import Path
from PIL import Image
from hashlib import sha256
import zipfile, json

project = Path(__file__).resolve().parent.parent
private_root = project.parent
pilot = private_root / 'FS_A38_GODOT_IDLE_ANIMATION_PILOT_20261114'
assets = project / 'assets'
output = project / 'qa' / 'output'
assert private_root.name == 'FS_AI_ASSET_FACTORY_Restricted_Binaries'
expected_sha = {
    'actor01_run_a35_8frames.png': 'ec0c7a59fb5983f13b1b3385323218edf0e77c23890db074c18c6e114e74408b',
    'actor01_idle_r1_raw_8phases.png': 'ba8d0db8bc78017ecb465788665325a058d613e92044024e33a68ded19293502',
    'actor01_idle_r2_raw_8phases.png': 'b986b4b8aa7a0d20c5812fc8fe14d3c5cb551523c6b0d01002bf4c4db6a1f4e2',
    'actor01_idle_r1_calm_curated_8phases.png': '25859b73282ea2f928b7fbca7ed60a3e46e5996a75f979525e5b6b51ff6eae31',
}
for name, value in expected_sha.items():
    f = assets/name
    assert f.is_file() and sha256(f.read_bytes()).hexdigest() == value, 'bad source: '+name
    im = Image.open(f).convert('RGBA')
    assert im.size == (256,128)
    assert set(im.getchannel('A').getdata()) <= {0,255}

def frames_for(name):
    im=Image.open(assets/name).convert('RGBA')
    return [im.crop(((i%4)*64,(i//4)*64,(i%4+1)*64,(i//4+1)*64)) for i in range(8)]

unique_count={name:len({f.tobytes() for f in frames_for(name)}) for name in expected_sha}
assert unique_count['actor01_run_a35_8frames.png']==8
assert unique_count['actor01_idle_r1_raw_8phases.png']==5
assert unique_count['actor01_idle_r2_raw_8phases.png']==5
assert unique_count['actor01_idle_r1_calm_curated_8phases.png']==3
assert frames_for('actor01_idle_r1_calm_curated_8phases.png')[0].tobytes()==frames_for('actor01_idle_r1_calm_curated_8phases.png')[-1].tobytes()

native_orig={
    'r1_png':'c38c6cfd6f1690c73136c67cf4e106b3f75a427fecacdc06332cf4611dd37022',
    'r1_gif':'95e76d457f940364af7f5678249a5ea39faae2480309ffa5f1b62e36a56ce87d',
    'r2_png':'18642325ee867b481ef9d450219aab4a21c545bcb3b43d2fabb09dd73f054be5',
    'r2_gif':'15dcc32fd27d0a2defd958ccd64e009804fe32e81addd3938d921d79af5bfe30',
}
source_paths={
    'r1_png':pilot/'provider'/'A38_PIXELLAB_ORIGINAL_3X2_SHEET.png',
    'r1_gif':pilot/'provider'/'A38_PIXELLAB_ORIGINAL_5FRAME.gif',
    'r2_png':pilot/'provider_r2'/'A38_R2_PIXELLAB_ORIGINAL_3X2_SHEET.png',
    'r2_gif':pilot/'provider_r2'/'A38_R2_PIXELLAB_ORIGINAL_5FRAME.gif',
}
for key, p in source_paths.items():
    assert sha256(p.read_bytes()).hexdigest()==native_orig[key], 'provider original failed '+key

for file in ['A38_GODOT_RUNTIME_VERIFIED.log','A38_GODOT_GPU_FRAMES_VERIFIED.log',
             'A38_GODOT_REAL_GPU_RUN_AND_IDLE.png',
             'A38_GODOT_GPU_IDLE_RAW_EIGHT_FRAMES.png',
             'A38_GODOT_GPU_IDLE_R2_EIGHT_FRAMES.png',
             'A38_GODOT_GPU_IDLE_CALM_EIGHT_FRAMES.png']:
    assert (output/file).is_file() and (output/file).stat().st_size>0, 'QA evidence missing '+file
assert 'A38_GODOT_RUNTIME_PASS' in (output/'A38_GODOT_RUNTIME_VERIFIED.log').read_text('utf-8-sig')
assert 'A38_IDLE_GPU_CAPTURE_PASS' in (output/'A38_GODOT_GPU_FRAMES_VERIFIED.log').read_text('utf-8-sig')
manifest=json.loads((assets/'actor01_animation_manifest.json').read_text('utf-8'))
assert manifest['schema_version']==2
assert set(manifest['animation_profiles'])=={'run_raw','run_tuned','idle_raw','idle_r2','idle_calm'}
qa={
 'stage':'A38', 'date':'2026-11-14',
 'godot_editor_import':'PASS', 'gpu_renderer':'AMD Radeon RX 6700 XT (OpenGL 3.3)',
 'runtime_motion_profiles':list(manifest['animation_profiles']),
 'godot_runtime':'PASS (21 observed idle frame_changed; 2 loop wraps; 5 profiles; reject attack)',
 'gpu_frame_capture':'PASS (3 x 8 actual framebuffer snapshots; uniqueness hashes diagnostic only, not distinct sprites)',
 'provider_calls':2, 'provider':'PixelLab Creator Interpolate V3',
 'r1_real_generated_frames':5,'r2_real_generated_frames':5,
 'eight_phase_loops':True,
 'original_unique_frames':unique_count,
 'r1_first_source_RGBA_diff':0,'r1_end_A23_mechanical_RGBA_diff':16,
 'r1_head_diff_px':[0,309,327,54,234],
 'r2_first_source_RGBA_diff':0,'r2_end_R1_G3_RGBA_diff':17,
 'r2_head_diff_px':[0,243,329,281,56],
 'curated_selection_from_R1_original':[0,0,3,3,4,4,3,0],
 'curated_distinct_source_poses':3,
 'curated_art_status':'HOLD: reduced broad arm motion but possible sprite bob/hand inconsistency',
 'r1_art_status':'FAIL: G1/G2 face and arm drift',
 'r2_art_status':'FAIL: G1/G2/G3 face drift and stepping despite still-feet prompt',
 'battle_system_integration':'NOT_RUN: isolated Godot actor pilot, not migrated FS full combat',
 'formal_art_approved':False,
 'rmvx_three_frames':'NOT_REQUIRED per user Godot-first direction',
 'original_e_drive_files_changed':False,
 'github_main_changed':False,
 'pc_temp_cleaned':True,
 'sha256_art_assets':expected_sha,
 'sha256_provider_originals':native_orig,
}
(project/'qa'/'A38_QA_FINAL.json').write_text(json.dumps(qa,indent=2,ensure_ascii=False),encoding='utf-8')
(project/'qa'/'A38_FAILURE_LOG.md').write_text('''# A38 Failure Log and resolution\n\n- **R1 model art FAIL:** API model generated 5 actual frames; F1/F2 had excessive arm/head motion. Do not call it a natural breathing loop. F0 exact; end vs A23 mechanical 16 px different.\n- **R2 model art FAIL:** two closer endpoints did not fix the naturalness problem: middle frames still moved arms, legs and face. R2 was a separate 1-generation attempt, not a free retry.\n- **Calm selection ART HOLD:** selected existing R1 G0/G3/G4 without generating or modifying pixels. 8 playback slots contain only 3 unique poses; reverse motion is intentional symmetric breathing. Do not call them eight newly generated frames.\n- **GPU evidence caution:** test script hashes can differ for duplicate frames due rendering timing. Hash count is a GPU-frame diagnostic, not count of unique source poses. Source PNG exact byte comparisons are authoritative.\n- **A37 RUN art HOLD unchanged:** A35 F6 stride and F7 glove defects remain. Godot runtime PASS never means aesthetic acceptance.\n- **A39 priority:** pose-controlled 48px IDLE art with fixed hands/feet; consider breathing AnimationPlayer upper-body rig rather than unconstrained full-frame image prompts. Then Attack/Cast/Hurt/Death and FS battle migration.\n- All binaries on private Drive, no new user PC local work files, no main overwrite.\n''',encoding='utf-8')

# Reproducible owner-only archives. The .godot editor cache is excluded from source package.
archives={
  private_root/'FS_A38_PIXELLAB_IDLE_R1_R2_PRIVATE_20261114.zip':pilot,
  private_root/'FS_A38_GODOT_RUN_IDLE_NATIVE_PRIVATE_20261114.zip':project,
}
for archive, folder in archives.items():
    with zipfile.ZipFile(archive,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=9) as z:
        for p in sorted(folder.rglob('*')):
            if not p.is_file() or '.godot' in p.relative_to(folder).parts or p==archive:
                continue
            z.write(p,p.relative_to(folder))
    with zipfile.ZipFile(archive) as z:
        crc=z.testzip()
        assert crc is None, 'ZIP CRC FAILURE '+str(crc)
        count=len(z.namelist())
    print('A38_ARCHIVE',archive.name,'BYTES',archive.stat().st_size,'SHA256',sha256(archive.read_bytes()).hexdigest(),'FILES',count,'CRC',crc)
print('A38_GODOT_SOURCE_SHA',expected_sha['actor01_run_a35_8frames.png'])
print('A38_QA_PASS_ENGINE_ART_HOLD')
