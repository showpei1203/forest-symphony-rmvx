# Forest Symphony | Route B 2.5D Godot Ground/PAR POC | 2026-10-30

## Objective
Test whether a single 3D scene with a fixed orthographic camera can produce a matching 544x416 GROUND and genuinely transparent PAR. No complete 2D master is reverse-cut. Existing FS/RPG Maker VX baseline is untouched.

## Tools
- User Windows PC DESKTOP-90VT437, AMD RX 6700 XT
- Godot 4.7.2, Compatibility/OpenGL 3.3
- Python 3.11, Pillow, NumPy

## Reproduction
1. Open the folder containing project.godot.
2. Run: E:\\Godot\\4.7.2\\Godot_v4.7.2-stable_win64.exe\\Godot_v4.7.2-stable_win64_console.exe --path <project folder> --rendering-method gl_compatibility --script res://render_scene.gd
3. Run: python qa.py
4. Review out/QA_4PANEL.png, out/GROUND.png, out/PAR.png, out/COMPOSITE_PREVIEW.png, out/QA_REPORT.json.

## Actual results
- Ground and PAR are each native 544x416 outputs of the same 3D world/camera, using per-mesh render layer masks 1 and 2.
- Ground is native RGB (fully opaque); PAR is native RGBA with 178,389 transparent pixels, 47,915 nonzero alpha pixels; transparent border zero.
- Alpha composite vs separately rendered full scene differs at 259 of 226,304 pixels (~0.114%) / RGB MAE 0.02685. This is NOT pixel-exact.
- Camera initialization issue, transparent-background color mismatch and edge leakage were found and corrected during real Godot execution.
- Geometry includes 2 cottages, 4 trees, cobble paths, fence, lamps, small plants and coordinated object footprints.
- NOT a formal art pass. Result is low-poly prototype, too flat/simple for user's high-quality pixel elven village. Manual art approval pending.
- This version deliberately uses unshaded materials for reliable PAR-composite color. Need a proper baked-lighting/correct alpha workflow before adding complex shadows.
- NO changes to sealed VX project binaries, scripts, collision, passability or any previous approved baseline.

## Next steps
1. Replace gray-box geometry with artist-quality 3D modular source asset kit or verified open-licensed models. Keep 2.5D camera, scale, common world coords and capture masks.
2. Compare 1x 544x416 source images against ground3 and elf-village art reference; pixel style gate, density, roof/front coherence, contact shadows.
3. Test a color-consistent baked-lighting pass, optional 2x-low-res pixel sample / nearest neighbor, and prevent pixel halos at transparent edges.
4. Only after visual approval automate output for FS Ground-first/PAR workflow. Do not touch collision.
Status: TECH POC / ART FAIL / FORMAL SEAL NO.