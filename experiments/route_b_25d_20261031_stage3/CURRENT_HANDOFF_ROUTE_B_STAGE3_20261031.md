# FS ROUTE B STAGE3 / SINGLE ELF COTTAGE PREFAB / 2026-10-31
## Stage status
**Real Godot 4.7.2 render and cold-source authoring; NOT formal art pass.**
STAGE3_PREFAB_EXPORT=PASS
GROUND_NATIVE_RGB=PASS
PAR_NATIVE_RGBA=PASS
PAR_BORDER_ALPHA=PASS
PREFAB_VS_SOURCE_RENDER_HASH=PASS
FULL_3D_RENDER_VS_2_LAYER_PIXEL_EXACT=FAIL (2,728 pixels)
FS_PIXEL_ART_REFERENCE_MATCH=FAIL
FORMAL_SEAL=NO

## Scope and non-regression
Isolated Stage3 under E:\\FS_ROUTE_B_STAGE3_COTTAGE_20261031.
The sealed RPG Maker VX binaries / Map.rvdata / Scripts.rvdata / K4 / collision and passability were NOT edited. Stage2 source and results preserved. Stage12 art rejection still governs the original FS output.

## Authored deliverables
- cottage_prefab.gd: reproducible, parameterized Godot Node3D builder with 3D roof slope / distinct tile surfaces, roof ridge, native timber frame, doors, flower-box windows, chimney and path-contact geometry.
- export_prefab.gd: packs source-generated meshes into FS_Elf_Cottage.tscn (214 nodes).
- FS_Elf_Cottage.tscn: **actual editable Godot scene prefab**; 3D visual objects placed in PAR collision mask 2 and contact/ground pieces in mask 1.
- render_cottage_stage3.gd: creates full world plus loaded .tscn instance, source GLB plants/trees and fixed orthographic 544x416 camera.
- render_cottage_source_stage3.gd: historical source-driven render for byte-comparison.
- render_scene.gd, render_stage2.gd, qa.py, diff_audit.py: 3D capture, GLB palette/texture handling, QA & discrepancy map.
- out/GROUND.png RGB, PAR.png RGBA, COMPOSITE_PREVIEW.png, SCENE_FULL.png, QA_4PANEL.png, COMPOSITE_DIFF_HIGHLIGHT.png, QA_REPORT.json, COMPOSITE_DIFF_REPORT.json.

## Evidence and results
- On user Windows desktop Godot 4.7.2 / RX 6700 XT, native captures GROUND and PAR each 544x416.
- PAR transparent pixel count=175,467; nontransparent=50,837; alpha at image border exactly zero.
- Composite against independent full 3D scene differs at 2,728 of 226,304 pixels = 1.205%. RGB MAE 0.0611, max channel error 101. Mismatch clustered on roof tiles, lower wall/entry and small ground contact; not a whole-frame alignment offset.
- Source generated procedural house and .tscn-loaded house produce **identical COMPOSITE_PREVIEW.png SHA256** on same runtime.
- House square grass rectangle removed from Ground; contact colors isolated by original source components. Character occlusion/FS passability not tested.
- The building silhouette, coherent roof, facade and planters have visibly improved over Stage2, but final quality remains far below the user's ground3 and elf village image. Ground is still flat and simplified, scene overall remains unshaded stylized 3D, not exquisite painterly pixel art. Do not claim art completion.

## Critical technical caveat
Source 3D object and Ground/PAR layered composite share identical camera/world geometry, but independent full 3D rendering is not pixel exact. Significant differences on roof parts and contact areas remain. Separate ART / TECH gates; do not call production PASS based solely on dimension and alpha.

## Next step / Stop conditions
1. Improve real art source, not scatter procedural dots. Compare a single cottage 1x against user's reference, then investigate soft shadow and roofs/facade.
2. Resolve 3D-vs-layer pixel mismatch with geometrically supported render priority/occlusion pipeline, or explicitly define 2D composite as authoritative and independently test character occlusion behavior.
3. Create palette and pixelization A/B for cottage only at *native 544x416*; compare crispness and detail.
4. Only if single cottage art gate passes, expand to adjacent house, rocks, fence and forest. No large village and no collision scripting until user acceptance.