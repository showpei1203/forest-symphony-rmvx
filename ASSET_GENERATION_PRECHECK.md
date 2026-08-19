# Forest Symphony — Asset Generation Precheck

**Mandatory before every image generation or image edit.**

1. Read Google Drive shared `SHARED_GAME_ASSET_GENERATION_AUTHORITY`.
2. Read Drive `Forest Symphony/00_Project_Authority/ASSET_GENERATION_PRECHECK_FS`.
3. Apply the latest FS Style DNA / accepted benchmark / sealed visual authority.
4. For any layered map/parallax/environment work, read `MAP_DUAL_OUTPUT_AUTHORITY_V2_5.md` before generation or extraction.

## Current layered-map mode — v2.5
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
`Shared Authority -> FS Drive Precheck -> MAP_DUAL_OUTPUT_AUTHORITY_V2_5 -> latest FS benchmark/handoff -> Ground -> Ground QA -> anchors -> source/extraction -> deterministic assembly -> per-object QA -> recomposition/witness QA`

Version: 2026-08-20 v2.5
