#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_AutoBattleAI_Authority v2.3
# 【用途】統一 Forest Symphony 自動戰鬥 AI：AI State 套件判定、實際傷害評分、加權隨機、治療／防護／支援決策與安全目標 fallback。
# 【主要機制】Phase 10 將 AutoBattleAI／DamageEval／Integration 收斂為單一 Authority；Phase 11 解除 MechanicExpansion 的 AI alias；Phase 12 再把 Robot 固定行動模式正式回寫本 Authority：協議回合執行 Robot Protocol，非協議回合固定普通攻擊，不再由 DatabaseSupport 疊兩層 make_action wrapper。原 make_action snapshot 與 skill_can_use? 的 super 語意保留。
# 【主要影響】AutoBattleAI、ALBERT_AUTO_AI_EVAL、ALBERT_AUTO_BATTLE_AI_FIX、Game_Actor#make_action、process_*_package。
# 【設定／可調參數】AI State：17=wild、18=healy、22=protect、23=support、25=balanced。可調 AI_STATE_PRIORITY、HEAL_HP_THRESHOLD、RANDOM_SWING、WILD_FOCUS_POWER、BALANCED_RANDOM_RATE、AI_RATING_POINT、KILL_BONUS。
# 【依賴／載入順序】必須在 VX／既有 Game_Actor#make_action 建立後載入，並維持在 FS_MechanicExpansion 前方。Phase 12 起 Robot fixed pattern 也由本頁直接負責；後方 FS_DatabaseSupport_Authority 只提供 Compact ID／資料庫相容與等級／成長支援，不再包裝 make_action。傷害評估仍動態呼叫目前的 make_obj_damage_value。
# 【呼叫方式／範例】角色持有 State 17/18/22/23/25 即自動套用對應 AI。技能 Note：<AI除外>＝不主動選擇；<AI評価:8>＝增加 AI 評價。沒有 AI State 時回到原 Game_Actor#make_action。
# 【相關素材】本頁未直接引用固定 Graphics／Audio 素材。
# 【英文說明中文化】本 Authority 的維護說明與原元件重要英文說明已整理為繁體中文；程式識別字、Notetag、原作者名稱與授權資訊維持原樣。
# 【來源／授權】來源元件：AutoBattleAI、FS_AutoBattleAI_DamageEval_Random、FS_AutoBattleAI_Integration_Authority。三者為專案既有程式，本頁只做等價收斂與中文維護整理。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 範例只記錄原文件、既有事件或程式碼能證實的入口。
# 3. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
# 4. 原作者署名、Credits、License 與來源資訊不得因整理或翻譯而刪除。
# 【Phase 23】所有 Actor AI 內部隨機分支／weighted pick／target tie-break 已經由 FS_AI_RANDOM 統一；正常遊戲 RNG 序列仍委派 Kernel.rand。
#==============================================================================

#==============================================================================
# 【Phase 10｜來源元件與最終責任】
#------------------------------------------------------------------------------
# 1. AutoBattleAI：保留 STATE_AI_MAPPING、make_action snapshot、skill_can_use?。
# 2. DamageEval_Random：提供實際傷害評分、Wild／Balanced 加權選招。
# 3. Integration：提供固定 State 優先序、Healy／Protect／Support 與安全 fallback。
# 4. 原本會被後頁重新定義的舊 process_ai_package／Healy／Wild／Balanced 已不再重複保留。
#==============================================================================

module AutoBattleAI
  STATE_AI_MAPPING = {
    18 => :healy,
    22 => :protect,
    23 => :support,
    17 => :wild,
    25 => :balanced
  }
end

class Game_Actor < Game_Battler
  # 保存載入到此處時的原始 Game_Actor#make_action；沒有 AI State 時回到原流程。
  alias_method :original_make_action, :make_action

  def make_action
    self.action.clear
    return unless movable?

    # Phase 12：Robot fixed pattern 正式由 AI Authority 擁有。
    # 舊 DatabaseSupport v2.0/v2.1 的最外層行為是：
    #   協議回合 -> albert_mx_try_robot_protocol
    #   非協議回合 -> 固定普通攻擊
    # 這裡維持完全相同的 Runtime 行為，但移除兩層 make_action alias。
    if respond_to?(:albert_robot?) && albert_robot?
      if respond_to?(:albert_mx_try_robot_protocol)
        return if albert_mx_try_robot_protocol
      end
      self.action.set_attack
      self.action.decide_random_target
      return
    end

    ai_package = AutoBattleAI.get_actor_ai(self)
    if ai_package.nil?
      original_make_action
      return
    end

    process_ai_package(ai_package)
  end

  # 保留舊 AutoBattleAI 的既有行為：技能可用判定交給 Game_Battler。
  # 注意：這個 super 具有實際語意，不是多餘包裝，請勿任意刪除。
  def skill_can_use?(skill)
    return super(skill)
  end
end

#==============================================================================
# 【實際傷害評分與 Wild／Balanced AI】
#==============================================================================
module ALBERT_AUTO_AI_EVAL
  # 隨機擾動幅度。25 = 權重會在 75%~125% 間浮動。
  RANDOM_SWING = 25

  # Wild AI 偏向高傷害的程度。2 代表高傷害技能優勢更明顯，但仍非必定。
  WILD_FOCUS_POWER = 2

  # Balanced AI 保留多少純隨機行動。30 = 30% 機率從可用技能中隨機挑。
  BALANCED_RANDOM_RATE = 30

  # <AI評価:n> 每 1 點轉換成多少分數。
  AI_RATING_POINT = 25

  # 擊殺目標時的額外分數倍率。50 = +50%。
  KILL_BONUS = 50

  def self.note(obj)
    return "" if obj == nil
    return obj.note.to_s if obj.respond_to?(:note) && obj.note != nil
    return ""
  end

  def self.ai_exclude?(obj)
    text = note(obj)
    return true if text =~ /[<＜]AI除外[>＞]/i
    return true if text =~ /[<＜]AI_EXCLUDE[>＞]/i
    return false
  end

  def self.ai_rating(obj)
    text = note(obj)
    if text =~ /[<＜]AI評価[:：]\s*(-?\d+)[>＞]/i
      return $1.to_i
    end
    if text =~ /[<＜]AI_RATING[:：]\s*(-?\d+)[>＞]/i
      return $1.to_i
    end
    return 0
  end

  def self.weight_with_noise(score, focus_power)
    score = score.to_i
    score = 1 if score < 1

    weight = score
    if focus_power != nil && focus_power > 1
      # 避免數字爆炸：用 score * score / 100 做偏向，而不是直接 score ** 2。
      weight = score + (score * score / 100)
    end

    swing = RANDOM_SWING
    noise = 100 - swing + FS_AI_RANDOM.rand(swing * 2 + 1, :actor_ai_noise)
    weight = weight * noise / 100
    weight = 1 if weight < 1
    return weight
  end

  def self.weighted_pick(list, score_index, focus_power)
    return nil if list == nil || list.empty?
    weights = []
    total = 0
    for item in list
      w = weight_with_noise(item[score_index], focus_power)
      weights.push(w)
      total += w
    end
    return list[FS_AI_RANDOM.rand(list.size, :actor_ai_weight_fallback)] if total <= 0
    value = FS_AI_RANDOM.rand(total, :actor_ai_weight)
    for i in 0...list.size
      if value < weights[i]
        return list[i]
      end
      value -= weights[i]
    end
    return list[0]
  end
end

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● 技能可選目標
  #--------------------------------------------------------------------------
  def albert_ai_targets_for_skill(skill)
    return [] if skill == nil
    if skill.for_opponent?
      return $game_troop.existing_members
    elsif skill.for_user?
      return [self]
    elsif skill.for_dead_friend?
      return $game_party.dead_members
    elsif skill.for_friend?
      return $game_party.existing_members
    end
    return []
  end

  #--------------------------------------------------------------------------
  # ● Phase 11：MechanicExpansion 晚綁定 Hook
  #--------------------------------------------------------------------------
  # 這些方法刻意只用 respond_to? 在「AI 實際執行時」查詢後載入的角色機制。
  # 如此 MechanicExpansion 不需要再用 alias 包裝 AI Authority。
  def albert_auto_ai_mx_filter_actions(available_actions)
    return available_actions if available_actions == nil
    if respond_to?(:albert_mx_ai_filter_actions)
      filtered = albert_mx_ai_filter_actions(available_actions)
      return filtered if filtered.is_a?(Array)
    end
    return available_actions
  end

  def albert_auto_ai_mx_target_condition_pass?(skill, target)
    if respond_to?(:albert_mx_ai_target_condition_pass?)
      return albert_mx_ai_target_condition_pass?(skill, target)
    end
    return true
  end

  def albert_auto_ai_mx_target_bonus(skill, target)
    if respond_to?(:albert_mx_ai_target_bonus)
      return albert_mx_ai_target_bonus(skill, target).to_i
    end
    return 0
  end

  #--------------------------------------------------------------------------
  # ● 用實際戰鬥傷害流程估算技能對單一目標的價值
  #--------------------------------------------------------------------------
  def albert_ai_damage_score(skill, target)
    return 0 if skill == nil || target == nil
    return 0 unless albert_auto_ai_mx_target_condition_pass?(skill, target)

    # 舊鏈為 Mechanic 外層包裝 包住 AI Authority，因此即使 base 因 <AI除外> 回 0，
    # 外層包裝 仍會在最後加 target bonus。這裡刻意保留該細節。
    if ALBERT_AUTO_AI_EVAL.ai_exclude?(skill)
      return albert_auto_ai_mx_target_bonus(skill, target)
    end

    tester = nil
    begin
      tester = target.clone
      tester.clear_action_results if tester.respond_to?(:clear_action_results)
      tester.make_obj_damage_value(self, skill)
    rescue
      begin
        tester = target.clone
        tester.clear_action_results if tester.respond_to?(:clear_action_results)
        tester.make_damage_value(self, skill)
      rescue
        fallback = [skill.base_damage.to_i, 0].max
        return fallback + albert_auto_ai_mx_target_bonus(skill, target)
      end
    end

    damage = 0
    if skill.respond_to?(:damage_to_mp) && skill.damage_to_mp
      damage = tester.mp_damage.to_i rescue 0
    else
      damage = tester.hp_damage.to_i rescue 0
    end
    damage = 0 if damage < 0

    # 乘上命中與迴避的期望值，避免高傷但低命中技能被過度高估。
    begin
      hit = target.calc_hit(self, skill)
      eva = target.calc_eva(self, skill)
      rate = hit - eva
      rate = 5 if rate < 5
      rate = 100 if rate > 100
      damage = damage * rate / 100
    rescue
    end

    # 打得死的技能略加分，但不保證必選。
    begin
      damage += damage * ALBERT_AUTO_AI_EVAL::KILL_BONUS / 100 if damage >= target.hp
    rescue
    end

    damage += ALBERT_AUTO_AI_EVAL.ai_rating(skill) * ALBERT_AUTO_AI_EVAL::AI_RATING_POINT
    damage = 0 if damage < 0

    # 舊 MechanicExpansion 外層包裝 是「基礎分數算完後再加目標加分」；
    # 這裡維持完全相同的順序，負加分亦不另外 clamp。
    return damage.to_i + albert_auto_ai_mx_target_bonus(skill, target)
  end

  #--------------------------------------------------------------------------
  # ● 取得某技能的最佳/加權目標與總分
  #--------------------------------------------------------------------------
  def albert_ai_skill_score_and_target(skill, target_random = true)
    targets = albert_ai_targets_for_skill(skill)
    return [0, nil] if targets == nil || targets.empty?

    # 全體技：分數取所有目標總和，目標索引給第一個活著目標即可。
    if skill.for_all?
      total = 0
      for target in targets
        total += albert_ai_damage_score(skill, target)
      end
      return [total, targets[0]]
    end

    scored_targets = []
    for target in targets
      score = albert_ai_damage_score(skill, target)
      scored_targets.push([target, score]) if score > 0
    end
    return [0, targets[0]] if scored_targets.empty?

    if target_random
      picked = ALBERT_AUTO_AI_EVAL.weighted_pick(scored_targets, 1, 1)
      return [picked[1], picked[0]]
    else
      best = scored_targets[0]
      for item in scored_targets
        best = item if item[1] > best[1]
      end
      return [best[1], best[0]]
    end
  end

  #--------------------------------------------------------------------------
  # ● 攻擊技能候選
  #--------------------------------------------------------------------------
  def albert_ai_attack_candidates(available_actions, target_random = true)
    result = []
    for skill in available_actions
      next if skill == nil
      next if ALBERT_AUTO_AI_EVAL.ai_exclude?(skill)
      next unless skill.for_opponent?
      next unless skill.base_damage > 0
      score_target = albert_ai_skill_score_and_target(skill, target_random)
      score = score_target[0]
      target = score_target[1]
      result.push([skill, target, score]) if score > 0 && target != nil
    end
    return result
  end

  #--------------------------------------------------------------------------
  # ● Wild Package：偏向高傷害，但用加權輪盤保留隨機性
  #--------------------------------------------------------------------------
  def process_wild_package(available_actions)
    available_actions = albert_auto_ai_mx_filter_actions(available_actions)
    candidates = albert_ai_attack_candidates(available_actions, true)
    return [nil, nil] if candidates.empty?
    picked = ALBERT_AUTO_AI_EVAL.weighted_pick(candidates, 2, ALBERT_AUTO_AI_EVAL::WILD_FOCUS_POWER)
    return [picked[0], picked[1]]
  end

  #--------------------------------------------------------------------------
  # ● Balanced Package：部分隨機，部分依實際傷害加權
  #--------------------------------------------------------------------------
  def process_balanced_package(available_actions)
    available_actions = albert_auto_ai_mx_filter_actions(available_actions)
    return [nil, nil] if available_actions == nil || available_actions.empty?

    # 保留一部分純隨機，讓 AI 不像機器人每次都算最佳解。
    if FS_AI_RANDOM.rand(100, :balanced_branch) < ALBERT_AUTO_AI_EVAL::BALANCED_RANDOM_RATE
      shuffled = []
      while shuffled.size < available_actions.size
        item = available_actions[FS_AI_RANDOM.rand(available_actions.size, :balanced_shuffle)]
        shuffled.push(item) unless shuffled.include?(item)
      end
      for skill in shuffled
        next if skill == nil
        next if ALBERT_AUTO_AI_EVAL.ai_exclude?(skill)
        targets = albert_ai_targets_for_skill(skill)
        next if targets == nil || targets.empty?
        return [skill, targets[FS_AI_RANDOM.rand(targets.size, :balanced_target)]]
      end
    end

    candidates = albert_ai_attack_candidates(available_actions, true)
    unless candidates.empty?
      picked = ALBERT_AUTO_AI_EVAL.weighted_pick(candidates, 2, 1)
      return [picked[0], picked[1]]
    end

    # 沒有攻擊技能時，回到可用技能隨機。
    for skill in available_actions
      next if skill == nil
      next if ALBERT_AUTO_AI_EVAL.ai_exclude?(skill)
      targets = albert_ai_targets_for_skill(skill)
      next if targets == nil || targets.empty?
      return [skill, targets[FS_AI_RANDOM.rand(targets.size, :balanced_fallback_target)]]
    end

    return [nil, nil]
  end
end

#==============================================================================
# 【AI 套件整合與最終決策入口】
#==============================================================================
module ALBERT_AUTO_BATTLE_AI_FIX
  # 多個 AI State 同時存在時的固定判定順序。
  AI_STATE_PRIORITY = [18, 22, 23, 17, 25]

  # Healy AI 低於此 HP 百分比才主動補血。
  HEAL_HP_THRESHOLD = 80

  #--------------------------------------------------------------------------
  # AI 控制用 State ID，不應被治療 AI 當成異常狀態處理。
  #--------------------------------------------------------------------------
  def self.ai_control_state_ids
    result = []
    if defined?(AutoBattleAI) && AutoBattleAI.const_defined?(:STATE_AI_MAPPING)
      for state_id in AutoBattleAI::STATE_AI_MAPPING.keys
        result.push(state_id)
      end
    end
    return result
  end
end

#==============================================================================
# AutoBattleAI
#==============================================================================
module AutoBattleAI
  def self.get_actor_ai(actor)
    return nil if actor == nil

    checked = []

    for state_id in ALBERT_AUTO_BATTLE_AI_FIX::AI_STATE_PRIORITY
      next unless STATE_AI_MAPPING.has_key?(state_id)
      checked.push(state_id)
      return STATE_AI_MAPPING[state_id] if actor.state?(state_id)
    end

    # 若日後擴充 STATE_AI_MAPPING，新 ID 仍可使用。
    for state_id in STATE_AI_MAPPING.keys
      next if checked.include?(state_id)
      return STATE_AI_MAPPING[state_id] if actor.state?(state_id)
    end

    return nil
  end
end

#==============================================================================
# Game_Actor
#==============================================================================
class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # 共用：取得 target 目前擁有的 State ID
  #--------------------------------------------------------------------------
  def albert_auto_ai_state_ids(target)
    result = []
    return result if target == nil

    for state in target.states
      next if state == nil
      result.push(state.id)
    end

    return result
  end

  #--------------------------------------------------------------------------
  # 共用：技能真正能從 target 移除哪些狀態
  #--------------------------------------------------------------------------
  def albert_auto_ai_curable_state_ids(skill, target)
    result = []
    return result if skill == nil || target == nil
    return result unless skill.respond_to?(:minus_state_set)

    target_states = albert_auto_ai_state_ids(target)
    ai_states = ALBERT_AUTO_BATTLE_AI_FIX.ai_control_state_ids

    for state_id in skill.minus_state_set
      next if ai_states.include?(state_id)
      result.push(state_id) if target_states.include?(state_id)
    end

    return result
  end

  #--------------------------------------------------------------------------
  # 共用：技能真正能對 target 新增哪些尚不存在的狀態
  #--------------------------------------------------------------------------
  def albert_auto_ai_missing_plus_state_ids(skill, target)
    result = []
    return result if skill == nil || target == nil
    return result unless skill.respond_to?(:plus_state_set)

    target_states = albert_auto_ai_state_ids(target)
    ai_states = ALBERT_AUTO_BATTLE_AI_FIX.ai_control_state_ids

    for state_id in skill.plus_state_set
      next if ai_states.include?(state_id)
      result.push(state_id) unless target_states.include?(state_id)
    end

    return result
  end

  #--------------------------------------------------------------------------
  # 共用：估算技能對 target 的 HP 回復量
  # 使用目前實際 make_obj_damage_value 流程，與傷害公式補丁保持一致。
  #--------------------------------------------------------------------------
  def albert_auto_ai_estimated_heal(skill, target)
    return 0 if skill == nil || target == nil

    tester = nil
    begin
      tester = target.clone
      tester.clear_action_results if tester.respond_to?(:clear_action_results)
      tester.make_obj_damage_value(self, skill)
      damage = tester.hp_damage.to_i
      return -damage if damage < 0
    rescue
    end

    return 0
  end

  #--------------------------------------------------------------------------
  # 共用：HP 百分比
  #--------------------------------------------------------------------------
  def albert_auto_ai_hp_rate(target)
    return 0 if target == nil
    maxhp = target.maxhp.to_i
    return 0 if maxhp <= 0
    return target.hp.to_i * 100 / maxhp
  end

  #--------------------------------------------------------------------------
  # 共用：技能 Note 的 AI 評價加分
  #--------------------------------------------------------------------------
  def albert_auto_ai_note_bonus(skill)
    bonus = 0
    if defined?(ALBERT_AUTO_AI_EVAL)
      begin
        bonus = ALBERT_AUTO_AI_EVAL.ai_rating(skill) *
                ALBERT_AUTO_AI_EVAL::AI_RATING_POINT
      rescue
        bonus = 0
      end
    end

    # Phase 11：保留舊 MechanicExpansion 外層包裝 的行為。
    # 只把「最大的正向目標加分」加入 Support／Protect／Healy 的技能評分。
    if respond_to?(:albert_mx_ai_valid_targets)
      max_bonus = 0
      for target in albert_mx_ai_valid_targets(skill)
        value = albert_auto_ai_mx_target_bonus(skill, target)
        max_bonus = value if value > max_bonus
      end
      bonus += max_bonus
    end

    return bonus
  end

  #--------------------------------------------------------------------------
  # 共用：攻擊 fallback
  # 優先沿用 DamageEval_Random 的 Wild 實際傷害評估。
  #--------------------------------------------------------------------------
  def albert_auto_ai_offense_fallback(available_actions)
    if respond_to?(:process_wild_package)
      result = process_wild_package(available_actions)
      if result != nil && result[0] != nil
        return result
      end
    end

    if respond_to?(:process_balanced_package)
      result = process_balanced_package(available_actions)
      if result != nil && result[0] != nil
        return result
      end
    end

    return [nil, nil]
  end

  #--------------------------------------------------------------------------
  # 共用：安全設定普通攻擊
  #--------------------------------------------------------------------------
  def albert_auto_ai_set_normal_attack
    target = $game_troop.random_target

    if target == nil
      self.action.clear
      return
    end

    self.action.set_attack
    self.action.target_index = target.index
  end

  #--------------------------------------------------------------------------
  # 共用：確認目標是否仍符合技能基本範圍
  #--------------------------------------------------------------------------
  def albert_auto_ai_target_valid?(skill, target)
    return false if skill == nil
    return true if skill.for_all?

    if skill.for_user?
      return target == self
    elsif skill.for_dead_friend?
      return target != nil && target.dead?
    elsif skill.for_friend?
      return target != nil && target.exist?
    elsif skill.for_opponent?
      return target != nil && target.exist?
    end

    return target != nil
  end

  #--------------------------------------------------------------------------
  # Phase 11：MechanicExpansion 目標偏好後處理
  #--------------------------------------------------------------------------
  def albert_auto_ai_apply_mx_target_preference(skill)
    return if skill == nil
    return if skill.for_all?
    return unless respond_to?(:albert_mx_ai_has_target_tags?)
    return unless albert_mx_ai_has_target_tags?(skill)
    return unless respond_to?(:albert_mx_ai_valid_targets)

    valid_targets = albert_mx_ai_valid_targets(skill)
    return if valid_targets.empty?

    best_score = nil
    best_targets = []
    for target in valid_targets
      score = albert_auto_ai_mx_target_bonus(skill, target)
      if best_score == nil || score > best_score
        best_score = score
        best_targets = [target]
      elsif score == best_score
        best_targets.push(target)
      end
    end

    return if best_targets.empty?
    chosen = best_targets[FS_AI_RANDOM.rand(best_targets.size, :actor_ai_best_target_tie)]
    self.action.target_index = chosen.index if chosen != nil
  end

  #--------------------------------------------------------------------------
  # 覆寫原 AutoBattleAI 的 package 執行入口
  #--------------------------------------------------------------------------
  def process_ai_package(package)
    available_actions = []

    for skill in skills
      next if skill == nil
      next unless skill_can_use?(skill)

      if defined?(ALBERT_AUTO_AI_EVAL)
        begin
          next if ALBERT_AUTO_AI_EVAL.ai_exclude?(skill)
        rescue
        end
      end

      available_actions.push(skill)
    end

    method_name = "process_#{package}_package"
    action_result = nil

    if respond_to?(method_name)
      action_result = send(method_name, available_actions)
    else
      action_result = [nil, nil]
    end

    action_result = [nil, nil] unless action_result.is_a?(Array)
    chosen_skill = action_result[0]
    chosen_target = action_result[1]

    if chosen_skill == nil
      albert_auto_ai_set_normal_attack
      return
    end

    # 單體技能若 package 沒給合法目標，再補一次安全目標。
    unless chosen_skill.for_all?
      unless albert_auto_ai_target_valid?(chosen_skill, chosen_target)
        if chosen_skill.for_opponent?
          chosen_target = $game_troop.random_target
        elsif chosen_skill.for_dead_friend?
          list = $game_party.dead_members
          chosen_target = list.empty? ? nil : list[0]
        elsif chosen_skill.for_user?
          chosen_target = self
        elsif chosen_skill.for_friend?
          list = $game_party.existing_members
          chosen_target = list.empty? ? nil : list[0]
        end
      end
    end

    if !chosen_skill.for_all? && chosen_target == nil
      albert_auto_ai_set_normal_attack
      return
    end

    self.action.set_skill(chosen_skill.id)

    unless chosen_skill.for_all?
      self.action.target_index = chosen_target.index
    end

    albert_auto_ai_apply_mx_target_preference(chosen_skill)
  end

  #--------------------------------------------------------------------------
  # Healy Package
  # 優先順序：復活 > 真正可解除的異常 > HP 回復 > 攻擊 fallback
  #--------------------------------------------------------------------------
  def process_healy_package(available_actions)
    available_actions = albert_auto_ai_mx_filter_actions(available_actions)
    # 1. 復活
    dead_allies = $game_party.dead_members
    unless dead_allies.empty?
      best = nil

      for skill in available_actions
        next unless skill.for_dead_friend?

        if skill.for_all?
          score = dead_allies.size * 10000 + albert_auto_ai_note_bonus(skill)
          candidate = [skill, dead_allies[0], score]
          best = candidate if best == nil || candidate[2] > best[2]
        else
          for target in dead_allies
            heal = albert_auto_ai_estimated_heal(skill, target)
            score = 10000 + heal + albert_auto_ai_note_bonus(skill)
            candidate = [skill, target, score]
            best = candidate if best == nil || candidate[2] > best[2]
          end
        end
      end

      return [best[0], best[1]] if best != nil
    end

    # 2. 解除真正存在、而且技能真的能解除的異常狀態
    alive_allies = $game_party.existing_members
    best = nil

    for skill in available_actions
      next unless skill.for_friend?
      next if skill.for_dead_friend?
      next unless skill.respond_to?(:minus_state_set)
      next if skill.minus_state_set.empty?

      if skill.for_all?
        total_curable = 0
        for target in alive_allies
          total_curable += albert_auto_ai_curable_state_ids(skill, target).size
        end
        if total_curable > 0
          score = total_curable * 1000 + albert_auto_ai_note_bonus(skill)
          candidate = [skill, alive_allies[0], score]
          best = candidate if best == nil || candidate[2] > best[2]
        end
      else
        for target in alive_allies
          count = albert_auto_ai_curable_state_ids(skill, target).size
          next if count <= 0
          score = count * 1000 + (100 - albert_auto_ai_hp_rate(target))
          score += albert_auto_ai_note_bonus(skill)
          candidate = [skill, target, score]
          best = candidate if best == nil || candidate[2] > best[2]
        end
      end
    end

    return [best[0], best[1]] if best != nil

    # 3. HP 回復。只考慮低於門檻的隊友，並確認技能實際能回 HP。
    weak_allies = []
    for target in alive_allies
      if albert_auto_ai_hp_rate(target) < ALBERT_AUTO_BATTLE_AI_FIX::HEAL_HP_THRESHOLD
        weak_allies.push(target)
      end
    end

    unless weak_allies.empty?
      best = nil

      for skill in available_actions
        next unless skill.for_friend?
        next if skill.for_dead_friend?

        if skill.for_all?
          total_effective = 0
          for target in weak_allies
            heal = albert_auto_ai_estimated_heal(skill, target)
            missing = target.maxhp - target.hp
            effective = [heal, missing].min
            total_effective += effective if effective > 0
          end

          if total_effective > 0
            score = total_effective + albert_auto_ai_note_bonus(skill)
            candidate = [skill, alive_allies[0], score]
            best = candidate if best == nil || candidate[2] > best[2]
          end
        else
          for target in weak_allies
            heal = albert_auto_ai_estimated_heal(skill, target)
            next if heal <= 0

            missing = target.maxhp - target.hp
            effective = [heal, missing].min
            urgency = 100 - albert_auto_ai_hp_rate(target)
            score = effective + urgency * 10 + albert_auto_ai_note_bonus(skill)
            candidate = [skill, target, score]
            best = candidate if best == nil || candidate[2] > best[2]
          end
        end
      end

      return [best[0], best[1]] if best != nil
    end

    return albert_auto_ai_offense_fallback(available_actions)
  end

  #--------------------------------------------------------------------------
  # Protect Package
  # 優先施放我方尚未存在的增益 State。
  # 沒有適合增益時，轉入 Healy，再轉攻擊。
  #--------------------------------------------------------------------------
  def process_protect_package(available_actions)
    available_actions = albert_auto_ai_mx_filter_actions(available_actions)
    allies = $game_party.existing_members
    best = nil

    for skill in available_actions
      next unless skill.for_friend? || skill.for_user?
      next if skill.for_dead_friend?
      next unless skill.respond_to?(:plus_state_set)
      next if skill.plus_state_set.empty?

      targets = skill.for_user? ? [self] : allies

      if skill.for_all?
        total_missing = 0
        for target in targets
          total_missing += albert_auto_ai_missing_plus_state_ids(skill, target).size
        end
        if total_missing > 0
          score = total_missing * 1000 + albert_auto_ai_note_bonus(skill)
          candidate = [skill, targets[0], score]
          best = candidate if best == nil || candidate[2] > best[2]
        end
      else
        for target in targets
          count = albert_auto_ai_missing_plus_state_ids(skill, target).size
          next if count <= 0
          score = count * 1000 + (100 - albert_auto_ai_hp_rate(target))
          score += albert_auto_ai_note_bonus(skill)
          candidate = [skill, target, score]
          best = candidate if best == nil || candidate[2] > best[2]
        end
      end
    end

    return [best[0], best[1]] if best != nil
    return process_healy_package(available_actions)
  end

  #--------------------------------------------------------------------------
  # Support Package
  # 優先對敵方附加尚不存在的 State，再考慮我方增益。
  #--------------------------------------------------------------------------
  def process_support_package(available_actions)
    available_actions = albert_auto_ai_mx_filter_actions(available_actions)
    enemies = $game_troop.existing_members
    best = nil

    # 1. 敵方 Debuff / 異常
    for skill in available_actions
      next unless skill.for_opponent?
      next unless skill.respond_to?(:plus_state_set)
      next if skill.plus_state_set.empty?

      if skill.for_all?
        total_missing = 0
        for target in enemies
          total_missing += albert_auto_ai_missing_plus_state_ids(skill, target).size
        end
        if total_missing > 0
          score = total_missing * 1000 + albert_auto_ai_note_bonus(skill)
          candidate = [skill, enemies[0], score]
          best = candidate if best == nil || candidate[2] > best[2]
        end
      else
        for target in enemies
          count = albert_auto_ai_missing_plus_state_ids(skill, target).size
          next if count <= 0
          score = count * 1000 + albert_auto_ai_note_bonus(skill)
          candidate = [skill, target, score]
          best = candidate if best == nil || candidate[2] > best[2]
        end
      end
    end

    return [best[0], best[1]] if best != nil

    # 2. 我方 Buff
    allies = $game_party.existing_members
    for skill in available_actions
      next unless skill.for_friend? || skill.for_user?
      next if skill.for_dead_friend?
      next unless skill.respond_to?(:plus_state_set)
      next if skill.plus_state_set.empty?

      targets = skill.for_user? ? [self] : allies

      if skill.for_all?
        total_missing = 0
        for target in targets
          total_missing += albert_auto_ai_missing_plus_state_ids(skill, target).size
        end
        if total_missing > 0
          score = total_missing * 1000 + albert_auto_ai_note_bonus(skill)
          candidate = [skill, targets[0], score]
          best = candidate if best == nil || candidate[2] > best[2]
        end
      else
        for target in targets
          count = albert_auto_ai_missing_plus_state_ids(skill, target).size
          next if count <= 0
          score = count * 1000 + albert_auto_ai_note_bonus(skill)
          candidate = [skill, target, score]
          best = candidate if best == nil || candidate[2] > best[2]
        end
      end
    end

    return [best[0], best[1]] if best != nil
    return albert_auto_ai_offense_fallback(available_actions)
  end
end
