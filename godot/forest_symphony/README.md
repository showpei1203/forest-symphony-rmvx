# Forest Symphony | Godot-first A31 (RPG Maker VX migration pilot)

**Godot 4.7.2 stable.** A31 extends the verified A30 collision+Actor A62 baseline with an **opt-in** localized tree-canopy visibility aid. Original A11 Master, A62 approved frames and source PAR remain unchanged. This repository section is the **source-code-only** Godot development project. Download the matching **owner-only Drive A30 ZIP** for the complete privately licensed 1280×928 FS Master, Actor01 A62 Run frames, tree/bridge PAR and real engine screenshots. Do not publish those PNGs to GitHub.

## A30 concrete features

- FullGround is the **original SHA-locked A11 1280×928 Master**, not a downscaled/repainted image; editable same-XY tree/bridge occluders are retained from A28.
- **32×32 native Godot TileMapLayer `CollisionPaint`**: 180 **visual-candidate** blocked tiles across 40×29 cells, with an external, editable 1-tile `TileSet`, actual physics polygon on collision layer 1, and collisions tested against `CharacterBody2D`. Source annotations are in `data/collision_candidate.json` and regeneration logic in `tools/make_a30_collision_candidate.py` + `tools/build_collision_scene.gd`. **Do not import A10 collision JSON: a different Master.**
- **Original A62-approved Actor01 Run 48×48 three-frame replay**, hashes locked and no resampling or new image generation. Native input movement loops `_1,_2,_1,_3` at 8 fps; idle returns to approved F0. This is **battle angle proxy**, not an all-direction town walking cycle.
- **Dynamic same-XY PAR** on each actor, updated on footpoint **or changed animation frame**, so animation cannot leave a stale foreground mask. Not an inferred 3D depth reconstruction; 1x ART is still HOLD.
- Camera2D, native Godot CharacterBody2D, editor-visible red collision debug tiles, view toggle at runtime, editable source occluder depth.

## A31 experimental art candidate (NOT ART APPROVED)

- Tree-only canopy alpha in the actor-sized foreground clip can be adjusted with `assisted_tree_alpha` (Inspector; initial 0.35). By default the assistance is OFF, reproducing A30 pixel-for-pixel. Toggle at runtime with `H`.
- This is **not** a replacement for the real original tree or the unchanged 1280x928 Ground. PAR source pixel **RGB** stays the same; only selected **runtime overlay alpha** over the actor changes. Bridge/roof/cliff source remains fully opaque.
- Actual Godot native 4-way 100/65/35/20-percent canopy comparisons, private-source regression and QA reports are in owner-only Drive R3 ZIP. One 45-degree battle Actor01 is still a stylistic mismatch to the high-detail A11 scene. Tree-head artifact is mitigated but may remain visually awkward. USER ART HOLD.
- A31 test entrypoints: `res://tests/test_a31_canopy_public.gd` (133 source-only checks) and `res://tests/test_a31_canopy_real.gd` (4,627 checks with private source), both actually run under Godot 4.7.2. A30 real 221 checks PASS; A30 public 389 checks PASS on unchanged collision and animation contracts.

## Controls

WASD / arrows = move; Shift = faster; `G` = 32px world grid; `C` = collision debug red candidate cells; `O` = toggle per-actor PAR; `R` = toggle A62 **battle-run preview** when moving; `H` = toggle experimental canopy assistance (tree-only, OFF initially). Editing `CollisionPaint` tiles in Godot updates the collision layer directly, which is the primary advantage over the old VX approach.

## QA status and reproducible tests

- **Real private assets, native Godot 4.7.2**: `res://tests/test_a30_real_runtime.gd` **221/221 checks PASS**, including 180 source-locked candidate tile cells, four A27 footpoint occlusion counts **197/0/29/0**, actual Godot physics contact with a painted pond tile, three A62 run frames playing and idle return, camera following, overlay changing with frame. Real 544×416 Godot OpenGL framebuffer captures under `qa/`, plus GIF assembled **only from 12 real Godot frames**.
- **Public checkout without private original PNGs**: `res://tests/test_a30_public_contract.gd` **389/389 checks PASS**, Godot 4.7.2 editor import no errors, correct physics shape and external TileSet, 180 blocked candidate cells, 980 candidate free cells connected in 4-neighbor graph. **Connectivity is not proof all 980 are truly safe to walk.**
- **Not approved**: manual visual candidate collision geometry; whole-scene art, floating-head tree occlusion, top-down town walking angles, Windows EXE, full navigation, doors, dialogues, save, battle and user Art Gate. The 180 tiles exclude a lot of unvalidated blocked terrain; this is a map-editing **pilot**, not a complete collision solution.

## Pipeline and safety

On GitHub keep **only source code, A30 collision candidate coordinates and procedurally drawn 32px debug atlas**. Private A11 Master, A18/A62 PNGs, A28 PAR, screenshot PNG/GIF and ZIP stay owner-only Drive. Isolated build/test, no user PC writes, no paid calls, no changes to old VX or `main`. Formal seal NO. Details: [`docs/A30_HANDOFF.md`](docs/A30_HANDOFF.md).
