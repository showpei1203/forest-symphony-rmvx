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
