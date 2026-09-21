# Forest Symphony — Asset Generation Precheck

**Mandatory before every FS image-generation, image-edit, or map-composition task.**

## Current new-map authority — v3.1

Read in this order:

1. Google Drive shared `SHARED_GAME_ASSET_GENERATION_AUTHORITY`.
2. Drive `Forest Symphony/00_Project_Authority/ASSET_GENERATION_PRECHECK_FS`.
3. `docs/asset_pipeline/FS_MAP_ASSET_PRODUCTION_AUTHORITY_V3_1.md`.
4. `docs/asset_pipeline/FS_MAP_ASSET_PROMPT_WORKFLOW_V2.md`.
5. `docs/asset_pipeline/FS_MAP_COMPILER_AUTHORITY_V1.md`.
6. current FS Style DNA / benchmark / validator rules.

## Default architecture

`FS References -> Style DNA -> Map Intent -> Asset Inventory -> Prompt Contracts -> Accepted Asset Kit -> Scene Blueprint -> Scene Manifest -> Deterministic Compiler -> Runtime Derivatives -> Visual/Runtime QA -> RMVX Acceptance`

Short form:

> **Generate Assets, Compile Map.**

## Hard rules

- Image generation is **source-art authority only**, not final-canvas coordinate authority.
- Scene Manifest is the canonical geometry / placement / z-order / semantic authority.
- Ground, PAR/occlusion, collision, events, shadows and lights must derive from the same canonical placement records.
- Do **not** independently redraw or regenerate Ground and PAR for a new map.
- Use integer coordinates and deterministic composition.
- No sub-pixel shifts or smoothing.
- Nearest Neighbor only for approved pixel-art resizing.
- Prefer explicit per-asset `base_mask`, `occlusion_mask`, `collision_mask/polygon` over whole-object PAR classification or crude horizontal bands.
- Fix the smallest responsible artifact: placement -> manifest; occlusion -> mask; collision -> metadata; source-art defect -> source asset.
- Whole-map regeneration is a last resort.
- Manual mapping remains allowed, but stable placement must be captured into the Scene Manifest before final derivatives.
- Authorized AI-agent placement is allowed when it edits deterministic scene data rather than silently repainting the final canvas.
- The workflow is **model-agnostic**. GPT-6 Astra is optional, not a project dependency.

## FS scale / style inheritance

- 32x32 is the RMVX world-scale player/tile readability reference, not the total map-canvas limit.
- 544x416 is a viewport reference only.
- Large villages, castles, dungeons and parallax scenes may exceed it while preserving the 32px world-scale relationship.
- High top-down / three-quarter FS projection remains mandatory unless a later explicit authority changes it.
- Pixel-crisp rendering remains mandatory.

## Concept / Master policy

For NEW maps, a generated full-scene Master/Concept is optional mood/composition reference only.

It is not:
- exact geometry authority;
- Ground authority;
- PAR authority;
- a mandatory decomposition source.

## Legacy Reconstruction Mode

Use historical `MAP_DUAL_OUTPUT_AUTHORITY_V2_9.md` and inherited v2.x extraction rules only when explicitly preserving/recovering an already-existing flattened Master.

Existing Castle Town reverse-extraction assets and QA reports remain valid historical/recovery evidence. Do not delete or silently rewrite them.

## SAM2 / segmentation policy

SAM2 / Guided SAM2 remains optional QA/omission evidence.

It is not final Ground/PAR/Collision authority. For new maps, source semantic masks + Scene Manifest + deterministic compiler are preferred.

## Runtime gate

A map is not accepted until actual-scale RMVX checks pass:

1. world scale;
2. traversal/routes/exits;
3. door/stair/bridge alignment;
4. collision/passability;
5. actor occlusion;
6. no duplicate/ghost Ground-PAR objects;
7. no seams/sub-pixel drift;
8. stable scene reload/return behavior.

Version: **2026-09-21 v3.1**  
Seal: `FS_ASSET_GENERATION_PRECHECK_V3_1_SCENE_MANIFEST_COMPILER`
