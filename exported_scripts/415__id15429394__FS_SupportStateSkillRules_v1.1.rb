#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_SupportStateSkillRules v1.1
# 【用途】Forest Symphony 專用 Runtime／資料腳本「FS_SupportStateSkillRules v1.1」。
# 【主要機制】屬目前正式專案功能的一部分；具體責任以本頁定義的類別、模組與方法，以及 LoadOrder Guide 為準。
# 【主要影響】Game_Battler、Sprite_Damage、FS_SUPPORT_STATE_RULES、FS_ELEMENT_FINAL
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：HEAL_TAG、STATE_TAG、STATE_CHANCE_TAG、STATE_FAILURE_TEXT。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 9 個 alias／方法包裝，載入順序具有語意；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
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
# ■ FS_SupportStateSkillRules_v1_1
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2
#
# 功能：
#   1. 回復技能真正必中，且不受屬性、迴避、受け流し、格檔影響。
#   2. 回復技能即使資料庫誤設屬性，也固定以無屬性 100%倍率計算。
#   3. 狀態技能不顯示「屬性克制／屬性抵抗」。
#   4. 無傷害狀態技能若有 <state_chance ID:X>：
#        - 技能 HIT 固定視為 100
#        - 不再進行迴避／受け流し／格檔判定
#        - 只由 state_chance 與目標狀態有效率決定結果
#   5. 無傷害狀態技能命中後，若所有附加狀態都失敗，顯示「附加失敗」。
#
# 建議 Note：
#   回復技能：<回復技能>
#   狀態技能：<狀態技能>
#
# 放置位置：
#   FS_ElementRate_FinalGuard_v1_1 之後，
#   「全腳本導出工具」與 Main 之前。
#
# 注意：
#   本版不覆寫 Game_Actor／Game_Enemy 的 elements_max_rate。
#   它直接包裝 FS_ELEMENT_FINAL.max_rate_for，因此必須在 FinalGuard 之後。
#==============================================================================

module FS_SUPPORT_STATE_RULES
  VERSION = "1.1"

  HEAL_TAG = /[<＜](?:回復技能|回复技能|恢復技能|恢复技能|回復技|回复技|AI_HEAL)[>＞]/i
  STATE_TAG = /[<＜](?:狀態技能|状态技能|狀態技|状态技|AI_STATE)[>＞]/i
  STATE_CHANCE_TAG = /<state_chance\s+(\d+)\s*:\s*(-?[0-9]+(?:\.[0-9]+)?)\s*>/i

  STATE_FAILURE_TEXT = "附加失敗"

  def self.note(obj)
    return "" if obj == nil
    return "" unless obj.respond_to?(:note)
    return obj.note.to_s
  end

  def self.skill?(obj)
    return obj != nil && obj.is_a?(RPG::Skill)
  end

  # 回復技能：優先使用專案既有 Note；負 BaseDamage 的友方技能也自動辨識。
  def self.recovery_skill?(obj)
    return false unless skill?(obj)
    return true if note(obj) =~ HEAL_TAG

    begin
      return false if obj.for_opponent?
    rescue
    end

    return obj.respond_to?(:base_damage) && obj.base_damage.to_i < 0
  end

  def self.no_damage?(obj)
    return false if obj == nil
    return false unless obj.respond_to?(:base_damage)
    return obj.base_damage.to_i == 0
  end

  # 資料庫勾選及 Note 宣告的附加 State ID。
  def self.state_ids(obj)
    result = []
    return result if obj == nil

    if obj.respond_to?(:plus_state_set) && obj.plus_state_set != nil
      for state_id in obj.plus_state_set
        state_id = state_id.to_i
        result.push(state_id) if state_id > 0
      end
    end

    note(obj).scan(STATE_CHANCE_TAG) do |state_id, chance|
      state_id = state_id.to_i
      result.push(state_id) if state_id > 0
    end

    return result.uniq
  end

  # 明確標記的狀態技能，或「無傷害且確實嘗試附加 State」的技能。
  def self.state_skill?(obj)
    return false unless skill?(obj)
    return false if recovery_skill?(obj)
    return true if note(obj) =~ STATE_TAG
    return no_damage?(obj) && !state_ids(obj).empty?
  end

  def self.pure_state_skill?(obj)
    return state_skill?(obj) && no_damage?(obj)
  end

  # 有 Note 成功率時，Note 成功率是唯一的主動命中骰。
  def self.note_chance_mode?(obj)
    return false unless pure_state_skill?(obj)
    return note(obj) =~ STATE_CHANCE_TAG ? true : false
  end

  def self.action_failed_before_state?(battler)
    return true if battler == nil
    return true if battler.instance_variable_get(:@skipped)
    return true if battler.instance_variable_get(:@missed)
    return true if battler.instance_variable_get(:@evaded)
    return true if battler.instance_variable_get(:@parried)
    return false
  end

  def self.state_measure(battler, state_id)
    return 0 if battler == nil
    state_id = state_id.to_i
    return 0 if state_id <= 0

    if battler.respond_to?(:stack)
      begin
        return battler.stack(state_id).to_i
      rescue
      end
    end

    begin
      return battler.state?(state_id) ? 1 : 0
    rescue
      return 0
    end
  end

  def self.result_state_ids(battler, method_name)
    result = []
    return result if battler == nil
    return result unless battler.respond_to?(method_name)

    begin
      states = battler.send(method_name)
      for state in states
        next if state == nil
        result.push(state.id.to_i) if state.respond_to?(:id)
      end
    rescue
    end
    return result
  end
end


#==============================================================================
# ■ ElementRate FinalGuard 相容
#------------------------------------------------------------------------------
# FinalGuard 會在 Game_Battler、Game_Actor、Game_Enemy 最後直接定義
# elements_max_rate。若只 alias Game_Battler，子類別仍會繞過回復中立化。
# 因此本版直接包裝 FinalGuard 的唯一核心入口 max_rate_for。
#==============================================================================
if defined?(FS_ELEMENT_FINAL)
  module FS_ELEMENT_FINAL
    class << self
      if method_defined?(:max_rate_for) &&
         !method_defined?(:fs_ssr_old_max_rate_for)
        alias fs_ssr_old_max_rate_for max_rate_for

        def max_rate_for(battler, element_set)
          if battler != nil &&
             battler.instance_variable_get(:@fs_ssr_neutral_recovery_element)
            return 100
          end
          return fs_ssr_old_max_rate_for(battler, element_set)
        end
      end
    end
  end
end

#==============================================================================
# ■ Game_Battler：判定與結果
#==============================================================================
class Game_Battler
  attr_accessor :fs_ssr_state_add_failed

  #--------------------------------------------------------------------------
  # 回復必中；Note 狀態機率模式不再重複擲技能 HIT。
  #--------------------------------------------------------------------------
  unless method_defined?(:fs_ssr_old_calc_hit)
    alias fs_ssr_old_calc_hit calc_hit
  end

  def calc_hit(user, obj = nil)
    return 100 if FS_SUPPORT_STATE_RULES.recovery_skill?(obj)
    return 100 if FS_SUPPORT_STATE_RULES.note_chance_mode?(obj)
    return fs_ssr_old_calc_hit(user, obj)
  end

  #--------------------------------------------------------------------------
  # 回復技能與 Note 狀態機率模式不受迴避。
  #--------------------------------------------------------------------------
  unless method_defined?(:fs_ssr_old_calc_eva)
    alias fs_ssr_old_calc_eva calc_eva
  end

  def calc_eva(user, obj = nil)
    return 0 if FS_SUPPORT_STATE_RULES.recovery_skill?(obj)
    return 0 if FS_SUPPORT_STATE_RULES.note_chance_mode?(obj)
    return fs_ssr_old_calc_eva(user, obj)
  end

  #--------------------------------------------------------------------------
  # 回復技能與 Note 狀態機率模式不受受け流し。
  #--------------------------------------------------------------------------
  if method_defined?(:calc_parry) && !method_defined?(:fs_ssr_old_calc_parry)
    alias fs_ssr_old_calc_parry calc_parry

    def calc_parry(user, obj = nil)
      return false if FS_SUPPORT_STATE_RULES.recovery_skill?(obj)
      return false if FS_SUPPORT_STATE_RULES.note_chance_mode?(obj)
      return fs_ssr_old_calc_parry(user, obj)
    end
  end

  #--------------------------------------------------------------------------
  # 回復技能與 Note 狀態機率模式不受格檔。
  #--------------------------------------------------------------------------
  if method_defined?(:calc_guard) && !method_defined?(:fs_ssr_old_calc_guard)
    alias fs_ssr_old_calc_guard calc_guard

    def calc_guard(obj = nil)
      return false if FS_SUPPORT_STATE_RULES.recovery_skill?(obj)
      return false if FS_SUPPORT_STATE_RULES.note_chance_mode?(obj)
      return fs_ssr_old_calc_guard(obj)
    end
  end

  #--------------------------------------------------------------------------
  # 傷害／回復值計算：回復無屬性；回復與狀態技能不保留 weak/strong。
  #--------------------------------------------------------------------------
  unless method_defined?(:fs_ssr_old_make_obj_damage_value)
    alias fs_ssr_old_make_obj_damage_value make_obj_damage_value
  end

  def make_obj_damage_value(user, obj)
    recovery = FS_SUPPORT_STATE_RULES.recovery_skill?(obj)
    state_skill = FS_SUPPORT_STATE_RULES.state_skill?(obj)
    old_neutral = @fs_ssr_neutral_recovery_element
    @fs_ssr_neutral_recovery_element = true if recovery

    result = nil
    begin
      result = fs_ssr_old_make_obj_damage_value(user, obj)
    ensure
      @fs_ssr_neutral_recovery_element = old_neutral
    end

    if recovery || state_skill
      @weak = false
      @strong = false
    end
    return result
  end

  #--------------------------------------------------------------------------
  # 技能結果：追蹤狀態成功／失敗，並修正 Note 狀態模式的物理 0 傷害早退。
  #--------------------------------------------------------------------------
  unless method_defined?(:fs_ssr_old_skill_effect)
    alias fs_ssr_old_skill_effect skill_effect
  end

  def skill_effect(user, skill)
    recovery = FS_SUPPORT_STATE_RULES.recovery_skill?(skill)
    state_skill = FS_SUPPORT_STATE_RULES.state_skill?(skill)
    pure_state = FS_SUPPORT_STATE_RULES.pure_state_skill?(skill)
    note_mode = FS_SUPPORT_STATE_RULES.note_chance_mode?(skill)
    attempted_ids = pure_state ? FS_SUPPORT_STATE_RULES.state_ids(skill) : []

    @fs_ssr_state_add_failed = false

    before_values = {}
    for state_id in attempted_ids
      before_values[state_id] = FS_SUPPORT_STATE_RULES.state_measure(self, state_id)
    end

    # 有 <state_chance> 的無傷害狀態技，只由 state_chance 判定。
    # 暫時取消 physical_attack，可避開舊 skill_effect 的「物理 0 傷害直接 return」。
    physical_changed = false
    old_physical = false
    if note_mode && skill != nil && skill.respond_to?(:physical_attack)
      old_physical = skill.physical_attack
      if old_physical
        if skill.respond_to?(:physical_attack=)
          skill.physical_attack = false
        else
          skill.instance_variable_set(:@physical_attack, false)
        end
        physical_changed = true
      end
    end

    result = nil
    begin
      result = fs_ssr_old_skill_effect(user, skill)
    ensure
      if physical_changed
        if skill.respond_to?(:physical_attack=)
          skill.physical_attack = old_physical
        else
          skill.instance_variable_set(:@physical_attack, old_physical)
        end
      end
    end

    # 最外層再清一次，防止中間其他機制重新寫入 weak / strong。
    if recovery || state_skill
      @weak = false
      @strong = false
    end

    if pure_state && !attempted_ids.empty? &&
       !FS_SUPPORT_STATE_RULES.action_failed_before_state?(self)

      added_ids = FS_SUPPORT_STATE_RULES.result_state_ids(self, :added_states)
      remained_ids = FS_SUPPORT_STATE_RULES.result_state_ids(self, :remained_states)
      success = false

      for state_id in attempted_ids
        after_value = FS_SUPPORT_STATE_RULES.state_measure(self, state_id)
        if after_value > before_values[state_id].to_i ||
           added_ids.include?(state_id) || remained_ids.include?(state_id)
          success = true
          break
        end
      end

      @fs_ssr_state_add_failed = !success
    end

    return result
  end
end

#==============================================================================
# ■ Sprite_Damage：「附加失敗」結果文字
#------------------------------------------------------------------------------
# 不重寫原 damage_pop，只在原方法準備文字 Window 時替換文字。
# 因此不碰原本的數字、暴擊、護衛位移與傷害動畫。
#==============================================================================
if defined?(Sprite_Damage)
  class Sprite_Damage < Sprite_Base
    if method_defined?(:window) && !method_defined?(:fs_ssr_old_window)
      alias fs_ssr_old_window window

      def window(text)
        if @fs_ssr_replace_with_state_failure
          text = FS_SUPPORT_STATE_RULES::STATE_FAILURE_TEXT
        end
        fs_ssr_old_window(text)
      end
    end

    if method_defined?(:damage_pop) && !method_defined?(:fs_ssr_old_damage_pop)
      alias fs_ssr_old_damage_pop damage_pop

      def damage_pop(num = nil)
        show_failure = false
        if num == nil && @battler != nil &&
           @battler.respond_to?(:fs_ssr_state_add_failed)
          show_failure = @battler.fs_ssr_state_add_failed ? true : false
        end

        @fs_ssr_replace_with_state_failure = show_failure
        result = fs_ssr_old_damage_pop(num)

        if show_failure && @battler.respond_to?(:fs_ssr_state_add_failed=)
          @battler.fs_ssr_state_add_failed = false
        end
        return result
      ensure
        @fs_ssr_replace_with_state_failure = false
      end
    end
  end
end
