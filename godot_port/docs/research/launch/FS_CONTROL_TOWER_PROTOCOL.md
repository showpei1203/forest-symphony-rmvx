# Forest Symphony｜總監控台（Control Tower）協議 v1.0
**建立日期：2026-11-21｜權威：使用者當前指令、FS 最新 Cloud-only、Godot 優先、GitHub/Drive/Linear 可核驗成果。**

## 角色與讀取規則
本 ChatGPT 對話只充當**協調／查核／驗收／阻擋衝突／整合排程**的總監控台；T-C/T-A/T-B 三個對話分別執行實際施工。**沒有背景持續監控能力**，只有使用者在總監控台下達「總控同步」或相似指令時，才從雲端來源查詢真實最新狀態。不同對話間的文字不能自動同步，只有寫入 GitHub/Drive/Linear 的紀錄可互相核對。

所有線共用：
- 專案 `showpei1203/forest-symphony-rmvx`。
- 路線圖：`godot_port/docs/research/FS_PIXELLAB_THREE_EXPERIMENTS_ROADMAP_20261121.md`。
- 本協議：`godot_port/docs/research/launch/FS_CONTROL_TOWER_PROTOCOL.md`。
- 中央狀態：`godot_port/docs/research/launch/FS_CONTROL_TOWER_STATUS.md`，只有總監控台更新，工作線不要修改。
- Linear：T-C `SHO-39`、T-A `SHO-38`、T-B `SHO-37`。
- 分支：T-C `feat/fs-pixellab-tc-map-20261121`、T-A `feat/fs-pixellab-ta-actor-20261121`、T-B `feat/fs-pixellab-tb-monster-20261121`。
- 每條分支固定 Handoff：T-C `godot_port/docs/handoff/PIXELLAB_TC_CURRENT_HANDOFF.md`；T-A `godot_port/docs/handoff/PIXELLAB_TA_CURRENT_HANDOFF.md`；T-B `godot_port/docs/handoff/PIXELLAB_TB_CURRENT_HANDOFF.md`。

## 指令與真實執行

### 「總控同步」
1. 讀此協議、中央狀態、最新 Roadmap、Linear 三任務。
2. 讀三個專屬分支最新 Handoff／提交，按 Handoff 連結回讀實際 Drive 存檔、QA 圖片與 Godot Native 證據；**不可只靠 Linear 文字宣稱**。
3. 逐項比較上一回中央狀態，產生 **Delta**：實際增加的完整地圖／動作／怪物鏈、何者只新增文件、何者沒有變化。
4. 判定：`NOT_RUN`（只有規格）／`ACTIVE`（有真實新產出）／`BLOCKED`（重要依賴不足）／`ART_HOLD`（工程可跑但美術未過）／`AWAIT_USER_ART`／`VERIFIED_PASS`（原生及美術證據俱全）；未驗證的傳聞不可升級狀態。
5. 檢查 conflict：是否碰其他分支、覆蓋 A35 或已核准 source、改用 VX、寫到使用者 PC、意外改觸碰 NAV/傳送、從單純文字誇稱完工。若發生，先阻止合併，提出修復指令。
6. 提出每條線**下一個完整成果單位**、主要阻礙、是否符合宏觀進度，必要時更新中央狀態並交代 GitHub commit／Drive ID／Linear 更新。
7. 不在沒有可核驗原始證據下宣布 PASS。**總監控台不替代使用者最終美術驗收**。

### 「總控驗收 T-C」／「總控驗收 T-A」／「總控驗收 T-B」
只深入該分支的 Handoff/圖片/Native QA，做 3 道獨立判定：技術與來源、Godot 原生、視覺美術。若美術只能由用戶最終認可，標 `AWAIT_USER_ART` 並交出最有代表性的核對畫面，不猜測通過。

### 「總控重排」
按目前可用的雲端成果、阻礙與使用者指定優先順序提出下一輪的 1 個主要目標與 1–2 個平行目標，更新 Roadmap／Linear 之前保留來源/已通過版本，不能無理由翻盤。

### 「總控交接」
製作下一個對話可接續的總控 Handoff，包含路線圖、三個分支頭 SHA／Linear／Drive 真實 evidence、待處理衝突、當前指令，保存在 GitHub／Drive 並讀回驗證。禁止創建使用者 PC 專案副本。

## 每條施工線 Handoff 必備欄位
```
TARGET: T-C / T-A / T-B
STAGE: M1(完整候選) / M2(Godot整合) / M3(阻斷缺陷修正) / M4(第二案例)
STATUS: NOT_RUN / ACTIVE / BLOCKED / ART_HOLD / AWAIT_USER_ART / VERIFIED_PASS
BASELINE: 已批准來源連結、commit、SHA、art authority
DELTA: 這次真正新增、能觀察的完整成果（不是「研究了」）
ARTIFACTS: GitHub commit/branch；Drive item URLs/ids；圖像尺寸／frame數／層數
PIXELLAB: model／prompt、job id、實際費用（未用標 NOT_RUN）
QA: source / Godot native / art 各自 PASS、HOLD、FAIL、NOT_RUN，連結證據
FAILURE_LOG: 類型、阻斷與否、修了幾輪、若超過 2 輪的改路線理由
NEXT_MACRO_UNIT: 下一個完整畫面／完整動作／完整進化鏈成果
P0_STORAGE: 雲端 WRITE→READBACK 與 PC 暫存狀態
```

## 防止細節困住團隊
- **全線硬規則**：先 `M1 完整候選`→`M2 Godot native`→`M3 只修阻斷性錯誤`→`M4 第二樣本`。不是每張圖修到完美才下一張。
- 非阻斷微調最多連續 2 輪；留一筆 Failure Log 後繼續有意義的下一大成果。不會因為局部小瑕疵停止宏觀進度。
- 重要阻斷：視角錯、身份漂移、跑步不換腳、房屋拼接、影像裁切、Master/PAR 不同源、遮蔽反轉、權利/來源不明。不以配額或進度為由接受，修兩輪無效就**換路線**，不能同法無限重試。
- 預設工作重心：實際生成與整合 70%、QA 20%、Handoff 10%。這是防拖延原則，不是免 QA 的藉口。
- 避免重工：跨線共用工具、校色器、格式驗證可提 PR 給總監控台決定合併；兩線不得同時寫同一個文件／場景。需要共用規則先由總監控台落地。

## 透明限制
三個獨立聊天視窗不會自動互相看見尚未雲端保存的內容。本聊天不會在使用者離開後自行持續執行或監測。只有總控同步時主動讀 GitHub/Drive/Linear，或另行經明確安排的排程機制，才能看到更新。

## 固定比較基準與查核誠信（2026-11-21 同步補充）
- 三個實驗分支的共同**固定起點**是 GitHub commit `4a2a50e3aacb3115dbb3418b6e229b8a34c430d0`。未來計算「新增 commits／檔案變動」必須用此 SHA 與各分支比較，而不是持續更新的總控 research 分支，否則會產生虛假的 behind 數字。
- 每次「總控同步」讀取三個分支**當下 HEAD commit SHA**與 CURRENT_HANDOFF，並保存 SHA／新增檔案／Drive 真實 metadata／Linear 讀取時間。
- Drive metadata READBACK 只確認 ID、大小、權限與存在，不等於直接重新校驗私人 ZIP bytes／PNG 色彩或人工 ART Gate；施工線提供的 SHA/CRC 是聲明證據，需要另做獨立 byte QA 才可稱總控獨立證實。
- 有 GitHub Actions native PASS 只證明該 run 的指定 revision、測試輸入和 renderer 在該環境成功。Mesa llvmpipe 是軟體 OpenGL，不得說成使用者 RX 6700 XT 本地 GPU。
- 若任何 Handoff 承認 Windows %TEMP% 或其他 PC 暫存，應記錄是否使用用戶本人 PC／事前授權／清理與驗證。未核實前標 `P0_TEMP_CLEANUP_UNVERIFIED`，不直接臆測清除或違規。
