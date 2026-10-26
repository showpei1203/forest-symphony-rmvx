# CURRENT_HANDOFF — P3 BACK-VOLCANO G6R3 PMD 0002 and 0003
Date: 2026-10-26 | Shared Game Pixel Asset Pipeline
**F2/F1 mapping PAUSED on user direction**. Do not modify already accepted F1R1 A04, Ground/PAR, other concurrent game jobs or 0001 user-liked original.

## User intent (new art authority)
PMD0001 G3R1 was explicitly liked/approved as an orange-gray cracked basalt juvenile. The newly approved evolutionary concept is **a little volcano grows on the animal's BACK**:
- 0001 orange-gray frog + cracked rock shell, leave existing accepted design untouched.
- 0002 low volcano emerging above the frog's back, small dark crater/rim with internal molten glow.
- 0003 mature but still backpack-sized cone, distinctly larger crater, a short lava runnel on slope, orange-gray rock/fire family palette.
- Any candidate looking like a whole walking volcano instead of a frog carrying a volcano is ART_FAIL.

## THIS TURN ACTUAL IMPLEMENTATION
New G6R3 outputs were built directly on each authentic PMDCollab/SpriteCollab original source:
- 0002 original AnimData.xml defines 14 names, 12 actual action sheets, 682 individual frames. All 682 frames updated with native-pixel volcano materials at their original locations. 309/682 cells also have >=2 newly altered alpha pixels; don't claim all original outlines differ.
- 0003 original AnimData.xml 14 names, 12 actual action sheets, 698 frame cells. All 698 cells updated, of which 573/698 have >=2 alpha profile changes.
- Original XML, every Offsets PNG and every Shadow PNG retained byte-identical. All action frame dimensions, sheet layout, direction rows, names and original frame timings preserved. Foot alpha below the mountain and original frame boundary protected. Some pose actions can legitimately show minimal silhouette change; each still has substantial pixel material change.
- Source visual previews inspected: G6R1 grew a volcano too large and swallowed frog anatomy (ART_FAIL), G6R2 smaller but still too big (ART_FAIL), G6R3 reduced both cone height and width and keeps the frog head/body/limbs visible in the Idle source previews. Errors in source image conversion and strict Hurt/Attack source masks fixed and retained in historical isolated fail folders.
- Actual Godot 4.7.2 native XMLParser+OpenGL GPU replay for 0002+0003: PASS with three changing GPU frames per species, zero ERROR/WARNING. Cold-extracted ZIP all file SHA + 1,380 source frame checks and actual native Godot import/render for both: PASS. **This is a Godot bridge, not original PMD game loader or actual RPG Maker VX Tankentai SBS compatibility**. Both original target runtimes NOT TESTED.
- 0002/0003 USER HUMAN ART SIGNOFF still PENDING. User approval on original 0001 art direction is not blanket acceptance of new stages. Fan SpriteCollab attribution/licensing/commercial use unverified.

## Downloadable verified artifact
PRIVATE complete ZIP (both original and transformed atlases, original XML, source scripts, native Godot projects, QA LOG/CMD/Handoff, comparison image, Idle GIF):
https://drive.google.com/file/d/13KjrgRd0jg-uV2QudHGdHIzoq9p7I5x8/view?usp=drivesdk
1,875,908 bytes, 493 members, SHA256 3fdb72351d92ffbb4c2bbc0aaf36cda2b3fb5454baa5637a4d54cb2d72dc3767; CRC/cold SHA/full QA/cold native Godot both PASS.
Three actual original-source-derived 0001-0002-0003 screenshots:
https://drive.google.com/file/d/1EywDRko-8LcReoYqhdWl3V3VbKbeItEI/view?usp=drivesdk
0002 original versus backpack volcano all facings:
https://drive.google.com/file/d/1v3gsHmytIHTwpYtu5qkzhsGkFJFZku6h/view?usp=drivesdk
0003 original versus backpack volcano all facings:
https://drive.google.com/file/d/1p3qTrz37vQrvkqSo5cpyCuQy34VpNT8a/view?usp=drivesdk
0002 true XML Idle preview:
https://drive.google.com/file/d/1owZJsiMUjMPVGwyZQNJ6AsFxIIBORbJV/view?usp=drivesdk
0003 true XML Idle preview:
https://drive.google.com/file/d/1yZTp2fALXx-LDzrEnKgciWM1H3Rpk4XC/view?usp=drivesdk

## Latest GitHub Authority
https://github.com/showpei1203/forest-symphony-rmvx/blob/feature/ai-art-toolchain-pilot-20261025/authority/PMD_BACK_VOLCANO_G6R3_0002_0003_20261026.md
Reproduction tools at tools/ai_art_toolchain/build_p3_g6r3_volcano_0002_0003.py, test_p3_g6r3_true_godot_volcano.py, package_p3_g6r3_volcano_all.py, on feature/ai-art-toolchain-pilot-20261025 branch.

## Next steps (not yet PASS)
- User human visual review of G6R3 0002 & 0003 true source previews/Idle XML GIF, especially whether the animal's head and body remain legible and caldera clearly reads like a mountain.
- Actual PMD engine original XML player or isolated original VX Tankentai SBS integration with Offsets, Shadow, native face directions, frame timing, foot positioning. Never promote merely from Godot bridge.
- No map work while paused. Deliver each next iteration with source, original, ZIP, quick CMD, QA failure records, latest Drive/GitHub/Linear Handoff.
