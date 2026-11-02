# Forest Symphony — A36F R1 Visual Rework | 2026-11-03

**Latest active visual candidate A36F R1: engineering verified, art review still PENDING, Formal Seal NO.** Actual 1280×928 Ground/PAR, separate 32px VX collision and real native runs; not a concept rendering. Original FS and A36E are read-only and preserved.

## Canonical user-provided reference paths
- Original: https://drive.google.com/drive/folders/1JZL1RLbWECyZP_ddn-TSFjpCaw5C8jtr
- Original maps: https://drive.google.com/drive/folders/18PuuvYK1ClurHzLeKLG6yXZqKXDLa_tS
- Trees: https://drive.google.com/drive/folders/1Zth8u84_5-_pLTf-Ut_a86QiLBuhdaBw
- Buildings: https://drive.google.com/drive/folders/1_1fCD0jLwISt1SApxKwbNF3zIVMOyYlW
- Plants: https://drive.google.com/drive/folders/1lem9jNNVOqmpXMpu1Ns90bbuT6XtK59U
- Precise original flower source Hanzo-VSFlowers01 SHA256 `3d39b5a25a75a886bba42380a567ab86aefd58e515d4ffb2ec109e5dcf50ddc3`: https://drive.google.com/file/d/1VTKD9xCNNagPsNXzLufhPy8Uj6B5NLxj/view
- RIGHT house parent came from A36E original user Hanzo-TownSet03VS SHA256 `8a1da7ffe2db8361c68fb2a2874fa0868a313aca9861bba4a07f95d4c455063c`: https://drive.google.com/file/d/1OmAF2slFsRwTsaXDjQn4QWgfz57CdHCo/view
- Previous baseline: `experiments/route_b_25d_20261031_stage16/CURRENT_HANDOFF_STAGE16_A36E_20261102.md`.

## What was really created
- Remote source directory: `E:\FS_STAGE16_A36F_ELF_FOREST_REWORK_20261103`. A36E still exists untouched at `E:\FS_STAGE16_A36E_VILLAGE_ART_20261102`.
- Real Ground: `A36F_GROUND_GRASS_FLOWERS_ROAD_1280x928.png`; sourced from original A36E Ground, rebuilt organic road edge via signed distance and spatially coherent multi-scale disturbances, preserving all road core pixels and the five route topology. **33,859 road-mask pixels changed**.
- **1,450** small native forest shrub-derived tufts, **175** source-derived small Hanzo flower groups and grass intrusions along footpaths, with actual independent small source PNGs in `GROUND_SOURCE_RGBA`. Plant decorations are Ground ONLY, never fake blockers or separate PAR generated for convenience.
- Real PAR: `A36F_PAR50_RGBA_1280x928.png` from independent SHA checked source RGBA objects in sorted `(foot_y,id)` order; **222 original trees + 240 shrubs (65 new nonblocking undergrowth) + 2 distinct same-family houses + 4 landmarks = 468 RGBA scene objects**.
- House art: BOTH houses from the previous **RIGHT** Hanzo moss/stonehouse visual family. `A36F_ELF_COTTAGE_B` is the original right mother; `A36F_ELF_COTTAGE_A` is a **238×236** genuine same-family variant with workshop side annex masonry, second window/shutters, sloped annex roof, stone chimney, and native source flower planters. Left A36E blue roof has been removed from A36F; original remains preserved in A36E baseline. This is not just a recolor.
- Full actual pixel composite `A36F_TRUE_GROUND_PLUS_PAR_1280x928.png`, before/after `A36E_VS_A36F_REAL_GROUND_PAR_COMPARISON.png`.
- **233 blocked footprint cells**, **927/927 free cells reachable**; natural road remains navigable, all underlying sprites individually alpha-isolated and whole, no guessed cliff terrain/parallax.

## Real engine evidence and results
- Isolated VX native: `E:\FS_STAGE16_A36F_ELF_FOREST_VX_NATIVE_20261103`. Actual RPG Maker VX `Game.exe`, 40×29 Map050, **468 sprites loaded**, 11 positions/22 real 544×416 actor/hidden screenshots, **0 RGSS error modals**.
- Real tree-root collision: `A36F_BLOCK before=11,11 after=11,11`.
- Real road walk: `A36F_ROAD before=11,8 after=12,8`.
- Godot 4.7.2 RX6700XT: 6 native GPU 1280×928 images, 6 native 544×416 regions, **max RGB per channel delta 1**, **0 pixels above delta 1** compared with compiled true Ground+PAR source.
- Isolated independent cold VX clone: `E:\FS_STAGE16_A36F_ELF_FOREST_VX_COLD_20261103` **3,875/3,875 SHA256 identical**, fresh Game.exe starts Map050 with 468 objects and no modal. QA saved in `A36F_NATIVE_VX_COLD_REBUILD_QA.json`. Existing QA source script inherited the "stage": "A36E" label but the verified cold path/log and 468-object assertions are A36F; correct stage label in QA archive metadata.
- Proof files `A36F_GROUND_QA.json`, `A36F_ART_BUILD_QA.json`, `A36F_NATIVE_GPU_STAGE_GATE_QA.json`, `A36F_NATIVE_VX_COLD_REBUILD_QA.json`, plus per-frame captures and candidate PNGs.

## Actual QA failures fixed (not silently ignored)
- Initial Ground generator could not import `scipy.ndimage` on remote Python. Installed verified scipy 1.17.1 in authorized remote Python. Ground successfully generated and source QA checks passed.
- Initial PAR source filenames collided: prior A36C undergrowth renamed `A36F_UNDERSTORY_0xx` clashed with newly added `A36F_UNDERSTORY_0xx`, causing source SHA mismatch. Fixed generated additions to unique `A36F_EXTRA_LAYER_0xx`; deleted ONLY the partial unsealed A36F source asset folder, regenerated 468 verified sources, original A36E unchanged.
- Initial isolated VX generator incorrectly read nonexistent `cases` from A36E engine build QA (KeyError). Fixed to use verified A36D source cases; reset only unsealed A36F VX test clone and regenerated. 11-case real native PASS after fix.

## Visual art still OPEN
- This is a genuine source-based improvement, not the final free-painting/reference `ground3` level. The new A-house stone annex transition and roof outline still need localized artist review; flora clusters may be sparse at 640px zoom despite huge count at full resolution; road edges remain uneven and should be checked at native 1× for excess pixel noise.
- Full tree/actor canopy review (not just 11 representative points), house front/rear door interaction, and all visual art need user signoff. Formal Seal NO.
- Legacy terrain/cliff 1–2-tile obstruction layer remains deferred until original FS triplet/source audit. Do not introduce guessed elevation.
- Next A36G should improve cottage seam, native-source botanical scale and road material transition while preserving the stronger forest and verified engine pipeline.

## Exact reproducible steps
- `a36f_ground.py` generates native ground and path mask from A36E/A34 sources in a fresh A36F worktree only.
- `a36f_par.py` builds 468 independent RGBA sources, PAR and composite from A36E/A34 originals.
- `a36f_build_engines.py` constructs isolated VX and Godot sources.
- `a36f_capture_native.py` records 22 real RGSS Player screenshots.
- `GODOT_A36F_ELF_FOREST_40x29/a36f_godot_native_render.gd` records 6 GPU full + 6 crops.
- `a36f_validate_native_gpu.py` verifies exact GPU source and VX passability.
- `a36f_native_cold_verify.py` clones and reboots native VX with SHA check.
- `a36f_package_private.py` archives source/QA, CRC + member-SHA + independent ZIP extract.
