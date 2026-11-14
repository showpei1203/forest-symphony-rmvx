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
