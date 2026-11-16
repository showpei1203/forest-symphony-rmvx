# Forest Symphony A43 | Attack Art Rewrite + Native Godot GPU | 2026-11-15
## Source and scope
- Branch feat/fs-asset-factory-v1-20261107, no main changes.
- Original A42 ZIP FS_A42_GODOT_LAYERS_HITSTOP_FINAL_20261114.zip, SHA256 52a3c040387a1d0da9c617c3d257d77ab441457859b4adf40830d5181951fdca.
- Godot 4.7.2 stable Windows / AMD RX 6700 XT, OpenGL 3.3 compatibility.
- 45 degree battle art, 12x64x64 frames in 4x3 atlas; 12 fps. Old RMVX archival source untouched.

## Changed deliverables
- assets/actor01_a43_body_12frames.png: revised torso lunge and right arm poses.
- assets/actor01_a43_weapon_12frames.png: consistent steel sword, gold guard, independent layer.
- assets/actor01_a43_fx_12frames.png: tip-following swing trail, independent layer.
- assets/actor01_a43_composite_reference.png: source visual QA target.
- assets/actor01_animation_manifest.json: attack now points to A43 Body.
- scripts/fs_actor_animator.gd: revised Godot Weapon and FX loader, one clock preserved.
- qa/a43_art_rewrite.py: reproducible Python art generator.
- qa/a43_native_gpu_runtime_qa.gd: real native Godot GPU + attack timing test.
- A43_BODY_WEAPON_FX_12FRAME_BEFORE_AFTER.png, A43_BODY_WEAPON_FX_12FRAME_ZOOM3X.png, A43_BODY_WEAPON_FX_ATTACK_PREVIEW_4X.gif.
- qa/output/a43/A43_NATIVE_F00.png through A43_NATIVE_F11.png: real engine screenshots.
- qa/A43_NATIVE_GPU_RUN_LOG.txt, A43_ART_REWRITE_QA.json, qa/A43_FAILURE_LOG.md.

## Verified
- Godot import exit code 0; native Godot v4.7.2.stable.official.ed1daf0bf.
- GPU renderer AMD Radeon RX 6700 XT OpenGL 3.3 Compatibility, real non-headless run.
- All 12 native GPU frames vs A43 image source: corrected alpha comparison 0 pixel mismatches each; alpha exact, RGB premultiplied rounding max +/-1.
- 12x no border crop, 11 unique poses, 12 native PNG screenshots saved.
- All 12 body frames preserve original A62 head y=0..33 (exact pixel equal).
- Attack hit F6 at t=0.55 seconds, 70ms hitstop, returns to A39 breathing; weapon and FX invisible after attack.
- A42 source body/weapon/FX still intact.

## Decision gates
ASSET PRODUCTION PASS; GODOT IMPORT PASS; NATIVE GPU/ATTACK EVENT PASS.
HUMAN ART APPROVAL HOLD; FORMAL FS ATB/DAMAGE BATTLE INTEGRATION NOT RUN.

## Next
Evaluate new-vs-old frame strip at 1x and 3x, refine anatomy and weight if needed. Once human art accepted, integrate into main migrated FS combat scene. Never claim battle system integration from the standalone art QA.
