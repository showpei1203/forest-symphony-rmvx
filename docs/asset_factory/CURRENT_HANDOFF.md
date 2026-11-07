# FS AI Asset Factory CURRENT_HANDOFF — A09 | 2026-11-08

**ACTIVE NEXT CHAT ENTRYPOINT: A10 real family-level art and full-scene source generation.** No more A06 railing-pixel fixes or A08-only rules expansion. The A08 22-page audit and Sprite/Map Factory SOPs remain mandatory. All source-art/game assets stay private.

## Authority and current stage
- Global FS P0-P6, [Sprite SOP](FS_SPRITE_FACTORY_SOP_V1_20261108.md), [Map SOP](FS_MAP_FACTORY_SOP_V1_20261108.md), [22p research mapping](A08_REPORT_22PAGE_IMPLEMENTATION_AUDIT_20261108.md), [A08-A12 queue](A08_DUAL_FACTORY_EXECUTION_QUEUE_20261108.md).
- Branch `feat/fs-asset-factory-v1-20261107`, [Draft PR #15](https://github.com/showpei1203/forest-symphony-rmvx/pull/15), main untouched.
- [A09 public source & two-scene QA](A09_SOURCE_LOCKED_SPRITE_AND_SEMANTIC_SCENE_QA_20261108.md); private full A09 QA and Handoff stored in owner-only `FS_AI_ASSET_FACTORY_Restricted_Rules` (find by titles FS_ASSET_FACTORY_A09_* through user's Drive authority index); actual PNG/XML/ZIP solely in restricted Binaries.

## Actual Sprite deliverable (not conceptual art)
- Recovered PRIVATE P3_G9_FULL_EVOLUTION_CHAIN_0001_0003_20261027.zip: `3,881,101` bytes, `1,128` entries, ZIP SHA256 `74061d61a7fde6650699ee30ad1339ff255924a9cae13c98cb1703478eae260f`, CRC PASS.
- Historical scope: PMD0001 G3R1 is user-accepted native all-action baseline; G8R4/G8R5 selected keyframes of PMD0002/0003 accepted, but 1356 newly generated G9 0002/3 frames require human art review. Do not promote 0002/3 full-art approval.
- Native source PMD0001 `AnimData.xml` SHA `c7722f5da724f40f35fccabb1135fbd1b70e770b2a38db3d9fbe7643af626162`; original Idle 32x40 ×3 frames ×8 direction rows, Walk 40x40 ×6 ×8; native Anim/Offsets/Shadow all intact. PMD0002/0003 Idle and Walk 32x32 ×4 ×8. In each of six action atlases, eight row first-frames have eight different RGBA values. Direction row NAMES and native eight-direction animation semantics still not certified.
- A62 approved 48px three-pose Actor run source extracted from sealed private A63. F0 SHA `a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba`; 144×48 strip SHA `ea063e6ec2db5caf3bddb2dd0b277d888f60e65fe6392bccdad4fdcc34274d5f`. Playback 0,1,0,2. No new Tankentai validation.
- **Actual delivered restricted ZIP** `FS_A09_SOURCE_LOCKED_SPRITE_FACTORY_PILOT_20261108.zip`, `217,991` bytes, `37` files, SHA256 `9b1465828dd40b4fedf63e49f7598583b2a08ac9e2181c5a0c85ebb86c5b389a`, ZIP CRC PASS; uploaded & downloaded back from owner-only Google Drive Restricted_Binaries, shared=false. Contains original PMD0001/2/3 six actions' XML/Anim/Offsets/Shadow PNG, eight-row previews/pose metrics, A62 independent three frames PNG/GIF, manifest. These are reused existing real sprites, **not new AI-generated art**.
- A25 separate new 64px PixelLab concept source archive remains SOURCE_NOT_VERIFIED and must NOT be confused with recovered G9 source. A26 five-frame candidate Idle/Walk not accepted native 3/6.

## Actual Map production and authoritative style source
- Verified authentic local project `Graphics/Parallaxes/ground3.png`, not `Overlays/ground3.png`. Read-only Windows file SHA `ddc1f21e1d23dcb8258a20baa2acb106d1c0e56683a4dc280faedc23bcd47a13`, size `2,400,808` bytes. No PC source altered or new workfiles created; ground3 art bytes were NOT copied to new maps in A09.
- New public source `tools/asset_factory/scene_blueprint.py`: SAME 40×29 grid/32px family template, DIFFERENT `ELF_VILLAGE` seed 20261108 and `FOREST_BRIDGE` seed 20261203. Authoring source-role objects include whole workshop houses, canopy groups, bridge deck/far/near rail and posts, water and seeded grass/flowers/pebbles.
- `bridge_deck` role GROUND_ONLY and `bridge_near_rail` CONDITIONAL_FOREGROUND with missing actual object art/mask. This is designed before rendering, so no manual GrabCut guessing brown wood. Ground3 true style SHA pinned; real semantic object art and full scene Master still NOT generated.
- New `tools/asset_factory/export_a09_scenes.py` emits 2 Tiled object-layer `.tmj` designs, 2 JSON blueprints and SHA manifest inside GitHub Actions, published as non-art artifact. Earlier successful build artifact [FS_A09_Tiled_Semantic_Blueprints](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/42424904974/artifacts/13595047682), SHA `50a05e6e99ef555ce8540c48471d0553b78137eaab6bc18c35c853ddc76a7048`. These are geometry, NOT completed Ground or PAR PNG.
- Shared template had one early 8-digit-date-seed validation error causing 7 CI errors; fixed in generator. Later actual 95/95 test run passed. This is the desired template-level correction, not pixel-by-pixel repair.
- Public metadata config `config/asset_factory/FS_A09_REAL_SOURCE_BRIEF_V1.json` records verified source SHA, approval scope, art holds, style SHA, current cost and scene IDs.

## Gate matrix; mandatory truthful labels
- SPRITE_SOURCE_REAL: PASS. PMD0001 G3R1 historical art baseline approval only; PMD0002/3 G9 newly generated frames ART_HOLD; A62 runner motion historical accepted only.
- ART_NEW_PMDS/ACTORS: NOT_CREATED in this turn; native Game.exe/PMD integration A09: NOT_RUN.
- GROUND3_STYLE_SOURCE_SHA: PASS (reference hash only). TWO_SCENE_SEMANTIC_GEOMETRY: PASS. MASTER_RGB / Authoring CompletePAR / Runtime FullGround / OcclusionPAR for newly generated scene: NOT_CREATED. A09 Native Switch203: NOT_RUN.
- PixelLab paid calls: 0. Orca new agents: NOT_LAUNCHED (permission gate). PC new persistent files: 0. Main untouched; formal seal NO.

## A10 exact action order
1. Reuse A09 native 0001/A62 actual approved appearance, build family-level *motion rig/pose source* from real action frames without overriding XML per-action counts. Use G9 0002/3 newly generated frames as QA candidate, not approved material. A25 distinct source remains a separate missing item.
2. Take authentic Ground3 palette/material/1x look as the art baseline. Build complete tree, house/workshop and bridge object-family SOURCE art and object-only masks **together**. Fill both semantic scene layouts with SAME family kit, preserving coherent full Master. No color segmentation from already flattened map, no V0/V1/V2 railing micro-trimming.
3. Only once actual art source and user-approved bounded PixelLab batch exist, run one limited provider test; never guess availability/credit balance or make unapproved paid calls.
4. Export full four FS layers and per-object Source IDs, legal footpoint depth, collision. Native Windows VX Game.exe requires separately scoped temp authorization/cleanup. Judge both scene-scale 1x aesthetics and motion before scaling beyond pilots.
5. Each stage: GitHub PR feature source only, private Drive QA/Handoff + binary source readback, final PR HEAD CI SHA/run and unresolved gates. Keep old A01-A09 evidence immutable.

Rollback only feature branch. No main merge, no sealed original source overwrite.