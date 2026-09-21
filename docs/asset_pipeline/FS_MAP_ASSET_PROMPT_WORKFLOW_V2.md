> **SUPERSEDED FOR NEW MAPS — 2026-09-21**  
> Use `FS_MAP_ASSET_PROMPT_WORKFLOW_V3.md`. v2 remains historical evidence.

# FS Map Asset Prompt Workflow v2

Date: 2026-09-21  
Project: Forest Symphony / RPG Maker VX  
Status: **CURRENT DEFAULT NEW-MAP WORKFLOW**  
Authority: `FS_MAP_ASSET_PRODUCTION_AUTHORITY_V3_1.md`  
Supersedes: `FS_MAP_ASSET_PROMPT_WORKFLOW_V1.md` where conflicting

## 1. Core flow

`Reference Set -> Style DNA -> Map Intent -> Asset Inventory -> Prompt Contracts -> Pilot Generation -> QA/Revision -> Accepted Asset Kit -> Scene Blueprint -> Scene Manifest -> Deterministic Compiler -> Runtime Derivatives -> Visual QA -> RMVX Acceptance`

AI source-art generation and final map composition are separate stages.

## 2. Model-agnostic workflow

No step requires GPT-6 Astra specifically.

Use the strongest available model/tool for each stage:

- image model: source art and localized edits;
- reasoning/agent model: inventory, Prompt Contracts, Scene Blueprint, manifest edits and QA diagnosis;
- deterministic code: exact coordinates, compositing, masks, export and hashes;
- RMVX/runtime: final acceptance.

Astra may execute more of these roles in one continuous agent loop, but all artifacts must remain portable and reproducible without Astra.

## 3. Reference Set

Select a small explicit set from accepted FS material:

- tilesets for pixel density / material / palette;
- representative maps/scenes for camera / scale / stage grammar;
- accepted asset-family anchors;
- optional concept image for mood only.

Do not treat a concept image as exact geometry.

## 4. Style DNA

Track camera/projection, 32x32 world-scale relationships, palette, materials, edge treatment, lighting assumptions, texture density, silhouette, variation range and forbidden traits.

## 5. Map Intent + Scene Blueprint

Before mass asset production define:

- gameplay role
- approximate dimensions
- routes / exits
- landmark zones
- no-build corridors
- density zones
- architecture / vegetation families
- major occlusion interactions

The Blueprint is planning. Canonical geometry begins when values enter the Scene Manifest.

## 6. Asset Inventory

Every item records:

- Asset ID
- category / family
- reuse class
- priority
- target footprint
- expected variations
- reference set
- alpha/background mode
- connector / semantic notes

Reuse classes:

`SHARED_BIOME / MAP_SPECIFIC / HERO / LEGACY_REUSE`

## 7. Prompt Contract

Required fields:

Asset/Family ID; Category; Map/Biome; Reference Set; Use Case; Target Footprint; Perspective Rule; Silhouette Rule; Palette/Material Cues; Variation Axis; Background/Alpha Mode; Positive Prompt; Negative Prompt; Output Resolution; Allowed Postprocess; Forbidden Operations; QA Checklist; Status.

Prompts must target isolated reusable assets or declared texture/transition families.

**Do not ask image generation to place a final object at an exact whole-map coordinate.**

## 8. Asset generation rules

### Base terrain
- seamless/tileable source;
- no embedded prop/building/character;
- 3x3 repeat QA;
- deterministic VX tile/autotile conversion later.

### Isolated props
- transparent PNG preferred;
- `#FF00FF`, then `#00FF00` fallback;
- no contextual background / ground plane;
- no unrelated props;
- safe silhouette margin.

### Transitions
- explicit connector topology;
- consistent thickness/material/perspective;
- deterministic assembly preferred.

### Hero assets
- explicit footprint/orientation/entrance;
- individual QA;
- same camera/pixel density/world scale.

## 9. Pilot + QA

Run a small pilot before large batches.

Classify candidates:

`ACCEPT / ACCEPT_WITH_TECH_CLEANUP / REGENERATE_PROMPT_REVISION / REJECT_STYLE / REJECT_SCALE / REJECT_PERSPECTIVE / REJECT_CONTAMINATION`

## 10. Technical normalization

Normalize accepted assets only:

PNG, integer dimensions, no accidental resampling, Nearest Neighbor if resizing is approved, clean alpha/chroma, binary alpha for hard pixel art unless exception approved, stable naming and metadata.

## 11. Scene Manifest

Every placed instance records at minimum:

- `instance_id`
- `asset_id`
- integer `x`, `y`
- `anchor`
- `z` / `draw_order`
- source size
- approved transform
- semantic masks / parts
- collision / passability
- optional event / shadow / light metadata

Coordinates are canonical.

Do not maintain separate Ground and PAR placement lists for the same object.

## 12. Asset semantic parts

Where an object crosses actor depth, define explicit parts/masks such as:

- `base_mask`
- `occlusion_mask`
- `collision_mask` / polygon
- optional `shadow_mask`

Examples:

- tree base/trunk versus canopy;
- building lower/base versus roof/upper façade;
- bridge walkable surface versus front rail/arch.

Do not classify an entire object as PAR merely because it is a building/tree, and do not use crude horizontal slicing by default.

## 13. Deterministic compilation

Compiler inputs:

- accepted assets
- Scene Manifest
- canvas/grid definition
- semantic masks/metadata

Compiler outputs may include:

- Ground
- Par / Occlusion
- Shadow / Light overlays
- Collision / Event metadata
- Scene Manifest snapshot
- compile report and hashes

The compiler owns exact placement and pixels.

Image generation cannot independently repaint sibling outputs.

## 14. Visual QA loop

`compile -> preview/RMVX -> screenshot -> diagnose -> patch the smallest responsible artifact -> recompile`

Diagnose failures as:

`source art / placement / anchor / mask / collision / draw order / runtime`

Only source-art failures should normally trigger image regeneration.

## 15. Manual mapping compatibility

The user may continue placing objects manually.

Manual placement should be captured into the Scene Manifest or equivalent deterministic geometry record before runtime derivatives are finalized.

Manual authoring and agent authoring therefore converge on the same compiler path.

## 16. Legacy Reconstruction

Existing flattened Masters may still use historical extraction rules when explicitly placed in Legacy Reconstruction Mode.

New maps do not default to Master -> Ground/PAR reverse extraction.

## 17. PASS

A production-ready map requires accepted assets, stable Scene Manifest, reproducible compiler output, actual-scale visual QA and RMVX runtime acceptance.

**SEAL:** `FS_MAP_ASSET_PROMPT_WORKFLOW_V2_SCENE_MANIFEST_20260921`
