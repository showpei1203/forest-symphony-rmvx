# Forest Symphony → Godot｜長期目標與移植施工權威 (2026-11-14)

**狀態**：候選實作，非完成移植。**最新使用者指令優先**於本分支任何舊的 P1 線性施工順序。

## 本輪決策（不可再退回）
1. **先完成既定 Forest Symphony 搬移**：以 P1 真實戰鬥系統、原始角色／職業／裝備／物品／技能／動畫數值、MENU/BATTLE 操作及素材重用為首要驗收；不可被 Event Studio 的長期增量工作無限推遲。
2. **FS Event Studio 與完整劇情工具列為長期目標**：現有 v0.1 原生工具／沙盒／預覽保留且可回歸測試，不需砍掉。但日後事件指令庫、雲端一鍵儲存、TileMapLayer 編輯、公共事件、移動路線、對話多角色編排、NPC 自動/平行事件、觸發器管理等暫以 roadmap 管理，非此次 P1 的前置依賴。
3. **不強求 VX 舊劇情批次轉移**：保留原始 VX `code/indent/parameters` 向 `FSVXEventInterpreter` 的兼容入口；未支援 opcode 明確報錯，沒有聲稱全面相容。
4. **人物行走／戰鬥／怪物動作脫離 VX 固定 3 幀限制**：Godot 的動畫每一動作可獨立配置 **1、3、6、8、12+ 幀**、逐格秒數、循環／單次、轉向、位移、圖層、受擊判定與事件訊號。VX Kaduki 3×4×4 資料只是一個 Legacy **adapter**，不是新動畫引擎的核心規格。
5. **其他動畫管線不得被倒退到 3 幀**：使用者已有另一條動畫實驗線（A17/A19 / PixelLab、ASF、骨架運動、PMD/LPC 等）；它已探索可變幀與動作資料。此移植只定義接入格式與可替換 renderer，不宣稱已從那些分支合併或已驗證所有原始素材。
6. **新舊素材兼容**：先保留 32×32 來源、原始角度與人物外觀；可使用更長幀動畫、逐格 timing 和一組動作多張透明圖。禁止為了硬塞舊 3 幀而砍掉新動畫，亦不可假裝原始 90×120／96×128 sheet 每格相同尺寸。
7. **所有新成果 GitHub／Drive；原始 `E:\遊戲專案開發\三大項目現行專案\FS project` 唯讀**。程式、CI、Handoff 留 `showpei1203/forest-symphony-rmvx` 分支 `feature/fs-godot-phase1`。私有完整圖、聲音與 .rvdata 轉換輸出留私人 Google Drive。原始 `main`、`develop` 與私有 `tankentai-sbs-godot` 均不得污染或覆寫。

## 優先排程 / 完成條件

| 階段 | 預定成果 | P1 Gate |
|---|---|---|
| **M0** 現存成果保護 | FS source hashes、GitHub candidate branch、原始 VX 相容與 Event Studio 定版長期事項 | 已有初步資料稽核／Godot CI；Phase 1 seal NO |
| **M1** 動作格式拆耦 | FSAnimationClip/Renderer data-driven multi-frame，Legacy Kaduki adapter，不同尺寸、duration、loop/end/action signal，同步測試 | **本輪優先施工** |
| **M2** 真實原始資料匯入 | 11 種 .rvdata 全量 JSON（含 actor tables、skills、states、classes、troops、animations）轉入**私人 Drive** 並 hash+readback，不公開原始私有/授權資產 | 缺少 cloud-only 大型二進位轉移整合；尚未完成 |
| **M3** FS 戰鬥相容 | RGSS2 505 節點的有效 alias/override 路徑、ATB、命中/防禦、OD/Break/Cover、裝備合法性/使用與敵人 AI，10+ 角色/怪物 seed 固定 fixture 比對 VX | 公式 placeholder 不能叫 parity |
| **M4** MENU / BATTLE UI | 原 FS 544×416 影像與圖示（權利確認後）直接重用、裝備/技能/道具/編隊/角色狀態、ATB/BATTLE/目標選擇與結果 UI 可操作 | Native screenshots + VX 對照 |
| **M5** 行走/戰鬥動作 | 原 Kaduki 16 組可 fallback；新骨架/PixelLab/ASF/LPC 轉為同一 Clip manifest，行走四方向、站立、攻擊、施法、受傷、死亡、特殊動作均可自定格數 | 6 主角＋指定怪物動作和引擎回放 QA |
| **M6** 完整移植驗收 | 真實原始資料驅動實戰、MENU 裝備/物品/技能、控制器輸入、可存讀測試、原始圖視覺驗收 | P1 Seal 待定 |

> **核心規則**：動作自由度提升不意味戰鬥數值可以隨意改。原技能/裝備/狀態、ATB 與戰鬥結果仍以原版資料和有效 RGSS2 規則為判準，除非未來使用者要求改設計。

## Event Studio 長期 Backlog（保留但暫不阻擋搬移）
- L1：Godot 編輯器中角色對話可視化、臉圖、表情、立繪、原版音樂／音效；先前 v0.1 預覽和合成測試繼續保留。
- L2：事件地圖觸發器、事件頁優先順序、碰撞/貼合/步進、平行和自動事件與保存／恢復語意。
- L3：多角色對話、劇情節點圖、任務／標籤、公共事件、動畫/鏡頭/音效、中文指令清單與 undo/redo。
- L4：安全的一鍵 GitHub/Drive 提交及版本衝突偵測（不能把 access token 寫在 Godot 版控）。
- L5：事件編輯器整體可用性 benchmark：完成 10 種典型 RPG 事件所需點擊、操作時間與 QA 錯誤率。
- L6：遺留 Ruby 腳本的明確 Adapter 白名單，不自動執行 Ruby；由真正需要的舊事件逐項補齊。
- L7：地圖美術遵守既有 Ground→PAR 順序（完整圖片拆層僅輔助），新動畫與地圖 Pipeline 不互相綁死。

## 隔離與驗證
- 任何三幀 Legacy 動作都應有 **明確 clip_id、來源圖、cell、sheet、幀間時間**，可無損播放原來源，不得默認要將所有新動作填滿 3 幀。
- 長幀的角色動畫是 presentation layer；戰鬥計算完成才透過 action signal request 演出，不能把輸出 frame index 當作造成傷害的判斷依據。
- CI：native Godot 4.7.2 headless、長/短幀 1/3/6/8/12 clip、混合尺寸、停止/loop/frame-skip、MENU/BATTLE 相容、實機圖像來源未進入私人 Drive 前清楚標 WIP。
- 每一個施工步驟需更新 QA、Failure Log、Handoff，取得 GitHub commit、CI log 與 readback。

## 第三方研究條件
- 先前 A17/A19 動作線的素材與規格必須獨立讀取授權／版本，不直接把其他對話「已完成」當作在此分支可用；ASF 喬伊 7 姿勢雖曾驗證像素差 0，仍需真正移入本分支的 asset source & test。
- 4.7.2 為本輪固定引擎版本；所有 UI/動作移植若換版本需 CI 重新認證。

## 本輪 Gate
**FS Event Studio v0.1**：目前已有功能雛形和獨立沙盒，本輪保留既有全部測試且不新增後續事件特性。**FS 原始數值/介面/動畫搬移**：開始新階段，待實際施工結果另寫 Failure Log。

## 本輪 M1/M3/M4 增量施工證據（2026-11-14）
- M1 **Godot Native synthetic PASS**：`FSAnimationProfile.gd` + `FSAnimationSprite.gd` 可播放任意幀數並設定各格播放時間、loop/end、marker、frame region；`FSActionSprite.gd` 只負責 16 組 Kaduki 舊動作相容。測試涵蓋 1/3/6/8/12 幀與 30／32 px 來源影格。**這不等於原六主角正式動作素材已核准或導入**。
- 使用者已有獨立 [A37 Godot-first RUN 實作](https://drive.google.com/file/d/1h1Z7XfyEicDrVfZdmiqbfnUeSU6QBQEu/view)（8 幀、原圖 256×128、採 64 px 格並用 AnimatedSprite2D）。此線目前明示 **ART HOLD**，F6／F7 待修，只有 RUN 而無攻擊／施法／受傷／死亡。新 Clip 方案可容納該格式，尚未搬入實際私有圖。
- M3 **部分資料移植 PASS**：唯讀確認 FS Actors 300/Classes 300/Skills 800/Items 850/Weapons 350/Armors 800/Enemies 800/States 155（資料表包含 nil slot 0），和 System.party_members=[1,2,5]；Godot `FSDatabase` 現在處理 actor Table(6×100), Class.learnings, 角色名稱/臉圖、dual wield/offhand、class weapon_set/armor_set、armor kind、hit/eva/cri；`FSBattle.equip` 支援雙手武器自動卸裝與原子庫存更新。測試 synthetic PASS，**真 FS 505 RGSS2 最終覆寫與完整原資料匯入仍缺**。
- M4 **操作介面增量 PASS**：`FSMenuModel.gd` + `FSScreen.gd` 提供目前隊伍真正已學技能、持有道具、裝備更換、編隊、角色能力、BATTLE 指定操作角色與我/敵目標。Godot 4.7.2 真引擎 headless 測試 source-shaped synthetic PASS。**外觀未還原、原始 UI 圖私有來源尚未匯入**。
- 最新完整 CI PASS： https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43546339479

## 2026-11-14 第二輪來源有效性與物品子系統狀態
- **嚴格更新 M2**：FS 原資料真正來源 = `Data/*.rvdata` + `FS_MasterSetup_00..20`（含 06.5，計 22 頁）+ `FS_MasterSetup_18` 在啟動後通過 `FS_DB_AUTOSET.apply_all` 覆寫。真實移植必須由這個 **post-Apply 狀態** 輸出並與原 VX 執行痕跡交叉對照。raw RVData-only 的 JSON 現在無法通過 `FSDatabase.load_all`，這是刻意保護。新規格 `docs/BOOT_FINAL_DATABASE_CONTRACT_20261114.md`。
- **M3 部分物品功能**：`FSItemRules` 已保守支援單體 HP/MP 恢復與藥物知識，僅在來源欄位無特殊 Note/State/CommonEvent/傷害/Element 時執行，不擅自付費或消耗，且包含 MENU/BATTLE 真控制項。User-facing FS 全量特殊道具 **未完成**。
- **FS-SkillCost 規則風險**：`FS_SkillCost_Authority_v2.0.0` 在 script #411 定義 `calc_mp_cost` 與其他成本；技能欄位只是移植起點。必須另實作 effective cost source and trace，現行 `FSBattle.use_skill` 仍僅過渡候選。
- **機器可讀證據**：Actions `fs-rgss2-static-authority-index` 具有 505 scripts source SHA and method/alias line hints。不可將最後一個 lexical definition 誤當 final-effective method；動態 alias、class re-open、runtime test pages 都需 runtime 判斷。
- Native Godot 4.7.2 **最新 CI PASS**： https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43547941870。所有原始來源檔 E: 唯讀，GitHub 只提交新程式與文件。

## M3 source-anchored battle rules advance（2026-11-14，本輪）
- 已在原始第 411 段 FS SkillCost Authority 確認固定 MP、百分比 MP、Half MP 並以 `FSSkillCostRules` 實際移植，連動 MENU quote 與 BATTLE debit。任何 HP/Gold/OD/Item/State cost 與非成本標籤仍需實際有效來源查核，默認 FAIL CLOSED；YEZ level modifier 待補。
- 已在原始第 377 段 FS ATB DynamicResistance 確認 Boss 的 direct ComboCore ATB 延遲抗性規則，`FSATBResistance` 實裝 source multipliers、Boss Note/抗性/最低線、穿透與恢復；仍需與全 Tankentai ATB/ComboCore/CharacterCore 時序整合並對原 VX trace。
- Godot 4.7.2 native QA：https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43549022785。P1 seal 仍 NO，資料後套用與原圖缺口最高優先。

## M3 Tankentai Source ATB 1.2c 核心增量（2026-11-14）
- 改用 `FSTankentaiATBCore` 的原版 **60fps integer 0..1000 gauges**，替換舊 `delta*(0.08+AGI/800)` placeholder；ATB/ACT 分離，兩者個別 readiness。來源 #230/#231，正常速度為 `10 × AGI / 全場最高 AGI` 每幀，純整數；特定 Actor01 開場30%、一般10%、原 source 未持武器時開場 ATB 會加倍、先制/偷襲 -50%。
- 戰鬥 Runtime 目前能 `start` 時初始化，`advance_atb` 進位 source frames，等待旗標暫停，透過 `begin_source_atb_charge`/ `finish_source_atb_action` 明確外部 API 切換量表；但**完整行動佇列、遊戲指令流程與實際戰鬥 action execution 的 ATB 強制限制仍未建立**，不能宣稱 ATB 系統全部完成。
- `FSScreen._process` 在 BATTLE 將 delta 導入 source Core，角色/敵人 ATB/ACT label 即時更新，MENU 無背景推進。第 374 段 ComboCore 負延遲與 #377 Boss Resistance 已同步 source integer gauge 及中斷 charge/ready。
- CI source-shaped synthetic 21 原生測試（新核心 + UI）、Python 505 脚本掃描：https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43550617123。
- 下一個最高優先級是 1. 真 VX post-Apply private data 快照與 witness；2. **ACT ready→真正動畫/動作執行→傷害/成本支付→ATB reset** 的完整可重播動作佇列與行動中 pause flags；3. 505 RGSS2 最終覆寫/OD/Break/Cover；4. 6 位主角正式素材/戰鬥動作和 UI 對照。Event Studio 仍長期，不優先擴充。

## M3 玩家端 Source ATB/ACT 行動佇列（2026-11-14 最新）
- **實作**：`FSActionQueue` 將 `FSBattle` 的 Source ATB READY→玩家 Attack/Guard/Skill/Item 指令→ACT source charge→單次執行/依 source recharge 重置，真正套用於 `FSScreen` 的戰鬥按鈕。固定/百分比 MP 成本交給 `FSSkillCostRules` quote；物品走 `FSItemRules`。只有 ACT 結算時才支付 MP／Item，失敗或中斷不扣。選敵/己/技能/物品時以原 #230/#231 wait 預設凍結 ATB。ACT 中斷後防止佇列重放。
- **Godot 4.7.2 自動 QA**：新 `test_fs_atb_action_queue.gd` + 修改老 UI 單體測試；既有 21 + 1 = 22 native tests PASS：https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43551938441。新 Gate 規格 `docs/FS_ATB_ACT_COMMAND_QUEUE_GATE_20261114.md`。
- **未完成**：對 `Game_Enemy` 真 AI 與 action queue 的自動派送、Force/Union/Break/Cover/OD 實際付款與動作連動、傷害最終原版 505 aliases、狀態與敵 AI Turn、原 VX screenshot 測試。標準原始資料庫的 post-Apply 版本與私人圖像未到位；P1 Seal 仍 NO。Event Studio 保持長期。

## M3 敵方 AI/ATB 自動行動子系統（2026-11-14 最新）
- 原版 #211 的 Enhanced Enemy Action roulette（而非 VX stock rating），#406 的特定敵人攻擊分布機率，#210 deterministic test RNG 都已來源比對並保守移植至 `FSEnemyAIDecision` / `FSAIRandom`。特定不完整 AI 事件/Target Priority/#401 Boss runtime context 優先 fail-closed。
- `FSActionQueue` 已包含 actor 和 enemy 兩邊來源形狀的 pending ACT；敵方 ATB Ready 後自動選技能/攻擊、防禦，經 ACT 充能才套用 HP/MP 效果及 source ATB recharge。 `FSBattle.advance_atb` 依每個 60Hz source frame 排程，而不是在 delta 後整批跳過。敵方 scope1 對玩家、scope7 對敵方友軍，原相對技能定義已修復。
- 合成 native 24 組 Godot 4.7.2 PASS：https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43553309465。下一步 #401 Boss AI/召喚群組、#211 composite conditions/turn_count、#372 TargetPriority/Provoke、damage/OD/Break/Cover 原 505 最終有效邏輯；真後套用 11 庫+美術資料到私人 Drive，對應的原 VX Runtime witness。完整 P1 遠未封版。


## M3 Boss Context AI + #372 Target Priority 實際完成（2026-11-14）
- `FSBossContext.gd` 已等值 port #401/#440 15 個 Core 551–565 的動態 AI 行動表（Boss 存在時替換、無 Boss 回原 actions、排序 BossID、已倒下仍視為在場），與 #211 輪盤、#231 ACT/MP/行動佇列相容。
- `FSTargetPriority.gd` 已來源驗證並接線：玩家 UI 只顯示合法敵人；queue request/ACT completion 二次合法性檢查，包含 #372 最高優先 Enemy/State Note、Provoke State14。敵方 random target 含 Provoke 優先與 safe weighted fallback。 `FSSkillCostRules` 白名單允許 source #372 的 ignore-priority tag 不影響 MP quote；未知 Note 繼續 FAIL CLOSED。
- Godot 4.7.2 source-shaped native tests 從 24→26，新增 Boss context / TargetPriority + 先前所有 regressions，CI PASS：https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43554328368。
- **P1 Seal NO**：尚未得到真 FS post-Apply DB/runtime witness；Boss 召喚/天氣/Phase 與完整 505 Alias、EnemyActionPattern Skill83/TargetFix/Threat/Disappear、OD/Break/Cover、原角色動畫/怪物與 UI 美術圖片。後續以真來源資料的 private Drive 匯入優先，並逐項 port Boss special runtime。Event Studio 仍列長期功能。


## M3 Boss Summon Runtime（2026-11-14 最新）
- 已逐字對照 #401 Runtime Boss Provider 與 MasterSetup #440 的 `START_SUMMONS` / `CORE_GROUPS` 原始資料，實裝 `FSBossSummonRuntime.gd` 依 Boss ID 排序的 start guard、Boss510 altar 隨機1、Boss511 500..510 隨機不重複兩名 scale72、Boss520 HP≤70% core557、Boss547 HP≤60% core558×2；按 source `members.size<=8`、敵人 count 包含死亡、per-battle flag once。
- `FSBossSummonRuntime.prepare_summoned` 依 source fixed/database/growth mode 與倍率做最終基本能力、HP/MP，Pokémon 成長型沒有 Runtime Level witness 時 fail closed；`FSBattle` 官方 boot-final DB 驗證後才自動開啟 Boss runtime，且每 source frame 於原 AI/ACT 更新後執行。召出的怪物 `FSTankentaiATBCore.initialize_summoned` 只初始化新人的 ATB，不重設其他人的 gauge，接現有 BossContext/#211 Enemy AI。
- 新增兩個 Godot 4.7.2 native tests + 原有 26 → **28 PASS**：https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43555104501。
- **下一個阻擋**：#401 Boss524 階段 State150/151/152 及 Law140-143、Weather 548–550、530/531 Core shield State77/128/129 的有來源 State effect；#401 `ma_call_ally` sprite／safe coordinates；原 VX post-Apply 11-table private Drive 與 runtime witness；角色/怪物多幀動畫。P1 Seal NO。


## M3 Boss Phase Source-ID Intents + Field Weather（2026-11-14 最新）
- 新 `FSBossPhaseRuntime.gd` 使用原 #401 Lines415–489 與 MasterSetup #440 的逐字一致 PHASE_WEATHER 表實作 524: State150/151/152, 70/35% gates + Law140–143 pending；548–550 的 early/late State 122–127、全域 Field153–158 與55%門檻、先後來源；530/531 在對應 Core 存活時 Shield77、HP≤45 Awakening128，Start/Threshold 後所有 Core 死亡一次 Exposure129。全為**條件與 ID 意圖**，不是效果移植；未驗證原始 State 與天氣數據時 Fail Closed。
- `FSBossSummonRuntime` 已接 Phase intent engine，維持 Source 開場召喚 → Threshold → Phase/Weather/Shield → Core exposure。Boss phase tick 即使 `source_atb_wait` 仍更新；只有 ATB/ACT/敵方排隊在 Wait 模式凍結。
- `FSEnemyAIDecision` 和 `FSActionQueue` 在 Boss 仍有未套用 phase effects 時保護性停止；`FSScreen` BATTLE 狀態可視化待套用 ID 及天氣來源、未實裝效果。新測試 `test_fs_boss_phase_state_intents.gd` 與 `test_fs_boss_weather_intents.gd`，28→30 native QA。
- **下一步**：原 VX final DB + witness 優先，再釐清 524 151→Law140-143 最後 alias、#404 Weather damage/element target type/priority、正式 State77/128/129 effect、OD/Break/Cover；原角色/怪物動畫和 MENU/BATTLE 美術及 VX screenshots。Phase1 Seal NO。


## M3 第404段全域天氣傷害 + 第015段角色攻擊元素（2026-11-14 本輪）
- 原版 FieldWeather #404 (MasterSetup #440)：`FSFieldWeather` 單一 global Field153..158，來源/優先權、ctx ID510→554/555/556，元素＆目標型別 Note、rate clamp25–175，正 HP/MP 傷害、治療/比例傷害豁免；Skill/Item Note 前置合法性及源技能 ACT 結算後才切場域。按 #401 Boss548–550 選出 Field 時，只有 `boot_final_verified` 或合成測試顯式啟用的 Field runtime 才真正套入。Boss 122–127 等階段 State 效果仍 pending。
- `FSBattle.attack/use_skill` 與 `FSActionQueue`／`FSEnemyAIDecision` 已接入全域 Field 授權與正傷倍率，`FSSkillCostRules` 已限縮允許 #404 確認的 Field Note 而非整段未知 Note。真 Godot BATTLE UI 區分「有限 Field 倍率已套用」與「Boss 階段 State 未套用」。
- 來源 #015 `Game_Actor#element_set`：空手[1]、武器 ElementSet union。已接 `FSDatabase.apply_equipment`、`FSBattle.equip`、源 #013 Game_Battler enemy default []，實測動態換裝後天氣元素倍率同步；缺 metadata fail closed。
- 原有30 native + 兩項 Field測試 + 一項 Actor ElementSet = **33/33 Godot4.7.2 native PASS**：https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43557813518。完整規格在 `docs/FS_FIELD_WEATHER_DAMAGE_GATE_20261114.md`；Handoff/FailureLog 同步。
- **下一步**優先解原 VX post-Apply 私有11表 witness + #358類型/ #414 ElementRate 與傷害基數；Law140–143 真 State、77/128/129 護盾；正式角色/怪物 6+ multi-frame Animation 與 MENU/BATTLE screenshot。P1 Seal NO。


## M5→M6 P534：A35 R8 R3 私有場景安全匯入架構（2026-11-16）
- [P534 Handoff](HANDOFF_20261116_A35_BRIDGE_P534.md) / [Failure Log](FAIL_LOG_A35_BRIDGE_P534_20261116.md) / [Godot 4.7.2 native CI PASS #43818163395](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43818163395)。
- 新 SHA256+CRC ZIP 安全 staging、A35 namespace path rewrite、真私人 Ground HASH gate、Godot 主畫面只有來源實際就緒才有苔光村 Preview。Synthetic P532 existing full flow PASS。
- 切記：正式 A35 source staging + native GPU 合併 **NOT RUN**；A35 ART HOLD；世界故事/事件/ACT 真場景接線未完成；11 post-Apply DB / 505 runtime authority 未完成；Phase1 SEAL NO。
- P535：私有臨時原圖 native 匯入與 GPU QA，A35 角色／碰撞／Footpoint/事件/戰鬥接線；不得再以合成 Map999/1000 冒充正式村莊。


## User 2026-11-18 explicit priority override: BATTLE + MENU + original FS UI artwork FIRST
- Completed P535 private source original archive 202 PNG (8,371,041 bytes owner-only Drive ID 1OCeiV5ZZyxBUrZypIxI8UJv2ytHywbnT). Original code archive hash C08EA693... and private source SHA per PNG. No source images public.
- Godot 4.7.2 original UI import gate, source IconSet, six portrait hookups, live HP/MP/ATB battle HUD, native code QA SUCCESS #44134508271. Handoff docs/HANDOFF_20261118_UI_ART_535.md and FailureLog docs/FAIL_LOG_UI_ART_535_20261118.md.
- P536 priority: original private PNG + real Godot native GPU / VX visual 1:1; P537 original full BattleScape, multi-frame 6/12+ actors/monsters and ACT FX; P538 all MENU source artwork and functionality. A35 village/forest integration deferred, not erased. Keep original VX read-only. Phase1 SEAL NO.


## P536 原版 UI 真圖 Godot native 進展（2026-11-18）
- 最新 Handoff: [P536](HANDOFF_20261118_P536_ORIGINAL_UI_NATIVE.md)，[FAILURE](FAIL_LOG_UI_ART_536_20261118.md)。原版 202 PNG/私有 ZIP 真正 staged 進 Godot 4.7.2；原生 Editor Import PASS、真 OpenGL MENU/STATUS/BATTLE × (544x416 / 1088x832) 6/6 PASS，私人 SHA 證據 https://drive.google.com/file/d/17BwXCHAlhAEDZBUyH8fntmhPZiAyBGV5/view 。
- 修正「整張 Gauge sprite atlas」與「STATUS 立繪文字互疊」，source strip 72×6 + Btskin 135×40 live HP/MP/OD，獨立原始 SHA 鎖；代碼完整 CI 83/83 PASS https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44189891079 。
- P537 仍優先原版 BATTLE Stage + 多幀角色/敵人 + 武器/FX；P538 主選單與技能/裝備/物品全美術；A35 真圖事件後排，不得以合成場冒充正式 FS。原 VX compare parity 尚無、ART HOLD、Phase1 SEAL NO。


## P537｜原版 BATTLE 指令圖片正式接入真 ATB（2026-11-18）
- [Handoff](HANDOFF_20261118_P537_BATTLE_ICONS_NATIVE.md) [Failure Log](FAIL_LOG_UI_ART_537_20261118.md)：原源 Battle01/02/03/04 對應 Attack/Skill/Defend/Item，原 54x48 + a 灰版全 source hash locked；真 ATB 未 READY 灰色、READY 彩色，禁止偷跑 ACT；2×2 Grid 讓 544×416 四張都可見。Escape #05 仍需原版 source rule witness，不捏造玩法。
- 真 202 原圖片＋ Godot 4.7.2 隔離 native 6/6 GPU：https://drive.google.com/file/d/1CM3cQRXFT_-9TJm4v0t_Z2qDE58lvXiE/view 。Native / ART SOURCE PASS，正式 Original BattleScape/角色敵人多幀動作/VX pixel-parity HOLD，Phase1 SEAL NO。
- Next P537B actual original battle background, separate A52/A54 character animation Body/Weapon/FX/ACT/Hitstop; P538 main MENU original button/skin composition; A35 forest map after BATTLE/MENU art.


## P537B (2026-11-21): A52 original 12-frame ACTOR01 attack integrated into live Battle UI (source-gated)
- Continue BATTLE visuals first; original MENU second; A35 maps later. Cross-branch pin T-A 072db87, original A52 45° Body/Weapon/FX 256x192×3, F7 t=.630; do not copy ART HOLD RUN weapon placeholder.
- New Godot ACT queue serial-driven actor01 visual presenter / 3-layer rig, source SHA lock / private stage script, native tests, see docs/HANDOFF_20261121_P537B_ACTOR01_BATTLE_VISUAL.md and FAIL_LOG_20261121_P537B_ACTOR01_BATTLE_VISUAL.md.
- Critical hold: cosmetic contact is NOT final gameplay ACT hit-time, no original private GPU image has been captured in this main battle branch yet. Real post-Apply DB and enemy visuals unresolved; Phase1 SEAL NO.


## P537C 2026-11-21 BATTLE original enemy sources and Actor01 presentation cleanup
Priority BATTLE original actor/enemy scene first, then MENU, then A35 map. Source-battler private archive 167 original PNG, owner-only Drive ID `1xd1ZIxLt-xPQ4NKqx3MoRpysdHYBJ1So`, SHA `4d2f629ea643187d2b96999798214c1fdf75a1ec969df1c29561bf7bfa1ee9e3`. Added SHA-gated batch import and native Sprite Stage from exact Enemy.battler_name; source hue unsupported fails closed. A52 F11 now hides rather than freeze. Handoff `docs/HANDOFF_20261121_P537C_BATTLE_ORIGINAL_BATTLERS.md`, FailureLog `docs/FAIL_LOG_20261121_P537C_BATTLE_ORIGINAL_BATTLERS.md`. Native public CI pass is separate from owner-only real GPU. P537C real private OpenGL original actor+enemy screenshot still NOT RUN; A52 visual t=.630 not aligned with gameplay ACT. Phase1 SEAL NO.


## P537D 2026-11-21: 372 genuine original UI/Battlers/A52 PNG imported; native RX6700XT source-pixel GPU proof
- Code P537D dc51665928d0c3a84de31cc8c3b6f227a74abe1b; native Godot 4.7.2 full CI #44872922592 SUCCESS 88/88 steps. Original GPU QA owner-only Drive https://drive.google.com/file/d/1vS5pbWqWcyU7ZlXETv2C-SXAMfTcMsFT/view, 514477 bytes, SHA b6f47468fbca6185f558196f2c0216ce765b02233a132c82ca534c49e4fb374e (shared=false).
- 202 original UI + 167 original Battlers + 3 A52 original attack Body/Weapon/FX staged SHA-verified into G: Google Drive isolated game checkout, native official 4.7.2 Editor Import 372 steps PASS. Source pixels visible in GPU RX6700XT OpenGL 3.3 544/1088 captures, enemy pixel delta 2506/10050 and A52 F7 pixel delta 618/2472. 6/6 real GPU screenshots with 2 failed-first-pass images recorded.
- Found visual FALSE-POSITIVE: before fix the screen FSScreen zero width left actor and Battlers OFF VIEWPORT even though all capture images existed. Corrected Control.PRESET_FULL_RECT, overlap and 2x2 command area; capture now requires original source pixel visibility ROI and physical viewport bounds.
- See docs/HANDOFF_20261121_P537D_PRIVATE_REAL_GPU.md and docs/FAIL_LOG_20261121_P537D_NATIVE_UI_ART.md. Full BattleScape original background, native 11 post-Apply/505 alias enemy authority, actual VX scene parity, ACT 0.630 damage/hitstop contact still ART HOLD. NEXT P537E source-verified BattleScape original scene, then P538 MENU original skins, A35 later.


## P539 2026-11-22｜全量原始程式整合策略（最新使用者指令）
立即停止逐按鈕猜配置。FS 一次讀取 Scripts.rvdata 全 505 Ruby 段（包含 load order）和 11 原始 .rvdata，生成 owner-only ZIP + 機器可查的 section/def/alias/resource 全源索引。程式 GitHub `tools/fs_unified_source_bridge.py` 和 Godot `scripts/source/FSUnifiedSourceRegistry.gd`、完整交接 `docs/HANDOFF_20261122_P539_UNIFIED_SOURCE.md`。原始 Ruby 和資料不公開，只存 G: Google Drive。重要發現：原 #268 5 個縱向 Battle01..05 命令，現有 Godot 2x2 只是臨時過渡，不是原版 UI；#264 BattleScape 有 map/area/variable/troop 層優先。後續以完整原版整個 BATTLE Scene/Window 及 MENU 批次施工，禁止再碎片化。但 Ruby 本身不是 Godot 可執行程式，純 source inventory NOT gameplay parity，ART HOLD / Phase1 NO。


## P539 source complete intakes FINISHED, source execution remains HOLD (2026-11-22)
Private 505 original Ruby sections/11 RVData unified ZIP 5,342,988 bytes owner-only Drive https://drive.google.com/file/d/1wYjxv4CZ7NUv2axlrjWqNplT_tA6Rug0/view, SHA a7089ef45dfe4c92260932ffc4c0f21934b43ac0b296eb8ca53c828e4af2e106. Source index 9,724 def / 1,604 alias positions; native actual 505 index Godot 4.7.2 PASS, public full CI #44986992752 90/90 success. Next: batch port full BATTLE Scene/Windows/SBS/ATB/ACT/BattleScape with effective alias evidence, then MENU full source, NOT 2x2 per-button one-off. Docs HANDOFF_20261122_P539_UNIFIED_SOURCE.md and FAIL_LOG_20261122_P539_UNIFIED_SOURCE.md. Indexed source is not executable Ruby / gameplay parity. ART HOLD Phase1 NO.


## P539B 2026-11-22 whole-original Battle scene+five commands+source Scape native GPU
Actual FS 505 RGSS2 source #232/#264/#268/#312 combined as one Godot 4.7.2 scene, authentic five 54x48 staggered icons and original z49 additive ffog / z51 new_back01 Troop12 scape and source actor A52/monster; original source troop default and last-wins duplicate troop36 tested. 7 true source backdrop assets SHA-staged owner-only Drive https://drive.google.com/file/d/1p9DvILBhvYh9acKk-7FIWu5f3vkj3xn9/view; missing Bridge and BlueSky source ART HOLD. Private AMD RX6700XT Godot4.7.2 OpenGL source genuine 544×416 /1088×832 6/6 GPU screenshots, physical image pixel witness 88826/354871; old overlapping Godot debug prototype bars removed after direct visual QA. Private final ZIP https://drive.google.com/file/d/1s62sACD_IN5SPo9hclITqEYYyXngl4pR/view SHA 8cb132f507898206040530dde6ee028b04b80f6eb331af05da4c552a51991836. Public full native CI #44988257528 92/92 success. Full Handoff docs/HANDOFF_20261122_P539B_ORIGINAL_FULL_BATTLE_SCENE.md and Failure Log docs/FAIL_LOG_20261122_P539B_FULL_BATTLE_SCENE.md. Completed source BATTLE layout/backdrop renderer, not whole Ruby runtime. Next P539C effective source battle command seals and original HUD full Scene, boot-final enemy/Troop and actual hit time; P538 full MENU next. ART HOLD Phase1 NO.


## P539C 2026-11-22 原 505 #312 State-note Seal + #269 source Btskin HUD (latest)
- Exact extracted original Ruby #312 four Japanese seal tags and Game_BattleAction.valid?/Game_Battler/Window/Scene alias implemented in FSOriginalActionSeal shared by FSBattle, FSActionQueue and FSScreen five authentic original commands plus fallback, with dual-guard request/ACT-time and actor/enemy. Source #269 original 135x40 Btskin_main, 77x20 HP/MP, 120x48 digit atlases, 135x135 HUD_hero portrait rendered at true original x=9+139*partyIndex,y371, source portrait y249 (only first <=3 regular actor ids).
- Native source comparison found overwritten FSScreen UI bool version after HUD integration; fixed 71f06986. Reconciled old synthetic Tankentai state-less fixtures with real stock states=[], and kept detached formula tests separate from live source battle authority.
- Native Godot 4.7.2 official full CI #44992946795 93/93 PASS. Private AMD RX6700XT OpenGL actual original source GPU 544/1088 6/6, HUD source pixel diff13060/52244, backdrop92621/370373, authentic art with true SHA. Owner-only QA https://drive.google.com/file/d/1vbgi88r3hnnXyhSXAjQxDAVet3NGQxac/view, 3163664 bytes SHA e3c6ac681b16b9b7f41427564e1c1626d9e53074a38b3fa0be17cd6c56ca4c91.
- Handoff docs/HANDOFF_20261122_P539C_SOURCE_STATE_SEAL_AND_HUD.md, Fail docs/FAIL_LOG_20261122_P539C_STATE_SEAL_HUD_COMPARE.md. Extra Actor.id>=7, number rolling/state icons, 505 alias+boot-final data and ACT timing remain ART HOLD/Phase1 NO. Next coherent P539D state HUD #381/#462 + AI+boot-final witnesses, then P538 MENU; A35 later.


## P539D original 180° opposite-facing Actor01 + source #381 StateHUD / #462 label semantics 2026-11-22
Source A52 Actor01 Body+Weapon+FX together horizontal mirrored (not upside-down): rig.scale=(-1,1). From original Scripts.rvdata #381 exact 4x20 source State iconset (alpha180), priorities/hide/forced/overflow; #462 source SHOW_HELP_STATE_ICONS=false and enemy name is target-help, not permanent sprite caption. Real visual compare found icon on monster face (image centre instead of source feet baseline), and overlapping old enemy name; both corrected and original before failure source GPU images preserved. Native full Godot4.7.2 CI #44994999882 SUCCESS 94/94, real owner RX6700XT source native 544x416 and 1088x832 12/12 screenshot PASS; A52 before/after changed pixels 792/3172, #381 source Iconset 336/1346, original HUD269 13060/52244. Owner-private G Drive https://drive.google.com/drive/folders/1PgNHwuFDxVAcbBjJCzAq9Lxg7Hk-7d27 source QA ZIP 6405355 bytes SHA 01effe01107f516e955fa1f4c4008e06625a06e9969540b62644bb228293773d ZIP CRC PASS, 36 entries. Full Handoff docs/HANDOFF_20261122_P539D_A52_OPPOSITE_FACING_AND_STATE_HUD381.md; failure docs/FAIL_LOG_20261122_P539D_FACING_STATE_POSITION_COMPARE.md. Actual #462 target helper detail, #381 stack/turn badge, #269 digit roll, effective 505/11 boot-final original, all RUN motion still HOLD. Next P539E complete original target help and state details then P538 original MENU. ART HOLD, Phase1 NO.


## P539E Original #462 target Help + #381 Stack/Turns, source #269 digits 2026-11-22
Actual 505 Ruby source: #269 Sprite_strNumbers.update instantly swaps four digit atlas slices (NO easing), #381 MAX_STACK/current stack/remaining turns/detail per original State notes and badges, #462 target-help is Name + only verified Albert_CaptureRate, no duplicated State icon (SHOW_HELP_STATE_ICONS=false). Godot new FSBattleSourceTargetHelp462, extended FSBattleSourceStateHUD381, FSScreen real enemy/ally target hover and actual #372 guarded button selection -> #312 ACT queue. Pixel compare caught former developer tabs/State details overlapping original monster; fixed source title top/State detail below enemy/buttons right while keeping actionable controls. First synthetic State notes without target_priority correctly rejected by source #372 (fixed test fixture not game authority). Owner true RadeonRX6700XT 544+1088 source GPU 14/14, original #462 ROI changed 40548/162295 pixels. Official full Godot472 CI #44996910206 95/95 PASS. Private evidence ZIP https://drive.google.com/file/d/1znQPh_XiT64zp6EmfW9GEk-4b2YJYzZb/view 6372214 bytes SHA e1d855f9b0900b1aa88a9ceb569aa4d74a9ef2417b77f05f271ef436738dbce3, 30 entries CRC PASS owner-only. Handoff docs/HANDOFF_20261122_P539E_ORIGINAL_TARGET_HELP_AND_STATE_DETAIL.md, Failure docs/FAIL_LOG_20261122_P539E_TARGET_HELP_VISUAL_COMPARE.md. Full source capture/element/detail special semantics, 11 boot-final DB and 505 effective aliases still ART HOLD Phase1 NO. Next P539F source special UI/DB, then full P538 MENU.


## P539F 2026-11-22 genuine source #381 seven special InfoRows + live battle target data integrity
Original #381 seven information rows source order ManaShield/ATBResistance/IvyStoredCover/Break/StateResist/RobotProtocol/TargetPriority and InfoRows BEFORE StateDetails. Ported new FSOriginalBattleInfo381.gd with strict original source/current provider verification; FSBattleSourceTargetHelp462 live refresh, 4..6 row detail moves right outside original #269 portrait, FSScreen polls source target window every12 frames. **CRITICAL** original prior UI active_target.clear() deleted reference-linked real Game_Battler Dictionary on selection refresh or switching. Fixed active_target={} and tests assert both enemy dictionaries survive. No extra fake values for missing original 505 modules. Native Godot4.7.2 official CI #44998957776 SUCCESS 96/96; owner RadeonRX6700XT 544x416+1088x832 original GPU each8/8, 381 extra info physical delta 33712/133517. Owner-private QA G Drive https://drive.google.com/drive/folders/1tWSHFtaIoPsohfL6pavJVCSCHnqACLRk ZIP FS_P539F_ORIGINAL_381_SPECIAL_INFO_BOOT_RAW_SOURCE_PRIVATE_QA_20261122.zip bytes7189128 SHA 2f97554ac38a4c12c0e433d4c7489feabf13a37e221a9afd016a829dc6176237, CRC PASS37entries. Original owner Drive raw11 Data RVData +505 Ruby SHA manifest extracted, but post FS_DB_AUTOSET.apply_all runtime witness still NOT PRESENT; original E FS project path presently not mounted. Preserve FSDatabase fail-closed source authority. Handoff docs/HANDOFF_20261122_P539F_ORIGINAL_EXTRA_INFO_SOURCE_BOOT_AUDIT.md and Failure docs/FAIL_LOG_20261122_P539F_BATTLER_REFERENCE_AND_INFO.md. Next major unit: P538 FULL original MENU, not more HUD microsteps; separate postApply witness gating. Overall ART HOLD Phase1 SEAL NO.

P539F 完整原版來源 QA ZIP 已以 Google Drive provider readback 確認只有 owner 權限（shared=false）：https://drive.google.com/file/d/1yfdT-Ra63t2fIl3U2LNULQr7Rh8d6Jha/view，7,189,128 bytes，SHA256 2f97554ac38a4c12c0e433d4c7489feabf13a37e221a9afd016a829dc6176237，ZIP CRC PASS 37 entries。不得將 private 原圖上傳 GitHub。

## 2026-11-23 P538A MENU source integration / next P538B
P539F next-unit text above is now HISTORICAL: P538A was actually built on feature/fs-godot-phase1, not merely planned. 8 source Menu01..08 icons 50×20 and SHA-locked source MenuBack_b, five real existing menu routes, three disabled unsupported routes, original 60x20 subpage tabs. M1 source candidate, M2 14 source original Godot 4.7.2 OpenGL Mesa llvmpipe screens 544/1088, M3 fixed CI native P537C battle regression and second actor synthetic fixture indexing, M4 original source portraits Joey/Mia separately. Official CI #45101720647 completed success 97/97, private Drive owner-only original 14 frame proof https://drive.google.com/file/d/19x7wqwVbXInCR2OWWbbx9OGkafXrJ05B/view SHA c3fdeff4d3558231a7c6217ebbd1e95a05ffdc814a58f262803c71a519050001.
P538B next: original full STATUS/SKILLS/ITEMS/EQUIP/FORMATION subpage composition with approved source art/UI windows, original live function coupling, both resolutions and second actor. Current developer chrome remains, no VX 1:1 same-state or owner AMD GPU P538A verified. Missing final 11 postApply DB and 505 effective alias runtime HOLD; Phase1 SEAL NO. See CURRENT_HANDOFF.md and HANDOFF_20261123_P538A_ORIGINAL_MENU_NATIVE.md.


## P538B｜2026-11-23 原始 MENU 全頁功能候選與 PRIVATE 視覺 Gate

- **已實際施工（M1）**：原版 SHA 原圖入口 + `FSOriginalMenuPage` 五個完整功能頁：Status / Skills / Items / Equip / Formation，附物品選對象、裝備候選/換裝和隊伍交換；資料全部透過既有 `FSMenuModel`，不得重寫 ATB/ACT/裝備/背包，沒有私人圖片入公開 Repo。
- **Godot4.7.2 native（M2）**：初版完整 CI [45114810650](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45114810650) 98/98 SUCCESS（包括 P538B 和戰鬥、劇情回歸）；加強的第二 synthetic Actor2 Lv7 / 544與1088測試已由 [最終 native CI #45115275149](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45115275149) 98/98 SUCCESS 驗證；PRIVATE 原始圖截圖另行 HOLD。
- **M3**：本輪第一套完整原生回歸未觀測到 FAIL，不編造修復。既有 P538A 戰鬥 debug chrome 不可退化。
- **M4**：兩位不同 ID/等級的 synthetic 角色資料與原圖喬伊／米亞 identity，私有源圖的 10 張/解析度 capture harness 已編寫，但尚未 stage 真實 PRIVATE UI ZIP，故 SOURCE VISUAL QA 不是 PASS。
- **Gates**：MENU 行為候選≠VX 原始同狀態 parity；私人原圖 native 544/1088、WindowSkin、原 VX 比圖、使用者 Art Gate，以及原11 postApply資料/505 effective alias 未完成，**ART HOLD / Phase1 SEAL NO**。Quest/Save/System及未驗證 sub tabs 保持 disabled。完整交接 [P538B Handoff](HANDOFF_20261123_P538B_ORIGINAL_MENU_PAGES.md)，[Failure Log](FAIL_LOG_20261123_P538B_ORIGINAL_MENU_PAGES.md)。
- **後續完整施工**：在核准的隔離私有雲端一次性執行 20 張 source UI 圖／對照＋真來源第二角色與操作，修正原版子頁 WindowSkin 與窗格定位，再由私人 Drive WRITE→READBACK→SHA 保存，並獨立解決 VX postApply DB witness。不得以漂亮的 synthetic 畫面代替原版 Gate。


## P538C｜2026-11-23 真正來源原始頁窗格校正、可見拒絕與原生 QA
- 來源優先：下載 Owner-only 202 原始 PNG ZIP 到 ChatGPT 隔離雲端環境，SHA/CRC PASS；從真 `MenuBack_status_a/skill/item/equip/party` 找到 P538B 統一白色 Panel 蓋住五頁內建原圖窗格的錯誤。
- **M1 實作**：`FSOriginalMenuPage` 使用每頁不同的來源 544×416 配置，透明窗格取代不當白 Panel；Current Squad 三槽／Reserve Squad 分層，四角色隊伍交換；MENU 隱藏 developer log 導致拒絕裝備或道具操作不顯示的問題已修。原有 FSMenuModel/FSBattle 不重寫。
- **M2 native 完整 PASS**：Godot 4.7.2 官方 Actions [#45129180313](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45129180313) **99/99 steps SUCCESS**，新 `test_fs_p538c_source_window_geometry.gd` 以 synthetic single-colour textures 實證五頁窗格、544／1088 控制元件、四角色操作及 item debit 禁止，所有既有戰鬥／ATB／ACT／地圖回歸 PASS。此 fixture **不是來源原 PNG native 影像**。
- **M3**：#45128951564 native FAIL（SceneTree 動態改 viewport 卻未同步 FSScreen Control 尺寸），#45129180313 FIX PASS，實際修正 commit `074c8e2`；另外真 source ART 錯位 commit `db31135`，顯示拒絕 commit `1d2d8a0`。
- **M4 私人 Drive 真來源**：5 張原圖 544×416 + 10 張 60×20 來源 tabs Verified；5×544 原圖框選示意、5×1088 離線最近鄰放大及 manifest/FAIL (12 件) 保存 [P538C PRIVATE source layout ZIP](https://drive.google.com/file/d/13EQhnMU8iYBDsjMEdO3A9Mp0iFjwb0SE/view)，723,848 bytes、SHA256 `78a0313020038deeb90e5a7978753b7a37d40616f6d3a42f29d42486fa04216d`、Drive 已回讀、owner-only shared=false。M4 第二 native fixtures 喬伊/米亞/艾薇/泰勒與 current-reserve swap PASS。
- **明示 Gate**：本輪私人真 source PNG **Godot viewport capture NOT RUN**（缺合法同機 private art+Godot executable）；原 VX 同狀態、11 postApply、505 effective runtime、用戶原畫核准 **HOLD**，Phase1 SEAL NO。離線原圖框選不替代 Godot source-native screenshot。
- 後續完整單位 P538D：在獲授權的隔離 private Godot 環境實拍原始 202 原圖 544／1088 10 頁，按原版 VX 來源畫面對照和修正；私人 Drive 寫入／回讀 SHA。詳見 [P538C Handoff](HANDOFF_20261123_P538C_SOURCE_UI_GEOMETRY.md)、[Failure Log](FAIL_LOG_20261123_P538C_SOURCE_UI_GEOMETRY.md)。


## P538D｜2026-11-24 原版 Current/Reserve 編隊槽位與 source-original 私人雙樣本
- **實際 M1**：重開 owner-only 202 UI PNG 原版 `MenuBack_party.png`：P538C 已通過合成 Layout CI，但原版三個高直 `Current Squad` 槽位 x~75..220,y~69..142 被通用低矮 Button x66..205,y103 切過，`Reserve Squad` 標題區 y328..360 被從 y333 開始的選單侵入。現改 `FSOriginalMenuPage.gd` 使用三個來源肖像 TextureButton 41x62, x77/127/177,y73；Reserve 水平列表 y362 起。角色名對應 true original 252x312 PNG，無 SHA 認證圖片不可假冒。另修正 `FSScreen` 裝備更換拒絕 log 在 configure 重建後被消滅的真 bug。
- **M2 source-only engine PASS**：官方 pinned Godot4.7.2 full [Actions #45285924622](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45285924622)，code head `ea4975a9159d38b636b1df9ce8256b9a5781cfed`，**100/100 workflow steps SUCCESS**。新增 P538D test 實際按 TextureButton + Reserve button 交換 6 人並更新 world party `[6,2,3,4,5,1]`，二種來源幾何 544/1088、拒絕換裝且文字仍顯示；保留先前 Battle/ACT/ATB/Quest/Event/Map 回歸。這是 **合成尺寸素材 native 功能測試，不是 original-source PNG native GPU 驗收**。
- **M3 真問題**：來源 PNG 原槽位 UI 遮擋修正 `c193b91a`；拒絕換裝後 Label 消失修正 `57d8cdd`；離線 PIL RGBA-mask QA false-positive 修成精確 RGB 外槽遮罩。新 native P538D first full run PASS，沒有捏造引擎 Fail→Fix。
- **M4 PRIVATE 原版 QA**：六名原版角色源肖像、兩套不同上場組合，544 source-original 框位合成與 1088 離線倍增，外槽像素 **0 變動**，真正 PNG SHA/manifest，Owner-only [P538D private audit ZIP](https://drive.google.com/file/d/1MIPFJVDgHMcI3DILgGIgvIaOSkoACblQ/view)，**421,290 bytes** SHA `119d7bf30e5e1df4f68f2cb66dd8964a33f9eeb51da26005ba694d0d48e1ae8c`，上傳後真下載 SHA+CRC readback，shared=false。**這是離線 source art geometry，不是 engine screenshot。**
- **PRIVATE Godot native 入口備妥但未執行**：新 `capture_fs_p538d_private.gd` (Linux-only/private opt-in/來源 SHA/預存在私人輸出資料夾/no overwrite)，可分別 544/1088 產生 11 張真 Godot 截圖，各 6 人編隊與對象/裝備/角色二號。隔離執行環境因無 Godot executable 及 Github release DNS blocked 而沒有把本輪私人 UI 圖與引擎合併執行；Github public CI 不可引入 private 原 PNG 以繞 Gate。**ART HOLD**。
- **接下來完整單位 P538E**：合法 PRIVATE 官方 Godot 4.7.2 native 22 張原圖實拍+source VX same-state 1:1、Skin/font、ID/MENU 實際呼叫+owner SHA readback；並行 11 PostApply 原版 FS DB 505 effective runtime 樣本。VX Source Art/VX source numeric/user RX GPU/FULL migration Phase1 SEAL **仍 NO**。詳 [P538D Handoff](HANDOFF_20261124_P538D_SOURCE_PARTY_SLOTS.md) 及 [P538D Failure Log](FAIL_LOG_20261124_P538D_SOURCE_PARTY_SLOTS.md)。


## P538E｜2026-11-24 真正 202 原 PNG 於 Godot 4.7.2 OpenGL 雙尺寸渲染修正
- **實際取回 Godot 官方引擎而非假裝不可使用：** 從最新公用 GitHub Actions #45285924622 artifacts `14872195477` (official Godot4.7.2 executable) + `14872580349` (full project source)，經 GitHub Connector 真正下載至隔離 Linux，版本 `4.7.2.stable.official.ed1daf0bf`。私人原版 UI ZIP SHA c08ea693... 真從 owner Drive 解包，`stage_private_ui_535.py` 202 PNG 正式 Godot import PASS；隔離 OpenGL Mesa llvmpipe 4.5/Xvfb 把真正原圖編成 native frame，**首次 R0 11×544+11×1088 成功，修正後 R1 再 22 張成功**。
- **M1 真圖片抓到的 BUG**：STATUS 深字黑底（R0 明亮數值像素 0）；技能頁肖像壓原版 Description（R0 覆蓋來源像素 1,358）；中文字標題 flex column 折行、QA 訊息貼在來源底框。修正 `FSOriginalMenuPage.gd` commit `f03bc2770a8d0a834bb926c66dede8be77ab342d`，status 改高對比白字、heading no-wrap 分離 back/source tabs、source肖像下緣避開 Description、QA 訊息位於上方。
- **M2**：用真正原生引擎重拍 R1 得 STATUS 明亮字 **706**、SKILLS Description 遭覆蓋 **0**；新增可永久維護的 source-only `test_fs_p538e_original_ui_visual_regressions.gd`（合成尺寸貼圖驗幾何，不放私人 PNG）並併入 GitHub 官方 Godot4.7.2 [**CI #45301488209**](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45301488209) **101/101 workflow steps SUCCESS**。前一輪 Godot 主線戰鬥與地圖/事件/ATB/ACT 測試全部保留。
- **M3**：記錄原版 artwork R0 真畫面錯誤及 R1 像素量測改善，不虛構原生 parser/runtime FAIL。
- **M4 真正 PRIVATE Native QA**：owner-only [**P538E 44 Godot screenshots/51-file original source QA ZIP**](https://drive.google.com/file/d/16wtWALH4oJvrPIfxfAoYKGwoDwnK0GLp/view)，5,327,631 bytes、SHA256 `f64212d6140e56c4eda6ea90409d454745b439bda4f96dddd448ab4af055b9ca`、CRC PASS、已實際 Google Drive 上傳/重下載 SHA readback、`shared=false`。44 張是 22 R0+22 R1 原版真圖片在 Godot viewport 捕獲，5 張雙圖比較 PNG 及 manifest/HOLD；不是離線拼成假的 native。
- **剩餘 Gate**：本次 GPU 為隔離雲端 Mesa llvmpipe，**不是 user RX6700XT**；HP/MP/Actor fixture synthetic，**原 VX live same-state 1:1、原字型/WindowSkin、boot-final FS_DB_AUTOSET.apply_all 11 tables/505 RGSS2 aliases、最後使用者 ART approval** 繼續 HOLD。Quest/Save/System/未授權行為 fail closed；**Phase1 SEAL NO**。
- **Next P538F whole engineering unit**：以已存在 44 real native 原圖作正式 source parity baseline，優先獲取 read-only VX 同狀態 screenshot 及 original 11-table postApply effective witness，再接回 Godot 真正事件/選單/資料通路。詳 [P538E Handoff](HANDOFF_20261124_P538E_TRUE_PRIVATE_NATIVE_UI.md) 與 [P538E FailureLog](FAIL_LOG_20261124_P538E_TRUE_PRIVATE_NATIVE_UI.md)。新規以使用者 Godot 正式引擎取代歷史 FS skill 中 VX 主要引擎說法。


## P538F｜2026-11-24 真 VX boot-final 11 表語意防線與雙驗證器
- **正式入口現況：** `FSDatabase.load_all` 已要求全部 11 張 post-`FS_DB_AUTOSET.apply_all` JSON、檔案 SHA、原 VX Runtime Witness SHA、stage、505 段 script/22 MasterSetup metadata、start party/表筆數；但既有交叉引用驗證不足，曾可用重新哈希且**同筆數**的壞技能/壞職業蒙混。所有來源與 M2 人工樣本必須區分，不能讓合成測試代替 VX 真 boot。
- **M1 代碼 `51f2acbc`：** 新 `FSDatabase.validate_runtime_table_integrity`，整合進 `load_all` reject path。檢 11 張 source 記錄 index/null 與 id、Actors class FK、6×levels RPG::Table int16、System party Actors/唯一、Troop→Enemy、Class learning→Skill ID。錯誤從載入源頭封鎖，不自動更正來源資料。
- **M2 Godot native `b9c7895e`**：source-shaped 11-table valid + **12 個反例**，刻意示範舊 witness counts+party 對 class 999 仍 PASS、新資料完整性 FAIL；GitHub pinned Godot4.7.2 full [CI #45309636925](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45309636925) **102/102 workflow steps SUCCESS**，保留全部原先 BATTLE/ATB/ACT/Map/Event/原圖 UI smoke。原版 505 scripts 的有效 alias NOT proven。
- **M4 independent Python `9086939a`：** `verify_boot_final_bundle.py` 在原驗每個 SHA、實際 JSON、Actor Table/職業、Troop Enemy 外，增 source arrays index0 必 null、初始 party 不重複、Class.learned Skill 必存在。特別自測「class 指向不存在的 Skill，重新算 SHA」仍擋下，2026-11-24 102-step CI 的 Python preflight SUCCESS。
- **真來源判定：** owner Drive [P539F RAW authority](https://drive.google.com/file/d/1Ot7NnCqtJ2ZsRIM3Sqxnf2yJyU43-kzH/view) 記錄 `postApplyRuntimeVerified=false`、`originalVXProjectEPathMounted=false`；這 11 張確實是 **RAW RVData**，不是完成 MasterSetup/DB_AUTOSET 的實際 `$data_*`。所以**本輪只是安全驗證器與反例通過，並未完成原 VX 正式數值匯入或有效 alias 對照**。
- **HOLD / P538G**：在符合 Global Cloud-only/最少授權的原版 VX 真運行環境，取得 boot 時 `apply_all` 之後、事件開始前 11 張真資料表、原始 runtime Witness 與 505 effective alias 样本；保存在 owner-only Drive，SHA+readback，再以 P538F Python/Godot 雙驗證器與真表跑主角/怪物、技能、裝備、ATB/ACT 全流程。若 VX read-only 原生 runtime 未取得授權，**不接觸使用者 PC、不以 RAW 偽造 POST-APPLY**；繼續 Godot 主線來源已證實功能，但保持 Phase1 Seal NO。
- 詳 [P538F Handoff](HANDOFF_20261124_P538F_BOOT_FINAL_SEMANTIC_INTEGRITY.md) / [Failure Log](FAIL_LOG_20261124_P538F_BOOT_FINAL_SEMANTIC_INTEGRITY.md)；一切程式碼與 handoff 只提交主線 GitHub、私有素材保持 owner Drive；T-A/T-B/T-C 分支沒有更動。
