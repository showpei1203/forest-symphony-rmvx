# FS Elf Forest Village — Reuse Classification v1

Date: 2026-08-22
Project: Forest Symphony / RPG Maker VX
Workflow: FS Map Asset Prompt Workflow v1
Stage: 5 — Reuse Classification
Status: LOCKED FOR STAGE 6 PILOT SELECTION
Reference Set: FS_REFSET_ELF_FOREST_VILLAGE_V1
Style DNA: FS_ELF_FOREST_VILLAGE_STYLE_DNA_V1
Map Intent: FS_ELF_FOREST_VILLAGE_MAP_INTENT_V1
Inventory: FS_ELF_FOREST_VILLAGE_ASSET_INVENTORY_V1

## 1. Stage 5 Scope

This stage audits the Stage 4 inventory against currently available Forest Symphony asset evidence and decides, per family, whether new AI generation is actually required.

Classification meanings:
- `SHARED_BIOME` = intended reusable family suitable across compatible FS forest/village maps.
- `LEGACY_REUSE` = current requirement can be fulfilled primarily by an existing historical/current FS source after extraction/normalization where needed.
- `MAP_SPECIFIC` = new or adapted art exists mainly to create this Elf Forest Village identity.
- `HERO` = unique landmark family.

Supply decision meanings:
- `DIRECT_CURRENT` = usable current-project source exists.
- `EXTRACT_LEGACY` = source art exists in accepted reference/legacy material but must be isolated/normalized before Asset Kit use.
- `NEW` = no sufficient accepted source was found; generation is required.
- `CONDITIONAL` = no generation now; revisit only if manual mapping proves a real need.

`NEW_GENERATION_REQUIRED=NO` does not mean zero work. It may still require deterministic extraction, alpha cleanup, tile slicing, naming and game-scale QA.

## 2. Binary Authority Audit Result

The authenticated full project authority is `FS project.zip`, Drive ID `13OU15Lfc9t6mcD2AJS6cpleaj_QhumMp`, previously reconstructed and CRC-audited as the Phase49K4 full project source. Stage 5 re-used its three-volume transport copy only for read-only Graphics inspection.

Important discoveries:
- `Graphics/System/TILEA2.png` is a real 512×384 current-project terrain sheet and contains compatible grass, dirt/earth, darker natural ground and warm/gray stone families.
- current `Graphics/System/TileE.png` is **not** the architectural TileE reference used by Stage 1; it is mostly marker/helper graphics and must not be treated as current runtime architectural art.
- the Drive Reference Set `TileB.png`, `TileD.png`, `TileE.png` are style/reference and legacy-reuse sources, not automatically current-runtime tiles.
- the full project also contains `Graphics/Parallaxes/FS_Dungeon/SAVE/TileB.png` and `TileD.png`, but these differ from the locked Drive reference sheets and contain mixed snow/dungeon/castle material. Only individually compatible pieces may be promoted through extraction + QA.
- `FS_Dungeon/TileA1.png` contains water, but its cool/dungeon treatment does not satisfy the locked Elf Village water DNA well enough to become the default stream source.

Consequence: Stage 5 may reuse many ordinary vegetation/prop/architecture components, but it does not silently promote entire historical sheets into the new Asset Kit.

## 3. Reuse Matrix — Base Terrain

| Family | Class | Supply | New Generation | Decision |
|---|---|---|---|---|
| TERRAIN-GRASS-A | SHARED_BIOME | DIRECT_CURRENT | NO | Use compatible grass source from current `TILEA2`; normalize/export only if the new kit needs standalone terrain art. |
| TERRAIN-DIRT-PATH-A | SHARED_BIOME | DIRECT_CURRENT | NO | Current `TILEA2` supplies warm earth/dirt material compatible with Style DNA. |
| TERRAIN-FOREST-FLOOR-A | SHARED_BIOME | DIRECT_CURRENT | NO | Current `TILEA2` supplies darker natural ground candidates. |
| TERRAIN-WATER-STREAM-A | SHARED_BIOME | NEW | YES | Existing project water evidence is too dungeon/cold-oriented or flattened in scenes. Generate one restrained outdoor blue-green stream source. |
| TERRAIN-STONE-PAD-A | SHARED_BIOME | DIRECT_CURRENT | NO | Current `TILEA2` contains compatible warm/gray stone surface candidates. |

## 4. Reuse Matrix — Terrain / Structure Transitions

| Family | Class | Supply | New Generation | Decision |
|---|---|---|---|---|
| TRANS-GRASS-DIRT-A | SHARED_BIOME | DIRECT_CURRENT | NO | Existing current terrain family supports natural grass/earth edge logic; deterministic assembly preferred. |
| TRANS-GRASS-FORESTFLOOR-A | SHARED_BIOME | DIRECT_CURRENT | NO | Build from selected `TILEA2` grass + darker floor family. |
| TRANS-GRASS-WATER-BANK-A | SHARED_BIOME | NEW | YES | No sufficiently clean accepted outdoor river-bank kit was found. Must match the new stream source. |
| TRANS-BANK-ROCK-ROOT-ACCENT-A | SHARED_BIOME | EXTRACT_LEGACY | NO | Compose from compatible rocks/logs/plants/limited root-like pieces from reference sheets. |
| TRANS-LOW-ELEVATION-EDGE-A | SHARED_BIOME | EXTRACT_LEGACY | NO | Existing rock/earth edge vocabulary is sufficient if mapping uses it. |
| TRANS-STAIR-NATURAL-A | LEGACY_REUSE | CONDITIONAL | NO | Existing stair/ladder/wood-step pieces are adequate candidates. |

## 5. Reuse Matrix — Vegetation

| Family | Class | Supply | New Generation | Decision |
|---|---|---|---|---|
| VEG-BROADLEAF-COMMON-A | SHARED_BIOME | EXTRACT_LEGACY | NO | Multiple compatible broadleaf trees exist across locked reference sheets. |
| VEG-CONIFER-COMMON-A | SHARED_BIOME | EXTRACT_LEGACY | NO | Locked TileD reference provides enough conifer vocabulary for the initial kit. |
| VEG-ACCENT-TREE-A | SHARED_BIOME | EXTRACT_LEGACY | NO | Larger ordinary tree candidates exist; keep subordinate to Sacred Tree. |
| VEG-BUSH-SHRUB-A | SHARED_BIOME | EXTRACT_LEGACY | NO | Compatible bushes/shrubs exist in legacy/reference art. |
| VEG-GRASS-TUFT-A | SHARED_BIOME | EXTRACT_LEGACY | NO | Existing small grass/plant clusters are sufficient. |
| VEG-FLOWER-CLUSTER-A | SHARED_BIOME | EXTRACT_LEGACY | NO | Existing sheets cover restrained floral accents. |
| VEG-ROOT-EXPOSED-A | SHARED_BIOME | NEW | YES | Existing root/dead-tree evidence is too limited for the intended reusable root family. |
| VEG-DEAD-LOG-A | SHARED_BIOME | EXTRACT_LEGACY | NO | Existing log assets cover the requirement. |
| VEG-STUMP-A | SHARED_BIOME | EXTRACT_LEGACY | NO | Existing stump/deadwood assets cover the optional requirement. |
| VEG-ROCK-FOREST-A | SHARED_BIOME | EXTRACT_LEGACY | NO | Existing rock families are abundant; reject dungeon/crystal/snow variants. |

## 6. Reuse Matrix — Architecture

| Family | Class | Supply | New Generation | Decision |
|---|---|---|---|---|
| ARCH-HOUSE-SMALL-A | LEGACY_REUSE | EXTRACT_LEGACY | NO | Ordinary houses can be assembled from existing FS wooden roof/wall/window/door grammar. |
| ARCH-HOUSE-MEDIUM-A | LEGACY_REUSE | EXTRACT_LEGACY | NO | Same modular architecture language can produce occasional larger buildings. |
| ARCH-SHOP-A | LEGACY_REUSE | EXTRACT_LEGACY | NO | Use ordinary timber building grammar plus existing merchant/service identifiers. |
| ARCH-INN-A | LEGACY_REUSE | EXTRACT_LEGACY | NO | Legacy project/reference art includes inn/pub signage and suitable timber components. |
| ARCH-TREEHOUSE-SMALL-A | MAP_SPECIFIC | NEW | YES | No accepted existing treehouse family satisfies platform + entrance + support logic. |
| ARCH-TREEHOUSE-MEDIUM-A | MAP_SPECIFIC | CONDITIONAL | NO | Add only if manual mapping proves the small family insufficient. |
| ARCH-TREE-PLATFORM-A | MAP_SPECIFIC | NEW | YES | Existing bridge/deck pieces do not provide a coherent tree-integrated modular platform family. |
| ARCH-RAILING-ORGANIC-A | MAP_SPECIFIC | NEW | YES | Must match the new platform kit; may share the same contract/batch. |
| ARCH-STAIR-LADDER-TREEHOUSE-A | LEGACY_REUSE | EXTRACT_LEGACY | NO | Existing ladder/stair assets can explain access at 32px scale. |

## 7. Reuse Matrix — Bridge / Riverside Structures

| Family | Class | Supply | New Generation | Decision |
|---|---|---|---|---|
| STRUCT-BRIDGE-MAIN-A | LEGACY_REUSE | EXTRACT_LEGACY | NO | Existing bridge/deck/rail vocabulary is sufficient for the initial main crossing. |
| STRUCT-BRIDGE-MINOR-A | LEGACY_REUSE | CONDITIONAL | NO | Existing plank/bridge vocabulary is enough if later needed. |
| STRUCT-RIVERSIDE-DECK-A | LEGACY_REUSE | CONDITIONAL | NO | Existing deck/platform pieces can cover this optional node. |

## 8. Reuse Matrix — Props / Village Life

| Family | Class | Supply | New Generation | Decision |
|---|---|---|---|---|
| PROP-SIGN-DIRECTION-A | LEGACY_REUSE | EXTRACT_LEGACY | NO | Existing wooden direction signs are suitable. |
| PROP-SIGN-SHOP-INN-A | LEGACY_REUSE | EXTRACT_LEGACY | NO | Existing service/inn/merchant identifiers are sufficient for first assembly. |
| PROP-LAMP-A | LEGACY_REUSE | EXTRACT_LEGACY | NO | Existing lamp families are available. |
| PROP-BENCH-A | SHARED_BIOME | NEW | YES | No clean accepted outdoor bench family was confirmed in audited core sources. |
| PROP-WELL-A | LEGACY_REUSE | EXTRACT_LEGACY | NO | Existing well art directly satisfies the role. |
| PROP-CRATE-BARREL-A | LEGACY_REUSE | EXTRACT_LEGACY | NO | Existing crates/barrels are sufficient. |
| PROP-FENCE-WOOD-A | LEGACY_REUSE | EXTRACT_LEGACY | NO | Existing wooden fence vocabulary is sufficient. |
| PROP-PLANTER-POT-A | LEGACY_REUSE | CONDITIONAL | NO | Existing pots/flowers can cover the optional need. |
| PROP-WOODPILE-TOOLS-A | LEGACY_REUSE | CONDITIONAL | NO | Existing rustic utility objects can cover this if required. |
| PROP-MARKET-GOODS-A | LEGACY_REUSE | CONDITIONAL | NO | Existing merchant/stall vocabulary is sufficient if mapping needs it. |
| PROP-SACRED-GROVE-ACCENT-A | MAP_SPECIFIC | NEW | YES | No accepted low-profile elf sacred marker/offering family exists. |

## 9. Reuse Matrix — Hero

| Family | Class | Supply | New Generation | Decision |
|---|---|---|---|---|
| HERO-CENTRAL-SACRED-TREE-A | HERO | NEW | YES | Unique Hero required. Existing large trees are reference-scale evidence only. |
| HERO-SACRED-ROOT-BASE-KIT-A | HERO | CONDITIONAL | NO | Add only if manual mapping exposes integration gaps after Hero design. |

## 10. Generation Reduction Result

Total Stage 4 inventory families: **46**.

Current Stage 5 result:
- `NEW_GENERATION_REQUIRED = YES`: **9 families**.
- existing/reuse/conditional: **37 families**.

The nine new families are:
1. TERRAIN-WATER-STREAM-A
2. TRANS-GRASS-WATER-BANK-A
3. VEG-ROOT-EXPOSED-A
4. ARCH-TREEHOUSE-SMALL-A
5. ARCH-TREE-PLATFORM-A
6. ARCH-RAILING-ORGANIC-A
7. PROP-BENCH-A
8. PROP-SACRED-GROVE-ACCENT-A
9. HERO-CENTRAL-SACRED-TREE-A

For the **19-family Minimum Assembly Core**, only five families currently require new generation:
1. TERRAIN-WATER-STREAM-A
2. TRANS-GRASS-WATER-BANK-A
3. ARCH-TREEHOUSE-SMALL-A
4. ARCH-TREE-PLATFORM-A
5. HERO-CENTRAL-SACRED-TREE-A

Everything else in the Minimum Assembly Core can begin from existing current/legacy/reference material plus deterministic extraction/normalization.

## 11. Reuse Promotion Rules

Legacy/reference extraction is accepted only when all of the following pass:
- source silhouette matches locked Style DNA;
- 32×32 world-scale readability passes at 100%;
- no dungeon/snow/crystal/castle contamination remains;
- background becomes clean transparent PNG or approved chroma fallback;
- no accidental smoothing or sub-pixel resize;
- source is not copied as an entire mixed tilesheet into the final Asset Kit;
- extracted item receives FS asset naming + manifest entry;
- map-tied old composition stays reference-only rather than being promoted.

Current `TILEA2` terrain may be reused directly or deterministically normalized. Reference `TileB/D/E` assets must be individually extracted and QA'd before promotion.

## 12. Stage 5 Gate

PASS because:
- all 46 inventory families have an explicit class and supply decision;
- current binary authority was checked rather than inferred from reference screenshots;
- runtime `TileE` versus reference `TileE` ambiguity was resolved;
- minimum-core new-generation burden is reduced to five families;
- optional families remain conditional;
- no image generation has started;
- exact final geometry remains user manual-mapping authority.

Stage 5 result: **PASS**.

NEXT: Stage 6 — Pilot Selection. Select the smallest pilot that proves the missing production capabilities without generating the whole nine-family gap list. Pilot should explicitly include reuse-preparation tasks and new-generation tasks, and should defer the Hero final until ordinary family scale/pixel language is validated.
