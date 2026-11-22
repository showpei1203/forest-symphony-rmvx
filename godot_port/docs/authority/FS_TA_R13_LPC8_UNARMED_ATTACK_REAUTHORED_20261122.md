# Forest Symphony T-A R13 | REAL LPC 8-DIRECTION ANATOMY -> ACTOR01 UNARMED ATTACK (R13 ART HOLD)
Date 2026-11-22. This is the latest complete practical T-A work. No weapons, no FX, do not use old front/right 4-direction splice to claim true 45 degrees.

## What is ORIGINAL versus RE-AUTHORED
**ORIGINAL VERIFIED LPC EIGHT-DIRECTION:**
- Original diagonal walk/run archive, artist Wolthera van Hövell tot Westerflier (TheraHedwig), https://opengameart.org/content/lpc-runcycle-and-diagonal-walkcycle .
- User-authorized private E archive E:\LPC_Original_20261121\LPC_8DIR_ORIGINAL_DIAGONAL\LPC_diagonalwalknruncycle.zip . ZIP SHA256 278bba048b4f25b8c8d9601b2cc27402c298cf1c68c554be9e68c8e11c2ee716, 13 members CRC PASS. Original male diagonal walk source 576×512 (9 frames x 8 rows). Editable LPC_male_diagonal_walkcycle.ora has *actual* three sprite layers named torso, arms and head.
- Selected original diagonal *forward/right* direction row7 as owner ACTOR01 45-degree anatomy. Torso/leg source frames [0,1,2,3,4,6,7,8,7,5,2,0]. No original source-native attack frames existed in this downloaded package.
**NEW R13 ATTACK ART (RE-AUTHORED FROM TRUE DIAGONAL ANATOMY):**
- Source GDScript/Python: godot_port/tools/ta_r13_lpc8_actor01_unarmed_attack.py . Actual original ORA torso/arms independently read; attack pose authoring changes both complete source arms about their original shoulder pivot with nearest-neighbor rigid rotation (uniform scale 1, no synthetic linear rubber-arm sticks). Original diagonal torso/legs pose steps retained for weight transfer; approved A62 white hair/face head with SHA 70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e. Green/dark outfit remapped from source shading.
- BODY 12 × 64×64 atlas 256×192 RGBA, **SHA256 04478beeececa0e52e617bf70ca00679bdd77ec8a0c687e50c9a6f7e7010812e**. 11 distinct poses plus F0/F11 exact loop. Every frame one connected full-body silhouette; no isolated pixels. Weapon and FX each separate 256x192 sheets with zero opaque pixels. No sword, shield, attack arc or symbols.
- R13 private output E:\LPC_Original_20261121\FS_R13_ACTOR01_EIGHTDIR_UNARMED_45_ART including 12 pose source contact/animated GIF, actual native Godot contact and original 73 frames.
- **ORIGINAL 8-DIR ATTACK FOUND? NO.** This 12-frame sprite IS a newly authored attack using authentic diagonal body and ORIGINAL layered arms. Do not call it "downloaded 8-dir LPC slash" or "official original 8-dir attack". This fact is NOT a blocker to verifying new artwork quality, but truthfulness required.

## ACTUAL native original-source QA
- On owner Windows, official Godot 4.7.2 OpenGL SubViewport renders actual private source atlas, 64x64 at 60Hz, 73/73 captured PNG; 12 frame slots all shown, visual F7 contact presentation event at local 0.630 sec fires once. Source-to-native screenshot 12/12 exact RGBA 0 differing bytes. No simulated test-color atlas.
- Video-style proof R13_GODOT472_ACTUAL_73_FRAMES_60HZ.gif is constructed FROM all 73 real captured native screenshots at 60Hz, NOT synthetic images; sprite 1×/4× true native contact sheets included.
- QA ZIP: E:\LPC_Original_20261121\FS_R13_ACTOR01_EIGHTDIR_UNARMED_45_ART\FS_TA_R13_REAL_8DIR_UNARMED_73_NATIVE_QA_20261122.zip, 261925 bytes, 90 entries ZIP CRC PASS, SHA256 f875f8015d8a515e21c280c862e8560c2c3178149fab36001436067815196c7b.
- Reproducer godot_port/tools/ta_r13_lpc8_actor01_unarmed_attack.py, native capture godot_port/tests/capture_ta_r13_lpc8_unarmed_native.gd, native pack godot_port/tools/ta_r13_lpc8_native_qa_pack.py. Real manifest godot_port/docs/handoff/TA_R13_TRUE_8DIR_UNARMED_ATTACK_MANIFEST_20261122.json and GPU QA godot_port/docs/handoff/TA_R13_8DIR_UNARMED_NATIVE_QA_20261122.json.
- These are engine art presentation tests only. The real FS ATB, damage/HP, main combat scene and other branch integration were NOT run. No original A52/A62 or R8-R12 artifacts modified; independent T-A branch only.

## QUALITY STOPS / Current ART gate
**ART HOLD** due visible rigid shoulder movement, stiff fist/arm gesture, and possible 1x face expressiveness/depth concerns. Source correct and OpenGL native PASS does not confer ART PASS. User must see 1× actual 64px 12 frame loop; further pixel-painted arm/shoulder/chest/head transitions needed before production. Zero weapons until user changes requirement. Do not revert to four-way base source; audit 8-way pose source via original ORA and credit author.

## Copyright
Original diagonal LPC art uses CC BY-SA 3.0 / GPL 3.0 / OGA-BY 3.0 per original OpenGameArt listing. Original art PNG/ORA remain private on owner E or compliant private Drive; GitHub only stores code, manifests, credit/provenance. Follow author attribution and relevant license obligations if distributed.
