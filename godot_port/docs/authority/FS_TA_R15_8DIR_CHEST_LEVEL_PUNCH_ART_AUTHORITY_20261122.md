# Forest Symphony T-A R15 — LPC eight-direction source, chest-level unarmed strike, source-locked joint trajectory
Date 2026-11-22. Current latest T-A candidate. Godot 4.7.2; preserve original A52/A62, main, T-B and T-C.

## Context and blocking visual correction
R14 used real eight-direction LPC diagonal ORA (9 frames × 8 source rows) with separate shoulder/elbow source-pixel joints, but actual enlarged Godot F7 shows fist too high, appearing attached to hair rather than a plausible shoulder. R14 12/12 eight-connected whole-body test misleadingly appeared to validate anatomical arm placement; connectivity alone cannot prove correct shoulder. Mark R14 F7 art visually REJECTED, preserve R14 as historical.
User's hard constraints still: real LPC original eight-direction diagonal source, approved A62 white hair/face/dark-green outfit, fully unarmed, no sword/shield/FX/stray symbol or stretched elastic limbs. No 4-dir splicing.

## What R15 actually builds and tests
Retains original 8px upper-arm rigid source-pixel segments + original LPC forearm, but retimes shoulder/elbow poses throughout 12 frames for drawn-back guard, torso load, F5→F7 forward punch and F8–F10 recoil. Source angle arrays in godot_port/tools/ta_r15_8dir_actor01_punch_kinematics.py. Original 8-direction row7 body/feet and A62 approved identity SHA-locked. Both arms separated at shoulder and elbow, no sprite scaling or synthetic rubber tubes.
New hard-fail projected shoulder→elbow→wrist geometry checks forward x displacement F5-F7, return F8-F9, F7 projected y29..35 vs previous y27.6 hairline. These are PROJECTED JOINT GEOMETRY constraints based on 8+6px original bone assumptions, NOT an actual mask proof of anatomically connected hand or human visual art acceptance.
Measured R15 front projected wrist (screen 64px):
F5 [39.554,35.820], F6 [48.407,33.100], F7 [52.325,31.142], F8 [48.915,33.370], F9 [42.080,36.652].
Prior R14 projected F7 [54.164,27.605]; R15 is about 3.54px lower, more credible chest-level contact.
The ORIGINAL 8-dir source bundle is diagonal WALK/RUN, NOT an attack. R15 is NEW reauthored ATTACK from genuine diagonal 8-dir source, not a downloaded 8dir attack sprite.

## Verified actual production and QA
- 12×64px Body atlas 256×192 SHA256 dba04b8c0375635789799340e2e6b74df9a9b7410817cb4f52dbef2b549cd675. F0/F11 exactly pixel-equal, 11 distinct poses, 12/12 whole-body 8-connected, no debris removal. Separate Weapon and FX 256×192 full alpha ZERO. Original approved A62 SHA256 70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e.
- ACTUAL official Windows Godot 4.7.2 OpenGL owner-private original Body input 64px, 73/73 native PNG frames at 60Hz, 12/12 pose-slot source-vs-GPU identical RGBA bytes, visual F7 event local t0.630 sec exactly once, zero weapon/FX. Isolated sprite presenter ONLY; no live original FSBattle/ATB/damage.
- Owner authorized E:\LPC_Original_20261121\FS_R15_ACTOR01_EIGHTDIR_TWO_JOINT_UNARMED_45. Real GIF R15_GODOT472_ACTUAL_73_FRAMES_60HZ.gif, native 1x/4x contact sheets, R14-source vs R15-native comparison. QA ZIP FS_TA_R15_8DIR_TWO_JOINT_UNARMED_NATIVE_73FRAMES_QA_20261122.zip 250953 bytes, 91 members CRC PASS, SHA256 b513bc18db9e05aab786b44fbf319e0611b6c011d455133ef486ef150706dfdc. Originals are private E, NOT claimed uploaded as Drive binary.
- Reproducible source godot_port/tools/ta_r15_8dir_actor01_punch_kinematics.py; Godot actual capture godot_port/tests/capture_ta_r15_unarmed_native.gd; private proof repacker godot_port/tools/ta_r15_8dir_native_qa_pack.py; locked JSON godot_port/docs/handoff/TA_R15_8DIR_UNARMED_SOURCE_MANIFEST_20261122.json and TA_R15_8DIR_UNARMED_NATIVE_QA_20261122.json.
- R15 QA pack first run failed due a leftover R13-vs-R15 screenshot include path. Corrected to actual R14-vs-R15 generated file; rerun CRC PASS, 91 ZIP members. Failure logged, do not claim first version passed.

## Current mandatory ART HOLD
R15 resolves R14 *projected* high-fist issue and has actual 73-frame native evidence, but the visible 1x human gesture remains unapproved. In particular shoulder cloth attachment, front fist silhouette, body torque and near/far foot weight transfer, and expression legibility must receive further art-grade redraw. All-body connectivity and 0 GPU pixel differences do NOT prove arm attaches to intended shoulder. No production merge, no full FS gameplay battle, no PixelLab paid job. Never call ART PASS without genuine user approval.

## Source attribution
Original artist TheraHedwig (Wolthera van Hövell tot Westerflier), based on Redshrike, original OpenGameArt diagonal walk/run; original ORA SHA 63c990cbf5c882415414a67819de6350a094d130477ac3533c938306483b349c; ZIP SHA 278bba048b4f25b8c8d9601b2cc27402c298cf1c68c554be9e68c8e11c2ee716. Respect original CC BY-SA 3.0 / GPL 3.0 / OGA-BY 3.0 licensing as applicable. Licensed art stays private owner E, public GitHub source/policy only.
