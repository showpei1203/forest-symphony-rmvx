# Forest Symphony — Asset Generation Precheck

Version: **2026-09-21 v3.2**  
Status: **CURRENT / MANDATORY**

## Read first

1. shared `SHARED_GAME_ASSET_GENERATION_AUTHORITY`
2. `FS_MAP_ASSET_PRODUCTION_AUTHORITY_V3_2.md`
3. `FS_MAP_ASSET_PROMPT_WORKFLOW_V3.md`
4. `FS_MAP_VALIDATION_GATE_V1.md`
5. `FS_MAP_COMPILER_AUTHORITY_V1.md`
6. current FS Style DNA / benchmark / validator rules

## Prime directive

> **GENERATE ASSETS. COMPILE MAPS. VERIFY BEFORE DELIVERY.**

## New-map hard rules

- Never generate final Ground and PAR/Occlusion as independent image-model outputs.
- Never ask for “same map without foreground” plus “foreground only” as final runtime layers.
- Never crop engine layers from an infographic/mockup.
- Visual similarity is not registration proof.
- Checkerboard pixels are not proof of alpha.
- Scene Manifest is canonical geometry authority.
- Compiler owns final sibling-layer pixels.
- VX/Godot adapters consume the canonical scene data.
- Any required validation-gate failure = FAIL-CLOSED.
- A PNG pair is not an Engine Test Build.

## Status vocabulary

Use only:

`CONCEPT`  
`SOURCE ASSET`  
`DRAFT`  
`COMPILED CANDIDATE`  
`ENGINE TEST BUILD / UNVERIFIED`  
`ENGINE TEST BUILD PASS`  
`FAIL`  
`FORMAL PASS`

## Minimum first benchmark

Unless explicitly overridden:

- 544x416;
- simple grass;
- one dirt path;
- 3 trees;
- 2 rocks;
- 1 sign;
- one spawn;
- only tree base/occlusion/collision depth is under test.

No house/bridge/water/landmark until this passes.

## Legal image-generation targets

- seamless terrain source;
- isolated reusable asset;
- optional concept reference;
- localized source-art edit;
- mask assistance.

## Illegal final image-generation targets

- `Ground.png`
- `Par.png` / `Occlusion.png`
- sibling copies of an already placed object
- final collision data
- final engine-ready map package

## One-source-object rule

`Tree_01.png + base_mask + occlusion_mask + collision + one Scene Manifest placement -> all runtime derivatives`

Do not generate another Tree_01 for another layer.

## Mandatory gates

A. Canvas  
B. Manifest  
C. Registration  
D. Recomposite / Visual  
E. Semantic / Collision  
F. Engine Import

See `FS_MAP_VALIDATION_GATE_V1.md`.

## Claim rule

Never claim pixel-perfect, aligned, compiled, engine-ready, VX-ready, Godot-ready, successful or PASS without matching evidence.

## Engine request rule

If the user requests VX and Godot, both adapters/test builds are mandatory.

## Repair rule

Patch the smallest responsible artifact:

- art -> source asset
- position -> manifest
- occlusion -> mask
- collision -> metadata
- export -> compiler
- engine behavior -> adapter/runtime integration

Do not regenerate the whole map for a local deterministic defect.

## Model policy

The pipeline is model-agnostic. GPT-6 Astra is optional.

## Legacy

Historical flattened-Master extraction is Legacy Reconstruction Mode only.

**SEAL:** `FS_ASSET_GENERATION_PRECHECK_V3_2_FAIL_CLOSED_20260921`
