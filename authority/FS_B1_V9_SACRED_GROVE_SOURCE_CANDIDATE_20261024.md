# Forest Symphony | B1 V9 Sacred-Grove Two-Layer Source Art Candidate (2026-10-24)

**Source art prototype ONLY. NOT a V9 playable VX version. Artistic Fidelity, Human Gate F and source licensing are PENDING.**

### Base and no-regression
Baseline remains verified **FS_B1_BRIDGE_DUAL_LEVEL_V8_20261024_PRIVATE_VX.zip**, 17,095,059 bytes / SHA256 `2d36734a479fe56d4544a1656ec5473d21b57f54e14e22fc9e99c8e756f1a69f`. V8 has independently playable two-level treehouse, Level2 bridge over Level0 ford, and all 25 native isolated VX height interaction gates PASS. The original V8 Game.exe, manifest, Ground/Par/Owner/Height source, and 505 sealed FS scripts were **not touched** by this prototype.

### Actual artwork increment
Created one original source-backed **224×224 sacred canopy/trunk module** designed to integrate visually behind the existing central treehouse. Art derived from the private Rich/V8 `broadleaf_oak.png` canopy texture with deterministic pixel-1x recolor plus self-authored twisted trunk, branches, roots, bark and golden rune details. Seed=241024; no scaling/interpolation.

- Transparent editable source layers: `output/sacred_trunk_v9.png`, `output/sacred_canopy_v9.png`
- Their exact RGBA composite: `output/sacred_tree_v9.png` SHA256 `4c3f4225308793a5618abd076892ebe0d20126d77caa3340e4633a8b1e824df1`
- Retains original V8 leaf-source SHA256 `4ad9d97f2ac4aad5ec4cd4892938ac6977fa42da615b560915b6b8eabafd92fa`.
- V9 manifest fragment: `sacred_grove_tree_v9`, x=337,y=108, 224×224, z=foot_y=332, occlusion cut=153, **collision pending**, not integrated into the playable game.
- Native scene preview from exact existing V8 49 sources plus new art changes **11,475 visible RGBA pixels**, leaving V8 original files untouched.
- Extra source-first semantic PNGs: `sacred_par_base_v9.png` and `sacred_par_occlusion_v9.png` recombine exactly.
- Art source tester `RUN_V9_ART_SOURCE_TEST.cmd` ran on user's Windows **PASS**: source pinned SHA, alpha binary and exact recomposition, +1px negative geometry mutation detected. **Does not test native VX or collision.**

### Deliverable
Private ZIP `FS_B1_V9_SACRED_TREE_SOURCE_CANDIDATE_20261024.zip`: **2,147,561 bytes**, 46 items, SHA256 `d22008bab6d55d235aa4daed43c5e6f83673d0369c610ffb7cf77d599b953e61`, ZIP CRC & per-member SHA verified, Windows/G mounted Google Drive SHA equal:
https://drive.google.com/file/d/1sDuDfsy6-2s5H17q2NNFyXJFhRKSDGfP/view
Visual side-by-side PNG:
https://drive.google.com/file/d/1ky0WrLvvIUw4yaDZcGasNtHT-q8czxai/view

Python generator/validator plus packaging under `tools/fs_b1_v9/`; actual source artwork **must remain in private user Google Drive, not public repository or Approved Assets**, until proper licensing verified.

### Next legitimate step
Only after user accepts the look: fork the latest V8 working source in isolated V9 branch; run one unified manifest compiler into Ground/ParComplete/Owner/Height/collision/VX; preserve existing treehouse Level1 and bridge Level2; run independently Godot/VX, 1px negative and owner/height gates; run Human visual Gate F. Never treat a preview as a playable release.
