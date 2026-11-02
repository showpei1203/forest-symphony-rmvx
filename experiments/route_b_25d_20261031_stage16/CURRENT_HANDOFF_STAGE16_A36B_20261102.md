# Forest Symphony | Stage16 A36B Handoff | 2026-11-02

## Scope and authority
- ACTIVE: flat forest / future elf village, no terrain elevation or cliff PAR.
- Baseline A36 preserved immutable: `E:\FS_STAGE16_A36_FLAT_FOREST_ELF_VILLAGE_20261102`.
- This stage works in `E:\FS_STAGE16_A36B_FOREST_VILLAGE_VISUAL_20261102`.
- Isolated native VX: `E:\FS_STAGE16_A36B_FOREST_VILLAGE_VX_NATIVE_20261102`.
- Independent VX cold clone: `E:\FS_STAGE16_A36B_FOREST_VILLAGE_VX_COLD_20261102`.
- Base reference: `experiments/route_b_25d_20261031_stage16/CURRENT_HANDOFF_STAGE16_A36_20261102.md`.
- Original FS project and previous A36/A35 assets have NOT been overwritten.

## A36B actual deliverables
- True 1280×928 Ground: `A36B_FLAT_FOREST_GROUND_1280x928.png` SHA256 `dacb0517a61ef901a03bc7c8d87cfac043164dee3d53f1826543491aebd0ce76`.
- Transparent sorted PAR: `A36B_FLAT_FOREST_PAR50_RGBA_1280x928.png` SHA256 `65f30dbb4c277f7002073c460e8516cb8594ee4ed93bb89017e0355c6b1264c9`.
- Actual Ground+PAR composite: `A36B_FLAT_FOREST_TRUE_GROUND_PAR_1280x928.png` SHA256 `ed06ded3e5f3060e6d6d0a0e6f1b34e6ca72a0641c8230895e9a585e77d79a6a`.
- Real A36 before/A36B after contact sheet: `A36_VS_A36B_ACTUAL_GROUND_PAR_COMPARISON_1280.png`.
- 40×29 grid, 120 independent alpha objects: 54 trees, 60 shrubs, 4 landmarks, 2 authentic existing V29 moss-roof cottage images (the **same** house art duplicated, clearly NOT final diversity).
- 5 routes, 94,120 dirt-path pixels sourced from A33F native visual assets; 291 source-colored microscopic meadow blossoms (ground decoration, not standalone PAR).
- 78 collision grid cells blocked (trees + cottage front-wall footprints), 1082/1082 walkable cells connected.
- Neither PixelLab quota nor regenerated independent Ground/PAR was used to falsely satisfy alignment.

## Actual engine acceptance
- **RPG Maker VX Game.exe PASS for engineered test only**: 11 positions/22 real 544×416 screenshots, zero modal windows, loaded 120 objects, Map050 entered.
- Real cottage collision: tile (14,11) -> (14,12) blocked, player remains (14,11).
- Real natural dirt road: tile (11,8) -> (12,8) moved.
- **Godot 4.7.2 AMD Radeon RX 6700 XT PASS**: 6 native 1280×928 scenes, 6 native 544×416 crops, static expected vs actual GPU max RGB channel delta=1 and zero pixels beyond RGB1.
- **Independent cold VX PASS**: 3538/3538 files SHA256 exact, no RGSS modal, actual 544×416 screenshot, Map050 runtime loaded 120 objects after 8.57 seconds.

## Failure register and verified fixes
1. First isolated VX runtime opened a missing asset dialog: global RGSS `A36_` to `A36B_` replacement changed references to 118 reused sprite PNG filenames. Fixed by renaming files in isolated VX to matching `A36B_` names, verified second native run. Permanent fix incorporated in `a36b_build_native_VX.py`.
2. First Godot-to-composite pixel QA FAIL: 202 pixels with RGB delta >1 at x315–346, y783–809, because tree_005 and shrub_043 share foot_y=812 and had unstable tie order. Stable sort by (foot_y, id) in Godot manifest resolves the issue; rerender max RGB1, >1 pixel count0. Permanent sort incorporated in `a36b_build_godot.py`.
3. Cold snapshot at 7 seconds was premature: only `A36B_AUTO_NEW_GAME` had appeared, false-negative map-load assertion. A cold runtime retry waited for actual map/120-source messages and passed at 8.57 seconds. Do not claim success by a fixed 7s delay.

## Art review: NOT PASSED
- Two cottage clones lack architecture variety; replace one with a distinct, style-matched structure.
- Forest remains too sparse in patches, lacks layered flowers, fern clusters, stones, signs, garden details, local undergrowth density, weathered path edges and village props compared with original FS ground3 benchmark.
- Village currently preliminary cottages in forest, not a fully realized elf village. Avoid decorative, boxy pasted assets; retain source pixel density and RGBA crop quality.
- No terrain elevation, cliff lip or stairs; these remain deferred to original FS scripts/parallaxes audit, independent from this flat-ground milestone.
- **Formal Seal = NO. User visual acceptance = PENDING.**

## NEXT Stage A36C
Create two genuinely distinct elf-village building candidates from approved reference/material (do not fabricate a cheap box), validate each transparent silhouette/door/footpoint/collision. Improve forest ecology, preserve path connectivity, test native VX actor behind/in front of each house, then regenerate GPU and VX actual evidence, before/after, Failure Log and Handoff. Prefer real FS-style assets and source-sprites first; if using PixelLab limit to one declared constrained experiment after art preflight.

## Reproducible sequence
1. `python a36b_build_visual_candidate.py`
2. `python a36b_build_native_VX.py` (new isolated native folder only; source A36 intact)
3. `python make_capture.py`, then `python a36b_capture_native_11_scenes.py`
4. `python a36b_build_godot.py`, then Godot4.7.2 console with `--path GODOT_A36B_FULL_MAP_40x29 --script res://a36b_godot_full_native_render.gd`
5. `python a36b_validate_engine_and_montage.py`
6. Cold copy + full SHA run via `a36b_native_independent_cold.py`; if cold game's window not yet entered Map050 in 7 seconds, use `a36b_cold_runtime_retry.py` instead of treating it as an engine failure.
7. ZIP packaging including hashes, CRC, independent extraction and remote Drive link read-back.
