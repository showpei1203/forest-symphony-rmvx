# Forest Symphony — Castle Town M3 West Plaza Fountain Formal QA

Date: 2026-08-21
Authority: MAP_DUAL_OUTPUT_AUTHORITY_V2_8 Ground-Remnant Cleanup Authority
Canvas: 1448×1086

## Result
M3 | West Plaza Fountain Compound = FORMAL PARENT PASS

## Child owners

### M3A-R1E | Central fountain sculpture / vertical jet / circular stone basin
- bbox: [372,528,416,576]
- workcell: 44×48
- opaque: 503 px
- alpha: {0,255}; partial alpha: 0
- local alpha bbox: [3,6,34,42]
- boundary safe: PASS
- Master-exact RGB: PASS
- Ground-remnant cleanup: 1600 px
- cleanup policy: drifted Ground remnant uses an independent cleanup mask rather than assuming byte alignment with the Master-derived PAR owner mask
- owner recomposition: 503/503 exact

### M3B-R2C | Rectangular water-basin stone rim
- bbox: [340,518,429,601]
- workcell: 89×83
- opaque: 1885 px
- alpha: {0,255}; partial alpha: 0
- local alpha bbox: [9,3,83,80]
- boundary safe: PASS
- Master-exact RGB: PASS
- Ground-remnant cleanup: 1885 px
- cleanup policy: aligned remnant, cleanup restricted to the owner mask
- owner recomposition: 1885/1885 exact
- canonical R2C PAR/mask/checker bytes are identical to R2B; R2C changes only Ground-cleanup authority

### M3C-R2B | Outer flowerbed structural curb
- bbox: [319,492,455,630]
- workcell: 136×138
- opaque: 1924 px
- alpha: {0,255}; partial alpha: 0
- local alpha bbox: [4,4,131,133]
- boundary safe: PASS
- Master-exact RGB: PASS
- Ground-remnant cleanup: 1924 px
- cleanup policy: aligned remnant, cleanup restricted to the owner mask
- owner recomposition: 1924/1924 exact
- canonical R2B PAR/mask/checker bytes are identical to R2A; R2B changes only Ground-cleanup authority

## Parent gate
- child overlap: 0 px
- max owner count: 1
- union opaque: 4312 px
- parent-owned recomposition: 4312/4312 Master-exact
- Ground cleanup changed pixels: M3A 1600 + M3B 1885 + M3C 1924 = 5409 px
- whole-parent visual recomposition: PASS

## Superseded evidence
The first parent cleanup attempt was rejected because overly broad M3B/M3C Ground cleanup exposed replacement texture outside the PAR-owned stone rims. R2 restricts aligned Ground cleanup to the owner mask while retaining the independent larger cleanup only for the genuinely drifted M3A Ground remnant.

## Canonical revision identity checks
- M3B R2C mask == R2B mask byte-for-byte (SHA-256 3a00b9b938f9570cd3aaeb270811c8ce83e2d3aa1ab1ad562a405025cb282f69)
- M3B R2C PAR == R2B PAR byte-for-byte (SHA-256 955b0b0b9fabc880a9edc5eef5926fd37b8570ca3efa3fc01b07abbd167beca1)
- M3C R2B mask == R2A mask byte-for-byte (SHA-256 4bd31fd35b2a77c86a8c5e4863ccdc02f3fe8ea667a14d5a3ac44b794d7aa5c4)
- M3C R2B PAR == R2A PAR byte-for-byte (SHA-256 b501207b4788ec4af55b70cb0c283f9e7aca708a96719336efd891f0615439ff)

M3 is sealed. Future MID work must not modify M3 unless a later dependency revalidation proves a specific foreground ownership transfer is required.
