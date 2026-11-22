# Forest Symphony｜Cherry Studio 本地技術知識庫 Handoff

日期：2026-11-22（台灣）
狀態：**LOCAL_RAG_RECALL_QA_PASS / CHAT_MODEL_NOT_CONFIGURED / FS_ENGINE_NOT_TOUCHED**

## 1. 目的與安全邊界
- Windows 10 x64 桌面端 Cherry Studio **2.2.3** 已安裝及開啟。
- User 明確指定 **不使用 Codex，不消耗 Codex 額度**；ChatGPT 原生對話仍為主控台。
- 未設定 OpenAI API、Gemini API 或其他新付費 API；Gemini 訂閱帳號未拿來冒充 API。
- Cherry Studio 僅做本地規範檢索和未來可選的輔助工作台；所有正式來源仍在 GitHub/私人 Google Drive。
- 未讀取、同步或外傳保險客戶個資、私人圖像、保單資料。
- GitHub main、T-A、T-B、T-C 原有工作分支、Godot 工程與 ART HOLD 狀態皆未更動。本 Handoff 使用獨立工作分支：`feat/fs-cherry-studio-kb-20261122`。

## 2. 已實際完成的設定
- Cherry Studio 知識庫：`FS_技術規範`，唯一保留正式實例（SQLite KB id `73cf2eb7-c52f-4e5f-87fb-9fd00b321825`）。
- Embedding: **本機 Qwen3 Embedding 0.6B**（內建 Local Models，無 API Key），在建立正式知識庫時即指定。
- Rerank: none；聊天模型尚未串接；不把檢索 PASS 當生成答案 PASS。
- 5/5 來源狀態 completed、5 content / 5 material / 33 search units / 33 search texts / **33 local embedding vectors**（SQLite read-only 核查）。
- 失敗測試用的早期 BM25→Embedding 中途變更副本已移除；僅保留上述正式實例。
- Cherry Studio 內部 raw 5 個文件與匯入臨時檔 SHA256 **5/5 相同**，已刪除匯入臨時資料夾。正式原檔仍保留 GitHub，Cherry 內副本只是可重建索引。

## 3. 已匯入的 GitHub 正式規範快照
本批都是 2026-11-22 讀取的原檔快照，**不是 GitHub 的自動同步**。版本衝突永遠以最新權威與使用者更新指令為準。

1. `01_FS_TA_PAPER_DOLL_SOURCE_CONTRACT.md`
   - `feat/fs-pixellab-ta-actor-20261121:godot_port/docs/authority/FS_TA_PAPER_DOLL_SOURCE_CONTRACT_20261122.md`
   - raw SHA256: `a531bf17f3a77c8dee1283c7f55b32344e246839fc3761e153d6eb2b57a2935d`
2. `02_FS_TA_R20_SOURCE_LOCK.md`
   - `feat/fs-pixellab-ta-actor-20261121:godot_port/docs/authority/FS_TA_R20_A62_SOURCE_LOCK_PAPER_DOLL_AUDIT_20261122.md`
   - raw SHA256: `52f4b053f8b64e2bb41ea257e707afa1a691b0ddacfac3ce21946d993ecd56b4`
3. `03_FS_TC_MAP_GROUND_PAR_RULES.md`
   - `feat/fs-pixellab-tc-map-20261121:godot_port/docs/research/launch/T_C_MAP_LAUNCH_PROMPT.md`
   - raw SHA256: `a13f8c272faea42ea93c673fc18d9e0736bfb4f58fd90e12da0813a21464e4ce`
4. `04_FS_TB_MONSTER_PRODUCTION.md`
   - `feat/fs-pixellab-tb-monster-20261121:godot_port/docs/research/launch/T_B_MONSTER_LAUNCH_PROMPT.md`
   - raw SHA256: `5bdfe1d8344861d3498551cb637353647a904d7409717df367bdd0b1ff4b1ae5`
5. `05_FS_CONTROL_TOWER_PROTOCOL.md`
   - `feat/fs-pixellab-tc-map-20261121:godot_port/docs/research/launch/FS_CONTROL_TOWER_PROTOCOL.md`
   - raw SHA256: `236f0755f22f2796cdf1444a685298bcb5aef2524627d6cedc5fe004b506ba68`

## 4. 本機檢索 QA（實際執行）
- 問題「Ground 與 PAR 圖層分工，是否要判斷角色遮擋？」→ Top 1：`T_C_MAP_GROUND_PAR_RULES`，回收 Ground first / all non-ground PAR / 無須遮擋判斷的規範，**PASS**。
- 問題「紙娃娃角色缺少原始衣裝來源時，能否用多邊形重畫腹部？」→ Top 1：`TA_PAPER_DOLL_SOURCE_CONTRACT` 的禁止補畫／同源模組規則，**PASS**。
- 問題「PMD0001 熔岩蛙的三階進化與動畫驗收要求？」→ Top 1：`TB_MONSTER_PRODUCTION`，含三階進化與 Idle/Attack 驗收，**PASS**。
- 另以 `Tankentai` 檢索：前幾項為 A62、紙娃娃來源、原 FS 武器分層，**PASS**。
- 執行時間約 0.4–2.6 秒（依首次本機推論載入與查詢不同）。
- 注意：首次自動化點擊曾在查詢結果尚未更新時看到上一次快照；已改成等待實際查詢完成及 Top 1 改變後才判定 PASS。勿將這個 UI 延遲誤判為新問題的搜尋結果。

## 5. Failure Log／已排除問題
- 最初 BM25 實驗與中途切換 embedding 的原知識庫，導致自動化 QA 中新舊結果混淆；為確保單純可重現，直接建立新庫時指定本地 embedding。舊測試庫已刪除。
- 自動化在輸入後太快點檢索，畫面會留上一題結果；需要等待進入「檢索中」並看到查詢對應的內容變更。重新按檢索並等待後可正常取得匹配結果。
- 實測 Cherry Studio 2.2.3「設定 → 模型供應商」以完整字串 `CherryAI` 搜尋顯示**沒有結果**。官方文件的免費 CherryAI/Qwen3-8B 服務在此桌面版目前無法直接選用；**免費聊天模型未啟用**，也未登入 CherryIN 或申請其他 API。

## 6. 下一工作單位
1. 保持 ChatGPT 原生對話執行 FS 施工；Cherry 僅做來源文件召回，不直接代表 GitHub 最新版。
2. 如果要在 Cherry 聊天回答知識庫內容，先確認可用聊天模型的免費條件、服務提供者、傳輸資料及限額，再經過同樣三題的**回答+引用**測試。
3. 後續將 GitHub 最新權威檔逐一更新 Cherry 快照，依 source SHA 比對，不自動覆蓋其他分支；所有更新要重新跑 T-A/T-B/T-C 三題。
4. 不把 Gemini 付費訂閱、ChatGPT Plus 或 Codex 的額度直接視為 Cherry Studio 可用 API 量。
5. 權威文件、測試 Handoff 只能以 GitHub/私人 Drive 為正式留存；Cherry 本機資料是應用快取，並非專案唯一備份。

## 7. 檔案與實際進度聲明
本輪沒有執行 Godot、沒有生成角色/怪物/地圖素材、沒有做 T-A/T-B/T-C 原生 ART QA，也沒有改寫既有 FS 程式。成果限於 **Cherry Studio 安裝、5份規範匯入、33向量本地索引及實際檢索 QA**。
