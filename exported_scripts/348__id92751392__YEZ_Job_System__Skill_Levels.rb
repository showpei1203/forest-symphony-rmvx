#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：YEZ Job System: Skill Levels
# 【用途】為 Job System 已學／可學技能加入等級成長，使技能可隨等級調整傷害、命中、成本、State 回合、Chain、速度、Cooldown 等。
# 【版本】Last Date Updated: 2010.01.28；Level: Normal, Hard。
# 【依賴】Requires: YEZ Skill Command Selection、YEZ Job System: Base；原文件並列與 Custom Damage Control、Custom Skill Effects、Custom Status Effects、Formation Macros 等相容。
#   <max level x>：最大技能等級；無標籤時用 DEFAULT_MAX_LEVEL。
#   <cannot level>：不可升級，也不列在技能升級清單；效果等同最大等級 0 的概念。
#   <level x jp: y>：指定升到 x 級需要 y JP；未指定時使用 LEVEL_DATA。
#   <level dmg all: +x%/-x%>：每級共通傷害百分比；<level x dmg: +y%/-y%>：指定等級覆蓋值。
#   <level hit all: +x%/-x%>、<level x hit: +y%/-y%>：共通／指定等級命中修正。
#   <level cost all: +x/-x>、<level x cost: +y/-y>：技能成本共通／指定等級修正。
#   <level state all: +x/-x>、<level x state: +y/-y>：技能施加 State 的回合數修正。
#   <level chain all: +x/-x>、<level x chain: +y/-y>：Chain 次數修正；需要 Custom Skill Effects。
#   <level speed all: +x/-x>、<level x speed: +y/-y>：技能 initiative／速度修正。
#   <level cooldown all: +x/-x>、<level x cooldown: +y/-y>：Cooldown 修正；需要 Custom Skill Effects。
# 【Enemy Notetag】<skill x at level y>：Enemy 的 Skill x 視為 y 級；<all skills level +x>：全部技能額外加 x 級，可與前者疊加。
# 【測試快捷鍵】原文件：$TEST/$BTEST 的技能升級選單中 F7/F8 調整目前 Class JP，F5 強制技能升級。
# 【主要設定】
#   LEVEL_TITLE / LEVEL_ENABLE_SWITCH：技能升級指令名稱與顯示 Switch。
#   LEVEL_VOCAB：滿級、基本級、成本、命中、傷害、治療、回合、Chain、速度、Cooldown、Limited Usage 等 UI 詞彙。
#   UNLEVEL_RATE：降級時 JP 返還／成本率；負值代表返還，例如 -0.50 = 返還 50%；正 0.75 = 需支付原成本 75%；0 = 無得失。
#   ALLOW_UNLEVEL：是否允許降級技能；LEVEL_UP_SOUND / LEVEL_DN_SOUND：升／降級 SE。
#   LEVEL_ICONS：成本、命中、傷害、治療、速度、Cooldown 類別 Icon。
#   DEFAULT_MAX_LEVEL：沒有 Notetag 時最大等級；DEFAULT_DMG_BONUS、DEFAULT_HIT_BONUS、DEFAULT_STATE_UP：預設每級成長。
#   LEVEL_DATA：每級 [Icon, 顯示文字, JP Cost]；Level 0 必須保留，即使不可降到 0。
# 【FS 注意】本頁的傷害／命中最終仍會經 FS_BattleFormula 等後續 Authority；Phase 24 起 MP 成本不再 alias calc_mp_cost，只保留 apply_level_cost Modifier Provider；Phase 26 起 calc_hit_jpsl 也退休，level_hit 改由 FS_BattleFormula_Authority v1.2 最終 calc_hit 直接讀取。
# 【範例】<max level 4>、<level 2 jp: 3000>、<level dmg all: +20%>、<skill 10 at level 3>。
# 【來源】Yanfly Engine Zealous；完整原始更新紀錄與英文說明保存於 Phase 16 Archive。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本頁所有維護說明集中於腳本最前方；下方程式識別字、Notetag、Action Key、方法名不可翻譯改名。
# 2. 原作者、版本、Credits、License、網址等來源資訊保留；完整翻譯前原稿另存 Phase 16 Archive。
# 3. 範例只使用原文件已明示的 API／Notetag，或由既有方法簽章可直接證實的呼叫方式。
# 4. 本輪只改註解／說明，不改任何可執行 Ruby；載入順序仍以 FS LoadOrder Guide／Authority Map 為準。
#==============================================================================
$imported = {} if $imported == nil
$imported["JobSystemSkillLevels"] = true

module YEZ
  module JOB
    
    #===========================================================================
    # 基本設定
    # --------------------------------------------------------------------------
    #===========================================================================
    
    LEVEL_TITLE = ""
    
    LEVEL_ENABLE_SWITCH = 45
    
    LEVEL_VOCAB ={
      :no_text    => "-",
      :gain_jp    => "+%s",
      :max_level  => "極限等級",
      :max_short  => "滿等",
      :level_0    => "基本等級",
      :level_to   => "等級 %s → %s",
      :upgrade    => "升級需要",
      :downcost   => "降級需要",
      :downgain   => "降級獲得",
      :cost       => "%s 消耗",
      :hit_rate   => "命中率",
      :level_dmg  => "傷害加乘",
      :level_heal => "治癒",
      :dmg_per    => "%s%%",
      :duration   => "回合數",
      :st_turns   => "%s回合",
      :chain_plus => "Chain Number",
      :speed      => "Initiative",
      :cooldown   => "Cooldown",
      :coolturns  => "%sT",
      :limit_use  => "Limited Usage",
      :limit_time => "%sx",
    } # 此結構不可刪除。
    
    UNLEVEL_RATE = -0.50
    
    ALLOW_UNLEVEL = true
    
    LEVEL_UP_SOUND = RPG::SE.new("Up", 80, 150)
    LEVEL_DN_SOUND = RPG::SE.new("Down", 80, 150)
    
    LEVEL_ICONS ={
      :cost     => 100,
      :hit      => 135,
      :dmg      => 119,
      :heal     => 128,
      :speed    => 158,
      :cooldown => 142,
    } # 此結構不可刪除。
    
    #===========================================================================
    # 技能等級設定
    # --------------------------------------------------------------------------
    #===========================================================================
    
    DEFAULT_MAX_LEVEL = 4
    DEFAULT_DMG_BONUS = 100
    DEFAULT_HIT_BONUS = 0
    DEFAULT_STATE_UP  = 2
    
    LEVEL_DATA ={
    # Level => [Icon,  Text, JP Cost],這裡設等級icon
          0 => [   0,   "0",       0],
          1 => [ 2512,   "1",    1000],#治療之觸補500
          2 => [ 2513,   "2",    3000],#治療之觸補1000
          3 => [ 2514,   "3",    6000],#治療之觸補2000
          4 => [ 2515,   "4",   12000],#治療之觸補4000
          5 => [ 2516,   "5",   24000],#治療之觸補8000
          6 => [ 2405,   "6",   16000],
          7 => [ 2406,   "7",   32000],
          8 => [ 2407,   "8",   65000],
          9 => [ 2408,   "9",  130000],
         10 => [ 2409,  "10",  260000],
         11 => [ 2410,  "11",  204800],
         12 => [ 2411,  "12",  409600],
         13 => [ 2412,  "13",  819200],
         14 => [ 2413,  "14", 1638400],
         15 => [ 2414,  "15", 3276800],
    } # 此結構不可刪除。
    
  end
end

#===============================================================================
#===============================================================================

module YEZ
  module REGEXP
    module BASEITEM
      
    MAX_LEVEL = /<(?:MAX_LEVEL|max level|level max)[ ]*(\d+)>/i
    CANNOT_LEVEL = /<(?:CANNOT_LEVEL|cannot level|cant level)>/i
    LEVEL_JP_COST = /<(?:LEVEL|level)[ ](\d+)[ ](?:JP|jp cost):[ ]*(\d+)>/i
    
    LEVEL_PER_ONE = /<(?:LEVEL)[ ](\d+)[ ](.*):[ ]*([\+\-]\d+)([%％])>/i
    LEVEL_PER_ALL = /<(?:LEVEL)[ ](.*)[ ](?:ALL):[ ]*([\+\-]\d+)([%％])>/i
    LEVEL_SET_ONE = /<(?:LEVEL)[ ](\d+)[ ](.*):[ ]*([\+\-]\d+)>/i
    LEVEL_SET_ALL = /<(?:LEVEL)[ ](.*)[ ](?:ALL):[ ]*([\+\-]\d+)>/i
      
    end
    module ENEMY
      
      SKILL_LEVEL = /<(?:SKILL)[ ](\d+)[ ](?:AT_LEVEL|at level)[ ]*(\d+)>/i
      ALL_SKILLS_LEVEL = /<(?:ALL_SKILLS_LEVEL|all skills level)[ ]*([\+\-]\d+)>/i
      
    end
  end
end

#===============================================================================
# RPG::BaseItem
#===============================================================================

class RPG::BaseItem
  
  #--------------------------------------------------------------------------
  # 共用快取：yez_cache_baseitem_jpsl
  #--------------------------------------------------------------------------
  def yez_cache_baseitem_jpsl
    @max_level = YEZ::JOB::DEFAULT_MAX_LEVEL; @cannot_level = false
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when YEZ::REGEXP::BASEITEM::MAX_LEVEL
        @max_level = $1.to_i
      when YEZ::REGEXP::BASEITEM::CANNOT_LEVEL
        @cannot_level = true
        @max_level = 0
      end
    } # end self.note.split
      
    @level_jp = {}; @level_dmg = {}; @level_hit = {}; @level_cost = {}
    @level_state = {}; @level_chain = {}; @level_speed = {}; @level_cool = {}
    @level_limit = {};
    for i in 0..@max_level; @level_jp[i] = YEZ::JOB::LEVEL_DATA[i][2]; end
    for i in 0..@max_level; @level_dmg[i] = YEZ::JOB::DEFAULT_DMG_BONUS * i; end
    for i in 0..@max_level; @level_hit[i] = YEZ::JOB::DEFAULT_HIT_BONUS * i; end
    for i in 0..@max_level; @level_state[i] = YEZ::JOB::DEFAULT_STATE_UP * i; end
    for i in 0..@max_level; @level_cost[i] = 0; end
    for i in 0..@max_level; @level_chain[i] = 0; end
    for i in 0..@max_level; @level_speed[i] = 0; end
    for i in 0..@max_level; @level_cool[i] = 0; end
    for i in 0..@max_level; @level_limit[i] = 0; end
      
    self.note.split(/[\r\n]+/).each { |line|
      case line
      #---
      when YEZ::REGEXP::BASEITEM::LEVEL_JP_COST
        for i in ($1.to_i)..@max_level; @level_jp[i] = $2.to_i; end
      #---
      when YEZ::REGEXP::BASEITEM::LEVEL_PER_ONE
        case $2.upcase
        when "DMG", "DAMAGE"
          for i in ($1.to_i)..@max_level; @level_dmg[i] = $3.to_i; end
        when "HIT", "HIT_RATE", "HIT RATE"
          for i in ($1.to_i)..@max_level; @level_hit[i] = $3.to_i; end
        end
      #---
      when YEZ::REGEXP::BASEITEM::LEVEL_PER_ALL
        case $1.upcase
        when "DMG", "DAMAGE"
          for i in 0..@max_level; @level_dmg[i] = $2.to_i * i; end
        when "HIT", "HIT_RATE", "HIT RATE"
          for i in 0..@max_level; @level_hit[i] = $2.to_i * i; end
        end
      #---
      when YEZ::REGEXP::BASEITEM::LEVEL_SET_ONE
        case $2.upcase
        when "COST", "MP_COST", "MP COST"
          for i in ($1.to_i)..@max_level; @level_cost[i] = $3.to_i; end
        when "STATE", "STATE_TURNS", "STATE TURNS"
          for i in ($1.to_i)..@max_level; @level_state[i] = $3.to_i; end
        when "CHAIN", "CHAIN_NUMBER", "CHAIN NUMBER"
          for i in ($1.to_i)..@max_level; @level_chain[i] = $3.to_i; end
        when "SPEED", "INITIATIVE"
          for i in ($1.to_i)..@max_level; @level_speed[i] = $3.to_i; end
        when "COOLDOWN", "COOL_DOWN", "COOL DOWN", "RECHARGE"
          for i in ($1.to_i)..@max_level; @level_cool[i] = $3.to_i; end
        when "LIMIT", "LIMITED USE", "LIMITED_USE", "LIMITED USAGE"
          for i in ($1.to_i)..@max_level; @level_limit[i] = $3.to_i; end
        end
      #---
      when YEZ::REGEXP::BASEITEM::LEVEL_SET_ALL
        case $1.upcase
        when "COST", "MP_COST", "MP COST"
          for i in 0..@max_level; @level_cost[i] = $2.to_i * i; end
        when "STATE", "STATE_TURNS", "STATE TURNS"
          for i in 0..@max_level; @level_state[i] = $2.to_i * i; end
        when "CHAIN", "CHAIN_NUMBER", "CHAIN NUMBER"
          for i in 0..@max_level; @level_chain[i] = $2.to_i * i; end
        when "SPEED", "INITIATIVE"
          for i in 0..@max_level; @level_speed[i] = $2.to_i * i; end
        when "COOLDOWN", "COOL_DOWN", "COOL DOWN", "RECHARGE"
          for i in 0..@max_level; @level_cool[i] = $2.to_i * i; end
        when "LIMIT", "LIMITED USE", "LIMITED_USE", "LIMITED USAGE"
          for i in 0..@max_level; @level_limit[i] = $2.to_i * i; end
        end
      #---
      end
    } # end self.note.split
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：max_level
  #--------------------------------------------------------------------------
  def max_level
    yez_cache_baseitem_jpsl if @max_level == nil
    return @max_level
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：cannot_level
  #--------------------------------------------------------------------------
  def cannot_level
    yez_cache_baseitem_jpsl if @cannot_level == nil
    return @cannot_level
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：level_jp
  #--------------------------------------------------------------------------
  def level_jp
    yez_cache_baseitem_jpsl if @level_jp == nil
    return @level_jp
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：level_dmg
  #--------------------------------------------------------------------------
  def level_dmg
    yez_cache_baseitem_jpsl if @level_dmg == nil
    return @level_dmg
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：level_hit
  #--------------------------------------------------------------------------
  def level_hit
    yez_cache_baseitem_jpsl if @level_hit == nil
    return @level_hit
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：level_cost
  #--------------------------------------------------------------------------
  def level_cost
    yez_cache_baseitem_jpsl if @level_cost == nil
    return @level_cost
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：level_state
  #--------------------------------------------------------------------------
  def level_state
    yez_cache_baseitem_jpsl if @level_state == nil
    return @level_state
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：level_chain
  #--------------------------------------------------------------------------
  def level_chain
    yez_cache_baseitem_jpsl if @level_chain == nil
    return @level_chain
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：level_speed
  #--------------------------------------------------------------------------
  def level_speed
    yez_cache_baseitem_jpsl if @level_speed == nil
    return @level_speed
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：level_cool
  #--------------------------------------------------------------------------
  def level_cool
    yez_cache_baseitem_jpsl if @level_cool == nil
    return @level_cool
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：level_limit
  #--------------------------------------------------------------------------
  def level_limit
    yez_cache_baseitem_jpsl if @level_limit == nil
    return @level_limit
  end
  
end # RPG::BaseItem

#===============================================================================
# RPG::Enemy
#===============================================================================

class RPG::Enemy
  
  #--------------------------------------------------------------------------
  # 共用快取：yez_cache_enemy_jpsl
  #--------------------------------------------------------------------------
  def yez_cache_enemy_jpsl
    @skill_level = {}; @all_skills_level = 0
    
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when YEZ::REGEXP::ENEMY::SKILL_LEVEL
        @skill_level[$1.to_i] = $2.to_i
      when YEZ::REGEXP::ENEMY::ALL_SKILLS_LEVEL
        @all_skills_level = $1.to_i
      end
    } # end self.note.split
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def skill_level
    yez_cache_enemy_jpsl if @skill_level == nil
    return @skill_level
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def all_skills_level
    yez_cache_enemy_jpsl if @all_skills_level == nil
    return @all_skills_level
  end
  
end # RPG::Enemy

#===============================================================================
# Game_Battler
#===============================================================================

class Game_Battler
  
  #--------------------------------------------------------------------------
  # 公開實例變數
  #--------------------------------------------------------------------------
  attr_accessor :temp_level
  
  #--------------------------------------------------------------------------
  # alias 方法：make_obj_damage_value
  #--------------------------------------------------------------------------
  unless $imported["CustomDamageControl"]
  alias make_obj_damage_value_jpsl make_obj_damage_value unless $@
  def make_obj_damage_value(user, obj)
    make_obj_damage_value_jpsl(user, obj)
    @hp_damage = apply_level_dmg(user, obj, @hp_damage)
    @mp_damage = apply_level_dmg(user, obj, @mp_damage)
  end
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：apply_level_dmg
  #--------------------------------------------------------------------------
  def apply_level_dmg(user, obj, damage)
    return damage if obj == nil or user == nil
    return damage if damage == 0
    return damage unless obj.is_a?(RPG::Skill)
    rate = [100 + obj.level_dmg[user.skill_level(obj)], 0].max
    damage = damage * rate / 100.0
    return Integer(damage)
  end
  
  #--------------------------------------------------------------------------
  # Phase 26：命中率 Wrapper 已退休。
  # 技能等級的 level_hit 修正已由 FS_BattleFormula_Authority v1.2
  # 直接納入最終 calc_hit；本頁只保留 level_hit 資料 Provider。
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  # Phase 24：MP 成本 alias 已移除。
  # `apply_level_cost` 僅作為 Modifier Provider，由最終 Skill Cost Authority 呼叫。
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  # 新增方法：apply_level_cost
  #--------------------------------------------------------------------------
  def apply_level_cost(cost, skill)
    temp = @temp_level == nil ? 0 : @temp_level
    level = [[skill_level(skill) + temp, skill.max_level].min, 0].max
    cost += skill.level_cost[level]
    cost -= skill.level_cost[level] / 2 if half_mp_cost and
      !$imported["CustomSkillEffectsZeal"]
    return [cost, 0].max
  end
  
  #--------------------------------------------------------------------------
  # alias 方法：apply_state_changes
  #--------------------------------------------------------------------------
  unless $imported["CustomStatusPropertiesZeal"]
  alias apply_state_changes_jpsl apply_state_changes unless $@
  def apply_state_changes(obj)
    apply_state_changes_jpsl(obj)
    return if obj == nil
    for i in @added_states
      apply_state_turns(obj, i)
    end
  end
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：apply_state_turns
  #--------------------------------------------------------------------------
  def apply_state_turns(skill, state_id, forced = false)
    return unless skill.is_a?(RPG::Skill)
    return if !skill.plus_state_set.include?(state_id) and !forced
    if $scene.is_a?(Scene_Battle)
      user = $scene.active_battler
    elsif $scene.is_a?(Scene_Skill)
      user = $scene.actor
    else
      return
    end
    return if user == nil
    level = [[user.skill_level(skill), skill.max_level].min, 0].max
    value = skill.level_state[level]
    @state_turns[state_id] = [@state_turns[state_id] + value, 0].max
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：skill_level_up
  #--------------------------------------------------------------------------
  def skill_level_up(skill, levels = 1)
    skill = skill.id if skill.is_a?(RPG::Skill)
    self.skill_level(skill) if @skill_level[skill] == nil
    @skill_level[skill] += levels
    original = $data_skills[skill]
    @skill_level[skill] = [[original.max_level, @skill_level[skill]].min, 0].max
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：skill_level_down
  #--------------------------------------------------------------------------
  def skill_level_down(skill, levels = 1)
    skill_level_up(skill, -levels)
  end
  
end # Game_Battler

#===============================================================================
# Game_BattleAction
#===============================================================================

class Game_BattleAction
  
  #--------------------------------------------------------------------------
  # alias 方法：make_speed
  #--------------------------------------------------------------------------
  alias make_speed_jpsl make_speed unless $@
  def make_speed
    make_speed_jpsl
    if skill?
      level = [[battler.skill_level(skill), skill.max_level].min, 0].max
      @speed += skill.level_speed[level]
    end
  end
  
end # Game_BattleAction

#===============================================================================
# Game_Actor
#===============================================================================

class Game_Actor < Game_Battler
  
  #--------------------------------------------------------------------------
  # 公開實例變數
  #--------------------------------------------------------------------------
  attr_accessor :skill_level
  
  #--------------------------------------------------------------------------
  # alias 方法：setup
  #--------------------------------------------------------------------------
  alias setup_jpsl setup unless $@
  def setup(actor_id)
    setup_jpsl(actor_id)
    @skill_level = {}
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：learned_skills
  #--------------------------------------------------------------------------
  def learned_skills
    result = []
    for i in @skills
      result.push($data_skills[i])
    end
    return result
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：skill_level
  #--------------------------------------------------------------------------
  def skill_level(skill)
    @skill_level = {} if @skill_level == nil
    skill = skill.id if skill.is_a?(RPG::Skill)
    @skill_level[skill] = 0 if @skill_level[skill] == nil
    original = $data_skills[skill]
    @skill_level[skill] = [[original.max_level, @skill_level[skill]].min, 0].max
    return @skill_level[skill]
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：total_skills
  #--------------------------------------------------------------------------
  unless $imported["CustomSkillEffectsZeal"]
  def total_skills
    result = skills
    result.sort! { |a,b| a.id <=> b.id }
    return result.uniq
  end
  end
  
end # Game_Actor

#===============================================================================
# Game_Enemy
#===============================================================================

class Game_Enemy < Game_Battler
  
  #--------------------------------------------------------------------------
  # 公開實例變數
  #--------------------------------------------------------------------------
  attr_accessor :skill_level
  
  #--------------------------------------------------------------------------
  # alias 方法：initialize
  #--------------------------------------------------------------------------
  alias initialize_enemy_jpsl initialize unless $@
  def initialize(index, enemy_id)
    initialize_enemy_jpsl(index, enemy_id)
    @skill_level = {}
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：skill_level
  #--------------------------------------------------------------------------
  def skill_level(skill)
    @skill_level = {} if @skill_level == nil
    skill = skill.id if skill.is_a?(RPG::Skill)
    if enemy.skill_level.include?(skill)
      @skill_level[skill] = enemy.skill_level[skill] if @skill_level[skill] == nil
    else
      @skill_level[skill] = 0 if @skill_level[skill] == nil
    end
    @skill_level[skill] += enemy.all_skills_level
    original = $data_skills[skill]
    @skill_level[skill] = [[@skill_level[skill], 0].max, original.max_level].min
    return @skill_level[skill]
  end
  
end # Game_Enemy

#===============================================================================
# Game_Party
#===============================================================================

class Game_Party < Game_Unit
  
  #--------------------------------------------------------------------------
  # alias 方法：setup_starting_members
  #--------------------------------------------------------------------------
  alias setup_starting_members_jpsl setup_starting_members unless $@
  def setup_starting_members
    setup_starting_members_jpsl
    $game_switches[YEZ::JOB::LEVEL_ENABLE_SWITCH] = true
  end
  
end # Game_Party

#===============================================================================
# Scene_Skill
#===============================================================================

class Scene_Skill < Scene_Base
  
  #--------------------------------------------------------------------------
  # 公開實例變數
  #--------------------------------------------------------------------------
  attr_accessor :actor
  
  #--------------------------------------------------------------------------
  # 新增方法：start_levelskill_selection
  #--------------------------------------------------------------------------
  def start_levelskill_selection
    @levelskill_window.y = @status_window.height
    @levelskill_window.y += @help_window.height if @help_window.visible
    @levelskill_window.active = true
    @command_window.active = false
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：update_levelskill_selection
  #--------------------------------------------------------------------------
  def update_levelskill_selection
    @levelskill_window.update
    if @last_levelskill_index != @levelskill_window.index
      @last_levelskill_index = @levelskill_window.index
      @leveldata_window.refresh(@levelskill_window.skill, @status_window.class)
    end
    if Input.trigger?(Input::B)
      Sound.play_cancel
      if @class_window != nil
        @class_window.y = @levelskill_window.y
        @class_window.active = true
        @class_window.update_help
        @classdata_window.y = @class_window.y
        @levelskill_window.active = false
        @levelskill_window.y = 416*3
        @leveldata_window.y = 416*3
      else
        @levelskill_window.active = false
        @command_window.active = true
        @sprites[@command_window.index].color.set(255, 255, 255, 0)
      @sprites[@command_window.index].y = (@command_window.index * 26) + 19
      end
      refresh_windows
    elsif $TEST and Input.repeat?(Input::F8)
      Sound.play_equip
      value = YEZ::JOB::JP_COST * 10
      value *= 10 if Input.press?(Input::SHIFT)
      @actor.gain_jp(value + rand(value), @status_window.class)
      @status_window.refresh
      @levelskill_window.refresh
      @leveldata_window.refresh(@levelskill_window.skill, @status_window.class)
    elsif $TEST and Input.repeat?(Input::F7)
      Sound.play_equip
      value = YEZ::JOB::JP_COST * 10
      value *= 10 if Input.press?(Input::SHIFT)
      @actor.lose_jp(value + rand(value), @status_window.class)
      @status_window.refresh
      @levelskill_window.refresh
      @leveldata_window.refresh(@levelskill_window.skill, @status_window.class)
    elsif $TEST and Input.repeat?(Input::F5)
      skill = @levelskill_window.skill
      return if skill == nil
      if @levelskill_window.mode
        YEZ::JOB::LEVEL_UP_SOUND.play
        cost = skill.level_jp[@actor.skill_level(skill) + 1]
        @actor.skill_level_up(skill)
      else
        YEZ::JOB::LEVEL_DN_SOUND.play
        cost = skill.level_jp[@actor.skill_level(skill)]
        cost = Integer(cost * YEZ::JOB::UNLEVEL_RATE)
        @actor.skill_level_down(skill)
      end
      @status_window.refresh
      @levelskill_window.refresh
      @leveldata_window.refresh(skill, @status_window.class)
    elsif Input.trigger?(Input::LEFT) or Input.trigger?(Input::RIGHT)
      return unless YEZ::JOB::ALLOW_UNLEVEL
      Sound.play_cursor
      @levelskill_window.mode = !@levelskill_window.mode
      @leveldata_window.mode = !@leveldata_window.mode
    elsif Input.trigger?(Input::C)
      skill = @levelskill_window.skill
      if skill == nil or !@levelskill_window.enabled_skill?(skill)
        Sound.play_buzzer
        return
      end
      if @levelskill_window.mode
        YEZ::JOB::LEVEL_UP_SOUND.play
        cost = skill.level_jp[@actor.skill_level(skill) + 1]
        @actor.skill_level_up(skill)
      else
        YEZ::JOB::LEVEL_DN_SOUND.play
        cost = skill.level_jp[@actor.skill_level(skill)]
        cost = Integer(cost * YEZ::JOB::UNLEVEL_RATE)
        @actor.skill_level_down(skill)
      end
      @actor.lose_jp(cost, @status_window.class)
      @status_window.refresh
      @levelskill_window.refresh
      @leveldata_window.refresh(skill, @status_window.class)
    end
  end
  
end # Scene_Skill

#===============================================================================
# Scene_Battle
#===============================================================================

class Scene_Battle < Scene_Base
  
  #--------------------------------------------------------------------------
  # 公開實例變數
  #--------------------------------------------------------------------------
  attr_accessor :active_battler
  
end # Scene_Battle

#===============================================================================
# Window_Base
#===============================================================================

class Window_Base < Window
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_skill_level(dx, dy, skill, actor, enabled = true)
    return if skill == nil or actor == nil
    level = actor.skill_level(skill)
    icon = YEZ::JOB::LEVEL_DATA[level][0]
    draw_icon(icon, dx, dy, enabled)
  end
  
end # Window_Base

#===============================================================================
# Window_Skill
#===============================================================================

class Window_Skill < Window_Selectable
  
  #--------------------------------------------------------------------------
  # alias 方法：draw_item
  #--------------------------------------------------------------------------
  unless $imported["CustomSkillEffectsZeal"]
  alias draw_item_window_skill_jpsl draw_item unless $@
  def draw_item(index)
    draw_item_window_skill_jpsl(index)
    rect = item_rect(index); skill = @data[index]
    return if skill == nil
    draw_skill_level(rect.x, rect.y, skill, @actor, @actor.skill_can_use?(skill))
  end
  end
  
end # Window_Skill

#===============================================================================
# Window_LevelSkill
#===============================================================================

class Window_LevelSkill < Window_LearnSkill
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize(dx, dy, actor)
    @mode = true
    super(dx, dy, actor)
    self.opacity = 0
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def mode; return @mode; end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def mode=(value)
    @mode = value
    refresh
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def include?(skill)
    return false if skill == nil
    skill_total = @actor.learned_skills + @actor.total_skills
    return false if !skill_total.include?(skill)
    return false if skill.cannot_level
    return false if skill.max_level <= 0
    return true
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_item(index)
    super(index)
    rect = item_rect(index); skill = @data[index]
    return if skill == nil
    draw_skill_level(rect.x, rect.y, skill, @actor, enabled_skill?(skill))
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_jp_cost(skill, dx, dy, enabled)
    dw = self.width - 32 - dx
    self.contents.font.size = YEZ::JOB::JP_SIZE
    if @actor.skill_level(skill) >= skill.max_level and @mode
      text = YEZ::JOB::LEVEL_VOCAB[:max_level]
      self.contents.draw_text(dx, dy, dw-4, WLH, text, 2)
    else
      icon = $imported["Icons"] ? YEZ::ICONS[:txtjp] : YEZ::JOB::JP_ICON
      if @mode
        text = skill.level_jp[@actor.skill_level(skill) + 1]
      else
        text = skill.level_jp[@actor.skill_level(skill)]
        text = Integer(text * YEZ::JOB::UNLEVEL_RATE)
        text = sprintf(YEZ::JOB::LEVEL_VOCAB[:gain_jp], -text) if text <= 0
      end
      draw_icon(icon, dx + dw - 24, dy, enabled)
      self.contents.draw_text(dx, dy, dw - 24, WLH, text, 2)
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def enabled_skill?(skill)
    level = @actor.skill_level(skill)
    if @mode
      return false if @actor.skill_level(skill) >= skill.max_level
      return false if @actor.class_jp[@class_id] < skill.level_jp[level + 1]
    else
      return false if @actor.skill_level(skill) <= 0
      cost = skill.level_jp[level]
      cost = Integer(cost * YEZ::JOB::UNLEVEL_RATE)
      return true if cost <= 0
      return false if @actor.class_jp[@class_id] < cost
    end
    return true
  end
  
end # Window_LevelSkill

#===============================================================================
# Window_LevelData
#===============================================================================

class Window_LevelData < Window_Base
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize(x, y, skill, actor, class_id)
    super(x, y, 544 - x, 416 - y)
    self.opacity = 0
    @mode = true
    @actor = actor
    @class_id = class_id
    refresh(skill, class_id)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def mode; return @mode; end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def mode=(value)
    @mode = value
    refresh(@skill, @class_id)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh(skill, class_id)
    self.contents.clear
    self.contents.font.color = normal_color
    self.contents.font.size = Font.default_size
    @skill = skill; @class_id = class_id
    return if @skill == nil
    draw_skill_name
    self.contents.font.size = YEZ::JOB::REQUIRE_SIZE; dy = WLH
    dy = draw_level(dy)
    dy = draw_jp_cost(dy)
    dy = draw_cost_bonus(dy)
    dy = draw_hit_bonus(dy)
    dy = draw_speed_bonus(dy)
    dy = draw_cooldown(dy)
    dy = draw_limited_usage(dy)
    dy = draw_dmg_bonus(dy)
    dy = draw_chain_bonus(dy)
    dy = draw_state_turns(dy)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_skill_name
    c_width = contents.text_size(@skill.name).width
    dx = (self.width-32)/2 - c_width/2
    self.contents.draw_text(dx, 0, c_width, WLH, @skill.name)
    draw_icon(@skill.icon_index, dx-24, 0)
    return WLH
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_level(dy)
    self.contents.font.color = normal_color
    hash = YEZ::JOB::LEVEL_DATA
    level1 = @actor.skill_level(@skill)
    if level1 == @skill.max_level and @mode
      text = YEZ::JOB::LEVEL_VOCAB[:max_level]
      self.contents.draw_text(0, dy, self.width-32, WLH, text, 1)
      return (dy + WLH)
    end
    level2 = @mode ? level1 + 1 : level1 - 1
    if level2 < 0
      text = YEZ::JOB::LEVEL_VOCAB[:level_0]
    else
      level1 = hash[level1][1]
      level2 = hash[level2][1]
      text = sprintf(YEZ::JOB::LEVEL_VOCAB[:level_to], level1, level2)
    end
    self.contents.draw_text(0, dy, self.width-32, WLH, text, 1)
    return (dy + WLH)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_jp_cost(dy)
    vocab = YEZ::JOB::LEVEL_VOCAB
    if @mode
      cost = @skill.level_jp[@actor.skill_level(@skill) + 1]
      text = vocab[:upgrade]
    else
      cost = @skill.level_jp[@actor.skill_level(@skill)]
      cost = Integer(cost * YEZ::JOB::UNLEVEL_RATE)
      if cost == nil or cost <= 0
        text = vocab[:downgain]
      else
        text = vocab[:downcost]
      end
    end
    draw_icon(YEZ::JOB::JP_ICON, 0, dy)
    self.contents.font.color = system_color
    self.contents.draw_text(24, dy, self.width-56, WLH, text)
    self.contents.font.color = normal_color
    if cost == nil
      cost = @skill.level_jp[@actor.skill_level(@skill)]
    elsif @actor.class_jp[@class_id] < cost
      self.contents.font.color = text_color(YEZ::JOB::REQUIRE_BAD)
    end
    self.contents.draw_text(24, dy, self.width-60, WLH, cost, 2)
    return (dy + WLH)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_cost_bonus(dy)
    return dy unless draw_cost_bonus?
    level = @actor.skill_level(@skill)
    level = @mode ? level + 1 : level - 1
    level = [[@skill.max_level, level].min, 0].max
    vocab = YEZ::JOB::LEVEL_VOCAB
    if $imported["CustomSkillEffectsZeal"]
      case @skill.cost_type
      when "MP"
        icon = YEZ::SKILL::MP_COST[:icon_id]
        text = sprintf(YEZ::SKILL::MP_COST[:suffix], "")
      when "HP"
        icon = YEZ::SKILL::HP_COST[:icon_id]
        text = sprintf(YEZ::SKILL::HP_COST[:suffix], "")
      when "GOLD"
        icon = YEZ::SKILL::GOLD_COST[:icon_id]
        text = sprintf(YEZ::SKILL::GOLD_COST[:suffix], "")
      when "RAGE"
        icon = YEZ::SKILL::RAGE_COST[:icon_id]
        text = sprintf(YEZ::SKILL::RAGE_COST[:suffix], "")
      when "CUSTOM"
        icon = @actor.custom_skill_costs(@skill, "USE_ICON")
        text = sprintf(@actor.custom_skill_costs(skill, "SUFFIX"), "")
      else
        icon = YEZ::JOB::LEVEL_ICONS[:cost]
        text = Vocab.mp
      end
      draw_icon(icon, 0, dy)
    else
      draw_icon(YEZ::JOB::LEVEL_ICONS[:cost], 0, dy)
      text = Vocab.mp
    end
    text = sprintf(vocab[:cost], text)
    self.contents.font.color = system_color
    self.contents.draw_text(24, dy, self.width-56, WLH, text)
    self.contents.font.color = normal_color
    @actor.temp_level = @mode ? 1 : -1
    value = @actor.calc_mp_cost(@skill)
    if $imported["CustomSkillEffectsZeal"] and @skill.cost_type == "GOLD"
      if @skill.per_cost[:gold] > 0
        value = sprintf(YEZ::SKILL::GOLD_COST[:suffixp], value)
      end
    end
    self.contents.draw_text(24, dy, self.width-60, WLH, value, 2)
    @actor.temp_level = nil
    return (dy + WLH)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_cost_bonus?
    @actor.temp_level = 0
    for i in 0..@skill.max_level
      if @actor.calc_mp_cost(@skill) > 0
        @actor.temp_level = nil
        return true
      end
      @actor.temp_level += @mode ? 1 : -1
    end
    @actor.temp_level = nil
    return false
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_hit_bonus(dy)
    level = @actor.skill_level(@skill)
    level = @mode ? level + 1 : level - 1
    level = [[@skill.max_level, level].min, 0].max
    return dy unless draw_hit_rate?
    vocab = YEZ::JOB::LEVEL_VOCAB
    draw_icon(YEZ::JOB::LEVEL_ICONS[:hit], 0, dy)
    self.contents.font.color = system_color
    self.contents.draw_text(24, dy, self.width-56, WLH, vocab[:hit_rate])
    self.contents.font.color = normal_color
    value = [[@skill.hit + @skill.level_hit[level], 100].min, 0].max
    value = sprintf("%s%%", value)
    self.contents.draw_text(24, dy, self.width-60, WLH, value, 2)
    return (dy + WLH)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_hit_rate?
    for i in 0..@skill.max_level; return true if @skill.level_hit[i] != 0; end
    return false
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_dmg_bonus(dy)
    return dy unless @skill.base_damage != 0 or
      ($imported["CustomDamageControl"] and @skill.base_dmg != 0) or
      ($imported["CustomDamageControl"] and @skill.custom_dmg != [])
    vocab = YEZ::JOB::LEVEL_VOCAB
    if @skill.base_damage < 0 or 
      ($imported["CustomDamageControl"] and @skill.base_dmg < 0)
      draw_icon(YEZ::JOB::LEVEL_ICONS[:heal], 0, dy)
      text = vocab[:level_heal]
    else
      draw_icon(YEZ::JOB::LEVEL_ICONS[:dmg], 0, dy)
      text = vocab[:level_dmg]
    end
    self.contents.font.color = system_color
    self.contents.draw_text(24, dy, self.width-56, WLH, text)
    self.contents.font.color = normal_color
    level = @actor.skill_level(@skill)
    level = @mode ? level + 1 : level - 1
    level = [[@skill.max_level, level].min, 0].max
    value = @skill.level_dmg[level]
    value = sprintf(vocab[:dmg_per], [value + 100, 0].max)
    self.contents.draw_text(24, dy, self.width-60, WLH, value, 2)
    return (dy + WLH)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_state_turns(dy)
    return dy if @skill.plus_state_set == []
    level = @actor.skill_level(@skill)
    level = @mode ? level + 1 : level - 1
    level = [[@skill.max_level, level].min, 0].max
    vocab = YEZ::JOB::LEVEL_VOCAB
    for state_id in @skill.plus_state_set
      state = $data_states[state_id]
      next if state == nil
      next if state.icon_index == 0
      draw_icon(state.icon_index, 0, dy)
      text = vocab[:duration]
      self.contents.font.color = system_color
      self.contents.draw_text(24, dy, self.width-56, WLH, text)
      self.contents.font.color = normal_color
      value = [state.hold_turn + @skill.level_state[level], 0].max
      value = sprintf(vocab[:st_turns], value)
      self.contents.draw_text(24, dy, self.width-60, WLH, value, 2)
      dy += WLH
    end
    return dy
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_chain_bonus(dy)
    return dy unless $imported["CustomSkillEffectsZeal"]
    return dy unless @skill.chain_kind > 0
    level = @actor.skill_level(@skill)
    level = @mode ? level + 1 : level - 1
    level = [[@skill.max_level, level].min, 0].max
    vocab = YEZ::JOB::LEVEL_VOCAB
    draw_icon(@skill.icon_index, 0, dy)
    text = vocab[:chain_plus]
    self.contents.font.color = system_color
    self.contents.draw_text(24, dy, self.width-56, WLH, text)
    self.contents.font.color = normal_color
    value = @skill.chain_number
    value += @skill.level_chain[level]
    self.contents.draw_text(24, dy, self.width-60, WLH, value, 2)
    return (dy + WLH)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_speed_bonus(dy)
    return dy unless draw_speed_bonus?
    level = @actor.skill_level(@skill)
    level = @mode ? level + 1 : level - 1
    level = [[@skill.max_level, level].min, 0].max
    vocab = YEZ::JOB::LEVEL_VOCAB
    draw_icon(YEZ::JOB::LEVEL_ICONS[:speed], 0, dy)
    text = vocab[:speed]
    self.contents.font.color = system_color
    self.contents.draw_text(24, dy, self.width-56, WLH, text)
    self.contents.font.color = normal_color
    value = sprintf("%+d", @skill.speed + @skill.level_speed[level])
    self.contents.draw_text(24, dy, self.width-60, WLH, value, 2)
    return (dy + WLH)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_speed_bonus?
    for i in 0..@skill.max_level; return true if @skill.level_speed[i] != 0; end
    return false
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_cooldown(dy)
    return dy unless draw_cooldown?
    level = @actor.skill_level(@skill)
    level = @mode ? level + 1 : level - 1
    level = [[@skill.max_level, level].min, 0].max
    vocab = YEZ::JOB::LEVEL_VOCAB
    draw_icon(YEZ::SKILL::COOLDOWN[:icon_id], 0, dy)
    text = vocab[:cooldown]
    self.contents.font.color = system_color
    self.contents.draw_text(24, dy, self.width-56, WLH, text)
    self.contents.font.color = normal_color
    value = [@skill.cooldown + @skill.level_cool[level], 0].max
    value = sprintf(vocab[:coolturns], value)
    self.contents.draw_text(24, dy, self.width-60, WLH, value, 2)
    return (dy + WLH)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_cooldown?
    return false unless $imported["CustomSkillEffectsZeal"]
    return false unless @skill.cooldown > 0
    for i in 0..@skill.max_level; return true if @skill.level_cool[i] != 0; end
    return false
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_limited_usage(dy)
    return dy unless draw_limited_usage?
    level = @actor.skill_level(@skill)
    level = @mode ? level + 1 : level - 1
    level = [[@skill.max_level, level].min, 0].max
    vocab = YEZ::JOB::LEVEL_VOCAB
    draw_icon(YEZ::SKILL::LIMITED_USE[:icon_id], 0, dy)
    text = vocab[:limit_use]
    self.contents.font.color = system_color
    self.contents.draw_text(24, dy, self.width-56, WLH, text)
    self.contents.font.color = normal_color
    value = [@skill.limited_use + @skill.level_limit[level], 0].max
    value = sprintf(vocab[:limit_time], value)
    self.contents.draw_text(24, dy, self.width-60, WLH, value, 2)
    return (dy + WLH)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_limited_usage?
    return false unless $imported["CustomSkillEffectsZeal"]
    return false unless @skill.limited_use > 0
    for i in 0..@skill.max_level; return true if @skill.level_limit[i] != 0; end
    return false
  end
  
end # Window_LevelData

#===============================================================================
# 
# 
#===============================================================================