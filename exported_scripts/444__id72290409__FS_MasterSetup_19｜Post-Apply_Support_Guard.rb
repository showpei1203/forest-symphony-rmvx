#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_MasterSetup 19 Support State Fix
# 【用途】Forest Symphony MasterSetup 資料頁「FS_MasterSetup 19 Support State Fix」，集中定義正式遊戲資料／修正資料。
# 【主要機制】依 00～20 編號順序建立技能、狀態、物品、裝備、敵人、文字、Soulmark 等 Authority 資料，最終由 Apply 頁套用。
# 【主要影響】FS_AUTOSET_SUPPORT_STATE_DATA_FIX、FS_SOULMARK_RESONANCE
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：HEAL_TAG_TEXT、STATE_TAG_TEXT、HEAL_TAG、STATE_TAG、STATE_CHANCE_TAG、FRIEND_SCOPES、SOUL_SUPPORT_SKILL_IDS。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 1 個 alias／方法包裝，載入順序具有語意；登記 $imported：FS AutoSetup Support State Data Fix；必須依 00～20 編號順序；18 Apply 不可提前。
# 【呼叫方式／範例】本頁屬啟動時依載入順序自動建立／套用資料，不需要事件 Script Call。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【Setup 分類】POST-APPLY INTEGRITY GUARD / SUPPORT STATE
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
# ■ FS_MasterSetup 19 Support State Fix
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2
# 載入順序：19 / 20
# 分類用途：回復／狀態技能資料正規化與魂刻擴充相容
#
# 本頁由 FS_MasterSetup_AllData_v1_1 自動等值拆分。
# 請依編號順序放置，並停用原本未拆分的整合頁，避免資料重複套用。
#==============================================================================

# ■ 內建：回復／狀態技能資料正規化
#==============================================================================
#==============================================================================
# ■ FS_AutoSetup_SupportStateDataFix_v1_0
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2
#
# 【目的】
# 配合 FS_SupportStateSkillRules_v1_1，自動校正 AutoSetup 與魂刻擴充
# 建立的回復／無傷害狀態技能，避免資料庫數值與執行規則互相打架。
#
# 【自動調整】
# 1. 回復技能：
#      HIT = 100
#      physical_attack = false
#      element_set = []
#      Note 追加 <回復技能>
#
# 2. 無傷害狀態技能：
#      Note 追加 <狀態技能>
#      若已有 <state_chance ID:X>，則 HIT = 100、physical_attack = false
#      沒有 state_chance 時保留原 HIT，讓 HIT 成為唯一成功率。
#
# 3. 同步處理：
#      FS_DB_AUTOSET_SKILLS::DATA
#      魂刻維護技能 193～198
#      魂刻專屬技能 200～265
#
# 【放置位置】
# 放在 FS_SoulMark_Resonance_Expansion 與其他 AutoSetup 資料補丁之後，
# FS_ElementRate_FinalGuard_v1_1 之前。
#
# 建議順序：
#   FS_SoulMark_Resonance_Expansion
#   FS_AutoSetup_SupportStateDataFix_v1_0
#   FS_ElementRate_FinalGuard_v1_1
#   FS_SupportStateSkillRules_v1_1
#   全腳本導出工具
#   Main
#
# 【測試】
# 地圖事件腳本：
#   FS_AUTOSET_SUPPORT_STATE_DATA_FIX.print_report
#==============================================================================

$imported = {} if $imported == nil
$imported["FS AutoSetup Support State Data Fix"] = "1.0"

module FS_AUTOSET_SUPPORT_STATE_DATA_FIX
  VERSION = "1.0"

  HEAL_TAG_TEXT  = "<回復技能>"
  STATE_TAG_TEXT = "<狀態技能>"

  HEAL_TAG = /[<＜](?:回復技能|回复技能|恢復技能|恢复技能|回復技|回复技|AI_HEAL)[>＞]/i
  STATE_TAG = /[<＜](?:狀態技能|状态技能|狀態技|状态技|AI_STATE)[>＞]/i
  STATE_CHANCE_TAG = /<state_chance\s+\d+\s*:\s*-?[0-9]+(?:\.[0-9]+)?\s*>/i

  FRIEND_SCOPES = [7, 8, 9, 10, 11]
  SOUL_SUPPORT_SKILL_IDS = [193, 194, 195, 196, 197, 198]

  def self.note_string(value)
    return value.compact.collect { |line| line.to_s }.join("\n") if value.is_a?(Array)
    return value.to_s
  end

  def self.append_note_tag(value, tag_text, regexp)
    text = note_string(value)
    return value if text =~ regexp

    if value.is_a?(Array)
      result = value.dup
      result.push(tag_text)
      return result
    end

    text = text.gsub(/\s+\z/, "")
    return tag_text if text.empty?
    return text + "\n" + tag_text
  end

  def self.data_array(data, key)
    value = data[key]
    return value if value.is_a?(Array)
    return []
  end

  def self.active_skill_data?(data)
    return false unless data.is_a?(Hash)
    scope = data[:scope].to_i
    return false if scope <= 0
    return false if data[:occasion].to_i == 3
    return true
  end

  def self.soul_art_index_from_skill_id(skill_id)
    return nil unless defined?(FS_SOULMARK_RESONANCE)
    return nil unless FS_SOULMARK_RESONANCE.const_defined?(:SOUL_SKILL_START)
    return nil unless FS_SOULMARK_RESONANCE.const_defined?(:SOUL_ARTS)

    index = skill_id.to_i - FS_SOULMARK_RESONANCE::SOUL_SKILL_START.to_i
    return nil if index < 0
    return nil if index >= FS_SOULMARK_RESONANCE::SOUL_ARTS.size
    return index
  end

  def self.soul_art(skill_id)
    index = soul_art_index_from_skill_id(skill_id)
    return nil if index == nil
    return FS_SOULMARK_RESONANCE::SOUL_ARTS[index]
  rescue
    return nil
  end

  def self.soul_art_recovery?(skill_id)
    art = soul_art(skill_id)
    return false unless art.is_a?(Hash)
    effects = art[:effects]
    effects = {} unless effects.is_a?(Hash)
    return true if effects.has_key?(:heal_maxhp)
    return true if effects.has_key?(:mp_restore)
    return false
  end

  def self.soul_art_zero_support?(skill_id)
    art = soul_art(skill_id)
    return false unless art.is_a?(Hash)
    return false if soul_art_recovery?(skill_id)
    return art[:base_damage].to_i == 0
  end

  def self.recovery_data?(skill_id, data)
    return false unless data.is_a?(Hash)
    note = note_string(data[:note])
    return true if note =~ HEAL_TAG
    return true if SOUL_SUPPORT_SKILL_IDS.include?(skill_id.to_i)
    return true if soul_art_recovery?(skill_id)

    if data[:base_damage].to_i < 0 && FRIEND_SCOPES.include?(data[:scope].to_i)
      return true
    end
    return false
  end

  def self.state_data?(skill_id, data)
    return false unless active_skill_data?(data)
    return false if recovery_data?(skill_id, data)

    note = note_string(data[:note])
    return true if note =~ STATE_TAG
    return true if soul_art_zero_support?(skill_id)
    return false unless data[:base_damage].to_i == 0
    return true if note =~ STATE_CHANCE_TAG
    return true unless data_array(data, :plus_state_set).empty?
    return true unless data_array(data, :minus_state_set).empty?
    return false
  end

  def self.normalize_recovery_data!(data)
    return unless data.is_a?(Hash)
    data[:hit] = 100
    data[:physical_attack] = false
    data[:element_set] = []
    data[:note] = append_note_tag(data[:note], HEAL_TAG_TEXT, HEAL_TAG)
  end

  def self.normalize_state_data!(data)
    return unless data.is_a?(Hash)
    data[:note] = append_note_tag(data[:note], STATE_TAG_TEXT, STATE_TAG)

    # 無傷害狀態技使用 state_chance 時，不再讓 HIT 成為第二次骰點。
    if data[:base_damage].to_i == 0 && note_string(data[:note]) =~ STATE_CHANCE_TAG
      data[:hit] = 100
      data[:physical_attack] = false
    end
  end

  def self.normalize_data_entry!(skill_id, data)
    return unless data.is_a?(Hash)
    if recovery_data?(skill_id, data)
      normalize_recovery_data!(data)
    elsif state_data?(skill_id, data)
      normalize_state_data!(data)
    end
  end

  def self.normalize_autoset_table!
    return unless defined?(FS_DB_AUTOSET_SKILLS)
    return unless FS_DB_AUTOSET_SKILLS.const_defined?(:DATA)

    table = FS_DB_AUTOSET_SKILLS::DATA
    return unless table.is_a?(Hash)
    table.each do |skill_id, data|
      normalize_data_entry!(skill_id.to_i, data)
    end
  end

  def self.set_skill_value(skill, key, value)
    return if skill == nil
    writer = (key.to_s + "=").to_sym
    if skill.respond_to?(writer)
      skill.send(writer, value)
    else
      skill.instance_variable_set(("@" + key.to_s).to_sym, value)
    end
  rescue
  end

  def self.normalize_skill_object!(skill_id, skill, forced_kind = nil)
    return if skill == nil

    data = {
      :scope => skill.respond_to?(:scope) ? skill.scope : 0,
      :occasion => skill.respond_to?(:occasion) ? skill.occasion : 3,
      :base_damage => skill.respond_to?(:base_damage) ? skill.base_damage : 0,
      :hit => skill.respond_to?(:hit) ? skill.hit : 100,
      :physical_attack => skill.respond_to?(:physical_attack) ? skill.physical_attack : false,
      :element_set => skill.respond_to?(:element_set) ? skill.element_set : [],
      :plus_state_set => skill.respond_to?(:plus_state_set) ? skill.plus_state_set : [],
      :minus_state_set => skill.respond_to?(:minus_state_set) ? skill.minus_state_set : [],
      :note => skill.respond_to?(:note) ? skill.note : ""
    }

    recovery = forced_kind == :recovery || recovery_data?(skill_id, data)
    state_skill = forced_kind == :state || (!recovery && state_data?(skill_id, data))

    if recovery
      set_skill_value(skill, :hit, 100)
      set_skill_value(skill, :physical_attack, false)
      set_skill_value(skill, :element_set, [])
      if skill.respond_to?(:note=)
        skill.note = append_note_tag(skill.note, HEAL_TAG_TEXT, HEAL_TAG)
      end
    elsif state_skill
      if skill.respond_to?(:note=)
        skill.note = append_note_tag(skill.note, STATE_TAG_TEXT, STATE_TAG)
      end
      if skill.respond_to?(:base_damage) && skill.base_damage.to_i == 0 &&
         note_string(skill.note) =~ STATE_CHANCE_TAG
        set_skill_value(skill, :hit, 100)
        set_skill_value(skill, :physical_attack, false)
      end
    end

    if defined?(FS_DB_AUTOSET) && FS_DB_AUTOSET.respond_to?(:invalidate_note_cache)
      FS_DB_AUTOSET.invalidate_note_cache(skill)
    end
  end

  def self.normalize_loaded_soul_skills!
    return if $data_skills == nil

    SOUL_SUPPORT_SKILL_IDS.each do |skill_id|
      normalize_skill_object!(skill_id, $data_skills[skill_id], :recovery)
    end

    return unless defined?(FS_SOULMARK_RESONANCE)
    return unless FS_SOULMARK_RESONANCE.const_defined?(:SOUL_ARTS)
    return unless FS_SOULMARK_RESONANCE.const_defined?(:SOUL_SKILL_START)

    FS_SOULMARK_RESONANCE::SOUL_ARTS.each_with_index do |art, index|
      skill_id = FS_SOULMARK_RESONANCE::SOUL_SKILL_START.to_i + index
      kind = nil
      kind = :recovery if soul_art_recovery?(skill_id)
      kind = :state if kind == nil && art.is_a?(Hash) && art[:base_damage].to_i == 0
      normalize_skill_object!(skill_id, $data_skills[skill_id], kind)
    end
  end

  def self.audit_lines
    lines = []
    recovery_errors = []
    state_errors = []
    recovery_count = 0
    state_chance_count = 0

    if $data_skills != nil
      i = 1
      while i < $data_skills.size
        skill = $data_skills[i]
        if skill != nil && !skill.name.to_s.empty?
          data = {
            :scope => skill.scope,
            :occasion => skill.occasion,
            :base_damage => skill.base_damage,
            :hit => skill.hit,
            :physical_attack => skill.physical_attack,
            :element_set => skill.element_set,
            :plus_state_set => skill.plus_state_set,
            :minus_state_set => skill.minus_state_set,
            :note => skill.note
          }

          if recovery_data?(i, data)
            recovery_count += 1
            bad = []
            bad.push("HIT=#{skill.hit}") unless skill.hit.to_i == 100
            bad.push("physical") if skill.physical_attack
            bad.push("element=#{skill.element_set.inspect}") unless skill.element_set.empty?
            recovery_errors.push([i, skill.name, bad]) unless bad.empty?
          elsif data[:base_damage].to_i == 0 && note_string(data[:note]) =~ STATE_CHANCE_TAG
            state_chance_count += 1
            bad = []
            bad.push("HIT=#{skill.hit}") unless skill.hit.to_i == 100
            bad.push("physical") if skill.physical_attack
            state_errors.push([i, skill.name, bad]) unless bad.empty?
          end
        end
        i += 1
      end
    end

    lines.push("Support/State Data Fix v#{VERSION}")
    lines.push("Recovery skills checked: #{recovery_count}")
    lines.push("Pure state_chance skills checked: #{state_chance_count}")
    lines.push(recovery_errors.empty? ?
      "Recovery data: OK" : "Recovery errors: #{recovery_errors.inspect}")
    lines.push(state_errors.empty? ?
      "State chance data: OK" : "State chance errors: #{state_errors.inspect}")
    return lines
  end

  def self.print_report
    audit_lines.each { |line| p line }
  end
end

# 先校正 AutoSetup 01 已存在的主技能表；Main 尚未執行，現在修改最安全。
FS_AUTOSET_SUPPORT_STATE_DATA_FIX.normalize_autoset_table!

#==============================================================================
# ■ 魂刻擴充相容
#------------------------------------------------------------------------------
# 魂刻擴充會在資料庫載入後再次產生 193～265 技能，因此在它的 apply
# 完成後再做一次最終校正。只改技能資料，不碰魂刻武器本身的屬性。
#==============================================================================
if defined?(FS_SOULMARK_RESONANCE)
  module FS_SOULMARK_RESONANCE
    class << self
      if method_defined?(:apply) &&
         !method_defined?(:fs_support_state_data_old_apply)
        alias fs_support_state_data_old_apply apply

        def apply
          result = fs_support_state_data_old_apply
          FS_AUTOSET_SUPPORT_STATE_DATA_FIX.normalize_autoset_table!
          FS_AUTOSET_SUPPORT_STATE_DATA_FIX.normalize_loaded_soul_skills!
          return result
        end
      end
    end
  end
end


#==============================================================================
