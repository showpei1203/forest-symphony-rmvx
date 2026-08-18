#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_EquipmentCombo_OpeningSkill_FinalAuthority v2.0
# 【用途】Forest Symphony 正式 Authority「FS_EquipmentCombo_OpeningSkill_FinalAuthority v1.3」，集中管理此功能目前應修改的主要實作。
# 【主要機制】本頁可能由既有 Base／第三方插件一路 Patch 而來；修改時仍需查看 LoadOrder Guide／Authority Map，確認是否還有後載入 wrapper。
# 【主要影響】Game_BattleAction、Scene_Battle、Game_Interpreter、FS_COMBO_OPENING_TARGET
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】含 6 個 alias／方法包裝，載入順序具有語意；登記 $imported：FS EquipmentCombo Opening Skill Fix；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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

# ■ FS_EquipmentCombo_OpeningSkill_FinalAuthority v2.0

#------------------------------------------------------------------------------

# RPG Maker VX / RGSS2 / Ruby 1.8.1

#

# 修正：

#   1. 鳴刻冠開場技能不要求召喚物已自然學會該技能。

#   2. <combo_summon_opening_target:-1> 改為「依技能scope自動選邊」：

#        敵方技能 → 敵軍

#        我方技能 → 我軍

#        自身技能 → 使用者

#        復活技能 → 我方倒地者

#   3. 不再把自動目標完全交給其他補丁改寫過的decide_random_target。
#   4. v1.3將單體開場技能鎖定到實際Battler物件：
#        make_targets完成後鎖定
#        target_decision完成後再鎖定
#        damage_action套用效果前最後鎖定
#   5. 同種敵人各自視為獨立Battler，不依名稱或Enemy ID群體套用。
#   6. v2.0 恢復 Combo State ownership：戰後只清除本場真正新加入的 State。

#

# 固定目標：

#   target >= 0 時，代表技能所屬陣營中的成員index。

#

# 放置位置：

#   所有戰鬥、安全補丁與FS_MasterSetup之下，Main之前。

#==============================================================================

$imported = {} if $imported == nil

$imported["FS EquipmentCombo Opening Skill Fix"] = "2.0"



module FS_COMBO_OPENING_TARGET

  VERSION = "2.0"



  def self.random_member(list)

    return nil if list == nil || list.empty?

    return list[rand(list.size)]

  end



  def self.target_unit(skill)

    return :user if skill.for_user?

    return :dead_friend if skill.for_dead_friend?

    return :friend if skill.for_friend?

    return :opponent if skill.for_opponent?

    return :none

  end



  def self.members_for_side(side)

    case side

    when :dead_friend

      return $game_party.dead_members

    when :friend

      return $game_party.existing_members

    when :opponent

      return $game_troop.existing_members

    end

    return []

  end



  def self.resolve(user, skill, requested_index)

    side = target_unit(skill)

    return user if side == :user

    list = members_for_side(side)

    return nil if list.empty?



    if requested_index.to_i >= 0

      candidate = list[requested_index.to_i]

      return candidate unless candidate == nil

    end

    return random_member(list)

  end



  def self.assign(action, user, skill, requested_index)

    target = resolve(user, skill, requested_index)

    if action.respond_to?(:fs_combo_opening_target=)

      action.fs_combo_opening_target = target

      action.fs_combo_opening_skill_id = skill == nil ? 0 : skill.id

    end

    if target != nil && target.respond_to?(:index)

      action.target_index = target.index

      return target

    end



    # 全體或無目標技能仍可能不需要index。

    # 保留原行動建立流程作為最後退路。

    action.decide_random_target if action.respond_to?(:decide_random_target)

    return nil

  end



  def self.scope_text(skill)

    case target_unit(skill)

    when :user then return "使用者"

    when :dead_friend then return "我方倒地"

    when :friend then return "我方"

    when :opponent then return "敵方"

    else return "無目標"

    end

  end



  def self.write_report

    file = File.open("FS_OpeningSkill_Target_Report.txt", "wb")

    file.write("FS Combo Opening Target v#{VERSION}\r\n")

    for armor_id in 220..285

      armor = $data_armors[armor_id] rescue nil

      next if armor == nil

      next unless armor.respond_to?(:albert_combo_summon_opening_skill_id)

      skill_id = armor.albert_combo_summon_opening_skill_id.to_i

      next if skill_id <= 0

      skill = $data_skills[skill_id] rescue nil

      next if skill == nil

      requested = armor.albert_combo_summon_opening_target.to_i

      text = "A#{armor_id} #{armor.name} | " +

        "S#{skill_id} #{skill.name} | scope=#{skill.scope} " +

        scope_text(skill) + " | note_target=#{requested}"

      file.write(text + "\r\n")

    end

    file.close

    return true

  rescue

    return false

  end

  def self.target_valid?(target, user, skill)
    return false if target == nil || skill == nil

    if skill.for_user?
      return target.equal?(user)
    end

    if skill.for_dead_friend?
      return target.dead?
    end

    if skill.for_friend? || skill.for_opponent?
      return target.exist?
    end

    return false
  rescue
    return false
  end

  def self.same_opening_skill?(action, obj)
    return false if action == nil || obj == nil
    return false unless obj.respond_to?(:id)
    return obj.id.to_i ==
      action.fs_combo_opening_skill_id.to_i
  rescue
    return false
  end

  def self.locked_target(action, user, obj)
    return nil unless same_opening_skill?(action, obj)
    return nil unless obj.respond_to?(:for_one?) && obj.for_one?

    target = action.fs_combo_opening_target
    return nil unless target_valid?(target, user, obj)

    return target
  end

  def self.update_locked_target(action, target, skill)
    return if action == nil || target == nil || skill == nil

    action.fs_combo_opening_target = target
    action.fs_combo_opening_skill_id = skill.id.to_i
    action.target_index = target.index if target.respond_to?(:index)

    record_runtime("redirect", action.battler, skill, target, [target])
  rescue
  end

  def self.describe_battler(battler)
    return "nil" if battler == nil

    side = battler.actor? ? "Actor" : "Enemy"
    db_id = if battler.actor?
              battler.id
            else
              battler.enemy_id
            end

    return "#{side} db=#{db_id} index=#{battler.index} " +
      "object=#{battler.object_id} name=#{battler.name}"
  rescue
    return battler.to_s
  end

  def self.record_runtime(stage, user, skill, locked, targets)
    @last_runtime ||= []
    @last_runtime.push(
      "#{stage} | user=#{describe_battler(user)} | " +
      "skill=#{skill == nil ? 'nil' : skill.id.to_s + ' ' + skill.name.to_s} | " +
      "locked=#{describe_battler(locked)} | " +
      "targets=#{(targets || []).collect { |t| describe_battler(t) }.join(' || ')}"
    )
    @last_runtime.shift while @last_runtime.size > 40
  rescue
  end

  def self.write_runtime_report
    file = File.open(
      "FS_OpeningSkill_Runtime_Target_Report.txt", "wb")

    file.write(
      "FS Combo Opening Runtime Target v#{VERSION}\r\n")
    file.write("=" * 88 + "\r\n")

    rows = @last_runtime || []
    if rows.empty?
      file.write("(尚無開場技能執行紀錄)\r\n")
    else
      for row in rows
        file.write(row.to_s + "\r\n")
      end
    end

    file.close
    return true
  rescue
    return false
  end

end




#==============================================================================
# ■ Game_BattleAction：單體開場技能鎖定實際Battler
#------------------------------------------------------------------------------
# target_index只是數字，後段腳本可能重新組出目標陣列。
# v1.3保存實際Battler物件，並在make_obj_targets與make_targets最終結果鎖定。
#==============================================================================

class Game_BattleAction

  attr_accessor :fs_combo_opening_target
  attr_accessor :fs_combo_opening_skill_id

  unless method_defined?(:fs_combo_opening_clear_v13)
    alias fs_combo_opening_clear_v13 clear
  end

  def clear
    fs_combo_opening_clear_v13
    @fs_combo_opening_target = nil
    @fs_combo_opening_skill_id = 0
  end

  # 第一層：物件目標建立。
  unless method_defined?(:fs_combo_opening_make_obj_targets_v13)
    alias fs_combo_opening_make_obj_targets_v13 make_obj_targets
  end

  def make_obj_targets(obj)
    locked = FS_COMBO_OPENING_TARGET.locked_target(
      self, battler, obj)

    if locked != nil
      FS_COMBO_OPENING_TARGET.record_runtime(
        "make_obj_targets", battler, obj, locked, [locked])
      return [locked]
    end

    return fs_combo_opening_make_obj_targets_v13(obj)
  end

  # 第二層：所有保護、威脅、隨機目標等後段系統完成後，
  # 再檢查一次最終目標陣列。
  unless method_defined?(:fs_combo_opening_make_targets_v13)
    alias fs_combo_opening_make_targets_v13 make_targets
  end

  def make_targets
    targets = fs_combo_opening_make_targets_v13

    obj = skill? ? skill : (item? ? item : nil)
    locked = FS_COMBO_OPENING_TARGET.locked_target(
      self, battler, obj)

    return targets if locked == nil

    # 若後段系統合法地把單體目標改成另一名單體，
    # 例如護衛／保護，接受那名唯一目標並更新鎖定。
    if targets != nil && targets.size == 1 &&
       targets[0] != nil &&
       FS_COMBO_OPENING_TARGET.target_valid?(
         targets[0], battler, obj)

      locked = targets[0]
      FS_COMBO_OPENING_TARGET.update_locked_target(
        self, locked, obj)
    end

    result = [locked]

    FS_COMBO_OPENING_TARGET.record_runtime(
      "make_targets", battler, obj, locked, result)

    return result
  end
end


#==============================================================================
# ■ Scene_Battle：SBS最終目標陣列鎖定
#------------------------------------------------------------------------------
# Tankentai真正套用技能效果時使用Scene_Battle的@targets。
# 即使後段腳本覆寫Game_BattleAction，這裡仍保證單體開場技能只有一名目標。
#==============================================================================

class Scene_Battle < Scene_Base

  def fs_combo_opening_current_obj_v13
    return nil if @active_battler == nil
    return nil if @active_battler.action == nil

    action = @active_battler.action
    return action.skill if action.skill?
    return action.item if action.item?
    return nil
  rescue
    return nil
  end

  def fs_combo_opening_locked_target_v13(obj = nil)
    return nil if @active_battler == nil
    return nil if @active_battler.action == nil

    obj = fs_combo_opening_current_obj_v13 if obj == nil

    return FS_COMBO_OPENING_TARGET.locked_target(
      @active_battler.action,
      @active_battler,
      obj)
  end

  def fs_combo_opening_force_scene_target_v13(obj, stage)
    locked = fs_combo_opening_locked_target_v13(obj)
    return nil if locked == nil

    # 若目前結果是合法的唯一單體目標，保留護衛／保護等重導結果。
    if @targets != nil && @targets.size == 1 &&
       @targets[0] != nil &&
       FS_COMBO_OPENING_TARGET.target_valid?(
         @targets[0], @active_battler, obj)

      locked = @targets[0]
      FS_COMBO_OPENING_TARGET.update_locked_target(
        @active_battler.action, locked, obj)
    end

    @targets = [locked]

    # Individual序列的damage_action會優先shift這個陣列，
    # 因此也必須同步鎖定。
    if @active_battler.respond_to?(:individual) &&
       @active_battler.individual
      @individual_target = [locked]
      @stand_by_target = [locked]
    end

    if @spriteset != nil
      begin
        @spriteset.set_target(
          @active_battler.actor?,
          @active_battler.index,
          @targets)
      rescue
      end
    end

    FS_COMBO_OPENING_TARGET.record_runtime(
      stage, @active_battler, obj, locked, @targets)

    return locked
  end

  # 第三層：SBS target_decision完成後。
  unless method_defined?(:fs_combo_opening_target_decision_v13)
    alias fs_combo_opening_target_decision_v13 target_decision
  end

  def target_decision(obj = nil)
    result = fs_combo_opening_target_decision_v13(obj)
    fs_combo_opening_force_scene_target_v13(
      obj, "target_decision")
    return result
  end

  # Individual序列建立快照後，再鎖定一次。
  if method_defined?(:individual) &&
     !method_defined?(:fs_combo_opening_individual_v13)

    alias fs_combo_opening_individual_v13 individual

    def individual
      result = fs_combo_opening_individual_v13
      obj = fs_combo_opening_current_obj_v13
      fs_combo_opening_force_scene_target_v13(
        obj, "individual")
      return result
    end
  end

  # 第四層：真正逐一呼叫target.skill_effect前。
  unless method_defined?(:fs_combo_opening_damage_action_v13)
    alias fs_combo_opening_damage_action_v13 damage_action
  end

  def damage_action(action)
    obj = fs_combo_opening_current_obj_v13

    fs_combo_opening_force_scene_target_v13(
      obj, "before_damage_action")

    result = fs_combo_opening_damage_action_v13(action)

    locked = fs_combo_opening_locked_target_v13(obj)
    FS_COMBO_OPENING_TARGET.record_runtime(
      "after_damage_action",
      @active_battler,
      obj,
      locked,
      @targets)

    return result
  end

  #--------------------------------------------------------------------------
  # ○ EquipmentCombo 戰鬥開始 Final Authority
  #   - 保留 v1.3：開場技不要求 summon 已自然學會。
  #   - 保留 scope-aware / exact Battler target lock。
  #   - v2.0 恢復：只登記本場 Combo 真正新加入的 Summon State 所有權。
  #--------------------------------------------------------------------------
  def albert_prepare_equipment_combo_battle_effects
    $game_party.members.each do |member|
      next unless member.is_a?(Game_Actor)
      member.albert_refresh_combo_actor_states
    end

    @forcing_battlers ||= []
    queued_summon_ids = {}
    state_plan = {}
    before_states = {}

    # 先建立 State 計畫與進場前快照，不改變任何 State。
    $game_party.members.each do |owner|
      next unless owner.is_a?(Game_Actor)
      owner.albert_active_combo_equips.each do |equip|
        summon_actor_id = owner.albert_combo_summon_actor_id_for(equip)
        next if summon_actor_id <= 0
        summon = $game_actors[summon_actor_id]
        next if summon == nil
        next unless $game_party.members.include?(summon)
        next unless summon.exist?

        unless before_states.has_key?(summon_actor_id)
          before_states[summon_actor_id] = []
          for state in summon.states.compact
            before_states[summon_actor_id].push(state.id)
          end
        end
        state_plan[summon_actor_id] = [] if state_plan[summon_actor_id] == nil
        equip.albert_combo_summon_state_ids.each do |state_id|
          id = state_id.to_i
          next if id <= 0 || $data_states[id] == nil
          state_plan[summon_actor_id].push(id) unless state_plan[summon_actor_id].include?(id)
        end
      end
    end

    # 維持 v1.3 Equip 順序，套 State 並為同一 summon 排入第一個合法 Opening Skill。
    $game_party.members.each do |owner|
      next unless owner.is_a?(Game_Actor)
      owner.albert_active_combo_equips.each do |equip|
        summon_actor_id = owner.albert_combo_summon_actor_id_for(equip)
        next if summon_actor_id <= 0
        summon = $game_actors[summon_actor_id]
        next if summon == nil
        next unless $game_party.members.include?(summon)
        next unless summon.exist?

        equip.albert_combo_summon_state_ids.each do |state_id|
          next if state_id <= 0 || $data_states[state_id] == nil
          summon.add_state(state_id) unless summon.state?(state_id)
        end

        skill_id = equip.albert_combo_summon_opening_skill_id
        next if skill_id <= 0 || queued_summon_ids[summon_actor_id]
        skill = $data_skills[skill_id]
        next if skill == nil

        # v1.3 正式規則：不檢查 skill_learn?；鳴刻冠本身即可授權開場技。
        summon.action.clear
        summon.action.set_skill(skill_id)
        requested_index = equip.albert_combo_summon_opening_target
        FS_COMBO_OPENING_TARGET.assign(summon.action, summon, skill, requested_index)
        summon.action.forcing = true
        @forcing_battlers << summon
        queued_summon_ids[summon_actor_id] = true
      end
    end

    # 只取得「本場 Combo 新增」而非原本就存在的 State 所有權。
    state_plan.each_pair do |actor_id, desired|
      summon = $game_actors[actor_id]
      next if summon == nil
      before = before_states[actor_id] == nil ? [] : before_states[actor_id]
      newly_added = []
      for state_id in desired
        if !before.include?(state_id) && summon.state?(state_id)
          newly_added.push(state_id)
        end
      end
      summon.albert_combo_register_owned_summon_states(newly_added) if
        summon.respond_to?(:albert_combo_register_owned_summon_states)
    end

    @status_window.refresh unless @status_window == nil
  end
end



class Game_Interpreter

  def fs_opening_runtime_target_report

    result = FS_COMBO_OPENING_TARGET.write_runtime_report

    if $game_message != nil
      text = result ? "開場技能執行目標報告已輸出。" :
        "開場技能執行目標報告輸出失敗。"
      $game_message.texts.push(text)
    end

    return result
  end



  def fs_opening_target_report

    result = FS_COMBO_OPENING_TARGET.write_report

    if $game_message != nil

      text = result ? "開場技能目標報告已輸出。" :

        "開場技能目標報告輸出失敗。"

      $game_message.texts.push(text)

    end

    return result

  end

end
