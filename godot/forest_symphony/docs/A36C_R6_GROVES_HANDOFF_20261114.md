# A36C R6 | Real Godot forest grove geometry | 2026-11-14

## Actual committed engineering
- New Godot scene `scenes/a36c_r6_forest_groves_80x58.tscn`, manifest `data/a36c_r6_forest_groves_manifest.json`.
- R4 1 + R5 28 + R6 39 = 68 tree movement events across versions. R6 uses nearest 3 tree centroid to form local grove clusters; no source asset, tree count, object ID, footprint, Ground or Shadow changes.
- World 2560x1856 @32px, 310 trees, 326 full independent PAR object owners, six existing families.
- Immutable A36B R2 and PR #16 branch maintained. Godot 4.7.2 ONLY; no VX.

## Source QA actually performed
- Live GitHub fetch after both new files committed; JS field-by-field R5->R6 compare PASS: 39 actual changed positions match 39 declared changes, all unchanged tree asset metadata, 326 objects and 326 scene source nodes, Ground and Shadow manifests identical.
- Godot 4.7.2 native screenshot NOT RUN. Runtime walkability/river clearance NOT VERIFIED. No private artwork downloaded this round. CI for latest R6 not run/verified.
- No new tree silhouettes, no new ground painting, no animated water. ART HOLD, COLLISION HOLD, WATER NOT_IMPLEMENTED, FORMAL SEAL NO.

## Failure log
- Prior iterations overemphasized manifests and documentation without visual deliverable.
- R4 only moved one tree; R5 and R6 increased geometric change, but spatial edits alone do not equal art quality.
- Native R6 image and path clearance missing. Do not promote R6 as visually better until actual private Godot A/B render and collision tests.
- Remote desktop was online but known E:\GodotProjects contained TSG_LPC_MILITARY_V06 and VX_SBS_Godot_Prototype, not a verified private A36B R2 copy. No permanent PC files written.

## Next non-negotiable work
1. Obtain owner-only A36B R2 ZIP and verify exact 54,150,993-byte archive SHA 7e1cd53397aeb76deb09ceed0dc3002b5b7cc56c0a7fe40fac684a32eda6ac2b.
2. Build temporary native Godot 4.7.2 R6 scene and capture true 1x before/after image.
3. Reject moved trees overlapping road/river, verify player footpoint/YSort/collision.
4. Create new full transparent independent RGBA trees (2-6 species) and improve Ground; preserve all private images in owner-only Drive.
5. Only then advance art gate. Update GitHub+Drive Handoff and Failure Log each round.
