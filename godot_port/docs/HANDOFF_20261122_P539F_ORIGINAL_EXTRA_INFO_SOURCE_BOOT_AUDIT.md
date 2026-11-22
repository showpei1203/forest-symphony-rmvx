# Forest Symphony｜P539F 2026-11-22 原版特殊戰鬥資訊整合與 boot-source 真實阻斷 Handoff

正式引擎 Godot 4.7.2，GitHub 專屬 feature/fs-godot-phase1。原 FS VX 來源不修改；原始 Ruby/RVData、私有素材及 GPU 來源證據不提交 GitHub，只儲存 owner-only Google Drive G:。

## 真原始 #381 來源比對
- Scripts.rvdata 原 #381 AlbertBattleStateHUD lines686–896 原順序七類資訊：Mana Shield剩餘、ATB延遲抗性、Ivy 儲存護衛傷害、Break進度及抗性、動態異常抵抗、Robot Protocol、目標優先權。lines1617–1673 是 extra_info_rows 先於 state detail 繪製，最多六行 info 和12個 source state。原 #376 角色核心 BREAK_PROGRESS_STATE_ID=50，原 #377 ATB DynamicResist；#372 target priority；#462 Help NO duplicate State icon。每項僅引述實際有權威的 provider 或原 State/Enemy Note。
- 真正新 scripts/FSOriginalBattleInfo381.gd：同順序七個 source-gated adapter。Mana盾需真的 live State77及已生成fs_boss_shield_remaining；ATB顯示需原 <atb_dynamic_resist> note、真正 #377已生成等級/最大值/下限及來源 rate表；Break需來源Enemy Note與 State50層數，不將0/threshold猜成真進度；動態異常抗性及Robot Protocol的資料不存在時絕不顯示；Ivy原護衛儲存傷害與 fs_ivy_stored_pain 絕非同一種數值，不可混用；目標優先一律經 #372 FSTargetPriority 的已知語義。
- scripts/ui/FSBattleSourceTargetHelp462.gd：先列原 #381 extra_info_rows，再列真 State stack/turn/detail；Source最多六行；目標仍從真 Godot FSBattle Dictionary只讀；加 live refresh 讀取動態 shield / ATB抗性。4–6行時 target panel換到 x>=152，避開原主角 #269 左下角肖像 x9..144,y249+。FSScreen每12 Godot frames刷新來源 target HELP，不排ACT也不消耗HP/MP。
- tests/test_fs_p539f_original_info_381.gd：測來源Mana120、ATB等級1/4 rate70% floor10%、State50 Break 2/5/20%/after-2、StateResist出血66%、TargetPriority3順序、動態盾120→72與ATB Lv1→Lv3自動刷新、缺來源欄位不猜算、Ivy stored-pain與 stored-cover隔離、來源Robot Protocol四回合間隔和剩餘行動、未知StateID拒絕、544原HUD肖像不被6行面板蓋住。

## 這輪真的抓出且修復的資料破壞
- 重要 Source UI BUG：原版 P539E 的 source_target_help.select/clear_source 使用 active_target.clear()，當 active_target 指向真正 enemy/party Dictionary 時，重新整理／切換目標會直接清空真 Game_Battler！不是美術問題。
- 已修成 active_target={}，僅解除UI自身的參照，不修改真敵人。新增實際 Godot原生回歸：目標持續刷新、切換敵人、關閉Help後兩份 battler 的 name/hp/mp/states仍完整。另 InfoRows和 StateDetail同時查無原State時只報單一 fail-closed source warning，不刪資料。
- 初版 source test先以同級 priority 導致六行限制選中 State50 而非預期 State77，修 synthetic fixture 的原版 priority 明確宣告；真資料規則不放寬。
- 初版 private GPU script複製自 P539E，var enemy 重複與 G: folder guard指向舊目錄，皆 fail-closed，修復後才接受8/8 native GPU PASS，失敗原始log保留。

## 真正可視化原圖驗收
- 真使用者 Windows Godot 4.7.2.stable.official.ed1daf0bf / AMD Radeon RX6700XT / OpenGL3.3、原 SHA private BattleScape, Battlers, Actor01 12幀Body/Weapon/FX, original Btskin269, Iconset381, ACT五個來源icons，544×416與1088×832各8張，共16/16原圖 native GPU screenshot PASS。
- #381增加特殊info在真的原版畫面的 ROI 544 changed=33,712px；1088 changed=133,517px；源 #462原選敵header與狀態、#269原肖像、A52三層反向保留。實際目視144x249左下HUD沒有被特別狀態文字覆蓋，底下 target buttons仍可用。
- 正式 source畫面：https://drive.google.com/file/d/1o3ilHBWAlza_wWb-bbDkEaKOxowyRdSP/view（544）與 https://drive.google.com/file/d/1Iwzn6WFNstc6fMf7rGFK3oZ5hMBeufb9/view（1088），皆 owner-only。
- 官方原生 Godot 4.7.2 完整 CI #44998957776 completed SUCCESS 96/96 steps、0 failures：https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44998957776。
- 私人完整 QA G Drive資料夾：https://drive.google.com/drive/folders/1tWSHFtaIoPsohfL6pavJVCSCHnqACLRk，正式 ZIP 檔名 FS_P539F_ORIGINAL_381_SPECIAL_INFO_BOOT_RAW_SOURCE_PRIVATE_QA_20261122.zip，7,189,128 bytes，SHA256 2f97554ac38a4c12c0e433d4c7489feabf13a37e221a9afd016a829dc6176237，ZIP CRC PASS 37 entries：16真GPU、2前輪版面FAIL圖、17 real Native/log(含源腳本fail閉鎖與修復)、來源證據JSON/11 raw表SHA稽核。

## 原始資料庫權威狀態（不能假冒完成）
- 可直接核對私有 FS_UNIFIED_ORIGINAL_505_SCRIPTS_11_TABLES_PRIVATE.zip：真 Scripts.rvdata 2457490 bytes及 505份Ruby、11 個 Data/Actors/Classes/Skills/Items/Weapons/Armors/Enemies/States/Troops/System/Animations.rvdata 原始檔，逐檔 SHA紀錄在私人 P539F來源QA manifest。
- 這些是 raw 原 VX 原始檔，不是原 RPG Maker VX 真執行 Script MasterSetup、FS_DB_AUTOSET.apply_all 後的 final DB。查無 fs_boot_final_runtime_witness.json；目前使用者主機預期 E: FS project 位置在此次遠端讀取時未掛載。故本次沒有將 raw tables宣稱 post-Apply，也不會更改 fs_boot_final_authority 的 hard fail-closed機制。
- 真11份 boot-final postApply table/runtime witness、完整505 RGSS2 effective override順序、真敵AI/Boss、所有主角動畫、#381 Clone/Role條件外部原生模組、原 VX vs Godot同frame 1:1 都仍 HOLD。Source測試用敵方狀態與數值明確 synthetic fixture，只有美術圖是私有原版來源。

## 後續主要路線
- 下一施工批應直接轉 P538 完整原版 MENU bundle，以原VX原始 UI/script一起搬到 Godot，不再陷入 #381單一 icon 微修。與此平行追查原VX boot-final runtime witness 來源（E: 沒掛載時不能偽造）。保持原SOURCE→實際程式→Native QA→原圖檢視→FailureLog→GitHub及Drive Handoff。
- 總狀態 ART HOLD、Phase1 SEAL NO。
