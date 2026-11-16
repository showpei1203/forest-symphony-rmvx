# A25｜Pixel Plays 程式化像素繪圖研究：FS 可採用方法與驗證門檻

日期：2026-11-13
分類：**REFERENCE_ONLY / 技術吸收，非正式生產工具或新的權威規範**
唯一方法權威：`authority/FS_ASSET_FACTORY_ACTIVE_MASTER.md`
進度權威：`docs/asset_factory/CURRENT_HANDOFF.md`
目前狀態：**原始碼查核 PASS；FS 整合 NOT_RUN；新美術 0；Art/VX NOT_RUN；正式封版 NO**。

## 1. 查核來源、授權與界線

- 原始專案：https://github.com/amirmushichge/pixel-plays
- 原始 README：https://github.com/amirmushichge/pixel-plays/blob/main/README.md
- 主要引擎：https://github.com/amirmushichge/pixel-plays/blob/main/engine.js
- 作者網頁實驗：https://pixel-plays-ruby.vercel.app/
- 評論文章：https://www.aiposthub.com/pixel-plays-zero-image-pixel-games-numbers-rules-claude-check/
- 原始碼以 MIT 授權釋出；**音樂明確例外，不得視為 MIT 可重用**。如果將來複製原始程式碼，保留上游 LICENSE/著作權聲明並記錄採用的 commit SHA；**本次只記錄原理、沒有複製任何上游原始碼**。
- README 的 360×280 低解析畫布、nearest-neighbour 放大、30 度正交視角、深度緩衝、階調、Bayer 抖點及 8 fps 植物風動等是其自身視覺設計；**不是 FS 的美術規範**。其角色 `figure()` 是程序化圓球／膠囊繪製，不會憑空還原已核准 Actor01 F0 的 pixel art。
- AI 作者署名／模型貢獻比例不可由 commit footer 推斷為已證實。

## 2. 實際讀取 engine.js 的可借鏡模組

| 原始功能 | 對應 FS | 納入決策 |
| --- | --- | --- |
| `project()` 和 `zb` 每像素深度 | 有來源物件語意、幾何和可用角色腳點時，產生**遮擋候選**；不拿其 30 度投影覆蓋 FS 既有 top-down 3/4 座標 | **REFERENCE / 建議 PoC** |
| `shadeEdges()` 依深度差處理邊界 | 將遮擋邊緣的前後關係輸出成供人審查的診斷層；正式 Ground/PAR **不得自動加入色暈或模糊** | **DIAGNOSTIC ONLY** |
| `figure()`、`capsule()` 的可參數化姿勢 | Actor01 既有 F0 / A62 Run Rig 的關節及姿勢合理性測試；最終輸出仍須繼承 F0 原外觀 | **REFERENCE / 非動畫生成器** |
| `rampOf()`、`BAYER`、`hash()` | 候選圖片的有限色盤、抗模糊、可重現性 QA；既有核准母圖**不可被任意重調色** | **QA CANDIDATE** |
| `growTree()`、`drawLeaves()`、8 fps steps | 假如日後需要 Ground10 式動態環境，研究按整數像素更新的植被循環，不改動既有靜態分層或原有循環腳本 | **LOW PRIORITY** |

**核心判斷**：Pixel Plays 的深度資訊來自「已知幾何／物件」，不是對一張扁平 PNG 自動理解樹冠、屋簷。FS M-A 的 Master-first 原圖無 3D 資料時，必須先有 source alpha、語意 mask、輪廓／物件 ID、遮擋前後關係或人工標註；**不可直接依同色 RGB 猜 PAR**。

## 3. Map PoC：A21 同源像素基線之上加「語意＋深度提示」

**不另起製圖主線；先沿用** `tools/asset_factory/a21_runtime_occlusion.py` 及其 tests，避免再做一個互不相容的遮擋引擎。

### 3.1 輸入（來源可追溯）
1. 真正 FS Master PNG，檔案路徑／尺寸／SHA，`ART_MASTER_APPROVED` 與否獨立列出。
2. 每物件 `object_id`、足點／碰撞輪廓、可以遮擋角色的同源像素 mask、前後深度／高度語意，以及標註來源（Source/人工/AI 候選）。
3. 三到四個合法角色站位及角色投影盒／腳點；前方、後方、側方對照；實際 32×32 world grid。
4. FS 原生 Switch203、碰撞及合法走路網的驗收條件。

### 3.2 必須保持的不變量
- `Runtime_FullGround` 和 Master **同座標、完整保留**；Runtime PAR 只複製 Master 指定 XY 的 RGBA，禁止 RGB 顏色類推。
- 只有當角色應在物件**後方**，才針對該角色姿勢啟用對應前景遮擋。前側合法腳點須不被整棵樹／屋簷錯誤遮住。
- Ground 不是 GroundOnly：地表低草、小花、橋面、一般道路不因物件邊界而被抬進人物前景。
- `Authoring_GroundOnly`、`Authoring_CompletePAR` 保留四圖契約，且不把 Authoring PAR 全部當 Runtime PAR。
- 地形高差仍依 FS 實際腳點、上沿 1–2 格可遮擋需求及現行原生腳本查核，不直接挪用 Pixel Plays 的 z-buffer 判斷。

### 3.3 失敗優先的測試
- **正例**：角色進入大樹／屋簷後方，應被正確部位遮擋；站在其前面、接近房門前方，不被過度遮擋。
- **負例**：故意把草、橋面、道路、相同 RGB 的不相干背景列入遮罩，QA 必須擋下。
- **保真**：Runtime Ground SHA／對齊／重組像素與 master 一致；Mask alpha 必須只出現在所指定、來源真實的物件像素，嚴禁殘留草地底色。
- **語意**：合法 footpoint、角色相對深度、分區碰撞與路網完整，且 1x 檢查。零 RGB mismatch 只代表同源像素正確，**不代表 occlusion PASS**。
- **原生實機**：必須在 VX Game.exe／Switch203 觀察前後走位；Godot 和 Pillow screenshot 不算 Game.exe PASS。

若同類錯誤重現兩次，停下改**物件語意模板／來源遮罩**，不是再拿畫筆修十張圖片。

## 4. Sprite PoC：姿勢參數化，而不是把程序化小人當 FS 資產

- 來源：已確認 SHA 的白髮 Actor01 F0、A62 核准 Run、既有合法 Rig；不可丟失 45°、身體比例、裝備與 1x 像素。
- 建立每個關節的 pose/side/occlusion 表；至少檢查左右腳**交替領先**、髖膝踝關係、重心、頭身一致、雙手及武器不跳動、循環接點。
- FS Actor SBS：`_1/_2/_3` 三關鍵影格，Run loop 可為 `0,1,0,2`；靜態技術 PASS 不能取代 F0 身份及自然步態藝術驗收。
- PMD：根據每個物種真實 `AnimData.xml`、`Anim/Offsets/Shadow` 建立不同方向與 frame-count；**不可把「3 pose」等同 PMD 原生各動作只有 3 幀**。
- 將 Pixel Plays 的姿勢函式視作動作診斷參考；**不把它生成的膠囊人直接作為新 Actor 或怪物**。不要因為「算得出姿勢」就宣稱新的 RUN PNG 已生產。

## 5. 實驗順位與交付定義

優先度 P1｜在 **A21 真實 Master** 的單棵樹與屋簷上，針對四站位建立手工可核對的 depth/semantic mask 提示，重用既有 A21 converter；比較「只有 alpha」與「alpha + geometry + legal footpoint」的過度遮擋率、錯遮擋數、人工修正數，輸出相同 SHA Master 的 PAR/Pillow 預覽及一份 failure log。**若 AI 推斷不可靠，保留人工物件語意，不能重畫母圖**。

優先度 P2｜以 **A62 Run** 的原始 F0 及骨架，輸出一份可重跑的左右腳交替／關節界限診斷；PixelLab/ASF 仍須另有真實生成影格並通過藝術與原生格式門檻，才算 Sprite 動作進展。

優先度 P3｜待 P1、P2 已有真實輸入與 QA 後，再考慮色盤／抖點與動態樹葉研究。不得影響已核准 ground3/森林風格，也不得先加 30 度等角畫風。

### Status Gates（本次研究吸收時）
| Gate | 狀態 |
| --- | --- |
| Read upstream README + engine.js | **PASS**（2026-11-13） |
| License constraints documented | **PASS** |
| GitHub reference and handoff record | **PASS when committed and read back** |
| P1 FS A21 depth/semantic runtime PoC | **NOT_RUN** |
| P2 F0 / A62 joint diagnostic | **NOT_RUN** |
| New compliant Actor/PMD art generated | **NO** |
| Real VX Game.exe / User 1x ART acceptance | **NOT_RUN** |
| PixelLab paid calls | **0** |
| Authority / main / sealed artwork touched | **NO** |
| FORMAL SEAL | **NO** |

## 6. 交接（新對話從這裡接續）

1. **先讀** `authority/FS_ASSET_FACTORY_ACTIVE_MASTER.md`、P0，再讀 `docs/asset_factory/CURRENT_HANDOFF.md` 的**最新頂部**；本文件只是新加入的實驗技術附錄。
2. 資料以 A21 真實 Master、A18 F0、A62、A23 ASF 實際 QA 為準；不可憑本筆研究宣稱有新 art 或 Native VX。
3. 下一輪如執行 P1：先定位 A21 私有原始檔及確切 SHA，建最小可重現數據；測試四腳點，記錄 fail/pass；owner-only Drive 保存原圖、PNG 和實機證據；公開 PR 只放合規程式、非私有合成測試與去識別紀錄。
4. 原有 PR #15 保持 Draft；未完成 CI／ART／Game.exe／Drive readback 前不合併 main。
5. 每輪更新本研究的實驗附錄或新的 Axx 證據，以及頂部 `CURRENT_HANDOFF`；同時同步 Drive，記錄 commit SHA、失敗及下一步。不要求使用者在 PC 保存新資產。

**決策一句話：借用深度、姿勢、可重現性這三種「數學」，不借它的 30° 畫風，也絕不讓零像素差異冒充語意正確。**
