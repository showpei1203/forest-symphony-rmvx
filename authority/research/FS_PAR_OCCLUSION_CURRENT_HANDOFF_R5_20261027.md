# CURRENT HANDOFF R5 | FS full master + transparent occlusion PAR | 2026-10-27
STATUS: ISOLATED FS (original 504/505 pages + 1 disabled regression page + 1 TEST adapter) HK/ISS native tech PASS; 505 unmodified runtime boot FAIL; visual+semantic art HOLD.
Formal baseline root E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE
Formal 505 Scripts sha256 5A728530764E61D22D8C6927367D983C14E36EE37E777508D154A04A2EE7ACAA unchanged.
R5 working path E:\GameAssetToolLab_20261023\FS_MasterSplit_Research_20261027
- R5 formal scripts original 145 HK,146 Animated,342 ISS passed byte-identical; regression page480 pre-Main NameError (p45b_prepare_resources then p45b_restore_battle_skill_slot). Isolate page480 only for map test, no edits to master K4 or other map thread.
- R5 actual Game.exe HK_STATIC & DYNAMIC_ADAPTER each 5 native screenshots, Game_Event NPC. Map001 third layer set 769 walk/768 blocked in isolated clone. Native actual move/blocked PASS for both, HK Par viewport z8; actor viewport z0. 10 screenshots saved.
- Actual FS 51 Map files: 39 have ParaPassa labels,17,196 third-layer cells. Map003 40x29 includes1,155 ParaPassa cells. Authoritative map files untouched.
- R5 native visual FAIL/HOLD: two independently run full FS modes include dark tones/UI and animated effects, 73,685–80,876 nonactor pixel differences (not directly PAR errors); cannot declare Pixel Visual Gate. SCENE21 only three provisional occlusion masks, right_tree semantic suspect.
- R6 single-session A/B normalized overlay/visual gating, then more complete SAM2 masks and native 4-dir movement, water loop and large map.
- Reproduce RUN_R5_REAL505_TEST.cmd; see RESEARCH_REPORT_R5.md and R5_FORMAL_ADAPTER_ISOLATED/R5_FINAL_GATE.json.
- Repeated failures documented: formal harness alias failure; bridge uncovered second alias failure; new R5 adapter Ruby line39 SyntaxError corrected; visual effects not isolated. No formal sealed modifications.