# A36C R8 | Independent water animation candidate
2026-11-14. Authoritative: ACTIVE MASTER v1.3 Ground-first; Godot 4.7.2 only.
## Actual work
Downloaded SHA-verified private A36B R2 source ZIP from owner-only Drive; produced water-region mask and four distinct transparent RGBA river-glint frames at 2560x1856. Added an AnimatedSprite2D node to a new copy of A36B scene; script plays 4 frames at 5 fps. Preserved original Ground SHA ac591877b05c00543e6756e44e6ba81f6fea7e36086049e35de81e2610e0c911 and all 326 independent PAR object nodes. No Ground or tree changes. This is WATER subtask, not a Ground art improvement.
## Private artifact
[Owner-only ZIP](https://drive.google.com/file/d/1XGVDveCJlbWgYDUF6xR6mw6adA4PyiB6/view). Contains the complete candidate scene, script, 4 RGBA frames, water mask, two PIL 1x crop previews, and source QA manifest. Keep all private PNGs off public GitHub.
## QA / Failure Log
Source Ground SHA verified; four frame hashes distinct; scene 326 source objects; mask restricted to x<600; source-level checks PASS. **Godot native run NOT_RUN; collision HOLD; user ART HOLD; formal seal NO**. The water region is HSV/connected-component derived, so banks/blue flowers and bridge-edge segmentation need actual 1x visual/native QA. Four full-size transparent frames are memory-heavy and need optimization to tight water bounds after approval. Do not claim this resolves the original Ground native pixel-scale issue.
## Next
1. Run actual Godot 4.7.2 native import/render and reject water glints on bank/bridge.
2. Primary art gate remains Ground-only native pixel-scale riverbank/road/grass quality.
3. Only then approve independent PAR family and walkability.
