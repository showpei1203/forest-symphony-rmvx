#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：YEZ Custom Status Properties
# 【用途】強化 State：動畫、堆疊、能力增減、HP/MP Regen/Degen、Traits，以及 Lunatic 自訂生命週期效果。FS 目前亦在 custom_status_effects 內含多個專案自訂效果。
# 【來源】Yanfly Engine Zealous - Custom Status Properties；Last Date Updated: 2010.02.07。
# 【State Notetag】<animation n>：狀態動畫；<max stack n>：最大堆疊；<stat +n>/<stat -n>/<stat n%>：maxhp/maxmp/atk/def/spi/agi/hit/eva/cri/odds 等能力變化；<hp degen n>/<hp degen n%>/<mp degen...> 與 regen 版本：回合末固定值或 MaxHP/MaxMP 百分比恢復／流失。
# 【Trait】<trait: phrase> 支援 super guard、pharmacology、fast attack、dual attack、prevent critical、half mp cost、double exp gain、auto hp recover、anti hp degen、anti hp regen、anti mp degen、anti mp regen、immortal。Trait 本身不可任意翻成中文，因 phrase 是 Runtime Key。
# 【Lunatic Effect Notetag】<apply effect: phrase> 附加時；<erase effect: phrase> 主動移除；<leave effect: phrase> 時間到；<react effect: phrase> 受傷前；<shock effect: phrase> 受傷後；<begin effect: phrase> 回合開始；<while effect: phrase> 行動回合中；<close effect: phrase> 回合結束。多個 phrase 依出現順序執行。
# 【Lunatic API】state_origin(effect_state) 取得該 State 原始施放者；若無來源則回傳 battler 自身。自訂效果集中在 Game_Battler#custom_status_effects 的 case 區。
# 【主要設定】ANIMATION_SOUND／ANIMATION_FLASH 控制 State Animation 聲音／全畫面閃光；ANI_ACTOR_SHOW／ANI_ACTOR_ZOOM 控制 Actor 上的狀態動畫；REMAINED_RULES：0不變、1重設持續回合、2累加回合；UPDATE_ADD／UPDATE_REM 控制 MaxHP/MP 改變時同步調整當前值；STEP_UPDATE_STATES／STEPS_PER_ST_TURNS 控制步行減少 State 回合。
# 【FS 自訂效果】本頁 custom_status_effects 內已有「火系開／關、Clear、ATK Degen、Siphon、Invincible、Talk、傷害加總、破防、狂怒+/-、靈魂共享」等 case。這些字串是實際 Runtime Effect Key／遊戲資料，不能為文件中文化任意改名。
# 【相容性】原作者標示與 YEZ Battle Engine Zealous 相容，並含 Job System Skill Levels、Core Fixes、Aggro/AI 等歷史相容。後方 FS StateEffects／SoulMark 等仍可能再包 skill_effect／State 流程。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 維護說明集中於腳本最前方；程式識別字、Notetag、Script Call、Action Key 不可翻譯改名。
# 2. 原作者、版本、Credits、License、網址等來源資訊保留；翻譯前 byte-exact 原稿另存 Phase 17 Archive。
# 3. 範例只列原文件或既有程式能直接證實的入口，不捏造 API。
# 4. 本輪除註解／說明外不修改任何可執行 Ruby；載入順序仍以 FS LoadOrder Guide／Authority Map 為準。
#==============================================================================
#===============================================================================
# 
# Yanfly Engine Zealous - Custom Status Properties
# Last Date Updated: 2010.02.07
# 
# 
# 
#===============================================================================
# -----------------------------------------------------------------------------
#===============================================================================
# -----------------------------------------------------------------------------
# 
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# <animation n>
# 
# <max stack n>有用
# 
# <stat +n> <stat -n> <stat n%>
# 
# <hp degen n> <hp degen n%> or <mp degen n> <mp degen n%>
# <hp regen n> <hp regen n%> or <mp regen n> <mp regen n%>
# 
# <trait: phrase>
# 
#===============================================================================
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
#===============================================================================

$imported = {} if $imported == nil
$imported["CustomStatusPropertiesZeal"] = true

module YEZ
  module STATE
    
    ANIMATION_SOUND = false
    ANIMATION_FLASH = false
    
    ANI_ACTOR_SHOW = true
    ANI_ACTOR_ZOOM = 100
    
    REMAINED_RULES = 1
    
    UPDATE_ADD = true  # 附加狀態時同步更新 HP／MP。
    UPDATE_REM = true  # 移除狀態時同步更新 HP／MP。
    
    STEP_UPDATE_STATES = true  # 啟用／停用步行時的狀態回合更新。
    STEPS_PER_ST_TURNS = 3     # 每減少 1 回合所需步數。
    
  end
end

#===============================================================================
# ----------------------------------------------------------------------------
# 
# 
#   <apply effect: phrase> - 附加 State 時。
#   <erase effect: phrase> - 主動移除 State 時。
#   <leave effect: phrase> - State 持續時間耗盡時。
#   <react effect: phrase> - 承受傷害前。
#   <shock effect: phrase> - 承受傷害後。
#   <begin effect: phrase> - 每回合開始時。
#   <while effect: phrase> - 該 Battler 的行動回合中。
#   <close effect: phrase> - 每回合結束時。
# 
# 
# state_origin(effect_state)
# 
#===============================================================================

class Game_Battler
  
  #--------------------------------------------------------------------------
  # 新增方法：custom_status_effects
  #--------------------------------------------------------------------------
  def custom_status_effects(effect_state, type = nil)
    return if effect_state == nil
    case type
    when "APPLY"; effects = effect_state.apply_effect
    when "ERASE"; effects = effect_state.erase_effect
    when "LEAVE"; effects = effect_state.leave_effect
    when "REACT"; effects = effect_state.react_effect
    when "SHOCK"; effects = effect_state.shock_effect
    when "BEGIN"; effects = effect_state.begin_effect
    when "WHILE"; effects = effect_state.while_effect
    when "CLOSE"; effects = effect_state.close_effect
    else; return
    end
    return unless effects != []
    for effect in effects
      case effect
      #----------------------------------------------------------------------
      # 從這裡開始編輯自訂效果。
      #----------------------------------------------------------------------
      when "火系開"
        $game_switches[473] = true

      when "火系關"
        $game_switches[473] = false

      when "Clear"
        for state in states
          next if state == effect_state
          remove_state(state.id)
        end
        
      when "ATK Degen"
        dmg = [state_origin(effect_state).atk, self.hp - 1].min
        self.hp -= dmg
        
      when "Siphon"
        next if state_origin(effect_state).dead?
        dmg = [self.maxhp / 10, self.hp - 1].min
        self.hp -= dmg
        state_origin(effect_state).hp += dmg
        
      when "Invincible"
        @hp_damage = [@hp_damage, 0].min
        @mp_damage = [@mp_damage, 0].min
      
      when "Talk"
        $game_message.texts.push("被附加")
        state_origin(effect_state).force_damage = 100
        
      when "傷害加總"
        $game_variables[302] += @hp_damage
        
      when "破防"
       self.animation_id = 232
       
      when "狂怒+"
       self.atk -= $game_variables[302]
       $game_variables[302] = 0
       $game_variables[302] = self.overdrive / 10
       self.atk += $game_variables[302]
       
      when "狂怒-"
       self.atk -= $game_variables[302]
       $game_variables[302] = 0
       
      when "靈魂共享"
        # 取得當前隊伍成員
        targets = []
 
        # 遍歷隊伍成員，手動篩選符合條件的角色
        $game_party.members.each do |actor|
         if actor.id == 1 || actor.id >= 7
          targets.push(actor)  # 加入符合條件的角色
         end
        end

        Game_Interpreter_Self.new(23)#傷害分攤顯示圖片
        # 統一對這些角色 HP 進行扣減
        @hp_damage = @hp_damage / targets.size  # 這裡的數值可以自行更改
        targets.each do |actor|
        actor.hp -= @hp_damage
        sprite = $scene.spriteset.actor_sprites[$scene.spriteset.pos_in_sprite_array(actor.id)]
        sprite.damage_pop(@hp_damage)
        $scene.spriteset.set_action(true, $scene.spriteset.pos_in_sprite_array(actor.id), "HURT")
       
        end
      #----------------------------------------------------------------------
      # 自訂效果編輯區到此結束。
      #----------------------------------------------------------------------
      end
    end
  end
  
end

#===============================================================================
#===============================================================================

module YEZ
  module REGEXP
    module STATE
      
      CUSTOM_APPLY = /<(?:APPLY_EFFECT|apply effect):[ ](.*)>/i
      CUSTOM_ERASE = /<(?:ERASE_EFFECT|erase effect):[ ](.*)>/i
      CUSTOM_LEAVE = /<(?:LEAVE_EFFECT|leave effect):[ ](.*)>/i
      CUSTOM_REACT = /<(?:REACT_EFFECT|react effect):[ ](.*)>/i
      CUSTOM_SHOCK = /<(?:SHOCK_EFFECT|shock effect):[ ](.*)>/i
      CUSTOM_BEGIN = /<(?:BEGIN_EFFECT|begin effect):[ ](.*)>/i
      CUSTOM_WHILE = /<(?:WHILE_EFFECT|while effect):[ ](.*)>/i
      CUSTOM_CLOSE = /<(?:CLOSE_EFFECT|close effect):[ ](.*)>/i
      
      STATEANI = /<(?:STATE_ANIMATION|state ani|animation|ani)[ ]*(\d+)>/i
      STAT_SET = /<\s*(MAXHP|MAXMP|HP|MP|ATK|DEF|SPI|AGI|HIT|EVA|CRI|ODDS)?\s*([\+\-]\d+)>/i
      STAT_PER = /<\s*(MAXHP|MAXMP|HP|MP|ATK|DEF|SPI|AGI|HIT|EVA|CRI|ODDS)?\s*(\d+)([%％])>/i
      MAXSTACK = /<(?:MAX_STACK|max stack)[ ]*(\d+)>/i
      TRAITS   = /<(?:TRAITS|trait):[ ](.*)>/i
      
      SLIP_SET = /<\s*(HP|MP)?\s*[ ]\s*(DEGEN|REGEN)?\s*(\d+)>/i
      SLIP_PER = /<\s*(HP|MP)?\s*[ ]\s*(DEGEN|REGEN)?\s*(\d+)([%％])>/i
      
    end
  end
end

#===============================================================================
#===============================================================================

class RPG::State
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def yez_cache_state_csp
    @max_stack = 1; @traits = []; @state_animation = 0
    @stat_set ={ :hp => 0, :mp => 0, :atk => 0, :def => 0, :spi => 0,
                 :agi => 0, :hit => 0, :eva => 0, :cri => 0, :odds => 0}
    @stat_per ={ :hp => 100, :mp => 100, :atk => 100, :def => 100, :spi => 100,
                 :agi => 100, :hit => 100, :eva => 100, :cri => 100, :odds => 100}
    @slip_set ={ :hpdegen => 0, :hpregen => 0, :mpdegen => 0, :mpregen => 0}
    @slip_per ={ :hpdegen => 0, :hpregen => 0, :mpdegen => 0, :mpregen => 0}
    
    @apply_effect = []; @erase_effect = []; @leave_effect = []; 
    @react_effect = []; @shock_effect = []; @begin_effect = []; 
    @while_effect = []; @close_effect = [];
    
    self.note.split(/[\r\n]+/).each { |line|
      case line
      #---
      when YEZ::REGEXP::STATE::CUSTOM_APPLY; @apply_effect.push($1.to_s)
      when YEZ::REGEXP::STATE::CUSTOM_ERASE; @erase_effect.push($1.to_s)
      when YEZ::REGEXP::STATE::CUSTOM_LEAVE; @leave_effect.push($1.to_s)
      when YEZ::REGEXP::STATE::CUSTOM_REACT; @react_effect.push($1.to_s)
      when YEZ::REGEXP::STATE::CUSTOM_SHOCK; @shock_effect.push($1.to_s)
      when YEZ::REGEXP::STATE::CUSTOM_BEGIN; @begin_effect.push($1.to_s)
      when YEZ::REGEXP::STATE::CUSTOM_WHILE; @while_effect.push($1.to_s)
      when YEZ::REGEXP::STATE::CUSTOM_CLOSE; @close_effect.push($1.to_s)
      #---
      when YEZ::REGEXP::STATE::STATEANI
        @state_animation = $1.to_i
      when YEZ::REGEXP::STATE::MAXSTACK
        @max_stack = [$1.to_i, 1].max
      when YEZ::REGEXP::STATE::TRAITS
        @traits.push($1.upcase)
      #---
      when YEZ::REGEXP::STATE::STAT_SET
        case $1.upcase
        when "HP","MAXHP"; @stat_set[:hp] = $2.to_i
        when "MP","MAXMP"; @stat_set[:mp] = $2.to_i
        when "ATK"; @stat_set[:atk] = $2.to_i
        when "DEF"; @stat_set[:def] = $2.to_i
        when "SPI"; @stat_set[:spi] = $2.to_i
        when "AGI"; @stat_set[:agi] = $2.to_i
        when "HIT"; @stat_set[:hit] = $2.to_i
        when "EVA"; @stat_set[:eva] = $2.to_i
        when "CRI"; @stat_set[:cri] = $2.to_i
        when "ODDS"; @stat_set[:odds] = $2.to_i
        end
      #---
      when YEZ::REGEXP::STATE::STAT_PER
        case $1.upcase
        when "HP","MAXHP"; @stat_per[:hp] = $2.to_i
        when "MP","MAXMP"; @stat_per[:mp] = $2.to_i
        when "ATK"; @stat_per[:atk] = $2.to_i
        when "DEF"; @stat_per[:def] = $2.to_i
        when "SPI"; @stat_per[:spi] = $2.to_i
        when "AGI"; @stat_per[:agi] = $2.to_i
        when "HIT"; @stat_per[:hit] = $2.to_i
        when "EVA"; @stat_per[:eva] = $2.to_i
        when "CRI"; @stat_per[:cri] = $2.to_i
        when "ODDS"; @stat_per[:odds] = $2.to_i
        end
      #---
      when YEZ::REGEXP::STATE::SLIP_SET
        case $1.upcase
        when "HP"
          case $2.upcase
          when "DEGEN"; @slip_set[:hpdegen] = $3.to_i
          when "REGEN"; @slip_set[:hpregen] = $3.to_i
          end
          @traits.push("HPSLIP")
        when "MP"
          case $2.upcase
          when "DEGEN"; @slip_set[:mpdegen] = $3.to_i
          when "REGEN"; @slip_set[:mpregen] = $3.to_i
          end
          @traits.push("MPSLIP")
        end
      #---
      when YEZ::REGEXP::STATE::SLIP_PER
        case $1.upcase
        when "HP"
          case $2.upcase
          when "DEGEN"; @slip_per[:hpdegen] = $3.to_i
          when "REGEN"; @slip_per[:hpregen] = $3.to_i
          end
          @traits.push("HPSLIP")
        when "MP"
          case $2.upcase
          when "DEGEN"; @slip_per[:mpdegen] = $3.to_i
          when "REGEN"; @slip_per[:mpregen] = $3.to_i
          end
          @traits.push("MPSLIP")
        end
      #---
      end
    } # end self.note.split
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：apply_effect
  #--------------------------------------------------------------------------
  def apply_effect
    yez_cache_state_csp if @apply_effect == nil
    return @apply_effect
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：erase_effect
  #--------------------------------------------------------------------------
  def erase_effect
    yez_cache_state_csp if @erase_effect == nil
    return @erase_effect
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：leave_effect
  #--------------------------------------------------------------------------
  def leave_effect
    yez_cache_state_csp if @leave_effect == nil
    return @leave_effect
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：react_effect
  #--------------------------------------------------------------------------
  def react_effect
    yez_cache_state_csp if @react_effect == nil
    return @react_effect
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：shock_effect
  #--------------------------------------------------------------------------
  def shock_effect
    yez_cache_state_csp if @shock_effect == nil
    return @shock_effect
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：begin_effect
  #--------------------------------------------------------------------------
  def begin_effect
    yez_cache_state_csp if @begin_effect == nil
    return @begin_effect
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：while_effect
  #--------------------------------------------------------------------------
  def while_effect
    yez_cache_state_csp if @while_effect == nil
    return @while_effect
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：close_effect
  #--------------------------------------------------------------------------
  def close_effect
    yez_cache_state_csp if @close_effect == nil
    return @close_effect
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：state_animation
  #--------------------------------------------------------------------------
  def state_animation
    yez_cache_state_csp if @state_animation == nil
    return @state_animation
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：max_stack
  #--------------------------------------------------------------------------
  def max_stack
    yez_cache_state_csp if @max_stack == nil
    return @max_stack
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：traits
  #--------------------------------------------------------------------------
  def traits
    yez_cache_state_csp if @traits == nil
    return @traits
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：stat_set
  #--------------------------------------------------------------------------
  def stat_set
    yez_cache_state_csp if @stat_set == nil
    return @stat_set
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：stat_per
  #--------------------------------------------------------------------------
  def stat_per
    yez_cache_state_csp if @stat_per == nil
    return @stat_per
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：slip_set
  #--------------------------------------------------------------------------
  def slip_set
    yez_cache_state_csp if @slip_set == nil
    return @slip_set
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：slip_per
  #--------------------------------------------------------------------------
  def slip_per
    yez_cache_state_csp if @slip_per == nil
    return @slip_per
  end
  
end

#===============================================================================
#===============================================================================

class Game_Battler

  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  attr_accessor :state_stack
  attr_accessor :state_animation
  
  #--------------------------------------------------------------------------
  # alias 方法： clear_extra_values
  #--------------------------------------------------------------------------
  alias clear_extra_values_csp clear_extra_values unless $@
  def clear_extra_values
    clear_extra_values_csp
    @stack_stack = {}
    @state_origin = {}
    @origin_side = {}
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： clear_sprite_effects
  #--------------------------------------------------------------------------
  alias clear_sprite_effects_csp clear_sprite_effects unless $@
  def clear_sprite_effects
    clear_sprite_effects_csp
    @state_animation = 0
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：reload_state_animation
  #--------------------------------------------------------------------------
  def reload_state_animation
    @state_animation = 0
    return if actor? and !YEZ::STATE::ANI_ACTOR_SHOW
    for state in states
      next unless state.state_animation > 0
      @state_animation = state.state_animation
      break
    end
  end
  
  #--------------------------------------------------------------------------
  # 覆寫方法：state?
  #--------------------------------------------------------------------------
  def state?(state_id)
    return states.include?($data_states[state_id])
  end
  
  #--------------------------------------------------------------------------
  # 覆寫方法：apply_state_changes
  #--------------------------------------------------------------------------
  def apply_state_changes(obj)
    plus = obj.plus_state_set
    minus = obj.minus_state_set
    if obj.is_a?(RPG::Skill) or obj.is_a?(RPG::Item)
      plus += $scene.active_battler.plus_state_set if obj.physical_attack
    end
    for i in plus
      next if state_resist?(i)
      next if dead?
      next if i == 1 and @immortal
      if state?(i)
        remained_rules(i, obj)
        @remained_states.push(i) unless @remained_states.include?(i)
        next
      end
      if rand(100) < state_probability(i)
        add_state(i)
        @added_states.push(i) unless @added_states.include?(i)
      end
    end
    for i in minus
      next unless state?(i)
      remove_state(i)
      @removed_states.push(i) unless @removed_states.include?(i)
    end
    for i in @added_states & @removed_states
      @added_states.delete(i)
      @removed_states.delete(i)
    end
    for i in @added_states
      apply_state_turns(obj, i) if $imported["JobSystemSkillLevels"]
    end
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：remained_rules
  #--------------------------------------------------------------------------
  def remained_rules(state_id, obj = nil)
    state = $data_states[state_id]
    return if state == nil
    hpdif = self.maxhp
    mpdif = self.maxmp
    increase_stack(state_id)
    case YEZ::STATE::REMAINED_RULES
    when 0
      return
    when 1
      @state_turns[state_id] = state.hold_turn
    when 2
      @state_turns[state_id] = state.hold_turn if !@state_turns.include?(state_id)
      @state_turns[state_id] += state.hold_turn
    end
    if !dead? and YEZ::STATE::UPDATE_ADD
      self.hp += maxhp - hpdif
      self.mp += maxmp - mpdif
    end
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： skill_test
  #--------------------------------------------------------------------------
  alias skill_test_csp skill_test unless $@
  def skill_test(user, skill)
    for state_id in skill.plus_state_set
      state = $data_states[state_id]
      next if state == nil
      return true if state.max_stack > self.stack(state)
    end
    return skill_test_csp(user, skill)
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： add_state
  #--------------------------------------------------------------------------
  alias add_state_csp add_state unless $@
  def add_state(state_id)
    create_state_origin(state_id)
    custom_status_effects($data_states[state_id], "APPLY")
    hpdif = maxhp
    mpdif = maxmp
    increase_stack(state_id)
    add_state_csp(state_id)
    if !dead? and YEZ::STATE::UPDATE_ADD
      self.hp += maxhp - hpdif
      self.mp += maxmp - mpdif
    end
    reload_state_animation
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： remove_state
  #--------------------------------------------------------------------------
  alias remove_state_csp remove_state unless $@
  def remove_state(state_id)
    custom_status_effects($data_states[state_id], "ERASE")
    hpdif = maxhp
    mpdif = maxmp
    reset_stack(state_id)
    remove_state_csp(state_id)
    if !dead? and YEZ::STATE::UPDATE_REM
      self.hp += maxhp - hpdif
      self.mp += maxmp - mpdif
    end
    @removed_states.push(1) if dead? and !@removed_states.include?(1)
    clear_state_origin(state_id)
    reload_state_animation
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： remove_states_auto
  #--------------------------------------------------------------------------
  alias remove_states_auto_csp remove_states_auto unless $@
  def remove_states_auto
    clear_action_results
    unless @hidden
      for state in states; custom_status_effects(state, "WHILE"); end
      for i in @state_turns.keys.clone
        custom_status_effects($data_states[id], "LEAVE") if @state_turns[i] == 0
      end
    end
    remove_states_auto_csp
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： execute_damage
  #--------------------------------------------------------------------------
  alias execute_damage_csp execute_damage unless $@
  def execute_damage(user)
    for state in states; custom_status_effects(state, "REACT"); end
    execute_damage_csp(user)
    for state in states; custom_status_effects(state, "SHOCK"); end
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：create_state_origin
  #--------------------------------------------------------------------------
  def create_state_origin(state_id)
    @state_origin = {} if @state_origin == nil
    @origin_side = {} if @origin_side == nil
    return unless $scene.is_a?(Scene_Battle)
    return if $scene.active_battler == nil
    if $scene.active_battler.actor?
      @state_origin[state_id] = $scene.active_battler.id
      @origin_side[state_id] = 0
    else
      @state_origin[state_id] = $scene.active_battler.index
      @origin_side[state_id] = 1
    end
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：clear_state_origin
  #--------------------------------------------------------------------------
  def clear_state_origin(state_id)
    @state_origin = {} if @state_origin == nil
    @origin_side = {} if @origin_side == nil
    @state_origin.delete(state_id)
    @origin_side.delete(state_id)
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：state_origin
  #--------------------------------------------------------------------------
  def state_origin(state_id)
    state_id = state_id.id if state_id.is_a?(RPG::State)
    @state_origin = {} if @state_origin == nil
    @origin_side = {} if @origin_side == nil
    if @origin_side.include?(state_id)
      if @origin_side[state_id] == 0
        return $game_actors[@state_origin[state_id]]
      else
        return $game_troop.members[@state_origin[state_id]]
      end
    else
      return self
    end
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：reset_state_origins
  #--------------------------------------------------------------------------
  def reset_state_origins
    @state_origin = {}
    @origin_side = {}
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：stack
  #--------------------------------------------------------------------------
  def stack(state)
    @state_stack = {} if @state_stack == nil
    state = $data_states[state] if state.is_a?(Integer)
    return 0 if state == nil
    return 0 if !state?(state.id)
    n = 1
    m = @state_stack.include?(state.id) ? @state_stack[state.id] : 0
    return [n, m].max
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：increase_stack
  #--------------------------------------------------------------------------
  def increase_stack(state_id, stack_up = 1)
    state = $data_states[state_id]
    return if state == nil
    @state_stack = {} if @state_stack == nil
    @state_stack[state_id] = 0 if @state_stack[state_id] == nil
    return if @state_stack[state_id] > state.max_stack
    @state_stack[state_id] += stack_up
    @state_stack[state_id] = [@state_stack[state_id], state.max_stack].min
    @added_states.push(state_id) unless state_id == 1
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：reset_stack
  #--------------------------------------------------------------------------
  def reset_stack(state_id)
    @state_stack = {} if @state_stack == nil
    @state_stack.delete(state_id)
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： maxhp
  #--------------------------------------------------------------------------
  alias maxhp_csp maxhp unless $@
  def maxhp
    n = maxhp_csp
    for state in states
      percent = 100
      for i in 1..stack(state); percent += state.stat_per[:hp] - 100; end
      n = n * percent / 100.0
    end
    for state in states;
      for i in 1..stack(state); n += state.stat_set[:hp]; end
    end
    n = [[Integer(n), 1].max, maxhp_limit].min
    @hp = [@hp, n].min
    return Integer(n)
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： maxmp
  #--------------------------------------------------------------------------
  alias maxmp_csp maxmp unless $@
  def maxmp
    n = maxmp_csp
    for state in states
      percent = 100
      for i in 1..stack(state); percent += state.stat_per[:mp] - 100; end
      n = n * percent / 100.0
    end
    for state in states;
      for i in 1..stack(state); n += state.stat_set[:mp]; end
    end
    limit = (defined?(maxmp_limit) ? maxmp_limit : 9999)
    n = [[Integer(n), 1].max, limit].min
    @mp = [@mp, n].min
    return Integer(n)
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： atk
  #--------------------------------------------------------------------------
  alias atk_csp atk unless $@
  def atk
    n = atk_csp
    for state in states
      percent = 100
      for i in 2..stack(state); percent += state.atk_rate - 100; end
      n = n * percent / 100.0
    end
    for state in states
      percent = 100
      for i in 1..stack(state); percent += state.stat_per[:atk] - 100; end
      n = n * percent / 100.0
    end
    for state in states;
      for i in 1..stack(state); n += state.stat_set[:atk]; end
    end
    limit = (defined?(parameter_limit) ? parameter_limit : 999)
    n = [[Integer(n), 1].max, limit].min
    return Integer(n)
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： def
  #--------------------------------------------------------------------------
  alias def_csp def unless $@
  def def
    n = def_csp
    for state in states
      percent = 100
      for i in 2..stack(state); percent += state.def_rate - 100; end
      n = n * percent / 100.0
    end
    for state in states
      percent = 100
      for i in 1..stack(state); percent += state.stat_per[:def] - 100; end
      n = n * percent / 100.0
    end
    for state in states;
      for i in 1..stack(state); n += state.stat_set[:def]; end
    end
    limit = (defined?(parameter_limit) ? parameter_limit : 999)
    n = [[Integer(n), 1].max, limit].min
    return Integer(n)
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： spi
  #--------------------------------------------------------------------------
  alias spi_csp spi unless $@
  def spi
    n = spi_csp
    for state in states
      percent = 100
      for i in 2..stack(state); percent += state.spi_rate - 100; end
      n = n * percent / 100.0
    end
    for state in states
      percent = 100
      for i in 1..stack(state); percent += state.stat_per[:spi] - 100; end
      n = n * percent / 100.0
    end
    for state in states;
      for i in 1..stack(state); n += state.stat_set[:spi]; end
    end
    limit = (defined?(parameter_limit) ? parameter_limit : 999)
    n = [[Integer(n), 1].max, limit].min
    return Integer(n)
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： agi
  #--------------------------------------------------------------------------
  alias agi_csp agi unless $@
  def agi
    n = agi_csp
    for state in states
      percent = 100
      for i in 2..stack(state); percent += state.agi_rate - 100; end
      n = n * percent / 100.0
    end
    for state in states
      percent = 100
      for i in 1..stack(state); percent += state.stat_per[:agi] - 100; end
      n = n * percent / 100.0
    end
    for state in states;
      for i in 1..stack(state); n += state.stat_set[:agi]; end
    end
    limit = (defined?(parameter_limit) ? parameter_limit : 999)
    n = [[Integer(n), 1].max, limit].min
    return Integer(n)
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：trait?
  #--------------------------------------------------------------------------
  def trait?(phrase)
    for state in states; return true if state.traits.include?(phrase); end
    return false
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： super_guard
  #--------------------------------------------------------------------------
  alias super_guard_battler_csp super_guard unless $@
  def super_guard
    traits = ["SUPER_GUARD", "SUPER GUARD", "SUPERGUARD"]
    for state in states; return true if (state.traits & traits) != []; end
    return super_guard_battler_csp
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： fast_attack
  #--------------------------------------------------------------------------
  alias fast_attack_battler_csp fast_attack unless $@
  def fast_attack
    traits = ["FAST_ATTACK", "FAST ATTACK", "FASTATTACK"]
    for state in states; return true if (state.traits & traits) != []; end
    return fast_attack_battler_csp
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： dual_attack
  #--------------------------------------------------------------------------
  alias dual_attack_battler_csp dual_attack unless $@
  def dual_attack
    traits = ["DUAL_ATTACK", "DUAL ATTACK", "DUALATTACK"]
    for state in states; return true if (state.traits & traits) != []; end
    return dual_attack_battler_csp
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： prevent_critical
  #--------------------------------------------------------------------------
  alias prevent_critical_battler_csp prevent_critical unless $@
  def prevent_critical
    traits = ["PREVENT_CRITICAL", "PREVENT CRITICAL", "PREVENTCRITICAL",
      "PREVENT_CRIT", "PREVENT CRIT"]
    for state in states; return true if (state.traits & traits) != []; end
    return prevent_critical_battler_csp
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： half_mp_cost
  #--------------------------------------------------------------------------
  alias half_mp_cost_battler_csp half_mp_cost unless $@
  def half_mp_cost
    traits = ["HALF_MP_COST", "HALF MP COST", "HALFMPCOST", "HALF_MP",
      "HALF MP", "HALFMP"]
    for state in states; return true if (state.traits & traits) != []; end
    return half_mp_cost_battler_csp
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：immortal
  #--------------------------------------------------------------------------
  def immortal
    traits = ["IMMORTAL", "CANNOT DIE", "IMMORTALITY"]
    for state in states; return true if (state.traits & traits) != []; end
    return @immortal
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： slip_damage_effect
  #--------------------------------------------------------------------------
  alias slip_damage_effect_csp slip_damage_effect unless $@
  def slip_damage_effect
    slip_damage_effect_csp
    hpslip if trait?("HPSLIP")
    mpslip if trait?("MPSLIP")
    for state in states; custom_status_effects(state, "CLOSE"); end
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：hpslip
  #--------------------------------------------------------------------------
  def hpslip
    return if dead?
    n = 0
    if !trait?("ANTI HP DEGEN") or !trait?("ANTI_HP_DEGEN")
      for state in states
        percent = 100
        for i in 1..stack(state); percent += state.slip_per[:hpdegen]; end
        n += maxhp * percent / 100.0
      end
      for state in states;
        for i in 1..stack(state); n += state.slip_set[:hpdegen]; end
      end
    end
    if !trait?("ANTI HP REGEN") or !trait?("ANTI_HP_REGEN")
      for state in states
        percent = 100
        for i in 1..stack(state); percent += state.slip_per[:hpregen]; end
        n -= maxhp * percent / 100.0
      end
      for state in states;
        for i in 1..stack(state); n -= state.slip_set[:hpregen]; end
      end
    end
    self.hp -= [Integer(n), self.hp - 1].min
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：mpslip
  #--------------------------------------------------------------------------
  def mpslip
    return if dead?
    n = 0
    if !trait?("ANTI MP DEGEN") or !trait?("ANTI_MP_DEGEN")
      for state in states
        percent = 100
        for i in 1..stack(state); percent += state.slip_per[:mpdegen]; end
        n += maxmp * percent / 100.0
      end
      for state in states;
        for i in 1..stack(state); n += state.slip_set[:mpdegen]; end
      end
    end
    if !trait?("ANTI MP REGEN") or !trait?("ANTI_MP_REGEN")
      for state in states
        percent = 100
        for i in 1..stack(state); percent += state.slip_per[:mpregen]; end
        n -= maxmp * percent / 100.0
      end
      for state in states;
        for i in 1..stack(state); n -= state.slip_set[:mpregen]; end
      end
    end
    self.mp -= Integer(n)
  end
  
end

#===============================================================================
#===============================================================================

class Game_Actor

  #--------------------------------------------------------------------------
  # alias 方法： hit
  #--------------------------------------------------------------------------
  alias hit_actor_csp hit unless $@
  def hit
    n = hit_actor_csp
    for state in states
      percent = 100
      for i in 1..stack(state); percent += state.stat_per[:hit] - 100; end
      n = n * percent / 100.0
    end
    for state in states;
      for i in 1..stack(state); n += state.stat_set[:hit]; end
    end
    n = [Integer(n), 0].max
    return Integer(n)
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： eva
  #--------------------------------------------------------------------------
  alias eva_actor_csp eva unless $@
  def eva
    n = eva_actor_csp
    for state in states
      percent = 100
      for i in 1..stack(state); percent += state.stat_per[:eva] - 100; end
      n = n * percent / 100.0
    end
    for state in states;
      for i in 1..stack(state); n += state.stat_set[:eva]; end
    end
    n = [Integer(n), 0].max
    return Integer(n)
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： cri
  #--------------------------------------------------------------------------
  alias cri_actor_csp cri unless $@
  def cri
    n = cri_actor_csp
    for state in states
      percent = 100
      for i in 1..stack(state); percent += state.stat_per[:cri] - 100; end
      n = n * percent / 100.0
    end
    for state in states;
      for i in 1..stack(state); n += state.stat_set[:cri]; end
    end
    n = [Integer(n), 0].max
    return Integer(n)
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： odds
  #--------------------------------------------------------------------------
  alias odds_actor_csp odds unless $@
  def odds
    n = odds_actor_csp
    for state in states
      percent = 100
      for i in 1..stack(state); percent += state.stat_per[:odds] - 100; end
      n = n * percent / 100.0
    end
    for state in states;
      for i in 1..stack(state); n += state.stat_set[:odds]; end
    end
    n = [Integer(n), 1].max
    return Integer(n)
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： super_guard
  #--------------------------------------------------------------------------
  alias super_guard_actor_csp super_guard unless $@
  def super_guard
    return true if trait?("SUPER_GUARD")
    return true if trait?("SUPER GUARD")
    return true if trait?("SUPERGUARD")
    return super_guard_actor_csp
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： pharmacology
  #--------------------------------------------------------------------------
  alias pharmacology_actor_csp pharmacology unless $@
  def pharmacology
    return true if trait?("PHARMACOLOGY")
    return true if trait?("ITEM_BOOST")
    return true if trait?("ITEM BOOST")
    return pharmacology_actor_csp
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： fast_attack
  #--------------------------------------------------------------------------
  alias fast_attack_actor_csp fast_attack unless $@
  def fast_attack
    return true if trait?("FAST_ATTACK")
    return true if trait?("FAST ATTACK")
    return true if trait?("FASTATTACK")
    return fast_attack_actor_csp
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： dual_attack
  #--------------------------------------------------------------------------
  alias dual_attack_actor_csp dual_attack unless $@
  def dual_attack
    return true if trait?("DUAL_ATTACK")
    return true if trait?("DUAL ATTACK")
    return true if trait?("DUALATTACK")
    return dual_attack_actor_csp
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： prevent_critical
  #--------------------------------------------------------------------------
  alias prevent_critical_actor_csp prevent_critical unless $@
  def prevent_critical
    return true if trait?("PREVENT_CRITICAL")
    return true if trait?("PREVENT CRITICAL")
    return true if trait?("PREVENTCRITICAL")
    return true if trait?("PREVENT_CRIT")
    return true if trait?("PREVENT CRIT")
    return prevent_critical_actor_csp
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： half_mp_cost
  #--------------------------------------------------------------------------
  alias half_mp_cost_actor_csp half_mp_cost unless $@
  def half_mp_cost
    return true if trait?("HALF_MP_COST")
    return true if trait?("HALF MP COST")
    return true if trait?("HALFMPCOST")
    return true if trait?("HALF_MP")
    return true if trait?("HALF MP")
    return true if trait?("HALFMP")
    return half_mp_cost_actor_csp
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： double_exp_gain
  #--------------------------------------------------------------------------
  alias double_exp_gain_actor_csp double_exp_gain unless $@
  def double_exp_gain
    return true if trait?("DOUBLE_EXP_GAIN")
    return true if trait?("DOUBLE EXP GAIN")
    return true if trait?("DOUBLE EXP")
    return double_exp_gain_actor_csp
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： auto_hp_recover
  #--------------------------------------------------------------------------
  alias auto_hp_recover_actor_csp auto_hp_recover unless $@
  def auto_hp_recover
    return true if trait?("AUTO_HP_RECOVER")
    return true if trait?("AUTO HP RECOVER")
    return auto_hp_recover_actor_csp
  end
  
end

#===============================================================================
#===============================================================================

class Game_Enemy < Game_Battler
  
  #--------------------------------------------------------------------------
  # alias 方法： hit
  #--------------------------------------------------------------------------
  alias hit_enemy_csp hit unless $@
  def hit
    n = hit_enemy_csp
    for state in states
      percent = 100
      for i in 1..stack(state); percent += state.stat_per[:hit] - 100; end
      n = n * percent / 100.0
    end
    for state in states;
      for i in 1..stack(state); n += state.stat_set[:hit]; end
    end
    n = [Integer(n), 0].max
    return Integer(n)
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： eva
  #--------------------------------------------------------------------------
  alias eva_enemy_csp eva unless $@
  def eva
    n = eva_enemy_csp
    for state in states
      percent = 100
      for i in 1..stack(state); percent += state.stat_per[:eva] - 100; end
      n = n * percent / 100.0
    end
    for state in states;
      for i in 1..stack(state); n += state.stat_set[:eva]; end
    end
    n = [Integer(n), 0].max
    return Integer(n)
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： cri
  #--------------------------------------------------------------------------
  alias cri_enemy_csp cri unless $@
  def cri
    n = cri_enemy_csp
    for state in states
      percent = 100
      for i in 1..stack(state); percent += state.stat_per[:cri] - 100; end
      n = n * percent / 100.0
    end
    for state in states;
      for i in 1..stack(state); n += state.stat_set[:cri]; end
    end
    n = [Integer(n), 0].max
    return Integer(n)
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： odds
  #--------------------------------------------------------------------------
  alias odds_enemy_csp odds unless $@
  def odds
    n = odds_enemy_csp
    for state in states
      percent = 100
      for i in 1..stack(state); percent += state.stat_per[:odds] - 100; end
      n = n * percent / 100.0
    end
    for state in states;
      for i in 1..stack(state); n += state.stat_set[:odds]; end
    end
    n = [Integer(n), 1].max
    return Integer(n)
  end
  
end

#==============================================================================
#==============================================================================

class Game_Party < Game_Unit
  
  #--------------------------------------------------------------------------
  # alias 方法： on_player_walk
  #--------------------------------------------------------------------------
  alias on_player_walk_csp on_player_walk unless $@
  def on_player_walk
    on_player_walk_csp
    return unless YEZ::STATE::STEP_UPDATE_STATES
    return unless @steps % YEZ::STATE::STEPS_PER_ST_TURNS == 0
    for actor in members
      actor.remove_states_auto
    end
  end
  
end

#===============================================================================
#===============================================================================

class Sprite_Battler < Sprite_Base
  
  #--------------------------------------------------------------------------
  # class variable
  #--------------------------------------------------------------------------
  @@state_animations = []
  RATE = $imported["CoreFixesUpgrades"] ? YEZ::FIXES::ANIMATION_RATE : 4
  
  #--------------------------------------------------------------------------
  # alias 方法： initialize
  #--------------------------------------------------------------------------
  alias initialize_sprite_battler_csp initialize unless $@
  def initialize(viewport, battler = nil)
    initialize_sprite_battler_csp(viewport, battler)
    @state_animation_duration = 0
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： dispose
  #--------------------------------------------------------------------------
  alias dispose_sprite_battler_csp dispose unless $@
  def dispose
    dispose_sprite_battler_csp
    dispose_state_animation
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： update
  #--------------------------------------------------------------------------
  alias update_sprite_battler_csp update unless $@
  def update
    update_sprite_battler_csp
    if @state_animation != nil
      @state_animation_duration -= 1
      if @state_animation_duration % RATE == 0
        update_state_animation
      end
    end
    @@state_animations.clear
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： setup_new_effect
  #--------------------------------------------------------------------------
  alias setup_new_effect_sprite_battler_csp setup_new_effect unless $@
  def setup_new_effect
    setup_new_effect_sprite_battler_csp
    if @battler.state_animation != nil
      if @battler.state_animation == 0
        dispose_state_animation
      else
        start_state_animation($data_animations[@battler.state_animation])
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：start_state_animation
  #--------------------------------------------------------------------------
  def start_state_animation(animation)
    return if @state_animation != nil and @state_animation.id == animation.id
    dispose_state_animation
    @state_animation = animation
    return if @state_animation == nil
    @state_animation_mirror = false
    @state_animation_duration = @state_animation.frame_max * RATE + 1
    load_state_animation_bitmap
    @state_animation_sprites = []
    if @state_animation.position != 3 or !@@state_animations.include?(animation)
      if @use_sprite
        for i in 0..15
          sprite = ::Sprite.new(viewport)
          sprite.visible = false
          @state_animation_sprites.push(sprite)
        end
        unless @@state_animations.include?(animation)
          @@state_animations.push(animation)
        end
      end
    end
    if @state_animation.position == 3
      if viewport == nil
        @state_animation_ox = 544 / 2
        @state_animation_oy = 416 / 2
      else
        @state_animation_ox = viewport.rect.width / 2
        @state_animation_oy = viewport.rect.height / 2
      end
    else
      @state_animation_ox = x - ox + width / 2
      @state_animation_oy = y - oy + height / 2
      if @state_animation.position == 0
        @state_animation_oy -= height / 2
      elsif @state_animation.position == 2
        @state_animation_oy += height / 2
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：load_state_animation_bitmap
  #--------------------------------------------------------------------------
  def load_state_animation_bitmap
    animation1_name = @state_animation.animation1_name
    animation1_hue = @state_animation.animation1_hue
    animation2_name = @state_animation.animation2_name
    animation2_hue = @state_animation.animation2_hue
    @state_animation_bitmap1 = Cache.animation(animation1_name, animation1_hue)
    @state_animation_bitmap2 = Cache.animation(animation2_name, animation2_hue)
    if @@_reference_count.include?(@state_animation_bitmap1)
      @@_reference_count[@state_animation_bitmap1] += 1
    else
      @@_reference_count[@state_animation_bitmap1] = 1
    end
    if @@_reference_count.include?(@state_animation_bitmap2)
      @@_reference_count[@state_animation_bitmap2] += 1
    else
      @@_reference_count[@state_animation_bitmap2] = 1
    end
    Graphics.frame_reset
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：dispose_state_animation
  #--------------------------------------------------------------------------
  def dispose_state_animation
    if @state_animation_bitmap1 != nil
      @@_reference_count[@state_animation_bitmap1] -= 1
      if @@_reference_count[@state_animation_bitmap1] == 0
        @state_animation_bitmap1.dispose
      end
    end
    if @state_animation_bitmap2 != nil
      @@_reference_count[@state_animation_bitmap2] -= 1
      if @@_reference_count[@state_animation_bitmap2] == 0
        @state_animation_bitmap2.dispose
      end
    end
    if @state_animation_sprites != nil
      for sprite in @state_animation_sprites
        sprite.dispose
      end
      @state_animation_sprites = nil
      @state_animation = nil
    end
    @state_animation_bitmap1 = nil
    @state_animation_bitmap2 = nil
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：update_state_animation
  #--------------------------------------------------------------------------
  def update_state_animation
    if @state_animation_duration > 0
      frame_index = @state_animation.frame_max -
        (@state_animation_duration + RATE - 1) / RATE
      state_animation_set_sprites(@state_animation.frames[frame_index])
      for timing in @state_animation.timings
        if timing.frame == frame_index
          state_animation_process_timing(timing)
        end
      end
    else
      @state_animation_duration = @state_animation.frame_max * RATE + 1
    end
    if @state_animation.position == 3
      if viewport == nil
        @state_animation_ox = 544 / 2
        @state_animation_oy = 416 / 2
      else
        @state_animation_ox = viewport.rect.width / 2
        @state_animation_oy = viewport.rect.height / 2
      end
    else
      @state_animation_ox = x - ox + width / 2
      @state_animation_oy = y - oy + height / 2
      if @state_animation.position == 0
        @state_animation_oy -= height / 2
      elsif @state_animation.position == 2
        @state_animation_oy += height / 2
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：state_animation_set_sprites
  #--------------------------------------------------------------------------
  def state_animation_set_sprites(frame)
    cell_data = frame.cell_data
    for i in 0..15
      sprite = @state_animation_sprites[i]
      next if sprite == nil
      pattern = cell_data[i, 0]
      if pattern == nil or pattern == -1
        sprite.visible = false
        next
      end
      if pattern < 100
        sprite.bitmap = @state_animation_bitmap1
      else
        sprite.bitmap = @state_animation_bitmap2
      end
      sprite.visible = true
      sprite.src_rect.set(pattern % 5 * 192,
        pattern % 100 / 5 * 192, 192, 192)
      if @state_animation_mirror
        sprite.x = @state_animation_ox - cell_data[i, 1]
        sprite.y = @state_animation_oy + cell_data[i, 2]
        sprite.angle = (360 - cell_data[i, 4])
        sprite.mirror = (cell_data[i, 5] == 0)
      else
        sprite.x = @state_animation_ox + cell_data[i, 1]
        sprite.y = @state_animation_oy + cell_data[i, 2]
        sprite.angle = cell_data[i, 4]
        sprite.mirror = (cell_data[i, 5] == 1)
      end
      sprite.z = self.z + 300 + i
      sprite.ox = 96
      sprite.oy = 96
      sprite.zoom_x = cell_data[i, 3] / 100.0
      sprite.zoom_y = cell_data[i, 3] / 100.0
      if @battler.actor?
        sprite.zoom_x *= YEZ::STATE::ANI_ACTOR_ZOOM
        sprite.zoom_x /= 100
        sprite.zoom_y *= YEZ::STATE::ANI_ACTOR_ZOOM
        sprite.zoom_y /= 100
      end
      sprite.opacity = cell_data[i, 6] * self.opacity / 255.0
      sprite.blend_type = cell_data[i, 7]
    end
  end
  #--------------------------------------------------------------------------
  # 新增方法：state_animation_process_timing
  #--------------------------------------------------------------------------
  def state_animation_process_timing(timing)
    timing.se.play if YEZ::STATE::ANIMATION_SOUND
    case timing.flash_scope
    when 1
      self.flash(timing.flash_color, timing.flash_duration * RATE)
    when 2
      return unless YEZ::STATE::ANIMATION_FLASH
      if viewport != nil
        viewport.flash(timing.flash_color, timing.flash_duration * RATE)
      end
    when 3
      self.flash(nil, timing.flash_duration * RATE)
    end
  end
  
end

#===============================================================================
#===============================================================================

class Scene_Battle < Scene_Base
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  attr_accessor :active_battler
  
  #--------------------------------------------------------------------------
  # alias 方法： start
  #--------------------------------------------------------------------------
  alias start_battle_csp start unless $@
  def start
    start_battle_csp
    for member in $game_party.members + $game_troop.members
      member.reload_state_animation
    end
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： start_main
  #--------------------------------------------------------------------------
  alias start_main_csp start_main unless $@
  def start_main
    start_main_csp
    for member in ($game_party.members + $game_troop.members)
      for state in member.states
        member.custom_status_effects(state, "BEGIN")
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： battle_end
  #--------------------------------------------------------------------------
  alias battle_end_csp battle_end unless $@
  def battle_end(result)
    battle_end_csp(result)
    for member in $game_party.members; member.reset_state_origins; end
  end
  
end

#===============================================================================
# 
# 
#===============================================================================