# -*- coding: utf-8 -*-
#===============================================================================
# ■ Albert_RMVX_REFERENCE_All_Variables_Switches_TC
#-------------------------------------------------------------------------------
#  Forest Symphony 森之交響曲
#  Main 以上有效腳本之「變數 / 開關」完整整理與保護名單
#-------------------------------------------------------------------------------
# 【用途】
#  這是一頁可以直接放進 RPG Maker VX 腳本庫的純註釋文件。
#  不執行任何功能，只用來防止重新規劃資料庫時誤刪、誤改、撞號。
#
# 【基準】
#  依據 All_Scripts_Export(7).txt，只整理 Main 以上有效腳本。
#  Main 以下依本專案規則視為無效，不納入正式衝突判定。
#
# 【重要閱讀原則】
#  1. 「硬鎖 / 保留」：腳本直接依賴，改 ID 必須同步改腳本。
#  2. 「設定常數」：可改，但要同步改常數與資料庫設定。
#  3. 「直接數字引用」：程式碼直接寫死，屬於高風險。
#  4. 「動態入口」：腳本可接受任意 ID，不代表整個範圍已被占用。
#
#  這份文件刻意把「已確認衝突」寫得很明白。因為最可怕的不是腳本報錯，
#  而是兩個系統共用同一個開關、遊戲還能跑，直到某天玩家打 Boss 時順便
#  把自動跑步關掉。這種幽默不需要留給正式版。
#===============================================================================

# ===============================================================================
# 第一部　最重要的變數（Variable）保護名單
# ===============================================================================
#
# 【Variable 1】
# 狀態：高風險重複使用
# 來源：
#   ・YEM Restored Functions：PICTURE_NUMBER_VARIABLE = 1
#   ・對事件使用物品：LAST_USE_ITEM = 1
#   ・接金幣：VAR_ID = 1
#   ・數個小遊戲腳本的範例 / 註釋也使用 1
# 判定：
#   目前 Variable 1 同時被多個舊系統視為預設值。
# 建議：
#   不要再新增用途。若「對事件使用物品」「接金幣」「YEM Picture Number」
#   仍要共存，最好將其中至少兩個改到獨立高號段。
#
# 【Variable 2】
# 用途：YEM System Game Options，BGM 音量百分比。
# 建議名稱：SYS_BGM_VOLUME
# 保護等級：高
#
# 【Variable 3】
# 用途：YEM System Game Options，BGS 音量百分比。
# 建議名稱：SYS_BGS_VOLUME
# 保護等級：高
#
# 【Variable 4】
# 用途：
#   ・YEM System Game Options，SFX 音量百分比。
#   ・圓盤系統也有直接讀寫 Variable 4。
# 判定：已確認衝突。
# 建議：圓盤系統應改到其他變數，系統音量變數最好固定保留 2～7。
#
# 【Variable 5】
# 用途：ATB Active Type。
# 建議名稱：SYS_ATB_ACTIVE_TYPE
# 保護等級：高
#
# 【Variable 6】
# 用途：ATB Speed。
# 建議名稱：SYS_ATB_SPEED
# 保護等級：高
#
# 【Variable 7】
# 用途：Windowskin 選擇。
# 建議名稱：SYS_WINDOWSKIN
# 保護等級：高
#
# 【Variable 11】
# 用途：Thomas Edison VX 日夜系統。
# 常數：KGC_DAY_NIGHT_SCRIPT_VARIABLE = 11
# 建議名稱：WORLD_DAY_NIGHT
# 保護等級：中高
#
# 【Variable 61～64】
# 用途：遇敵控制系統。
#   61 = STEPS_REMAINING_VARIABLE
#   62 = REPEL_STEPS_VARIABLE
#   63 = LURE_STEPS_VARIABLE
#   64 = LURE_RATE_VARIABLE
# 建議：整段保留，不拆散。
#
# 【Variable 90】
# 用途：YEZ Status Command Menu 的註釋 / 顯示設定來源。
# 判定：目前掃描主要出現在註釋，不是核心硬鎖。
# 建議：仍避免隨意占用，若要重用先檢查該腳本頁。
#
# 【Variable 101～118】
# 用途：TPET 寵物系統。
# 設定：
#   USE_VARIABLES_ID = 101
#   MAX_PET = 3
#   每隻寵物使用 6 個變數。
# 因此實際保留：
#   Pet 0：101～106
#   Pet 1：107～112
#   Pet 2：113～118
# 補充：
#   Variable 101 / 102 還被 TPet_Dog 直接拿來判斷圖像 / 成長。
# 建議：若 TPet 系統確定保留，101～118 整段不要分配給其他系統。
#
# 【Variable 105】
# 用途：
#   Custom Dmg Formulas RD 的親密度傷害加成。
# 程式：
#   damage += $game_variables[105] * 10
# 注意：
#   105 同時落在 TPET 101～118 保留區。
# 判定：已確認衝突。
# 建議：
#   必須二選一改號。長期建議把「親密度」移到獨立角色資料或 3000+ 區段。
#
# 【Variable 121】
# 用途：
#   Window_ShowD / Window_ShowD備份 / Window_FriendInfo 直接讀取。
# 建議：保留，除非這三個視窗系統確定刪除。
#
# 【Variable 200】
# 用途：
#   YERD_TargetEffects 內部亂數 / 自訂目標流程。
# 判定：有實際執行引用。
# 建議：保留。
#
# 【Variable 201】
# 用途：
#   SBS Battler Configuration / BattlePopText_Note。
#   儲存目前 Battler X 座標。
# 建議名稱：BATTLE_POP_X
# 保護等級：極高
#
# 【Variable 202】
# 用途：
#   SBS Battler Configuration / BattlePopText_Note。
#   儲存目前 Battler Y 座標。
# 建議名稱：BATTLE_POP_Y
# 保護等級：極高
#
# 【Variable 203】
# 用途：
#   SBS / BattlePopText_Note。
#   儲存目前技能 ID。
# 建議名稱：BATTLE_CURRENT_SKILL_ID
# 保護等級：極高
#
# 【Variable 210】
# 用途：
#   YERD_TargetEffects 的註釋 / 舊測試資料。
# 判定：目前正式程式多數為註釋。
# 建議：可回收，但回收前搜尋一次完整腳本。
#
# 【Variable 302】
# 用途：
#   YEZ Custom Status Properties 的客製效果流程。
#   目前有直接累積傷害、修改 ATK、重設為 0 的程式。
# 判定：硬鎖，極高風險。
# 建議：保留。
#
# 【Variable 1000】
# 用途：Variable Battle Scapes。
# 常數：BATTLE_SCAPES_VARIABLE = 1000
# 建議：保留。
#
# 【Variable 4997】
# 用途：BattleSwirl。
# 常數：P2BSWIRL::VARIABLE = 4997
# 建議：保留；這種超高號碼至少很有自知之明，知道該遠離人群。
#
# ===============================================================================
# 第二部　最重要的開關（Switch）保護名單
# ===============================================================================
#
# 【Switch 1】
# 用途：
#   ・VX 敵人戰鬥座標永續固定：ENEMY_XY_SWITCH = 1
#   ・NPC自言自語：SW_MESSAGE_STOP = 1
# 判定：已確認衝突。
# 建議：至少移走其中一個。
#
# 【Switch 3】
# 用途：YERD_BestiaryScan 的圖鑑功能開啟。
# 常數：BESTIARY_SWITCH = 3
# 保護等級：中高
#
# 【Switch 4】
# 用途：YEM Restored Functions，圖片鏡像。
# 常數：PICTURE_MIRROR_SWITCH = 4
#
# 【Switch 5】
# 用途：YEM 系統選項，BGM 靜音。
#
# 【Switch 6】
# 用途：YEM 系統選項，BGS 靜音。
#
# 【Switch 7】
# 用途：YEM 系統選項，SFX 靜音。
#
# 【Switch 8】
# 用途：YEM 系統選項，是否顯示戰鬥動畫。
#
# 【Switch 9】
# 用途：YEM 系統選項，AutoCursor。
#
# 【Switch 10】
# 用途：YEM 系統選項，選完指令後自動換下一角色。
#
# 【Switch 11】
# 用途：
#   ・YEM 系統選項，Skill Help。
#   ・YEM Restored Functions，STOP_ALL_SWITCH = 11。
# 判定：已確認衝突。
# 建議：不要讓兩套功能共用。
#
# 【Switch 12】
# 用途：YEM 系統選項，自動跑步。
#
# 【Switch 13】
# 用途：YEM 系統選項，即時文字。
#
# 【Switch 14～15】
# 用途：月紳士「根據位置選擇」的舊 / 重複設定頁之一。
# 注意：
#   最新腳本同時還有 TOP_SWITCH = 134 的正式高號段版本。
# 建議：
#   若 14～15 那份舊版仍實際執行，應移除或停用重複腳本；
#   不建議同一功能保留兩套 TOP_SWITCH。
#
# 【Switch 16～17】
# 用途：月紳士「技能有效度」的舊 / 重複設定頁之一。
# 注意：
#   另有 TOP_SWITCH = 136 的高號段版本。
# 建議同上。
#
# 【Switch 18】
# 用途：KGC LargeParty，隊伍編成。
# 常數：PARTYFORM_SWITCH = 18
#
# 【Switch 19】
# 用途：KGC LargeParty，戰鬥隊伍編成。
# 常數：BATTLE_PARTYFORM_SWITCH = 19
#
# 【Switch 21～24】
# 用途：月紳士「根據狀態選擇技能」的舊 / 重複設定頁之一。
# 注意：
#   另有 TOP_SWITCH = 150 的高號段版本。
# 重大問題：
#   Switch 23 同時被乗り物拡張直接使用。
# 建議：
#   優先淘汰 21～24 這份重複配置，統一使用 150～153。
#
# 【Switch 23】
# 用途：乗り物拡張直接使用。
# 判定：
#   與上述 21～24 狀態 AI 範圍衝突。
#
# 【Switch 27】
# 用途：Counterattack State v1.3.1 修正版。
#
# 【Switch 29】
# 用途：Neo Save System V，SWAP_TILE_SWITCH。
#
# 【Switch 30】
# 用途：Neo Save System V，MAP_NO_NAME_SWITCH。
#
# 【Switch 31】
# 用途：MOG 顯示地名停用開關。
#
# 【Switch 32】
# 用途：霧氣效果 SW_NOUSE。
#
# 【Switch 36】
# 用途：
#   Scene_Battle / Sideview / ATB 舊整合流程中有直接或註釋引用。
# 建議：
#   視為保留，除非完成來源清理。
#
# 【Switch 37】
# 用途：地圖技能 / 乗り物拡張。
#
# 【Switch 44】
# 用途：YEZ Job System，技能學習選單。
# 常數：LEARN_ENABLE_SWITCH = 44
#
# 【Switch 45】
# 用途：YEZ Job System Skill Levels，技能升級選單。
# 常數：LEVEL_ENABLE_SWITCH = 45
#
# 【Switch 50】
# 用途：
#   多個戰鬥視窗、Sideview、ATB、臨時加入等系統。
# 判定：高風險交叉使用。
# 建議：
#   在未逐一清理來源前，不要新增用途。
#
# 【Switch 96】
# 用途：戰鬥畫面天氣。
# 常數：WEATHER_SWITCH_ID = 96
#
# 【Switch 97】
# 用途：戰鬥畫面色調。
# 常數：TONE_SWITCH_ID = 97
#
# 【Switch 121～130】
# 用途：月紳士 Extension_Action_Condition。
# TOP_SWITCH = 121
# 保留 10 個條件開關。
# 建議：整段保留。
#
# 【Switch 134～135】
# 用途：月紳士根據位置選擇技能。
# TOP_SWITCH = 134
# 保留 2 個條件開關。
#
# 【Switch 136～137】
# 用途：月紳士技能有效度條件。
# TOP_SWITCH = 136
# 保留 2 個條件開關。
#
# 【Switch 139～144】
# 用途：圓盤系統。
# 判定：直接使用，整段保留。
#
# 【Switch 150～153】
# 用途：月紳士根據狀態選擇技能。
# TOP_SWITCH = 150
# SETTING = [2,-2,3,-3]
# 建議：把它當作正式版本，優先於重複的 21～24。
#
# 【Switch 202～204】
# 用途：乗り物拡張。
#
# 【Switch 473】
# 用途：YEZ Custom Status Properties。
# 判定：直接讀取。
# 建議：保留。
#
# 【Switch 1000 + Actor ID】
# 用途：
#   臨時加入 / 角色圖鑑。
# 形式：
#   actor_id + 1000
# 例如 Actor 7 → Switch 1007。
# 建議：
#   若 Actor 1～36 都可能出現，至少保留 1001～1036。
#
# ===============================================================================
# 第三部　動態 ID 入口：不是固定占用，但必須知道
# ===============================================================================
#
# 以下腳本會依資料庫 Note、事件參數或設定 Hash 讀取任意 ID。
# 它們不是「整個範圍被占用」，但你重新規劃時必須避免無意觸發。
#
# 【技能學習 JP】
#   <jp switch: n>
#   <jp switches: n,n>
# 用途：
#   對應 Switch ON 後，技能才顯示 / 可學。
#
# 【Equipment Overhaul】
#   <require switch: x>
#   <require switches: x,x>
#   <require variable x: above y>
#   <require variable x: under y>
#
# 【技能使用條件】
#   <特殊使用条件>
#   スイッチ,n
#   狀態開關,n
#   </特殊使用条件>
#
# 【事件直譯器】
#   內建事件指令可依任意 Variable / Switch ID 操作。
#   這類不構成固定保留，但事件資料本身可能仍使用大量 ID。
#   注意：All_Scripts_Export 只包含腳本，不包含所有地圖事件內容，
#   因此這份表不可能取代「事件資料庫 ID 掃描」。
#
# 【敵人 AI 開關條件】
#   Enemy action condition type 6 可使用任意 Switch ID。
#   月紳士擴充又另外保留固定區段。
#
# 【遊戲選項 Hash】
#   YEM System Options 透過 options[:xxx] 間接讀取 Variable / Switch，
#   因此不能只搜尋「$game_variables[2]」就以為 2 沒人用。
#
# ===============================================================================
# 第四部　建議的重新規劃區段
# ===============================================================================
#
# 若你未來要大規模整理，我建議採用：
#
# Switch：
#   1～99       舊系統 / 系統選項 / UI
#   100～199    戰鬥 AI 保留
#   200～299    地圖 / 交通 / 劇情系統
#   300～499    狀態 / 戰鬥特殊系統
#   500～799    劇情進度
#   800～999    支線 / 世界狀態
#   1000～1199  Actor 專用旗標
#   1200+       預留新系統
#
# Variable：
#   1～99       系統選項 / 舊腳本
#   100～199    寵物 / 角色長期資料
#   200～299    戰鬥暫存
#   300～399    狀態 / Combo 暫存
#   400～699    劇情與任務
#   700～999    小遊戲
#   1000+       特殊系統 / 大型資料
#
# 最重要的不是「看起來整齊」，而是：
#   一旦某個 ID 有腳本依賴，就把來源寫進名稱或這份保護表。
#
# ===============================================================================
# 第五部　Main 以上直接數字引用自動掃描附錄
# ===============================================================================
#
# 【Variable 直接引用】
# Variable 1
#   執行程式來源：無
#   註釋來源：--------------------------------------------------、SSS - Minigame Bull's Eye、SSS - Minigame Button Mash、SSS - Minigame Input Match、SSS - Minigame Slot Machine
# Variable 4
#   執行程式來源：圓盤系統
#   註釋來源：無
# Variable 90
#   執行程式來源：無
#   註釋來源：YEZ Status Command Menu
# Variable 101
#   執行程式來源：設定項目
#   註釋來源：無
# Variable 102
#   執行程式來源：設定項目
#   註釋來源：YERD_EnemyLevelControl
# Variable 105
#   執行程式來源：--------------------------------------------------
#   註釋來源：無
# Variable 108
#   執行程式來源：無
#   註釋來源：YERD_EnemyLevelControl
# Variable 121
#   執行程式來源：Window_FriendInfo、Window_ShowD、Window_ShowD備份
#   註釋來源：無
# Variable 200
#   執行程式來源：YERD_TargetEffects
#   註釋來源：YERD_TargetEffects
# Variable 201
#   執行程式來源：BattlePopText_Note、SBS Battler Configuration (K)
#   註釋來源：無
# Variable 202
#   執行程式來源：BattlePopText_Note、SBS Battler Configuration (K)
#   註釋來源：無
# Variable 203
#   執行程式來源：BattlePopText_Note、SBS Battler Configuration (K)
#   註釋來源：無
# Variable 210
#   執行程式來源：無
#   註釋來源：YERD_TargetEffects
# Variable 302
#   執行程式來源：YEZ Custom Status Properties
#   註釋來源：無
#
# 【Switch 直接引用】
# Switch 23
#   執行程式來源：乗り物拡張
#   註釋來源：無
# Switch 27
#   執行程式來源：Counterattack State v1.3.1 (修正版)
#   註釋來源：無
# Switch 32
#   執行程式來源：圓盤系統
#   註釋來源：無
# Switch 36
#   執行程式來源：無
#   註釋來源：ATB (1.2c)-0627、Scene_Battle、Sideview 2 (3.4d)
# Switch 37
#   執行程式來源：乗り物拡張、地圖技能
#   註釋來源：無
# Switch 50
#   執行程式來源：ATB (1.2c)-0627、Scene_Battle、Sideview 2 (3.4d)、Window_FriendInfo、Window_ShowD、Window_ShowD備份、YERD_TargetEffects、臨時加入
#   註釋來源：ATB (1.2c)-0627、Scene_Battle
# Switch 139
#   執行程式來源：圓盤系統
#   註釋來源：無
# Switch 140
#   執行程式來源：圓盤系統
#   註釋來源：無
# Switch 141
#   執行程式來源：圓盤系統
#   註釋來源：無
# Switch 142
#   執行程式來源：圓盤系統
#   註釋來源：無
# Switch 143
#   執行程式來源：圓盤系統
#   註釋來源：無
# Switch 144
#   執行程式來源：圓盤系統
#   註釋來源：無
# Switch 202
#   執行程式來源：乗り物拡張
#   註釋來源：無
# Switch 203
#   執行程式來源：乗り物拡張
#   註釋來源：Game_Player、乗り物拡張
# Switch 204
#   執行程式來源：乗り物拡張
#   註釋來源：乗り物拡張
# Switch 473
#   執行程式來源：YEZ Custom Status Properties
#   註釋來源：無
#
# 【常數 / 設定掃描】
# [設定項目] USE_VARIABLES_ID = 101
# [Chest_Item_Pop-Up] POPUP_SWITCH = 0
# [Thomas Edison VX] KGC_DAY_NIGHT_SCRIPT_VARIABLE = 11
# [對事件使用物品] LAST_USE_ITEM = 1
# [YEM Restored Functions] PICTURE_MIRROR_SWITCH = 4
# [YEM Restored Functions] PICTURE_NUMBER_VARIABLE = 1
# [YEM Restored Functions] STOP_ALL_SWITCH = 11
# [YEM Main Menu Melody] USE_MULTI_VARIABLE_WINDOW = true
# [YEM Main Menu Melody] VARIABLES_SHOWN = [-5, 1, 0]
# [YEM Main Menu Melody] VARIABLES_ICONS = false
# [YEM Main Menu Melody] VARIABLES_HASH = {
# [FFXIII Layout] YEM::MENU::USE_MULTI_VARIABLE_WINDOW = false
# [YEM System Game Options] YEM::SYSTEM::WINDOWSKIN_VARIABLE = YEM::SYSTEM::OPTIONS[:window_var]
# [Neo Save System V] SWAP_TILE_SWITCH = 29
# [Neo Save System V] MAP_NO_NAME_SWITCH = 30
# [エネミー行動パターン改良] TOP_SWITCH = 121
# [エネミー行動パターン改良] SWITCHES_RANGE = TOP_SWITCH...(TOP_SWITCH + CONDITION_SIZE)
# [追加：根據狀態選擇技能] TOP_SWITCH = 150
# [追加：根據狀態選擇技能] TOP_SWITCH = 21
# [追加：根據狀態選擇技能] SWITCHES_RANGE = TOP_SWITCH...(TOP_SWITCH + SETTING.size)
# [追加：根據位置選擇] TOP_SWITCH = 134
# [追加：根據位置選擇] TOP_SWITCH = 14
# [追加：根據位置選擇] SWITCHES_RANGE = TOP_SWITCH...(TOP_SWITCH + SETTING.size)
# [追加：技能有效度] TOP_SWITCH = 136
# [追加：技能有效度] TOP_SWITCH = 16
# [追加：技能有效度] SWITCHES_RANGE = TOP_SWITCH...(TOP_SWITCH + SETTING.size)
# [SBS General Settings] BACK_ATTACK_SWITCH = []
# [BattleSwirl] VARIABLE = 4997
# [Variable Battle Scapes] BATTLE_SCAPES_VARIABLE = 1000
# [Variable Battle Scapes] VARIABLE_BATTLE_SCAPES = {
# [雾气效果] SW_NOUSE = 32
# [雾气效果-測試模式] SW_NOUSE = 32
# [戰鬥轉盤+逃跑] SWITCH_COMMAND_BUTTON = Input::X
# [YERD_BestiaryScan] BESTIARY_SWITCH = 3
# [戰鬥畫面天氣+色調] WEATHER_SWITCH_ID = 96
# [戰鬥畫面天氣+色調] TONE_SWITCH_ID = 97
# [VX 敵人戰鬥坐標永續固定的設定] ENEMY_XY_SWITCH = 1
# [--------------------------------------------------] STEPS_REMAINING_VARIABLE = 61
# [--------------------------------------------------] REPEL_STEPS_VARIABLE = 62
# [--------------------------------------------------] LURE_STEPS_VARIABLE = 63
# [--------------------------------------------------] LURE_RATE_VARIABLE = 64
# [KGC_LargeParty] PARTYFORM_SWITCH = 18
# [KGC_LargeParty] BATTLE_PARTYFORM_SWITCH = 19
# [YEZ Job System: Base] LEARN_ENABLE_SWITCH = 44
# [YEZ Job System: Base] JP_SWITCH = /<(?:JP_SWITCH|jp switch|jp switches):[ ]*(\d+(?:\s*,\s*\d+)*)>/i
# [NPC自言自語] SW_MESSAGE_STOP = 1
# [MOG_顯示地名] WM_SWITCH_VIS_DISABLE = 31
# [Message Queue] SWITCH = nil
# [--------------------------------------------------] REQ_SWITCH = /<(?:REQUIRE SWITCH||require switches):[ ]*(\d+(?:\s*,\s*\d+)*)>/i
# [接金币] VAR_ID = 1
# [--------------------------------------------------] MUL_VARIABLE = /<(?:MULVAR|mul var)[ ]*(\d+)>/i
# [--------------------------------------------------] DIV_VARIABLE = /<(?:DIVVAR|div var)[ ]*(\d+)>/i
# [--------------------------------------------------] ADD_VARIABLE = /<(?:ADDVAR|add var)[ ]*(\d+)>/i
# [--------------------------------------------------] SUB_VARIABLE = /<(?:SUBVAR|sub var)[ ]*(\d+)>/i
# [YEZ Job System: Skill Levels] LEVEL_ENABLE_SWITCH = 45
#
# ===============================================================================
# 第六部　實務檢查流程
# ===============================================================================
#
# 每次要重用 Variable / Switch 前：
#
# 1. 先在本頁搜尋 ID。
# 2. 再搜尋最新 All_Scripts_Export。
# 3. 若仍無結果，再檢查：
#    ・地圖事件
#    ・公共事件
#    ・戰鬥事件
#    ・資料庫 Enemy action switch condition
#    ・裝備 / 技能 / State Note
# 4. 確認後才重新分配。
#
# 腳本搜尋不到，不代表事件資料沒在用。
# 事件資料搜尋不到，也不代表 Note 沒在用。
# 人類把同一個 ID 藏在五個地方，然後期待未來的自己記得，這件事本身就很勇敢。
