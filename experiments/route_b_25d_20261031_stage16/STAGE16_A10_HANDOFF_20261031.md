# Forest Symphony — Stage 16 A10 Pixel-Space Material Synthesis: Experimental Handoff

Date: 2026-10-31. **Pixel-space procedural material synthesis ENGINEERING PASS / Ground3 visual ART NOT APPROVED (full style FAIL) / Godot NOT RUN / native RPG Maker VX NOT RUN / Formal Seal NO.**

## Source of truth and preserved baselines
The user's original private Ground3 source composite is RGB 1280x928 SHA256 `ddc1f21e1d23dcb8258a20baa2acb106d1c0e56683a4dc280faedc23bcd47a13`. Neither original Ground3 nor Stage15–A09 files were edited. Stage15 engineering PASS/art FAIL/VX NOT RUN remains unchanged. Stage16 A09 showed an original-48px SD1.5 VAE reconstruction with MAE22.50/255 and 19.27dB PSNR; two combined ControlNet+IPAdapter low-denoise runs natively crashed without an output. A10 **does not** rerun those models.

## New original reference materials
Manually inspected 12 programmatically shortlisted 64x64 grass candidates and rejected crops showing fences, plants, tree stems or transition contamination. Grass-only reference crop from original Ground3 (752,282)-(816,346), RGB 64x64, SHA256 `b185fbbccd5f84a58f12144b906d7a5fe71809b59a8f75ac385c92b2c5543407`.
Original sand-only reference from A06 (1032,321)-(1080,369), RGB 48x48, SHA256 `ca7c4ea242a9b81ab39113acdad1de47ed193117d1f5db6c6d2dea5383548adb`.
Both are private **inputs** from original copyrighted Ground3, NOT claimed to be newly generated assets.

## Tested generation architecture (not neural image synthesis)
NumPy 2.4.6/Pillow12.3.0, original RGB source reference per material. Material stochastic synthesis operates in **pixel space**, with 2D Fourier power spectrum magnitude from source, bilinear periodic spectral interpolation to output size, independently sampled random phases from synthetic noise, source RGB cross-channel covariance and per-channel histogram rank matching. Seed: grass 101064, sand 101048. Does NOT copy donor source tiles or original source 2D pixel arrangements. Source material colors/histograms do inform output; it is statistical synthesis, not AI latent model or an imagined prompt-only drawing.

Actual fresh RGB PNGs: 384x384 standalone grass, sand and full ground; independent native new 544x416 RGB grass, sand and full Ground candidates. 544x416 is generated fresh at that size; **not scaled from 384px**. Both use independent Ground3 grass and sand source statistics. No PAR/object layers, no roofs, rocks, tree trunks or tall props were deliberately added. All ground is conceptually walkable; no game collision or native VX test built.

## Controlled A/B versus prior A09
At 384x384 the two comparator ground PNGs have **identical generated grass**, exact same original A05 road-mask geometry (28,818/147,456, 19.5435%) and same first-pass border blending. Only ROAD material source algorithm differs: A09 seeded multivariate random normal statistical prior vs A10 random-phase spectral source-statistics model. All 118,638 non-road pixels were identical; 28,816/28,818 road pixels differ. Test is algorithmic, no SD1.5/ControlNet/IPAdapter model inference was performed.

Native 32px source and output color/gradient statistics:
- Sand source mean RGB (208.49,184.52,102.70), 1px mean L1 neighbor difference 12.2717, 2px difference 14.3928.
- A09 random-sand mean RGB (208.02,183.83,102.09), 1px 12.3075, 2px 12.6245.
- A10 spectral-sand mean RGB (208.68,184.57,102.87), 1px 13.0579, 2px 14.4813.
- Grass source mean RGB (109.31,151.95,23.30), 1px 12.4792, 2px 14.8910; A10 independently synthesized grass mean (109.32,151.95,23.29), 1px 12.6902, 2px 15.0183.

These are **low-order descriptive texture statistics**, not style similarity scores. 32px native screenshot comparison favors A10's micro-grain density versus previous giant SD1.5 stones, but it is still visibly too uniform/static with almost no organic vegetation.

## Road boundary control: R1 vs R2
First R1 road blend only modified target road, preserving zero pixels outside exactly but causing an abrupt grass/path edge. R2 controls a thin 4-pixel band **outside** road only, with alpha fade [0.18,0.12,0.06,0.02]. The interior road is *identical* R1 vs R2, and all 115,566 exterior pixels beyond the allowed band remain unchanged. Allowed external transition band = 3,072px. Mean RGB absolute jump across actual 384px road boundary fell **20.2319 -> 11.4086** (a local geometric seam diagnostic, NOT artistic proof).

## Fresh 544x416 native ground benchmark
Actual original RGB 544x416 file `A10_BENCHMARK_GROUND_544x416.png`, SHA256 `20bb55e2b9212b45204a885cb34c0a59ba77fa2e5d0c0754d8eb62a956e33e5a`. 226,304 total pixels; 44,321 continuous road-mask pixels = 19.585%; 3,328 allowed 4px exterior transition pixels; 178,655 protected exterior pixels identical to synthesized grass; road connected from top to bottom with one continuous segment in every row. No resampling, no superresolution, RGB native PNG.

## Fail-closed interpretation
A10 proves a **new non-donor, non-VAE original PNG material generation process** can preserve original Ground3 local fine-grain scale more reliably than earlier SD1.5 outputs and achieve exact roadmap/zone controls. This is important yet still not the end-user's desired detailed large village. The visual looks too monotonous, overly homogeneous, with uniformly wide sinusoidal path and little organic transition/flower/grass variation. **Full Ground3 aesthetic ART FAIL / user not yet approved**. No native Godot import/render and no RPG Maker VX Game.exe walk/occlusion run. Formal Seal NO.

## Reproducibility and privacy
Private files include authentic small source crops, raw generated standalone RGB PNG, 384px paired A/B, 32px nearest comparisons, native 544 benchmark, masks and QA scripts. The `verify_a10_cold_reproduce.py` script, from independent extraction, reconstructs BOTH sizes directly from source sample pixels and validates exact generated RGB pixel arrays, road masks and protected exterior. It requires NumPy/Pillow but **not** full original source nor any SD checkpoint. Large original Ground3 source remains only on authorized user's Windows desktop. GitHub stores text and scripts, not the private source/reference artwork.

## A11 next falsifiable gate
Concentrate on grass/ground ecological variation and nonuniform terrain structure at original 544x416 without reintroducing donor tiles, tall PAR objects, or synthetic giant geometry. Establish a **spatially conditioned low-frequency terrain structure** that controls grass density/flowers/soil micro-patches while keeping independently synthesized original Ground3 scale texture intact. Compare fixed A10 baseline 1x native 32px and new one-factor patch-variation candidate. Stop if scene art does not improve. Do not use A10 technical PASS as official FS Ground acceptance. Preserve Ground/PAR rules: ground generally walkable; static props handled via PAR and colliders only after art acceptance.
