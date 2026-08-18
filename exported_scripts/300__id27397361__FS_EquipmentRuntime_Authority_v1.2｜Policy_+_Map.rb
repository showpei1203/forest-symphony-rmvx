#==============================================================================
# 【Forest Symphony｜Equipment Runtime Authority v1.2｜Policy + Map｜Phase 31】
#------------------------------------------------------------------------------
# 【用途】Forest Symphony 裝備 Runtime 共用政策＋責任地圖。Phase 31 起集中「裝備本身決定的戰鬥政策」，避免 Magic ID 留在通用 Damage Formula。
# 【目的】回答「裝備資料改哪裡、技能從哪裡來、換裝誰最後處理、召喚裝備如何
#         分流、Combo／開場技／UI／存檔 Mapping 各由誰負責」。
# 【維護規則】不要因腳本名稱都含 Equip 就合併；先依下列 8 個責任層判斷。
#==============================================================================
#
$imported = {} if $imported == nil
$imported["FS Equipment Runtime Authority"] = "1.2"

module FS_EQUIPMENT_RUNTIME
  ARMOR_ATTACK_DRAIN_ID = 212

  #--------------------------------------------------------------------------
  # ○ Armor 212 普攻吸血政策
  #   Phase 30 以前位於 Custom Dmg Formulas RD：
  #     attacker.force_damage -= damage / 2
  #   Tankentai 稍後才把負 force_damage 套成使用者 HP 回復與 Popup。
  #   本 Provider 只移轉 Equipment Policy ownership，不改計算與套用時點。
  #--------------------------------------------------------------------------
  def self.queue_legacy_attack_drain(attacker, damage)
    return if attacker == nil
    return unless attacker.respond_to?(:armors)
    armor = $data_armors[ARMOR_ATTACK_DRAIN_ID]
    return unless attacker.armors.include?(armor)
    attacker.force_damage -= damage / 2
  end
end

# 1. EQUIPMENT DATA AUTHORITY
#------------------------------------------------------------------------------
# FS_MasterSetup 09｜Equipment / 鳴刻冠
#   → Weapon / Armor 正式資料唯一來源。
# AutoSetup_04 / 05
#   → Engine Adapter；Phase 22 起不再保存第二份正式 Equipment Data。
# FS_MasterSetup 18 Apply
#   → Authority Data → $data_weapons / $data_armors。
#
# 2. BASE EQUIPMENT RUNTIME
#------------------------------------------------------------------------------
# VX Game_Actor / Scene_Equip / Window_Equip
#   ↓
# KGC PassiveSkill｜Passive Data / Runtime Provider
#   - 被動技能資料、learn/forget/setup/discard 後刷新。
#   - Phase 29 起不再早期包 change_equip。
#   ↓
# KGC_AddEquipmentOptions
#   - 裝備元素／State／特殊效果資料 Provider。
#   ↓
# YEM Equipment Overhaul｜FS CoreSafe v1.1
#   - 動態欄位、equip_type、extra armor、requirements、optimize 等核心 Runtime。
#   - Phase 30 已直接整合 equip_type／欄位增刪／purge／equip_legal_slot 六項安全修正。
#   ↓
# FS_YEM_EquipmentUI_SafetyPatch v1.1
#   - 只保留 UI cache、召喚預覽、Optimize、Scene_Equip 等後載相容責任。
#
# 3. EQUIPMENT SKILL AUTHORITY
#------------------------------------------------------------------------------
# FS_EquipmentSkill_Authority v2.1
#   來源 A：Modern Algebra \ls[skill_id, level_min]
#   來源 B：Shanghai <equipskill: x,...>
#   - Actor.skills 最終裝備技能來源／去重
#   - 換裝、setup、level_up 後全量同步 \ls 技能
#   - Item 教技能（level >= level_min）
#   - skill_can_use? learned-list 安全門
#   - 完整換裝狀態確定後刷新 KGC PassiveSkill
#   Phase 29 已退休兩個舊獨立 Runtime Page：
#     Skill Teaching Equipment & Items (MA)
#     Equipment Skills
#
# 4. EQUIPMENT COMBO STAGED CHAIN
#------------------------------------------------------------------------------
# FS_EquipmentCombo_Base v1.2
#   → combo tag / active equips / combo skills / actor states / change_equip refresh
#   ↓
# FS_BattleIntegrity_MultiFix_Authority
#   → SummonEquip mapping / ATB / multi-hit 等修正；Phase 31 不再擁有 Combo prepare。
#   ↓（中間仍有 State / Mechanic / Battle Runtime）
# FS_EquipmentCombo_OpeningSkill_FinalAuthority v2.0
#   → 唯一 albert_prepare_equipment_combo_battle_effects
#   → Scope-aware 實體目標鎖定
#   → 本場新加入 Combo State ownership 登記
#
# Base 與 Final 仍是 Staged Authority：Base 的 process_battle_start hook 必須先存在；
# Final 位於 Target Runtime 後方，才能取得最終實體目標鎖定能力。Phase 31 已移除中間兩層 prepare override。
#
# 5. SUMMON EQUIPMENT
#------------------------------------------------------------------------------
# ArmorMapping Storage：FS_GlobalRuntime_Utilities
# Mapping Data / Migration：FS_DatabaseSupport_Authority v2.3
# New Game / Load normalization：FS_SaveCompatibilityCore v1.1
# Summon battle runtime：FS_SummonRuntime_Authority
# Summon equipment skill power/description：FS_SummonEquipSkill_PowerAndDesc
# Equip summon detail page：FS_EquipSummonPage_Authority
# Summon skill level UI：FS_SummonSkillLevel_UI
#
# 注意：ArmorMapping 的 66 條 Pokémon 魂刻 600～665 另由 FS_PKMN66 BASE_MAPPING
#       動態補入；Compact 286～295 與舊 ID 遷移則由 DatabaseSupport 負責。
#
# 6. SAVE / ARMOR MAPPING AUTHORITY
#------------------------------------------------------------------------------
# FS_GlobalRuntime_Utilities
#   → Game_System#armor_mapping Storage + ArmorMapping API；預設只為空 Hash。
# FS_DatabaseSupport_Authority v2.3
#   → Compact 286～295 正式 Mapping Data；精確移除歷史 101/103/105、732～741。
# FS_SaveCompatibilityCore v1.1
#   → 新遊戲與每次讀檔後都呼叫 normalize；非 nil 舊存檔也會遷移。
#
# Phase 29 已退休：PokemonSummon｜Armor Mapping Init（101/103/105 舊初始化）。
#
# 7. EQUIPMENT UI / HELP
#------------------------------------------------------------------------------
# YEM Equipment Overhaul
#   ↓
# FS_YEM_EquipmentOverhaul_SafetyPatch
#   ↓
# FS_EquipSummonPage_Authority
#   ↓
# FS_EquipHelpScroll v1.3
#
# EquipmentCombo Base 仍會提供 Help Window combo prefix；HelpScroll 最後負責捲動與色彩。
#
# 8. SHOP / UPGRADE / NEW ITEM BRIDGES
#------------------------------------------------------------------------------
# SetupBridge｜ItemClass / NewIndicator / PlayerText
#   → change_equip 最外層之一，用 suppress scope 避免換裝時把舊裝備回背包誤標 NEW。
# 商店／鍛冶／Upgrade 各自保留獨立交易責任，不與 Game_Actor#change_equip 混為一頁。
#
#==============================================================================
# 【目前 change_equip 主鏈（Phase 29）】
#------------------------------------------------------------------------------
# VX Game_Actor
#   → YEM Equipment Overhaul
#   → FS_EquipmentSkill_Authority v2.1
#   → FS_EquipmentCombo_Base v1.2
#   → SetupBridge NewIndicator Suppression
#
# KGC PassiveSkill 的 change_equip wrapper 已退休；被動刷新由 EquipmentSkill Authority
# 在「YEM 額外欄位已真正更新」後執行，因此比舊時序更可靠。
#==============================================================================

#==============================================================================
# 【Phase 30｜YEM Core Ownership】
#------------------------------------------------------------------------------
# 六個 Game_Actor 核心方法由 2 份定義收斂為 1 份：
#   equip_type / equip_type= / add_equip_type / delete_last_equip_type
#   purge_unequippable / equip_legal_slot
# 中間頁沒有 alias／snapshot 這六個方法，因此回寫 Core 不改最終 Runtime 時序。
# SafetyPatch 的 ALBERT_YEM_EQUIP_SAFE helper 仍保留給 SetupRuntime_10 與 UI 使用。
#==============================================================================

#==============================================================================
# 【Phase 31｜Equipment Combat Intersection】
#------------------------------------------------------------------------------
# Armor 212 普攻吸血：FS_EQUIPMENT_RUNTIME.queue_legacy_attack_drain
#   → Custom Dmg Formulas 仍在原本普攻 Damage 計算位置呼叫 Provider。
#   → Tankentai force_damage 繼續負責延後回復與 Popup。
# Summon Equip Skill Bonus：FS_EquipmentCombat_SummonSkillModifier v1.1
#   → 保留既有 make_obj_damage_value 相對位置；後面仍有 Combo / State / Weather。
#==============================================================================
