# Forest Symphony / Route B Stage 10 — Actual 3D Crown Geometry
Date: 2026-10-31
Experiment: E:\\FS_ROUTE_B_STAGE10_CROWN_GEOMETRY_20261031
Authority: Stage9 verified, R17 native independent Ground/PAR source-first; **no source-master reverse mask**.
Formal status: ENGINE POC PASS / ART FAIL / FORMAL SEAL NO.

## Preserved source
- 3D Godot 4.7.2 on user's Windows + AMD RX 6700 XT.
- Stage8 Innerscene detailed oak original GLB (CC0) and Stage7 real 3D Witch Cottage; Stage9 leaf shading used unchanged.
- Native 544x416 Ground RGB and transparent PAR RGBA, world-camera aligned, not independent image generation.
- Existing RPG Maker VX sealed scripts, maps, collision, passability, K4, Stage9 source not modified.
- Original Ground3 visual acceptance remains the target, not reached.

## Real implementation (not a recolor)
Created render_stage10_geometry.gd (extends render_stage9_crown.gd): source-native 3D editable geometry extra leaf meshes anchored to each original CC0 oak tree. Ground tree-root objects unchanged. New crown geometry lives in PAR layer, no flattened image treatment.
- Variant A / LOBES: added 13 ellipsoid foliage lobes per tree; visually reintroduces disconnected colored green spheres -> negative example.
- Variant B / SPRAYS: extra 848 tiny leaf structures across two trees, 3,392 native leaf mesh triangles. Visually too scattered and noisy (detached confetti) -> negative example.
- Variant C / WOVEN: 668 grouped leaf-polygon constructions and their shared polygon centers, 3,610 native triangles across two trees. Subordinate leaves congregate around primary radial bough centers and preserve deliberate negative space -> most coherent tested candidate, but **still not ground3 fidelity**. This is real 3D geometry change.
- All variants rendered through actual Godot Compatibility engine and original native capture with 32x32 actor tests, never by text-only inference.
- Preserved baseline_stage9 and all 3 variants with native Ground, PAR, composite, scene full, tree contact mask and QA JSON.
- Added compare_stage10.py: 2x2 full native 544x416 comparative montage, region-specific shape-pixel comparison and diagnostic 4-way 1x crop/nearest-neighbor display.
- Added audit_walk_stage10.py: 70 actor movement positions (2 trees x five horizontal offsets x seven vertical offsets), same unchanged 32x32 actor mask and actual order Ground -> actor -> PAR; with 20 front-position tests (at y +16,+32) all 0% occlusion. These are **still static composited positions, not real VX executable movement**.

## Actual native Pixel QA
- Ground RGB unchanged **0 changed pixels** relative to Stage9 in all variants.
- A: new PAR alpha opaque +1,628 px, old PAR opaque lost 0; complete full-vs-two-layer independent 3D differing 417 px; boundary alpha 0.
- B: new PAR alpha opaque +3,542 px, old lost 0; full-vs-two-layer differing 1,355 px; boundary alpha 0.
- C: new PAR alpha opaque +1,494 px, old lost 0; full-vs-two-layer differing **903 px / 226,304 = ~0.3990%**; boundary alpha 0. Pixel-exact FAIL.
- Both unchanged screen tile contacts WEST rect x78..92 y136..159 (15x24); EAST rect x460..470 y132..153 (11x22). 2/2 PASS.
- Standard six actor checks 6/6 PASS in all three candidate variants. C still has front center actor occlusion 0%.
- Additional C 70-pos static sweep computed; **20 frontal offsets** across both trees all 0% PAR occlusion. Only qualifies specific positions and one test sprite; does not prove dynamic sorting or whole-map movement.
- A, B, C do not degrade Ground; all have PAR alpha zero on image border.
- Stage9 (prior) 3D-vs-composite differed 431 px; C worsens to 903 px; unresolved and no formal technical seal.
- Clear artistic ranking by side-by-side human review: A FAIL geometric puffs, B FAIL fragmented leaf confetti, C best but still too small/discrete and below real ground3, not a production-ready source.

## Important workflow guardrails
- Every fresh project must run Godot editor import BEFORE running a render, or empty/invalid GLB/PBR resources can deceptively write blank PNG outputs. RUN_STAGE10_ALL_CHECKS.ps1 enforces mandatory import and checks for model load lines and plausible PAR/Ground counts, not just presence of PNG.
- Source assets in raw source_raw/ and normalized/importable assets/ kept separate. Each scene uses identical coordinate system and native tree root ownership.
- Do not claim 70 dynamic actor test positions simulate actual RPG Maker VX runtime. Full Gate F, map import and collision test not performed.

## Reproducibility entrypoint
RUN_STAGE10_ALL_CHECKS.ps1
Steps: Python deterministic Ground and roof source regen -> Godot --headless --editor --import -> each of 3 Godot source renders -> qa.py -> audit_tree_contact.py -> test_actor_occlusion.py -> compare_stage10.py -> audit_walk_stage10.py, strong guardrails.
Original components and GLBs included in ZIP. New source provenance anchored in Stage7/8 manifests; no protected reference visual image included.

## Next phase
1. **Do not yet scale to larger village.** Best candidate C still visually far from dense 2D reference.
2. Consider artist-grade connected foliage meshes with actual hand-authored leaf bunches at multiple LOD scales, baked 3D lighting/occlusion shading and stronger architectural source; not endless random triangle patches.
3. Test character occlusion in actual VX scene before claiming production readiness. Source-native PAR 0.4% composite mismatch still present.
4. Re-run fixed camera, 32x32 contact, true-alpha and 70 actor positions after any further crown silhouette edit.

## Cold rebuild & automation regression
- Initial fresh-unzip RUN failed because PowerShell ErrorActionPreference=Stop promoted Godot's harmless glTF scene fallback WARNING on stderr into a terminating error. Not an import failure; fixed to use Start-Process with independently captured stdout/stderr and exit-code checking. This is a new workflow negative case.
- Rebuilt ZIP, extracted E:\\FS_ROUTE_B_STAGE10_COLD_CHECK, ran full RUN_STAGE10_ALL_CHECKS.ps1 including native Ground+roof generation, Godot editor import, three real GL renders, 2/2 contact checks, 6-position actor, 70-position actor sweep and all comparison checks. Exit code 0.
- Matched SHA256 of 15 crucial files including original GLB, both source images, native Ground/PAR, 3D full scene, composite, tree mask, 4-way comparison, 70-position audit and each variant's PAR: **15/15 identical**.

## Final Gate
COLD_REBUILD=PASS_15_OF_15_SHA256
NATIVE_RENDER=PASS
THREE_3D_GEOMETRY_VARIANTS=PASS
NATIVE_GROUND_PAR_544x416=PASS
TREE_CONTACT_SINGLE_32px_TILE=PASS_2/2
ACTOR_SIX_POSITION=PASS_6/6
ADDITIONAL_ACTOR_SWEEP=PASS_70_SAMPLES_WITH_20_FRONT_ZERO
GROUND_SOURCE_UNCHANGED=PASS_0
PAR_EXISTING_ALPHA_RETAINED=PASS_0_LOSS
COMPOSITE_PIXEL_EXACT=FAIL_903
FINAL_FS_ART=FAIL
FORMAL_SEAL=NO