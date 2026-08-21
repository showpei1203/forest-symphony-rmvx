# FS Castle Town SW Junction / K07 Boundary Audit R3 — 2026-08-21

## Result

**BOUNDARY AUDIT R3 PASS — final child staging geometry for current SWJ parent.**

R3 supersedes R2 only for Child B's lower extraction margin. Parent R2 extent, sealed Child A and Child C staging remain otherwise unchanged.

## Trigger

The first Child B R2 extraction inside `[155,625,245,735]` still placed `5` valid wall pixels on its bottom boundary. The incoming west-wall face visibly tapers below the old bottom and does not fully clear until approximately global `y=745`.

This was detected before any Child B artifact was accepted.

## Final parent / children

Parent staging bbox remains:

`[155,625,410,825]`

### Child A — SEALED

`[200,640,305,770]`, canonical K07 R1E. No changes.

### Child B — FINAL STAGING

`[155,625,245,755]`

Workcell `90×130`, placement `(155,625)`.

Accepted structural pixels may touch the top boundary because global row `625` is the declared upstream seam from sealed West Mid row `624`.

Bottom / left / right boundaries must be clear.

### Child C — unchanged staging

`[205,690,410,825]`

Final C mask must subtract A+B ownership and exclude the next lower corner tower.

## Child B semantic split from Child C

For the ambiguous lower-right junction region, Child B owns the incoming wall/wall-face continuation from the west perimeter. Outgoing diagonal-wall pixels are reserved for Child C.

Current deterministic split reserves the region at global `y>=700, x>=220` for Child C unless already owned by sealed Child A.

This is an ownership rule, not a crop rule. Child workcells may overlap.

## Required upstream seam proof

West Mid R1C bottom footprint on global row `624` must match Child B top footprint on row `625` exactly.

The accepted Child B candidate proves:
- West Mid row624 owner x-range: `172..195`
- pixels: `24`
- Child B row625 owner x-range: `172..195`
- pixels: `24`
- exact footprint match: PASS

## Evidence

Drive boundary witness:
`FS_CASTLE_TOWN_SWJ_K07_BOUNDARY_AUDIT_R3_WITNESS_3X.png`
Drive ID: `1rt-zy_QJP-qcquWgsGoU1N1Itz8ppZIt`

## Supersession

- R1: original parent/B/C geometry superseded.
- R2: parent and C geometry retained; B `[155,625,245,735]` superseded due bottom contact.
- R3: current active SWJ boundary authority.

## Status

`SWJ A R1E SEALED -> SWJ BOUNDARY R3 PASS -> CHILD B R1A FORMAL QA`
