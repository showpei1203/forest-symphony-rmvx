# Forest Symphony P539E｜原 #462 選敵 Help、#381 疊層/回合詳情與 #269 原始數字｜正式 Handoff
日期：2026-11-22。Godot 4.7.2 ONLY，主分支 feature/fs-godot-phase1。原始 FS VX E: 只讀，原 Ruby/RVData/像素素材和 owner-only GPU evidence 只存 Google Drive，GitHub只含程式碼、測試、Handoff。

## 依原始 505 Scripts.rvdata 比對的真規則
1. 原 #269 Sprite_strNumber / Sprite_strNumbers（lines589-656）：每次 update 直接把四位數字切到 Btskin_n00/n01 120×48 圖集的指定 src_rect；原始程式沒有數字滾動補間。P539C 的原像素即時更新符合源碼，P539E 不製造假的數字 easing。
2. 原 #381 AlbertBattleStateHUD（70616 bytes SHA b1df4785f85efbe412a84a227883b9b77bf11aab9b9e9fb70dcfb4ecd89c8b39）：MAX_STACK note tag、battler 當前 stack/state_turns、priority/hidden/forced icon、層數n/max、剩n回合、自訂 HUD詳細文字；圖示 stack>1 顯示黃色 badge，非stack可自動解除且剩回合>0 顯示藍色 badge，名稱/文本讀真 StateID。
3. 原 #462 FS_BATTLE_TARGET_HUD_LAYOUT（63272 bytes SHA b65d704f87c50ec00788b23f49892042d99e10bc62016bdcc4c00f71d10e31e3）：Window_Help#set_text_n01add 是 Target Name + source CaptureRate 若原 Albert_CaptureRate::HELP_SHOW/資料俱真才顯示；SHOW_HELP_STATE_ICONS=false，狀態 icon 已在 #381 Sprite 畫；命令 UI 下的 detail max safe right x410。未驗證的捕獲率、元素 icon 絕不推算或假畫。
4. 原 #372 FSTargetPriority remains authority：有陌生 State.note target 語義不能判斷時保留 fail closed；原 #312 真 State seal 與 ATB/ACT 動作 queue 亦不旁路。

## 真正整套施工
- scripts/ui/FSBattleSourceStateHUD381.gd：加入 original State max_stack（含 MAX_STACK tag）、當前 stack/turns、State detail sorted/read-only、20px原 Iconset stack/turn badge。缺 State record 時不捏造。
- 新 scripts/ui/FSBattleSourceTargetHelp462.gd：來源 Help Name、限有來源證據的 CaptureRate、#381 stack/turn/custom detail 6行 bounded、Source #462 helper不複製 State icon。實際 Godot 可顯示，並獨立於決定是否真正出手。
- scripts/FSScreen.gd：真正 _select_enemy_target 和 _select_ally_target 選目標時裝 source target Help，滑過合法目標更新資訊，點擊真選擇 Button 仍經來源 #372 priority、#312 封印與 FSActionQueue；預覽時敵人HP/MP/RNG不變。按下才排入ACT一次並清理Help，退出模式重設ATB wait。私人來源原圖模式隱藏舊Godot developer title/tabs/log，但保留可操作 target ScrollContainer；Target Help Name放頂端、detail下移避開 monster，目標按鈕縮到右側避開原 #269 左下主角頭像。
- tests/test_fs_p539e_target_help_detail.gd：原 #269數字非動畫規則、第 #381 State Stack 2/5 與3回合、hidden/priority/custom detail、非證實CaptureRate必須隱藏/非法輸入拒絕；正式 FS Battle ATB READY, source #372目標可選、Help預覽不能出手、實際 Button.pressed 必須 ACT pending恰好一筆、不提早扣HP、Help清除與wait解除。
- owner-only tests/capture_fs_p539e_private.gd：用真 SHA 原 BattleScape/敵人/源五ACT按鍵/#269狀態主角頭像/#381圖示/A52原三層橫向反方向，建立標為 synthetic的 State30/31 測試資料與可來源辨識的 target_priority:0，真 Godot 原生7個階段各一張，544×416及1088×832合計14張。

## 真實可核對 QA
- Godot 4.7.2.stable.official.ed1daf0bf Win64，AMD RX6700XT OpenGL 3.3，原圖私有 G: Drive 專案。
- GPU 源畫面 14/14 PASS：兩解析度各 idle、ATB_READY、源 #462 target+State detail、A52 F7、錯朝向before/正朝向after、#381 Source Iconset。#462動態顯示物理畫面像素差 544=40548、1088=162295；原 #381 Iconset 336/1346；原 #269 Btskin 13060/52244；上一輪修好 A52三層反方向仍是792/3176像素差。
- 原生完整 Godot官方 CI #44996910206 95/95 steps SUCCESS failed0：https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44996910206
- Google Drive owner-only 真原圖及QA ZIP：https://drive.google.com/file/d/1znQPh_XiT64zp6EmfW9GEk-4b2YJYzZb/view，6,372,214 bytes，SHA256 e1d855f9b0900b1aa88a9ceb569aa4d74a9ef2417b77f05f271ef436738dbce3，30 entries、ZIP CRC PASS，14 final GPU + 2失敗前畫面 + 13份原生 logs + 源 #269/312/372/381/462 SHA manifest。Google Drive provider 確認 shared=false、permission owner only。Folder https://drive.google.com/drive/folders/1dT30Xgr4sRkjD0AGBvgD0NJZVvtv17xJ
- 原圖修正後 544：https://drive.google.com/file/d/16Rl47a-KLLiwZUaJFKymnOVi0dqG6qgF/view；1088：https://drive.google.com/file/d/1edgk9Mgk1q_JMM2-fu4XkGoEz-UTlZku/view。

## 不能假稱完全原版的 HOLD
- 本次 #462/381 是 source-bounded 可操作部分，非原 VX 完整動態 target/help/window 1:1 pixel parity：#462 Albert_CaptureRate 真實 module/rate與 element icon mapping、特定選敵窗口動態座標尚未移植完整；#381 shield/Break/Ivy/Robot/ATB dynamic detail等 extra rows／所有stack別名、原 source State 語義仍待 port。
- 原 FS 11 boot-final tables after FS_DB_AUTOSET.apply_all 及505 Ruby effective alias完整執行、敵方 AI、原 A52 F7真傷害結算/70ms hitstop、T-A RUN12及其他五主角、source BattleScape Bridge/BlueSky、完整 MENU 都是下一階段阻斷。這次數值 fixture標明 synthetic，絕非原 Game DB 最終授權。
- ART HOLD，Phase1 SEAL NO。下一個完整施工單位 P539F 特殊 State/Target detail + boot-final源權威、之後 P538整套原版 MENU；地圖 A35仍由獨立T-C美術線處理。
