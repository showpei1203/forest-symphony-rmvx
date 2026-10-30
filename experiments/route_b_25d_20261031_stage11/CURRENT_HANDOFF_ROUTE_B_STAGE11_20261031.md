# Forest Symphony / Route B Stage 11 — Hand-authored 3D Crown Components
Date: 2026-10-31 | **ART FAIL, FORMAL SEAL = NO** | Branch isolated in E:\\FS_ROUTE_B_STAGE11_CROWN_COMPONENTS_20261031

## Authority and non-regression
- R17 Ground-first / separately native rendered PAR architecture; no reverse segmentation from completed image.
- Same Godot 4.7.2 orthographic 544x416 world/camera. Ground RGB full opaque, PAR RGBA transparent; 32x32 base Ground from same native CC0 oak GLB. The original FS VX RPG project, Scripts.rvdata, sealed maps and passability were NOT edited.
- Authoritative 3D source: Stage8 CC0 Innerscene detailed oak + Stage7 imported Witch Cottage + original authored roof shader and Stage10 woven baseline. Assets with provenance/CC0 source manifests retained. Old original Ground3 reference remains private (not bundled).
- Original Stage10 C candidate preserved byte-for-byte in baseline_stage10.

## Real new work
Stage11 is NOT merely a shader/recolor. `render_stage11_components.gd` extends Stage10 and adds **genuine native 3D geometry in PAR**: shaped scallop-edge leaf-mass panels built from triangles, recessed underside faces, visible upper surfaces with angular color variation, 5 articulated leaf fans per mass, plus tapered connections from center trunk to each clump. Geometry is deterministic, editable at source level; not post-process/image crop. Source 3D Ground, roof and root unchanged.
- Stage11 A BROAD: 26 large sculpted components / 24 branches / 1140 new triangles (two trees); broad green planar leaves too conspicuous.
- Stage11 B FINE: same 26 groups and topology with smaller silhouette; less obtrusive than broad.
- Stage11 C PRUNED: 20 components / 18 branches / 876 new triangles, deliberate gaps in selected radial clusters. Selected as *research candidate only*, modest gain and still below user's ground3 source reference.
- All variants passed original fixed six 32x32 actor placements. New 70-position static actor grid on C repeated from Stage10 (2 trees × 5 horizontal × 7 vertical); 20 front-labeled positions have exactly 0 occlusion. THIS IS NOT executable VX walking, sorting or collision validation.

## Measured native source-layer QA (all actual Godot renders)
- Native Ground RGB and PAR RGBA 544x416 / PAR alpha image border 0 for A, B, C.
- Ground changed pixels versus Stage10: **0 across all three**. Stage10 existing PAR opaque pixels lost: **0 across all three**.
- Newly opaque PAR silhouette pixels: A 329, B 254, C 243. PAR changed pixels are expected because new 3D canopy components are geometry, not unchanged-shape material.
- Independent full Godot 3D vs Ground+PAR composite mismatch: Stage10 C **903**; Stage11 A **1263**, B **1167**, C **1127** pixels. Pixel exact gate **FAIL** for all. C 1127 / 226304 ≈ 0.498%.
- Tree-contact mask: WEST native 15x24 x78..92 y136..159; EAST 11x22 x460..470 y132..153, both belong to exactly one screen 32x32 tile.
- Six actor fixed cases PASS 6/6; West/East front 0; rear heads >80% occluded; C actor static 70-point sweep with zero PAR obstruction in 20 marked front cases.
- House core color/pixels unchanged: 0 change in `compare_stage11.py` region; tree-only source edits.

## Visual finding / stop-loss
- A: recognizable expanded clumps but broad planar green texture; still artificial.
- B: less dominating plates, looks similar to existing Stage10; limited uplift.
- C: more branch gaps and smaller clumps; modest structural improvement, NOT premium painterly FS sprites.
- Stop extending this exact procedural 3D addition paradigm. Even more 3D triangles do not approach the user-provided high density `ground3` reference at screen resolution. Next stage should test professionally composed high-fidelity 2D sourced art / AI-authored coherent art components as native editable source layers, with Godot kept for mask/camera/depth validation. Do not upscale to a big village without visual approval. Do not destroy CC0 or sealed baselines.

## Source tests and handoff
`RUN_STAGE11_ALL_CHECKS.ps1`: deterministic texture regeneration; mandatory Godot editor import with separate stderr warning capture and process exit code; 3 separate actual native renders; proper load logs, Ground/PAR/mask mode; 2/2 root cell; actor 6/6; visual QA and 70-position actor static sweep; baseline compare and expected PAR alpha counts.
`compare_stage11.py`: native 1x 2x2 original and candidates; Ground invariant and PAR alpha preservation QA. 
`audit_walk_stage11.py`: 70 sample static positions; no claim to simulate real executable VX movement.
`package_stage11.py`: source/asset/QA ZIP with independent fresh directory cold-extract validation and cryptographic comparisons.
Outputs: out/STAGE11_4WAY_NATIVE_1X.png, out/STAGE11_TREE_DETAIL_4WAY.png, out/STAGE11_GEOMETRY_QA.json, out/STAGE11_ACTOR_WALK_SWEEP_70.png, out/STAGE11_ACTOR_WALK_SWEEP_QA.json plus all native GROUND/PAR/COMPOSITE/SCENE_FULL/TREE_CONTACT_MASK and QA data. Candidate source variants individually retained.
**Never call production READY/PASS before original art reference visually meets specification and VX executable integration/Gate F pass.**

## Cold rebuild result
- Full ZIP was extracted into independent E:\\FS_ROUTE_B_STAGE11_COLD_CHECK, deterministic textures regenerated, Godot 4.7.2 editor imported all assets, all three stages re-rendered and native Ground/PAR, actor checks, tree contacts, 70 point sweep and regression compare rerun successfully with exit code 0.
- **15/15 SHA256 exact matches** across source GLB, authored textures, native Ground/PAR, independent full scene, tree mask, final art comparison, 70-position sweep, and all three variant PARs.
- Root glTF `WARNING: The load-time scene is not defined` is nonfatal and is captured as stderr without producing a false failure. Source 3D model load is checked by log, not merely PNG existence.

## Final gates
COLD_REBUILD=PASS_SHA256_15_OF_15
STAGE11_NEW_EDITABLE_3D_GEOMETRY=PASS
NATIVE_LAYERS=PASS
TREE_CONTACT_CELL=PASS_2_OF_2
FIXED_ACTOR_TESTS=PASS_6_OF_6
STATIC_ACTOR_SWEEP=PASS_70_WITH_20_FRONT_ZERO
GROUND_BASELINE_IDENTICAL=PASS_0_DIFF
PAR_OLD_OCCLUSION_LOST=PASS_0
FULL_3D_COMPOSITE_PIXEL_EXACT=FAIL_1127
ORIGINAL_FS_ART_FIDELITY=FAIL
VX_RUNTIME=NOT_TESTED
FORMAL_SEAL=NO