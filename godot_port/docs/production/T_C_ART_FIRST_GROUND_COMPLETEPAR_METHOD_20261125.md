# 最新正式更正｜2026-11-26 D27「整張完整 PAR 一次生成」優先於以下歷史 SOP

**最新使用者指令：目標是一次性生成整張完整的 PAR，而不是生成與修正單獨部件。**
正式規格全文：[`T_C_D27_ONE_PASS_COMPLETE_PAR_AUTHORING_CONTRACT_20261126.md`](T_C_D27_ONE_PASS_COMPLETE_PAR_AUTHORING_CONTRACT_20261126.md)。下文過去 D18-D26 所有「從來源切 Alpha 島、白/灰去背、分群重排、單獨生成橋與工坊再拼圖」只作技術歷史，**自 D27 不得作為 T-C 量產合格來源**。
以鎖定 D17 Ground 作地貌及 32px 世界比例參考，同一次作者生成**整張全非地表、真透明 RGBA PAR**，在同一個原生世界畫布完成全部房屋、橋、吊車、屋棚、燈、旗、岩柱等的材質／光向／透視／對位。不生成 Master、不對單件重畫或調位置，也不把失敗 RGB/錯尺寸 plate 用重排硬修成正式候選。整張 SOURCE Gate → 只做 1× 整張 Composite → 必要的真 Godot 原生 → 使用者 ART Gate；失敗就換整張出圖方法。**正式 ART 仍0/12**。
此新規則覆蓋舊文中「連通物件群重新配置也可做正式產出」的例外，但不修改或刪除歷史成果。

---

# Forest Symphony｜T-C「Ground FIRST → 完整 PAR」美術量產方法（ART-FIRST RESET）
版本：v1.0｜2026-11-25｜適用：T-C 六地形×村莊／迷宮（12 張）｜唯一新引擎：Godot 4.7.2

> **現況不可美化：目前是「可重建雙圖＋D18/D19 真素材 Godot 原生渲染成功」，不是「美術驗收通過」。正式十二圖 ART PASS = 0/12，沒有任何一張能宣告美術達標。** 本文件記錄哪些工法已有效、哪些尚未證明；目的是回到高品質地圖美術生產，而非繼續延伸碰撞／動畫／AI 工具研究。

## 一、這次真正證實的成功原因

1. **完整構圖比貼片更自然。** D16 用舊材質重組整張 Ground，出現鋪面重複、羽化接縫、路網不自然；D17 改成一口氣生成完整 Ground-only 原始畫面，對同一 scene 採記錄清楚的原生 1× 裁切，解掉 Ground 的宏觀拼貼問題。以地形高低、道路和熔岩的**完整連續構圖**作為風格基礎，不再把同一塊 32px 素材無限複製或擴大模糊。[D17 實證](../handoff/TC_D17_FS_04_MAZE_GROUND_FIRST_COMPLETEPAR_SOURCE_QA_20261123.md)。
2. **先 Ground 後 PAR，Ground 冷凍為世界座標。** Ground 本身只包含草土、雪、沙、火山玄武岩、路、水面、貼地花碎石等「地表」；生成並確認後立即鎖定 Source SHA、原生尺寸、道路和關鍵物件預定落點。第二張 PAR 只能參照此 Ground／同一 Blueprint／色盤／視角／光向，**不可改畫原 Ground**。這避免每輪修房子就把道路改掉。
3. **PAR 必須另起一張，完整包含所有非地表物件。** 一次產生與同一世界相符的整體透明物件布局：**整棵樹／完整房屋／岩柱／石橋及欄杆／燈／圍欄／道路標示／屋簷／礦車／燈具……**，不管會不會擋人物都在 PAR。不能先生成 Ground+物件的 Master 再回頭反切；不能只挑會擋角色的樹冠。這項是使用者最新最高優先製程。
4. **真正 Alpha，而不是檔名叫 RGBA 就算透明。** D11 多次輸出看似 RGBA、實際 `alpha=0` 為 0 的不透明 Master，全部拒收。D13、D18 已證明能取得獨立來源且真正 `alpha=0`；D14-D15 證明**只有來源本來就是獨立非地表白底 plate**時，才能使用白底轉透明 fallback，且要修封閉白底大洞、保留白色裝飾，**絕對不得對含 Ground 的 Master 作此處理**。[D14](../handoff/TC_D14_FS_04_VILLAGE_WHITE_PLATE_TRUE_RGBA_NATIVE_PROBE_QA_20261122.md)／[D15](../handoff/TC_D15_FS_04_VILLAGE_WHITE_VOID_REPAIR_SOURCE_QA_20261123.md)。
5. **保留完整物件輪廓，而非以多邊形硬裁。** D17 舊 PAR 重排裁掉 **16,915** 個原來源 alpha>0 像素，建築/橋梁斷面可見；D18 改成重新生成獨立全非地表作者圖，按完整 alpha 連通物件群及 bounding box 原生 1× 放置，六主要物件群 **641,682** 個來源 alpha>8 像素保留、Polygon Trim **0**。但 138 個微小孤立物件像素未納入、Alpha 低階雜訊有清理，**不得宣稱全部原始像素 100% 相同**。此方法是可用的**技術 fallback**，不代表生成器已原生 1280×928 一次完成，也不代表世界足點已正確。[D18 實證](../handoff/TC_D18_FS_04_MAZE_INTACT_COMPLETEPAR_SOURCE_QA_20261123.md)。
6. **製圖與驗收分階段，不把工程綠燈當藝術綠燈。** D20 已使用**真私人 Ground+PAR**在 Godot 4.7.2 取得 1280×928 原生 1× 截圖、Ground/PAR 雙 SHA 和透明驗證 PASS；僅證明載入、Alpha、像素尺寸／世界原點沒有明顯問題。橋頭接地、建築比例、畫面整體自然度、邊界及人物視覺前後關係仍未過 HUMAN ART。[D20 原生實證](../handoff/TC_D20_FS_04_MAZE_REAL_PRIVATE_GODOT472_NATIVE_1X_QA_20261124.md)。

## 二、正式一張地圖的「最短且完整」製圖 SOP

**0. 鎖定 Style DNA 與 Scene Blueprint（一次就好）**：先讀 Drive 的 `FS_SIX_BIOMES_WORLD_ART_PLAN_20261114`、`FS_12_MAP_ACTIVE_MASTER_20261116` 和既有 A35/A36 參考，確定正式 scene ID、地形主材質、32×32／top-down 3/4、畫布應有格數、整張道路與入口出口、光向／色盤、樹和屋的體量、非地表家族及世界落點。森林以自然林帶/土路，火山以連續玄武岩/熔岩裂岸；**不是同圖換色**。規格以該場景正式 manifest 為準，40×29=1280×928 只是目前火山樣本；46×33 來源樣本不能擅稱 40×29/80×58 正式圖。

**1. 一次作者化完成整張 GroundOnly**：一張真不透明 RGB PNG，完整可視地表、道路分岔與群落，不得混入房屋、整樹、橋欄杆、岩柱等 PAR 內容。審視 1× 畫面是否連續、有自然過渡且無重複複製紋理；**整張 Ground 先通過 Ground 來源和構圖 Gate**，保存原檔/尺寸/裁切座標/SHA，之後鎖住不再重生。

**2. 同 Blueprint、同風格生成「完整獨立 PAR」**：輸入剛鎖定的 Ground 作**風格／地點對位參考，不把它當需消去的底圖**；另外製作一張真正透明 RGBA，全部非地表物件盡可能在整張視覺構圖中同時安排，橋頭、屋腳、道路預留須對位。最優先的是**一次出完整全非地表 plate**，不是逐棵樹拼貼。若生成器拒絕透明且只給**獨立白底的純非地表 plate**，才使用受控 White-key fallback 並人工檢查橋／屋內的封閉白區；若吐出帶地表的 Master，立即 REJECT，不再靠遮罩/反切偷救。原 PNG 留存。

**3. 原生畫布及透明 Gate**：Ground 與 PAR 必須同寬高、原點、1× 世界像素；PAR 要有大量真正 alpha=0 且有可見完整物件，不能有整張地表底色、大片白底或嚴重 Alpha 雜訊。生成來源過大時，只允許**有數據證明不裁掉重要物件**的同座標 1× 裁切；若需重排，按**完整連通物件群**放入目標 1× 畫布並保留原始定位與移動後座標，**明確標為 re-layout 不是作者原生一次出圖**。D13 裁切曾損失 82,476 px（12.4%）來源高不透明物件；D14 裁切損失 106,197 px（12.8%），不得再強裁冒稱完成。

**4. 只用 Composite 做「整張畫面美術 QA」**：`Image.alpha_composite(GROUND,PAR)` 是預覽，不是任何一張來源。先 1× 看**整張畫面**：道路連續、視覺重心、場景層次與物件密度；再看相機四邊：主建築/樹/橋沒切斷、背景無白洞；最後查屋腳、橋頭、樹根是否真的著地，不壓道路/熔岩。漂亮卻模糊的合成、完整 Alpha 卻出現浮空房舍，都是 ART HOLD。每張完整候選輸出 Ground/PAR/Composite 三圖及尺寸、Alpha histogram、SHA 和 Failure Log。

**5. Godot 原生只做簡短終檢，人工 ART 是最終權威**：在已存在的 Godot 4.7.2 1× 雙圖 renderer 讀真私人 PNG、NEAREST、同 (0,0) 原點，截圖並核 Ground/PAR 雙 SHA。真引擎渲染 PASS ≠ ART PASS。**人眼要以原稿豐富度、世界風格 DNA、道路自然、建築／樹群比例、落腳與邊界為標準明確核准**，才能把該場景由 HOLD → ART PASS。**尚無使用者核准，計數永遠 0**。碰撞、角色遮擋、NPC、劇情、ATB、存讀交另一條 Godot 工作線；不再當 T-C 生圖前置依賴。

**6. 修正阻斷、第二張樣本及量產**：M1 完整候選 → M2 真原生雙圖（一次） → M3 只修**影響畫面完整性的阻斷** → M4 同色系**第二張完整地圖**。非阻斷微瑕疵最多兩輪；仍不改善就列入 Failure Log 並改方法，不能無限雕一棟屋。**先至少拿到一張經使用者 ART 核准的範本，才可說量產方法已成功**；之後六地形各有獨立 Style DNA、村落與迷宮不同構圖。每輪作業工時原則 70% 生圖／20% QA／10% Handoff（依 T-C Launch Prompt）。

## 三、硬驗收表：什麼可以 PASS，什麼絕不能假冒

| Stage | 可宣告 PASS 的必要證據 | 未通過的處理 |
|---|---|---|
| GROUND SOURCE | 整張連續且不含非地表、尺寸/裁切/SHA 可靠 | REJECT／重作 Ground，不對錯誤底圖繼續生 PAR |
| COMPLETE PAR SOURCE | 真獨立非地表、完整物件、真透明 Alpha=0；與 Ground 視角/語義一致 | REJECT 不透明 Master／白洞／剪斷物件 |
| STRUCTURAL PAIR | Ground 與 PAR 同原生 1× 世界畫布、SHA、靜態合成 | TECH HOLD，禁止靠縮放或錯位假完成 |
| GODOT 4.7.2 NATIVE | **這一批真正私有圖片**渲染出的 1× PNG 與 logs | NATIVE NOT_RUN／FAIL，不能借 synthetic CI |
| **HUMAN VISUAL ART** | **使用者對整張 Ground+PAR 1× 成果明確確認美術達標**，無嚴重拼貼感、建築破圖、浮空/切邊、世界不連貫 | **ART HOLD，不增加 12 地圖正式 PASS** |
| Gameplay collision / Actor occlusion | 另一工作線的正式 map/collision/ACTOR01/game-loop smoke | 與 T-C 生圖 ART 狀態分離 |

## 四、已驗證實績和下一個指定完整單位

- **技術成功：** D11 火山 Ground-only；D14/D15「獨立非地表白底來源→受控真透明」但原生尺寸 FAIL；D17 完整連續的火山 Ground；D18 真獨立全非地表、六完整物件群無 polygon trim 的 40×29 PAR；D20 私人來源 Godot 4.7.2 1× 雙圖原生 PASS（D18、D19）。
- **藝術未封版：** D16 路面拼貼、D17 裁斷、D18 局部煙霧貼邊/橋腳定位、D19 雖四邊無高不透明貼邊但前景重疊由 868→1596；D21 橋面角色遮擋是**遊戲 runtime 問題**，不當 T-C 下一個美術產出。正式台帳 `formally_art_sealed = 0`（12 張）。
- **下一個美術工作單位（固定）**：取 **FS_04_MAZE** 的 [D17 1280×928 Ground](https://drive.google.com/file/d/1fHMcvGb6W3AaZvI07uN-GsSrLe0h5c2k/view) + [D18 1280×928 完整 PAR](https://drive.google.com/file/d/1HbMxtnvKQMif4V_r7jOX7UyLRUpznCbd/view) + [D20 真 Godot 1× 畫面](https://drive.google.com/file/d/1eDyr2FwOk8Mdv3WEjiOe5isYkiWoU2qA/view) 當技術基準，**專心判定與修正整張的美術：房舍是否切斷／接地、路徑與熔岩橋頭、天然群落、遠近一致性、與 A35/A36 風格差距**。若整體作者美術仍不達標，改用同世界 blueprint 重生**整張完整非地表 PAR 或 Ground**，而不是再做碰撞/角色 z-index／逐 pixel 修補。達到人工 ART PASS 後，才用同色系 Blueprint 完整製作 `FS_04_VILLAGE`，再循既有十二圖計畫推進。**不可將 D18 技術樣本叫做已達標的美術范本。**

## 五、來源與持續交接（跨新對話有效）
- 規範：[正式 Drive Ground-first 完整 PAR SOP](https://docs.google.com/document/d/1zWXO6Z8SHobSK2jfI-M6-p6JDb81BniIH_4UCLiJhIw/edit)；[T-C 最新啟動規則](../research/launch/T_C_MAP_LAUNCH_PROMPT.md)；[最新 T-C CURRENT_HANDOFF](../handoff/PIXELLAB_TC_CURRENT_HANDOFF.md)。
- 證據：[D17 完整 Ground](../handoff/TC_D17_FS_04_MAZE_GROUND_FIRST_COMPLETEPAR_SOURCE_QA_20261123.md)；[D18 完整 PAR](../handoff/TC_D18_FS_04_MAZE_INTACT_COMPLETEPAR_SOURCE_QA_20261123.md)；[D20 原生](../handoff/TC_D20_FS_04_MAZE_REAL_PRIVATE_GODOT472_NATIVE_1X_QA_20261124.md)。
- 12 圖台帳：`godot_port/tc_factory/biomes/TC_SIX_BIOME_12_MAP_PRODUCTION_QUEUE_20261121.json`。禁止憑假設改正式完成數。
- Source of Truth：**所有 PNG、原始生成 plate、A/B 圖與 QA ZIP 存私人 owner-only Google Drive**；**GitHub 僅存方法、程式、元資料、Failure Log 與 Handoff**；Linear `SHO-39` 留狀態。完成後 WRITE→READBACK，禁止覆蓋 A35 正式資產、T-A/T-B 或使用者 Windows `E:` 工作目錄。
- 不修改已安裝 Skills 的封裝版號；舊 `fs-map-ground-par` SKILL.md 的「截至 2026-11-22 D11 沒 PAR」為**歷史描述**，**不得用它蓋過 D20/D21 CURRENT_HANDOFF**。新對話先讀本方法與最新版 Handoff，必須持續區分 **TECH PASS／NATIVE PASS／ART HOLD／USER ART PASS**。

**金句：**「好的地圖不是兩張 PNG 疊得起來，而是兩張分開生成時就屬於同一個世界。」


## 六、2026-11-25 D22 真實「美術優先」產線回歸測試（此章為最新證據，不改原規則）

**本輪真的新生成一張完整全非地表獨立 RGBA plate，而非沿用舊 PAR 重排當新美術。** 新原始影像 `1473×1068` SHA `7ab52f35107f468439436ff23e43ae879df6a90d9d55039e0fb761273fe32828`，有真正 `alpha=0 1,166,479` 個像素，含十個主要完整物件群。保留 D17 Ground 1280×928 SHA `2f9ad1d596171327fbc92f797495ea12d0e231c551da8eda3437035af2d6d94e`；全圖規劃改為左上工坊、右上吊車、右側熔岩裂橋、左下小工坊，中央道路留白。全十組物件原像素 1× 重排，沒有 Polygon 物件截斷；A/B 及 Raw/Matte 四版宏觀對照後採 B（A 物件重疊2713px、B 617px、D18 868px），外緣高 Alpha=0。修正模型來源 556 個紅色邊緣污染像素，原作者來源無損另存，絕不假稱所有 Alpha 保留或原模型直接產出 native 1280×928。

[**D22 新私人來源＋PAR＋真 Godot 4.7.2 原生 QA 十七檔完整 ZIP**](https://drive.google.com/file/d/1LJtjHRHl5f8F5FtGBK5uep_f6f243mGQ/view)｜[新 PAR 1280×928](https://drive.google.com/file/d/1cFR_YREdTCd82uNWyI3RxYbfIoo8FRha/view)｜[實際 Godot 4.7.2 原生圖](https://drive.google.com/file/d/1R7KnV8-1cgChPaOMnFoblvU97j6X3v8X/view)｜[D18／D22 真原生 A/B](https://drive.google.com/file/d/1nIMAztQ5SEJ4g1upb6vVTsQkT3F470w4/view)｜[完整 D22 實證與 Failure Log](../handoff/TC_D22_ART_FIRST_FS_04_MAZE_NEW_COMPLETEPAR_NATIVE_QA_20261125.md)（後者在隔離實驗分支，主分支尚未合併）。

**補足「成功」語意：** ART-FIRST 流程在 D22 再次實際產生雙圖可重現且 Native PASS；但是新 PAR 原模型仍是 1473×1068 再依世界座標 1× 重佈局、橋兩側實地接合/物件光向細節/既有 A35 美術比對尚未 USER ART 核准，正式封版仍 **0/12 HOLD**。下一輪優先原生 1× 真視覺的整張美術評審與新完整 PAR 作者化，不能把橋梁碰撞、遮蔽演算法當成 T-C 必備製圖工作。


## 七、2026-11-26 D25：把比例驗收移到生成來源前段（正式經驗增量）

**新經驗不是又成功一張圖，而是確立新圖為何一直不合格。** D24 已有真原生透明 RGBA（Alpha0 1149019）和 11 個完整物件，1× 合成、0 相互重疊、0 外框剪斷，但源橋 **388px=12.125格**、鍛造工坊 **495px=15.47格**，相對 D17 的窄熔岩裂谷與 32px 畫面**語意比例完全不合理**。過往先做全圖重排／Godot 渲染、後面才發現橋頭不著地，造成多輪「程式成功、藝術仍 HOLD」。

**D25 產線硬改：** 生成前使用 Ground 的 1280×928 世界 Blueprint 鎖主物件**尺寸與預定足點**，橋限 **160～192px（5～6格）**，主工坊寬 **<=288px（9格）**、高 <=360px，通路清晰保留；從**獨立原始**非地表 PNG 的 alpha>32 連通物件量實際 bounding box，**先執行 ART geometry gate**。任一超標即 SOURCE REJECT，不得送 PAR 排版、Godot、角色物理或假稱已可量產。若連續兩次生成來源輸出 RGB 假透明／無關報告式圖片／物件超標，停止相同自由提示，切換既有且已驗證可按固定 bbox 作者化的工具，或重新整張 Ground-first 世界構圖；不要把舊長橋縮放壓扁當新原生圖。

**D25 真驗證**：使用未修改的 D17 Ground SHA `2f9ad1d596171327fbc92f797495ea12d0e231c551da8eda3437035af2d6d94e`、D24 新獨立原 Source SHA `69fcdc6602394ddc7ece3e73515fe657ab74976c20aaa1548b58b712cfcca407`，直接量出橋 388x215、工坊 495x501；新 Gate 正確回 `REJECTED_BY_GEOMETRY_GATE`，五項源尺寸負面／正面自測 PASS，[CI #45780762391 SUCCESS](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45780762391) 為 synthetic 程式證據。另生成**只有 QA 標註**的 Ground 世界橋長方框 `[944,420,1136,626]` 和**暫定**岸邊參考點 (970,603)/(1110,603)，不是新增 Bridge PAR 或碰撞資料，來源 ART 仍 **0/12**。

[**D25 私人九件完整經驗、圖像 QA、作者 Blueprint、測試／拒收記錄 ZIP**](https://drive.google.com/file/d/1VsNJQcEFhM0-Se4sYvXWsSjrXFXKop34/view)｜[D25 完整正反實證與 Failure Log](../handoff/TC_D25_ART_GEOMETRY_GATES_LESSONS_HANDOFF_20261126.md)（隔離實驗分支）｜[完整 QA-only Ground 尺寸導引圖](https://drive.google.com/file/d/1Ca9xs3wGfO2CtFUjgQuzA3pwoRrwZj0-/view)。

**切記**：D25 **沒有**通過的新獨立 PAR、正式 Ground 新版本或真 D25 Godot native 截圖；不能因 source gate 程式 PASS 就更新任何一張正式 ART PASS。畫面漂亮 ≠ 世界尺度和腳點合格，下一完整單位仍是 Ground-first 世界一致、真透明完整 PAR 的美術創作。


## 八、2026-11-26 D26｜短橋尺寸 Gate 成功，但完整地圖畫風 Gate 拒收（新真實反例）

D25 尺寸門檻可量產地拒絕 388px 舊橋、495px 工坊；D26 隨即在真 D17 Ground 上以 1× **完全新作者化** 192×156px 短橋、282×356px 小工坊、236×288px 吊車、225×209px 倉庫，配 D24 獨立 PAR 來源剩餘七個完整、無縮放物件，成功重建一張同世界 `1280×928 RGBA CompletePAR`，但**整張畫風未達標，已正式 ART REJECT**。因此後續不得把「先過尺寸再進 Godot」誤讀成只需尺寸/Alpha/零重疊就能宣告新美術合格。

- **工程證據**：不變 D17 Ground SHA `2f9ad1d596171327fbc92f797495ea12d0e231c551da8eda3437035af2d6d94e`，獨立新 1× PAR SHA `f8096afedba93dd66211cfd92385596ffda061c0d6cb6688fc762d83887805fe`，靜態合成 SHA `3b7cbd819e2983c2548eb98e386bc2e15593912e93f0c30b41c2e43e31b94920`，真正 alpha0=1003743，物件相交=0，世界畫布外框高 Alpha=0；四項冷重建 SHA 完全一致。
- **美術拒收**：新小物件是**程式手繪像素風、非同一模型的一次全 PAR 作者圖**；屋頂、架構與橋的平板色塊，與 D24 來源及 D17 Ground 的豐富石材、屋瓦、微光細節有**肉眼可辨的風格斷層**。可見唯一 RGB 的差異 D24 forge 112457 vs D26 forge 57、D24 bridge 42793 vs D26 bridge 38，只作風格變化診斷，**不是人工 ART 分數或可取代視覺審核的規則**。D26 省去 Godot 正式跑圖是合理 fail-fast；**正式 ART 0/12，D26 PRIVATE native NOT RUN**。
- **圖像生成失敗三例**：孤立橋源仍是 RGB 棋盤、且尺寸大；另外兩次拿到混入 Ground 的 Master（一次還是資訊式圖片），即刻拒收，不得從圖像上的文字認領「技術／美術 PASS」，更不得拿混合 Master 逆切 PAR。
- **製程新增順序**：Ground 已鎖 → **同一 Style DNA／物件作者一致性**與橋腳位置設計 → 取得真正完整獨立非地表來源 → 先 Source geometry + alpha + style 類比整張肉眼驗收 → 才做完整 PAR 1×對位、合成和有限 Godot native → 使用者 HUMAN ART Gate。兩次產生混地表/錯媒介/比例錯/風格跳動就改作者工具或重新 Ground-first 構圖，不再用手工少色階替換 AI 高細節物件。
- **現有工具路線**：先確認既有 PixelLab／Map Workshop 是否在當前工具鏈實測支援**固定世界像素尺寸 + 同風格 source authoring**，不假設可用；禁止未核准付費 API 自動觸發。T-C 工廠追求一張已經一致的完整 PAR，不能再次轉為研究角色碰撞／事件。

**D26 真來源/失敗樣本/風格 A/B 完整 owner-private 封存**：[19件 ZIP 17,973,255 bytes CRC PASS](https://drive.google.com/file/d/1AziDn0gHc01P5wdCBmlbOcv_Kvr1DM1v/view)｜[正式 D26 Failure Log 及累積經驗](../handoff/TC_D26_ART_FIRST_COMPACT_ASSETS_STYLE_REJECT_20261126.md)（實驗分支）｜[D24 vs D26 全景](https://drive.google.com/file/d/1nLwACbNfYJapHJUXzYw69urrunUPzdD3/view)。所有新原圖與 D17/D24 來源均私人，正式 ART 仍 0/12。
