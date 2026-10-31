# Forest Symphony — Route B Stage 15: Minimum-error 2D Ground Quilting
Date: 2026-10-31 | Experimental benchmark only | ART FAIL | VX NOT RUN | FORMAL SEAL NO

## Objective, reality and lesson
- Stage14B private Style-first texture-donor Ground demonstrated native 2D Godot pixel-exact Ground/PAR but retained visible 64px quilt seams / repeat plants.
- Stage15 implements **actual dynamic-programmed minimum-error overlapped patch cuts**, rather than fixed 8px overwriting. Samples 80x80 donor patches every 56px (24px overlap); 110 placement cells per material. Rejects visually redundant repeated donors using recent-source reuse penalty, selects among 26 candidates by seam RGB cost + repeat penalty.
- Input is unchanged Stage12 private Style-first independent ground (source/ground_stage12_source.png), NOT a finished composite. Out source/ground_long.png is a NEW ROAD CONFIGURATION AND NEW DERIVED QUIT IMAGE, but **NOT new original AI-painted style-art**. This lineage is explicit in evidence/STAGE15_SOURCE_LEDGER.json.
- We attempted image-model generated native Ground: returned two decorative results boards/infographics full of made-up Stage16 PASS scores and invented links, not valid raw Ground. Rejected both; neither was tested/integrated. Do not use their fake metadata or links.
- Canva previous generation job gave only media ID without accessible source PNG bytes, not imported or counted as success.
- Original R17 Source-first Ground/PAR rule preserved. No deriving Ground by cutting a completed scene.

## Actual private source and new pixels
- New local branch E:\\FS_ROUTE_B_STAGE15_SEAM_QUILTING_20261031. Stage14B baseline copied to baseline_stage14/ and sealed production FS/VX sources not touched.
- A deterministic road mask with main road and branching trail is authored in source pixel coordinate space. All other meadow motifs are borrowed from private source Ground's all-grass patches; dirt pixels from soil-only donor patches. No imported trees, houses, separate tall props into Ground.
- Author Python author_ground15.py uses PIL+numpy; output RGB 544x576, PATH_SEMANTIC_MASK.png, WALKABLE_MASK.png white 100%; source ledger specifies old private art hash / new output hash / 80x80 / 24px overlap / 56px stride / counts and sizes.
- Source-private asset rights, some AI-generated, not formally cleared for public commercial redistribution. Raw project assets distributed only in private ZIP/Drive, not public GitHub.

## Actual Godot execution and QA
- Godot 4.7.2 Compatibility on AMD Radeon RX 6700 XT, native GPU source sprites/independent source AtlasTexture, NOT reading precompiled Pillow Ground/PAR as GPU inputs.
- 2 distinct 544x416 scene ROIs A_BLUE_COTTAGE and B_OCHRE_GROVE; independently source-rendered tree contact base + surrounding Ground decal, top PAR, home/well/sign/hedge source sprites imported from prior private Stage12.
- Independently PIL-compiled source Ground, PAR, Full vs native Godot GPU captured Ground, PAR, Full: **0 differing pixels in each of six cross-tool comparisons**.
- PAR border alpha zero both scenes; tree root CORE exactly one 32x32 tile each (PASS 2/2). Source mask root logic unchanged.
- 70 static 32px actor placements (2 trees x 5 x 7); **20 front positions all zero PAR false overlay**. NOT a real RPG Maker VX Game.exe runtime walk/collision/depth-sort test.
- Negative control: shifting A PAR by 1 pixel changes 61,519 pixels, rejected by exact-compare gate.
- Descriptive global contrast metric (fraction of horizontal+vertical neighboring mean-RGB differences >50) Stage14B 6.432%, Stage15 3.790%. Lower by ~41.1%, but these are nonidentical layouts and this is NOT a precise seam-quality or art-quality improvement measure. No falsified art score.
- Visual inspection: more homogeneous grass/road surface, some stylized donor vegetation repetition remains. Not approved against ground3 painterly 2D high-detail fidelity.
- Native 544x416 actor/video screenshots and gate artifacts are in gpu/ and evidence/. Key art side-by-side evidence/STAGE14B_VS_STAGE15_GROUND_1X.png, screenshot evidence/STAGE15_TWO_GODOT_SCENES.png.
- New work does not prove independent AI-native Ground source; next pipeline stage needs an actual raw image file (not an infographic/report) and clear original component provenance.

## Reproducibility
Entry RUN_STAGE15_ALL_CHECKS.ps1 regenerates Ground/source semantic masks from private donor, compiles source-independent Ground/PAR, mandatory Godot editor import, native GPU A+B captures, pixel QA, 70 actor offsets, 1px negative control and same-size art comparisons, asserts measured native gate correctness.
Canonical private ZIP includes all source/private donor sprites, semantic parts, scene manifests, Godot project, images and QA. Cold extract into E:\\FS_ROUTE_B_STAGE15_COLD_CHECK and rerun; compare cryptographic hashes before claiming reproducibility.
No files in FS sealed production maps/scripts/collision modified.

## Result gates
SOURCE_INDEPENDENT_NEW_LAYOUT = PASS
MINIMUM_ERROR_QUILT_SOURCE = PASS
GODOT_REAL_GPU_2_SCENES = PASS
SOURCE_COMPOSITOR_VS_GODOT_PIXEL_EXACT = PASS_0_DIFF_6
PAR_BORDER_ALPHA=PASS_0
TREE_ROOT_32PX=PASS_2_OF_2
STATIC_ACTOR_SWEEP=PASS_70_WITH_20_FRONT_ZERO
NEGATIVE_1PX_SHIFT_DETECTION=PASS_61519
ART_MATCH_GROUND3 = FAIL
NEW_AI_PAINTED_GROUND = FAIL_NOT_OBTAINED
ACTUAL_VX_RUNTIME=NOT_RUN
FORMAL_SEAL=NO

## Next research (not done)
- Stop image-generation route until it returns actual standalone editable high quality 2D art without labels/trees/buildings; no screenshots pretending masks.
- Better: create a verified original style sprite/microtexture library with explicit licenses, high-fidelity object layers, then target original Ground3 artist reference. Quantify seam defects separately from color distribution changes.
- Test true map animation/scroll and passability in VX; don't call 70 static positions a real Game.exe run.

## Verified cold rebuild on DESKTOP-90VT437
- A standalone 72-file private ZIP was extracted to E:\FS_ROUTE_B_STAGE15_COLD_CHECK; RUN_STAGE15_ALL_CHECKS.ps1 completed exit 0. Both Godot scenes, 70-position actor QA and strict source-to-GPU pixel parity passed.
- 12 of 12 critical source, Ground, PAR, GPU scene, side-by-side and actor QA files have identical SHA256 against the original stage15 project.
- Packaging SHA is versioned; after appending this handoff, regenerate final ZIP before remote sync.
