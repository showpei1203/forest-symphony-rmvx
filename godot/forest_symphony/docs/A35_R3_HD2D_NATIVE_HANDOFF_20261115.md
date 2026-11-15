## Verified private complete artifact (Drive readback)
- [FS A35 R3 HD-2D Native QA full release](https://drive.google.com/file/d/1xWgVRNW2bLL9XUBZvc6I1vP7W8BQdX9-/view) (owner-only, **shared=false**, 108,931,403 bytes, 236 members, CRC PASS).
- SHA256 `16a707417d65dc41eeb12919a52b560af26a9860d888f560f740e785c018797c`.
- Original real Godot captures, also owner-only: [DAY](https://drive.google.com/file/d/18hz0XhDHkIVAdazr-y9WRBkDkyK7MZ-x/view), [DUSK](https://drive.google.com/file/d/1N-YPJ4nIoDUyP_S-t1379d0SCM8T5-R2/view), [NIGHT](https://drive.google.com/file/d/1qCgN_T7NiNazeR_vreIKiW60zUVFd3yh/view).
- Native pixel differences: DAY-DUSK 1,185,598 changed pixels (MAE 13.4242), DAY-NIGHT 1,187,405 changed pixels (MAE 32.6205), DUSK-NIGHT 1,187,262 changed pixels (MAE 19.2291).
- Full source artifact includes all three GPU screenshots, source and GPU logs, corrected test script, CRC+SHA report, current handoff and failure log.
- Native contract **PASS**, lighting artistic acceptance and the 8 R2 crown families **HOLD**.

# Forest Symphony | A35 R3 HD-2D Native Handoff | 2026-11-15

## Ownership and correct baseline
- This workstream is FS Godot 4.7.2 **map-art and optional HD-2D lighting**, NOT RPG Maker VX or the parallel A36C large forest.
- Source is **A35 R2 owner-only sealed full ZIP** `FS_A35_R2_COMPLETE_NATIVE_RELEASE_PRIVATE_20261115.zip`, Drive file ID `16HaP7PUWKbP9SPvsYtdmT6dULJtr4dIy`.
- Preserve R2 baseline source, original A35 R1 and unrelated A36C. No private full PNG on public GitHub.
- Source branch: `feat/fs-a35-r3-hd2d-20261115`.

## Actual code implemented
1. `scripts/a35_r3_hd2d_fx.gd`: separate Godot Node2D with CanvasModulate day/dusk/night tint; 4 PointLight2D warm lamp glows; ambient shafts, dust motes, rain strokes; keyboard N for 3 phases, V rain toggle, L entire FX toggle.
2. `tools/a35_r3_hd2d_build.py`: immutable sealed R2 ZIP input -> additive `scenes/a35_r3_hd2d_layered_scene.tscn`; source files and native test/capture scripts. Original R2 scene/187 PAR trees/Ground bytes preserved.
3. `tests/test_a35_r3_hd2d_real.gd`: Godot native asserts 187 PAR positions and paths remain unchanged, original Ground SHA remains `3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000`, FX attached.
4. `tests/capture_a35_r3_hd2d_native.gd`: actual GPU day/dusk/night output 1280x928, not Pillow.
5. `tools/a35_r3_finalize_native.py`: private ZIP packaging native PNG evidence/QA/Failure Log. Read PowerShell Tee-Object UTF-16 logs.

## Native testing verified, not just planned
- Engine: Godot 4.7.2 stable official; GPU AMD Radeon RX 6700 XT, OpenGL 3.3 Compatibility.
- Cold Godot editor import Exit 0.
- Godot native scene/PAR source test **PASS Exit 0**, all 187 PAR sources and positions unchanged and R2 ground SHA intact.
- Godot GPU native day/dusk/night capture **PASS Exit 0 (3/3 images)**. Actual 1280×928 PNG files `A35_R3_HD2D_DAY_NATIVE.png`, `A35_R3_HD2D_DUSK_NATIVE.png`, `A35_R3_HD2D_NIGHT_NATIVE.png`.
- R2 character occlusion and physical navigation prior PASS. **R3 did not re-test full physical navigation**; only checked unchanged object sources and positions. Do not claim R3 NAV retested.

## ART remains HOLD
- **R3 HD-2D lighting is an optional atmosphere prototype, not complete HD-2D renderer.** Current source retains all R2 trees; the eight R2 crowns' repeating foliage/tile patches, blob-like silhouette remain ART HOLD. The separate organic-canopy exploration has no native QA/approval and is NOT integrated in this release.
- PointLight2D shadows and per-tree LightOccluder2D, true DOF and volumetric 3D lighting not implemented. Sunshafts are 2D polygons, rain/motes are 2D draw commands.
- Artist to inspect direct 1x screenshots before accepting saturation/contrast and lamp positioning.

## Sources, release and handoff
- Original owner-only R2 private artifact: https://drive.google.com/file/d/16HaP7PUWKbP9SPvsYtdmT6dULJtr4dIy/view
- Owner-only Drive R3 workspace folder: https://drive.google.com/drive/folders/1zigGjPHA-2tJM2RzInLpqLGGIk4Bhw2T
- Private intended final release name `FS_A35_R3_HD2D_NATIVE_QA_PRIVATE_20261115.zip`, VERIFIED uploaded and read back from owner-only Drive; SHA and file link above.
- Commit to this branch only, no overwrite of original R2 or A36C.

## Next work: R3 ART (not A33 reset)
1. Repair all 8 crown silhouette and texture families using multi-scale organic cluster accents. Keep fixed anchor, footpoint, root collision, 187 owners / 175 trees and 32 source swaps.
2. Pixel-by-pixel 1x A/B crops against original FS map house/ground; prevent same 8px pattern repeats and over-smoothed foliage shapes.
3. Re-run Godot editor import, native source QA, original R2 physical navigation 8/8 gates & 4/4 routes, front/back occlusion, old+new ROI union and GPU screenshots for art.
4. Only after ART PASS move to Ground3 road/grass/flowers and shade occluder/lighting polish; all stages finish Failure Log + Handoff.
