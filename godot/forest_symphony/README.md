# Forest Symphony A34 | Godot Ground-first + full independent house family

**Use Godot 4.7.2 stable.** Active project `res://scenes/a34_groundfirst_full_houses_scene.tscn`.

- Main A32 Ground-only source 1280×928, SHA locked. No flattened full-scene slicing.
- 2 full transparent house sprites, original standalone generated transparent RGBA source preserved in private assets, 146 edit-ready Godot PAR nodes (27 families), 4 independent A33 lanterns, YSort, 140 legacy collision candidates.
- Real native tests: `res://tests/test_a34_full_houses_real.gd` (**1036 checks**), previous A33 (**760**) and A32 (**734**) native regression, plus 4 native OpenGL framebuffers and `qa_a34/A34_NATIVE_HOUSE_AB_1X.png`.
- Public CI only code/scene/provenance manifest; source-only `res://tests/test_a34_public_contract.gd` (**744 checks**). Private art only in owner-only Drive ZIP.
- New house art still USER ART HOLD; doorway geometry, building entrance event and 4-direction character animation NOT_RUN. We do not mark it final map.

Open [`CURRENT_HANDOFF.md`](CURRENT_HANDOFF.md) and [`A34 Failure Log`](docs/A34_INDEPENDENT_COMPLETE_HOUSES_HANDOFF.md) before future work.

## A35: independent tree families + six-biome art contract (2026-11-14)

Godot main scene: `scenes/a35_independent_tree_family_scene.tscn`; original A34 scene is kept. A35 uses **two original transparent art sheets containing four separately isolated, COMPLETE tree sprites**, preserving the original art sheet copies privately. **No sprites extracted from flattened map / Master**. Only eight tree references are changed, all footpoints and collision footprints remain; houses, lamps, and Ground SHA are immutable.

Native Godot 4.7.2 privately sourced checks: 1063 PASS, two full 1280x928 true native A/B frames and two new-tree actor depth frames. Source-only GitHub smoke: `tests/test_a35_public_contract.gd` (788 checks), data only not private bitmaps. Independent `tools/a35_build_independent_tree_family.py` supports `--base --dest --pair1 --pair2` reproducible building. Native real sources only in owner-only Google Drive.

For **six future terrain families** (each maze+village, 12 map artwork goals), see `docs/FS_SIX_BIOMES_WORLD_ART_PLAN_20261114.md` and `data/fs_six_biomes_world_catalog.json` (Python validator `tools/validate_world_biomes.py`). First scale target A36 is 2560x1856, 80x58 at 32px, **not yet authored as new art**. No repeated A34 Ground quilting. This conversation owns art and map visuals only; events, NPC and combat belong to other conversation. All A35 art remains **USER_ART_HOLD**.
