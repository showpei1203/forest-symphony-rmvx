# Forest Symphony Map Benchmark Workflow v2

Date: 2026-08-21
Project: Forest Symphony
Related Linear: SHO-39
Status: CURRENT NEW-MAP BENCHMARK WORKFLOW

## 1. Goal

Prove that a NEW Forest Symphony map can be produced at scale from existing FS visual references by manufacturing an approved modular Asset Kit first, then manually assembling the final map and deriving runtime layers afterward.

This replaces the v1 requirement to begin with multiple flattened full-map candidates and decompose a selected Master Scene.

## 2. Stage A — Reference Set

Select representative existing FS evidence:
- tileset(s);
- 2-5 compatible village/field/settlement scenes;
- accepted asset families where available.

Document what each source contributes: palette, projection, scale, material language, object density, architecture or vegetation grammar.

Existing scene geometry is not copied.

## 3. Stage B — Style DNA + Map Intent

Confirm:
- 32x32 world-scale basis;
- high top-down / three-quarter RPG projection;
- object-to-character size relationships;
- palette/material direction;
- map role and traversal pattern;
- expected focal hierarchy;
- biome/shared-library reuse opportunities.

No image generation is required yet.

## 4. Stage C — Asset Inventory

Build the inventory before generating art.

Categories:
- Base Terrain Source;
- Terrain / Structure Transitions;
- Vegetation;
- Architecture;
- Props;
- Hero / Landmark Assets;
- Runtime Derivatives, planned but not produced yet.

Each entry records target tile footprint, reuse class, priority and variation count.

## 5. Stage D — Pilot Prompt Contracts

Create Prompt Contracts for the smallest representative set that can prove the map family's visual compatibility.

Suggested pilot:
- 2-3 terrain materials;
- one transition family;
- one vegetation family;
- one architecture family;
- one small-prop family;
- one hero only when needed.

Do not generate a large mixed batch before these pilots pass.

## 6. Stage E — Pilot Generation + QA

Generate small candidate batches.

Evaluate:
- style match to FS references;
- perspective;
- scale;
- pixel density;
- palette/material;
- silhouette readability;
- background isolation;
- family cohesion.

Revise prompts by changing only the variables responsible for failure where possible.

## 7. Stage F — Production Batch

After each family is accepted, generate its production variants.

Perform batch consistency QA and reject near-duplicates/outliers.

Do not allow one bad candidate to redefine an accepted family.

## 8. Stage G — Technical Normalization

Normalize accepted assets:
- PNG;
- transparent background preferred for isolated objects;
- pure #FF00FF chroma fallback where needed;
- clean alpha/chroma edge;
- integer dimensions;
- nearest-neighbor-only resizing for pixel art;
- no accidental crop or hidden background plane;
- stable names and manifest entries.

Terrain sources must also pass repeat/seam QA.

## 9. Stage H — Asset Kit Gate

The benchmark Asset Kit must contain enough accepted pieces to build the intended map without relying on reverse extraction from a full-scene image.

This is the primary scalability gate.

A concept image may exist, but the map must not depend on cutting its ordinary objects back out.

## 10. Stage I — Manual Map Assembly

The user assembles the final map using the approved kit.

The user controls:
- layout;
- routes;
- object placement;
- density;
- final landmark relationships;
- editor integration.

Check at actual RMVX scale during assembly.

## 11. Stage J — Assembly Visual QA

Before runtime derivatives:
- character/environment scale feels correct;
- paths/exits are readable;
- central movement space is not accidentally overcluttered;
- boundaries and focal hierarchy fit FS;
- repeated assets do not create obvious stamp patterns;
- transitions/roads/walls connect cleanly;
- no object is accidentally cropped or floating.

## 12. Stage K — Runtime Derivatives

Only after layout is stable, derive as required:
- Par / actor-occlusion overlays;
- light overlay;
- shadow overlay;
- collision/passability metadata;
- event/transfer anchors.

Source art should not be regenerated when a deterministic downstream mask/metadata operation is sufficient.

## 13. Stage L — RMVX Runtime Acceptance

Test in Forest Symphony using an actual actor.

Required checks:
- correct visual scale;
- intended routes are traversable;
- exits align to transfer/event logic;
- doors, stairs and bridges align with movement;
- actor passes behind intended occluders;
- no doubled objects/ghost layers;
- no obvious terrain seams;
- no impossible openings/invisible walls;
- lighting/shadow does not obscure gameplay readability.

## 14. Optional Concept / Master Reference

A full-scene concept may be generated at any point for art direction, but:
- it is optional;
- it is not the default geometry authority;
- it is not required to be decomposed;
- it cannot replace accepted modular assets;
- it must not force the benchmark back into the v1 flattened-scene workflow.

## 15. Benchmark PASS definition

The v2 benchmark passes only if:
1. the Reference Set and Style DNA are explicit;
2. the map's modular inventory is planned;
3. pilot families pass style/scale/perspective QA;
4. a usable production Asset Kit exists;
5. the user can assemble the intended map from that kit;
6. no ordinary required asset must be reverse-extracted from a flattened Master;
7. assembly visual QA passes at RMVX scale;
8. runtime derivatives compile/author successfully where needed;
9. actual RMVX traversal/occlusion acceptance passes.

Only then is the workflow considered proven for wider map production.

## 16. Legacy compatibility

`FS_MAP_BENCHMARK_WORKFLOW_V1.md` remains historical and may be used only when specifically studying or salvaging flattened concept scenes.

For new-map scalability evaluation, v2 is authoritative.