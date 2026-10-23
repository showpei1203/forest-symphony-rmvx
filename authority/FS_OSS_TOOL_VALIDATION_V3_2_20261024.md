# FS Open-Source Game Asset Toolchain | T14 + T16 | 2026-10-24

Status: **V3.1 established 10/10 PASS** + **T14/T16 incremental native 5/5 PASS**. Formal Forest Symphony map art and human Gate F are still **PENDING**.

## First read

- [V3.2 latest Drive handoff](https://docs.google.com/document/d/1-TSCAQKaM8AAbKZt3Drby_TDPtIJIzGDHQmA_c8lEcg/edit)
- [V3.2 complete test ZIP](https://drive.google.com/file/d/11TtRIWhkuX1lbE0TIUHQx0wzQrDLQO3V/view), **295 entries**, **757,499 bytes**, SHA256 `bf1ff18ffdf8d476b829b3432d6bba4d92e1cbcfc644c126c0c0fdbbac0e0ff6`.
- [Locked map/B0/N5 checkpoint](https://docs.google.com/document/d/1jPAJMPf3nhKUDohCuzQZho9AsPJqEG0XPCvKj8u87tE/edit)
- [Precise Drive source file path registry](https://docs.google.com/document/d/1aa9UjWLr7FP7-sGKChXJ26POtCZkQJRl19KAPh07PgQ/edit)

Local root: `E:\GameAssetToolLab_20261023\ToolValidation_v3_20261024`. Launch `RUN_T14_T16.cmd` or `python scripts/run_t14_t16.py`. Machine reports `reports/T14_T16_INCREMENTAL_REGRESSION.json`, `reports/T14_LAIGTER_STITCHED_NORMALS.json`, `reports/T16_GODOT_SYNCHRONIZED_NORMAL_ANIM.json`.

## T14: Do not alpha-blend independent normal-map frames

6 original B0 tree diffuse frames 64×96 generate 6 Laigter individual normals. Reapply each source Alpha to corresponding normal, then pixel-exact `PIL.Image.paste` into 384×96 RGBA sheet. Each cropped normal matches its independent PNG *byte-for-byte*. `alpha_composite` altered pixel values and failed strict comparison, so it cannot be used for pixel-exact source-sheet aggregation.

Naive whole-sheet Laigter normal and reconstructed normal differ on **1,726 visible pixels**. Injected +1px frame-2 offset gives **3,283 differing visible pixels**. Swapping 2 and 3 gives **2,072**. True LibreSprite ASE metadata times [70,90,110,130,150,170]ms and idle tag preserved.

## T16: Actual Godot GPU animation pixel gate

Godot 4.7.2 native OpenGL on AMD Radeon RX6700XT, CanvasTexture normal+diffuse animated at six native ASE frame timings.

Initial runtime strategy changed AtlasTexture regions assigned to *an existing* CanvasTexture: six actual GPU PNG captures were identical, **FAIL**, even though native GPU returned save_png success and printed "PASS". Fixed experimental adapter creates a **new CanvasTexture per frame** with corresponding diffuse+normal frame textures and reassigns `Sprite2D.texture`. Six actual 160×160 frames now distinct. Consecutive sprite-visible changes: [2553,2547,2540,2548,2544]; outside sprite union changes zero. After a 120ms warm-up, timing measurements [65,82,100,114,148,164]ms versus metadata [70,90,110,130,150,170]ms, all within ±35ms.

**Important:** This is confirmed behavior of the tested adapter/project, not a universal Godot bug conclusion. Distinct captures + timing gates are compulsory in future projects; console success alone means nothing.

## Immutable map/runtime status

N5 sealed original 505 scripts remain unchanged (SHA256 `3271f5653a7f53cb55c0762d3b047e2300fbb6d6547257bef1fb2328be2b3ea9`), B0 isolated runtime 6/6 smoke PASS; referenced SCENE04/ground3 style fidelity, bridge-above/under height regions, legally approved source art and human visual Gate F still pending.

No restricted third-party Hanzo art in latest proprietary source test extension. Pixelorama v1.2.3 Shader-effects headless crash remains unresolved; don't claim shader support because disabling effects succeeds. Normal maps are **materials**, never semantic Ground/PAR or Collision/Height separation.

Next: T15 Pixelorama shader GUI/version differential diagnosis; T17 approved PMD/LPC/SBS animation and equipment; T18 multi-actor dynamic lights/GPU performance; preserve every failed test and negative gate.
