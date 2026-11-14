# FS Tool Registry | GDQuest Make Pro 2D Games | 2026-11-10

**Classification:** Godot auxiliary scene/animation QA architectural reference.
**Status:** ADOPTED_AS_REFERENCE; NOT_INTEGRATED. Priority: medium. Does NOT supersede FS ACTIVE MASTER or A19 Handoff.

## Upstream evidence
- Repository: https://github.com/gdquest-demos/godot-make-pro-2d-games
- Official README: https://github.com/gdquest-demos/godot-make-pro-2d-games/blob/master/README.md
- Upstream description: full A-RPG demonstration, Godot 3.1, source MIT licensed (repo metadata and README). Last push shown: 2021-04-26. No source or art code copied.
- Confirm license notices and asset-specific rights again if snippets/assets are actually copied later.

## Investigated files and FS-specific relevance
1. [StateMachine.gd](https://github.com/gdquest-demos/godot-make-pro-2d-games/blob/master/utils/state/StateMachine.gd): enter/exit/update and animation_finished states. Candidate for separate Godot 4 *QA playback viewer*, NOT an animation generation model. T1 should preview approved FS Actor 48px frames (run loop 0,1,0,2) and native PMD AnimData.xml actions without conflating the two contracts.
2. [LevelLoader.gd](https://github.com/gdquest-demos/godot-make-pro-2d-games/blob/master/core/LevelLoader.gd): scene swap keeps Player and initializes maps/monsters. Candidate T2 independent layered-map QA runner. YSort is not a semantic PAR splitter.
3. [Grasslands.tscn](https://github.com/gdquest-demos/godot-make-pro-2d-games/blob/master/levels/Grasslands.tscn): Godot 3 TileMap cell_size=128x128, NOT FS 32x32 tile contract.
4. [SaveAndLoad.gd](https://github.com/gdquest-demos/godot-make-pro-2d-games/blob/master/core/save/SaveAndLoad.gd): tree save-group JSON round-trip reference for later QA sandbox only, NOT RMVX main save replacement.
5. [Actor.gd](https://github.com/gdquest-demos/godot-make-pro-2d-games/blob/master/actors/Actor.gd) and [DamageSource.gd](https://github.com/gdquest-demos/godot-make-pro-2d-games/blob/master/actors/DamageSource.gd): Actor movement/health/hitbox patterns for later isolated combat simulation; cannot replace RGSS2 Tankentai SBS+ATB.

## API migration guard
Godot 3.1 KinematicBody2D, YSort node, PackedScene.instance() and yield must be adapted and tested on Godot 4 (e.g. CharacterBody2D, Node2D.y_sort_enabled, instantiate, await). Do not assume compatibility or retroactively label native FS VX PASS.

## Proposed validation, not performed
- T1: A62 verified F0/run source only; separate actor _1/_2/_3 vs PMD action XML contracts; 1x preview plus source SHA, alpha, limb alternation, true direction/pose.
- T2: approved complete Master -> same-pixel RuntimeFullGround + OcclusionPAR and 32px collision footpoint QA. Test actor in front/behind object, negative occlusion, scene transitions and deterministic screenshot.
- Gate each result separately: provenance; Godot4 rendering; semantic / visual; native Game.exe / Switch203; user ART. Duplicate error -> fix adapter or model, not tweak approved pixels.
- No paid PixelLab action. A19 requires explicit one-shot authorization and tool permission.

## Adoption QA as of 2026-11-10
UPSTREAM_READ: PASS; LICENSE_METADATA: PASS; GITHUB_REFERENCE_RECORD: pending readback; GODOT4_PORT: NOT_STARTED; T1/T2: NOT_RUN; ART: NOT_RUN; NATIVE_VX: NOT_RUN; NEW_ASSETS: ZERO; FORMAL_SEAL: NO; FS MAIN/SEALED: UNCHANGED.
Read ACTIVE MASTER and docs/asset_factory/CURRENT_HANDOFF.md before any execution. Documentation is not evidence of game engine operation.
