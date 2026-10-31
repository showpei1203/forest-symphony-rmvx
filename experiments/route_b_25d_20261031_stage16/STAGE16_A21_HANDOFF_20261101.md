# Forest Symphony Stage 16 A21 — FS Direct Pure-Ground Style Reference Library
2026-11-01 (Asia/Taipei). **No PixelLab paid generation** in A21. Verified source crop pixel identity, isolated standing-object contamination, and completed A22 no-charge API spec. No full Ground / PAR generation, no Godot/VX, Formal Seal NO.

## Accepted baseline and reason to correct
A20 used `generate-with-style-v2` with 3 FS 128x128 source crops; true API response returned 4 128x128 PNG and 10 subscription generations spent, balance 1990 -> 1980. A20 versions improved botanical legibility but did NOT meet full Ground3 detailed material standard. Three A20 style references in 128x128 were polluted by parts of trees, cliff, or vegetation that belongs to standing PAR, and potentially taught the wrong image semantics.

A21 **does not** generate another model image. It replaces FS style input selection with smaller, spatially verified SOURCE-TRUE square crops rather than source-image patch synthesis. No bogus repaired 'original image' nor hidden diffusion resizing. Original Ground3: `E:\GameAssetToolLab_20261023\ASF_Test_20261031\VX_A09_3_INENGINE_BRIDGE\Graphics\Parallaxes\ground3.png`, 1280x928 RGB, SHA256 `ddc1f21e1d23dcb8258a20baa2acb106d1c0e56683a4dc280faedc23bcd47a13`.

## A21 exact FS native crop references

1. `GROUND_GRASS`: `A21_FS_PURE_GROUND_GRASS_NATIVE96.png`, 96x96. Source top-left (288,564), box (288,564)-(384,660), SHA256 `1ad9b9e1f583f731a86aa4feb2f8096fe778cab663226a4fad0ee462769bf473`. 6,933 unique RGB, neighbor L1 12.65. Predominantly natural fine grass material, with a tiny original ground herb at edge.
2. `GROUND_SAND`: `A21_FS_PURE_GROUND_SAND_NATIVE128.png`, 128x128. Source top-left (948,264), box (948,264)-(1076,392), SHA256 `358cf7c92214b2001179b3e004c16458d121e74fb857c38fe605bda0ac44517d`. 6,150 unique RGB, neighbor L1 13.106. Substantial fine sand and curved grass-edge material.
3. `GROUND_FLORA`: `A21_FS_PURE_GROUND_FLORA_NATIVE64.png`, 64x64. Source top-left (164,636), box (164,636)-(228,700), SHA256 `f3f9742625b47c39f2710e090663a9a50606fb0bbb96b1dbb4c46be17ede284a`. 3,668 unique RGB, neighbor L1 16.782. Recognizable white-yellow pixel wildflower cluster and natural grass. Flower standing-depth/occlusion semantic still requires art/engine judgement.

Each image passed byte-identical native-pixel comparison with its source region at 1x after unpacking PNG (not necessarily identical PNG compression bytes, which is why SHA of each saved PNG is separately recorded). No resampling, retouch, color reduction, fill or patch quilting; three sources not the same sizes but **official generate-with-style-v2 API deduces square output from maximum reference size**, thus max(96,128,64)=128 and predicts four original 128x128 output images. Verified official live OpenAPI `StyleImage` accepts width/height up to 512, 1-4 images. This is only a source reference PRECHECK, NOT a claim provider accepted this future request.

## Why smaller clean native samples are superior
Original ground3 is a completed village scene, NOT a tile-only dataset. Exhaustive color/contrast heuristic ranks often selected windows with tree foliage, rooftops, wall edges or cliff, and a naive 'bright yellow flowers' detector confused pale sand with wildflowers. Manual side-by-side visual review was used after automated ranking; old contaminated A20 references are retained for an honest comparison. No automatic image segmentation can guarantee semantic purity; images flagged as clean are human-inspected candidates, not formally pixel-level masks.

## A22 style-provider request spec (not executed)
`A22_ZERO_CHARGE_NATIVE_STYLE_SPEC.json`: endpoint `/v2/generate-with-style-v2`, 3 private style_images at their actual native widths/heights (96,128,64) and hashes, fixed seed 162101, no_background false, preview-only prompt. Maximum dimension 128 predicts one 128x128 4-variant batch; actual charges would need live balance and usage verification first. No API token printed or persisted. Current stage has **ZERO POSTs and ZERO PixelLab generations charged**.

## Validation and cold pack
All accepted crops original pixels from complete source; exact original SHA/coordinates and crop PNG SHA recorded. A21 private bundle includes accepted images, candidate contact sheets, rejected contamination examples, scripts, manifest, no-charge A22 spec, validation and failure register. Cold ZIP extraction must reproduce every file SHA and check all true image dimensions and reference metadata. Cold source pixels are verified on Windows against actual full source; full source is not distributed. The ZIP contains three small native FS source crops for user's private Drive only; **DO NOT put pixel assets on public GitHub**, commit docs and scripts only.

## Stop and next move
A21 source engineering PASS, native ground-only visual precheck IMPROVED, full Ground3 **NOT_TESTED as a new model generation**. Next A22 can use exactly ONE PixelLab style API request after preflight from the remaining subscription balance. Do not automatically submit without a distinct budgeted user continuation. Native 544x416, PAR, VX and Godot remain NOT RUN. Formal Seal NO.
