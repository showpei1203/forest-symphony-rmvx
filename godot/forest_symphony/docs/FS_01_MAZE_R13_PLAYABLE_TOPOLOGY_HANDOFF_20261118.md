# Forest Symphony｜FS_01_MAZE 幽葉迴廊 R13 正式 Handoff

**2026-11-18 · Godot 4.7.2 only · PLAYER/NAV/BRIDGE/NORTH-EXIT/GPU PASS · ART HOLD · ACTUAL CROSS-SCENE TRANSITION HOLD**

## R12 immutable authority
Private R12 full Godot source: [Drive R12 241-file ZIP](https://drive.google.com/file/d/1VikZtZc0YWhHFNMjylNGXFEbN2_oW6qR/view), 113,804,051 bytes, SHA256 `cf1d01ca564eaba05d7ff900314ae82b385dfab7a74b7d5010f5004e5aa21106`. Original R12 scene SHA256 `54224083a741bf4d451c9d44674d48fae68e399eac856c31b31c15c10457c392`; Ground SHA256 `ac591877b05c00543e6756e44e6ba81f6fea7e36086049e35de81e2610e0c911`. New R13 PackedScene SHA256 `569d0591dc5eac581f11a227aecc0e3ffd9503b1baefeaf94dd50fd023c23e88`. Preserve original Ground, Shadow, 326 independent PAR, 310 trees and 148 original water collision tiles. Never overwrite the original R12 R8, village, combat or A36C branches.

## Substantive authored Godot gameplay
- Reproducible `tools/fs_01_maze_r13_scene_build.py` creates `scenes/fs_01_maze_r13_playable_entrance_bridge_exit_80x58.tscn` from private canonical R12. Original PAR nodes and artworks remain byte-identical. R13 ZIP alone sets `run/main_scene` to this new scene.
- `scripts/fs_01_maze_r13_topology.gd`: actual entrance Marker2D cell (39,55), exit Marker2D (49,5), original painted bridge from (6,29) to (14,29). Bridge 9/9 cells and continuous real Player 13x9-foot sweeps are physically open, without removing a water collider. Actual exit interaction emits `exit_requested("FS_01_VILLAGE","maze_north_return")`.
- `scripts/fs_01_maze_r13_walkable_player.gd`: actual CharacterBody2D move_and_slide, keyboard input, left-click road-weighted R12 runtime AStar travel, route cancellation, and physical original stone-earth river crossing.
- `tests/test_fs_01_maze_r13_playable_native.gd` independently loaded real R13 Godot PackedScene and performed south entrance → north exit continuous Player movement, real exit interaction, and west/east bridge player crossing; emits exactly one bridge event. Official Windows Godot 4.7.2 `Exit Code 0` after first failed event-timing test was fixed and rerun.
- Source SHA/physical baseline: 4,640 original R12 player-foot grid cells, 4,129 walkable, 511 blocked, 148 actual water collision rectangles; 3/3 static route connectivity, 9/9 original bridge grid; separate actual R13 native physics PASS.

## Original Godot native GPU evidence
Non-headless official Godot 4.7.2 Compatibility OpenGL 3.3, AMD Radeon RX 6700 XT, **four actual 2560 × 1856 1x GPU frames**: actor-hidden R12 control, actor-hidden R13 control, bridge/player, north-exit/player. Pixel-exact comparison of R12/R13 with actor hidden: **4,751,360 identical pixels, 0 changes**. See private `FS_01_MAZE_R13_NATIVE_GPU_EVIDENCE_PRIVATE_20261118.zip` (37,438,022 bytes, SHA256 `4c36e29289177c680517cace7872daaf4bfb7ad06ae9265e7669e7d7ea307cec`) and embedded 5-file manifest after Drive metadata verifies the cloud link. The first headless capture hung waiting for framebuffer post_draw; native GPU non-headless rerun completed with Exit 0.

## Honest HOLD and next stage
**ART HOLD**: Current Ground3, river appearance, foliage/silhouette repeats, HD-2D art still unapproved. **WORLD TRANSFER HOLD**: R13 emits a valid destination ID/spawn contract but does NOT yet instantiate the separate FS_01_VILLAGE map, reciprocal return marker, persistent world state, quest events or save/load cross-map state. Do not label the twelve maps done; the ten nonforest maps are still planned. Next wire real destination/return and save/load using the main Godot world registry, then independent Ground3 original native A/B; advance both FS_02_MAZE「冰脊迷谷」and FS_02_VILLAGE「霜燈聚落」.

Related: [R13 Failure Log](FS_01_MAZE_R13_PLAYABLE_FAILURE_LOG_20261118.md), [CURRENT_HANDOFF](../CURRENT_HANDOFF.md). Preserve **Godot only**, 32×32 native grid, per-stage native QA + private Drive full source/CRC/SHA + public GitHub Handoff.
