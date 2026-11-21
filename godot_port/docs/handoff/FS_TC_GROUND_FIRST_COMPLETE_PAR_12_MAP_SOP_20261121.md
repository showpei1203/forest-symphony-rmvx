# Forest Symphony｜六地形×村莊／迷宮 Ground-first → CompletePAR 量產 SOP v1.0

**日期：2026-11-21｜工作線 T-C｜引擎 Godot 4.7.2｜狀態：已施工測試的 Ground/PAR SOP，並非十二圖美術封版。**

## 0. 世界設定來源、範圍與最高優先規則

正式世界設定：2026-11-14 Drive `FS_SIX_BIOMES_WORLD_ART_PLAN_20261114.md`；2026-11-16 `FS_12_MAP_ACTIVE_MASTER_20261116.md`。官方名稱、順序、場景 ID 以這兩份文件為準。森林既有正式工程 / A35 / R12 / 其他工作分支不得覆蓋。

**使用者最後確認的最重要規則：先生成完整 GROUND，後生成完整 PAR；PAR = 除 Ground 地表外的一切物件。** 不做角色遮擋判斷、不把角色遮罩當 CompletePAR、不將完整 Master 再反切為 Ground/PAR。擋不擋角色是未來 Runtime 另行決定的功能，不是本美術工廠產出兩張圖的標準。

## 1. 經 D2 實作確認的完整流程

1. **查定一張地圖的 Scene Blueprint**：使用正式 scene ID、預期世界網格（每格 32px）、該地形的色彩／光向／材質、迷宮或村莊類型、道路、物件預留與建築足點。不要自行改動官方地形/場景名稱。
2. **GROUND-FIRST**：以同一份 Blueprint／Style Lock 一次創作**完整地表**。Ground 必須不透明、具自然細節，包含該地形的草地、雪地、沙土、玄武岩地面、泥炭/水面或晶石地面、平面道路、貼地花草、碎石與陰影色變。**不能出現房屋、樹、完整灌木、石柱、石橋扶手、路燈、圍欄與所有非地表物件**。本層通過來源/尺寸審核後鎖定原始檔 SHA。
3. **COMPLETE PAR SECOND**：以**剛完成的同一張 Ground 與 Blueprint**作世界座標、視角、色盤、光向參考，另外生成**真透明 RGBA PAR**，所有非地表物件都在 PAR；包含房屋、樹幹/樹冠/根部、橋、圍籬、岩石、灌木、路牌、櫃檯、階梯／建築立體部件、燈、道具等，無論是否擋人物。要求同一原生像素座標；不得用 alpha 矩形橫切成「會擋人的部分」。
4. **只為 QA 合成**：以 `Image.alpha_composite(GROUND, CompletePAR)` 製作 Preview，**Preview 不是 Ground 或 PAR 的替代品**。觀察整體畫面、樹木林帶、建築落地、道路銜接、風格一致。原檔不動。
5. **輸出與 Gate**：`GROUND.png`、`PAR_ALL_NON_GROUND.png` 為最重要兩個檔。附 `COMPOSITE_QA.png`、PNG mode、dimensions、full alpha histogram、source SHA、exact crop/resize metadata、source model/seed（若實際可得），以及 Human Art Gate 判定。可供後續 Godot 4.7.2 以兩個 Sprite2D 原位載入；正式 Native PASS 必須真正跑 Godot 渲染，不要借用其他圖的 CI 綠燈。
6. **Storage**：圖片、ZIP、私有來源、截圖存 user-only Google Drive；GitHub 僅代碼/文檔/清單；每項寫入後 readback metadata/SHA/權限。絕不在使用者 PC 存地圖。每輪 Failure Log + Handoff + Linear SHO-39。

## 2. 這次成功與失敗的數據（2026-11-21，D2）

- 原生圖像生成 Ground 與 PAR v1/v2 各自獨立；原始畫布 **1473×1068**，不是 Godot 32px 整數網格。
- 主候選 `46×33 = 1472×1056`，對兩張圖使用**完全相同** `(0,0,1472,1056)` 原生 1:1 裁切，無插值與重採樣；Pillow 合成/同世界原點 TECH PASS、畫面整體統一風格的宏觀可用性改善，USER ART GATE 未完成。
- **不能把 1280×928 裁切候選冒稱正式合格**：中央裁切 `(96,70,1376,998)` 截斷大量 PAR 邊界物件、正式 40×29 ART HOLD。往後必須**先鎖定欲生尺寸的 Blueprint，再生 Ground 與 PAR**，不能生完才任意裁掉完整物件。
- **原始 Alpha 問題**：PAR v1 實際有 147,430 個 `alpha=1..8` 色彩殘留像素，715,548 個 `alpha=240..254` 近不透明像素。清理測試僅將 alpha≤8 歸 0、alpha≥240 歸 255，**保留原始 PAR 與真 Alpha 稽核結果，不冒稱原圖本來乾淨**。新圖以透明乾淨為優先，不要靠清理規則改掉完整物件。
- Ground SHA256 `226a0733dc92cd0023ddcd4a86afff9d8a469cc658b0a5e884c5667bcce36af1`；原 PAR SHA256 `0a52c590e85086b29af37754bdbc9206d2aab96ec9d98e0c82f5d4d4dbd2f574`；清理 PAR SHA256 `80b6aee06908c3e8160881af28a3faa9cf0d3d09c85bac3f0b538de45e9e406c`；Composite SHA256 `09137573db960dead52bc599e859a7f5134b65366f13e371df39a1cd3f91e7a8`。
- D2 **Godot 4.7.2 native NOT RUN**，Art HOLD；**勿把 D1 歷史來源 192/192 類別/Engine PASS 借給新生成 D2**。
- 既有私人 Drive D2 [Ground](https://drive.google.com/file/d/1zop1sxdXiTfee_rpiSQCJXu5Uotikt4y/view)、[raw CompletePAR](https://drive.google.com/file/d/17lUUXnCCNk4pQGWUGiRciSJW9qAVGbrl/view)、[cleaned PAR candidate](https://drive.google.com/file/d/1nywEe4sG-KTtWFTpPC7VCoQjD_ANa6Lv/view)、[composite](https://drive.google.com/file/d/1cASgC0jbjiXbFOf_HSJPTanjgBHUfUrU/view)。四圖各自 provider readback shared=false owner-only。

## 3. 六系十二張既定目標，不新增地形代稱

| 地形 | 迷宮正式 ID / 名稱 | 聚落正式 ID / 名稱 | Ground 材質 | CompletePAR 全物件語言 |
|---|---|---|---|---|
| 蒼翠精靈林 | FS_01_MAZE 幽葉迴廊 | FS_01_VILLAGE 苔光村 | 苔毯、自然土徑、蕨類、卵石 | 巨橡、白樺、木石屋、路燈、木橋 |
| 凜霜雪原 | FS_02_MAZE 冰脊迷谷 | FS_02_VILLAGE 霜燈聚落 | 積雪、凍土、碎冰、冷色岩面 | 冷杉、冰柱、覆雪屋舍、暖爐煙囪 |
| 風蝕金砂 | FS_03_MAZE 風沙裂谷 | FS_03_VILLAGE 星井綠洲 | 沙丘、砂岩、乾涸河道、礫地 | 岩柱、棕櫚、砂岩民居、布棚 |
| 赤焰火山 | FS_04_MAZE 熔脈裂橋 | FS_04_VILLAGE 灰鑄工坊城 | 玄武岩、火山灰、熔岩岸、礦渣 | 熔爐、斷崖岩柱、鐵橋、工坊屋 |
| 幽霧水澤 | FS_05_MAZE 泥潭迷水 | FS_05_VILLAGE 蘆燈水上村 | 泥炭、淺水、木棧、浮萍 | 紅樹根、蘆葦、木船埠、高腳屋 |
| 星晶浮島 | FS_06_MAZE 星盤斷空 | FS_06_VILLAGE 虹晶臺地村 | 碎晶、白石、星紋、浮空草坪 | 晶簇、觀測塔、石橋、晶石圓頂屋 |

每一系使用相同的色盤/日光方向/建築設計語言，但村莊有可辨識的聚落街道和建築群；迷宮以地形路線、分岔、迴路和危險/高差為主。獨立 SHADOW/LIGHT/WATER 可後續開發，不取代兩張必須交付的圖。

## 4. 當輪實際施工優先序及狀態

- **01 森林**：FS_01_VILLAGE 有 D2 新 Ground/PAR 完整視覺候選，**46×33** 不等於正式既有 40×29 地圖；藝術/原生 Hold。FS_01_MAZE 有早期 80×58 技術來源但藝術仍 Hold。兩者皆不得稱封版。
- **02 雪原**：從 FS_02_VILLAGE 霜燈聚落 **先生成全圖 Ground**，鎖源後才生成 FS_02_VILLAGE 全物件 PAR。然後同色盤生成 FS_02_MAZE 冰脊迷谷 Ground→PAR。嚴禁把精靈村僅改成白色就冒充新雪原。
- **03～06**：照 12-map World Bible 順序：風蝕金砂→赤焰火山→幽霧水澤→星晶浮島。每組兩張，絕對保持不同地貌與建築家族。各個候選的 QA 必須實測，如沒有生成圖片就明列 NOT_STARTED。
- 事件/NPC/對話/劇情/戰鬥移交其他工作線；美術工程不進行它們的開發。
- 既有 A35、R12、正式 main 完全不碰，專屬分支 `feat/fs-pixellab-tc-map-20261121`。

## 5. Failure Log／避免再次偏離

- **禁止**再次研究「哪些樹冠會遮人物」才決定 PAR，因為那是後續遊戲遮擋功能，不是 authoring layer。
- **禁止**重新生成 12 張同底圖換色、複製樹木均勻排列、或以幾片 32px tile 填滿地圖假稱美術合格。
- 不將原生畫面未實測者標 Godot PASS；不將原始 PNG 透明雜色的後製視為 AI 原生 Alpha PASS；使用者未人工簽核者始終 ART HOLD。
- 每次完成**整張地圖**候選或一個 Ground/PAR 重要階段，才記實際里程碑，不以樹葉小修灌水。

## 6. 下次對話接手（固定 Handoff）

1. 讀此 SOP、Drive 的 FS_SIX_BIOMES_WORLD_ART_PLAN_20261114.md 和 FS_12_MAP_ACTIVE_MASTER_20261116.md、最新 PIXELLAB_TC_CURRENT_HANDOFF。
2. 只接受真正完整的 Ground、CompletePAR 原始 PNG，追蹤原始大小/SHAs/透明度與畫布對齊，不接受流程 infographic 當 source。
3. 在 12-map 狀態表勾選確實已產生／已測量的地圖，不能從規劃跳成已完工。
4. 新成果全都 Owner-only Drive + GitHub code/manifest/Handoff，Linear SHO-39 更新實際進度。