# FS Castle Town — Step 3C NORTH PAR Validation

Date: 2026-08-19
Authority: MAP_DUAL_OUTPUT_AUTHORITY_V2_4
Status: FAIL — return to Step 3B

## Inputs
- Accepted Ground: 1448×1086 RGB
- Candidate NORTH PAR: 1536×1024 RGBA
- Castle Master: 1448×1086 RGBA

## Gate Results
1. Canvas / registration: FAIL
   - NORTH PAR dimensions do not match 1448×1086 Ground/Master.
2. Alpha integrity: FAIL
   - alpha=0 pixels: 53,985
   - alpha=255 pixels: 0
   - partial-alpha pixels: 1,518,879
   - structural PAR is effectively broad feathered transparency rather than pixel-crisp cutout.
3. PAR purity: FAIL
   - Candidate contains black/dark presentation background and metadata/text panel rather than asset-only content.
4. Placement Anchor QA: NOT RUN
   - Per v2.4 ordering, canvas/alpha/purity must pass before placement validation.

## Decision
Candidate is discarded. Do not resize or transform it to force registration.
Return to Step 3B and regenerate NORTH PAR only using accepted Ground + North Anchor Contract.
