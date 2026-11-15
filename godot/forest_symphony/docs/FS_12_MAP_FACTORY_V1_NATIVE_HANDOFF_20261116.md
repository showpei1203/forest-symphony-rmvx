# Forest Symphony | 12 Map Factory V1 + FS_01_MAZE R7 | Official Native Handoff | 2026-11-16

**ENGINE PASS · NATIVE GPU PASS · ROI PASS · ART HOLD · FOREST ROUTES/WATER HOLD. Godot 4.7.2 only.**

## World-bible authority, canonical 12 maps
- Original 2026-11-14 world bible exists inside private A36B R2 ZIP: data/fs_six_biomes_world_catalog.json and docs/FS_SIX_BIOMES_WORLD_ART_PLAN_20261114.md. Original ZIP: https://drive.google.com/file/d/15t5Yn6zdTC8vG1dOYrLmMEHGVYqjEjwO/view, 54,150,993 bytes, SHA256 7e1cd53397aeb76deb09ceed0dc3002b5b7cc56c0a7fe40fac684a32eda6ac2b, 173 files.
- 01 蒼翠精靈林: FS_01_MAZE 幽葉迴廊; FS_01_VILLAGE 苔光村.
- 02 凜霜雪原: FS_02_MAZE 冰脊迷谷; FS_02_VILLAGE 霜燈聚落.
- 03 風蝕金砂: FS_03_MAZE 風沙裂谷; FS_03_VILLAGE 星井綠洲.
- 04 赤焰火山: FS_04_MAZE 熔脈裂橋; FS_04_VILLAGE 灰鑄工坊城.
- 05 幽霧水澤: FS_05_MAZE 泥潭迷水; FS_05_VILLAGE 蘆燈水上村.
- 06 星晶浮島: FS_06_MAZE 星盤斷空; FS_06_VILLAGE 虹晶臺地村.
- Canonical material palettes, Ground layers, full independent PAR families and visual route cues are the Nov14 source. Keep its names and scene IDs; do not substitute generic variants.
- Reusable factory authority: docs/FS_12_MAP_ACTIVE_MASTER_20261116.md. Operational state: data/fs_12_map_catalog.json. Native helper: scripts/fs_world_map_registry.gd. Native QA: tests/test_fs_12_map_catalog_native.gd.

## What is actually constructed
1. 12-map catalog/registry on branch feat/fs-a35-r3-hd2d-20261115. The Godot world-catalog test PASS Exit 0: 6 biome pairs, exactly 12 source IDs, 32px logical grid; actual existing R8 R3 forest village scene instantiated with 175 real canopy occluders. Only one same-project village DEV scene runnable, zero formally ART-sealed maps. Other maps are not faked.
2. Current FS_01_VILLAGE 苔光村 still uses real R8 R3 village 1280x928 Godot source. Full native ZIP owner-only: https://drive.google.com/file/d/1uGa7waQ-SwSSWVcgGUnbmlI7PjRaEKC2/view (199,988,204 bytes/398 files, SHA256 1c235f6155298a8f4bd54173e228ad4061ac8abced29d3d296136e0567983830). Day/dusk/night 6 original GPU PASS. ART HOLD.
3. FS_01_MAZE 幽葉迴廊 starts from A36B R2 private 2560x1856 @ 32px; 80x58 grid, 326 independent complete transparent PAR, 310 trees.
4. Found actual conflict in A36C R6 from parallel branch feat/fs-godot-first-a29-20261113: against A36B R2, 40 tree source_file/SHA changed to older art families and 56 owner positions differ; R6 sub-manifest has 39 movement entries. Blind use of R6 would regress earlier A36B sprites. Initial Godot strict source test FAILED, recorded in Failure Log.
5. FIX: reproducible tools/fs_01_maze_a36c_r7_merge.py builds new isolated scene scenes/fs_01_maze_a36c_r7_reconciled_80x58.tscn from original A36B private scene, preserving every original sprite asset/source SHA and importing only 56 current A36C grove positions. New manifest data/fs_01_maze_a36c_r7_reconciled_manifest.json; no changes to any original scenes or parallel branch.
6. Original Ground SHA ac591877b05c00543e6756e44e6ba81f6fea7e36086049e35de81e2610e0c911; original separate contact Shadow SHA 752c252b0ac48961a164943749b421172ad775d2fe0e1329faa748219ff63ffa.
7. Scene hashes: original A36B=143a0b5dd079e60d22e9df82f697a697c98a858823f7ba070fca4900b8915c69; original A36C R6=442e6a960ed13bca9dcd6655765e60093d35812412a2566a4a313b8628bfafc1; new reconciled R7=8bf0a897bc6525ec7cef29e4992c46aa36639ffbeb9b675bbc4cd88194128c36.

## Actual Godot-native results
- Original A36B R2 private ZIP fetched on authorized remote PC, SHA256 checked and CRC PASS. Godot 4.7.2 editor import of A36C with private sources Exit 0.
- tests/test_fs_01_maze_r7_native.gd PASS Exit 0: 326 real owner nodes/310 trees, 56 exact footpoint changes, original full sprite source SHA and collision shapes, Ground/Shadow source files unchanged.
- tests/capture_fs_01_maze_r7_native.gd PASS Exit 0: TWO actual full 2560x1856 Godot OpenGL GPU screenshots, original A36B baseline and new merged FS_01_MAZE, player hidden and camera fixed.
- tools/fs_01_maze_r7_gpu_qa.py PASS: 910,809 changed pixel positions **inside** the bounding union of 56 moved whole-object trees, **ZERO outside**. Only the new grove positions account for visible changes; original Ground unchanged.
- Visual A/B from original Godot frames (derivative 1x contact): https://drive.google.com/file/d/1MSMGYlS1QLLHENuxjVpKtdsSOSeWxMcO/view. This contact is NOT an original single framebuffer.
- Original R8 R3 village remains a separate source/branch from the large forest; do not pretend they were merged into one current Godot runtime yet.

## Honest art/navigation state and next construction
- FS_01_MAZE R7: SOURCE/NATIVE GPU PASS, ART HOLD, WATER HOLD, ROUTE/COLLISION HOLD. A36B's Ground is an enlarged (non-native source 1478x1064 -> 2560x1856) continuous image and its 1x pixel structure must be refined. Original 148 river hazard candidate cells are NOT physically validated. Entrances/exits, actual maze traversal and player occlusion not passed. Scene has cottages, roads and river but this is not yet an approved maze gameplay layout.
- Other ten maps remain PLANNED. All 12 must eventually have authentic unique biome Ground/PAR, SHADOW/LIGHT/WATER, physically walkable route/dungeon exits, 1x native screenshots and human ART PASS.
- Immediate next: validate river semantic mask, navigable entry→exit and looped branches; ensure actor can traverse doors/bridges while respecting tree-crown occlusion. After this, improve Ground source at native pixel density and unify color/size, then start fresh snow biome, not just endless tree adjustments.
- No NPC/event/dialog/story/combat in this map-art workstream. No VX. Source code/Handoff GitHub; private binary PNG and full ZIP owner-only Google Drive, SHA/CRC/permissions readback after packaging.
- Do not overwrite A36B historical art, A36C parallel branch or existing R8 R3 village/combat.

For exact problems see FS_12_MAP_FACTORY_V1_FAILURE_LOG_20261116.md. Every new turn: 12-map status update, Source QA, Native Screenshot/Physics QA, Failure Log, complete Handoff and owner-only Drive backup.
