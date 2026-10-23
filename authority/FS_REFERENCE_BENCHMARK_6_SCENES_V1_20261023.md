# Six reference scenes | Forest Symphony source-first map QA | 2026-10-23

Artifact class: **CONCEPT REFERENCE**, not compiled Ground/PAR. Never crop the six flattened user-supplied images into claimed engine-ready sibling layers.

Google Drive authority and 6 original PNGs: https://drive.google.com/drive/folders/1_p2Yq27CT4poSzvVp9nhVE8u3_9KfMj9

New detailed native benchmark: https://docs.google.com/document/d/1Mv-ijuSH432yTd3ZtuK5Afj3daQYxuLTrKJYpGOAzI0/edit

Portable complete snapshot (originals, source PNG SHA checks, machine-readable source/ground/PAR/occlusion/collision rubric): https://drive.google.com/file/d/1ymsPunATsaIgDhBpVI5sCoraTVCCaDkj/view

## Visual categories

| Reference | Pixel size | Purpose | Stage |
|---|---|---|---|
| SCENE04.png | 544×416 | two elevations, stair/ledge, water edge, vertical cliff faces | **B0 P0** |
| ground3.png | 1280×928 | rich 2D woodland village, distinct house silhouettes, terraced paths and canopy | **B1 P0** |
| SCENE21.png | 544×416 | sacred woodland mood, moss roofs, mixed canopy, flora and landmark | B1 |
| SCENE001(1).png | 544×416 | wood cottage, well, notice, yard, roof/stone rim occlusion | B1 |
| ground12_4.png | 1280×1280 | market props, campsite, tents, readable paths | B2 |
| ground2_1.png | 1280×1600 | high-complexity cave, abyss, 2D bridges/underpasses, multi-height collision | B3 |

All six provided PNGs have **zero pixels with alpha=0**. Several contain opaque black matte void regions; do not interpret a black background as a ready-to-use transparency mask. Occluded background data is irretrievable from a single flattened image.

## Ground/PAR and height semantics

- Ground: paths, terrain top surfaces, floor textures, small flowers, lower-zone water/abyss background. Ground alone does not imply passability.
- Par_COMPLETE: buildings, roofs, trunks, tree canopies, vertical cliff and cave faces, bridges/decks and railings, signs, fences, well and market props.
- Occlusion: per-source-object, including height region and actor's world state. A simple global Y-sorting order is insufficient for character moving under a bridge or on another height plane.
- Collision: terrain cliffs/abyss/structures must block movement; legal ramps/stairs/bridges connect height regions. Player's feet are tested, not decorative object bounding rectangles.
- All derivatives must compile from one Scene Manifest / canonical source assets, with real alpha, SHA/provenance and exact integer placement.

## Measured gap versus existing Rich Pilot V2.1

Remote `scripts/reference_gap_gate_v1.py` produced 2/9 *additional reference-readiness* criteria met: only proximity-ID interaction tests and independent engine smoke. Missing: distinct architecture geometry, inn, treehouse, river, true bridge, central sacred tree, terrain-height transitions. Prior 12/12 native engine smoke results remain valid, but do **not** imply concept fidelity. Logs stored on authorized Windows PC at `E:\GameAssetToolLab_20261023\FS_ElfVillage_RichPilot_20261023\logs\RICH_REFERENCE_STYLE_GAP_V1.json`.

## Execution priority

1. B0 SCENE04: 544×416 source-first terrain prototype with 2 height zones, walkable stair connection, cliff sidewall/shore Ground/PAR semantics, 1px mutation and real VX/Godot actor movement. If suitable approved source tiles are absent, mark BLOCKED_SOURCE_KIT. No fake source from opaque screenshot.
2. B1 ground3: retain the existing 864×640 or larger source-first map but replace paint-over roofs with **3 true building silhouettes**; add inn, treehouse, central sacred tree, river and bridge. Full navigation, object ordering and formal human QA.
3. B2 market/camp ground12_4.
4. B3 multi-height cave/bridges ground2_1 with elevation-aware actor movement.

Do not alter sealed Forest Symphony runtime or claim FORMAL PASS until the actual sealed binary has been cloned and verified and human Gate F is completed.
