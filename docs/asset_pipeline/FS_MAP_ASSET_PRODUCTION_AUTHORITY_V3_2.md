# FS Map Asset Production Authority v3.2

Date: 2026-09-21  
Project: Forest Symphony / RPG Maker VX + Godot validation  
Status: **CURRENT DEFAULT AUTHORITY FOR NEW MAP PRODUCTION**  
Related: SHO-39  
Supersedes: `FS_MAP_ASSET_PRODUCTION_AUTHORITY_V3_1.md` where conflicting

## 0. Why v3.2 exists

A failed benchmark produced a visually plausible full map and a separately generated foreground layer and treated them as if they were compiled engine-ready outputs.

They did not share canonical geometry, source pixels, Scene Manifest placement, semantic masks, collision data or engine-import evidence.

v3.2 makes that failure mode fail-closed.

## 1. Prime directive

> **GENERATE ASSETS. COMPILE MAPS. VERIFY BEFORE DELIVERY.**

For new maps:

- image generation may create source assets or concept references;
- image generation MUST NOT directly create final Ground/PAR sibling outputs;
- Ground/PAR/Occlusion/Collision/Event derivatives MUST come from the same deterministic scene data;
- a pretty picture is never evidence of layer correctness.

## 2. Forbidden shortcut — HARD FAIL

Prohibited:

`Generate full map -> separately generate foreground/background -> visually assume alignment -> deliver as engine-ready`

Also prohibited:

- independently generating Ground and PAR;
- cropping final runtime layers from an infographic/mockup;
- resizing/warping one generated layer to resemble another;
- treating checkerboard-looking pixels as real alpha without verification;
- calling a concept/mockup/separately generated layer an Engine Test Build;
- claiming pixel-perfect/aligned/compiled/VX-ready/Godot-ready/PASS without validation evidence.

Any occurrence = **FAIL-CLOSED**.

## 3. Artifact classes

Every output must be one class:

- **CONCEPT** — mood/composition only.
- **SOURCE ASSET** — reusable terrain/prop/building/tree/etc.
- **COMPILE INPUT** — manifest/masks/collision/canvas metadata.
- **COMPILED CANDIDATE** — deterministic compiler output, not engine-accepted yet.
- **ENGINE TEST BUILD** — actual VX/Godot-consumable test package.
- **FORMAL PASS** — required engine/validation gates passed.

Never promote CONCEPT/SOURCE ASSET directly to COMPILED CANDIDATE or ENGINE TEST BUILD.

## 4. Minimum benchmark rule

A new pipeline starts with the smallest scene that proves the mechanism.

Default first Ground/PAR benchmark:

- 544x416 canvas;
- simple grass;
- one dirt path;
- 3 trees;
- 2 rocks;
- 1 sign;
- one actor/start position;
- only tree occlusion/collision depth is under test.

No house, bridge, water, landmark or decorative complexity until this passes unless explicitly overridden.

## 5. Single-origin source asset rule

Each object family/instance originates from one accepted source asset.

Example:

`Tree_01.png -> base_mask + occlusion_mask + collision polygon`

The compiler may derive multiple runtime outputs from that one source.

A second generated “foreground Tree_01” is illegal.

## 6. Scene Manifest single source of truth

Each placed instance requires one canonical record with at least:

- `instance_id`
- `asset_id`
- integer `x/y`
- `anchor`
- `z/draw_order`
- source dimensions
- approved transform
- base/ground semantic reference
- occlusion semantic reference
- collision/passability reference
- event/transfer metadata where applicable
- source hash/version where available

No separate Ground-coordinate and PAR-coordinate authorities for the same instance.

## 7. Semantic depth rule

Depth is pixel/part based, not category based.

Examples:

- tree lower trunk/base versus canopy;
- building lower facade versus roof/upper facade;
- bridge walkable deck versus front rail/arch.

Use explicit masks/parts for mixed-depth assets.

## 8. Deterministic compiler rule

Compiler uses:

- same canvas;
- same placements;
- same source assets;
- same transforms;
- same semantic masks.

Rules:

- integer coordinates;
- no sub-pixel drift;
- no smoothing;
- Nearest Neighbor only for approved resize;
- no silent AI redraw during compile;
- no independent generative repaint per runtime layer.

## 9. Mandatory pre-delivery validation

No compiled candidate may be delivered before all applicable gates in `FS_MAP_VALIDATION_GATE_V1.md` pass.

Required gates:

A. Canvas  
B. Manifest  
C. Registration  
D. Recomposite / Visual  
E. Semantic / Collision  
F. Engine Import

Any required FAIL keeps the candidate FAIL/DRAFT.

## 10. Self-check evidence

Before presentation the agent must inspect actual artifacts.

Evidence includes as applicable:

- exact dimensions;
- actual alpha/transparency;
- manifest instance count;
- source asset IDs;
- coordinate consistency;
- deterministic composite;
- compiler report;
- collision metadata;
- engine-import evidence.

Do not infer these from appearance.

## 11. Engine Test Build definition

### VX

Requires:

- exact Ground/Par files for the current VX runtime profile;
- map/runtime integration files or configuration;
- passability/collision setup;
- spawn;
- test procedure;
- package structure that can actually be copied into the project.

### Godot

Requires:

- importable project or scene;
- referenced textures;
- deterministic object placement;
- collision objects/data;
- actor/start or minimal movement test;
- run/test instructions.

A PNG pair alone is **not** an Engine Test Build.

## 12. Cross-engine authority

VX and Godot may use different runtime adapters, but should consume the same canonical Scene Manifest and accepted source assets.

Preferred:

`Canonical Scene Manifest -> VX Adapter + Godot Adapter`

Do not maintain two manually redrawn maps.

## 13. Repair policy

Repair the smallest responsible artifact:

- wrong art -> source asset
- wrong position -> manifest
- wrong occlusion -> semantic mask
- wrong collision -> collision metadata
- wrong export -> compiler/adapter
- wrong engine behavior -> runtime integration

Whole-map regeneration is not the default fix.

## 14. Claim discipline

Use exact statuses:

`CONCEPT / SOURCE ASSET / DRAFT / COMPILED CANDIDATE / ENGINE TEST BUILD / UNVERIFIED / ENGINE TEST BUILD PASS / FAIL / FORMAL PASS`

Do not loosely use “成品”, “可直接測試”, “成功” or “PASS”.

## 15. Model policy

The pipeline is model-agnostic.

GPT-6 Astra may accelerate tool, visual and runtime loops, but the manifest, masks, compiler, validation gates and engine packages must remain reproducible without it.

## 16. Formal PASS

Formal PASS requires:

1. accepted source assets;
2. stable Scene Manifest;
3. deterministic compile;
4. mandatory validation gates PASS;
5. local defects repairable without whole-map regeneration;
6. VX pass when VX requested;
7. Godot pass when Godot requested;
8. claimed outputs read back/inspected.

**SEAL:** `FS_MAP_ASSET_PRODUCTION_V3_2_FAIL_CLOSED_ENGINE_TEST_20260921`
