# Forest Symphony A35B | Terrain foreground semantics rebuild / native VX proof
2026-11-02. Real remote A35B isolated engineering correction. **Old 217 cliff PAR masks REJECTED.**

Read first `authority/FS_TERRAIN_PAR_WALKABLE_FOOT_OCCLUSION_SEMANTIC_GATE_V1_20261102.md`, original Ground/PAR authority, this Handoff and A35B Failure Register; compare A35 A34 Handoffs. DO NOT resurrect 217 arbitrary masks.

## Actual source
Original A35 AI-direct map Ground **1280×928 / 40×29**, Ground SHA `478b3f40367cb449721a9216c28c3906557cbb292ffcc6702984ec0d90559f00` untouched. Original style approved by user as reference; do not revert to procedural patchwork or use PixelLab. A35B semantic scene source `E:\FS_STAGE16_A35B_TERRAIN_OCCLUSION_SEMANTICS_20261102`.
- `A35B_TERRAIN_OCCLUSION_SEMANTIC_CONTRACTS.json` defines explicit criteria, 746 legal candidates / 414 blockers from existing A35 provisional collision, and flag 291 questionable intersecting cliff-color actor bbox tiles.
- `A35B_GROUND_SOURCE_IDENTICAL_1280x928.png` fully identical SHA to A35. `A35B_PAR50_SEMANTIC_GATE_EMPTY_RGBA_1280x928.png`: completely transparent, SHA `3ddfa14f3ff633edcbe37d2a8d022608d374dbb5ef1698cfa408c54ca4e25c16`. There are **ZERO approved terrain PAR occlusion sprites at present**. This is the *correct fail-closed baseline* before authenticated behind-foot and actor occlusion zones, not a claim all terrain needs no PAR.
- Cave upper lip *potential* occluder must wait for a real walkable entrance tile and tested actual map transition; no active overhang currently.
- `A35B_CLIFF_NOT_AUTOMATIC_PAR_GROUND_FOOT_AUDIT.png` red QA plots 291 possible collision/overlap tile errors, not automatically foreground candidates.
- Original A35 separate 217 mask PNG archive preserved. A35B test clone rejects their use but does not overwrite sealed or previous baseline files.

## Native actual comparison
Independent VX clone `E:\FS_STAGE16_A35B_SEMANTIC_OCCLUSION_VX_NATIVE_20261102`. Map050 40×29 E tile table unchanged, 11 positions and 22 actual Game.exe RGSS screenshots, 0 modal, source 217 masks not loaded, 0 active terrain overlays. Native actor around cliff: A35 visible 550/627 on west valley, corrected A35B 627/627, **77 recovered wrongly masked pixel positions**; additional recovered20 lower center,13 lower east,8 center plateau,4 upper east,3 grass walk. Every native A35/A35B case2..10 hidden background equal **0 RGB difference**. `A35B_REAL_VX_WRONG_TERRAIN_PAR_VS_CORRECT_ACTOR_5_CASES.png` is real Game.exe screenshot comparison of 5 worst cases, no synthetic actor art.
- Real road move (21,14)->(22,14), cliff blocked (20,14)->(20,14) retained. Source 506 other RGSS script payloads unmodified, only test-only script483 references zero object manifest; old source A35 and A34 untouched.
- Godot 4.7.2 RX6700XT actual native full map 6×1280×928 GPU frames, 6 544×416 screen crops, zero active cliff PAR, 0 RGB difference vs unchanged original Ground. Separate independent cold SHA and startup to be read from A35B cold QA.
- `A35B_ACTUAL_NATIVE_ACTOR_OCCLUSION_REGRESSION_QA.json` is numerical authoritative before/after case measurement.

## Next
A35C implement **tile semantic height graph** and cave/bridge/overhang region definitions. Only then emit non-empty terrain PAR if front/behind actor proof succeeds at >=1 explicitly walkable behind tile. Do not generate visual cliff boundary masks by RGB. Preserve Ground. Recheck incorrect collision tiles (291 source cliff pixels overlapping 32px player projected footprint), 746 provisional walkable / 695 contiguous. Only after this deliver full-size trees/structures as independently sourced PAR.
Formal Seal NO, art direction preserved and actual actor-occlusion regression fixes proven, actual future cave/hide test not completed.


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
