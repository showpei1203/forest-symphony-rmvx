## FINAL R12 FULL STANDALONE GODOT ZIP: CLOUD + COLD REBUILD VERIFIED
- **[FS_01_MAZE「幽葉迴廊」R12 FULL PRIVATE GODOT 4.7.2 SOURCE + ALL QA](https://drive.google.com/file/d/1VikZtZc0YWhHFNMjylNGXFEbN2_oW6qR/view)** is the preferred complete playable technical candidate (no extra patch needed). **241 files, 113,804,051 bytes, SHA256 cf1d01ca564eaba05d7ff900314ae82b385dfab7a74b7d5010f5004e5aa21106; ZIP CRC PASS**. Google Drive readback exact size, shared=false, owner-only permission confirmed.
- **Cold rebuild after package:** Extracted all 241 files into a **new** owner-only Google Drive working directory, ran official **Godot 4.7.2 --headless --editor --import Exit 0**, then **R12 live RoadNavigator test Exit 0** (4,640 native physics cells, 148 river, 5/5 runtime exact weighted road routes, 231/231 real Player sweeps), then independent **R11 CharacterBody2D test_move 231/231 Exit 0**.
- Native GPU R8 vs R12 two original **2560×1856** OpenGL frames PASS; 4,751,360 visual pixels changed **0**; preserves old A36B Ground/Shadow/R8 scene SHA. R10 derived A/B review image is only a private debug comparison, not regenerated map art.
- Formal production status intentionally remains **ART HOLD / MAZE ENTRANCE–EXIT & GAMEPLAY TRANSITION HOLD**. R12 is a technical, reproducible, fully Godot-loadable **forest dungeon candidate**, not an approved completed maze. Other 10 canonical biome pair maps remain PLANNED.
- Primary next-stage source should be this R12 full ZIP and this GitHub CURRENT_HANDOFF. Do not redo R8, recut sprites or return to RPG Maker VX.

# Forest Symphony | FS_01_MAZE R9→R12 Road Navigator | Official Engineering Handoff | 2026-11-16

**ENGINE/GPU PASS · 4,640 actual Godot physical cells PASS · 148 water blockers PASS · 5/5 road routes PASS · 231/231 real CharacterBody2D sweeps PASS · R12 LIVE RUNTIME API PASS · VISUAL PIXEL REGRESSION 0 · ART HOLD · FINAL MAZE/ENTRANCE/EXIT HOLD.**

## 0. Permanent world goal and source authority
- Godot 4.7.2 ONLY. Forest Symphony world has **SIX ORIGINAL BIOME families**, one dungeon and one village each = **12 canonical scenes**, not 12 new placeholder names. See [FS_12_MAP_ACTIVE_MASTER_20261116.md](FS_12_MAP_ACTIVE_MASTER_20261116.md) and [fs_12_map_catalog.json](../data/fs_12_map_catalog.json).
- Original 2026-11-14 world bible from A36B R2 private source archive: data/fs_six_biomes_world_catalog.json and docs/FS_SIX_BIOMES_WORLD_ART_PLAN_20261114.md (original palettes, full separate PAR families, Ground terrain materials, route cues).
- 01 蒼翠精靈林: FS_01_MAZE **幽葉迴廊** and FS_01_VILLAGE **苔光村**. 02 凜霜雪原: 冰脊迷谷／霜燈聚落. 03 風蝕金砂: 風沙裂谷／星井綠洲. 04 赤焰火山: 熔脈裂橋／灰鑄工坊城. 05 幽霧水澤: 泥潭迷水／蘆燈水上村. 06 星晶浮島: 星盤斷空／虹晶臺地村.
- Map factory rules: Ground-only original continuous art (grass/flowers/soil/roads/shore, walkable unless hazard), independently generated *complete* alpha PAR objects with footpoints + YSort, separate SHADOW/LIGHT/WATER physics/animation. Godot originals screenshot 1:1, native real player collision, 32×32 grid, private images/full ZIP owner-only Drive, GitHub code/docs only, every stage source SHA, QA, Failure Log and Handoff.
- FS_01_VILLAGE original R8 R3 Godot source and lighting/actor visibility PASS but ART HOLD, separate branch. Other 10 maps are still PLANNED; do not invent them as built.

## 1. Immutable source baseline / real map
- [FS_01_MAZE R8 FULL PRIVATE PLAYABLE GODOT SOURCE](https://drive.google.com/file/d/19uk8jdZTTkLWVky1qbnD08vMiDzjPDLI/view), **211 files, 91,979,830 bytes, ZIP SHA256 bcafbe212c101ddcfbdb5de5d31d3bf69ee9d2e3c6c447fcc90f8f50a972895b** owner-only, CRC PASS, real cold reconstruct/148 water QA PASS.
- Full forest map 80×58 logical 32px, 2560×1856 pixel Ground, **326 original independent complete PAR**, **310 trees**, **148** Godot native independent StaticBody2D river collision cells. Old R8 scene SHA256 **bb7f1b565419977c0851e4a188531b3426128758a098251bd151805e0e9fbfec**, original Ground SHA256 **ac591877b05c00543e6756e44e6ba81f6fea7e36086049e35de81e2610e0c911**, Shadow SHA256 **752c252b0ac48961a164943749b421172ad775d2fe0e1329faa748219ff63ffa**.
- A36C R6 40 different tree source sprites found and REJECTED; 56 grove footpoint changes integrated safely in R7. R8 added water collision WITHOUT changing any original art pixel; R8 and earlier R7 original scenes are all retained.
- [R9 native route survey EVIDENCE ZIP](https://drive.google.com/file/d/1koMu1j2RhTwb7466DcpUdH6A3dpbtcUT/view) 9 files/8,164,645 bytes/SHA256 d7b6f8b4c78704e2605d4d5cabf9ea849eacd916c020cdaf70f6fab36b9062ca, private. Five raw shortest routes were physically connected but visual road misalignment was a real issue.

## 2. R10: road semantics from ORIGINAL Ground-only, not composited trees
Actual source: tools/fs_01_maze_r10_road_confidence.py.
- Reads private original Ground-only RGB. Cross-checks original Ground SHA; no PNG edits and no public image upload. For 32×32 cells counts warm earthy road/soil pixels using **R > 1.10×G, G > 1.22×B, R > 1.55×B, R > 82, G > 53**, then computes 3×3 Gaussian-like smoothing kernel (1,2,1 / 2,4,2 / 1,2,1)/16. This yields 4,640 ground road-confidence scores in private data/fs_01_maze_r10_ground_road_confidence.json, SHA256 **d442540efe2b45389aed99e77a3ddc81129201ec891404cbf785dc02234f54ec**.
- Roads are preference, NOT hard ground collision. The absolute authority remains Godot native player-foot 13×9 physics query and 148 water colliders. Weighted path cost = **1 + 8×max(0,0.55−road_confidence)/0.55**. Four-neighbor AStarGrid2D only; no diagonal shortcuts.
- tests/test_fs_01_maze_r10_road_weighted_native.gd **actual Godot EXIT 0**: 4,640 real physical cell checks and all 148 water obstacles. 5/5 original R9 anchor connections have higher original-Ground road affinity:
  - south→center 29→39 cells, mean score improvement **+0.2509**
  - center→west cottage 19→19, **+0.0447**
  - center→east cottage 34→34, **+0.3604**
  - center→east clearing 35→63, **+0.4091**
  - south→north forest 61→81, **+0.3553**
- Actual Godot-native base screenshot, **derived review image only**: [R9 vs R10 road semantic A/B](https://drive.google.com/file/d/1l4hSLmu7hZOEtjBsESiETYj0Ic5094wY/view). The road-following routes visually improve, including winding center/north trail. This image is a labeled derivative, NOT a replacement Ground nor one raw Godot framebuffer. Artistic roads still ART HOLD.

## 3. R11: actual PLAYER moving-body sweep, not point-only AStar
- tests/test_fs_01_maze_r11_actor_sweep_native.gd instantiates original Godot R8 scene, takes FIVE real R10 weighted routes and calls the **original Player CharacterBody2D.test_move** for every exact adjacent 32px actor movement segment. The actor uses its real foot-shaped 13×9 collision object, so collisions between grid centers are tested, not merely center-point passability.
- Official Godot native Exit 0: **231/231 segments, 0 collision**, all **5/5 route groups** PASS; original 148 water blockers remain in physics.
- Important: movement sweep test does not constitute full animated movement, responsive input, NPC dynamic collision, official route endpoints or bridge over/under navigation. FORMAL GAMEPLAY NAV HOLD.

## 4. R12: build real LIVE Godot scene with runtime path API
- scripts/fs_01_maze_r12_runtime_road_navigator.gd, a real Godot Node2D component that builds a Godot runtime 80×58 weighted AStar graph by re-checking 4,640 real physics footprints on scene readiness. Restores original actor collision-layer afterwards; uses original Ground-only confidence.
- Exposes live gameplay functions get_route_cells(start:Vector2i,end:Vector2i), get_world_route(start:Vector2,end:Vector2), get_nearest_open(cell,radius). Rejects invalid/outside/blocked grid endpoints.
- tools/fs_01_maze_r12_navigation_scene_build.py creates a **new** scene, never overwrites R8: scenes/fs_01_maze_r12_live_road_navigation_80x58.tscn, SHA256 **54224083a741bf4d451c9d44674d48fae68e399eac856c31b31c15c10457c392**, appends RoadNavigator node and selects it as main; original 326 PAR, 148 water and Ground unchanged.
- tests/test_fs_01_maze_r12_runtime_navigation_native.gd official Godot Exit 0, actually instantiated new scene: 4,640 physics checks, **4,129 walkable / 511 blocked**, 148 water, exact matching **5/5** R10 reference routes, **231/231 original Player test_move** segments, runtime public world-space path API tested, bounds guards.
- tests/capture_fs_01_maze_r12_native.gd actual Godot OpenGL RX 6700 XT two full **2560×1856 raw GPU frames**. tools/fs_01_maze_r12_gpu_pixel_qa.py compared **4,751,360 pixels**, RGB difference **0**, verified exact old R8 scene and Ground SHA unchanged. This is an additive navigation feature, not an art remake.

## 5. Acceptance and next work
- R12 ENGINE/RUNTIME/REAL GPU/PLAYER SWEEP PASS, **ART HOLD and FORMAL MAZE NAV HOLD** (entrance/exit deliberately authored, roads approved against art, bridge crossing, moving actor actual game input, event/teleport/NPC interface not yet complete).
- Original A36B forest Ground had been resampled from 1478×1064 into 2560×1856, not newly painted at original 32px fidelity. River still uses visually static image; no game-grade flowing WATER shader/foam. Needs separate art candidate, preserve source SHA. Conifer needle and cottage/river/road style coherence remain art review items.
- Next 1: select true artist-approved south entrance, north exit and branch/bridge points; test player moving through route via game input, not just test_move. 2: improve Ground3 native source at full 1:1 (grass clusters, flowers, natural roads), independently generate full PAR and water flow; use original Godot 1x A/B. 3: begin next canonical **凜霜雪原** dungeon/village pair using original world bible while maintaining all 12-map backlog, not endless cosmetic test of same tree.
- Every stage: real Godot scene and native GPU, 32px physical QA, ART HOLD until approved, Failure Log/Handoff, public code GitHub and private binary full ZIP owner-only Drive with exact SHA/CRC/permissions readback.

**No formal 12-map production seals until real art and final nav pass.**
