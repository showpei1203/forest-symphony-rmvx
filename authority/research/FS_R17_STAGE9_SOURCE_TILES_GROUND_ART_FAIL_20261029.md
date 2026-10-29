# FS R17 Stage9｜原始 Tileset Ground 來源比較／比例修正（2026-10-29）

**正式狀態：TECH CANDIDATE / GROUND ART FAIL / PAR SOURCE ART HOLD / PAIR VISUAL FAIL / FORMAL SEAL NO。**

## 動機
Stage8 雖能從零編出完整 GROUND.png，但由大量隨機草線、程序石路製成，與使用者指定的 ground3/精靈村高精緻 PAR 相比過於簡陋；不可再用重複執行基本 Alpha Gate 冒充藝術進步。使用者指定「全新 GROUND，不得拿既有 GROUND 修補」，本輪嚴格遵守。

## 來源和方法
Windows `DESKTOP-90VT437` 執行了真正的兩版原生 Ground，比對原始 PNG 及合成 QA：
- Ground **沒有打開任何 Stage4–Stage8 的 Ground 圖檔**，從 `FS_ElfVillage_RichPilot_20261023/source/` 中的真正 32×32 `grass_tile.png`、`path_tile.png` 重新編排路面與草地。
- 在同一個原始 Tileset `legacy_tileD.png` 中，以 Alpha + 連通元件萃取小型綠植來源，嚴格限制最大16×13px，根據葉綠／陰影／棕色比例排除非植被；最初篩選混入黑色方框後修改條件，留存為錯誤案例。最後確保 Ground 沒有孤立的樹幹、樹冠、屋頂、欄杆。
- 兩版：A 原始草地來源拼接＋51小型植被群，B 分層素材紋理＋68小型植被群，皆包含約96塊不規則石板。路徑經藍房與赭房門前，一切在 544×416 的同一世界座標。
- PAR **完全沿用 Stage7 原生容器中的高細節透明層，沒有重新切割已完成的 Master**。它保留兩棟屋、神聖樹、木欄杆、吊燈、花飾。注意 PAR 是原本獨立生成、但一次組合多物件且經過最近鄰縮放的透明圖，仍不是逐物件原生可編輯套件。

## Windows 原機可重現實測

| 指標 | 結果 |
|---|---|
| GROUND_B 最終 SHA256 | `60574419ce812dbc7a009b8b5b4dcbe2c0c3419c1d260b5dfeaed02df276924c` |
| PAR 不變 SHA256 | `e5c33ddd1ca4ffb00eb89306c57fbd60f3ed2c5bf4e83992f2124a47d07ef3e9` |
| Ground／PAR 尺寸 | 544×416 同座標 |
| Ground/PAR 模式 | RGB / 真 RGBA |
| 正式圖合成 QA | 逐 RGB 像素差 0 |
| 官方 source validator | Exit 0，TECH_CANDIDATE_ONLY_NO_ART_PASS |
| Strict native/alpha gate | Exit 0，TECH_CANDIDATE_ONLY_ART_HOLD |
| 冷重建 | 從原始草地、道路、TileD atlas 和同一份 PAR，以V2程式隔離重新產出；Ground/PAR/QA及GroundB byte SHA相同 |
| 故意裁短 PAR 1px | Exit2，拒絕 |
| 故意污染 PAR 邊界 1px | Exit2，拒絕 |
| 偽造來源 manifest Ground SHA | Exit2，拒絕 |
| ZIP | 3,919,487 bytes、19 entries、CRC PASS；SHA `646066a3cb2f023583e338bd8f4f4a1c33d645d41c681e331ba6b6430b7408f2` |
| 本機 E: 與同步 G: | Ground、PAR、ZIP 三項 SHA 一致；雲端 ZIP 另讀回原始檔案 CRC PASS |

## 逐項人眼藝術稽核
1. `GROUND_ART = FAIL`：A/B 雖改善巨型花叢和黑方塊污染，但草皮重複、石路造型單純、植物呈均勻散點；與高細節 PAR 及 ground3 參考仍嚴重不協調。
2. `GROUND_VEG_SCALE = TECH CANDIDATE`：原生萃取植被上限16×13px，房屋約數百像素的畫面比例恢復合理；注意單次素材尺寸上限不代表人工語意完整分割。
3. `PAR_RICHNESS = VISUAL REFERENCE ONLY`：保留成功高豐富度風格，但個別物件未全部獨立為 1×來源 Sprite，建築周邊部分地面花草留在 PAR，語義仍 HOLD。
4. `TREE_CONTACT = HOLD`：Ground 無孤立樹幹，PAR 仍保留完整樹；未符合早期樹底32×32歸Ground規則，保留衝突並禁止宣稱完全通過。
5. `PAIR_VISUAL = FAIL`：材質細節不匹配，不通過美術／場景質感驗收。0像素 QA 只證明合成機器一致，**不是 ART PASS**。
6. `FORMAL_SEAL = NO`。完全不修改 FS/K4 正式 Map.rvdata、Scripts.rvdata、Collision 和使用者自定通行度。

## 交付及接續
- [Google Drive Stage9 原始研究檔與完整 ZIP](https://drive.google.com/drive/folders/1ypX94pDQh4CmDJ5pkAhuGQHziGVXIOl7)
- [真 Ground.png](https://drive.google.com/drive/folders/1ypX94pDQh4CmDJ5pkAhuGQHziGVXIOl7) 及 [PAR.png](https://drive.google.com/file/d/1KQ5f5TWd_9-iDaUG8OFZnrckWlLDu72O/view) 均已包含 ZIP
- [V2 原始生成器](../../tools/r17_direct_stage9/build_stage9_source_material_ground_v2.py)
- [冷重建及負向測試程式](../../tools/r17_direct_stage9/package_and_validate_stage9.py)

**下一輪不能繼續投入大量時間僅變更程序草紋、色塊或小石頭密度。** 真正待突破的是一組足以匹配高精細 PAR 的原創、可編輯 Ground 高品質材質原始資產，以及來源端可分物件處理的高品質 PAR 套件；這是美術來源問題，不是 Alpha 或 ZIP 問題。
