# AI Semantic-First Pixel Map Pipeline — Research Integration v1.0
Date: 2026-10-23
Status: RESEARCH INTEGRATED / IMPLEMENTATION NOT VERIFIED / NOT FORMAL PASS
Scope: Forest Symphony RPG Maker VX, reusable architecture for PMD AutoChess and CG Pet Battle.

## Source and provenance
Primary source: user-supplied 38-page report "AI 生成像素風格遊戲地圖：從生成模型到可維護圖層的技術研究報告" (2026-10-23). The report recommends semantic-first grids, deterministic autotiling, separate objects, collision and occlusion, and Tiled/LDtk as editing/interchange tools. Its reference implementation targets Unity; VX adaptation below is a proposed engineering extension, not a finding verified by the report.

## Decision
Canonical scene blueprint is the single source of truth. Do not independently generate Ground.png and PAR.png; do not use segmentation of a finished composite PNG as the production pipeline. AI may propose terrain/object semantic layout. The compiler derives ground, decoration, object placements, foreground/occlusion, collision, navigation, and test metadata from the same coordinate system and asset registry.

## VX-specific adapter (PROPOSED, requires actual engine verification)
- Grid size: RPG Maker VX 32x32 pixels per tile; the report's 16px Unity examples are not VX specifications.
- 544x416 forest benchmark = 17x13 tiles. All exported raster layers use exactly 544x416 RGBA canvas and identical origin (0,0), with no resizing.
- Ground and PAR image files are compiler outputs, not independent AI source images. Rendering/overlay integration depends on the project's actual VX RGSS2 parallax script, which must be inspected before choosing draw order or filenames.
- Semantic terrain ID != visual tile ID. VX tile ID/autotile conventions require a dedicated mapping adapter and actual tileset validation; do not reuse Tiled global tile IDs or Unity 16/47 RuleTile indices directly.
- RGSS2 Map.rvdata writing/import, event handling, passage flags and layered foreground behavior remain research/implementation tasks, not verified capabilities in this report.
- Tree object is anchored at trunk foot; collider from trunk footprint; occluder from crown; shadow separate; ground remains fully defined underneath.
- Existing sealed project runtime/scripts must remain untouched until authorized integration tests.

## Canonical JSON (example, schema candidate)
```json
{
  "schema_version":"fs-semantic-v1",
  "scene_id":"forest_benchmark_17x13",
  "engine_target":"rmvx-rgss2",
  "tile_size_px":32,
  "width_tiles":17,
  "height_tiles":13,
  "canvas_px":[544,416],
  "origin_px":[0,0],
  "seed":42811,
  "terrain":{"encoding":"row-major","values":"17x13 terrain IDs in source data"},
  "objects":[
    {"id":"tree_01","asset_id":"oak_01","anchor_tile":[5,5],"anchor":"bottom_center","collision_profile":"trunk","occlusion_profile":"crown","variant_seed":1}
  ],
  "spawn":{"tile":[1,1]},
  "asset_registry_version":"pinned",
  "compiler_version":"pinned"
}
```
The terrain placeholder above is documentary, not a valid production instance. Production schema must validate exact array length, coordinates, enum IDs, and referenced assets.

## Compiler stages
1. Resolve licensed, pixel-crisp source tiles and object sprites from asset registry; pin checksums and provenance.
2. Produce or edit semantic terrain grid and object-instance list.
3. Validate 17x13 bounds, object anchors, no overlap/illegal placement, required spawn and path.
4. Repair connectivity and adjacency deterministically; reject unsatisfiable scenes.
5. Autotile terrain from explicit asset-specific adjacency tables. Fail on missing variants; never invent IDs.
6. Place sprites once using immutable world-to-pixel transforms; derive Ground, PAR/occluder, collision, masks and manifest.
7. Export layered editable intermediate (Tiled/LDtk optional) plus VX-target assets and test build.
8. Compare pixel-perfect composite against canonical renderer, run visual and in-engine checks, record logs.

## Forest benchmark acceptance
Scene: grass + one dirt path + 3 trees + 2 rocks + 1 sign + 1 spawn. No houses/bridge/water/garden.
- Gate A: source assets provenance/license, palette, dimensions, nearest-neighbor and alpha integrity.
- Gate B: semantic blueprint validity, 17x13 grid, unique IDs, immutable anchors.
- Gate C: deterministic layer compiler, same-size RGBA exports, zero offset, stable seed and hash.
- Gate D: collision/occlusion semantic audit: trunk blocks, crown occludes, rock blocks, sign policy explicit; A* reachability.
- Gate E: 1:1 pixel overlay and pixel-crisp visual inspection, no misplaced trees or ghost silhouettes.
- Gate F: actual RPG Maker VX playable test + log, including behind/in-front-of-tree traversal and collision. Godot optional comparison, never a substitute for VX test.
No PASS before Gate F evidence. Missing source art, mappings or runtime integration means BLOCKED, not PASS.

## Priority / no-regret MVP
P0: extract and pin existing FS v3.2 authority and current handoff; catalog previous failures, assets and actual VX parallax integration.
P1: implement deterministic 17x13 semantic->layers compiler without AI training.
P2: verify tree anchor, trunk collider, crown occlusion, overlay invariants, test in VX.
P3: introduce rule-based procedural terrain and A*/WFC repair.
P4: only then evaluate semantic diffusion and AI-assisted asset generation.
Do not change authority or claim an engine PASS on research alone.

## Report-supported references
Tiled: https://doc.mapeditor.org/en/stable/reference/tmx-map-format/
LDtk IntGrid: https://ldtk.io/docs/general/intgrid-layers/
LDtk Auto Layers: https://ldtk.io/docs/general/auto-layers/
WFC: https://github.com/mxgmn/WaveFunctionCollapse
PCGML: https://arxiv.org/abs/1805.00728
Single-example diffusion: https://ojs.aaai.org/index.php/AAAI/article/view/28865
Text-to-Level diffusion: https://arxiv.org/abs/2507.00184
Pixel VQ-VAE: https://arxiv.org/abs/2203.12130
SD-piXL: https://arxiv.org/html/2410.06236v1
