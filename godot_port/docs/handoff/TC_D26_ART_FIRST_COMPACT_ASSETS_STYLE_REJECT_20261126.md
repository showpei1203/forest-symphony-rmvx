# Forest Symphony｜T-C D26｜FS_04_MAZE「熔脈裂橋」｜比例達標但美術不達標

日期：2026-11-26（Asia/Taipei）｜隔離工作線：`feat/fs-tc-d12-chroma-par-20261122`｜**正式 ART PASS 0/12，D26 VISUAL SOURCE REJECT**

## 用戶要求與絕對遵守事項
Ground FIRST → Ground 凍結 SHA → 另外創作包含全部非地表的完整 PAR；只用 Composite 作 QA，不從含 Ground 的 Master 逆切，不拆角色遮擋、不改已封存 D17/D24；正式美術核准與 TECH/NATIVE 必須分開，圖資只上傳 owner-only Drive，GitHub 只保存程式/Handoff/尺寸元資料。

## 實際完成（不是概念規劃）

1. 原 Ground 真來源 `TC_D17_WORK/FINAL_PAIR/GROUND.png`，1280×928 RGB，SHA256 `2f9ad1d596171327fbc92f797495ea12d0e231c551da8eda3437035af2d6d94e`，逐 byte 保持不變。
2. D24 獨立非地表 RGBA 原圖 SHA256 `69fcdc6602394ddc7ece3e73515fe657ab74976c20aaa1548b58b712cfcca407`，本輪也沒有修改。
3. 新增四個**單獨作者化**、物件原生 1× RGBA 原圖：`FORGE 282×356`、`ORE_CRANE 236×288`、`IRON_BRIDGE 192×156`、`SUPPLY_WORKSHOP 225×209`，均**沒有把 D24 舊物件縮小重採樣**；其他七個沿用 D24 原作者獨立物件的完整 Alpha 連通區，全部以 1× 配置。
4. 產生新實驗 `1280×928` CompletePAR RGBA SHA256 `f8096afedba93dd66211cfd92385596ffda061c0d6cb6688fc762d83887805fe`，含真正 alpha=0 像素，原生 world canvas 四邊無高 alpha 截斷，物件彼此 overlap=0。與不變 Ground 合成 SHA256 `3b7cbd819e2983c2548eb98e386bc2e15593912e93f0c30b41c2e43e31b94920`。依據 source-locked `build_d26.py` 完全隔離冷重建，四張關鍵 PNG SHA 完全一致。
5. 創作時另測三個生成器候選，分別為**RGB 棋盤背景的大橋**及**兩張含 Ground 的混合 Master（其中一張含資訊樣式）**。三者均**REJECT**，沒有冒充獨立真透明 PAR。

## 精確 Gate 與專業 ART Reject

| Gate | D26 技術狀態 | 真實美術判讀 |
|---|---|---|
| D17 Ground SHA 鎖定 | PASS | 地貌未變，屬前輪已驗證基準 |
| 新短橋來源尺寸 <= 192px | PASS (192px) | 橋樑、柱頭具 32px 比例，但畫風偏平板 |
| 新鍛造工坊 <=288px 寬、<=360px 高 | PASS (282×356) | 相較 D24 原生成工坊的屋瓦與陰影細節不足 |
| 新來源 RGBA 真透明 | PASS（四個新 1× source） | 不是 AI 一次生成完整單張 PAR；不可錯誤宣稱 |
| 七個 D24 舊物件保留原生 1× | PASS | 與四個新手繪物件的**像素密度與陰影不一致** |
| 11物件完整 PAR 與靜態合成 | TECH PASS；零重疊、鎖尺寸 | **美術 ART REJECT**，不採納這個新 PAR 作正式候選 |
| 實際 Godot 4.7.2 D26 真圖 | NOT RUN | source art 不通過，按 SOP 不應繼續花時間引擎驗證 |
| 正式 12 圖 ART | **0/12** | 沒有人眼核准，禁止提高 |

這一輪最重要的新反例：**尺寸可以用程式精確控制，但不能靠較少的顏色、簡化的輪廓替代與 D24 風格一致的細緻美術。** 參考 D24 工坊與 D26 新工坊的 visible unique RGB 分別為 112457 與 57，橋樑為 42793 與 38；這只是風格細節的**輔助診斷，不是正式美術品質分數**。對完整 1× 合成圖的直接人眼檢視，確認新物件與原地貌、D24 七個保留物件風格不一致，因此 FAIL/HOLD。

## 累積經驗（D11 → D26）

- D17 一次生成自然連續 Ground 比 D16 羽化地表拼片好；Ground 一旦凍結，不應任意重畫。
- D18 完整 Alpha 物件保留優於 D17 多邊形強切；D23 的 RGB 棋盤背景不能冒充真 RGBA。
- D24 用真正獨立透明來源且 1× 放物件仍把 388px/495px 的橋及工坊畫得太大：**先對世界比例做原來源 Gate**。
- D25 用 160–192px 橋、<=288×360px 工坊和岸點預先量測，成功拒收不符比例舊圖。
- **D26 新教訓：比例 Gate 通過 ≠ Style DNA Gate 通過。** 不能用機械向量式作者法的少色階物件塞進高度細緻、帶陰影抗鋸齒的 A35/D24 風格。接下來的工法必須在**原生尺寸／源物件比例**約束下，直接以**同一作者/風格模型**生成整張非地表物件，或透過已有已驗證的 PixelLab/Map Workshop 原生素材方式，不能在低品質源圖上無限做微調。

## 下一個完整施工單位（D27）

先選擇**能原生作者化固定長寬與畫風一致**的方式，再用 D25 世界框產生一套尺寸正確、樣式一致的完整 **ALL-NON-GROUND PAR**。若生成引擎又交混合地表/棋盤/報告，直接 REJECT 并切換供應路線。保留本輪四個手繪素材作 QA 失敗實證，不把它們當美術基準。Ground D17、D22/D23/D24 原來源保持不動。ART 仍0/12，不混碰撞/演出/存讀。

## 隱私與驗收邊界

本地圖全部 PRIVATE PNG/比較圖/拒收生成源、QA、冷重建、完整來源 ZIP 應存 owner-only Drive；公開 GitHub 只能存 source-locked 作者程式、文字與 FAIL/HOLD 交接。D26 沒有實際完整 Godot 4.7.2 Native、沒有 User ART PASS、沒有改 PC Windows/其他分支。所有備份需先上傳並回讀確認後才算交付。
