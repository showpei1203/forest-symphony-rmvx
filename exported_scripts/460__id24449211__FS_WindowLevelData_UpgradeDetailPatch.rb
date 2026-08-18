#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_WindowLevelData_UpgradeDetailPatch
# 【用途】Forest Symphony 相容／修正頁「FS_WindowLevelData_UpgradeDetailPatch」，針對既有系統補正專案需要的行為。
# 【主要機制】通常透過 alias／class reopen 包裝前方實作；它不是可任意搬動的獨立功能，需維持在被修正腳本之後。
# 【主要影響】Window_LevelData、FS_WINDOW_LEVEL_DETAIL
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：PRESERVE_CUSTOM_PAGE_IDS、STATE_CHANCE_TAG。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 1 個 alias／方法包裝，載入順序具有語意；登記 $imported：FS_WindowLevelData_UpgradeDetailPatch、CustomDamageControl；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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
# -*- coding: utf-8 -*-
#==============================================================================
# ** FS_WindowLevelData_UpgradeDetailPatch v1.0
#------------------------------------------------------------------------------
#  Forest Symphony／RPG Maker VX／RGSS2／Ruby 1.8
#------------------------------------------------------------------------------
# 【目的】
#
#  修正 YEZ JobSystemSkillLevels 的 Window_LevelData：
#
#  1. 升級數值改為顯示「目前 → 升級後」。
#
#       傷害加乘  108% → 116%
#       治療加乘  108% → 116%
#
#  2. 固定不變的 MP 消耗不再假裝是升級收益。
#
#     原版 draw_cost_bonus? 只判斷技能是否有 MP 消耗，因此所有有 MP
#     消耗的可升級技能都會顯示 MP 列，即使 <level cost> 完全沒有改變。
#
#  3. 支援 Note 宣告的狀態：
#
#       <state_chance 31:30>
#
#     ALBERT_STATE_CHANCE_V27 會在實際技能效果期間，暫時把這些 State
#     加進 plus_state_set，因此 JobSystemSkillLevels 的 DEFAULT_STATE_UP
#     仍會增加狀態持續時間。
#
#     原 Window_LevelData 只讀資料庫 plus_state_set，所以完全看不到。
#     本補丁會顯示：
#
#       中毒持續  4回合 → 6回合
#
#  4. 滿級升級模式與基本等級降級模式不再讀取不存在的 JP 費用。
#
#  5. 保留 Skill 104「鳴刻指令」既有的專用升級頁。
#
# 【目前全腳本稽核】
#
#    ・一般 MasterSetup 可升級技能：122
#    ・鳴刻指令執行時轉為可升級：1
#    ・實際可升級技能合計：123
#    ・使用 <state_chance> 且原視窗漏顯示持續時間：47
#    ・治療技能：5
#    ・零傷害卻只有傷害倍率升級的無效技能：0
#
# 【重要但不改動的既有規則】
#
#  YEZ::JOB::DEFAULT_STATE_UP 目前為 2。
#  所以所有可升級且成功附加 Note State 的技能，每級實際增加 2 回合。
#
#  本補丁只把真實效果顯示出來，不擅自改成 0，也不調整技能平衡。
#
# 【安裝位置】
#
#  放在以下腳本全部下方、Main 正上方：
#
#    JobSystemSkillLevels
#    SummonSkillLevel_UI
#    ALBERT_STATE_CHANCE_V27
#    FS_MarkedCommand_ConditionTransparency v1.4
#
#  本腳本不修改技能 Note、傷害公式、JP、技能等級或狀態回合。
#==============================================================================

$imported = {} if $imported == nil
$imported["FS_WindowLevelData_UpgradeDetailPatch"] = "1.0"

unless defined?(Window_LevelData)
  raise "FS_WindowLevelData_UpgradeDetailPatch 必須放在 Window_LevelData 下方。"
end

module FS_WINDOW_LEVEL_DETAIL
  VERSION = "1.0"

  # 這些技能已經有更完整的專用 Window_LevelData 頁面。
  PRESERVE_CUSTOM_PAGE_IDS = [104]

  STATE_CHANCE_TAG =
    /<state_chance\s+(\d+)\s*:\s*-?[0-9]+(?:\.[0-9]+)?\s*>/i

  def self.preserve_original_page?(skill)
    return false if skill == nil
    return PRESERVE_CUSTOM_PAGE_IDS.include?(skill.id)
  end

  def self.note_state_ids(skill)
    result = []
    return result if skill == nil
    text = skill.note == nil ? "" : skill.note.to_s

    text.scan(STATE_CHANCE_TAG) do |data|
      state_id = data[0].to_i
      result.push(state_id) unless result.include?(state_id)
    end

    return result
  end

  def self.all_applied_state_ids(skill)
    result = []

    if skill != nil && skill.respond_to?(:plus_state_set)
      for state_id in skill.plus_state_set
        result.push(state_id) unless result.include?(state_id)
      end
    end

    for state_id in note_state_ids(skill)
      result.push(state_id) unless result.include?(state_id)
    end

    return result
  end

  def self.short_state_name(state)
    return "狀態" if state == nil
    name = state.name.to_s
    return "狀態" if name.empty?

    # MasterSetup 部分 State 名稱為「中毒 Poison」。
    # 升級視窗較窄，只取第一段中文名稱。
    words = name.split(/[ ]+/)
    return words[0].to_s
  end
end

#==============================================================================
# ** Window_LevelData
#==============================================================================
class Window_LevelData < Window_Base

  unless method_defined?(:fs_wld_v10_original_refresh)
    alias fs_wld_v10_original_refresh refresh
  end

  #--------------------------------------------------------------------------
  # ● 全面刷新
  #--------------------------------------------------------------------------
  def refresh(skill, class_id)
    if FS_WINDOW_LEVEL_DETAIL.preserve_original_page?(skill)
      return fs_wld_v10_original_refresh(skill, class_id)
    end

    self.contents.clear
    self.contents.font.color = normal_color
    self.contents.font.size = Font.default_size

    @skill = skill
    @class_id = class_id
    return if @skill == nil

    draw_skill_name

    self.contents.font.size = YEZ::JOB::REQUIRE_SIZE
    dy = WLH

    dy = draw_level(dy)
    dy = draw_jp_cost(dy) if fs_wld_transition_valid?

    dy = fs_wld_draw_damage(dy)
    dy = fs_wld_draw_level_cost(dy)
    dy = fs_wld_draw_hit(dy)
    dy = fs_wld_draw_speed(dy)
    dy = fs_wld_draw_cooldown(dy)
    dy = fs_wld_draw_limited_use(dy)
    dy = fs_wld_draw_chain(dy)
    dy = fs_wld_draw_states(dy)

    # 理論上目前 122 個一般可升級技能至少都會顯示傷害／治療。
    # 留一行防呆，免得未來新增只有自訂效果、卻沒有專用頁的技能。
    if dy <= WLH * 3
      dy = fs_wld_draw_row(
        dy,
        "升級效果",
        "未登錄自訂明細",
        @skill.icon_index
      )
    end
  end

  #--------------------------------------------------------------------------
  # ● 等級
  #--------------------------------------------------------------------------
  def fs_wld_current_level
    value = @actor.skill_level(@skill).to_i
    value = 0 if value < 0
    value = @skill.max_level if value > @skill.max_level
    return value
  end

  def fs_wld_target_level
    current = fs_wld_current_level
    target = @mode ? current + 1 : current - 1
    target = 0 if target < 0
    target = @skill.max_level if target > @skill.max_level
    return target
  end

  def fs_wld_transition_valid?
    current = fs_wld_current_level
    return current < @skill.max_level if @mode
    return current > 0
  end

  #--------------------------------------------------------------------------
  # ● 顯示工具
  #--------------------------------------------------------------------------
  def fs_wld_pair(left, right, suffix = "")
    left_text = left.to_s + suffix.to_s
    return left_text if left == right
    return left_text + " → " + right.to_s + suffix.to_s
  end

  def fs_wld_draw_row(dy, label, value, icon = nil)
    return dy if dy + WLH > self.contents.height

    if icon != nil && icon.to_i > 0
      draw_icon(icon.to_i, 0, dy)
      text_x = 24
      text_width = self.width - 56
      value_width = self.width - 60
    else
      text_x = 0
      text_width = self.width - 32
      value_width = self.width - 36
    end

    self.contents.font.color = system_color
    self.contents.draw_text(text_x, dy, text_width, WLH, label.to_s)

    self.contents.font.color = normal_color
    self.contents.draw_text(
      text_x,
      dy,
      value_width,
      WLH,
      value.to_s,
      2
    )

    return dy + WLH
  end

  def fs_wld_table_value(table, level)
    return 0 if table == nil
    value = table[level]
    return value == nil ? 0 : value.to_i
  end

  def fs_wld_table_varies?(table)
    return false if table == nil

    values = []
    for level in 0..@skill.max_level
      value = fs_wld_table_value(table, level)
      values.push(value) unless values.include?(value)
    end

    return values.size > 1
  end

  #--------------------------------------------------------------------------
  # ● 傷害／治療
  #--------------------------------------------------------------------------
  def fs_wld_damage_skill?
    return true if @skill.base_damage.to_i != 0

    if $imported["CustomDamageControl"]
      return true if @skill.respond_to?(:base_dmg) &&
        @skill.base_dmg.to_i != 0
      return true if @skill.respond_to?(:custom_dmg) &&
        @skill.custom_dmg != nil &&
        @skill.custom_dmg != []
    end

    return false
  end

  def fs_wld_healing_skill?
    return true if @skill.base_damage.to_i < 0

    if $imported["CustomDamageControl"] &&
       @skill.respond_to?(:base_dmg)
      return true if @skill.base_dmg.to_i < 0
    end

    return false
  end

  def fs_wld_draw_damage(dy)
    return dy unless fs_wld_damage_skill?

    current = fs_wld_current_level
    target = fs_wld_target_level

    current_rate = 100 + fs_wld_table_value(@skill.level_dmg, current)
    target_rate = 100 + fs_wld_table_value(@skill.level_dmg, target)

    current_rate = 0 if current_rate < 0
    target_rate = 0 if target_rate < 0

    if fs_wld_healing_skill?
      label = "治療加乘"
      icon = YEZ::JOB::LEVEL_ICONS[:heal]
    else
      label = "傷害加乘"
      icon = YEZ::JOB::LEVEL_ICONS[:dmg]
    end

    return fs_wld_draw_row(
      dy,
      label,
      fs_wld_pair(current_rate, target_rate, "%"),
      icon
    )
  end

  #--------------------------------------------------------------------------
  # ● MP 消耗
  #--------------------------------------------------------------------------
  def fs_wld_mp_cost_at(level)
    current = fs_wld_current_level
    old_temp = @actor.temp_level

    begin
      @actor.temp_level = level.to_i - current
      return @actor.calc_mp_cost(@skill).to_i
    ensure
      @actor.temp_level = old_temp
    end
  end

  def fs_wld_mp_cost_varies?
    values = []

    for level in 0..@skill.max_level
      value = fs_wld_mp_cost_at(level)
      values.push(value) unless values.include?(value)
    end

    return values.size > 1
  end

  def fs_wld_draw_level_cost(dy)
    # 固定 MP 消耗不屬於升級收益。
    return dy unless fs_wld_mp_cost_varies?

    current = fs_wld_mp_cost_at(fs_wld_current_level)
    target = fs_wld_mp_cost_at(fs_wld_target_level)

    return fs_wld_draw_row(
      dy,
      Vocab.mp.to_s + "消耗",
      fs_wld_pair(current, target),
      YEZ::JOB::LEVEL_ICONS[:cost]
    )
  end

  #--------------------------------------------------------------------------
  # ● 命中率
  #--------------------------------------------------------------------------
  def fs_wld_hit_at(level)
    value = @skill.hit.to_i +
      fs_wld_table_value(@skill.level_hit, level)
    return [[value, 100].min, 0].max
  end

  def fs_wld_draw_hit(dy)
    return dy unless fs_wld_table_varies?(@skill.level_hit)

    current = fs_wld_hit_at(fs_wld_current_level)
    target = fs_wld_hit_at(fs_wld_target_level)

    return fs_wld_draw_row(
      dy,
      "命中率",
      fs_wld_pair(current, target, "%"),
      YEZ::JOB::LEVEL_ICONS[:hit]
    )
  end

  #--------------------------------------------------------------------------
  # ● 行動速度
  #--------------------------------------------------------------------------
  def fs_wld_speed_at(level)
    return @skill.speed.to_i +
      fs_wld_table_value(@skill.level_speed, level)
  end

  def fs_wld_draw_speed(dy)
    return dy unless fs_wld_table_varies?(@skill.level_speed)

    current = fs_wld_speed_at(fs_wld_current_level)
    target = fs_wld_speed_at(fs_wld_target_level)

    return fs_wld_draw_row(
      dy,
      "行動速度",
      fs_wld_pair(current, target),
      YEZ::JOB::LEVEL_ICONS[:speed]
    )
  end

  #--------------------------------------------------------------------------
  # ● 冷卻
  #--------------------------------------------------------------------------
  def fs_wld_cooldown_at(level)
    return 0 unless @skill.respond_to?(:cooldown)
    value = @skill.cooldown.to_i +
      fs_wld_table_value(@skill.level_cool, level)
    return [value, 0].max
  end

  def fs_wld_draw_cooldown(dy)
    return dy unless @skill.respond_to?(:level_cool)
    return dy unless fs_wld_table_varies?(@skill.level_cool)

    current = fs_wld_cooldown_at(fs_wld_current_level)
    target = fs_wld_cooldown_at(fs_wld_target_level)

    icon = @skill.icon_index
    if defined?(YEZ::SKILL::COOLDOWN)
      icon = YEZ::SKILL::COOLDOWN[:icon_id]
    end

    return fs_wld_draw_row(
      dy,
      "冷卻",
      fs_wld_pair(current, target, "回合"),
      icon
    )
  end

  #--------------------------------------------------------------------------
  # ● 使用次數
  #--------------------------------------------------------------------------
  def fs_wld_limited_at(level)
    return 0 unless @skill.respond_to?(:limited_use)
    value = @skill.limited_use.to_i +
      fs_wld_table_value(@skill.level_limit, level)
    return [value, 0].max
  end

  def fs_wld_draw_limited_use(dy)
    return dy unless @skill.respond_to?(:level_limit)
    return dy unless fs_wld_table_varies?(@skill.level_limit)

    current = fs_wld_limited_at(fs_wld_current_level)
    target = fs_wld_limited_at(fs_wld_target_level)

    icon = @skill.icon_index
    if defined?(YEZ::SKILL::LIMITED_USE)
      icon = YEZ::SKILL::LIMITED_USE[:icon_id]
    end

    return fs_wld_draw_row(
      dy,
      "使用次數",
      fs_wld_pair(current, target, "次"),
      icon
    )
  end

  #--------------------------------------------------------------------------
  # ● 連擊次數
  #--------------------------------------------------------------------------
  def fs_wld_chain_at(level)
    return 0 unless @skill.respond_to?(:chain_number)
    return @skill.chain_number.to_i +
      fs_wld_table_value(@skill.level_chain, level)
  end

  def fs_wld_draw_chain(dy)
    return dy unless @skill.respond_to?(:level_chain)
    return dy unless fs_wld_table_varies?(@skill.level_chain)

    current = fs_wld_chain_at(fs_wld_current_level)
    target = fs_wld_chain_at(fs_wld_target_level)

    return fs_wld_draw_row(
      dy,
      "連擊次數",
      fs_wld_pair(current, target, "次"),
      @skill.icon_index
    )
  end

  #--------------------------------------------------------------------------
  # ● 狀態持續時間
  #--------------------------------------------------------------------------
  def fs_wld_state_turn_at(state, level)
    value = state.hold_turn.to_i +
      fs_wld_table_value(@skill.level_state, level)
    return [value, 0].max
  end

  def fs_wld_draw_states(dy)
    state_ids =
      FS_WINDOW_LEVEL_DETAIL.all_applied_state_ids(@skill)

    return dy if state_ids.empty?
    return dy unless fs_wld_table_varies?(@skill.level_state)

    current_level = fs_wld_current_level
    target_level = fs_wld_target_level

    for state_id in state_ids
      state = $data_states[state_id]
      next if state == nil

      current = fs_wld_state_turn_at(state, current_level)
      target = fs_wld_state_turn_at(state, target_level)

      icon = state.icon_index.to_i
      icon = @skill.icon_index if icon <= 0

      label =
        FS_WINDOW_LEVEL_DETAIL.short_state_name(state) + "持續"

      dy = fs_wld_draw_row(
        dy,
        label,
        fs_wld_pair(current, target, "回合"),
        icon
      )
    end

    return dy
  end
end
