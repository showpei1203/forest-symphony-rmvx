# FS V6 P3 R1 | Actual Ground B + House/Tree/Flora Isolated Scene | 2026-10-26

**Verdict: TECH 13/13 PASS; HOUSE CONTACT ART FAIL; HUMAN PENDING; RGSS2 NATIVE NOT RUN.**

## Source-first scene produced
Ground B 544x416 (17x13) combined from original approved-to-proceed V6 P2 source with previously available isolated FS house 261x183, complete sacred tree 213x224, GrabCut flora 57x57. Actual VX Actor1 frame 32x32 (visible 28x32). No independent second scene generation; all derivatives share canonical object XY/foot anchors.

Derivatives: GROUND_OPAQUE, PAR_COMPLETE, entity ownership Alpha Masks, Pixel Owner ID, hard footprint and blocked 17x13 cells, 2x nearest scene review, Actor1 in 4 world stand locations. 15/221 grid cells blocked by actual house/tree foot contact; default Ground and soft flora walkable. Doorfront tile (4,7) walkable and reachable from spawn (8,10). One-pixel shift of tree detected 28,973 changed pixels.

## Repeatable evidence and storage
Windows QA script 13/13 PASS; cold unzip verified 28 SHA256 file hashes; cold source recompile gave matching composite hash 3f655dba13206fd29328a8efa691cf7b26bc71ba76f8a215e69952e3e4307aad.
ZIP 6,747,918 bytes, sha256 12857fd9f23e832811cd4121010905035253f5014a7373b27317a66bf5b1945f, downloaded again from cloud Drive and SHA validated:
https://drive.google.com/file/d/1szzAszbFIgvkPuP_5bt3beEIJDqCjN5R/view
Actual embedded preview screenshots: https://docs.google.com/document/d/1LCcZ6YkEnw5Iasm1i5AIEvyUpGmLT0CxA0w5cQ6vDNU/edit
Reproducible script: https://github.com/showpei1203/forest-symphony-rmvx/blob/main/tools/fs_map_v6/compile_p3_r1_source_scene.py
Windows workspace: E:/GameAssetToolLab_20261023/MAP_TARGET_V6_20261026/P3_R1_SINGLE_SOURCE_ASSETS_20261026

## Fail closed, no premature promotion
FS-ART-106: existing wood cottage source has baked grass, flowers and earth at its base, likely mismatched against new Ground B; source has full uncut silhouette but NOT clean semantic ownership of Ground contact. Repair/re-author source and independent contact transition before formal art or native compilation.
FS-ART-105: GrabCut flora alpha still pending hand refinement; tree relative world scale 213x224 vs Actor1 28x32 needs human review. P2 Ground B is accepted as a working candidate but no user final composite visual PASS has been issued.
Real RMVX Game.exe, RGSS2 Events and Scroll NOT RUN. Sealed FS and parallel map conversation files untouched.

## Next step
P3 R2 source revision: remove cottage baked underpaint with source-faithful mask, restore full flowers/barrels/steps, true Ground-under-object and optional contact shadow independent. Re-run actor occlusion/collision and pixel negative tests, require real user art acceptance. Only then consider Native adapter.
V6 authority: https://docs.google.com/document/d/1aypbyssZaYh1SG8cae0iK98JW5ufU__xcXA-q3gLZu8/edit