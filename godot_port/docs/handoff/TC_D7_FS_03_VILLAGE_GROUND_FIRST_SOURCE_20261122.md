# Forest Symphony｜T-C D7｜FS_03_VILLAGE 星井綠洲 Ground-first 實作與失敗紀錄

**日期**：2026-11-22（Asia/Taipei）｜**專屬分支**：feat/fs-pixellab-tc-map-20261121｜**正式狀態**：新獨立沙漠 Ground 美術候選已產出並私人封存；立體砂岩崖壁混入 Ground，CompletePAR 兩次失敗，正式 ART HOLD，Godot 4.7.2 native NOT_RUN。

## 已核對的原始世界規格

2026-11-14 [六地形 × 迷宮／村莊正式世界規劃](https://docs.google.com/document/d/1SjVPK3J5exwp0fC3bRMHjoWo2vne_pck/edit)：

- 03 地形正式名稱：**風蝕金砂**。
- 村莊正式 ID：**FS_03_VILLAGE**；名字：**星井綠洲**。
- 同系迷宮：FS_03_MAZE「風沙裂谷」，本輪未施工。
- Ground-only：沙丘、砂岩地面、乾涸河道、礫地。
- **完整獨立 PAR：所有非地表物件**，岩柱、完整棕櫚、砂岩民居、布棚、木／石欄杆、路燈／水井立體部件、商販裝飾。無論是否遮角色，**全部都必須在 PAR**。
- 使用者明訂「先 Ground，再 PAR」：不能從完成 Master 反向切 PAR，也不能只抽樹冠／屋頂當完整 PAR。角色遮擋不是本輪 Ground/PAR 產生前置條件。

## D7 真正新生成地圖及逐像素來源 QA

- **新 Ground-first AI 獨立圖片真正生成**：原始 1477×1065，RGB；包含風沙波紋、砂岩路、中心石板廣場、湖水與乾涸河道，沒有村屋或棕櫚。
- 只以原始像素裁切 `(98,68,1378,996)`，得到 **1280×928，40×29 tiles @32px**，不插值、不拉伸、不拼接或重製 Master。
- 原始 PNG SHA256 **`8f8c0ac66359bf8bc47e00beb889a4e66c5f2c9d339b00f9cf05957818556f91`**；1280×928 Ground 候選 SHA256 **`ac3688112874cd45a38f484b8c37dbc0b8f6abd41b67cc0c578bc95f0935aa97`**；另製作不寫入來源檔的 32px 格線 QA 圖。
- 實際使用 D7 像素資料的暖色地形粗略識別：**warm 0.949892、cool 0.039116**，地形身份的驗證 PASS；僅代表不是錯誤的雪原圖，**不是 Ground-layer 或 Art PASS**。
- **真正藝術阻斷**：大面積立體砂岩斷崖立面（以及部分凸起灌木）仍在 Ground 圖內，與「除了平面地表之外全部放 PAR」規則衝突。這張可作同地形風格參考，不能正式封版成純 Ground。

## PAR 兩次錯誤輸出均拒收

- 兩次嘗試使用新沙漠 Ground 生成同座標完整透明 PAR，圖像工具都錯畫成 FS_02_MAZE **冰雪迷宮**，沒有任何可用沙漠物件。
- 第一份不相關輸出 1473×1068 RGBA，alpha extrema (51,250)，alpha=0 **0 pixels**；第二份 1470×1070 RGBA，alpha extrema (1,251)，alpha=0 **0 pixels**。兩份都是混合場景而非真正透明的全部非地表物件 PNG。**拒收，沒有把它們上傳為 PAR，也沒有從中反切物件**。
- 若輸出工具持續忽略沙漠與透明背景要求，下一階段需要換成真的可以指定固定原生尺寸、同 Blueprint/reference、透明 Alpha 與可編輯完整來源的生成器；目前外部圖像服務尚未確認已連接，不能虛構 PixelLab / fal API job 或扣款。
- **沒有合格 PAR，因此不能合成 Ground+PAR、不能做 Godot native 或宣稱玩家 ART PASS。**

## 私人 Google Drive，已 WRITE → READBACK

- [D7 原始圖片／Ground 候選／32px Grid／QA JSON／Failure Log ZIP](https://drive.google.com/file/d/1tFCb_V0VaxWFgKrewGIs3sIEcZ-DN7yi/view)：**8,009,029 bytes，五檔 ZIP CRC PASS，SHA256 `c491c51279ee558371893df95a5b8a32a346ed35092bb371a0d7297b1e6603b6`**。
- [原始 1477×1065 AI Ground](https://drive.google.com/file/d/1OQmMo0pBq7WE0RwcsRkALqDDaLXrThjA/view)：3,209,978 bytes。
- [1280×928 Ground 候選](https://drive.google.com/file/d/1dYmk2I49wp0gCCWxAh5k0JiStzwNtCM4/view)：2,436,200 bytes。
- 三份 Google Drive provider metadata 已讀回 **shared=false、owner-only**；沒有在使用者 PC 存任何圖，也沒有將私人 PNG 提交到公開 GitHub。

## 確實新增的產線驗證

- `godot_port/tc_factory/biomes/fs_biome_identity_guard.py`：粗辨雪原／風蝕金砂色盤，抓到「要求沙漠卻輸出冰雪」的模型錯誤，不會把任何純色值當 Art PASS。
- `test_fs_biome_identity_guard.py`：4 項 Ground 身份及交叉拒收單元測試。
- [.github/workflows/fs-tc-biome-identity-guard.yml](../../../../.github/workflows/fs-tc-biome-identity-guard.yml)：**[GitHub Actions run 44987584378](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44987584378)** 真正 completed/success、4/4 synthetic pass；在本輪本機真像素上亦對比 D7 沙漠 Ground warm 95% / D6 雪原 Ground warm 0%。
- 這只是「不同地形不要認錯」的自動 guard，**不是規格一致、地表純度、PAR 完整或 Godot PASS**。

## 下一個完整施工單位與正式 Gate

**FS_03_VILLAGE 星井綠洲**：直接以本輪沙漠風格參考，重新輸出一整張**真的純地表 Ground**，不含高聳砂岩壁、棕櫚、完整灌木和建築；Ground 同尺寸鎖定後，再以相同世界 Blueprint 輸出**全部非地表物件的真透明 PAR**，自然融入砂丘、路網、綠洲。然後才執行真正 1280×928 pixel alpha composite QA、Godot 4.7.2 native 與人工 Art Gate。

其他五組與原 12 scene IDs、森林/雪原既有素材及所有 ART HOLD 狀態不變，不涉及 VX 或事件/NPC/戰鬥。正式地圖藝術封版 **0／12**。
