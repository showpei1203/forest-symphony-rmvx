# FS Godot P539C｜原始 #312 State 封印與 #269 原版 HUD 整批移植 Handoff
日期 2026-11-22；Godot 4.7.2 ONLY。原 FS E:唯讀，來源原 Ruby/RVData/PNG 只存 owner-only Google Drive；GitHub 只存程式碼、QA、文件。

## 1. 原始全 505 分頁比對依據
- Ruby section #312（7829 bytes，source SHA a4e205e31760ddb1471839f9b7c7e84141beebaaf59b9469614b56dc91ecfc29）真正 RPG::State#setup_seal 由當下 State.note 的「攻撃封印／スキル封印／防御封印／アイテム封印」推導 a/s/g/i seal。Game_Battler#skill_can_use?、Game_BattleAction#valid?、Scene_Battle#commanding?、Window_ActorCommand#refresh 和 alias 包裝的命令選擇皆查來源狀態。不是 actor.a_seal 等憑空存的布林；繁體「攻擊封印」與 source 日本漢字「攻撃封印」也不相同。
- Ruby section #269（24327 bytes，source SHA a2b426c1930b95c6b9affc7945a3181a10e3015c03416b6f50308cdc9e588dde）source Window_BattleStatus 正式位置：regular Actor ID1-6 之 HUD Btskin_main x=9+139*index, y=371；HUD_角色名肖像 135×135 x=9+139*index, y=249；第一位 HP gauge x52 y374、MP gauge x52 y387、HP 數字 x66 y370、MP 數字 x70 y384、OD 數字 x74 y397。原圖 Btskin_main 135×40，Btskin_hp/mp 77×20，Btskin_n00/n01 120×48（十字×三色，單字12×16），HP/MP fill int(77*current/max+1) 並限制77px。
- 505 完整 Ruby 來源封包 SHA a7089ef45dfe4c92260932ffc4c0f21934b43ac0b296eb8ca53c828e4af2e106；未執行全部原 Ruby，仍需要逐項 505 effective aliases runtime witness。

## 2. 一次改動的可執行 Godot 模組
- scripts/FSOriginalActionSeal.gd：讀 FSDatabase 的 state ID/note，四類 State seals OR 結合，每次即時計算，未知 State fail closed。
- scripts/FSActionQueue.gd：真 ATB/ACT 玩家與敵方行動排隊前、行動即將真正結算時再次查 #312。ACT 中途被加封印，不可扣血、MP、道具或誤耗 RNG。
- scripts/FSBattle.gd：當真正 party/troop actor 發動直接攻擊、技能、戰鬥物品時也使用來源 #312；獨立 Dictionary formula unit test 不等於已加入 party 的正式 Game_Battler，避免拿測試缺少 states 假扮來源。
- scripts/FSScreen.gd：真 5 SOURCE Battle01..05 與 2x2 fallback 都共用同一 State.note 封印表，按鍵執行前再查。修正同一輪 #269 HUD 整合時意外從舊 screen 覆蓋 #312 UI 驗證的 merge regression。
- scripts/ui/FSBattleSourceHUD269.gd：真正 owner-private SHA 檢驗的 HUD_喬伊/泰勒/米亞/艾卓/艾薇/維娜，原 Btskin_main/hp/mp/n00/n01，按照 Ruby 真座標和數字/雙列 HP MP texture draws。可證明來源的普通角色最多3位時取代上方 generic Godot HFlow；extra actor ID>=7／不合來源規格一律候選 fallback，不冒稱正式原作。
- tests/test_fs_battle_source_539c.gd：四種精確日文 State note、OR 疊加、中文誤配不得封印、未知 State fail closed、Attack-only 原UI 按鈕 disable、不提前排隊、ACT 蓄力中新增 Seal 即不傷害、#269 來源精確位置與77px條。test_fs_atb_action_queue / test_fs_tankentai_ui_tick 手寫 fixture 原缺 stock @states=[]，已依原 Game_Battler#initialize 補齊。原 stock 道具 formula regression 恢復。
- 初始 source batch commit 8407cb5e69701e64b12b18a74a500a2c8b27e78a；source UI+HUD 合併修正 71f069861b2d09b33e56375675b6adb164e095c3；pure formula API 079bc43114832492163299fe5d0ad11c4d71015b；正確 source State fixtures 5005679c08cf030dba130d09d4f6125f80a0191b、49bc2c7c3756b9ffdde7759c828ebd62279853c4。

## 3. 實際 Native QA & 使用者私人 GPU
- Godot v4.7.2.stable.official.ed1daf0bf，Windows、AMD Radeon RX6700XT OpenGL3.3 Compatibility。原本 private SHA-stage 的真 UI202、Battlers167、Scapes7、A52三層均未上 GitHub。
- 使用真正原版 喬伊 HUD_喬伊肖像及 Btskin 圖片，與 SOURCE Scape／原敵人／A52 F7／5指令同場景；合成戰鬥數值是明示 fixture，非正式 FS 11 post-Apply 資料。544×416、1088×832 各 idle、ATB READY、A52 F7 共 6/6 真源原 GPU 截圖。
- Source #269 HUD physical GPU delta：544=13060 pixels、1088=52244 pixels；Source BattleScape delta 544=92621、1088=370373。原本 generic HUD 對照圖各一張放一起，保留 real Before/After。私有證據 ZIP owner-only https://drive.google.com/file/d/1vbgi88r3hnnXyhSXAjQxDAVet3NGQxac/view 3,163,664 bytes，SHA e3c6ac681b16b9b7f41427564e1c1626d9e53074a38b3fa0be17cd6c56ca4c91，14 entries，CRC PASS，Google Drive provider shared=false/owner permission；私人來源工作目錄 https://drive.google.com/drive/folders/106wprwejXpayflaaGut8UQTW4uRjiYB-。
- 完整 GitHub Godot 4.7.2 官方 native CI #44992946795 completed SUCCESS 93/93 steps, failed0：https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44992946795 。

## 4. 不可隱瞞的 HOLD
- #269 滾動數字過渡、尾隨血條、原色調脈衝、狀態 Icon/回合、額外 Actor.id>=7 及四個常規角色越界畫面，仍是候選或 ART HOLD，不能稱原版全 HUD 1:1。
- #312 實際 State.note／輸入／ACT 封印已實作，但所有 505 runtime alias、全部敵方 AI 回合選擇、狀態轉換與後續特殊規則仍未等價；合成 Enemy/Troop 非原始 11 tables boot-final。逃跑、原 A52 0.630s 命中與 ACT 真時間、70ms Hitstop、來源缺失 Bridge/BlueSky、VX/Godot 相同狀態 pixel parity 都 HOLD。
- BATTLE 真原圖 HUD/封印 bounded PASS；整體 Phase1 SEAL NO、ART HOLD。
- 下一個完整施工 P539D：#269 state icons / 滾動 digits 與 #381/#462 target HUD、真正 AI State 重新選招、boot-final 11 DB witness；接 P538 整套 MENU，再回 A35 地圖。依來源→比較→修正→原生 QA/GPU→Handoff 一批做，不拆成一顆按鈕。
