# P3 G8R3: Actual PMD Sprite Repair, Invalid ImageGen Detour (2026-10-26)

## Failure cause
User reported extra black outlines surrounding G8R1 frog and magma almost invisible. Assistant mistakenly returned two unrelated 1448x1086 AI concept images instead of editing original 32x32 PMD sprite sheets. That was a genuine workflow failure. The images are NOT compatible with original PMD XML or atlas grids and cannot count as deliverables.

## Native source repair candidate
Rebuilt authentic SpriteCollab PMD 0002/0003 source in isolated Windows toolchain. Fixed only 12 original Idle/Walk source cells per species (D0/D2/D4 F0/F1), 24 total. Original 0001 and maps unchanged, F2 maps paused. All other motions unchanged, original XML, offsets and shadows exact. Cleaned original flower/leaf black drawing outside protected body area; reduced harsh saddle outline; retoned upper non-body black pixels to basalt without deleting alpha; moved genuine orange/yellow visible lava rim and flickering flame into topmost OpenRaster editable layer, added restrained stone fissures. Original blue-body opaque pixel removal count=0, foot contact and frame edge preserved. Native Godot XMLParser/OpenGL GPU tests both passed, with no engine errors/warnings. ZIP cold extracted, all file hashes and independent source/ORA QC passed.

## ART FAIL GATE STILL OPEN
Although technical validation passed, 8x manual inspection and image QA still show a remaining extraneous black mark in certain 0003 frames. Therefore G8R3 is a partial tech candidate with HUMAN ART FAIL/PENDING, not visually approved. Do not expand 682/698 original frames or promote as sealed. Original PMD engine and VX SBS NOT TESTED. Pixelorama headless export remains unverified.

## Delivery
Drive ZIP: https://drive.google.com/file/d/1JmyszFCKJ-_wvpWj6llCPU6kKDNWiiKG/view?usp=drivesdk
2,026,111 bytes, 527 files, SHA256 7a7a9268b57ea6f983e1ecab3689557f1cd72dd65afa3c9c2c7c91b1465aac05, cloud hash checked.
True 0002 Idle comparison https://drive.google.com/file/d/1Am8kPVRT-jVsnqLD0copK8EleK2u1RmA/view?usp=drivesdk
True 0003 Idle comparison https://drive.google.com/file/d/1EapTaj8BcI5C_RYLH-L4dKC3vRmOj85o/view?usp=drivesdk
Drive Handoff https://drive.google.com/file/d/1vx_C8YFLKxAojnXthnORIKAJOivcxrqO/view?usp=drivesdk

## Next gate
Inspect every selected actual source 32x32 frame at 1x and nearest-neighbor zoom. Eliminate remaining stray upper 0003 dark parts while fully protecting body outline, align vent fire with body movement, reopen OpenRaster in native editor if possible. Do not substitute AI-generated conceptual sheets. Keep all negative tests + Drive/GitHub/Linear Handoff.