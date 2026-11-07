# Forest Symphony — Asset Generation Precheck

## 2026-11-07 FS 新版本強制優先（P0 + Master-first）
開工前先讀 [P0 Cloud-only](docs/FS_CLOUD_ONLY_STORAGE_POLICY_20261107.md)：成果與證據存 Drive/GitHub，PC 僅必要安裝/最短實機臨時副本；不准把 E: 目錄/快取當輸出庫。
**FS 新精靈村 ACTIVE 方法**：一張完整高品質 MASTER 作唯一 RGB/world-XY 權威，AI Ground-only 只作底下地表補繪候選，AI PAR 只作物件語意遮罩候選。作者層 `GroundOnly+CompletePAR`、Runtime 層 `FullGround+OcclusionPAR` 分開；每個可見前景像素從同一 MASTER XY 取樣。真實 RPG Maker VX Map050、203 開關、可走格進出遮擋／空地負例和 USER ART Gate 全部必須另驗證。合成零差是建構式技術指標，不等於完整語意或美術 PASS。
**下方 v2.5 GROUND-FIRST 流程僅對其當年的既有 Ground-first 分支與其他未指定 Master-first 的使用情境保留。**兩種方法的最終 Source SHA／Manifest／Alpha／Scale／Collision／Passability／Art Gate 一樣嚴格。 [V3 Native 實驗](experiments/agent_skills_20261107/MASTER_FIRST_V3_NATIVE_203_COLLISION_HANDOFF.md) 只是局部 Canopy PASS，Formal Seal NO。

**Mandatory before every image generation or image edit.**

1. Read Google Drive shared `SHARED_GAME_ASSET_GENERATION_AUTHORITY`.
2. Read Drive `Forest Symphony/00_Project_Authority/ASSET_GENERATION_PRECHECK_FS`.
3. Apply the latest FS Style DNA / accepted benchmark / sealed visual authority.
4. For any layered map/parallax/environment work, read `MAP_DUAL_OUTPUT_AUTHORITY_V2_5.md` before generation or extraction.

## Legacy general layered-map mode — v2.5 (NOT current FS new-village Master-first)
Use:
`GROUND-FIRST + PLACEMENT ANCHORS + SOURCE-ASSET/EXTRACTION + DETERMINISTIC ASSEMBLY + PAR PURITY + PIXEL-CRISP`

- `GROUND = true ground/terrain + floor/road/plaza/terrain tiles + grass + flowers + water surfaces`.
- `PAR = EVERYTHING ELSE`.
- Occlusion is not PAR membership authority.
- Ground is generated/accepted first and becomes the base geometry authority.
- Major structures require unique Placement Anchor Contracts.
- Image generation is source-art authority only; it is **not** final canvas, exact workcell, scale or coordinate authority.
- Prefer Master/existing-art extraction when exact source pixels already exist.
- Final PAR placement uses deterministic integer coordinates on the unchanged Ground canvas.
- Default source-to-target viability profile is `0.75–1.25`; outside this range is Source Scale FAIL unless a later explicit authority approves an exception.
- Pixel-art resize/downsample, if approved, uses Nearest Neighbor only.
- Normal structural alpha should prefer `0/255`; broad partial-alpha haze/feather/AA is DRAFT/FAIL evidence.
- Validate every object/group before proceeding to the next.
- Primary completeness authority remains `MASTER ≈ GROUND + COMPLETE PAR`.

## FS scale / style inheritance
- 32×32 is the RMVX world-scale player/tile reference, not a total map-canvas limit.
- 544×416 is a viewport reference only.
- Large villages/castles/dungeons/parallax scenes may be larger while preserving 32px world scale.
- Monsters are not limited to 32×32.
- Runtime isolated pixel assets should use crisp edges, no AA, approved palette, and chroma key only when appropriate for reusable source assets.

## SAM2 authority
- SAM2 / Guided SAM2 is semantic QA / omission evidence only.
- Never accept a raw union mask as Ground/PAR/Collision truth.
- Do not use a universal whole-mask overlap percentage as a formal PAR gate.
- Prefer witness/core-structure QA for important objects.

## Layer-Split Quality Gate
A candidate remains **DRAFT** unless applicable checks pass:
1. exact canvas/registration authority;
2. no visible PAR structure duplicated in Ground;
3. exhaustive PAR ownership;
4. clean alpha / no Ground leakage;
5. per-anchor placement correctness;
6. pixel-crisp edges at integer zoom;
7. `MASTER ≈ GROUND + COMPLETE PAR` recomposition;
8. witness/high-risk omission QA.

## Required read order
**FS new-village ACTIVE:** `FS Current Rules Index -> P0 Cloud-only -> Shared Authority -> FS Precheck -> Style/MASTER art Gate -> freeze one MASTER -> AI segmentation + hidden underpaint -> source-registered Authoring/Runtime four layers -> per-object QA -> native Map050 / 203 movement / empty control -> final User Art Gate`.
**LEGACY v2.5:** `Shared Authority -> Project Precheck -> MAP_DUAL_OUTPUT_AUTHORITY_V2_5 -> Ground -> Ground QA -> anchors -> source/extraction -> deterministic assembly -> recomposition/witness QA`.

Version: 2026-08-20 v2.5
