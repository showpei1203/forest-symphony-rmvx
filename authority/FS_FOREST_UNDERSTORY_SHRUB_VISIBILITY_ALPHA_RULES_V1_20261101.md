# Forest Symphony Ground + PAR | Forest understory: 1x shrub visibility & alpha rules v1.0
Date: 2026-11-01. ACTIVE production QA, separate from acceptance of A33F candidate.

## Why this exists
A33E introduced real two-source-species conifers and nine independently owned leaf-bunch shrubs. However A33E shrubs (32–40px width, 20–27px height) were too subtle at native 544×416, so neither "9 shrubs" nor 32 PAR object count guarantees art richness.

## Original assets and strict layer responsibilities
- A32B user-approved 12 standalone tree/prop RGBA must remain byte-identical; A33D and A33E stages remain separate immutable history. A33F uses exactly 15 A33E trees and 32 total independent PAR objects.
- Every shrub is an individual alpha PNG with explicit X,Y, immutable foot/ownership. Existing nine A33E shrubs are REPLACED in R2, not counted as nine new object IDs. Three botanically distinct silhouettes: clustered broadleaf, discrete frond ferns, and small flowering shrub. Avoid using just color changes to call species new.
- Ground is one independent opaque 544×416 PNG; no tree or shrub flattened into it. PAR50 alpha-composed by foot ascending from separate source PNG, never independent all-in-one image substituted for layers.
- Environmental SHADOW/LIGHT are NOT merged into Ground or PAR. Internal foliage pixel detail permitted, no shadows cast to grass and no random contour-like black lines.

## Style/art gates
- Inspect both isolated checkerboard shrubs and final native VX 1× full scene. Large shrubs still must not overwhelm road or hide important map props. Native-pixel nearest-neighbor details, complete transparent margin, no cut alpha edges, no anti-alias smear.
- Habitat-level ecology, not global grass particle spray: multiple contiguous large grass communities, fern + broadleaf + flowering understory, original 1885 bright source flower pixel positions retained. Road RGB pixels must remain **exactly** A33E; do not shift path shape or change road collisions.
- Source A33B erroneous dark grass line detector class `R<105 && G<124 && G>1.12R && B<46 AND !road` must remain 0. This is a limited visual regression metric, not a substitute for human art judgment.
- R1/R2 compare, R2 selected: 9 habitat bands, 285 actual small plant colony centers / 2133 native leaf stems / 74 native little flowers, exactly 1885 original bright-flora pixel positions preserved; A33F Ground SHA `39d9b1163eb44ed46a614c5d93029300f7a99df47e079cf905620905009b5e72`, PAR50 SHA `05a8f5e1e2253c7fe7c547c8e904c548b2f367b0b5ca18de341ad25913cd0626`.
- Shrub specific visual limits remain subject to user acceptance: R2 gives bigger clustered leaf bodies but not a fully original reference-quality landscape. Avoid declaring art PASS from metrics.

## Real engine QA and protection
- Original A33E native Map050 E blocking stays byte-for-byte identical: 23 blocking, 198 walkable, BFS 198/198; nine shrubs are **nonblocking**. All old tree blocker cases and road move must still succeed.
- Source RGSS2 Test Script 483 differs only by nine updated shrub sprite filenames and coords; other 506 script compressed payloads identical. Real VX Game.exe 18 positions/36 screenshots, 32 individual Cache.overlay loaded, native 0 error modals.
- Real Godot 4.7.2 AMD RX6700XT OpenGL 20 frames; independent Ground+32 object PAR vs true Godot no-actor image 3765 pixel positions max RGB channel1, 0 >1. Do not claim exact-zero.
- Separate native VX cold clone 3415/3415 file SHA and live Map50 loaded, 0 modal; not 36/36 exact replay. Isolated map-only harness **contains historical battle-regression bypass**, DO NOT ship its Scripts.rvdata into formal production. Formal Seal NO pending official production and user art acceptance.
