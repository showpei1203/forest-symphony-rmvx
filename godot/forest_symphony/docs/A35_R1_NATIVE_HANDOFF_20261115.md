# Forest Symphony | A35 R1 Forest Groves Native Handoff | 2026-11-15

## Scope
Godot 4.7.2 only, A33/A34 elf village map art workline, not separate A36C large-forest workline. No RMVX. Existing A34 R4 default scene, independent buildings, A33 lamps, A32 Ground unchanged.

## Real construction
- Additive scene: `res://scenes/a35_r1_forest_groves_scene.tscn` based on exact sealed A34 R4.
- 8 grouped forest continuations add **41 independently selectable and physically colliding complete-tree PAR owners**. 146 -> 187 independent PAR owners; 134 -> 175 trees, 15 visual families reused for additions.
- Existing 146 owners remain at identical positions and source hashes. No crop from flattened Master, no new Ground art. All new trees have 22x12 root collisions, Y-sort pivot at footpoint.
- Deterministic source builder `tools/a35_r1_build_forest.py`, full manifest `data/a35_r1_forest_groves_manifest.json`, source-only GitHub 4.7.2 runtime, real and navigation tests.

## Godot native QA, independently verified
- Engine RX 6700 XT Godot 4.7.2 OpenGL 3.3; **1601/1601 original-source checks PASS Exit 0**.
- Physical 80x58 map of 16px foot probes: **8/8 gates PASS Exit 0**, 4/4 north-south, west-east, village-to-west-house, village-to-east-house routes preserved. 67 newly blocked non-road cells; 0 newly blocked protected road cells.
- 4 native framebuffer PNG at 1280x928 from GPU **Exit 0**; A34 vs A35 RGB delta 95,610 pixels, **0 outside appended tree ROIs**. Tree actor behind delta 0, front 554.
- Original Ground SHA `3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000`; original A34 scene SHA `7b692954563b0ecaaea541b064ea0d36a046225c21fcad7eb5544f72ce37557c`; original private R4 ZIP SHA `dd2ecf7612e45d65c8fbb04515e0f0c94a69af449c941f6d9a7db71787f9d6f0`.

## Ownership and files
- Public GitHub branch `feat/fs-godot-first-a29-20261113`, draft PR #16: scene source, engine script, manifest, 3 native Godot tests, deterministic builder, public-source no-private-PNG CI. Do NOT upload private PNG to GitHub.
- Owner-only Drive native evidence folder: https://drive.google.com/drive/folders/1pfTUIXgOfVlV_12_G8SD8q_udNJM9Vjv
- Owner-only Drive candidate archive: https://drive.google.com/file/d/1vRcyqFsLlgyq8jYhuHJcwG5YU3uTVqcO/view
- This final package includes all 4 native screenshot PNGs, original private A34 assets, public tests, source changes, QA and Failure Log.

## Art gate and next
ENGINE PASS, NAV PASS, ART HOLD (user 1x approval pending, visual repetition from reusing 15 tree families; Ground pixel density improvement still pending).
- A35 R2: create 8-12 truly different coherent native-resolution tree silhouettes and woodland/understory families, combine into natural edge groves, keep source-locked independent PAR and real Godot 1x regression.
- A36: separately repaint Ground road edges, native-size flowers, ground cover, coarse repeated texture in non-destructive variant; do not touch sealed Ground until approved.
- A37: implement validated collision, entrances and deeper canopy occlusion; A38+ automated map factory and fully navigable village acceptance.

## Failure log
See `docs/A35_R1_FAILURE_LOG_20261115.md`; prior A34 R2/R3 hash and incomplete-ZIP regressions are not repeated. Do not mark formal ART PASS.
