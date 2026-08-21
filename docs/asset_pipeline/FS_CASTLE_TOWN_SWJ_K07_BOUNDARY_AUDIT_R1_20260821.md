# FS Castle Town SW Junction / K07 Boundary Audit R1 — 2026-08-21

## Result

**BOUNDARY AUDIT R1 PASS — SW Junction parent geometry locked for child extraction.**

This follows sealed `West Mid Wall Tower / Side Perimeter Structure R1C` and consumes the declared south ownership seam beginning at global `y=625`.

## Source Authority

Canvas: `1448×1086`.

- Master: `FS_CASTLE_TOWN_MASTER_REFERENCE_1448x1086.png`
- Ground: `FS_CASTLE_TOWN_GROUND_WORKING_1448x1086.png`
- upstream sealed owner: `West Mid Perimeter R1C`
- Guided SAM2 location evidence: `K07 SW Wall Tower`, authored box `[215,625,280,735]`

Guided K07 is location evidence only. It does not define complete wall/junction ownership.

## Why K07 cannot be treated as an isolated tower

The K07 tower simultaneously participates in three visible structural relationships:
1. it receives the south continuation of the west perimeter from the sealed West Mid seam;
2. it owns the foreground tower/junction silhouette at the turn;
3. a diagonal perimeter wall exits the tower toward the next lower corner tower.

A single K07 bbox would therefore either clip connected masonry or steal adjacent wall ownership. The parent is split into child ownership zones while remaining one dependency-audited junction.

## Locked SW Junction parent workcell

Parent semantic name: **SW Junction / K07 Perimeter Turn**

Parent staging bbox:

`[155,625,365,800]`

Workcell:

`210×175`

Placement:

`(155,625)`

This is an extraction workcell, not a blanket ownership rectangle.

## Child staging zones

### Child A — K07 Tower / Immediate Junction

Staging bbox:

`[200,640,305,770]`

Purpose:
- K07 purple roof / turret silhouette;
- visible tower body;
- immediate masonry junction pixels that cannot be cleanly assigned to either incoming or outgoing wall without splitting foreground structure.

### Child B — West Seam Connector

Staging bbox:

`[155,625,230,700]`

Purpose:
- consume the exact structural continuation immediately below the sealed West Mid south seam;
- connect the west vertical perimeter into Child A without a missing row or double ownership.

### Child C — Diagonal Wall

Staging bbox:

`[255,690,365,800]`

Purpose:
- own the visible diagonal perimeter wall leaving K07 toward the next lower corner tower;
- stop before taking ownership of that next tower.

Child workcells may overlap for extraction margin. Final binary owner masks may not overlap.

## Upstream seam contract

Sealed West Mid R1C owns legal wall pixels through global row `624` and touches its bottom workcell edge on 24 wall pixels.

SW Junction begins at global row `625`.

Required parent gate:
- West Mid × SW Junction owner overlap = `0 px`;
- recomposition must show no visual wall gap across rows `624/625`;
- if a later child extraction proves exact seam pixels must transfer, perform explicit dependency revalidation rather than silently overlapping ownership.

## Southeast exclusion / next-corner dependency

The next lower corner tower is visible at the southeast edge of the parent workcell. It is **not** part of SW Junction R1.

The SW Junction workcell may contain some of that tower as extraction margin, but final masks must exclude it. Exact next-corner tower geometry will be audited separately.

The diagonal wall may meet the future tower at the parent bottom/right vicinity. Boundary contact there is allowed only as a declared semantic seam and must be dependency-revalidated when the next tower is extracted.

## Hard semantic exclusions

Do not capture:
- grass / flowers / terrain / water Ground classes;
- trees / bushes / vegetation that belong to later PAR parents;
- S1 residential buildings / roofs / props;
- the next lower corner tower;
- any previously sealed owner pixel.

## Child extraction order

1. Child A — K07 Tower / Immediate Junction.
2. Child B — West Seam Connector, subtracting A ownership.
3. Child C — Diagonal Wall, subtracting A/B ownership and excluding the next corner tower.
4. Parent union / pairwise overlap QA.
5. Recomposition against Master with sealed West Mid in place.

## Evidence

Drive witness:
`FS_CASTLE_TOWN_SWJ_K07_BOUNDARY_AUDIT_R1_WITNESS_3X.png`
Drive ID: `1dc1JHKpcMj0V0MOF4VT7z-rYY4S9HHoc`

## Status

`WEST MID R1C SEALED -> SWJ BOUNDARY R1 PASS -> CHILD A K07 EXTRACTION NEXT`
