# Forest Symphony A35C R2 | Source-first cliff top 1-2 tile PAR handoff
Date 2026-11-02 Asia/Taipei. Read authority FS_TERRAIN_PAR_TOP_EDGE_HEIGHT_FOOT_GATE_V2_20261102.md, failure register and latest CURRENT_HANDOFF_STAGE16_A35C_20261102.md. Earlier A35B blank PAR was temporary; A35 217 color cliffs invalid.

Local working directory E:/FS_STAGE16_A35C_TOP_EDGE_OCCLUSION_20261102; source Ground original SHA478b3f40367cb449721a9216c28c3906557cbb292ffcc6702984ec0d90559f00; image 1280x928 (40x29 VX). No PixelLab. Four documented top ledges: west long and middle high have 2 tile behind cover, east middle and south woodland have 1. SIX independently owned true original-source RGBA 9px lip sprites, 32 behind tile predicates. Full composite static preview A35C_PAR50_TOP_EDGE_1_TO_2_TILES_1280x928.png SHA 86c04ea3b85935f20216b4e90bc9441de8d010be24776194e21ca73f2e471fa2. The static preview alone does NOT create correct actor occlusion; conditional engine sprite allowlists do.

Original VX Game.exe isolated clone E:/FS_STAGE16_A35C_TOP_EDGE_OCCLUSION_VX_NATIVE_20261102, 6 runtime assets; separate reference E:/FS_STAGE16_A35C_TEST_REFERENCE_NO_PAR_VX_20261102 has identical actor foot positions and 0 PAR. Both 11-case 22 screenshot native 544x416 runs no modal. A35C_R2_NATIVE_TRUE_FRONT_BEHIND_DIFF_QA.json: strict late 5 behind hide154-159 pixels; four front/unrelated 0 pixels change; hidden background pixel RGB0; earlier intro case0/1 fade outliers. Visual contact A35C_R2_TRUE_NATIVE_VX_BEHIND_FRONT_8_CASES_COMPARISON.png.
Godot native project E:/FS_STAGE16_A35C_TOP_EDGE_OCCLUSION_20261102/GODOT_A35C_R2_TEST_1_AND_2_TILE_LIP, AMD RX6700XT compatibility OpenGL: 19 full1280x928 GPU PNG, five back changes188-195 and four front changes0; source noactor GPU RGB exact0.
Native VX cold clone E:/FS_STAGE16_A35C_TOP_EDGE_OCCLUSION_VX_COLD_20261102, exact3635/3635 per-file SHA, Game.exe boot Map50 loads6 sprites with zero modal. Not 22 cold screenshots deterministic replay.
A35C_R1_OVER_MASKED_FAIL_EVIDENCE documents initial 20px-alpha wrong full-body coverage; R2 correct 9px. Original A35/A35B untouched.
Next finish all cliff front ledges, height-region and stairs/cave actual navigation, front/behind NPC multi-actor logic in production-safe engine. Source 32px geometry conversion and A35 collision (414 blocked, 746 passable, BFS695) still provisional. Formal Seal NO and user visual signoff pending.


## Verified Google Drive A35C R2 delivery (2026-11-02)
These are **actual IDs returned from Drive folder listing**. Local ZIP CRC, per-member SHA256 and independent full extract SHA PASS; remote ZIP Drive metadata readback confirms title/byte length, not a separate full remote ZIP download hash.
- **Most useful: actual native VX Game.exe 8 pairs front/behind noPAR vs R2 lip closeup:** https://drive.google.com/file/d/1w7JLfLrbmbOeSyg0oj28C_BRtDp182UE/view
- **Actual cliff top ledge layout and height 1–2 foot grid test plan:** https://drive.google.com/file/d/1elKuJFHTj6d3vF3TKJYhGsY9NB6iIAoI/view
- Locked original direct-style full 1280x928 Ground: https://drive.google.com/file/d/1aTfPCt4t0fGkwssh4LK_ImV-7FFnf_1M/view
- Full transparent STATIC preview PAR50 (runtime actually uses six conditional-foot depth sprites): https://drive.google.com/file/d/1Jpn--T80jh5t1dgb91u8IJxTYGTH-bfO/view
- Source composed full-size Ground+PAR preview: https://drive.google.com/file/d/11b5vonbwCCMbpYTMPErWWCRq7QEvZm-w/view
- Six RGB+alpha images + exact tile/depth manifest: https://drive.google.com/file/d/1hoF-5lzV_52ENMETXvubVYxLGs1TNaC2/view
- True VX independent Game.exe positive 5/negative4 numeric strict QA: https://drive.google.com/file/d/1O9etEt5tpro0fjpVvl01zOGqI4ukmql8/view
- Godot AMD GPU 19 real 1280x928 frames, behind positive/front zero QA: https://drive.google.com/file/d/1leJNhc4-O9QFxqUA1ZlJZIlvnAjOkd4x/view
- Cold native 3635/3635 files, six active source sprites Game.exe, no RGSS error: https://drive.google.com/file/d/1VzXTuYAeAdRssI7nCevKm97EUF23KDeB/view
- Final cross-engine QA: https://drive.google.com/file/d/1Z0r5oGQt_xJPl6S-65ucQXFz5OggR1t5/view
- **FULL PRIVATE R2 source/QA archive**, 146 members, **94,481,296 bytes** including 22 true R2 VX frames, 22 true noPAR control frames, 19 real full-size GPU frames, 22 failed R1 screenshots, source and scripts, no main production binaries: https://drive.google.com/file/d/1PdVFDZpN6pCdkOOUBnje0tmtGvMYZqN0/view
- Package ZIP QA record: https://drive.google.com/file/d/11hBZJMzM6d7tYXupIrbhaDJ2wBU-Y-be/view
- Permanent v2 PAR source/foot/elevation rule: https://drive.google.com/file/d/1u47yzdoEUpfku16locDKTVTBEP5rdKJz/view
- R1 excessive overlay + path/log bug Failure Register: https://drive.google.com/file/d/1fGQgjLAnpUE1sx5bU9Q55epLH5lT7Hix/view
- Detailed A35C R2 Handoff: https://drive.google.com/file/d/1xSLab_L-RQ0u_TxqSSoQjKX1GgVcjuj3/view
- Latest CURRENT_HANDOFF: https://drive.google.com/file/d/16PXa-YIeUJb5lhXv4OlAqG4-kdeIiaEi/view
- Stage folder: https://drive.google.com/drive/folders/1WHfweiXoEZgTxhTM5Xgy3rXEHuO4qXyJ

R2 representative lip engineering **PASS**; not all cliff segments and multi-actor/height passages verified; user visual signoff PENDING and **Formal Seal NO**.
