# ASF VX-native Kaduki/SBS adapter verification | 2026-10-31
Status: TECH PASS on 4-direction native images and Godot; VX native Runtime of NEW adapter NOT RUN; original/numbered actions not reimagined.

Original sealed test source: FS_FORMAL_RUNTIME_B0_ISOLATED_20261024/clone_project/K4_BASELINE (read-only; no modification).
Source $actor01.png: 96x128 -> 3x4 x 32x32, sha256 df6abaa888dc4ffcaf5351daf26d678bace121e277f21b4651eb69884591a2a5.
Source IconSet.png: 384x15096, icon ID2 crop 48,0,24,24, sha256 8273bc643025f92496a7471cf080cd6a87d0a762fc04731c7f016e00f0c0bb2c.
Body battler root [16,21]; Godot SpriteFrames root offset [-16,-21], original G0-1B authority.
Original RGSS visible weapon angles [-75,-15,45] maps to [75,15,-45] Godot, Or=4 bottom right with no fabricated X/Y offset.
ASF \`build_animation_clips.py\`: 12 original frame PNG, 8 clips (idle+walk x4), warnings=0; \`export_engine.py\`: Aseprite JSON + Godot SpriteFrames from same original art, no sprite reconstruction and no rescaling.
Godot 4.7.2 AMD Radeon RX6700XT native OpenGL: 560x340 two capture PNG actual GPU render. Pixel ROI comparisons for four directions x two timepoints = EIGHT exact matches, all mean absolute error 0 and max channel delta 0 vs original source blended over screenshot background. The 4 moving character ROI changes [down 471,left 384,right 384,up 370].
NEGATIVE case: removed down-0.png from 11/12 copied original cells, tool exited nonzero and output directory was not published.
Critically original numbered $actor01_5.png has 5/12 occupied cells; _7 has 6/12. They are action-specific/partial, NOT four complete facing clips. Import should reject any nonexistent orientations/poses.
LIMITS: G0-1B angle mapping is reused from prior formal authority, not a new comparison with contemporaneous native VX video; this test only proved Godot using that mapping. No fresh VX Game.exe test, no realistic attack/idle/hurt/new art created, no human weapon visual acceptance.
Source PNGs, 24x24 icon crop, GPU screenshots remain local in an isolated ZIP and must NOT be placed in a public repository without licensing audit. GitHub holds reproducible code, exported scene metadata and QA only.

FULL LOCAL PATH: E:\GameAssetToolLab_20261023\ASF_Test_20261031\vx_real_actor_20261031