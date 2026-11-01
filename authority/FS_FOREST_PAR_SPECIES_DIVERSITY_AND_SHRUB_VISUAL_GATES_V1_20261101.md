# Forest Symphony | Forest PAR botanical diversity and shrub quality gates v1.0
Date: 2026-11-01. ACTIVE process rules; NOT aesthetic signoff.

## Provenance and visual semantics
A33D had 13 trees but 9 added tree images were scaled/mirrored derivatives of four existing approved broadleaf source sprites. More objects is not automatically a more natural forest. For the next A33E isolated candidate, use *real source-shape diversification*: original user Drive source `tree01.png` (dark compact fir silhouette) and `Hanzo-VSTrees03.png` (needle-detail tall conifer). These introduce **two new source species/forms**. Source tree crops must have explicit parent/source hashes, crop rect and alpha boundary inspection, not pretend to be AI-created new species.
Four A33D repeat-heavy tree slots use new complete alpha conifer imagery, keep exact X/Y object ownership and approved foot tile; two additional conifer instances get two NEW verifiable blocked foot tiles. Individual image can change width/composition within its protected canvas, but clipped silhouettes or glow/shadow-as-PAR FAIL.
Shrubs are independent new **programmatically generated** small grouped-leaf RGBA images, not extracted from unrelated reference photos or flattened Ground. They are **nonblocking** flora, but still get explicit `foot`, 2px transparent margin, y-sort and source_kind PROGRAMMATIC. At native 1x size, shrub detail should be visible; if 9 shrub images are too tiny against meadow material, **ART still pending**. Don't conflate object count with user-perceived richness.

## Ground vs PAR
Keep 544×416 opaque full Ground separate from truly transparent complete PAR50. Source flower coordinates (A33C/A33D 1885 bright flora positions) retained, original road RGB exact, new modest forest-floor sprouts only in source floor RGB. Environmental SHADOW and LIGHT belong to separate layers; do not bake cast shadows, ambient light, sunrays, contour-like black bands into Ground or PAR. Internal foliage microshading is not a cast shadow.
Original A32B 12 approved individual tree/rock/barrel/lamp image bytes are fixed; A33D candidate remains independently stored, A33E changes only isolated project.

## Gameplay
- Collision via `Map050.rvdata` E-layer tile 768/769; original A33D had 21 blocked/200 free and BFS 200/200. A33E added 2 distinct nonroad conifer foot tiles (7,5) and (16,6), now 23 blocked/198 connected walkable. Original 21 blocked tiles unchanged. Nine tiny shrub RGBA never block.
- Source test-only RGSS Script 483 dynamic `A30_MAP::OBJECTS` lists all 32 **independent Cache.overlay PNGs**; original other 506 script payloads byte-identical. This is isolated native map test; old production BattleRegression alias bypass remains unsolved, don't install test script in production.
- Actual VX Game.exe actor 18 scenarios/36 real 544×416 RGSS HWND captures; old road right move (8,6)->(9,6), old blocks and new left (7,4) down to (7,5), right (16,5) down to (16,6) stay blocked, 0 RGSS modal. Actor behind original canopy and new source tree must be tested, not merely a composite.
- Godot 4.7.2 AMD RX6700XT native OpenGL 16 screenshots, independently compare actual noactor native output to PIL original Ground+32 y-sorted separate PAR objects, max RGB channel delta1, 0 >1. Report exact not zero.
- Separate cold VX file-by-file SHA and actual startup Map50 32 object logging, no modal. User art review and **formal seal NO** until user approves visual and main production regression is resolved.

## Anti-regression failure log
Misleading prior assistant remote unavailability assertion was contradicted by actual Remote Desktop Commander list_devices and execution. Check availability with tool, do not block work with a 'paste elsewhere' handoff.
Do not infer visually new forest species from mirrored/toned broadleaf copies. Big tree crowns, needle conifer trees and clearly visible foreground shrubs should have diversified sizes/hues and biological grouping, not random decoration. Always compare old and new native VX 1x/nearest 2x crops before signoff.
