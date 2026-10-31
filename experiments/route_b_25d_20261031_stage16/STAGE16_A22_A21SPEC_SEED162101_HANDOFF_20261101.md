# Forest Symphony Stage16 A22 — FS Clean Ground Style Reference Specialist Model Trial
Date: 2026-11-01 (Asia/Taipei)

**Authentic PixelLab style model execution PASS / original native 128×128 PNG PASS / meaningful compositional and fine-texture REGRESSION compared with A20 / Ground3 art FAIL / no full map / Formal Seal NO.**

## Authority / baseline
A19 Pro ordinary endpoint generated flat 128×128 meadow with path, 34 colors. A20 used authentic full-scene FS ground3 128×128 style crops across grass, sand, flora, though these samples had tree/cliff contamination; PixelLab `/v2/generate-with-style-v2` returned 4 original 128×128 images from one POST using 10 reported subscription generations. A20 comparatively had visible winding paths, full vegetation clusters and more pronounced textures. However full Ground3 style did not PASS.

A21 prepared three cleaner original FS crops and A22 zero-charge blueprint (without any provider call), source SHA validated. This A22 stage applied that exact reference spec once, not a procedural replacement, no resize and not from generic text2image.

## Exact source (user-private only)
Three direct source crop files from FS ground3.png original SHA256 `ddc1f21e1d23dcb8258a20baa2acb106d1c0e56683a4dc280faedc23bcd47a13`:
- `A21_FS_PURE_GROUND_GRASS_NATIVE96.png`, SHA `1ad9b9e1f583f731a86aa4feb2f8096fe778cab663226a4fad0ee462769bf473`, 96×96.
- `A21_FS_PURE_GROUND_SAND_NATIVE128.png`, SHA `358cf7c92214b2001179b3e004c16458d121e74fb857c38fe605bda0ac44517d`, 128×128.
- `A21_FS_PURE_GROUND_FLORA_NATIVE64.png`, SHA `f3f9742625b47c39f2710e090663a9a50606fb0bbb96b1dbb4c46be17ede284a`, 64×64.

All sources exact original pixels. No artificial retouch/recolor/interpolation. Official style endpoint infers 128×128 square output because max reference size is 128×128, returns 4 variants in the corresponding size band.

## Authenticated provider execution
Exactly one POST `/v2/generate-with-style-v2`, fixed seed 162101, same A21 spec description and style_description, no_background=false, 3 source style images as documented, job ID `5d982789-69a5-41aa-ab7c-1d6c45b26712`. Returned HTTP 202 asynchronous job. All subsequent polls GET only; no retries or duplicate charges.

Original result PNGs, each genuine 128×128 direct API returned:
1. `A22_FS_CLEAN_REF_ORIGINAL_VARIANT_01.png` SHA256 `091c03d5df32edbf105ad2e7644bb2d326307cbb942751f21b7139245aca6d46`, 34 colors, neighbor RGB L1 3.409. Almost uniform grass, no complete requested sand road.
2. `A22_FS_CLEAN_REF_ORIGINAL_VARIANT_02.png` SHA256 `27773ef8fcd48a89022803b5aee59b8ff7d30785ea560f22b43cf8050d0a7c1f`, 33 colors, neighbor RGB L1 6.450. Broad mostly simple regions of green and sand, limited texture.
3. `A22_FS_CLEAN_REF_ORIGINAL_VARIANT_03.png` SHA256 `35520fa473b2fb73e36edcb3049152ec069769fe71aaffe97bfdb8826ebc83a9`, 42 colors, neighbor RGB L1 7.009. Path wide, details heavily concentrated at edges.
4. `A22_FS_CLEAN_REF_ORIGINAL_VARIANT_04.png` SHA256 `fb8a80c8f3a0185aeb16c1c8dbbfc6ecaa8d435fefd8bf3e3e441eeed228b275`, 38 colors, neighbor RGB L1 7.761. Dominated by flowers/grass, no coherent path.

A20 same four baseline variants had neighbor RGB L1 [10.062,15.183,13.811,14.812]. A22 values [3.409,6.450,7.009,7.761]. This suggests reduced local texture variation in A22, consistent with the 1× and nearest 8× human-visible comparisons, **not a validated art score**. The two stages also differ in input reference sizes and composition content; do not attribute regression to removing trees alone.

## Budget anomaly (IMPORTANT)
Subscription generations BEFORE the single POST **1980**. Account balance after completion **1960**, observed drop **20**. Provider job `usage` reports `{"type":"generations","generations":10.0}`. USD API credits remained $0. There is a **10-generation mismatch** between job usage and subscription account delta, cause unknown (could be account-side concurrency or accounting). Do not claim the A22 job itself definitely cost 20 nor claim that balance only decreased by 10. Preserve both fields in receipt. No second POST until clarified.

## Art acceptance
Native valid PNG + official model return PASS. **FS Ground3 full art FAIL**. A22 is less expressive, grasses are flat and poor in fine grain, paths missing or oversized; not an upgrade over A20. User aesthetic acceptance remains not obtained. No 544×416 source art, no PAR/Collision/occlusion, no Godot or native VX Game.exe. Formal Seal NO. Do not merge into production.

## Root-cause hypotheses, unproven
(A) Tiny clean material references removed compositional context essential for a wandering road and mixed vegetation. (B) Reference-size asymmetry 96/128/64 biases model toward the larger sand reference; A20 used 128/128/128. (C) More stylized high-level diffusion prior prefers broad flat fills despite authentic fine-grained FS material examples. These are hypotheses requiring controlled A/B testing before facts.

## Reproducibility and handoff
Preserve raw source PNG bytes, all source native crops, exact generation job metadata, model and visual QA, 1×/2×/32px comparison sheets, SHA manifest, isolated cold extract verification. **Cold verification does NOT make another paid API call.** Keep all private FS artwork and model outputs in user's private Drive ZIP; public GitHub for docs/code and hashes only. Keep source credentials out of both.

## Next A23 recommendation (no more automatic spending)
**Stop broad prompt/seed loops.** Next step must preserve successful A20 compositions while separately conditioning the high-frequency ground textures. Try a controlled ground-material-only inpaint/reference-image strategy *after inspecting endpoint cost*. A20 should remain the better candidate baseline for composition, not A22. Only one explicitly budgeted new POST with transparent spending discrepancy resolution, if needed. No stage seal.
