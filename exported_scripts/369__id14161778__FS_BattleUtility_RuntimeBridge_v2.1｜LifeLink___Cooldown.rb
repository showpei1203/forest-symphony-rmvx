#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_BattleUtility_RuntimeBridge v2.1｜LifeLink / Cooldown
# 【用途】Forest Symphony 戰鬥 Utility Runtime Bridge；保留 LifeLink、回復阻擋、SkillDelay／Target 等相容橋接。Phase 27 起不再保存寄生種子傷害公式。
# 【主要機制】通常透過 alias／class reopen 包裝前方實作；它不是可任意搬動的獨立功能，需維持在被修正腳本之後。
# 【主要影響】Game_Battler、Game_Actor、RPG::BaseItem、Scene_Battle、ALBERT_BATTLE_UTILITY_FIX
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：LIFE_LINK_INCLUDE_MAIN_ACTOR、LIFE_LINK_INCLUDE_SUMMONS、LIFE_LINK_MAIN_ACTOR_MAX_ID、LIFE_LINK_SUMMON_ACTOR_IDS、LIFE_LINK_ONLY_SAME_STATE。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 2 個 alias／方法包裝，載入順序具有語意；登記 $imported：TankentaiATB；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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
# ■ Albert_RMVX_BattleUtility_IntegrationFix_v2.rb
#------------------------------------------------------------------------------
#  RPG Maker VX / RGSS2
#
#  放置位置：
#    YEZ Custom Status Properties
#    回復不能ステート
#    KGC_AddEquipmentOptions
#    行動封印
#    H87-Skill Delay
#    PopUp Generale
#    YERD_TargetEffects / Custom Target Select
#    其他相關戰鬥補丁
#    Albert_RMVX_BattleUtility_IntegrationFix_v2.rb
#    Main
#
#  修正與整合：
#    1. 修正 YEZ Custom Status Properties 的 LEAVE 觸發錯誤。
#       原本使用 $data_states[id]，應為 $data_states[i]。
#
#    2. 修正 CSP 的 ANTI HP/MP REGEN/DEGEN 判斷：
#       原本使用 or，導致只寫其中一種格式時仍可能無效。
#
#    3. 讓「回復不能ステート」能阻止：
#       - CSP HP/MP regen
#       - KGC / 裝備自動 HP/MP 回復
#
#    4. 修正 H87 Skill Delay：
#       - battle delay / step delay 不再被 turn delay 判斷擋掉。
#       - ATB 中 turn delay 不會在使用當下立刻少算一回。
#       - 冷卻遞減改用 keys.clone，避免迭代中刪 hash 的不穩定。
#
#    5. 修正 Yanfly Custom Target Select：
#       - multifoe 的 @rmultifoe typo。
#
#    6. 行動封印小防呆：
#       - @commander nil 時不報錯。
#
#    7. 額外新增 CSP Lunatic effect：
#       - <close effect: 寄生種子>
#       - <react effect: 生命共同體>
#
#==============================================================================

module ALBERT_BATTLE_UTILITY_FIX
  # Phase 27：寄生種子數值 Authority 已統一到 FS_StateEffects_Integration。
  # 本頁只保留 CSP CLOSE effect 的 dispatch／其他 Utility bridge。

  #--------------------------------------------------------------------------
  # 生命共同體：承傷分攤。
  #--------------------------------------------------------------------------
  LIFE_LINK_INCLUDE_MAIN_ACTOR = true
  LIFE_LINK_INCLUDE_SUMMONS = true
  LIFE_LINK_MAIN_ACTOR_MAX_ID = 6
  LIFE_LINK_SUMMON_ACTOR_IDS = [7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18]

  # true：
  #   只找同樣擁有該 State 的隊友一起分攤。
  #
  # false：
  #   依上面的主角 / 召喚物條件分攤。
  #
  # 建議：生命共同體這類狀態通常設 true，比較好控制。
  LIFE_LINK_ONLY_SAME_STATE = true

  #--------------------------------------------------------------------------
  # ATB Skill Delay：
  # H87 原本會在使用技能的同一個 execute_action 結尾立刻 scale_turn。
  # 因此 turn delay 會少算 1。這裡用 +1 抵銷。
  #--------------------------------------------------------------------------
  ATB_TURN_DELAY_FIX = true
end

#==============================================================================
# ■ Game_Battler
#==============================================================================

class Game_Battler
  #--------------------------------------------------------------------------
  # * 回復不能判定防呆
  #--------------------------------------------------------------------------
  def albert_hp_heal_blocked?
    return false unless respond_to?(:rx_hp_cannot_heal)
    return rx_hp_cannot_heal
  end

  def albert_mp_heal_blocked?
    return false unless respond_to?(:rx_mp_cannot_heal)
    return rx_mp_cannot_heal
  end

  #--------------------------------------------------------------------------
  # * 修正 CSP remove_states_auto
  #   不呼叫原 CSP 版本，避免 $data_states[id] 的錯誤 LEAVE 觸發。
  #--------------------------------------------------------------------------
  if method_defined?(:custom_status_effects)
    def remove_states_auto
      clear_action_results

      unless @hidden
        for state in states
          custom_status_effects(state, "WHILE")
        end
      end

      for state_id in @state_turns.keys.clone
        state = $data_states[state_id]
        next if state == nil

        if @state_turns[state_id] > 0
          @state_turns[state_id] -= 1
        else
          custom_status_effects(state, "LEAVE") unless @hidden
          if rand(100) < state.auto_release_prob
            remove_state(state_id)
            @removed_states.push(state_id) unless @removed_states.include?(state_id)
          end
        end
      end
    end
  end

  #--------------------------------------------------------------------------
  # * 修正 CSP hpslip：
  #   - ANTI HP DEGEN / ANTI_HP_DEGEN 任一存在即可阻止扣血。
  #   - ANTI HP REGEN / ANTI_HP_REGEN 任一存在即可阻止回血。
  #   - 回復不能ステート會阻止 regen。
  #--------------------------------------------------------------------------
  if method_defined?(:hpslip)
    def hpslip
      return if dead?
      n = 0

      unless trait?("ANTI HP DEGEN") || trait?("ANTI_HP_DEGEN")
        for state in states
          percent = 100
          for i in 1..stack(state)
            percent += state.slip_per[:hpdegen]
          end
          n += maxhp * percent / 100.0
        end

        for state in states
          for i in 1..stack(state)
            n += state.slip_set[:hpdegen]
          end
        end
      end

      unless trait?("ANTI HP REGEN") || trait?("ANTI_HP_REGEN") || albert_hp_heal_blocked?
        for state in states
          percent = 100
          for i in 1..stack(state)
            percent += state.slip_per[:hpregen]
          end
          n -= maxhp * percent / 100.0
        end

        for state in states
          for i in 1..stack(state)
            n -= state.slip_set[:hpregen]
          end
        end
      end

      self.hp -= [Integer(n), self.hp - 1].min
    end
  end

  #--------------------------------------------------------------------------
  # * 修正 CSP mpslip：
  #--------------------------------------------------------------------------
  if method_defined?(:mpslip)
    def mpslip
      return if dead?
      n = 0

      unless trait?("ANTI MP DEGEN") || trait?("ANTI_MP_DEGEN")
        for state in states
          percent = 100
          for i in 1..stack(state)
            percent += state.slip_per[:mpdegen]
          end
          n += maxmp * percent / 100.0
        end

        for state in states
          for i in 1..stack(state)
            n += state.slip_set[:mpdegen]
          end
        end
      end

      unless trait?("ANTI MP REGEN") || trait?("ANTI_MP_REGEN") || albert_mp_heal_blocked?
        for state in states
          percent = 100
          for i in 1..stack(state)
            percent += state.slip_per[:mpregen]
          end
          n -= maxmp * percent / 100.0
        end

        for state in states
          for i in 1..stack(state)
            n -= state.slip_set[:mpregen]
          end
        end
      end

      self.mp -= Integer(n)
    end
  end

  #--------------------------------------------------------------------------
  # * 寄生種子
  #   Phase 27：實作由後載入 FS_StateEffects_Integration v3.3 提供。
  #   本頁保留 custom_status_effects 的名稱 dispatch，不再保存第二份公式。
  #--------------------------------------------------------------------------

  #--------------------------------------------------------------------------
  # * 生命共同體目標群
  #--------------------------------------------------------------------------
  def albert_csp_life_link_members(effect_state)
    members = []

    if actor?
      for actor in $game_party.members
        next if actor == nil
        next if actor.dead?
        next unless actor.exist?

        if ALBERT_BATTLE_UTILITY_FIX::LIFE_LINK_ONLY_SAME_STATE
          next unless effect_state != nil && actor.state?(effect_state.id)
        else
          ok = false
          if ALBERT_BATTLE_UTILITY_FIX::LIFE_LINK_INCLUDE_MAIN_ACTOR
            ok = true if actor.id <= ALBERT_BATTLE_UTILITY_FIX::LIFE_LINK_MAIN_ACTOR_MAX_ID
          end
          if ALBERT_BATTLE_UTILITY_FIX::LIFE_LINK_INCLUDE_SUMMONS
            ok = true if ALBERT_BATTLE_UTILITY_FIX::LIFE_LINK_SUMMON_ACTOR_IDS.include?(actor.id)
            ok = true if actor.respond_to?(:albert_summon?) && actor.albert_summon?
          end
          next unless ok
        end

        members.push(actor)
      end
    else
      # 敵方生命共同體：同 troop 且同狀態。
      for enemy in $game_troop.members
        next if enemy == nil
        next if enemy.dead?
        next unless enemy.exist?
        next unless effect_state != nil && enemy.state?(effect_state.id)
        members.push(enemy)
      end
    end

    members.push(self) unless members.include?(self)
    return members
  end

  #--------------------------------------------------------------------------
  # * 生命共同體效果
  #   建議狀態 Note：
  #     <react effect: 生命共同體>
  #
  #   注意：這是在 execute_damage 前改寫 @hp_damage。
  #--------------------------------------------------------------------------
  def albert_csp_life_link(effect_state)
    return if effect_state == nil
    return if @hp_damage == nil
    return if @hp_damage <= 0

    members = albert_csp_life_link_members(effect_state)
    return if members == nil || members.size <= 1

    total = @hp_damage.to_i
    share = [total / members.size, 1].max
    rest = total - share * members.size

    # 目標自己稍後會由 execute_damage 正常扣除。
    @hp_damage = share + [rest, 0].max

    for member in members
      next if member == self
      dmg = [share, member.hp - 1].min
      next if dmg <= 0
      member.hp -= dmg
      member.albert_csp_popup_damage(dmg)
    end
  end

  #--------------------------------------------------------------------------
  # * 安全顯示傷害 popup
  #--------------------------------------------------------------------------
  def albert_csp_popup_damage(value)
    begin
      return unless $scene.is_a?(Scene_Battle)
      return if $scene.spriteset == nil
      if actor?
        if $scene.spriteset.respond_to?(:actor_sprites) &&
           $scene.spriteset.respond_to?(:pos_in_sprite_array)
          index = $scene.spriteset.pos_in_sprite_array(self.id)
          sprite = $scene.spriteset.actor_sprites[index]
          sprite.damage_pop(value) if sprite != nil && sprite.respond_to?(:damage_pop)
        end
      else
        if $scene.spriteset.respond_to?(:enemy_sprites)
          sprite = $scene.spriteset.enemy_sprites[self.index]
          sprite.damage_pop(value) if sprite != nil && sprite.respond_to?(:damage_pop)
        end
      end
    rescue
    end
  end

  def albert_csp_popup_recovery(value)
    begin
      return unless $scene.is_a?(Scene_Battle)
      return if $scene.spriteset == nil
      text = value.to_s
      if actor?
        if $scene.spriteset.respond_to?(:actor_sprites) &&
           $scene.spriteset.respond_to?(:pos_in_sprite_array)
          index = $scene.spriteset.pos_in_sprite_array(self.id)
          sprite = $scene.spriteset.actor_sprites[index]
          sprite.damage_pop(text) if sprite != nil && sprite.respond_to?(:damage_pop)
        end
      else
        if $scene.spriteset.respond_to?(:enemy_sprites)
          sprite = $scene.spriteset.enemy_sprites[self.index]
          sprite.damage_pop(text) if sprite != nil && sprite.respond_to?(:damage_pop)
        end
      end
    rescue
    end
  end

  #--------------------------------------------------------------------------
  # * 擴充 CSP custom_status_effects
  #--------------------------------------------------------------------------
  if method_defined?(:custom_status_effects) &&
     !method_defined?(:albert_battle_utility_fix_custom_status_effects)
    alias albert_battle_utility_fix_custom_status_effects custom_status_effects
  end

  def custom_status_effects(effect_state, type = nil)
    if effect_state != nil
      effects = []
      case type
      when "APPLY"; effects = effect_state.apply_effect
      when "ERASE"; effects = effect_state.erase_effect
      when "LEAVE"; effects = effect_state.leave_effect
      when "REACT"; effects = effect_state.react_effect
      when "SHOCK"; effects = effect_state.shock_effect
      when "BEGIN"; effects = effect_state.begin_effect
      when "WHILE"; effects = effect_state.while_effect
      when "CLOSE"; effects = effect_state.close_effect
      end

      for effect in effects
        case effect
        when "寄生種子", "LEECH SEED", "Leech Seed"
          albert_csp_leech_seed(effect_state)
        when "生命共同體", "LIFE LINK", "Life Link"
          albert_csp_life_link(effect_state)
        else
          # pass to original
        end
      end
    end

    if respond_to?(:albert_battle_utility_fix_custom_status_effects)
      albert_battle_utility_fix_custom_status_effects(effect_state, type)
    end
  end
end

#==============================================================================
# ■ Game_Actor
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # * 自動回復整合：
  #   讓回復不能可以阻止 KGC_AddEquipmentOptions / 原本自動 HP 回復。
  #--------------------------------------------------------------------------
  def do_auto_recovery
    return if dead?

    if auto_hp_recover && !albert_hp_heal_blocked?
      if respond_to?(:auto_hp_recover_value)
        self.hp += auto_hp_recover_value
      else
        self.hp += maxhp / 20
      end
    end

    if respond_to?(:auto_mp_recover) && auto_mp_recover && !albert_mp_heal_blocked?
      if respond_to?(:auto_mp_recover_value)
        self.mp += auto_mp_recover_value
      end
    end
  end
end

#==============================================================================
# ■ H87 Skill Delay 修正
#==============================================================================

class Game_Battler
  if method_defined?(:add_turn_skill)
    def add_turn_skill(skill)
      @turn_skills = {} if @turn_skills == nil
      value = skill.turn_delay
      if ALBERT_BATTLE_UTILITY_FIX::ATB_TURN_DELAY_FIX &&
         $imported != nil && $imported["TankentaiATB"]
        value += 1
      end
      @turn_skills[skill.id] = value
    end
  end

  if method_defined?(:scale_turn)
    def scale_turn
      @turn_skills = {} if @turn_skills == nil
      for skill_id in @turn_skills.keys.clone
        @turn_skills[skill_id] -= 1 if @turn_skills[skill_id] > 0
        @turn_skills.delete(skill_id) if @turn_skills[skill_id] <= 0
      end
    end
  end

  if method_defined?(:scale_battle)
    def scale_battle
      @battle_skills = {} if @battle_skills == nil
      for skill_id in @battle_skills.keys.clone
        @battle_skills[skill_id] -= 1
        @battle_skills.delete(skill_id) if @battle_skills[skill_id] <= 0
      end
    end
  end

  if method_defined?(:scale_step)
    def scale_step
      @step_skills = {} if @step_skills == nil
      for skill_id in @step_skills.keys.clone
        @step_skills[skill_id] -= 1
        if @step_skills[skill_id] <= 0
          @step_skills.delete(skill_id)
          show_popup($data_skills[skill_id]) if defined?(H87_Delay) && H87_Delay.allow_popup?
        end
      end
    end
  end

  if method_defined?(:no_charged)
    def no_charged(skill)
      return false if skill == nil
      @turn_skills = {} if @turn_skills == nil
      @battle_skills = {} if @battle_skills == nil
      @step_skills = {} if @step_skills == nil

      return true if skill.turn_delay > 0 &&
                     @turn_skills.include?(skill.id) &&
                     @turn_skills[skill.id].to_i > 0
      return true if skill.battle_delay > 0 &&
                     @battle_skills.include?(skill.id) &&
                     @battle_skills[skill.id].to_i > 0
      return true if skill.step_delay > 0 &&
                     @step_skills.include?(skill.id) &&
                     @step_skills[skill.id].to_i > 0
      return false
    end
  end
end

#==============================================================================
# ■ Yanfly Custom Target Select 修正
#==============================================================================

class RPG::BaseItem
  if method_defined?(:multifoe)
    def multifoe
      yanfly_cache_cts if @multifoe == nil
      return @multifoe
    end
  end
end

#==============================================================================
# ■ 行動封印小防呆
#==============================================================================

class Scene_Battle
  if method_defined?(:commanding?) &&
     !method_defined?(:albert_battle_utility_fix_commanding?)
    alias albert_battle_utility_fix_commanding? commanding?
  end

  def commanding?
    return false if @commander == nil
    if @commander.respond_to?(:a_seal?) &&
       @commander.a_seal? &&
       @commander.s_seal? &&
       @commander.g_seal? &&
       @commander.i_seal?
      return false
    end
    if respond_to?(:albert_battle_utility_fix_commanding?)
      return albert_battle_utility_fix_commanding?
    end
    return true
  end
end
