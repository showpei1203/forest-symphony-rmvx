# Forest Symphony | Stage16 A36E R2 | 2026-11-02

**CURRENT ACTIVE FLAT-FOREST MAP VISUAL CANDIDATE: A36E R2. Native VX/Godot/independent cold PASS; visual approval pending; Formal Seal NO.** Original Forest Symphony VX project and A36/A36B/A36C/A36D baselines remain untouched.

## User-designated canonical authority
- Original assets root: https://drive.google.com/drive/folders/1JZL1RLbWECyZP_ddn-TSFjpCaw5C8jtr
- Map & parallax references: https://drive.google.com/drive/folders/18PuuvYK1ClurHzLeKLG6yXZqKXDLa_tS
- Original Tree references: https://drive.google.com/drive/folders/1Zth8u84_5-_pLTf-Ut_a86QiLBuhdaBw
- Original Buildings: https://drive.google.com/drive/folders/1_1fCD0jLwISt1SApxKwbNF3zIVMOyYlW
- Original Plants: https://drive.google.com/drive/folders/1lem9jNNVOqmpXMpu1Ns90bbuT6XtK59U
- R2 flower asset source: original **Hanzo-VSFlowers01.png** https://drive.google.com/file/d/1VTKD9xCNNagPsNXzLufhPy8Uj6B5NLxj/view SHA256 `3d39b5a25a75a886bba42380a567ab86aefd58e515d4ffb2ec109e5dcf50ddc3`.
- Original Hanzo-TownSet03VS.png (second house): SHA256 `8a1da7ffe2db8361c68fb2a2874fa0868a313aca9861bba4a07f95d4c455063c`.
- Original authoritative instructions: `authority/FS_CANONICAL_DRIVE_ART_REFERENCES_A36C_20261102.md`.

## Art changes, real pixel sources, historical failure control
1. **A36D R2 198×236 house roof was too tall, pointed and disproportionately bright**. New house sprite: `SOURCE_INDEPENDENT_RGBA/A36E_HANZO_STONE_THATCH_HOUSE_02_LOWER_ROOF_RGBA.png` SHA256 `110471397ccf079b1ed4367bf840335498bd60c3ac58b20cf2cf9b7f07723fb5`. Nearest-neighbor compressed original upper 169px to 143px at y26; lower **67 pixels (stone frontage/door)** unscaled, same 198×236 sprite bounds, same actor footpoint and blocking footprint. Gentle per-pixel olive roof tone, no resampling blur.
2. Source flowers are actual user-approved Hanzo-VSFlowers01 atlas assets. Split into five independent cropped alpha sources with SHA in `A36E_SCENE_MANIFEST.json` and `GROUND_DETAIL_RGBA/`. Following user's Ground-first architecture, these are *flat Ground decorations*, never extra collision or fake PAR blockers.
3. **R1 VISUAL FAIL:** original large flower groups were out of scale and too purple; the actual R1 Ground, composite, preview, manifest, QA and before/after are preserved with `A36E_R1_` prefix as failure witnesses. **R2** uses nearest-neighbor 54% flowers with reduced neon color; **29 small botanical patches** scattered near path/house edges. Exact source and placements are in manifest.
4. **Source retains 403 RGBA PAR objects, 222 trees, 175 shrubs, 2 distinct cottage styles, 4 landmarks**, 1280×928 (40×29 tiles, flat), stable `(foot_y,id)` sprite ordering and true pixel-identical Ground+PAR object pipeline. All original A36D tree/root collision remains unchanged.
5. **239 impassable root/house tiles; 921/921 remaining tiles connected**. Road and door passage protected. No cliff/terrain elevation PAR or guessed cliff lip.
6. Actual pixel outputs: `A36E_GROUND_BOTANICAL_VILLAGE_1280x928.png`, `A36E_PAR50_RGBA_1280x928.png`, `A36E_ACTUAL_GROUND_PLUS_PAR_1280x928.png`, and `A36D_VS_A36E_ACTUAL_GROUND_PAR_BEFORE_AFTER.png`. R2 before/after truly uses original transparent PAR and newly compiled Ground.

## Real executable acceptance
- Native RPG Maker VX `Game.exe` independent clone `E:\FS_STAGE16_A36E_VILLAGE_VX_NATIVE_20261102`: **11 scripted positions, 22 544×416 RGSS Player screenshots, Map050 entered, 403 resources loaded, ZERO error dialogs**.
- Real blocked tree root: `A36E_BLOCK before=11,11 after=11,11`; real legal road step: `A36E_ROAD before=11,8 after=12,8`.
- Original R2 behind-house actor test remains fully occluded (case06 delta 0); front-of-house actor appears (case07 delta >0). Front/back door usability needs additional human visual testing; no fabricated formal pass.
- Godot 4.7.2 RX6700XT OpenGL native GPU actual: **6 full 1280×928 + 6 region 544×416 images**; expected source vs GPU max RGB channel delta **1**; pixels with RGB delta >1 **0**; 403 independent sprites.
- Isolated cold clone `E:\FS_STAGE16_A36E_VILLAGE_VX_COLD_20261102` checked **3824/3824 file SHA256 identical**, independently launched Game.exe, actual Map050 enter and 403 resources, no modal, real 544×416 screenshot.
- Proof `A36E_ENGINE_GPU_VX_GATE_QA.json`, `A36E_NATIVE_VX_COLD_REBUILD_QA.json`, `A36E_ART_BUILD_QA.json`.

## Actual reproducible worktree
- Stage: `E:\FS_STAGE16_A36E_VILLAGE_ART_20261102`.
- Ground/PAR visual source R1: `a36e_build_visual.py`, **run only in fresh empty worktree**, never overwrite this candidate.
- R2 failed-art correction: `a36e_r2_scale_flowers.py`.
- Verified engine assembly: `a36e_build_engines.py`.
- Actual VX screenshot collector: `a36e_capture_native_11_scenes.py`.
- Godot native script: `GODOT_A36E_VILLAGE_40x29/a36e_godot_native_render.gd`.
- Gate evaluator: `a36e_validate_gpu_vx.py`.
- Independent cold verifier: `a36e_native_cold_verify.py`.
- Package and complete CRC/SHA reextract: `a36e_package_private.py`.

## Next A36F art and fail-closed conditions
- Main remaining issue: second thatch roof still has a strong triangular silhouette and can conflict with the first cottage's material richness. Compare the user's original FS `ground3` sample and real scene references before remodelling or replacing.
- Village ground remains flatter/less rich than the supplied original source; continue with real Plants/Props and deliberate ecological details, not a higher count of randomly scattered sprites.
- More actor-crown, behind-house and natural corridor walk tests should supplement 11 representative cases before formal art acceptance.
- Keep original 222-tree high-density forest visual, tree-root blockers, 32px Foot-Y and Ground/PAR pixel alignment. **Art acceptance PENDING / Formal Seal NO.**


## Verified A36E R2 Drive delivery (2026-11-02)
- A36E Drive project folder: https://drive.google.com/drive/folders/15kzDFVVK2vg43mN6VOhp72lQnJNKSmtA
- Full private source ZIP, 59,003,532 bytes, 490 members: https://drive.google.com/file/d/1W3LOIACBCkdbcDRqrErqusL2J0ToTfMi/view
- Actual A36D vs A36E R2 Ground+PAR comparison: https://drive.google.com/file/d/1LNNmZ0qYLQX-kiJjdrSo6N0SrlObzfUV/view
- A36E R2 actual complete 1280x928 Ground+PAR: https://drive.google.com/file/d/1YbvAmP5FCiFIWyGIr2AGQwP4WEHYaJdw/view
- Native VX 9-region montage: https://drive.google.com/file/d/19j5jcclWLYjdH1AhBaq6RPuQRLysSelw/view
- Full archive CRC/SHA/re-extract QA: https://drive.google.com/file/d/1Ntk_p38PBXJqfObDZhrNYTI8H3uiH-0s/view
- GPU and actual VX QA: https://drive.google.com/file/d/1rINuGz7IgctI8FLVyPoFWFxCk5xPxRJq/view
- Cold VX 3824 file SHA runtime QA: https://drive.google.com/file/d/1KBLu-5j9BI_g5o0gWWf5Zj9jAANYpb5r/view
- Local ZIP SHA256 `3a3dc38630bc567ac9b707716d5510b90876cfda1c0fb7469f4d2869684e861a`. Drive remote ZIP size verified, cloud ZIP not fully downloaded again to rehash.
