# FS Elf Forest Village — Pilot Selection v1

Date: 2026-08-22  
Workflow: FS Map Asset Prompt Workflow v1  
Stage: 6 — Pilot Selection  
Status: LOCKED FOR STAGE 7 PROMPT CONTRACTS

Reference Set: `FS_REFSET_ELF_FOREST_VILLAGE_V1`  
Style DNA: `FS_ELF_FOREST_VILLAGE_STYLE_DNA_V1`  
Map Intent: `FS_ELF_FOREST_VILLAGE_MAP_INTENT_V1`  
Inventory: `FS_ELF_FOREST_VILLAGE_ASSET_INVENTORY_V1`  
Reuse Classification: `FS_ELF_FOREST_VILLAGE_REUSE_CLASSIFICATION_V1`

## Goal
Select the smallest pilot that proves reuse promotion, new terrain generation, modular elf architecture, and mixed reused/new visual consistency. No final map geometry and no generation before Stage 7 Prompt Contracts.

## Lane A — Reuse preparation

1. `TERRAIN-GRASS-A` — current `Graphics/System/TILEA2.png`; normalize 1 grass source.
2. `TERRAIN-DIRT-PATH-A` — current `Graphics/System/TILEA2.png`; normalize 1 warm dirt source.
3. `VEG-BROADLEAF-COMMON-A` — extract 2 representative broadleaf trees from approved legacy/reference material.
4. `ARCH-HOUSE-SMALL-A` — prepare 1 ordinary FS timber-house witness for direct scale comparison against the new treehouse family.

Reuse items must pass 32x32-world readability, pixel-crisp/no-resample rules, clean isolation, no old-map composition contamination, and no whole mixed tilesheet promotion.

## Lane B — New generation

### `TERRAIN-WATER-STREAM-A`
- 3 pilot candidates.
- Restrained outdoor blue-green seamless stream material.
- Must pass 3x3 repeat with no seam, central stamp, embedded object or excessive micro-noise.

### `TRANS-GRASS-WATER-BANK-A`
- Dependency: accepted water direction/material family.
- Pilot modules: straight, inner corner, outer corner, end/cap or equivalent soft termination.
- Must connect reused grass to new water without bank-thickness or scale drift.

### Elf Treehouse Modular Pilot
Primary families:
- `ARCH-TREEHOUSE-SMALL-A`
- `ARCH-TREE-PLATFORM-A`
Supporting treatment:
- `ARCH-RAILING-ORGANIC-A`

Pilot target:
- 3 small treehouse body/silhouette candidates;
- 4 platform modules: straight deck, small landing, supported edge, end treatment;
- compatible organic railing treatment;
- use one existing ladder/stair candidate as access witness before any new access generation.

Pass only if platform, entrance, support and access logic remain readable at game scale, 3–5 tile platform family scale holds, camera stays high top-down three-quarter RPG, and modules recombine coherently.

## Explicit deferrals
Do not generate in this pilot:
- `HERO-CENTRAL-SACRED-TREE-A`
- `VEG-ROOT-EXPOSED-A`
- `PROP-BENCH-A`
- `PROP-SACRED-GROVE-ACCENT-A`
- `ARCH-TREEHOUSE-MEDIUM-A`
- secondary bridge / riverside deck
- Hero root-base kit
- full vegetation/house production batches
- shop/inn redraw

Hero is deferred until ordinary family scale/pixel language passes.

## Diagnostic witness composition
After individual QA, assemble a small non-authoritative witness containing:
- reused grass + dirt;
- new water + bank;
- at least one reused broadleaf tree;
- one reused ordinary house;
- one new treehouse body;
- at least two new platform modules;
- one reused access/stair/ladder witness.

This witness tests mixed pixel density, house/tree/treehouse scale, shoreline compatibility and platform modularity. It is not final map geometry authority.

## PASS gates

### Terrain
- reused grass/dirt crisp and compatible;
- water 3x3 repeat PASS;
- bank fits both grass and water;
- no seam/stamp contamination.

### Architecture
- at least one treehouse matches ordinary FS scale;
- modules connect coherently;
- entrance/support/access readable at 100%;
- no cinematic/isometric drift.

### Reuse
- tree/house promote cleanly;
- reused and generated assets coexist without looking like different games;
- no whole historical mixed sheet is promoted.

### Scalability
- a second treehouse composition can be built by recombining accepted modules rather than generating a new whole scene;
- terrain/water/bank can be arranged without a flattened Master.

## Stage 7 Contract Set
Create generative Prompt Contracts only for:
1. `PC-TERRAIN-WATER-STREAM-A`
2. `PC-TRANS-GRASS-WATER-BANK-A`
3. `PC-ARCH-TREEHOUSE-SMALL-A`
4. `PC-ARCH-TREE-PLATFORM-A` with compatible `ARCH-RAILING-ORGANIC-A` treatment

Reuse items get deterministic extraction/normalization QA instructions, not generative prompts.

Stage 6 result: **PASS**.

NEXT: Stage 7 — Prompt Contracts. Do not generate images until those contracts are locked.
