# Flow V4.4 ART-FIRST CURRENT_HANDOFF — 2026-11-26

## 2026-11-26 09:25｜最新使用者更正：地圖／戰鬥共用 Sprite 不變
[現行相容性硬規則](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/docs/research/FS_SHARED_MAP_BATTLE_SPRITE_COMPATIBILITY_20261126.md)：禁止自行提高全局素材解析度、像素密度、角色尺寸或切換成新版高細節畫風；撤銷 128px 級優先提案。高解析母圖只能是暫時姿勢參考，若無法回到原角色/地圖美術基準則淘汰。保留已核准 A62 原圖、V3 64px 戰鬥素材契約（不是所有地圖圖格尺寸）、既有地圖及戰鬥共用 Sprite，原有足點/遮擋/站位與紙娃娃分層不變。ACTOR01 先修不合格圖；ACTOR02 米亞用原角色風格和尺度建立母圖，不要求整套資產重製。新增動作可使用既有可變幀契約，不分裂成兩組角色素材。先原地圖+戰鬥實際尺度美術驗收再整合。全局規格變更必須事先得到使用者明確核准。這次只更新規範，無新圖、付費、引擎或 PC 改動。先前高解析新母圖均概念候選，不能當核准素材。


## Latest owner priority: qualified character art
Stop extra runtime work. Complete ACTOR01 actual art, begin ACTOR02 plan. Current actual 40-frame review and correction attempt failures; DODGE F3/F4 and DAMAGE F2/F3 HOLD. ACTOR02 confirmed 米亞 (Mia), actor 5 is Ivy; original actor2 image not recovered. [Art closeout and ACTOR02 source plan](../flow_motion_factory/ART_FIRST_ACTOR01_ACTOR02_20261126.md) is current next unit. No new approved art, no engine change. Prior V4.3 test evidence unchanged. Do not treat infographic/AI-generated concept as source or completion.
本節取代下方舊 gate 狀態；原始 V3 不變，禁止長劍，DODGE 向後跳且朝向不變。

## V4.3 — FSScreen opt-in presentation integrated; native synthetic and REAL_V3 PASS
- Integration branch feat/fs-flow-v4-outcomes-20261126, tested commit 591a146efd6a2624d8551384a905e495f70872ed. Changes: FSFlowOutcomePresenter, FSFlowBattlePresentation, FSFlowMotionBody, FSScreen opt-in, actual UI test.
- Source ACTOR01 unique party slot; immutable settled outcome serial gate; ATTACK/CAST on source; DAMAGE on actual recipient positive HP/shield MP; DODGE only enemy EVADE with real enemy-view anchor; MISS no reaction; no stale result polling. Fixed left-facing mirrored parent, local inverse transform to world away vector; max 24px; cancel/reset on clip end, death, menu, battle end, actor identity/slot change. No source weapon/FX addition, no battle rule changes.
- Default art unchanged; explicit --flow-v3-preview only, exact SHA pins for five V3 manifests transitively verify all files, no synthetic fallback. Private files res://motions/<action>/ staged only in isolated project. No automatic source installation. If preview enabled, it suppresses legacy A52; no true idle/death animation, lethal battle finish cancels visual immediately, overlapping action replaces prior animation. RUN loaded but not bound to a real movement event. Only ACTOR01 render, not all actors/enemies.
- First CI 45711900942 failed on enemy damage fixture: no-critical enemy used extra CRIT RNG, causing rejected variance. Corrected test only, commit 9c01291caf57f58245601a312014e1731c64dc3d; REAL_V3 12-case replay passed. Latest test adds actual queued ACT and pinned private loader. CI 45712185904 SUCCESS, 5 suites (15 UI check marker, outcome 11, cover 3, existing accuracy and Ivy Cover). Real private replay on exact same commit, official engine 4.7.2.stable.official.ed1daf0bf, import + test exit 0, FLOW_V4_UI_PASS cases=15 scope=REAL_V3. Source archive SHA unchanged. Real test enemy art is synthetic texture and DB source-shaped fixture; no claim of original DB parity/GPU/complete real-game visual acceptance.
- Evidence: https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45712185904 ; transport artifact 15067981774 sha256 70f4e8985a9577eec660d01f47ed74df49a262139f9125869d00dee2113dd09c (tracked source only, 1 day); real log SHA 2f676f69642d389c4993f1aa70a0a75e5444aa7b28278dc08072c16f289cf052; import SHA 8bf53e94a4f0d0298e868db8fbe65e751231124675ae376ae7a3123871c3187c. Raw logs not persisted to Drive. 45 raw PNG export warnings plus root-run warning; export still HOLD.
- Next: establish exact source export-safe resource path with actual pack/native replay; real movement lifecycle for RUN, accepted idle/death sources and battle finishing/overlap presentation policy; GPU visual review and user ART, full Phase1 regression and independent EGM before merge. V3 pose correction still HOLD. No generation, paid tools, owner PC access, Phase1 or original art modification.

## V4.2 戰鬥事件 producer：native PASS，UI 尚未接入
- 獨立整合分支 feat/fs-flow-v4-outcomes-20261126，基底 Phase1 bc88b10d37d4e3a9816cdfa6932e7aaefaf33666，commit b0affe9f719c53d1a3da4c818a66787af5631037；正式主線未變更。
- FSBattle 新增 target_outcome_resolved；只在既有 attack/use_skill 成功結算路徑發出，命中/落空/迴避明確區分，包含特殊 141/145 已結算分支；選定與實際承傷者分開，Ivy Cover 用 transferred.guard；Dictionary identity/陣營/slot 不依 DB ID；serial 單調、事件唯讀純 scalar snapshot，不暴露戰鬥 Dictionary，不改傷害/MP/ATB/ACT。
- Official Godot 4.7.2 CI 45711247503 SUCCESS：https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45711247503 。兩個新測試 marker FLOW_V4_OUTCOME_PASS cases=11 events=7；FLOW_V4_COVER_OUTCOME_PASS cases=3。既有 test_fs_battle_accuracy_205 與 test_fs_ivy_cover_native_522 同時 PASS。測試含重複 DB ID 的兩個目標、UI changed refresh 無重發、invalid RNG/拒絕技能無事件、已付 MP miss/evade、HP hit、死亡事件先於 finished、護衛真實承傷與 miss 不轉移。不是 AOE 新機制，未做完整 Phase1 全套回歸；技能護衛/141/145 事件自身的獨立新測試尚缺。
- 下一步優先完成 FSScreen/renderer subscriber：一次性 serial gate、真實 slot 綁定、HIT/EVADE/MISS 映射、取消/死亡/finished cleanup、收尾復位；不得讀舊 fs_last_action_result 判定新動作，不以動畫驅動戰鬥數值。之後 native 真圖戰鬥 replay、GPU/ART、export 與完整 source regression；無 merge 授權。
- 整體 gameplay / UI hookup 仍 HOLD，producer subset PASS；不可把新事件當成實際整合完成。

## V4.1 動畫引擎實際增量
- V4 原 CI 45709676853 取消：Godot 原生 Animation 類別名稱衝突，編譯錯誤後測試卡住。修正 AnimationSprite alias、45 秒 timeout、CI 錯誤掃描；commit 955a42ca48623d30e7bb993d304aacc8a5e16559，native synthetic 45710662960 SUCCESS。
- 6f3d39c143f78ac4e2ee7d7f6e337b1201a3f118 再加強 shell fail-closed 判定。最新 synthetic 45710784540 SUCCESS，public-only engine/source transport 45710785860 SUCCESS。短期 artifact 僅原本公開 source 與官方引擎，無私有圖；1 天保留。環境不能直接連 github.com，故改用 connector transport，未使用使用者 PC。
- 私有 V3 ZIP 重新由 Drive 取得，SHA/CRC/112 檔、5 atlas/source/frame SHA、40/40 RGBA parity 通過。隔離 cloud native Godot 4.7.2，public transport SHA256 符合，55 私有 motion files 暫存於隔離環境。editor import exit 0、real replay exit 0，實際 marker: FLOW_BATTLE_ADAPTER_PASS scope=REAL_V3 actions=5 directions=4 host_unchanged=true。
- 公開倉庫只保存無圖測試 receipt 與 log SHA，raw logs 尚未上傳。未修改 Phase1、E:、原始 V3；未新增生成、未付費。

## Gate（最新）
| Gate | Status |
|---|---|
| Source/structure/40 RGBA frames | PASS |
| V4 native synthetic | PASS |
| V4 native private real replay (headless) | PASS |
| GPU / visual playback capture | NOT_RUN |
| Back-hop body art | HOLD，原姿勢前傾 |
| Export | HOLD，45 raw PNG loading export warnings |
| Actual combat outcome producer | PASS，獨立分支 4 native tests |
| ACTOR01 opt-in FSScreen / queued ACT fixture | PASS synthetic + REAL_V3 |
| Full original game / GPU / RUN / other actors | HOLD / NOT_RUN |
| Independent EGM review / merge | NOT_RUN / HOLD |

## V4.1 歷史施工計畫（producer 已完成，下一步見上）
以 Phase1 bc88b10d37d4e3a9816cdfa6932e7aaefaf33666 為基底隔離新增 authoritative target outcome producer：只在攻擊/技能已結算後發出一次，使用實際承傷目標（含 Ivy Cover 轉移）而非原指定目標；miss 與 evade 分開、拒絕動作不發出；序號及 battle membership 防重複；不改 damage/MP/ATB/ACT。再做 UI subscriber、返回站位與死亡/戰鬥結束、多目標和完整 source regression。不可用 fs_last_action_result 輪詢。匯出資源載入需另行解決，原美術 HOLD 不替換主線素材。

## 舊交接（歷史）
# Forest Symphony | Flow V4 combat presentation Handoff
日期：2026-11-26 Asia/Taipei
工作線：T-A / Flow ACTOR01 Body-only；獨立整合候選，不是 Phase1 主線定版。

## 最新權威
- 使用者：不製作長劍；DODGE 必須向後跳，保持面向敵人。原圖 V3 不可覆寫。
- FS 正式 Godot 4.7.2 主線 feature/fs-godot-phase1：讀取 commit bc88b10d37d4e3a9816cdfa6932e7aaefaf33666 的 animation API；FSAnimationSprite blob f938e8916a86195a00d3f7cf7b9dc1934487c857，FSAnimationProfile blob 765c5d49b2ab18e99dd6641e3a5083aff6c80bd2。
- 目前 Flow 分支 feat/fs-flow-attack8-body-20261126，Draft PR #21。新增 adapter commit ec692ddefe0d6282d8cbdca970f4fe304a3ca75e。MotionBody 最新 snapshot b674a035a91862a02314d6831b5a89c42f6f999f，保留另一線的 3-pose RUN 支援，沒有覆寫原 runtime。
- V3 真實素材：112 檔 2439862 bytes，SHA256 1e4619deeee26601e4e70aef5274e3e00cf521cbdbe5f537f3e41ad327c24bef，私人 Drive https://drive.google.com/file/d/1N9lnZjCoLuVHXI0TPiM--RksUp_PyaY0/view 。既有 Windows #266 原生播放 PASS，並非 V4 轉接層的測試。
- 讀取正式共用 fs-handoff-qa SKILL.md blob b1bb934d2dfe01bd07ecb38709ea356f11ab3dc7、Godot roadmap、主線/T-A Handoff、PC route v1.1、EGM review gate。FS_CONTROL_TOWER_PROTOCOL 在 phase1 預期路徑查詢 404，尚未找到正確分支，不假裝讀取。

## 本輪實際增量
1. 新增 FlowBattlePresentation.gd blob 052667959f31fd02b9feefc20bc2a635ce47d12d；從已通過來源驗證的 SpriteFrames 轉成 fs-animation-v1 profile，五種動作保留 AtlasTexture 底層圖集、區域與逐幀時序。64×64 原點 (32,50) 轉為 centered Sprite2D offset (0,-18)。
2. 後跳：輸入 actor 到 enemy 的同一個本地座標系方向；反向正規化乘上 0/0/4/14/24/24/24/24 native px。僅改 BodyPresentation 子節點 local position，不改 host、戰鬥格或朝向。F4 已有 5px 離地，不重複加跳高。收尾保持最後演出位置直到 caller reset 或新動作；這是待審的演出政策，非永久戰鬥站位。原 DODGE 身體偏前傾，美術 HOLD。
3. present_resolved_evade 只接受明確 evade；miss/hit/未知/零方向拒絕，不中斷目前 RUN。沒有 damage marker 或 ATB/ACT 判定權。
4. test_adapter.gd blob 9bc93960fe9e9a98ba123ab0357cfc25427e650b：五種 clips、區域/offset/duration、四個方向、host 不變、循環、完成、取消、拒絕 miss、reset；預設合成輸入；-- --real-v3 需私有 V3 motions/，不允許以合成替代真圖。
5. 實際重新讀 V3 ZIP，SHA、CRC、五套原始來源/manifest/atlas/frame SHA、40/40 atlas RGBA parity、地面基準、時序均通過 offline 核查。DODGE F4 離地 5px，其餘 grounded。ATTACK 1000、RUN 640、DAMAGE 800、DODGE 800、CAST 1000 ms。
6. GitHub Actions V4 https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45709676853 job 139540537474；最後查詢 in_progress，尚未取得結束碼或 PASS marker。不可把前一版 #266 結果當成 V4 CI 成功。

## 主線接入缺口（源碼實查）
FSBattle.gd blob 60e42f4455c86bdee9d34d030632b88593fc8e1f: 只有 changed(message) / finished(victory) 信號；attack L348–369、use_skill L638/708–728 在確定未命中/迴避後寫入 target.fs_last_action_result。FSScreen.gd blob ec44f1b7ef0bd5c8a1350482674a61d71fed431c: L66/67、91/92 接 changed/finished；_combat_result_text L1106–1115 只是顯示上次結果，不能輪詢它來重複觸發動畫。不得從文字 log 或畫面刷新推測新事件。
下一個完整施工單位：以當下最新版 phase1 為基底開隔離整合候選，先設計一次性、已結算的 target outcome 事件（攻擊與技能、每 target、唯一序號、明確 miss/evade/hit、無已拒絕動作），由 UI/renderer 訂閱，映射正確演出，不改數值/成本/ATB；加入多目標、重複刷新、取消、死亡、戰鬥結束/返回站位及 source-authority 回歸測試。先完成 V4 native 測試與真實 V3 private replay，再做主線接入，ART 未通過不替換正式素材。

## QA / Failure / Gates
| Gate | 狀態 |
|---|---|
| V3 SOURCE / STRUCTURE | PASS，實際 ZIP 40/40 |
| V4 code / repo readback | PASS |
| V4 official native synthetic | IN_PROGRESS / HOLD |
| V4 real private native / GPU | NOT_RUN |
| Correct backward-hop body pose / ART | HOLD |
| Actual battle event hookup / gameplay | NOT_RUN |
| Independent EGM review | NOT_RUN，未宣稱獨立審查或允許 merge |
| V3 PERSISTENCE | 既有私人 Drive verified |
無新增生成、無武器/FX、無 Codex、無 Desktop Remote、無新增 Bridge 工作。未更動 main、Phase1、T-A/B/C、E: 原始遊戲。V4 是候選，非完整移植。
