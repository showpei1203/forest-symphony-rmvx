# FS Castle Town M5 Formal QA Report — 2026-08-21

## Result

**M5 | East Windmill Compound = FORMAL PARENT PASS / SEALED**

## Canonical child

- `M5A-R1G`
- bbox `[1228,338,1364,532]`
- workcell `136×194`
- placement `(1228,338)`
- opaque `6,202 px`
- alpha `{0,255}`; partial alpha `0`
- local alpha bbox `[23,33,114,181]`
- all four workcell boundaries clear
- Master-exact RGB mismatch on opaque pixels: `0`

## Ground / layering

Working Ground already removes the windmill tower and blade footprint. No Ground semantic correction or restoration is required for M5. Blade lattice holes remain transparent and therefore reveal accepted background layers.

The final visual recomposition gate was performed on top of the sealed NORTH 24-asset recomposition rather than bare Ground because several blade holes legitimately expose NORTH wall/tower PAR.

## Ownership

- M5 × NORTH 24-asset final owner union: `0 px` overlap
- MID accepted assets after M5: `11`
- MID pairwise combinations: `55`
- nonzero overlap pairs: `0`
- multi-owned pixels: `0`
- max owner count: `1`
- MID union opaque: `16,820 px`

## Rejected history

R1 through R1F were diagnostic candidates. They were rejected for vegetation capture and/or unrelated endpoint props such as the lower-left rack/net and upper-right wall ornament. R1G is the first accepted windmill silhouette.

## Canonical files

- `FS_CASTLE_TOWN_M5A_R1G_EXTRACTED_PAR_136x194.png`
- `FS_CASTLE_TOWN_M5A_R1G_BINARY_MASK_136x194.png`
- `FS_CASTLE_TOWN_M5A_R1G_CHECKER.png`
- `FS_CASTLE_TOWN_M5A_R1G_QA_REPORT.json`
- `FS_CASTLE_TOWN_M5_PARENT_FINAL_QA_REPORT.json`
- `FS_CASTLE_TOWN_MID_M0_M5_11ASSET_OWNERSHIP_AUDIT.json`
- `M5_MASTER_NORTHBASE_M5RECOMP4X.png`

M5 is sealed. Later changes require a specific dependency-revalidation finding rather than re-segmentation by default.
