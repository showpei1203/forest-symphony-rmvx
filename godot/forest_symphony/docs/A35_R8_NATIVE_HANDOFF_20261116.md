# Forest Symphony | A35 R8 · Pixel-derived Canopy Shadows | Native Godot Handoff

**交接日期：2026-11-16（台灣）**  
**狀態：ENGINE PASS · NAV PASS · GPU SHADOW PASS · PRIVATE DRIVE VERIFIED · ART HOLD**

## 一、施工方向與原始基準

- Engine: **Godot 4.7.2** (AMD RX 6700 XT, OpenGL 3.3 Compatibility)。此工作線負責森林地圖分層與 HD-2D 光影；**不使用 RPG Maker VX**，不更動戰鬥系統，**不覆蓋平行 A36C**。
- 正式輸入：A35 R7 可重建的原始私人 ZIP，SHA256 `9e32a559fc40b90c38a573c227106f9f33c6c48a5165ccd55ca96af7f55fb3eb`。R7 原始完整樹幹遮光系統 175 個 occluders、187 PAR、導航 8/8、4 條路線 4/4 維持。
- 原始 Ground SHA256 `3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000`。
- 原始 R7 場景 SHA256 `45553197527883088bde69d11b8210d5d6fc94f6632378be36353c9378b05e14`，字節不變。R2–R6 舊場景保留不動。
- 新候選場景：`res://scenes/a35_r8_canopy_shadow_scene.tscn`，不取代原來的 R7 場景。

## 二、這次實際完成的工程

1. `tools/a35_r8_canopy_extract.py`：從私人 R7 完整封包中讀取真正的樹木 PNG，依據原始透明度與葉片像素建立樹冠幾何。讀取 **175 棵樹，實際 29 種不同來源素材**。每張素材以葉片／Alpha 的逐列 4%–96% 範圍建立 Y 單調輪廓，約限制在樹冠上方 76% 的範圍，避免把樹幹與整個圖檔矩形當樹冠；總計 **5,378 個輪廓頂點**。這是源自真正素材的*近似多邊形輪廓*，不是逐像素完全精準描邊。
2. `scripts/a35_r8_canopy_shadow.gd`：保留 R7 175 個樹幹 `LightOccluder2D`，另外在原本樹的 Node2D 下掛上 **175 個樹冠 `LightOccluder2D` / `OccluderPolygon2D`**。29 種輪廓 Resource 依路徑共用快取，控制網格、原素材 SHA、樹木 Anchor、CollisionShape2D 都不變。PCF5 柔化；鍵盤 **P** 獨立開／關樹冠遮光，**O** 維持 R7 所有樹影總開／關。
3. `tools/a35_r8_build.py`：從封存的 R7 ZIP 加入新的 R8 場景、輪廓 JSON、Godot 原生 QA / GPU 測試程式與來源報告，不覆蓋舊檔案。
4. `tools/a35_r8_pixel_qa.py`：比較真正 Godot GPU 同視角、同測試燈、同夜間設定，只有樹冠陰影開／關的 2 張原生 PNG。
5. `tests/a35_r8_native_frame_bench.gd`：6 組、每組 50 幀、交替 ON/OFF 的引擎 wall-frame 抽樣；非獨立 GPU 量測。

## 三、Godot 真實原生驗證

- Cold editor import **PASS / Exit 0**。
- Source QA: **175 個 R7 樹幹 + 175 個 R8 樹冠遮光節點**；29 種輪廓；187 PAR 均維持座標、原始 `source_file` / `source_sha256` 與碰撞；樹影獨立切換 **PASS / Exit 0**。
- Real Godot physics: NAV **8/8**、四條主要路徑 **4/4**、protected road 新阻擋 **0**，**PASS / Exit 0**。
- OpenGL 3.3 原生 1280×928 GPU 截圖（樹幹陰影皆開啟；樹冠陰影 OFF/ON）**2/2 PASS / Exit 0**。
- 原生 GPU A/B：**122,342 個變動像素**，全部位在座標 (260, 785) 半徑 263px 測試燈範圍內；範圍外 **0 像素**，平均 RGB 絕對差 1.046159，最大通道差 132。這證明樹冠的真正 2D 遮光有參與 GPU 渲染。
- 6 × 50 幀 Godot wall-frame 測量：canopy OFF 平均 **16.688ms**、ON 平均 **16.681ms**。這是引擎排程與渲染總 wall-clock 幀時間，非 isolated GPU time，不足以保證所有地圖 60FPS 或低階硬體效能；僅此單次執行未見明顯差異。

## 四、實際原生圖與私人封包

- **[A35 R8 完整可執行 Godot 專案來源 ZIP](https://drive.google.com/file/d/1xcUgm5bqAfKr8-MB45ijOfP8WoW4qAO2/view)**，**354 個檔案、176,237,979 bytes、ZIP CRC PASS、SHA256 `e47e8cba8d746a034fcd5620680554a20bfd96c2d146d8c062874f59f22507fc`**。Drive 已重新讀取並確認私人權限 `shared=false`。
- **[真實 Godot 樹冠陰影 OFF 截圖](https://drive.google.com/file/d/1zR8c0JcYXRUH6_Iq3YVIg-2BaCzfY1On/view)**；**[真實 Godot 樹冠陰影 ON 截圖](https://drive.google.com/file/d/1qUvUGhuMl3Sii6OD0EyLR9tDgMInzUFw/view)**。
- **[兩張原生截圖衍生的對照圖（非原始 GPU 幀）](https://drive.google.com/file/d/15yhRdJPTPrSVkXO8nhAq-QQgTt7eaoMF/view)**。
- **[Pixel GPU QA JSON](https://drive.google.com/file/d/1DV7MM77p8oVP6Rdgc-UtdtsjjjIapOao/view)**、**[Godot Wall-frame 效能 JSON](https://drive.google.com/file/d/1C3xxZh5Hm6PUnze1cKr-gPFz4kset9BJ/view)**。
- 私人工作區：[A35 R8 Drive](https://drive.google.com/drive/folders/1eYK4rx6-D2FboIe7gFhWmbdPZRgnOnya)。
- 公開 GitHub **僅原始碼與文件**。完整 PNG、ZIP、原始遊戲素材全部維持私人 Google Drive，不傳到公開儲存庫。

## 五、驗收限制與後續工程

**ENGINE PASS · NAV PASS · GPU REAL SHADOW PASS · ART HOLD**。

現有 R8 遮光輪廓依樹木原始透明度產生，已超越 R7 簡化樹幹六邊形的測試，但仍是近似的 2D 樹冠輪廓，夜間測試燈周圍會形成比較深的大片陰影。**真實 3D 景深、體積光、樹葉透光、散射光、完整森林多光源與完整 HD-2D 美術均尚未完成**。R6 三種針葉樹邊緣仍有尖刺狀細節；目前不可標記 `ART PASS`。

下一階段 A35 R8 R2：
- 以目前 1:1 原生截圖人工驗收樹冠過度陰暗區與葉片投影是否自然，調整光照能量與 mask 百分位，不直接覆蓋 R8。
- 在分離候選版進一步測試多光源、性能，以及更自然的半透明樹葉陰影，再決定能否整合到正式村莊。
- 持續修正三種針葉樹像素品質；美術達標後再進入 **Ground3** 草地、花卉與自然道路邊界，仍保留原始 Ground SHA。
- 每次必須保留可重建來源、真實 Godot QA、錯誤紀錄、Google Drive 私人封包與 `CURRENT_HANDOFF`。

詳細失敗紀錄：[A35 R8 Failure Log](A35_R8_FAILURE_LOG_20261116.md)。
