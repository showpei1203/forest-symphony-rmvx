# Forest Symphony Stage16 A33 — real Ground material reference style rework, dual-engine benchmark
2026-11-01 Asia/Taipei. A32B approved by user. **A33 R5 ENGINEERING PASS / ART USER REVIEW PENDING / FORMAL SEAL NO.**

## Reading order
1. `authority/FS_GROUND_PAR_SOURCE_FIRST_PRODUCTION_V1_20261101.md`
2. `authority/FS_NATIVE_VX_DYNAMIC_PAR_OCCLUSION_PASSAGE_V1_20261101.md`
3. `authority/FS_PAR_LEAF_STRUCTURE_VISUAL_QA_V1_20261101.md`
4. `authority/FS_GROUND3_TRUE_REFERENCE_AND_MATERIAL_EDGE_RULES_V1_20261101.md`
5. This detailed A33 handoff + A33 failure register + A33 actual QA files
6. A32B accepted current baseline and earlier A29 scene/source manifests.

## User-approved input locks
User 2026-11-01: 「好，這次給過，繼續推進。」 explicitly accepts A32B two upper tree foliage art. Original A27/Ground A32B path remains immutable: PNG 544×416 SHA256 `35c454c82d4f32906de39702a8463ca72316b14e157239604c18971bd67d00ce`. A32B transparent `Par50.png` SHA256 `24912a82622043c6c0b25b434a0a49585bb5cc470c4c83222a7db2d187de45fb`; 12 independent original PAR RGBA sprites, approved trees, x/y/foot and native E-layer collisions, RGSS2 map/data/scripts, SHADOW/LIGHT roles unchanged.

## Corrected style source
Prior audit mistakenly used `Overlays/ground3.png`, dark light/shadow image. Correct native FS Ground3 art is `Graphics/Parallaxes/ground3.png`, 1280×928 RGB SHA256 `ddc1f21e1d23dcb8258a20baa2acb106d1c0e56683a4dc280faedc23bcd47a13`. Material-only pixels taken from previously extracted original reference `A10_GROUND3_GRASS_SOURCE_64.png` 64×64 and `A06_GROUND3_SAND_MATERIAL_REF_48.png` 48×48, not the flattened large scene. No new PixelLab API generation in A33; deterministic source-first retexturing.

## Correct A33 Ground process
A27 35-RGB-color original has flat green patches and coarse blocky sand transitions. Source sand mask extracted using RGB material class. 3×3 semantic ModeFilter repaired **1,568 road-mask positions** out of 226,304 total pixels (road sand cells 37,874→38,256), original paths remained in same positions and shape. Preserve **1,885 original bright flora pixel positions** and nearby **7,005 dark ground-attached grass-tuft pixels**, no PAR pixels on Ground. Actual authentic source material sampling at 1x, no bilinear.
Rejected R1–R3 patched quilting with square-grid checkerboard seams. R4/R5/R6 mirrored original grass/sand source patterns remove those grid seams; `A33_GROUND_R5_SEAMLESS_FLORA_544x416.png` chosen for native-engine candidate with source flower/tuft retention.
New A33 R5 Ground SHA256 `ec06a5c01d292beba7dbb042be844dc95b59e5e127f293767d7ea86c11d287c0`. Original A27 file stays SHA-locked in original A32B source project; new Ground lives ONLY in A33 isolation, not silent overwrite. New R5 green brightness/reference texture not yet user accepted; mirrored pattern repeat may require future iteration.

## Actual isolated native RPG Maker VX proof
- Isolated Map50 clone: `E:\FS_STAGE16_A33_GROUND_R5_NATIVE_VX_20261101`.
- Actual `Game.exe` RGSS Player display 544×416. 12 scenarios / 24 actual HWND hidden/actor PNGs, 0 error modal. Source actor 627 opaque pixels: full east crown occlusion 0 changed, west partial 351, east partial 357, actor full front 627. Native blocked tree move (2,4)→(2,4); legal road (8,6)→(9,6). The source A32B Par50 SHA unchanged. Collision E tile 12 blocker/209 legal untouched.
- Native screen comparison `A33_REAL_NATIVE_VX_GROUND_BEFORE_AFTER_MOBILE_544W.png` includes real before A32B/after A33 native shots and 4 material-edge crop pairs. Ground-only 4-way `A33_R4_R6_SEAMLESS_SCENE_4WAY.png` and material closeups show actual layered composite.

## Actual fresh Godot GPU proof
New distinct Godot project `E:\FS_STAGE16_A33_GROUND_VISUAL_REWORK_20261101\GODOT_A33_GROUND_R5_ISOLATED`, copies R5 Ground and EXACT twelve approved A32B PAR sprites (new manifest with source SHA). Godot 4.7.2 OpenGL compatibility on AMD RX 6700 XT rendered **8 actual GPU-native scenes** from `a33_godot_native_render.gd`. No-actor true Godot image vs independently recomposed PIL Ground+PAR: 2,971 RGB coordinates differ but **max single channel difference1**, zero >1. Thus `PASS_WITH_RGB_TOLERANCE_1`, NOT exact zero. Previous `--headless` process hung awaiting frame_post_draw, discarded; GUI OpenGL rerun genuinely completed and wrote 8 frames.

## Cold independent rebuild
Fresh `E:\FS_STAGE16_A33_GROUND_R5_VX_COLD_20261101`: 3,395/3,395 file-by-file SHA256 identical to new isolated VX clone, actual native cold `Game.exe` enters Map50 and loads 12 sprites with zero modal, real native 544×416 screenshot. Does **not** prove 24/24 cold-frame identical SHA and does **not** exercise original sealed production battle regression harness.

## Gates
A32B approved PAR frozen PASS; source Ground original lock PASS; new A33 independent R5 Ground and real overlay layering PASS; native VX 12/12 cases PASS; cold 3,395/3,395 PASS; Godot 8/8 actual OpenGL native render PASS_WITH_TOLERANCE_1; lossless/material mask + bright flora coordinate QA PASS. Art Ground3 fidelity **PENDING user visual review**; true large Ground3-sized village production, lighting layer rendering, original sealed production RPGMaker VX battle compatibility, licenses, full cold screenshot parity **NOT PASSED**. Formal Seal NO.

## Next
User review A33 R5 before promoting art. If repetitive mirrored ground grass, flower sparseness or overall brightness disagree with Ground3 target, iterate A33 with original reference patches at pixel scale and no grid/soft transition, while holding A32B approved assets unchanged. Once candidate art approved, proceed larger real village-sized Ground and independent SHADOW/LIGHT layers, not prematurely. Private Drive source sprites only.
