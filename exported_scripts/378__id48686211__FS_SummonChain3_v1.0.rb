#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_SummonChain3 v1.0
# 【用途】Forest Symphony 專用 Runtime／資料腳本「FS_SummonChain3 v1.0」。
# 【主要機制】屬目前正式專案功能的一部分；具體責任以本頁定義的類別、模組與方法，以及 LoadOrder Guide 為準。
# 【主要影響】Scene_Battle、ALBERT_SUMMON_CHAIN3
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：MAX_STAGES、OD_REQUIRE_USES_CHAIN_START、NEW_CHAIN_OVERRIDES_LEGACY、DEBUG、TARGET_CONDITION_TYPES、RESULT_CONDITION_TYPES。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 3 個 alias／方法包裝，載入順序具有語意；登記 $imported：AlbertSummonChain3；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
# 【呼叫方式／範例】<summon_chain 1:18:241:700:0>；<chain_require 階段:條件[:數值]>；<chain_require 1:type:pokemon>
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
# ■ Albert_RMVX_SummonChain3_v1_0.rb
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2 / Ruby 1.8 相容
# 三段條件式召喚物追擊補丁
#------------------------------------------------------------------------------
# 【放置位置】
#   請放在：
#   1. Albert_RMVX_ComboCore_AllInOne_v1_1_OD
#   2. Albert_RMVX_CharacterMechanicCore_v1_0_TC
#   之下，Main 之上。
#
# 【用途】
#   將 CharacterMechanicCore 原本的單段 <summon_followup> 擴充為最多三段的
#   條件式連鎖追擊。沿用既有 Tankentai SBS 追擊執行器，因此：
#
#   ・召喚物使用自己的能力值與技能公式。
#   ・使用追擊技能自己的 SBS base_action。
#   ・不消耗召喚物正常 ATB。
#   ・不吃掉召喚物下一個正常回合。
#   ・沿用原本死亡目標重新選擇機制。
#   ・同一召喚物在同一條連鎖中最多追擊一次。
#   ・最多三段，避免遞迴與無限追擊。
#   ・沒有新標籤的技能仍沿用舊 <summon_followup> 規則。
#
#==============================================================================
# ■ 一、基本用法
#==============================================================================
#
# 寫在「喬伊的起手技能」Note：
#
#   <summon_chain 1:18:241:700:0>
#   <summon_chain 2:30:250:700:100>
#   <summon_chain 3:35:260:900:300>
#
# 格式：
#   <summon_chain 階段:召喚物ActorID:追擊技能ID:需求OD:成功後消耗OD>
#
# 代表：
#   第1段：Actor 18 使用 Skill 241，需求喬伊起手時 OD 700，不消耗 OD。
#   第2段：Actor 30 使用 Skill 250，需求喬伊起手時 OD 700，成功後消耗 100 OD。
#   第3段：Actor 35 使用 Skill 260，需求喬伊起手時 OD 900，成功後消耗 300 OD。
#
# 注意：
#   ・需求OD預設看「喬伊發動起手技能前的OD」。
#   ・實際消耗OD時，仍會檢查喬伊目前剩餘OD是否足夠。
#   ・第2段只有第1段成功後才會判定。
#   ・第3段只有第2段成功後才會判定。
#
#==============================================================================
# ■ 二、條件用法
#==============================================================================
#
# 寫法：
#   <chain_require 階段:條件[:數值]>
#
# 目前支援：
#
# 【目前目標條件】
#   <chain_require 2:state:31>       目標目前有 State 31
#   <chain_require 2:not_state:31>   目標目前沒有 State 31
#   <chain_require 3:hp_below:30>    目標目前 HP <= 30%
#   <chain_require 3:hp_above:50>    目標目前 HP >= 50%
#   <chain_require 3:broken>         目標目前有 CharacterMechanicCore 的崩防狀態
#
# 【上一棒結果條件】
#   對第1段而言，「上一棒」就是喬伊的起手技能。
#   對第2段而言，「上一棒」就是第1段追擊。
#   對第3段而言，「上一棒」就是第2段追擊。
#
#   <chain_require 1:hit>            上一棒造成有效結果
#   <chain_require 2:damage:500>     上一棒總共造成至少 500 HP 傷害
#   <chain_require 2:added_state:31> 上一棒新附加 State 31
#   <chain_require 2:stack_up:31>    上一棒讓 State 31 疊層增加
#   <chain_require 2:weak>           上一棒命中弱點
#   <chain_require 2:critical>       上一棒出現暴擊
#   <chain_require 2:kill>           上一棒至少擊倒一個目標
#
# 【召喚物種類條件】
#   <chain_require 1:type:pokemon>
#   <chain_require 2:type:robot>
#   <chain_require 3:type:clone>
#
#   支援：pokemon / robot / clone / summon
#
#==============================================================================
# ■ 三、完整範例
#==============================================================================
#
#   <summon_chain 1:18:241:700:0>
#   <chain_require 1:type:pokemon>
#
#   <summon_chain 2:30:250:700:100>
#   <chain_require 2:type:robot>
#   <chain_require 2:added_state:31>
#
#   <summon_chain 3:35:260:900:300>
#   <chain_require 3:type:clone>
#   <chain_require 3:broken>
#   <chain_require 3:hp_below:30>
#
# 流程：
#   喬伊起手
#     → 第1段寶可夢追擊
#     → 若第1段新附加 State 31，第2段機器人追擊
#     → 若目標此時崩防且 HP <= 30%，第3段複製人終結追擊
#
#==============================================================================
# ■ 四、同階段候補
#==============================================================================
#
# 同一階段可寫多個候補，會依 Note 出現順序，選擇第一個符合條件且在場存活者。
#
#   <summon_chain 1:18:241:0:0>
#   <summon_chain 1:19:242:0:0>
#
# 若 Actor 18 不在場或死亡，才嘗試 Actor 19。
#
#==============================================================================

$imported = {} if $imported == nil
$imported["AlbertSummonChain3"] = true

module ALBERT_SUMMON_CHAIN3
  VERSION = "1.0"

  # 最多追擊段數。此腳本設計上不要超過 3。
  MAX_STAGES = 3

  # true：需求OD使用「喬伊起手技能前的OD」。
  # false：每一段都使用該段觸發當下的目前OD。
  OD_REQUIRE_USES_CHAIN_START = true

  # 技能同時存在新舊追擊標籤時：
  # true  = 有 <summon_chain> 時只跑新連鎖，不額外跑舊 <summon_followup>
  # false = 新連鎖跑完後仍可再跑舊追擊（不建議，容易過強）
  NEW_CHAIN_OVERRIDES_LEGACY = true

  # 測試用紀錄檔。正式遊戲建議 false。
  DEBUG = false

  TARGET_CONDITION_TYPES = [
    "state", "not_state", "hp_below", "hp_above", "broken"
  ]

  RESULT_CONDITION_TYPES = [
    "hit", "damage", "added_state", "stack_up",
    "weak", "critical", "kill"
  ]

  #--------------------------------------------------------------------------
  # ● 安全讀取 Note
  #--------------------------------------------------------------------------
  def self.note(obj)
    return "" if obj == nil
    return obj.note.to_s if obj.respond_to?(:note)
    return ""
  end

  #--------------------------------------------------------------------------
  # ● 解析三段追擊設定
  #   回傳：[stage, actor_id, skill_id, od_need, od_cost]
  #--------------------------------------------------------------------------
  def self.chain_specs(skill)
    result = []
    text = note(skill)
    regex = /<summon_chain\s+([1-3])\s*:\s*(\d+)\s*:\s*(\d+)(?:\s*:\s*(\d+))?(?:\s*:\s*(\d+))?\s*>/i
    text.scan(regex) do |data|
      stage    = data[0].to_i
      actor_id = data[1].to_i
      skill_id = data[2].to_i
      od_need  = data[3] == nil ? 0 : data[3].to_i
      od_cost  = data[4] == nil ? 0 : data[4].to_i
      result.push([stage, actor_id, skill_id, od_need, od_cost])
    end
    return result
  end

  #--------------------------------------------------------------------------
  # ● 解析階段條件
  #   回傳：{ 1 => [[type, value], ...], 2 => [...], 3 => [...] }
  #--------------------------------------------------------------------------
  def self.chain_conditions(skill)
    result = {1 => [], 2 => [], 3 => []}
    text = note(skill)
    regex = /<chain_require\s+([1-3])\s*:\s*([a-z_]+)(?:\s*:\s*([a-z0-9_]+))?\s*>/i
    text.scan(regex) do |data|
      stage = data[0].to_i
      type  = data[1].to_s.downcase
      value = data[2] == nil ? nil : data[2].to_s.downcase
      result[stage].push([type, value])
    end
    return result
  end

  #--------------------------------------------------------------------------
  # ● Debug Log
  #--------------------------------------------------------------------------
  def self.log(text)
    return unless DEBUG
    begin
      file = File.open("Albert_SummonChain3_Log.txt", "a")
      file.write(text.to_s + "\n")
      file.close
    rescue
    end
  end
end

#==============================================================================
# ■ Scene_Battle
#==============================================================================
class Scene_Battle < Scene_Base

  #--------------------------------------------------------------------------
  # ● 先包住 execute_action_skill，標記「下一次 target_decision 要保存起手快照」。
  #
  #   你的 Tankentai execute_action_skill 是先 target_decision(skill)，再 playing_action，
  #   因此不能在 execute_action_skill 入口直接抓 @targets，否則目標尚未建立。
  #--------------------------------------------------------------------------
  unless method_defined?(:albert_sc3_old_execute_action_skill)
    alias albert_sc3_old_execute_action_skill execute_action_skill
  end

  def execute_action_skill
    captured_root = false
    begin
      if !@albert_cc_in_summon_followup && @active_battler != nil
        if @active_battler.respond_to?(:albert_cc_joey?) && @active_battler.albert_cc_joey?
          skill = nil
          if @active_battler.action != nil
            skill = @active_battler.action.skill
          end
          if skill != nil && !ALBERT_SUMMON_CHAIN3.chain_specs(skill).empty?
            @albert_sc3_prepare_root_capture = true
            @albert_sc3_root_snapshot = nil
            captured_root = true
          end
        end
      end
      albert_sc3_old_execute_action_skill
    ensure
      if captured_root
        @albert_sc3_prepare_root_capture = false
        @albert_sc3_root_snapshot = nil
      end
    end
  end

  #--------------------------------------------------------------------------
  # ● 在真正完成 target_decision 後、playing_action 前保存喬伊起手目標快照。
  #   只抓第一次，避免 SBS 動作序列中途再次 target_decision 時覆蓋。
  #--------------------------------------------------------------------------
  unless method_defined?(:albert_sc3_old_target_decision)
    alias albert_sc3_old_target_decision target_decision
  end

  def target_decision(obj = nil)
    result = albert_sc3_old_target_decision(obj)
    if @albert_sc3_prepare_root_capture && @albert_sc3_root_snapshot == nil
      @albert_sc3_root_snapshot = albert_sc3_snapshot(@targets)
      @albert_sc3_prepare_root_capture = false
    end
    return result
  end

  #--------------------------------------------------------------------------
  # ● 保存舊版單段追擊方法
  #--------------------------------------------------------------------------
  unless method_defined?(:albert_sc3_legacy_try_summon_followups)
    alias albert_sc3_legacy_try_summon_followups albert_cc_try_summon_followups
  end

  #--------------------------------------------------------------------------
  # ● 覆寫 CharacterMechanicCore 的追擊入口
  #--------------------------------------------------------------------------
  def albert_cc_try_summon_followups(joey, trigger_skill, pre_od, original_targets)
    specs = ALBERT_SUMMON_CHAIN3.chain_specs(trigger_skill)

    # 沒有新標籤：完整沿用舊 <summon_followup>。
    if specs.empty?
      return albert_sc3_legacy_try_summon_followups(
        joey, trigger_skill, pre_od, original_targets
      )
    end

    albert_sc3_run_chain(joey, trigger_skill, pre_od, original_targets)

    # 預設不讓同一技能再額外跑舊追擊，避免免費攻擊堆成煙火大會。
    unless ALBERT_SUMMON_CHAIN3::NEW_CHAIN_OVERRIDES_LEGACY
      albert_sc3_legacy_try_summon_followups(
        joey, trigger_skill, pre_od, original_targets
      )
    end
  end

  #--------------------------------------------------------------------------
  # ● 執行最多三段連鎖
  #--------------------------------------------------------------------------
  def albert_sc3_run_chain(joey, trigger_skill, pre_od, original_targets)
    specs = ALBERT_SUMMON_CHAIN3.chain_specs(trigger_skill)
    conditions = ALBERT_SUMMON_CHAIN3.chain_conditions(trigger_skill)
    return if specs.empty?

    used_actor_ids = {}
    chain_targets = original_targets == nil ? [] : original_targets.compact.clone
    chain_start_od = pre_od.to_i

    # 第1段的「上一棒結果」＝喬伊起手技能結果。
    previous_result = albert_sc3_analyze_result(@albert_sc3_root_snapshot)

    stage = 1
    while stage <= ALBERT_SUMMON_CHAIN3::MAX_STAGES
      stage_specs = []
      for spec in specs
        stage_specs.push(spec) if spec[0] == stage
      end

      # 中間少一段就終止，禁止直接 1 → 3 跳號。
      break if stage_specs.empty?

      executed = false

      for spec in stage_specs
        actor_id = spec[1]
        skill_id = spec[2]
        od_need  = spec[3]
        od_cost  = spec[4]

        # 同一召喚物每條鏈最多一次。
        next if used_actor_ids[actor_id]

        summon = ALBERT_CHARACTER_CORE.actor_by_id(actor_id)
        next if summon == nil
        next unless ALBERT_CHARACTER_CORE.actor_in_battle?(summon)
        next unless summon.exist?
        next if summon.active

        if summon.respond_to?(:albert_summon?)
          next unless summon.albert_summon?
        end

        follow_skill = $data_skills[skill_id]
        next if follow_skill == nil

        # OD需求：預設看整條連鎖起手前OD；消耗則一定看目前實際剩餘OD。
        current_od = joey.respond_to?(:overdrive) ? joey.overdrive.to_i : 0
        od_base = ALBERT_SUMMON_CHAIN3::OD_REQUIRE_USES_CHAIN_START ? chain_start_od : current_od
        next if od_base < od_need
        next if current_od < od_cost

        stage_conditions = conditions[stage] == nil ? [] : conditions[stage]

        # 召喚物種類與上一棒結果條件。
        next unless albert_sc3_non_target_conditions_pass?(
          summon, stage_conditions, previous_result
        )

        # 目前目標條件會真正過濾目標，確保同一個目標同時滿足所有條件。
        filtered_targets = albert_sc3_filter_targets(
          summon, chain_targets, stage_conditions
        )
        next if filtered_targets == nil
        next if albert_sc3_has_target_conditions?(stage_conditions) && filtered_targets.empty?

        source_targets = filtered_targets
        if source_targets.empty?
          source_targets = chain_targets
        end

        targets = albert_cc_followup_targets(summon, follow_skill, source_targets)
        next if targets.empty?

        before_snapshot = albert_sc3_snapshot(targets)
        success = albert_cc_execute_summon_followup(summon, follow_skill, targets)
        next unless success

        # 成功後才消耗喬伊OD。
        if od_cost > 0 && joey.respond_to?(:overdrive)
          joey.overdrive -= od_cost
        end

        previous_result = albert_sc3_analyze_result(before_snapshot)
        chain_targets = targets.compact.clone
        used_actor_ids[actor_id] = true
        executed = true

        ALBERT_SUMMON_CHAIN3.log(
          "stage=#{stage} actor=#{actor_id} skill=#{skill_id} " +
          "damage=#{previous_result[:damage]} hit=#{previous_result[:hit]}"
        )

        # 同一階段只選一個候補執行。
        break
      end

      # 任何一段沒有成功，整條鏈立即中止。
      break unless executed
      stage += 1
    end
  end

  #--------------------------------------------------------------------------
  # ● 快照：記錄 HP / State / 疊層
  #--------------------------------------------------------------------------
  def albert_sc3_snapshot(targets)
    result = {}
    list = targets == nil ? [] : targets.compact

    for target in list
      state_ids = albert_sc3_state_ids(target)
      stacks = {}
      for state_id in state_ids
        stacks[state_id] = albert_sc3_stack_count(target, state_id)
      end

      result[target.object_id] = {
        :target => target,
        :hp => target.hp.to_i,
        :states => state_ids,
        :stacks => stacks,
        :dead => target.dead?
      }
    end

    return result
  end

  #--------------------------------------------------------------------------
  # ● 分析一次行動結果
  #--------------------------------------------------------------------------
  def albert_sc3_analyze_result(before_snapshot)
    result = {
      :hit => false,
      :damage => 0,
      :added_states => [],
      :stack_up_states => [],
      :weak => false,
      :critical => false,
      :kill => false
    }

    return result if before_snapshot == nil || before_snapshot.empty?

    before_snapshot.each_value do |data|
      target = data[:target]
      next if target == nil

      before_hp = data[:hp].to_i
      after_hp = target.hp.to_i
      damage = before_hp - after_hp
      result[:damage] += damage if damage > 0

      before_states = data[:states] == nil ? [] : data[:states]
      after_states = albert_sc3_state_ids(target)
      added_states = after_states - before_states
      result[:added_states] |= added_states

      all_state_ids = before_states | after_states
      for state_id in all_state_ids
        before_stack = 0
        if data[:stacks] != nil && data[:stacks][state_id] != nil
          before_stack = data[:stacks][state_id].to_i
        end
        after_stack = albert_sc3_stack_count(target, state_id)
        if after_stack > before_stack
          result[:stack_up_states].push(state_id)
        end
      end
      result[:stack_up_states].uniq!

      begin
        result[:weak] = true if target.respond_to?(:weak) && target.weak
      rescue
      end

      begin
        result[:critical] = true if target.respond_to?(:critical) && target.critical
      rescue
      end

      killed = false
      begin
        killed = true if before_hp > 0 && (target.dead? || target.hp.to_i <= 0)
      rescue
      end
      result[:kill] = true if killed
    end

    result[:hit] = true if result[:damage] > 0
    result[:hit] = true unless result[:added_states].empty?
    result[:hit] = true unless result[:stack_up_states].empty?
    result[:hit] = true if result[:weak]
    result[:hit] = true if result[:critical]
    result[:hit] = true if result[:kill]

    return result
  end

  #--------------------------------------------------------------------------
  # ● 取得 State ID 陣列
  #--------------------------------------------------------------------------
  def albert_sc3_state_ids(target)
    result = []
    begin
      for state in target.states
        next if state == nil
        result.push(state.id)
      end
    rescue
    end
    return result
  end

  #--------------------------------------------------------------------------
  # ● 取得 State 疊層
  #--------------------------------------------------------------------------
  def albert_sc3_stack_count(target, state_id)
    return 0 if target == nil
    begin
      if target.respond_to?(:albert_combo_stack_count)
        return target.albert_combo_stack_count(state_id).to_i
      end
      return target.state?(state_id) ? 1 : 0
    rescue
      return 0
    end
  end

  #--------------------------------------------------------------------------
  # ● 是否含目前目標型條件
  #--------------------------------------------------------------------------
  def albert_sc3_has_target_conditions?(conditions)
    for condition in conditions
      type = condition[0]
      return true if ALBERT_SUMMON_CHAIN3::TARGET_CONDITION_TYPES.include?(type)
    end
    return false
  end

  #--------------------------------------------------------------------------
  # ● 判定召喚物種類與上一棒結果條件
  #--------------------------------------------------------------------------
  def albert_sc3_non_target_conditions_pass?(summon, conditions, previous_result)
    previous_result = {} if previous_result == nil

    for condition in conditions
      type = condition[0]
      value = condition[1]

      # 目前目標型條件交給 filter_targets。
      next if ALBERT_SUMMON_CHAIN3::TARGET_CONDITION_TYPES.include?(type)

      case type
      when "type"
        actual_type = nil
        if summon.respond_to?(:albert_summon_type)
          actual_type = summon.albert_summon_type
        end
        actual_text = actual_type == nil ? "summon" : actual_type.to_s
        return false unless actual_text.downcase == value.to_s.downcase

      when "hit"
        return false unless previous_result[:hit]

      when "damage"
        return false if previous_result[:damage].to_i < value.to_i

      when "added_state"
        states = previous_result[:added_states] || []
        return false unless states.include?(value.to_i)

      when "stack_up"
        states = previous_result[:stack_up_states] || []
        return false unless states.include?(value.to_i)

      when "weak"
        return false unless previous_result[:weak]

      when "critical"
        return false unless previous_result[:critical]

      when "kill"
        return false unless previous_result[:kill]

      else
        # 未知條件視為不成立，避免拼錯字卻偷偷放行。
        ALBERT_SUMMON_CHAIN3.log("unknown condition: #{type}:#{value}")
        return false
      end
    end

    return true
  end

  #--------------------------------------------------------------------------
  # ● 依目前目標條件過濾
  #   所有 target condition 必須由同一個目標同時滿足。
  #--------------------------------------------------------------------------
  def albert_sc3_filter_targets(summon, chain_targets, conditions)
    has_target_condition = albert_sc3_has_target_conditions?(conditions)
    return chain_targets == nil ? [] : chain_targets.compact.clone unless has_target_condition

    targets = []
    if chain_targets != nil
      for target in chain_targets.compact
        targets.push(target) if target.exist?
      end
    end

    # 原目標已死亡時，沿用 CharacterMechanicCore 的重選規則。
    if targets.empty? && ALBERT_CHARACTER_CORE::FOLLOWUP_RETARGET_IF_DEAD
      opponent_unit = summon.actor? ? $game_troop : $game_party
      targets = opponent_unit.existing_members.clone
    end

    for condition in conditions
      type = condition[0]
      value = condition[1]
      next unless ALBERT_SUMMON_CHAIN3::TARGET_CONDITION_TYPES.include?(type)

      filtered = []
      for target in targets
        next if target == nil
        next unless target.exist?

        passed = false
        case type
        when "state"
          passed = target.state?(value.to_i)

        when "not_state"
          passed = !target.state?(value.to_i)

        when "hp_below"
          maxhp = target.maxhp.to_f
          rate = maxhp <= 0.0 ? 0.0 : target.hp.to_f * 100.0 / maxhp
          passed = rate <= value.to_f

        when "hp_above"
          maxhp = target.maxhp.to_f
          rate = maxhp <= 0.0 ? 0.0 : target.hp.to_f * 100.0 / maxhp
          passed = rate >= value.to_f

        when "broken"
          broken_id = 0
          if defined?(ALBERT_CHARACTER_CORE::BROKEN_STATE_ID)
            broken_id = ALBERT_CHARACTER_CORE::BROKEN_STATE_ID
          end
          passed = broken_id > 0 && target.state?(broken_id)
        end

        filtered.push(target) if passed
      end

      targets = filtered
      break if targets.empty?
    end

    return targets
  end
end
