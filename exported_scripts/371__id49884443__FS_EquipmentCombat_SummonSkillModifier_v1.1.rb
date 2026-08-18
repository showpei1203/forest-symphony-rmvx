#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_EquipmentCombat_SummonSkillModifier v1.1
# 【用途】Forest Symphony 專用 Runtime／資料腳本「FS_EquipmentCombat_SummonSkillModifier」。
# 【主要機制】屬目前正式專案功能的一部分；具體責任以本頁定義的類別、模組與方法，以及 LoadOrder Guide 為準。
# 【主要影響】Game_Battler、Window_Skill、ALBERT_SUMMON_EQUIP_SKILL
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】含 2 個 alias／方法包裝，載入順序具有語意；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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
# Albert_RMVX_SummonEquipSkill_PowerAndDesc.rb
#------------------------------------------------------------------------------
# 功能：
#  1. 讓 <equipskill: n> 提供的技能，可以依照對應召喚 Actor 的能力補傷害
#  2. 讓技能說明欄可顯示對應召喚物名稱、等級、能力值
#
# 使用方式：
#  技能 Note 可寫：
#    <summon_lv_power: 10>    # 傷害 + 召喚物等級 * 10
#    <summon_atk_power: 50>   # 傷害 + 召喚物攻擊 * 50%
#    <summon_spi_power: 50>   # 傷害 + 召喚物精神 * 50%
#    <summon_def_power: 50>   # 傷害 + 召喚物防禦 * 50%
#    <summon_agi_power: 50>   # 傷害 + 召喚物敏捷 * 50%
#
#  技能說明可寫：
#    由%SUMMON_NAME%共鳴。Lv.%SUMMON_LV%
#==============================================================================

module ALBERT_SUMMON_EQUIP_SKILL

  #--------------------------------------------------------------------------
  # 取得技能對應的召喚 Actor
  # user  : 技能使用者，通常是喬伊
  # skill : 技能物件
  #--------------------------------------------------------------------------
  def self.summon_actor_for(user, skill)
    return nil if user == nil
    return nil if skill == nil
    return nil unless user.respond_to?(:equips)
    return nil unless defined?(ArmorMapping)

    for equip in user.equips.compact
      next if equip == nil
      next unless equip.respond_to?(:skills)

      has_skill = false
      for s in equip.skills
        next if s == nil
        if s.id == skill.id
          has_skill = true
          break
        end
      end

      next unless has_skill

      actor_id = nil
      begin
        actor_id = ArmorMapping.mapping[equip.id]
      rescue
        actor_id = nil
      end

      next if actor_id == nil
      return $game_actors[actor_id]
    end

    return nil
  end

  #--------------------------------------------------------------------------
  # 取得召喚物等級
  #--------------------------------------------------------------------------
  def self.summon_level(actor)
    return 0 if actor == nil

    # 你的召喚物有 temp_level 的保存設計，優先讀目前 actor.level。
    # 如果將來遇到未初始化情況，再退回 temp_level。
    begin
      return actor.level if actor.level != nil
    rescue
    end

    begin
      return actor.temp_level if actor.temp_level != nil
    rescue
    end

    return 0
  end

  #--------------------------------------------------------------------------
  # 從技能 Note 讀取數值
  #--------------------------------------------------------------------------
  def self.note_value(skill, tag)
    return 0 if skill == nil
    return 0 unless skill.respond_to?(:note)

    skill.note.split(/[\r\n]+/).each do |line|
      case line
      when /<#{tag}:[ ]*(\d+)>/i
        return $1.to_i
      end
    end

    return 0
  end

  #--------------------------------------------------------------------------
  # 計算額外傷害
  #--------------------------------------------------------------------------
  def self.bonus_damage(user, skill)
    summon = summon_actor_for(user, skill)
    return 0 if summon == nil

    bonus = 0

    lv_rate  = note_value(skill, "summon_lv_power")
    atk_rate = note_value(skill, "summon_atk_power")
    def_rate = note_value(skill, "summon_def_power")
    spi_rate = note_value(skill, "summon_spi_power")
    agi_rate = note_value(skill, "summon_agi_power")

    bonus += summon_level(summon) * lv_rate
    bonus += summon.atk * atk_rate / 100
    bonus += summon.def * def_rate / 100
    bonus += summon.spi * spi_rate / 100
    bonus += summon.agi * agi_rate / 100

    return bonus
  end

  #--------------------------------------------------------------------------
  # 動態技能說明
  #--------------------------------------------------------------------------
  def self.dynamic_description(user, skill)
    return "" if skill == nil

    text = skill.description.clone
    summon = summon_actor_for(user, skill)

    if summon == nil
      text.gsub!("%SUMMON_NAME%", "召喚物")
      text.gsub!("%SUMMON_LV%", "0")
      text.gsub!("%SUMMON_ATK%", "0")
      text.gsub!("%SUMMON_DEF%", "0")
      text.gsub!("%SUMMON_SPI%", "0")
      text.gsub!("%SUMMON_AGI%", "0")
      return text
    end

    text.gsub!("%SUMMON_NAME%", summon.name.to_s)
    text.gsub!("%SUMMON_LV%", summon_level(summon).to_s)
    text.gsub!("%SUMMON_ATK%", summon.atk.to_s)
    text.gsub!("%SUMMON_DEF%", summon.def.to_s)
    text.gsub!("%SUMMON_SPI%", summon.spi.to_s)
    text.gsub!("%SUMMON_AGI%", summon.agi.to_s)

    return text
  end

end

#==============================================================================
# Game_Battler
#------------------------------------------------------------------------------
# 技能傷害補正
#==============================================================================

class Game_Battler

  alias albert_summon_equip_make_obj_damage_value make_obj_damage_value

  def make_obj_damage_value(user, obj)
    albert_summon_equip_make_obj_damage_value(user, obj)

    return unless obj.is_a?(RPG::Skill)
    return unless user != nil && user.actor?

    bonus = ALBERT_SUMMON_EQUIP_SKILL.bonus_damage(user, obj)
    return if bonus == 0

    # 只對傷害技能加成，不影響補血技能。
    if @hp_damage > 0
      @hp_damage += bonus
    elsif @mp_damage > 0
      @mp_damage += bonus
    end
  end

end

#==============================================================================
# Window_Skill
#------------------------------------------------------------------------------
# 技能說明欄動態替換
#==============================================================================

class Window_Skill < Window_Selectable

  alias albert_summon_equip_update_help update_help

  def update_help
    if skill == nil
      @help_window.set_text("")
    else
      text = ALBERT_SUMMON_EQUIP_SKILL.dynamic_description(@actor, skill)
      @help_window.set_text(text)
    end

    @info_window.refresh(skill) unless @info_window.nil?
  end

end