# FS v2.8 G2A | Ground-only visual crop review (2026-10-25)

Ground passability defaults WALKABLE; roads are purely visual, and water/holes/cliff-gap exceptions alone add terrain collision. Prior G1C/G1D road-mask topology does not gate Ground.

Reviewing original G1B 1434x1097 raw generated ground, prepared three precise native-pixel 544x416 crops, no interpolation, no PAR:

| Candidate | source top-left | SHA256 |
|---|---|---|
| G1B_ORIGINAL | (420,300) | `1c6cfc72368b4f2d7ffff9f21d56192aa91eb30244ac641e9baac881c50be053` |
| G2_OPEN_FIELD | (800,240) | `5eb86aa98f6a1a230416fc8e03defaac30c0e76c744591a12e49f61782a1ce13` |
| G2_GRASS_MEADOW | (230,550) | `5bd4d5618934477267110ddc79985881f8f220d3492cf0b413b53063153d89a8` |

Includes 100% three-way contact sheet, nearest-neighbor 200% zooms and audit. **G2 visual HUMAN PENDING, G3 PAR NOT RUN, native VX NOT RUN, release BLOCKED.** Crop comparison is not a new generation or art PASS, and must not hide any tall vegetation or clipped edge issue. If all candidates fail, generate a new stand-alone ground source.

Google Drive Handoff: https://docs.google.com/document/d/1AJ_eELWFIVwhd82Xy7xfgd2vTWatPoPm0rbKNRkHvYA/edit
Private local ZIP `FS_V28_G2A_GROUND_VISUAL_COMPARISON_HANDOFF_20261025.zip`, 5,249,200 bytes, SHA256 `fad88b16df206d627ff8f32285e7ff0079651e9998873149da7d2b3707ef7b2b`. ZIP has not been backed up to Drive; public GitHub contains no restricted art.

SEALED FS/v2.1/v2.2/v2.3.3 unchanged.