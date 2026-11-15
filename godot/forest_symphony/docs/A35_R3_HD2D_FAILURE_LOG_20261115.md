# FS A35 R3 HD-2D | Native QA Failure Log | 2026-11-15

- **F1 Cold import:** First execution requires `Godot --headless --editor --import`, as inherited from R2. R3 official 4.7.2 editor import PASS Exit 0.
- **F2 Native GDScript parser:** Initial R3 test used `get_node_or_null(node.name)` where Godot 4.7.2 requires `NodePath`, not `StringName`. Godot first source test Exit 1. Corrected `get_node_or_null(NodePath(str(node.name)))` on disk and GitHub builder, native rerun **PASS Exit 0**.
- **F3 Native log encoding:** PowerShell `Tee-Object` produced UTF-16 LE (`FF FE` BOM). Initial native ZIP finalizer read UTF-8 and falsely marked source/GPU QA as failing. Corrected finalizer to read native/GPU logs with `encoding="utf-16"`. Must verify final packager report before marking package PASS.
- **F4 Art not fixed:** This particular R3 tested Godot atmosphere with original R2 8 new tree sprites unmodified. Repetitive foliage texels and geometric crowns still unresolved. **ART HOLD.**
- **F5 GPU day/night comparison:** Time-of-day effects alter whole frame. R2 old/new tree-union ROI check is not applicable between day/dusk/night frames. Compare phases separately; run tree-only ROI check with identical light phase when later replacing trees.
- **F6 PointLight2D occlusion:** Fixed location warm light, shadow_enabled=false, no per-tree/house occluder polygons, no physically realistic shadows or true 3D DOF. Do not promote the effect to complete HD-2D.
- **F7 Release privacy:** Source-only GitHub, full ZIP and real native captures private owner-only Drive. Do not commit 100MB archive/screenshots or private art to public GitHub.
- **F8 Scene regressions:** 187 PAR source/positions and Ground SHA checked in Godot, but full original R2 navigation 8/8 and player front/back occlusion were NOT rerun under R3. Must run before art release and never infer new physical tests passed.

Status: **ENGINE/SOURCE PASS, native day/dusk/night GPU 3/3 PASS, ART HOLD**. Final release ZIP CRC PASS / 236 members / 108,931,403 bytes / SHA256 `16a707417d65dc41eeb12919a52b560af26a9860d888f560f740e785c018797c`. Google Drive metadata readback verified `shared=false`: https://drive.google.com/file/d/1xWgVRNW2bLL9XUBZvc6I1vP7W8BQdX9-/view.
