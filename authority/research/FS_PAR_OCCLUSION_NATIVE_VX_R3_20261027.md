# Forest Symphony | Full Master Ground + Source PAR | R3 Native VX 2026-10-27
**Status: TECH PASS (isolated original Game.exe), ART HOLD, formal 505-script FS NOT TESTED.**

## Objective
Preserve one full beautiful Master scene as Ground, and extract only pixels that must obscure the actors into aligned transparent PAR. No mandatory terrain inpainting and no random second generation for PAR. 32x32 grid guides selection, not forced opaque rectangles.

## Actual source and runtime
- Source SCENE21 544x416, original SHA256 4414db2f8d0be840a336679b44d74e5a549c0ad693d1e165250cc0d2f660e730.
- Original master was never overwritten. Its transparent outer pixels exposed background tilemap in VX; output-level black matte MASTER_OPAQUE_BLACK_MATTE.png preserves intended visible image and makes comparisons deterministic.
- SAM2 research R0/R1 masks: house, left tree, right tree. These are prototype semantic masks, NOT full PAR.
- Test-only B1 99-script Ruby/VX template cloned into independent R3_NATIVE_VX/STATIC and R3_NATIVE_VX/DEPTH projects, each with own Game.exe and Scripts.rvdata. Official Forest Symphony 505 Scripts / K4 / N5 / other current map tracks untouched.
- Sprite in STATIC uses z=900 (above actor). In DEPTH uses per-object contact foot_y. Player uses foot_y as its z. Ground full master uses z=1.
- Native program captures 7 positions each mode, total 14 actual Game.exe screen shots 544x416, pixel analysis performed in WSL with NumPy.

## Results verified
- Each native Game.exe logs R3_NATIVE_BASIC_PASS: map movement, blocked tile, source objects count, map dimension smoke.
- Seven positions: TREE_BEHIND (4,3), TREE_FRONT (4,5), HOUSE_BEHIND (10,4), HOUSE_FRONT (10,6), RIGHT_BEHIND (14,4), RIGHT_FRONT (14,7), CLEAR (8,9).
- ALL 7: each mode pixels outside player ROI equal rendered black-matte original scene, 0 mismatch.
- ALL 7: STATIC vs DEPTH outside actor ROI 0 mismatch. House, right-tree, clear probes all equal.
- TREE_FRONT at tile(4,5), foot(144,192): 140 pixels differ, ALL inside actual native player ROI; dynamic z properly exposes player against static z.
- TREE_BEHIND, HOUSE_BEHIND, RIGHT_BEHIND: STATIC and DEPTH captures identical.
- Result JSON: R3_NATIVE_SCREENSHOTS/R3_NATIVE_COMPARISON.json, status ISOLATED_NATIVE_VX_TECH_PASS.

## Failed attempts and permanent lessons
1. R3_ERR_001 first attempt duplicate FSOBJ_ file prefix: Game.exe process started but scene load hung. Fix exact naming in isolated generated build, then actual boot/capture passed. Game.exe existence alone is never a valid boot gate.
2. R3_ERR_002 original SCENE21 transparent exterior leaked tilemap, 1916 px nonactor mismatch, 800 px static/depth CLEAR screenshot variance. Output-level black matte (no original source image mutation) fixed to zero.
3. R3_ERR_003 Windows Python missing NumPy, after 14 successful native captures the QA script crashed. Fixed by splitting native Windows capture from WSL NumPy visual pixel analyzer. Re-ran full native twice. No missing import in repeatable launcher.

## Current limitations: do NOT claim formal pass
- SAM2 masks incomplete and potentially semantically wrong. Right tree still contains some unintended foliage.
- Native probe selection uses isolated teleport testing, not proof of every tile being walkable via actual ISS-ParaPassa.
- Only player z was changed, not all NPC and event sprites. Per-NPC depth, multi-actor ordering and overlapping multiple PAR entities untested.
- Test-only script is NOT HK Ultimate Overlay 505-script official runtime. Need isolated adapter integration with official scripts before formal acceptance.
- No water animation, light/shadow, map scrolling, large ground3 scale tested this round.
- Private source only and no reuse/public redistribution without verifying rights.
- User visual Gate F pending.

## Local deliverables
- build_native_full_master_r3.py
- verify_native_full_master_r3.py
- analyze_native_r3_screenshots.py
- make_native_r3_contact.py
- RUN_R3_NATIVE_VX.cmd
- R3_NATIVE_VX/STATIC, R3_NATIVE_VX/DEPTH, R3_NATIVE_VX/R3_BUILD_REPORT.json
- R3_NATIVE_SCREENSHOTS/STATIC_*.png DEPTH_*.png, COMPARE_* and DIFF_*, R3_NATIVE_COMPARISON.json
- R3_NATIVE_SCREENSHOTS/FS_R3_NATIVE_VX_STATIC_VS_DEPTH_CONTACT.png
- CURRENT_HANDOFF_R3.md
- Official authority earlier Ground Exclusive Ownership not changed by this candidate experiment. This branch remains isolated research until authorized.

## R4 next technical gate
Add NPC z and all four approach directions; scan reachable tile/passability; fix semantic false positives, especially foliage against tree; then integrate into isolated copy of actual full FS 505 scripts and check HK-UOM viewport stacking + switch 201–205. Hold visual Gate F until native replay demonstrates correct output.