#==============================================================================
# ■ FS_Battle_Authority_Map v2.5
#------------------------------------------------------------------------------
# Forest Symphony / RPG Maker VX / RGSS2
# Phase 6：戰鬥 Patch Chain / Authority 梳理
#
# 【目的】
#   這頁只記錄「目前實際載入後，誰是最後一層／哪條鏈不能亂搬」。
#   不執行任何 Runtime 程式碼。
#
# 【重要原則】
#   1. Base Plugin 先載入，Compatibility / Fix 在後。
#   2. 下列「Final」指的是目前 Scripts.rvdata 的最後 method 外層包裝，
#      不代表前面的 Base 可以刪；多數 Final 會呼叫 previous alias。
#   3. Phase 6 只合併本來就相鄰的頁面，不重排跨區依賴。
#
#==============================================================================
# [TGT] Targeting / Target Selection
#------------------------------------------------------------------------------
# Game_BattleAction#make_obj_targets 主要鏈：
#   VX Core
#   -> YERD_TargetEffects
#   -> FS_DynamicThreat_Targeting v2.2
#   -> Provoke & Disappear
#   -> TargetPriority_SelectionFix
#   -> TargetGroup_System
#   -> Target Selection Exact
#   -> FS_MarkedCommand_ConditionTransparency
#   -> FS_EquipmentCombo_OpeningSkillFix v1.3   [目前最後 外層包裝]
#
# Game_BattleAction#make_attack_targets：
#   VX Core
#   -> 200x/XP 全體攻擊等
#   -> Friendly Monsters
#   -> KGC_AddEquipmentOptions
#   -> Provoke & Disappear
#   -> TargetPriority_SelectionFix
#   -> Target Selection Exact
#   -> FS_SoulMark_Resonance_Expansion v2.1.2  [目前最後 外層包裝]
#
# Game_Unit#random_target：
#   VX Core
#   -> Provoke & Disappear
#   -> FS_RandomTarget_Authority v1.2           [目前 Authority]
#
# Scene_Battle#start_target_selection：
#   SBS / ATB
#   -> 目標過濾-new
#   -> TargetPriority_SelectionFix
#   -> TargetGroup_System
#   -> Target Selection Exact
#   -> FS_MarkedCommand_ConditionTransparency   [目前最後 外層包裝]
#
# Scene_Battle#update_target：
#   SBS / ATB
#   -> TargetPriority
#   -> TargetGroup
#   -> Exact Target
#   -> BattleIntegrityFix
#   -> FS_MarkedCommand
#   -> FS_BattleTargetUI_Authority              [HUD/Lifecycle 最後 外層包裝]
#
#==============================================================================
# [DMG] Damage / Hit / State Runtime
#------------------------------------------------------------------------------
# Game_Battler#calc_hit / calc_eva：
#   VX Core -> FS_BattleFormula_Authority v1.2 -> SupportStateSkillRules                    [目前最後 外層包裝]
#
# Game_Battler#make_obj_damage_value：
#   舊插件層很多；FS Battle Formula / Combo / CharacterMechanic /
#   MechanicExpansion / BattleIntegrity / FieldWeather / SoulMark 等依序疊加。
#   FS_MarkedCommand_ConditionTransparency 為目前最後 外層包裝 之一。
#   不可把任何單一中間層當成可獨立刪除。
#
# Game_Battler#execute_damage：
#   DPS / SBS / OD / DynamicThreat / State / Counter / Combo / Mechanic /
#   Antagonist / IvyClone -> FS_MarkedCommand     [目前最後 外層包裝]
#
#==============================================================================
# [SUMMON] Summon
#------------------------------------------------------------------------------
# EnemySummon_Core v1.1（含 SafePosition）
#   -> SummonChain3 / Boss Runtime 等使用者
#   -> AutoSetup_12｜FS_EnemySummonGuard_FinalAuthority
#   -> SummonTemporaryBattle / DatabaseSync
#
# Summon UI：
#   SummonUI_v2_3 -> SummonUI_v2_8_CompactOverride
#   Phase 6 已收斂為 FS_SummonUI_Authority v2.8。
#
#==============================================================================
# [HUD] Battle Target UI
#------------------------------------------------------------------------------
# Albert_RMVX_BattleStateHUD_Core_v2_5_1_TC
#   -> FS_BattleTargetHUD_LayoutPatch v1.4.1
#   -> FS_BattleTargetHUD_NameCenterFix
#   -> FS_BattleStateHUD_Lifecycle_TargetOverlay v1.1
#   Phase 6 收斂後：FS_BattleTargetUI_Authority v1.4.1。
#
#==============================================================================
# 【未來修改規則】
#   - 修 Targeting：先查 [TGT]，不要直接再加一個 TargetFixFinal。
#   - 修 Damage：先查 [DMG] 的最後 外層包裝，再決定應併回哪個 Authority。
#   - 修 Summon UI：直接修改 FS_SummonUI_Authority。
#   - 修 Battle Target HUD：直接修改 FS_BattleTargetUI_Authority。
#==============================================================================

#==============================================================================
# [PHASE 7] Canonical Battle Authorities
#------------------------------------------------------------------------------
# 【Summon Runtime】
#   FS_SummonRuntime_Authority v2.0.1
#     = SummonTemporaryBattle v2.0
#       -> SummonTemporaryBattle_DatabaseSync v2.0.1
#   戰鬥加入／離隊與資料庫身分同步，今後優先修改此 Authority。
#
# 【Summon Equipment Page】
#   FS_EquipSummonPage_Authority v1.0
#     = Equip_SummonPage_Extension
#       -> Equip_SummonPage_SkillElementIcon
#   召喚物裝備頁顯示、資料同步、技能屬性 Icon 由此負責。
#
# 【Summon Battle UI】
#   FS_SummonUI_Authority v2.8
#   只負責戰鬥中的召喚 UI；不要與 EquipSummonPage 混為同一層。
#
# 【Equipment Combo】
#   FS_EquipmentCombo_Base v1.1
#     -> FS_BattleIntegrity_Authority v1.0
#     -> FS_EquipmentCombo_OpeningSkillFix v1.3 [目前最後開場技 外層包裝]
#
# 【Battle State HUD】
#   FS_BattleStateHUD_Core v2.5.1 TC
#     -> FS_BattleStateHUD_BreakZeroHide v1.0
#     -> FS_MarkedCommand_ConditionTransparency
#     -> FS_BattleTargetUI_Authority v1.4.1
#   注意：BreakZeroHide 不能任意前移；MarkedCommand 後續仍包裝 extra_info_rows。
#
# 【Steal / Capture Result】
#   KGC_Steal｜Base + Tankentai Compatibility
#     -> FS_DynamicCaptureRate v1.4
#     -> FS_SoulRepeatRecipe v1.1.2
#     -> FS_StealResult_Authority v1.0
#     -> FS_SoulMark_Resonance_Expansion v2.1.2 等後續經濟／共鳴規則
#   StealResult Authority 負責 Tankentai 判定補強＋成功/失敗 SE。
#
# 【SBS Pure Presentation Bridge】
#   FS_SBS_PresentationBridge_Authority v1.0.1
#     = 戰鬥 SBS 純演出 Bridge -> 地圖 SBS 純演出 Adapter
#   不負責實際技能效果；真正強制行動仍由 FS_ForceAction_Bridge 處理。
#==============================================================================

#==============================================================================
# [PHASE 8] Cross-page chains that intentionally remain staged
#------------------------------------------------------------------------------
# 【EquipmentCombo 不是單頁 Authority 的原因】
#   FS_EquipmentCombo_Base v1.1
#     -> FS_BattleIntegrity_MultiFix_Authority v1.0
#     -> FS_ATB_DynamicResistance / FS_StateEffects / FS_IvyClone 等會檢查或
#        alias albert_combo_* API
#     -> FS_EquipmentCombo_OpeningSkill_FinalAuthority v1.3
#   因此 Base 不可延後、Final 不可提前。這是刻意保留的 分階段依賴鏈。
#
# 【BattleStateHUD 分階段依賴鏈】
#   FS_BattleStateHUD_Core v2.5.1 TC
#     -> FS_BattleStateHUD_Hotfix_BreakZeroHide v1.0
#     -> FS_MarkedCommand_ConditionTransparency v1.6
#     -> FS_BattleTargetUI_Authority v1.4.1
#   MarkedCommand 會再包 extra_info_rows / target selection；TargetUI 又接管 HUD
#   placement/lifecycle，因此目前維持順序比物理相鄰更重要。
#
# 【Element layers｜Phase 28】
#   FS_ElementTypeAndUI_Provider v1.1
#     = 唯一 FS_ELEMENT_TYPE_DATA / Pokemon 雙屬性資料 / UI Provider，不再覆寫最終倍率。
#   KGC_AddEquipmentOptions
#     = Actor 裝備 Element Data Provider（resist/weak/guard/invalid/absorb）。
#   FS_ActorEnemyGrowth_Authority v2.1
#     = Growth 資料 Provider；USE_ENEMY_ELEMENT_RATE 由 FinalAuthority 讀取。
#   FS_BattleBalanceCore v1.4
#     = 傷害平衡，不再擁有 element_rate wrapper。
#   FS_ElementRate_FinalAuthority v2.0
#     = 唯一 element_rate / elements_max_rate Final Authority。
#   FS_SupportStateSkillRules
#     = 最後只包 max_rate_for，讓回復／Note 狀態技能視為 100% 中立屬性。
#
# 【Growth layers】
#   FS_ActorEnemyGrowth_Authority v2.0
#     = ActorEnemyGrowth -> HPMP_Scale_Growth
#   後續 CharacterMechanic / Summon / Database setup 只在其上擴充，不應把
#   HPMP Scale 移到 ActorEnemyGrowth 前方。
#==============================================================================

#==============================================================================
# [PHASE 10] AI / Targeting / Formula consolidation
#------------------------------------------------------------------------------
# 【AutoBattleAI】
#   FS_AutoBattleAI_Authority v2.1
#     = 基礎 make_action 快照 + DamageEval + Integration + 晚綁定 Mechanic 掛鉤
#   FS_MechanicExpansion 仍提供 albert_mx_ai_* 與 Robot Protocol，但 Phase 11 起已不再
#   包裝 albert_ai_damage_score／note_bonus／五種 package／process_ai_package／make_action。
#   因此 AI 核心責任歸屬回到單一 Authority；MechanicExpansion 是「掛鉤提供者」而非外層包裝。
#
# 【Targeting】
#   YERD_TargetEffects
#     -> SummonGuard_DynamicThreat_v2
#     -> Provoke & Disappear
#     -> FS_TargetingCompatibility_Layer v1.1
#     -> FS_TargetGroupExact_Authority v2.1
#     -> FS_MarkedCommand_ConditionTransparency
#     -> FS_BattleTargetUI_Authority（Scene_Battle UI／Lifecycle 後段）
#   注意：TargetGroup + Exact 已物理合併，但不代表前後 分階段依賴鏈 可以重排。
#
# 【Hit Formula】
#   FS_BattleFormula_Authority v1.1 的 calc_hit 已直接包含技能等級命中加成，
#   不再透過 albert_bfrt_old_calc_hit 自我 alias；後方 SupportStateSkillRules 仍可能包裝。
#==============================================================================

#==============================================================================
# 【Phase 11：AutoBattleAI／MechanicExpansion 去 Alias】
#------------------------------------------------------------------------------
# 最終 AI 方法責任：
#   Game_Actor#make_action                -> FS_AutoBattleAI_Authority v2.1
#      晚綁定： albert_mx_try_robot_protocol
#   Game_Actor#albert_ai_damage_score    -> FS_AutoBattleAI_Authority v2.1
#      晚綁定： albert_mx_ai_target_condition_pass? / target_bonus
#   process_wild/balanced/healy/protect/support -> FS_AutoBattleAI_Authority v2.1
#      晚綁定： albert_mx_ai_filter_actions
#   process_ai_package                   -> FS_AutoBattleAI_Authority v2.1
#      晚綁定： albert_mx_ai_has_target_tags? / valid_targets / target_bonus
#
# 仍需注意：後方 Robot Fixed / Enemy Action / 其他專案頁仍可能再包 make_action；
# Phase 11 只解除 MechanicExpansion 這一層，不宣稱整條 make_action chain 已單一化。
#==============================================================================

#==============================================================================
# 【Phase 12：Game_Actor#make_action / Robot 最終責任】
#------------------------------------------------------------------------------
# Robot / AutoBattle Actor 的最終專案層責任：
#   FS_AutoBattleAI_Authority v2.2
#     - 一般 AutoBattle package 決策
#     - late-bound Mechanic target hooks
#     - Robot Protocol 優先
#     - Robot 非協議回合固定普通攻擊
#
# FS_DatabaseSupport_Authority v2.2 CompactID：
#     - 不再包裝 make_action
#     - 只負責 Compact ID、Lv60、成長、EquipmentCombo 安全門、ArmorMapping 遷移
#
# 已退休 Runtime：6主角＋5映體＋5機器人資料庫 v2.0。
# 它曾在 v2.1 CompactID 後方再次寫入 Robot Skill 857～861、Armor 732～741、
# Growth Enemy 746～755，形成「新版先套、舊版再覆蓋」的反向 Authority。
# Phase 12 已移除此反向覆蓋。
#==============================================================================

#==============================================================================
# 【Phase 13：BattleStateHUD 詳細資訊列最終責任】
#------------------------------------------------------------------------------
# AlbertBattleStateHUD.extra_info_rows：
#   FS_BattleStateHUD_Authority v2.6.0 TC   ← 唯一正式 def
#
# 晚綁定 Provider：
#   FS_ActorProfile v2.1.1 HUD
#     -> clone_stability_rows（只提供 Clone 穩定度資料）
#   FS_MarkedCommand_ConditionTransparency v1.6
#     -> FS_MARKED_COMMAND.role_text（只提供職能文字）
#
# 已整合退休：
#   FS_BattleStateHUD_Hotfix_BreakZeroHide v1.0
#     -> 行為已回寫 break_rows；完整舊碼保留於 Project History／外部 Archive。
#
# 注意：FS_BattleTargetUI_Authority v1.4.1 仍是後載入 UI/Lifecycle Authority，
# 但不接管 extra_info_rows。不得因 extra_info_rows 已單一化就提前搬動 TargetUI。
#==============================================================================

#==============================================================================
# 【Phase 19：Steal / BattleStatusHUD 最終責任補記】
#------------------------------------------------------------------------------
# 【Steal / Capture】
#   KGC_Steal｜Base + Tankentai Compatibility
#     -> FS_DynamicCaptureRate v1.4
#          最終重寫 Game_Battler#make_obj_steal_result 的魂刻動態成功率基礎。
#     -> FS_SoulRepeatRecipe v1.1.2
#          display_steal_item 的首次／重複汲取經濟規則。
#     -> FS_SkillCost_AllFix v1.1.1
#          汲取分支 MP 成本／Action Cost 相容。
#     -> FS_StealResult_Authority v1.0
#          make_obj_steal_result / skill_effect / execute_action_steal /
#          display_steal_effects 的最終 Tankentai 安全包裝與結果 SE。
#   因上述中間層都具有真實 Runtime 責任，Phase 19 不物理合併。
#
# 【Battle Status Skin】
#   BattleStatusHUD_Core｜0226
#     -> STR11+og_KGC Overdrive
#     -> 後續 ATB/SBS/UI 整合。
#   本頁是隊伍底部 Skin/HP/MP/OD 數字核心；FS_BattleStateHUD_Authority v2.6.0
#   則是額外狀態資訊／Target Detail Provider，兩者不應合併成單一巨型 HUD。
#==============================================================================

# [PHASE 20] Enemy Summon responsibility cleanup
#   EnemySummon_Core v1.1 = modern algebra Enemy Summon + SafePosition。
#   SafePosition 不再位於 TargetingCompatibility；TargetingCompatibility v1.1 專心處理
#   TargetPriority / RandomTarget。Final Guard 仍由 AutoSetup_12 後載入層負責。

# [PHASE 21] Friendly Monsters
#   FriendlyMonsters_Core v1.1 已直接使用 friendly_gold；原 FS_FriendlyMonsters_GoldFix 不再是 Runtime page。
#   BattleResultStats 仍在後方包 Game_Troop#gold_total 套 Bonus，兩者責任分離。
# [PHASE 21] Testability
#   Setup / AI / Equipment 整理完成後，戰鬥 Authority 必須提供可被 FS_TestHarness 注入的 deterministic fixture / log hook；
#   不再依賴玩家手動選招來驗證戰鬥鏈。


#==============================================================================
# 【Phase 23：AI Authority / Deterministic Random Test Hook】
#------------------------------------------------------------------------------
# AI Runtime 的責任鏈正式分為四層：
#
# [ACTOR]
#   VX Game_Actor#make_action
#     -> ActorActionPattern_Bridge v2.10（State 驅動的敵方行動表擬似 AI）
#     -> FS_AutoBattleAI_Authority v2.3（正式 Actor / Robot AI Authority）
#          -> 執行時晚綁定 FS_MechanicExpansion 的 albert_mx_ai_* Provider
#
# [ENEMY]
#   VX Game_Enemy#make_action
#     -> EnemyActionPattern_Core v8.02（條件 + rating roulette + target condition）
#     -> FriendlyMonsters_Core（只包 faction context）
#     -> FS_EnemyActionDistribution_FinalAuthority v1.1
#          （Pokemon enemy 600～745 最後可依比例改為普通攻擊）
#
# [BOSS / ANTAGONIST]
#   SetupRuntime_09 Boss Runtime / AI Provider
#     -> 動態覆寫 candidate_actions_enemy；不重新定義 make_action。
#   FS_AntagonistMechanicCore
#     -> Law Cycle / Observer / Link 等機制；不是通用 make_action Authority。
#
# [TARGET]
#   YERD_TargetEffects
#     -> FS_DynamicThreat_Targeting v2.2
#     -> Provoke & Disappear
#     -> FS_RandomTarget_Authority v1.2
#     -> FS_TargetGroupExact_Authority
#     -> MarkedCommand / TargetUI 後段
#
# [RANDOM]
#   FS_AI_DeterministicRandom v1.0 必須位於上述 AI Runtime 之前。
#   正常遊戲：FS_AI_RANDOM.rand(...) 直接委派 Kernel.rand(...)，不改亂數行為。
#   $TEST + 明確 enable(seed)：使用固定 LCG，並記錄 tag / max / result trace。
#   Phase 23 已將 Enemy Action roulette、DynamicThreat、Actor AutoBattle、
#   RandomTarget、Robot Protocol target、Boss summon、EnemyActionDistribution 的
#   AI 隨機入口導向 FS_AI_RANDOM。
#
# 注意：YERD custom target、命中／狀態成功率、傷害 variance 等「戰鬥機制亂數」
# 尚未納入本 AI Provider；它們會在正式 Battle Test Harness 階段另建 Combat RNG 層。
#==============================================================================


#==============================================================================
# 【Phase 24：Skill Cost Authority】
#------------------------------------------------------------------------------
# [DATA / UI BASE]
#   SkillCost_LegacyBase｜Holy87 Parser / UI / Battle Timing Bridge
#     -> Skill_Costs constants / RPG::Skill legacy accessors / Window_Skill legacy UI
#     -> Scene_Battle timing bridge（只保留既有支付時點）
#
# [COOLDOWN MODIFIER]
#   H87_SkillDelay
#     -> skill_can_use? cooldown / battle delay / step delay
#
# [LEVEL COST MODIFIER]
#   YEZ Job System: Skill Levels
#     -> apply_level_cost(cost, skill) Provider only
#
# [FINAL AUTHORITY]
#   FS_SkillCost_Authority v2.0.0
#     -> note parse / cache rebuild
#     -> calc_mp_cost / calc_hp_cost / calc_gold_cost / calc_var_cost
#     -> calc_item_cost / calc_angry_cost / state requirement
#     -> skill_can_use? extra cost checks
#     -> Scene_Skill full payment
#     -> Scene_Battle MP + Angry final payment
#     -> Window cost display
#
# [POST RESTRICTION]
#   MarkedCommand skill_can_use? 等後段機制仍可再限制技能使用；
#   但不得重新計算或重複支付 Skill Cost。
#==============================================================================


#==============================================================================
# 【Phase 25｜Skill Effect Authority Pipeline】
#------------------------------------------------------------------------------
# Script-load 主鏈：
# VX -> Sideview -> KGC OverDrive -> EnemyLevel -> BestiaryScan -> KGC Steal
# -> FieldEffect -> Cover -> ComboCore -> CharacterMechanic -> MechanicExpansion
# -> Antagonist -> ActorProfile -> StateEffects -> IvyClone -> FieldWeather
# -> SoulMark -> StealResult -> SupportState -> PokemonFollowup。
#
# Database-load 晚安裝：AutoSetup_01 Skills::install_runtime_patch
# -> 包住當時最終 skill_effect -> 處理 <fs_user_add_state:ID>。
#
# Phase 25：CharacterMechanic / MechanicExpansion / StateEffects / IvyClone
# 各自 2 -> 1 skill_effect def；Main 前靜態定義總數 25 -> 21。
#==============================================================================

#==============================================================================
# [PHASE 26] Damage Pipeline / Direct-override audit
#------------------------------------------------------------------------------
# 【Hit / Eva】
#   YEZ Skill Levels 的 calc_hit_jpsl 已退休。
#   FS_BattleFormula_Authority v1.2 為主 calc_hit/calc_eva。
#   calc_eva 直接保留 KGC ReproduceFunctions：普通攻擊 user.ignore_eva => eva 0。
#   FS_SupportStateSkillRules 在後方處理 Recovery / Note-chance 必中與零迴避。
#
# 【Skill / Item Damage】
#   Game_Battler#make_obj_damage_value 仍為 Staged Pipeline，不可單頁化：
#   BattleResultStats -> SkillActivation -> KGC Equipment -> CustomDamage -> Cover
#   -> YEZ SkillLevel Damage -> IntegerFix -> BattleFormula SmoothDefense
#   -> SummonEquip -> Combo -> Character -> MechanicExpansion -> BattleIntegrity
#   -> ActorProfile -> StateEffects -> IvyClone -> FieldWeather -> SoulMark
#   -> SupportState -> MarkedCommand。
#
# 【Normal Attack Damage】
#   BattleResultStats -> KGC Equipment -> CustomDamage -> IntegerFix -> BattleBalance
#   -> Combo -> StateEffects -> IvyClone -> FieldWeather -> SoulMark。
#
# 【Execute Damage】
#   DPS / SBS / OD / DynamicThreat / IntegerFix / RecoveryBlock / Counter
#   -> Combo / Character / MechanicExpansion / Antagonist / IvyClone / MarkedCommand。
#
# 【注意】Phase 26 只移除可證明已被最終 BattleFormula 取代的 calc_hit_jpsl，
#   並修復 Direct Override 遺漏的 ignore_eva；其他 Damage wrappers 保留至逐層等價驗證。
#==============================================================================

#==============================================================================
# [PHASE 27] Residual / Drain / Leech Authority
#------------------------------------------------------------------------------
# Scene_Battle#hp_slip_damage / mp_slip_damage：
#   ATB Base -> FS_StateEffects_Integration v3.3 [Final Residual Authority]
#
# CSP CLOSE effect `寄生種子`：
#   FS_BattleUtility Runtime dispatch -> 執行時方法解析
#   -> FS_StateEffects_Integration#albert_csp_leech_seed [唯一正式實作]
#
# VX Absorb/Drain：
#   make_obj_absorb_effect -> @absorbed -> execute_damage -> user HP/MP 回復。
#
# SoulMark Drain：
#   FS_SOULMARK_RESONANCE.apply_soul_post_effect
#   -> actual_damage -> effects[:drain]。
#   此路徑是 SoulArt post-effect，Phase 27 暫不改寫成 VX @absorbed，避免 popup /
#   timing / dispel / break 等 post-effect 順序改變。
#
# Legacy Armor 212 Drain：
#   Custom Dmg Formulas -> attacker.force_damage -> Tankentai Sprite force_damage。
#   屬裝備／演出耦合，延後到 Equipment Authority 階段。
#==============================================================================
