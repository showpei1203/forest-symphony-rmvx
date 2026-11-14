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
