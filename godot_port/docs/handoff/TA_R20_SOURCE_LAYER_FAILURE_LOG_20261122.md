# T-A R20 Failure and Discovery Log | 2026-11-22
1. **SOURCE MISMATCH:** A62 source F0 from original 2026-11-02 archive is 48×48 source SHA 0ca4ce9f..., while the 64×64 reference used by R19 does not contain any equal 48×48 window. No legitimate crop/pad mapping can be claimed. Source from original A62 generation was a trial with visual ART review pending; don't promote source existence into formal user approval.
2. **CLOTHING LAYER BLOCKER:** verified original eight-direction walk ORA stack has torso/arms/head only, no outfit/boots of ACTOR01. Universal LPC generator clothing folders are 4dir family, same frame/pose and 45° compatibility unverified.
3. **NO MORE R19 BELLY:** R19 used A62 head with invented new polygon body; rejected. R20 uses original entire F0 48x48, preserves all original torso/abdomen/shoes RGB.
4. **ORA PARITY:** 7 disjoint visible-pixel masks, exact recompose 575/575 alpha pixels; all 48×48 RGBA equal, no new pixel, ORA CRC PASS. Not complete original paper-doll equipment source, cannot pivot arms to new attacks without hidden material.
5. **FIRST VALIDATOR FALSE FAIL:** source original PNG re-encoded by Pillow, breaking raw PNG SHA although all RGBA identical. Fixed by copying original source file bytes instead of re-encoding. Documented and re-tested.
6. **NEGATIVE TESTS:** altered source RGB rejected; false claim `complete_modular_lpc_source_verified=True` rejected; official source layer proof remains blocked.
7. No paid PixelLab, Godot native, full FSBattle or original game changes; no art approved. All binaries/private pixels Drive only.
