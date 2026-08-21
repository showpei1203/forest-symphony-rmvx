# Forest Symphony — Castle Town Southwest Corner Tower Formal QA

Date: 2026-08-21
Canvas: 1448×1086
Authority: deterministic Master extraction + semantic pixel ownership

## Result

**SWC | Southwest Corner Tower = FORMAL PARENT PASS / SEALED**

Canonical owner: `SWC-R1B`.

## Geometry

- bbox: `[335, 770, 415, 910]`
- workcell: `80×140`
- placement: `(335,770)`
- opaque: `4,713 px`
- local alpha bbox: `[18, 6, 65, 128]`
- alpha: `{0,255}`
- partial alpha: `0`
- all four workcell boundaries clear

## Mechanical gates

- Master-exact RGB mismatch: `0`
- Working Ground identical on owner pixels: `0`
- connected components: `1`
- strong-green leakage: `0 px`
- overlap with sealed SWJ C / A / B / West Mid: `0 / 0 / 0 / 0 px`

## Upstream seam revalidation

The first tower candidate left a one-pixel unowned column between Child C and the tower:

- `x=353`
- `y=818..876`
- `59 px`

R1B assigns this exact visible structural column to the tower. Sealed Child C bytes remain unchanged.

After transfer:
- C ↔ SWC overlap: `0 px`
- minimum chessboard distance: `1 px`
- SWC pixels adjacent to C: `59`
- seam continuity: **PASS**

## Semantic exclusions

SWC owns only the visible purple-roof tower and tower body.

Excluded:
- incoming diagonal wall: sealed SWJ Child C
- outgoing horizontal south wall: next parent
- foreground vegetation: transparent

## Global MID ownership

After SWC:
- accepted assets: `16`
- pairwise pairs: `120`
- nonzero overlap pairs: `0`
- multi-owned pixels: `0`
- max owner count: `1`
- union opaque: `51,643 px`

## Next

**South Wall West Segment Boundary Audit** from the SWC east silhouette toward the South Gatehouse west-side seam.

Do not reopen SWC or SWJ by default.

Status:

`SWJ SEALED -> SWC R1B SEALED -> SOUTH WALL WEST SEGMENT BOUNDARY AUDIT NEXT`
