# Forest Symphony｜Godot 4.7.2｜2026-11-16 真正可操作流程正式 Handoff

## Migrate P1 Phase532–533: 地圖→VX事件→ACT戰鬥→劇情分支→跨圖→可讀進度

### 0. 施工範圍與不能倒退的結論
- Project: `showpei1203/forest-symphony-rmvx`; **只改** `feature/fs-godot-phase1`、`godot_port`，不覆蓋 main／地圖或動畫合作分支。
- 延續正式上游 `godot_port/docs/HANDOFF_20261116_IVY145_FURNACE_STATE.md`（上一輪 Ivy145/State85+100、142/814 OD減傷、146蓄痛400、147復仇、天氣／Boss 與 QA 全部保留）。
- 使用者真正目標：**FS 正式轉 Godot 4.7.2 的可玩成品**，非永無止境的分離單元測試。原始 RPG Maker VX `E:\遊戲專案開發\三大項目現行專案\FS project` 全程**唯讀**。所有新工程在 GitHub，私有原圖與原版資料只可放 owner-only Drive，不存使用者電腦常駐檔案。
- 舊事件不必逐條全部搬移，但須保留 VX `code/indent/parameters` 相容入口，未知 Ruby code355/655 fail closed；人物動畫不得被 VX 三幀限制。
- 本輪使用**明確合成 source-shaped** Actor/Enemy/Troop 與 32×32 格地圖。**不是**使用者正式 A35 R8 R3 地圖、完整 505 RGSS2 aliases、原版戰鬥數值或 private post-Apply 11 DB。這輪通過代表**可操作垂直切片的流程**通了，不代表完整 FS 移植：**PHASE1 SEAL=NO**。

### 1. 發現的真實跨系統缺口
原有 `FSStorySandbox` 已可走路／寶箱／對話；`FSVXEventInterpreter` 已支援 VX301／601/602/603／201 等來源相容事件；`FSVXBattleBridge` 與 `FSScreen` 可啟動真 `FSBattle` 的 Tankentai ATB/ACT；`FSGameState` 可保存開關／物品／座標，但**沒有整合玩家可從一張地圖走入戰鬥、回到地圖、轉另一張地圖、持續劇情與讀取狀態的流程**。
另外，原 `FSVXBattleBridge` 每場 `FSBattle.add_actor` 重新給滿 HP/MP，且未檢查 add_actor 返回值，因此跨場生命魔力與真正 VX `Game_Actor` 的持續值不相容。此次全部接線並加入數據安全測試。

### 2. 本輪具體已提交程式
1. **新增 `scripts/story/FSPlayableSliceData.gd`**：兩張合成 17×13 地圖，Map999 `測試森林`、Map1000 `測試遺跡`，原始 VX 相容事件：
   - Map999 Event1 寶箱，VX101/401→126 item1+1→123 selfswitch A；二次調查不重複領。
   - Map999 Event2 木靈，VX101/301 troop1、601勝利分支→121 Switch10 ON／125金幣+50；603失敗分支 Switch11；已勝利時免重複戰。
   - Map999 Event3→Map1000 Event1：VX201 傳送雙向，各自檢查地圖／座標／阻擋，回傳至 Interpreter 才 ACK。
   - Map1000 Event2：驗證 VX Switch10 之後 VX102 選項、402 分支、Switch20／selfswitch B／item1+1；支援拒絕選項與重入不重複獎勵。
   - Synthetic DB Record Scope: Actor1、Class1、Enemy1、Troop1，不會設置 `db.boot_final_verified`；Enemy1 的 `actions=[{kind:0,basic:0,rating:5,condition_type:0}]` 讓**既有** #211 EnemyAI roulette、#231 ATB/ACT 真正出手，而不是靜態木偶。
2. **新增 `scripts/story/FSPlayableSlice.gd`** + `scenes/story/FSPlayableSlice.tscn`：實際 Godot Tile 走路／碰撞、方向 E/Enter 互動、同一 `FSGameState`、`FSStoryRuntime`／`FSDialoguePanel`／`FSVXBattleBridge`／`FSBattle`／`FSScreen` 實際連線。事件301暫停劇情、開源有 BATTLE UI（ATB READY→選敵→ACT→傷害）、勝利返回601/603、退出戰鬥畫面後續事件 Message、跨圖換位置；invalid transfer拒絕。不在事件或戰鬥中移動／暫存讀檔。
3. **修改 `scripts/FSScreen.gd`**：當真正原版 DB 尚未通過 `FSDatabase.load_all` 私有簽章 Gate 時，在 Boot 提供明顯**合成資料可玩流程**入口，正式原資料一旦可用，MENU也有此入口。保留原有 MENU/BATTLE 和舊 Event Studio 沙盒。開啟的合成戰鬥在 UI 顯示來源限定，不冒充正式 FS 美術／數值；可正常回主選單。
4. **新增 `scripts/story/FSCheckpointCodec.gd`**：ver1 schema+SHA256 的 JSON 快照，輸出 `payload_json` **精確 UTF-8 字串**與摘要、驗證SHA後解析、檢查地圖／座標／party／變數／背包／角色生命值。暫存只在`FSPlayableSlice.checkpoint_json`**記憶體**存在，沒有寫使用者的E:或本機 user://永久檔。未接私人 Drive 雲端永久存檔。SHA256 是意外毀損偵測，不是密鑰簽章或防作弊安全來源。
5. **修改 `scripts/FSGameState.gd`**：新的 `actor_vitals` 只存真正 VX `Game_Actor` 的 HP/MP；加入 `set_actor_vitals/get_actor_vitals`、`as_save_dict`／`restore_save_dict`。不把戰鬥暫時 ATB/OD/護衛或未驗證 State 假裝可持久化。
6. **修改 `scripts/FSVXBattleBridge.gd`**：建立 battle 前，對每個 actor 檢查 add_actor，恢復上場存檔的合法 HP/MP（按目前原始 actor max 值 clamp）；實際 victory/可負敗／已驗證成功逃跑時把 actor vitals 提交回共享世界。來源缺失 fail closed，不再靜默略過未知 Actor。
7. **新增 `tests/test_fs_playable_slice_532.gd`**：native Godot 真連接 UI、實際走路／寶箱／任務／換地圖／對話選項、真源 ATB READY/ACT、真人 UI 請求選敵、真敵木靈 HP48→0、VX601 +50、第二地圖領取草藥、轉存 JSON SHA、竄改拒絕、版本拒絕，第二次 VX301 從上場實際 HP100 繼續，再驗證源 Enemy.actions 真 AI ATB/ACT 造成 HP100→80、戰後 HP80 持續。
8. **新增 `tests/capture_fs_playable_slice_qa.gd`**：Xvfb/OpenGL 真 1088×832 兩張 native GPU screenshot：`fs-godot-p1-playable-slice-battle-native-qa` 正開原生 FSScreen 戰鬥指令選敵；`fs-godot-p1-playable-slice-map-native-qa` 代表完成第二地圖 NPC、VX601勝利 +50、草藥×2、自動任務完成／當場暫存。繁中 system CJK fallback 驗證，不能把合成貼圖冒充原版美術。
9. **Workflow** `.github/workflows/fs-godot-phase1.yml`：以上新 P532 native 腳本+P533 native OpenGL 雙截圖納入所有先前 Boss、Weather、事件、145/146、動畫和 505 source audit 的完整 CI；不得只提供文字猜想。

### 3. 本輪 Failure Log（不能掩蓋）
- `43782394589` **FAIL** 於新 P532 最後記憶體 JSON 復原。其它 preceding steps/FS 既有流程先完成。根因 Godot `JSON.parse_string` 數字 roundtrip 改變原 JSON 的 int/float 編碼，原 `JSON.stringify(parsed_payload).sha256_text()` 不等於寫出快照時 hash，造成合法暫存被錯判篡改。
- `43782521765` instrumentation 確認回覆 `檢查點內容不一致或遭到修改`，世界仍保持未更改（正確原子復原）。
- 修正 `FSCheckpointCodec` 將 Hash 計算在原始內層 `payload_json` 的精確 bytes，避免 re-encode；新增修改實際 inner Gold 字串但留舊 SHA 會失敗，重算 SHA 但無效版本亦失敗，合法存檔可 roundtrip，不寫本機。
- `43782680463` **SUCCESS**：修復後完整 532 MAP→ACT→QUEST→checkpoint 真引擎 Native 回歸 ALL PASS；後來增加 actor HP persistence 和敵人行動後還需以最新 HEAD CI 再驗證。
- `43783230381` **SUCCESS**：支援跨場 HP/MP 後完成原生 532、雙 OpenGL 真 1088×832 截圖、所有舊完整回歸；map GPU PNG SHA256 `e620d276f957dc732061c55504dfb4f11291ede2c4eaeeae64a8be6022d83530`、battle GPU PNG SHA256 `9ca3e959c62ab68e848bb49ecf6dc033e0d0be714d43e4135028bfc904bbd3f3`，兩張 PNG 已實際下載和目視檢查。後新增合法 Enemy AI 設定，**需查最終 CI**。
- 所有 source-shaped 合成案例仍不滿足完整 FS runtime 11 post-Apply / 505 alias 原始資料，正式遊戲的美術/角色模型非此測試素材。

### 4. 跨工作線真地圖（已核對，避免重做）
獨立地圖 GitHub branch `feat/fs-a35-r3-hd2d-20261115`、`godot/forest_symphony` 現已不只是 A35 R2。其 `docs/FS_12_MAP_ACTIVE_MASTER_20261116.md` 指定**六種 biome×地下城/村落＝十二張地圖**，並沿用正式 World Bible 名稱（如 `FS_01_MAZE 幽葉迴廊`、`FS_01_VILLAGE 苔光村`）。2026-11-16 真正 R8 R3 已有 Godot 4.7.2 native 1280×928、187 PAR、175 trees、8/8 nav checks、日暮夜 6 幀 GPU QA，**ART HOLD**。私人完整 398檔、199,988,204 bytes ZIP 只放 owner-only Drive https://drive.google.com/file/d/1uGa7waQ-SwSSWVcgGUnbmlI7PjRaEKC2/view，SHA256 `1c235f6155298a8f4bd54173e228ad4061ac8abced29d3d296136e0567983830`。
**這條正式地圖線不得被簡化測試場覆蓋**。要讓 FSPlaybleSlice 用正式 A35 Ground/PAR 時，先取得 owner-only 完整資產 ZIP，在私人 staging 核對 hash/manifest、相容 map ID/actor footpoint/collision/PAR/YSort，重新跑真 Godot GPU navigation/透視再合併；不得只把地圖源 code 和私人缺圖的空白 scene 假裝已連接。

### 5. 下一輪明確工作
1. 取得真正有效私有 original `FS_DB_AUTOSET.apply_all` 後 11 表／505最後別名 runtime witness，打開 FSDatabase 真原版 gate，禁止把合成 DB 當正式 FS。
2. **跨工作線合併**：用私人 Ground/PAR A35 R8 R3 真 native 場景做正式 `FS_01_VILLAGE`，套入既有 `FSVXEventInterpreter` 的事件標記、互動觸發、真 `FSBattle` ACT overlay；使用獨立 A35 R8R3 baseline、不污染它。保留 A36C 森林迷宮及 12 MAP world bible。
3. 地圖導航與動畫：正式角色任意幀動畫/腳點、事件觸發、碰撞/遮蔽、地圖/戰鬥實際場景切換。未驗證的原版事件 opcode fail closed，Game Over/escape source witness 待補。
4. 永久進度只可導向 user-authorized owner-only Cloud Drive/GitHub，不在開發機留常駐文件；此輪「記憶體暫存」會隨應用結束消失，不能叫正式永久存檔。
5. QA、Failure Log、GitHub Handoff、PRIVATE Drive Handoff 每輪完整收尾；**Phase1 SEAL=NO**。
