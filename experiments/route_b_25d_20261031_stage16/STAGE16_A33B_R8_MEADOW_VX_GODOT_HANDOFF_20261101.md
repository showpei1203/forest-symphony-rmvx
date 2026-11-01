# Forest Symphony Stage16 A33B — R8 Natural Meadow Ground source-first rework
Date: 2026-11-01, Taiwan. **A33B R8 engineering verified; visual user review PENDING; Formal Seal NO.**

## Mandatory reading order
1. `authority/FS_GROUND_PAR_SOURCE_FIRST_PRODUCTION_V1_20261101.md`
2. `authority/FS_GROUND3_TRUE_REFERENCE_AND_MATERIAL_EDGE_RULES_V1_20261101.md`
3. **NEW** `authority/FS_GROUND_TERRAIN_NONPERIODIC_VISUAL_QA_V1_20261101.md`
4. `authority/FS_NATIVE_VX_DYNAMIC_PAR_OCCLUSION_PASSAGE_V1_20261101.md` and `FS_PAR_LEAF_STRUCTURE_VISUAL_QA_V1_20261101.md`
5. This A33B Handoff and `STAGE16_A33B_GROUND_NATURAL_FAILURE_REGISTER_20261101.md`
6. `CURRENT_HANDOFF_STAGE16_A32B_20261101.md`, A33 R5 Handoff and true Ground3 original reference.

## Baseline and permissions
A32B upper two leaf structure art explicitly approved by user 2026-11-01 and frozen. A27 original Ground opaque 544x416 SHA `35c454c82d4f32906de39702a8463ca72316b14e157239604c18971bd67d00ce` locked; A33 R5 Ground SHA `ec06a5c01d292beba7dbb042be844dc95b59e5e127f293767d7ea86c11d287c0` retained for comparison. A32B PAR50 SHA `24912a82622043c6c0b25b434a0a49585bb5cc470c4c83222a7db2d187de45fb` and all 12 separate PAR sprites unchanged. No SHADOW/LIGHT to be baked in new Ground.

## A33B R8 source and generation
Actual official Ground3 art source `Graphics/Parallaxes/ground3.png` reference 1280x928; native grass 64x64 and sand 48x48 extracts from A10/A06. New A33B generator uses multi-scale smoothly varying *coordinate displacement* (no interpolated RGB blending; NEAREST lookup) on those existing pixel materials, moderate macro green-growth modulation, 1-3px pixel-bit boundary changes, original bright flora 1,885 pixel positions preserved, extra individual green pixel-blade plants in natural nonuniform clumps. This reduces obvious R5 reflected pattern without introducing hard square quilting seams. It does NOT mathematically eliminate source periodicity and has NOT obtained user visual approval. No AI paid PixelLab generation occurred in this stage.
Generated candidates: `A33B_GROUND_R7_ORGANIC_544x416.png` (171 blade strokes), **selected R8 `A33B_GROUND_R8_MEADOW_544x416.png` (345 strokes)**, R9 `A33B_GROUND_R9_LUSH_544x416.png` (456 strokes). R8 road mask remains 38,256 original A33 sand positions and same topology; ground erosion/grass-in-sand 1,922 positions, sand-in-grass 280 positions. New R8 SHA256 `dba346a620a15d7ddd9995273bac55c977c5e179c0bbcb8f9f986dd23e1c84fe`; source R5 to new R8 223,645 RGB pixel positions changed due intentional full texture resampling, not an incremental color tweak.

## Real RPG Maker VX isolated native proof
Local source `E:\FS_STAGE16_A33B_GROUND_NATURAL_20261101`.
New isolated native VX clone `E:\FS_STAGE16_A33B_GROUND_R8_VX_NATIVE_20261101`, 3395 files copied from A33 R5 clone. **Exactly ONE file changed** in native clone: `Overlays/ground50.png`. `Data/Map050.rvdata`, `Scripts.rvdata`, original 12 PAR sprites, `Par50.png`, foot, collision E layer, actor sorting and independent SHADOW/LIGHT all SHA identical to A33 source/A32B approved.
Native Game.exe actual RGSS Player Map50 544x416, **12 scenarios / 24 actual HWND screenshots / 0 modals**. Target 32x32 source actor alpha opaque 627: full upper-east tree behind visible diff **0/627**, west partially **351**, east partially **357**, actor in front **627**. Actual road move (8,6)->(9,6); blocked tree-root attempt (2,4)->(2,4). Do not confuse forced staging moveto to establish scenario with actual move-right/down passability tests.
- Native QA: `A33B_VX_NATIVE_12_CASES_SCREEN_QA.json`, `A33B_REAL_VX_VISUAL_PASSAGE_QA.json`.
- Mobile actual A33 R5 vs A33B R8 screenshot + four before/after material closeups `A33B_NATIVE_VX_R5_VS_R8_MOBILE_544W.png` 544x2950. Source 4-way compare `A33B_R5_R7_R8_R9_TRUE_GROUND_PAR.png` contains true Ground plus unchanged A32B PAR sources, NOT fabricated all-in-one image. Crop details `A33B_GROUND_MATERIAL_DETAILS_4WAY.png`.

## Real Godot GPU and cold independent proof
Fresh Godot project `E:\FS_STAGE16_A33B_GROUND_NATURAL_20261101\GODOT_A33B_GROUND_R8_ISOLATED`, 12 original approved PAR PNG sources independently hash verified against A32B. Godot 4.7.2 actual OpenGL RX6700XT **8 native frames rendered**. No-actor actual GPU frame vs independent Pillow Ground+12 PAR composite: **2946 changed positions, max per-channel RGB diff 1, zero >1**. State ENGINEERING_GPU_PASS_WITH_RGB_TOLERANCE_1, *not exact pixel equality*.
Fresh independent native VX clone `E:\FS_STAGE16_A33B_GROUND_R8_VX_COLD_20261101` copied **3395/3395 file SHA256 exactly**, cold Game.exe genuinely enters Map50, loads 12 objects, 0 modal; cold window screenshot 544×416. This is NOT 24/24 exact cold screenshot SHA parity and not sealed production battle regression pass.

## True QA states and next
Engineering layer separation, VX actor/collision, 8/8 Godot, 3395-file cold SHA: PASS. A32B tree visual: USER APPROVED unchanged. A33B R8 macro ecology, road material appearance, landscape richness vs Ground3: ART USER REVIEW PENDING. The full 1280x928 village-scale Ground3 final size, separate SHADOW/LIGHT engine pipeline and original sealed FS production battle harness remain pending. Formal Seal NO.

Next: user reviews R8 screenshot and R7/R9 alternatives. If grass still feels periodic or ecology too sparse, adjust only A33B Ground morphology and density, not A32B trees. Source R5 and A27 Ground must remain untouched. Full private PNGs/ZIP in Drive only because original art licensing unresolved; public GitHub documents and non-binary QA/repro instructions.
