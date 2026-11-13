# FS 移植之後還能像 RMVX 一樣編劇情嗎？

**結論：可以設計成接近 RMVX 的工作方式，但 Godot 原生不會自動提供 RPG Maker 的完整事件編輯器。** 事件頁/觸發器/開關/變數/條件/指令列表需要建立 FS 專屬工具或整合穩定插件。

## 2026-11-14 本次施工
新增 `FSGameState.gd` 和 `FSVXEventInterpreter.gd` 作為 **source-first、fail-closed prototype**：
- 讀取來源 `RPG::EventCommand` 同格式的 `code/indent/parameters`。
- 實作 101/401 文本、102/402/403/404 選項與分支、111/411/412 條件（開關/變數/獨立開關）、121 開關、122 變數（常數/變數/亂數操作）、123 獨立開關、201 移動場所、230 等待幀、301/601..604 戰鬥分支與 108/408 註解。
- 不支援的 opcode（含 355/655 RGSS script eval）發出 `unsupported_command` 並停止進度，**絕不能猜效果或跳過造成劇情破壞**。
- `FSGameState` 儲存開關、變數、獨立開關、物品、隊伍、位置，可供 MENU/BATTLE 共用。提供 JSON-save compatible 物件序列化，但真正的存取檔存/讀檔 UI 尚待整合。
- **未進行 Godot 4.7.2 原生執行**，標記 CANDIDATE / NOT TESTED。事件儀表板、地圖、角色、動作、資產導入未接線，不能稱完整劇情可跑。

## 使用者將來寫事件的方式
理想工作流：
1. 在 FS Event Editor 選地圖及事件座標，選「按確認鍵、接觸、平行、啟動自動」及事件頁的條件。
2. 用選單插入「對話、表情、選項、開關、變數、移動、取得物品、播放音樂、戰鬥」指令，像 RMVX 一樣編輯。
3. 編輯器保存為可追蹤 JSON/`.tres`， Godot runtime 以指令執行器播放。
4. 舊有 `MapNNN.rvdata` / `CommonEvents.rvdata` 的事件應透過 Python Marshal 轉換器批次抽出原始指令，保留 map_id/event_id/page/condition/trigger/graphic/priority。純文字事件可直接重用；RGSS `eval` 內容須逐一轉為明確 API/安全 adapter。
5. 劇情回歸 QA：地圖開關/變數/獨立開關/隊伍/物品/劇情節點，逐項和原 VX 比對。

## 相容性矩陣
| 原始 VX 事件功能 | Godot 目標 | 目前證據 |
|---|---|---|
| 顯示訊息/對話 | 訊息事件 + 劇情 UI | 指令處理候選；UI 尚未接 |
| 事件選項/條件分歧 | 分支與等待回覆 | 指令處理候選；未 native test |
| 開關/變數/獨立開關 | FSGameState + 儲存 | 源碼候選；未 native test |
| 場所移動/觸發戰鬥 | 對外 signal，交主遊戲處理 | 有接口；實機未接 |
| 取得物品/隊伍變動 | 共享 state/Inventory Adapter | 尚未完成指令解碼與接線 |
| 事件頁條件/觸發器/移動路線 | FSMapEventManager + 編輯器 | 尚未開始 |
| 播放 BGM/SE/動畫/圖片 | Godot Scene/Audio Adapter | 尚未開始 |
| 公共事件/循環/標籤/並行處理 | 嵌套解譯器與調度器 | 尚未開始 |
| 特殊 RGSS 腳本 | 專屬 Godot API/轉譯規則 | **不自動 eval；暫時阻擋** |

## 工程優先序
**Phase 1**：先驗戰鬥、MENU/BATTLE，補 EventBridge「切入戰鬥→返回事件」的最小閉環。
**Phase 2**：完成 51 張地圖的指令表與原地圖/劇情導入。開發一個人用得順的 FS Event Editor；不要把「支援 JSON」誤當成「易於寫事件」。
**Phase 3**：創作新內容的編輯器效能、複雜劇情、動畫與多平台成品 QA。

## 兩個前置風險
1. 大量原版事件可能直接呼叫 Ruby Script。沒有完整使用頻率掃描與腳本 API 清單前，不宣稱「事件大部分可直接沿用」。
2. 使用者明確要求 Cloud-only。所有新程式、QA、Handoff 保存 GitHub；完整資料庫與私有圖像應保存私人 Google Drive。既有 `E:\...` 來源只讀，不覆寫。
