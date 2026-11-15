# Forest Symphony｜Godot 4.7.2｜2026-11-16 正式工程 Handoff
## Phase529｜艾薇被動142 OD 減傷實際戰鬥、舊版814相容、State100真相核對

**正式分支：** `showpei1203/forest-symphony-rmvx` / `feature/fs-godot-phase1`
**原版：** `E:\\遊戲專案開發\\三大項目現行專案\\FS project` 僅唯讀；Godot 為唯一未來開發引擎。禁止回退 VX 開發流程、禁止覆蓋 main、禁止公開原始有效資料庫。
**仍未完成：** 原始 VX `FS_DB_AUTOSET.apply_all` 完整 post-Apply 11 表及 505 RGSS2 最後覆寫的原生 runtime witness。這一批為可執行、通過原生 Godot 測試的**來源限定子集合**；**Phase1 SEAL = NO**。
**承接前輪：** `godot_port/docs/HANDOFF_20261116_IVY_REVENGE_SOURCE.md`，147 蓄痛復仇 / State85 自動 Note 產生器、原生 CI `43756469456` PASS。不得重頭重做。

### 1. 核對原版 RGSS2、真正生效順序
- `All_Scripts_Export.txt` 原始腳本 SHA256 `9cbc7a9b4f3595706f3bd9987c8353951b73b14bfafce0c574d5c21e438f0f24`，原版 ComboCore `Game_Battler#albert_combo_od_damage_reduction_percent` ~211185–211227：`<reduce_damage_if_od 50:12>` 先檢查受傷者目前 OD 百分比；`<reduce_damage_per_od_percent:0.08>` 加上每 1% OD 的 0.08% 減傷；所有符合標籤加總，再 clamp **0..90%**。對正 HP／MP 技能傷害及正 HP 普攻傷害，`int(damage×(100-reduction)/100)` **截斷**，不是四捨五入。此階段只處理已證的單目標正 HP 攻擊及技能；未知原版 MP 傷害仍被 FSBattle 原有 gate 阻擋。
- 原版 `FS_MASTER_SETUP::SKILLS[142]` ~278835：被動 **怒意不熄**，來源字串確有條件 50:12 + 連續 0.08。OD 0%＝0%；49%＝3.92%；50%＝16%；100%＝20%。以來源傷害77為例，實傷分別 **77、73、64、61**。
- `FS_BATTLE_V22` ~253385–253540 `PASSIVE_NAMES` 同時辨識正式 ID142 與舊版 ID814（名稱必須「怒意不熄」）；`passive_skill_note_text` 收錄已習得且為機制被動的 Notes，即使沒有 `<mechanic_passive>` 也可以由 **ID+名稱** 辨識。被動亦可由 `skill.passive` 判定。OD 減傷的最終 ComboCore `source_text` ~210345 讀取 `albert_notes_for_user`，經 ~253787 最終擴充後包含裝備 + 目前 States + 已習得被動；**不包含 ActorProfile.tag_text**（不同於艾薇蓄痛的來源），故故意在 QA 加入 Profile 假 90% 減傷，驗證沒有錯套。
- `ALBERT_IVY_CLONE.try_redirect` ~248198–248300 的**真正順序**：主動護衛先減少護衛次數並給主 Ivy **+6% MaxOD**，才呼叫 `perform_guard_damage` 重新計算護衛者自己的攻擊傷害，最後 source `execute_damage` 結算、致死保命、隊伍與自身 OD+2% 回饋。因此 OD490/1000 主動護衛時 **先變 OD550/1000**，142 的 50% 門檻已跨過；護衛者來源 raw77 × (1−16.4%) 截斷為64，再 Cover25% => **48 HP**，事件結束 OD590（+60+20+20），蓄痛增加48，原本被保護隊友不扣 HP。舊程式用「護衛前 OD49%」估算是錯的。
- `FS_MASTER_SETUP::SKILLS[145]` ~278895–278915 的 **痛苦熔爐** 仍為 scope11/MP16/plus_state_set=[85,100]，而 `ALBERT_MECHANIC_EXPANSION::AIZHUO_OVERLOAD_STATE_ID=100` ~219662 也使用同一個 State ID。透過只讀 Python RubyMarshal 直接開啟原始 `Data/States.rvdata`（21,830 bytes，SHA256 `55EB136CFB616313D804CDBD0A221DE46121ACDCDA098EF11E24C554D6FB00DC`），原始 raw State100 為空名稱、空 Note、hold_turn0、auto_release_prob0、四屬性倍率100。原版 MasterSetup STATES 清單中 91→120 無100補丁。但**原始 raw 並非 runtime post-Apply 有效 State100**，不能據此認定正式 145 的 State100 是無效／可刪；且 JP/蓄力/冷卻/State timer 等原版覆寫仍未完工。Skill145 **嚴格 HOLD**，不得假裝只加 State85 就完成。私有原始 RVData 沒有上傳 GitHub。

### 2. 本輪實際完成的原始碼
1. **新增 `scripts/FSIvyODDefense.gd`**：`.active=false` production，僅已來源核對的 Actor#5。動態解析原版 ComboCore 條件及連續 OD 減傷，對已知源的裝備/State Notes + 最終 FS_BATTLE_V22 被動技能 Notes 加總、上限90%、Ruby 正傷害截斷。讀取當前 `max_od`／`od`；`pending_main_cover` 先虛擬加入 Main Ivy +6% MaxOD 計算而不提前真正改寫 OD，直到整筆 Cover 交易驗證成功。雙重檢查 ID142 正確原始名稱與 Note；支援舊版 ID814 以及其他合法被動的名稱匹配。來源不符立即 `ok=false`、不碰 HP/MP/OD/RNG。
2. `FSBattle.gd`：`attack_preflight`、`skill_preflight` 來源純檢查，在 HIT RNG 前完成；真正普攻／單體技能在 source power、暴擊、Guard、141/147 source 子集之後，Field404、Cover、ManaShield77 **之前**套入 OD 防禦，damage commit 後才記錄 evidence。新增 `enable_private_ivy_od_defense`：只有 `db.boot_final_verified` + private Profile/裝備/State provider 且非 fixture 才可交易式開啟；不能靠手填旗標冒充原版生效。
3. `FSIvyCover.gd`：原先有正確 fail-closed guard，學會142便拒絕，因為當時還沒有減傷引擎。現在改成142/814 都需**實際活躍 `FSIvyODDefense.quote`** 才能護衛，避免以前 `fs_ivy_passive_defense_verified` 單獨放行卻沒有真正減傷。計算實際護衛者傷害時在最終 Cover reduction **之前**加上含 +6% 待付款的 OD 減傷。交易 commit 後才紀錄 source QA。
4. `FSScreen.gd`：戰鬥 HUD 讀真實 source quote，顯示「怒意不熄：OD 59.0%｜傷害減免 16.72%（來源限定）」，並保留 HP、OD、護衛次數、蓄痛原本欄位。
5. **新增 `tests/test_fs_ivy_od_defense_528.gd`**：真正執行 Godot `FSBattle.attack`、`FSBattle.use_skill`、`FSIvyCover.commit`，測 OD0/49/50/100%、來源77→77/73/64/61；來源 Profile 的假 90% 不干擾 ComboCore，裝備+1% 叠加、90% clamp、完全純淨 Preflight 不抽亂數；實際 HP、MP、OD、護衛充能與蓄痛一致；OD49→55 後主動 Cover raw77→64→48（再+2%+2%，OD590）；技能 Smooth171→減傷143；不存在 post-Apply 來源時 private activation 拒絕；Skill142 缺 Note／錯名字 fail close，舊 Skill814 即使無 `mechanic_passive` 仍按被動名匹配，且關閉來源引擎時 Main Cover 必須拒絕，不能錯算。
6. **新增 `tests/capture_fs_ivy_od_defense_qa.gd`**：真正 Godot 4.7.2 Xvfb / OpenGL 1280×720 原生 GPU 截圖，不是拼裝的 Mock image；合成 Actor5、Friend、Enemy 真正走 native source Cover，HUD 顯示 Ivy HP952／OD590／蓄痛48／護衛1次／OD59%／減傷16.72%。來源只限獨立 synthetic QA，不把原版 private FS art/boot data 當成已通過的測試。CI 上傳 artifact `fs-godot-p1-ivy-od-passive-native-qa`。

### 3. QA / Failure Log（不可把失敗隱藏）
- 新增測試首次 `43769697853` FAIL：舊 `FSIvyCover._guard` 發現 Skill142 即直接拒絕，原因是當時未移植減傷。沒有扣血、OD、護衛充能，也沒有消耗 RNG，為正確的前期安全設計。
- `43769814285` 及 `43769916017` FAIL：第二輪詳列實際 Godot trace，`damage=0`, Ivy HP1000/OD490/charge2、不抽 RNG，`errors=["艾薇被動142 的怒氣減傷尚未驗證"]`。確認不是新公式錯，而是舊前置防護尚未接線。修正 `eb5bce45d92e64d2c830b1e55feff90fc2798de9`：舊布林 gate 換成真實 OD adapter `quote`。完整 `43770035094` **SUCCESS**。
- `43770388627` **SUCCESS**，包含 source native 528、完整舊 Battle/Boss/Field404/Event Studio/Skill147/native Screenshot suite，以及新 1280×720 OD142 OpenGL artifact。人工下載與目視驗證，中文字型正常，HP952/OD590/蓄痛48/減傷16.72% 無數值截斷。
- 新增舊 ID814 name-match 與私有來源 transaction 測試後，最終完整 `43770731926` **SUCCESS**，0 failures；最新 artifact `fs-godot-p1-ivy-od-passive-native-qa` ID **14184013335**，下載驗證 PNG 1280×720 RGBA、187KB 左右、SHA256 **`d12dc9cec6fb510d47ff23e406c73581b3905b2646708550758dacf18262b480`**。已在原生截圖目視確認中文字、OD59%、減傷16.72%與傷害事件。此包尚未取得正式 FS 原始有效資料 witness。

### 4. 下一階段（從這裡繼續，不重啟專案）
1. **145 真正痛苦熔爐**：查原版有效 boot 11 tables/State100 最後有效內容，確認 Aizhuo 100 與 Ivy 145 交叉 ID 設計，整理原始 `Game_Battler` State85/100 附加、行動回合、四回合屬性/Note 刷新，連同 JP/charge/recharge/ricarica 效果及動畫精確整合。未有相容權威前仍 fail closed，絕對不能只造 State85。
2. **全戰鬥系統與劇情可玩**：打通 Map、事件視覺編輯器、真實角色動畫和完整 Boss 戰鬥等其他工作線成果，取得可遊玩 vertical slice，而非持續只做合成測試。
3. **私有原始 witness**：先由 E: 唯讀的真正 VX runtime 產出 `FS_DB_AUTOSET.apply_all` 後有效 11 表及 505 最後覆寫序列證據，僅放 PRIVATE Drive，不進公開 source GitHub。
4. 每輪要更新原生 Godot QA、Failure Log、GitHub 專用分支、私人 Drive Handoff，**Phase1 SEAL=NO**。

**備註：** 本段轉換資料與 source snippets 僅用於直接比對原版、不包含整個私有 RVData；原始 E: 未改動。所有工程 source、測試、Handoff 在 GitHub feature branch 持久化，私人正式 Drive Handoff 另建。
