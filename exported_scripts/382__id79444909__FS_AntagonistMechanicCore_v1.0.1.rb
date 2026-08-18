#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_AntagonistMechanicCore v1.0.1
# 【用途】Forest Symphony 專用 Runtime／資料腳本「FS_AntagonistMechanicCore v1.0.1」。
# 【主要機制】屬目前正式專案功能的一部分；具體責任以本頁定義的類別、模組與方法，以及 LoadOrder Guide 為準。
# 【主要影響】Game_Temp、Game_Battler、Game_Enemy、Scene_Battle、ALBERT_ANTAGONIST_CORE
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：MAIN_ACTOR_MAX_ID、LINK_CAN_KILL_DEFAULT、DEBUG。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 7 個 alias／方法包裝，載入順序具有語意；登記 $imported：Albert_AntagonistMechanicCore；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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
# 【Phase47A1｜2026-08-17 實機修正】Enemy524 正式 Note 使用 <law_cycle_interval:3>，
#   舊 parser 只讀 <law_cycle_actions:x>，實機因此 interval=1。現以 interval 為正式標籤，
#   並保留 law_cycle_actions 作舊資料相容 alias；不改 action key／State ID／其他 Boss 規則。
#==============================================================================
#==============================================================================
# ■ Albert_RMVX_AntagonistMechanicCore_v1_0_1.rb
#------------------------------------------------------------------------------
#  RPG Maker VX / RGSS2
#
#  Forest Symphony 專用：反派共用戰鬥機制核心
#
#  目的：
#    1. 觀律：偵測玩家重複使用同技能／同屬性，累積「被解析」State。
#    2. 雙弦：一次選中兩名我方角色後，建立傷害連結。
#    3. 改譜：依目標 Actor ID，自動套用不同的專屬 State。
#    4. 大諧律：Boss 每完成指定次數的有效行動，自動輪替法則 State。
#
#------------------------------------------------------------------------------
# 【建議放置位置】
#
#   YEZ Custom Status Properties
#   BattleUtility_IntegrationFix
#   Albert_RMVX_CharacterMechanicCore
#   Albert_RMVX_MechanicExpansion
#   ↓
#   本腳本
#   ↓
#   BattleStateHUD_Core（若你的 HUD 在更前面也通常可運作）
#   Main
#
#  最低要求：
#   - 放在 Albert_RMVX_MechanicExpansion 之下
#   - 放在 Main 之上
#
#------------------------------------------------------------------------------
# 【重要設計原則】
#
#  本腳本不做「任意複製玩家技能」。
#
#  原因：
#    RPG Maker VX 的技能可能同時牽涉：
#      - Target Select
#      - SBS / Tankentai Action Sequence
#      - ATB
#      - MP / 金錢 / 特殊消耗
#      - JP / 技能等級
#      - Note Tag
#      - 召喚物限定目標
#
#  在戰鬥中直接複製任意技能，看似帥氣，實際上很容易把腳本庫變成
#  一場無人願意認領責任的跨部門會議。
#
#  所以「改譜」採用：
#    Actor ID → 預先設計好的專屬 State／反制 Profile
#
#  這樣可控、可平衡、可顯示，也能和目前 HUD / AI / CSP 共存。
#
#==============================================================================
$imported = {} if $imported == nil
$imported["Albert_AntagonistMechanicCore"] = true

module ALBERT_ANTAGONIST_CORE

  VERSION = "1.0.1"

  #--------------------------------------------------------------------------
  # ● 基本設定
  #--------------------------------------------------------------------------

  # 使用 <observe_main_actors_only> 時，只觀察 Actor ID 1～此值。
  MAIN_ACTOR_MAX_ID = 6

  # 雙弦預設是否可以直接把連結對象殺死。
  # false：最多扣到 1 HP。
  # true ：可以致死。
  LINK_CAN_KILL_DEFAULT = false

  # Debug 模式。
  DEBUG = false

  #--------------------------------------------------------------------------
  # ● 安全取得 Note
  #--------------------------------------------------------------------------
  def self.note(obj)
    return "" if obj == nil
    return obj.note.to_s if obj.respond_to?(:note)
    return ""
  end

  #--------------------------------------------------------------------------
  # ● 取得目前 Scene_Battle 的 Active Battler
  #--------------------------------------------------------------------------
  def self.active_battler
    return nil unless defined?($scene)
    return nil if $scene == nil
    if $scene.respond_to?(:active_battler)
      return $scene.active_battler
    end
    return $scene.instance_variable_get(:@active_battler)
  end

  #--------------------------------------------------------------------------
  # ● 判斷是否為真正正在執行的戰鬥行動
  #
  #    避免 AI 傷害估算、技能預測等假執行流程誤觸反派機制。
  #--------------------------------------------------------------------------
  def self.real_battle_action?(user)
    return false if user == nil
    return false if $game_temp == nil
    return false unless $game_temp.in_battle
    return false unless defined?($scene)
    return false if $scene == nil
    return false unless $scene.is_a?(Scene_Battle)
    active = self.active_battler
    return false if active == nil
    return active.equal?(user)
  end

  #--------------------------------------------------------------------------
  # ● 安全取得 Battler 當前使用技能
  #--------------------------------------------------------------------------
  def self.current_skill(battler)
    return nil if battler == nil
    return nil unless battler.respond_to?(:action)
    action = battler.action
    return nil if action == nil

    if action.respond_to?(:item)
      obj = action.item
      return obj if obj != nil && obj.is_a?(RPG::Skill)
    end

    if action.respond_to?(:skill)
      obj = action.skill
      return obj if obj != nil && obj.is_a?(RPG::Skill)
    end

    if action.respond_to?(:skill_id)
      skill_id = action.skill_id.to_i
      return $data_skills[skill_id] if skill_id > 0
    end

    return nil
  rescue
    return nil
  end

  #============================================================================
  # ■ 一、觀律：偵測重複技能／屬性
  #============================================================================
  #
  # 【Enemy Note】
  #
  #   <observe_repeat_state:120>
  #
  #     玩家重複行為時，累積 State 120。
  #
  #   <observe_same_skill:1>
  #
  #     連續使用同一個技能時，增加 1 層。
  #
  #   <observe_same_element:1>
  #
  #     連續使用相同屬性組合時，增加 1 層。
  #
  #   <observe_stack_both>
  #
  #     若同技能＋同屬性同時成立，兩者相加。
  #     沒寫時只取較高值，避免一回直接爆兩層。
  #
  #   <observe_if_state:150>
  #
  #     只有觀察者自身擁有 State 150 時才啟動觀律。
  #     可重複寫多行，任一指定 State 存在即可啟動（OR）。
  #     適合賽勒斯的階段制戰鬥。
  #
  #   <observe_main_actors_only>
  #
  #     只觀察 Actor ID 1～MAIN_ACTOR_MAX_ID。
  #     不觀察召喚物。
  #
  # 【被解析 State 120 建議】
  #
  #   <max stack 3>
  #
  # 並讓該 State 顯示在目前 BattleStateHUD。
  #
  # 【反制技能 AI】
  #
  #   可直接沿用現有 MechanicExpansion：
  #
  #   <ai_bonus_vs_state 120:400>
  #   <ai_require_state:120>
  #
  #============================================================================

  def self.observer_enemies
    result = []
    return result if $game_troop == nil

    members = nil
    if $game_troop.respond_to?(:existing_members)
      members = $game_troop.existing_members
    else
      members = $game_troop.members
    end

    for enemy in members
      next if enemy == nil
      next if enemy.dead?
      next unless enemy.is_a?(Game_Enemy)
      text = self.note(enemy.enemy)
      if text =~ /<observe_repeat_state\s*:\s*(\d+)\s*>/i
        result.push(enemy)
      end
    end

    return result
  end

  def self.observer_enabled_for?(enemy, actor)
    return false if enemy == nil
    return false if actor == nil
    return false unless actor.respond_to?(:actor?) && actor.actor?

    text = self.note(enemy.enemy)

    required_states = []
    text.scan(/<observe_if_state\s*:\s*(\d+)\s*>/i) do |data|
      required_states.push(data[0].to_i)
    end
    unless required_states.empty?
      condition_met = false
      for required_state in required_states
        if enemy.state?(required_state)
          condition_met = true
          break
        end
      end
      return false unless condition_met
    end

    if text =~ /<observe_main_actors_only\s*>/i
      return false if actor.id.to_i > MAIN_ACTOR_MAX_ID
    end

    return true
  end

  def self.skill_element_key(skill)
    return nil if skill == nil

    elements = []
    if skill.respond_to?(:element_set)
      elements = skill.element_set
    end
    elements = [] if elements == nil

    ids = []
    for element_id in elements
      id = element_id.to_i
      ids.push(id) if id > 0
    end

    ids.sort!
    return nil if ids.empty?
    return ids.join(",")
  rescue
    return nil
  end

  def self.apply_repeat_observation(actor, skill)
    return if actor == nil
    return if skill == nil
    return unless actor.respond_to?(:actor?) && actor.actor?

    observers = self.observer_enemies
    return if observers.empty?

    enabled_observers = []
    for enemy in observers
      enabled_observers.push(enemy) if self.observer_enabled_for?(enemy, actor)
    end
    return if enabled_observers.empty?

    last_skill_id = actor.instance_variable_get(:@albert_ant_last_skill_id)
    last_element_key = actor.instance_variable_get(:@albert_ant_last_element_key)

    current_skill_id = skill.id.to_i
    current_element_key = self.skill_element_key(skill)

    same_skill = (last_skill_id != nil && last_skill_id.to_i == current_skill_id)
    same_element = (
      current_element_key != nil &&
      last_element_key != nil &&
      current_element_key == last_element_key
    )

    # 先更新記憶。就算沒有成功累積，也代表觀察者已看見這次行動。
    actor.instance_variable_set(:@albert_ant_last_skill_id, current_skill_id)
    actor.instance_variable_set(:@albert_ant_last_element_key, current_element_key)

    return unless same_skill || same_element

    # 同一個 State 若有多名觀察者，取本次最高累積值，避免重複疊加。
    pending = {}

    for enemy in enabled_observers
      text = self.note(enemy.enemy)
      next unless text =~ /<observe_repeat_state\s*:\s*(\d+)\s*>/i
      state_id = $1.to_i
      next if state_id <= 0

      skill_amount = 0
      element_amount = 0

      if same_skill && text =~ /<observe_same_skill\s*:\s*(\d+)\s*>/i
        skill_amount = $1.to_i
      end

      if same_element && text =~ /<observe_same_element\s*:\s*(\d+)\s*>/i
        element_amount = $1.to_i
      end

      # 如果只寫 observe_repeat_state，預設同技能重複 +1。
      if text !~ /<observe_same_skill\s*:/i &&
         text !~ /<observe_same_element\s*:/i
        skill_amount = 1 if same_skill
      end

      amount = 0
      if text =~ /<observe_stack_both\s*>/i
        amount = skill_amount + element_amount
      else
        amount = [skill_amount, element_amount].max
      end

      next if amount <= 0

      old_amount = pending[state_id]
      old_amount = 0 if old_amount == nil
      pending[state_id] = [old_amount, amount].max
    end

    pending.each do |state_id, amount|
      amount.times do
        actor.add_state(state_id)
      end
      if DEBUG
        p "[AntagonistCore] #{actor.name} +#{amount} observe stack State #{state_id}"
      end
    end
  end

  #============================================================================
  # ■ 二、雙弦：兩名角色建立傷害連結
  #============================================================================
  #
  # 【Skill Note】
  #
  #   <double_thread:121,40>
  #
  #     成功命中的前兩名 Actor 建立雙弦。
  #     121 = 顯示用 State ID
  #     40  = 實際 HP 損失的 40% 傳給另一人
  #
  #   <double_thread_animation:45>
  #
  #     連結傷害發生時，在另一人身上播放動畫 45。
  #
  #   <double_thread_lethal>
  #
  #     允許連結傷害致死。
  #     沒寫時，預設最多扣到 1 HP。
  #
  # 【重要】
  #
  #   技能必須能選到至少兩名 Actor。
  #   本腳本不改你的 Target Select，只讀取實際成功命中的目標。
  #
  #============================================================================

  def self.double_thread_data(skill)
    return nil if skill == nil
    text = self.note(skill)

    return nil unless text =~ /<double_thread\s*:\s*(\d+)\s*,\s*(-?\d+)\s*>/i
    state_id = $1.to_i
    rate = $2.to_i

    rate = 0 if rate < 0
    rate = 1000 if rate > 1000

    lethal = LINK_CAN_KILL_DEFAULT
    lethal = true if text =~ /<double_thread_lethal\s*>/i

    animation_id = 0
    if text =~ /<double_thread_animation\s*:\s*(\d+)\s*>/i
      animation_id = $1.to_i
    end

    return [state_id, rate, lethal, animation_id]
  end

  #============================================================================
  # ■ 三、改譜：依 Actor ID 套用不同 State
  #============================================================================
  #
  # 【Skill Note】
  #
  #   <rewrite_actor 1:130>
  #   <rewrite_actor 2:131>
  #   <rewrite_actor 3:132>
  #   <rewrite_actor 4:133>
  #   <rewrite_actor 5:134>
  #   <rewrite_actor 6:135>
  #
  #   命中 Actor 1 時，自動加 State 130。
  #   命中 Actor 2 時，自動加 State 131。
  #   依此類推。
  #
  #   <rewrite_default_state:139>
  #
  #   若沒有指定該 Actor ID，改套 State 139。
  #
  #============================================================================

  def self.rewrite_state_for(skill, actor)
    return 0 if skill == nil
    return 0 if actor == nil
    return 0 unless actor.respond_to?(:actor?) && actor.actor?

    text = self.note(skill)

    text.scan(/<rewrite_actor\s+(\d+)\s*:\s*(\d+)\s*>/i) do |data|
      actor_id = data[0].to_i
      state_id = data[1].to_i
      return state_id if actor.id.to_i == actor_id
    end

    if text =~ /<rewrite_default_state\s*:\s*(\d+)\s*>/i
      return $1.to_i
    end

    return 0
  end

  #============================================================================
  # ■ 四、大諧律：Boss 自身行動次數輪替法則 State
  #============================================================================
  #
  # 【Enemy Note】
  #
  #   <law_cycle_states:140,141,142,143>
  #   <law_cycle_interval:3>
#   # 舊資料仍相容 <law_cycle_actions:3>
  #
  #   Boss 每完成 3 次有效行動：
  #     140 → 141 → 142 → 143 → 140 ...
  #
  #   <law_cycle_if_state:151>
  #
  #   只有 Boss 自身擁有 State 151 時，法則輪替才啟動。
  #   適合賽勒斯第二階段。
  #
  #   當 State 151 被移除，所有法則 State 也會一起清除。
  #
  #============================================================================

  def self.law_cycle_states(enemy)
    return [] if enemy == nil
    return [] unless enemy.is_a?(Game_Enemy)

    text = self.note(enemy.enemy)
    return [] unless text =~ /<law_cycle_states\s*:\s*([0-9,\s]+)\s*>/i

    raw = $1.to_s
    result = []
    raw.scan(/\d+/) do |id_text|
      id = id_text.to_i
      result.push(id) if id > 0 && !result.include?(id)
    end

    return result
  end

  def self.law_cycle_actions(enemy)
    return 1 if enemy == nil
    text = self.note(enemy.enemy)

    # Phase47A1：目前正式 Enemy524 使用 <law_cycle_interval:3>。
    # interval 為現行 Authority；actions 保留為舊資料相容 alias。
    if text =~ /<law_cycle_interval\s*:\s*(\d+)\s*>/i
      value = $1.to_i
      return [value, 1].max
    end

    if text =~ /<law_cycle_actions\s*:\s*(\d+)\s*>/i
      value = $1.to_i
      return [value, 1].max
    end

    return 1
  end

  def self.law_cycle_condition_state(enemy)
    return 0 if enemy == nil
    text = self.note(enemy.enemy)

    if text =~ /<law_cycle_if_state\s*:\s*(\d+)\s*>/i
      return $1.to_i
    end

    return 0
  end

end

#==============================================================================
# ■ Game_Temp
#==============================================================================
class Game_Temp
  attr_accessor :albert_ant_pair_targets
  attr_accessor :albert_ant_pair_state_id
  attr_accessor :albert_ant_pair_rate
  attr_accessor :albert_ant_pair_lethal
  attr_accessor :albert_ant_pair_animation_id
end

#==============================================================================
# ■ Game_Battler
#==============================================================================
class Game_Battler

  #--------------------------------------------------------------------------
  # ● 戰鬥開始時清除反派系統暫存
  #--------------------------------------------------------------------------
  def albert_ant_reset_battle_memory
    @albert_ant_last_skill_id = nil
    @albert_ant_last_element_key = nil

    @albert_ant_link_actor_id = nil
    @albert_ant_link_rate = nil
    @albert_ant_link_state_id = nil
    @albert_ant_link_lethal = nil
    @albert_ant_link_animation_id = nil
    @albert_ant_link_guard = false
    @albert_ant_link_clearing = false
  end

  #--------------------------------------------------------------------------
  # ● 取得雙弦對象
  #--------------------------------------------------------------------------
  def albert_ant_link_partner
    return nil unless respond_to?(:actor?) && actor?

    actor_id = @albert_ant_link_actor_id.to_i
    return nil if actor_id <= 0
    return nil if $game_actors == nil

    return $game_actors[actor_id]
  rescue
    return nil
  end

  #--------------------------------------------------------------------------
  # ● 只清除自身的雙弦內部資料
  #--------------------------------------------------------------------------
  def albert_ant_clear_link_raw
    @albert_ant_link_actor_id = nil
    @albert_ant_link_rate = nil
    @albert_ant_link_state_id = nil
    @albert_ant_link_lethal = nil
    @albert_ant_link_animation_id = nil
  end

  #--------------------------------------------------------------------------
  # ● 完整解除雙弦
  #--------------------------------------------------------------------------
  def albert_ant_clear_link(remove_marker = true)
    return unless respond_to?(:actor?) && actor?
    return if @albert_ant_link_clearing

    @albert_ant_link_clearing = true

    partner = albert_ant_link_partner
    state_id = @albert_ant_link_state_id.to_i

    albert_ant_clear_link_raw

    if partner != nil &&
       partner.respond_to?(:actor?) &&
       partner.actor? &&
       partner.instance_variable_get(:@albert_ant_link_actor_id).to_i == self.id.to_i

      partner.instance_variable_set(:@albert_ant_link_clearing, true)
      partner_state_id = partner.instance_variable_get(:@albert_ant_link_state_id).to_i
      partner.albert_ant_clear_link_raw

      if remove_marker &&
         partner_state_id > 0 &&
         partner.state?(partner_state_id)
        partner.remove_state(partner_state_id)
      end

      partner.instance_variable_set(:@albert_ant_link_clearing, false)
    end

    if remove_marker && state_id > 0 && state?(state_id)
      remove_state(state_id)
    end

  ensure
    @albert_ant_link_clearing = false
  end

  #--------------------------------------------------------------------------
  # ● 建立雙弦
  #--------------------------------------------------------------------------
  def albert_ant_set_link(partner, state_id, rate, lethal, animation_id)
    return false unless respond_to?(:actor?) && actor?
    return false if partner == nil
    return false unless partner.respond_to?(:actor?) && partner.actor?
    return false if partner.equal?(self)

    albert_ant_clear_link(true)
    partner.albert_ant_clear_link(true)

    @albert_ant_link_actor_id = partner.id
    @albert_ant_link_rate = rate.to_i
    @albert_ant_link_state_id = state_id.to_i
    @albert_ant_link_lethal = lethal ? true : false
    @albert_ant_link_animation_id = animation_id.to_i

    partner.instance_variable_set(:@albert_ant_link_actor_id, self.id)
    partner.instance_variable_set(:@albert_ant_link_rate, rate.to_i)
    partner.instance_variable_set(:@albert_ant_link_state_id, state_id.to_i)
    partner.instance_variable_set(:@albert_ant_link_lethal, lethal ? true : false)
    partner.instance_variable_set(:@albert_ant_link_animation_id, animation_id.to_i)

    add_state(state_id) if state_id.to_i > 0
    partner.add_state(state_id) if state_id.to_i > 0

    if ALBERT_ANTAGONIST_CORE::DEBUG
      p "[AntagonistCore] Double Thread: #{name} <-> #{partner.name}, rate=#{rate}%"
    end

    return true
  end

  #--------------------------------------------------------------------------
  # ● 雙弦是否仍有效
  #--------------------------------------------------------------------------
  def albert_ant_link_valid?
    return false unless respond_to?(:actor?) && actor?

    partner = albert_ant_link_partner
    if partner == nil || partner.dead?
      albert_ant_clear_link(true)
      return false
    end

    state_id = @albert_ant_link_state_id.to_i
    if state_id > 0
      unless state?(state_id) && partner.state?(state_id)
        albert_ant_clear_link(true)
        return false
      end
    end

    return true
  end

  #--------------------------------------------------------------------------
  # ● 套用雙弦傷害
  #
  #    只讀取「本次真正失去的 HP」，避免 overkill 額外放大。
  #--------------------------------------------------------------------------
  def albert_ant_apply_link_damage(actual_loss)
    return 0 if @albert_ant_link_guard
    return 0 if actual_loss.to_i <= 0
    return 0 unless albert_ant_link_valid?

    partner = albert_ant_link_partner
    return 0 if partner == nil

    rate = @albert_ant_link_rate.to_i
    return 0 if rate <= 0

    mirror_damage = (actual_loss.to_f * rate / 100.0).round
    mirror_damage = 1 if mirror_damage <= 0

    lethal = @albert_ant_link_lethal ? true : false

    unless lethal
      max_loss = [partner.hp.to_i - 1, 0].max
      mirror_damage = [mirror_damage, max_loss].min
    end

    return 0 if mirror_damage <= 0

    partner.instance_variable_set(:@albert_ant_link_guard, true)

    begin
      partner.hp = partner.hp.to_i - mirror_damage

      animation_id = @albert_ant_link_animation_id.to_i
      if animation_id > 0 && partner.respond_to?(:animation_id=)
        partner.animation_id = animation_id
      end
    ensure
      partner.instance_variable_set(:@albert_ant_link_guard, false)
    end

    if ALBERT_ANTAGONIST_CORE::DEBUG
      p "[AntagonistCore] Thread echo: #{name} lost #{actual_loss}, #{partner.name} lost #{mirror_damage}"
    end

    return mirror_damage
  end

  #--------------------------------------------------------------------------
  # ● 傷害後觸發雙弦
  #--------------------------------------------------------------------------
  unless method_defined?(:albert_ant_old_execute_damage)
    alias albert_ant_old_execute_damage execute_damage
  end

  def execute_damage(user)
    before_hp = self.hp.to_i

    result = albert_ant_old_execute_damage(user)

    actual_loss = before_hp - self.hp.to_i
    if actual_loss > 0 &&
       respond_to?(:actor?) &&
       actor? &&
       !@albert_ant_link_guard
      albert_ant_apply_link_damage(actual_loss)
    end

    return result
  end

  #--------------------------------------------------------------------------
  # ● Skill Effect：
  #    - 記錄雙弦命中目標
  #    - 套用改譜 Profile State
  #--------------------------------------------------------------------------
  unless method_defined?(:albert_ant_old_skill_effect)
    alias albert_ant_old_skill_effect skill_effect
  end

  def skill_effect(user, skill)
    result = albert_ant_old_skill_effect(user, skill)

    return result unless ALBERT_ANTAGONIST_CORE.real_battle_action?(user)

    success = true
    begin
      success = false if @missed
      success = false if @evaded
      success = false if @skipped
    rescue
      success = true
    end

    return result unless success
    return result unless respond_to?(:actor?) && actor?

    #----------------------------------------------------------------------
    # 改譜
    #----------------------------------------------------------------------
    rewrite_state_id = ALBERT_ANTAGONIST_CORE.rewrite_state_for(skill, self)
    if rewrite_state_id > 0
      add_state(rewrite_state_id)
    end

    #----------------------------------------------------------------------
    # 雙弦目標收集
    #----------------------------------------------------------------------
    thread_data = ALBERT_ANTAGONIST_CORE.double_thread_data(skill)
    if thread_data != nil &&
       $game_temp != nil &&
       $game_temp.albert_ant_pair_targets != nil

      targets = $game_temp.albert_ant_pair_targets
      targets.push(self) unless targets.include?(self)
    end

    return result
  end

  #--------------------------------------------------------------------------
  # ● Remove State：雙弦標記被移除時，自動解除兩邊連結
  #--------------------------------------------------------------------------
  unless method_defined?(:albert_ant_old_remove_state)
    alias albert_ant_old_remove_state remove_state
  end

  def remove_state(*args)
    state_id = args[0].to_i
    linked_state_id = @albert_ant_link_state_id.to_i

    result = albert_ant_old_remove_state(*args)

    if respond_to?(:actor?) &&
       actor? &&
       linked_state_id > 0 &&
       state_id == linked_state_id &&
       !state?(linked_state_id) &&
       !@albert_ant_link_clearing
      albert_ant_clear_link(true)
    end

    # Boss 的 law_cycle_if_state 被移除時，立刻清除法則。
    if is_a?(Game_Enemy) &&
       respond_to?(:albert_ant_law_condition_state_id)
      condition_id = albert_ant_law_condition_state_id
      if condition_id > 0 &&
         state_id == condition_id &&
         !state?(condition_id)
        albert_ant_disable_law_cycle
      end
    end

    return result
  end

  #--------------------------------------------------------------------------
  # ● Add State：
  #    Boss 取得 law_cycle_if_state 時，立刻啟動第一個法則。
  #--------------------------------------------------------------------------
  unless method_defined?(:albert_ant_old_add_state)
    alias albert_ant_old_add_state add_state
  end

  def add_state(*args)
    state_id = args[0].to_i

    result = albert_ant_old_add_state(*args)

    if is_a?(Game_Enemy) &&
       respond_to?(:albert_ant_law_condition_state_id) &&
       !instance_variable_get(:@albert_ant_law_refresh_guard)

      condition_id = albert_ant_law_condition_state_id

      if condition_id > 0 &&
         state_id == condition_id &&
         state?(condition_id)

        instance_variable_set(:@albert_ant_law_refresh_guard, true)
        begin
          albert_ant_initialize_law_cycle
        ensure
          instance_variable_set(:@albert_ant_law_refresh_guard, false)
        end
      end
    end

    return result
  end

end

#==============================================================================
# ■ Game_Enemy：大諧律法則輪替
#==============================================================================
class Game_Enemy < Game_Battler

  def albert_ant_law_states
    return ALBERT_ANTAGONIST_CORE.law_cycle_states(self)
  end

  def albert_ant_law_interval
    return ALBERT_ANTAGONIST_CORE.law_cycle_actions(self)
  end

  def albert_ant_law_condition_state_id
    return ALBERT_ANTAGONIST_CORE.law_cycle_condition_state(self)
  end

  def albert_ant_law_condition_met?
    condition_id = albert_ant_law_condition_state_id
    return true if condition_id <= 0
    return state?(condition_id)
  end

  def albert_ant_clear_law_states
    states = albert_ant_law_states
    for state_id in states
      remove_state(state_id) if state?(state_id)
    end
  end

  def albert_ant_initialize_law_cycle
    states = albert_ant_law_states
    return false if states.empty?
    return false unless albert_ant_law_condition_met?

    @albert_ant_law_refresh_guard = true

    begin
      albert_ant_clear_law_states

      @albert_ant_law_index = 0
      @albert_ant_law_action_count = 0
      @albert_ant_law_active = true

      add_state(states[0])
    ensure
      @albert_ant_law_refresh_guard = false
    end

    if ALBERT_ANTAGONIST_CORE::DEBUG
      p "[AntagonistCore] #{name} law start: State #{states[0]}"
    end

    return true
  end

  def albert_ant_disable_law_cycle
    return if @albert_ant_law_refresh_guard

    @albert_ant_law_refresh_guard = true

    begin
      albert_ant_clear_law_states
      @albert_ant_law_active = false
      @albert_ant_law_index = 0
      @albert_ant_law_action_count = 0
    ensure
      @albert_ant_law_refresh_guard = false
    end
  end

  def albert_ant_after_completed_action
    states = albert_ant_law_states
    return if states.empty?

    unless albert_ant_law_condition_met?
      albert_ant_disable_law_cycle if @albert_ant_law_active
      return
    end

    unless @albert_ant_law_active
      albert_ant_initialize_law_cycle
      return
    end

    @albert_ant_law_action_count = 0 if @albert_ant_law_action_count == nil
    @albert_ant_law_action_count += 1

    interval = albert_ant_law_interval
    return if @albert_ant_law_action_count < interval

    @albert_ant_law_action_count = 0

    old_index = @albert_ant_law_index.to_i
    new_index = (old_index + 1) % states.size

    old_state_id = states[old_index]
    new_state_id = states[new_index]

    @albert_ant_law_refresh_guard = true

    begin
      remove_state(old_state_id) if state?(old_state_id)
      add_state(new_state_id)
      @albert_ant_law_index = new_index
    ensure
      @albert_ant_law_refresh_guard = false
    end

    if ALBERT_ANTAGONIST_CORE::DEBUG
      p "[AntagonistCore] #{name} law rotate: #{old_state_id} -> #{new_state_id}"
    end
  end

end

#==============================================================================
# ■ Scene_Battle
#==============================================================================
class Scene_Battle < Scene_Base

  #--------------------------------------------------------------------------
  # ● 戰鬥開始：
  #    - 清除 Actor 觀律記憶／雙弦暫存
  #    - 啟動無條件的 Boss 法則循環
  #--------------------------------------------------------------------------
  unless method_defined?(:albert_ant_old_start)
    alias albert_ant_old_start start
  end

  def start(*args)
    result = albert_ant_old_start(*args)

    if $game_actors != nil && $data_actors != nil
      for i in 1...$data_actors.size
        next if $data_actors[i] == nil
        actor = $game_actors[i]
        actor.albert_ant_reset_battle_memory if
          actor != nil && actor.respond_to?(:albert_ant_reset_battle_memory)
      end
    end

    if $game_troop != nil
      for enemy in $game_troop.members
        next if enemy == nil
        next unless enemy.respond_to?(:albert_ant_initialize_law_cycle)
        next if enemy.albert_ant_law_states.empty?
        next unless enemy.albert_ant_law_condition_met?
        enemy.albert_ant_initialize_law_cycle
      end
    end

    return result
  end

  #--------------------------------------------------------------------------
  # ● 技能行動：
  #    - 行動前準備雙弦目標收集
  #    - 行動後建立雙弦
  #    - 行動後執行觀律記憶
  #--------------------------------------------------------------------------
  unless method_defined?(:albert_ant_old_execute_action_skill)
    alias albert_ant_old_execute_action_skill execute_action_skill
  end

  def execute_action_skill(*args)
    battler = @active_battler
    skill = ALBERT_ANTAGONIST_CORE.current_skill(battler)
    thread_data = ALBERT_ANTAGONIST_CORE.double_thread_data(skill)

    if $game_temp != nil
      $game_temp.albert_ant_pair_targets = []
      if thread_data != nil
        $game_temp.albert_ant_pair_state_id = thread_data[0]
        $game_temp.albert_ant_pair_rate = thread_data[1]
        $game_temp.albert_ant_pair_lethal = thread_data[2]
        $game_temp.albert_ant_pair_animation_id = thread_data[3]
      else
        $game_temp.albert_ant_pair_state_id = nil
        $game_temp.albert_ant_pair_rate = nil
        $game_temp.albert_ant_pair_lethal = nil
        $game_temp.albert_ant_pair_animation_id = nil
      end
    end

    result = nil

    begin
      result = albert_ant_old_execute_action_skill(*args)

      #--------------------------------------------------------------------
      # 建立雙弦
      #--------------------------------------------------------------------
      if thread_data != nil &&
         $game_temp != nil &&
         $game_temp.albert_ant_pair_targets != nil

        targets = $game_temp.albert_ant_pair_targets.compact
        targets.uniq!

        if targets.size >= 2
          actor_a = targets[0]
          actor_b = targets[1]

          actor_a.albert_ant_set_link(
            actor_b,
            thread_data[0],
            thread_data[1],
            thread_data[2],
            thread_data[3]
          )
        end
      end

      #--------------------------------------------------------------------
      # 觀律
      #--------------------------------------------------------------------
      if battler != nil &&
         battler.respond_to?(:actor?) &&
         battler.actor? &&
         skill != nil

        ALBERT_ANTAGONIST_CORE.apply_repeat_observation(battler, skill)
      end

      return result

    ensure
      if $game_temp != nil
        $game_temp.albert_ant_pair_targets = nil
        $game_temp.albert_ant_pair_state_id = nil
        $game_temp.albert_ant_pair_rate = nil
        $game_temp.albert_ant_pair_lethal = nil
        $game_temp.albert_ant_pair_animation_id = nil
      end
    end
  end

  #--------------------------------------------------------------------------
  # ● Enemy 完成有效行動後，更新法則循環
  #
  #    你的 MechanicExpansion 也 alias 過 execute_action。
  #    本腳本放在它下方，因此會安全接在 alias chain 最外層。
  #--------------------------------------------------------------------------
  unless method_defined?(:albert_ant_old_execute_action)
    alias albert_ant_old_execute_action execute_action
  end

  def execute_action(*args)
    battler = @active_battler
    valid_before = false

    begin
      valid_before = (
        battler != nil &&
        battler.action != nil &&
        battler.action.valid?
      )
    rescue
      valid_before = (battler != nil)
    end

    result = albert_ant_old_execute_action(*args)

    if valid_before &&
       battler != nil &&
       battler.is_a?(Game_Enemy) &&
       battler.respond_to?(:albert_ant_after_completed_action)

      battler.albert_ant_after_completed_action
    end

    return result
  end

end

#==============================================================================
# ■ 使用範例總表
#==============================================================================
#
#------------------------------------------------------------------------------
# 1. 莉瑟／觀律者
#------------------------------------------------------------------------------
#
# Enemy Note：
#
#   <observe_repeat_state:120>
#   <observe_same_skill:1>
#   <observe_same_element:1>
#
# State 120：
#
#   <max stack 3>
#
# 反制技能：
#
#   <ai_bonus_vs_state 120:400>
#   <ai_require_state:120>
#   <bonus_vs_state 120:50>
#
#------------------------------------------------------------------------------
# 2. 赫薩／雙弦
#------------------------------------------------------------------------------
#
# Skill Note：
#
#   <double_thread:121,40>
#   <double_thread_animation:45>
#
# 技能需實際命中至少兩名 Actor。
#
#------------------------------------------------------------------------------
# 3. 諾維亞／改譜師
#------------------------------------------------------------------------------
#
# Skill Note：
#
#   <rewrite_actor 1:130>
#   <rewrite_actor 2:131>
#   <rewrite_actor 3:132>
#   <rewrite_actor 4:133>
#   <rewrite_actor 5:134>
#   <rewrite_actor 6:135>
#   <rewrite_default_state:139>
#
#------------------------------------------------------------------------------
# 4. 賽勒斯／大諧律
#------------------------------------------------------------------------------
#
# Enemy Note：
#
#   <observe_repeat_state:120>
#   <observe_same_skill:1>
#   <observe_same_element:1>
#   <observe_if_state:150>
#
#   <law_cycle_states:140,141,142,143>
#   <law_cycle_interval:3>
#   # 舊資料仍相容 <law_cycle_actions:3>
#   <law_cycle_if_state:151>
#
# 建議：
#   State 150 = 第一階段「全知儀」
#   State 151 = 第二階段「大諧律」
#
# HP 70% 以下時，用 Troop Event：
#   移除 State 150
#   加入 State 151
#
# HP 35% 以下時，用 Troop Event：
#   移除 State 151
#   加入 State 152「失奏」
#
# 由於移除 State 151 時，本腳本會自動清除所有 law_cycle_states，
# 所以第三階段不會殘留上一階段的法則。
#
#==============================================================================
