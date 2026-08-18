#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_EquipmentSkill_Authority v2.2
# 【用途】裝備技能／道具教技能的正式 Runtime Authority；統一 Parser、技能來源、同步、使用權限與 PassiveSkill 最終刷新。
# 【主要機制】整合 Modern Algebra `\ls[...]`、Shanghai `<equipskill:...>`、Actor.skills 最終列表、裝備教學技能全量同步、Item 教技能、YEM 額外欄位與 KGC PassiveSkill 換裝後刷新。
# 【主要影響】Game_Actor、Game_Battler
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【Phase 29】已吸收並退休 Modern Algebra Skill Teaching 與 Equipment Skills 兩個獨立 Runtime Page；必須位於 YEM Equipment Overhaul／KGC PassiveSkill 之後、EquipmentCombo 之前。
# 【Phase44K】final convergence 內的 Teaching mutation 以短暫 deferred transaction 執行；其內 learn/forget 不重複 rebuild Passive，Teaching 結束後仍由既有 albert_refresh_equipment_passive_skills 精確刷新一次。standalone Teaching 呼叫維持原即時語意。
# 【依賴／載入順序】含 7 個 alias／方法包裝，載入順序具有語意。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【英文說明中文化】本頁頂部已用繁體中文整理／翻譯原說明中與維護直接相關的用途、機制、設定、順序、呼叫與範例；下方原文保留作作者授權、完整細節與歷史查核依據。
# 【來源／授權】整合 Modern Algebra Skill Teaching Equipment & Items v2.0、Shanghai Simple Script - Equipment Skills，以及既有 FS Safe Patch；原頁完整原稿保存在 Phase 29 Archive。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 範例只記錄原文件、既有事件或程式碼能證實的入口；沒有入口就明寫自動執行。
# 3. 原作者署名、授權與原始說明保留在下方；中文化不代表取得原作權。
# 4. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
#==============================================================================
#==============================================================================
# ■ FS_EquipmentSkill_Authority v2.2
#------------------------------------------------------------------------------
# 放置位置：所有素材腳本之下、Main 之上。
# 目的：
#   1. 保留所有後段 skill_can_use? 限制，同時補回「Actor 必須會技能」規則。
#   2. 整理 skills 陣列，避免裝備技能、狀態技能重複顯示。
#   3. 修正 Modern Algebra Skill Teaching Equipment 在 YEM 額外裝備欄位下，
#      換裝後技能不同步的問題。
#   4. 修正 \ls[skill_id, level_min] 在剛好等於需求等級時，物品教技能不生效的問題。
#------------------------------------------------------------------------------
# 注意：
#   本補丁不處理技能消耗重複扣除。
#   技能消耗請優先移除「消耗修正」腳本頁，避免破壞後段 execute_action_skill 鏈。
#==============================================================================

$imported = {} if $imported == nil
$imported["EquipmentSkills"] = true
$imported["FS Equipment Skill Authority"] = "2.2"

#==============================================================================
# ■ 1. 裝備技能資料 Parser + 最終技能列表 Authority
#------------------------------------------------------------------------------
# 來源 A：Modern Algebra Skill Teaching Equipment & Items
#   \ls[skill_id, level_min]
#   - Weapon / Armor：裝備期間把技能同步進 Actor learned list。
#   - Item：使用後永久學習；level_min 省略時視為 0。
#
# 來源 B：Shanghai Simple Script - Equipment Skills
#   <equipskill: x>
#   <equipskill: x, x, x>
#   - 不修改 learned list；技能只在該裝備存在時動態加入 actor.skills。
#
# Phase 29：兩份舊獨立 Runtime Page 已退休並收進外部 Archive；
# Parser 與列表責任全部集中於本 Authority。原作者 Credits：
#   Modern Algebra (rmrk.net), Skill Teaching Equipment & Items v2.0 (2008)
#   Shanghai Simple Script - Equipment Skills (2010.05.25)
#==============================================================================
class RPG::BaseItem
  # Modern Algebra \ls[skill_id, level_min]
  def skill_ids
    return if self.class == RPG::Skill
    learn_skills = []
    text = self.note.dup
    while text[/\\ls\[(\w+),*\s*(\d*?)\]/i] != nil
      text.sub!(/\\ls\[(\w+),*\s*(\d*?)\]/i) { '' }
      learn_skills.push([$1.to_i, $2.to_i])
    end
    return learn_skills
  end

  # Shanghai <equipskill: ...>
  def skills
    return @equipment_skills if @equipment_skills != nil
    @equipment_skills = []
    self.note.split(/[\r\n]+/).each do |line|
      case line
      when /<(?:EQUIPMENTSKILL|equipskill):[ ](\d+(?:\s*,\s*\d+)*)>/i
        $1.scan(/\d+/).each do |num|
          @equipment_skills.push($data_skills[num.to_i]) if num.to_i > 0
        end
      end
    end
    return @equipment_skills
  end
end

class Game_Actor < Game_Battler
  unless method_defined?(:albert_equipment_skill_base_skills)
    alias albert_equipment_skill_base_skills skills
  end

  def skills
    list = albert_equipment_skill_base_skills
    list = [] if list == nil
    if respond_to?(:equips)
      equips.compact.each do |equip|
        next unless equip.respond_to?(:skills)
        list += equip.skills
      end
    end
    list.compact.uniq.sort_by { |skill| skill.id }
  end
end

#==============================================================================
# ■ 2. Actor 技能使用權限補強
#------------------------------------------------------------------------------
# 問題來源：
#   某些腳本把 Game_Actor#skill_can_use? 改成 return super(skill)，
#   會繞過原本「Actor 必須學會技能」的檢查。
#
# 修正策略：
#   先檢查技能是否存在於 actor.skills。
#   但若 EAC 的 <エネミー行動変化：ID> 開啟未學技能可用，則放行。
#   最後仍呼叫原本最終 skill_can_use?，保留 MP、HP、冷卻、變數、召喚等限制。
#==============================================================================
class Game_Actor < Game_Battler
  unless method_defined?(:albert_eqskill_final_skill_can_use?)
    alias albert_eqskill_final_skill_can_use? skill_can_use?
  end

  def skill_can_use?(skill)
    return false unless skill.is_a?(RPG::Skill)

    allow_unlearned = false
    allow_unlearned = not_learn_skill_can_use if respond_to?(:not_learn_skill_can_use)

    unless allow_unlearned
      return false unless albert_skill_in_current_skill_list?(skill)
    end

    albert_eqskill_final_skill_can_use?(skill)
  end

  def albert_skill_in_current_skill_list?(skill)
    return false if skill == nil
    skills.any? { |s| s != nil && s.id == skill.id }
  end
end

#==============================================================================
# ■ 3. Skill Teaching Equipment 同步修正
#------------------------------------------------------------------------------
# 對應 Modern Algebra 的 \ls[skill_id, level_min]
# 修正：
#   - 支援 YEM Equipment Overhaul 的額外裝備欄位。
#   - 換裝、升級、setup 後重新同步裝備教學技能。
#   - 技能達到自然學習等級後，移除 @unnatural_skills 舊 marker，避免卸裝誤忘。
#==============================================================================
class Game_Actor < Game_Battler
  def albert_natural_level_skill?(skill_id)
    return false if self.class == nil
    self.class.learnings.any? do |learning|
      learning.skill_id == skill_id && learning.level <= @level
    end
  end

  def albert_equipment_teaching_entries
    result = []
    return result unless respond_to?(:equips)

    equips.compact.each do |item|
      next unless item.respond_to?(:skill_ids)
      skill_ids = item.skill_ids
      next if skill_ids == nil

      skill_ids.each do |data|
        skill_id = data[0].to_i
        level_min = data[1].to_i
        next if skill_id <= 0
        next if $data_skills[skill_id] == nil
        result << [skill_id, level_min]
      end
    end

    result
  end

  def albert_refresh_equipment_teaching_skills
    @unnatural_skills = [] if @unnatural_skills == nil

    desired = []
    albert_equipment_teaching_entries.each do |skill_id, level_min|
      desired << skill_id if @level >= level_min
    end
    desired.uniq!

    @unnatural_skills.clone.each do |skill_id|
      # 若角色目前等級已經自然學會此技能，立刻把它從「裝備臨時技能」
      # 名單除籍，但保留 learned skill。這可避免日後卸裝時被舊 marker 誤忘。
      if albert_natural_level_skill?(skill_id)
        @unnatural_skills.delete(skill_id)
        learn_skill(skill_id) unless @skills && @skills.include?(skill_id)
        next
      end

      next if desired.include?(skill_id)
      @unnatural_skills.delete(skill_id)
      forget_skill(skill_id) if @skills && @skills.include?(skill_id)
    end

    desired.each do |skill_id|
      skill = $data_skills[skill_id]
      next if skill == nil
      learn_skill(skill_id) unless skill_learn?(skill)

      # 自然學會的技能不標記為裝備臨時技能。
      next if albert_natural_level_skill?(skill_id)
      @unnatural_skills << skill_id unless @unnatural_skills.include?(skill_id)
    end
  end

  # Phase44K：已知外層會在 Teaching 後立即執行 Passive final refresh 時使用。
  # 用短暫 ivar transaction 通知 KGC learn/forget 延後 rebuild；ensure 後把 ivar
  # 恢復到呼叫前「存在／不存在」的 exact shape，避免把 TEST／Save runtime state 汙染。
  def albert_refresh_equipment_teaching_skills_deferred
    flag = :@albert_equipment_teaching_passive_deferred
    had_flag = instance_variables.include?(flag.to_s)
    old_flag = instance_variable_get(flag)
    instance_variable_set(flag, true)
    begin
      return albert_refresh_equipment_teaching_skills
    ensure
      if had_flag
        instance_variable_set(flag, old_flag)
      else
        begin
          send(:remove_instance_variable, flag)
        rescue
        end
      end
    end
  end

  # KGC PassiveSkill 的舊 change_equip wrapper 位於 YEM 額外裝備欄更新之前，
  # 可能看到舊 extra slot。Phase 29 統一在完整換裝狀態確定後刷新。
  def albert_refresh_equipment_passive_skills
    restore_passive_rev if respond_to?(:restore_passive_rev)
  end

  unless method_defined?(:albert_eqskill_change_equip_final)
    alias albert_eqskill_change_equip_final change_equip
  end

  def change_equip(equip_type, item, test = false)
    result = albert_eqskill_change_equip_final(equip_type, item, test)
    unless test
      albert_refresh_equipment_teaching_skills_deferred
      albert_refresh_equipment_passive_skills
    end
    return result
  end

  unless method_defined?(:albert_eqskill_setup_final)
    alias albert_eqskill_setup_final setup
  end

  def setup(actor_id)
    result = albert_eqskill_setup_final(actor_id)
    albert_refresh_equipment_teaching_skills_deferred
    albert_refresh_equipment_passive_skills
    return result
  end

  unless method_defined?(:albert_eqskill_level_up_final)
    alias albert_eqskill_level_up_final level_up
  end

  def level_up
    result = albert_eqskill_level_up_final
    albert_refresh_equipment_teaching_skills_deferred
    albert_refresh_equipment_passive_skills
    return result
  end
end

#==============================================================================
# ■ 4. Skill Teaching Item 等級判定修正
#------------------------------------------------------------------------------
# 原腳本物品教技能使用 self.level > level_min，會導致剛好等於需求等級時不能學。
# 這裡改成 >=。
#==============================================================================
class Game_Battler
  def albert_item_teaches_skill_now?(item)
    return false unless self.is_a?(Game_Actor)
    return false unless item.respond_to?(:skill_ids)

    skill_ids = item.skill_ids
    return false if skill_ids == nil

    skill_ids.any? do |data|
      skill_id = data[0].to_i
      level_min = data[1].to_i
      skill = $data_skills[skill_id]
      skill != nil && self.level >= level_min && !skill_learn?(skill)
    end
  end

  unless method_defined?(:albert_eqskill_item_test_final)
    alias albert_eqskill_item_test_final item_test
  end

  def item_test(user, item)
    result = albert_eqskill_item_test_final(user, item)
    return true if result
    return true if albert_item_teaches_skill_now?(item)
    return result
  end

  unless method_defined?(:albert_eqskill_item_effect_final)
    alias albert_eqskill_item_effect_final item_effect
  end

  def item_effect(user, item)
    albert_eqskill_item_effect_final(user, item)
    return unless self.is_a?(Game_Actor)
    return unless item.respond_to?(:skill_ids)

    skill_ids = item.skill_ids
    return if skill_ids == nil

    @unnatural_skills = [] if @unnatural_skills == nil
    skill_ids.each do |data|
      skill_id = data[0].to_i
      level_min = data[1].to_i
      skill = $data_skills[skill_id]
      next if skill == nil
      next unless self.level >= level_min

      @unnatural_skills.delete(skill_id)
      learn_skill(skill_id)
    end
  end
end
