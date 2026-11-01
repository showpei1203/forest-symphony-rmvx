# FS Stage16 A33F Understory | FAILURE REGISTER, 2026-11-01
A33F selected R2 based on actual 1× layered Ground + separate PAR and native engine tests. Visual user signoff PENDING. Formal Seal NO.

### F-01 A33E 1x understory too weak
A33E's 9 RGBA shrubs were isolated and technically loaded but visually almost disappeared in rich forest-floor grass. A33F R1 (scale1.26) and R2 (scale1.61, bounded edge clamping) tested; R2 selected. Three distinct pixel botanical constructions (broadleaf, fern and tiny flower/shrub) replace original nine IDs and preserve SAME foot/collision status. **Do not call nine existing shrubs new IDs**, and don't mistake number of leaves/strokes for ecological realism.

### F-02 A33F initial source path wrong
First real PAR compile script attempted to find A33D historical tree assets in the A33E work folder, failing FileNotFound for `A33D_TREE_left_copse.png`. The missing source was not a lost user asset: canonical existing source is `E:\FS_STAGE16_A33E_FOREST_DIVERSITY_VX_20261101\Overlays`. Fixed branch to use original verified A33E VX Overlays fallback, then complete compilation and 1x composite QA passed. NEVER flatten missing objects to fill gaps, never silently skip.

### F-03 scatter versus coherent habitat
A33E had only ~150 recent grass additions. A33F improves large ecological zones using nine broad growth areas, 285 clustered stems sources, 2133 small native leaf strokes and 74 petite wildflower markers, preserving original 1885 accepted flora pixels and entire A33E road RGB exact. Candidate still depends on pixel-level source textures; visually check full Ground3 reference rather than presume ground realism from count.

### F-04 Test-only RGSS map script must never contaminate production
Original A32B 12 RGBA sha and original 15 A33E trees preserved. In A33F independent native map clone, `Data/Map050.rvdata` and original E collision SHA identical to A33E (23 blocked, 198 walkable). RGSS Script 483 filenames updated for 9 new RGBA art; other 506 scripts byte-identical. Original production BattleRegression fix from prior stages is still unresolved and map test scripts contain bypass; isolated native VX PASS is NOT sealed FS release acceptance.

### F-05 Dynamic foliage can alter actor ROI by design
Original road actor and full tree cover tests still PASS. At one behind-tree/understory test case the enlarged shrub may partially cover a character which was fully exposed in A33E. Do not treat changes in actor ROI automatically as a missing sprite or failed alpha; validate which foot-sorted shrub now occupies that region. Visual signoff needed.

### F-06 Godot GPU tolerance not exact zero
20 actual Godot GPU outputs passed, actual frame vs independent layered source has 3765 positions with only max 1 channel RGB difference, 0 positions exceed1. Do not report an exact zero-difference GPU match.
Native VX 18 cases/36 actual screenshots, road and 5 original/new tree-root movement tests, zero modal; independent cold 3415/3415 file SHA + actual startup/32 objects. User art review PENDING; Formal Seal NO.


### F-07 R1 and R2 standalone source filename collision caught by ZIP fail-closed
In first A33F generator, R1 and R2 used the same `A33F_a33e_shrub_XX_*.png` output filenames, so generating R2 silently overwrote R1 **standalone sprite source**, although already-composed R1 PNG appeared correct. The private package demanded `18` independent R1+R2 sources, and failed instead of accepting only 9.
**Fix:** R1 files now have distinct `A33F_R1_a33e_shrub_XX_*.png` names, while selected R2 retains its previous exact filenames and SHA values; generator rerun creates 18 unique RGBA sprites and complete R1/R2 manifests. ZIP packaging glob updated to include both source families. Rebuilt ZIP CRC, every member SHA and independent extract compare are mandatory PASS. Prevent any future overwrite by checking **unique variant source paths** before secondary variant generation, and assert source count in deliverable (9 per variant, 18 total). R2 native VX/Godot output remained byte-identical; rejected alternative remains reproducible.


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
