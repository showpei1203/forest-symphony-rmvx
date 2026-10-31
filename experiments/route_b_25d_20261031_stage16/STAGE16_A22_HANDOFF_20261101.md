# Forest Symphony Stage16 A22 — Controlled FS Clean-Reference PixelLab A/B
2026-11-01 | Authentic PixelLab API 128×128 model generation PASS | Reference-cleanup hypothesis not supported | Ground3 art FAIL | Godot / VX NOT RUN | Formal Seal NO.

## Baseline A20 and controlled change

A20 `/v2/generate-with-style-v2`, seed `161902`, 3 FS style images, four 128×128 raw PNG. A20 subscription cost 10 generations, balance 1990→1980. A22 **re-used the same exact endpoint, seed, 883-character description and 391-character style_description** (SHA256 of UTF-8 description `6f710ed0a9cbfd3679eec20c7b7fa4a7d8e5f3886fbfb23c94ffe29321b5d197`; style description `73ddcec166cae83c44c65f261c931deaf979102a519c85f64c562edaa8f10066`). The **three reference images** were replaced by A21 original native crops, including their respective original sizes (96, 128 and 64). Because content **and reference dimensions** changed, this tests the *full clean reference pack*, not exact content-only isolation. Model sampling may vary even with the same seed if the service changes implementations; the comparison is small-sample evidence, not a controlled causal proof.

A21 new source images direct from original FS ground3, never resized, original SHA256 `ddc1f21e1d23dcb8258a20baa2acb106d1c0e56683a4dc280faedc23bcd47a13`.
- GRASS `A21_FS_PURE_GROUND_GRASS_NATIVE96.png`, SHA256 `1ad9b9e1f583f731a86aa4feb2f8096fe778cab663226a4fad0ee462769bf473`.
- SAND `A21_FS_PURE_GROUND_SAND_NATIVE128.png`, SHA256 `358cf7c92214b2001179b3e004c16458d121e74fb857c38fe605bda0ac44517d`.
- FLORA `A21_FS_PURE_GROUND_FLORA_NATIVE64.png`, SHA256 `f3f9742625b47c39f2710e090663a9a50606fb0bbb96b1dbb4c46be17ede284a`.

## Real provider execution and account balance

A22 HTTP POST accepted exactly **once**, `/v2/generate-with-style-v2`, job ID `d1d7e89d-571f-41a2-ac79-286171edced2`, subsequent requests were read-only GET job polls. On completion, **4 real original provider-native 128x128 PNG** were saved, no alteration or resize before SHA256. Official balance before 1,980 subscription generations, after 1,970; official job usage `generations:10.0`. Additional US dollar API credit charges 0.

| Variant | Source PNG SHA256 | RGB unique | Mean neighboring RGB L1 |
|---|---|---:|---:|
| A22 #1 | b0338b6f1949be1066f30719ebca3d891a620e74b02f38e4a9f449ea93c32248 | 33 | 7.484 |
| A22 #2 | 2de1a37dff0c42a76ab1dc1a09d01b09f42d663b1527b6f8e043931d73c467ec | 38 | 11.025 |
| A22 #3 | 58155bb1bd6578a6b264767be3b1de9f886b7840a9ba9eb8c29ea4eb65686067 | 35 | 11.260 |
| A22 #4 | afa37a231d1c8727f0136dcbe24228c46952a2504e25af188aff591b83485e2c | 35 | 6.642 |

A20 variants: 43 / 36 / 42 / 41 colors, mean neighbor L1 10.062 / 15.183 / 13.811 / 14.812. Mean all four A20 color count 40.5 vs A22 35.25; average neighboring L1 A20 13.4675 vs A22 9.10275 (lower). These are density diagnostics only, not calibrated art quality.

## Visual inspection at original and 32px nearest-neighbor crops

A22 preserved original low-resolution geometry and soft winding sand path. However its grass is noticeably **flatter and more uniformly bright green** than A20; ground flowers and dense patch structures are sparse. Some roads in A22 #1/2 have nice natural edges, but sand interior and grassy terrain remain below authentic ground3 color complexity. A20's slightly contaminated reference images gave richer high-contrast botanical forms, which might have helped model discover decorative vocabulary. This is a plausible hypothesis, NOT a proof that contaminated references are necessary: reference content and size were both changed, and endpoint sampling variance remains.

**A22 full Ground3 visual ART FAIL, no gold/official 544×416 Ground file, no PAR, no Godot, no native RPG Maker VX; no Formal Seal.**

## Engineering package and next finite decision

Private ZIP contains four real A22 provider PNGs, four frozen A20 comparison PNGs, three A21 verified direct FS original crops, QA JSON, original API job receipt with credit use, generated comparison sheets 1x/2x/32px, conversion-free standalone cold-verification script, immutable SHA256 manifest, this handoff and failure register. ZIP cold extraction verifies original output bytes and independent 128x128 image QA; **does not re-call paid PixelLab API** and should never be called a model output replay. GitHub public material consists of text/metadata/code only; actual FS source reference crops stay private on Google Drive.

**Recommendation A23**: Pause further API spend. A22 shows that purity alone may reduce desirable botanical shape, while authentic Ground3 texture richness still fails. Test *segmented functional style roles* first (one pure grass texture reference, one ground-level illustrated botanical motifs reference, separate dirt path), and consider source-ground3 material grain compositing *as a diagnostic* on A22's AI scene geometry, but do not sell procedural texture transfer as newly AI-generated original high-quality ground. If a subsequent paid test is authorized, choose one at a time and state the exact control variable. Keep 1,970 generations intact until the experiment improves information gain.
