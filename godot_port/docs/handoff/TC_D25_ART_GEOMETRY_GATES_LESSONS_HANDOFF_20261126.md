# Forest Symphony｜T-C D25｜美術優先經驗總結、比例硬門檻與接手 Handoff

**日期**：2026-11-26（Asia/Taipei）  
**場景**：`FS_04_MAZE`「熔脈裂橋」  
**工作線**：T-C 隔離實驗 `feat/fs-tc-d12-chroma-par-20261122`，不 merge 不覆寫 T-A/T-B/Godot 主線  
**正式藝術進度**：**ART PASS 0/12**  
**D25 產出類別**：真 Ground 量測＋只供 QA 的尺寸定位圖＋防錯程式／負面測試／正式製圖方法。**D25 沒有新的合格 Ground 或 PAR，沒有取得任何原生 Godot D25 渲染。**

## A. 來源核對與本輪真實測試

- 從 [D24 最新 Handoff](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-tc-d12-chroma-par-20261122/godot_port/docs/handoff/TC_D24_ART_FIRST_FS_04_MAZE_TRUE_RGBA_BRIDGE_ALIGNMENT_QA_20261126.md)、[ART-FIRST 正式方法](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-tc-d12-chroma-par-20261122/godot_port/docs/production/T_C_ART_FIRST_GROUND_COMPLETEPAR_METHOD_20261125.md) 與 D24 實際 PNG 回讀開始，沒有使用舊的碰撞／角色遮擋任務作為前置條件。
- 正式已鎖 Ground：`1280×928 RGB`、SHA256 `2f9ad1d596171327fbc92f797495ea12d0e231c551da8eda3437035af2d6d94e`。
- D24 **獨立真透明非地表 RGBA** 原始圖：`1474×1067`、SHA256 `69fcdc6602394ddc7ece3e73515fe657ab74976c20aaa1548b58b712cfcca407`；未修改。D24 B 完整 PAR 與前一輪原件也沒有覆寫。
- 針對 D24 原始圖片的 `alpha>32` 八連通物件精確計算：**11 組**，主工坊 **495×501 px**，完整橋 **388×215 px**，都超出依現有 Ground 設定的比例硬門檻。驗證來源為原始 Source，**不是預覽圖的主觀估算**。
- 已執行 `fs_tc_d25_art_geometry_gate.py`，在進入重排／Godot 前回傳 `REJECTED_BY_GEOMETRY_GATE`；失敗明細：`BRIDGE_WIDTH_EXCEEDS_6_TILES`、`FORGE_MORE_THAN_9_TILES_WIDE`、`FORGE_HEIGHT_TOO_LARGE`。五個合約回歸測試全部 PASS，這只證明程式會拒收不合格比例，**不是美術 ART PASS**。
- 量測後輸出兩張**純標註 QA PNG**：已鎖 Ground 上標 `bridge`、`forge`、`crane`、`shed` 的參考範圍及兩岸候選接點；另一張為 D24 全景 vs Ground+目標框的對照。標註框不是新增美術、不是正式 Ground，也不是碰撞／通行圖。

## B. 這次必須保存的「因果經驗」

| 經驗 | 經過 D11～D25 實證的因果關係 | 新的產線決策 |
|---|---|---|
| **先整張地表再畫 PAR** | D16 以舊片羽化拼地表留下重複接縫，D17 整張連續 Ground 改善了地貌；反覆改 Ground 導致物件落點追不上 | Ground-only 鎖正式尺寸／SHA／道路，只有完整世界變更才開新候選，絕不覆蓋原件 |
| **PAR 是完整非地表** | D17 從舊圖多邊形裁出橋與屋舍，損失 16,915 個有效像素；D18 按完整源物件重排，Polygon Trim=0 | 不能從 Ground+非地表 Master 逆切；也不能只生角色會遮住的物件 |
| **透明是像素事實** | D23 新模型交 RGB 棋盤格，去底雖可暫時製作 RGBA，容易有硬邊；D24 能直接取得 RGBA 真透明 alpha=0 | 優先直接 Alpha RGBA；棋盤底＝FAIL 原生透明，不可拿「RGBA 檔名」矇混 |
| **1× 不代表世界比例正確** | D24 11 物件來源全保留、無相互重疊、原生 1× 排入 1280×928，**橋仍388px、主工坊495px**，遠大於裂谷及32px遊戲世界 | **在 PAR 拼接、冷重建、Godot 前先做物件比例 GATE；超標直接 REJECT** |
| **橋頭必須落在同一張 Ground 的岸上** | D24 的 A/B 雖將右橋墩移近地面，但只是對巨橋搬位置，無法治癒源橋過長；僅依顏色取樣也不能認證走位 | 優先同世界來源對位：橋完整寬 160～192px，候選包圍框 (944,420)～(1136,626)，兩側候選腳點 (970,603)、(1110,603)；**全屬 ART 參考，不是已核准碰撞** |
| **工坊與地貌必須同尺度** | D24 主工坊 495px ≈15.5 格，佔畫面過多、遮掉地貌與道路，不能靠挪位置修復 | 全新來源主工坊 <=288px（9格），高 <=360px，位置限定在經人眼驗證的岩地，不能踩熔岩 |
| **不能把失敗的圖解當作素材** | D25 生成嘗試之一得到新 RGB 棋盤背景物件圖（非原生透明），數次針對短橋的輸出偏成施工報告資訊圖，並非獨立橋梁原圖 | **全部拒收**；不能把圖片自帶的「PASS／新橋 6 格」文字當事實；在沒有合格短橋來源前，D25 圖像交付狀態為 `NOT_ACCEPTED` |
| **ART 與 TECH 分開驗** | D20 之後實際 Godot 4.7.2 私人雙圖渲染成功，但所有迭代仍有畫面比例、世界腳點問題；D21 角色碰撞研究還分散 T-C 精力 | D25 只做美術幾何與來源 Gate；native 只在候選成立後少量確認；**正式 Human ART 0/12** |

## C. 新製圖硬規格（D26 作者化輸入契約）

- **不可變**：D17 `GROUND.png` 1280×928、RGB、SHA 上述，32×32 格、top-down 3/4、暗紫玄武岩、熔岩亮橙、青銅＋木質屋舍、整張同光向與自然道路。
- **獨立真正透明 `PAR.png`**：全地表以外**所有**物件；不出 Ground、不出白／灰格背景、不出附中文字／進度圖、不抽取混合 Master；完整建築、橋、樹/岩柱/吊車/圍籬/旗/燈都在 PAR。
- **短橋**：主體實際 Alpha bbox 寬度 **160～192px（5～6 格）**，橋身完整且左右橋墩皆在熔岩岸上；世界**暫定** bbox `(944,420,1136,626)`，腳點 `(970,603)`／`(1110,603)`。若它與岩岸視覺不合，應修改作者構圖或重作完整 Ground-first 新場景，不得擅自把舊橋壓縮縮放。
- **小工坊**：主工坊原作者寬度 **<=288px**、高度 **<=360px**；預留道路可辨識和行走視覺留白。這是下一個候選的**設計規格**，不是既有 FS 全域或歷史規範。
- **順序**：Blueprint 先量 Ground 參考座標 → 生獨立完整 PAR 作者圖 → **先做原始 PNG 比例/Alpha/背景 Gate** → 再完整 1× 世界座標對位 → 真地表合成 → Godot 4.7.2 原生源 SHA → 整張人眼風格 Gate。超標在第二步就退回，不再先做多輪布局、Godot、碰撞。
- **產線停止準則**：連續兩次輸出不滿足最小圖像媒介或來源幾何，停止重複自由文字提示，改有固定 source canvas／bbox 能力的既有 PixelLab／Map Workshop（先核工具真實可用性），或製作新的完整 Ground-first 世界 Blueprint。禁止把任何品質不達標圖強行貼回 D17 宣告成功。
- **ART Gate**：需要整張場景的自然道路、材質相容、房屋比例、短橋踏點、岩岸完整、前景物件自然密度和 32px 體系皆由使用者確認。測試 PASS 不能代替使用者美術核准。

## D. 真正完成與未完成

- **本輪新增：** D25 源尺寸拒收規則、已鎖 Ground 的短橋兩岸「純 QA」座標／落點圖、D24 真素材早期拒收記錄、五個自動化合約測試與此文件。
- **本輪未新增：** 合格新橋、完整新 PAR、美術核准地圖、D25 真 Godot 截圖。不能把生成的報告圖片算成成品。
- **不可修改：** D17 Ground、D22/D23/D24 正式素材、主 T-C／T-A／T-B、使用者 Windows `E:\`。
- **下一個完整施工單位：** 真實產出符合世界比例的**整張獨立完整 PAR**（不是再重排長橋），或若生成模型持續無法控制橋幅度則切換工具／重做**整張 Ground-first** 的世界構圖。在拿到第一張經使用者核准 ART PASS 前，正式 12 圖完成數仍是 **0**。

## E. 證據和來源界線

- [D24 正式來源 Handoff](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-tc-d12-chroma-par-20261122/godot_port/docs/handoff/TC_D24_ART_FIRST_FS_04_MAZE_TRUE_RGBA_BRIDGE_ALIGNMENT_QA_20261126.md)
- [D24 私有 15 檔封存（owner-only）](https://drive.google.com/file/d/1lFPX6IV0lJ6dNmQte1ocRHFlyPBtmMoC/view)
- [ART-FIRST 正式 SOP](https://docs.google.com/document/d/1ao0YyDWoa6CbpTzVojLfifK60DDUuZhjxt2cqZ0fNbA/edit)；[Ground-first 完整 PAR SOP](https://docs.google.com/document/d/1zWXO6Z8SHobSK2jfI-M6-p6JDb81BniIH_4UCLiJhIw/edit)
- 本文所有原 Ground／D24 物件尺寸為**本輪原始 PNG 的實測資料**；橋頭座標與光亮熔岩比例屬**暫定美術設計推論**；D25 圖像生成未通過源品質檢核，不能宣告藝術完成。

**總結句**：**「漂亮的橋」不是驗收單位；「跨對的岸、符合 32px 比例、與整張 Ground 是同一世界的橋」才是。**
