# Forest Symphony Stage16 A24 — 544×416 Ground / Transparent PAR / Real Godot Renderer
Date: 2026-11-01. **Engineering isolated benchmark rendered in real Godot 4.7.2; visual full Ground3 art FAIL; native VX NOT RUN; Formal Seal NO.**

## New division of responsibilities: future PixelLab Ground, assistant-managed PAR

User suggests using PixelLab to generate **Ground** later, while the assistant builds **PAR**. The proposal is correct *as a separate testable workflow*:
- GROUND owner: PixelLab original pixel-art native image at target map dimensions (544×416 or exact tile-native scene if the provider cannot deliver that canvas). Contains only traversable soil, paths, grass and ground flowers; exceptions such as water / chasms are explicitly semantic nonwalkable. This exact provider output was **NOT RUN** in A24. No new PixelLab request, and the last confirmed subscription balance remains 1,970 generations.
- PAR owner: assistant assembles or accurately extracts transparent **tree crowns, trunks, buildings, props, cliffs, fences** from approved FS visual sources or explicitly consistent generated assets, with source manifests, transform matrices, alpha integrity, actor-front/back depth, and 32px collision footprint data. Notably, PAR has to match map coordinates; a separately generated full scene with independent layout will fail alignment. Every object is tracked in a scene manifest.
- Default ground passability is unrestricted except explicit terrain hazards; PAR object base/footprint blocks selected 32×32 tiles; top canopy may hide actors without blocking the entire visual footprint. For objects painted inside Ground, PAR must overlay the *identical pixels* from the same scene, not reinterpret or shift them. Prefer ground-only source image, no upright things.
- Fail closed on size mismatch, visible cutouts, image smoothing, broken edges, and alpha compositing failures. Preserve previous sealed FS production assets untouched.

## What A24 actually generated

A24 ran **zero** PixelLab paid API requests. This is an **independent diagnostic 544×416 Ground/PAR composition**, not a PixelLab full-sized original image, and is labeled accordingly.

GROUND `A24_GROUND_544x416.png`: verified original FS grass64 SHA256 b185fbbccd5f84a58f12144b906d7a5fe71809b59a8f75ac385c92b2c5543407 and pale-sand48 SHA256 ca7c4ea242a9b81ab39113acdad1de47ed193117d1f5db6c6d2dea5383548adb. Deterministic 24px overlapping 16px-stride texture pixel quilting (35 candidates) at 544×416 without resizing; texture provenance is original FS RGB values. Road was built by tracing A22 variant #1/#4 connected road profiles and joining them as a 416px vertical walkable path; this derived macro road geometry is **not** the full original 128px AI model image output. Ground-only flowers were copied from A23 genuine PixelLab botanical RGB overlay, with a 2px perimeter trim to remove the rectangular white edge leak found in the first A24 run.

PAR `A24_PAR_RGBA_544x416.png`: transparent FS-original layers, 10 source-bound objects from real `!$Object2.png` (rock and barrel), `!$habbel_lamp.png` (streetlamp), and transparent `par12.png` (forest boundary foliage). The exact source file hashes and crop boxes are in `A24_SCENE_MANIFEST.json`. The original full standalone tree/trunk source was not acquired; **full tree occlusion NOT TESTED**. `PAR_COMPONENTS` holds independent true-alpha sprites for replay. Original right foliage 95px crop had stray branch and fence contamination; fixed with tighter 70px source crop and the old stale 95px source cropped PNG is excluded from the package. Clean right border and ground white-line bug were visually reviewed.

PAR is fully transparent outside objects; `A24_PAR_BACK_RGBA_544x416.png` and `A24_PAR_FRONT_RGBA_544x416.png` are **single-actor-footpoint snapshots**, not dynamic generic occlusion rules. Godot Y-sort based on actual object footpoint is the real dynamic occlusion test. A stand-in blue diagnostic actor, **not** production `$ACTOR01`, is used.

## Real engine and physical QA

Godot install `E:\Godot\4.7.2\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`, compatibility OpenGL 3.3 with AMD RX 6700 XT GPU. Native isolated `GODOT_ISOLATED_V4_7_2` scene renders **four** real 544×416 PNGs:
1. No actor
2. Actor behind a 64px FS streetlamp
3. Actor in front of same streetlamp
4. Actor standing on middle road
The actual renderer returned success `A24_GODOT_NATIVE_RENDER_PASS image_count=4 par_sprites=10`. Different image regions from actor screenshots prove the camera scene updated correctly. Body y-sort matches foot depth in the two lamp overlap positions.

Independent pixel QA: Godot no-actor screenshot vs Pillow original Ground + transparent PAR composite differs at **641 / 226,304 pixels (0.283%)**, mean RGB absolute difference **0.0010266 / 255**, NOT exact pixels. Pass is real-render-with-tiny differences, not formal pixel-perfect equivalence.

Collision QA: 544×416 equals 17×13 native 32px cells; Ground default passable, PAR foot/border tiles set 34 blocked, 187 passable, BFS from actor spawn reaches **all 187 open tiles**, including top and bottom road exits. This is a preliminary **grid model**, not actual RGSS2 Game.exe passability. Need test tree base, canopy, actor behind/in front on native VX separately.

## Honest art and integration status

At 1× the A24 ground has brighter denser grass grain and a fairly thin winding road than the original full Ground3; the scene is sparse (no real complete trees, no buildings, no cliffs) and still not at FS aesthetic density. Side forest edge uses existing FS fragments. Cannot claim Village / Elven Forest art pass.
- Ground format 544×416 PASS (procedural original FS texture-derived).
- Alpha PAR 544×416 PASS; imported real FS props and forest edge.
- Actual Godot 4.7.2 renderer PASS.
- Dynamic lamp front/back occlusion test PASS for stand-in actor only; full tree FAIL/NOT TESTED.
- Preliminary passable 17×13 path connectivity PASS; native VX NOT RUN.
- PixelLab original 544×416 full Ground NOT RUN.
- Art full Ground3 **FAIL / not approved**.
- FORMAL SEAL **NO**.

## Reproduction and privacy

Isolated experiment folder `E:\FS_ROUTE_B_STAGE16_A24_LARGE_FOREST_GROUND_PAR_20261101`, separate from any existing FS baseline. Private ZIP retains source-owned grass/sand crops, true A22 road masks and A23 flora source, selected original FS Character sprite sheets and par12 border source, generated outputs, render scripts, screenshots and QA. **No private FS source pixels or character sheets in public GitHub.** Cold reproducibility: regenerate the scene with Python without any paid PixelLab calls, rerun Godot console in isolated project, recompare original PNGs and hashes. Public GitHub contains only code/docs and fingerprints, not images of user's private FS data.

## Next A25 gate: first provider-native GROUND

Before any paid API call verify current PixelLab v2 endpoint/plan dimension allowance. Official PixelLab docs describe `/create-image-pixen` up to 768px, but Pro/style endpoints and the user's Apprentice subscription have model-specific limits; **do not assume the chosen quality model can produce 544×416**. Test provider capability and account balance with read-only requests. If direct 544×416 is available, one budgeted Ground-only request using FS original style palette, no PAR props. Save raw PNG unchanged; then assistant builds separate transparent PAR on that exact geometry. If not available, stop and design connected terrain chunks with strict 1x seam validation rather than high-res downscale. No automatic API post in A24.

**A24: real graphics PASS; Godot PASS; ground+PAR art FAIL; VX NOT RUN; Formal Seal NO.**
