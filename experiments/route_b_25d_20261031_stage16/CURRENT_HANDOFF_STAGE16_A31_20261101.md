# CURRENT_HANDOFF Stage16 A31: two upper-tree PAR separation 2026-11-01

**Stage A31 native VX map engineering PASS; tree-color aesthetic candidate PENDING user review; Formal Seal NO.**

## Mandatory read order
1. authority/FS_GROUND_PAR_SOURCE_FIRST_PRODUCTION_V1_20261101.md
2. authority/FS_PAR_SEMANTIC_ORIGINAL_OBJECT_GENERATION_V1_20261101.md
3. authority/FS_NATIVE_VX_DYNAMIC_PAR_OCCLUSION_PASSAGE_V1_20261101.md
4. experiments/route_b_25d_20261031_stage16/STAGE16_A31_TOP_TWO_TREE_PAR_PALETTE_SEPARATION_HANDOFF_20261101.md
5. experiments/route_b_25d_20261031_stage16/STAGE16_A30_TRUE_NATIVE_VX_GROUND_PAR_HANDOFF_20261101.md
6. Drive FS_SOURCE_ASSET_LOCATION_REGISTRY_V1_20261023 and A29 Scene Manifest.

## Baseline source
A27 Ground native PNG 544x416 SHA256 35c454c82d4f32906de39702a8463ca72316b14e157239604c18971bd67d00ce. Exact unchanged original A27/A29/A30. Twelve A30 independent PAR sprites, of which only two upper broadleaf canopies RGB changed. Three options (subtle, balanced, strong) created, **BALANCED** selected for A31 native.

## A31 exact edit
Changed only foliage RGB inside `drive_broadleaf_west` and `drive_broadleaf_east`; pixel-perfect source alpha preserved, non-leaf/trunk/root untouched, all positions/foot/collision preserved. Balanced: leaf red×.85 green×.96 blue×1.35+2, local contrast×1.19, 1–2px in-alpha edge×.75, underside×.93; NEAREST pixel art compositing, no anti-alias or artificial alpha halos. Recompiled actual `Par50.png` to match 12 separate objects. 19,287 RGB pixels changed only within those two tree alpha areas, zero alpha changes, zero changes outside tree alpha, all lower screen y>205 untouched. Ground source SHA unchanged.

## Actual VX execution
Native A31 isolated Game.exe clone `E:\FS_STAGE16_A31_TREE_CANOPY_VX_CANDIDATE_20261101`, not sealed production. Real RGSS Player 544x416, 24 screenshots across 12 cases, zero error modals. Actor full-hide east at(14,3) 0/627 pixels visible; west partial 404; east partial 417; front fully 627. Native E-layer 12 blocked/209 connected walkable unchanged. Native blocked attempt(2,4)->(2,4); right open road(8,6)->(9,6). The staged A31 first run had 0 captures due tester reading wrong log name and a second run had misaligned character positions due interpolation; both are recorded failures and fixed in **test-only** script (actor moveto again at visible phase). Final 24-frame set and target ROI QA PASS.

## Cold independent test (actually run)
Fresh project `E:\FS_STAGE16_A31_TREE_CANOPY_VX_COLD_20261101` copied and 3,395/3,395 per-file SHA256 equal. Native cold Game.exe launched, entered Map50, loaded 12 objects, 0 modal, real HWND 544x416 screenshot 31,990 distinct colors. This proves cold map render not 24/24 deterministic frame hash parity.

## Local evidence
E:\FS_ROUTE_B_STAGE16_A31_TREE_CANOPY_SEPARATION_20261101
- `A31_NATIVE_VX_TREE_BEFORE_AFTER_MOBILE_544W.png` (544x2730) REAL A30/A31 native Game.exe comparisons and enlarged upper-tree details.
- `A31_FOUR_WAY_TREE_ZOOM.png`, `A31_FOUR_WAY_FULL_SCENE.png`, subtle/balanced/strong individually reconstructed true Ground+PAR maps.
- `A31_PAR50_BALANCED_RGBA_544x416.png` full independent transparent PAR, plus balanced left/right source sprites.
- `A31_FINAL_NATIVE_VX_VISUAL_PASSAGE_QA.json`, `A31_PAR50_RECOMPOSE_QA.json`, `A31_VX_INDEPENDENT_COLD_REBUILD_QA.json`, 24 actual native case screenshot PNG and all source generator scripts.
- Private Drive G:\我的雲端硬碟\FS_ROUTE_B_STAGE16_20261031\STAGE16_A31_TREE_CANOPY_SEPARATION_20261101 (links recorded after actual readback). 
- Original A30 private evidence and Handoff unchanged.

## Next
User visual approval/feedback on A31 upper trees; if not sufficiently separated adjust canopy palette only (avoid editing Ground), keep independent sprite RGBA and recomposed PAR synced. Distinguish true color separation from fake sharpened whole-scene preview. Continue A32 only after review; full village Ground3, art and original sealed FS startup remain pending. Current A31 is test-only, not production/rights cleared. Formal Seal NO.


## Verified private A31 Drive files (readback 2026-11-01)
- Actual native Game.exe before/after mobile comparison, 544×2730 (upper west/east crop): https://drive.google.com/file/d/1SzJCDGBIih701eKb5n4HH-ucLCDkkX-0/view
- 4-way upper-tree comparison (original/subtle/balanced/strong): https://drive.google.com/file/d/1fw_N4WaIaZbuGlELvxFz3-jBV9qOaJ6s/view
- BALANCED complete transparent PAR50 544×416: https://drive.google.com/file/d/17nkoSRczPVJijlT8FbfiYkdhpS2499GL/view
- BALANCED independent upper WEST tree RGBA: https://drive.google.com/file/d/1OkLyJdJCIQ320uAi1QcsJwXwWl8D2q_V/view
- BALANCED independent upper EAST tree RGBA: https://drive.google.com/file/d/1XZ9nZ9upiFSFt8NTjOKjrfZRrXCAjABk/view
- Actual cold-native VX 544×416 screenshot: https://drive.google.com/file/d/13PQ5Jkbamcq34r2z661W5nAC4QMGFmM3/view
- Full private A31 ZIP, 74 members, 10,312,776 bytes. Local ZIP CRC+all SHA256+independent extraction PASS; Google Drive size readback verified, but no remote byte-for-byte ZIP hash claim: https://drive.google.com/file/d/1d-FL2zQZkFuW6w2I9Owq6KBD5WuaDIql/view
- Native A31 Handoff: https://drive.google.com/file/d/18cdnt0-K081Tk0fwSO_bedgsnbe9hIca/view
- Latest CURRENT_HANDOFF A31: https://drive.google.com/file/d/15R8uzpknr-CIELcz2f8dJOfXCJMrJg0M/view
- Folder: https://drive.google.com/drive/folders/1gMUxU_2ZV3b655LJerpyg1L-zjW9N8O1
