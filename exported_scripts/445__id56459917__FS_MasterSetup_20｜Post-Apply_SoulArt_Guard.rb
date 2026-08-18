#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_MasterSetup 20 Soul Art Integrity
# 【用途】Forest Symphony MasterSetup 資料頁「FS_MasterSetup 20 Soul Art Integrity」，集中定義正式遊戲資料／修正資料。
# 【主要機制】依 00～20 編號順序建立技能、狀態、物品、裝備、敵人、文字、Soulmark 等 Authority 資料，最終由 Apply 頁套用。
# 【主要影響】FS_SOUL_ART_INTEGRITY_FIX、FS_SOULMARK_RESONANCE
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：SOUL_SKILL_START、SUMMON_TARGET_SCOPES、STATUS_COUNT_STATE_IDS、CLEANSE_STATE_IDS、SPREAD_STATE_IDS、BUFF_STATE_IDS、HUD_FORCE_STATE_IDS、KNOWN_EFFECT_KEYS。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 2 個 alias／方法包裝，載入順序具有語意；登記 $imported：FS SoulArt Integrity Fix、FS Master Setup Ready；必須依 00～20 編號順序；18 Apply 不可提前。
# 【呼叫方式／範例】本頁屬啟動時依載入順序自動建立／套用資料，不需要事件 Script Call。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【Setup 分類】POST-APPLY INTEGRITY GUARD / SOUL ART
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
# ■ FS_MasterSetup 20 Soul Art Integrity
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2
# 載入順序：20 / 20
# 分類用途：魂刻資料、目標、狀態效果與 Help 一致性修正
#
# 本頁由 FS_MasterSetup_AllData_v1_1 自動等值拆分。
# 請依編號順序放置，並停用原本未拆分的整合頁，避免資料重複套用。
#==============================================================================

# ■ 內建：魂刻資料與執行一致性修正
#==============================================================================
#==============================================================================
# ■ FS_SoulArt_IntegrityFix_v1_0
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2
#
# 【修正範圍】
#   1. 魂刻支援技（Skill 200～265 中 Scope 7/8/9/10）
#      自動加入 <target_group: summon>，只選召喚物。
#   2. 回復／增益型魂刻技固定 HIT 100、非物理、無屬性。
#   3. 魂刻支援技的正面 State 改為真正必中，並補上 BattleStateHUD 顯示標籤。
#   4. 修正三招「混亂」誤用 State 41（魔力層），改用 State 71（混亂）。
#   5. 修正「鱗粉回音」異常擴散永遠不會執行。
#   6. 修正「蛛絲封域」被誤設成 1 傷害，改為真正的純狀態技能。
#   7. 修正魂刻共用的異常／增益清單，避免把魔力層當異常、
#      無法辨識混亂，以及漏判部分能力降低／增益。
#   8. 補記魂刻自訂狀態的 added／removed／remained 結果，
#      讓 HUD、狀態跳字與結果判斷同步。
#   9. 校正已確認與實際效果不一致或資訊缺漏的技能說明。
#  10. 額外校正 AutoSetup 主技能表靜態掃描發現的兩筆明確說明缺漏。
#
# 【放置位置】
#   FS_SoulMark_Resonance_Expansion
#   FS_AutoSetup_SupportStateDataFix_v1_0
#   ElementRate_FinalGuard_v1_1
#   FS_SupportStateSkillRules_v1_1
#   ↓
#   本補丁
#   ↓
#   全腳本導出工具
#   Main
#
# 【測試指令】
#   FS_SOUL_ART_INTEGRITY_FIX.print_report
#   FS_SOUL_ART_INTEGRITY_FIX.write_report
#
#   write_report 會在遊戲資料夾產生：
#   FS_SoulArt_Integrity_Report.txt
#
# 【注意】
#   BattleStateHUD 要畫出圖示，State 本身仍需有非 0 的 Icon Index。
#   本補丁會強制允許 HUD 顯示，但不擅自替你的 Iconset 指派圖案。
#==============================================================================

$imported = {} if $imported == nil
$imported["FS SoulArt Integrity Fix"] = "1.0"

module FS_SOUL_ART_INTEGRITY_FIX
  VERSION = "1.0"

  SOUL_SKILL_START = 200
  SUMMON_TARGET_SCOPES = [7, 8, 9, 10]

  # 用於「異常數量增傷」等判定。
  # 破勢／崩防可計入負面狀態數量，但不會被一般淨化或擴散。
  STATUS_COUNT_STATE_IDS = [
    31, 32, 33, 34, 35, 37, 38, 39,
    44, 45, 46, 47, 48, 49,
    50, 51,
    58, 59, 60, 61,
    67, 69, 71
  ]

  # 一般「解除異常」可移除的狀態。
  CLEANSE_STATE_IDS = [
    31, 32, 33, 34, 35, 37, 38, 39,
    44, 45, 46, 47, 48, 49,
    58, 59, 60, 61,
    67, 69, 71
  ]

  # 可由「鱗粉回音」擴散的異常。
  SPREAD_STATE_IDS = [
    31, 32, 33, 34, 35, 37, 38, 39,
    44, 45, 46, 47, 48, 49,
    67, 69, 71
  ]

  # 一般「移除增益」與正面 State 判定。
  BUFF_STATE_IDS = [
    52, 53, 54, 55, 56, 57, 62, 64, 65, 72
  ]

  # 需要在 BattleStateHUD 正常顯示的標準正面狀態。
  # Mana Shield／生命共同體另有專屬資訊，不在此強制重複顯示。
  HUD_FORCE_STATE_IDS = [54, 55, 56, 57, 62, 64, 65, 72]

  KNOWN_EFFECT_KEYS = [
    :atb_shift,
    :bonus_any_status,
    :bonus_low_hp,
    :bonus_low_hp2,
    :bonus_per_status,
    :bonus_target_atb,
    :bonus_vs_buff,
    :bonus_vs_state,
    :break,
    :cleanse,
    :cleanse_ids,
    :dispel,
    :drain,
    :heal_maxhp,
    :mp_restore,
    :spread,
    :state,
    :state2,
    :state_if_state,
    :user_atb_shift,
    :user_state
  ]

  DESCRIPTION_OVERRIDES = {
    201 => "火屬性單體攻擊；35%灼燒。對灼燒目標增傷45%，HP低於30%再增傷35%，並削減10% ATB。",
    202 => "恢復單體召喚物14%最大HP，解除濕潤並提高防禦。",
    203 => "蟲屬性單體攻擊；65%脆弱。若目標已有可擴散異常，複製其中一種給另一名敵人。",
    208 => "毒屬性單體攻擊；65%疊2層中毒、55%遲緩。目標原本中毒時，45%追加腐蝕。",
    209 => "電屬性單體攻擊；35%麻痺。對已濕潤目標增傷50%，另擲30%麻痺，並削減15% ATB。",
    210 => "恢復單體召喚物10%最大HP，並提高攻擊與防禦。",
    213 => "飛行屬性單體攻擊，削減22% ATB並有35%機率混亂。",
    214 => "毒屬性單體攻擊；55%疊3層中毒。目標原本中毒時，45%追加腐蝕。",
    216 => "蟲屬性全體攻擊；45%盲目，20%混亂。",
    220 => "恢復全體召喚物8%最大HP並提高防禦。",
    224 => "恢復單體召喚物8%最大HP，並提高防禦、獲得護盾。",
    225 => "火屬性單體物理攻擊；40%灼燒。目標ATB達70%以上時增傷35%，喬伊推進15% ATB。",
    229 => "幽靈屬性單體攻擊；目標每有一種異常增傷12%，並有45%機率混亂。",
    233 => "恢復單體召喚物12%最大HP，並提高防禦與精神。",
    236 => "解除全體召喚物各一個異常，並提高攻擊、防禦與精神。",
    237 => "提高全體召喚物敏捷並推進12% ATB。",
    238 => "敵全體狀態技；65%遲緩，30%根縛。",
    239 => "恢復全體召喚物15%最大HP，解除各一個異常並提高精神。",
    241 => "恢復單體召喚物12%最大MP，並提高精神與敏捷。",
    242 => "電屬性全體攻擊；濕潤目標增傷45%，削減12% ATB，並有30%機率麻痺。",
    244 => "恢復全體召喚物12%最大HP，提高防禦，並解除濕潤、遲緩與冰凍。",
    246 => "水屬性全體攻擊；65%濕潤並削減8% ATB。",
    247 => "恢復全體召喚物8%最大HP，並提高防禦與敏捷。",
    249 => "鋼屬性單體物理攻擊；45%脆弱並移除一個增益，有增益時增傷30%。",
    252 => "恢復單體召喚物25%最大HP，解除兩個異常並提高精神。",
    257 => "冰屬性單體攻擊；65%遲緩、18%冰凍，並削減12% ATB。",
    259 => "水屬性單體攻擊；70%濕潤。目標原本已濕潤時，另有35%機率麻痺。",
    262 => "蟲屬性單體物理攻擊，吸收40%傷害、累積1層破勢；對崩防目標增傷30%。",
    263 => "惡屬性單體物理攻擊；50%灼燒、35%脆弱，對灼燒目標增傷30%。",
    265 => "恢復全體召喚物12%最大HP，解除各一個異常並提高精神。"
  }

  # AutoSetup 主技能表 290 筆結構掃描後，確認有兩筆說明漏掉實際效果。
  GENERAL_SKILL_HELP_OVERRIDES = {
    129 => "敵全體電爆發；高ATB敵人越多越有效，並有25%機率麻痺。",
    720 => "自身獲得攻擊、精神與速度提升。"
  }

  def self.note_string(value)
    if value.is_a?(Array)
      return value.compact.collect { |line| line.to_s }.join("\n")
    end
    return value.to_s
  end

  def self.append_note(value, tag, regexp)
    text = note_string(value)
    return value if text =~ regexp

    if value.is_a?(Array)
      result = value.dup
      result.push(tag)
      return result
    end

    text = text.gsub(/\s+\z/, "")
    return tag if text.empty?
    return text + "\n" + tag
  end

  def self.set_value(obj, key, value)
    return if obj == nil
    writer = (key.to_s + "=").to_sym
    if obj.respond_to?(writer)
      obj.send(writer, value)
    else
      obj.instance_variable_set(("@" + key.to_s).to_sym, value)
    end
  rescue
  end

  def self.arts
    return [] unless defined?(FS_SOULMARK_RESONANCE)
    return [] unless FS_SOULMARK_RESONANCE.const_defined?(:SOUL_ARTS)
    result = FS_SOULMARK_RESONANCE::SOUL_ARTS
    return result.is_a?(Array) ? result : []
  end

  def self.art_by_skill_id(skill_id)
    index = skill_id.to_i - SOUL_SKILL_START
    return nil if index < 0 || index >= arts.size
    return arts[index]
  end

  def self.replace_effect_state(skill_id, key, old_id, new_id)
    art = art_by_skill_id(skill_id)
    return if art == nil
    effects = art[:effects]
    return unless effects.is_a?(Hash)
    data = effects[key]
    return unless data.is_a?(Array)
    return unless data[0].to_i == old_id.to_i
    data[0] = new_id.to_i
  end

  def self.soul_recovery?(art)
    return false unless art.is_a?(Hash)
    effects = art[:effects]
    effects = {} unless effects.is_a?(Hash)
    return true if effects.has_key?(:heal_maxhp)
    return true if effects.has_key?(:mp_restore)
    return false
  end

  def self.summon_support?(art)
    return false unless art.is_a?(Hash)
    return SUMMON_TARGET_SCOPES.include?(art[:scope].to_i)
  end

  #--------------------------------------------------------------------------
  # ● 修正 SOUL_ARTS 資料源
  #--------------------------------------------------------------------------
  def self.patch_soul_art_data
    return if arts.empty?

    # State 41 現在是「魔力層」；真正的「混亂」是 State 71。
    replace_effect_state(213, :state,  41, 71)
    replace_effect_state(216, :state2, 41, 71)
    replace_effect_state(229, :state,  41, 71)

    # 純狀態技不應帶 1 點假傷害。
    art = art_by_skill_id(238)
    art[:base_damage] = 0 if art != nil

    DESCRIPTION_OVERRIDES.each do |skill_id, description|
      art = art_by_skill_id(skill_id)
      art[:description] = description if art != nil
    end

    # 統一目前系統正式用語。
    arts.each do |entry|
      next unless entry.is_a?(Hash)
      entry[:description] = entry[:description].to_s.gsub("崩勢", "崩防")
    end

    # 舊常數同時被部分既有函式直接讀取，故原地更新，不重建常數。
    if FS_SOULMARK_RESONANCE.const_defined?(:HARMFUL_STATES)
      FS_SOULMARK_RESONANCE::HARMFUL_STATES.replace(STATUS_COUNT_STATE_IDS)
    end
    if FS_SOULMARK_RESONANCE.const_defined?(:BUFF_STATES)
      FS_SOULMARK_RESONANCE::BUFF_STATES.replace(BUFF_STATE_IDS)
    end
  end

  #--------------------------------------------------------------------------
  # ● 修正 AutoSetup 一般技能說明資料源
  #--------------------------------------------------------------------------
  def self.patch_general_skill_help_data
    return unless defined?(FS_AUTOSET_PLAYER_TEXT_V12)
    return unless FS_AUTOSET_PLAYER_TEXT_V12.const_defined?(:SKILL_HELP)
    table = FS_AUTOSET_PLAYER_TEXT_V12::SKILL_HELP
    return unless table.is_a?(Hash)

    GENERAL_SKILL_HELP_OVERRIDES.each do |skill_id, description|
      table[skill_id] = description
    end
  end

  #--------------------------------------------------------------------------
  # ● 修正已載入的一般技能說明
  #--------------------------------------------------------------------------
  def self.patch_loaded_general_skill_help
    return if $data_skills == nil
    GENERAL_SKILL_HELP_OVERRIDES.each do |skill_id, description|
      skill = $data_skills[skill_id] rescue nil
      set_value(skill, :description, description) if skill != nil
    end
  end

  #--------------------------------------------------------------------------
  # ● 修正 AutoSetup 的正面 State 資料源
  #--------------------------------------------------------------------------
  def self.patch_state_autoset_data
    return unless defined?(FS_DB_AUTOSET_STATES)
    return unless FS_DB_AUTOSET_STATES.const_defined?(:DATA)
    table = FS_DB_AUTOSET_STATES::DATA
    return unless table.is_a?(Hash)

    BUFF_STATE_IDS.each do |state_id|
      data = table[state_id]
      next unless data.is_a?(Hash)

      # 「提高精神／防禦／敏捷」等沒有寫機率時，應真正必定附加。
      data[:nonresistance] = true

      next unless HUD_FORCE_STATE_IDS.include?(state_id)
      data[:note] = append_note(
        data[:note],
        "<hud_show>",
        /<\s*(?:hud_show|show_battle_hud|HUD顯示|HUD強制顯示)\s*>/i
      )
      data[:note] = append_note(
        data[:note],
        "<hud_priority:120>",
        /<\s*hud_priority\s*:/i
      )
    end
  end

  #--------------------------------------------------------------------------
  # ● 修正已載入的 State 物件
  #--------------------------------------------------------------------------
  def self.patch_loaded_states
    return if $data_states == nil

    BUFF_STATE_IDS.each do |state_id|
      state = $data_states[state_id] rescue nil
      next if state == nil

      set_value(state, :nonresistance, true)

      next unless HUD_FORCE_STATE_IDS.include?(state_id)
      note = state.respond_to?(:note) ? state.note : ""
      note = append_note(
        note,
        "<hud_show>",
        /<\s*(?:hud_show|show_battle_hud|HUD顯示|HUD強制顯示)\s*>/i
      )
      note = append_note(
        note,
        "<hud_priority:120>",
        /<\s*hud_priority\s*:/i
      )
      set_value(state, :note, note)
    end
  end

  #--------------------------------------------------------------------------
  # ● 修正產生中的魂刻技能資料
  #--------------------------------------------------------------------------
  def self.normalize_skill_data(index, data)
    return data unless data.is_a?(Hash)
    art = arts[index.to_i]
    return data unless art.is_a?(Hash)

    data[:name] = art[:name]
    data[:description] = art[:description]
    data[:scope] = art[:scope]
    data[:base_damage] = art[:base_damage]
    data[:plus_state_set] = (art[:plus_states] || []).clone

    if summon_support?(art)
      data[:hit] = 100
      data[:physical_attack] = false
      data[:element_set] = []
      data[:note] = append_note(
        data[:note],
        "<target_group: summon>",
        /<\s*target_group\s*:/i
      )

      if soul_recovery?(art)
        data[:note] = append_note(
          data[:note],
          "<回復技能>",
          /[<＜](?:回復技能|回复技能|恢復技能|恢复技能)[>＞]/i
        )
      else
        data[:note] = append_note(
          data[:note],
          "<狀態技能>",
          /[<＜](?:狀態技能|状态技能)[>＞]/i
        )
      end
    end

    return data
  end

  #--------------------------------------------------------------------------
  # ● 修正已載入的 Skill 200～265
  #--------------------------------------------------------------------------
  def self.normalize_loaded_skills
    return if $data_skills == nil

    arts.each_with_index do |art, index|
      skill_id = SOUL_SKILL_START + index
      skill = $data_skills[skill_id] rescue nil
      next if skill == nil

      set_value(skill, :name, art[:name])
      set_value(skill, :description, art[:description])
      set_value(skill, :scope, art[:scope])
      set_value(skill, :base_damage, art[:base_damage])

      states = (art[:plus_states] || []).clone
      if skill.respond_to?(:plus_state_set) &&
         skill.plus_state_set.respond_to?(:replace)
        skill.plus_state_set.replace(states)
      else
        set_value(skill, :plus_state_set, states)
      end

      if summon_support?(art)
        set_value(skill, :hit, 100)
        set_value(skill, :physical_attack, false)
        set_value(skill, :element_set, [])

        note = skill.respond_to?(:note) ? skill.note : ""
        note = append_note(
          note,
          "<target_group: summon>",
          /<\s*target_group\s*:/i
        )
        if soul_recovery?(art)
          note = append_note(
            note,
            "<回復技能>",
            /[<＜](?:回復技能|回复技能|恢復技能|恢复技能)[>＞]/i
          )
        else
          note = append_note(
            note,
            "<狀態技能>",
            /[<＜](?:狀態技能|状态技能)[>＞]/i
          )
        end
        set_value(skill, :note, note)
      end

      if defined?(FS_DB_AUTOSET) &&
         FS_DB_AUTOSET.respond_to?(:invalidate_note_cache)
        FS_DB_AUTOSET.invalidate_note_cache(skill)
      end
    end
  end

  #--------------------------------------------------------------------------
  # ● 狀態結果記錄
  #--------------------------------------------------------------------------
  def self.state_stack_value(target, state_id)
    return 0 if target == nil
    if target.respond_to?(:stack)
      begin
        return target.stack(state_id).to_i
      rescue
      end
    end
    return target.state?(state_id) ? 1 : 0
  rescue
    return 0
  end

  def self.result_array(target, variable_name)
    result = target.instance_variable_get(variable_name)
    unless result.is_a?(Array)
      result = []
      target.instance_variable_set(variable_name, result)
    end
    return result
  end

  def self.add_state_and_record(target, state_id)
    return false if target == nil
    state_id = state_id.to_i
    return false if state_id <= 0

    before_exists = target.state?(state_id)
    before_stack = state_stack_value(target, state_id)

    target.add_state(state_id)

    after_exists = target.state?(state_id)
    after_stack = state_stack_value(target, state_id)
    success = (!before_exists && after_exists) || (after_stack > before_stack)

    if !before_exists && after_exists
      result = result_array(target, :@added_states)
      result.push(state_id) unless result.include?(state_id)
    elsif after_exists
      # 已存在 State 的刷新／疊層，沿用 VX 的 remained 結果語意。
      result = result_array(target, :@remained_states)
      result.push(state_id) unless result.include?(state_id)
    end
    return success
  rescue
    return false
  end

  def self.remove_state_and_record(target, state_id)
    return false if target == nil
    state_id = state_id.to_i
    return false unless target.state?(state_id)

    target.remove_state(state_id)
    result = result_array(target, :@removed_states)
    result.push(state_id) unless result.include?(state_id)
    return true
  rescue
    return false
  end

  #--------------------------------------------------------------------------
  # ● 報告
  #--------------------------------------------------------------------------
  def self.effect_state_ids(effects)
    result = []
    return result unless effects.is_a?(Hash)

    [:state, :state2, :user_state].each do |key|
      data = effects[key]
      result.push(data[0].to_i) if data.is_a?(Array) && data.size >= 1
    end

    data = effects[:state_if_state]
    if data.is_a?(Array)
      result.push(data[0].to_i) if data.size >= 1
      result.push(data[1].to_i) if data.size >= 2
    end

    return result.uniq
  end

  def self.audit_lines
    result = []
    errors = []
    warnings = []

    result.push("FS SoulArt Integrity Fix v" + VERSION)
    result.push("==================================================")
    result.push("Soul Arts checked: " + arts.size.to_s + "/66")

    arts.each_with_index do |art, index|
      skill_id = SOUL_SKILL_START + index
      unless art.is_a?(Hash)
        errors.push("S#{skill_id}: Soul Art data is not a Hash")
        next
      end

      effects = art[:effects]
      effects = {} unless effects.is_a?(Hash)

      unknown = effects.keys - KNOWN_EFFECT_KEYS
      unless unknown.empty?
        errors.push("S#{skill_id} #{art[:name]}: unknown effects #{unknown.inspect}")
      end

      if art[:description].to_s.empty?
        errors.push("S#{skill_id} #{art[:name]}: empty description")
      end

      if summon_support?(art) && $data_skills != nil
        skill = $data_skills[skill_id] rescue nil
        if skill == nil
          errors.push("S#{skill_id} #{art[:name]}: missing loaded skill")
        elsif skill.note.to_s !~ /<\s*target_group\s*:\s*summon\s*>/i
          errors.push("S#{skill_id} #{art[:name]}: missing target_group:summon")
        end
      end

      all_state_ids = (art[:plus_states] || []) + effect_state_ids(effects)
      all_state_ids.uniq.each do |state_id|
        next if state_id.to_i <= 0
        if $data_states != nil && $data_states[state_id.to_i] == nil
          errors.push("S#{skill_id} #{art[:name]}: missing State #{state_id}")
        end
      end
    end

    if $data_states != nil
      HUD_FORCE_STATE_IDS.each do |state_id|
        state = $data_states[state_id] rescue nil
        next if state == nil
        if state.respond_to?(:icon_index) && state.icon_index.to_i <= 0
          warnings.push(
            "State #{state_id} #{state.name}: Icon Index is 0; HUD has no visible icon art"
          )
        end
      end
    end

    result.push(errors.empty? ? "Integrity errors: none" :
      "Integrity errors: " + errors.size.to_s)
    errors.each { |line| result.push("  ERROR: " + line) }

    result.push(warnings.empty? ? "Warnings: none" :
      "Warnings: " + warnings.size.to_s)
    warnings.each { |line| result.push("  WARN: " + line) }

    result.push("")
    result.push("Fixed summon-target Soul Arts: 17")
    result.push("Fixed confusion State references: S213, S216, S229")
    result.push("Fixed spread logic: S203")
    result.push("Fixed pure state damage: S238")
    result.push("Soul Art description corrections applied: " +
      DESCRIPTION_OVERRIDES.size.to_s)
    result.push("General AutoSetup help corrections applied: " +
      GENERAL_SKILL_HELP_OVERRIDES.size.to_s)
    return result
  end

  def self.print_report
    audit_lines.each { |line| p line }
  end

  def self.write_report
    begin
      File.open("FS_SoulArt_Integrity_Report.txt", "wb") do |file|
        file.write(audit_lines.join("\r\n"))
      end
      return true
    rescue
      return false
    end
  end
end


#==============================================================================
# ■ 先修正資料源
#==============================================================================

FS_SOUL_ART_INTEGRITY_FIX.patch_soul_art_data
FS_SOUL_ART_INTEGRITY_FIX.patch_general_skill_help_data
FS_SOUL_ART_INTEGRITY_FIX.patch_state_autoset_data


#==============================================================================
# ■ FS_SOULMARK_RESONANCE：生成資料與共用效果修正
#==============================================================================

if defined?(FS_SOULMARK_RESONANCE)

  module FS_SOULMARK_RESONANCE
    class << self

      #------------------------------------------------------------------------
      # ● 生成 Skill 200～265 時補上目標群組與校正資料
      #------------------------------------------------------------------------
      if method_defined?(:soul_skill_data) &&
         !method_defined?(:fs_saif_old_soul_skill_data)

        alias fs_saif_old_soul_skill_data soul_skill_data

        def soul_skill_data(index)
          data = fs_saif_old_soul_skill_data(index)
          return FS_SOUL_ART_INTEGRITY_FIX.normalize_skill_data(index, data)
        end
      end

      #------------------------------------------------------------------------
      # ● 異常數量
      #------------------------------------------------------------------------
      def status_count(battler)
        count = 0
        FS_SOUL_ART_INTEGRITY_FIX::STATUS_COUNT_STATE_IDS.each do |state_id|
          count += 1 if battler != nil && battler.state?(state_id)
        end
        return count
      end

      #------------------------------------------------------------------------
      # ● 是否有可移除增益
      #------------------------------------------------------------------------
      def has_buff?(battler)
        FS_SOUL_ART_INTEGRITY_FIX::BUFF_STATE_IDS.each do |state_id|
          return true if battler != nil && battler.state?(state_id)
        end
        return false
      end

      #------------------------------------------------------------------------
      # ● 魂刻自訂 State 機率與結果記錄
      #------------------------------------------------------------------------
      def apply_state_chance(target, data)
        return unless data.is_a?(Array) && data.size >= 3

        state_id = data[0].to_i
        chance = data[1].to_i
        stacks = data[2].to_i
        return if state_id <= 0 || stacks <= 0

        if target.respond_to?(:state_probability)
          begin
            chance = chance * target.state_probability(state_id).to_i / 100
          rescue
          end
        end

        return unless rand(100) < chance

        stacks.times do
          FS_SOUL_ART_INTEGRITY_FIX.add_state_and_record(target, state_id)
        end
      end

      #------------------------------------------------------------------------
      # ● 解除一般異常
      #------------------------------------------------------------------------
      def cleanse(target, count)
        count = count.to_i
        return if count <= 0

        FS_SOUL_ART_INTEGRITY_FIX::CLEANSE_STATE_IDS.each do |state_id|
          next unless target != nil && target.state?(state_id)
          if FS_SOUL_ART_INTEGRITY_FIX.remove_state_and_record(target, state_id)
            count -= 1
            break if count <= 0
          end
        end
      end

      #------------------------------------------------------------------------
      # ● 解除指定異常
      #------------------------------------------------------------------------
      def cleanse_ids(target, ids)
        return unless ids.is_a?(Array)
        ids.each do |state_id|
          FS_SOUL_ART_INTEGRITY_FIX.remove_state_and_record(target, state_id)
        end
      end

      #------------------------------------------------------------------------
      # ● 移除增益
      #------------------------------------------------------------------------
      def dispel(target, count)
        count = count.to_i
        return if count <= 0

        FS_SOUL_ART_INTEGRITY_FIX::BUFF_STATE_IDS.each do |state_id|
          next unless target != nil && target.state?(state_id)
          if FS_SOUL_ART_INTEGRITY_FIX.remove_state_and_record(target, state_id)
            count -= 1
            break if count <= 0
          end
        end
      end

      #------------------------------------------------------------------------
      # ● 將目標的一種異常擴散給同陣營另一名成員
      #------------------------------------------------------------------------
      def spread_one_state(source)
        return if source == nil

        state_id = 0
        FS_SOUL_ART_INTEGRITY_FIX::SPREAD_STATE_IDS.each do |id|
          if source.state?(id)
            state_id = id
            break
          end
        end
        return if state_id <= 0

        # source 是被攻擊的目標；要找的是 source 的同伴，不是對手。
        unit = source.actor? ? $game_party : $game_troop
        return if unit == nil

        candidates = unit.existing_members.select { |member|
          member != nil && member != source
        }
        return if candidates.empty?

        target = candidates[rand(candidates.size)]
        FS_SOUL_ART_INTEGRITY_FIX.add_state_and_record(target, state_id)
      end

      #------------------------------------------------------------------------
      # ● SoulMark apply 完成後做最終同步
      #------------------------------------------------------------------------
      if method_defined?(:apply) &&
         !method_defined?(:fs_saif_old_apply)

        alias fs_saif_old_apply apply

        def apply
          result = fs_saif_old_apply
          FS_SOUL_ART_INTEGRITY_FIX.patch_soul_art_data
          FS_SOUL_ART_INTEGRITY_FIX.patch_loaded_states
          FS_SOUL_ART_INTEGRITY_FIX.patch_loaded_general_skill_help
          FS_SOUL_ART_INTEGRITY_FIX.normalize_loaded_skills
          return result
        end
      end
    end
  end
end



#==============================================================================
# ■ Master 最終重新套用
#------------------------------------------------------------------------------
# 內建修正可能調整主表；此處不再重置主表，只輸出載入標記。
#==============================================================================
$imported["FS Master Setup Ready"] = true
