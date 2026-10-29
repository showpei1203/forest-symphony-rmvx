# Forest Symphony｜R17 Stage7 獨立高精細 PAR 修復與全新 Ground 實測（2026-10-29）

**結果：Ground/PAR TECH CANDIDATE／PAR Richness 提升／Ground ART FAIL／Original Source Editability HOLD／FINAL SEAL NO。**

## 核心問題與實際變更
上一輪 Stage5 新生成的兩張原圖（Ground 1434×1097；PAR 1448×1086）不能直接配對，但其中的 PAR 是**單獨生成的透明層**，具備房屋、樹、燈、欄杆、招牌、木桶與花草等高細節概念。本輪**沒有由完整 Master 反向切出 PAR**。

在 Windows 原機進行新的來源先行實驗：
- **GROUND**：基於自行開發的原始繪製程式、全新種子與重新規劃的路徑，從零生成原生 544×416 RGB 地面，未使用 Stage4 或 Stage6 舊 Ground 圖片再修改。
- **PAR**：從 Stage5 獨立透明原圖保留所有原始物件，進行一次 Alpha 範圍 70–215 線性對應到 0–255，採最近鄰等比例轉換至 521×391，放進 544×416 透明畫布之座標 (11,12)。原始來源1448×1086，X/Y縮放分別0.359806/0.360037，差距不超過0.1%。該步驟**有實際縮圖，不可說原始素材已經是 native 1×**；也沒有因此變成逐物件可編輯的素材集合。
- 獨立原始 PAR SHA256 `f44b7c11c7b5bbf345f4c5b8a7821d297fc8dd6c52166cb160bf6cc83ae7eb2d`，與 Stage5 備份內容一致。來源讀自獨立 PAR PNG，而非完成的場景合成圖。
- 尺度視覺：兩棟房、神聖大樹、燈具、花圃與木製柵欄的比例和密度顯著改善，已較接近你指定的 PAR 範例美術水準。Ground 地面仍過於平整、碎石路偏程式感，不符合 ground3 級品質。

## 核心 Gate 數據

| 項目 | Stage7 實測 |
|---|---|
| Ground | 544×416 RGB，SHA256 `62e1ed6ed604568096172511787cf4aeacde604dea7ed56d4e21c2f8e38db2eb` |
| PAR | 544×416 RGBA，SHA256 `e5c33ddd1ca4ffb00eb89306c57fbd60f3ed2c5bf4e83992f2124a47d07ef3e9` |
| PAR alpha0 | 112,766px |
| PAR alpha255 | 108,885px |
| PAR partial alpha (1..254) | 4,653px；來源邊緣需要人眼審核，官方驗證器給出 warning |
| PAR 外框非透明像素 | 0 |
| 官方 Source Validator | exit0 / `TECH_CANDIDATE_ONLY_NO_ART_PASS` |
| Stage5 strict Canvas/Alpha Gate | exit0 / `TECH_CANDIDATE_ONLY_ART_HOLD` |
| Cold regenerate | Ground、PAR、Composite QA、PAR Checker QA、Source Manifest 五份 SHA 均完全一致 |
| 1px 尺寸負向測試 | exit2，攔截 |
| 1px 邊緣 Alpha 負向測試 | exit2，攔截 |
| 偽造 PAR 來源 SHA 負向測試 | exit2，攔截 |
| 私人 ZIP | 4,224,399 bytes，15 entries，CRC PASS，SHA256 `cf61454d94f4ea6ace558cb7a4da61091cd969a67e35fff5eb7592166659c1c9` |
| Windows E:/G:/Google Drive 雲端下載 SHA | Ground、PAR、ZIP 三方一致 |

## 美術及來源 FAIL/HOLD
1. **GROUND_ART=FAIL**：雖是全新來源、未修補舊 Ground，但程序草地與稀疏石路缺乏 ground3 的天然材質層次及細節。
2. **PAR_RICHNESS=VISUAL_IMPROVED**：多建築、神聖樹、大量村莊裝飾細節比 Stage6 大幅提升，但目前仍需使用者 1× 驗收。
3. **PAR_SOURCE_EDITABILITY=HOLD**：最新 PAR 源並非從完整 Master 後切，但仍是模型一次生成的「多物件合成在單一透明來源」；未交付每棟屋／樹／欄杆／燈之獨立可編輯 sprite。不能當作已達最終 Source Kit。
4. **PAR_FLOOR_FLORA=HOLD**：屋旁和樹根花草與原件黏合，需判定哪些屬高灌木（PAR）哪些應歸地表花草（GROUND）；禁止從合成 Master 逆切。
5. **PAIR_VISUAL=HOLD**：實際畫布對齊和 Alpha Gate 通過，但房門到地面道路、樹根接地、Ground/PAR 繪畫精緻度一致性尚未驗收。
6. **TREE_FOOT=HOLD**：為避免使用者指出的 Ground 孤立樹幹，本輪保留完整樹幹在 PAR，Ground 只有接地陰影；仍與歷史最低32×32歸Ground規則不同，不能假稱兩者同時符合。
7. **FORMAL_SEAL=NO**。所有 K4 Sealed、FS Map.rvdata、Scripts.rvdata、Collision／Passability 完全未修改。使用者自行合成 NEW_GROUND 及通行度。

## 連結與下一步
- [Google Drive 私人 Stage7](https://drive.google.com/drive/folders/1tFys5Al3zV0NxAYf7tpWJEM-eySC1Gji)
- [GROUND.png](https://drive.google.com/file/d/15EzJoNE-ucLIkr1c7UfRoiIfZHXJT8qL/view)
- [PAR.png](https://drive.google.com/file/d/1nyT-Ln7d45LiRBQPxCoUM53ID8vdFO3-/view)
- [合成 QA](https://drive.google.com/file/d/1wQGzJ0LR7H0BFaFJazgV7GOnqXFgC99b/view)
- [私人冷重建 ZIP](https://drive.google.com/file/d/1R__XnrIdFo8figVYJKsXyjN43pdqDqFb/view)
- [來源生成腳本](../../tools/r17_direct_stage7/build_stage7_source_first_ground_clean_par.py)
- [冷重建與負向驗證](../../tools/r17_direct_stage7/package_cold_stage7.py)

**真正的後續工程瓶頸已縮窄為：高品質的新 Ground 與 PAR 裡各物件來源可編輯的真正原生化。** 對 Stage7 產物只許標記 visual candidate 和 TECH PASS，不得封版或要求使用者接手修好美術。
