# Forest Symphony | A35 R2 | New tree silhouettes & Godot QA | 2026-11-15

## Scope / retained sources
- Godot 4.7.2 map-art only, not RPG Maker VX, not separate A36C large-forest branch.
- Base: A35 R1 owner-only ZIP 195 members, source SHA preserved; immutable scene `res://scenes/a35_r1_forest_groves_scene.tscn`, all historical A32/A33/A34 scene files preserved.
- New candidate scene `res://scenes/a35_r2_new_species_scene.tscn`. Default project scene updated only in the private candidate; original Ground unchanged SHA `3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000`.

## Real construction
- 8 full independent new transparent PNG silhouettes: cypress, willow, elder, fir, birch, oak, needle conifer, maple. Each drawn at its final 1x pixel dimensions (90..172w by 152..185h) without resampling.
- New foliage rendered using unscaled 8px original FS texture patches within newly authored tree canopy and trunk silhouettes. This is a source-derived procedural visual candidate, *not* eight independently hand-painted premium sprites. See art limitation.
- 32 out of 41 A35 R1 new-grove tree bindings were replaced, 9 kept for variation. Total **187 independent PAR** and **175 tree owners**, each with footpoint Y-sort, physical root CollisionShape2D, source_path+SHA. Replacements preserve anchors and physical collision footprints.
- Source-only builder `tools/a35_r2_build_new_species.py`, replayable native tests and pixel QA included.

## Godot-native verification
- Official Godot 4.7.2 Windows, AMD RX 6700 XT; initial test failed to load PNGs before editor import, then **editor import Exit 0**, source SHA/collision contract **Exit 0**.
- **Native physical navigation PASS 8/8 gates, 4/4 routes**, newly blocked protected road cells 0, exit 0.
- **GPU OpenGL 3.3 native 1280x928 capture PASS (4 images)**. Comparing A35 R1 vs R2, 149,047 changed native RGB pixels inside union(old,new) tree ROIs, **0 outside**, exit 0. First test wrongly used only new bounding rectangles and reported 187 outside; fixed union and rerun.
- Source PNG QA: all 8 hash and size PASS; full ZIP CRC PASS; A35 R1 scene and Ground byte-immutable.

## Status / remaining art issues
ENGINE PASS, NAV PASS, ROI PASS, **ART HOLD**. New crown textures have obvious tiled patches and overly smooth canopy geometry at native 1x. They need visual refinement / hand-pixel review before declaring FS-quality art. Source screenshot outputs remain on remote testing session, not yet included in private ZIP (so native proof is runtime log here, not screenshot bytes).

## Art + collision next
- Refine native crown texture synthesis so source tiles do not repeat; increase irregular leaf outline and trunk foot realism, keeping R2 as reversible candidate.
- Re-run native full frame, character back/front occlusion screenshot, and exact old+new union ROI checks; independently inspect at 1x; mirror real PNGs to owner-only Drive.
- Continue Ground3 native pixel density and seamless biome transition work only after the tree styles fit Ground and village architecture.

## Public/private boundary
- Private owner-only ZIP contains PNGs, build sources, QA reports. Do **not** publish new tree PNGs publicly. GitHub branch only source, manifest and QA. No public share permissions.