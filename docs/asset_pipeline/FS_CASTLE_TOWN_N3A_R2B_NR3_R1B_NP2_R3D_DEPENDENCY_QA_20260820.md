# FS Castle Town — N3A-R2B / NR3-R1B / NP2-R3D Dependency QA

Date: 2026-08-20
Authority: MAP_DUAL_OUTPUT_AUTHORITY_V2_7
Branch workflow: SHO-39

## Root cause
Fresh recomposition from the true Ground base exposed that N3A-R1D under-owned its purple roof silhouette. Placement `(867,164)` was proven correct by exact Master pixel sampling; the defect was mask completeness, not registration.

## N3A-R2B
- placement `(867,164)`
- workcell `153×148`
- opaque `8,843 px`
- added vs R1D: `955 px`
- Master-exact RGB on all opaque pixels: PASS
- alpha `{0,255}`, partial alpha `0`
- true purple-roof residual after R2B: `0 px`
- six classifier residual pixels remain outside roof silhouette and are Ground texture false positives

## Dependency ownership transfers
Completing the foreground roof exposed historical ownership that had filled the old hole:
- NR3-R1A canopy/fence owned `47 px` now visibly covered by N3A roof
- NP2-R3C east back wall owned `99 px` now visibly covered by N3A roof

Authority rule: foreground visible roof owns these pixels. Background owners must retreat rather than forcing N3A to remain incomplete.

### NR3-R1B
- old opaque `3,779 px`
- new opaque `3,732 px`
- exactly `47 px` transferred to N3A
- Master-exact RGB retained

### NP2-R3D
- old opaque `29,210 px`
- new opaque `29,111 px`
- exactly `99 px` transferred to N3A
- East Back Wall geometry remains unchanged; only pixels visually covered by N3A are relinquished
- Master-exact RGB retained

## Dependency revalidation
After transfer:
- N3A vs NR3 = `0 px`
- N3A vs NP2 = `0 px`
- NR3 vs NP2 = `0 px`
- N3A vs all other accepted owners = `0 px`
- NR3 vs all other accepted owners = `0 px`
- NP2 vs all other accepted owners = `0 px`

Fresh union opaque after correction: `249,321 px` (`+807 px` vs prior 23-asset fresh aggregate).

## Authority result
- **N3A-R2B = FORMAL PASS**, supersedes N3A-R1D
- **NR3-R1B = FORMAL PASS**, supersedes NR3-R1A
- **NP2-R3D = FORMAL PASS**, supersedes NP2-R3C

No Ground movement, no resize, no redraw. All new/retained opaque pixels are exact Master source pixels.
