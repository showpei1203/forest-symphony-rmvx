# Forest Symphony Ground Natural-Terrain Visual QA v1.0
Date: 2026-11-01, A33B. Status: ACTIVE PROCESS RULE, NOT A33B ART ACCEPTANCE.

## Scope and locked assets
A32B upper-two-tree PAR was explicitly visually accepted by user and frozen. A33 Ground R5 was a functioning VX/Godot engineering candidate but visually too monotonous/repetitive and distant from correct historical Ground3 artwork. A33B works on **Ground only**, separately from immutable A32B 12-object PAR, no environmental SHADOW/LIGHT baked into Ground or PAR.
Original A27 native Ground SHA256 `35c454c82d4f32906de39702a8463ca72316b14e157239604c18971bd67d00ce`. A33 R5 Ground SHA256 `ec06a5c01d292beba7dbb042be844dc95b59e5e127f293767d7ea86c11d287c0`. Approved A32B PAR50 SHA256 `24912a82622043c6c0b25b434a0a49585bb5cc470c4c83222a7db2d187de45fb`.

## Correct Ground3 style authority
The actual art reference is original `Graphics/Parallaxes/ground3.png` (1280x928), not `Overlays/ground3.png` (dark shadow/light resource). Native 64x64 grass and 48x48 sand material samples were extracted in earlier A10/A06 and are used as source pixel colors/texture, not as permission to flatten/parallax the whole Ground3 village. Legal provenance remains private until licensed.

## Four independent art gates, fail-closed
1. **Material identity**: grass contains native pixel-microtexture, genuine varying green tonal density, occasional compact low ground flora; sand remains legible at 1x. No global blur, no indiscriminate sharpening or sampling at bilinear scale.
2. **Macro ecology**: uneven grassy patches, authentic low-growing blades and clustered flora rather than huge featureless plains OR uniform noise or random unstructured green stripes. Verify at 1x and 2x nearest-neighbor cropped terrain.
3. **Road/grass boundary**: pixel-step interleaving of tiny grass tufts/soil grains, preserve original road shape/connectivity, no thick halo/drop shadow, no blended muddy antialias gradient, no accidental foot collision change. Ground stays walkable; obstacles derived from PAR foot/E layer and water/hole masks if present.
4. **Anti-repetition**: reject obvious 48/64px mirroring, grid seams, checkerboard quilting, pixel-stretch artifacts, repeated circles or decorative symmetrical plants. Sampling may use native texture coordinate displacement only if it improves aesthetics; must inspect full scene, not only an enlarged patch. Never claim mathematical nonperiodicity solely from a stochastic generator.

## Tested A33B precedent, not automatic art PASS
R7/R8/R9 source-first Ground candidates re-sample authentic Ground3 grass and sand with multi-scale smooth coordinate displacement but NEAREST native pixel lookup (no RGB antialias), low-frequency per-region growth tint, localized 1-3px road fringe interleaving, and small individual 2-5px ground-only blade strokes. Dense plant strokes restricted to grass and mostly PAR-uncovered pixels. 1,885 original bright-flower positions preserved. Three choices:
- R7_ORGANIC: 171 low-grass strokes, softer transition, insufficient ecological density.
- **R8_MEADOW ENGINEERING SELECTED**: 345 blade strokes, grass-in-sand 1,922 pixels / sand-in-grass 280 pixels; balanced richness at real native 544x416. Still user art PENDING.
- R9_LUSH: 456 strokes, 1,688 grass-in-sand / 175 sand-in-grass; higher density may visually clutter roads.
The authentic R5 image contains original flora and repeated mirrored reference tiles; source-first reflow changes many pixels (R8 vs R5 = 223,645 positions). This is intentional new Ground, not 'same source SHA'.
- Caution: the underlying source tile is still periodically reflected; the displacement **reduces visible repetition** but is not a guarantee of no remaining motifs. Avoid claiming no repeating texture without human visual acceptance.

## Mandatory engineering and delivery checks
- Keep RGBA/par object assembly *real*: Ground 544x416 opaque and separate byte-identical A32B PAR50 + twelve individual PNGs. Test Godot and RPG Maker VX using the SAME inputs; no single flattened picture as a substitute for layers.
- True VX Game.exe native 12 actor case/24 frame screenshot capture by RGSS Player HWND, west/east full/partial/front occlusion, foot blocking and open road, 0 modal errors.
- True Godot 4.7.2 RX6700XT OpenGL 8 outputs, compare actual render with independent PIL Ground+PAR composition. RGB tolerance 1 if measured; **must not claim zero difference unless measured**.
- Independent clone 3395/3395 file SHA256 and actual cold Map50 startup, not 24/24 identical screenshot cold parity.
- Archive stage with original source crops, chosen and rejected visuals, PNG SHA and failure register; user must visually sign off Ground before Formal Seal. Old original production battle regression remains unverified by isolated test.
