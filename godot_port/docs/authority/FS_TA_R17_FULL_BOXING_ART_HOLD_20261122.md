# Forest Symphony T-A R17 — 8-dir LPC 12-frame boxing alternate (ART HOLD)
Date 2026-11-22. Branch `feat/fs-pixellab-ta-actor-20261121`. R16 remains preserved, R17 is not production art and must not be merged into formal combat until actual 1x art acceptance.

## Actual work
- Started from R16 generator, retained the verified original LPC eight-direction diagonal WALK layered ORA, approved A62 white-haired/green outfit identity, and original hip/boot source pixels. The source is 8-dir WALK/RUN, NOT an official 8-dir ATTACK animation.
- Re-posed the whole 12-frame attack in one pass: left-handed guard/anticipation, negative-x pre-load through F2-F4, forward chest and arm drive F5-F7, F7 contact at 0.630s, F8-F10 retract and exact F11=F0 seam. Near/far shoulders and elbows use original 8px source upper bones, no elastic lines.
- Reworked near-hand distal source skin contour by trimming edge source pixels, NOT drawing synthetic fist/connector or adding a weapon. It is an artistic attempt, not an approved convincing boxing fist.
- Private Body256x192 PNG SHA256 `1a3001f87278b9244e7282cf0baa110ce10dfd0b159badcb76c4d911e1981587`; 12 poses, 11 unique, F0=F11. Separate Weapon and FX layers both fully transparent.
- All original foot source rows remain untouched within source torso transform; shoulder contact and body connectivity verified BEFORE hair overlay.

## Actual native engine QA
Owner machine Windows / AMD RX 6700 XT / official Godot 4.7.2 OpenGL. 73/73 native 64x64 screenshots at 60Hz. 12 key source vs GPU full RGBA byte mismatch = 0; all 12 poses visited; visual contact event once at 0.630s. This is an isolated sprite presenter, NOT live original FS Battle ATB/HP/damage.
Private QA ZIP: `FS_TA_R17_8DIR_TWO_JOINT_UNARMED_NATIVE_73FRAMES_QA_20261122.zip`, 249356 bytes, 91 members, CRC PASS; SHA256 `1140ca1b3b9ed358ffa9466e3726c583c2c09fb161274e375e6f26dd884d05cb`.
Owner E source/art path `E:\LPC_Original_20261121\FS_R17_ACTOR01_EIGHTDIR_TWO_JOINT_UNARMED_45`. 13 main files copied SHA-identically to owner G: Google Drive Desktop mount `FS_GameAsset_Backups/FS_SBS_Character_Actions_20261101/T_A_R17_LPC8_ACTOR01_UNARMED_20261122`; cloud upload is NOT claimed until Drive connector readback.

## ART Gate
**ART HOLD.** Compared original R16 and actual R17 Godot 4x key frames. R17 has different chest-load and forward strike poses but F7 hand still reads as an elongated open palm/forearm rather than a compact natural clenched fist; full-body kinetic chain and subtle 1x expression remain below acceptance. The next improvement must address the *complete boxing silhouette* rather than adding more pixel-connectivity tests. Do not hide flaws as PASS. Preserve approved A52/A62, don't add sword/shield/FX, don't modify T-B/T-C or main.
## Provenance
Original eight-direction body: TheraHedwig based on Redshrike, https://opengameart.org/content/lpc-runcycle-and-diagonal-walkcycle ; preserve upstream multi-license and attribution. Do not commit original private binary art to public GitHub.
