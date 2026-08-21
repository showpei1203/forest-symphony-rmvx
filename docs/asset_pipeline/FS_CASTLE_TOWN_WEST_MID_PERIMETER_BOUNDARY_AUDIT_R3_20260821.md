# FS Castle Town West Mid Perimeter Boundary Audit R3 — 2026-08-21

## Result

**BOUNDARY AUDIT R3 PASS / FINAL FOR CURRENT EXTRACTION.**

R3 supersedes R1 and R2 geometry. R1/R2 remain historical evidence only.

The key correction is conceptual as well as geometric: a workcell may cross already-sealed ownership zones for extraction margin, but the final owner mask must never duplicate sealed owner pixels. Bbox overlap is not ownership overlap.

## Source Authority

Canvas: `1448×1086`.

- Master: `FS_CASTLE_TOWN_MASTER_REFERENCE_1448x1086.png`
  - Drive ID: `14wte3dHhneq626WLNio8QznMwiFeryp4`
  - SHA-256: `4a7aabccad28bdafc548efe3e338320e5dd4c26cfa135c19eb9b4951a51fc06f`
- Ground: `FS_CASTLE_TOWN_GROUND_WORKING_1448x1086.png`
  - Drive ID: `1lQTpdA8WP68pHYQfLeJguJZSc4mbLNDb`
  - SHA-256: `4992659137123114c57b318bf74d8c476d725c9321ab4784728fe3a257257c94`
- accepted NORTH recomposition witness: `FS_CASTLE_TOWN_NORTH_AGGREGATE_RECOMPOSED_1448x1086.png`
  - SHA-256: `7f1321597f027fedf50ba768ee322b602e994a906e249c497b1927544edf2e4a`

## Why R2 was insufficient

R2 used `[155,260,336,625]`.

Pixel / visual revalidation showed that the west perimeter wall-top/parapet begins above `y=260`. Treating `y=260` as a hard workcell boundary would omit legal non-Ground structure below the sealed NORTH wall.

The correct rule is therefore:

- extraction workcell may extend into the NORTH vicinity;
- accepted NORTH owner pixels are a hard subtract / exclusion layer;
- only the final binary owner mask must have `0 px` overlap with NORTH.

## Locked R3 Parent Staging Geometry

Semantic parent: **West Mid Wall Tower / Side Perimeter Structure**.

Final workcell bbox:

`[155,230,336,625]`

Workcell:

`181×395`

Fixed placement:

`(155,230)`

This workcell provides safe top/right extraction margin while retaining the south semantic seam.

## Ownership rules

Include only this connected perimeter structure:
- west-side upper wall-top / parapet immediately below the NORTH parent;
- descending connector wall;
- W Mid Wall Tower including purple roof, banner, tower body and masonry;
- south-running west perimeter wall through global row `624`.

Hard exclusions:
- all accepted NORTH owner pixels;
- grass / flowers / terrain / water Ground classes;
- trees / vegetation owned by later PAR parents;
- adjacent buildings / market props / racks / crates;
- SW junction and SW Tower beginning at global `y=625`.

## South seam contract

The current parent deliberately terminates at the ownership seam immediately before global row `625`.

The accepted mask may therefore touch the workcell bottom boundary where the vertical perimeter wall continues into the future SW junction parent. This is not ordinary clipping. It is a declared semantic seam.

Future SW extraction must:
1. start at or below global `y=625` for the shared vertical-wall continuation / junction;
2. maintain `0 px` overlap with the sealed West Mid owner mask;
3. restore continuous visual wall geometry in recomposition;
4. trigger dependency revalidation if the exact seam must transfer pixels.

## Current extraction outcome

The resulting R1C candidate inside this R3 geometry has:
- opaque pixels: `15,050`
- Master RGB mismatch: `0 px`
- alpha values: `{0,255}`
- partial alpha: `0`
- NORTH owner overlap: `0 px`
- top boundary opaque: `0 px`
- left boundary opaque: `0 px`
- right boundary opaque: `0 px`
- bottom boundary opaque: `24 px`, all part of the declared south seam

R1A contained `468 px` of verified Ground/vegetation leakage. Those pixels were removed in R1B/R1C. A final high-green micro-audit identified `182 px` across `32` components; all localized inside valid wall/tower structure and were retained as structure texture rather than incorrectly erased by color alone.

## Status

`M5 SEALED -> WEST MID BOUNDARY R3 PASS -> WEST MID R1C FORMAL QA`
