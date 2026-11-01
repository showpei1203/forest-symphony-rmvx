# Forest Symphony Stage16 A32: upper two broadleaf PAR pixel-edge alpha cleanup

**2026-11-01 Asia/Taipei. FINAL ENGINEERING CANDIDATE PASS, USER ART ACCEPTANCE PENDING, FORMAL SEAL NO.**
Branch: real Forest Symphony original RPG Maker VX Ground/PAR technique, isolated MAP50. Not the separate Sprite Sheet/PMD line.

## Read first
1. authority/FS_GROUND_PAR_SOURCE_FIRST_PRODUCTION_V1_20261101.md
2. authority/FS_PAR_SEMANTIC_ORIGINAL_OBJECT_GENERATION_V1_20261101.md
3. authority/FS_NATIVE_VX_DYNAMIC_PAR_OCCLUSION_PASSAGE_V1_20261101.md
4. experiments/route_b_25d_20261031_stage16/STAGE16_A31_TOP_TWO_TREE_PAR_PALETTE_SEPARATION_HANDOFF_20261101.md
5. THIS A32 handoff and A32 derived scene manifest.

## User mandate and decomposition
User says PAR should contain **objects and occlusion only**, while scene/environment SHADOW and LIGHT must be independently rendered. Specifically, two upper trees had blurry alpha/visual edges blending into grassy Ground; improve edge clarity using TWO LOWER TREES as edge reference. **A32 MUST NOT change any Ground data.** Next stage A33 must begin Ground visual rework, particularly the PixelLab-generated Ground's overly soft boundaries versus FS reference Ground3.

This A32 edit is not another whole-scene recolor. Follows A31 balanced leaf palette. Keep object's intrinsic painted pixel texture (including inherent leaf tonal variation), but do NOT introduce a cast shadow, bloom, dynamic lighting, ambient light overlay, or project SHADOW/LIGHT onto PAR. The scene's actual separate light/shadow systems are unchanged, not rebuilt in A32.

## Exact A32 source edit
A31 source (untouched): E:\FS_STAGE16_A31_TREE_CANOPY_VX_CANDIDATE_20261101
A32 candidate working dir: E:\FS_ROUTE_B_STAGE16_A32_TREE_EDGE_ALPHA_20261101
A32 isolated native VX clone: E:\FS_STAGE16_A32_TREE_EDGE_VX_CANDIDATE_20261101
Complete A32 scene object manifest: A32_SCENE_MANIFEST.json

Exactly two original individual transparent RGBA tree sprites updated:
- upper west: `A32_B_crisp_drive_broadleaf_west_RGBA.png`
- upper east: `A32_B_crisp_drive_broadleaf_east_RGBA.png`
All other 10 object PNGs, camera, actor, script, scene placements, depth foot, obstacle geometry, and the original Ground byte-identical to A31. Changed only files inside isolated clone: the two object sprites and the newly recompiled `Overlays/Par50.png`. This Par50 is composed from the same twelve individual sprites; it is not a replacement for those sources.

### Actual alpha and outline approach
Reference bottom southeast tree had binary alpha (0/255) and an obviously crisp contour. Southwest reference was partially alpha-ed; use southeast as cleaner silhouette target rather than smearing edges with hue/brightness. User's issue was the **outer silhouette**, not overall color.

Three alternatives were generated/compared visually:
- A_softcleanup: threshold82, in-pixel contour brightness×0.89;
- **B_crisp SELECTED: threshold130, in-pixel contour brightness×0.79;**
- C_hardcut: threshold176, contour brightness×0.74.

Only the *canopy region* y below 77% of each independent tree sprite is processed, with transparent pixel alpha at or above threshold set to fully opaque and below threshold set to 0. A ONE-PIXEL **inward colored foliage contour** is slightly darkened inside the already-rendered sprite; this is not an outside black shadow/bloom halo, and adds ZERO alpha outside original source. The bottom trunk/root and its original RGBA are byte-for-byte unchanged. Silhouette remains padded away from independent source canvas edge. RGBA transparent pixels are made RGB=0 outside the canopy, so no leftover green RGB matte. No new light/shadow assets are introduced.

Quantitative validation:
- west alpha nonzero count 13,377 → 12,860, removed 517 low-opacity pixels, canopy partial alpha 1,541 → **0**; original alpha bbox (5,4,131,153) → (5,7,131,153).
- east alpha nonzero count 15,347 → 14,618, removed 729 low-opacity pixels, canopy partial alpha 1,838 → **0**; original bbox (13,4,141,178) → (13,13,141,178).
- No existing zero-alpha source pixel becomes newly opaque. Exact source dimensions, lower trunk/root, foot, map X/Y and original collision E tile remain invariant.
- Exact source Ground PNG SHA256 `35c454c82d4f32906de39702a8463ca72316b14e157239604c18971bd67d00ce`. Both 544x416 Ground and Data/Map050.rvdata unchanged. All ten other individual PAR files untouched.
- RGB full Ground+PAR composition changed only **3,952 pixels**, bounded x14..515 and y17..152, zero changed lower-map pixels below y205 (unlike entire-frame generative redraw).
- Output `A32_B_crisp_PAR50_RGBA.png` is rebuilt from actual twelve sprites; independently exact pixel-check equal to the isolate Overlays/Par50.png. Shadow/Light separate, never fused into the PAR.

## Actual native RPG Maker VX QA
Original isolated native VX Game.exe, RGSS Player HWND client 544×416, map50. All test-only, original production not altered. Test-only BattleRegression alias bypass inherited from A30; must not promote edited Scripts.rvdata to production. Existing FS actor and ISS ParaPassa real E layer 768=block/769=pass and source character z sort are retained.

Re-ran 12 scenario placements and **24 actual native RGSS Player screenshots**, no #32770 error dialog. In source actor tile 32x32 ROI, original actor fully visible has 627 opaque pixels:
- east canopy **fully behind 0/627 visible**
- west canopy partial **351/627 visible**
- east canopy partial **357/627 visible**
- front of trees **627/627 visible**
- original tree base block: (2,4) move down stays (2,4)
- open road: (8,6) move right reaches (9,6).
As expected, edge alpha cleanup changes partial silhouette occlusion counts but DOES NOT break front/back semantics.

## Independent cold VX QA
Fresh clone E:\FS_STAGE16_A32_TREE_EDGE_VX_COLD_20261101 (not modified original).
- **3,395/3,395 files match SHA256** compared with A32 isolate.
- Cold native Game.exe launched Map50, 12 objects loaded; 0 modal; actual RGSS Player frame 544×416 with 31,338 distinct colors.
- Full frame-for-frame 24/24 cold screenshot SHA parity is NOT claimed.
- Prior A29 Godot 8/8 cold PASS is an **unchanged old baseline**; no new independent A32 Godot GPU replay has yet been made, so do NOT claim both engines retested this round.

## Reproducibility/visual proof and acceptance
- 4-way comparison `A32_FOUR_WAY_TREE_EDGES_ZOOM.png` and `A32_FOUR_WAY_FULL.png`, rendering source Ground+independent exact-object PAR, never an invented full-scene raster.
- Genuine native A31 vs A32 comparison `A32_NATIVE_VX_BEFORE_AFTER_MOBILE_544W.png`, 544×2962, full actual native no-actor A31 and A32 map screenshots + west/east enlarged crops and lower-tree edge reference.
- `A32_B_crisp_drive_broadleaf_west_RGBA.png`, `A32_B_crisp_drive_broadleaf_east_RGBA.png`, `A32_B_crisp_PAR50_RGBA.png`.
- QA: A32_CANDIDATES_MANIFEST.json, A32_SILHOUETTE_ALPHA_QA.json, A32_NATIVE_VX_BUILD_MANIFEST.json, A32_NATIVE_VX_ACTOR_OCCLUSION_PASSAGE_QA.json, A32_BEFORE_AFTER_VISUAL_QA.json, A32_VX_INDEPENDENT_COLD_REBUILD_QA.json.
- Full private sprites/evidence must remain in Drive; public GitHub only script method/authority/manifest/Handoff and redacted QA, not third-party binary art without license.

## Next stage A33 MUST BE Ground-first pixel edge restoration
**NON-NEGOTIABLE NEXT TASK:** user's current PixelLab native Ground still has too much soft/buzzy edge when compared with example style, notably Ground3. The A32 master source stays frozen with SHA above and its native QA, but A33 shall use a NEW isolated Ground candidate (new SHA expected) to repair boundaries. Read original PixelLab PNG and grounded reference Ground3 1280×928; compare actual grass/path texture transition and existing FS reference for pixel-crisp contours. No generic global unsharp mask or anti-aliasing, no incorrect shadow/light baking, no retexturing whole map without layer tests. Identify flat terrain/material transitions, ground-attached grass/flowers, and ensure PAR remains independently authored. Preserve original A32 for reversibility; test candidate Ground with exactly A32 PAR sprites, native Godot and VX, foot/collision unaffected. Review before/after closeups and cold rebuild. A33 start is **Ground style research/edge pass**, not new PAR trees.

**A32 Formal Seal NO; art approval and complete A32 Godot cold native replay pending.**
