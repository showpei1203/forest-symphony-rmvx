# Forest Symphony｜FS_01_MAZE 幽葉迴廊 R14｜美術專責 Handoff

Date: 2026-11-18 | Godot 4.7.2 ONLY | ART HOLD | Static art/source QA PASS | Godot native GPU NOT RUN

## One-line mission
Only create 12 final *visually approved* Ground/PAR maps across the canonical six biomes. Do not use this map-art workstream for teleport, save-load, event editor, NPC/ATB/other gameplay.

## Base and no-overwrite
- Base: R13 full owner-only project `FS_01_MAZE_R13_PLAYABLE_FULL_GODOT_PRIVATE_20261118.zip` with original scene `res://scenes/fs_01_maze_r13_playable_entrance_bridge_exit_80x58.tscn`.
- R13 scene SHA256 `569d0591dc5eac581f11a227aecc0e3ffd9503b1baefeaf94dd50fd023c23e88` retained; old scene and original ground stay unchanged.
- Original floor `res://private_assets/a36_ground_only_2560x1856.png` SHA `ac591877b05c00543e6756e44e6ba81f6fea7e36086049e35de81e2610e0c911` retained.
- Original single-image source `a36_ground_original_1478x1064.png` retained.
- Two NEW *separate* R14 candidate Godot scenes, non-destructive:
  1. `res://scenes/fs_01_maze_r14_canopy_ecology_80x58.tscn`: whole-source PAR foliage/silhouette only, Ground original.
  2. `res://scenes/fs_01_maze_r14_ground3_canopy_80x58.tscn`: original Ground3 clarity candidate + PAR foliage changes.
- `scripts/a36b_world_r14_ground3.gd` changes ONLY the Ground image path and expected SHA; Shadow untouched. R13 runtime components remain base references.

## Real art modifications (not plans)
1. New `private_assets/a36_ground3_r14_2560x1856.png` re-renders original single authored continuous Ground via 65% Lanczos + 35% original native-nearest weighting, then controlled high-frequency enhancement. Original ground untouched. Ground3 differs on 4,597,036 pixels. This CANNOT create true native 32px source detail from missing 1478×1064 texture; do not market it as genuine native-resolution pixel art or approved final.
2. Create **16 independently saved full transparent tree sprites** from original whole source oak/birch/willow/pine; subtle crown palette ecology and four oak crown silhouette variants, no object crops from finished map.
3. 225 tree instances selected for variant source PNG; 122 tree instances mirrored about their original object pivot for silhouette variety. Existing source source_sha256 updated per object. Tree feet/positions/footprint/collision block source text remain untouched. R13 retained.
4. Full-source tree count 310 and total independent PAR object count 326 unchanged. No gameplay/transfer/save-load code authored in R14.

## Evidence and QA boundaries
- Static source, alpha/full-PAR, SHA, object scene-diff, original Ground non-mutation PASS: `data/fs_01_maze_r14_art_qa.json`.
- Rendered **CPU approximation only** comparing original vs candidate: `qa_art_r14/FS_R13_R14_ArtAB_CPU_NOT_NATIVE.png`. It is NOT a Godot framebuffer screenshot; no native Godot art/GPU seal claimed.
- The R13 player/road/water functionality was previously verified but **R14 native Godot cold rebuild/actor physics/GPU pending**, because Desktop Commander Remote reported offline while authoring. Must rerun native scene and original 1x screenshot on reconnect.
- **ART HOLD**: visual repetition mitigated but not author-approved; original background 1478×1064 enlarged, river static, trees still have shared source architecture, upper conifer silhouette/houses/forest clearing coherence and riverbank art still pending. This is an additive *candidate*, not the final aesthetic goal.

## Next actions (art only)
1. Native Godot 4.7.2 cold import, independent R14 scene full-map GPU 1x screenshots and camera-scale passes, R13/R14 ROI pixel A/B, root/canopy cropping and road/river 4-way review. On any import or alpha/source error, do not mark PASS.
2. Make *material* whole-scene improvements to forest silhouettes, naturally nonrepeating groves, clearings/path edges, riverbank/water visual coherence; preserve Ground/PAR separation and independent objects. Obtain ART acceptance.
3. Then apply the same coherent art pipeline to the currently ART-HOLD village FS_01_VILLAGE 苔光村 (house stylistic unity required) and proceed to FS_02_MAZE 冰脊迷谷 / FS_02_VILLAGE 霜燈聚落; ultimate target 12 ART-sealed maps.
4. Every art stage: original input + independent Ground/PAR + native frame/screenshots + 1x crop review + source integrity + Failure Log/Handoff; Drive owner-only art binaries, GitHub only scripts/text/docs. No local permanent source as authoritative.
