# CURRENT_HANDOFF — P3 G6R4R2 ROUND BASALT + ORIGINAL PETAL SWAY
2026-10-26 | PMD source-derived monster evolution, all maps paused

## User's accepted requirements
- Keep PMD0001 G3R1 current orange/gray cracked rock baby completely unchanged.
- User rejected earlier 0002/0003 visual style: original flower petals only recolored, rocks not distinct. Explicit new direction is individual **rounded boulders** replacing petals while preserving actual **original petal rocking/sway**. 0002 = 3 smaller round stones around vent. 0003 = 5 bigger rounded stones, broader magma opening and brief lava runnel. Do not build a giant walking volcano or hard symmetrical recolored petals.
- F2 maps fully PAUSED, sealed F1R1 A04 untouched.

## This turn's actual output
`P3_G6R4R2_ROUND_BASALT_PMD0002_0003_20261026.zip`, exactly **2,130,073 bytes / 493 files / SHA256 65cf07aa99902a015c4833c9460a58410669ec53e5ca00df0b487b0438cd266a**.
Private Drive ZIP: https://drive.google.com/file/d/1ab-mee3FxA8lenhi74-E5G_dWoTZjA7t/view?usp=drivesdk
Real 0001→0002→0003 current art: https://drive.google.com/file/d/1tujvHlbxZ6o3l8NBXDMlU_qfAUrmn_kQ/view?usp=drivesdk
0002 full original vs new preview: https://drive.google.com/file/d/15xkYVvmAZ6ZCg-Qc2Ai3ut8kIZLqBY0S/view?usp=drivesdk
0003 full original vs new preview: https://drive.google.com/file/d/1i5Aes1ue6u7Ot4kkYbOXG4oDefhzGmer/view?usp=drivesdk
0002 Idle GIF: https://drive.google.com/file/d/1GH74gpehp-h9mIudY7ZP-qfjnFJr6ED3/view?usp=drivesdk
0003 Idle GIF: https://drive.google.com/file/d/19ffbvDusn_0qL12Ps0jmua8pqqRfZZXo/view?usp=drivesdk
0003 Attack GIF: https://drive.google.com/file/d/1i2qkCf39fJpgUjffD1iiiZSPrc4CaezK/view?usp=drivesdk

- 0002 authentic PMDCollab original: 14 XML named motions, 12 true motion image sheets, **682/682 original frame slots edited**; petal/leaf region erased then replaced by 3 distinct rounded basalt units with mineral outlines, shade and orange lava.
- 0003 same independent true `sprite/0003` source: 14/12, **698/698 original frames edited**, 5 bigger round stones and brighter crater.
- The center/position of each edited stone comes from that frame's **original flower centroid and green leaf-petal group data**. Verified every action/direction sequence where original petal moves also has changed boulder placement: **0002 88/88, 0003 89/89**. No made-up sine movement. Real original XML frame timings retained.
- All original XML, original Offsets and Shadows byte-identical. Entire sheet layout, original per-action cell sizes, names and facings preserved. No added sprite frame boundary alpha; foot alpha remains intact.
- First edited G6R4 candidate showed stray old petal outline black pixels near 0003 upper edge. R4R1/R4R2 cleaned tiny isolated remnants; old candidates archived. Historical G6R1/G6R2 overly huge volcano art FAIL retained.
- Native Godot 4.7.2 XMLParser/OpenGL3 GPU ran genuine edited atlas + original XML for BOTH monsters, dynamic frames with 0 ERROR/WARNING. Cold ZIP source and sway QA / both native GPU replay PASS, all SHA checks pass. **This is a Godot bridge only: original PMD game or VX Tankentai SBS NOT TESTED.**
- User Human Art for G6R4R2 0002/0003 **PENDING**; original licensed redistribution/commercial usage unverified. Do not seal as visual PASS without user acceptance.

## Next work
Have user compare 0002/0003 actual PNG/GIF, then adjust rounded stone anatomy of specific frames if needed or implement true target PMD/VX loader offsets/shadow/facing. Never resume F2 maps unless user explicitly requests.
