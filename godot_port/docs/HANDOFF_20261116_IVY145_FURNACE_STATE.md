# Forest Symphony｜Godot 4.7.2｜2026-11-16 正式工程 Handoff
## Phase530–531｜艾薇145「痛苦熔爐」真實 ACT／State85+100 生命週期與被動來源修正

### 一、續工位置、禁制與真正目標
**專案：** `showpei1203/forest-symphony-rmvx`，分支 `feature/fs-godot-phase1`，Godot 根目錄 `godot_port`，Godot **4.7.2**。
**只接續，不重建：** 承接 `godot_port/docs/HANDOFF_20261116_IVY142_OD.md`，142/814 真實減傷、141 Cover、146 保命、147 蓄痛復仇與其較早來源驗證、Boss、Field404、地圖/Event Studio 等工程繼續有效。
**只讀：** 用戶原版 `E:\遊戲專案開發\三大項目現行專案\FS project`，完整 `All_Scripts_Export.txt` SHA256 `9cbc7a9b4f3595706f3bd9987c8353951b73b14bfafce0c574d5c21e438f0f24`；沒有修改原始 E:／GitHub main，未公開私有 11 表或 RVData。
**目標：** 真正移植 Forest Symphony 成為 Godot **可遊玩遊戲**，並建立可視事件編輯器，而非永久停留在合成 Boss 測試。地圖與人物動畫由其他工作線推進，不能重置或改寫其基準。**PHASE1 SEAL=NO**，仍缺正式遊玩所需完整 post-Apply 資料／505 scripts 最後覆寫 runtime 見證。

### 二、原版來源實際查核
1. `FS_MASTER_SETUP::SKILLS[145]` ~278895–278917：Scope11 自身，MP16，`plus_state_set=[85,100]`，`element_set=[13,7]`，`<jp cost:2800>`、`<jp level:27>`、`<jp skill:143>`、`<charge: 4, 10%, 0>`、`<recharge:10%>`、`<ricarica turni:2>`、`<cannot level>` 和兩條 `<pop_text>`。**所有真正原始 Full Note 仍 fail closed**：不得因這輪測試源型別成功，就宣稱已移植 JP/蓄力/冷卻全系統。
2. `FS_MASTER_SETUP::STATES[85]` ~285060：優先權290、`hold_turn=4`、`auto_release_prob=100`、`battle_only=true`、`restriction=0`、`nonresistance=false`、不因傷害解除、不降低命中、四屬性倍率100，`<store_cover_damage:150>`、`<cover_store_cap_percent:300>`、HUD 字串。
3. 原始 `Data/States.rvdata` **21,830 bytes**、SHA256 `55EB136CFB616313D804CDBD0A221DE46121ACDCDA098EF11E24C554D6FB00DC`，遠端只讀 Python `rubymarshal.reader.load` 實際確認 raw State100 空白名稱/Note、priority5、`hold_turn=0`、`auto_release_prob=0`、battle_only=true、四屬性100。`FS_MASTER_SETUP::STATES::DATA` 的條目從91跳120，不管理100；`FS_MASTER_SETUP.apply_authoritative_data!` ~294872 將 `STATES::DATA` 注入 `FS_DB_AUTOSET_STATES::DATA`，`FS_DB_AUTOSET.apply_all` ~37359–37382 經 Scene_Title 載入後修改表，另 `FS_AUTOSET_SUPPORT_STATE_DATA_FIX.BUFF_STATE_IDS` ~295427 未包含100。**以上是靜態／raw 查核而非正式 runtime 證據**，不可以推論有效 post-Apply State100 永遠是原樣。
4. 跨角色編號衝突：`ALBERT_MECHANIC_EXPANSION::AIZHUO_OVERLOAD_STATE_ID=100` ~219662，~222490 可移除 State100。這是同一個編號，**不能私自改名或刪掉145的100**。
5. `Game_Battler.add_state` ~3460–3520：若狀態不存在就加入，然後按 `state.priority` 降序排序（同優先權小ID先），每次附加／重新附加將 `@state_turns[id]` 重設為 `state.hold_turn`。`remove_states_auto` ~3659 只有在倒數>0 時減1，倒數=0 時 NEXT 次才抽 `auto_release_prob`。所以 State85 **第1、2、3、4次 ATB READY：4→3→2→1→0，第5次 READY 才100%移除**。
6. Tankentai `Sprite_ATB.atb` ~131388–131401：當 **ATB GAUGE READY** 呼叫 `remove_states_auto`，不是每秒、畫面刷新或技能 ACT 期限。ATB WAIT 冻結倒數。
7. `Scene_Battle#battle_end` ~32782／141997 與 `Game_Battler.remove_states_battle` ~3643：在一般戰鬥結束時移除所有 `battle_only` State。Gameover 特殊分支不同，本輪只在**勝利**清除來源限定的 Ivy85+100，不擅自擴張敗北處理。
8. **重要 Source 最後別名鏈修正：** `FS_BATTLE_V22` ~253385–253540 的 `PASSIVE_NAMES` 與 `passive_skill_note_text`，經 ~253787 將已習得機制被動的有效 Note 追加至 `ALBERT_CHARACTER_CORE.source_text`。因此有效 Note 不只 ActorProfile/Equip/States，還包括**Skill142/814、146 及合法其他被動**。`Skill146` 原始 Note 有 `<cover_store_cap_percent:400>`，故 State85 的300%上限可由學會146提升至400%。若 Note 被動已由 source provider 合併，`FSIvyODDefense` 不能第二次再加 Skill142 造成 OD50 減傷16%誤變32%。

### 三、本輪完成並提交的實際 Godot 工程
1. **NEW `scripts/FSIvyFurnaceRuntime.gd`**：`active=false` 預設，source-gated Ivy Actor#5 自身 Skill145 合成來源限定子集合，保留原 Scope11、MP16、State85+100、Element IDs；State85 完整 Note/hold4/priority290、State100 原 raw neutral/hold0/priority5，任何未知 Note 或完整原版 JP 等標記都 fail closed。`preview` 使用 `FSSkillCostRules` 真實 MP 預驗證 + future State 的 `FSIvyPainSourceProvider.build`，不動實際 HP/MP/RNG；`apply` 只在 ACT 成功後扣 MP16、同時附加兩 State 並設 State85 timer=4。重新附加重置 hold4，按 VX State.priority 排序；不會只套 State85 假裝完整原版145。
2. **`FSBattle.gd` + `FSActionQueue.gd`**：認可來源限定 Ivy145 `scope11` 只向自己施放，通過 10 個真實 Tankentai ACT frames 才執行（前9 frames 不消耗 MP/State），完整舊版原 Note 禁止執行。`advance_atb` 在每次 ATB READY 時呼叫 Ivy runtime 的 `on_atb_ready`，與既有 Boss State adapter 並行不重複消耗；舊天氣、OD142、Shield、147 仍保持。
3. **`FSTankentaiATBCore.gd`**：對已確認的來源限定145 使用原版 `recharge:10%` 公式在 ACT 結束時重置 ATB=100/1000，沒有把未實裝的原版 `ricarica turni:2` 當成不存在。
4. **`FSIvyFurnaceRuntime.on_atb_ready`**：State85 第1～4次 READY 4→0，第5次 READY 真正解除85但保持 State100，立即重新衍生 ActorProfile/Equip/States/Passive Note；不在 WAIT、同一 READY 重複畫面、ACT 充能時扣期限。異常 State 資料/計數器時 fail closed。
5. **`FSIvyFurnaceRuntime.end_battle` + `FSBattle._check_end`**：真實 Godot **勝利**結束時按來源 `battle_only` 移除 State85/100、清 timer，重算角色有效 Note；unknown State100 變更即阻擋並標記 pending，而不靜默清除。GAMEOVER 特殊流程未憑空移植。
6. **`FSScreen.gd`**：Godot Battle HUD 可顯示「痛苦熔爐：State85｜倒數3｜State100：來源限定」，到期改顯示已解除，保留原有蓄痛／怒意／護衛與原生中文字型。
7. **FINAL source Note 修正**：`FSIvyPainSourceProvider.gd` 合併已學源形被動 Notes、受控處理 FS_BATTLE_V22 原版 3 組缺漏 default 補丁（名稱辨識 + 確切 Source Tags），並以 `fs_ivy_effective_notes_have_passives` 標記。`FSIvyODDefense.gd` 遇到已合併的被動 Note 時僅比對來源，不二次累加，避免142 減傷16%錯計32%。`FSBattle.enable_private_ivy_pain_notes`、`FSIvyFurnaceRuntime` 的 apply/expire/victory 都維持這個來源標記。
8. **NEW `tests/test_fs_ivy_furnace_state_530.gd`**：真實 Godot queue_actor_action→10 ACT frames→MP100→84 + State[85,100]，原生敵人對艾薇造成HP77，State85實際累積蓄痛77（預設100%），依第1～5 ATB READY 倒數／到期後真實蓄痛由100%回50%（受傷HP77記38）。另外測 WAIT不計次、同READY不重扣、再次施放重設4、完整原版145含JP Note拒絕、State100修改Note拒絕、欠缺post-Apply runtime拒絕、**勝利清掉兩個 battle_only State**，以及 State100臨時未知時保留且 pending 的 fail-close。
9. **NEW `tests/test_fs_ivy_final_passive_notes_531.gd`**：真實 Godot 攻擊+Pain+OD 實傷，Skill142學會後OD50=16%，同時學會146→痛苦蓄積 cap4000/MaxHP1000，未學146→State85 cap3000，舊Skill814名稱相符可生效，State85移除→直接承傷50%，修改被動技能Note或刪來源技能紀錄會在HIT RNG／HP／痛苦提交前拒絕；不能重複合併被動導致減傷16→32。
10. **NEW `tests/capture_fs_ivy_furnace_qa.gd`** + workflow：真正 Godot 4.7.2 native 1280×720 OpenGL/Xvfb 畫面，使用真實 Ivy145 ACT 10 frames、實際來源自我 State[85,100]、MP16、敵方 HP77 造成 Pain77，首次 ATB READY 4→3，確認 CJK 字元正確、畫面包含 HP923/1000 MP84/100 痛苦熔爐倒數3／蓄痛77。每次 CI 會保存 `fs-godot-p1-ivy-furnace-native-qa` PNG artifact。

### 四、原生 QA、Failure Log、交接邊界
- `43775011079`：新源形 Skill145、State85 5次 READY、State100 raw 狀態、舊專案所有 prior Godot headless native suite **SUCCESS**。
- `43775214767`：加上真正 OpenGL 1280 戰鬥 Screenshot 與 CJK 斷言，完整 **SUCCESS**。artifact ID **14185861394**，已下載原生 PNG、解壓目視確認無錯字/裁切：HP923、MP84、State85倒數3、痛苦77、State100仍在；PNG **1280×720 RGBA，149,802 bytes，SHA256 `2991138fa9172ce2c63818781e58b2d5bc8e2d164121d35c263e9e97654289a0`**。
- `43775661989`：學習被動 Note + Skill146 cap400 + Skill142 OD16不重算 + Legacy814 後，完整所有原生 QA + OpenGL 截圖 **SUCCESS**。
- `43775947118`：本輪最後新增**勝利解除 State85/100** 與來源失效安全測試後，正式 CI 應確認結果再封 Handoff；若失敗，先修正來源計時與交易並完整重跑。所有中間被後續 commit 的 CI concurrency 取消，不得當成測試成功，也不是測試失敗。
- **Failure Log**：本輪主要是原版讀法與相容性差異，不是可玩完整145：① 最初 State100 從 raw 空白與 Aizhuo 共用ID，不能推論 post-Apply；② State85到期是第5次 READY，不能從4→0就刪除；③ 重新施放必須依 priority 排序；④ 曾發現已習得 Skill146 的 cap400 與 Skill142 Note 雙計問題，完成程式修正並有原生回歸；⑤ 原始完整 Skill145 JP/charge/ricarica 仍未移植，**一律拒絕原版 Full Note**；⑥ Victory battle_only 初始尚未處理，已以來源 Game_Battler/battle_end 真正接線。
- 這些工程 source/測試/QA/Handoff 存 GitHub **feature** 分支；私人完整原版資料未曝光；原始 E: 未寫入。

### 五、下輪具體施工（不得停止在重新規劃）
1. **取得原版真正 post-Apply 11有效表與最後 505 alias runtime witness**，尤其 State100 與 Skill145 是否受額外補丁更動。設計**私有**資料驗證／匯出程序，絕不能把 raw States.rvdata 冒充已證明的 effective runtime，亦不得因 static absence 就宣稱 State100正式無效。
2. **JP/Skill Level/Charge/Cooldown/ricarica**：將原版145完整Note的各個引擎寫成 source-gated實際 Godot runtime + native tests，最終解除 Full Note fail-close。釐清 original Skill145對 State85/100 的命中/不抵抗/Duration 和 shared Aizhuo狀態管理。
3. **更重要的整體可玩度**：跨工作線整合 A35 Ground/PAR 地圖、正式角色行走/戰鬥動畫、可視事件編輯器和進場→戰鬥→劇情→存檔的一整段 Godot vertical slice。原版舊事件不必逐條原樣搬，但要可相容地再製。角色不受 VX 3 幀束縛。
4. 每輪大批施工，真的程式、原生 Godot QA、Failure Log、GitHub + 私人 Drive Handoff，不能只寫建議與測試口號。**Phase1 SEAL = NO**。
