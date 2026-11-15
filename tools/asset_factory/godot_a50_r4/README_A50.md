# Forest Symphony A50 | Real PixelLab Full-Body Attack (2026-11-16)

New engine is exclusively Godot 4.7.2. No RPG Maker VX new development.

R3: real A49 PixelLab R2 body plus exact model-generated silver sword split into a true independent Weapon layer F6-F10. Actual F6 upright blade leads into F7 slash, so real hit has moved from old F6 0.55s to F7 0.63s (marker 29,7). Floating A49 FX fragments removed; 1/3/1 tiny original-palette sparks track model blade F6/F7/F8.

R4: genuine NEW PixelLab Skeleton V3 model job 1c671687-681a-4667-a4e7-956b15fc7eae (3.0 generations), ten NEW 64x64 character Body frames, no model-baked sword. Six R1 face/neck joints retained; stronger R2 torso/hip/sword wrist joints retained. F0/F11 exact A62. All model Body RGBA bytes and pixels preserved, no sliced-body synthesis. Original genuine R2 model weapon remains a separate layer, with F9/F10 weapon-only 1px/2px rigid anchor shifts.

Both separate FULL Godot native test projects: godot_a50 (R3) and godot_a50_r4 (R4). Each has real 4.7.2 RX6700XT GPU native imports, 12/12 GPU screen pixels matched, hit F7 at .63s, early hit negative at .55s, 70ms Hitstop, real practice target damage HP 100->75->50, cancel/miss/double speed tests PASS. Tests are isolated demo, NOT formal FS ATB integration.

Face/identity movement residual R2 293 to R4 141 pixel sum after motion registration; chest motion 366->401; pelvis/legs 337->218. This is objective metric, not human art approval. ENGINE PASS, ART HOLD; R4 recommended engineering candidate.

Full original PixelLab R2 model PNG, true separated sword, approved A62 source and 18-joint input are included in R2_ORIGINAL_PIXEL_LAB_PROVENANCE. R4 paid model input, job lock, raw frames and original API response are in head_lock_R4. Real GPU previews in preview_final. See A50_FORMAL_HANDOFF_20261116.md, A50_FAILURE_LOG.md and A50_R3_R4_FINAL_NATIVE_QA.json.

Owner-only Google Drive source and private art. GitHub feature branch only source code and engineering QA, no private art. A42-A49, original E: RMVX and main/map/migration branches preserved. No saved C: scratch after Godot cold native tests.