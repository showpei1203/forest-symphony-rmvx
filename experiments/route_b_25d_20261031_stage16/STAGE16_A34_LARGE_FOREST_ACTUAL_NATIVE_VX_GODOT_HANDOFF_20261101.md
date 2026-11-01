# Stage16 A34 | Full-size forest 1280x928 actual-source handoff
2026-11-01 Asia/Taipei. Engineering PASS; art pending; Formal Seal NO.

READ ORDER: authority/FS_GROUND_PAR_SOURCE_FIRST_PRODUCTION_V1_20261101.md; authority/FS_PAR_SEMANTIC_ORIGINAL_OBJECT_GENERATION_V1_20261101.md; authority/FS_LARGE_MAP_GROUND3_SCALE_GATE_V1_20261101.md; this file; A34 FAILURE REGISTER and latest CURRENT_HANDOFF_STAGE16_A34_20261101.md; A33F previous handoff.

TRUE REFERENCE: E:/FS_STAGE16_A33F_UNDERSTORY_VX_20261101/Graphics/Parallaxes/ground3.png, RGB 1280x928 SHA ddc1f21e1d23dcb8258a20baa2acb106d1c0e56683a4dc280faedc23bcd47a13, visual only (do NOT flatten into A34).
WORK: E:/FS_STAGE16_A34_LARGE_FOREST_1280x928_20261101
Ground A34_GROUND_LARGE_FOREST_1280x928.png SHA 4363cf0da3c268e9d45114786a1537161c68b789468f08a7c0b799d61cd47b9c; source A33F native material quilting, five connected organic roads, 13 regional forest habitats, separate trail/habitat semantic masks. Not 544x416 resized.
Full PAR50 A34_PAR50_LARGE_FOREST_1280x928.png SHA fe1d2c19461d4447619a1f489124edb8cd88328c8db6859b7fa7ab829e5c230c; complete 210 independent alpha images (104 trees, 96 shrubs, 10 landmarks) under SOURCE_INDEPENDENT_OBJECTS with x/y, foot, blocking, asset-source hashes, manifest A34_LARGE_SCENE_MANIFEST.json. Static full Ground+PAR A34_FULL_LARGE_FOREST_GROUND_PLUS_PAR_1280x928.png SHA 911fe406c83da2b7f297cb9c670a5b9a6ef1a42bce1e0632ea75340d6627b55a. No SHADOW/LIGHT scene layers baked.
Map 40x29: native Ruby Marshal Map050 Table z2 E768 blocked on 104 distinct tree foot tiles, 1056/1056 E769 walkable BFS connected. Source A33F untouched.
Native VX clone E:/FS_STAGE16_A34_LARGE_FOREST_VX_NATIVE_20261101. Isolated Script483 map-only, 210 Cache.overlay native sprites; camera display_x/8, display_y/8, full 544x416 scroll. Native 11 cases/22 true RGSS screenshots, 0 modal, Map50 size40x29 actually logged; tree root (15,10) DOWN remains (15,10); legal road (20,14) RIGHT reaches (21,14). Initial camera screenshot cases0..1 show fading title UI (RGB >3); CASES2..10 max RGB3 against source scene viewport, zero coordinates with RGB difference>3. Failing first two were retained for forensic, NOT claimed PASS.
Godot actual engine source E:/FS_STAGE16_A34_LARGE_FOREST_1280x928_20261101/GODOT_A34_FULL_MAP_40x29. RX6700XT 4.7.2 OpenGL, 6 real 1280x928 GPU renders + 6 544x416 actual GPU crops. Source composed 210 sprite scene vs GPU max RGB single-channel difference1 (21319 positions delta<=1), zero positions >1.
Separate VX cold E:/FS_STAGE16_A34_LARGE_FOREST_VX_COLD_20261101, 3626/3626 file SHA match, fresh Game.exe launched with 210 objects; no error windows. Not all 22 cold screenshots replayed.
VISUAL LIMIT: compared with original ground3 at equal resolution, A34 does not yet contain houses, cliffs, hill terraces or standalone architectural structures. Thus complete village/ground3 art quality NOT YET IMPLEMENTED. A35 should add house/cliff source objects and real layering/collision to this same full-size map, not restart small. User art acceptance PENDING and full production battle regression still unresolved. Formal Seal NO.
Raw licensed/private source and binaries private on Drive only, GitHub documentation and source recipes permitted.


## 2026-11-01 VERIFIED Google Drive A34 outputs
- **True entire 1280x928 Ground+PAR image**: https://drive.google.com/file/d/1KuwrdAvw9gqRY9UjB5jGNe34Eyd1bsK5/view
- True A34 full-size Ground: https://drive.google.com/file/d/1SfgJbfslyeP5waKNYlmR5dFJqw4gfZz2/view
- True alpha compiled A34 PAR50: https://drive.google.com/file/d/1gAgvQhgcA-Cw8sxwhwUBJb7rtX0XCHcO/view
- **Actual native VX camera scroll 9-view montage**: https://drive.google.com/file/d/1fhalInoWUcj3SCx_zWrlUwfXJ7y1iqP_/view
- **1280x928 Ground3 original reference vs current A34 side-by-side quality gap**: https://drive.google.com/file/d/10bwtrlJY27iPhqfF_lwkzrTz3CNteTk6/view
- 640px map thumbnail: https://drive.google.com/file/d/1u65_tTktWOaveOCfh9ORIaGDg2Xc8lf1/view
- Trail semantic mask: https://drive.google.com/file/d/1k8HyKLPAKm0hu2zrVzKA7VqqDK6884Do/view
- Habitat mask: https://drive.google.com/file/d/1aUCQyPo5eY3-JXCPTM-HZE7DMQ1hK6MT/view
- Source scene manifest with all 210 original owned foot objects: https://drive.google.com/file/d/1SSlX0JgozulcliEJosv7h9ingSS5UV6R/view
- Native VX actual 11 cases/22 screenshot QA: https://drive.google.com/file/d/1axGOXU4o_g7qY6iMcHjo8bDuBYyDQnFK/view
- VX viewport vs source pixel discrepancy analysis (first 2 title fade failures; late 9 max RGB 3): https://drive.google.com/file/d/1RmWWE5580Eq1YxvRyqjxkgrop9-aLVFf/view
- Godot 4.7.2 full-size GPU pixel QA: https://drive.google.com/file/d/1RsCMLQenOdcKY5gbIPD9BVzHHxU931CY/view
- Native separate 3626/3626 cold SHA QA: https://drive.google.com/file/d/1QeSnXPxg-EiiXxPzmaeb-YE8wGl2__UX/view
- Latest comprehensive native engine QA: https://drive.google.com/file/d/1P-dzkf_O2tU7A8c3b8JvnbAiZopNsl2p/view
- **Complete PRIVATE A34 ZIP: 49,547,735 bytes; 304 items including 210 unique PNGs, 22 native VX frames, 6 full-size GPU frames and 6 crops, isolated test-only Map050/Scripts, QA/repro source**: https://drive.google.com/file/d/1BbJhrIv3OiI-0l8vwjedY6auOaGExI-3/view
- Full ZIP local CRC, ALL member SHA256 and separate cold re-extract PASS. Remote Drive listing confirms file title and byte count, not separately redownloaded remote ZIP SHA.
- Private source folder: https://drive.google.com/drive/folders/1OfIRpAqsTU-QXyLFBe8aOnU6UKovEWgQ
- Formal A34 failure register: https://drive.google.com/file/d/1ton3fw_DImNBMJIkRIF_xjr85aMFT8f3/view
- Detailed A34 Handoff: https://drive.google.com/file/d/18nM8t-S7Nb7IxG3eIRJUhjz58_5ZV1Gh/view
- Latest A34 CURRENT_HANDOFF: https://drive.google.com/file/d/1dyxzQ3Cq-1lLVqOKqUMfzkpuIOW50scE/view

**A34 engineering PASS; not a fully finished village, art PENDING, Formal Seal NO.**
