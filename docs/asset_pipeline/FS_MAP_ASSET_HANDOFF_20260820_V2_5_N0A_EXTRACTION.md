# Forest Symphony MAP / Game Asset Pipeline Handoff — 2026-08-20

## Scope
Continue the Forest Symphony Castle Town / layered map authoring pipeline. Do **not** restart PixelLab/API transport work, Grounding-DINO threshold research, or earlier whole-scene PAR attempts.

This is an asset/map workflow checkpoint only. It does not alter the sealed Forest Symphony runtime/script baseline.

## Read Order
1. Google Drive `Forest Symphony/00_Project_Authority/MASTER_PROJECT_STATE.md`
2. Google Drive `Forest Symphony/05_Handoff/CURRENT_HANDOFF.md`
3. Google Drive shared `SHARED_GAME_ASSET_GENERATION_AUTHORITY`
4. Google Drive `Forest Symphony/00_Project_Authority/ASSET_GENERATION_PRECHECK_FS`
5. GitHub `MAP_DUAL_OUTPUT_AUTHORITY_V2_5.md`
6. Linear `SHO-39 | FS Map Style DNA + Forest Clearing Benchmark I`
7. This handoff and `FS_MAP_ASSET_HANDOFF_MANIFEST_20260820.json`

## Unchanged Runtime Authority
Phase49N5 remains SEALED. Current map/asset work must not modify or imply a change to the sealed runtime Scripts baseline.

## Current Mandatory Map Authority
**v2.5 — SOURCE-ASSET + DETERMINISTIC ASSEMBLY**

- `GROUND` = true ground/terrain surface + floor/road/plaza/terrain tiles + grass + flowers + water surfaces.
- `PAR` = EVERYTHING ELSE.
- Occlusion is not PAR membership authority.
- Image generation is source-art authority only, not final canvas / exact workcell / coordinate authority.
- Final PAR placement uses deterministic integer coordinates on the unchanged Ground canvas.
- Pixel-art resize, if accepted, uses Nearest Neighbor only.
- Default source-to-target scale viability profile = `0.75–1.25`; outside is Source Scale FAIL unless later authority records an exception.
- Normal structural alpha prefers `0/255`.
- `MASTER ≈ GROUND + COMPLETE PAR` remains the primary completeness authority.
- SAM2 / Guided SAM2 remains QA evidence only.

## Why v2.5 Exists
Prompt-only precision was empirically rejected. N0A requested `220×275`, but image generation returned `1491×1055`, with `36.76%` partial-alpha pixels and a target fit of only ~`15.7%`.

Do not resume endless prompt tuning to make the image generator behave like CAD.

## Castle Town Working Assets
Drive asset authority:
- `FS_CASTLE_TOWN_MASTER_REFERENCE_1448x1086.png`
- `FS_CASTLE_TOWN_GROUND_WORKING_1448x1086.png`
- `FS_CASTLE_TOWN_PLACEMENT_ANCHOR_CONTRACT_V1.json`
- `FS_CASTLE_TOWN_NORTH_ANCHOR_CONTRACT_V1.json`
- `FS_CASTLE_TOWN_NORTH_GENERATION_GUIDE_V1.json`
- `FS_CASTLE_TOWN_NORTH_DETERMINISTIC_ASSEMBLY_PLAN_V1.json`

Master and Ground are Working assets, NOT Runtime Approved.

The current Working Ground was deterministically recovered from the exact R4 composite by restoring the preserved N0A Ground workcell at `(600,30)`. It was not regenerated.

## NORTH State
Do not generate a full NORTH PAR again.

### N0A Main Castle Compound
Global bbox: `[600,30,820,305]`
Workcell: `220×275`

### N0A-R4 deterministic extraction candidate
- extracted directly from Master;
- no redraw;
- no resize;
- fixed integer placement `(600,30)`;
- opaque RGB remains Master-exact;
- alpha only `{0,255}`;
- partial alpha = `0`;
- opaque pixels = `39,235`;
- placement = PASS by construction.

Drive working files:
- `FS_CASTLE_TOWN_N0A_EXTRACTED_PAR_220x275.png`
- `FS_CASTLE_TOWN_N0A_BINARY_MASK_220x275.png`
- `FS_CASTLE_TOWN_N0A_EXTRACTION_CHECKERBOARD_220x275.png`
- `FS_CASTLE_TOWN_N0A_ON_GROUND_CLEAN_1448x1086.png`
- `FS_CASTLE_TOWN_N0A_ON_GROUND_QA_1448x1086.png`
- `FS_CASTLE_TOWN_N0A_R4_EXTRACTION_REPORT.json`

N0A-R4 is **not Formal PASS yet**.

## NEXT STEP — DO NOT SKIP
### N0A-R5 Mask Completeness + Ground-Leak QA
Validate the current binary extraction mask only:
1. all visible N0A castle structures that belong to PAR are included;
2. grass / road / terrain / Ground-class pixels are excluded;
3. structural stairs, castle body, roofs, towers, flags, banners and other non-Ground structure are not clipped;
4. opaque RGB remains identical to Master;
5. alpha remains `0/255`;
6. do not resize or move the `220×275` workcell;
7. composite at exact integer coordinate `(600,30)`.

If PASS: seal N0A, then proceed to **N0B only** with the same deterministic extraction/QA approach.
If FAIL: repair/refine the mask only. Do not generate N0B and do not revert to whole-region generation.

## Do Not Do
- Do not restart PixelLab/Cloudflare transport work.
- Do not continue Grounding DINO threshold tuning.
- Do not use a whole-SAM2-mask overlap percentage as PAR authority.
- Do not generate Ground + PAR simultaneously.
- Do not generate full-scene/full-NORTH PAR and call it registered.
- Do not rescale/move Ground to match PAR.
- Do not enter Collision / Exit / RMVX actor-scale tests before Layer Visual / recomposition genuinely passes.

## Handoff Status
`N0A-R4 COMPLETE -> N0A-R5 NEXT`
