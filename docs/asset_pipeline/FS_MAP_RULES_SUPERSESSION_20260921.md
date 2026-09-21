> **HISTORICAL — SUPERSEDED BY R2**  
> Current index: `FS_MAP_RULES_SUPERSESSION_20260921_R2.md`.

# FS Map Rules Supersession — 2026-09-21

Project: Forest Symphony / RPG Maker VX  
Related: SHO-39  
Status: **CURRENT**

## Current new-map authority

Read in this order:

1. `FS_MAP_ASSET_PRODUCTION_AUTHORITY_V3_1.md`
2. `FS_MAP_ASSET_PROMPT_WORKFLOW_V2.md`
3. `FS_MAP_COMPILER_AUTHORITY_V1.md`
4. current `FS_MAP_DIARAMA_FIELD_STYLE_DNA_*.md`
5. current benchmark/validator rules
6. non-conflicting shared asset-generation rules

## Current production decision

Default architecture:

`Source Assets -> Scene Blueprint -> Scene Manifest -> Deterministic Compiler -> Runtime Derivatives -> Visual/Runtime QA`

Short form:

> **Generate Assets, Compile Map.**

The Scene Manifest is geometry/placement/z-order/semantic authority.  
The compiler is final pixel-registration authority.  
RMVX runtime evidence remains final runtime authority.

## Model policy

The workflow is **model-agnostic**.

GPT-6 Astra may provide a stronger one-agent closed loop across planning, code, visual inspection and computer use, but it is optional. No project file format, manifest schema or compiler behavior may require Astra.

## Superseded defaults

For NEW maps:

- `FS_MAP_ASSET_PRODUCTION_AUTHORITY_V3_0.md` -> superseded by V3.1 where conflicting.
- `FS_MAP_ASSET_PROMPT_WORKFLOW_V1.md` -> superseded by V2 where conflicting.
- `FS_MAP_COMPILER_PROTOTYPE_V0_2.md` -> superseded for whole-map production by `FS_MAP_COMPILER_AUTHORITY_V1.md`.
- `FS_MAP_RULES_SUPERSESSION_20260821.md` -> historical.

## Historical / Legacy Reconstruction

Historical `MAP_DUAL_OUTPUT_AUTHORITY_V2_9.md` and earlier v2.x extraction rules remain valid only when explicitly preserving/recovering an existing flattened Master.

Castle Town reverse-extraction artifacts and QA evidence remain preserved and are not invalidated.

## Non-negotiable inherited rules

- RMVX 32x32 world-scale basis;
- high top-down / three-quarter FS projection;
- pixel-crisp output;
- no blur/sub-pixel drift;
- Nearest Neighbor only for approved pixel-art resizing;
- accepted source assets are not silently redrawn;
- final runtime acceptance occurs in Windows / RPG Maker VX.

**SEAL:** `FS_MAP_RULES_SUPERSESSION_20260921_SCENE_MANIFEST_COMPILER`
