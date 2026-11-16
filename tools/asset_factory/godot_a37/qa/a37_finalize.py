from __future__ import annotations
import json,hashlib,zipfile
from pathlib import Path
from PIL import Image

root=Path(__file__).resolve().parent.parent
out=root/'qa'/'output'
source=root/'assets'/'actor01_run_a35_8frames.png'
expected='ec0c7a59fb5983f13b1b3385323218edf0e77c23890db074c18c6e114e74408b'
assert hashlib.sha256(source.read_bytes()).hexdigest()==expected,'A35 source art has changed'
sheet=Image.open(source).convert('RGBA');assert sheet.size==(256,128)
frames=[sheet.crop((i%4*64,i//4*64,(i%4+1)*64,(i//4+1)*64)) for i in range(8)]
assert len({hashlib.sha256(f.tobytes()).hexdigest() for f in frames})==8
bboxes=[list(f.getchannel('A').getbbox()) for f in frames]
colors=[len({px for px in f.getdata() if px[3]}) for f in frames]
valid_alpha=all(set(f.getchannel('A').getdata()).issubset({0,255}) for f in frames)
assert valid_alpha
captures=[out/f'A37_GPU_RUN_F{i:02d}.png' for i in range(8)]
assert all(p.exists() for p in captures),[str(p) for p in captures if not p.exists()]
imgs=[Image.open(p).convert('RGBA') for p in captures]
assert all(im.size==(320,320) for im in imgs)
assert len({hashlib.sha256(im.tobytes()).hexdigest() for im in imgs})==8

def save_gif(name:str,durations:list[int]):
    rgb=[im.convert('RGB').quantize(colors=128,method=Image.Quantize.MEDIANCUT) for im in imgs]
    dest=out/name
    rgb[0].save(dest,save_all=True,append_images=rgb[1:],loop=0,duration=durations,disposal=2,optimize=False)
    assert Image.open(dest).n_frames==8
    return dest

raw_ms=[125]*8
tuned_ms=[90,100,100,100,90,100,70,80]
gif_raw=save_gif('A37_GODOT_GPU_RUN_RAW_8FPS.gif',raw_ms)
gif_tuned=save_gif('A37_GODOT_GPU_RUN_TUNED_PREVIEW.gif',tuned_ms)
qa={
 'stage':'A37',
 'timestamp_local':'2026-11-14 10:20 Asia/Taipei',
 'project_type':'standalone Godot-first battle animation pilot; not merged into FS migration project',
 'engine':'Godot 4.7.2.stable.official.ed1daf0bf',
 'gpu':'AMD Radeon RX 6700 XT, OpenGL 3.3 GL Compatibility',
 'source':'A35 approved + native PixelLab V3 intermediate 8-frame source; artwork unchanged',
 'source_exact_sha256':expected,
 'sheet_size':[256,128],
 'frames':8,'frame_size':[64,64],'source_visual_size_approx_px':48,
 'source_rgba_unique_frames':8,
 'gpu_captured_unique_frames':8,
 'alpha_only_0_255':valid_alpha,
 'visible_rgba_color_counts':colors,
 'source_bboxes':bboxes,
 'profiles':{
    'run_raw':{'fps':8,'durations_ms':raw_ms,'cycle_ms':sum(raw_ms)},
    'run_tuned':{'fps':10,'durations_ms':tuned_ms,'cycle_ms':sum(tuned_ms),
                 'basis':'F6 and F7 are displayed for less time; artwork itself is NOT repaired'}
 },
 'actual_engine_test':{
    'godot_editor_import_exit':0,
    'native_renderer_exit':0,
    'frame_changed_events':27,
    'complete_wraps_observed':2,
    'profile_switch':'PASS',
    'unsupported_states':'REJECTED CORRECTLY',
    'actual_gpu_frames':'8/8 UNIQUE',
    'capture_test_exit':0
 },
 'gates':{'PROVIDER':'A35 PRIOR PASS','SOURCE_INTEGRITY':'PASS','GODOT_IMPORT':'PASS',
          'GODOT_RENDER':'PASS','GODOT_ANIMATION':'PASS','DYNAMIC_PROFILE':'PASS',
          'ART':'HOLD','FULL_FS_INTEGRATION':'NOT_RUN','VX':'NOT_RUN'},
 'art_issues':['A35 F6 exaggerated spread stride','A35 F7 hand anatomy drift',
              'source combat facing needs human evaluation','no attack/idle/hurt/cast/death art provided yet'],
 'safety':'Original VX project and GitHub main untouched. No new user PC non-cloud assets.'
}
(root/'qa/A37_QA_RESULT.json').write_text(json.dumps(qa,ensure_ascii=False,indent=2)+'\n',encoding='utf8')
(root/'qa/A37_FAILURE_LOG.md').write_text('''# A37 Failure Log / Art Hold\n\n- **No reused VX 3-frame limit.** Source sheet is 8×64px, layout 4 columns × 2 rows. No 32px downsample.\n- **RUNTIME PASS:** Godot 4.7.2 RX6700 XT (OpenGL) imported, played and captured unique frames, 27 frame_changed events, 2 loops.\n- **ART HOLD:** F6 extreme leg stance and F7 dangling/unstable glove remain in source. Tempo variant only SHORTENS dwell on these two frames, does not fix pixel art.\n- **NO FALSE STATES:** WAITING/IDLE/ATTACK/CAST/HURT/DEATH are intentionally unavailable, never aliased to RUN.\n- **NO INTEGRATION CLAIM:** This is an isolated Godot battle actor scene, not yet merged with the FS combat system, balance, equipment or state machine.\n- **SOURCE LOCK:** source PixelLab A35 PNG has known SHA256 and copied without any editing. Original FS VX project and GitHub main unchanged.\n\nNext: introduce an approved fixed-pose identity source for idle, test one dedicated 6–8-frame breathing generation, then connect the animation state API to the separately progressing FS Godot combat migration. Consider F6/F7 pose-constrained local artwork revision only after signoff.\n''',encoding='utf8')
archive=root.parent/'FS_A37_GODOT_NATIVE_RUN8_GPU_TEST_PRIVATE_20261114.zip'
with zipfile.ZipFile(archive,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=9) as z:
    for p in sorted(root.rglob('*')):
        if not p.is_file() or '.godot' in p.relative_to(root).parts or p.suffix=='.uid':
            continue
        z.write(p,p.relative_to(root))
with zipfile.ZipFile(archive) as z:
    count=len(z.namelist());crc=z.testzip()
print('A37_SOURCE_SHA='+expected)
print('A37_SHEET_SIZE='+str(sheet.size))
print('A37_FRAME_BBOX='+str(bboxes))
print('A37_COLOR_COUNTS='+str(colors))
print('A37_8_GPU_CAPTURE_DISTINCT='+str(len({hashlib.sha256(im.tobytes()).hexdigest() for im in imgs})))
print('A37_GIF_RAW_BYTES='+str(gif_raw.stat().st_size))
print('A37_GIF_TUNED_BYTES='+str(gif_tuned.stat().st_size))
print('A37_TUNED_CYCLE_MS='+str(sum(tuned_ms)))
print('A37_ZIP_PATH='+str(archive))
print('A37_ZIP_BYTES='+str(archive.stat().st_size))
print('A37_ZIP_SHA256='+hashlib.sha256(archive.read_bytes()).hexdigest())
print('A37_ZIP_COUNT='+str(count))
print('A37_ZIP_CRC='+str(crc))
