# Forest Symphony — Castle Town M4 East Garden Fountain Formal QA

Date: 2026-08-21
Authority: MAP_DUAL_OUTPUT_AUTHORITY_V2_9

## Result
M4 | East Garden Fountain = FORMAL PARENT PASS

### M4A-R1B
- bbox: [1114,416,1150,453]
- workcell: 36×37
- PAR opaque: 392 px
- alpha: {0,255}; partial alpha: 0
- local alpha bbox: [4,4,27,33]
- boundary safe: PASS
- Master-exact RGB: PASS
- Ground restoration: 76 px legal flat basin water
- outside-target Ground changes: 0
- PAR owner recomposition: 392/392 exact
- Ground restoration: 76/76 exact
- combined semantic footprint: 468/468 Master-exact
- whole-workcell visual recomposition: PASS

## Ground semantic finding
Unlike M0/M3, Working Ground did not retain fountain stone. It removed the entire fountain footprint, including the legal Ground-class basin water, and replaced it with grass. v2.9 therefore requires a Ground restoration mask in addition to any Ground-remnant cleanup masks.

## MID ownership revalidation after M4
Accepted child assets M0A, M0B, M1L, M1R, M2L, M2R, M3A, M3B, M3C, M4A:
- assets: 10
- pairwise pairs: 45
- nonzero overlap pairs: 0
- multi-owned pixels: 0
- max owner count: 1
- union opaque: 10,618 px

M4 is sealed. Later edits require dependency evidence.
