# P3 G6R4R2 — Round Basalt Stones with Original PMD Petal Sway
Date: 2026-10-26 | Authority branch `feature/ai-art-toolchain-pilot-20261025`

## Scope lock
- User explicitly paused **all map work**, so no F2 Ground/PAR or accepted F1R1 A04 material was touched.
- Original PMD `0001` user's **orange-gray lava basalt juvenile direction** is preserved unchanged.
- User approved new morphology requirement: in 0002/0003, **flower petals become visibly individual rounded stones**, preserving the original flower/leaf motion and original XML atlas structure. Do not merely recolor petals or leave a rigid triangular shell.

## Actual completed G6R4R2 original source-derived art
Rebuilt BOTH authentic `PMDCollab/SpriteCollab` species source sets:
- `sprite/0002`: original 14 XML motion names (12 real action atlases plus 2 CopyOf), **682/682** original action/direction/frame cells modified. **Three separate rounded uneven dark basalt stones** encircle a small inner lava vent. Warm orange and gray frog body and feet remain recognizable.
- `sprite/0003`: 14 XML names, 12 action sheets, **698/698** source cells modified. **Five larger separate rounded stones**, fuller magma crater and restrained outer lava runnel; stronger family evolution than 0002.
- Original `AnimData.xml`, all `-Offsets.png`, all `-Shadow.png` are **byte-identical** to respective original species. All atlas sheet dimensions, facing rows, action slots and source durations unchanged. At original cell borders **no new opaque pixels**; original bottom-four-row foot alpha preserved for each cell.
- Original green flower/leaf and upper petal surfaces were **semantically cleared**, then the new boulders were drawn as pixel-crisp individual disks with outline, shadow and highlight rather than petal-shaped blocks.
- **Preserving sway is checked, not just asserted**: each new cell derives stone placement from its *own original* flower centroid and left/right leaf-petal groups, so the original motion is the spatial input. In 0002, **88/88** originally moving action/direction sequences showed edited boulder position changes. In 0003 **89/89**. Original XML frame durations unchanged. Per-frame anchoring points and the resulting rounded-stone centers are in the QA JSON.
- Every one of the 1,380 individual original cells has measurable new pixels, at least 2 hot visible lava pixels, and 3 or 5 rounded rock centers depending on species. Do not incorrectly assert every cell has new outer alpha silhouette; material and outline editing are distinct measurements.

## Recorded failures and improvements
- Earlier G6R3 volcano still read as gray recolored flower petals. User rejected morphology, therefore G6R3 art is not a production baseline.
- G6R4 source changed to true individual round boulders; first self-visual review found **floating dark flower-outline specks**, especially over 0003. Preserved older draft and updated to `G6R4R1`, then `G6R4R2`, cleaning only tiny detached original flower outlines in the upper crown while keeping source pose/leg regions and original frame borders. No overwrites of historic candidates.
- Original earlier giant volcano artifacts G6R1/G6R2 are ART FAIL and remain archived separately.
- If user sees any persistent flower outline or rigid rock wobble, do not mark Art PASS; iterate source-derived geometry on specific frame/pose, never redraw full-sheet fake mockups.

## Native QA and cold release evidence
- For **both** species: native Godot v4.7.2 XMLParser + OpenGL GPU bridge loaded actual modified atlas sources paired with untouched original `AnimData.xml`; 3 changing GPU outputs, **zero ERROR/WARNING**.
- From a **freshly cold extracted ZIP**: all file SHA-256 confirmed, full 682+698 source/stone/sway tests passed and both Godot import/native GPU tests reran PASS.
- Native **original PMD game runtime** and RPG Maker VX Tankentai SBS loader **NOT TESTED**, so no claims of their compatibility. Commercial fan-asset licensing and attribution not yet verified.
- `0002` and `0003` **Human Visual Gate = PENDING**; user likes 0001 lineage but has not personally accepted G6R4R2 yet.

## Verified private Drive deliverables
- [Actual G6R4R2 complete 0002+0003 source/modified sprites/XML/Godot/animations/QA/LOG/Handoff ZIP](https://drive.google.com/file/d/1ab-mee3FxA8lenhi74-E5G_dWoTZjA7t/view?usp=drivesdk). **2,130,073 B, 493 ZIP members; SHA256 `65cf07aa99902a015c4833c9460a58410669ec53e5ca00df0b487b0438cd266a`**; cloud copy SHA confirmed.
- [Actual 0001→0002→0003 round basalt family preview](https://drive.google.com/file/d/1tujvHlbxZ6o3l8NBXDMlU_qfAUrmn_kQ/view?usp=drivesdk)
- [0002 original versus new round-stone atlas preview](https://drive.google.com/file/d/15xkYVvmAZ6ZCg-Qc2Ai3ut8kIZLqBY0S/view?usp=drivesdk), [0003 comparison](https://drive.google.com/file/d/1i5Aes1ue6u7Ot4kkYbOXG4oDefhzGmer/view?usp=drivesdk)
- Source-movement GIFs: [0002 Idle](https://drive.google.com/file/d/1GH74gpehp-h9mIudY7ZP-qfjnFJr6ED3/view?usp=drivesdk), [0003 Idle](https://drive.google.com/file/d/19ffbvDusn_0qL12Ps0jmua8pqqRfZZXo/view?usp=drivesdk), [0003 Attack](https://drive.google.com/file/d/1i2qkCf39fJpgUjffD1iiiZSPrc4CaezK/view?usp=drivesdk).

## Next gates
1. User visual check whether rounded basalt is sufficiently rocklike rather than flowerlike and whether movement is pleasing in 0002 and 0003 actions.
2. Isolated real target-compatible PMD game or RGSS2/VX Tankentai SBS test, including action facing, correct per-species offsets, shadows, pivots and timing. Do **not** conflate with our Godot bridge.
3. If the user requests further revision, use **specific original frame cells** and preserve user-approved 0001.
4. Continue per-milestone ZIP+source+CMD+LOG+Handoff / Drive+GitHub+Linear. F2 maps remain PAUSED.
