# FS Map Asset Prompt Workflow v3

Date: 2026-09-21  
Project: Forest Symphony / RPG Maker VX + Godot validation  
Status: **CURRENT DEFAULT NEW-MAP WORKFLOW**  
Authority: `FS_MAP_ASSET_PRODUCTION_AUTHORITY_V3_2.md`  
Supersedes: `FS_MAP_ASSET_PROMPT_WORKFLOW_V2.md` where conflicting

## 1. User command contract

The user may say:

> 用 FS v3.2 流程做一張小型森林測試地圖，VX/Godot 都要可測。

The agent expands that into the full workflow. The user does not need to author compiler/mask specs.

## 2. Required stages

0. Scope  
1. Reference Set / Style DNA  
2. Scene Blueprint  
3. Asset Inventory  
4. Source Asset Production  
5. Asset Normalization  
6. Semantic Authoring  
7. Scene Manifest  
8. Deterministic Compile  
9. Validation Gates  
10. VX Adapter/Test Build  
11. Godot Adapter/Test Build  
12. Delivery

No stage may be skipped merely because an image looks plausible.

## 3. First benchmark default

Unless explicitly overridden:

- 544x416;
- grass;
- one dirt path;
- 3 trees;
- 2 rocks;
- 1 sign;
- one spawn;
- only tree base/occlusion/collision depth is under test.

Do not add house/bridge/water/landmark before this passes.

## 4. Image-generation restriction

Legal image-generation targets:

- seamless terrain source;
- isolated reusable asset;
- optional concept reference;
- localized source-art edit;
- mask assistance.

Illegal final new-map generation targets:

- final Ground layer;
- final PAR/Occlusion layer;
- “same map without foreground”;
- “transparent foreground only”;
- a second generated copy of the same placed object for another runtime layer.

## 5. Source asset rule

Generate/accept one source asset and reuse it.

Do not regenerate the same placed object for a sibling layer.

## 6. Manifest rule

Every instance requires:

`instance_id, asset_id, x, y, anchor, z/draw_order, transform, semantics, collision reference`

No manifest = no compiled candidate.

## 7. Compile rule

Ground/Occlusion are compiler outputs, not image-generation outputs.

No deterministic compile report = no “compiled” claim.

## 8. Validation rule

Before delivery:

- inspect actual files;
- record validation gate status;
- fail closed on any required failure;
- repair before promotion.

Do not send an obvious failed candidate as successful.

## 9. Engine package rule

If VX/Godot testing is requested, actual engine adapters/packages are mandatory.

A PNG pair is insufficient.

## 10. Claim discipline

Do not claim:

`pixel-perfect / aligned / engine-ready / VX-ready / Godot-ready / test successful / PASS`

without matching validation evidence.

## 11. Failure diagnosis

Classify defects as:

`SOURCE_ART / NORMALIZATION / MANIFEST / REGISTRATION / MASK / COLLISION / COMPILER / VX_ADAPTER / GODOT_ADAPTER / RUNTIME_VISUAL`

Patch the smallest responsible source.

## 12. User review moment

For the minimum benchmark, the first user-facing visual review normally occurs **after deterministic composition exists**, not after a decorative concept sheet.

Concept sheets are optional and must be labeled CONCEPT.

## 13. Scale-up order

After minimum tree benchmark Formal PASS:

1. simple building;
2. bridge/water;
3. larger vegetation clusters;
4. landmark;
5. full map family.

Complexity is earned through passing tests.

## 14. Model policy

Any capable model/agent may plan or QA.

Image models create source art.

Deterministic code owns final map pixels.

Astra is optional.

**SEAL:** `FS_MAP_ASSET_PROMPT_WORKFLOW_V3_FAIL_CLOSED_20260921`
