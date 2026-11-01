# Forest Symphony A33C — REAL Ground revision, dark stripes removed + macro grass habitat
Date 2026-11-01 Asia/Taipei. **A33C R13 engineering PASS; visual user approval PENDING; Formal Seal NO.**

## Authority
1. `authority/FS_GROUND_PAR_SOURCE_FIRST_PRODUCTION_V1_20261101.md`
2. `authority/FS_GROUND3_TRUE_REFERENCE_AND_MATERIAL_EDGE_RULES_V1_20261101.md`
3. `authority/FS_GROUND_TERRAIN_NONPERIODIC_VISUAL_QA_V1_20261101.md`
4. **NEW** `authority/FS_GROUND_BLACK_STREAKS_ECOLOGY_FAIL_CLOSED_V1_20261101.md`
5. This A33C Handoff and new Failure Register, A33B prior baseline, accepted A32B user visual pass.

## User instruction and actual root-cause correction
User requested **remove black curves + rebuild large vegetative communities + reduce repetition** and later explicitly criticized an unproductive only-verbal answer. Actual R8 Ground inspected, pixel mask made. Dark green repeated stripe artifacts from grass tile material rather than real relief were highlighted in `A33C_DARK_LINE_DIAGNOSTIC_ORIGINAL_HIGHLIGHT_2X.png`. No new relief/cliff created. Ground3 auth art is `Graphics/Parallaxes/ground3.png`, 1280x928; NOT `Overlays/ground3.png` shadow resource.

## Genuine source files
A27 immutable original Ground 544x416 SHA `35c454c82d4f32906de39702a8463ca72316b14e157239604c18971bd67d00ce`.
A33B R8 source Ground SHA `dba346a620a15d7ddd9995273bac55c977c5e179c0bbcb8f9f986dd23e1c84fe`.
**New A33C R13 true Ground** `A33C_R13_MACRO_MEADOW_GROUND_544x416.png`, SHA `d76bd016017fd6adcd4f767f2972fb2dc3f97e1f26d11b36cef2cc280e9b4043`.
A32B user-approved transparent PAR50 SHA `24912a82622043c6c0b25b434a0a49585bb5cc470c4c83222a7db2d187de45fb`, exact unchanged, including upper left/east tree leaf art and all ten lower objects.
All original 12 RGBA object PNGs, x/y foot/collision map E layer, original 17x13 Map050 rvdata, isolated RGSS scripts, SHADOW and LIGHT responsibilities unchanged. Exactly one edited file in isolated native clone vs A33B: `Overlays/ground50.png`.

## A33C real material edits
Source R8 repeated blackish grass bands identified by `R<105,G<124,G>1.12R,B<46 AND nonroad`: 8,084 problematic native pixels in grass. Replacement selectively via **local 7x7 median ONLY for flagged pixels**, with RGB floor cleanup for rare remaining dark values. Original road color pixels pixel-exact (no road erosion); original bright flower 1,885 source pixel RGB restored. Detector class reduced 8,084 → **0** in R13. This metric is not absolute guarantee of every possible dark curve, so inspect the real image.
R10 cleaning-only ablation (no plant community), R11/R12 low-density habitat trial did not materially change structure at 1x, R13/R14 macro construction uses 11 physically located irregular grass habitat masks, source-native pixel-level species tone variation, no blurred shadow, no fake altitude contour. Selected **R13**: 41,200 mapped habitat pixel positions, 176 grouped clump centers, 1,365 pointed native grass leaf strokes. R14 dense alternative 1,549 strokes unapproved.
Compare originals via 4-way true Ground+PAR images, R8/R13/R14 scene contact, 3-region native zoom, dark RGB detector mask.

## Real native RPG Maker VX
Working dir `E:\FS_STAGE16_A33C_GROUND_COMMUNITIES_20261101`. Native independent clone `E:\FS_STAGE16_A33C_R13_GROUND_VX_NATIVE_20261101` from A33B R8. **3,395 input files**, only new Ground changed.
Actual original `Game.exe` RGSS Player 544×416. 12 distinct actor positions, **24 screenshots** with source show hidden/actor; 0 RGSS modal, Map50 enters with 12 independent PAR objects.
Real 32×32 avatar ROI: full behind east upper canopy = **0/627** visible; partial west 351/627; partial east 357/627; front both 627. Native block tree root (2,4)→(2,4), road legal (8,6)→(9,6).
**Not all entire 24 hidden/actor screenshots are identical except character:** early title “米亞” transparency animation fades asynchronously and shifts whole-frame RGB. ROI tests remain precise. Use case05 no-actor real VX screenshots for user mobile comparison (544px wide), titles gone.

## Real Godot
Independent Godot copy `E:\FS_STAGE16_A33C_GROUND_COMMUNITIES_20261101\GODOT_A33C_R13_GROUND_ISOLATED`, source A32B approved 12 original sprites SHA verified. Godot 4.7.2 AMD RX 6700 XT OpenGL actual **8 GPU-native frames**. No-actor native output vs standalone Pillow true original A32B PAR50 + new A33C R13 Ground: **2,938 pixel positions differ max 1 RGB channel unit, zero >1**. State `PASS_WITH_RGB_TOLERANCE_1` not exact perfect 0.

## Cold copy / production limits
Independent VX cold clone `E:\FS_STAGE16_A33C_R13_GROUND_VX_COLD_20261101`: **3,395/3,395 original files match SHA256 exactly**, actual cold Game.exe entered map50 loaded 12 objects, 0 modal and native 544×416 screenshot. Not deterministic 24/24 complete frame hash verification. Legacy BattleRegression alias script remains test-only bypass from A30; full sealed VX production startup regression remains pending.
Art user review is **PENDING** and formal seal **NO** despite real engineering PASS. Larger 1280x928 Ground3-scale village style target, fully developed natural ecological biodiversity, and separate SHADOW/LIGHT production rendering remain future work.

## Reproduce and deliver
Private working source `E:\FS_STAGE16_A33C_GROUND_COMMUNITIES_20261101`.
- `a33c_black_curve_source_audit.py`, `a33c_remove_curves_rebuild_colonies.py`, `a33c_macro_habitat_upgrade.py`.
- `A33C_R13_MACRO_MEADOW_GROUND_544x416.png`, actual original Ground/12 PAR separated.
- `A33C_R8_VS_R13_ACTUAL_VX_MOBILE_544W.png` 544x3128 with no title fade comparison, 4 regions at 2x.
- `A33C_MACRO_MEADOW_R8_R13_R14_GROUND_PAR.png`, `A33C_FOUR_WAY_REAL_GROUND_PLUS_A32B_PAR.png`, `A33C_DARK_LINE_DIAGNOSTIC_ORIGINAL_HIGHLIGHT_2X.png`, fault mask and macro habitat semantic mask.
- `A33C_NATIVE_VX_ROI_PASSAGE_QA.json`, `A33C_GODOT_REAL_GPU_PIXEL_QA.json`, `A33C_VX_INDEPENDENT_COLD_REBUILD_QA.json`, `A33C_GENERATION_QA.json`, and private full evidence ZIP.
Full private art and PNGs go to user's Drive only, GitHub docs and safe nonimage QA only.


## Verified A33C private delivery links — 2026-11-01
- **Actual native VX R8 BEFORE vs A33C R13 AFTER** with four material/vegetation zoom pairs (544×3128), late Case05 no title fade: https://drive.google.com/file/d/1AO38t8j8LGQK7NVsVm-U1gMjL5Py4bb5/view
- **Actual new Ground R13**, 544×416 PNG, SHA256 `d76bd016017fd6adcd4f767f2972fb2dc3f97e1f26d11b36cef2cc280e9b4043`: https://drive.google.com/file/d/18WwWzZ9AmCEMI2OuQ7Jppmnxk0cKBucn/view
- Three-way **REAL Ground + same approved A32B PAR50** R8/R13/R14: https://drive.google.com/file/d/1ISrdNuHN2tZV-5_SdgReADb7IiHkEnZZ/view
- Four-way ablation R8/R10/R11/R12: https://drive.google.com/file/d/1UkAklr8V7VI8s3vD8a9lZYA60yRdS2LA/view
- Three terrain-habitat / dark-line closeups: https://drive.google.com/file/d/1eIuPx11EBvncZiCM7KmWKDqsu7DFPew8/view
- Actual dark source bands **red diagnostic**: https://drive.google.com/file/d/1McOPwzdu_N4OsHJKyEqsPGJxH4uOtCw8/view
- 8,084 pixel dark fault mask: https://drive.google.com/file/d/10dzwiaf8Le_KHC7RUWGHPX-evswZk_kh/view
- Macro vegetation community mask: https://drive.google.com/file/d/1LD37A3NVKIg_OrTxQAQd_FM7abcqZEV8/view
- **Complete private native VX/Godot test evidence ZIP** 108 entries, 27,111,371 bytes. All CRC, per-item SHA256, and independent full unzip recheck local PASS. Google Drive name & size metadata readback PASS; do not claim additional remote downloaded ZIP hash: https://drive.google.com/file/d/1Iy6e2tEVvswy9rsizeyGOXdKTXnH-ssp/view
- VX actor collision/occlusion QA: https://drive.google.com/file/d/1dk-uPPm6QcGtbk19YGKmO-3NCC1uWE_H/view
- Godot GPU numerical QA: https://drive.google.com/file/d/1f0v7S-3OeZfyq-6zE6BAE6ectmajybwl/view
- Cold 3395 SHA QA: https://drive.google.com/file/d/1PeBoynxgQ12wvAswqDZk5sxgz3rrKOO7/view
- A33C permanent authority: https://drive.google.com/file/d/1y49jUmAW3kzQMcTdB_KRtsUGy85lB3hG/view
- A33C failure register: https://drive.google.com/file/d/1uKDhEXLGe3eqkqRWUvexjq7Lru54EXWl/view
- A33C detailed Handoff: https://drive.google.com/file/d/1zg95bBU4kwtXVUDpAiHs8Dalqw4BxX3V/view
- Latest A33C CURRENT_HANDOFF: https://drive.google.com/file/d/1ury9yl7GMiOkeETMjEWcDs_nWsZcsp48/view
- Stage folder: https://drive.google.com/drive/folders/1Qmd2pg1zCOwl829-DX7U1YUyjc__pBi9

**Engineering PASS / Ground art review PENDING / Formal Seal NO**.
