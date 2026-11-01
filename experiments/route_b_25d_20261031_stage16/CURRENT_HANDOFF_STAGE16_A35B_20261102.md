> **SUPERSEDED BY A35C R2 (2026-11-02):** The A35B 0 terrain-PAR baseline was only temporary to remove 217 incorrect cliff-outline masks. User requires 1-2 tile cliff-top upper-rim actor occlusion depending on height. [A35C R2 CURRENT_HANDOFF](CURRENT_HANDOFF_STAGE16_A35C_20261102.md) provides four curated front edges / six depth sprites with real Game.exe actor 5 behind positives vs 4 front negatives, Godot 19 GPU frames and cold 3635 SHA PASS. Original A35 Ground unchanged. A35B 0-PAR blanket rule must NOT be carried forward. Formal Seal NO.

# FS CURRENT_HANDOFF Stage16 A35B, 2026-11-02
Latest branch = **A35B semantic redefinition of terrain PAR, not visual cliff outline**.

**STOP RULE:** A35 old 217 cliff-face color mask PAR not approved. A35B preserved A35 direct-image generated Ground1280x928 SHA478b3f40367cb449721a9216c28c3906557cbb292ffcc6702984ec0d90559f00. New deliberately empty alpha terrain PAR50 SHA3ddfa14f3ff633edcbe37d2a8d022608d374dbb5ef1698cfa408c54ca4e25c16 pending any physically behind actor-foot entry. Active real terrain PAR 0 until actual front/behind tile pair.

User explained: **PAR exists specifically to hide an actor walking into the appropriate tile**, not trace cliff contour. Ground includes all cliff pixels; only independently sourced semantic overhang/bridge/roof/cave front pixels in front of an actually walkable BEHIND foot tile get PAR. Must specify tile, elevation, foot depth and actual VX FRONT/BACK actor screenshot before activation.

True native VX measured: previous cliff masks covered legal actors (west valley 550 vs corrected627 actor pixels; 77 falsely hidden). 9 native case2..10 hidden background screenshots source identical; A35B 11 positions/22 real 544x416 cases no modal, native move block and road retained. Real Godot full1280 6 +6 native crop actual frames 0 RGB diff. Source A35 remains untouched. 291 provisional walkable actor bbox overlaps cliff-color pixels (flag for collision QA not foreground). A35 pending 746 walkable/414 blockers, largest component695. Cave mouth NOT active until map entry and actual behind/walkable tile.

Read order:
1. authority/FS_TERRAIN_PAR_WALKABLE_FOOT_OCCLUSION_SEMANTIC_GATE_V1_20261102.md
2. experiments/route_b_25d_20261031_stage16/STAGE16_A35B_TRUE_TERRAIN_PAR_WALKABLE_FOOT_VX_QA_HANDOFF_20261102.md
3. experiments/route_b_25d_20261031_stage16/STAGE16_A35B_TERRAIN_OCCLUSION_WRONG_MASK_FAILURE_REGISTER_20261102.md
4. A35 source direct art current handoff / original A34 40x29 size authority.

Remote DESKTOP-90VT437 online, local source E:\FS_STAGE16_A35B_TERRAIN_OCCLUSION_SEMANTICS_20261102, isolated VX E:\FS_STAGE16_A35B_SEMANTIC_OCCLUSION_VX_NATIVE_20261102, Godot source in above\GODOT_A35B_TERRAIN_OCCLUSION_GATED, independent cold VX clone path recorded in cold QA. Formal Seal NO, user A35B screenshots awaiting visual signoff. Continue A35C height graph/real traversable behind-foot occlusion + native test, NOT 217 color contour masks.


## Verified Drive A35B actual diagnostic (2026-11-02)
URLs below were retrieved from actual Google Drive directory listing after local Windows G Drive sync; no invented links.
- **Most important: REAL VX Game.exe actor actually hidden WRONG vs CORRECT, 5-case enlarged comparison**: https://drive.google.com/file/d/1LR5kV0G8VXAg5dnNXrcytBiGju2Lcaw6/view
- **A35B terrain Ground unchanged full 1280x928**: https://drive.google.com/file/d/1LMUeZ_8dBN5Ueo9cspshgkMaRkFeMksd/view
- **A35B PAR50 now fully transparent, deliberately 0 unverified terrain-occluder pixels**: https://drive.google.com/file/d/1R7bRPQjWwQL51TTiLnWMOLFtTb0awF1i/view
- 1280×928 genuine Ground+PAR composited output unchanged: https://drive.google.com/file/d/1hzIF6N6TGFv-udoSFZ_uebZPLv9565Qb/view
- **291 32-tile actor source-cliff-color collision-suspect audit image**, NOT auto-PAR candidates: https://drive.google.com/file/d/1wlQ-K3YpmFHglm7wGlK0iMadRvibiYNt/view
- Explicit terrain PAR semantic rules + 746 legal foot tile QA including cave overhang candidate NOT ACTIVE: https://drive.google.com/file/d/1Ie0bABdoIoxORaFPenQXeApGkCZb8aiL/view
- Numeric source A35 vs A35B original RGSS real actor pixels: https://drive.google.com/file/d/1sdL_Qce1KA8eEg3I5MVB7PRv_rHU6tyk/view
- A35B native VX 11 cases/22 frames QA: https://drive.google.com/file/d/1BKwUdKBxg-SBWcY5dURpGAJY9gddPlvR/view
- Godot native GPU 6 full +6 crops 0 RGB error: https://drive.google.com/file/d/1eLkfwLU6ZVTyrAI_lVV07ReBcmuXyn8g/view
- Independent cold VX 3628/3628 SHA (normalized stage label): https://drive.google.com/file/d/1HpNpfkKMkF14NLG1Qkma8YIuwcZ1w0_C/view
- **Complete 70-item PRIVATE A35B source and actual VX/Godot evidence ZIP 40,641,354 bytes**, local ZIP CRC/all SHA+independent extract PASS: https://drive.google.com/file/d/1f806h8RS1Fw5azGqStawDknQ4BaRdKh6/view
- CRC/SHA evidence: https://drive.google.com/file/d/1gJjoOgtFgoJhRpCuflLh4uabbCVomZ3q/view
- New permanent semantic PAR authority: https://drive.google.com/file/d/1dfPI3kBxT10vsKF36hsuBPBHz2H7HR-2/view
- A35B failure log: https://drive.google.com/file/d/1tmQf0fcVYoiCBnnVy3ZIqM4NvT9Q9IJY/view
- Detailed A35B handoff: https://drive.google.com/file/d/1tEXNdlxYy6890WjRvBCZNAdTPDC0JHhz/view
- CURRENT_HANDOFF latest: https://drive.google.com/file/d/1aWRJsceHrI3Ium15wGEOMyn_Net49Ps9/view
- Verified private Drive A35B folder: https://drive.google.com/drive/folders/1EykVYwEtnxSsS6UaMEQWXpoXk5R7kAuc

**Status: Proven elimination of wrong face-mask actor occlusion; real behind-foot terrain PAR gate not yet supported until actual authored cave/overhang/height; no false art/gameplay seal.**
