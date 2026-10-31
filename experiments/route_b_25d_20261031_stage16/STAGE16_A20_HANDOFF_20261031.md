# Forest Symphony — Stage 16 A20：以 FS ground3 真素材作 PixelLab 風格生成

Date: 2026-10-31. **True PixelLab FS reference conditioned generation PASS / Native PNG 128×128 PASS / Relative-to-A19 visual legibility improved / Full Ground3 art FAIL / Godot and VX NOT RUN / Formal Seal NO.**

## Authority and budget

A19 original authorized PixelLab Pro `generate-image-v2` 128×128 style+reference output was a real PNG with SHA256 `ad073344c627c8d7e727ddbb36092d6f7010f87eb2fd4732166868115dc02c8e`, 34 unique RGB colors, and full ground3 style FAIL. A19 consumed 10 generations, 2000→1990.

A20 submitted **exactly one** paid POST to `/v2/generate-with-style-v2`; job id `f70e6051-83d3-453e-97fa-9de33c7f0362`, seed 161902, 3 actual native 128×128 FS source crops. API reported 4 final original PNG images and 10 generations spent: 1990→1980. USD credits 0 before and after. No follow-up generation or duplicate requests were sent.

## Three FS native source artwork references, original pixels unchanged

Ground3 original fully private `ground3.png` source SHA256 `ddc1f21e1d23dcb8258a20baa2acb106d1c0e56683a4dc280faedc23bcd47a13`, size 1280×928. **Only private 128×128 native source crops** were used as actual API style_images:
- `GROUND_GRASS`: original crop (288,560)-(416,688), SHA256 `b1b9eab00c5daee0cb4b63e959da74449032bcd8943d3132a58e9906516d32dc`.
- `GROUND_SAND`: original crop (896,256)-(1024,384), SHA256 `88cc3f876b2d59a49a417d3bdbfd74ac3fa01258e598f52df6d43f4fccae11f2`.
- `GROUND_FLORA`: original crop (128,592)-(256,720), SHA256 `08a9128534fd428ab682be3f432d242814dcef1f488fa14abca4cc1495435860`.

**Reference limitation:** actual source crops contain some tree, cliff or canopy edges in addition to ground. A20 API prompt expressly excluded these standing objects, but this is a possible reason for oversized outlined foliage. Future references should be strictly masked clean ground regions rather than whole environment compositions. These reference crops are original FS assets, not newly generated material and should not be uploaded publicly to GitHub.

## Actual PixelLab endpoint semantics

Official OpenAPI source `https://api.pixellab.ai/v2/openapi.json`: `generate-with-style-v2` requires `style_images` (1–4) and `description`; accepts `style_description`; max each reference width/height 512; **output is square and deduced from largest reference dimension**, so three 128×128 inputs lead to 128×128 outputs. For output 86–170px endpoint returns four image variants per job. All A20 outputs are original API-returned PNGs. No high-res image resizing, palette quantization, or A10–A13 procedural tile compositing.

## Four raw model results

1. `A20_FS_STYLE_MODEL_NATIVE128_VARIANT_01.png`, SHA256 `504b4ed270caea6acfeacff9505485d17a33ced2817cdffd36776c1025e6275d`, 43 RGB colors, RGB neighbor difference 10.062.
2. `A20_FS_STYLE_MODEL_NATIVE128_VARIANT_02.png`, SHA256 `aca57c23905a1f8b1493c2f074681c004b969241d291eda1c891cfe9b096d2b1`, 36 colors, difference 15.183.
3. `A20_FS_STYLE_MODEL_NATIVE128_VARIANT_03.png`, SHA256 `3319acdd86f68a60dc184b367ad97ad195fba4400a18cdcafffc99535825cce8`, 42 colors, difference 13.811.
4. `A20_FS_STYLE_MODEL_NATIVE128_VARIANT_04.png`, SHA256 `c658c8058ace3969cf6325fc02e22b7bd9595be558facaad7464c506823fd0a0`, 41 colors, difference 14.812.

Compared with A19's 34 colors, RGB neighbor difference 5.166, each A20 variant has more pronounced small leaf and/or flower forms and organic sand-edge detail. These are descriptive statistics, NOT calibrated artistic scores. Full 1× and nearest 2× before/after and native 32px crops are saved.

## Human-facing visual judgment

A20 clearly improves visual density versus A19. Variant 1 has recognisable daisies and a curving sandy path; variant 2 has stronger clustered white flowers; variant 3 has articulated foliage and some intrusive green sprigs inside the road; variant 4 has a continuous curving narrow path with foliage but outlined grass clumps. All remain more stylized and less fine-grained than authentic ground3, which has more nuanced continuous pixel-level texture and better harmony of grass vs sand. No 544×416 artwork from this model exists; no approved walkable Ground or PAR. **Internal full Ground3 ART FAIL**, user approval pending.

## Private library and cold validation

FS style reference pack is categorised GROUND_GRASS / GROUND_SAND / GROUND_FLORA, plus original coordinate manifests. Other future categories BUILDING_WOOD, STONE, TREE_CANOPY, WATER are registered as NOT_PREPARED only; none generated in this stage. Private ZIP has genuine original 3 crops, four original model PNGs, state record (job ID, no secret), visual audits, QA, scripts and SHA manifest. Cold archive verification checks exact file hashes and original model PNG dimensions, **does not re-execute the paid API**. GitHub contains docs/code/metadata only, not original private FS images or generated image assets.

## Next stage and spending stop

Stop spending after this single 10-generations job. A21 should start with better **pure ground-only reference curation** (remove tree/cliff contaminated style input) and examine A20 original images in engine-appropriate 1x without upscaling. Do not move to 544×416 before matching ground3 fine-grain style at 128×128 and user acceptance. Any further API POST must be explicitly budgeted as one charge.
