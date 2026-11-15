# Forest Symphony | A35 R8 R2 · Canopy Fill + Dual Light | Official Native Handoff
**Date: 2026-11-16 (Taiwan). Engine Godot 4.7.2, AMD RX 6700 XT OpenGL Compatibility.**  
**ENGINE PASS · NAV PASS · ORIGINAL GPU 4/4 PASS · PIXEL CONTROL PASS · ART HOLD.**

## Baseline and isolation
- Continue **Godot only** from official A35 R8 source. Do not go back to VX, rebuild obsolete A33, touch A36C large-forest parallel workstream, combat engine or sealed R2–R8 scenes.
- Original private R8 source [verified owner-only Google Drive](https://drive.google.com/file/d/1xcUgm5bqAfKr8-MB45ijOfP8WoW4qAO2/view), SHA256 `e47e8cba8d746a034fcd5620680554a20bfd96c2d146d8c062874f59f22507fc`. New scene `scenes/a35_r8_r2_light_balance_scene.tscn` is **additive**, not an overwrite.
- The original Ground SHA remains `3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000`.
- Original R8 scene SHA remains `27aad890c0c6c8d7f770070738550f0a84fe278c275ae67ce9c94844cdb6d3ad`.
- Original 187 PAR owner footpoints, source SHA, collision shape equivalence, 175 R7 trunk occluders, 175 R8 canopy occluders, 29 canopy asset profiles remain unchanged; historic source files preserved exactly.

## Actual construction
1. New `scripts/a35_r8_r2_light_balance.gd` extends verified R8 canopy controller. Existing shadowed primary lamp at (260,785) uses original energy .98; a **second same-position unshadowed PointLight2D** supplies an adjustable fraction (default **24%**) while reducing primary key's energy by the same fraction so original total light energy is preserved. This is an **artistic lighting approximation** of foliage transmission, not physically accurate fractional-opaque `OccluderPolygon2D`.
2. Introduced independent **northeast experimental grove illumination** at (1090,280), consisting of a shadowed `PointLight2D` and no-shadow fill. Default OFF, optional ON. Primary and secondary have individual light masks/shadow settings and no physics collision.
3. Gameplay toggles: **O** from R7 for shadows, **P** from R8 for canopy occluders, **F** for the soft primary fill, **M** for secondary lighting. Candidate is reversible.
4. New build pipeline `tools/a35_r8_r2_build.py`, native source and collision QA `tests/test_a35_r8_r2_native.gd`, native nav `tests/test_a35_r8_r2_navigation.gd`, four raw GPU frames `tests/capture_a35_r8_r2_native.gd`, precise per-region pixel QA `tools/a35_r8_r2_gpu_qa.py`, six 50-frame benchmark `tests/a35_r8_r2_native_bench.gd`, release sealing `tools/a35_r8_r2_finalize_native.py`.
5. The first failed zero-fill control exposed a genuine Godot edge case: **zero energy secondary `PointLight2D` nodes still altered 16,633 pixels near northeast lamp**, despite user-visible multi-light being off. Fixed by setting the actual `PointLight2D.enabled=false` for inactive secondary pair and for fill fraction 0. Re-ran native source and all four GPU screenshots after repair.

## Real Godot QA
- **Cold Godot editor import PASS / Exit 0**.
- Native source/geometry **PASS / Exit 0**: 187 original PAR locations, 175 trunks, 175 canopy `LightOccluder2D`, matching sprite SHA, all collision geometries unchanged, four actual lights constructed, runtime toggles and key energies tested.
- Native physical navigation **8/8 gates and 4/4 preserved routes PASS / Exit 0**, zero newly blocked protected roads.
- Original 1280×928 Godot GPU screenshots **4/4 PASS / Exit 0**: R8 baseline hard shadows, R2 zero fill, R2 24% canopy fill, R2 24% fill plus northeast light.
- **Critical zero-effect regression gate**: R2 fill=0/multi-light off is **pixel-for-pixel identical** to R8 baseline (0 changed pixels, not merely similar).
- With 24% primary fill: **131,758 affected pixels**, all inside primary lamp radius; 0 outside. **94,175 pixels brightened by more than 1 luminance unit**, 0 darkened. Average signed RGB delta +0.418892, max channel difference 46.
- With northeast secondary light: **122,464 additionally affected pixels**, all inside northeastern lamp radius; 0 outside. **101,948 brightened**; 0 darkened. Average signed RGB delta +1.128708, max channel difference 107.
- Godot 6 samples of 50 frames each on RX 6700 XT: hard shadow wall-frame avg **16.691ms**, fill **16.684ms**, dual **16.696ms**. This is likely limited by frame pacing and is **not** isolated GPU timing, not proof of 60 FPS on every device.

## Owner-only deliverables, provider metadata verified
- **[Complete A35 R8 R2 Godot playable native QA ZIP](https://drive.google.com/file/d/1qPRcM1uT-4Ep9cglVcUzHsz0kvd8CQ-p/view)**, **378 members / 188,106,570 bytes / CRC PASS**, SHA256 `1217c36f9e19ece3d104f6cdf3b8973474c472fd62a7f5e6cd0b94013ffab37c`. Contains all private project sources, 4 original Godot frame PNGs, corrected scripts, source/nav/GPU logs, exact pixel JSON and benchmark. Verified `shared=false`, owner only.
- [Standalone R2 source candidate ZIP](https://drive.google.com/file/d/1EipigwoH2Nqk0tJHGQpEnddol4WgXSj0/view), 363 files / 176,258,786 bytes, SHA256 `094d4c362d7f9f4fa6c32c3eeb194202492cb44f1884a0e4a4cbde8fefbd9cb3`, private. Full QA ZIP above is preferred.
- [Native hard R8 GPU frame](https://drive.google.com/file/d/1S6AK6lBkCzl-ubvNazrXrrYPnkkc4Xgo/view), [R2 unchanged control GPU](https://drive.google.com/file/d/1xrvOpo6dVK5orZHUV2ZwC-3DVYnRmmuG/view), [R2 24% soft canopy fill GPU](https://drive.google.com/file/d/1TJJ6OzrjrhvkKU83aoYRcY-bLsqp7cqY/view), [R2 dual-light GPU](https://drive.google.com/file/d/1KYwDdgam-5avHF0eiq3SUuntQ3GHF-AF/view).
- [Derived four-way comparison PNG](https://drive.google.com/file/d/1572OLVno9Y3Eu0pI08LEwpo_IU9pfAk0/view) is a layout made of original GPU frames, **not a single native frame**.
- [Exact real GPU delta report](https://drive.google.com/file/d/1zCgcR5GhLSQNQQAf8LZ3geiHMbXKvAZE/view), [Godot wall-frame benchmark JSON](https://drive.google.com/file/d/1XSjHfKJPyIR8zYfyTPs4Ph54z6sGHG4A/view).
- [Private R2 work folder](https://drive.google.com/drive/folders/1y_nIQzqS3xPrhXvy15IkxNfEvaZxErLx). No private PNGs committed to public GitHub; only source and Handoff text.

## Actual art evaluation and limitations
After inspecting the original GPU-derived four-way screenshot at 1:1, the **fill subtly improves shadow readability**, but the experimental secondary northeast lamp illuminates the right-side house too strongly and makes that area conspicuously bright. **ART HOLD**; the second lamp is a technical proof, not approved permanent village lighting. A soft fill is not physical alpha ray transmission or true 3D HD-2D. Forest art still has some R6 conifer spike edges. R8 R2 does **not** implement full real 3D depth-of-field, volumetric lighting or seasons.

## Next concrete construction (do not reset)
- **R8 R3** tune secondary lamp placement/energy so it accents canopy without blowing out east cottage. Capture identical Godot A/B and exact light ROI, preserve optional OFF pixel equivalence.
- Add proper variable lighting and actual independent day/dusk/night comparisons for the whole map, with tree shadow color against background.
- Move on to **Ground3** grasses/flowers/road edges in a separate map candidate once foliage art gate passes, while keeping original Ground SHA untouched.
- Every phase: 1:1 original GPU, real native import/physics/ROI, Failure Log, SHA/ZIP CRC, private Drive and GitHub Handoff. No concept image substituted for playable map.
