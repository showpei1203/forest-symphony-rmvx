# FS T-A R25｜Source-bound A62/A52 character moving with existing R24 Bone2D | 2026-11-24

**AUTHORITY: Source PASS / Isolated Godot 4.7.2 GPU PASS / ART HOLD / Full FSBattle NOT_RUN.**

## User objective and actual change
Previous R24 moved the A52 original sword via eight Bone2D, but kept the entire A62 full-body character a STATIC source reference. Owner correctly demanded a real paper-doll body moving, large credible sword slash, no procedural palette-block belly. R25 does **actual bone-parented original SOURCE ART**, and extends R24 rather than rewriting approved IK, timing, original source sword, or Godot setup. R25 is NOT yet a source-native LPC costume system with original hidden sleeve fabric or artist-approved attack art.

## M1 delivered
- Actual approved source: A62 64x64 original F0 SHA256 `70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e`, A52 complete 256x192 twelve-frame original Body SHA256 `a10ea14eddd3173c48a87a31227a6a017ba8092713f6d56f95cc5d82a46fd12f`.
- Source builder checks original full-body SHA, A52 body SHA, all 576 F0 source RGBA pixels, and disjoint seven visible owners from R23; recomposition is pixel-exact. No manual torso recoloring or invented source RGB values. Identical original source costume colors.
- Nine actually **Bone2D-attached Sprite2D original-source visible regions**: far-arm sleeve→far guard bone; pants/boots/belt→pelvis; original torso/coat/belly and white hair/head→chest; near upper sleeve→upper-arm shoulder; near forearm→elbow; near visible hand→wrist. Actual independent A52 sword remains child of wrist Bone2D.
- All SIX source-core regions show the real 12 A52 original source atlas frames by attack timeline rather than static silhouette. Two original donor source near-arm frames F04 and F05 are split into source-exact upper/forearm/hand pieces. Original F00/F11 restores full approved A62 pixels at zero GPU difference. Separate new R25 subclass inherits the R24 8-bone 12-key AnimationPlayer, 2-bone IK, two large original source sword slashes. This is source-bone attaching, **NOT weighted mesh deformation** or complete original LPC native paper doll.

## M2 native Godot 4.7.2 executed
- Official `4.7.2.stable.official.ed1daf0bf` isolated Linux Xvfb Mesa OpenGL, 195 named native assertions PASS, overhead and diagonal profiles each 12 frames captured, plus 8 sword-hidden body-only screenshots = 32 real native PNG.
- Confirmed exact F0 GPU source pixel delta 0; actually toggle off one original moving torso coat layer at F7 changes 85 GPU pixels, restore 0 delta. Source BODY-ONLY between F3 and F7 changed 643 pixels overhead / 610 diagonal (original source pixels and bone poses, sword HIDDEN), so body is actually changing rather than sword-only.
- Original R24 F7 contact 0.630 seconds, 0.070s requested Hitstop and real AnimationPlayer playback retained. Complete self-contained private R25 source archive compiled/re-run after editor class scan (Godot requires initial `--editor --quit` in fresh isolated project). Both confirmed successful native runs exist; not user's Windows GPU nor full migrated game.

## M3 failure repair / fail-closed
1. Initial native manual pose capture FAILED due to R25 `_process` hiding source costume while AnimationPlayer idle. Corrected explicit `manual_pose` state and reran 195 PASS.
2. First source build failed due to missing one R23 near arm source atlas in the packaging root; corrected by including all seven real original owner atlases.
3. One isolated software-render run measured Hitstop wall 54ms and FAILED previous min 60ms; unchanged next run measured 70ms and PASS. **Timing not deterministic across Mesa/Xvfb**: preserve both logs, do NOT falsely guarantee 70ms wall time on Windows.
4. Clean private project first native QA before Godot editor scan failed unknown R25 `class_name`; documented editor bootstrap; rerun on independent clean release project after import 195 PASS. Godot preview QA is not a standalone release build.
5. Source artist issue persists: A52 F04 donor contains just 1 original visible hand pixel; F05 donor 8. Shared pixels cannot invent hidden original costume. Hand-wrist connection / sleeve holes may remain ugly. No fake painting was done.

## M4 second source+motion sample
Two full R24 original real sword motion profiles with different genuine-source shoulder donor frames (overhead F04 vs diagonal F05) both rendered as original body-bound source parts, 12/12 native screenshots, real 0.630 event and Hitstop. This validates engineering repeatability, NOT that two aesthetically good slash sprite families exist.

## Owner-private Drive evidence
[PRIVATE R25 folder](https://drive.google.com/drive/folders/1CQSo09VKNLHB5_r5n0P_wqfQ-omWmeBs) contains 14 actual cloud readback files all shared=false, [full 80-member self-contained R25 archive](https://drive.google.com/file/d/1IW6VrXnxAdvi49E0O4KlvbTOc8dGgbfj/view), 199,994 bytes, local SHA256 `210c13f66901475f74b6de7cac3a0ae9584d597f0f623189665561e850591d76`, ZIP CRC PASS. No engine binary bundled.
- [Overhead real Godot original-body animation](https://drive.google.com/file/d/1YjOopAspYdIe8ntaaoj4P2rM8GdMFNyk/view)
- [Diagonal real Godot original-body animation](https://drive.google.com/file/d/1M1yJAQ9JyWVpSwwjnj-HIu82JqmZx7C3/view)
- [True native 1× contact](https://drive.google.com/file/d/1Ps1wAGhs2WBEx4MBN3k5DqK5jGfHPb0x/view)
- [True native QA JSON](https://drive.google.com/file/d/1yje0S26029ZE0DzA3iCMtC2zsIFC77zr/view).
Original/private sprite PNG and screenshots are Drive-only; GitHub source-only tools, contract, manifest, Failure Log, Handoff, CI metadata guard.

## Hard HOLD / next macro unit
Source-owned visible masks **lack original source-native LPC hidden cloth, shoulder/underarm backside and glove-hilt occlusion**, so can't claim physically complete modular source paper doll, full skinned character, artist approval, natural hand-to-sword connection, or entire Forest Symphony Battle/ATB/HP integration. Owner ART HOLD. Existing R25 code can now attach newly painted original, source-matched near/far sleeves to bones without any more skeleton rewrites. Next real work: source-compatible 1× painted underpaint arm/hand/shoulder matched to original A62; art gate on F3 high guard, F7 contact, F9 recovery, then extend proper new 12 natural full-body art and integrate into formal FS Battle. No unapproved paid PixelLab work, no Codex/Desktop Remote or owner Windows machine touched. Main/T-B/T-C/A52 originals unchanged.
