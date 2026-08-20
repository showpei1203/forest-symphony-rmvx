# FS Castle Town — NORTH Zone Final QA

Date: 2026-08-20
Branch workflow: SHO-39
Authority: MAP_DUAL_OUTPUT_AUTHORITY_V2_7

## Result
**FORMAL ZONE PASS**

Zone working bounds: `[230,0,1300,350]`
Ground base: `FS_CASTLE_TOWN_GROUND_WORKING_1448x1086.png`

## Fresh deterministic audit
The final owner audit does not reuse historical placement tables. Each of the 24 current Formal PAR PNGs was independently placed by solving its Master-exact opaque RGB against the Master image, then a fresh owner-count canvas and recomposition were rebuilt from the clean Ground.

Mechanical result:
- assets: **24**
- pairwise combinations: **276**
- nonzero overlap pairs: **0**
- multi-owned pixels: **0**
- max owner count: **1**
- union opaque pixels: **251,222**

## Completeness gate
Master-vs-fresh whole-zone visual QA plus residual-classifier review found no remaining discrete internal North PAR object without an owner.

Remaining differences are limited to:
- Ground road/floor texture;
- Ground grass/flowers;
- Ground water texture;
- legal sibling-zone continuation.

## Legal sibling seams
- WEST: `x=230`
- EAST: `x=1300`
- SOUTH: `y=350`

A classifier candidate around `x≈1015–1094, y≈325–350` was inspected and classified as the upper edge/roof of a building that continues south beyond the North work domain. It is explicitly **not** a North residual anchor.

## Latest superseding revisions
- NP1-R2A
- NP2-R3E
- N3A-R2C
- NR3-R1C
- NR5W-R2A
- NR8-R2A
- NR9-R1A

Older revisions remain diagnostic history only.

## Persistent Drive evidence
Stored under `Forest Symphony/08_Assets/02_Working`:
- `FS_CASTLE_TOWN_NORTH_FRESH_24ASSET_FINAL_RECOMPOSED.png`
- `FS_CASTLE_TOWN_NORTH_FRESH_24ASSET_FINAL_OWNERSHIP_AUDIT.json`
- `FS_CASTLE_TOWN_NORTH_ZONE_FINAL_QA_REPORT.json`
- `FS_CASTLE_TOWN_NORTH_FINAL_MASTER_VS_FRESH2X.png`
