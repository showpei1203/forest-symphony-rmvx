# R12｜NEW_ELF_VILLAGE_001｜Controlled Full-size Art & VX Acceptance Gates
**Plan authorized by R11 tech evidence, no R12 image generated yet, not an art PASS.**
Source of benchmark: original FS K4 `ground3.png` 1280×928 / 40×29. User wants similarly rich pixel-detailed original village/field scenes (not primitive tiles or repeated prefab patterns), from user-owned source/authorized tiles. Do not copy the existing ground3 wholesale and label a new creation.

## Output contract
- `MASTER_NEW_ELF_VILLAGE_001.png`: 1280×928 at native exact 1× pixel density and correct top-down 3/4 visual, transparent not required; coherent grass/dirt, refined trees/buildings/rocks/flowers, winding road and margins. Distinct structures; no missing roofs, chopped barrels/stumps, low-quality tile repetitions, blurry 1x surfaces.
- `PAR_...png`: 1280×928 RGBA, every non-transparent RGB source-matched to the exact newly generated Master. No independently regenerated PAR. Include all independently raised occluders: high conifers, buildings, shrubs, low rocks and garden props, regardless of size. Exclude floor/road/stairs/flat grass & flowers by user semantic policy. If mixed tiles, cut α object, never blindly whole 32px tile.
- `OBJECT_REGISTRY.json`: all physical object IDs; type, bounding ROI, foot anchor, standable footprint (polygon or tile mask), occlusion semantic, source mask, collision independent policy, operator-approved yes/no, confidence/review flags.
- `MAP_40x29_CANDIDATE.rvdata`: third-layer ISS ParaPassa passable 769 by default except actual geometry/water/holes/cliffs/solid roofs; no reuse of SCENE21's 17-block model for new village.
- `LIGHT.png`, `SHADOW.png`, `LOOP_GROUND_0..N.png` if used: same canvas and native alignment; Ground animation loop must be tested against source FS #146 or safe local adapter; never claim animated art until tested.
- Native VX Test Build, six directional camera/terrain edge positions, user-visible 1× screenshots without HUD obstruction, JSON source hash and all Gate A-F results.

## Fail-closed sequence
A. STYLE: Master native 1280×928, explicit 1× visual and comparison against ground3, no blur/seams/repeated tiles, architecture consistent. If fail regenerate Master; no collision or build claims.
B. AUTHORITY: per-object ROI + foot depth + collision footprint registration. Verify all roof/fauna/foliage raised objects, including tiny ones; roads/stairs are hard-excluded from PAR.
C. SOURCE: parse source RGB and transparent PAR exact alignment at every pixel. Alpha mask object completeness and 1× source visual review. Flag missing/overselected object, do not "fix" Ground by inpainting.
D. PASSA: collision uses geometry, not visual alpha size; all 40×29 cells third layer with 769/768 & special states as warranted; unit tests for paths, door 1-cell approach, terrain.
E. NATIVE: original FS VX Game.exe scene size 40×29; camera scrolling and source-pixel dynamic PAR; A1/B/A2 same-position comparisons at multiple camera offsets, 4 directional actual move, NPC front/behind, blocked and pass, sprite occlusion match and background unchanged. Animated ground, light, shadow if present tested, no hidden HUD for Visual QA.
F. ART HUMAN: user acceptance vs ground3 and elf village reference. No "PASS" unless accepted. Preserve failed revisions & reasons in Drive/GitHub/Linear; Final Seal only after all Gates.

## Current readiness
- Verified 40×29 Ground native Game.exe viewport, original Map003 passability and actual player moves: PASS.
- Verified 5 full-size 1280×928 SAM2 original-color objects dynamically positioned with correct camera math: TECH PASS.
- Verified **novel Master generation** at this artistic fidelity: NOT TESTED.
- Verified **full scene** source-semantic occlusion segmentation: NOT TESTED.
- Verified whole-house and collision polygon semantics: NOT TESTED.
- Verified full original 505-page scripts/events + loop/light/shadow: HOLD.
- **Decision**: BEGIN NEW_ELF_VILLAGE_001 as a separate candidate after acknowledging limitations. Do not modify the existing other-dialogue village branch or ground3 source.

## Next production step
Build one full-size `MASTER_NEW_ELF_VILLAGE_001.png` from authorized source objects and pixel-art generation, no parallax split until the **1× native-image quality Gate A** passes. On failure repeat Master stage, not route to pseudo-PAR or falsely mark user acceptance. 