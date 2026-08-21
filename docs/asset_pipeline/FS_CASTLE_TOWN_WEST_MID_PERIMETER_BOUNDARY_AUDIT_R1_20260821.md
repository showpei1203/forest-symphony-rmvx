# FS Castle Town West Mid Perimeter Boundary Audit R1 — 2026-08-21

## Result

**BOUNDARY AUDIT PASS — geometry locked for extraction staging.**

This audit does not seal a new PAR asset and does not assign an `M6` identifier. It only establishes the deterministic ownership/workcell geometry for the next west-side perimeter parent after sealed M5.

## Source Authority

Canvas: `1448×1086`.

- Master: `FS_CASTLE_TOWN_MASTER_REFERENCE_1448x1086.png`
  - Drive ID: `14wte3dHhneq626WLNio8QznMwiFeryp4`
  - SHA-256: `4a7aabccad28bdafc548efe3e338320e5dd4c26cfa135c19eb9b4951a51fc06f`
  - bytes: `4,784,681`
- Ground: `FS_CASTLE_TOWN_GROUND_WORKING_1448x1086.png`
  - Drive ID: `1lQTpdA8WP68pHYQfLeJguJZSc4mbLNDb`
  - SHA-256: `4992659137123114c57b318bf74d8c476d725c9321ab4784728fe3a257257c94`
- NORTH accepted recomposition witness: `FS_CASTLE_TOWN_NORTH_AGGREGATE_RECOMPOSED_1448x1086.png`
  - SHA-256: `7f1321597f027fedf50ba768ee322b602e994a906e249c497b1927544edf2e4a`

## Guided SAM2 Evidence

Legacy Guided SAM2 K05 locates the west-mid tower with prompt/detection box:

`[160,310,215,405]`

K05 evidence:
- mask pixels: `1,336`
- bbox fill ratio: `0.2556937799`

This is **location evidence only**. It is not the complete perimeter ownership bbox and must not be used directly as the final extraction workcell.

Adjacent SW tower K07 begins with Guided box:

`[215,625,280,735]`

This gives useful boundary evidence for reserving the southwest junction/tower for the later SW parent.

## NORTH Seam Audit

Pixel-exact comparison of the accepted NORTH recomposition against Working Ground shows that the western NORTH owner union reaches only through:

`y = 259`

Inside the new west-side candidate x-range there are no NORTH-owned pixels from `y=260` downward.

Therefore the north ownership seam is locked at:

`y = 260`

The candidate parent workcell intersects the accepted NORTH owner union by:

`0 px`

## South Seam Audit

The west vertical perimeter wall remains continuous southward until the geometry begins turning toward the southwest tower/junction. Guided K07 starts at `y=625`, matching the visible transition zone.

Ownership split:
- current west-mid parent owns rows `260..624` for its legal structural pixels;
- later southwest junction/tower parent owns structural pixels beginning at `y=625`.

This avoids assigning the SW tower to the current parent and prevents later double ownership.

## Locked Parent Staging Geometry

Semantic parent: **West Mid Wall Tower / Side Perimeter Structure**.

Staging bbox:

`[155,260,305,625]`

Workcell:

`150×365`

Fixed placement:

`(155,260)`

The workcell deliberately contains margin and unrelated scene pixels. Workcell inclusion does **not** confer PAR ownership.

### Legal PAR membership inside this workcell

Include only the visible connected west perimeter structure belonging to this parent:
- descending connector wall below the sealed NW/NORTH perimeter ownership;
- West Mid Wall Tower including roof, tower body, banner and structural masonry;
- south-running vertical perimeter wall through row `624`.

### Explicit exclusions

Do not capture:
- grass, flowers, terrain, water or other Ground-class pixels;
- trees/vegetation;
- adjacent shop/building roof or building body;
- racks/crates/market props;
- any unrelated MID asset;
- any NORTH-owned pixel;
- southwest turn/junction or SW Tower pixels reserved from `y=625` downward.

## Extraction Rule

The next step is deterministic Master extraction inside the locked `150×365` workcell only.

Required gates:
1. source RGB on opaque pixels remains Master-exact;
2. alpha only `{0,255}`;
3. no resize;
4. exact integer placement `(155,260)`;
5. NORTH owner overlap remains `0 px`;
6. unrelated building/market/vegetation capture = `0 px` by semantic QA;
7. south boundary must not consume the SW junction/tower;
8. recomposition must restore the west-side perimeter silhouette without moving Ground.

SAM2 or other segmentation may assist mask discovery, but it remains QA evidence and may not override semantic ownership.

## Status

`M5 SEALED -> WEST MID PERIMETER BOUNDARY AUDIT R1 PASS -> DETERMINISTIC EXTRACTION NEXT`
