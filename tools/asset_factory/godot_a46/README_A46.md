# Forest Symphony | A46 Integrated Torso Attack (Godot 4.7.2)

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
