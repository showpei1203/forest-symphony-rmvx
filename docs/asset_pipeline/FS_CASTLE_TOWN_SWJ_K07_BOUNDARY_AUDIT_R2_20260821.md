# FS Castle Town SW Junction / K07 Boundary Audit R2 — 2026-08-21

## Result

**BOUNDARY AUDIT R2 PASS — R1 child/parent geometry superseded before Child B acceptance.**

Child A K07 R1E remains sealed and unchanged. R2 exists because Child B extraction witness proved that the original B bottom boundary at `y=700` cut through continuing structural wall pixels, while the original parent / Child C right-bottom extent also clipped the outgoing diagonal wall before the next lower corner tower.

## Root finding

R1 Child B bbox `[155,625,230,700]` produced `58` opaque wall pixels touching its bottom boundary. Visual inspection showed these were not an arbitrary crop artifact: the incoming west-wall face remains visible below `y=700` before terminating into grass / the K07 junction.

R1 Child C `[255,690,365,800]` and parent `[155,625,365,800]` were also too tight. The outgoing diagonal wall remains visible toward the next lower corner tower beyond the R1 right/bottom staging boundary.

Therefore no R1 Child B mask is accepted.

## Locked R2 parent workcell

Parent semantic name: **SW Junction / K07 Perimeter Turn**

R2 parent staging bbox:

`[155,625,410,825]`

Workcell:

`255×200`

Placement:

`(155,625)`

The next lower corner tower is intentionally inside the enlarged staging workcell as extraction margin only. It remains a hard semantic exclusion and is not transferred to SWJ ownership.

## R2 child staging zones

### Child A — K07 Tower / Immediate Junction

**SEALED, UNCHANGED**

- bbox `[200,640,305,770]`
- canonical `R1E`
- opaque `3,352 px`
- all four child boundaries clear
- West Mid overlap `0 px`

### Child B — West Seam Connector

R2 staging bbox:

`[155,625,245,735]`

Workcell `90×110`.

Purpose:
- consume the exact wall continuation from the sealed West Mid row `624/625` seam;
- own the full remaining incoming wall / wall-face silhouette until it terminates into the K07 junction / ground;
- provide enough lower/right margin so the accepted owner mask must not be clipped by the old `y=700` boundary.

Final B mask must subtract Child A owner pixels.

### Child C — Outgoing Diagonal Wall

R2 staging bbox:

`[205,690,410,825]`

Workcell `205×135`.

Purpose:
- own the complete diagonal wall leaving K07 toward the next lower corner tower;
- allow overlap with A/B workcells for extraction margin while final owner masks remain disjoint;
- stop ownership before the next lower corner tower roof/body even though that tower appears inside the workcell.

## Seam rules

### Upstream West Mid seam

Sealed West Mid R1C owns through global row `624`. Child B begins at row `625`.

Required proof:
- West Mid × Child B owner overlap `0 px`;
- row `624/625` visible wall footprint has no gap;
- no pixel transfer occurs without explicit dependency revalidation.

### A/B/C internal ownership

Child workcells may geometrically overlap. Final binary owner masks may not.

Extraction order remains:
1. A sealed;
2. B extracts incoming wall and subtracts A;
3. C extracts outgoing wall and subtracts A+B.

### Next lower corner tower

The purple-roof lower tower centered near the outgoing wall endpoint is a future parent. Its roof/body/tower masonry must remain excluded from Child C.

If the outgoing wall physically meets that future tower at a shared pixel seam, the later tower audit must perform explicit dependency revalidation rather than overlapping owners.

## Evidence

Drive witness:
`FS_CASTLE_TOWN_SWJ_K07_BOUNDARY_AUDIT_R2_WITNESS_3X.png`
Drive ID: `1iK_6q3vHt5RgyNJ9f2mBMTMofHADWa6S`

## Supersession

`FS_CASTLE_TOWN_SWJ_K07_BOUNDARY_AUDIT_R1_20260821.md` remains historical evidence. Its Child A geometry is retained by the separately sealed Child A R1E authority; its parent/B/C staging geometry is superseded by this R2 audit.

## Status

`WEST MID R1C SEALED -> SWJ A R1E SEALED -> SWJ BOUNDARY R2 PASS -> CHILD B R2 EXTRACTION NEXT`
