# FS Ground3 Authentic Reference + Ground Material Edge Rules v1 — 2026-11-01
ACTIVE. New evidence A33 after explicit A32B user art approval. Formal Seal remains NO.

> **2026-11-07 P0 來源目錄說明**：此頁引用的 `E:\FS_ROUTE_B...` 是 2026-10/11 的材料擷取歷史位置，**不是**新的 Ground3 參考圖或草/沙 source 正式儲存庫。來源以已登記的 Google Drive ID／SHA 與使用者持有的原圖為權威；新圖修整與所有 QA 存 Drive/GitHub、PC 不存成果。[P0](../docs/FS_CLOUD_ONLY_STORAGE_POLICY_20261107.md)。

## Critical source identity rule
**The real historical Forest Symphony ground3 ART is `Graphics/Parallaxes/ground3.png`, 1280×928 RGB, SHA256 `ddc1f21e1d23dcb8258a20baa2acb106d1c0e56683a4dc280faedc23bcd47a13`.**
**`Overlays/ground3.png` is a dark light/shadow-type map, 1280×928, NOT the artistic material reference.** Prior A33 kickoff source audit incorrectly treated it as the reference, producing invalid visual color/gradient comparisons. Correct the path, file type and SHA before deriving style data, and retain prior wrong-source report only as failure evidence.
Reference grass material extraction: `E:\FS_ROUTE_B_STAGE16_A10_PIXELSPACE_20261031\A10_GROUND3_GRASS_SOURCE_64.png`, 64×64 native pixel RGB.
Reference sand material extraction: `E:\FS_ROUTE_B_STAGE16_A06_SAND_MATERIAL_20261031\A06_GROUND3_SAND_MATERIAL_REF_48.png`, 48×48 native pixel RGB.
The real Ground3 full scene includes buildings, walls, canopies and foreground; do NOT paste the entire flattened artwork onto a new Ground. Only take verified ground-only grass/sand/flushed flora material crops and preserve source provenance; independently rebuild ground and PAR.

## A33 current source-first material contract
- A32B explicitly approved by user on 2026-11-01; lock A32B `Overlays/Par50.png` and all 12 object PNGs, exact alpha/foot/y-sort/collision.
- Immutable original A27 PixelLab Ground: 544×416 SHA256 `35c454c82d4f32906de39702a8463ca72316b14e157239604c18971bd67d00ce`. New Ground must have NEW name and SHA; never overwrite historical source A27/A32B.
- Original A27 Ground has only 35 RGB colors, broad flat green, irregular muddy grasses and pixel blocks. Ground3 original is more detailed and natural. Compare actual material classes at 1x and nearest-neighbor 2x-4x, not misleading full-map gradient metrics across different scene compositions.
- Road sand semantic mask derived from original road-specific colors; A33 cleaned 1,568 mask positions with 3×3 MODE filter while preserving topology. Validate actual native road walk and tree-root block. Original source ground was all-walkable except specific terrain exclusions; PAR obstacle collision stays in E layer, not chroma-mask-driven.
- Preserve original bright ground-attached flora pixels in place if possible; A33 retained 1,885 bright source flora pixels at identical XY, and existing sparse nearby dark plant blades. Don't silently erase floras, add fake global shadow maps, or bake scene LIGHT/SHADOW into Ground.
- When replacing ground material, sample authentic original pixel-scale source, output 544×416 (no blurring/bilinear). Native-scale grass/sand candidates: R1-R3 dynamic patch quilting produced visible square grid seam rectangles, **ART FAIL**. Reject even if 3×3 cleanup and 1x source are technically valid. Subsequent R4-R6 reflected periodic source tile avoids large seam grid; R5 source flora preserved is selected as an **A33 engineering candidate**, visual user acceptance pending. Mirrored periodic motif / repetition at scale must still be visually evaluated.
- Pixel art edge ≠ naive sharpening; crisp material borders need readable source texture, semantically protected road geometry and optional sparse natural pixel stipple, never uniformly sharpen or soften entire image.

## Mandatory dual engine and release gates
Native RPG Maker VX: real `Game.exe`, RGSS Player HWND 544×416, 12 scenario positions, 24 real screenshots, actor complete/front/partial occlusion, E-layer ParaPassa road movement and tree blocker, no RGSS error modal.
Godot: fresh 4.7.2 OpenGL RX 6700XT native 8 renders, same Ground and 12 approved PAR sprites. Independently compare engine no-actor screenshot to PIL true Ground+PAR composite, report pixel errors not false zero. A33 native Godot R5 had 2,971 pixels at max single-channel delta **1**, 0 >1; permitted engineering tolerance 1, not literal pixel-identical.
True independent cold copy 3,395/3,395 SHA plus actual cold VX map launch; do not conflate with 24/24 frame-repeat SHA.
All legacy source-license unknown sprite/source PNGs remain private Drive only; public GitHub documentation/QA without raw art. Formal Seal NO until user accepts Ground art and full production regression is resolved.
