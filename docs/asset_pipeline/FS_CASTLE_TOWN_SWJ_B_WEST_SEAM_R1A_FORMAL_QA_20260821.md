# FS Castle Town SWJ Child B West Seam R1A Formal QA — 2026-08-21

## Result

**SWJ Child B | West Seam Connector = FORMAL CHILD PASS / SEALED WITHIN OPEN SWJ PARENT**

## Geometry

Boundary Authority: SWJ Boundary Audit R3.

- bbox `[155,625,245,755]`
- workcell `90×130`
- placement `(155,625)`
- opaque `4,756 px`
- local alpha bbox `[16,0,78,121]`
- alpha `{0,255}`
- partial alpha `0`
- no resize / redraw
- Master RGB mismatch `0 px`

## Boundary gate

Opaque boundary pixels:
- top `24`
- bottom `0`
- left `0`
- right `0`

Top contact is the declared semantic seam from sealed West Mid. It is not clipping.

The enlarged R3 workcell clears the previous false bottom boundary: accepted B owner ends at global `y=745`, leaving clear margin before workcell bottom `y=755`.

## West Mid row624/625 seam proof

Sealed West Mid R1C bottom row `624` owns exactly:

`x = 172..195` (`24 px`)

Child B top row `625` owns exactly:

`x = 172..195` (`24 px`)

Result:
- footprint intersection `24/24`
- West-Mid-only pixels `0`
- Child-B-only pixels `0`
- exact seam footprint match **PASS**

This provides pixel-level continuity across the upstream wall seam without shared ownership.

## Ownership / semantic purity

- overlap with sealed West Mid R1C: `0 px`
- overlap with sealed Child A K07 R1E: `0 px`
- strong-green selected pixels: `0`
- Working Ground pixels identical to Master on B owner footprint: `0`
- Ground remnant cleanup required: `0 px`
- Ground restoration required: `0 px`

Child B owns only the incoming west perimeter wall / wall face through its termination into the K07 junction.

For the lower-right ambiguous area, global `y>=700, x>=220` is reserved for Child C unless already owned by Child A. This prevents B from consuming the outgoing diagonal wall.

## Recomposition gate

Placed on the accepted base with sealed West Mid and Child A:
- incoming west-wall silhouette is restored to Master geometry;
- row624/625 wall transition has no gap;
- outgoing diagonal wall remains intentionally absent pending Child C.

Canonical witness:
`FS_CASTLE_TOWN_SWJ_B_WEST_SEAM_R1A_RECOMPOSITION_WITNESS_3PANEL_3X.png`

## Canonical Drive files

- PAR `FS_CASTLE_TOWN_SWJ_B_WEST_SEAM_R1A_EXTRACTED_PAR_90x130.png`
  - Drive ID `12co-eGKnvTKe0AHewFHoaTiCOj6OLTI2`
  - SHA-256 `9bf2bd4523652a51d7fed03641e98d31544364b78c39029d40c6f9fe23dfd605`
- Mask `FS_CASTLE_TOWN_SWJ_B_WEST_SEAM_R1A_BINARY_MASK_90x130.png`
  - Drive ID `1XWtsSGOGYV_tTqYw1fWM_x4ccBVGsQB5`
  - SHA-256 `3460d7e46207ea25a81073db9b7dd2c2f4effdad501a1fe808c9c68182b9b587`
- Checker `FS_CASTLE_TOWN_SWJ_B_WEST_SEAM_R1A_CHECKER_5X.png`
  - Drive ID `1smugLw8DrBrgpKRb1bhDVEhosYyDAzFm`
- QA overlay `FS_CASTLE_TOWN_SWJ_B_WEST_SEAM_R1A_QA_OVERLAY_5X.png`
  - Drive ID `1dsxQA3DYIcTOFr4VquDZsx9BdWy1poHu`
- Recomposition witness `FS_CASTLE_TOWN_SWJ_B_WEST_SEAM_R1A_RECOMPOSITION_WITNESS_3PANEL_3X.png`
  - Drive ID `1SwP4rIGAYuLScxoxYy8PSM5keBCRTQum`
- QA report `FS_CASTLE_TOWN_SWJ_B_WEST_SEAM_R1A_QA_REPORT.json`
  - Drive ID `1kYmsDUlUdrO_GIXgsUkj9S3kOukxwMXH`

## Next legal step

Proceed to **SWJ Child C | Outgoing Diagonal Wall** using staging bbox `[205,690,410,825]`.

Child C must subtract sealed A+B ownership and exclude the next lower corner tower while preserving a visually continuous diagonal wall.
