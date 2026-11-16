## Verified actual route visualization and observed limitation
- [Godot actual-physics five-route OVERLAY (DERIVED annotation)](https://drive.google.com/file/d/1yIsGxa7OGJEIj6gVPeyro0vj2UyKqQ_C/view) owner-only; [Original actual Godot route survey JSON](https://drive.google.com/file/d/1SGTALKKlvWu8kFntKjBDD87zFyusYboG/view) has exact physical cell paths. Neither image overlay nor JSON is a newly painted road layer.
- Human visual inspection of original full Godot 1x background + route overlay shows several **axis-aligned shortest-path cuts through visibly dense vegetation away from deliberately winding roads**. Five connected static-footprint paths do not establish suitable maze routes. Require separate authored/AI-assisted road semantic path cost, entrance/exit and native swept actor traversal before NAV promotion.
- Keep distinct gates: R9 REAL PHYSICS CONNECTIVITY PASS 5/5; R9 ROAD SEMANTICS HOLD / FORMAL NAV HOLD / ART HOLD.

# Forest Symphony | FS_01_MAZE R9 Actual Godot Footprint Route Survey | 2026-11-16

ENGINE PHYSICS SURVEY PASS, 4640 grid samples, 148 actual river colliders, 5/5 candidate landmark routes, FORMAL MAZE NAV/ART HOLD.

## Correct source and 12-map long-term goal
- Actual first dungeon FS_01_MAZE 幽葉迴廊 (80x58 at 32px = 2560x1856). Read original Nov14 six-biome world bible, FS_12_MAP_ACTIVE_MASTER_20261116.md, FS_12_MAP_FACTORY_V1_NATIVE_HANDOFF_20261116.md, FS_01_MAZE_R8_WATER_NATIVE_HANDOFF_20261116.md, and data/fs_12_map_catalog.json.
- [Full owner-only R8 Godot source](https://drive.google.com/file/d/19uk8jdZTTkLWVky1qbnD08vMiDzjPDLI/view), 211 files/91,979,830 bytes SHA256 bcafbe212c101ddcfbdb5de5d31d3bf69ee9d2e3c6c447fcc90f8f50a972895b. Cold Godot import, 148/148 water physics and 2/2 original GPU pixel test PASS. R9 does NOT mutate any original scene, Ground, PAR, water object or separate A36C workstream.

## Actual construction
- tests/test_fs_01_maze_r9_route_survey.gd runs in official Godot 4.7.2. Instantiates full R8 scene, disables standing actor's own collision for scan, tests ALL **4,640** actual 32px grid cell centers using **PhysicsDirectSpaceState2D.intersect_shape** with a **13x9px actor-foot rectangle**, collision layer 1. Includes 326 original full PAR and 148 new water physics rectangles.
- AStarGrid2D four-neighbor traversal, NO diagonal corner cuts, records each sampled grid status and exact route cell IDs; resolves candidate visual landmarks to closest clear cell within eight tiles. This is a survey, not automatic final maze design.
- Actual Godot official run **Exit 0**, water cells still blocked 148/148. FIVE independently sampled candidate routes connected:
  - south_approach to central_fork: 29 cells
  - central_fork to west_cottage: 19 cells
  - central_fork to east_cottage: 34 cells
  - central_fork to east_clearing: 35 cells
  - south_approach to north_forest: 61 cells
- tools/fs_01_maze_r9_route_overlay.py takes actual full original Godot 2560x1856 GPU frame and Godot physical JSON route coordinates, creates a plainly marked **DERIVED QA debug overlay** (NOT original single GPU framebuffer and NOT in Ground).
- JSON report: FS_01_MAZE_R9_ACTUAL_PHYSICS_ROUTE_SURVEY.json, includes candidate IDs, snapped endpoints and full cell sequences; unchanged original artwork.
- Preserve R8 full private Godot project; R9 survey source code and Handoff on public GitHub; optional companion private evidence archive should be clearly NOT STANDALONE and reference full R8 SHA.

## Honest acceptance gates
- **Engineering static-footprint route connectivity PASS 5/5** at grid centers. **Formal NAV HOLD** because this does not prove intentionally designed start/exit maze topology, bridges, actor movement sweeps, route aligned with visual roads or interactive gameplay events.
- **ART HOLD** because forest original Ground is nonuniform enlarged from older art source, needle/river pixel qualities inconsistent. Water flow animation and rich biomes remain future work.
- First village FS_01_VILLAGE 苔光村 remains original Godot-native candidate art HOLD. Other ten of twelve planned. Six biome pairs unchanged, no map formally sealed.

## Next practical tasks
1. Inspect colored routes at 1:1 and reject unnatural routes through visually dense canopy/rocks not represented by physics. Select actual entrance+exit and looped branching path, then native actor moving-body route test with bridge/water edge checks.
2. Separate Ground3 original native 32px art pass for forest; preserve old Ground SHA. Correct natural clustered grass, flower and path edges; independent PAR remains full RGBA objects.
3. After first paired biome is approved, create snow original pair FS_02_MAZE 冰脊迷谷 + FS_02_VILLAGE 霜燈聚落 based on saved world bible. Track all 12 forever.
4. Each new stage: actual art files/Godot native proof, QA, Failure Log, GitHub CURRENT_HANDOFF, owner-only Drive verified metadata. No VX/main overwrites.
