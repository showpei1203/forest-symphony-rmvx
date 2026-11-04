# Forest Symphony | A36G R4 R3 Six-Region Integrated Forests | 2026-11-04

**Checkpoint status: ENGINE_SMOKE_PASS, COLD_VX_PASS; ART SIGNOFF PENDING; FORMAL_SEAL NO.**
**Goal:** actual executable RPG Maker VX / RGSS2 1280×928 (40×29 32px tiles) elf forest village, with independent Ground, alpha PAR, and depth-sorted integrated forest sources. No concept-only image. Do not overwrite A36F R1 or A36G R3B.

## Immutable source authority
- A36F R1 engineering baseline: E:\FS_STAGE16_A36F_ELF_FOREST_REWORK_20261103
- A36G R3B authentic integrated left workshop and first WEST contiguous forest: E:\FS_STAGE16_A36G_INTEGRATED_REGIONS_20261104
- New independent A36G R4 source: E:\FS_STAGE16_A36G_R4_ALL_REGION_FORESTS_20261104
- New R4 R3 native RPGVX build: E:\FS_STAGE16_A36G_R4_R3_VX_NATIVE_20261104
- New Godot 4.7.2 GPU project: E:\FS_STAGE16_A36G_R4_ALL_REGION_FORESTS_20261104\GODOT_A36G_R4_R3_40x29
- Independent cold restored RPGVX clone: E:\FS_STAGE16_A36G_R4_R3_VX_COLD_20261104

## Real deliverables (source art, not concepts)
- Forest first verified WEST from R3B retained: origin (-112,-110), authentic original 464×576 PixelLab RGBA with six depth strips.
- SIX ADDITIONAL genuine complete PixelLab region RGBA sources, each independently isolated; ALL actual output PNGs in SOURCE_INDEPENDENT_RGBA:
  - NORTH_WEST: 464×432 at (310,-145), SHA256 7f1705229921f924b6fb4707147c4cadaf532e04bfc4a0daec00fe5be793719b
  - NORTH_EAST: 464×432 at (714,-140), SHA256 3f639733957fa2c0e39de91318b48f5777205d04a8c2d86b9e622eb4afe35454
  - EAST: 464×564 at (976,260), SHA256 23bb04c3c53929ac058de1c588879433bed6269b4f7397735a46ee3c96ee8beb
  - SOUTH_WEST: 464×552 at (-86,435), SHA256 670f530b411e1dfeb7de312ba0e7200eac3d90e38171b5f7b38f0868bd91e4f6
  - SOUTH_CENTRE: 464×552 at (322,535), SHA256 53c5d824e423400b75ad94bdc53ba3dd02e4bac179c935b8a72dd60d106baa21
  - SOUTH_EAST: 464×552 at (754,545), SHA256 4f929433506044150c313af8ebbeb8a42e58d5b7f1bccf7d18c244bed8b8ee6e
- Each native provider source is preserved. Compiled clear-road and building-safe alpha PNG also preserved, plus R2 irregular edge seam transitions and 38 independent y-depth PAR slices.
- House: original R3B PixelLab one-piece integrated main house + left workshop 284×259 RGBA preserved (NOT rebuilt or patched).
- Original A36F Ground retained SHA256 8c4acbfe3c7201de5f66c51f84af8b568972c5a09d97ebc0a76e3152d764e371; no change to road topology/flower ground during this forest stage.
- Final independent Ground file: A36G_R4_GROUND_1280x928.png
- Final independent true-alpha PAR: A36G_R4_PAR50_RGBA_1280x928.png, SHA256 d5f7604aa051e67c91eb58fcdd524631cac4b09c3c175d54836886e11ff2b628
- Actual rebuilt composite: A36G_R4_TRUE_GROUND_PLUS_PAR_1280x928.png, SHA256 feb0b783e24bb2c845a1f6473d1ecf06cfd599a47f903f3284c2cf80106a590e
- Actual source metadata: A36G_R4_SCENE_MANIFEST.json, R4_FOREST_REGION_BLUEPRINT.json, per-PixelLab provider submission locks and hashes.
- Art before/after: A36G_R3B_VS_R4_TRUE_GROUND_PAR_BEFORE_AFTER.png, A36G_R4_R1_VS_R2_SEAM_COMPARISON.png, A36G_R4_R2_VS_R3_ROOT_REPAIR_COMPARISON.png.

## What changed over the rejected attempts
- R4 R1 replaced 267 old tree and shrub sprites with 6 massive 3D forest region source assets. An actual full composite showed sharp rectangular joins, **ART FAIL**.
- R4 R2 applied source-preserving, irregular alpha seam transitions only to compiled forest layers. Native provider source PNGs and original Ground untouched.
- Independent root audit checked 137 old blocking tree roots now visually replaced by integrated forest. Found 3 where alpha coverage was too low and an invisible blocker was possible. R4 R3 restored the EXACT 3 original independent tree RGBA source sprites: a36c_dense_tree_048, a36c_dense_tree_059, a36c_dense_tree_094. Original 32×32 collision layout kept, no whole-canopy collisions invented. All changes recorded in failure log and per-step QA.

## Exact engine proof for R4 R3, not inherited
- Real RPG Maker VX engine Map050: 192 independent scene objects loaded, 11 test locations, 22 actual 544×416 RGSS Player screenshots, 0 modal windows.
- Real blocked movement: A36G_BLOCK before=11,11 after=11,11. Real legal road movement: A36G_ROAD before=11,8 after=12,8.
- Recalculated independent collision tile map: 241 blocked, all 919/919 free cells reachable. Floor remains basic walkable unless blocked roots/building footprint.
- Actual Godot 4.7.2 GPU on RX6700XT: six 1280×928 full scenes, six 544×416 crops, max RGB delta 1, RGB>1 pixels 0 versus exact Ground+PAR source composite.
- Native engine audit: A36G_R4_R3_NATIVE_GPU_STAGE_QA.json, status ENGINE_SMOKE_PASS true.
- Original VX independent cold rebuild: 3600/3600 SHA256 identical; fresh Game.exe starts Map050, 192 objects loaded, window size 544×416, no modal; see A36G_R4_R3_NATIVE_VX_COLD_REBUILD_QA.json and A36G_R4_R3_NATIVE_INDEPENDENT_COLD_544x416.png.
- 9-panel screenshot contact: A36G_R4_R3_NATIVE_VX_9_REGION_CONTACT.png; 22 individual original native images in R4_R3_VX_CAPTURES.

## Gates still deliberately OPEN
1. User has not reviewed and accepted full-map art at native 1×. The R4 R3 appearance and ground flora may still require correction. **ART PASS not claimed**.
2. Root/forest overlap is smoke-tested with 137 anchor alpha checks plus 3 restored sources. Exact root-vs-new-generated-tree-trunk semantics and all player walk/occlusion positions were NOT exhaustively verified. **Collision semantic final pass not claimed**.
3. Real mountain/cliff terrain 1-2-tile front occlusion is separately deferred until audit of original FS Ground/PAR parallax. Do not improvise terrain.
4. If full ZIP/Drive/GitHub cloud sync is not confirmed, record it as not done. Formal Seal remains NO.

## Preserve reproducible engineering, never regenerate paid sources
- Read r4_prepare_sources.py; R4_FOREST_REGION_BLUEPRINT.json; r4_generate_region.py; each A36G_R4_*_PROVIDER_LOCK.json. **NEVER re-run provider POST with an existing lock.**
- Reproduce source composition using r4_integrate_all_regions.py (R1, not art-final), then r4_fix_region_seams_r2.py, then r4_restore_root_anchor_sources_r3.py, each expects previous stage and does not silently overwrite locked original sources.
- Native R4 R3 builds: r4_r3_build_native_engines.py, r4_r3_capture_native.py, r4_r3_validate_native_gpu.py, r4_r3_native_cold_verify.py. Build into NEW directories if rerunning rather than overwriting tested source.
- Failure note: R4_R1_BEFORE_SEAM_REWORK and R4_R2_PRE_ROOT_REPAIR contain independent before states; A36F and R3B never altered.
- Source files are pinned with SHA in A36G_R4_SCENE_MANIFEST.json and R4 QA JSON; changed independent PNG or missing source must fail closed.

**Next:** review actual full 1280×928 composite and 9 native screenshots, fix remaining art quality only as needed, then per-root foot and 32-grid collision verification. Do not claim seal based solely on successful engine render.
