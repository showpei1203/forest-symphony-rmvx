# Forest Symphony A48 | Canonical Body + Connected Sword Arm
**Godot 4.7.2 real runtime demo.** 45-degree southeast Actor01, 64x64 frames x12, 3 separate Body/Weapon/FX atlases.

## What's different, and why
A47 R3 displayed broken-looking head/neck, shoulder and torso segments despite passing its coarse alpha-connectivity QA. A48 is a genuine replacement Body atlas, not only a test script. It starts from the SAME complete approved A62 character body in EVERY frame, does **not deform face/hair/waist/pelvis/legs/offhand**, and redraws only the sword arm as a continuous 3-joint shoulder -> elbow -> wrist sleeve. Original A62 outline, palette and boots are retained exactly; arm has a dark connected silhouette, teal sleeve, gold pauldron and gloved wrist that follows the original weapon trajectory. Head-on-front sprite occlusion and fixed pelvis/boot region are explicitly enforced after drawing. A48 F0 and F11 are pixel-identical canonical A62 idle.

## Play
Open project.godot in Godot 4.7.2; F5 runs isolated battle practice target. A = attack; R = reset HP. One AnimationPlayer controls 12 frames Body/Weapon/FX/HitMarker, F6 at 0.55s, 70ms hitstop. Target HP -25 per real in-range contact; cancel/double-speed/miss/dedupe regression tests available.
This is NOT the formal migrated FS ATB/skills/enemy combat.

## Reproducible sources / QA
- python qa/a48_connected_arm_generator.py
- python qa/a48_joint_connectivity_qa.py
- python qa/a48_anatomical_bone_qa.py
- qa/a48_cold_native.py for real Godot 4.7.2 OpenGL AMD GPU and isolated target regression.
- A48_A47_VS_A48_GODOT_1X.png / _3X.png and actual Godot-native GIFs.
- qa/A48_CONNECTION_QA.json, qa/A48_ANATOMICAL_BONE_COVERAGE_QA.json and qa/A48_NATIVE_COLD_QA_RESULT.json.
- PROMPT_A48_SHOULDER_ELBOW_WRIST_CONNECTED.md for the next 18-joint provider/pixel artist task.

## Gates and limitations
Native GPU 12/12 exact 0 pixel mismatch, 11 poses, hit 0.55s, hitstop 70ms and independent dummy damage PASS. Head 12/12, hips/feet 12/12 and offhand exact A62; shoulder/elbow/wrist 10/10, min 5x5 arm coverage 16 opaque pixels. A47 known deformed head/legs fails the new identity-preservation negative test. A45 known waist-failure still fails historical waist gate while A48 passes.
**A48 structural art PASS, final ART aesthetic HOLD**: limited chest rotation, arm motion still pixel-simple. Do not claim the complete 18-joint system or PixelLab rendering was implemented. No paid PixelLab call. Formal migrated FS battle ATB NOT RUN.
