# ASF A16 R3 Native 8-frame Editor (2026-10-31)
## Status
Tooling PASS. Human artwork G7 remains FAIL. No ASF/Godot/VX gate rerun; no FS sealed file touched.
## Reproducible facts
A15 636-file private baseline archive SHA256 ebe074d87cc242bbeab5d4e3061a5db0333a6db2bff2abac6c60f870aa5956b5 matched on disk; 16 source attack PNG raw bytes match ZIP entries.
Two native LibreSprite .ase projects, each **8 frames / 3 layers / 18 cels**. Layer 0 A15_REFERENCE_HIDE, Layer 1 A16_R2_EDITABLE, Layer 2 JOINT_GUIDE_HIDE.
8-frame visible PNG sheet and separately exported hidden A15 reference layer pixel differences 0 for BOTH characters, actually exported using LibreSprite 1.3.
One-pixel smoke test using native LibreSprite JavaScript API changed exactly 1 RGBA pixel in copy of T1 frame_02 at (1,1); source .ase unchanged. Color (255,0,255,255). Test copy is excluded from private package.
T1 *only two art-edited frames* attack_02/05; T2 *only two art-edited frames* attack_03/05. Other six in each remain A15. Never represent these as 16 new art frames.
Image generation route TESTED TWICE and REJECTED: output was infographics with wrong human/animal identity and unsourced QA badges, not reusable 96px transparent sprites. Generated images are not production assets.
Remaining artistic blocker: T1 rigid shoulder/hand and disconnected sword grip; T2 rear-leg protrusion, artificial knee/hoof shapes, poor weight transfer. Next is pixel artist corrective paint on the native key cels, no further coordinate-based action reconstruction.
Tooling gate is separate from artistic G7, which fails until actual human visual review. Do not expand to ASF or overwrite official game sprites.
## Private package
Located E:\GameAssetToolLab_20261023\ASF_Test_20261031\A16_KEYPOSE_REDRAW\A16_R3_EDITABLE_8FRAME
