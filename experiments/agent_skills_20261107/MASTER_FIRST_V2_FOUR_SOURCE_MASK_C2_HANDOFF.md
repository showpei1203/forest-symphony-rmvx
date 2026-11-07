# FS Master-first V2 / C2 source-registered Ground + PAR probe (2026-11-07)

## Exact scene and source invariant
The new user-directed workflow starts from ONE full AI-created elf-village master image. Raw 1473×1068 AI separate Ground/PAR from V1 did not align (12 exact pixels, RGB MAE 40.136). **Do not use their independently generated object RGB.** From the V1 archive, use the exact 1280×928 frozen master `VX_MASTER_RUNTIME_FULL_GROUND_1280x928.png`, with source SHA in V1 `FS_MASTER_FIRST_QA_REPORT.json`. This is the only pixel RGB authority.

V2 actually made four world-coordinate source-mask image objects, not a new detached concept render:
1. `LEFT_HOUSE_ROOF`: initial hand polygon 16,013 px → C2 GrabCut 12,169 px;
2. `RIGHT_HOUSE_ROOF`: 23,303 → 17,601 px;
3. `LEFT_TREE_CANOPY`: 42,534 → 33,600 px;
4. `LOWER_RIGHT_TREE_CANOPY`: 58,884 → 55,055 px.

Each C2 object is a source-canvas alpha mask with **RGB copied from exactly the same (x,y) in MASTER**. The C2 combined partial RuntimePar has **118,425 nonzero-alpha pixels**; it is **not** whole-scene PAR. No scaling after segmentation, no tile-aligned rectangle mask, no independently redrawn roofs/trees.

## Actual four-layer delivery, not just a picture
- `VX_RUNTIME_FULL_GROUND_MASTER_1280x928.png`: unchanged complete master, RPG Maker VX scene background candidate.
- `VX_RUNTIME_OCCLUSION_PAR_4_C2_SOURCE_REGISTERED_DRAFT.png`: only four roof/canopy groups which *might* occlude the actor. All RGB per-pixel exact from frozen master.
- `AUTHORING_GROUND_ONLY_AI_UNDERPAINT_DRAFT.png`: retains master exactly outside proposed object cutout, and uses AI ground inpainting **only behind** the proposed Authoring CompletePAR mask. It is a candidate hidden-ground restoration, not the VX complete runtime background.
- `AUTHORING_COMPLETE_PAR_SOURCE_MASTER_MASK_DRAFT.png`: broad AI-alpha proposed "all above-ground objects" mask but with visible RGB from master. **Not the actor front/occlusion layer**. Per-object semantics not approved.

Both `Runtime FullGround + Runtime 4-source PAR` and `Authoring Ground + Authoring CompletePAR` reconstruct the master with **0 mismatched RGB pixels BY CONSTRUCTION** (as the foreground under alpha exactly samples master). This is a mathematical registration check, **not** a silhouette or VX PASS.

## Direct first QA and C2 fix
- Initial broad manual polygons covered wrong nearby foliage, especially on the right house. The first mask is preserved as failure/reference.
- C2 applied ROI-confined OpenCV GrabCut with definite source-material seeds (roof timber vs vegetation, canopy green), bounded to existing polygons. Refined mask coverage drops ~24–25% for roofs and ~21% for left canopy. Still **ART SEMANTIC DRAFT**, green vines/trees and foliage/path borders can remain mixed; does not prove per-leaf correct contours.
- C2 4-in-1 witness `QA_V2_C2_REFINED_MASKS_ON_MASTER.png` versus before `QA_SEMANTIC_4_OBJECT_MASKS_OVER_MASTER.png`, 1x crop pairs each object, full scene contact `QA_C2_CONTACT_4_VIEW.png`.
- A 40×29 COLLISION **draft** is manually annotated: 333 blocked / 827 free, with bridge deck explicitly exempt from stream mask. **Do not claim this is real VX native tile state or correct walkability**. Candidate clear controls: tile (20,15), (24,24), (14,12); all are draft walkable with 0 alpha actor-body overlap. Initial (20,13) was a false clear due standing-stone blockage and replaced: keep that error as caution.
- Real `Game.exe`, Map050 export and switch203 tests on the **new master** have **NOT RUN**. Prior A36G/R7 native tests were on *different art and map*, must not be reused.

## QA gate summary
| Gate | State |
| --- | --- |
| Frozen single master, 1280×928 target and source SHAs | PASS |
| Four PNG actual same-source RGB/object mask outputs | PASS / geometric |
| Runtime FullGround + four-source C2 PAR exact RGB reconstruction | PASS **BY CONSTRUCTION** |
| Authoring composite exact source RGB reconstruction | PASS **BY CONSTRUCTION** |
| Four C2 source mask silhouettes and real object/foot-depth semantics | **REVIEW_REQUIRED** |
| Ground hidden underpaint visual plausibility | **REVIEW_REQUIRED** |
| Master-first whole map complete PAR geometry | **NOT COMPLETE** |
| Native 40×29 collision, 203 actor positive/negative and move | **NOT RUN** |
| Artist approval | **PENDING** |
| Formal Seal | **NO** |

## Reproduce
Download conversation attachment `FS_MASTER_FIRST_V2_C2_SOURCE_REGISTERED_20261107.zip` (contains 47 files, ZIP CRC verified): the actual original master, four masks, original vs GrabCut candidate cutouts and witnesses, authoring and runtime layer PNGs, `build_fs_masterfirst_v2.py`, `refine_fs_masterfirst_v2.py`, `finalize_fs_masterfirst_v2.py`, JSON QA and SHA256 manifest. Needs Python 3 + numpy + pillow + opencv-python.

For staging use isolated directory only, no writes to R5/R7/A36H sealed assets. Before claiming a validated new RPGVX scene, refine actual outlines and legitimate walkability at two test positions, then import `Runtime_FullGround` and `Runtime_OcclusionPar` with a new isolated Map050 clone, native `Game.exe` fixed camera OFF/ON `$game_switches[203]`, movement, negative controls, screenshot difference, source SHA. Do not install unreviewed alpha as a game asset.

**Evaluation:** This proves the *new master-first source-registered method is technically implementable*. Full Ground/PAR segregation **not yet approved**. No formal merge of new scene.
