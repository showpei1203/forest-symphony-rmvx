# FS Castle Town West Mid Perimeter Boundary Audit R2 — 2026-08-21

## Result

**BOUNDARY AUDIT R2 PASS — R1 geometry superseded before extraction acceptance.**

R1 correctly locked the north seam at `y=260` and south seam at `y=625`, but extraction witness R2 exposed right-edge contact at `x=305` on the descending connector wall. R2 expands only the staging workcell right boundary. No sealed asset is modified.

This audit still does not assign an `M6` identifier.

## Source Authority

Canvas: `1448×1086`.

- Master: `FS_CASTLE_TOWN_MASTER_REFERENCE_1448x1086.png`
  - Drive ID: `14wte3dHhneq626WLNio8QznMwiFeryp4`
  - SHA-256: `4a7aabccad28bdafc548efe3e338320e5dd4c26cfa135c19eb9b4951a51fc06f`
- Ground: `FS_CASTLE_TOWN_GROUND_WORKING_1448x1086.png`
  - Drive ID: `1lQTpdA8WP68pHYQfLeJguJZSc4mbLNDb`
  - SHA-256: `4992659137123114c57b318bf74d8c476d725c9321ab4784728fe3a257257c94`
- NORTH accepted recomposition witness: `FS_CASTLE_TOWN_NORTH_AGGREGATE_RECOMPOSED_1448x1086.png`
  - SHA-256: `7f1321597f027fedf50ba768ee322b602e994a906e249c497b1927544edf2e4a`

## Persistent seams retained from R1

- North ownership seam: `y=260`.
- South ownership seam: `y=625`.
- Current parent owns legal structural pixels on rows `260..624`.
- SW junction / SW tower ownership remains reserved from `y=625` downward.

## Right-boundary dependency revalidation

R1 staging bbox:

`[155,260,305,625]`

The first combined wall+tower extraction witness touched the `x=305` right boundary on the upper descending connector wall. A formal extraction workcell must not rely on a clipping boundary when additional canvas space is available.

Pixel-exact NORTH-owner checks on the expanded right boundary:

- bbox x-range `155..304`: NORTH overlap below `y=260` = `0 px`
- bbox x-range `155..319`: NORTH overlap below `y=260` = `0 px`
- bbox x-range `155..335`: NORTH overlap below `y=260` = `0 px`
- expansion through `x=351`: NORTH overlap below `y=260` = `438 px`

Therefore `x=336` is the last tested clean staging seam before entering accepted NORTH ownership on the adjacent upper object zone.

## Locked R2 Parent Staging Geometry

Semantic parent: **West Mid Wall Tower / Side Perimeter Structure**.

R2 staging bbox:

`[155,260,336,625]`

Workcell:

`181×365`

Fixed placement:

`(155,260)`

The larger workcell is extraction margin only. It does not transfer ownership of adjacent buildings, vegetation or props.

## Legal PAR membership

Include only the connected west perimeter structure belonging to this parent:
- descending connector wall below sealed NORTH ownership;
- West Mid Wall Tower roof/body/banner/structural masonry;
- south-running vertical perimeter wall through row `624`.

Explicitly exclude:
- Ground-class terrain/grass/flowers/water;
- trees/vegetation;
- adjacent shop/building roof/body;
- racks/crates/market props;
- unrelated MID assets;
- all NORTH-owned pixels;
- SW junction / SW Tower from `y=625` downward.

## Extraction strategy

Use deterministic Master extraction. Segmentation may be developed as semantic sub-masks for:
1. upper connector wall;
2. K05 tower roof/body/banner;
3. south vertical wall.

The sub-masks are diagnostic construction aids only. The deliverable remains one parent binary alpha mask unless later authority explicitly creates child asset IDs.

Required gates:
- opaque RGB Master-exact;
- alpha only `{0,255}`;
- no resize;
- placement exactly `(155,260)`;
- NORTH owner overlap `0 px`;
- no unrelated building/market/vegetation capture;
- no SW junction/tower capture;
- no structural clipping at any workcell boundary except the deliberate ownership seams.

## Supersession

`FS_CASTLE_TOWN_WEST_MID_PERIMETER_BOUNDARY_AUDIT_R1_20260821.md` remains historical evidence but its `x=305` right boundary is superseded.

## Status

`M5 SEALED -> WEST MID PERIMETER BOUNDARY AUDIT R2 PASS -> 181x365 DETERMINISTIC EXTRACTION NEXT`
