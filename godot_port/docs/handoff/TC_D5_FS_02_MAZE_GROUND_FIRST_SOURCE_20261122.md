# Forest Symphony｜T-C D5｜FS_02_MAZE 冰脊迷谷 Ground-first｜2026-11-22

**結果：真正生成與冰脊迷谷相符的獨立 Ground 原始美術，1× 裁切出 46×33 格候選並上傳私人 Google Drive。正式目標 80×58 尚未達成；完整 PAR NOT_GENERATED，Godot 4.7.2 Native NOT_RUN，正式 ART HOLD。**

## 正確世界設定與本輪產圖

- 正式 scene ID `FS_02_MAZE`，名稱冰脊迷谷，地形凜霜雪原，設計目標 **80×58 tiles @32px = 2560×1856**。不能把其他地圖或雪村合成圖當作迷宮。
- 延續使用者正式工廠規則：**先獨立 Ground（道路、雪、冰面、冰裂、凍湖、自然地形），後獨立透明 CompletePAR（完整冷杉、直立岩壁/冰柱、橋、裝飾等全部非地表物件）。不因是否遮角色而剔除 PAR 內容。**
- 本輪終於生成一張正確形態的 Ground：蜿蜒連續雪路、上下左右分支、可見多個回路與碎裂凍湖。畫面**未見村屋、路燈、冷杉、商店與中央晶泉**，因此不像之前兩次誤畫的雪村 Master。
- 新 AI Ground 圖 **1473×1068，RGB**，原始 SHA256 `140dfdc865a7ed299e5bbc8ec8045b2c865ff16ccdc1b7125aa9f0ef6d27071c`。
- 為了取得精確 32px 整數格，從原圖以 **(0,6,1472,1062)** 精確原像素裁切 **1472×1056 = 46×33 tiles**，不插值、無變形、無縮放；候選 SHA256 `3b5dd011b38213ff5d6f2fe82c2d2d5dcae26204f0f64d2a98ebc05772188b4c`。輸出獨立 PNG 與 Grid QA 預覽，格線沒有寫入原 Ground。
- 重要：圖片有雪堆凸緣、凍湖與地貌陰影，尚待美術評估某些直立冰緣是否應作 PAR（可重生來源或在完整兩階段生成時改 Blueprint），不能將美觀目視直接當 Ground 純度/可走性 100% PASS。

## Failure Log 與 QA

| 項目 | 真實結果 |
|---|---|
| 新生成 Ground 影像存在、RGB 且獨立 | PASS |
| 1× 裁切尺寸、原始 SHA | PASS |
| 純雪路/冰裂/凍湖、沒有雪村建物 | 目視 PASS |
| 46×33 格候選 | PASS，僅尺寸對齊 |
| 正式 80×58 原生地圖 | **NOT_MET**，不可將低解析圖非等比放大冒充 |
| 真正獨立 CompletePAR | **NOT_GENERATED** |
| 產圖階段 PAR 嘗試 | **兩次失敗**：生成器輸出帶虛假 QA PASS、Google Drive 敘述的資訊圖，完全不是真透明 RGBA 遊戲素材，已拒收 |
| Ground＋PAR 正式合成 QA | NOT_RUN |
| 迷宮通行與角色遮蔽 | NOT_TESTED，不做產圖前置必要 |
| Godot 4.7.2 原生 GPU | NOT_RUN |
| Human ART Gate | HOLD |

## Google Drive WRITE → READBACK 實際驗證

- [完整 D5 Ground 原始來源／Grid／QA ZIP](https://drive.google.com/file/d/1hLXgbMYBG0lawzZwTOb_Iv4i8Ju3GtsS/view)，**9,050,368 bytes**、**5 檔**、ZIP CRC PASS、SHA256 `ff87c0a1443de3cae930886a8351ec301b8529376bd57a81fd9592a6198b7199`。
- [原始完整 Ground 1473×1068](https://drive.google.com/file/d/1_pjneuKesT8_5EELIn2nX9xuFW4YsTia/view)，**3,194,864 bytes**，原始 SHA 如上。
- [不縮放 46×33 Ground 候選](https://drive.google.com/file/d/17mUgD3av2eNfUJPYX01gOUfGzazfK1sT/view)，**2,930,387 bytes**，SHA 如上。

三個 Drive 檔案 readback metadata **shared=false，僅使用者 owner**。真正圖片不提交公開 GitHub、未操作使用者 PC。CI/Linear 不能把這張圖誤算入 0／12 正式 Art-Sealed。

## 下一個完整施工單位

優先解決兩件事，不倒退到修每棵樹／判斷角色遮蔽：

1. **FS_02_MAZE 正式 80×58 / 2560×1856**：需要真正可在該尺寸輸出雪谷地貌 Ground-only 的生成流程。46×33 的 D5 原始圖可作風格構圖參考，但不可直接 nearest 放大稱為真正 80×58。
2. **真 PAR**：要對同一張已凍結、尺寸符合的 Ground 與 Blueprint 生成完整透明非地表 PAR，包含完整冷杉、直立岩壁、冰柱、巨石、棧橋、雪原標誌、岩晶等全部物件；圖像生成器若只給資訊圖，直接 reject，不要改名為 PAR。

正式六地形十二圖 SOP：[Google Drive 可編輯文件](https://docs.google.com/document/d/1zWXO6Z8SHobSK2jfI-M6-p6JDb81BniIH_4UCLiJhIw/edit)。此檔案是 2026-11-22 最新 D5 QA；T-C Current Handoff 優先。
