# CURRENT_HANDOFF_R12｜NEW_ELF_VILLAGE_001 (2026-10-28)
**新圖已生成，原生VX已跑兩次共28 shots，TECH PASS，ART/Master Gate A/PAR Gate F HOLD。正式FS封版完全不改。**

- R12真正新美術Master：`R12_NEW_ELF_VILLAGE_001/MASTER_NEW_ELF_VILLAGE_001_R12_CANDIDATE.png` 1280x928，新生成圖非ground3；SHA256 `eda8fa28b537d9a96ee839f8c5c667c466bd55102731d41a7a9e560362854c80`。原圖1471x1069 resize nearest到40x29格比例，有像素清晰度與原生32px角色藝術檢查風險，Gate A HOLD。
- SAM2對同一新Master生成18物件，其中14個prompt/owner檢查入選、4排除(A11,A14,A15,A17)。14 PAR獨立RGBA與Union總Alpha233875，所有RGB exact源圖。User將在後續回饋PAR，現階段未自稱語義／美術PASS。
- Collision與PAR獨立：手工幾何多邊形 + 水/牆/階梯/橋梁的候選769可通行686格/768阻擋474格。原Map003 25 Event Ruby Marshal re-serialize corrupt，**暫以隔離Game_Map setup runtime injection**，未正式輸出新的Map.rvdata；不可假稱完工。
- R12首次native14/14表面過關但實際**新PAR疊舊ground3**，被標FAIL。修正只在隔離Clone覆蓋`Graphics/Parallaxes/ground3.png`資源Key為新的Master。現`Cache.parallax("ground3").get_pixel(100,100)=[3,22,18]`對應新Master、舊ground3是[52,119,10]，已人工觀看Game.exe畫面正確新地形。避免未來混圖，production須修資產名稱。
- 修後2獨立Game.exe，每輪14/14真行走/障礙/NPC案例、14張，合計28 Native 544x416 PNG。每站位camera偏移與14源PAR Sprite世界補償符合；R12_FINAL_GATE.json Fail Closed通過。原有FS HUD/光影遮擋美術，未作Art Gate F。
- 原正式FS Scripts505頁SHA256 `5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa`，原正式Map003 SHA256 `118c6563ea89e4f644bad6e38ca01542ad4955cd4c24a7435a01409686ac1bf4` 保持未動；測試Adapter504原頁byte-exact，#480舊NameError於clone停用，新增頁1。
- 一切候選：`R12_NEW_ELF_VILLAGE_001`。輸出：`R12_MASTER_PAR_COLLISION_4PANEL_QA.png`、`R12_SCALE_QA_32PX_ACTOR_4SPOTS.png`、`R12_REAL_NATIVE_VX_4SCENE_GALLERY.png`、`PAR_R12_VX_SELECTED14_SOURCE_ONLY.png`、`R12_TILE_GRID_40x29.json`、`R12_NATIVE_TEST_CASES.json`、`R12_SAM2_18OBJECT_GATE.json`、`R12_SELECTED14_AND_COLLISION_GATE.json`、`R12_NEW_ELF_VILLAGE_NATIVE/R12_FINAL_GATE.json`、`R12_NEW_ELF_VILLAGE_NATIVE/NATIVE*`。
- 下一次優先：USER後續PAR目視回饋→改四個reject+全場物件、做1×局部Mask，修正式新資源Key/Map編譯器，正常多NPC／無HUD Native camera A/B/A／動態Ground LightShadow／Gate F。不能因TECH PASS封版。