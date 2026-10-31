# Forest Symphony Stage16 A23 — Scene Geometry and Authentic Ground Texture Separation
Date: 2026-11-01, timezone Asia/Taipei.

**Genuine FS texture-source / PixelLab scene-mask material transfer diagnostic PASS; full Ground3 art candidate NOT FORMALLY ACCEPTED; model-native full 544×416 NOT RUN; Godot NOT RUN; VX NOT RUN; Formal Seal NO.**

## Authority, baseline and cost
A22 API generated four true original 128×128 pixel PNGs with PixelLab `generate-with-style-v2`, native hashes recorded in A22; job `d1d7e89d-571f-41a2-ac79-286171edced2`; A22 subscription usage 10 generations, balance 1,980→1,970. A23 uses frozen copies of these files and performs **zero PixelLab API calls, zero new generations**.

User-approved FS original material crops only, kept private:
- Grass 64×64 ground3 native original `A10_GROUND3_GRASS_SOURCE_64.png`, SHA256 `b185fbbccd5f84a58f12144b906d7a5fe71809b59a8f75ac385c92b2c5543407`.
- Sand 48×48 ground3 native original `A09_GROUND3_ORIGINAL_48.png`, SHA256 `ca7c4ea242a9b81ab39113acdad1de47ed193117d1f5db6c6d2dea5383548adb`.

Do **not** call the output 'PixelLab native map generation': it is deterministic **post-processing, genuine FS-source texture quilting/compositing applied to AI scene geometry**.

## Executed pipeline, four model examples

1. Read original unmodified 128×128 model-provided A22 PNG.
2. Detect pale-sand road in original RGB with fixed channel boundaries, 3×3 majority twice, keep largest 4-connected component. Road connected fraction in variants #1–#4: 21.6%, 25.68%, 21.36%, 20.37%; largest-component share of the smoothed road mask 100%. Four PNG 128×128 road masks and original RAW mask counterparts are saved.
3. Fill ground from genuine FS source grass64 / sand48 WITHOUT any interpolation or palette replacement using **two different methods**:
   - PERIODIC_BASELINE: source image repeats at source period, revealing regular stripes and tile edges.
   - QUILTED_GROUND: deterministic source-pixel-only overlapping 24px patches at 16px stride, 35 source candidates per patch, cost-minimizing 8px short seams via dynamic programming. Pixel RGB for every grass pixel matches at least one value of original FS grass source; similarly each road pixel matches original sand pixels. No down/upscale.
4. Preserve selected original A22 high-contrast flowers and nearby plant details over quilted Ground. The generated RGBA overlay is transparent except the source-matching AI pixels; separately exporting this overlay and alpha-compositing onto original quilted ground reproduces A23 merged PNG with zero pixel difference, all four examples.
5. Compare raw model image / periodic / quilt / quilt+botanical overlay at native 128×128 and center 32px nearest x8. Keep original PixelLab input and user-private material source in ZIP.

## Engineering measurements
Original A22 #1 source grass L1 6.675 vs quilt 12.799; path L1 8.408 vs quilt 12.598.
A22 #2 grass 11.399 vs quilt 12.594; road 8.141 vs quilt 12.195.
A22 #3 grass 11.454 vs quilt 12.404; road 9.121 vs quilt 12.178.
A22 #4 grass 5.494 vs quilt 12.530; road 8.677 vs quilt 12.480.
These are mean adjacent channel differences measured only where both neighboring pixels belong to the same semantic material, NOT art-quality scores. Resulting texture's local detail frequency better approximates genuine FS source roughness than flatter raw A22 in some locations.

Seam comparison at grass-only x=64: periodic vs quilt L1:
1. 12.230 vs 11.904 (reduction)
2. 14.442 vs 13.843 (reduction)
3. 13.877 vs 13.259 (reduction)
4. 13.354 vs 14.365 (**increase**). Quilt is therefore NOT universally better; further seam/art gate required. Source material may repeat and texture quilt may still show patch patterns.

AI botanical overlay pixel counts #1–#4: 513, 814, 875, 431, equivalently 3.13%, 4.97%, 5.34%, 2.63% of all 128×128 pixels. All other pixels in composite match quilt ground exactly. Plant overlay RGBA is **ground-decoration candidate only**, NOT verified PAR, collision, character occlusion, or final art. It is a heuristic high-contrast mask; leaf silhouette omissions and unnatural edges possible.

## Acceptance honesty
Geometry mask connectedness PASS; authentic FS pixel material source membership PASS; traceable source-vs-model separation PASS; independent botanical overlay exact alpha recomposition PASS. Human visual review: significantly richer natural material granularity than flat A22, but some planted flora disconnect from new underlying texture; material image is a post-composition, and user has not approved Ground3 full artistic quality. Final Ground3 style **NOT FORMALLY PASS**.

No full-size 544×416 town/forest Ground map, no PAR, no collision, no Godot or RPG Maker VX original runtime test. Formal Seal NO. No production FS source modification.

## Provenance, cold reproducibility, upload discipline
Private ZIP contains (1) 4 original authenticated A22 raw PNGs, (2) verified FS 64px grass and 48px sand original source reference crops, (3) road masks, (4) 3 transfer variants × 4 source images, (5) independent botanical RGBA overlays, (6) frozen QA JSON/contact sheets, (7) rebuild and cold-validation scripts. Cold rebuild from ZIP inputs executes the local deterministic segmentation/quilting/overlay and checks all 128×128 outputs by SHA, **without a new PixelLab API call**. GitHub only public scripts and textual handoff; no user-private original FS source pixels or image data in public repo.

## Next stage A24
Stop generating extra high-resolution image model outputs. Review A23 quilt+flower results with the user. If visuals look worthwhile, use the same controlled scene-manifest geometry layering to attempt one genuinely new **544×416 benchmark** with nonrepetitive FS texture and semantic ground-flora separation, then run isolated Godot and VX test-build, not official FS seal. If A23 seam artifacts or plant masks are visually unacceptable, improve seam and botanical separation first, keeping budget 1,970 untouched. No automatic paid PixelLab generation justified from this test alone.
