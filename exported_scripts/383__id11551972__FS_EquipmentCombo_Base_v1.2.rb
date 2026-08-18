#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_EquipmentCombo_Base v1.2
# 【用途】Forest Symphony 專用 Runtime／資料腳本「FS_EquipmentCombo_Base v1.1」。
# 【主要機制】屬目前正式專案功能的一部分；具體責任以本頁定義的類別、模組與方法，以及 LoadOrder Guide 為準。
# 【主要影響】RPG::BaseItem、Game_Actor、Window_Equip、Window_Equip_Item、Scene_Battle、Albert_EquipmentCombo_UI
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：SHOW_HELP_STATUS、HELP_LABEL、HELP_ACTIVE、HELP_INACTIVE。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 5 個 alias／方法包裝，載入順序具有語意；登記 $imported：AlbertEquipmentComboSummonOpening；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
# 【呼叫方式／範例】<combo_actor: 1>；<combo_require_armor: 120>；<combo_skill: 202>
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【英文說明中文化】本頁頂部已用繁體中文整理／翻譯原說明中與維護直接相關的用途、機制、設定、順序、呼叫與範例；下方原文保留作作者授權、完整細節與歷史查核依據。
# 【來源／授權】若下方有原作者署名、Credits、License 或網址，必須保留；本中文維護說明不取代原授權。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 範例只記錄原文件、既有事件或程式碼能證實的入口；沒有入口就明寫自動執行。
# 3. 原作者署名、授權與原始說明保留在下方；中文化不代表取得原作權。
# 4. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
#==============================================================================
#==============================================================================
# ■ Albert_EquipmentCombo_SummonOpening v1.2
#    RPG Maker VX / RGSS2
#------------------------------------------------------------------------------
# 目的：
#  1. 裝備組合成立時，額外習得技能。
#  2. 裝備組合成立時，裝備者額外獲得狀態。
#  3. 裝備組合成立時，對應召喚物進入戰鬥後額外獲得狀態。
#  4. 裝備組合成立時，對應召喚物可於開場強制使用一次技能。
#  5. 裝備畫面的 Help Window 顯示組合效果「已達成／未達成」。
#     本專案 ATB 設定若為：
#       N02::FORCE_ACTION_CONSUME_GAUGE = false
#       N02::FORCE_ACTION_INCREASE_TURN = false
#     則該強制行動不消耗 ATB，也不增加回合計數。
#------------------------------------------------------------------------------
# 安裝位置：
#  請放在以下腳本之下，Main 之上：
#   - Equipment Skills
#   - YEM Equipment Overhaul
#   - ArmorMapping / 召喚物臨時加入腳本
#   - ATB
#   - Advanced Forced Action（若有）
#------------------------------------------------------------------------------
# 使用方式：請把標籤寫在「觸發組合效果的裝備」NOTE 中。
#
# <combo_actor: 1>
#   限定角色 ID 1 才能觸發。省略則任何裝備者都可觸發。
#
# <combo_require_armor: 101>
# <combo_require_armor: 101, 103>
#   必須同時裝備指定防具 ID。
#
# <combo_require_weapon: 12>
# <combo_require_weapon: 12, 13>
#   必須同時裝備指定武器 ID。
#
# <combo_skill: 202>
# <combo_skill: 202, 203>
#   組合成立時，裝備者額外習得技能。
#
# <combo_actor_state: 51>
# <combo_actor_state: 51, 52>
#   組合成立時，裝備者額外獲得狀態。
#   建議使用「專門給裝備組合用的獨立狀態 ID」，不要與一般戰鬥技能共用。
#
# <combo_summon_actor: 20>
#   指定對應召喚物 Actor ID。
#   若省略，腳本會嘗試從 combo_require_armor 中，依 ArmorMapping.mapping
#   自動推導對應召喚物。
#
# <combo_summon_state: 53>
# <combo_summon_state: 53, 54>
#   對應召喚物進入戰鬥後額外獲得狀態。
#
# <combo_summon_opening_skill: 310>
#   對應召喚物開場強制使用一次技能。
#   每個召喚物每場最多只會排入一個開場強制技能，避免同一 Actor 的 action
#   被多個組合效果互相覆寫。
#
# <combo_summon_opening_target: -1>
#   -1：依技能範圍自動決定隨機目標（預設）
#   0以上：指定 target_index
#------------------------------------------------------------------------------
# 範例：拉達疾行靴
#
# <combo_actor: 1>
# <combo_require_armor: 120>
# <combo_skill: 202>
# <combo_actor_state: 51>
# <combo_summon_actor: 20>
# <combo_summon_state: 52>
# <combo_summon_opening_skill: 310>
# <combo_summon_opening_target: -1>
#
# 代表：
#  - 角色 1 同時裝備本裝備與防具 120 時，習得技能 202。
#  - 角色 1 獲得狀態 51。
#  - Actor 20 若有進入戰鬥，獲得狀態 52。
#  - Actor 20 開場強制使用技能 310。
#==============================================================================

$imported = {} if $imported == nil
$imported["AlbertEquipmentComboSummonOpening"] = "1.2"

#==============================================================================
# ■ Help Window 顯示設定
#==============================================================================
module Albert_EquipmentCombo_UI
  SHOW_HELP_STATUS = true
  HELP_LABEL       = "組合效果"
  HELP_ACTIVE      = "已達成"
  HELP_INACTIVE    = "未達成"

  #--------------------------------------------------------------------------
  # ○ 組合裝備的 Help Window 文字
  #    狀態放在最前方，避免單行 Help Window 因描述過長而裁掉狀態。
  #--------------------------------------------------------------------------
  def self.help_text(actor, equip)
    return "" if equip == nil

    description = equip.description.to_s
    return description unless SHOW_HELP_STATUS
    return description unless equip.respond_to?(:albert_combo_defined?)
    return description unless equip.albert_combo_defined?

    active = false
    if actor != nil && actor.respond_to?(:albert_combo_effect_active?)
      active = actor.albert_combo_effect_active?(equip)
    end

    status = active ? HELP_ACTIVE : HELP_INACTIVE
    prefix = "【#{HELP_LABEL}：#{status}】"
    return prefix if description == ""
    return prefix + " " + description
  end
end

#==============================================================================
# ■ RPG::BaseItem
#==============================================================================
class RPG::BaseItem
  #--------------------------------------------------------------------------
  # ○ 解析組合標籤
  #--------------------------------------------------------------------------
  def albert_combo_load_cache
    return if @albert_combo_cache_loaded
    @albert_combo_cache_loaded = true

    @albert_combo_actor_id = 0
    @albert_combo_required_armors = []
    @albert_combo_required_weapons = []
    @albert_combo_skill_ids = []
    @albert_combo_actor_state_ids = []
    @albert_combo_summon_actor_id = 0
    @albert_combo_summon_state_ids = []
    @albert_combo_summon_opening_skill_id = 0
    @albert_combo_summon_opening_target = -1

    self.note.each_line do |line|
      case line
      when /<combo_actor:\s*(\d+)>/i
        @albert_combo_actor_id = $1.to_i
      when /<combo_require_armor:\s*(\d+(?:\s*,\s*\d+)*)>/i
        $1.scan(/\d+/).each do |num|
          id = num.to_i
          @albert_combo_required_armors << id if id > 0
        end
      when /<combo_require_weapon:\s*(\d+(?:\s*,\s*\d+)*)>/i
        $1.scan(/\d+/).each do |num|
          id = num.to_i
          @albert_combo_required_weapons << id if id > 0
        end
      when /<combo_skill:\s*(\d+(?:\s*,\s*\d+)*)>/i
        $1.scan(/\d+/).each do |num|
          id = num.to_i
          @albert_combo_skill_ids << id if id > 0
        end
      when /<combo_actor_state:\s*(\d+(?:\s*,\s*\d+)*)>/i
        $1.scan(/\d+/).each do |num|
          id = num.to_i
          @albert_combo_actor_state_ids << id if id > 0
        end
      when /<combo_summon_actor:\s*(\d+)>/i
        @albert_combo_summon_actor_id = $1.to_i
      when /<combo_summon_state:\s*(\d+(?:\s*,\s*\d+)*)>/i
        $1.scan(/\d+/).each do |num|
          id = num.to_i
          @albert_combo_summon_state_ids << id if id > 0
        end
      when /<combo_summon_opening_skill:\s*(\d+)>/i
        @albert_combo_summon_opening_skill_id = $1.to_i
      when /<combo_summon_opening_target:\s*(-?\d+)>/i
        @albert_combo_summon_opening_target = $1.to_i
      end
    end

    @albert_combo_required_armors.uniq!
    @albert_combo_required_weapons.uniq!
    @albert_combo_skill_ids.uniq!
    @albert_combo_actor_state_ids.uniq!
    @albert_combo_summon_state_ids.uniq!
  end

  def albert_combo_actor_id
    albert_combo_load_cache
    return @albert_combo_actor_id
  end

  def albert_combo_required_armors
    albert_combo_load_cache
    return @albert_combo_required_armors
  end

  def albert_combo_required_weapons
    albert_combo_load_cache
    return @albert_combo_required_weapons
  end

  def albert_combo_skill_ids
    albert_combo_load_cache
    return @albert_combo_skill_ids
  end

  def albert_combo_actor_state_ids
    albert_combo_load_cache
    return @albert_combo_actor_state_ids
  end

  def albert_combo_summon_actor_id
    albert_combo_load_cache
    return @albert_combo_summon_actor_id
  end

  def albert_combo_summon_state_ids
    albert_combo_load_cache
    return @albert_combo_summon_state_ids
  end

  def albert_combo_summon_opening_skill_id
    albert_combo_load_cache
    return @albert_combo_summon_opening_skill_id
  end

  def albert_combo_summon_opening_target
    albert_combo_load_cache
    return @albert_combo_summon_opening_target
  end

  #--------------------------------------------------------------------------
  # ○ 是否包含任何組合效果定義
  #--------------------------------------------------------------------------
  def albert_combo_defined?
    albert_combo_load_cache
    return true unless @albert_combo_required_armors.empty?
    return true unless @albert_combo_required_weapons.empty?
    return true unless @albert_combo_skill_ids.empty?
    return true unless @albert_combo_actor_state_ids.empty?
    return true if @albert_combo_summon_actor_id > 0
    return true unless @albert_combo_summon_state_ids.empty?
    return true if @albert_combo_summon_opening_skill_id > 0
    return false
  end
end

#==============================================================================
# ■ Game_Actor
#==============================================================================
class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ○ 組合條件是否成立
  #--------------------------------------------------------------------------
  def albert_combo_active?(equip)
    return false if equip == nil
    return false unless equip.albert_combo_defined?

    actor_limit = equip.albert_combo_actor_id
    return false if actor_limit > 0 && actor_limit != self.id

    armor_ids = self.armors.compact.collect { |armor| armor.id }
    weapon_ids = self.weapons.compact.collect { |weapon| weapon.id }

    equip.albert_combo_required_armors.each do |armor_id|
      return false unless armor_ids.include?(armor_id)
    end

    equip.albert_combo_required_weapons.each do |weapon_id|
      return false unless weapon_ids.include?(weapon_id)
    end

    return true
  end

  #--------------------------------------------------------------------------
  # ○ 指定裝備目前是否真的穿在角色身上
  #--------------------------------------------------------------------------
  def albert_combo_equipped_now?(equip)
    return false if equip == nil

    self.equips.each do |current|
      next if current == nil
      next unless current.class == equip.class
      return true if current.id == equip.id
    end

    return false
  end

  #--------------------------------------------------------------------------
  # ○ 組合效果目前是否真正生效
  #    與 albert_combo_active? 的差別：
  #      albert_combo_active? 只檢查條件。
  #      本方法還要求「觸發組合效果的裝備本身」真的已穿上。
  #
  #    這可避免在裝備清單中只是把游標移到某件組合裝備時，
  #    因其他必要裝備已穿著，就被誤顯示成「已達成」。
  #--------------------------------------------------------------------------
  def albert_combo_effect_active?(equip)
    return false unless albert_combo_equipped_now?(equip)
    return albert_combo_active?(equip)
  end

  #--------------------------------------------------------------------------
  # ○ 目前成立的組合裝備
  #--------------------------------------------------------------------------
  def albert_active_combo_equips
    result = []
    self.equips.compact.each do |equip|
      result << equip if albert_combo_active?(equip)
    end
    return result
  end

  #--------------------------------------------------------------------------
  # ○ 從 ArmorMapping 自動推導召喚物 Actor ID
  #--------------------------------------------------------------------------
  def albert_combo_summon_actor_id_for(equip)
    return 0 if equip == nil

    actor_id = equip.albert_combo_summon_actor_id
    return actor_id if actor_id > 0

    return 0 unless defined?(ArmorMapping)
    return 0 unless ArmorMapping.respond_to?(:mapping)
    mapping = ArmorMapping.mapping
    return 0 if mapping == nil

    armor_ids = equip.albert_combo_required_armors.dup
    if equip.is_a?(RPG::Armor)
      armor_ids.unshift(equip.id)
    end

    armor_ids.each do |armor_id|
      return mapping[armor_id] if mapping.key?(armor_id)
    end

    return 0
  end

  #--------------------------------------------------------------------------
  # ○ 組合技能
  #    放在 Equipment Skills 之下，保留原本 equipskill 功能，再追加組合技能。
  #--------------------------------------------------------------------------
  alias albert_combo_skills_without_combo skills
  def skills
    list = albert_combo_skills_without_combo
    albert_active_combo_equips.each do |equip|
      equip.albert_combo_skill_ids.each do |skill_id|
        skill = $data_skills[skill_id]
        list << skill unless skill == nil
      end
    end
    return list.compact.uniq
  end

  #--------------------------------------------------------------------------
  # ○ 同步「裝備者組合狀態」
  #    只移除由本補丁自己加入、且組合已失效的狀態。
  #--------------------------------------------------------------------------
  def albert_refresh_combo_actor_states
    @albert_combo_owned_state_ids = [] if @albert_combo_owned_state_ids == nil

    desired = []
    albert_active_combo_equips.each do |equip|
      desired.concat(equip.albert_combo_actor_state_ids)
    end
    desired.compact!
    desired.uniq!

    # 移除：之前由本補丁加入，但現在不再需要的狀態
    (@albert_combo_owned_state_ids - desired).each do |state_id|
      remove_state(state_id) if state?(state_id)
    end

    # 保留仍然有效的所有權記錄
    new_owned = @albert_combo_owned_state_ids & desired

    # 加入：目前需要、但角色身上尚未存在的狀態
    desired.each do |state_id|
      next if state_id <= 0
      next if $data_states[state_id] == nil
      next if state?(state_id)
      add_state(state_id)
      new_owned << state_id if state?(state_id)
    end

    @albert_combo_owned_state_ids = new_owned.uniq
  end

  #--------------------------------------------------------------------------
  # ○ 裝備變更後立即同步組合狀態
  #    YEM Equipment Overhaul 的 test=true 預覽不產生實際狀態副作用。
  #--------------------------------------------------------------------------
  alias albert_combo_change_equip_without_refresh change_equip
  def change_equip(equip_type, item, test = false)
    result = albert_combo_change_equip_without_refresh(equip_type, item, test)
    albert_refresh_combo_actor_states unless test
    return result
  end
end


#==============================================================================
# ■ 裝備畫面 Help Window 整合
#------------------------------------------------------------------------------
# 你的專案 Window_Help 為單行顯示，因此格式為：
#   【組合效果：已達成】 裝備原本說明
# 或
#   【組合效果：未達成】 裝備原本說明
#
# 只有具有 combo 標籤的裝備才追加狀態，普通裝備維持原說明。
#==============================================================================
if defined?(Window_Equip)
  class Window_Equip < Window_Selectable
    unless method_defined?(:albert_combo_ui_old_update_help)
      alias albert_combo_ui_old_update_help update_help
    end

    def update_help
      # 先保留原本 Help 更新與其他插件可能追加的副作用。
      albert_combo_ui_old_update_help

      return if @help_window == nil
      current_item = item
      text = Albert_EquipmentCombo_UI.help_text(@actor, current_item)
      @help_window.set_text(text)
    end
  end
end

if defined?(Window_Equip_Item)
  class Window_Equip_Item < Window_Selectable
    unless method_defined?(:albert_combo_ui_old_update_help)
      alias albert_combo_ui_old_update_help update_help
    end

    def update_help
      # 尤其保留 Galv New Item 等腳本在 update_help 內做的處理。
      albert_combo_ui_old_update_help

      return if @help_window == nil
      current_item = item
      text = Albert_EquipmentCombo_UI.help_text(@actor, current_item)
      @help_window.set_text(text)
    end
  end
end

#==============================================================================
# ■ EquipmentCombo 召喚物 State 所有權 Storage API
#------------------------------------------------------------------------------
# Phase 31 從 BattleIntegrity 回歸 EquipmentCombo Base。這裡只保存「本場 Combo
# 親自加入哪些 State」；最終判定與登記由 OpeningSkill FinalAuthority 負責。
#==============================================================================
class Game_Actor < Game_Battler
  def albert_combo_register_owned_summon_states(state_ids)
    @albert_combo_owned_summon_state_ids = [] if @albert_combo_owned_summon_state_ids == nil
    for state_id in state_ids
      next if state_id == nil || state_id.to_i <= 0
      id = state_id.to_i
      next unless state?(id)
      @albert_combo_owned_summon_state_ids.push(id) unless @albert_combo_owned_summon_state_ids.include?(id)
    end
  end

  def albert_combo_clear_owned_summon_states
    @albert_combo_owned_summon_state_ids = [] if @albert_combo_owned_summon_state_ids == nil
    for state_id in @albert_combo_owned_summon_state_ids.clone
      remove_state(state_id) if state?(state_id)
    end
    @albert_combo_owned_summon_state_ids.clear
  end
end

#==============================================================================
# ■ Scene_Battle
#==============================================================================
class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ○ 戰鬥開始後：
  #    1. 同步裝備者狀態
  #    2. 套用召喚物狀態
  #    3. 將召喚物開場技能排入 ATB 的 forced-action queue
  #--------------------------------------------------------------------------
  alias albert_combo_process_battle_start_without_combo process_battle_start
  def process_battle_start
    albert_combo_process_battle_start_without_combo
    albert_prepare_equipment_combo_battle_effects
  end

  # Phase 31：prepare 的唯一正式實作位於後載入
  # FS_EquipmentCombo_OpeningSkill_FinalAuthority v2.0。
  # process_battle_start 在真正戰鬥開始時才動態呼叫該最終方法。
end

#==============================================================================
# ■ END
#==============================================================================
