# A16 R2 Final QA & Visual Rejection Audit (2026-10-31)
STATUS: ENGINE TOOLCHAIN PASS, ART G7 FAIL. FS original sealed assets untouched.

- A15 source private ZIP SHA256 rechecked: ebe074d87cc242bbeab5d4e3061a5db0333a6db2bff2abac6c60f870aa5956b5 / expected ebe074d87cc242bbeab5d4e3061a5db0333a6db2bff2abac6c60f870aa5956b5; preserved = True
- New 96px RGBA keyframes: 4, separate from A15 and ASF original sheets.
- T1 attack_02: 56 changed RGBA pixels; alpha changes 19
- T1 attack_05: 67 changed RGBA pixels; alpha changes 9
- T2 attack_03: 156 changed RGBA pixels; alpha changes 82
- T2 attack_05: 201 changed RGBA pixels; alpha changes 73
- Identity/delta ROI: all head/antler-protected regions zero changed pixels; outside permitted joint-correction ROIs zero changes = True
- LibreSprite native .ase generated with actual installed Windows app; .ase -> PNG gives 4/4 full RGBA pixel parity, diff 0 = True
- These are separate, editable single-frame native .ase files, NOT a full native animation project with layers.
- R0 rejected for chunky hooves. R1 rejected for source-frame identity drift (551 changed face-ROI pixels on T1 frame 05), plus stick-legged monster.
- R2 source-identity bug FIXED and limb-size reduced, but visual FAIL: T1 elbow/fist remains stiff, T2 leg texture/hoof clusters lack convincing weight/motion; protruding rear-leg outlines.
- To progress: animate through *art-directable* redraw of silhouettes and volume, not further rigid geometry scripts. Source-pinned per-pose redraw with pixel palette, 1x/3x visible approval, no altered face/moss antlers; then 8-frame motion, ASF, Godot and VX.
- A16 R2 G7 = FAIL; A16 G5/G6/G8 not run, no replacement of sealed FS/VX files.
- Private PNG, native .ase, code, QA and magnified previews stored only on authorized Windows computer; GitHub/Drive synchronize text scripts and QA, not licensed/private images.
