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
