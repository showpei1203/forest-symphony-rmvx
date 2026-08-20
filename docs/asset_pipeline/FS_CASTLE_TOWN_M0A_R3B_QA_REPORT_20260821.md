# FS Castle Town — M0A-R3B QA Report

Date: 2026-08-21
Authority: MAP_DUAL_OUTPUT_AUTHORITY_V2_7 + MID Batch A Ground Semantic Purity Gate
Branch workflow: SHO-39

## Asset
`M0A | Central Goddess Statue + Basin`

Parent M0 bbox: `[650,440,775,585]`
Formal child bbox: `[691,446,745,547]`
Workcell: `54×101`
Placement: `(691,446)`

## Result
**FORMAL VISUAL PASS**

Mechanical gates:
- source RGB Master-exact on opaque pixels: PASS
- alpha values: `{0,255}`
- partial-alpha pixels: `0`
- opaque pixels: `2,184`
- transparent pixels: `3,270`
- local alpha bbox: `[2,2,51,98]`
- no resize/redraw: PASS
- placement drift: `0 px`

## Ground Semantic Purity Proof
The original Working Ground already had the statue body removed, but its central stone basin/rim remained semantically structural. A local proof therefore replaced only the basin structural underlay with deterministic water-class source pixels.

- Ground pixels changed: `760`
- Ground pixels changed outside the basin correction target: `0`
- recomposition exact on all M0A-owned pixels: `2184/2184`
- interpolation / anti-aliasing: none

This is a local proof only; it does not globally promote the Working Ground to Runtime Approved.

## Ownership refinement
Parent `M0` is split into:
- `M0A` Goddess Statue + Central Basin = **PASS**
- `M0B` Structural Planter / Curb Border = **candidate / not PASS**

The parent M0 compound remains incomplete until M0B passes.

## Drive artifacts
Stored under `Forest Symphony/08_Assets/02_Working`:
- `FS_CASTLE_TOWN_M0A_R3B_EXTRACTED_PAR_54x101.png`
- `FS_CASTLE_TOWN_M0A_R3B_BINARY_MASK_54x101.png`
- `FS_CASTLE_TOWN_M0A_R3B_CHECKER.png`
- `FS_CASTLE_TOWN_M0A_R3B_QA_REPORT.json`
