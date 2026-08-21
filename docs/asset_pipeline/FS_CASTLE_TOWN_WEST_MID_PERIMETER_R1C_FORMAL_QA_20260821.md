# FS Castle Town West Mid Perimeter R1C Formal QA — 2026-08-21

## Result

**West Mid Wall Tower / Side Perimeter Structure = FORMAL PARENT PASS / SEALED**

This parent remains semantically named rather than being assigned an invented `M6` ID. Future numbering may be added only if an authoritative MID anchor plan establishes it.

## Canonical geometry

Boundary Authority: `FS_CASTLE_TOWN_WEST_MID_PERIMETER_BOUNDARY_AUDIT_R3_20260821.md`

- bbox: `[155,230,336,625]`
- workcell: `181×395`
- placement: `(155,230)`
- opaque: `15,050 px`
- local alpha bbox: `[16,15,153,395]`
- alpha: `{0,255}`
- partial alpha: `0`
- no resize / redraw
- Master-exact RGB mismatch on opaque pixels: `0`

## Boundary gate

Opaque pixels on workcell boundaries:
- top: `0`
- left: `0`
- right: `0`
- bottom: `24`

The bottom contact is an explicit semantic seam, not accidental clipping. The west vertical perimeter continues into the future SW junction / SW Tower ownership starting at global `y=625`.

Future SW extraction must preserve `0 px` overlap and revalidate the seam if any pixel transfer is required.

## NORTH ownership gate

The workcell deliberately overlaps the vicinity of sealed NORTH geometry so it can contain complete extraction margin.

Final owner-mask rule is pixel ownership, not bbox isolation.

- accepted NORTH owner overlap: `0 px`
- the NORTH mask is therefore not modified and no NORTH dependency rollback is required.

## Ground / semantic purity

Working Ground already removes the entire accepted West Mid structural owner footprint.

- R1C owner pixels identical between Working Ground and Master: `0 / 15,050`
- Ground remnant cleanup required: `0 px`
- Ground restoration required: `0 px`

R1A contained `468 px` of verified Ground / vegetation leakage. R1B removed exactly those pixels. R1C retains the R1B binary mask after final micro-QA.

A high-green review examined the remaining color-risk candidates:
- candidate pixels: `182`
- connected components: `32`
- largest component: `87 px`
- disposition: all localized inside valid wall / tower material and retained as structure texture

Color alone is not semantic authority; deleting these pixels would create holes in valid masonry/roof texture.

## Recomposition gate

R1C is deterministic Master extraction.

Placed exactly at `(155,230)` on the accepted NORTH base:
- owner recomposition mismatch: `0 px`
- visual silhouette restores the west upper wall, W Mid tower, descending wall and south-running perimeter without moving Ground.

Canonical witness:
`FS_CASTLE_TOWN_WEST_MID_PERIMETER_R1C_RECOMPOSITION_WITNESS_3PANEL_3X.png`

## MID ownership revalidation

Previous accepted MID assets after M5:
- assets: `11`
- pairwise pairs: `55`
- nonzero overlap pairs: `0`
- union opaque: `16,820 px`

After adding West Mid R1C:
- assets: `12`
- pairwise pairs: `66`
- nonzero overlap pairs: `0`
- multi-owned pixels: `0`
- max owner count: `1`
- new union opaque: `31,870 px`

Ten previous MID asset bboxes are spatially disjoint from the R1C workcell. `M3C-R2B` is the only previous bbox that intersects the R1C workcell rectangle; the R1C mask contains `0 px` inside the actual overlap rectangle `[319,492,336,625]`, therefore exact M3C ownership overlap is necessarily `0 px`.

NORTH × West Mid R1C overlap is also `0 px`.

## Canonical Drive files

- `FS_CASTLE_TOWN_WEST_MID_PERIMETER_R1C_EXTRACTED_PAR_181x395.png`
  - Drive ID `1mBmvBJO4vwwHysQ9mOfbU5Nq3UPXH_jW`
  - SHA-256 `c6de2c2efd4200edbe442fad7beac37d217981971e1fcc858faa229f5adfd5ce`
- `FS_CASTLE_TOWN_WEST_MID_PERIMETER_R1C_BINARY_MASK_181x395.png`
  - Drive ID `1KI7fvwWlkP_8ePvyN2dAcPlU5ezRBRJE`
  - SHA-256 `67255b8247ef8d5ea4cfecb723e7c93b53980bd46ce1955a5d2fe92af22d504f`
- `FS_CASTLE_TOWN_WEST_MID_PERIMETER_R1C_CHECKER_3X.png`
  - Drive ID `1nfeQ3Bysq9jS7jHcYXIcJEIa_93aI4ij`
- `FS_CASTLE_TOWN_WEST_MID_PERIMETER_R1C_QA_OVERLAY_3X.png`
  - Drive ID `1TTJLkpyWr5epCew0F_BAsJXTE5t2TYdc`
- `FS_CASTLE_TOWN_WEST_MID_PERIMETER_R1C_RECOMPOSITION_WITNESS_3PANEL_3X.png`
  - Drive ID `1cDrLJWAAvfrdIvheiVNZS4Ps70s4Cycn`
- `FS_CASTLE_TOWN_WEST_MID_PERIMETER_R1C_QA_REPORT.json`
  - Drive ID `1v_J0ZtyP6XvP-2GzFhVqLgBJ1-xuVnTC`
- `FS_CASTLE_TOWN_WEST_MID_PERIMETER_R1C_GREEN_MICRO_AUDIT.json`
  - Drive ID `17O_CMHa__u-xTRZzfeXCKm45rj9DHrYm`
- `FS_CASTLE_TOWN_MID_M0_M5_WESTMID_12ASSET_OWNERSHIP_AUDIT.json`
  - Drive ID `1wL6DeAQxKiFROEHnDO0FHnEvLmQ_EfUo`

## Superseded history

- Boundary Audit R1: superseded by R2 after right-edge extraction witness.
- Boundary Audit R2: superseded by R3 after the `y=260` top boundary was proven to omit legal wall-top/parapet structure.
- R1A extraction: rejected for `468 px` Ground / vegetation leakage.
- R1B: purity-corrected mask; promoted byte-equivalently to R1C after green micro-QA established that the remaining 182 high-green pixels are valid structure texture.

## Next legal step

Proceed to **SW junction / K07 SW Wall Tower boundary audit**.

Do not modify sealed West Mid R1C unless the SW seam dependency revalidation proves a specific pixel transfer is required.
