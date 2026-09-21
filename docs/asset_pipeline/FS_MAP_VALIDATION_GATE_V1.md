# FS Map Validation Gate v1

Date: 2026-09-21  
Project: Forest Symphony / RPG Maker VX + Godot  
Status: **MANDATORY PRE-DELIVERY GATE**  
Authority: `FS_MAP_ASSET_PRODUCTION_AUTHORITY_V3_2.md`

A candidate may not be promoted or delivered as engine-ready until all applicable gates pass.

## Gate A — Canvas

PASS requires:

- declared expected dimensions;
- sibling runtime outputs match exact dimensions;
- no unintended resizing/cropping;
- integer pixel grid.

Evidence: dimensions + hashes.

## Gate B — Manifest

PASS requires:

- Scene Manifest exists;
- unique `instance_id`;
- every instance resolves to an accepted `asset_id`;
- integer x/y;
- explicit anchor/transform;
- semantic/collision references resolve where required.

Evidence: manifest validation report.

## Gate C — Registration

PASS requires:

- one canonical placement per instance;
- Ground and Occlusion derive from that same placement;
- no independently generated sibling layer;
- known test anchors match exactly;
- no object drift.

Evidence: compiler report + coordinate audit.

## Gate D — Recomposite / Visual

PASS requires:

- deterministic composite/preview generated from actual outputs;
- no duplicate/ghost structure;
- no obvious shift;
- no clipped occluder;
- no mask hole;
- no seam/sub-pixel blur;
- agent actually inspects the preview before delivery.

Evidence: composite preview + QA report.

## Gate E — Semantic / Collision

PASS requires:

- tested actor-depth semantics are correct;
- occlusion uses intended asset parts;
- collision/passability matches visible geometry;
- spawn is not blocked;
- test path is traversable.

Evidence: mask/collision audit.

## Gate F — Engine Import

### VX PASS

- files placed/imported in actual expected runtime structure;
- test map loads;
- actor spawns;
- movement works;
- occlusion behaves as intended;
- no missing-file/runtime error.

### Godot PASS

- project/scene imports;
- textures resolve;
- actor/test scene runs;
- collision works;
- draw order/occlusion works;
- no missing-resource/runtime error.

Evidence: runtime screenshot/log/test note as available.

## Status rule

A-E pass, engine not tested:
**COMPILED CANDIDATE**

Package exists but engine not exercised:
**ENGINE TEST BUILD / UNVERIFIED**

Relevant Gate F passes:
**ENGINE TEST BUILD PASS**

Project-required gates + user acceptance:
**FORMAL PASS**

## Automatic FAIL

- independent generated Ground/PAR siblings;
- no Scene Manifest;
- no compile report;
- mismatched dimensions;
- fake checkerboard transparency presented as alpha without verification;
- obvious visual drift/duplication;
- missing requested collision;
- PNG pair presented as complete VX/Godot build;
- unverified PASS claim.

**SEAL:** `FS_MAP_VALIDATION_GATE_V1_FAIL_CLOSED_20260921`
