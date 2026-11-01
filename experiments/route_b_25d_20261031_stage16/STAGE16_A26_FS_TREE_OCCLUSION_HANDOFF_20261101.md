# Forest Symphony Stage16 A26 — FS real tree & actor occlusion plus no-charge Ground texture study
Date: 2026-11-01
**Engineering: native Godot 4.7.2 seven screenshots PASS; A26 collision graph PASS; formal FS Ground3 ART FAIL; original RPG Maker VX runtime NOT RUN; Formal Seal NO.**

## Authority
- Baseline: A25 authentic PixelLab Pro 544×416 raw model Ground, untouched SHA256 `aea3c4d2454b92a342c4670563b390b2dc36959ed112a92bfc24b6f1564f014c`.
- A24 original transparent FS tree-border, rocks, barrels and streetlamps remain source-bound and in the same scene coordinates.
- A26 isolated folder `E:\FS_ROUTE_B_STAGE16_A26_TREE_PAR_OCCLUSION_20261101`; no changes to sealed FS project, production Data, Game.exe or previous isolated A25 baseline.
- PixelLab requests this stage **0**, additional subscription generation cost **0**. Last positively checked account balance from A25: 1,933 generations; *not* queried again.

## Source-owned trees and actor
- Real VX graphics source under the existing FS project `Graphics/Parallaxes/FS_Dungeon/SAVE/TileB.png` (transparent RTP-like source, not regenerated or upscaled).
- Exact direct-pixel crops: conifer x160..191, y320..383 (32×64); roundtree x256..287, y160..191 (32×32). Alpha ranges 0..255; file/source SHA256 in `A26_SCENE_MANIFEST.json` and `A26_QA.json`.
- Genuine FS `Graphics/Characters/$actor01.png` (96×128 sprite sheet), extracted downward-facing central idle frame x32..63, y0..31 (32×32), not blue diagnostic human.
- New native trees at scene coordinates conifer (108,172), root pixel (124,235); roundtree (414,222), root (430,253). Original 10 A24 FS props retained. A26 has 12 actual independent alpha objects total.
- Y-depth order uses object foot coordinates, not a flattened global PAR above actors. Static A26_PAR_RGBA_544x416.png is a diagnostic composite only; dynamic sprite sorting is native Godot, separate from visual upper foliage.

## Collision and actual render evidence
- 544×416 / 32 = 17×13=221 cells. Prior A24: 34 blocked, 187 walkable. New 2 real tree-root cells block (3,7) and (13,7): **36 blocked**, **185 walkable, all 185 BFS-reachable** from road actor at (320,200). Top and bottom map edges remain connected; entire canopy does NOT make all cells impassable.
- **7 distinct new real Godot 4.7.2 OpenGL compatibility screen files** under `GODOT_A26_ISOLATED/out/A26_GODOT_*.png`, proof `A26_GODOT_NATIVE_RENDER_PROOF.json`, engine stdout `A26_GODOT_NATIVE_RENDER_PASS SCREENSHOTS=7 TREE_COUNT=2 REAL_ACTOR=YES`.
- True original FS actor behind conifer: 617 opaque alpha-overlap pixels; in actual screen **94.652%** of those pixels remain consistent with no-actor tree image (a subset may differ due to exact geometry and sprite-edge blending). This is a thresholded, not pixel-perfect proof.
- In front of conifer: 334/334 opaque overlap pixels changed from no-actor tree scene. **Important: this actor foot (124,245), tile (3,7), is blocked by tree root, so it is a renderer diagnostic, NOT a legal movement position.**
- Right of conifer: actor tile (4,6) WALKABLE. Behind conifer: actor tile (3,6) WALKABLE.
- Behind roundtree: actor tile (13,7) blocked, so only an occlusion diagnostic; front of roundtree actor tile (13,8) is **WALKABLE**, shows 344 changed overlap pixels and visual foreground.
- Actor on path at (320,200), tile (10,6), WALKABLE. These are still static render and grid BFS tests, **not actual RGSS2/VX Game.exe movement**.
- Avoid claiming arbitrary tree blocking from silhouette; foot-only collision definitions are separate from canopy alpha.

## A26 zero-paid microtexture experiment
- PixelLab raw A25 whole image has 26 unique RGB colors. A 96×96 mostly bare PixelLab meadow sample has 5 colors and mean horizontal 1px RGB gradient 0.571; the original FS clean grass reference 96×96 contains 6,933 unique RGB colors and mean gradient 12.883.
- These texture statistics are diagnostics, not numerical definitions of beauty.
- `a26_ground_microtexture_variants.py` creates two **DERIVED** 544×416 research images using overlapped, random-flipped/rotated source FS high-frequency detail from A21 genuine grass + original A10 sand, no resizing and without moving model-composed road/flowers.
- SOFT candidate: 96×96 grass patch 2,087 distinct RGB colors, 1px gradient 5.146; DENSE candidate: 4,653 colors, gradient 8.907. Pixels outside semantic grass/path/material masks changed: ZERO. Model raw PNG unchanged, SHA256 above.
- Both candidates **ART NOT APPROVED**; they do not count as PixelLab-native original Ground output, and neither reaches original FS Ground3 dense environment art and prop variety. Avoid repeating Stage15 low-value tiling: no false claims that more noise creates premium hand-pixelled art.
- A26 no-charge variants are kept separate from renderer source. Godot A26 actual rendering tested **RAW A25 model Ground only**.

## Failure register / fail-closed lessons
1. PowerShell invoked quoted Godot EXE as a string and rejected `--path`; corrected with explicit `& "full-path.exe" --path ... --rendering-method gl_compatibility`. Real engine proof now PASS.
2. Original automated assertion incorrectly demanded <=3 changed pixels behind conifer; observed 33 changes out of 617 overlap. Revised gate to require >=90% occlusion and explicitly reported actual 94.652%, never manufactured 100% equivalence.
3. Renderer-only overlap examples may place actor feet on blocked root tiles. Clearly mark them diagnostically; grid-valid rear/front/road positions are tested separately.
4. Tall conifer 32×64 and small tree 32×32 are existing project sprites but are visually undersized against the user's Ground3 reference. A26 technical PASS ≠ visual approval.
5. Native RPG Maker VX `Game.exe` in original folder was located, but no isolated VX integration build was run; **VX gate stays NOT RUN**. Never execute or patch the production copy.
6. A25 A26 Ground art still lacks vegetation density, building/landform scale, ecological coherence; SOFT/DENSE high frequency do not address composition. **Formal Seal NO**.

## Next A27
- Separate approved art process: obtain larger, real high-detail 2D isolated FS-quality canopy/trunk with proven alpha and 1x matching; use source-owned pixels or clearly identify newly created art. Add multiple tree shapes before village scale.
- Build an **isolated** VX test harness using copied Game.exe and cloned Data (never alter sealed production) and formal 32px passability / fore-aft occlusion checks in RGSS2. Until a new native VX screenshot is observed, keep VX NOT RUN.
- Integrate fully reproducible A26 private package, cold re-render 7 screens, verify hashes. Mirror handoff to GitHub and Drive when upload has been independently verified.

## A26 cold-rebuild proof
- Isolated private ZIP: 5,755,136 bytes; SHA256 f673b02bad2b0a3ecd6c108ce22ba622f1b25e68b5923c99968c32cda819647b; 59 members with SHA checks.
- Independent fresh extraction and new Godot 4.7.2 execution: 7/7 screenshot SHA256 exact matches, exit code 0. `A26_COLD_VERIFY.json` and `A26_BUNDLE_MANIFEST.json` retain evidence.
- Drive text handoff placed in the private Stage16 folder. Binary ZIP remains local; Drive binary upload not confirmed.
- Art FAIL, native VX NOT RUN, formal seal NO.
