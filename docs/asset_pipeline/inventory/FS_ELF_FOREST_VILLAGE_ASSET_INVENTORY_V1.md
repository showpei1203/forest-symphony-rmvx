# FS Elf Forest Village — Asset Inventory v1

Project: Forest Symphony / RPG Maker VX  
Workflow: FS Map Asset Prompt Workflow v1  
Stage: 4 — Asset Inventory  
Status: LOCKED FOR STAGE 5 REUSE CLASSIFICATION  
Reference Set: `FS_REFSET_ELF_FOREST_VILLAGE_V1`  
Style DNA: `FS_ELF_FOREST_VILLAGE_STYLE_DNA_V1`  
Map Intent: `FS_ELF_FOREST_VILLAGE_MAP_INTENT_V1`

## Scope

This inventory defines the source-asset families required to assemble the intended medium-large Forest Elf Village. It defines purpose, footprint envelope, variation need, priority and conditionality.

It does **not** yet classify rows as `SHARED_BIOME`, `LEGACY_REUSE`, `MAP_SPECIFIC` or `HERO`; that is Stage 5. It also does not define exact placement, final map dimensions, Par, collision, event coordinates, global light or shadow.

Priority: `P0` required assembly core, `P1` full-identity/function support, `P2` conditional enrichment.

## Base Terrain

| ID | Pri | Purpose | Footprint / source logic | Variation target |
|---|---:|---|---|---:|
| TERRAIN-GRASS-A | P0 | primary village/forest ground | seamless, 32px-world compatible | 1 base + optional subtle alt |
| TERRAIN-DIRT-PATH-A | P0 | main/minor paths | supports 2–4 tile main, 1–2 tile minor paths | 1 base + optional wear alt |
| TERRAIN-FOREST-FLOOR-A | P1 | darker perimeter ground | seamless | 1 |
| TERRAIN-WATER-STREAM-A | P0 | village-scale stream/river | tileable, no directional mismatch | 1 calm source |
| TERRAIN-STONE-PAD-A | P1 | grove/threshold/service stone accent | warm weathered stone | 1 |

Terrain sources must avoid embedded props and must support repeat QA.

## Terrain / Structure Transitions

| ID | Pri | Purpose | Required family |
|---|---:|---|---|
| TRANS-GRASS-DIRT-A | P0 | grass/path connection | straight, inner, outer, end/fade as useful |
| TRANS-GRASS-FORESTFLOOR-A | P1 | village-to-forest soft edge | coherent edge/corner kit |
| TRANS-GRASS-WATER-BANK-A | P0 | readable stream banks | straight, inner, outer, end/cap equivalent |
| TRANS-BANK-ROCK-ROOT-ACCENT-A | P1 | bank reinforcement | 3–5 accents |
| TRANS-LOW-ELEVATION-EDGE-A | P1 | modest terrace/elevation | straight/corner/end family |
| TRANS-STAIR-NATURAL-A | P1 | connect low elevation | 1 primary family, optional narrow alt |

## Vegetation

| ID | Pri | Purpose | Target footprint | Variation target |
|---|---:|---|---|---:|
| VEG-BROADLEAF-COMMON-A | P0 | primary forest tree | ~2–3 tiles wide × 2.5–4 tall | 6 |
| VEG-CONIFER-COMMON-A | P0 | secondary forest tree | ~2–3 × 3–4 tiles | 4 |
| VEG-ACCENT-TREE-A | P1 | large non-Hero scenic tree | ~3–4 × 4–6 tiles | 2–3 |
| VEG-BUSH-SHRUB-A | P0 | middle vegetation layer | ~0.5–1.5 tiles | 6–8 |
| VEG-GRASS-TUFT-A | P0 | terrain breakup/edge layer | <1 to ~1 tile | 6–8 |
| VEG-FLOWER-CLUSTER-A | P1 | restrained color accents | <1 to ~1 tile | 6–10 |
| VEG-ROOT-EXPOSED-A | P1 | nature/elf integration | ~1–3 tiles | 4–6 |
| VEG-DEAD-LOG-A | P1 | perimeter/scenic detail | ~1–3 tiles long | 3–4 |
| VEG-STUMP-A | P2 | minor forest utility | ~0.5–1.5 tiles | 2–3 |
| VEG-ROCK-FOREST-A | P0 | boundary/riverside/path edge | ~0.5–2 tiles | 6–8 |

## Architecture

| ID | Pri | Purpose | Target footprint | Variation target |
|---|---:|---|---|---:|
| ARCH-HOUSE-SMALL-A | P0 | ordinary residences | ~3–5 tiles wide × 3–5 visual height | 3 |
| ARCH-HOUSE-MEDIUM-A | P1 | occasional larger residence/community | ~5–7 × 4–6 tiles | 1–2 |
| ARCH-SHOP-A | P0 | mandatory Shop | ~5–8 × 4–7 tiles | 1 + modular identifier |
| ARCH-INN-A | P0 | mandatory Inn | ~6–8 × 5–7 tiles | 1 + modular identifier |
| ARCH-TREEHOUSE-SMALL-A | P0 | distinctive elf residences | platform ~3–5 tiles wide | 3 |
| ARCH-TREEHOUSE-MEDIUM-A | P1 | stronger treehouse-cluster focal | body/platform ~4–6 tiles | 1–2 |
| ARCH-TREE-PLATFORM-A | P0 | elevated modular decks | ~2–5 tiles/module | 4–6 modules |
| ARCH-RAILING-ORGANIC-A | P1 | platform/walkway edges | modular ~1 tile segments | straight/corner/end + optional accent |
| ARCH-STAIR-LADDER-TREEHOUSE-A | P0 | readable elevated access | ~1–2 tiles wide | max 2 access types |

Treehouse assets must visibly explain platform, entrance/access and support logic at game scale.

## Bridge / Riverside Structures

| ID | Pri | Purpose | Target | Variation target |
|---|---:|---|---|---:|
| STRUCT-BRIDGE-MAIN-A | P0 | mandatory district connector | ~2–4 tiles traversable width | 3–5 modules |
| STRUCT-BRIDGE-MINOR-A | P2 | optional second crossing | ~1–2 tiles | 1 simple family if needed |
| STRUCT-RIVERSIDE-DECK-A | P2 | optional rest/NPC/view node | ~2–4 tiles | 1 small family if needed |

## Props / Village Life

| ID | Pri | Purpose | Target footprint | Variation target |
|---|---:|---|---|---:|
| PROP-SIGN-DIRECTION-A | P0 | arrival/routes | ~0.5–1.5 tiles | 3–4 |
| PROP-SIGN-SHOP-INN-A | P0 | service identity | ~0.5–1.5 tiles | Shop + Inn identifiers |
| PROP-LAMP-A | P1 | commons/service/path identity | ~0.5–1.5 tiles | 2–3 |
| PROP-BENCH-A | P1 | grove/commons/riverside rest | ~1–2 tiles | 2 |
| PROP-WELL-A | P1 | village-life focal prop | ~1.5–2.5 tiles | 1 + optional alt |
| PROP-CRATE-BARREL-A | P1 | lived-in utility | ~0.5–1 tile | 4–6 pieces/clusters |
| PROP-FENCE-WOOD-A | P1 | small boundaries | modular | straight/corner/end/gate, 4–6 modules |
| PROP-PLANTER-POT-A | P2 | residence/shop accent | ~0.5–1 tile | 3–4 |
| PROP-WOODPILE-TOOLS-A | P2 | rustic utility | ~1–2 tiles | 2–4 clusters |
| PROP-MARKET-GOODS-A | P2 | optional shop-front read | ~1–2 tiles | 2–4 clusters if needed |
| PROP-SACRED-GROVE-ACCENT-A | P1 | low-profile sacred framing | ~0.5–2 tiles | 3–5 |

## Hero / Landmark

### HERO-CENTRAL-SACRED-TREE-A — P0
Primary cultural, visual and navigation landmark. May exceed 4 tiles width and 6 tiles visual height while retaining the same 32px-world camera and trunk/character relationship. Target is one final Hero after limited pilot exploration. Identity comes from broad roots, canopy architecture, carved/natural details and restrained magical accents. Never solve it by enlarging an ordinary tree and adding random glow.

### HERO-SACRED-ROOT-BASE-KIT-A — P1
Optional modular root/base integration pieces if the final Hero needs better placement flexibility. Target roughly 1–4 tiles per piece, 3–5 pieces. Avoid baking the full Sacred Grove into the Hero PNG.

## Functional-node coverage

- Arrival / Commons: grass, dirt, grass-dirt transition, sign, common vegetation; lamp/bench/well optional.
- Central Sacred Grove: Hero tree, support terrain, controlled flowers/shrubs, low-profile sacred accents, optional root-base kit.
- Treehouse Cluster: common trees, small treehouse family, platforms, access, railing, bushes/grass/roots.
- Ground-house Cluster: small house family, paths/transitions, vegetation, lived-in utility props.
- Commerce: Shop, Inn, service identifiers, paths, moderate props.
- Riverside: water, banks, main bridge, rocks/bushes/roots; second crossing/deck conditional.
- Forest Perimeter: broadleaf, conifer, bushes, ground plants, rocks, logs/stumps/roots, optional forest-floor transition.

## Minimum Assembly Core

Before decorative enrichment, the village should be assemblable from:
1. Grass.
2. Dirt path.
3. Water.
4. Grass-Dirt transition.
5. Grass-Water bank transition.
6. Common broadleaf family.
7. Common conifer family.
8. Bush/shrub family.
9. Grass/ground-plant family.
10. Forest rock family.
11. Small ordinary house family.
12. Shop.
13. Inn.
14. Small treehouse family.
15. Tree-platform modules.
16. Treehouse access module.
17. Main bridge family.
18. Direction/service sign family.
19. Central Sacred Tree Hero.

If Stage 5 proves an approved legacy/shared asset already covers a row, new generation is not required for that row.

## Conditional assets

Do not generate these merely because they are listed: secondary footbridge, riverside deck, medium treehouse, low-elevation/cliff kit, natural stair kit, market goods, planters, extra utility clusters, expanded Sacred Tree root-base kit.

## Stage 4 Gate

PASS when every required Map Intent node is buildable from at least one listed family; terrain, transition, vegetation, architecture, bridge, props and Hero are covered; footprints and variation envelopes are explicit; conditional assets are separated; final geometry remains user authority; reuse classes remain unfinalized; and no image generation has started.

**Stage 4 result: PASS.**

NEXT: Stage 5 — Reuse Classification. Audit existing accepted FS assets against every inventory family and classify each row as `SHARED_BIOME`, `LEGACY_REUSE`, `MAP_SPECIFIC` or `HERO`, with `NEW_GENERATION_REQUIRED` yes/no and evidence source. Do not generate images yet.
