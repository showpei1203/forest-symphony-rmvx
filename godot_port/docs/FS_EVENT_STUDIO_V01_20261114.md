# FS Event Studio v0.1｜Godot 原生 RPG 劇情事件編輯器

**2026-11-14；階段 CANDIDATE（native headless smoke PASS，真人 GUI 體驗 / 原始劇情 parity 尚未驗收）**

## 使用者決策（最新版）
- 原本 RMVX 的 51 張地圖與舊劇情事件 **不必追求全量搬移**。
- 必須保留舊事件命令語意與相容性入口，原始 E: 來源只讀。
- 在 Godot 原生專案內 **優先打造易操作的新事件編輯器**；事件創作不該要求逐事件撰寫 GDScript。
- Godot P1 原始戰鬥／MENU／BATTLE 數值與 UI 移植依然是獨立必交範圍，不能因新事件編輯器而視為完成。

## 開啟與操作
1. 在 Godot **4.7.2 stable** 中開啟雲端開發分支下的 `godot_port/project.godot`（當前 GitHub source 是候選分支，未 merge main）。
2. 編輯器底部會出現 **FS Events**（`addons/fs_event_studio/plugin.cfg` 已在 `project.godot` 啟用）。面板中點「開啟事件」，選 `res://story/events/map_999_event_001.json` 即可查看示範寶箱。
3. 左側編輯事件名稱、Map/Event ID、X/Y、事件頁、觸發方式、優先級、頁面條件：開關 1/2、變數最低值、獨立開關 A/B/C/D。
4. 右側選指令類別「新增指令」，選取列表後在下方修改文字／數值／選項；支援插入、移動、刪除。新增 if／choice／battle 會自動建立必要的封閉結構。復原／重做最多保留 100 個變更快照。
5. 「檢查所有頁」會針對結構不合法的分支、選項或未知指令阻擋儲存；「儲存 JSON」會寫入**當前 Godot 專案的** `res://story/events/map_NNN_event_NNN.json`。已存在但未開啟的事件 ID 不覆寫。
6. **雲端唯一持久保存規則**：這個原生「儲存 JSON」按鈕在使用者電腦開啟時會產生本地專案檔，尚不符合 cloud-only 長期政策。**在未另行確認授權的 PC 本機工作流程之前，不可用它留下本機成果。** 面板提供「複製 JSON」（不新增本地檔）；可把序列化文字交給已連接的 GitHub 工作流程直接提交雲端。雲端 Actions 測試中的本地儲存只在雲端臨時工作區，不會寫到使用者 PC。未來應補 GitHub 原生雲端儲存／遠端圖形介面，避免複製貼上。
7. 地圖場景可加入 `res://scenes/story/FSStoryEventMarker.tscn`。在 Marker Inspector 選 `event_file` 並設定 Godot 2D 位置，從玩家互動腳本呼叫 `marker.interact(state, story_runtime)`；目前標記不是自行啟動的完整 NPC／碰撞觸發系統。

## 開放的視覺編輯指令
- 對話（多行、臉圖名稱、位置、背景）、註解
- 選項 1–4 項、各選項分支、可取消分支
- 開關、獨立開關、變數設定/加減乘除/餘數、常數/變數/亂數來源
- 條件分歧（開關、變數比較）、否則、結束
- 獲得／失去物品、金錢、角色入隊/離隊
- 等待（VX 幀）、地圖傳送、開始戰鬥與勝利/逃跑/失敗分支

## 兩層格式，確保舊事件不必搬移
1. **新製作事件**：人類可讀 `fs-story-event-v1` JSON，存 Map/Event ID，位置，依最後有效頁優先順序選頁，含步驟 `steps[].op`。由 `FSStoryCompiler.gd` 編譯成原生 VX 相容 `code/indent/parameters`。
2. **既有 VX 事件**：可把原始命令陣列送到 `FSStoryRuntime.interact_legacy_vx()` / `FSVXEventInterpreter.start_event()`；沒有強制把它們變成新事件頁格式的必要。
3. **共用運作**：`FSGameState` 的 switches、variables、self-switches、inventory、party、gold、map state；`FSVXBattleBridge` 接 battle 301、battle 601/602/603。

## Native QA 證據
- Godot 4.7.2 headless 專案匯入／插件初始化、原 VX 指令合成測試。
- 事件文件 Schema/頁面條件/JSON roundtrip/編譯 → runtime → choices/rewards/legacy 指令 PASS。
- 面板真實 Control instantiation：自動新增 IF/END、插入對話、TextEdit 實際修改模型、Undo/Redo、Save/Open PASS。
- 拖入地圖的 Marker 行為與兩頁示範寶箱：首次領取物品、設獨立開關 A、第二次只顯示空箱，沒有二次領取 PASS。
- GitHub Action：https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43529305543
- **未驗收**：手動開啟 Godot 真實桌面編輯器截圖／鍵盤操作體驗、遊戲內人物移動與按鍵對話框、NPC 動畫、經過事件/自動事件/平行事件排程、所有 VX opcodes / 355 Ruby。不要宣稱整款遊戲可玩。

## 需要遵守的邊界
- 新事件文字來源現在可在 PUBLIC GitHub；未經審核的原遊戲私有內容、授權素材、玩家存檔不能上傳 PUBLIC repo。
- 編譯器遇未知 op／未封閉 block 不生成不完整指令；執行器未知 VX opcode 直接中止，絕不忽略。
- 舊 RPG Maker VX 地圖、505 段 RGSS2 腳本不必全量轉寫；但任何未支援的事件指令要報告相容性缺口，不能假裝已相容。
- Engine 固定 4.7.2 stable；沒有完成真實素材導入時戰鬥/UI 仍是 prototype。
