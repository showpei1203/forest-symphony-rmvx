# Forest Symphony | T-B R6 official provider animation + Godot native Handoff

Updated 2026-11-21, Asia/Taipei. Working branch `feat/fs-pixellab-tb-monster-20261121`. Linear `SHO-37` In Progress. **ART HOLD**, not a final Approved Asset.

## Change from R5
- R5: static source cutout, procedural and mechanical, 0 provider jobs, ART HOLD.
- **R6: real PixelLab `animate-with-skeleton-v3` provider accepted and completed**: `job_id=3fea688e-1c8c-451c-aa3f-84941166dca2`, `generation_id=67dd6734-d3a5-4dc7-a860-ebb797f20964`.
- Used an original approved 96x96 padded frog source (SHA256 `e0b01e658d2659fa5c9a01c60c29a4e07cf525a0d5987aa677d09c7a0ed73c72`), `low top-down`, `south-east`, custom quadruped `dog` depth with 14 rig joints, and author-selected 11 poses from original PMD timing; 11 returned 96x96 images. No image source generated from scratch, and no full-body RBF warp.
- **Actual billing: 3.0 subscription generations charged**, no USD equivalent reported. User PC only held transient PixelLab request/response under Windows `%TEMP%`, not an archival results library; private raster transferred to Drive, code to GitHub. After syncing, remove transient PC files.
- Original provider atlas SHA256 `6d9b6690c3097225bf8fbba5f14eb5fbd667e815577543298898e71ea8e56252`; lossless indexed image transfer preserved all **119 unique RGBA values**, then RGBA reencoded to 384x288 for Godot. Do not mistake re-encoding checksum for the original provider checksum.

## Real verification
- Private V6 provider Sprite Sheet **384x288, 11 cells, 96x96** generated; no crop; 11 distinct evolving frames; 7/7 objective QA, as recorded in `qa/V6_PIXELLAB_REAL_QA.json`.
- **PixelLab output** actually imported in Godot `4.7.2.stable.official.ed1daf0bf`, real private atlas, isolated `/mnt/data` sandbox, not the user's PC. Native script log: `TB_V6_REAL_GODOT_472_NATIVE_SCRIPT_PASS 11F R2/H5/T7 exact-once cancel; TECH_ONLY`.
- Xvfb software OpenGL renderer: Mesa llvmpipe. Native viewport capture log: `TB_V6_GODOT_472_11_NATIVE_RENDER_PASS REAL_PRIVATE_ATLAS; ART_GATE_HOLD`. All 11 native PNG screenshots, native contact, normal+slow native GIF, and capture SHA evidence stored in private Drive ZIP.
- Historical normal attack is physical jumping lunge/bite, **not fireball**. F2 Rush / F5 Hit / F7 Return timing kept from original PMD XML. No modification to main FS battle damage code or T-A/T-C branches.

## Artistic result
The **foreleg and hindleg motions are more natural than deterministic V5**; basalt back, golden eye and lava fissures visibly remain one family. However, F5 has **insufficient open jaw/readable bite**, F6 has a 2-pixel detached artifact, original F0/F10 are provider redraws rather than source-exact, and exact FS 45° battle camera remains unapproved. **ART HOLD**; don't equate rendering with acceptance. Full blockers in `R6_FAILURE_LOG_20261121.md`.

## Deliverables
- Private Drive T-B working folder: `https://drive.google.com/drive/folders/10qOSm1id3o5oisfVQxhlC_4ncJaF0Yd3`
- Private R6 ZIP contains verified source 0001-3, prior real provider Idle, new provider 11F atlas + true frame PNGs, rejected V6 manual comparison, Godot 4.7.2 stand-alone project, captured 11 native PNGs, complete QA, source script, provider job/cost manifest and logs. Verify ZIP SHA and CRC before relying on it.
- GitHub: `godot_port/tools/pixellab_tb/pixellab_v3_provider.py`, `godot_port/tools/pixellab_tb/validate_pixellab_v6.py`, `godot_port/experiments/pixellab_tb/attack_v6_compare.gd`, `attack_v6_compare.tscn`, `tests/tb_attack_v6_native.gd`, `tests/tb_attack_v6_capture.gd` and R6 handoff / failure log.
- All approved history and V1-V5 sources preserved; **do not overwrite** earlier V5 comparison in Drive. Do not store third-party PNGs in public GitHub. No permanent owner Windows PC results library.

## Next unit
Keep V6 PixelLab-derived limb motion, produce three distinct source-consistent **mouth poses** for F4/F5/F6 by *masked pixel redraw or frame-focused provider inpaint*, not a blind full-chain reroll. F5 mouth must visibly open with jaw hinge and follow-through; no detached toes/mouth; then full native Godot 4.7.2 screenshots, QA and human Art Gate. Only after first chain approved, template-transfer to second truly different specimen; record generations per 11 frames (R6 baseline: 3.0).
