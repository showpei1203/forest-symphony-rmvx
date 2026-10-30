# FS Ground-first R0 | 2026-10-30 | Ground Generation Feasibility

**Status:** `GROUND_ART=FAIL`, `BLUEPRINT_ALIGNMENT=UNVERIFIED/FAIL`, `PAR=NOT_STARTED`, `FORMAL_SEAL=NO`.

## Goal
Implement the 14-page user-provided research proposal "Forest Symphony 精靈村 Ground-first → PAR 生成流程可行性研究" without reusing old Stage7/12/13 PAR or touching the sealed K4/FS runtime.

## Fixed planning contract
- Canonical canvas 544x416 = 17x13 tiles of 32 px.
- Scene A, main elven-village street. Blueprint anchors: House A door (144,208), House B door (400,208), Sacred Tree root (272,304), central path junction (272,240).
- House A reserved (72,72,200,224), House B (344,64,472,224), Sacred Tree (208,184,336,352).
- Same blueprint MUST constrain both Ground and later independently authored PAR, but PAR must be gated behind Ground Art PASS.
- Tree-ground contact bottom 32px remains HOLD for a separate A/B test; do not override user-stated semantics.

## Actually executed (not planned)
1. Generated three independent **forest scene concept** images. Original dimensions 1434x1097, RGB. The generation did not provide reliable mask/bbox control or project reference conditioning.
2. Produced three strictly 1x, no-interpolation crops of 544x416, with original decoded pixels preserved. Crops: G1 x=445..988,y=325..740; G2 x=445..988,y=340..755; G3 x=445..988,y=345..760.
3. Produced blueprint-rectangle overlays, 2x nearest previews, and SHA manifest.
4. Re-ran a Python test validating that each crop matches the same exact pixel region of its source, and verified all manifest SHA-256 values. **Three source/pixel tests PASS**.

## Critical visual result
- Generated source art contains upright trees, fences/stumps, and other standing material forbidden from Ground-only. Cropping those images is NOT a legitimate substitute for conditionally authored Ground.
- The crops have natural grass/path texture examples but no proof of the specified door/path contact or tree root location. Reserved areas visibly intersect central roads and/or incompatible terrain.
- Comparison to the exact original `ground3` and `SCENE21` pixels was not performed within this turn. Human Art PASS is not claimed.
- The initial target of four true Blueprint-conditioned seeds was NOT achieved: only three nonconditioned conceptual samples were generated; G4=NOT_RUN.

## Stop-loss decision
**Do not start PAR.** No run in Godot or VX; collision, passability and sealed `Map.rvdata`/`Scripts.rvdata` untouched.

## Next engineering action
Use original project style reference images, and a generator/authoring process that receives the Scene Blueprint as actual layout/mask/bbox inputs. Generate four truly independently authored 544x416 GROUND-only candidates (no standing objects), then apply the Art Gate before any PAR generation.

## Local QA bundle
`FS_GROUND_FIRST_R0_20261030_ART_FAIL.zip`
- Source original RGB images and 544x416 pixel-exact crops
- `blueprint.yaml`, `manifest.json`, `scripts/verify_r0.py`, `QA.log`
- Contact sheet, per-candidate Blueprint overlays, 2x nearest-neighbor QA previews

Local ZIP SHA256:
`a345c884f3e76ff3468957fca494dad8c522b279e2b8952de9b77a5447785358`

**Binary ZIP has not been uploaded to Drive.** GitHub contains the text audit only; image provenance remains local conversation artifact. No official release or Final Seal.
