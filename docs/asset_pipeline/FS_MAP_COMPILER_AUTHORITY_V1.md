# FS Map Compiler Authority v1

Date: 2026-09-21  
Project: Forest Symphony / RPG Maker VX  
Status: **CURRENT WHOLE-MAP COMPILER AUTHORITY FOR NEW MAPS**  
Related: SHO-39  
Supersedes: `FS_MAP_COMPILER_PROTOTYPE_V0_2.md` for new whole-map production

## 1. Purpose

The compiler converts an accepted modular Asset Kit plus one canonical Scene Manifest into reproducible RMVX map/runtime derivatives.

It is a deterministic renderer/compiler, not an image generator.

## 2. Inputs

Required:

- canvas/grid definition;
- `SceneManifest`;
- accepted source assets referenced by stable IDs;
- source dimensions and approved integer transforms;
- semantic masks/parts where needed.

Optional:

- collision polygons;
- event/transfer anchors;
- light/shadow masks;
- Style DNA / Blueprint IDs for report provenance.

## 3. Canonical placement

Each object instance has one authoritative placement record.

All outputs reuse the same:

- asset ID;
- x/y;
- anchor;
- scale/transform;
- z/draw order;
- semantic masks.

No output is allowed to invent a separate placement for the same instance.

## 4. Pixel rules

- integer coordinates only;
- no sub-pixel placement;
- no smoothing;
- Nearest Neighbor only for approved pixel-art resize;
- no silent source redraw;
- clipping/canvas bounds are explicit;
- deterministic input must produce deterministic output bytes where encoding settings are fixed.

## 5. Semantic composition

An asset may contribute to multiple derivative targets through explicit masks/parts.

Typical channels:

- base/Ground;
- actor occlusion/PAR;
- collision/passability;
- shadow/light;
- event/transfer.

Object category by itself is not sufficient depth authority.

## 6. Outputs

Expected per-map outputs may include:

- `MapXXX_Ground.png`
- `MapXXX_Par.png` / `MapXXX_Occlusion.png`
- `MapXXX_Shadow.png`
- `MapXXX_Light.png`
- `MapXXX_Collision.json`
- `MapXXX_Events.json`
- `MapXXX_SceneManifest.json`
- `MapXXX_CompileReport.json`
- hashes/checksums

Projects may omit channels that are not required.

## 7. Compile report

Record at least:

- compiler version;
- manifest version/hash;
- source asset IDs/hashes where available;
- canvas dimensions;
- placed instance count;
- warnings/failures;
- output dimensions;
- output hashes;
- reproducibility status.

## 8. Blocking conditions

Compilation or promotion must fail closed on:

- missing source asset;
- duplicate `instance_id`;
- invalid mask dimensions;
- non-integer placement where integer is required;
- out-of-policy scaling;
- unresolved canvas overflow;
- missing required semantic data;
- ambiguous duplicate placement authority.

Do not silently repair semantic ambiguity.

## 9. Visual QA integration

Compiler PASS is structural, not final visual acceptance.

Preferred loop:

`compile -> RMVX/preview -> screenshot -> visual diagnosis -> manifest/mask/source patch -> recompile`

A placement failure is fixed in the manifest.  
An occlusion failure is fixed in semantic masks/metadata.  
A collision failure is fixed in collision metadata/code.  
Only source-art defects should normally trigger image regeneration.

## 10. Model independence

The compiler must be ordinary deterministic code/data and MUST NOT require a particular LLM.

An AI model, including GPT-6 Astra, may author or patch a Scene Manifest and may drive QA, but the same manifest/assets must compile without that model.

## 11. Legacy note

`FS_MAP_COMPILER_PROTOTYPE_V0_2.md` remains historical single-object prototype evidence and may still describe legacy parallax experiments.

It is not the authority for new multi-object/whole-map production.

## 12. Promotion gate

Whole-map compiler production readiness requires:

1. repeat compilation from identical inputs yields matching outputs/hashes;
2. multiple objects preserve exact placement across every derivative;
3. base/occlusion masks behave correctly on mixed-depth assets;
4. RMVX actor-scale traversal/occlusion test passes;
5. visual QA can identify and repair a local defect without whole-map regeneration.

**SEAL:** `FS_MAP_COMPILER_AUTHORITY_V1_DETERMINISTIC_WHOLE_MAP_20260921`
