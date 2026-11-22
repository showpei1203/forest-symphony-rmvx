# FS P539C｜原始 #312 與 #269 比對／修正 Failure Log 2026-11-22

## R0 舊程式錯誤：用 actor.a_seal 等假旗標做視覺封印
原 FS #312 實為 Game_Battler 持有 source State IDs，依 RPG::State.note 精確 JP 文字四封印；同時防止原 Game_BattleAction.valid? 成功及 skill_can_use?。P539B 只從 bool flag 染灰 UI，但 queued ACT 可能執行。P539C 改一個 FSOriginalActionSeal 來源，讓 UI／玩家及敵方排隊／真正 ACT 結算同步，拒絕 State 不明的計算。

## R1 同一施工輪次 merge regression：HUD 接線覆蓋先前封印 UI（已修）
第一版新增 #269 HUD 時從舊 FSScreen source 編出新 blob，意外覆蓋剛寫好的 #312 source State-note UI 判定。實際 Godot Native diagnostic：ATB READY=true, source quote blocked=[true,false,false,false]，四個 fallback 按鈕 disabled=[false,false,false,false]，完全錯誤！已原生測試拒絕 PASS。
再合併固定版本 71f069861b2d09b33e56375675b6adb164e095c3 後按鈕 disabled=[true,false,false,false]，整組 State.note 或 ACT 正確。真 QA 不允許單看引擎成功判斷介面通過。

## R2 舊合成 Data fixture 不具 stock Game_Battler.states（已修）
- stock VX Game_Battler#initialize 一定先給 @states=[]；但 Godot 舊 test_fs_atb_action_queue、test_fs_tankentai_ui_tick 手寫 party.append/enemies.append 忘記此欄。新來源封印 fail-closed 直接暴露測試建模缺陷，已補合法 source-shaped states=[]，Tankentai ATB queue／ACT recharge 原生復測通過。
- test_fs_item_recovery 純公式 Dictionary 不屬真正 battle.party/troop 且無 State；新正式 FS Battle source gate 誤拒絕 standalone item formula unit test。改成只對真正 live party/enemy 或具 source states 的個體強制檢查，孤立 synthetic formula probe 明確分離。正式 FSBattle.add_actor/add_enemy 仍必給 source states=[]。
- PRIVATE GPU harness 起初 output guard 指向不存在的 FS_PRIVATE_P539C_FULL_BATTLE 路徑，已修成授權 G: FS_PRIVATE_P539C_BATTLE_COMPARE。未對原 FS E: 作任何修改。

## R3 真實原始畫面與完整回歸
Godot4.7.2/ RX6700XT owner-only 544/1088 原本 P539B generic HUD vs P539C 新 #269 真 Btskin/portrait 的 before-after、每解析度3張截圖與 HUD GPU source ROI 13,060/52,244、Scape ROI 92,621/370,373 比對，保存 3,163,664 bytes ZIP https://drive.google.com/file/d/1vbgi88r3hnnXyhSXAjQxDAVet3NGQxac/view SHA e3c6ac681b16b9b7f41427564e1c1626d9e53074a38b3fa0be17cd6c56ca4c91 CRC PASS owner-only。官方 Godot CI #44992946795 93/93 completed SUCCESS。
Remaining: 全 505 生效 alias、原 boot-final DB 11、敵方 AI 特殊狀態、HUD 269 附加角色與滾動 digits、State icons、逃跑及 A52 damage contact/hitstop、VX 同畫面 1:1 ART HOLD；Phase1 SEAL NO。
