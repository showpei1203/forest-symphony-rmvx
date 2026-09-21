# FS Map Asset Production Authority v3.1

Date: 2026-09-21  
Project: Forest Symphony / RPG Maker VX  
Status: **CURRENT DEFAULT AUTHORITY FOR NEW MAP PRODUCTION**  
Related: SHO-39  
Supersedes: `FS_MAP_ASSET_PRODUCTION_AUTHORITY_V3_0.md` where conflicting

## 1. Core decision

Forest Symphony new-map production uses an **Asset Kit + Scene Manifest + Deterministic Compiler** architecture.

Default workflow:

`FS References -> Style DNA -> Map Intent -> Asset Inventory -> Prompt Contracts -> Pilot Generation -> QA -> Accepted Asset Kit -> Scene Blueprint -> Scene Manifest -> Deterministic Composition -> Runtime Derivatives -> Visual/Runtime QA -> RMVX Acceptance`

Hard rule:

> **Generate Assets, Compile Map.**

Do not use image generation as final-canvas coordinate authority.  
Do not independently generate Ground and PAR as sibling images for a new map.

## 2. Model-agnostic authority

This pipeline **MUST NOT depend on GPT-6 Astra or any single model/vendor**.

Required capabilities are separated:

1. **Asset generation** — create or edit source art.
2. **Scene planning** — propose object IDs, anchors, footprints, routes, semantic layers and manifest edits.
3. **Deterministic compilation** — ordinary code owns exact pixel coordinates, compositing, masks and export.
4. **Visual/runtime QA** — inspect compiled output and real RMVX behavior, then patch manifest/masks/assets as required.

GPT-6 Astra may orchestrate all four when its computer-use/tool access is available, but Astra is an accelerator, not a file-format or authority dependency.

Any model, agent or toolchain may participate if it obeys this Authority and produces the same deterministic artifacts and QA evidence.

## 3. Source hierarchy

For new maps:

1. Existing FS tilesets and accepted scenes = visual/style/scale/material evidence.
2. Current FS Style DNA = reusable visual grammar.
3. Accepted modular assets = source-art authority.
4. **Scene Manifest = geometry / placement / z-order / semantic authority.**
5. **Deterministic compiler outputs = final pixel-registration authority.**
6. Windows / RPG Maker VX evidence = final runtime authority.

A generated full-scene concept is mood/composition reference only unless Legacy Reconstruction Mode is explicitly selected.

## 4. Scene Manifest as single source of truth

Every placed object has one canonical instance record. Minimum fields:

- `instance_id`
- `asset_id`
- integer `x`, `y`
- `anchor`
- `z` / `draw_order`
- source width / height
- approved scale / transform
- semantic parts or masks
- base / Ground contribution, if any
- actor-occlusion contribution, if any
- collision / passability
- event / transfer anchors when applicable
- optional shadow / light metadata
- status / version / source hash where available

The same object must **not** be re-described independently in Ground and PAR.

If `House_04` is at `x=512,y=384`, every derivative uses that same manifest placement. A model may propose a change; the compiler applies it.

## 5. Asset internal semantics

Ground/PAR membership is not decided only by object category.

An object may contain multiple semantic parts. Examples:

- tree base/trunk versus canopy;
- building base/lower face versus roof/upper façade;
- bridge walkable surface versus front rail/arch.

Prefer explicit per-asset metadata:

- `base_mask`
- `occlusion_mask`
- `collision_mask` / polygon
- optional `shadow_mask`

Do not horizontally slice objects into crude bands unless the asset contract explicitly defines that geometry.

## 6. Deterministic composer rule

Once source art and manifest coordinates are accepted:

- AI image generation MUST NOT redraw final placed pixels merely to create Ground/PAR;
- compiler uses integer coordinates;
- no sub-pixel transforms;
- no smoothing;
- Nearest Neighbor only for approved pixel-art resizing;
- the same source pixels and transforms feed all derived outputs;
- clipping, overlap, draw order and canvas bounds are programmatically reproducible.

Expected outputs may include:

- `MapXXX_Ground.png`
- `MapXXX_Par.png` or actor-occlusion overlay
- `MapXXX_Shadow.png` / `MapXXX_Light.png`
- `MapXXX_Collision.json`
- `MapXXX_Events.json`
- `MapXXX_SceneManifest.json`
- compile report / hashes / QA report

## 7. Asset categories and reuse

Retain source categories:

- Base Terrain Source
- Terrain / Structure Transitions
- Vegetation
- Architecture
- Props
- Hero / Landmark Assets
- Runtime Derivatives

Reuse classes remain:

- `SHARED_BIOME`
- `MAP_SPECIFIC`
- `HERO`
- `LEGACY_REUSE`

Reuse an accepted ordinary asset when it already fits.

## 8. Prompt Contract

Every AI-generated asset/family requires a tracked Prompt Contract containing at least:

- Asset / Family ID
- Category
- Reference Set
- Use Case
- Target Footprint
- Perspective
- Silhouette
- Palette / Material cues
- Variation Axis
- Alpha / Background Mode
- Positive Prompt
- Negative Prompt
- Resolution
- Allowed Postprocess
- Forbidden Operations
- QA Checklist
- Status

Prompt precision is source-art guidance, **not final-placement authority**.

## 9. Pilot before batch

Use a small pilot first. Accept or revise a representative family before expanding production.

Rejected outputs do not redefine the family. Do not regenerate an accepted ordinary asset merely to make each map artificially unique.

## 10. Technical asset gate

Before Asset Kit admission:

- PNG
- explicit integer dimensions
- scale / perspective PASS
- pixel-crisp edges
- no accidental resampling
- clean transparency / chroma
- binary alpha preferred for hard pixel assets
- partial alpha only for approved effect classes
- no contextual background contamination
- stable ID / naming / manifest metadata

## 11. Scene Blueprint before composition

Before production placement define:

- canvas size / tile grid
- walkable routes
- exits
- landmark zones
- no-build corridors
- density zones
- major occlusion risks
- gameplay-critical doors / stairs / bridges
- optional rough concept reference

The Blueprint may be authored by the user or proposed by an AI agent. It becomes geometry authority only when committed to the Scene Manifest or another approved deterministic geometry record.

## 12. Human and agent editing

The user remains final level-design authority.

Manual mapping remains allowed, but it is no longer the only normal path.

An AI agent may place or revise assets when authorized, provided it edits deterministic scene data rather than silently redrawing the final canvas.

Accepted/placed assets may not be moved, scaled, redrawn or semantically reclassified without an explicit reviewable manifest change.

## 13. Runtime derivatives

Ground, actor occlusion/PAR, shadows, lights, collision, passability and event anchors are downstream derivatives of stable source assets + Scene Manifest.

When source art is correct, fix runtime semantics by changing manifest/masks/metadata rather than regenerating the art.

## 14. Closed-loop visual QA

Preferred loop:

`compile -> launch/preview -> capture screenshot -> compare -> diagnose -> patch smallest responsible source -> recompile -> retest`

QA must distinguish:

- source-art defect
- placement / anchor defect
- semantic-mask defect
- collision / passability defect
- draw-order / occlusion defect
- renderer / runtime defect

Do not answer a placement defect by asking an image model to repaint the whole scene.

## 15. Required visual/runtime checks

At actual RMVX scale verify:

- pixel-crisp rendering
- correct world scale
- route readability and traversability
- doors / stairs / bridges align with movement
- no invisible wall or accidental opening
- no duplicate / ghost object across Ground/PAR
- occlusion only where intended
- no seams or sub-pixel drift
- repeated props do not create obvious stamp patterns
- overlays do not hide navigation
- scene reload/return preserves correct layers

## 16. Master Scene policy

For NEW maps, Master/Concept is optional visual reference.

It is not final pixel geometry authority and is not required to be decomposed.

## 17. Legacy Reconstruction Mode

Use only when preserving/recovering an existing flattened Master.

Historical `MAP_DUAL_OUTPUT_AUTHORITY_V2_9.md` and earlier extraction rules remain available there, including Master-exact extraction, binary alpha, deterministic coordinates, ownership QA and recomposition.

Existing Castle Town reverse-extraction artifacts remain valid historical/recovery evidence and must not be deleted or silently rewritten.

## 18. New-map PASS definition

PASS requires:

1. Reference Set and Style DNA explicit.
2. Asset Inventory sufficient.
3. Required asset families accepted.
4. Technical normalization stable.
5. Scene Blueprint defined.
6. Scene Manifest contains canonical placement/semantic metadata.
7. Deterministic compile is reproducible from source assets + manifest.
8. Ground/PAR/runtime derivatives share the same placement authority.
9. Visual QA passes at actual game scale.
10. RMVX traversal/occlusion/runtime acceptance passes.

## 19. Failure rule

If a deterministic compiler can reproduce the defect, fix data/code first.

If the source asset itself is wrong, fix/regenerate only that asset.

Whole-map regeneration is a last resort, not the default repair mechanism.

## 20. Authority priority

For FS new-map production after 2026-09-21:

1. later explicit FS production authority, if any;
2. `FS_MAP_ASSET_PRODUCTION_AUTHORITY_V3_1.md`;
3. `FS_MAP_ASSET_PROMPT_WORKFLOW_V2.md`;
4. `FS_MAP_COMPILER_AUTHORITY_V1.md`;
5. current FS Style DNA;
6. non-conflicting shared asset-generation authority;
7. V3.0 and historical v2.x only where non-conflicting or Legacy Reconstruction Mode is explicitly active.

**SEAL:** `FS_MAP_ASSET_PRODUCTION_V3_1_SCENE_MANIFEST_DETERMINISTIC_COMPILER_20260921`
