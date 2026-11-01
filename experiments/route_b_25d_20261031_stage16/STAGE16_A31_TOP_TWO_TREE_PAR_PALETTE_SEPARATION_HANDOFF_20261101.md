# Stage16 A31 — two top PAR tree canopies vs busy grass: color/edge separation
Date 2026-11-01 (Taiwan). **A31 is an isolated visual candidate and engineering benchmark; not art acceptance; Formal Seal NO.**

## User review and constraint
User sees both upper left and upper right PAR trees blend into the grassy Ground. Do not flatten Ground/PAR, do not re-generate entire image, do not touch Ground source. Existing A30 true native VX map50 (not a Godot-only preview) is the starting point. User permits independently authored PAR sprites after visual style confirmed; for this request it is safer to retain existing trees and adjust their own foliage palette only.

## Inputs and exact changes
- Real Ground: A27 PixelLab native opaque 544×416 SHA256 35c454c82d4f32906de39702a8463ca72316b14e157239604c18971bd67d00ce **byte-identical to A29/A30**.
- Original 12 distinct A30 PAR sprites; adjusted ONLY `drive_broadleaf_west` and `drive_broadleaf_east`, at their original x/y/foot. Original top trees are full RGBA source sprites from Drive-based Trees1 assets, NOT a whole-image recolor.
- Original sprite alpha bytes = modified sprite alpha bytes for all pixels, original bounding rectangles unchanged, nonfoliage/root/trunk RGB identical. Existing ten other sprites, collision E-layer (12 blocked, 209 walkable), Map050 rvdata unchanged.
- Original tree foliage mask: alpha >0, G > 1.10R, G >1.22B, G>38, y less than 80% of local sprite height. Leaf pixels west 9,029, east 10,259. Internal 1–2 px existing alpha-boundary foliage only receives darker color; NO alpha outline pixels added.
- Tunings tested: subtle, balanced, strong. **Balanced candidate selected for native VX test:** foliage R×0.85, G×0.96, B×1.35+2, local RGB contrast ×1.19 about per-tree original leaf mean, silhouette foliage edge RGB×0.75, canopy underside darkening factor down to ×0.93. This is RGB-only reproducible tone separation, not soft blur or antialiasing.
- A31 balanced distinct PNG files `A31_balanced_drive_broadleaf_west_RGBA.png`, `A31_balanced_drive_broadleaf_east_RGBA.png`.
- Rebuilt full independent RGBA `A31_PAR50_BALANCED_RGBA_544x416.png` and updated **only the isolated A31 clone's** `Overlays/Par50.png`. Its alpha matches A30 PAR50 pixel-for-pixel. The exact original 12-sprite composite was first verified to equal original A30 Par50 in all RGBA pixels. A31 changes ONLY the two top trees: 19,287 changed RGB pixels in PAR; 0 changed pixels outside original two-tree alpha. Source-composited Ground+PAR preview 19,251 changed RGB positions, bounding x14..515, y24..154; 0 differences below y205. The Ground is untouched.
- Four-way zoom and 544×416 scene contact sheets: `A31_FOUR_WAY_TREE_ZOOM.png`, `A31_FOUR_WAY_FULL_SCENE.png`.

## Actual native RMVX isolate and QA
- Distinct fresh native copy `E:\FS_STAGE16_A31_TREE_CANOPY_VX_CANDIDATE_20261101` derived from A30 isolated true VX map, new two sprite replacements and recomposed Par50. Original A30 remains untouched.
- No engine Z, collision or walk code changes as part of art edit. In A31 test-only RGSS script the scripted actor scenario auto-test was repaired: call `$game_player.moveto(x,y)` at the visible phase too, ensuring sprite x/y matches actual test tile before screenshot. Failed earlier auto-test had misleading image/actor positions due character interpolation. Never claim the failed case screens PASS; keep failure archive.
- Another test runner mistake: copied script looked for `A31_VX_ACTUAL_MAP_RUNTIME.log` although the RGSS script still writes `A30_VX_ACTUAL_MAP_RUNTIME.log`; failed first capture with zero cases. Fixed runner only. Engine was not failing.
- Final actual Game.exe RGSS Player: **24 valid frames / 12 scenarios**, no error modal, native map entered, 12 independent PAR sprites loaded. No forced superimposition outside engine. Native actor 627 opaque pixels: true full-hide east (14,3) visible ROI 0; west partial (3,4) visible ROI 404; east partial (15,4) visible ROI 417; front (2,6) visible ROI 627. Native down into tree collision (2,4)->(2,4) blocked; native right along road (8,6)->(9,6) walk succeeds. Unmodified tree alpha means occlusion semantics preserved.
- `A31_NATIVE_VX_TREE_BEFORE_AFTER_MOBILE_544W.png` is 544×2730, contains REAL A30/A31 native Game.exe no-actor screenshots and 2× nearest neighbor close-ups of west and east trees, not fabricated image.
- QA: `A31_CANDIDATES_MANIFEST.json`, `A31_VX_TREE_INTEGRATION_QA.json`, `A31_PAR50_RECOMPOSE_QA.json`, `A31_FINAL_NATIVE_VX_VISUAL_PASSAGE_QA.json`, `A31_VX_TREE_BEFORE_AFTER_IMAGE_QA.json`, `A31_VX_NATIVE_12_CASES_SCREEN_QA.json` with actor snapshots. A31 cold native evidence maintained in a separate QA (if completed); do not imply exact 24/24 native screenshot SHA cold parity.

## Status and handoff
A30 Ground source, true VX depth and ISS ParaPassa authority unchanged; new aesthetic improvement candidate engineering PASS with true per-layer assets. User visual acceptance is PENDING. Any future A32 sharpening should start from A31 balanced only AFTER user judges tree-vs-Ground integration. Do not add entirely new colored rim/ground shadow as a silent substitute for this visual request. Pixel-perfect studio-grade art remains unsealed.
Private binary art can be placed in user's Drive or private ZIP only, not public GitHub (uncertain source licenses).
**Formal Seal NO.**
