#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_RandomTarget_Authority v1.2｜TargetPriority / Provoke
# 【用途】整合 TargetPriority 手動選取／ATB 重導向與 RandomTarget 最終規則。Phase 20 已把與 Targeting 無關的 EnemySummon SafePosition 移回 EnemySummon_Core。
# 【主要影響】Game_Enemy、Scene_Battle、Game_BattleAction、Game_Unit、ALBERT_TARGET_PRIORITY、ALBERT_RANDOM_TARGET_INTEGRATION。
# 【設定】PROVOKE_STATE_ID=14、PROVOKE_PRIORITY=1000，以及 Random Target 對 Provoke／Disappear／no_random_target／TargetWeight 的整合規則。
# 【載入順序】必須位於 YERD TargetEffects、Friendly Monsters、Provoke、BattleFormula TargetFix 等基礎層之後；後方 TargetGroupExact、MarkedCommand、BattleTargetUI 還會繼續接管選取流程。
# 【EnemySummon】本頁不再定義 ma_call_ally 或召喚座標常數。敵方召喚請查 `EnemySummon_Core v1.1` 與後方 `FS_EnemySummonGuard_FinalAuthority`。
# 【呼叫方式】自動由戰鬥選取／AI 使用，無事件 Script Call。
# 【相關素材】無固定 Graphics／Audio。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、實際資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址保留；Phase 20 Archive 另保存修改前 byte-exact 原稿。
# 4. 除 EnemySummon SafePosition 責任回寫外，本輪只整理文件／註解；其他 Runtime code 與載入順序不得因翻譯而改變。
#==============================================================================
# PHASE6 ORIGINAL PAGE: 392 | TargetPriority_SelectionFix
#==============================================================================
#==============================================================================
# Albert_TargetPriority_SelectionFix_RGSS2.rb
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2
#
# 功能：
#  1. 敵人 Note / State Note 可設定 <target priority: n>
#  2. 場上只要存在較高 priority 的敵人，玩家手動選敵時只能選最高層級。
#  3. 沿用既有嘲諷狀態 ID 14，視為高優先級目標。
#  4. 修正「篩選後游標 index」與「原始隊伍 index」可能不一致的問題。
#  5. ATB 中若原目標在出手前死亡／失效，會重新導向當下仍合法的最高優先目標。
#  6. 修正 YERD Custom Target Select 的 pick custom 16 / 17，直接使用原始 target_index。
#
# 建議位置：所有戰鬥、ATB、YERD TargetEffects、目標過濾-new、
#             BattleFormula_TargetFix 等腳本之下，Main 之上。
#
# 使用方式：
#   Enemy Note：
#     <target priority: 1>
#
#   State Note：
#     <target priority: 2>
#
#   中文也支援：
#     <目標優先: 1>
#
#   想讓特定技能／物品無視限制：
#     <ignore target priority>
#     或 <無視目標優先>
#==============================================================================

module ALBERT_TARGET_PRIORITY

  # 既有系統中的嘲諷狀態 ID
  PROVOKE_STATE_ID = 14

  # 嘲諷的優先級。一般 <target priority: n> 通常用 1、2、3 即可。
  PROVOKE_PRIORITY = 1000

  # 是否排除 Friendly Monsters 系統中的友方敵人。
  EXCLUDE_FRIENDLY_ENEMIES = true

  #--------------------------------------------------------------------------
  # 安全取得 Note
  #--------------------------------------------------------------------------
  def self.note(obj)
    return "" if obj == nil
    return obj.note.to_s if obj.respond_to?(:note) && obj.note != nil
    return ""
  end

  #--------------------------------------------------------------------------
  # 讀取 priority
  # 支援：
  #   <target priority: 2>
  #   <target_priority: 2>
  #   <target-priority: 2>
  #   <目標優先: 2>
  #--------------------------------------------------------------------------
  def self.read_priority(obj)
    text = note(obj)

    if text =~ /<target[ _-]*priority\s*:\s*(-?\d+)>/i
      return $1.to_i
    end

    if text =~ /<目標優先\s*[:：]\s*(-?\d+)>/
      return $1.to_i
    end

    # 無數字時視為 priority 1
    return 1 if text =~ /<target[ _-]*priority>/i
    return 1 if text =~ /<目標優先>/

    return 0
  end

  #--------------------------------------------------------------------------
  # 技能／物品是否無視限制
  #--------------------------------------------------------------------------
  def self.ignore_priority?(obj)
    text = note(obj)
    return true if text =~ /<ignore[ _-]*target[ _-]*priority>/i
    return true if text =~ /<無視目標優先>/
    return false
  end

  #--------------------------------------------------------------------------
  # 從 battler 陣列中取最高優先級群組
  #--------------------------------------------------------------------------
  def self.highest_priority_members(members)
    return [] if members == nil || members.empty?

    max_priority = nil
    result = []

    for member in members
      next if member == nil
      priority = member.albert_target_priority

      if max_priority == nil || priority > max_priority
        max_priority = priority
        result = [member]
      elsif priority == max_priority
        result.push(member)
      end
    end

    return result
  end
end

#==============================================================================
# Game_Enemy
#==============================================================================
class Game_Enemy < Game_Battler

  #--------------------------------------------------------------------------
  # 敵人的最終目標優先級
  # Enemy Note、所有 State Note、既有嘲諷狀態 14 取最高值。
  #--------------------------------------------------------------------------
  def albert_target_priority
    priority = ALBERT_TARGET_PRIORITY.read_priority(enemy)

    for state in states
      value = ALBERT_TARGET_PRIORITY.read_priority(state)
      priority = value if value > priority
    end

    if state?(ALBERT_TARGET_PRIORITY::PROVOKE_STATE_ID)
      provoke = ALBERT_TARGET_PRIORITY::PROVOKE_PRIORITY
      priority = provoke if provoke > priority
    end

    return priority
  end
end

#==============================================================================
# Game_Troop
#==============================================================================
class Game_Troop < Game_Unit

  #--------------------------------------------------------------------------
  # 玩家可手動選擇的敵人候選
  #--------------------------------------------------------------------------
  def albert_player_target_candidates
    result = []

    for enemy in existing_members
      next if enemy == nil
      next unless enemy.exist?

      if ALBERT_TARGET_PRIORITY::EXCLUDE_FRIENDLY_ENEMIES
        if enemy.respond_to?(:friendly?)
          next if enemy.friendly?
        end
      end

      result.push(enemy)
    end

    # 若因特殊相容性情況全部被排除，避免空陣列造成游標錯誤。
    return existing_members if result.empty?
    return result
  end

  #--------------------------------------------------------------------------
  # 目前最高優先級的合法目標群
  #--------------------------------------------------------------------------
  def albert_priority_target_members
    candidates = albert_player_target_candidates
    return ALBERT_TARGET_PRIORITY.highest_priority_members(candidates)
  end

  #--------------------------------------------------------------------------
  # 將原始 troop index 矯正為目前合法的最高優先目標 index。
  # 這是防止「游標選 B，實際打 A」的核心。
  #--------------------------------------------------------------------------
  def albert_normalize_priority_target_index(index)
    allowed = albert_priority_target_members
    return index if allowed == nil || allowed.empty?

    target = nil
    if index != nil && index >= 0 && index < members.size
      target = members[index]
    end

    if target != nil && target.exist? && allowed.include?(target)
      return target.index
    end

    return allowed[0].index
  end
end

#==============================================================================
# Scene_Battle
#------------------------------------------------------------------------------
# 讓游標直接使用「合法 battler 陣列」，並把確認時的 target_index 維持為
# battler 在原始 members 裡的 index，而不是篩選後陣列的 @index。
#==============================================================================
class Scene_Battle < Scene_Base

  unless method_defined?(:albert_tp_start_target_selection)
    alias albert_tp_start_target_selection start_target_selection
  end

  def start_target_selection(actor = false)
    albert_tp_start_target_selection(actor)

    return if @target_members == nil || @target_members.empty?

    # 我方選擇沿用你現有「目標過濾-new」的結果，不重做規則。
    unless @target_actors
      obj = albert_tp_current_target_object
      unless ALBERT_TARGET_PRIORITY.ignore_priority?(obj)
        targets = $game_troop.albert_priority_target_members
        @target_members = targets unless targets == nil || targets.empty?
      end
    end

    albert_tp_sync_cursor_to_target_members
  end

  #--------------------------------------------------------------------------
  # 取得目前正在選目標的技能／物品。
  # 普通攻擊回傳 nil。
  #--------------------------------------------------------------------------
  def albert_tp_current_target_object
    battler = nil
    battler = @commander if @commander != nil
    battler = @active_battler if battler == nil && @active_battler != nil
    return nil if battler == nil || battler.action == nil

    return battler.action.skill if battler.action.skill?
    return battler.action.item  if battler.action.item?
    return nil
  end

  #--------------------------------------------------------------------------
  # 同步篩選後陣列、游標 index、游標 Sprite 與說明視窗。
  #--------------------------------------------------------------------------
  def albert_tp_sync_cursor_to_target_members
    return if @target_members == nil || @target_members.empty?

    @index = 0 if @index == nil
    @index = 0 if @index < 0 || @index >= @target_members.size
    @max_index = @target_members.size - 1

    target = @target_members[@index]
    @cursor.set(target) if @cursor != nil

    if @help_window2 != nil && target != nil
      @help_window2.set_text_n01add(target)
    end
  end

  #--------------------------------------------------------------------------
  # 你目前的 update_target 其實已經把 action.target_index 寫成
  # @target_members[@index].index，方向是對的。
  # 這裡再把 $game_temp.target_index 同步成一致資料：
  # Actor 保留 actor id（舊 pick custom 16 相容）；Enemy 使用原始 troop index。
  #--------------------------------------------------------------------------
  unless method_defined?(:albert_tp_update_target)
    alias albert_tp_update_target update_target
  end

  def update_target
    # ATB 戰況可能在選目標期間改變。每幀重新取得合法敵人群，
    # 讓「最高優先敵人全部倒下後，其他敵人立刻重新可選」。
    albert_tp_refresh_enemy_targets

    confirming = Input.trigger?(Input::C)
    selected = nil

    if confirming && @target_members != nil && @index != nil
      selected = @target_members[@index]

      if selected != nil && @commander != nil && @commander.action != nil
        @commander.action.target_index = selected.index
      end
    end

    albert_tp_update_target

    if confirming && selected != nil
      if selected.actor?
        $game_temp.target_index = selected.id
      else
        $game_temp.target_index = selected.index
      end
    end
  end

  #--------------------------------------------------------------------------
  # ATB 用動態刷新。保留原本正在指向的 battler；若已不合法則回到第一個。
  #--------------------------------------------------------------------------
  def albert_tp_refresh_enemy_targets
    return if @target_actors
    return if @target_members == nil

    obj = albert_tp_current_target_object
    return if ALBERT_TARGET_PRIORITY.ignore_priority?(obj)

    targets = $game_troop.albert_priority_target_members
    return if targets == nil || targets.empty?
    return if targets == @target_members

    current = nil
    if @index != nil && @index >= 0 && @index < @target_members.size
      current = @target_members[@index]
    end

    @target_members = targets
    new_index = current == nil ? nil : @target_members.index(current)
    @index = new_index == nil ? 0 : new_index
    albert_tp_sync_cursor_to_target_members
  end

  #--------------------------------------------------------------------------
  # 敵資料視窗原腳本用「@target_members == $game_troop.members」判斷是否 dispose。
  # 篩選後陣列不再相等，因此補上清理，避免反覆選敵後殘留視窗物件。
  #--------------------------------------------------------------------------
  if method_defined?(:end_target_selection)
    unless method_defined?(:albert_tp_end_target_selection)
      alias albert_tp_end_target_selection end_target_selection
    end

    def end_target_selection(cansel = false)
      enemy_selection = !@target_actors
      info_window = @enemy_element_window

      albert_tp_end_target_selection(cansel)

      if enemy_selection && info_window != nil
        if !info_window.respond_to?(:disposed?) || !info_window.disposed?
          info_window.dispose
        end
        @enemy_element_window = nil
      end
    end
  end
end

#==============================================================================
# Game_BattleAction
#------------------------------------------------------------------------------
# 執行前再次校正目標，防止 ATB 中「選擇後到出手前」戰況改變。
#==============================================================================
class Game_BattleAction

  #--------------------------------------------------------------------------
  # 是否為我方 battler 對敵方的選擇型行動
  #--------------------------------------------------------------------------
  def albert_tp_actor_action?
    return false if battler == nil
    return battler.actor?
  end

  def albert_tp_normalize_enemy_target_index
    return unless albert_tp_actor_action?
    return if $game_troop == nil
    @target_index = $game_troop.albert_normalize_priority_target_index(@target_index)
  end

  #--------------------------------------------------------------------------
  # 普通攻擊
  # Berserk / Confusion 有自己的隨機或友方選擇邏輯，不強制改寫。
  #--------------------------------------------------------------------------
  unless method_defined?(:albert_tp_make_attack_targets)
    alias albert_tp_make_attack_targets make_attack_targets
  end

  def make_attack_targets
    if albert_tp_actor_action?
      unless battler.confusion? || battler.berserker?
        albert_tp_normalize_enemy_target_index
      end
    end

    return albert_tp_make_attack_targets
  end

  #--------------------------------------------------------------------------
  # 技能／物品
  # 只有「對敵且需要手動選擇」的行動才校正。
  # 全體、純隨機等不需要選擇的技能不受影響。
  #--------------------------------------------------------------------------
  unless method_defined?(:albert_tp_make_obj_targets)
    alias albert_tp_make_obj_targets make_obj_targets
  end

  def make_obj_targets(obj)
    if albert_tp_actor_action? && obj != nil
      if obj.for_opponent? && obj.need_selection?
        unless ALBERT_TARGET_PRIORITY.ignore_priority?(obj)
          albert_tp_normalize_enemy_target_index
        end
      end
    end

    return albert_tp_make_obj_targets(obj)
  end

  #--------------------------------------------------------------------------
  # 修正 YERD TargetEffects 中 pick custom 16 / 17 的目標落差。
  #
  # 舊版 custom 16 用 $game_temp.target_index 記 Actor ID 再反查，
  # 這是「篩選後 index 與原始 index 不一致」時的權宜做法。
  # 現在 action.target_index 已統一存原始 friends_unit.members index，
  # 因此直接取 members[@target_index] 才是唯一真實來源。
  #--------------------------------------------------------------------------
  if method_defined?(:pickcustom)
    unless method_defined?(:albert_tp_pickcustom)
      alias albert_tp_pickcustom pickcustom
    end

    def pickcustom(obj, pickcustom_id)
      if pickcustom_id == 16 || pickcustom_id == 17
        target = nil

        if @target_index != nil && @target_index >= 0 &&
           @target_index < friends_unit.members.size
          target = friends_unit.members[@target_index]
        end

        if target != nil && target.exist?
          return [target]
        end

        return []
      end

      return albert_tp_pickcustom(obj, pickcustom_id)
    end
  end
end

#==============================================================================
# Phase 20：EnemySummon SafePosition 已回寫 EnemySummon_Core；本頁不再管理召喚座標。
#==============================================================================
#==============================================================================
# PHASE6 ORIGINAL PAGE: 394 | RandomTarget_IntegrationFix
#==============================================================================
#==============================================================================
# Albert_RandomTarget_IntegrationFix_RGSS2.rb
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2
#
# 目的：統一 Game_Unit#random_target 的最終規則。
#
# 支援：
#  1. Provoke / 挑釁優先。
#  2. Disappear / 消失排除；若所有可攻擊者都只是消失，保留舊系統 fallback。
#  3. <no_random_target> 與「対象不可」硬排除。
#  4. BattleFormula_TargetFix 的：
#       POSITION_WEIGHT
#       SUMMON_TARGET_WEIGHT
#       ACTOR_TARGET_WEIGHT
#       ENEMY_TARGET_WEIGHT
#       <target_weight:n>
#  5. Friendly Monsters：直接使用 existing_members，因此保留其動態 members 過濾。
#
# 建議位置：
#  Provoke & Disappear、Friendly Monsters、BattleFormula_TargetFix 之下，
#  Main 之上。
#==============================================================================

module ALBERT_RANDOM_TARGET_INTEGRATION
  #--------------------------------------------------------------------------
  # 是否為消失狀態
  #--------------------------------------------------------------------------
  def self.disappear?(member)
    return false if member == nil

    if defined?(ALBERT_BATTLE_FIX)
      begin
        return member.state?(ALBERT_BATTLE_FIX::DISAPPEAR_STATE_ID)
      rescue
      end
    end

    if defined?(SNF)
      begin
        return member.state?(SNF::DISAPPEAR_STATE_ID)
      rescue
      end
    end

    return false
  end

  #--------------------------------------------------------------------------
  # 是否為挑釁狀態
  #--------------------------------------------------------------------------
  def self.provoke?(member)
    return false if member == nil

    if member.respond_to?(:albert_provoke?)
      begin
        return member.albert_provoke?
      rescue
      end
    end

    if defined?(ALBERT_BATTLE_FIX)
      begin
        return member.state?(ALBERT_BATTLE_FIX::PROVOKE_STATE_ID)
      rescue
      end
    end

    if defined?(SNF)
      begin
        return member.state?(SNF::PROVOKE_STATE_ID)
      rescue
      end
    end

    return false
  end

  #--------------------------------------------------------------------------
  # 硬排除：即使所有人都 Disappear，也不應被 fallback 選中。
  #--------------------------------------------------------------------------
  def self.hard_excluded?(member)
    return true if member == nil
    return true unless member.exist?
    return false if member.actor?
    return false unless member.respond_to?(:enemy)

    text = ""
    begin
      if defined?(ALBERT_BATTLE_FIX)
        text = ALBERT_BATTLE_FIX.note(member.enemy)
      else
        text = member.enemy.note.to_s
      end
    rescue
      text = ""
    end

    return true if text =~ /<no_random_target>/i
    return true if text.include?("対象不可")
    return false
  end

  #--------------------------------------------------------------------------
  # 一般情況是否能被 random_target 選中
  #--------------------------------------------------------------------------
  def self.normal_targetable?(member)
    return false if member == nil
    return false unless member.exist?

    if member.respond_to?(:albert_targetable_unit?)
      begin
        return member.albert_targetable_unit?
      rescue
      end
    end

    return false if disappear?(member)
    return false if hard_excluded?(member)
    return true
  end

  #--------------------------------------------------------------------------
  # 取得最終目標權重
  #--------------------------------------------------------------------------
  def self.target_weight(member)
    return 0 if member == nil

    if member.respond_to?(:albert_target_weight)
      begin
        return member.albert_target_weight.to_i
      rescue
      end
    end

    begin
      return member.odds.to_i
    rescue
      return 1
    end
  end

  #--------------------------------------------------------------------------
  # 加權輪盤
  #--------------------------------------------------------------------------
  def self.weighted_pick(members)
    return nil if members == nil || members.empty?

    pairs = []
    total = 0

    for member in members
      weight = target_weight(member)
      next if weight <= 0
      pairs.push([member, weight])
      total += weight
    end

    # 所有權重都 <= 0 時，避免 nil 造成後續行動錯誤。
    return members[FS_AI_RANDOM.rand(members.size, :random_target_fallback)] if pairs.empty? || total <= 0

    value = FS_AI_RANDOM.rand(total, :random_target_weight)
    for pair in pairs
      return pair[0] if value < pair[1]
      value -= pair[1]
    end

    return pairs[0][0]
  end
end

class Game_Unit
  #--------------------------------------------------------------------------
  # 最終 random_target
  #--------------------------------------------------------------------------
  def random_target
    all_members = []
    list = existing_members
    return nil if list == nil || list.empty?

    for member in list
      next if member == nil
      next unless member.exist?
      all_members.push(member)
    end
    return nil if all_members.empty?

    # 1. 挑釁最高優先。
    #    Disappear 不會壓過 Provoke，但 <no_random_target> / 対象不可仍是硬排除。
    provoke_targets = []
    for member in all_members
      next unless ALBERT_RANDOM_TARGET_INTEGRATION.provoke?(member)
      next if ALBERT_RANDOM_TARGET_INTEGRATION.hard_excluded?(member)
      provoke_targets.push(member)
    end

    unless provoke_targets.empty?
      return ALBERT_RANDOM_TARGET_INTEGRATION.weighted_pick(provoke_targets)
    end

    # 2. 一般合法目標。
    normal_targets = []
    for member in all_members
      if ALBERT_RANDOM_TARGET_INTEGRATION.normal_targetable?(member)
        normal_targets.push(member)
      end
    end

    unless normal_targets.empty?
      return ALBERT_RANDOM_TARGET_INTEGRATION.weighted_pick(normal_targets)
    end

    # 3. 舊 Provoke / Disappear 系統的安全 fallback：
    #    若大家只是 Disappear，仍允許從存活者中抽選；
    #    但 <no_random_target> / 対象不可 不會因此失效。
    fallback = []
    for member in all_members
      next if ALBERT_RANDOM_TARGET_INTEGRATION.hard_excluded?(member)
      fallback.push(member)
    end

    return nil if fallback.empty?
    return ALBERT_RANDOM_TARGET_INTEGRATION.weighted_pick(fallback)
  end
end
