# FS Stage16 A33D — FAILURE REGISTER / anti-regression
Date: 2026-11-01. All original sources kept untouched.

## F-REMOTE-NO-TOOL
Assistant repeatedly claimed this conversation had no Remote Desktop tools and told user to change chats. Fact-check with connected tools showed `mcp__Remote_Desktop_Commander__list_devices` returned DESKTOP-90VT437 Online and remote file reads/terminal writes successfully executed. **Never claim tool absence without first inspecting tools and live status.**

## F-GROUND-DARK-12
First A33D Ground generator triggered a fail-closed assertion: 12 residual pixels reentered prior A33B erroneous dark-green contour class. The actual forest Ground was NOT emitted by this failed attempt. Corrected by repairing ONLY the residual specific RGB-class pixels, explicitly preserving original 1885 floral positions and entire original road RGB. Rerun produces fault detector 0. Do not use broad Gaussian/median across the whole Ground.

## F-FOOT-ROAD-LEFTSOUTH
New small tree `left_south` originally proposed foot [184,352], tile (5,11) had 22.8% road. Repositioned X 151→112, foot [145,352], tile (4,11) road fraction 0.0 and local 16px foot road fraction0. New foot blockers MUST fail closed if grass/road not inspected, not just overlay tree images and ignore player passability.

## F-RGSS-TEST-OBJECT-INDEX
First isolated VX Map50 build failed at expected line index for `OBJECTS =` in test-only script 483; index had actually contained `MAP_ID`. The failed first clone was renamed `E:\FS_STAGE16_A33D_FIRST_BUILD_FAILED_20261101` for forensic retention, not overwritten. A separate fresh clone was built from untouched A33C and locate `OBJECTS =` by exact line prefix rather than hard-coded line number. Marshal RGSS2 readback PASS.

## F-SOURCE-DIVERSITY-LIMIT
A33D adds nine individually sourced tree RGBA PNGs from four APPROVED source tree sprites, using nearest-neighbor scaling and horizontal flips with small intrinsic green offsets, not novel AI-drawn species. Potential visible repeated canopy identity, density imbalance and insufficient forest ecology remain an ART review risk; **user art review PENDING**. Do not claim full forest reference (Ground3 1280x928) or generated brand-new species. Future alternatives should introduce more verified authentic or truly newly generated complete tree sprite species and check style continuity rather than copy-pasting apparent clones.

## F-NATIVE-PAR-STATIC-vs-DYNAMIC
Ground+PAR composite is a proof visual, but real VX must also load each of 21 separate `Cache.overlay` sprites with foot-sorted depth; simply providing a 544x416 flattened screenshot would FAIL. New E-layer blocking IDs 768 must actually alter `Data/Map050.rvdata`, and test script slot movement must confirm both new side tree blockers. Existing block12 and original road remain PASS. New total blockers21, 200 of200 legal tiles BFS connected.

## Status, source, and next gate
A33D `E:\FS_STAGE16_A33D_FOREST_20261101`, actual native isolated `E:\FS_STAGE16_A33D_FOREST_VX_NATIVE_20261101`, source A33C original intact; Godot native source copies under A33D; independent cold verify. Existing A32B PAR original exact SHA `24912a82622043c6c0b25b434a0a49585bb5cc470c4c83222a7db2d187de45fb`, A33C Ground original SHA `d76bd016017fd6adcd4f767f2972fb2dc3f97e1f26d11b36cef2cc280e9b4043`. New A33D Ground SHA `4af7f6bd86b8cdd171c7a13de59cd93a3a6a904c599b9be2640d8cae88f46c00`; 21-object compiled PAR SHA `5cb0438c5535192d130d9aa39856bef0302994c1d1b023a21b2ae2c5eb239ac8`.
A33D native engineering PASS, user art PENDING, Formal Seal NO. Production sealed battle regression not retested.


## Verified Google Drive A33D deliverables (2026-11-01)
All file IDs below were actually returned by connected Google Drive folder listing. Private art is NOT published on public GitHub.
- Actual RPG Maker VX original forest **before/after 544px wide**, full scene and 4 regional crops: https://drive.google.com/file/d/1yQ-SmvuXalx4l6I97o7VArFCqS8mvFrE/view
- **Forest 4 trees vs 10 trees vs 13 trees**, truly layered Ground+PAR 3-way: https://drive.google.com/file/d/1IQs-i6n_EBPJd2akbKxWtFyNsMvIdUjt/view
- **Final standalone Ground opaque 544x416** `A33D_GROUND_FOREST_FLOOR_544x416.png`: https://drive.google.com/file/d/1HF6FzWd-DDvJD1nkrpDuZTMzZc8Cp9eG/view
- **Rebuilt 21-object transparent PAR50**: https://drive.google.com/file/d/1nEmQ0f9sNqwof5BuKFCgzSkQUfv9-X1F/view
- Actual 21-layer **Ground+PAR full render**: https://drive.google.com/file/d/163V6Y3a9BtxvnaWWTlb8XtG3eCmEm4NX/view
- **9 new transparent individual tree PNGs** preview: https://drive.google.com/file/d/1ZHSCSkAXV3JdE_1zD3XZeXa5xDvj6PGt/view
- Actual native VX forest quadrant zooms: https://drive.google.com/file/d/1XzcXV8Yb4BC2gRIFV3vT0hnFFJpZqKEv/view
- Habitat mask Ground ecology: https://drive.google.com/file/d/1HX6agBF7b9ekkDxW08nZMGiui65gRcO0/view
- Source and 9 object IDs/foot positions/alpha SHA in Manifest: https://drive.google.com/file/d/13hiH_p_1HAddkyUQA6yl1JzDPCjWJxKB/view
- **Complete private evidence ZIP**, 138 items 32,666,026 bytes, local ZIP CRC, all member SHA256 and cold extraction PASS; Google Drive title/size readback confirmed (no independent remote ZIP-content SHA claimed): https://drive.google.com/file/d/19qB0o7j8sVAOsy4lfLBYu8k-LaVUrifh/view
- Native VX 16 cases/32-frame verification: https://drive.google.com/file/d/1xtAT2dEqSmNJVQx0To1XQLpwJIfx10T8/view
- Fresh native 3404-file cold verification: https://drive.google.com/file/d/1RnOcX5A5qgDQNJiBwnGKGXmykrq9Cy2i/view
- Godot GPU actual 12-frame numeric QA: https://drive.google.com/file/d/1q5wwKlr43V117ekCA5dXu5SitHrRz5A6/view
- A33D Failure Register: https://drive.google.com/file/d/1F-pZ_t8Eod-HhMLjZlAhw8hHOf0iNLnI/view
- A33D detailed Handoff: https://drive.google.com/file/d/1evJHqFSzEMzl0GuJD7dvAQX526hkNviN/view
- A33D CURRENT_HANDOFF: https://drive.google.com/file/d/1m1THx2XEzZQlXB11iOGPcXZIbgwmdSry/view
- Private stage folder: https://drive.google.com/drive/folders/12cp_UCd2JvJw3zRZnHdyUhuyyvNgKI0z

**A33D engineering native dual engine/cold PASS, user forest ART approval PENDING, full production regression Formal Seal NO.**
