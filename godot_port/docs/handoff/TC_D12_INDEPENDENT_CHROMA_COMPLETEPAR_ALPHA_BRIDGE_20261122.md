# Forest Symphony | T-C D12 | Independent Chroma Plate -> TRUE Alpha CompletePAR engineering bridge

**Date:** 2026-11-22 Asia/Taipei
**Branch:** `feat/fs-tc-d12-chroma-par-20261122` branched from `feat/fs-pixellab-tc-map-20261121`
**Engine target:** Godot 4.7.2, NOT_RUN for D12
**Authority:** T-C D11 Ground-first Handoff, twelve-map SOP, FS_04_VILLAGE Ground SHA lock

## 1. Concrete production blockage and what D12 changes

D11 preserved an authentic basalt-lava Ground candidate for `FS_04_VILLAGE`, 1280x928 (40x29 @32), SHA256
`ebc6b0f5ad5e5a853e4a470c77c7a2e080609add78d44eb705bc7b51d021fc8d`.
The prior image generator returned an opaque full town, not an independent transparent PAR.
The final sixth attempt also had **zero alpha=0 pixels**; its original result is separately recorded in `PIXELLAB_TC_CURRENT_HANDOFF.md`, not the earlier five-failure private D11 ZIP.

D12 introduces a deterministic alpha bridge for a ***future independently authored foreground-only plate***, not another image-model transparency prompt:

1. Author one entire PAR composition, including ALL non-ground objects, on a clean constant chroma RGB canvas. This must NOT depict the town Ground, roads, lava floor, or a complete Master. The plate itself is a separately generated/painted original, with objects placed at locked Ground XY and all object families generated as a single scene.
2. Set the plate canvas **exactly 1280x928 pixels**, reference the locked Ground as artistic and positional reference but do not paint it in the PAR plate. A visual/world-XY proof will still be required.
3. Use chroma `#00FF00` in the volcano scene, absent from all object silhouettes. Corners must have exact chroma, and at least 25% of the image should be chroma background. Fully occupied Masters are rejected.
4. Program `fs_complete_par_from_chroma_plate.py` only converts chroma pixels to transparent alpha=0, and preserves other pixels at alpha=255. It never uses image segmentation, Ground subtraction, inferred occlusion, or object-by-object reverse extraction.
5. Inspect the raw independently-authored plate, resulting PAR, side-by-side Ground and preview. **Never infer art acceptance from successful alpha conversion.**

This workaround is intended ONLY for genuine independently created all-non-ground plates. Chroma extraction from a finished city Master is expressly prohibited. Green chroma touching legitimate green subjects is a visual rejection; change chroma key and regenerate the foreground plate rather than deleting the subject.

## 2. Actual repo files committed

- `godot_port/tc_factory/biomes/fs_complete_par_from_chroma_plate.py`: SHA lock, exact canvas & grid, flat chroma/corner coverage, rejects full opaque Master/empty plate, generates true RGBA PAR, preview, evidence JSON, preserves original inputs
- `godot_port/tc_factory/biomes/test_fs_complete_par_from_chroma_plate.py`: synthetic foreground-only multi-object plate, verifies true alpha=0, unchanged Ground, pixel details, corner, full-Master, empty, wrong XY, lock mismatch and native RGBA handling
- `.github/workflows/fs-tc-d12-chroma-par.yml`: CI using Pillow==12.0.0; full synthetic tests

**CI:** [FS T-C D12 #44995939096](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44995939096) completed SUCCESS. This is only synthetic tool validation, NOT art or Godot native QA.

## 3. Command for genuine next plate

```bash
python3 godot_port/tc_factory/biomes/fs_complete_par_from_chroma_plate.py \
  --ground FS_04_VILLAGE_GROUND_1280x928.png \
  --plate FS_04_VILLAGE_INDEPENDENT_ALL_NON_GROUND_CHROMA_1280x928.png \
  --out D12_VOLCANO_PAR_QA \
  --scene-id FS_04_VILLAGE \
  --ground-sha256 ebc6b0f5ad5e5a853e4a470c77c7a2e080609add78d44eb705bc7b51d021fc8d \
  --chroma 00FF00
```

Outputs: `PAR_ALL_NON_GROUND_CHROMA_CONVERTED.png`, `GROUND_PLUS_PAR_PREVIEW_ONLY.png`, `CHROMA_PAR_QA.json`.

Run existing `fs_validate_ground_complete_par.py` on the real locked Ground and the new PAR only after actual foreground-only plate exists. Chroma contract success does not prove real foreground generation, building ground contacts, correct bridge-to-road attachment, smoke and light style, or every object family represented.

## 4. Honest scene status at the end of D12

| Contract | Status |
|---|---|
| Original FS_04_VILLAGE Ground 40x29, locked SHA | PRESERVED; existing D11 candidate |
| New independent all-non-ground foreground chroma plate | **NOT_GENERATED** |
| New real source CompletePAR | **NOT_GENERATED** |
| Deterministic foreground chroma-to-true-alpha script | **IMPLEMENTED** |
| D12 synthetic CI | **PASS** |
| True Ground + newly authored PAR composition | **NOT_RUN** |
| Godot 4.7.2 native scene QA | **NOT_RUN** |
| Formal twelve-map art count | **0 / 12; HOLD** |
| New private art assets uploaded to Drive | **NONE; no actual new scene art to upload** |

## 5. Handoff / next complete art unit

Produce the whole **FS_04_VILLAGE independent all-non-ground chroma foreground scene** in one cohesive visual generation, on the flat chroma background, respecting the locked Ground's roads, square and lava gaps. This is NOT a call to tweak individual props. Required families: forge houses, tavern, smelters, chimneys, iron bridges and railings, basalt pillars, cranes, carts, posts, banners, lanterns and crates. No Ground visible in plate. After true plate exists, use this converter, the existing image QA, 1x Godot 4.7.2 renderer and visual ART Gate. Upload private original plate, raw PAR, preview, QA/Handoff to owner-only Drive; update main T-C Handoff, production queue and Linear SHO-39 only when actual status changes.

D12 is deliberately an isolated feature branch/draft PR candidate so it cannot overwrite another concurrent T-C agent's main work. No asset, Godot PASS, or ART PASS claim is made.
