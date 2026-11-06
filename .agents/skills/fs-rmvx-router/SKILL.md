---
name: fs-rmvx-router
description: Forest Symphony (FS), RPG Maker VX / RGSS2, A36F/A36G layered Ground/PAR, PMD0001-0003, Actor sprite, source-asset and engine-native validation. Route these tasks to FS authority before generic Godot or art workflows.
---

# Forest Symphony | Project-first Agent Skill

## Priority and classification
- **Primary engine: RPG Maker VX (RGSS2)**, grid 32x32. The 544x416 value is a viewport, **not** the total canvas. Godot is a supplementary native rendering/QA adapter, not the authoritative engine.
- If the task mentions FS, Forest Symphony, RMVX, Ground/PAR, A36F/A36G, PMD or ACTOR sprite production, read this skill **before** the upstream generic router and all discipline skills.
- Do not use a nested `project.godot` to reclassify the entire project as Godot.

## Mandatory authority and read sequence
1. Drive SHARED_GAME_ASSET_GENERATION_AUTHORITY (2026-08-24).
2. Drive ASSET_GENERATION_PRECHECK_FS v3.2 (2026-09-21), plus its referenced FS map production/validation/compiler authorities for map work.
3. Repository `AGENTS.md`, `ASSET_GENERATION_PRECHECK.md`, `MAP_DUAL_OUTPUT_AUTHORITY_V2_5.md`, `BACKGROUND_EXECUTION_AUTHORITY.md`.
4. Latest A36F/A36G and/or PMD task-specific handoff, approved style benchmark, Scene Manifest, input assets and SHA.
5. Only then load `create-game-assets` plus task-specific `procedural-gen`, `level-design`, `rpg` or Godot QA skill. **Project authority wins on conflicts.**

## Ground / PAR and A36F
- Canvas for A36F reference = 1280x928; 40x29 cells, 32px. Existing A36F R1 has historical engine **sprite/scene smoke** evidence, **not a verified original Hanzo PAR-switch runtime Gate**, and **art FAIL**; it is not approved visual target. A36G is independent, never overwrite A36F or sealed FS files.
- Single-source production: real semantic Ground (soil, grass, flowers, road, floor, water) and exhaustive **complete PAR = all non-ground objects**, regardless of whether objects occlude an actor. Optional actor-occlusion masks are **derived from complete PAR**, not a substitute.
- Scene Manifest owns placement, source SHA, pivot, collision, footpoint, occlusion regions; compiler produces final registered sibling layers. Never independently generate Ground and PAR, shift or crop siblings, or report a concept image as a playable map.
- A36G art: left house + attached workshop must be a single coherent art asset; forest must be coherent large groups extending outside the canvas rather than hundreds of visibly repeated cutouts; always evaluate house style against right house.
- Apply validation gates Canvas, Manifest, Registration, Recomposition/Visual, Semantics/Collision, VX Engine Import and Godot comparison. Under fail-closed policy, separate engineering QA, **visual/user art acceptance**, native VX verification and Formal Seal.

## Critical runtime correction: FS ground3/par3 vs authoring-layer mode (2026-11-06)
- **Never conflate two output contracts.** Authoring follows FS v3.2: semantic `GROUND_ONLY` + exhaustive `COMPLETE_PAR` from same scene/source masks. The **original FS Hanzo/Overlays runtime** instead uses `RUNTIME_FULL_SCENE_GROUND` (full picture in `Graphics/Parallaxes/ground*.png`) plus `RUNTIME_OCCLUSION_PAR` (a small actor-covering subset in `Overlays/par*.png` that duplicates registered source pixels from runtime Ground). Retain both named artifacts; optional runtime overlay is not a replacement for authoring complete-PAR.
- The runtime `RUNTIME_OCCLUSION_PAR` is derived from **the same master pixels**, 32x32 tile-aware occlusion masks and actor traversal semantics. On opaque runtime overlay pixels, compare RGB against the exact same full-scene Ground pixel; detect holes, mismatches and wrong locations. Model-predicted coverage alone is never proof of human-approved occlusion.
- Original FS `ground3/par3` measured PAR alpha coverage **13.8563%** and opaque RGB agreement **97.5685%**. A36F R1 original export had **64.3505%** / **0.0887%**; A36G R5 **76.509%** / **0.0327%**. These latter pairs recompose mathematically but **FAIL the original FS runtime overlay contract**. The ratios are diagnostic evidence, not universal hard thresholds for every map.
- A36F R2 *conservative* runtime candidate (33.0029% coverage, 100% RGB match) and *broader* candidate (46.4017%, 100%) pass **pixel registration checks only**. Their occlusion masks are heuristic and unapproved art.
- The Hanzo `$game_switches[203]` must actually be ON for runtime `@par` overlay display. Check RGSS native logs/sprite visibility and capture 544x416 actor screenshots **at identical player/camera positions** with switch OFF/ON. A shifted camera, a missing actor in both frames, or a generic Godot sprite smoke = **INVALID TEST**, never PAR PASS. Inspect per-case changed-pixel bounding boxes. Do not count a visible independent object sprite as proof of native Hanzo `@par`.
- Report separate Gates: authoring complete-PAR, runtime full-Ground + derived occlusion-PAR pixel consistency, native switch 203 and actor overlap, collision/traversal, Godot supplementary render, and **human art acceptance**. A36F/A36G historical smoke must not be relabeled as true FS PAR verification.

## Native RGSS2 movement, false positives and exhaustive grid QA (2026-11-07)
- FS loads **ISS - ParaPassa**. `Game_Character#passable?(x,y)` checks a **destination tile** with 2 arguments; `Game_Player#move_passable?(xo,yo,xt,yt)` checks the directed movement using **four** coordinates. Native `move_up/down/left/right` call this directed method. **Never** use the wrong 3-argument `$game_player.passable?(x,y,d)`; V6 did and caused a native RGSS error modal.
- In isolated V7 native `Game.exe` with R2 conservative runtime layers and A36F Map050, 12 sampled real `move_*` calls matched manifest: houses A/B front path/wall, road, forest blocked/free, 4 canopy exits, rear house. Source SHA256 unchanged. Treat this as **sample movement** evidence only.
- A map-wide passability scan that checks the actor's own tile yields a **self-collision false-negative**. V10 first pass showed 1 tile mismatch and 4 incoming edges to `(20,14)`, solely because the actor was still standing on that free spawn tile. For V11, park the **test-only actor** at a manifest-blocked tile `(3,6)` before scanning. Actual RGSS `Game_Player#passable?(x,y)` then matched all **1160/1160** map cells (927 free, 233 blocked); directed `move_passable?` from free origins matched **3576/3576** valid edges. Never move the original game's actor permanently or disable collision to make tests pass.
- **Avoid screenshot false positives:** A moving place-name UI (「米亞」) altered 9819 and 8819 background pixels in V7 OFF/ON pairs despite unchanged camera coordinates. V8 280-frame warmup reduced them to **0** and **5**; another 2 clear-ground controls remained 0. Lock position, verify identical display offsets, wait for UI transitions, compare full RGB diff **bounding box** and the known actor region; reject unrelated pixels.
- V9 sampled four real canopy exit paths with two actual switch203 OFF/ON pairs **before and after** the movement (5-state native screenshots). Changed actor pixels reduced W 625→119, S 368→0, N 627→232, E 454→1; actor moved in each case, source hashes unchanged. North remains **partially occluded**. This is an *engineering dynamic-occlusion* PASS for four sampled paths, **not human visual art approval**.
- Preserve all failed test iterations (V6 wrong arity, V10 self-collision) alongside successful QA; failed test code is not a legitimate map-quality FAIL and must be diagnosed before changing any art or collision metadata.
- Never infer A36G R5, full-game plot events, perfect tree-border visual semantics, Godot matches, PMD gait, or formal sealing from this A36F R2 native benchmark.

## Canonical style and R6 mask fail-closed gate (2026-11-07)
- **Art authority is the actual approved** `FS project/Graphics/Parallaxes/ground3.png` (1280×928 RGB), with original same-source `FS project/Overlays/par3.png` (1280×928 RGBA). **Do NOT** substitute `Overlays/ground3.png` (separate effect layer). R5 generated house material crops / forest group slices are **not** permitted as sole style authority for another generation. Compare to ground3 at native **1× pixel size** before every art promotion.
- The original 4-view, 32px-grid-aligned 544×416 reference kit is `FS_GROUND3_PAR3_REGISTERED_BENCHMARK_V4_20261107`. Views: NW cottage (0,0), central main house (352,192), eastern houses (736,0), western forest/cliff (0,448). Each pair is literal identical-coordinate crop from ground3 + par3 with SHA/Alpha/registration witnesses. Use it as a reproducible **reference**, never claim it's a new map.
- A36G R5 art currently **FAIL** compared to original blue/green finely delineated trees and wood structures; its coherent-thatched-house appearance is not retroactive approval. R5 Authoring GroundOnly/Complete PAR may be retained as historical sources but do not promote derived runtime layers or aesthetic style without new evidence.
- R6 C1 used walkable 32px actor cell coverage + object footpoint to derive occlusion. Even though all 192 source PNG SHA checks, 100% source-pixel registration, and master recomposition passed, **C1 FAIL**: 34.419% occlusion coverage and severe rectangular actor lattice. 81.682% of horizontal mask edge changes landed at x mod32 in {4,28}; original par3 only 4.770%. This metric detects a **specific sampling artifact**, not a universal aesthetic scoring formula.
- R6 C2 smoothed the reachable actor field but preserved hard RGB/alpha. It removed the lattice concentration (7.563% on x mod32 {4,28}) while increasing mask coverage to **52.761%** with broad block-shaped forest regions: **C2 FAIL**. Global `forest_group` depth-slice footpoints do not provide individual tree/roof canopy semantics. Stop relying on global object footpoint + actor rectangles or simply smoothing those rectangles. Preserve the failed candidates; neither was run in VX because required semantic/visual gates failed.
- Repair requires **per-source tree crown, roof and structural semantic masks**, semantic witness points, and user-approved original style first, before exporting runtime OcclusionPar, full-scene Ground and genuine native VX switch203 actor tests. Do not conflate Authoring Complete PAR with Runtime OcclusionPar.
- Before any new PixelLab generation, first demonstrate style continuity and source art scale at 1×. Preserve approved source PNG, original reference and byte hashes. Generative inputs from prior failed generations are not valid canonical style anchors.

## PMD / ACTOR
- Preserve approved original sprite proportions, silhouette, palette, view and naming. Use **source modification** before new unrelated generation.
- Battle-facing view stays fixed at approx. 45 degrees; always inspect foot alternation and baseline, weapon/paper-doll rules, clothing/no-nudity artifacts, real movement (not shoulder-only shake).
- Three export frames per named motion: `<id>_<action>_1.png`, `_2.png`, `_3.png`; preserve existing action spelling and original file conventions. Distinguish LOOP semantics (waiting, critical damage, magic use, moving to close attack) from ordered animations. A three-frame export may sample a four-phase alternating-foot cycle: confirm both sides actually appear before approval.
- PMD monster size is **not** restricted to 32x32; use source XML/Offsets/Shadow and original PMD identity/evolution ancestry.

## Acceptance and handoff
- Every batch: original assets/hash -> edited source -> named frames/layers -> metadata & manifest -> programmatic QA -> comparison/contact sheet -> true VX/Godot native test when claimed -> user art review -> failure log -> current handoff. Gate failure is explicit `FAIL`, `DRAFT` or `UNVERIFIED`, never implied `PASS`.
- Upstream `asset_report.py` checks image facts and `build_preview_sheet.py` makes QA contact sheets; **neither** proves artistic style, collision, in-engine behavior, or original bone motion on its own.
- New scripts/test harnesses must be safe when the application loses foreground focus; use offline tools and write machine-readable logs. Do not create unsafe RGSS threads.
- Work in an isolated pilot or branch; do not delete or modify the A36F original, the PMD sources, sealed runtime, or the accepted reference files.

## Upstream origin
`gamedev-skills/awesome-gamedev-agent-skills`, pinned at commit `19d93f97c9c1ea0f8b306e77aa81e0d3e352d3e9`, Apache-2.0. Full upstream skill folders retain their scripts, references and assets.