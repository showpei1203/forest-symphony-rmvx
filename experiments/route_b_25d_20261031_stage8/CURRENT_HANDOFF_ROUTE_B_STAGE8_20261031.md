# Forest Symphony — Route B / Stage 8 Detailed Tree Native Source
Date: 2026-10-31 | Status: TECHNOLOGY POC ONLY; ART FAIL; Formal Seal NO

## Governing authority / protection
- Preserve R17 Ground/PAR source-first rules: independently rendered GROUND RGB and transparent PAR RGBA, both 544 x 416, identical fixed 3D world camera. No finished 2D master reverse-crop.
- Keep 32 x 32 screen-aligned tree contact fully in GROUND; rest of tree trunk + crowns in PAR. Base and crown are generated from the SAME imported 3D GLB with identical transform, world-height cut shader.
- Ground -> 32 x 32 actor -> PAR for test, no VX passability/collision changes.
- Existing sealed RPG Maker VX FS maps, scripts, Gate, K4, source baselines, Stage3-7 left untouched; Stage8 isolated experiment at E:\\FS_ROUTE_B_STAGE8_TREE_ART_20261031.

## Source chain and license
Original artist/source model: Innerscene "Oak street tree, detailed leaves" CC0.
Publisher: https://www.innerscene.com/tools/library/3d-parts/oak-street-tree-detailed-leaves-a273fef9
Raw file: assets/oak_detailed_innerscene.glb and an identical unmodified archival copy source_raw/oak_detailed_innerscene.glb.
Raw GLB embedded copyright glTF asset text explicitly declares Innerscene Corp, CC0 1.0 Universal.
Downloaded bytes 6,184,284; SHA256 17e83e82b33a48e324cd3e479a89d0eee91046e6250e213fa326ceff587fad2e.
GLB native format: 625 meshes, 4 materials, 625 nodes, no extensions or external textures. Described by publisher as 9,450 lobed/heart-shaped leaves. The geometry is original editable 3D meshes; not 2D flattened sprites.

## Work performed, fully executed
1. Created isolated Stage8 fork of Stage7 with previous editable witch cottage, original authored roof world-coordinate shader, Ground source texture, Stage5 native tree clip and all QA scripts.
2. Downloaded Innerscene CC0 detailed oak GLB from official direct endpoint, verified magic glTF, size, mesh count, embedded copyright and SHA.
3. Ran Godot 4.7.2 compatibility native import; PackedScene succeeded with actual RX 6700 XT rendering.
4. Implemented render_stage8_oak.gd, creating two identical source GLB instances per tree. Lower root at clipping world Y <0.56 renders native separate Ground layer 4, upper trunk/crown native PAR layer 2. Cached and adjustable leaf materials with 3 luminance bands and bark. Both tree source instances share exactly the same source transforms.
5. Original new-oak source on WEST only compared with Stage7 baseline; preserved case A. Then switched BOTH to detailed oak. First "both" candidate broke Stage6 strict fixed-position actor test: EAST FRONT 2.174% occlusion, despite good-looking leaves (REJECTED, preserved as B negative test). This is a **functional regression** caught before artwork acceptance.
6. Fixed by narrowing only EAST source tree XZ scale to 0.86 **in both native Ground/PAR model instances**, not moving test actor or editing completed pixels. Re-rendered, re-ran same Stage6 script with unchanged 16px FRONT offset and all six 2D actor positional checks passed. Source roof, cabin and path unchanged.
7. Two actual native contact masks are each confined within one 32x32 tile: WEST rect [78,136,92,159], size 15x24; EAST [460,132,470,153], size 11x22. These are exact rendered alpha mask bounds at 544x416, not model-space assumptions.
8. Actual Godot QA Ground RGB 544x416 fully opaque; PAR RGBA 544x416 has zero nontransparent image-edge pixels. Scene layered composite vs separately rendered full 3D differs at 406/226,304 pixels (~0.1794%), RGB MAE 0.01617, max channel error 46, therefore **NOT PIXEL-EXACT** and no formal seal.
9. Fixed-position 2D actor tests after correction: WEST behind head occlusion 85.238%, at-base actor occlusion 38.538%, front actor occlusion 0%; EAST behind head occlusion 89.048%, at-base actor occlusion 36.561%, front actor occlusion 0%. Six of six thresholds PASS (very limited scope, not VX executable).
10. Native 1x Stage7 vs Stage8 same-frame comparison script: Stage8 changed 7017/22800 pixels (30.78%) in WEST canopy zone and 3732/22200 (16.81%) in EAST zone, 0 in central house and separate path probe. These measure **where** art changed, not overall artistic quality.
11. Stage8 new oak leaves are measurably structured and finer than Stage7 low-poly canopy blobs but currently too bright/pale and thin at 544x416; NOT approved against original high-density forest ground3. Home/path still simplified, art rating FAIL. "More meshes" is not a high-fidelity art pass.

## Final files / reproducibility
- render_stage8_oak.gd: source-native 3D tree construction, material palette, shader-based Ground/PAR split; selection FS_STAGE8_TREE=both, FS_STAGE8_PALETTE=harmonized.
- baseline_stage7/COMPOSITE_PREVIEW.png: untouched visual comparison baseline.
- candidates/A_LEFT_PALE/: first detail tree probe.
- candidates/B_BOTH_TREES_FRONT_FAIL/: known actor occlusion regression (2.174% front).
- assets/oak_detailed_innerscene.glb: exact CC0 model, imported into Godot.
- STAGE8_OAK_SOURCE_MANIFEST.json: asset provenance and SHA.
- RUN_STAGE8_ALL_CHECKS.ps1: self-contained Godot import/render and pixel QA.
- compare_stage8.py: native 1x A/B/C visuals and pixel-change localization; diagnostic 3x detail view is nearest-neighbor **display only**.
- out/GROUND.png, PAR.png, SCENE_FULL.png, TREE_CONTACT_MASK.png, COMPOSITE_PREVIEW.png, QA_4PANEL.png, QA_REPORT.json.
- out/CONTACT_32_GRID_AUDIT.json, STAGE8_ACTOR_OCCLUSION_QA.json, STAGE8_ACTOR_OCCLUSION_6PANEL.png.
- out/STAGE8_TREE_ABC_1X.png, STAGE8_LEFT_CROWN_3X_DIAGNOSTIC.png, STAGE8_CHANGED_PIXEL_MAP.png, STAGE8_ART_COMPARE_QA.json.
- Retained original Stage5+ Stage6 scripts and Stage7 cottage source model/material. No server connection required for cold rebuild.

## Testing limitations and future steps
- Two specific tree positions and one 32px actor; altering viewport, tree scale/pose or camera may break cell ownership.
- No native RPG Maker VX actual walk test, Y-sort behavior, full Gate F or final human visual acceptance.
- 406 pixel 3D full render vs Ground/PAR mismatch persists; not mathematically pixel exact.
- Next: art-sourcing must improve timber/crown materials, foliage depth and grounded natural shadows before larger village. Consider original higher quality 2D source templates or Blender pre-baked texture/normal rendering. Preserve source-first. Audit alpha fringes and final pixel art at 1x.

## Gates
CC0_SOURCE_PROVENANCE = VERIFIED_IN_GLB
REAL_GODOT_GL_RENDER = PASS
NATIVE_GROUND_RGB_PAR_RGBA_544x416 = PASS
PAR_BORDER_NONZERO = 0
TREE_CONTACT_32PX = PASS_2_OF_2
ACTOR_OCCLUSION_6_OF_6 = PASS_FINAL
REGRESSION_NEGATIVE_FRONT = CAPTURED_AND_FIXED
ART_SOURCE_NATIVE_EDITABLE = PASS
FULL_3D_COMPOSITE_PIXEL_EXACT = FAIL_406
REFERENCE_ART_GROUND3 = FAIL
VX_EXECUTABLE = NOT_RUN
FORMAL_SEAL = NO