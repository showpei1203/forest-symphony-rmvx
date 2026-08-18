#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_DynamicThreat_Targeting v2.2
# 【用途】召喚系統元件「SummonGuard_DynamicThreat_v2」。
# 【主要機制】處理召喚物資料、加入戰鬥、技能、UI、裝備或目標相容；需與 FS Summon Runtime／UI Authority 一起看。
# 【主要影響】Game_Troop、Game_Battler、Game_BattleAction、ALBERT_DYNAMIC_THREAT21
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：SUMMON_GROUPS、PRIORITY、ENEMY_ONLY、RANDOM_FALLBACK_WHEN_TAGGED、BASE_THREAT_WEIGHT、DEBUG。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 3 個 alias／方法包裝，載入順序具有語意。
# 【呼叫方式／範例】技能 Note：<summon_guard:2>、<state_focus:31>、<dps_focus:800>、<threat_target>、<state_threat:31,500>、<dps_threat:100,10>。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【英文說明中文化】本頁頂部已用繁體中文整理／翻譯原說明中與維護直接相關的用途、機制、設定、順序、呼叫與範例；下方原文保留作作者授權、完整細節與歷史查核依據。
# 【來源／授權】若下方有原作者署名、Credits、License 或網址，必須保留；本中文維護說明不取代原授權。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 範例只記錄原文件、既有事件或程式碼能證實的入口；沒有入口就明寫自動執行。
# 3. 原作者署名、授權與原始說明保留在下方；中文化不代表取得原作權。
# 4. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
# 【Phase 23】pick_random／pick_weighted 已改走 FS_AI_RANDOM；測試模式可固定 StateFocus／SummonGuard／Threat roulette。
#==============================================================================
#==============================================================================
# Albert_RMVX_SummonGuard_DynamicThreat_v2_1.rb
# 適用於 RPG Maker VX / RGSS2
#------------------------------------------------------------------------------
# 【目的】
# 這是建立在第一版 SummonGuard_TargetEffect 行為上的安全 v2.1。第一版之所以能穩定運作，
# 是因為它直接攔截 Game_BattleAction#make_obj_targets，而不以嚴格 scope 判定先拒絕技能。
#
# 【技能 Note 功能】
#   <summon_guard:2>       優先指定召喚群組；群組無人生存時退回隨機目標。
#   <state_focus:31>       優先指定具有 State 31 的角色／召喚物。
#   <dps_focus:800>        本場累計傷害達 800 後，優先指定目前 DPS／累積傷害最高者。
#   <threat_target>        使用柔性的威脅權重抽選。
#   <state_threat:31,500>  搭配 threat_target；State 31 額外增加 500 權重。
#   <dps_threat:100,10>    搭配 threat_target；每造成 100 傷害增加 10 權重。
#
# 【載入位置】
# 必須放在 YERD_TargetEffects／SBS／Tankentai 目標腳本之後、Main 之前；本版取代舊
# Albert_RMVX_SummonGuard_TargetEffect 與舊 v2。
#==============================================================================

module ALBERT_DYNAMIC_THREAT21
  #--------------------------------------------------------------------------
  # 群組 ID => 對應的召喚 Actor ID。
  #--------------------------------------------------------------------------
  SUMMON_GROUPS = {
    1 => [7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18],
    2 => [7],
    3 => [8],
    4 => [9]
  }

  # 硬性規則優先序：越前面的規則優先。
  PRIORITY = ["state_focus", "summon_guard", "dps_focus", "threat_target"]

  # true：只改變敵方行動；若測試需要讓我方也套用，可暫時改 false。
  ENEMY_ONLY = true

  # 重要：
  # 舊 v2 使用 SINGLE_TARGET_ONLY=true 與 obj.for_one?。
  # 部分 YERD／SBS 目標效果會讓該判定不可靠，因此 v2.1 不再使用。

  # 帶標籤的敵方技能若找不到 State／召喚／DPS 特殊目標，退回隨機選取。
  # 保留第一版行為：沒有符合召喚物時改用隨機目標。
  RANDOM_FALLBACK_WHEN_TAGGED = true

  BASE_THREAT_WEIGHT = 100

  # true：在遊戲資料夾輸出除錯紀錄。
  DEBUG = false

  @battle_serial = 0

  def self.battle_serial
    return @battle_serial || 0
  end

  def self.next_battle_serial
    @battle_serial = battle_serial + 1
  end

  def self.note(obj)
    return "" if obj == nil
    return "" unless obj.respond_to?(:note)
    return "" if obj.note == nil
    return obj.note.to_s
  end

  def self.note_number(obj, key, default_value)
    text = note(obj)
    if text =~ /<\s*#{key}\s*:\s*(-?\d+)\s*>/i
      return $1.to_i
    end
    return default_value
  end

  def self.note_tag?(obj, key)
    text = note(obj)
    return text =~ /<\s*#{key}\s*>/i ? true : false
  end

  def self.guard_group_id(obj)
    value = note_number(obj, "summon_guard", 0)
    return value if value > 0
    value = note_number(obj, "summon guard", 0)
    return value if value > 0
    return 0
  end

  def self.state_focus_id(obj)
    value = note_number(obj, "state_focus", 0)
    return value if value > 0
    value = note_number(obj, "focus_state", 0)
    return value if value > 0
    value = note_number(obj, "state focus", 0)
    return value if value > 0
    return 0
  end

  def self.dps_focus_threshold(obj)
    value = note_number(obj, "dps_focus", -1)
    return value if value >= 0
    value = note_number(obj, "dps focus", -1)
    return value if value >= 0
    return -1
  end

  def self.threat_target?(obj)
    return true if note_tag?(obj, "threat_target")
    return true if note_tag?(obj, "threat target")
    return false
  end

  def self.has_any_tag?(obj)
    return true if guard_group_id(obj) > 0
    return true if state_focus_id(obj) > 0
    return true if dps_focus_threshold(obj) >= 0
    return true if threat_target?(obj)
    return false
  end

  def self.group_actor_ids(group_id)
    result = SUMMON_GROUPS[group_id]
    result = [] if result == nil
    return result
  end

  def self.pick_random(list)
    return nil if list == nil || list.empty?
    return list[FS_AI_RANDOM.rand(list.size, :dynamic_threat_random)]
  end

  def self.pick_weighted(pairs)
    total = 0
    for pair in pairs
      next if pair == nil
      weight = pair[1].to_i
      total += weight if weight > 0
    end
    return nil if total <= 0

    roll = FS_AI_RANDOM.rand(total, :dynamic_threat_weight)
    acc = 0
    for pair in pairs
      next if pair == nil
      battler = pair[0]
      weight = pair[1].to_i
      next if weight <= 0
      acc += weight
      return battler if roll < acc
    end
    return nil
  end

  def self.state_threat_rules(obj)
    rules = []
    text = note(obj)
    text.scan(/<\s*state_threat\s*:\s*(\d+)\s*,\s*(-?\d+)\s*>/i) do |a, b|
      rules.push([a.to_i, b.to_i])
    end
    text.scan(/<\s*state threat\s*:\s*(\d+)\s*,\s*(-?\d+)\s*>/i) do |a, b|
      rules.push([a.to_i, b.to_i])
    end
    return rules
  end

  def self.dps_threat_rule(obj)
    text = note(obj)
    if text =~ /<\s*dps_threat\s*:\s*(\d+)\s*,\s*(-?\d+)\s*>/i
      return [$1.to_i, $2.to_i]
    end
    if text =~ /<\s*dps threat\s*:\s*(\d+)\s*,\s*(-?\d+)\s*>/i
      return [$1.to_i, $2.to_i]
    end
    return nil
  end

  def self.log(text)
    return unless DEBUG
    begin
      file = File.open("Albert_DynamicThreat21_Log.txt", "a")
      file.write(text.to_s + "\n")
      file.close
    rescue
    end
  end
end

#==============================================================================
# 戰鬥序號重置：讓 DPS／累積傷害只在本場戰鬥內有效。
#==============================================================================
class Game_Troop < Game_Unit
  unless method_defined?(:albert_dynamic21_troop_setup)
    alias albert_dynamic21_troop_setup setup
  end

  def setup(troop_id)
    ALBERT_DYNAMIC_THREAT21.next_battle_serial
    albert_dynamic21_troop_setup(troop_id)
  end
end

#==============================================================================
# Game_Battler：追蹤威脅用累積傷害。
#==============================================================================
class Game_Battler
  def albert_dynamic21_reset_threat_if_needed
    serial = ALBERT_DYNAMIC_THREAT21.battle_serial
    if @albert_dynamic21_serial != serial
      @albert_dynamic21_serial = serial
      @albert_dynamic21_damage = 0
    end
  end

  def albert_dynamic21_damage
    albert_dynamic21_reset_threat_if_needed
    return @albert_dynamic21_damage || 0
  end

  def albert_dynamic21_add_damage(value)
    albert_dynamic21_reset_threat_if_needed
    @albert_dynamic21_damage ||= 0
    @albert_dynamic21_damage += value.to_i if value.to_i > 0
  end

  unless method_defined?(:albert_dynamic21_execute_damage)
    alias albert_dynamic21_execute_damage execute_damage
  end

  def execute_damage(user)
    # 記錄我方 battler 真正造成的 HP 傷害。
    if user != nil && user.respond_to?(:actor?) && user.actor?
      begin
        user.albert_dynamic21_add_damage(@hp_damage.to_i) if @hp_damage.to_i > 0
      rescue
      end
    end
    albert_dynamic21_execute_damage(user)
  end
end

#==============================================================================
# Game_BattleAction：保留第一版直接攔截目標建立的方式，再加入動態規則。
#==============================================================================
class Game_BattleAction
  unless method_defined?(:albert_dynamic21_make_obj_targets)
    alias albert_dynamic21_make_obj_targets make_obj_targets
  end

  def make_obj_targets(obj)
    if ALBERT_DYNAMIC_THREAT21.has_any_tag?(obj)
      targets = albert_dynamic21_targets(obj)
      return targets if targets != nil && targets.size > 0
    end
    return albert_dynamic21_make_obj_targets(obj)
  end

  def albert_dynamic21_targets(obj)
    # 預設只處理敵方行動，但刻意不使用 obj.for_one? 做 scope 阻擋。
    if ALBERT_DYNAMIC_THREAT21::ENEMY_ONLY
      begin
        return nil if @battler != nil && @battler.actor?
      rescue
      end
    end

    begin
      return nil if obj.respond_to?(:for_opponent?) && !obj.for_opponent?
    rescue
    end

    candidates = albert_dynamic21_candidates
    return nil if candidates == nil || candidates.empty?

    target = nil
    used_rule = ""

    for rule in ALBERT_DYNAMIC_THREAT21::PRIORITY
      case rule
      when "state_focus"
        target = albert_dynamic21_state_focus_target(obj, candidates)
      when "summon_guard"
        target = albert_dynamic21_summon_guard_target(obj, candidates)
      when "dps_focus"
        target = albert_dynamic21_dps_focus_target(obj, candidates)
      when "threat_target"
        target = albert_dynamic21_weighted_target(obj, candidates)
      end
      if target != nil
        used_rule = rule
        break
      end
    end

    if target != nil
      ALBERT_DYNAMIC_THREAT21.log("hit rule=" + used_rule.to_s + " skill=" + obj.name.to_s + " target=" + target.name.to_s)
      return [target]
    end

    # 第一版相容：有標籤但找不到特殊目標時，退回隨機目標。
    if ALBERT_DYNAMIC_THREAT21::RANDOM_FALLBACK_WHEN_TAGGED
      begin
        target = opponents_unit.random_target
        if target != nil
          ALBERT_DYNAMIC_THREAT21.log("fallback random skill=" + obj.name.to_s + " target=" + target.name.to_s)
          return [target]
        end
      rescue
      end
    end

    return nil
  end

  def albert_dynamic21_candidates
    list = []
    begin
      for member in opponents_unit.existing_members
        next if member == nil
        next unless member.exist?
        list.push(member)
      end
    rescue
      list = []
    end
    return list
  end

  def albert_dynamic21_state_focus_target(obj, candidates)
    state_id = ALBERT_DYNAMIC_THREAT21.state_focus_id(obj)
    return nil if state_id <= 0
    list = []
    for member in candidates
      begin
        list.push(member) if member.state?(state_id)
      rescue
      end
    end
    return ALBERT_DYNAMIC_THREAT21.pick_random(list)
  end

  def albert_dynamic21_summon_guard_target(obj, candidates)
    group_id = ALBERT_DYNAMIC_THREAT21.guard_group_id(obj)
    return nil if group_id <= 0
    ids = ALBERT_DYNAMIC_THREAT21.group_actor_ids(group_id)
    return nil if ids == nil || ids.empty?

    list = []
    for member in candidates
      next unless member.respond_to?(:actor?) && member.actor?
      next unless member.respond_to?(:id)
      list.push(member) if ids.include?(member.id)
    end
    return ALBERT_DYNAMIC_THREAT21.pick_random(list)
  end

  def albert_dynamic21_dps_focus_target(obj, candidates)
    threshold = ALBERT_DYNAMIC_THREAT21.dps_focus_threshold(obj)
    return nil if threshold < 0

    best = nil
    best_value = -1
    for member in candidates
      next unless member.respond_to?(:actor?) && member.actor?
      value = member.albert_dynamic21_damage
      if value > best_value
        best = member
        best_value = value
      end
    end
    return nil if best == nil
    return nil if best_value < threshold
    return best
  end

  def albert_dynamic21_weighted_target(obj, candidates)
    return nil unless ALBERT_DYNAMIC_THREAT21.threat_target?(obj)

    state_rules = ALBERT_DYNAMIC_THREAT21.state_threat_rules(obj)
    dps_rule = ALBERT_DYNAMIC_THREAT21.dps_threat_rule(obj)
    pairs = []

    for member in candidates
      weight = ALBERT_DYNAMIC_THREAT21::BASE_THREAT_WEIGHT

      for rule in state_rules
        state_id = rule[0]
        bonus = rule[1]
        begin
          weight += bonus if member.state?(state_id)
        rescue
        end
      end

      if dps_rule != nil && member.respond_to?(:actor?) && member.actor?
        scale = [dps_rule[0].to_i, 1].max
        per = dps_rule[1].to_i
        weight += (member.albert_dynamic21_damage / scale) * per
      end

      pairs.push([member, weight])
    end

    return ALBERT_DYNAMIC_THREAT21.pick_weighted(pairs)
  end
end

#==============================================================================
# 建議測試用 Note：
#   <summon_guard:2>
#   <state_focus:31>
#   <dps_focus:1>
#   <threat_target>
#   <state_threat:31,500>
#   <dps_threat:100,10>
#==============================================================================
