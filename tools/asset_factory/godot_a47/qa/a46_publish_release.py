from pathlib import Path
import glob,hashlib,json,zipfile
from PIL import Image
root=Path(glob.glob('G:/*/FS_AI_ASSET_FACTORY_Restricted_Binaries')[0])
p=root/'FS_A46_INTEGRATED_TORSO_ATTACK_20261115'
qa=p/'qa';a=p/'assets'
q=json.loads((qa/'A46_NATIVE_COLD_QA_RESULT.json').read_text(encoding='utf8'))
assert q['status']=='PASS' and q['gpu_pass'] and q['contact_pass']
assert q['waist_A62_exit']==0 and q['waist_A45_exit']==1 and q['waist_A46_exit']==0
assert len(list((qa/'output/a46').glob('A46_NATIVE_F??.png')))==12
old_qa=json.loads((qa/'A46_V2_COHERENT_MOTION_QA.json').read_text(encoding='utf8'))
assert old_qa['qa']=='PASS'
repro=json.loads((qa/'A46_REPRODUCTION_RESULT.json').read_text(encoding='utf8'))
assert repro['pass']=='PASS'
a62=Image.open(a/'actor01_a62_approved_idle_source_64.png')
assert a62.size==(64,64)
readme='''# Forest Symphony | A46 Integrated Torso Attack (Godot 4.7.2)

**Working art-engine sandbox, not the formal FS ATB battle migration.**

## Run now
- Open project.godot in Godot 4.7.2. F5 launches the existing interactive practice target.
- Press A: perform 12-frame 45-degree sword attack; press R: reset target HP.
- Attack contact at F6 = 0.55s; Hitstop = 70ms; dynamic sword tip F6 local (30,9).
- Layers Body, Weapon and FX remain individual 256x192 RGBA 12-frame atlases, animated by one AnimationPlayer.
- Real practice target supports knockback/flash, 25 damage, miss outside radius, serial dedupe, cancel and double speed.

## NEW A46 art correction
- A45 had visually disconnected chest/belt/legs at F06-F08 even though one connected RGBA component.
- V1 restored the waist/pelvis from user-approved A62 art with a non-flat, anatomical curved patch rather than y46-55 horizontal wipe-and-paste.
- V2 adds coordinated +-1px upper-body anticipation and followthrough while the lower pelvis, planted feet and hip stay anchored: F2-4=-1px, F6-8=+1px, others=0.
- Sword/FX/12-frame hit marker follow the hand when the shoulder moves. F6 anchor changed (29,9) -> (30,9).
- A62 top-of-face appearance is retained pixel for pixel after undoing the intended upper-body translation.
- A44/A45/initial A46-V1 retained as immutable comparisons.

## Self-check pipeline
1. python qa/a46_rebuild_verify.py (regenerate V1/V2, assert EXACT published Body/Weapon/FX SHA)
2. python qa/a46_v2_motion_qa.py (16+ constraints including shoulder-waist attachment, 12 body alpha groups, 0 wrist/weapon/tip gaps)
3. python qa/a46_waist_gate.py --candidate assets/actor01_a46_body_12frames.png --reference assets/actor01_a62_approved_idle_source_64.png
4. Godot 4.7.2 original native GPU: res://qa/a46_native_gpu_runtime_qa.gd
5. Godot original contact regression: res://qa/a46_contact_damage_native_qa.gd
6. qa/a46_cold_native.py auto stages the working Godot binary and test project on C: for cold GPU import/test, saves original logs/screenshots back on private Drive and deletes temporary files. Requires the preinstalled Godot binary at E:/Godot/4.7.2.

## Evidence
- A46_GODOT_NATIVE_SLASH_12FRAMES_4X.gif: real Godot 12x screenshot frames, NOT illustration-only GIF.
- A46_A45_VS_A46_NATIVE_12FRAMES_3X.png: A45 composite vs native A46.
- A46_V1_V2_COHERENT_LEAN_12FRAMES_3X.png: effect of torso anticipatory motion.
- qa/output/a46/A46_NATIVE_F00.png ... F11.png and A46_NATIVE_DAMAGE_CONTACT_SCENE.png.
- qa/A46_NATIVE_COLD_QA_RESULT.json, A46_V2_COHERENT_MOTION_QA.json, A46_REPRODUCTION_RESULT.json, A46_FAILURE_LOG.md.

## Formal gates
- KNOWN WAIST SEAM REGRESSION PASS (A62 good / A45 known-bad / A46 V2 good; source + native GPU).
- GODOT EDITOR IMPORT + NATIVE GPU / ATTACK CLOCK / ISOLATED DAMAGE PASS.
- ART HUMAN AESTHETIC HOLD (shoulder chest twist still stylized/subtle; limited 64px resolution).
- FULL FOREST SYMPHONY MIGRATED ATB / skills / enemy damage integration NOT RUN.
'''
(p/'README_A46.md').write_text(readme,encoding='utf8')
failure='''# FS A46 Failure Log / Preventing Repeat Mistakes (2026-11-15)

- A45 known bad: F06-F08 upper-lower torso appears horizontally cut, invisible to simple alpha-connectivity QA. New gate intentionally FAILS A45 and PASSES A62; A46 must pass both sprite source and native Godot PNG.
- A46-ART01: V1 correctly eliminated horizontal waist band, but still looked too rigid in the original Godot visual comparison. Developed V2 instead: upper body/head anticipatory -1px and contact follow-through +1px with hip/feet retained at the same world position. Weapon tip and marker move with wrist.
- A46-QA01: Initial Godot native crosscheck wrapper looked for A45_NATIVE_Fxx naming and false-failed on A46_NATIVE_Fxx. Fixed version-aware filename resolution and reran; source and native A46 now both PASS.
- A46-ENV01: Godot 4.7.2 console executable on E: stalled even with --version; this is environment startup, not art. Console wrapper is 198,152 bytes and depends on 180,858,888-byte matching GUI binary in SAME directory. Copying both to temporary C: made --version exit 0 and subsequent native Godot import/GPU/contact all PASS. Temporary copies removed.
- A46-QA02: V2 QA initially pointed to the promoted A46 main body as V1 provenance and failed after promotion; corrected to stable actor01_a46_body_v1_12frames.png and reran PASS.
- A46-REPRO: Candidate generator originally read mutable main A46 art and would compound transformations on rerun. Refactored V2 generator to read immutable V1 art, A45 weapon/FX and V1 anchors. Double regeneration SHA identical on all 3 finalized layer atlases.
- A46-LIMIT01: The waist-band palette test is a calibrated Actor01 A62-specific regression detector, not general proof of natural biomechanics. Positive PASS cannot certify all motion. Current artistic human-review gate remains HOLD.
- Formal ATB and real FS battle migration NOT RUN; do not claim an isolated damage dummy constitutes full combat integration.
- No modification to original E: RMVX source, GitHub main, unrelated map or Godot migration branches. PixelLab not used.
'''
(qa/'A46_FAILURE_LOG.md').write_text(failure,encoding='utf8')
handoff='''# Forest Symphony | A46 V2 Formal Handoff | 2026-11-15

## Original source authority
A45 final private Drive ZIP: FS_A45_ACTOR01_MOTION_SELF_AUDIT_GPU_PASS_ART_HOLD_20261115.zip
SHA256 5913dc77ed3bbb0942585c8f491a4dbd3e6fa1b56464dcb72e478eaf264dddbc.
Engine Godot 4.7.2, 45-degree 64x64 battle frame; 32x32 map baseline is unchanged.
GitHub branch feat/fs-asset-factory-v1-20261107; A42-A45 preserved.

## User-reported failure, independently confirmed before editing
A45 F6-F8 waist was visually detached after the old process removed y46-55 and separately repainted legs. Existing alpha-component and native pixel QA were misleading false passes.
Correct blocking gate: baseline A62 PASS / bad A45 F06-F08 FAIL / fixed A46 V2 12/12 PASS.
This was checked against actual A46 Godot native captures, not just the PNG generator source.

## Delivered A46 V2, not merely documentation
- Rebuilt whole waist/pelvis span from original approved A62 pixels with 16-row anatomical irregular core masking, preserving existing hand/sword animation and dynamic foot placements.
- Applied coherent spine anticipation/recovery -1px F2-4, +1px F6-8, normal F0/1/5/9/10/11. Hip and boots remain grounded. Armor/face contents preserved under translation.
- Separate Body/Weapon/FX texture atlases: assets/actor01_a46_{body,weapon,fx}_12frames.png (256x192).
- F6 wrist/blade contact re-anchored: (29,9) -> (30,9) in assets/actor01_a46_attack_anchors.json; Godot single AnimationPlayer fifth HitMarker track remains synchronized.
- Preserved original V1, A45 and A62 art and deterministic two-stage generators.
- Native Godot 12 frame screenshots, GIF, true practice-target contact screenshot and logs.
- README_A46.md gives test commands and caveats.

## Verified in real native engine
- Godot 4.7.2 editor cold import exit 0.
- Native Windows OpenGL AMD Radeon RX 6700 XT: 12/12 frames, zero mismatched RGBA after premultiplied Alpha correctness, no boundary crop, 11 distinct poses.
- 0.55s F6 hit, 70ms hitstop, A39 breathing idle recovery PASS.
- Independent practice target HP 100->75->50, miss out of range, no duplicate serial, no ghost damage on cancellation, accelerated playback PASS; F6 local (30,9).
- Source A62 waist gate exit0, known bad A45 gate exit1, new A46 gate exit0. Godot GPU 12-frame crosscheck: no failures.
- V2 waist/shoulder row41-42 alpha overlap 11px for all 12 frames; Body one connected alpha component/frame; hand and sword/marker distances zero; under-34 head pixel content exact under lean translation.
- Deterministic regeneration: all three final Body/Weapon/FX SHA256 exactly reproducible.
- New project source and test evidence in private Drive FS_A46_INTEGRATED_TORSO_ATTACK_20261115 and GitHub future path tools/asset_factory/godot_a46/.

## Quality decisions
A45 ART FAIL for known seam. A46 V2 known-waist-geometry/regression PASS; engine & isolated contact PASS.
**A46 full art still HOLD** pending final human 1x review: shoulder/chest rotation is subtle and full dynamic weight may need stronger, authored poses beyond 1px.
Formal migrated FS combat ATB/system/skill/enemy damage **NOT RUN**.
No new development in RMVX. Do not overwrite main, map or migration branches.

## Next actual creative milestone
Build one coherent anatomically coupled 45-degree character pose chain (idle/loading/accelerate/hit/recover) with more substantial shoulder rotation and arm-bone articulation. Preserve A46 V2 as technical baseline and keep the bad A45 regression in QA. Do not label all art PASS on mere image geometry tests.
'''
(p/'A46_FORMAL_HANDOFF_20261115.md').write_text(handoff,encoding='utf8')
summary={'stage':'A46','variant':'V2 coherent upper lean','Godot':'4.7.2','renderer':'AMD RX 6700 XT OpenGL',
 'art_sprite_waist_gate':'PASS','prior_A45_known_bad':'FAIL, F06/F07/F08 (correct negative)',
 'native_A46_screenshots':12,'native_gpu_pixel_diff':[0]*12,
 'native_engine_import':'PASS','native_contact_demo':'PASS','waist_gate_native':'PASS',
 'F6_hit_time_seconds':0.55,'hitstop_milliseconds':70,'F6_hit_marker_local':[30,9],
 'isolated_hp_deltas':[-25,-25],'regenerate_from_source':'PASS, three layers exact SHA',
 'true_art_aesthetic':'HOLD: shoulder/chest rotational weight still subtle',
 'formal_migrated_fs_atb':'NOT_RUN',
 'body_sha256':hashlib.sha256((a/'actor01_a46_body_12frames.png').read_bytes()).hexdigest(),
 'weapon_sha256':hashlib.sha256((a/'actor01_a46_weapon_12frames.png').read_bytes()).hexdigest(),
 'fx_sha256':hashlib.sha256((a/'actor01_a46_fx_12frames.png').read_bytes()).hexdigest(),
 'gif_sha256':hashlib.sha256((p/'A46_GODOT_NATIVE_SLASH_12FRAMES_4X.gif').read_bytes()).hexdigest()}
(qa/'A46_FINAL_QA_SUMMARY.json').write_text(json.dumps(summary,indent=2,ensure_ascii=False),encoding='utf8')
# Complete source archive, omit engine transient cache and old .import files.
name='FS_A46_GODOT_CONNECTED_TORSO_NATIVE_GPU_PASS_ART_HOLD_20261115.zip'
destination=root/name
manifest_name='A46_FULL_SHA256_MANIFEST.json'
def exclude(rel):
 return (rel.startswith('.godot/') or rel.endswith('.import') or rel.endswith('.zip')
  or rel in [manifest_name,'A46_RELEASE_META.json']
  or rel.startswith('qa/output/a45/') or rel.startswith('qa/output/a44/')
  or rel.startswith('qa/output/a43/') or rel.startswith('qa/output/A41') or rel.startswith('qa/output/A42'))
sources=sorted(f.relative_to(p).as_posix() for f in p.rglob('*') if f.is_file() and not exclude(f.relative_to(p).as_posix()))
hashes={n:hashlib.sha256((p/n).read_bytes()).hexdigest() for n in sources}
(p/manifest_name).write_text(json.dumps({'stage':'A46 V2','source_count':len(sources),'files':hashes},indent=2,ensure_ascii=False),encoding='utf8')
filelist=sources+[manifest_name]
with zipfile.ZipFile(destination,'w',zipfile.ZIP_DEFLATED) as z:
 for n in filelist:z.write(p/n,n)
with zipfile.ZipFile(destination) as z:
 assert z.testzip() is None
 assert len(z.namelist())==len(filelist)
meta={'zip_name':name,'zip_file_count':len(filelist),'zip_sha256':hashlib.sha256(destination.read_bytes()).hexdigest(),
'zip_bytes':destination.stat().st_size,'engine':'PASS','waist_known_defect':'FIXED','art':'HOLD','formal_ATB':'NOT RUN'}
(p/'A46_RELEASE_META.json').write_text(json.dumps(meta,indent=2,ensure_ascii=False),encoding='utf8')
print('A46_FINAL_RELEASE_CRC_PASS',json.dumps(meta),flush=True)
