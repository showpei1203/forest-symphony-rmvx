# FS Castle Town MID — M1 / M2 Formal QA

Date: 2026-08-21
Branch workflow: SHO-39
Authority: MAP_DUAL_OUTPUT_AUTHORITY_V2_7 + MID Anchor Contract v1 Batch A

## M1 | Goddess Plaza Paired Flagpoles
Result: **FORMAL PASS**

### M1L-R2B
- bbox `[675,440,698,492]`
- workcell `23×52`
- opaque `384 px`
- alpha `{0,255}` / partial `0`
- local alpha bbox `[4,1,18,49]`
- all four boundaries safe

### M1R-R2B
- bbox `[739,440,762,492]`
- workcell `23×52`
- opaque `386 px`
- alpha `{0,255}` / partial `0`
- local alpha bbox `[4,1,17,48]`
- all four boundaries safe

M1 child overlap: `0 px`. M1 vs M0 overlap: `0 px`. Working Ground already excludes the flagpoles, so no Ground semantic correction is required.

Parent M1 union: `770 px`.

## M2 | Goddess Plaza Paired Lamps
Result: **FORMAL PASS**

Boundary Continuity Audit superseded the earlier y=592 bottom. Pole structure continues to global y=610. Final workcells end at y=614, leaving y=611..613 transparent safety margin.

### M2L-R3A
- bbox `[634,550,659,614]`
- workcell `25×64`
- opaque `272 px`
- local alpha bbox `[5,8,19,60]`
- alpha `{0,255}` / partial `0`
- all four boundaries safe

### M2R-R3A
- bbox `[780,550,805,614]`
- workcell `25×64`
- opaque `270 px`
- local alpha bbox `[2,6,15,60]`
- alpha `{0,255}` / partial `0`
- all four boundaries safe

Dependency revalidation found a 5-pixel historical ownership conflict with M0B-R4A at foreground lamp pixels:
- `(789,556)`
- `(789,557)`
- `(789,558)`
- `(788,559)`
- `(790,559)`

These visible foreground lamp pixels belong to M2R. M0B therefore supersedes R4A with **M0B-R4B**, which removes exactly those 5 pixels. After transfer, M0/M1/M2 pairwise overlap is `0`.

Working Ground already excludes both lamps, so no M2 Ground correction is required.

Parent M2 union: `542 px`.

## M0 dependency revalidation
M0B-R4B supersedes M0B-R4A:
- bbox `[638,488,798,587]`
- opaque `2,418 px`
- transferred to M2R: `5 px`
- revised Ground correction target: `2,417 px`
- owner recomposition exact: `2418/2418`

M0 parent remains **FORMAL PARENT PASS (dependency-revalidated)**:
- M0A-R3B + M0B-R4B
- child overlap `0`
- union `4,602 px`

## Persistent artifacts
Final PAR/mask/checker/QA JSON for M1L, M1R, M2L, M2R, and revised M0B are stored under `Forest Symphony/08_Assets/02_Working`.
