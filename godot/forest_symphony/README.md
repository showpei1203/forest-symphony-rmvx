# Forest Symphony A32 | Ground-first, independent complete PAR (GODOT)

**FS Active Master v1.3 (2026-11-14) supersedes Master-first**. A32 begins a new high-quality scene asset lane without rewriting old A31 baselines. Godot 4.7.2 stable primary map engine.

## What is real (not a conceptual scene)
- `scenes/a32_groundfirst_scene.tscn` is the runnable/main Godot PackedScene; 146 separate inspector-editable source-owned PAR nodes (134 tree, 2 house, 10 props), native `Node2D.y_sort_enabled`, individual collision roots.
- `private_assets/ground_only.png` is NEW 1280x928 full-detailed Ground without tall objects; **not extracted from flattened Master**. Source is a generated 1536x1024 Ground-only image, 1:1 center cropped without resampling.
- `private_assets/independent_par/*.png`: 27 *complete* independent source sprites derived from original A36F and FS v2.3.3 **separate RGBA source files** (not from flattened scene). SHA, original filename, attribution and size in `data/a32_groundfirst_manifest.json`. Every copy used at its source pixel scale, optional transparent padding only. Private files are **not on public GitHub**.
- `scripts/a32_world.gd`, `scripts/a32_par_instance.gd`, `scripts/a32_player.gd`: source-locked loading, editor render, no canopy-sized blocking, native footpoint collision and dynamic YSort.
- `tests/test_a32_groundfirst_real.gd`: Godot 4.7.2 native real-art **734 PASS**; actual tree-foot physics; screenshots under `qa/`. Public `tests/test_a32_public_contract.gd` contains no owner art.

## Open the owner-only project
Open `project.godot` in Godot **4.7.2**, press F6 in the open new A32 scene or F5 to play. WASD/arrows move the original 48px F0 actor proxy; G toggles 32px grid. **This is not a completed 4-way overworld animation.** Select any object under `YSort/obj_*` to change its footpoint position. Visual source path/SHA and footprint are exported per object.

GitHub checkout alone is source-only and intentionally **cannot render** owner-only art; download the matching private Drive project R4 for playable real-source scene. Never push private PNGs, screenshots or source ZIP to public GitHub.

## Art & production gate
**ART HOLD.** Dense floral Ground is improved; existing moss cottages and mixed tree palettes remain out of parity with finished Ground3 benchmark. **COLLISION HOLD**: tree/building body shapes only, no fully signed-off 40x29 walkable cells. **FORMAL SEAL NO**, no sound, event, Windows export or complete battle port claimed. See `docs/A32_GROUND_FIRST_HANDOFF.md`.

### Complete A32 private R4 + native proof

- [Owner-only complete Godot A32 ZIP](https://drive.google.com/file/d/10oUrfTbgohCHuCq0GO36vyQ3kCABIlBc/view) (47,995,335 bytes; SHA256 `28a52f2a901f8ea4ca2bcffe53646dcafe619a3d6ef365b6152efcc77b36b544`; 228 ZIP entries; download/CRC PASS).
- [True Godot 4.7.2 native whole-scene preview](https://drive.google.com/file/d/1YVEJozXA_4GyLO1T1647CvJFJAi9YXyg/view).
- [Ground only, standalone transparent PAR, and final composite 3-way](https://drive.google.com/file/d/1mV1P1M0gn8CHFvuVrFEdDdbGtUQjACop/view).
- [Detailed A32 Failure Log on Drive](https://drive.google.com/file/d/1-Cfnv_7QuVgShWZaLQftfrz-fADRIW3x/view).
