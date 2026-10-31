# Stage16 A25 — Native PixelLab Ground 544×416 + FS Transparent PAR (2026-11-01)

**Status: PixelLab full original image 544×416 PASS. Actual Godot 4.7.2 four-scene native renderer PASS. Ground3 visual quality FAIL. Full tree occlusion NOT TESTED. Native VX NOT RUN. Formal Seal NO.**

## Authoritative continuity
- A24 baseline: `STAGE16_A24_HANDOFF_20261101.md` (original reconstructed FS material + existing FS transparent PAR; Godot four-case renderer PASS).
- A25 objective: PixelLab creates **original Ground**, assistant uses real FS artwork for independent transparent PAR, followed by engine/occlusion/passability verification.
- The original FS game/project and sealed builds remain untouched. A25 isolated Windows directory: `E:\FS_ROUTE_B_STAGE16_A25_PIXELLAB_FULL_GROUND_20261101`.
- No private original FS pixels or generated private images are committed to this public GitHub repository.

## Actual verified provider operation
- Official OpenAPI v2 queried read-only, confirmed `create-image-pixen` requires each axis multiple of 4, max canvas area 512×512; `generate-image-v2` supports aspect-dependent non-square output. `generate-with-style-v2` infers a square output from its style reference, so it is inappropriate for exact 544×416 here.
- Account observed on 2026-11-01: **Tier 1 Pixel Apprentice**, active, **1,958 generations** before.
- Exactly **one accepted PixelLab Pro POST**: `/v2/generate-image-v2`, size 544×416, seed 162501, `no_background:false`.
- Style source: original FS ground-only grass 96×96; two guidance refs: pure FS sand 128×128 and ground-level flora 64×64 (A21 clean source references). Source file hashes are saved locally in the state receipt.
- Model returned **authentic PNG native resolution 544×416** without resizing.
- Original output: `A25_PIXELLAB_PRO_ORIGINAL_GROUND_544x416.png`; SHA256 `aea3c4d2454b92a342c4670563b390b2dc36959ed112a92bfc24b6f1564f014c`, 71,679 bytes.
- Account balance after: **1,933 generations**, actual expense **25 generations**, USD credits 0. One-POST no-retry guard retained in `a25_one_pro_full_ground.py` and `A25_SINGLE_PRO_JOB_STATE.json`.
- Real model output, not texture quilting, synthetic collage, or an upscaled/downscaled image.

## PAR composition and visual assessment
- `A25_PAR_REUSED_FROM_A24_RGBA_544x416.png` is a copy of A24's verified original FS transparent PAR at identical canvas coordinates; not newly hallucinated props.
- `A25_GROUND_PAR_COMPOSITE_544x416.png` was created by alpha composition of original A25 ground with original A24 PAR.
- Observed: one organic continuous beige sandy path and green meadow. No obvious rectangular tiling boundaries in Ground; no houses/trunks/trees in Ground. Some flowers visually large. Grass is materially flatter and less richly varied than original Ground3. PAR forest edge texture and new AI grass differ visibly.
- Therefore **native provider image format PASS; Ground3 artistic richness FAIL**. Do not call this production-ready.

## Gates and next work
| Gate | Result |
| --- | --- |
| Real PixelLab native Ground 544×416 | **PASS** |
| Provider balance, cost and one-charge audit | **PASS, 25 generations** |
| Transparent FS PAR same-canvas composite | **PASS** |
| Original full tree canopy and body passability | **NOT TESTED** |
| Godot A25 native 4-screen rendering with placeholder actor and FS lamp y-sort | **PASS** |
| RPG Maker VX Game.exe ground/PAR/passability | **NOT RUN** |
| Full FS Ground3 aesthetic quality | **FAIL** |
| Formal Seal | **NO** |

**Fail-closed policy:** do not relabel A24 Godot screen output as A25. A25 requires separately validated actual 4 native engine screenshots and source/image checks. Preserve the raw PixelLab original and the A24 PAR hashes; no further charged model submissions unless explicitly budgeted. Next art pass should increase fine meadow texture density, smaller flowers, and better style cohesion, not simply increase resolution.

## Portable paths
- `a25_readonly_preflight.py` / `A25_READONLY_CAPABILITY_AND_BALANCE.json`
- `a25_one_pro_full_ground.py` / `A25_SINGLE_PRO_JOB_STATE.json`
- `a25_compose_and_run_godot.py` (isolated scene and QA script, **verified actual GL render**; inspect `A25_RENDER_QA.json`)
- `GODOT_A25_ISOLATED_NATIVE_RENDER` (actual A25 native screenshot names begin with `A25_GODOT_`; A24 copies do **not** count)

## A25 real-engine QA: completed
- An initial run used Godot `--headless` and timed out after 95 seconds, generating **no** new A25 native renderer proof. This was an **execution-mode failure**; do not erase from failure record. Corrected by removing `--headless` and explicitly using `--rendering-method gl_compatibility` with Windows' actual Godot 4.7.2 console executable.
- Successful rerun: `A25_NATIVE_GROUND_PLUS_REAL_GODOT_RENDER_PASS`.
- Real source: A25 PixelLab original 544×416 PNG; original A24 private FS real transparent PAR/individual FS source props; 10 source-bound sprite objects; no fake tree test.
- Four **new** real Godot screenshots (not copied from A24): `A25_GODOT_NATIVE_SCENE_NO_ACTOR.png`, `A25_GODOT_ACTOR_BEHIND_LAMP.png`, `A25_GODOT_ACTOR_IN_FRONT_OF_LAMP.png`, `A25_GODOT_ACTOR_ON_ROAD.png`. Combined private preview: `A25_ACTUAL_GODOT_4PANEL_SCREENSHOTS.png`.
- Independent Pillow composite vs actual Godot screenshot: 689 differing RGB pixels / 226,304 (0.304458%); mean absolute RGB error 0.001095871 / 255, **not** a misleading claim of 0 differences.
- Grid-model collision: 17×13=221 tiles; 34 blocked via real FS PAR object footprints; 187 walkable; BFS from diagnostic actor reaches all 187. Ground is passable by default. This does **not** prove native VX passage logic.
- Stand-in actor and lamp front/back two Y-sort situations were visibly present in actual snapshots. Full FS `$ACTOR01` and complete tree crown-vs-trunk collision/occlusion are not exercised.
- Real native output pixel crisp and no rescaling. Overall full Ground3 aesthetic still **FAIL**, Formal Seal **NO**.

## A25 prevention and next required gates
1. Engine test must not use `--headless` for GPU viewport proof; require new stage-prefixed screenshot outputs.
2. Never call a provisional collision BFS model a native RPG Maker VX test.
3. Preserve generated Ground raw SHA and original FS component source hashes.
4. Next unpaid art iteration: diagnose/reference microscopic grass and flower scale and how to make the new model Ground less flat. Do not burn more provider generations automatically.
5. Next engineering iteration: real FS tree crown+trunk canopy occlusion, dynamic character footpoint, native VX runtime collision and 32px PAR tile masking.
