# Forest Symphony Stage16 A33F R2 Rich Understory | Detailed Handoff
Date 2026-11-01 (Asia/Taipei). **ACTUAL remote construction and engineering dual-engine/cold PASS; user Ground/PAR art PENDING; Formal Seal NO.**

## Reading order
1. `authority/FS_GROUND_PAR_SOURCE_FIRST_PRODUCTION_V1_20261101.md`
2. `authority/FS_PAR_SEMANTIC_ORIGINAL_OBJECT_GENERATION_V1_20261101.md`
3. `authority/FS_GROUND_BLACK_STREAKS_ECOLOGY_FAIL_CLOSED_V1_20261101.md`
4. `authority/FS_FOREST_PAR_SPECIES_DIVERSITY_AND_SHRUB_VISUAL_GATES_V1_20261101.md`
5. NEW `authority/FS_FOREST_UNDERSTORY_SHRUB_VISIBILITY_ALPHA_RULES_V1_20261101.md`
6. This detailed Handoff + `STAGE16_A33F_UNDERSTORY_FAILURE_REGISTER_20261101.md` and A33F CURRENT_HANDOFF; prior A33E source.
## Source names / exact limits
A33E original Forest Floor SHA `d129d229a1d5b75e3ab9ae061c9d42eea3a1014cbaa1b581c360b0b6b57c3fa5`; full transparent PAR50 SHA `0bb510b71ab5ad7c265b464d2aacfe228f3a4e98df2430bb8fc2a2e14c5b6b9c`.
**New A33F R2 opaque Ground 544×416**: `A33F_GROUND_RICH_UNDERSTORY_544x416.png`, SHA256 `39d9b1163eb44ed46a614c5d93029300f7a99df47e079cf905620905009b5e72`.
**New source-composed full transparent 32-object PAR50**: `A33F_PAR50_R2.png`, SHA256 `05a8f5e1e2253c7fe7c547c8e904c548b2f367b0b5ca18de341ad25913cd0626`.
All original A32B 12 user-approved sprites and all 15 A33E trees byte-identical. A33F **replaces nine** prior tiny A33E shrubs with nine independent larger RGBA objects, not increasing total count: 15 trees, 9 shrubs, 8 other PAR props = 32 objects. Same shrub IDs, same foot and nonblocking; three physical botanical architectures: broadleaf cluster, individual frond fern and flowering shrub.
## Ground ecology
A33F full Ground retains original A33E road RGB at exact XY, all 1885 A27 source bright plant positions, 9 coherent forest habitat regions, 285 clustered low-turf colonies, 2133 narrow blades, 74 tiny flowers. A33B erroneous deep-olive curved-band RGB fault class remains 0; no scene SHADOW/LIGHT embedded, no Gaussian blur.
Both R1 compact and R2 rich shrubs separately compiled into RGBA par50 and real Ground+PAR images; comparison `A33F_A33E_R1_R2_REAL_GROUND_PAR_COMPARISON.png` (3×544 at native scale) and actual original RMVX screenshot review `A33F_REAL_NATIVE_VX_A33E_VS_R2_544W.png`.
## Real native VX QA
Independent original VX 32-source Map50 clone at `E:\FS_STAGE16_A33F_UNDERSTORY_VX_20261101` from untouched A33E clone. Only new Ground, Par50, 9 new nonblocking shrub filenames, and isolated test-only Script483 dynamic overlay references changed. No changes to `Map050.rvdata` original 23 blocked/198 walkable cells, original road walk/foot, 12 approved sprite files or other506 RGSS scripts.
Actual `Game.exe` RGSS Player Map50 544×416, **18 cases / 36 real HWND screenshots / zero modal**, logged native 32 loaded object sources. Original tree full hide east 0/627, west partial 351, front 627 and road (8,6)->(9,6); all A33D and A33E tree-root tests still blocked: (2,4), (6,1), (11,1), (7,4), (16,5) unchanged. Larger shrub may naturally change actor ROI at some foot-sorted scenarios, not a render error.
## Actual Godot 4.7.2 GPU QA
New independent Godot project `E:\FS_STAGE16_A33F_UNDERSTORY_20261101\GODOT_A33F_R2_UNDERSTORY`. Same 32 standalone owned PAR source sprites, 20 actual RX6700XT OpenGL rendered PNG screenshots, including four new shrub/actor depth scenarios. Actual noactor GPU vs independent Pillow Ground+source-composed PAR target: **3765 changed image pixel positions, maximal single-channel RGB diff1, zero positions diff>1**. ENGINEERING PASS_RGB_TOLERANCE_1, **not** literal zero.
## Native independent cold
Separate source clone `E:\FS_STAGE16_A33F_UNDERSTORY_VX_COLD_20261101` exact **3415 / 3415** per-file SHA matched, independent actual cold Game.exe launched Map50 loaded 32 sources, no RGSS modal and 544×416 native screenshot. This is not 36/36 deterministic replay, and main FS production battle-regression bypass remains unresolved.
## Review and archive
Local source folder `E:\FS_STAGE16_A33F_UNDERSTORY_20261101` containing `a33f_generate_botanical_shrubs_and_floor.py`, `a33f_build_native_VX.py`, `a33f_capture_native_18_cases.py`, `a33f_build_godot_R2.py`, `a33f_godot_real_gpu_QA.py`, `a33f_native_cold_verify.py`, true PNGs, QA and native screen source. User source art private, no public sprite uploads to GitHub, full ZIP in Google Drive after SHA verification. User aesthetic pending. Full 1280×928 reference scene size and production shadow/light rendering are separate future milestones. Formal Seal NO.


## Verified A33F Private Google Drive delivery — 2026-11-01
All exact IDs below were returned by Drive folder listing, including ZIP name/37,958,085 bytes. Local CRC, all member SHA256 and independent reextract verified PASS; remote full ZIP SHA **not separately downloaded/rehashed**.
- **Actual native VX R2 before/after**, 544px-wide true Game.exe screenshot, 4 region zooms: https://drive.google.com/file/d/1L2BiREFKbdeA5BC22ESYRExfPsbwgHGc/view
- **Three-way full separately layered Ground+PAR comparison A33E / A33F R1 / R2**: https://drive.google.com/file/d/1mKk0d0cmFPC7QQsZsOcst3Z1tCP4zMBm/view
- **A33F new Ground 544×416** SHA `39d9b1163eb44ed46a614c5d93029300f7a99df47e079cf905620905009b5e72`: https://drive.google.com/file/d/1IwpkaZZBwsZJG_ag9LoyGex1wfvIqrMw/view
- **A33F R2 complete transparent Par50 32 individually sourced objects** SHA `05a8f5e1e2253c7fe7c547c8e904c548b2f367b0b5ca18de341ad25913cd0626`: https://drive.google.com/file/d/1QCsm_ebd6TwQA17vV_LUcWdYXg92_cN9/view
- **True complete layered Ground+PAR R2 composition**: https://drive.google.com/file/d/1OLGI2XxxX-rvqZsfh1X9dji8csTXE8Rt/view
- R1 alternative independent PAR50: https://drive.google.com/file/d/11DT1ohFF0gjM2XN2MEtj3kRfOQpyiRUk/view
- R2 9 independently owned RGBA shrubs + 9 R1 separate-source variants: files in private stage folder/ZIP.
- **Complete A33F private evidence ZIP 148 items 37,958,085 bytes**, real VX 36 screenshot frames, actual GPU20 frames, 18 independent shrub sprites, all 32 scene sprites, test-only map Data and source code. ZIP CRC, member SHA256 and cold extract PASS: https://drive.google.com/file/d/1LgspeeFQ9Y6LgNct7Lbw_ppWfzcG8uCY/view
- A33F source scene and R2 nine-shrub manifest: https://drive.google.com/file/d/1Z4ocj-YHjoXZ1msjHFeXwslgjBH8QsXt/view
- A33F source generation QA: https://drive.google.com/file/d/1yqkOOEYRR_jd8YrOSPmbBWaDJMpNfNTC/view
- Actual native VX 18-case / 36-frame actor movement and occlusion QA: https://drive.google.com/file/d/1uKnYUVTsgVHsBwrJ7yE1C3vr1-xZHdHg/view
- Actual Godot 20 GPU frames numeric tolerance1 pixel QA: https://drive.google.com/file/d/1JtN4C5v7wmaQHvClHV3jNhudxyAqBGTv/view
- Native separate cold 3415/3415 SHA QA: https://drive.google.com/file/d/1T3iPzRAttigNm-Ox9086FEpR3aR6O4dW/view
- Full permanent understory QA visual rules: https://drive.google.com/file/d/1nz2um6vEVa8IW0Grp6u-EML6f2GVMg4V/view
- Failure Register including fixed **R1 source overwrite bug**: https://drive.google.com/file/d/1hKmmIfBPyB_is1Y3EDr36WFB8yZ3sYwG/view
- A33F detailed handoff: https://drive.google.com/file/d/1vOyRkwRdU1xg7hZrAY9pzWZ7NfLStV1b/view
- Latest CURRENT_HANDOFF: https://drive.google.com/file/d/1GYVXhGZ_SixxdS0Hzus0uW7rGTAR8_Rv/view
- Private stage folder: https://drive.google.com/drive/folders/1qT2tLHC69CE2phoKdmtMJ9ORAvFJ1zoZ

A33F engineering VX/Godot/cold PASS; A33F user aesthetics pending; Formal Seal NO.
