# -*- coding: utf-8 -*-
#===============================================================================
# ■ Albert_RMVX_REFERENCE_Protected_IDs_v1_1_Antagonist_TC
#-------------------------------------------------------------------------------
#  Forest Symphony 森之交響曲
#  Main 以上有效腳本之「已使用／保留 ID」長篇索引
#-------------------------------------------------------------------------------
# 【用途】
#  這是一張放在 RMVX 腳本庫裡的保護名單。重新規劃資料庫 ID 前先搜尋。
#
# 【範圍】
#  依據 All_Scripts_Export(7).txt，只看 Main 以上有效腳本。
#  Main 以下腳本不列入正式衝突判定。
#
# 【重要】
#  本表分成兩層：
#    A. 已人工確認的核心保留 ID：強烈建議不要隨便改。
#    B. 靜態掃描到的直接數字引用：改 ID 前至少要同步檢查來源腳本。
#
#  「出現在註釋範例」和「執行中硬鎖」不是同一回事，因此附錄會標示來源。
#  數字看起來都一樣，後果完全不一樣。這是資料庫最擅長的低級惡作劇。
#===============================================================================

#===============================================================================
# 第一部　核心保留 ID
#===============================================================================
#
# 【Actor】
#-------------------------------------------------------------------------------
# 1：喬伊，CharacterMechanicCore 主角 ID。
# 2：米亞，CharacterMechanicCore 主角 ID。
# 3：艾卓，CharacterMechanicCore 主角 ID。
# 4：維娜，CharacterMechanicCore 主角 ID。
# 5：艾薇，CharacterMechanicCore 主角 ID。
# 6：泰勒，CharacterMechanicCore 主角 ID。
# 7-18：BattleFormula_TargetFix / Life Link / SummonGuard 使用的召喚物 Actor 範圍。
# 7：目前召喚裝備 mapping：Armor 103 → Actor 7。
# 8：目前召喚裝備 mapping：Armor 101 → Actor 8。
# 9：目前召喚裝備 mapping：Armor 105 → Actor 9；另有 Pet 系統 USE_NAME_ID = 9。
#
# 【State】
#-------------------------------------------------------------------------------
# 1：RPG Maker VX 內建戰鬥不能／死亡 State。絕對不要改用途。
# 2、3：月紳士「根據狀態選擇技能」目前 SETTING = [2,-2,3,-3]，用作 AI 行動條件。
# 13：Disappear / 消失 State，Provoke & Disappear 及 BattleFormula_TargetFix 使用。
# 14：Provoke / 挑釁 State，TargetPriority 也視為最高優先目標。
# 17：AutoBattleAI :wild。
# 18：AutoBattleAI :healy。
# 22：AutoBattleAI :protect。
# 23：AutoBattleAI :support。
# 25：AutoBattleAI :balanced。Main 以上有效腳本中目前用於 AI；Main 以下 Untargetable 不算有效。
# 50：泰勒 Break 進度／破勢 State，CharacterMechanicCore 預設。
# 51：崩防 Broken State，CharacterMechanicCore 預設。
#
# 【Skill】
#-------------------------------------------------------------------------------
# 83：月紳士エネミー行動パターン改良的「追加條件 Dummy Skill」。不要改作普通技能。
# 241 / 250 / 260 等：目前 SummonChain / Robot Protocol 註釋中的範例技能 ID，不代表已硬鎖；若資料庫正式採用需自行登記。
#
# 【Armor】
#-------------------------------------------------------------------------------
# 101：召喚裝備 mapping → Actor 8。
# 103：召喚裝備 mapping → Actor 7。
# 105：召喚裝備 mapping → Actor 9。
#
# 【CommonEvent】
#-------------------------------------------------------------------------------
# 21：BattlePopText_Note 舊普攻文字 fallback 公共事件。
# 22：BattlePopText_Note 舊技能文字 fallback 公共事件。
# 145、146、147、148、149、150、153、154：圓盤系統直接呼叫的公共事件。
#
# 【Variable】
#-------------------------------------------------------------------------------
# 201：SBS Pop Text：Battler X 座標。
# 202：SBS Pop Text：Battler Y 座標。
# 203：SBS Pop Text Skill：目前技能 ID。
#
# 【Switch】
#-------------------------------------------------------------------------------
# 121-130：月紳士 Extension_Action_Condition 的 10 個保留開關。
# 150-153：月紳士「根據狀態選擇技能」目前 4 個條件開關。
# 134-135：月紳士「根據位置選擇」目前 2 個條件開關。
# 136-137：月紳士「技能有效度」目前 2 個條件開關。
#
# 【Picture】
#-------------------------------------------------------------------------------
# 10 起：BattlePopText_Note ACTOR_PICTURE_ID_BASE = 10。
# 20：BattlePopText_Note FALLBACK_PICTURE_ID = 20。
#
# 【Element】
#-------------------------------------------------------------------------------
# 19、20：「200x/XP 機能再現 全體攻擊等」WEAPON_ELEMENTS。
# 30：Dash Action Sequence 的 DASH_ELEMENT。
#
#===============================================================================
# ===============================================================================
# 【AntagonistMechanicCore_v1_0 新增保留 State ID】
# ===============================================================================
#
# 以下 State 已被反派核心直接指定，
# 重新規劃資料庫時必須避開或同步修改腳本／Note。
#
# 【State 120｜觀律累積】
#
# 用途：
#   observe_repeat_state 的疊層State。
#
# 核心Note：
#   <observe_repeat_state:120>
#
# 建議：
#   Max Stack 5。
#
# 保護等級：
#   極高。
#
# -------------------------------------------------------------------------------
#
# 【State 121｜雙弦標記】
#
# 用途：
#   雙弦連結的標記State。
#
# 核心Note：
#   <double_thread:121,40>
#
# 保護等級：
#   極高。
#
# -------------------------------------------------------------------------------
#
# 【State 130～135｜六主角改譜State】
#
# 130 = 喬伊改譜
# 131 = 米亞改譜
# 132 = 艾卓改譜
# 133 = 維娜改譜
# 134 = 艾薇改譜
# 135 = 泰勒改譜
#
# 核心Note：
#   <rewrite_actor 1:130>
#   ...
#   <rewrite_actor 6:135>
#
# 保護等級：
#   極高。
#
# -------------------------------------------------------------------------------
#
# 【State 139｜改譜預設State】
#
# 用途：
#   沒有個別 Actor 映射時的 fallback。
#
# 核心Note：
#   <rewrite_default_state:139>
#
# 保護等級：
#   極高。
#
# -------------------------------------------------------------------------------
#
# 【State 140～143｜大諧律法則循環】
#
# 140 = 第一律
# 141 = 第二律
# 142 = 第三律
# 143 = 第四律
#
# 核心Note：
#   <law_cycle_states:140,141,142,143>
#
# 保護等級：
#   極高。
#
# -------------------------------------------------------------------------------
#
# 【State 150｜全知儀／觀律啟動】
#
# 用途：
#   啟動觀律。
#
# 核心Note：
#   <observe_if_state:150>
#
# 保護等級：
#   極高。
#
# -------------------------------------------------------------------------------
#
# 【State 151｜大諧律啟動】
#
# 用途：
#   啟動法則循環。
#
# 核心Note：
#   <law_cycle_if_state:151>
#
# 保護等級：
#   極高。
#
# -------------------------------------------------------------------------------
#
# 【State 152｜失奏】
#
# 用途：
#   賽勒斯第三階段。
#   移除151並停止140～143循環。
#
# 保護等級：
#   極高。
#
# -------------------------------------------------------------------------------
#
# 【重要修正：原ID區段規劃必須更新】
#
# 舊規劃曾建議：
#
#   150～179 = AI人格State
#
# 現在 State 150～152 已被 AntagonistMechanicCore 占用。
#
# 因此新建議：
#
#   150～152 = 反派核心硬鎖
#   153～179 = 未來AI人格State
#   180～199 = 系統隱藏State
#
# 不要把 State 150 又拿去做第二套 Wild AI。
# 一個ID同時代表「全知儀」與「野性AI」，至少在哲學上很有創意，
# 在程式上就不必了。
#
# ===============================================================================

# 第二部　腳本設定常數中的 ID／保留範圍
#===============================================================================
# [設定項目] USE_VARIABLES_ID = 101     # ペットステータスを格納する変数
# [設定項目] USE_NAME_ID = 9           # ペット名に使用するアクターID
# [Chest_Item_Pop-Up] POPUP_SWITCH = 0
# [Thomas Edison VX] KGC_DAY_NIGHT_SCRIPT_VARIABLE = 11
# [YEM Restored Functions] PICTURE_MIRROR_SWITCH = 4
# [YEM Restored Functions] PICTURE_NUMBER_VARIABLE = 1
# [YEM Restored Functions] STOP_ALL_SWITCH = 11
# [Neo Save System V] SWAP_TILE_SWITCH = 29 # The switch needs to be the same as your swap tile
# [Neo Save System V] MAP_NO_NAME_SWITCH = 30 # This switch has to be on for MAP_NO_NAME_LIST to work
# [200x/XP 機能再現 全體攻擊等] WEAPON_ELEMENTS = [19,20]
# [エネミー行動パターン改良] TOP_SWITCH = 121
# [追加：根據狀態選擇技能] TOP_SWITCH = 150
# [追加：根據狀態選擇技能] TOP_SWITCH = 21
# [追加：根據位置選擇] TOP_SWITCH = 134
# [追加：根據位置選擇] TOP_SWITCH = 14
# [追加：技能有效度] TOP_SWITCH = 136
# [追加：技能有效度] TOP_SWITCH = 16
# [Dash Action Sequence] DASH_ELEMENT = 30 # Default is 30, my Dash Element.
# [Variable Battle Scapes] BATTLE_SCAPES_VARIABLE = 1000
# [YERD_BestiaryScan] BESTIARY_SWITCH = 3             # Which switch will enable this command?
# [戰鬥畫面天氣+色調] WEATHER_SWITCH_ID = 96
# [戰鬥畫面天氣+色調] TONE_SWITCH_ID = 97
# [VX 敵人戰鬥坐標永續固定的設定] ENEMY_XY_SWITCH = 1
# [遇敵機率控制] STEPS_REMAINING_VARIABLE = 61
# [遇敵機率控制] REPEL_STEPS_VARIABLE = 62
# [遇敵機率控制] LURE_STEPS_VARIABLE = 63
# [遇敵機率控制] LURE_RATE_VARIABLE = 64
# [KGC_LargeParty] PARTYFORM_SWITCH = 18
# [KGC_LargeParty] BATTLE_PARTYFORM_SWITCH = 19
# [KGC_LargeParty] SORT_BY_ID = 0  # ID順
# [角色圖鑑] INCLUDED_ACTOR_IDS = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]
# [YEZ Job System: Base] LEARN_ENABLE_SWITCH = 44
# [MOG_顯示地名] WM_SWITCH_VIS_DISABLE = 31
# [乗り物拡張] HORSE_MAP_ID = 0
# [乗り物拡張] BIG_AIRSHIP_MAP_ID = 1
# [乗り物拡張] MAGIC_CARPET_MAP_ID = 0
# [乗り物拡張] NOT_ENCOUNTER_VEHICIE_ID = [0, 1, 2, 3, 4, 5]
# [乗り物拡張マニュアル・使い方編] NOT_ENCOUNTER_VEHICIE_ID = [3, 4, 5]
# [接金币] VAR_ID = 1
# [Provoke & Disappear State System v1.2.3] DISAPPEAR_STATE_ID = 13   # 設定「消失 (Disappear)」狀態 ID
# [Provoke & Disappear State System v1.2.3] PROVOKE_STATE_ID = 14     # 設定「挑釁 (Provoke)」狀態 ID
# [YEZ Job System: Skill Levels] LEVEL_ENABLE_SWITCH = 45
# [BattleFormula_TargetFix] MAIN_ACTOR_MAX_ID = 6
# [BattleFormula_TargetFix] SUMMON_ACTOR_IDS = [7, 8, 9, 10, 11, 12,
# [BattleFormula_TargetFix] DISAPPEAR_STATE_ID = 13
# [BattleFormula_TargetFix] PROVOKE_STATE_ID = 14
# [BattleUtility_IntegrationFix] LIFE_LINK_MAIN_ACTOR_MAX_ID = 6
# [BattleUtility_IntegrationFix] LIFE_LINK_SUMMON_ACTOR_IDS = [7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18]
# [TargetPriority_SelectionFix] PROVOKE_STATE_ID = 14
# [RMVX_ComboCore_AllInOne_v1_1_OD] COVER_ANIMATION_ID = 0       # > 0：保護者承傷時播放動畫 ID
# [CharacterMechanicCore_v1_0_TC] JOEY_ACTOR_ID = 1
# [CharacterMechanicCore_v1_0_TC] MIA_ACTOR_ID = 2
# [CharacterMechanicCore_v1_0_TC] AIZHUO_ACTOR_ID = 3
# [CharacterMechanicCore_v1_0_TC] VINA_ACTOR_ID = 4
# [CharacterMechanicCore_v1_0_TC] IVY_ACTOR_ID = 5
# [CharacterMechanicCore_v1_0_TC] TYLER_ACTOR_ID = 6
# [CharacterMechanicCore_v1_0_TC] BREAK_PROGRESS_STATE_ID = 50
# [CharacterMechanicCore_v1_0_TC] BROKEN_STATE_ID = 51
# [BattlePopText_Note] OLD_ATTACK_COMMON_EVENT_ID = 21
# [BattlePopText_Note] OLD_SKILL_COMMON_EVENT_ID = 22
# [BattlePopText_Note] ACTOR_PICTURE_ID_BASE = 10
# [BattlePopText_Note] FALLBACK_PICTURE_ID = 20
# [BattlePopText_Note] JOEY_ACTOR_ID = 1
#
#===============================================================================
# 第三部　目前已確認的特殊 Mapping / Hash
#===============================================================================
# [臨時加入 / Summon Equipment Mapping]
# Armor 101 → Actor 8
# Armor 103 → Actor 7
# Armor 105 → Actor 9
#
# [AutoBattleAI STATE_AI_MAPPING]
# State 18 → :healy
# State 22 → :protect
# State 23 → :support
# State 17 → :wild
# State 25 → :balanced
#
# [SummonGuard SUMMON_GROUPS]
# Group 1 → Actor 7..18
# Group 2 → Actor 7
# Group 3 → Actor 8
# Group 4 → Actor 9
#
# [月紳士追加行動條件]
# Extension_Action_Condition TOP_SWITCH = 121，保留 121..130
# ADDITION_CONDITION_SKILL = Skill 83
# EacAdd_State_Condition TOP_SWITCH = 150，SETTING = [2,-2,3,-3]
# EacAdd_Position_Target TOP_SWITCH = 134，SETTING = [-3,3]
# EacAdd_Effective_Rank TOP_SWITCH = 136，SETTING = [2,3]
#
#===============================================================================
# 第四部　Main 以上直接數字引用掃描
#===============================================================================
# 說明：只列出程式碼中直接寫出的 $data_xxx[n]、$game_switches[n]、
#       $game_variables[n]、add_state(n) 等高可信引用。
#       註釋中的引用會標成「註釋」，真正程式碼標成「執行」。
#
# 【Actor】
#-------------------------------------------------------------------------------
# ID 1：STR20_入手インフォメーション v1.2 / YERD_EnemyLevelControl / 臨時加入 / 乗り物拡張 / 描繪屬性（註釋）
#
# 【Item】
#-------------------------------------------------------------------------------
# ID 1：Neo Database Text / 读取rmvx备注栏（註釋）
# ID 155：圓盤系統
# ID 171：圓盤系統
# ID 184：圓盤系統
#
# 【Armor】
#-------------------------------------------------------------------------------
# ID 86：Custom Dmg Formulas RD
# ID 87：Custom Dmg Formulas RD
# ID 88：Custom Dmg Formulas RD
# ID 89：Custom Dmg Formulas RD
# ID 90：Custom Dmg Formulas RD
# ID 91：Custom Dmg Formulas RD
# ID 93：Custom Dmg Formulas RD（註釋）
# ID 94：Custom Dmg Formulas RD
# ID 212：Custom Dmg Formulas RD
# ID 213：Custom Dmg Formulas RD
#
# 【State】
#-------------------------------------------------------------------------------
# ID 1：Game_Battler / YEM Main Menu Melody（註釋） / YEM Main Menu Melody / Sideview 2 (3.4d) / ATB (1.2c)-0627 / Animation Overlay Patch / 物品打星星
# ID 2：YEM Main Menu Melody / Custom Dmg Formulas RD / Custom Dmg Formulas RD（註釋）
# ID 3：YEM Main Menu Melody / YERD_TargetEffects（註釋）
# ID 4：YEM Main Menu Melody
# ID 5：YEM Main Menu Melody
# ID 6：YEM Main Menu Melody
# ID 7：YEM Main Menu Melody
# ID 8：YEM Main Menu Melody
# ID 9：YEM Main Menu Melody
# ID 10：YEM Main Menu Melody
# ID 11：YEM Main Menu Melody
# ID 12：YEM Main Menu Melody
# ID 13：目標過濾-new
# ID 36：Sideview 1 (3.4d)（註釋） / Animation Overlay Patch
#
# 【Switch】
#-------------------------------------------------------------------------------
# ID 23：乗り物拡張
# ID 27：Counterattack State v1.3.1 (修正版)
# ID 32：圓盤系統
# ID 36：Scene_Battle（註釋） / Sideview 2 (3.4d)（註釋） / ATB (1.2c)-0627（註釋）
# ID 37：地圖技能 / 乗り物拡張
# ID 50：Window_ShowD / Window_ShowD備份 / Scene_Battle（註釋） / Scene_Battle / Sideview 2 (3.4d) / Window_FriendInfo / ATB (1.2c)-0627（註釋） / ATB (1.2c)-0627
#          ...另 2 個來源
# ID 139：圓盤系統
# ID 140：圓盤系統
# ID 141：圓盤系統
# ID 142：圓盤系統
# ID 143：圓盤系統
# ID 144：圓盤系統
# ID 202：乗り物拡張
# ID 203：Game_Player（註釋） / 乗り物拡張（註釋） / 乗り物拡張
# ID 204：乗り物拡張 / 乗り物拡張（註釋）
# ID 473：YEZ Custom Status Properties
#
# 【Variable】
#-------------------------------------------------------------------------------
# ID 1：選擇物品小視窗（註釋） / SSS - Minigame Bull's Eye（註釋） / SSS - Minigame Slot Machine（註釋） / SSS - Minigame Button Mash（註釋） / SSS - Minigame Input Match（註釋）
# ID 4：圓盤系統
# ID 90：YEZ Status Command Menu（註釋）
# ID 101：設定項目
# ID 102：設定項目 / YERD_EnemyLevelControl
# ID 105：Custom Dmg Formulas RD
# ID 108：YERD_EnemyLevelControl
# ID 121：Window_ShowD / Window_ShowD備份 / Window_FriendInfo
# ID 200：YERD_TargetEffects（註釋） / YERD_TargetEffects
# ID 201：SBS Battler Configuration (K) / BattlePopText_Note
# ID 202：SBS Battler Configuration (K) / BattlePopText_Note
# ID 203：SBS Battler Configuration (K) / BattlePopText_Note
# ID 210：YERD_TargetEffects（註釋）
# ID 302：YEZ Custom Status Properties
#
# 【CommonEvent】
#-------------------------------------------------------------------------------
# ID 145：圓盤系統
# ID 146：圓盤系統
# ID 147：圓盤系統
# ID 148：圓盤系統
# ID 149：圓盤系統
# ID 150：圓盤系統
# ID 153：圓盤系統
# ID 154：圓盤系統
#
#===============================================================================
# 第五部　其他值得避開的 Switch / Variable / Common Event
#===============================================================================
# Switch 50：Window_ShowD / Scene_Battle 相關召喚或顯示流程直接使用。
# Switch 32、139、140、141、142、143、144：圓盤系統直接使用。
# Switch 202、203、204、473：其他有效腳本中有直接引用，改前請全域搜尋。
# Variable 4：圓盤系統劇情狀態。
# Variable 90、101、102、105、108、121、200、201、202、203、210、302：
#   皆在 Main 以上腳本出現直接引用；201-203 尤其是 Pop Text / SBS 核心。
# Common Event 145-150、153、154：圓盤系統。
#
# 建議新規劃時，直接預留整段區域：
#   Actor    1-6 主角；7-99 召喚物／特殊角色
#   State    1 保留死亡；13/14 系統；17/18/22/23/25 AI；50/51 Break
#   Switch   避開 121-130、134-137、150-153，以及上方直接引用
#   Variable 避開 201-203
#
# 最安全原則：要改任何已使用 ID，先在「本腳本索引」與全腳本匯出檔同時搜尋。
