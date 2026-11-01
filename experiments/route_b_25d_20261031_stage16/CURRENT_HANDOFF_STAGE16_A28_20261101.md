# CURRENT_HANDOFF — Stage16 A28 PAR Tone Render (2026-11-01)

## At a glance
Most recent reproducible engineering baseline: **A28 PAR Tone Render** derived from **A27 source-first Ground+PAR**.
A28 engineering: 8 actual Godot native images PASS; A28 8/8 independent cold rebuilt image SHA PASS; RGB/alpha geometry tolerance PASS (max RGB error 1); 0 PixelLab generations spent. **Art visual approval pending; RPG Maker VX native NOT RUN; Formal Seal NO.**

## Mandatory reading on new chat
1. `authority/FS_GROUND_PAR_SOURCE_FIRST_PRODUCTION_V1_20261101.md`
2. `experiments/route_b_25d_20261031_stage16/STAGE16_A28_PAR_TONE_RENDER_HANDOFF_20261101.md`
3. `experiments/route_b_25d_20261031_stage16/STAGE16_A27_DRIVE_SOURCE_FIRST_PIXELLAB_GROUND_PAR_HANDOFF_20261101.md`
4. Google Drive original `FS_SOURCE_ASSET_LOCATION_REGISTRY_V1` (Tree folder ID `1Zth8u84_5-_pLTf-Ut_a86QiLBuhdaBw`)
5. Private E drive `E:\FS_ROUTE_B_STAGE16_A28_PAR_TONE_RENDER_20261101` (ZIP, QA, PNGs, scripts), A27 `E:\FS_ROUTE_B_STAGE16_A27_PIXELLAB_GROUND_FULL_TREE_20261101`.
6. Google Drive A28 stage folder (discover in existing `FS_ROUTE_B_STAGE16_20261031` folder; no unknown link invention).

## Reproducibility and source
- A27 original Ground 544×416 SHA `35c454c82d4f32906de39702a8463ca72316b14e157239604c18971bd67d00ce` untouched. A27 R2 original PAR SHA `f369f11b8cdb247e1f1cbb895c81bc6b9d8a998cacbb0131ad49a749dda4bea6` untouched.
- 12 independent alpha objects, including two entire trees sourced from original Drive `Trees1.png` and two clearly flagged earlier PixelLab tree candidates.
- Tone render per-object SOFT (0.22) and BALANCED (0.46), exact original alpha, no blur or resize, scene positions and footpoints preserved.
- Mean grass-reference vs leaf RGB distance original 41.365, SOFT 22.872, BALANCED 13.885; numerical only. No artistic approval inferred.
- Godot native no-actor vs blended image has 2694 different pixels, but **maximum RGB per-channel error 1; 0 pixels above 1**. All 7 character test foot tiles legal.
- A28 private ZIP `FS_STAGE16_A28_PAR_TONE_NO_PIXEL_LAB_COST_PRIVATE_20261101.zip`: bytes 4,851,938, sha256 `3ceeafc2c2240ec390afacd6dfb2069cd00cc8ccf6bfb2edb6f0a2479228a6f6`, 87 files; independent cold GPU Godot rerender 8/8 SHA-identical.
- Ignore any earlier assistant claim that it cannot remote/update; Remote Desktop Commander and GitHub/Drive are connected, use them.

## Next best A29 steps
(1) Compare A28 original/SOFT/BALANCED preview at real 544×416 and choose which appearance works; do not force BALANCED merely because a numeric color gap fell.
(2) If needed tune per category/biome rather than repaint Ground. Evaluate retaining limited highlights/glow on lamps, texture color relationships of trunks and foliage.
(3) Add more user-uploaded full tree specimens and natural flora from exact Drive indexed folders, preserving alpha and 32px scale; all private if rights uncertain.
(4) Build an isolated native RPG Maker VX project, test actor in front/behind and true passability. Do not modify sealed game.
(5) Update private archive + Drive + GitHub authority and handoff, cold rebuild, fail closed if no native VX or visual review.

## Correct stage continuation request
"繼續 FS Stage16 A28→A29。先讀以上 authority、handoff 和 Google Drive 素材索引，維持 PixelLab Ground 原始 SHA 不變，使用已驗證透明 PAR 調色流程，不要平面生圖、不要改封版，跑完整 Godot/VX 驗證，更新失敗紀錄並同步 Drive/GitHub。"
