# Forest Symphony R17 Stage10｜Source Art 石板地面重作與實測（2026-10-30）

**階段結論：TECH CANDIDATE / Ground Art HOLD / PAR Native Sprite Provenance HOLD / Pair Visual HOLD / FORMAL SEAL NO。**

## 本輪真正修改的東西
1. 停止 Stage8–9 多次使用大量隨機草線或規則拼貼小石子的方向。從原始 FS `grass_tile.png`、`path_tile.png`（**原始 Tileset，不是先前完成的 Ground**）重新編譯全新 544×416 Ground。
2. 高精細 Ground 來源試驗：原始地表材質座標扭曲減少週期重複，以 Voronoi 石材幾何重新繪出具有多種尺寸/色階/勾縫/邊緣的小石板道路；土路改成完整拼接鋪石而非少數零星石頭。來源端繪製帶葉/花的小植被群，最大來源群落 16×12px，以房屋為尺度限制。
3. A `GROUND_A_OPEN_MEADOW.png`：68個低矮花草群。B `GROUND_B_CLUSTERED_GARDEN.png`：114個低矮群。都沒有房屋、樹幹或立體障礙物。B 為本輪保留測試候選。
4. **PAR 完全保留** Stage7/8 獨立生成且透明的高細節候選，仍有兩棟房屋、大樹、木欄杆、路燈及花飾；SHA 未改。不反向分割已完成 Master。警告：此原生 544×416 PAR 是先前從1448×1086獨立透明原圖縮放/Alpha 修復的結果，**不是各物件的 native 1×來源**。

## 技術 QA：程式實際執行
| 項目 | Stage10 V2 測得 |
|---|---|
| GROUND.png | 544×416 RGB，SHA256 `87dcaf0f5adcc8e3989e68936af58bec0721c0f66caf9b5fda499f1fb8edd90d` |
| PAR.png | 544×416 RGBA，SHA256 `e5c33ddd1ca4ffb00eb89306c57fbd60f3ed2c5bf4e83992f2124a47d07ef3e9` |
| PAR Alpha0/255/1..254 | 112766 / 108885 / 4653（半透明細節仍需人眼查） |
| 4邊 Alpha>0 | 上0、下0、左0、右0 |
| 正式 RGB Ground+PAR 重合成與儲存 QA | RGB 0 像素差 |
| Stage5 strict source/canvas/alpha gate | exit0 `TECH_CANDIDATE_ONLY_ART_HOLD` |
| 隔離 source-only cold rebuild | Ground、PAR、兩個 Ground 候選、兩個 QA 和 manifest 等8項逐 SHA 完全相同 |
| 故意 PAR 寬度少1px | exit2，拒絕 |
| 故意 Alpha 邊界污染1px | exit2，拒絕 |
| 偽造 PAR 來源 SHA256 | exit2，拒絕 |
| Google Drive 雲端 ZIP | 4,479,886 bytes，18項，CRC PASS；SHA256 `71c66cba9153417cf02577e83d1cf453be982f06f9075502ac6a1d406de22cb2` |
| Windows authorized desktop cloud ZIP unpack + strict gate | exit0；Windows Ground、PAR SHA 與本地完全相同 |

以上核對均是**真 PNG 和可執行 Python**的結果。模型曾再次產生帶 PASS 字樣的「四格展示板」，並未當作任何來源或可驗收地圖。

## 美術與語義 Gate
- **Ground 美術 HOLD（未通過使用者正式參考驗收）**：比 Stage9 的單色土路更具有獨立石塊、勾縫與自然材質變化，但草地仍偏簡單，圖塊/花草細節仍不足以匹配神聖樹與兩棟高精緻房屋；未聲稱已達 ground3。
- **Ground 植被比例候選**：各群落不超過16×12px，Ground 沒有孤立樹幹。此為物件規格/視覺初審，不代表機器可通過語義繪圖。
- **PAR Richness 保留**，但其單張前景來源仍是多物件預合成，個別房屋/樹木/柵欄尚未都是完整獨立 source sprites；低矮花圃黏附房屋/樹根的污染疑慮仍 HOLD。
- **雙圖畫布與結果技術 PASS**，但舊 PAR 和新 Ground 只是宣告共享 544×416 最終畫布；不代表已能提供真實來源端的相同 Scene Blueprint。房門/樹腳精準接地仍是人工視覺 Gate。
- **樹幹底部規則 HOLD**：Ground 不留使用者先前指出的孤立樹幹，整棵樹仍在 PAR，但這與歷史最低32×32樹幹歸 Ground 的規則有差異。不可同時宣稱兩者均符合。
- **正式封版 NO**。未修改 FS K4、Map.rvdata、Scripts.rvdata、Collision 或使用者自行設定的通行度。

## 原始成果/接續
- [Drive Stage10 來源、兩張 Ground、真透明 PAR、QA、驗證與完整 ZIP](https://drive.google.com/drive/folders/1K2Uhq9PvVwsPnjsxeDezaXfYtIkMMad0)
- [Drive Stage10 FINAL Evidence ZIP](https://drive.google.com/file/d/1snWFqTrRGEw3vU_U-N9B5G_PR4HUeht-/view)
- [GitHub Stage10 Ground 來源生成器](../../tools/r17_direct_stage10/build_stage10_ground_v2.py)
- [GitHub Stage10 冷重建及 QA 原始碼](../../tools/r17_direct_stage10/validate_package_stage10.py)
- [前一輪 Stage9 報告](FS_R17_STAGE9_SOURCE_TILES_GROUND_ART_FAIL_20261029.md)

**下一步要走更高品質的單一美術源：** Ground 長短線紋理與草/道路明暗由同一個高精細原創材質來源控制，PAR 的房屋/樹/欄杆需要逐物件原始來源；不再以人工增加花點、石塊數量反覆提升 Gate 分數。所有階段必須人工 100% 尺寸與 544×416 全圖對照，無人眼簽核不得封版。
