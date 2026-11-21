# Forest Symphony | T-B R7 Failure Log | 2026-11-21

**Status: first family PMD0001 V6 Attack USER_ART_ACCEPTED. Second family TB02 TECH PASS / ART_REVIEW_PENDING.**

| Failure | Classification | Evidence | Actual mitigation | Disposition |
|---|---|---|---|---|
| Bat mid-stage first edit looks almost the same | BLOCKING stage morphology | stage1 vs attempted stage2 silhouette IoU ≈0.858; edited 96px | Kept rejected candidate, used wider 128px canvas and stronger anatomy guidance; Stage1/2 IoU ≈0.467 | FIXED, first 1gen spent |
| Bat Attack original 96px claws/wing clipped | BLOCKING ART | 10 of 11 frames touch border in initial 384×288 PixelLab sheet | Use source-locked 128×128 transparent padded mother, 14-joint wing rig, native new 512×384 11F atlas; all 11 have **zero border contacts** | FIXED, 3gen reroll spent |
| 128px local compressed PNG source SHA mismatch | TOOLING ERROR not visual | same RGBA image yielded different PNG byte SHA with encoder changes | source-lock exact decoded RGBA and stage source filename, preserve PNG hash separately | FIXED, failed attempt before API charge |
| Prompt exceeded edit-image-pixen 500-character limit | INPUT SCHEMA | provider HTTP 422 | shortened descriptions and cached exact API schema in generator | FIXED, rejected before generation |
| Stage3 160px final image 2 pixels on left edge | NONBLOCKING | static stage3 alpha edge count=2 | logged, unchanged under 2-round microfix cap | OPEN_NONBLOCKING |
| Human visual authorization of TB02 3 stages / motion | ART_GATE | No user approval of new species yet | provide Godot screenshots, Idle+Attack GIF and family manifest | ART_REVIEW_PENDING |
| Full FS battle-camera rig/pivot integration | INTEGRATION GATE | stand-alone native renderer only, not full battle scene | scheduled after user visual acceptance | PENDING |

**No false PASS**: PixelLab and Godot TECH PASS do not constitute user art approval. Preserve 96px and stage2 rejected candidates for learning. Cost 22.0 generations (7 actual paid jobs). No mutations to other T-A, T-C, main branches. No permanent asset results on owner's PC; transient source staging cleaned after cloud upload.
