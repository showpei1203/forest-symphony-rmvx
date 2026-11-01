# A35B Terrain Occlusion | Real 217 bogus cliff-mask regression
Date: 2026-11-02, run on user's DESKTOP-90VT437.

## Failure root cause
A35 detected brown cliff-face RGB on the Ground source, then automatically replicated **217 64×64 blocks** as PAR. The previous A35 report said Ground+PAR composited to 0 visual RGB difference and that native GPU/VX rendered; **this is NOT a proof the PAR belongs in front of actor**. The copied foreground did actively mask the player on LEGAL movement tile views.

## Actual native Game.exe before/after proof
A35 prior in independent original source 11 tested scenes; A35B **same original exact Ground** but 0 active cliff PAR, same underlying E collision, native same 11 cases/22 screenshots, 0 RGSS modal. Compare case2..10 after title fade: every hidden background frame 100% unchanged.
- Case03 west valley: actor visible pixel coordinates A35 **550**, A35B **627**, **77 recovered** wrongly masked actor coordinates.
- Case07 lower center: **607 → 627**, recovered 20.
- Case08 lower east: **614 → 627**, recovered 13.
- Case04 center terrace: **619 → 627**, recovered 8.
- Case02 upper east: **623 → 627**, recovered 4.
- Case10 grassy walk: **624 → 627**, recovered 3.
- Cases05/06/09: unchanged 627. The real native screenshot side-by-side contains cases 3/7/8/4/2 and original source actual Pixel images, no simulated drawing or compositing.
- A35B all nine after-fade visible actor footprint 627/627, clip 0. Some scenes should hide actor when truly walking under roof/tree/bridge; these need authored **explicit behind walkable foot zones**, not recolor-based face mask.
- Collision 414 blocked/746 provisional passable unchanged, main reachable 695: cliff/water/stairs gameplay still pending, do not conflate 0 bogus PAR with fully solved map. Classifier intersection reported 291 source-cliff-on-legal-actor-bbox tiles as semantic/collision review candidates, not accepted PAR.

## Correction
A35B Ground SHA same as A35 `478b3f40367cb449721a9216c28c3906557cbb292ffcc6702984ec0d90559f00`, no re-rendered grass. A35B PAR50 full transparent RGBA SHA `3ddfa14f3ff633edcbe37d2a8d022608d374dbb5ef1698cfa408c54ca4e25c16`; prior 217 mask source preserved only in archive as regression evidence; copy isolated VX clone has no active old masks. Native sprite Script483 adapted to zero objects; other 506 script snippets byte-identical; source A35 untouched.
- Prior A35 original cave mouth visually present but cave transition/overhang never validated, so `cave_mouth_upper_lip_candidate` gate NOT ACTIVE. Define foot tiles/elevation/map entrance first, only then source cutout as PAR.
- **ALWAYS** require front-actor and behind-actor real VX screenshot scenarios plus strict actor mask diff; Ground+PAR 0 diff isn't enough.
- No PixelLab needed for this correction.
- Production BattleRegression bypass is still unresolved; **Formal Seal NO**.


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
