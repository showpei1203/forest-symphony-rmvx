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
