#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_TargetGroupExact_Authority v2.1
# 【用途】統一「目標群組限制」與「手動選取身分一致性」：控制技能可選 Actor 群組，並確保游標選到的 battler 就是實際命中的 battler。
# 【主要機制】本頁依原載入順序先建立 TargetGroup，再套 Exact Target 最終修正。TargetGroup 以 Actor ID／群組過濾可用目標；Exact Target 以 battler 物件保存真正選中身分，避免 ATB／Large Party／召喚物讓過濾後 index 被誤當原始 members index。
# 【主要影響】ALBERT_TARGET_GROUP、ALBERT_EXACT_TARGET_FIX、Game_Battler、Window_Skill、Game_Troop、Game_BattleAction、Scene_Battle。
# 【設定／可調參數】TargetGroup：MAIN_ACTOR_MAX_ID、SUMMON_ACTOR_MIN_ID、HIDE_IF_NO_TARGET、STATIC_GROUPS、DEBUG。Exact：DEBUG。
# 【依賴／載入順序】必須位於 YERD_TargetEffects、DynamicThreat、Provoke、FS_TargetingCompatibility_Layer 等前段 Targeting 補丁之後；後方仍有 FS_MarkedCommand 與 FS_BattleTargetUI，因此本頁不是整條 Targeting 的最後 wrapper。兩個來源頁原本相鄰，Phase 10 只做等價物理合併。
# 【呼叫方式／範例】技能 Note 範例：<target_group: main>、<target_group: summon>、<target_group: actors 1,3,5>、<target_group: self_group>。Actor Note：<actor_group: pokemon>。使用 target_group 後，不必再為相同用途額外搭配舊 <pick custom 16/17>。
# 【相關素材】本頁未直接引用固定 Graphics／Audio 素材。
# 【英文說明中文化】本 Authority 的維護說明與原元件重要英文說明已整理為繁體中文；程式識別字、Notetag、原作者名稱與授權資訊維持原樣。
# 【來源／授權】來源元件：TargetGroup_System v2.0、Target Selection Exact Fix v1.0；完整原功能、Note 規格與原載入順序保留。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 範例只記錄原文件、既有事件或程式碼能證實的入口。
# 3. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
# 4. 原作者署名、Credits、License 與來源資訊不得因整理或翻譯而刪除。
#==============================================================================

#==============================================================================
# 【Part 1／2：Target Group】
#==============================================================================
#==============================================================================
# Albert_RMVX_TargetGroup_System_v2.rb
# Version 2.0－依行動限制 Actor ID 目標／ATB 安全版
# 適用於 RPG Maker VX / RGSS2
#------------------------------------------------------------------------------
# 目的：
#   建立統一的「技能目標群組」系統。
#
#   1. 技能 NOTE 可限制只能選指定角色群組。
#   2. 目標選擇游標只會出現在合法目標上。
#   3. 技能實際執行時再次驗證，避免目標死亡、離場後誤打其他人。
#   4. 沒有合法目標時，技能不可使用。
#   5. 可選擇在戰鬥技能欄中直接隱藏「目前沒有合法目標」的技能。
#
#------------------------------------------------------------------------------
# 【技能 NOTE 用法】
#
#   <target_group: main>
#     只能指定主要角色。預設 Actor ID 1～6。
#
#   <target_group: summon>
#     只能指定召喚物。預設 Actor ID 7以上。
#
#   <target_group: pokemon>
#   <target_group: robot>
#   <target_group: clone>
#     只能指定對應自訂群組。
#
#   <target_group: actor 1>
#     只能指定 Actor ID 1。
#
#   <target_group: actors 1,3,5>
#     只能指定 Actor ID 1、3、5。
#
#   <target_group: actor_1_3_5>
#     與上面相同，提供另一種寫法。
#
#   <target_group: all_actor>
#     所有我方 Actor 都可成為目標。
#
#   <target_group: self_group>
#     只能指定與技能使用者同群組的角色。
#     例：機器人只能維修機器人；寶可夢只能支援寶可夢。
#
#------------------------------------------------------------------------------
# 【Actor NOTE 用法】
#
#   <actor_group: pokemon>
#   <actor_group: robot>
#   <actor_group: clone>
#
#   未來增加新召喚物時，可直接在 Actor NOTE 指定分類，
#   不一定要回來修改 STATIC_GROUPS。
#
#------------------------------------------------------------------------------
# 【目前預設對應】
#
#   Actor 1～6 : main
#   Actor 7    : pokemon
#   Actor 8    : robot
#   Actor 9    : clone
#   Actor 7以上: summon
#
#   若實際 Actor ID 不同，只需修改 STATIC_GROUPS。
#
#------------------------------------------------------------------------------
# 【支援範圍】
#
#   - 我方單體
#   - 我方全體
#   - 戰鬥不能角色單體／全體（復活技能）
#   - 敵方技能若以 Actor 隊伍為目標，也可使用 target_group
#
#------------------------------------------------------------------------------
# 【重要】
#
#   使用 <target_group: ...> 後，不再需要額外搭配：
#
#     <pick custom 16>
#     <pick custom 17>
#
#   Target Group 自己會負責「畫面選擇」與「實際命中」。
#
#------------------------------------------------------------------------------
# 【放置位置】
#
#   放在：
#     - 目標過濾-new
#     - YERD_TargetEffects
#     - Albert Target Priority 修補
#     - SummonGuard / DynamicThreat 類目標修補
#   這些腳本的下方，Main 的上方。
#
#   最安全做法：放在所有戰鬥目標相關補丁之後、Main 之前。
#==============================================================================

module ALBERT_TARGET_GROUP

  #--------------------------------------------------------------------------
  # 設定
  #--------------------------------------------------------------------------

  MAIN_ACTOR_MAX_ID = 6
  SUMMON_ACTOR_MIN_ID = 7

  # true：戰鬥中若完全沒有合法目標，該 target_group 技能不顯示。
  # false：技能仍顯示，但會是不可使用狀態。
  HIDE_IF_NO_TARGET = true

  # 診斷模式：只在「確認目標」與「技能實際取目標」時寫入紀錄。
  # 測試正常後可改成 false。
  DEBUG = true
  LOG_FILE = "Albert_TargetGroup_Log.txt"

  # 自訂群組。
  # 可直接改 Actor ID，也可改用 Actor NOTE 的 <actor_group: xxx>。
  STATIC_GROUPS = {
    "pokemon" => [7],
    "robot"   => [8],
    "clone"   => [9]
  }

  TARGET_GROUP_REGEXP = /<\s*target[_ ]group\s*:\s*([^>]+)\s*>/i
  ACTOR_GROUP_REGEXP  = /<\s*actor[_ ]group\s*:\s*([^>]+)\s*>/i

  #--------------------------------------------------------------------------
  # 取得 NOTE
  #--------------------------------------------------------------------------
  def self.note(obj)
    return "" if obj == nil
    return "" unless obj.respond_to?(:note)
    return "" if obj.note == nil
    return obj.note.to_s
  end

  #--------------------------------------------------------------------------
  # 正規化群組名稱
  #--------------------------------------------------------------------------
  def self.normalize_group_name(name)
    return nil if name == nil
    result = name.to_s.strip.downcase
    result = result.gsub(/\s+/, " ")
    return result
  end

  #--------------------------------------------------------------------------
  # 技能／物品的 target_group
  #--------------------------------------------------------------------------
  def self.target_group(obj)
    text = note(obj)
    text.each_line do |line|
      if line =~ TARGET_GROUP_REGEXP
        return normalize_group_name($1)
      end
    end
    return nil
  end

  #--------------------------------------------------------------------------
  # 是否有 target_group
  #--------------------------------------------------------------------------
  def self.has_target_group?(obj)
    return target_group(obj) != nil
  end

  #--------------------------------------------------------------------------
  # 取得 Game_Actor 的 RPG::Actor NOTE
  #--------------------------------------------------------------------------
  def self.actor_note(actor)
    return "" if actor == nil
    return "" unless actor.respond_to?(:actor?) && actor.actor?
    begin
      data = actor.actor
      return "" if data == nil || !data.respond_to?(:note)
      return data.note.to_s
    rescue
      return ""
    end
  end

  #--------------------------------------------------------------------------
  # Actor NOTE 中所有 <actor_group: xxx>
  #--------------------------------------------------------------------------
  def self.actor_group_names(actor)
    result = []
    actor_note(actor).each_line do |line|
      if line =~ ACTOR_GROUP_REGEXP
        raw = $1.to_s
        raw.split(/\s*,\s*/).each do |name|
          group = normalize_group_name(name)
          result.push(group) if group != nil && group != ""
        end
      end
    end
    return result
  end

  #--------------------------------------------------------------------------
  # 判斷是不是 Actor
  #--------------------------------------------------------------------------
  def self.actor_battler?(member)
    return false if member == nil
    return false unless member.respond_to?(:actor?)
    return member.actor?
  end

  #--------------------------------------------------------------------------
  # 取得 Actor ID
  #--------------------------------------------------------------------------
  def self.actor_id(member)
    return 0 unless actor_battler?(member)
    return member.id.to_i if member.respond_to?(:id)
    return 0
  end

  #--------------------------------------------------------------------------
  # 解析 actor / actors 直接指定 ID 的語法
  # 回傳：
  #   nil  = 不是這種語法
  #   Array = 指定的 Actor ID 清單
  #--------------------------------------------------------------------------
  def self.direct_actor_ids(group)
    return nil if group == nil
    text = normalize_group_name(group)

    if text =~ /^actor\s+(\d+)$/i
      return [$1.to_i]
    end

    if text =~ /^actors\s+(.+)$/i
      ids = $1.scan(/\d+/).collect { |n| n.to_i }
      return ids
    end

    if text =~ /^actor_(\d+(?:_\d+)*)$/i
      ids = $1.split(/_/).collect { |n| n.to_i }
      return ids
    end

    return nil
  end

  #--------------------------------------------------------------------------
  # 指定 Actor 是否屬於群組
  # user：技能使用者。只有 self_group 需要。
  #--------------------------------------------------------------------------
  def self.member_in_group?(member, group, user = nil)
    return false unless actor_battler?(member)
    group = normalize_group_name(group)
    return false if group == nil || group == ""

    id = actor_id(member)

    case group
    when "main"
      return id > 0 && id <= MAIN_ACTOR_MAX_ID

    when "summon"
      return id >= SUMMON_ACTOR_MIN_ID

    when "all_actor", "all actor", "all"
      return true

    when "self_group", "self group"
      return same_group_as_user?(member, user)
    end

    ids = direct_actor_ids(group)
    return ids.include?(id) if ids != nil

    static_ids = STATIC_GROUPS[group]
    return true if static_ids != nil && static_ids.include?(id)

    return actor_group_names(member).include?(group)
  end

  #--------------------------------------------------------------------------
  # 判斷 member 是否與使用者同群組
  # 優先順序：
  #   1. 使用者 Actor NOTE 的 actor_group
  #   2. STATIC_GROUPS
  #   3. main / summon 基本分類
  #--------------------------------------------------------------------------
  def self.same_group_as_user?(member, user)
    return false unless actor_battler?(member)
    return false unless actor_battler?(user)

    user_groups = actor_group_names(user)
    unless user_groups.empty?
      user_groups.each do |group|
        return true if member_in_group?(member, group, user)
      end
      return false
    end

    user_id = actor_id(user)

    STATIC_GROUPS.each do |group, ids|
      if ids.include?(user_id)
        return member_in_group?(member, group, user)
      end
    end

    if user_id > 0 && user_id <= MAIN_ACTOR_MAX_ID
      return member_in_group?(member, "main", user)
    end

    if user_id >= SUMMON_ACTOR_MIN_ID
      return member_in_group?(member, "summon", user)
    end

    return false
  end

  #--------------------------------------------------------------------------
  # 依技能範圍判定目標目前是否有效
  #--------------------------------------------------------------------------
  def self.valid_by_scope?(member, obj)
    return false if member == nil
    return false if obj == nil

    if obj.respond_to?(:for_dead_friend?) && obj.for_dead_friend?
      return member.dead?
    end

    if member.respond_to?(:exist?)
      return member.exist?
    end

    if member.respond_to?(:dead?)
      return !member.dead?
    end

    return true
  end

  #--------------------------------------------------------------------------
  # 從 members 中取得合法群組目標
  #--------------------------------------------------------------------------
  def self.filter_members(members, group, user, obj)
    result = []
    return result if members == nil

    members.each do |member|
      next unless member_in_group?(member, group, user)
      next unless valid_by_scope?(member, obj)
      result.push(member)
    end

    return result
  end

  #--------------------------------------------------------------------------
  # 根據使用者與技能，取得技能理論上的目標 members
  # 用於 skill_can_use? / Window_Skill。
  #--------------------------------------------------------------------------
  def self.target_members_for_battler(user, obj)
    return [] if user == nil || obj == nil

    if obj.respond_to?(:for_user?) && obj.for_user?
      return [user]
    end

    user_is_actor = actor_battler?(user)

    if obj.respond_to?(:for_opponent?) && obj.for_opponent?
      if user_is_actor
        return $game_troop == nil ? [] : $game_troop.members
      else
        return $game_party == nil ? [] : $game_party.members
      end
    end

    if (obj.respond_to?(:for_friend?) && obj.for_friend?) ||
       (obj.respond_to?(:for_dead_friend?) && obj.for_dead_friend?)
      if user_is_actor
        return $game_party == nil ? [] : $game_party.members
      else
        return $game_troop == nil ? [] : $game_troop.members
      end
    end

    return []
  end

  #--------------------------------------------------------------------------
  # 是否存在至少一個合法目標
  #--------------------------------------------------------------------------
  def self.usable_target_exists?(user, obj)
    group = target_group(obj)
    return true if group == nil

    # 自身技能不改變原本可用性。
    if obj.respond_to?(:for_user?) && obj.for_user?
      return true
    end

    members = target_members_for_battler(user, obj)
    targets = filter_members(members, group, user, obj)
    return !targets.empty?
  end

  #--------------------------------------------------------------------------
  # 取得舊 YERD Custom Target Select 的 pickcustom ID
  #--------------------------------------------------------------------------
  def self.legacy_pickcustom_id(obj)
    return 0 if obj == nil
    return 0 unless obj.respond_to?(:pickcustom)
    begin
      return obj.pickcustom.to_i
    rescue
      return 0
    end
  end

  #--------------------------------------------------------------------------
  # 診斷紀錄
  #--------------------------------------------------------------------------
  def self.log(text)
    return unless DEBUG
    begin
      file = File.open(LOG_FILE, "a")
      file.write("[" + Time.now.to_s + "] " + text.to_s + "\n")
      file.close
    rescue
    end
  end

  def self.actor_id_list(members)
    result = []
    return result if members == nil
    for member in members
      if actor_battler?(member)
        result.push(actor_id(member))
      else
        result.push("non_actor")
      end
    end
    return result
  end

  #--------------------------------------------------------------------------
  # 給舊版「目標過濾-new」判斷：
  # 這個群組是否應先走召喚物側，避免舊腳本在本補丁接手前先得到空清單。
  #--------------------------------------------------------------------------
  def self.group_prefers_summon_side?(group, user = nil)
    group = normalize_group_name(group)
    return false if group == nil

    return true if group == "summon"

    if group == "self_group" || group == "self group"
      return actor_battler?(user) && actor_id(user) >= SUMMON_ACTOR_MIN_ID
    end

    ids = direct_actor_ids(group)
    if ids != nil && !ids.empty?
      return ids.all? { |id| id >= SUMMON_ACTOR_MIN_ID }
    end

    static_ids = STATIC_GROUPS[group]
    if static_ids != nil && !static_ids.empty?
      return static_ids.all? { |id| id >= SUMMON_ACTOR_MIN_ID }
    end

    # 自訂 Actor NOTE 群組：查看目前隊伍中符合者。
    if $game_party != nil
      matched = $game_party.members.select do |member|
        member_in_group?(member, group, user)
      end
      unless matched.empty?
        return matched.all? { |member| actor_id(member) >= SUMMON_ACTOR_MIN_ID }
      end
    end

    return false
  end
end

#==============================================================================
# ■ Game_Battler
#------------------------------------------------------------------------------
# 沒有合法 target_group 目標時，技能不可使用。
#==============================================================================

class Game_Battler
  unless method_defined?(:albert_tg_skill_can_use)
    alias albert_tg_skill_can_use skill_can_use?
  end

  def skill_can_use?(skill)
    return false unless albert_tg_skill_can_use(skill)

    if $game_temp != nil && $game_temp.in_battle
      if ALBERT_TARGET_GROUP.has_target_group?(skill)
        return false unless ALBERT_TARGET_GROUP.usable_target_exists?(self, skill)
      end
    end

    return true
  end
end

#==============================================================================
# ■ Window_Skill
#------------------------------------------------------------------------------
# 只隱藏「target_group 技能且目前完全沒有合法目標」的技能。
# 不改變其他技能原本的顯示規則。
#==============================================================================

class Window_Skill < Window_Selectable
  if method_defined?(:include?)
    unless method_defined?(:albert_tg_include_skill)
      alias albert_tg_include_skill include?
    end

    def include?(skill)
      return false unless albert_tg_include_skill(skill)

      if ALBERT_TARGET_GROUP::HIDE_IF_NO_TARGET &&
         $game_temp != nil && $game_temp.in_battle &&
         skill != nil && ALBERT_TARGET_GROUP.has_target_group?(skill)
        return false unless ALBERT_TARGET_GROUP.usable_target_exists?(@actor, skill)
      end

      return true
    end
  end
end

#==============================================================================
# ■ Scene_Battle
#------------------------------------------------------------------------------
# 1. 與現有「目標過濾-new」相容。
# 2. 目標選擇畫面只留下指定群組。
#==============================================================================

class Scene_Battle < Scene_Base

  #--------------------------------------------------------------------------
  # 取得目前正在選擇目標的技能／物品
  #--------------------------------------------------------------------------
  def albert_tg_current_object
    user = albert_tg_current_user
    if user != nil && user.respond_to?(:action) && user.action != nil
      begin
        return user.action.skill if user.action.skill?
        return user.action.item  if user.action.item?
      rescue
      end
    end

    return @skill if defined?(@skill) && @skill != nil
    return @item  if defined?(@item)  && @item != nil
    return nil
  end

  #--------------------------------------------------------------------------
  # 取得目前行動者
  #--------------------------------------------------------------------------
  def albert_tg_current_user
    return @commander if defined?(@commander) && @commander != nil
    return @active_battler if defined?(@active_battler) && @active_battler != nil
    return nil
  end

  #--------------------------------------------------------------------------
  # 相容舊版 skill_switch_condition
  # 原本用「特殊使用條件：開關50」區分 main / summon。
  # 現在 target_group 存在時，由群組系統先告訴舊腳本該走哪一側。
  #--------------------------------------------------------------------------
  if method_defined?(:skill_switch_condition)
    unless method_defined?(:albert_tg_old_skill_switch_condition)
      alias albert_tg_old_skill_switch_condition skill_switch_condition
    end
  end

  def skill_switch_condition
    obj = albert_tg_current_object
    group = ALBERT_TARGET_GROUP.target_group(obj)

    if group != nil
      return ALBERT_TARGET_GROUP.group_prefers_summon_side?(
        group, albert_tg_current_user)
    end

    if respond_to?(:albert_tg_old_skill_switch_condition)
      return albert_tg_old_skill_switch_condition
    end

    return false
  end

  #--------------------------------------------------------------------------
  # 開始目標選擇
  #--------------------------------------------------------------------------
  unless method_defined?(:albert_tg_start_target_selection)
    alias albert_tg_start_target_selection start_target_selection
  end

  def start_target_selection(actor = false)
    albert_tg_start_target_selection(actor)

    return unless @target_actors

    obj = albert_tg_current_object
    group = ALBERT_TARGET_GROUP.target_group(obj)
    return if group == nil

    user = albert_tg_current_user
    @target_members = ALBERT_TARGET_GROUP.filter_members(
      $game_party.members, group, user, obj)

    # 理論上技能無合法目標時已經不能出現在技能欄／不能使用。
    # 這裡仍做最後防呆，避免事件、強制行動或其他腳本硬闖進來。
    if @target_members.empty?
      Sound.play_buzzer
      if respond_to?(:end_target_selection)
        end_target_selection(true)
      end
      return
    end

    @index = 0 if @index == nil || @index < 0 || @index >= @target_members.size

    if @cursor != nil
      @cursor.set(@target_members[@index])
    end

    if defined?(@help_window2) && @help_window2 != nil
      @help_window2.set_text_n01add(@target_members[@index])
    end
  end

  #--------------------------------------------------------------------------
  # 在玩家按下確定的「當下」直接記住 Actor ID。
  #
  # 為什麼不能只記 target_index：
  #   @target_members 是過濾後清單，friends_unit.members 是原始戰鬥清單。
  #   ATB / Large Party / 其他目標補丁可能在選擇後到出手前改變索引語意。
  #   Actor ID 是身分，index 只是座位。
  #--------------------------------------------------------------------------
  unless method_defined?(:albert_tg_update_target_capture)
    alias albert_tg_update_target_capture update_target
  end

  def update_target
    if Input.trigger?(Input::C) && @target_actors &&
       @target_members != nil && !@target_members.empty? &&
       @index != nil && @index >= 0 && @index < @target_members.size

      target = @target_members[@index]
      obj = albert_tg_current_object
      user = albert_tg_current_user
      group = ALBERT_TARGET_GROUP.target_group(obj)
      custom_id = ALBERT_TARGET_GROUP.legacy_pickcustom_id(obj)

      # 新 target_group 技能，以及舊 pick custom 16 / 17 都保存 Actor ID。
      if ALBERT_TARGET_GROUP.actor_battler?(target) &&
         (group != nil || custom_id == 16 || custom_id == 17)

        action = nil
        begin
          action = user.action if user != nil
        rescue
          action = nil
        end

        if action != nil
          action.albert_tg_target_actor_id = target.id

          # 同步標準 target_index，供其他腳本使用；但真正執行仍以 Actor ID 為準。
          real_index = nil
          begin
            real_index = $game_party.members.index(target)
          rescue
            real_index = nil
          end
          action.target_index = real_index if real_index != nil

          ALBERT_TARGET_GROUP.log(
            "CAPTURE skill=" + (obj == nil ? "nil" : obj.id.to_s) +
            " group=" + group.to_s +
            " custom=" + custom_id.to_s +
            " actor_id=" + target.id.to_s +
            " actor_name=" + target.name.to_s +
            " action_target_index=" + action.target_index.to_s +
            " party_ids=" + ALBERT_TARGET_GROUP.actor_id_list($game_party.members).inspect
          )
        end
      end
    end

    return albert_tg_update_target_capture
  end
end

#==============================================================================
# ■ Game_BattleAction
#------------------------------------------------------------------------------
# Version 2.0 核心：
#   - 每一次行動自己保存選中的 Actor ID。
#   - 單體 target_group 技能執行時優先用 Actor ID 找目標。
#   - 不再把「過濾後游標 index」誤當成「原始 unit.members index」。
#   - 修復 TargetPriority_SelectionFix 對 pick custom 16 / 17 的覆寫衝突。
#==============================================================================

class Game_BattleAction
  attr_accessor :albert_tg_target_actor_id

  #--------------------------------------------------------------------------
  # 行動清空時，同步清空上一次保存的 Actor ID，避免殘留到下一個技能。
  #--------------------------------------------------------------------------
  unless method_defined?(:albert_tg_clear_action)
    alias albert_tg_clear_action clear
  end

  def clear
    albert_tg_clear_action
    @albert_tg_target_actor_id = nil
  end

  #--------------------------------------------------------------------------
  # 取得此技能真正的目標 Unit
  #--------------------------------------------------------------------------
  def albert_tg_target_unit(obj)
    return nil if obj == nil

    if obj.respond_to?(:for_opponent?) && obj.for_opponent?
      return opponents_unit
    end

    if (obj.respond_to?(:for_friend?) && obj.for_friend?) ||
       (obj.respond_to?(:for_dead_friend?) && obj.for_dead_friend?)
      return friends_unit
    end

    return nil
  end

  #--------------------------------------------------------------------------
  # 從 candidates 中依 Actor ID 找唯一目標
  #--------------------------------------------------------------------------
  def albert_tg_find_actor_by_id(candidates, actor_id)
    return nil if candidates == nil || actor_id == nil

    for member in candidates
      next unless ALBERT_TARGET_GROUP.actor_battler?(member)
      return member if member.id.to_i == actor_id.to_i
    end

    return nil
  end

  #--------------------------------------------------------------------------
  # target_group 實際目標
  #--------------------------------------------------------------------------
  def albert_tg_group_targets(obj, group)
    # 自身技能保持原系統。
    if obj.respond_to?(:for_user?) && obj.for_user?
      return nil
    end

    unit = albert_tg_target_unit(obj)
    return nil if unit == nil

    members = unit.members
    user = battler
    candidates = ALBERT_TARGET_GROUP.filter_members(members, group, user, obj)

    ALBERT_TARGET_GROUP.log(
      "EXEC_BEGIN skill=" + obj.id.to_s +
      " group=" + group.to_s +
      " saved_actor_id=" + @albert_tg_target_actor_id.to_s +
      " target_index=" + @target_index.to_s +
      " unit_ids=" + ALBERT_TARGET_GROUP.actor_id_list(members).inspect +
      " candidate_ids=" + ALBERT_TARGET_GROUP.actor_id_list(candidates).inspect
    )

    # 單體／需要手動選擇。
    if (obj.respond_to?(:for_one?) && obj.for_one?) ||
       (obj.respond_to?(:need_selection?) && obj.need_selection?)

      # 1. 最優先：這次行動在確認目標時保存的 Actor ID。
      if @albert_tg_target_actor_id != nil
        target = albert_tg_find_actor_by_id(candidates, @albert_tg_target_actor_id)
        if target != nil
          ALBERT_TARGET_GROUP.log(
            "EXEC_OK source=action_actor_id actor_id=" + target.id.to_s +
            " actor_name=" + target.name.to_s)
          return [target]
        end

        # 已保存 Actor ID，但現在找不到，表示目標死亡、離場或已不合法。
        # 不改打別人。
        ALBERT_TARGET_GROUP.log(
          "EXEC_EMPTY reason=saved_actor_not_valid actor_id=" +
          @albert_tg_target_actor_id.to_s)
        return []
      end

      # 2. 相容未經玩家游標確認的強制行動／事件技能：
      #    只有當 target_index 本身真的指到合法 candidate 才接受。
      target = nil
      if @target_index != nil && @target_index >= 0 &&
         @target_index < members.size
        target = members[@target_index]
      end

      if target != nil && candidates.include?(target)
        ALBERT_TARGET_GROUP.log(
          "EXEC_OK source=target_index actor_id=" +
          (ALBERT_TARGET_GROUP.actor_battler?(target) ? target.id.to_s : "non_actor"))
        return [target]
      end

      # 3. 最後只為舊系統保留：$game_temp.target_index 在你的舊流程中存 Actor ID。
      #    ATB 中不把它當第一優先，避免其他角色後續選擇覆寫全域值。
      legacy_id = nil
      begin
        legacy_id = $game_temp.target_index if $game_temp != nil
      rescue
        legacy_id = nil
      end

      if legacy_id != nil
        target = albert_tg_find_actor_by_id(candidates, legacy_id)
        if target != nil
          ALBERT_TARGET_GROUP.log(
            "EXEC_OK source=legacy_game_temp actor_id=" + target.id.to_s)
          return [target]
        end
      end

      ALBERT_TARGET_GROUP.log("EXEC_EMPTY reason=no_valid_single_target")
      return []
    end

    # 全體：只返回群組內目前仍合法的成員。
    ALBERT_TARGET_GROUP.log(
      "EXEC_OK source=group_all count=" + candidates.size.to_s)
    return candidates
  end

  #--------------------------------------------------------------------------
  # 接管 make_obj_targets
  #--------------------------------------------------------------------------
  unless method_defined?(:albert_tg_make_obj_targets_v2)
    alias albert_tg_make_obj_targets_v2 make_obj_targets
  end

  def make_obj_targets(obj)
    group = ALBERT_TARGET_GROUP.target_group(obj)

    if group != nil
      targets = albert_tg_group_targets(obj, group)
      return targets if targets != nil
    end

    return albert_tg_make_obj_targets_v2(obj)
  end

  #--------------------------------------------------------------------------
  # 相容舊 YERD pick custom 16 / 17
  #
  # TargetPriority_SelectionFix 曾把 16 / 17 改成：
  #   friends_unit.members[@target_index]
  # 這會破壞你原本 custom 16 用 Actor ID 反查本人的可靠做法。
  # 本段放在 TargetPriority 下方後，重新把 16 / 17 改回「以 Actor ID 為主」。
  #--------------------------------------------------------------------------
  if method_defined?(:pickcustom)
    unless method_defined?(:albert_tg_pickcustom_v2_previous)
      alias albert_tg_pickcustom_v2_previous pickcustom
    end

    def pickcustom(obj, pickcustom_id)
      if pickcustom_id == 16 || pickcustom_id == 17
        actor_id = @albert_tg_target_actor_id

        if actor_id == nil
          begin
            actor_id = $game_temp.target_index if $game_temp != nil
          rescue
            actor_id = nil
          end
        end

        if actor_id != nil
          candidates = []
          begin
            candidates = friends_unit.existing_members
          rescue
            candidates = []
          end

          target = albert_tg_find_actor_by_id(candidates, actor_id)
          if target != nil
            ALBERT_TARGET_GROUP.log(
              "PICKCUSTOM_OK id=" + pickcustom_id.to_s +
              " actor_id=" + target.id.to_s)
            return [target]
          end

          # 有明確保存的 Actor ID，卻已不在合法生存目標中：不改打別人。
          ALBERT_TARGET_GROUP.log(
            "PICKCUSTOM_EMPTY id=" + pickcustom_id.to_s +
            " actor_id=" + actor_id.to_s +
            " reason=actor_not_valid")
          return []
        end

        # 強制行動／事件等沒有經過玩家選擇時，交回原有鏈路處理。
        return albert_tg_pickcustom_v2_previous(obj, pickcustom_id)
      end

      return albert_tg_pickcustom_v2_previous(obj, pickcustom_id)
    end
  end
end

#==============================================================================
# END OF FILE
#==============================================================================

#==============================================================================
# 【Part 2／2：Exact Target Identity】
#==============================================================================
#==============================================================================
# ■ Albert 精確目標選取修正
#------------------------------------------------------------------------------
# 適用於 RPG Maker VX / RGSS2
# Version 1.0
#
# 修正：
#  1. 篩選後的 @index 被 ATB update_target 誤當成原始 members index，
#     導致「游標選 A，實際攻擊 B」。
#  2. TargetPriority_SelectionFix 雖先寫入 selected.index，
#     但之後 ATB 又用 @index 覆蓋 target_index。
#  3. 「対象不可」、albert_targetable_unit? == false、Friendly Monster
#     等不可手動攻擊目標，不再出現在敵方手動選擇清單。
#  4. 行動執行前再次依「當初真正選中的 battler 物件」同步 target_index，
#     避免 ATB / Large Party / 召喚物造成索引語意改變。
#
# 放置位置：
#   所有目標相關腳本之後、Main 之前。
#   建議直接放在 TargetGroup_System 之下。
#
# 注意：
#   本補丁不改寫隨機目標規則，只修正玩家手動選擇與實際命中的一致性。
#==============================================================================

module ALBERT_EXACT_TARGET_FIX
  DEBUG = false

  #--------------------------------------------------------------------------
  # * Log
  #--------------------------------------------------------------------------
  def self.log(text)
    return unless DEBUG
    begin
      file = File.open("Albert_ExactTarget_Log.txt", "a")
      file.write(text.to_s + "\n")
      file.close
    rescue
    end
  end

  #--------------------------------------------------------------------------
  # * 敵人是否允許被玩家手動選擇
  #--------------------------------------------------------------------------
  def self.manual_enemy_targetable?(enemy)
    return false if enemy == nil
    return false unless enemy.respond_to?(:exist?) && enemy.exist?

    # Friendly Monsters：友方敵人不應被玩家當一般敵人手動攻擊。
    if enemy.respond_to?(:friendly?)
      begin
        return false if enemy.friendly?
      rescue
      end
    end

    # 你目前 BattleFormula_TargetFix 的統一目標判定。
    if enemy.respond_to?(:albert_targetable_unit?)
      begin
        return false unless enemy.albert_targetable_unit?
      rescue
      end
    end

    # 相容舊「対象不可エネミー」腳本。
    if enemy.respond_to?(:special_target?)
      begin
        return false if enemy.special_target?
      rescue
      end
    end

    # 最後一層硬防呆：直接檢查 Enemy Note。
    begin
      if enemy.respond_to?(:enemy) && enemy.enemy != nil &&
         enemy.enemy.respond_to?(:note) && enemy.enemy.note != nil
        return false if enemy.enemy.note.include?("対象不可")
      end
    rescue
    end

    return true
  end

  #--------------------------------------------------------------------------
  # * 取得 battler 所屬原始 unit
  #--------------------------------------------------------------------------
  def self.unit_for_battler(target)
    return nil if target == nil

    begin
      return $game_party if target.actor?
    rescue
    end

    return $game_troop
  end

  #--------------------------------------------------------------------------
  # * 取得 battler 在原始 members 中的真正 index
  #--------------------------------------------------------------------------
  def self.real_index(target)
    unit = unit_for_battler(target)
    return nil if unit == nil

    begin
      return unit.members.index(target)
    rescue
      return nil
    end
  end
end

#==============================================================================
# ■ Game_Troop
#------------------------------------------------------------------------------
# 讓 TargetPriority_SelectionFix 的候選清單真正排除不可攻擊目標。
#==============================================================================

class Game_Troop < Game_Unit

  def albert_exact_manual_target_candidates
    result = []

    for enemy in existing_members
      next unless ALBERT_EXACT_TARGET_FIX.manual_enemy_targetable?(enemy)
      result.push(enemy)
    end

    return result
  end

  # TargetPriority_SelectionFix 存在時，直接修正它的候選來源。
  if method_defined?(:albert_player_target_candidates)
    def albert_player_target_candidates
      return albert_exact_manual_target_candidates
    end
  end
end

#==============================================================================
# ■ Game_BattleAction
#------------------------------------------------------------------------------
# 行動自身保存「玩家真正選中的 battler 物件」。
# target_index 只是座位；battler 物件才是身分。
#==============================================================================

class Game_BattleAction
  attr_accessor :albert_exact_selected_target

  unless method_defined?(:albert_exact_clear_previous)
    alias albert_exact_clear_previous clear
  end

  def clear
    albert_exact_clear_previous
    @albert_exact_selected_target = nil
  end

  #--------------------------------------------------------------------------
  # * 執行前重新同步 target_index
  #--------------------------------------------------------------------------
  def albert_exact_sync_target_index
    target = @albert_exact_selected_target
    return if target == nil

    unit = ALBERT_EXACT_TARGET_FIX.unit_for_battler(target)
    return if unit == nil

    index = nil
    begin
      index = unit.members.index(target)
    rescue
      index = nil
    end

    # 目標已經離場時，不硬塞錯誤 index；
    # 後續交回原有腳本決定是否重新導向或取消。
    return if index == nil

    @target_index = index
  end

  unless method_defined?(:albert_exact_make_attack_targets_previous)
    alias albert_exact_make_attack_targets_previous make_attack_targets
  end

  def make_attack_targets
    albert_exact_sync_target_index
    return albert_exact_make_attack_targets_previous
  end

  unless method_defined?(:albert_exact_make_obj_targets_previous)
    alias albert_exact_make_obj_targets_previous make_obj_targets
  end

  def make_obj_targets(obj)
    albert_exact_sync_target_index
    return albert_exact_make_obj_targets_previous(obj)
  end
end

#==============================================================================
# ■ Scene_Battle
#------------------------------------------------------------------------------
# 最終層修正：
#   先記住游標真正指到誰；
#   讓所有舊 update_target 跑完；
#   最後再把 target_index 改回原始 members 的真正 index。
#
# 這一步專門修正 ATB：
#   @commander.action.target_index = @index
# 將「篩選後 index」誤當成「原始隊伍 index」的問題。
#==============================================================================

class Scene_Battle < Scene_Base

  #--------------------------------------------------------------------------
  # * 開始選敵後，最後再做一次不可選目標排除
  #--------------------------------------------------------------------------
  unless method_defined?(:albert_exact_start_target_selection_previous)
    alias albert_exact_start_target_selection_previous start_target_selection
  end

  def start_target_selection(actor = false)
    albert_exact_start_target_selection_previous(actor)

    return if @target_actors
    return if @target_members == nil

    current = nil
    if @index != nil && @index >= 0 && @index < @target_members.size
      current = @target_members[@index]
    end

    filtered = []
    for enemy in @target_members
      if ALBERT_EXACT_TARGET_FIX.manual_enemy_targetable?(enemy)
        filtered.push(enemy)
      end
    end

    @target_members = filtered

    # 沒有任何合法敵方目標：不能把不可攻擊對象重新塞回來。
    if @target_members.empty?
      Sound.play_buzzer
      if respond_to?(:end_target_selection)
        end_target_selection(true)
      end
      return
    end

    new_index = current == nil ? nil : @target_members.index(current)
    @index = new_index == nil ? 0 : new_index
    @max_index = @target_members.size - 1

    target = @target_members[@index]
    @cursor.set(target) if @cursor != nil

    if defined?(@help_window2) && @help_window2 != nil
      @help_window2.set_text_n01add(target)
    end
  end

  #--------------------------------------------------------------------------
  # * 最終 update_target
  #--------------------------------------------------------------------------
  unless method_defined?(:albert_exact_update_target_previous)
    alias albert_exact_update_target_previous update_target
  end

  def update_target
    confirming = Input.trigger?(Input::C)

    selected = nil
    action = nil
    real_index = nil

    if confirming && @target_members != nil && @index != nil &&
       @index >= 0 && @index < @target_members.size

      selected = @target_members[@index]

      user = nil
      user = @commander if defined?(@commander) && @commander != nil
      user = @active_battler if user == nil &&
        defined?(@active_battler) && @active_battler != nil

      begin
        action = user.action if user != nil
      rescue
        action = nil
      end

      real_index = ALBERT_EXACT_TARGET_FIX.real_index(selected)

      ALBERT_EXACT_TARGET_FIX.log(
        "CAPTURE selected=" + selected.name.to_s +
        " filtered_index=" + @index.to_s +
        " real_index=" + real_index.to_s)
    end

    result = albert_exact_update_target_previous

    # 重要：一定要在舊 ATB update_target 執行完後才回寫。
    # 否則它會再次用 @index 覆蓋。
    if confirming && selected != nil && action != nil && real_index != nil
      action.target_index = real_index
      action.albert_exact_selected_target = selected

      # 相容 TargetGroup_System：Actor 身分仍以 Actor ID 保存。
      if selected.respond_to?(:actor?) && selected.actor? &&
         action.respond_to?(:albert_tg_target_actor_id=)
        begin
          action.albert_tg_target_actor_id = selected.id
        rescue
        end
      end

      # 相容舊 pick custom 16 / 17。
      begin
        if $game_temp != nil
          if selected.respond_to?(:actor?) && selected.actor?
            $game_temp.target_index = selected.id
          else
            $game_temp.target_index = real_index
          end
        end
      rescue
      end

      ALBERT_EXACT_TARGET_FIX.log(
        "COMMIT selected=" + selected.name.to_s +
        " final_target_index=" + action.target_index.to_s)
    end

    return result
  end
end

#==============================================================================
# END OF FILE
#==============================================================================
