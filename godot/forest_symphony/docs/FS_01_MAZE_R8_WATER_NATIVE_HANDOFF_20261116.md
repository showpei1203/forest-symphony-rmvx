## Verified owner-only R8 patch + full Godot package
- [R8 native physics patch + original GPU/QA evidence ZIP](https://drive.google.com/file/d/1urk3hwGXCUJqTZ-nUM1AYGTKUSYrQFFw/view): 18 members, **18,753,939 bytes**, SHA256 **b2f13ce1770a21113ba358206a9663a5c1140a0aa406b2d5f319e9b2bb58e49b**, ZIP CRC PASS. Google Drive provider returned exact bytes and shared=false / owner-only permissions. **Not standalone:** overlay over verified original R7B [full private source](https://drive.google.com/file/d/1vCUPIBc6Yv3vtc3Wy7cDRBvI8Y65-9wf/view).
- A **complete standalone R8 Godot project** was also built as FS_01_MAZE_R8_WATER_NATIVE_FULL_GODOT_PRIVATE_20261116.zip, 211 entries, 91,979,830 bytes, SHA256 **bcafbe212c101ddcfbdb5de5d31d3bf69ee9d2e3c6c447fcc90f8f50a972895b**, ZIP CRC PASS and original Ground/R7 scene SHA unchanged. As of this Handoff entry, its exact cloud file ID/owner-only sharing was **not yet provider-read-back**; link only after verification.
- The full project combines both previously verified owner-only source and patch; native R8 private scene tests (148/148 Godot physics and 2/2 real GPU) already PASS in the original Drive working directory. A full map maze path from entrance to exit is **NOT validated**.

# Forest Symphony | FS_01_MAZE R8 Water Physics | Official Godot Handoff | 2026-11-16

**ENGINE PASS · 148/148 REAL PHYSICS PASS · REAL GPU 2/2 PASS · ZERO-PIXEL VISUAL REGRESSION PASS · MAZE ROUTES HOLD · WATER ART HOLD · OVERALL ART HOLD.**

## Authority: 6 biomes × dungeon/village = 12 original maps
Read first [FS_12_MAP_ACTIVE_MASTER_20261116.md](FS_12_MAP_ACTIVE_MASTER_20261116.md), [FS_12_MAP_FACTORY_V1_NATIVE_HANDOFF_20261116.md](FS_12_MAP_FACTORY_V1_NATIVE_HANDOFF_20261116.md) and [FS_12_MAP_FACTORY_V1_FAILURE_LOG_20261116.md](FS_12_MAP_FACTORY_V1_FAILURE_LOG_20261116.md).
Original 2026-11-14 names/IDs of all six paired biomes and their palettes/materials remain mandatory. This stage concerns the first dungeon, **FS_01_MAZE 幽葉迴廊**. Do not overwrite completed R8 R3 first village FS_01_VILLAGE 苔光村, parallel A36C source branch, Godot combat, or any original Ground/PAR.

## Authoritative previous private Godot scene
- Fully reproducible **[FS_01_MAZE R7B original full private 80×58 Godot project](https://drive.google.com/file/d/1vCUPIBc6Yv3vtc3Wy7cDRBvI8Y65-9wf/view)**, 193 entries, 73,228,430 bytes SHA256 de0e2039327b234b3adffa2ab110fbaf7620022f566febb5c66cf618c912ded5; Google Drive returned shared=false, owner-only.
- R7 reconciled scene SHA256 8bf0a897bc6525ec7cef29e4992c46aa36639ffbeb9b675bbc4cd88194128c36.
- Original Ground SHA256 ac591877b05c00543e6756e44e6ba81f6fea7e36086049e35de81e2610e0c911; original separate contact Shadow SHA256 752c252b0ac48961a164943749b421172ad775d2fe0e1329faa748219ff63ffa.
- 2560×1856, 80×58 at 32px, 326 independently editable full PAR, 310 trees, 56 provenance-safe moved tree positions. A36B R2 original artwork stays unchanged despite 40 differences with A36C R6. Source/GPU PASS; route/river/art still HOLD.

## Actual new R8 engineering
- **Separate additive scene:** scenes/fs_01_maze_r8_water_collision_80x58.tscn; SHA256 bb7f1b565419977c0851e4a188531b3426128758a098251bd151805e0e9fbfec. R7 remains byte-identical.
- **Godot source:** scripts/fs_01_maze_r8_water_collision.gd, runs at scene ready, reads existing original data/a36_terrain_semantic_candidates.json without changing it. Builds 148 unique 32×32 CollisionShape2D rectangles inside a dedicated StaticBody2D, collision_layer=1, separate from artwork/YSort/house/tree collision.
- **Reproducible additive scene builder:** tools/fs_01_maze_r8_water_build.py, creates new scene and data/fs_01_maze_r8_water_collision_manifest.json, with manifest source SHA and explicit route/art HOLD.
- **Native source/physics QA:** tests/test_fs_01_maze_r8_water_native.gd. Official Godot 4.7.2 tested existing 326 original PAR owner names, image SHA/footpoints and collision dimensions unchanged, and used PhysicsDirectSpaceState2D physical point queries to HIT ALL 148/148 unique water-cell colliders. Exit 0.
- **Original Godot native OpenGL GPU:** tests/capture_fs_01_maze_r8_water_native.gd created TWO original full 2560×1856 Godot screenshots (R7 old collision OFF vs R8 new collision ON); test Exit 0.
- **Exact real native GPU pixel QA:** tools/fs_01_maze_r8_water_gpu_qa.py read both original GPU frames, compared all actual 4.75M pixels and verified **ZERO RGB pixels changed** from collision-only new logic. QA Exit 0. Water collision does not smuggle blue pixels into the art.
- **Derived debug map only, not a Godot framebuffer:** [148 cell water alignment overlay](https://drive.google.com/file/d/12kEk-6GMtMiVmKTkZrfxazQdaGjcOkgg/view) uses actual Godot R8 frame and an annotated blue grid visualization. Its blue mask is never part of game's Ground sprite.
- Godot editor cold import PASS Exit 0. Native physical QA PASS Exit 0. Native GPU 2/2 PASS Exit 0. Real pixel diff=0 PASS.

## Important limitations and next concrete work
- This validates that **148 candidate river tiles block physics at their centers**. It does NOT validate river-water appearance, correct wetland shoreline edge collision, bridge/shallows traversal, start-to-exit maze walkability, river crossing or actor collision across the actual maze.
- Original Forest Ground was resized from 1478×1064 to 2560×1856; does not pass native art fidelity. 1x art remains HOLD. No water animation yet. Do not claim two completed maps.
- Next: plan real maze entrance(s)/exit(s) and route graph on 80×58 grid; use Godot actual physics/nav path tests against all tree+river collider footprints, then fix any incorrect bridge/water obstructions on a new separate R9 scene with actual screenshot and QA. Preserve original PNGs SHA/scene immutability.
- Once first biome pair reaches genuine art+nav acceptance, start original six-biome second pair FS_02_MAZE 冰脊迷谷 / FS_02_VILLAGE 霜燈聚落. All 12 slots must remain tracked, never a single scene forever.
- Code/scene/manifest/tests/docs public GitHub, owner-only complete R7 ZIP on Drive. R8 independent patch evidence/source should be delivered as verified owner-only Drive ZIP, with exact file ID/size/SHA not a guessed link. Always append fresh Failure Log and CURRENT_HANDOFF, no docs-only progress claims.
