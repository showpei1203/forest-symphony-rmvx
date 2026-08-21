# FS Castle Town SWJ / K07 Boundary Audit R4 — 2026-08-21

## Result

**BOUNDARY AUDIT R4 PASS — R3 staging geometry superseded before Child C formal seal.**

R3 correctly sealed Child A and Child B, but the first Child C extraction witness touched the old parent bottom boundary at `y=825`. Pixel inspection proved that the outgoing diagonal wall's dark exterior face remains visibly present below that line and continues until it is occluded by the downstream corner-tower silhouette around `y≈875–890`.

No sealed Child A or Child B bytes are changed by R4.

## R4 parent staging geometry

Parent semantic scope: **SW Junction / K07 Perimeter Turn**.

Staging bbox:

`[155,625,410,905]`

Workcell:

`255×280`

The workcell intentionally contains the downstream corner tower as extraction margin. Workcell inclusion does not confer ownership.

## Child authority

- A | K07 Tower / Immediate Junction: `[200,640,305,770]` — sealed R1E, unchanged.
- B | West Seam Connector: `[155,625,245,755]` — sealed R1A, unchanged.
- C | Outgoing Diagonal Wall formal bbox: `[245,704,365,890]` (`120×186`).

## Downstream tower handoff

The downstream corner-tower roof and vertical body are a **hard semantic exclusion** from Child C and from SWJ parent ownership.

Child C owns only visible diagonal-wall pixels up to the tower silhouette. The wall may approach or touch the tower visually but may not claim tower roof/body pixels.

## Ownership rule

Workcells may overlap neighboring objects for margin. Final binary owner masks may not overlap previously sealed owners.

This is the same corrected geometry principle established during West Mid revalidation: **workcell is workspace; owner mask is authority.**

## Status

`SWJ A SEALED -> SWJ B SEALED -> BOUNDARY R4 PASS -> CHILD C FORMAL QA -> SWJ PARENT SEAL`
