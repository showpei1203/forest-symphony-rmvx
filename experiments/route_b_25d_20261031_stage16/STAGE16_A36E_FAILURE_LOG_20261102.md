# Stage16 A36E R2 | Failure Log | 2026-11-02

| ID | Observed issue / evidence | Verified correction | State |
|---|---|---|---|
| A36E-R1-ART-01 | A36D second house still had a disproportionately tall green triangular roof. | Physically compressed only 169px upper roof into 143px using nearest-neighbor, kept lower 67px stone/door native, retuned 18,577 roof pixels; independent 198×236 source RGBA and SHA retained. | ENGINE PASS, ART PENDING |
| A36E-R1-ART-02 | R1 flowers from Hanzo-VSFlowers01 were too large (purple clusters visually outweighed trees). Actual first-version screenshots archived under A36E_R1. | R2 shrinks original five isolated alpha clusters to 54% via nearest-neighbor, reduces magenta color brightness, and recomposes 29 placements as Ground ONLY. New actual before/after and QA generated. | FIXED, visual human review pending |
| A36E-TECH-03 | Flower could incorrectly become PAR obstruction or shift collision. | Each flower stored as independent source crop but composited only into Ground; existing PAR sprites and collision grid unchanged. | PASS, 921/921 connected |
| A36E-TECH-04 | RGSS PNG names may become missing after stage rename (previous A36B failure). | Same filename references and files copied to isolated A36E native Overlays, all 403 loaded without error; 11 cases / 22 actual screenshots. | PASS |
| A36E-TECH-05 | Godot could reorder depth-equal sprites or differ from source. | Stable (foot_y,id) order; actual GPU 6 full/6 crops, maxRGB1, 0 pixels >RGB1. | PASS |
| A36E-TECH-06 | Cold clone could pass SHA without engine startup. | Verified all 3824 clone files SHA, re-launched RGSS, actual 403 resources, Map050, no error window. | PASS |
| A36E-OPEN-07 | Character fully hidden behind stonehouse in rear case; human visual depth/entrance readability remains unaccepted. | Keep issue open, inspect more positional probes in A36F; do not overclaim. | OPEN |
| A36E-TERRAIN-08 | Original FS terrain PAR has not yet been reverse engineered fully. | Keep all cliffs/high terrain outside this flat branch. | DEFERRED |

**Formal Seal NO, user visual review pending, A36D immutable.**
