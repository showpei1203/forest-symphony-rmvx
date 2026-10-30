# FS Route B / Stage 9 — Native Crown Art Shading A/B
Date: 2026-10-31 | Status: POC; VISUAL FAIL; FORMAL SEAL=NO

## Authority and protection
- Isolated additive experiment at E:\\FS_ROUTE_B_STAGE9_CROWN_ART_20261031; Stage 8 and all existing FS VX sealed baselines untouched.
- Continue R17 Direct Ground / PAR authority: authentic 544x416 Ground RGB opaque, PAR RGBA transparent, fixed single-world camera, **no reverse cut from a flattened 2D master**.
- Existing original GLB model remains the same CC0 Innerscene Oak detailed tree (Stage8 SOURCE SHA256 17e83e82b33a48e324cd3e479a89d0eee91046e6250e213fa326ceff587fad2e) and Stage7 Witch Cottage + source roof material; no claim of new tree geometry.
- Model scale and fixed world height clip 0.56 preserve tree contact source in Ground layer 4 and upper crown PAR layer 2. Character test is Ground -> fixed 32px actor -> PAR.

## Actual implementation
1. Forked verified Stage8 project, source GLBs, scripts and baseline native rendered PNGs.
2. Added render_stage9_crown.gd (extends render_stage8_oak.gd), a source-native 3D spatial shader: 3-step directional lighting A ('bands'), and 3D-world-position leaf clump color bands with under-canopy shade B ('clusters'). No composited post-processing, resizing, smoothing, or flattening of Ground/PAR.
3. First executable call **failed** because project-local Godot imported resource cache was missing. The misleading blank outputs were discarded; isolated GDScript/GLB import must run with Godot --headless --editor --import before render. Both GLB imports were read back success.
4. A and B original shader color choices were too luminous; screenshot of first B was visibly neon. Preserved both as candidates/bands_too_bright and candidates/clusters_too_bright. Corrected to darker natural tones, reran both with strict actual renderer and original 6-position actor regression.
5. Final native candidates: candidates/bands and candidates/clusters. Original Stage8 source remains in baseline_stage8. Actual PAR alpha compared pixelwise with Stage8 in all four variants: **0 changed alpha pixels**, so native occlusion geometry and 32px source split are preserved.
6. Authored compare_stage9.py and generated out/STAGE9_STYLE_ABC_1X.png (Stage8 -> A -> B; each native 544x416 unchanged), out/STAGE9_CROWN_DETAIL_4WAY.png (nearest-neighbor zoom for diagnostic ONLY), out/STAGE9_ART_COMPARE_QA.json.
7. Selected B CLUSTERS as research candidate for relative material harmony and clump shade. Selection is provisional, still art FAIL vs user ground3 and reference. This changes *materials*, NOT actual topology, so do not claim 'higher density geometry'.

## Measured actual final result
Godot 4.7.2 Compatibility on AMD RX 6700 XT. Fixed native 544x416.
- Native RGB Ground, RGBA PAR; PAR border alpha nonzero = 0.
- Tree contact in Ground: WEST [78,136,92,159] = 15x24; EAST [460,132,470,153] = 11x22; both complete within one 32x32 screen tile.
- Fixed actor regression (after both A and B): WEST behind total obscured 84.19%, head 85.238%; AT_BASE total 38.538%, FRONT 0%. EAST behind total 87.352%, head 89.048%; AT_BASE 36.561%, FRONT 0%. All six original constraints PASS without relocating actor.
- Independent full 3D render compared to native Ground+PAR composite: Stage8 = 406 differing pixels; Stage9 A = 464; Stage9 B = 431 / 226,304 (~0.19046%), still **FAIL** pixel-exact.
- PAR alpha geometry Stage8-vs-A,B, and discarded bright candidates: **exact 0 differing pixels**.
- The original tree area content zone (includes backdrop) dark pixel share below mean RGB 89: Stage8 1.50%; Stage9 A 22.99%; Stage9 B 18.01%. Descriptive only; not art-quality thresholds.
- Stylized crown more visibly shaded but still too coarse/dark vs high-density FS ground3 foliage, and brown/tan Witch Cottage + path still not an exact visual match. Human visual acceptance absent.

## Deliverables and reproducibility
- RUN_STAGE9_ALL_CHECKS.ps1: cold project import, run BOTH style variants with source Ground/PAR render + tree 32px + actor QA, compare and enforce alpha zero.
- render_stage9_crown.gd: actual code; both are native 3D material variants.
- candidates/bands/, candidates/clusters/, too-bright negative cases, plus untouched baseline_stage8/.
- out/STAGE9_STYLE_ABC_1X.png, out/STAGE9_CROWN_DETAIL_4WAY.png, out/STAGE9_ART_COMPARE_QA.json; out native GROUND.png, PAR.png, TREE_CONTACT_MASK.png, SCENE_FULL.png, COMPOSITE_PREVIEW.png, QA_4PANEL.png.
- Original glb sources, authored 3D cottage and source material, scripts, QA, and source provenance in ZIP. No source/asset licensing silently altered.

## Next step (not performed)
1. Stage10: experiment with actual multi-scale leaf cluster geometry / crown silhouette and painterly source material, not another simple palette recolor. Preserve 32x32 trunk and six actor positions.
2. Assess real 32px actor traversing multiple Y positions and eventual VX executable Gate test.
3. If user reference art still fails at native 1x, STOP expansion and seek artist-quality source asset compatible with FS style. Do not tile a full village based on this POC.
4. Remaining full-scene 431 pixel differences remain unresolved. Never claim pixel-exact or formal PASS.

## Final Gates
COLD_SOURCE_REPRODUCIBILITY: PASS (15/15 SHA256 from fresh unzip, original 3D GLB+texture and Godot re-render+QA both A/B) 
GROUND_PAR_NATIVE_AND_ALPHA: PASS
TREE_BASE_32PX: PASS_2_OF_2
ACTOR_OCCLUSION_FIXED_6: PASS_6_OF_6
PAR_ALPHA_GEOMETRY_NO_REGRESSION: PASS_0_DIFF
INDEPENDENT_FULL_COMPOSITE_PIXEL_EXACT: FAIL_431
VISUAL_REFERENCE_GROUND3: FAIL
FORMAL_SEAL: NO