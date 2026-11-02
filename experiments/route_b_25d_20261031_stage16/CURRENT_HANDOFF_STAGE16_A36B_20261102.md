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

## USER-DEFINED CANONICAL GOOGLE DRIVE REFERENCES (2026-11-02, ACTIVE FOR A36C+)
These paths were supplied directly by the user and verified by the connected Google Drive folder listings. **Always check these before seeking replacement assets or making new pixel art.**

- **Original FS reference asset root (user-designated fixed location):**
  `00_Reference_Original` — https://drive.google.com/drive/folders/1JZL1RLbWECyZP_ddn-TSFjpCaw5C8jtr
- **Map / parallax reference subfolder inside that root:**
  `00_Reference_Original/01_Maps_Parallax` — https://drive.google.com/drive/folders/18PuuvYK1ClurHzLeKLG6yXZqKXDLa_tS
- Full_Map_References: https://drive.google.com/drive/folders/1dzRwlr3Npz9zr-uX3fnE0bM-HaDGicqe — FS scene examples including `SCENE*.png`, original matched `groundN.png` / `parN.png` and effect layer references. Drive's initial folder listing is partial (100 children); do not assume the list is exhaustive.
- Trees: https://drive.google.com/drive/folders/1Zth8u84_5-_pLTf-Ut_a86QiLBuhdaBw — 16 image sheets visible in listing: `Trees1.png`, `Trees2.png`, `Trees3.png`, `Trees4.png`, `tree variation*.png`, `Hanzo-VSTrees03/04.png`, etc.
- Buildings: https://drive.google.com/drive/folders/1_1fCD0jLwISt1SApxKwbNF3zIVMOyYlW — 14 image sheets visible, including `Hanzo-TownSet01VS.png` through `Hanzo-TownSet05VS.png`.
- Ground: https://drive.google.com/drive/folders/1fARpYIVEn4T2-3Q5Zv6HOy5O3Ia9z6-1
- Plants: https://drive.google.com/drive/folders/1lem9jNNVOqmpXMpu1Ns90bbuT6XtK59U
- Rocks: https://drive.google.com/drive/folders/10gdWhmCjrZEroahJe8zeM90Q6wnjeYqI
- Props: https://drive.google.com/drive/folders/1untMd8kVaxHXXDB53wnLPSif0bt5gsVL
- Water: https://drive.google.com/drive/folders/1qX3DkLmixcnSBBmw2m1qyefcttoaToT2

### A36C priority after user visual correction
- **The screen must read as a dense forest first, not a grassy field with isolated trees.** More overlapping, staggered crowns, visible multilayer forest depth; frame edges particularly filled with trees. Grass is mostly negative space for paths and small village clearings.
- Use the reference Trees and Full_Map_References folders first for the tree species, pixel density, architecture integration, and tree crown/ground relationships. Reference style may justify creating new PAR art, but assets should be rooted in these references rather than arbitrary generic style.
- Paths should pass through forest corridors; cottages should be enclosed by forest, preserving real playable entrances.
- Keep independent RGBA tree/object source, original scene-aligned Ground/PAR pixel-for-pixel consistency, correct foot-Y stable z-sort, base collision footprints, 32×32 VX passability, and real native VX plus GPU before/after testing. High visual canopy occupancy is **not** permission to block all walkable cells.
- Do not assume a visual numerical coverage percentage has been formally accepted: verify actual dense visual quality against FS reference scenes and user sign-off.
- Terrain/cliff elevation PAR remains deferred to its original-FS-source audit; do not reintroduce guessed terrain occlusion in A36C.
- A36B engine PASS baseline remains sealed only as a test reference, **not artistic approval**; A36C Formal Seal NO until new native screenshots, SHA, collision, and visual sign-off.
- Permanent authority pointer: `authority/FS_CANONICAL_DRIVE_ART_REFERENCES_A36C_20261102.md`. This user instruction supersedes prior guesses about where the canonical map art references live.
