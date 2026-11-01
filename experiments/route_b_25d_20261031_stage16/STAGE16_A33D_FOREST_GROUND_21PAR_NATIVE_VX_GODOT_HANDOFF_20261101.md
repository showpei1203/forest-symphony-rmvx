# Forest Symphony Stage16 A33D — Forest Floor + 9 NEW PAR Trees — 2026-11-01
**Actual implementation completed on DESKTOP-90VT437. Engineering verified; user forest art review PENDING, Formal Seal NO.**

## Read in order
1. authority/FS_GROUND_PAR_SOURCE_FIRST_PRODUCTION_V1_20261101.md
2. authority/FS_PAR_SEMANTIC_ORIGINAL_OBJECT_GENERATION_V1_20261101.md
3. authority/FS_GROUND_TERRAIN_NONPERIODIC_VISUAL_QA_V1_20261101.md
4. authority/FS_GROUND_BLACK_STREAKS_ECOLOGY_FAIL_CLOSED_V1_20261101.md
5. NEW authority/FS_REMOTE_A33D_FOREST_LAYER_COLLISION_FAIL_CLOSED_V1_20261101.md
6. THIS A33D full Handoff, A33D failure register, latest CURRENT_HANDOFF A33D
7. A33C R13, A32B accepted PAR official branch and original user Ground3 reference.

## Exact input/output (not simulated)
Remote DESKTOP-90VT437 status Online, actually used connected Desktop Commander, reading original A33C real map and writing new PNG, RGSS2 test scripts and collision tables.
- A33C original opaque Ground SHA `d76bd016017fd6adcd4f767f2972fb2dc3f97e1f26d11b36cef2cc280e9b4043`, original remains untouched.
- **A33D new native opaque Ground 544x416** `A33D_GROUND_FOREST_FLOOR_544x416.png`, SHA `4af7f6bd86b8cdd171c7a13de59cd93a3a6a904c599b9be2640d8cae88f46c00`.
- A32B 12 original user-approved individual tree/rock/barrel/lamp PAR sprites all SHA identical; existing original A32B PAR50 SHA `24912a82622043c6c0b25b434a0a49585bb5cc470c4c83222a7db2d187de45fb` preserved as immutable historical authority.
- **9 NEW independent transparent RGBA tree PNGs** `A33D_TREE_*.png`, each complete uncut source, derived from one of the four previously approved original user tree sprites, nearest-neighbor scale, flip and small intrinsic-green variance, each with exact source filename and digest in `A33D_GENERATION_MANIFEST.json`. No scene SHADOW/LIGHT baked into tree object artwork.
- **Recompiled full transparent 21-object `A33D_9_TREE_PAR50.png`**, SHA `5cb0438c5535192d130d9aa39856bef0302994c1d1b023a21b2ae2c5eb239ac8`, exact original12+new9 independent RGBA alpha-composite sorted by foot. Forest now 4 original +9 new = **13 trees**, **21 actual PAR objects**.
- Baseline scenes: original A33C 4 trees, alternative 6 trees added, selected 9 trees added. Visual comparison `A33D_ACTUAL_LAYERED_FOREST_4VS10VS13_TREES.png`. None of these are a single generated scene substituted for layered source.

## Forest Floor actual
A33D added **276 vegetation groves**, **2019 native pixel leaf sprigs**, **15 fern patches** preferentially distributed in meaningful woodland habitat density zones. Original A33C vegetation source contains 1,885 bright flower RGB pixel positions, ALL exactly restored at original XY. All original R13 road RGB exact (no geometry edit). Dark band defect-class residual 12 pixels flagged and repaired selectively, 0 class remain after. Macro habitat density mask `A33D_HABITAT_DENSITY_MASK.png`, no global blur or fabricated terrain contour.

## True native VX Map50
New independent full RPG Maker VX clone `E:\FS_STAGE16_A33D_FOREST_VX_NATIVE_20261101` (DO NOT copy the test-only script into sealed FS production). From A33C's native test project with new Ground and Par50, 9 extra individual sprites, and only native test Script 483 `A30_MAP` and `Data/Map050.rvdata` collision E layer updated to make new trunks genuinely blocked.
- Recompiled Ruby Marshal RGSS `Scripts.rvdata` readback and Map050 Table readback verified. Other 506 embedded scripts unchanged. Existing 12 E-layer blocked 768 tiles preserved; 9 NEW nonroad blocked cells added, total21 blocked and200 walkable, **BFS 200/200 reachable**, road connectivity intact.
- Game.exe RGSS Player **21 actual independent object sprites loaded**, **16 native scenarios / 32 true screenshot frames** at 544×416; 0 modal windows. Original west partially occluded 351/627, east partially 357/627, both front 627/627, full east behind 0/627. New left canopy case actor visibility 146/627, right 104/627. Added two **REAL movement** tests: (6,1) move_down into new tree foot (6,2) remains (6,1); (11,1) move_down into new tree foot (11,2) remains (11,1). Original old root blocked (2,4)->(2,4), legal road move (8,6)->(9,6).
- Actual no-title-fade native comparison `A33D_VX_FOREST_BEFORE_AFTER_MOBILE_544W.png` and quadrants `A33D_REAL_VX_FOREST_FOUR_QUADRANT_CLOSEUPS.png`, using native Game.exe screenshots, not synthetic actors.

## True native Godot
Separate `E:\FS_STAGE16_A33D_FOREST_20261101\GODOT_A33D_FOREST_21_OBJECTS`, source A32B approved 12 sprites retained byte-identical + new9 local source PNGs and A33D Ground. 13 trees, 21 objects loaded. Godot 4.7.2 GPU AMD RX 6700 XT OpenGL compatibility rendered **12 real native frames**, including new tree behind/front and old tree cases. Independent PIL exact Ground + 21 ordered PAR target vs actual Godot no-actor scene: **3925 positions differ at max 1 RGB channel**, 0 positions >1. PASS_WITH_RGB_TOLERANCE1, NOT exact pixel parity.
- Source/GPU manifest `A33D_SCENE_MANIFEST.json`, GPU log/proof `A33D_GODOT_RENDER_PROOF.json`, numeric `A33D_GODOT_NATIVE_PIXEL_QA.json`.

## Cold and acceptance
Separate cold VX clone `E:\FS_STAGE16_A33D_FOREST_VX_COLD_20261101` **3404/3404 file SHA256 identical**, actual cold Game.exe Map50 launches and loads 21 sprites, 0 modal, 544x416 visible. Not full cold frame-to-frame 32/32 exact SHA parity. A33D still uses isolated test-only A30 test harness with legacy battle regression alias bypass from A30: production compatibility unresolved.
- A33D Ground and forest art user review **PENDING**. Increase forest species variety or shrub density if user sees copied look, but never change original approved A32B source. Final formal Seal NO until full production original VX and user visuals accepted.
- All licensed/source art private on Drive only. GitHub documents/QA/repro code permitted; raw copied user source sprite binaries never published publicly.

## Repro file location
`E:\FS_STAGE16_A33D_FOREST_20261101`, files `a33d_generate_forest_ground_and_trees.py`, `a33d_build_vx_native_21_tree_objects.py`, `a33d_capture_native_16_cases.py`, `a33d_build_godot_21_objects.py`, `a33d_godot_pixel_target_QA.py`, `a33d_cold_native_vx_verify.py`, plus all 9 tree PNGs, Ground, Par50, previews, QA and local zip. Final verified Drive file links to be appended when synced.
