# FS Godot P1 Migration｜Failure Log & QA（2026-11-14 最新）

## Source / scope
- Current authority: `godot_port/docs/FS_GODOT_MASTER_ROADMAP_20261114.md`.
- Original source `E:\遊戲專案開發\三大項目現行專案\FS project` read-only. All new source/tests/QA written to GitHub draft branch only. No local PC deliverables.
- Godot 4.7.2 official Linux headless Actions runner is native engine runtime; UI screenshot/manual look & original VX source parity not yet done.

| Gate | Status | Evidence / blocker |
|---|---|---|
| Long-term Event Studio scoped and uploaded | **PASS** | Master roadmap GitHub readback; existing v0.1 retained |
| Original source read-only schema audit | **PASS focused** | Actors 300; Classes 300; Skills 800; Items 850; Weapons 350; Armors 800; Enemies 800; States 155; actor Table 6×100 and System.party_members [1,2,5] |
| Source animation 3-frame compatibility | **PASS synthetic** | Legacy adapter 16 actions; 30/32 px cells; 4-sheet mapping |
| New animation unrestricted frames | **PASS native synthetic** | Clips 1/3/6/8/12, individual ms, loop/one-shot, marker, dimensions; original private A37 8-frame art is ART HOLD |
| Actor/class/equip/learned skill data | **PASS source-shaped synthetic** | Class.learnings, weapon/armor sets, dual wield second-hand, two-handed release, hit/eva/cri, atomic inventory |
| MENU data model + screen controls | **PASS source-shaped native** | Owned items, only learned skills, equip-change, formation, status; original PNG visual parity **NOT DONE** |
| BATTLE commands/target GUI | **PASS source-shaped native partial** | Party actor selector, enemy/ally chosen targets, unlearned/special skill blocked, battle active guard; exact formulas/ATB **NOT DONE** |
| Actual source JSON full export to private Drive | **NOT DONE** | Only read-only parsing/audit; must transfer private binaries through approved cloud-only mechanism + readback hashes |
| FS effective 505 RGSS2 methods / ATB / OD / Break / Cover / state / AI | **NOT DONE** | Stock VX attack/skill/ATB candidate cannot be called final FS parity |
| Original MENU/BATTLE art/animations and screenshots | **NOT DONE** | Private PNG/audio not imported; A37 RUN8 pilot only, F6/F7 ART HOLD |
| Phase 1 sealed | **NO** | All source data, accurate combat/UI/assets and native GUI comparison still missing |

## Failure / fix records
1. **Animation compile failure (CI run 43545037525)**: `FSActionSprite.gd` child constant `PROFILE` shadowed parent `FSAnimationSprite.PROFILE`. Fixed as `LEGACY_PROFILE`. Rerun **PASS** run 43545175933.
2. **MENU runtime type failure (CI run 43546020413)**: synthetic test assigned `[1,2]` (Variant Array) directly to typed `FSGameState.party_actor_ids: Array[int]`. Native error, then 50s timeout. Fixed both `test_fs_menu_model.gd` and `test_fs_menu_battle_ui.gd` by appending integer IDs. Rerun **PASS** run 43546339479.
3. **Intermittent native Godot focus error (older runs)**: legacy Event Studio deferred focus targeted a Control after freeing it. Fixed `FSDialoguePanel.gd` to only focus current live buttons. Latest integration run has no fatal test errors.

## Verifiable current CI
- https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43546339479
- Import project Godot 4.7.2 **PASS**. All original event tests, animation tests, equipment tests, MENU model and MENU/BATTLE actual Control interaction tests **PASS**.
- Test data are synthetic source-shaped dictionaries and generated in-memory textures, NOT private FS binary asset playback or numerical original VX parity tests.

## Next execution gates (current P1)
1. Safe private asset/data transport (read-only original, Drive hashes/readback) with no PC new working copies.
2. Source-code authority graph: resolve final Ruby alias/override on combat stats, hit/evade, ATB, skill/item costs and AI.
3. Deterministic original-versus-Godot battle trace fixtures for party [1,2,5], representative enemies and 6 heroes, including equipment changes.
4. MENU/BATTLE reconstruct from private 544×416 original artwork and original icons; validate keyboard/pad + real screenshots.
5. Integrate A37 variable-frame RUN source when art QA approved, then complete other actor/battler clips without any 3-frame hard limit.

## 2026-11-14 新增 P1 Source Authority 與道具 QA
| Gate | 狀態 | 佐證與未解決部分 |
|---|---|---|
| 505 RGSS2 順序、SHA/alias/方法定義靜態索引 | **PASS 靜態** | Actions artifact `fs-rgss2-static-authority-index`，22 MasterSetup page、1 apply_all call；不等同 VX runtime 實際 alias 效果 |
| Boot-final FS 權威資料驗證 | **PASS synthetic gate** | `FSDatabase.load_all` 拒絕未具 VX source+SHA witness 的原始 11-table JSON；test_fs_boot_authority_guard 原生 PASS。現無真資料證據，因此 production load 仍刻意失敗 |
| Stock VX 簡單物品回復與 Pharma | **PASS synthetic** | `FSItemRules.gd`、`test_fs_item_recovery.gd`；FS 自訂 Note/狀態/公共事件/自訂成本全部仍 NOT DONE |
| 真正 MENU / BATTLE 物品選擇與我方角色目標 | **PASS synthetic native** | `FSScreen._select_item_target`、`test_fs_item_ui.gd`；未重製原 UI |
| FS_MasterSetup post-apply JSON 全量 | **NOT DONE** | 來源 E: 只讀，尚無能直接把最新本機 binary 安全上傳私人 Drive 的完成流程；不可用舊歷史 ZIP 取代 |
| FS 道具的最終 Runtime 公式 | **NOT DONE** | 須解析 MasterSetup + alias、Notes、Common Events、Item Cost 等 |
| Original VX trace / effective cost | **NOT DONE** | 無 runtime witness，CI 合成測試不代表精準等價 |
### 新增修復
1. `test_fs_item_recovery.gd` 最初用有 Pharmacology 的施用者預期 300 HP，實際應 ×2；測試拆分一般角色與 Pharmacology，修正。
2. 同一測試之 battle-only 物品誤選已滿血角色，保護拒絕是正確行為；改測受傷角色再驗證 occasion。
3. `rgss2_authority_scan.py --self-test` fixture 偵測只接受複數 `Fixtures`；修正同時支援單數/複數，502+ 等載入順序仍不據此判斷 runtime。
### 最新 native/CI 證據
- PASS run https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43547941870
- 17× Godot 4.7.2 headless native script tests、Python scanner unit selftest、505 script SHA/source audit，GitHub artifact retained 30 days（至 2026-12-14）。

## 2026-11-14 下一批戰鬥規則 Source-Parity 部分移植
| 本輪項目 | 結果 | Evidence / 風險 |
|---|---|---|
| FS #411 MP-only Cost source parser | **PASS native synthetic** | `FSSkillCostRules.gd` + `test_fs_skill_cost_authority.gd`: note 固定與百分比、halving、無法解析 fail-closed；其他多資源成本及 YEZ modifier 不可略過 |
| MENU/BATTLE 技能成本 quote=payment | **PASS native synthetic** | `FSMenuModel`/ `FSScreen`/ `FSBattle` 全部使用同個 `FSSkillCostRules.preview`；不明成本不能下指令、不扣 MP |
| FS #377 Boss 直接 ATB 削減與動態抗性 | **PASS native synthetic** | `FSATBResistance.gd`/ `test_fs_atb_dynamic_resistance.gd`: 1000-base、note、倍率、floor、Aizhuo pierce、有效敵方行動復原；其他 Tankentai ATB/OD/Break/Cover 仍 NOT DONE |
| 真 VX 505 RGSS2 最終實際 MP/ATB parity | **NOT DONE** | 尚無 post-Apply runtime witness、multi-script alias/行動時序、私有正式資料；不能由合成 PASS 代替 |
| 真原素材與 UI/VX 截圖手動驗收 | **NOT DONE** | 仍無 FS 私有原圖及 VX runtime 對照 |
- PASS CI：https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43549022785
- 兩組 Godot 4.7.2 synthetic native script tests 新增，原 17 tests retained。沒有讀寫使用者原始 E: 專案。

## 2026-11-14 Tankentai 核心計時與 UI QA

| Gate | 結果 | 證據及邊界 |
|---|---|---|
| 原版 ATB 基礎速度與初始量表 | **PASS source-shaped synthetic** | `FSTankentaiATBCore` 第 230／231 段對照，Source AGI per-frame 整數、武器空位加成、preemptive/surprise |
| ATB→ACT 充能與行動後重置 | **PASS model-level synthetic** | `begin_charge/reset_after_action` 分離兩條量表；**還沒有真完整 action queue/execution/scheduling** |
| Godot BATTLE 畫面即時推進 | **PASS native UI** | `FSScreen._process` 只在 BATTLE 更新 source gauge，狀態文字顯示真資料，MENU 暫停 |
| Boss 抗性與 ComboCore 負延遲一致 | **PASS deterministic synthetic** | source #374/#377 整數值同步，取消 ACT/ready 並重新計時；State 多段 alias/runtime witness 仍待 |
| 原 VX 真運行時序/傷害/OD/Break/Cover | **NOT DONE** | 需要原版 post-Apply 資料、動畫和 VX trace、完整行動佇列 |
| 原圖對照與原生 GUI 人工驗收 | **NOT DONE** | 缺少 FS 私有素材與截圖 |

### 失敗、分析、修正
- **原子幀數測試失敗**：`test_fs_tankentai_atb_core.gd` 整合測試原本從 enemy ATB400 推 58 幀卻要求達到 1000，實際只有 980。修正為 60 幀。正確原公式每幀 +10，沒有為了過測試而修改。
- **Array[Dictionary] 型態錯誤**：`test_fs_tankentai_ui_tick.gd` 初版直接指派普通陣列給型別化欄位，Godot 跳 Script Error，50秒 timeout exit124。改為 `.append(Dictionary)`，回歸 PASS。
- **錯誤分支寫入已立即復原**：漏傳 GitHub `update_file.branch`，導致 `main` 短暫被寫入單一測試 fixture commit `d0ebfdc7...`。當輪立刻以 `expected_sha` + `force=true` restore 原 `main=fca0f884...`，並在 feature branch 正確補上提交 `de49bfb6...`。`develop` 不變。後續所有 contents API 更新必須**強制傳 branch**，版本應從 feature ref 讀取及 readback。不可再違反不動 main 的規則。
- **同步風險修正**：源 #374 `albert_combo_apply_atb_delta` 對負 delta 會清掉 `act_count/act_active/at_active` 並 `atb_count_up=true`；源 #377 Boss 抗性之前只改顯示用 float，下一幀 source integer 可能覆蓋。已修正 source 整數同步與負 delta 取消充能。

### CI
- GitHub Actions official Godot 4.7.2，**21 native script smoke tests**（原本19 + 新增2）與 Python 505 scripts authority scanner。
- 原始成功鏈：https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43550617123
- 注意：**沒有執行原 FS 的有效數值 trace**。本輪都是 source-shaped/in-memory synthetic 檢驗，Phase1 Seal = NO。

## 2026-11-14 ATB 行動佇列回歸與風險
| Gate | 結果 | 證據與限制 |
|---|---|---|
| 玩家 ATB 指令防提前出招、重複佇列 | **PASS native synthetic** | `FSActionQueue.request` 強制 readiness 和唯一 pending actor |
| ACT 蓄力完成才付 Skill MP / 消耗 Item | **PASS native synthetic** | cost quote+effect 在 resolve 重新驗證；Item1 20% ACT (20 source frames) |
| Attack/Guard/Skill/Item 真 BATTLE UI | **PASS native integration** | `FSScreen` buttons disabled until ready; 目標／技能／物品選擇時按 #230/#231 wait freeze |
| 角色 ComboCore -ATB 中斷 ACT / 原佇列失效 | **PASS native synthetic** | `apply_combo_atb_shift_to_actor`、`cancel_interrupted`，中斷後 MP 及目標 HP 不變 |
| ACT 期間目標死亡、不合法執行 | **PASS native synthetic** | 只完成一次失敗 receipt，成本不扣，reset 為候選處理（**未經 VX trace**） |
| 敵方自動行動/攻擊數值與全 505 alias、OD Break Cover | **NOT DONE** | 此時只有玩家端已驗證子集，不可說全套 queue 完成 |
| 真 FS 資料/美術/動畫/VX screenshot | **NOT DONE** | 原始資料轉換後 post-Apply private Drive 尚未完成 |
### 重要 regression 說明
- 首次啟用 UI ATB command gate 時，舊版 `test_fs_menu_battle_ui` 仍預期 ATB 未滿就能選敵人，CI 43551735116 的 `attack opens target choice` 失敗是新 gate 正常拒絕。更新 fixture 使角色跑到 source READY，再 assert ACT 蓄滿後才扣技能 MP、再執行物品消耗。最新全 22 native PASS。
- 對 `FSActionQueue` 新增總計 1 個核心 regression，包含第 374 段失去 readiness 中斷與多種資源交易失敗防護。未藉由更動測試來繞過 source-gate。
- 最新原生/CI https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43551938441

## 2026-11-14 敵方 AI 串接與 QA
| 項目 | 狀態 | 驗證依據與限制 |
|---|---|---|
| #211 `CONDITION_ROULETTE=true` + #210 test RNG LCG | **PASS native synthetic** | 順序加權輪盤 + seed=12345 [6,5,3,573] + trace tag，非 stock VX ratings_max-3 |
| #406 Enemy Action Distribution for 600–745 | **PASS synthetic** | Party/BREAK/Note/previous skill rate, 15~90 clamp, off tag, fixed chance |
| Enemy readiness → choose → ACT → execute → recharge | **PASS native synthetic** | `FSActionQueue`, #231 60 fps，敵人不可能在 ATB 未滿時先造成傷害 |
| Enemy Scope1 attack／Scope7 friend recovery & late MP | **PASS native synthetic** | `FSBattle.skill_preflight` 修正敵我相對範圍，執行前成本與目標重驗 |
| -ATB 中斷／敵方目標死亡／雙敵人先後 | **PASS native synthetic** | 負 ATB 清除 queued ACT，死人不消費；兩敵同時 ready 分別下一來源幀執行 |
| #401 Boss action provider／#211 Skill83/Turn/121..130／#372 Provoke+Threat | **NOT PORTED** | 明確 fail closed 不假裝策略/目標；不能當正式 AI parity |
| 真 FS 後套用資料/VX witness/真原素材 | **NOT DONE** | 原私有 data 未透過核准 Drive 流程完整帶入；P1 Seal NO |
### Failure Log
- **Run 43553128766**：原 `test_fs_enemy_atb_queue` 的同時就緒測試假設「第二隻排隊時第一隻仍在 pending」，但零蓄力攻擊在選招後 frame+1 就能結算，因此 frame90 第一隻排隊、frame91 第一隻完成並排第二隻、frame92 第二隻完成。修正為觀測正確逐幀狀態，沒有降低來源規則嚴格性。
- **加強回歸**：新增 enemy scope7 對自己回復與 source ACT10幀成本、蓄力時敵方目標死亡未扣 MP。完整 24 組原生 PASS：https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43553309465。
- 原始 E 槽唯讀，`main`、`develop` 不允許改動，公開 GitHub 不含使用者私有 `.rvdata`/PNG。文件/程式已上傳 feature branch。


## 2026-11-14 Boss Context + TargetPriority QA（本輪）
| 項目 | 狀態 | 來源／證據／嚴格限制 |
|---|---|---|
| Boss 核心 551–565 情境 AI 表 | **PASS source-shaped synthetic** | #401 Runtime Provider = #440 MasterSetup 15，同一張 `CONTEXT_ACTIONS`；15 core；Boss ID 排序，包含已死亡但仍留場的 Boss |
| 無對應 Boss 時核心回原 Enemy.actions | **PASS synthetic** | #401 `candidate_actions_enemy` 僅在 specs 存在才替換；不可一律停止 |
| Boss Core551→Boss540 技能300/302，ACT 完成付款 | **PASS native synthetic** | 真戰鬥 `FSActionQueue` enemy pending Skill，不提前 MP，ACT 完成造成 HP 變化 |
| #372 目標最高優先與嘲諷 State14 | **PASS native synthetic** | UI 與 Queue 同源限制，Note、State Note priority，State14=1000；敵人 random first Provoke |
| ACT 期間優先級改變的舊目標失效 | **PASS native synthetic** | 結算前再驗證新最高優先；阻擋過期目標、不消耗 MP，精確 VX retarget 尚未認證 |
| 技能 `<ignore target priority>` 繞過與成本中立 | **PASS native synthetic** | #372 目標規則 + #411 quote：僅允許已驗證 target-priority tag，MP 在 ACT 完成扣 |
| Boss 召喚/天氣、複雜 Threat/Disappear、正式資料／原 VX trace | **NOT DONE** | 非 source-final / 非原 FS 可玩封版 |
### Failure log / source correction
- 首次工作流程 https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43554116441 的第 25 前之舊 `test_fs_enemy_ai_source.gd` fail：舊測試預期「Core551 不論 Boss 是否在場一律不得使用原 actions」。查原版 #401 `return base if specs == nil || base == nil` 才證實這是**錯誤的早期保守假設**，因此改為「無對應 Boss 時回原 `Enemy.actions`」。沒有為了通過測試而捏造 fallback attack。
- #372 新增 ACT 執行前目標再驗證；防範選定後 Provoke/target priority 動態改變導致錯人被打。這是安全 fail closed；原版自動換目標的完整流程未取得 VX runtime parity。
- 驗收：https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43554328368 （Godot 4.7.2 native 26/26 PASS；505 RGSS2 static authority scanner retained）。私有素材/檔案未進 public，原 E 槽未修改。


## 2026-11-14 Boss Summon Runtime + ATB QA
| Gate | 狀態 | 真正證據與限制 |
|---|---|---|
| #401 / MasterSetup #440 `START_SUMMONS`、`CORE_GROUPS` 一致 | **PASS static** | Ruby 原字串經雙腳本比較完全一致，Godot 靜態字典基於此 |
| 開場 Boss507→Core551×2、Boss503 自己補員 | **PASS native synthetic** | Count 含場上既存怪，缺1補1，flag 禁止逐幀重複 |
| Boss510 altar 和 Boss511 雙 Elite RNG | **PASS native synthetic** | #210 tagged FS_AI_RANDOM test-only seed，來源物種池、72% fixed stats，8 slots |
| HP門檻 520≤70%、547≤60% | **PASS native synthetic** | 邊界710/700與600，按 source once-only threshold flag |
| Pokémon600 動態等級／HP/MP 成長 | **PASS guarded synthetic** | 無 level runtime witness 拒絕；明確合成 verified level10 才按原 #401 算 |
| 召喚後 ATB/ACT 與 #401 Boss context AI | **PASS native synthetic** | 只新敵人初始化 gauge，不重置既有方；新 Core 受同場 Boss #401 context 影響 |
| Source `ma_call_ally` 視覺/座標、Phase State+Weather、Break/OD/Cover | **NOT PORTED** | 無真 original VX runtime witness，不能當完整 Boss 召喚戰 |
| 原 FS post-Apply DB/美術/VX Screenshot | **NOT DONE** | 正式資料未匯入私有 Drive，原 Godot FS 不可作 playable seal |
### Failure Log / 證據界線
- 這輪 Godot 4.7.2 原有 26 + 新 2 原生回歸 = **28/28 PASS**（CI https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43555104501）；沒有失敗的 native tests 被弱化跳過。
- 仍存在**已記錄的來源對照缺口**：原生 VX `ma_call_ally` 的 sprite/safe position、Game_Enemy Runtime Level、Phase States/Weather/Shield 的具體狀態機與視覺沒有 runtime trace；使用獨立 source guards 不為尚未驗證成長／召喚建假 stats。
- 因部分 P1 synthetic 設定不含真 Boss 資料，`boss_runtime` 預設只在 `FSDatabase.boot_final_verified` 真時啟用；合成針對 Boss 的 QA 才明確設 `.active=true`。
- 目前全部新成果僅存公開 GitHub 合法程式碼／source-shaped synthetic；**沒有把原始私有 RVData、PNG、角色圖或音效傳上公開庫**，也沒在使用者 E 槽寫檔。


## 2026-11-14 Boss 524 Phase / 548–550 Global Weather / 530–531 Shield：Failure Log + QA
| 功能 Gate | 驗收 | 邊界 |
|---|---|---|
| Boss524 初始150、HP≤70% 151、HP≤35% 152、清除 Law140–143 | **PASS native synthetic intent** | 原版 #401 行號 415–443；無法執行 `albert_ant_initialize_law_cycle`，只記 pending，不產生假 Law |
| Boss548–550 HP≤55% phase/Field153–158 切換 | **PASS native synthetic intent** | #401/#440 + #404 FieldWeather 是全域狀態，無元素傷害/target type 套用 |
| Boss530/531 Shield77、45%128、全部 Core 死亡 Exposure129 | **PASS native synthetic intent** | Source flags 必須先 start/threshold；只有 State-ID 意圖，原 Buff/Shield 效果未移植 |
| Wait 期間 Phase/Spawn tick 與 BATTLE 顯示 | **PASS native integration** | source #401 Scene_Battle.update 在 ATB input WAIT 時仍更新 phase；UI 清楚寫 pending/unapplied |
| 缺原 State/Field 資料 | **PASS fail-closed** | State151、Weather158 缺資料拒絕該階段變更，避免半生效與未知倍率 |
| 真原 VX State effect/Weather damage/Law cycle | **NOT DONE** | 不能只把 ID 塞進 battler.states；後套用真資料與完整 alias witness 未有 |
| 原始角色/怪物圖、動畫、正式 battle parity | **NOT DONE** | P1 Seal NO |

### 本輪特別處理的來源陷阱
1. **不可把 State IDs 當成完整狀態**：原 #404 明寫 Field153–158 是 `Game_Temp.field_effect`，不應加入每個角色 `states`。因此程式採 `fs_phase_state_intents` 和 global `weather_request`，BATTLE label 也標「未套用」。
2. **Boss524 第三階段不能強制變回第一階段**：原 #401 只在 HP門檻內增減 State，沒有補血後撤銷152的來源分支；測試覆蓋152與151可能共存這個反直覺結果。
3. **不能在 WAIT 模式漏掉 Boss 更新**：此前每幀 `advance_atb` 在 `source_atb_wait` 時提前 `continue`；source #401 Scene_Battle#update Boss hook 不應因此取消。改為 WAIT 只凍結 ATB/ACT/選招，Boss Tick 仍執行，新增 native 验证。
4. **只提供安全 Trigger，不偽造戰鬥效果**：State77 防禦、Law 140–143、Weather 正傷倍率與 505 alias 未確認時，任何標記為 pending 的 Boss 被 gameplay queue/AI fail-closed；不能用 synthetic PASS 推論正式 RPG Maker VX parity。

驗收來源：source-shaped in-memory synthetic 30 項 Godot 4.7.2 native script tests；第一輪 PASS https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43556057604，BATTLE UI 新文字後將重跑。只改指定 GitHub feature branch，原 E: 唯讀。
