# CURRENT_HANDOFF_R3 | Forest Symphony Parallax Research 2026-10-27
STATUS: isolated actual native VX R3 TECH PASS / semantic ART HOLD / official 505-script FS not tested.
Working directory: E:\GameAssetToolLab_20261023\FS_MasterSplit_Research_20261027
Method: full Master scene Ground unchanged except technical black backdrop where source transparent; PAR upper pixels extracted from same source image; STATIC above-player z=900 vs DEPTH per object foot Y, with actor z from foot.
Real Game.exe tests: STATIC/DEPTH 7 screenshots each = 14 screenshots. Every probe outside actor ROI pixel-matches Ground exactly (0px error). TREE_FRONT tile(4,5) foot(144,192) dynamic changes 140 actor pixels; TREE_BEHIND, house/right-tree probes and CLEAR stable.
Failures repaired: incorrect duplicate FSOBJ prefix causing native loading hang, transparent master exterior causing 1916 background mismatch, Windows NumPy absent causing postcapture QA crash. Final rerun passed.
RUN_R3_NATIVE_VX.cmd rebuilds/retests with isolated test-only B1 template. GitHub authority R3 document and private Drive ZIP.
Not validated: full SAM2 occlusion completeness, multiple NPC sorting, official HK-UOM / ISS ParaPassa scripts, water loop/light/shadow, large maps, Gate F. Do not change sealed FS or V6 map work.
R4: NPC + reachable walkability grid and 4-way probes, semantic mask correction, real FS 505 scripts isolated integration.