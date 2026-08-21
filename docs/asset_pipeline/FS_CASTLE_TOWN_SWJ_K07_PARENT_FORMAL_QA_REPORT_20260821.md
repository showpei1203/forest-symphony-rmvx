# Forest Symphony — Castle Town SWJ / K07 Parent Formal QA

Date: 2026-08-21
Authority: MAP_DUAL_OUTPUT semantic ownership + deterministic Master extraction
Canvas: 1448×1086

## Result

**SWJ | K07 West-South Perimeter Junction = FORMAL PARENT PASS / SEALED**

Boundary Audit R4 supersedes R1–R3 only for staging geometry. Already sealed Child A and Child B bytes remain unchanged.

## Boundary Authority R4

Parent staging bbox: `[155, 625, 410, 905]`
Workcell: `255×280`

The parent workcell intentionally includes the downstream corner-tower region as visual/extraction margin. Workcell inclusion does not confer ownership.

The downstream corner tower roof/body is a hard semantic exclusion. SWJ owns only the visible outgoing diagonal wall up to that tower silhouette.

## Child owners

### A | K07 Tower / Immediate Junction — R1E
- bbox: `[200,640,305,770]`
- workcell: `105×130`
- opaque: `3,352 px`
- alpha: `{0,255}`
- partial alpha: `0`
- boundary safe: PASS
- Master-exact RGB: PASS
- vegetation leakage: `0`
- status: **FORMAL CHILD PASS / SEALED**

### B | West Seam Connector — R1A
- bbox: `[155,625,245,755]`
- workcell: `90×130`
- opaque: `4,756 px`
- alpha: `{0,255}`
- partial alpha: `0`
- bottom/left/right boundaries clear
- top boundary is deliberate semantic seam at global row `625`
- West Mid row624 footprint = `x=172..195` (`24 px`)
- Child B row625 footprint = `x=172..195` (`24 px`)
- seam footprint exact match: **PASS**
- status: **FORMAL CHILD PASS / SEALED**

### C | Outgoing Diagonal Wall — R1A
- formal bbox: `[245, 704, 365, 890]`
- workcell: `120×186`
- placement: `(245,704)`
- opaque: `6,952 px`
- alpha: `{0,255}`
- partial alpha: `0`
- local alpha bbox: `[10, 10, 107, 171]`
- all four formal workcell boundaries clear
- Master-exact RGB mismatch: `0`
- Working Ground identical on owner pixels: `0`
- overlap with West Mid / A / B: `0 / 0 / 0 px`
- connected components: `1`
- A↔C minimum chessboard distance: `1 px`
- C pixels adjacent to A: `48`
- strong-green leakage: `0 px`
- moderate greenish wall-texture pixels manually retained: `7`
- downstream corner-tower roof/body excluded
- status: **FORMAL CHILD PASS / SEALED**

## Parent ownership gate

- children: `3`
- pairwise pairs: `3`
- nonzero overlap pairs: `0`
- multi-owned pixels: `0`
- max owner count: `1`
- union opaque: `15,060 px`
- parent-owned Master-exact recomposition mismatch: `0`
- Working Ground identical on parent-owned pixels: `0`
- parent top boundary: `24 px`, deliberate upstream seam only
- parent bottom/left/right boundaries: `0 / 0 / 0 px`

## Global MID ownership revalidation

Previous sealed MID authority:
- accepted assets: `12`
- union opaque: `31,870 px`
- pairwise overlap: `0`

After adding SWJ A/B/C:
- accepted assets: `15`
- pairwise pairs: `105`
- nonzero overlap pairs: `0`
- multi-owned pixels: `0`
- max owner count: `1`
- union opaque: `46,930 px`

## Next structural handoff

The next structural parent candidate is the **downstream southwest corner tower** at the end of Child C.

Do not reopen SWJ A/B/C by default. Future edits require specific dependency-revalidation evidence.

Status:

`M5 SEALED -> WEST MID SEALED -> SWJ A/B/C SEALED -> SWJ PARENT SEALED -> DOWNSTREAM SW CORNER TOWER BOUNDARY AUDIT NEXT`
