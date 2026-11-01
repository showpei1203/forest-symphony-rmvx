# Forest Symphony A35 — Direct Generated Ground-first Full-Size 40x29 / Native VX + Godot
2026-11-02 Taiwan. **A35 actual SOURCE/GROUND/PAR + dual-engine/cold engineering PASS**, vertical gameplay stairs/height still PENDING, user art conversion review pending, Formal Seal NO.

## Required read order
1. authority/FS_GROUND_PAR_SOURCE_FIRST_PRODUCTION_V1_20261101.md
2. authority/FS_PAR_SEMANTIC_ORIGINAL_OBJECT_GENERATION_V1_20261101.md
3. NEW authority/FS_DIRECT_GEN_GROUND_FIRST_NO_PIXELLAB_DEFAULT_V1_20261102.md
4. A35 detailed Handoff, A35 Failure Register, CURRENT_HANDOFF_STAGE16_A35_20261102.md, A34 native 40x29 baseline.

## Actual tool and provenance
- Original user-approved AI direct-generated RGB forest canyon image `森林峽谷湖畔地形圖.png`, **1473×1068**. It was generated directly by assistant, NO PixelLab. Not originally 32 grid. One-to-one aspect ratio converted NEAREST 1280×928 actual Ground without bilinear blur or procedural replacement.
- New A35 source SHA **478b3f40367cb449721a9216c28c3906557cbb292ffcc6702984ec0d90559f00**. Original reference converted to `A35_STYLE_DIRECT_GROUND_1280x928.png` via Google Drive and verified user's remote G drive sync. Same RGB as `A35_GROUND_DIRECT_ART_1280x928.png`. No PixelLab token/cost consumed.
- Source and actual script paths remote `E:\FS_STAGE16_A35_DIRECT_STYLE_LARGE_GROUND_20261102`; independent native clone `E:\FS_STAGE16_A35_DIRECT_STYLE_VX_NATIVE_20261102`, independent Godot project `E:\FS_STAGE16_A35_DIRECT_STYLE_LARGE_GROUND_20261102\GODOT_A35_40x29_GROUND_PAR`, cold clone `E:\FS_STAGE16_A35_DIRECT_STYLE_VX_COLD_20261102`.
- Strict own Ground 1280x928 SHA above. Detect grass/path/cliffs, water and cave. Output `A35_SEMANTIC_CLIFF_FACES_1280x928.png`, `A35_SEMANTIC_WATER_1280x928.png`, collision map and QA.
- Ground derived 217 native 64×64-ish source-cliff individually owned transparent PAR RGBA in `PAR_CLIFF_INDEPENDENT_RGBA`; each has alpha, X,Y, derived same pixel source and source SHA, foot/depth, no baked separate environmental shadow/light. Full transparent `A35_PAR50_ONLY_CLIFF_OCCLUSION_1280x928.png`, SHA256 **48ec0e4156f085f757542f6e06a9568ab75523d6bb857c773ccf895c05e528a9**. PAR source classification covers 256218/256513 (99.88%) of candidate cliff pixels, compiled with source Ground gives zero RGB differences. `A35_SOURCE_FIRST_LAYER_MANIFEST.json` records all 217 sprite files.
- **Important**: these derived cliffs are duplicate RGB pixels for occlusion, no unique sprites painted from scratch; this follows user authoring strategy. A35 has *no newly authored trees* yet. Next A35B tree and height/plateau expansion must preserve art.

## Real gameplay and native engine results
- Native VX `Map050.rvdata` actual 40×29, semantic E blocking: 414 blocked, 746 passable, largest connected region 695 tiles, other islands [12,12,12,8,2,2,1,1,1]. Five stair corridor candidates, but not fully verified passage transitions. Cave blocked pending map event. Only script483 changed, other506 RGSS scripts untouched. Test-only A30 map harness with battle regression bypass remains, no production seal.
- Actual Game.exe RGSS Player 11 placements / 22 true 544×416 screenshots, 217 separate Cache.overlay sprite assets, 0 RGSS modal. Native cliff block (20,14) move_down -> remains (20,14); allowed ground move_right (21,14)->(22,14). Native map scrolling covering far edges and corners with correct whole Ground+PAR color: first two title overlay transition images have major differences; cases2..10 **ZERO RGB pixel differences** to correct independent full ground+PAR source viewport crop.
- Actual native Godot4.7.2 RX6700XT OpenGL render: 6 full 1280×928 GPU frames and 6 true 544×416 viewport crops. Actual GPU noactor full RGB **zero differences** vs source independently composed full Ground+PAR.
- Independent cold native VX clone `E:\FS_STAGE16_A35_DIRECT_STYLE_VX_COLD_20261102` file-level SHA **3844/3844** identical; real Game.exe Map050 loaded 217 object sources, no RGSS modal. This does not establish deterministic 22 screenshot replay.

## Limitations / next pass
- VX frame/gameplay integration works for selected paths; original 32 grid not authored, so stairs/height/water shore collision still provisional. 695/746 connected in main walkable component only; no false full BFS. Need semantic leveling, stair connection graphs and actual native movement through stairs in A35B.
- A35 full large map 1280x928 is real Ground-first **forest canyon/shore base**, not a finished full forest-village: trees as independent PAR should be introduced next, so the current Ground remains clean and beautifully styled. Verify composite art against user's original direct-generated picture, no PixelLab requirement.
- A35 engine integration engineering PASS / map gameplay topological QA PENDING / aesthetics signoff PENDING / **Formal Seal NO**.
- All original copyrighted map/art source bytes kept private. GitHub holds docs, source recipes and failure log. Private ZIP/actual previews in Google Drive, links appended only after verification.


## Verified Google Drive A35 full-size direct Ground-first delivery — 2026-11-02
All Drive IDs below were retrieved from an actual Drive list-folder after remote Windows sync; local archive ZIP CRC, per-member SHA256 and cold re-extraction PASS. No additional independent *remote ZIP downloaded* SHA asserted.
- **Actual direct-generated art Ground 1280x928 (not PixelLab)**: https://drive.google.com/file/d/14TnQjNh_tziQXoERh9ViAkl8dV0A8WoA/view
- **Actual complete Ground+PAR native visual, 1280x928**: https://drive.google.com/file/d/1GuqaCw-a3TJUVSh8kRw9fyNL2--MgAoY/view
- **217-cliff-source transparent PAR50 PNG 1280x928**: https://drive.google.com/file/d/183Gn2LBuxC_261Atl8DEiQAqygL4q--Q/view
- **Actual native VX 9 scroll camera screenshot montage**: https://drive.google.com/file/d/1c-oU5WQXEwKn6KO1zBFA37ZmJ2s-0BOR/view
- Collision grid marked on full natural artwork (NOT final passability approval): https://drive.google.com/file/d/1L2BPgsIvzW2vL2FrTXpgVN6iCiTOTtKx/view
- Cliff-face alpha checker preview: https://drive.google.com/file/d/13Zw8Cjy7Whp41qOIdfThNu2rd5WpAqMb/view
- Independent derived 217 PAR clip RGBA objects with exact source SHA/foot in Manifest: https://drive.google.com/file/d/1cfZBLnN5gnoxd8o3wBlnHCuQWBQwQYy2/view
- **Full private source/evidence ZIP**, **47,285,065 bytes**, **298 members**: direct Ground, full PAR, 217 standalone alpha PNG clips, 22 real Game.exe frames, 6 full GPU frames+6 crops, isolated native test RGSS data, scripts and QA: https://drive.google.com/file/d/1k9bcWJfZ5Q7twuHWSp-RQgEduW3R2V-T/view
- ZIP QA (CRC, all SHA, separate cold extraction PASS): https://drive.google.com/file/d/1o-y-v01rltrMEHurb9uq1yXtuMhveDMO/view
- Real native VX 11-case screenshot+movement QA: https://drive.google.com/file/d/1ngVtPPzaejTpDOA54NzGZ2hKANsQYgpg/view
- VX native scroll pixel QA (cases0-1 fade not parity; cases2-10 ZERO): https://drive.google.com/file/d/1d2RAwjjpr3WWJzrJ89ByG8kNQ5Zdj0wT/view
- Godot real RX6700XT GPU full1280 6 frames+6 crops, exact ZERO RGB difference: https://drive.google.com/file/d/1RdZlDwNXW2GiEVZATekjL6xqbIBZefEw/view
- Cold actual VX 3844/3844 file SHA, 217 assets loaded with 0 modal: https://drive.google.com/file/d/1bzrcGCHAllVTN3GbVxsBFM3tQBK39xbU/view
- Actual provisional semantic terrain tile QA (414 blocking / 746 walkable, largest component 695): https://drive.google.com/file/d/1xtnrADzuuUvVAXAER4B6mcFzrlH5IEhr/view
- A35 direct Ground master QA authority: https://drive.google.com/file/d/1zMVu-P1JgdT-45Ftwondc1ypGMxrIQO1/view
- A35 Failure Register: https://drive.google.com/file/d/1pn45eY__WRcnHu_B6o5436rS7V0goTP8/view
- A35 Detailed Handoff: https://drive.google.com/file/d/1x2-6bI85yNX3TvfkO2rdLQ1Nco54GFlH/view
- Latest CURRENT_HANDOFF: https://drive.google.com/file/d/1XpA8jXWyaWyGjZ62ko6PmcFPDruZ-SVF/view
- Verified stage folder: https://drive.google.com/drive/folders/1RexfjOO791rA6hUrxa5lLN5KKM9fLFos

**A35 Ground/PAR composition, actual native rendering & cold QA PASS; 32-grid elevation/stair/cave/water final gameplay pending; visual user conversion signoff pending; Formal Seal NO.**
