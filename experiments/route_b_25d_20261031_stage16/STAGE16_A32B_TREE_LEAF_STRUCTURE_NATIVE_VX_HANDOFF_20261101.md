# Forest Symphony Stage16 — A32B upper two tree leaf structure rebuild
Date: 2026-11-01 (Asia/Taipei). **A32B engineering PASS, visual review still PENDING. Formal Seal NO.**

## Mandatory read
1. `authority/FS_GROUND_PAR_SOURCE_FIRST_PRODUCTION_V1_20261101.md`
2. `authority/FS_PAR_SEMANTIC_ORIGINAL_OBJECT_GENERATION_V1_20261101.md`
3. `authority/FS_NATIVE_VX_DYNAMIC_PAR_OCCLUSION_PASSAGE_V1_20261101.md`
4. **NEW** `authority/FS_PAR_LEAF_STRUCTURE_VISUAL_QA_V1_20261101.md`
5. THIS Handoff and adjacent `STAGE16_A32B_LEAF_STRUCTURE_FAILURE_REGISTER_20261101.md`
6. `STAGE16_A32_PAR_TREE_CANOPY_PIXEL_EDGE_NATIVE_VX_HANDOFF_20261101.md`, A32 source/manifest, Ground3/Drive art reference.

## User request and artistic correction
A32 was REJECTED artistically despite technically crisp outer alpha: the upper trees lacked internal visible leaf strokes / foliage segment boundaries compared with two lower trees. A32B now modifies **actual internal foliage RGB structure**, not outer alpha or general tint. The two lower tree original RGBA sprites guided real palette/leaf shape; no whole-scene or canvas raster substitution. No new environmental SHADOW/LIGHT in PAR. Object-intrinsic leaf-color variations do not grant permission to bake environmental lighting.

## A32B sources and scope
- Source A32 locked isolate: `E:\FS_STAGE16_A32_TREE_EDGE_VX_CANDIDATE_20261101`.
- New A32B private work: `E:\FS_ROUTE_B_STAGE16_A32B_LEAF_STRUCTURE_20261101`.
- NEW actual RPG Maker VX isolated game: `E:\FS_STAGE16_A32B_TREE_STRUCTURE_VX_CANDIDATE_20261101`.
- Original A27 native PixelLab Ground at 544×416 SHA256 `35c454c82d4f32906de39702a8463ca72316b14e157239604c18971bd67d00ce`, **UNCHANGED**. `ground3.png` unchanged. Real 17×13 Map050, System, all existing test RGSS scripts exactly unchanged.
- Twelve PAR sprites, only original upper west/east `drive_broadleaf_west/east` changed. Ten other sprites exact SHA. Original dimensions and RGBA alpha per pixel EXACT MATCH A32; original lower trunk/root bytes unchanged; all original x/y and foot/collision untouched.
- In isolated A32B `Overlays` exactly 3 files differ: 2 upper object PNGs and the recompiled transparent `Par50.png`. Recompiled from 12 individual sprites; output `A32B_FINAL_PAR50_RGBA_544x416.png`.
- Chosen variant `A32B_structured_390`: original upper tree canopy lobes manually mapped at native sprite scale; 390 input leaf strokes/tree distributed over 8 lobes; use lower-right source sprite foliage color palette medians for dark crevices and short angular/pointed leaflets; partially broken small lobe boundary arcs and asymmetric bright leaf clusters. No Gaussian blur, no blanket sharpen, no new shadow/glow outside sprite or overlay lighting. Other V1/V2/V3/V4 rejected alternatives documented in failure register.
- West actual edited foliage RGB pixels **2,334**. East **2,300**. A32-derived alpha channel completely identical for each pixel. Recomp Ground+PAR exact scene image differences 4,634 pixels, bounded [x19,y30,x509,y153]; bottom map unchanged.

## Actual native VX engine proof
- True original `Game.exe` (RGSS Player), not a generated single raster. Camera 544×416 Map50. Native hidden/actor paired captures: **12 cases, 24 screenshots, 0 error modals**.
- Original source player opaque 627 pixels. Full east canopy hide at (14,3) **0/627 changed** (fully hidden). West partial at (3,4) **351/627**, east partial at (15,4) **357/627**. Front and road baseline **627/627**.
- Native ParaPassa blocking verified (2,4) → (2,4) when moving down into blocked tree; right road move (8,6) → (9,6). Existing ISS::ParaPassa E special IDs 768 blocked and 769 walkable with 209/209 reachable baseline; no temporary custom collision override. Scene Map50/Test scripts byte-identical A32.
- Verified native `A32B_NATIVE_VX_FINAL_QA.json`, screenshots `A32B_VX_NATIVE_CASE_*.png` and `A32B_ACTUAL_NATIVE_VX_BEFORE_AFTER_MOBILE_544W.png` 544×2164, containing real before/after no-actor Game.exe and 2× nearest-neighbor west/east tree crops.
- Separate source-ground composite comparison `A32B_GROUND_PAR_SOURCE_DIFF_544x832.png`; does not replace true native evidence.

## Fresh isolated native cold run
- `E:\FS_STAGE16_A32B_TREE_STRUCTURE_VX_COLD_20261101`, **3,395 / 3,395 files per-file SHA256 identical** with new A32B isolated source.
- Fresh native Game.exe executed Map50, all 12 objects loaded, no RGSS modal. Native HWND frame had 28,898 colors. FULL 24/24 repeat-frame SHA pixel parity NOT ESTABLISHED.
- Previous A29 Godot 8/8 remains historical baseline; **no A32B fresh Godot GPU replay claimed**. Full production sealed FS battle test-harness script compatibility from A30 remains separate unresolved issue.

## QA classification and next mandatory step
- Engineering: true PAR layers, source integrity, native VX movement and occlusion, cold clone = PASS. Visual leaf shapes: candidate perceptually improved by new angular strokes, but user must inspect; **ART SIGNOFF PENDING** (do not claim formal artistic success).
- Actual source/QA: `A32B_VX_BUILD_QA.json`, `A32B_VISUAL_COMPARISON_QA.json`, `A32B_NATIVE_VX_FINAL_QA.json`, `A32B_VX_INDEPENDENT_COLD_REBUILD_QA.json`, all original and rejected prototypes.
- Deliver private source two independent transparent sprites `A32B_FINAL_drive_broadleaf_west_RGBA.png`, `A32B_FINAL_drive_broadleaf_east_RGBA.png`, full `A32B_FINAL_PAR50_RGBA_544x416.png`, mobile true native comparisons, failures and SHA ZIP. No legacy asset binary in public GitHub.
- **Only after user explicitly accepts A32B artistic quality** is A33 authorized to modify Ground: repair PixelLab-generated Ground's soft/buzzy grass, road and terrain boundary compared to Ground3, in a new A33 isolated Ground source; preserve A32B as immutable prior evidence. Existing A33 input audit does not constitute a Ground edit.
- `Formal Seal = NO`. Do not confuse native VX engineering success with acceptance.


## A32B verified private Drive deliverables (2026-11-01)
- **Native VX before/after mobile comparison**, 544×2164, A32 vs A32B full-scene and upper-tree close-ups: https://drive.google.com/file/d/1gmS8iLlEKXx59gBKMkbONYZvPfoosGSP/view
- Independent upper left original sprite reworked RGBA: https://drive.google.com/file/d/1GdnzL6lzk5rfaIn8zru49zrKHqYy95VF/view
- Independent upper right original sprite reworked RGBA: https://drive.google.com/file/d/1FoPtoHwTqQbsLGaPJADI24wAgIeDMbJZ/view
- **Recompiled PAR50 transparent 544×416**, exact 12 sprite composite: https://drive.google.com/file/d/1S8NCAVbx2rqVFLdCyouFCuImxfb8lU3W/view
- Selected first morphology prototype vs A32 zoom, plus discarded alternatives retained in evidence: https://drive.google.com/file/d/1vhjYwn717DWKLf5m_yiy_eRS9AkD3nEa/view
- **Complete private evidence ZIP**, 81 entries, 10,366,572 bytes (local CRC, individual SHA256 and independent extract all PASS; Drive metadata/title/size confirmed, but no remote full ZIP SHA claimed): https://drive.google.com/file/d/15_JDEYBjdtYPp5Ce0vZTwAlsP27MfbWf/view
- A32B native VX QA: https://drive.google.com/file/d/16TzIRfBpx5KCAUgX5PTshhJoMG36lmFO/view
- A32B independent cold QA: https://drive.google.com/file/d/1Ep0VPG6XZKXFdn7nilzj2Jxr57D07O_d/view
- A32B detailed Handoff: https://drive.google.com/file/d/1JlMi251_J-WnU4BXRbmsVR6ee0GxOAL-/view
- A32B specific **failure register**: https://drive.google.com/file/d/1nb0QVuEe8ZIDUuNdk0WJ0MhCdwpYHOJ7/view
- A32B **permanent leaf-structure QA**: https://drive.google.com/file/d/199Vk1JLY7hoJcapVgk9CsXNWfLRoVS6z/view
- A32B **CURRENT_HANDOFF**: https://drive.google.com/file/d/1H0evpqJX92M1JToC8eXnFlWFcW3p9VJ5/view
- A32B private Drive folder: https://drive.google.com/drive/folders/1ZCl8pwvwTKlZXxOwGuVyd15Z-eSx4UjG

**Status stays ART PENDING, Formal Seal NO. A33 Ground editing waits for user's A32B visual approval.**
