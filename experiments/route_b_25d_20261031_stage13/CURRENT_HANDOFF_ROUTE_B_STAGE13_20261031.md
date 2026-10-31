# Forest Symphony | Route B Stage 13 — Fresh independent Ground production test
Date: 2026-10-31 | Research experiment only | ART FAIL | VX NOT RUN | FORMAL SEAL NO

## Project baseline
Continue Stage12 private Style-first Source 2D workflow and R17 Ground/PAR authority. Preserve ALL already sealed RPG Maker VX files, game scripts, passability, collision and Stage12 baseline; none changed. Stage13 isolated Windows working project at `E:\\FS_ROUTE_B_STAGE13_GROUND_SOURCE_20261031`.

## Goal and honest scope
1. Generate an **entirely new** 544x576 independent walkable Ground from scratch, not a rearranged copy of Stage12 Ground.
2. Keep independent original Stage12 blue house, ochre house, moss and sacred trees, well, hedge, sign AS BASELINE REUSABLE OBJECT SOURCES, not falsely call them new.
3. Test 2 scene regions (544x416) using real Godot 4.7.2 GPU, identical pixel-space coordinates with source compiler.
4. Validate source mask, 32px root, actor position occlusion and pixel parity.
5. Artist-quality success not demonstrated; this new Ground is **deterministic Python algorithmic generation, not yet a painterly image-model generated high-quality asset**.

## Source authoring provenance
- Source `author_stage13_ground.py` (Pillow+NumPy) with deterministic seed 130042 creates grass, one sinuous dirt path with branch, connected paths, flat vegetation, embedded pebbles, low grass, walkable tiny flowers. No tall trees, roofs, walls, waterways, cliffs or any raised scene objects. Output `source/ground_long.png` RGB 544x576, 544x576 native pixel target.
- Explicit semantic masks `source/PATH_SEMANTIC_MASK.png`, `source/WALKABLE_MASK.png`: path 15.78%, walkable 100%. These are **authored semantic masks**, NOT inference from finished pixels.
- Stage13 new Ground SHA256 `8d3d13a67844bad457476682db5861c93dc043c9161ae03a0b8d869fa7ad7689`; prior old Stage12 Ground SHA256 `735fea2aa38cdb73c07cd3ffa7382662d256c8f6f3aec0d27b6343b22f5a2020`. Exact source files and source lists retained.
- Existing 9 independent Stage12 PAR object sources retained, some legacy commercial rights unknown; **private R&D only**, do not upload ZIP or private PNG sources to public GitHub.
- New Canva generated image job is a separate **unintegrated** visual experiment; NO binary from Canva is incorporated, and the previous image_gen infographic posters MUST NOT be treated as ground images, test evidence or PASS.
- Stage13 source PIL art looks much more monotonous than original Stage12 private Style-first generated Ground. Thus ground3 high-fidelity appearance FAIL. STOP loss applies: no fake art PASS.

## Actual Godot 4.7.2 execution
- Forked Stage12 native 2D Godot project and independent Python compiler. Unmodified Godot scene compiler loads declared `source/ground_long.png` as original AtlasTexture 544x416 ROIs, not compiled Ground image.
- A_BLUE_COTTAGE ROI (0,0)-(544,416); B_OCHRE_GROVE ROI (0,160)-(544,576). Same house/tree/well/sign/hedge sources and original coordinates from Stage12, native PAR source-first split at tree 32x32 root + peripheral grounded decal + independent PAR upper.
- Both real Godot 4.7.2 GPU render outputs Ground, PAR and full scene verified per pixel against independent Python source compile:
  - A: Ground=0 diff; PAR=0 diff; Full=0 diff. RGBA alpha exact, border nonzero=0, tree root single 32x32 tile.
  - B: Ground=0 diff; PAR=0 diff; Full=0 diff. RGBA alpha exact, border nonzero=0, tree root single 32x32 tile.
- Same 70 static actor sample positions, 20 front positions 0% PAR overlay. These are **not** real VX Game.exe movement or collision acceptance.
- Actual 4-way comparison `evidence/STAGE12_VS_STAGE13_SOURCE_COMPARE.png`: old Stage12 A, new Stage13 A, old Stage12 B, new Stage13 B. Old art is visually superior; architecture does not automatically supply style quality.
- QA: `evidence/STAGE13_ART_AND_SOURCE_QA.json`, `evidence/STAGE13_GPU_PIXEL_QA.json`, `evidence/STAGE12_ACTOR_SWEEP.json`, `evidence/STAGE13_NEW_GROUND_AUTHORITY.json` and `STAGE13_SOURCE_LEDGER.json`.
- Formal Seal NO and user visual Gate F not granted.

## Rebuild
Run `RUN_STAGE13_ALL_CHECKS.ps1` in a fresh directory. It regenerates NEW source ground and semantic masks, compiles two 2D native Ground+PAR targets from sources, runs Godot editor import, renders two real GPU images, audits pixel-exact parity, 70 actor static sweep and new/old reference side-by-side.
Do not pull legacy assets from any outside folders: full private 9 reusable source objects, baseline Stage12 Ground and baseline Stage12 image are included inside ZIP for deterministic rebuild and style comparison.
No need for exterior network during rerender. Container/download links must be verified before presenting.

## Gates
NEW_INDEPENDENT_GROUND_SOURCED_FROM_ZERO = TECH_PASS
GROUND_ONLY_HIGH_OBJECT_COUNT = ZERO_BY_AUTHORING_SPEC
NATIVE_SOURCE_GROUND_PAR_PIXEL_EXACT = PASS_0_DIFF_2_SCENES
GODOT_GPU_RENDER = PASS
TREE_CORE_SINGLE_32PX = PASS_2_OF_2
ACTOR_FRONT_STATIC = PASS_20_OF_20_ZERO_70_SAMPLES
ORIGINAL_GROUND3_STYLE_QUALITY = FAIL
NEW_AI_PAINTED_GROUND_PROVENANCE = NOT_AVAILABLE
REAL_VX_RUNTIME = NOT_TESTED
PRIVATE_LICENSE_REVIEW = OPEN
FORMAL_SEAL = NO

## Next priority
Need *new high-quality AI-rendered Ground* with proven accepted source image, no UI/text/trees/objects; import into source Ground rather than using infographics or screenshots. Make new original transparent tree and house component at same reference style and use independent all-layer QA. Test eventual original VX Game.exe walk and scroll before any production seal. Do not expand village until art quality gate actually passes.