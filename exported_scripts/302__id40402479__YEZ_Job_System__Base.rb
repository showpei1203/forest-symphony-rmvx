#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：YEZ Job System: Base
# 【用途】Yanfly Engine Zealous Job System 基底，以 JP 購買／學習技能，支援等級、前置技能、被動、Switch 等條件；Skill Levels 等擴充依賴本頁。
# 【版本】Last Date Updated: 2010.02.01；Level: Normal, Hard。
# 【依賴】Requires: YEZ Skill Command Selection；與 YEZ Custom Skill Effects 相容。FS 另有 Skill Levels／Passive 等後續層，載入順序不可反轉。
# 【Item Notetag】<jp growth +n> / <jp growth -n>：使用該 Item 時調整目前職業 JP。
#   <jp cost: n>：學習成本；無標籤時使用 JP_COST；n=0 表示不列為可用 JP 購買的技能。
#   <jp level: n>：購買前要求 Actor 至少 n 級。
#   <jp skill: n> / <jp skills: n,n>：要求先學會指定 Skill。
#   <jp passive: x> / <jp passives: x,x>：要求先取得指定 Passive。
#   <jp switch: n> / <jp switches: n,n>：指定 Switch 開啟前隱藏技能。
#   <jp skill x at level y>：需要 Skill Levels；要求 Skill x 達 y 級才可學習。
# 【State Notetag】<jp rate n%>：取得 JP 的倍率；200=200%，50=50%。
# 【Enemy Notetag】<jp gain n>：擊敗該敵人時提供 n JP，覆蓋 DEFAULT_ENEMY_JP。
# 【測試快捷鍵】原文件：$TEST/$BTEST 的技能學習選單可用 F7/F8 調整目前職業 JP（1000+rand(1000)），F5 強制學習技能。
# 【主要設定】
#   LEARN_TITLE：學習指令名稱；LEARN_ENABLE_SWITCH：控制指令是否顯示的 Switch。
#   JP_NAME / JP_ICON：JP 顯示名稱與圖示；JP_MAX：每職業最大 JP；JP_COST：無 Notetag 時預設技能 JP 成本；JP_SIZE：成本字體大小。
#   LEARN_SOUND：成功學會技能 SE；LEARN_VOCAB：已學會、需求、JP 成本、等級需求等文字。
#   REQUIRE_SIZE / REQUIRE_BAD / LEVEL_ICON：需求視窗字體、未達成顏色與等級需求 Icon。
#   CLASS_SKILLS：各 Class 可用 JP 學習的 Skill ID；Class ID 0 的清單所有職業皆可學。
#   DEFAULT_ENEMY_JP：無 Enemy Notetag 時的預設擊敗 JP。
#   JP_GAIN_ACTIONS：普通攻擊、防禦、技能、道具、升級等行動取得 JP 與隨機修正。
#   JP_VICTORY_MESSAGE：戰鬥結束 JP 訊息；Victory Aftermath 安裝時另使用其相容設定。
# 【範例】Skill Note：<jp cost: 500>、<jp level: 10>、<jp skills: 12,15>；Enemy Note：<jp gain 30>。
# 【FS 注意】本頁只提供 Job System 基底；技能等級實際成長另由 YEZ Job System: Skill Levels 與 FS BattleFormula 等後續系統共同影響。
# 【來源】Yanfly Engine Zealous；完整原始更新紀錄／英文說明保存於 Phase 16 Archive。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本頁所有維護說明集中於腳本最前方；下方程式識別字、Notetag、Action Key、方法名不可翻譯改名。
# 2. 原作者、版本、Credits、License、網址等來源資訊保留；完整翻譯前原稿另存 Phase 16 Archive。
# 3. 範例只使用原文件已明示的 API／Notetag，或由既有方法簽章可直接證實的呼叫方式。
# 4. 本輪只改註解／說明，不改任何可執行 Ruby；載入順序仍以 FS LoadOrder Guide／Authority Map 為準。
#==============================================================================
$imported = {} if $imported == nil
$imported["JobSystemBase"] = true

module YEZ
  module JOB
    
    #===========================================================================
    # 基本設定
    # --------------------------------------------------------------------------
    #===========================================================================
    
    LEARN_TITLE  = ""
    
    LEARN_ENABLE_SWITCH = 44
    
    JP_NAME = "技能點"
    JP_ICON = 145
    
    JP_MAX  = 999999999
    JP_COST = 500
    JP_SIZE = 16
    
    LEARN_SOUND = RPG::SE.new("Key", 80, 100)
    
    LEARN_VOCAB ={
      :learned_jp   => "已學",
      :learned_data => "已習得",
      :requirements => "需求",
      :jp_cost      => "技能點數",
      :level        => "等級",
    } # 此結構不可刪除。
    
    REQUIRE_SIZE = 16
    REQUIRE_BAD  = 2
    LEVEL_ICON   = 62
    
    #===========================================================================
    # 職業設定
    # --------------------------------------------------------------------------
    # Class ID 0 的技能清單可供所有職業學習。
    #===========================================================================
    
    CLASS_SKILLS ={
      0 => [],
      1 => [],
      #1 => [2,3,6..8,10..14,17..21,23,25..31,34..38,473],
      2 => [41,42,43,44,45,46,47,50..54,57..61,72,73],#艾卓
      5 => [201,208,209,210,212..221,225..230,234..240,242],#艾薇
    } # 此結構不可刪除。
    
    #===========================================================================
    # 戰鬥設定
    # --------------------------------------------------------------------------
    #===========================================================================
    
    # 若 Enemy 使用 <jp gain n>，則以 Notetag 指定值取代預設值。
    DEFAULT_ENEMY_JP = 20
    
    JP_GAIN_ACTIONS ={
      :attack   => 6,
      :attack_r => 3,
      :defend   => 6,
      :defend_r => 3,
      :skill    => 10,
      :skill_r  => 5,
      :item     => 10,
      :item_r   => 5,
      :level    => 50,
      :level_r  => 10,
    } # 此結構不可刪除。
    
    JP_VICTORY_MESSAGE = "%s 獲得 %s 技能點!"
    
    JP_GAINED  = "%+d"
    JP_COLOUR  = 3
    JP_MESSAGE = "Acquired %d JP from battle."
    
  end
end

#===============================================================================
#===============================================================================

module YEZ::JOB
  module_function
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def convert_integer_array(array)
    result = []
    array.each { |i|
      case i
      when Range; result |= i.to_a
      when Integer; result |= [i]
      end }
    return result
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def full_convert_hash(hash)
    result = {}
    hash.each { |key|
      result[key[0]] = convert_integer_array(key[1]) }
    return result
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  CLASS_SKILLS_LIST = full_convert_hash(CLASS_SKILLS)
  
end # YEZ::JOB

module YEZ
  module REGEXP
    module BASEITEM
      
      JP_COST   = /<(?:JP_COST|jp cost):[ ]*(\d+)>/i
      JP_LEVEL  = /<(?:JP_LEVEL|jp level):[ ]*(\d+)>/i
      JP_SKILLS = /<(?:JP_SKILL|jp skill|jp skills):[ ]*(\d+(?:\s*,\s*\d+)*)>/i
      JP_PASSIVES = /<(?:JP_PASSIVE|jp passive|jp passives):[ ]*(\d+(?:\s*,\s*\d+)*)>/i
      JP_SWITCH = /<(?:JP_SWITCH|jp switch|jp switches):[ ]*(\d+(?:\s*,\s*\d+)*)>/i
      JP_GROWTH = /<(?:JP_GROWTH|jp growth)[ ]*([\+\-]\d+)>/i
      
      LEVEL_AT  = /<(?:JP_SKILL|jp skill)[ ](\d+)[ ](?:AT_LEVEL|at level)[ ]*(\d+)>/i
      
    end
    module STATE
      
      JP_RATE   = /<(?:JP_RATE|jp rate)[ ]*(\d+)([%％])>/i
      
    end
    module ENEMY
      
      JP_GAIN   = /<(?:JP_GAIN|jp gain)[ ]*(\d+)>/i
      
    end
  end
end

#===============================================================================
# RPG::BaseItem
#===============================================================================

class RPG::BaseItem
  
  #--------------------------------------------------------------------------
  # 共用快取：yez_cache_baseitem_jpbase
  #--------------------------------------------------------------------------
  def yez_cache_baseitem_jpbase
    @jp_cost = YEZ::JOB::JP_COST; @jp_level = 0; @jp_growth = 0
    @jp_skills = []; @jp_switches = []; @level_at = {}; @jp_passives = []
    
    self.note.split(/[\r\n]+/).each { |line|
      case line
      #---
      when YEZ::REGEXP::BASEITEM::JP_COST
        @jp_cost = $1.to_i
      #---
      when YEZ::REGEXP::BASEITEM::JP_LEVEL
        @jp_level = $1.to_i
      #---
      when YEZ::REGEXP::BASEITEM::JP_SKILLS
        $1.scan(/\d+/).each { |num| 
        @jp_skills.push(num.to_i) if num.to_i > 0 }
      #---
      when YEZ::REGEXP::BASEITEM::JP_PASSIVES
        $1.scan(/\d+/).each { |num| 
        @jp_passives.push(num.to_i) if num.to_i > 0 }
      #---
      when YEZ::REGEXP::BASEITEM::JP_SWITCH
        $1.scan(/\d+/).each { |num| 
        @jp_switches.push(num.to_i) if num.to_i > 0 }
      #---
      when YEZ::REGEXP::BASEITEM::JP_GROWTH
        @jp_growth = $1.to_i
      #---
      when YEZ::REGEXP::BASEITEM::LEVEL_AT
        @level_at[$1.to_i] = $2.to_i
      #---
      end
    } # end self.note.split
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：jp_cost
  #--------------------------------------------------------------------------
  def jp_cost
    yez_cache_baseitem_jpbase if @jp_cost == nil
    return @jp_cost
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：jp_level
  #--------------------------------------------------------------------------
  def jp_level
    yez_cache_baseitem_jpbase if @jp_level == nil
    return @jp_level
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：jp_skills
  #--------------------------------------------------------------------------
  def jp_skills
    yez_cache_baseitem_jpbase if @jp_skills == nil
    return @jp_skills
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：jp_passives
  #--------------------------------------------------------------------------
  def jp_passives
    yez_cache_baseitem_jpbase if @jp_passives == nil
    return @jp_passives
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：jp_switches
  #--------------------------------------------------------------------------
  def jp_switches
    yez_cache_baseitem_jpbase if @jp_switches == nil
    return @jp_switches
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：jp_growth
  #--------------------------------------------------------------------------
  def jp_growth
    yez_cache_baseitem_jpbase if @jp_growth == nil
    return @jp_growth
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：level_at
  #--------------------------------------------------------------------------
  def level_at
    yez_cache_baseitem_jpbase if @level_at == nil
    return @level_at
  end
  
end # RPG::BaseItem

#===============================================================================
# RPG::State
#===============================================================================

class RPG::State
  
  #--------------------------------------------------------------------------
  # 共用快取：yez_cache_state_jpbase
  #--------------------------------------------------------------------------
  def yez_cache_state_jpbase
    @jp_rate = 100
    
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when YEZ::REGEXP::STATE::JP_RATE
        @jp_rate = $1.to_i
      end
    } # end self.note.split
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：jp_rate
  #--------------------------------------------------------------------------
  def jp_rate
    yez_cache_state_jpbase if @jp_rate == nil
    return @jp_rate
  end
  
end # RPG::State

#===============================================================================
# RPG::Enemy
#===============================================================================

class RPG::Enemy
  
  #--------------------------------------------------------------------------
  # 共用快取：yez_cache_enemy_jpbase
  #--------------------------------------------------------------------------
  def yez_cache_enemy_jpbase
    @jp_gain = YEZ::JOB::DEFAULT_ENEMY_JP
    
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when YEZ::REGEXP::ENEMY::JP_GAIN
        @jp_gain = $1.to_i
      end
    } # end self.note.split
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：jp_gain
  #--------------------------------------------------------------------------
  def jp_gain
    yez_cache_enemy_jpbase if @jp_gain == nil
    return @jp_gain
  end
  
end # RPG::Enemy

#===============================================================================
# Game_Battler
#===============================================================================

class Game_Battler
  
  #--------------------------------------------------------------------------
  # alias 方法：item_test
  #--------------------------------------------------------------------------
  alias item_test_jpbase item_test unless $@
  def item_test(user, item)
    return true if item.jp_growth != 0
    return item_test_jpbase(user, item)
  end
  
  #--------------------------------------------------------------------------
  # alias 方法：item_growth_effect
  #--------------------------------------------------------------------------
  alias item_growth_effect_jpbase item_growth_effect unless $@
  def item_growth_effect(user, item)
    gain_jp(item.jp_growth) if item.jp_growth != 0 and self.actor?
    item_growth_effect_jpbase(user, item)
  end
  
end # Game_Battler

#===============================================================================
# Game_Actor
#===============================================================================

class Game_Actor < Game_Battler
  
  #--------------------------------------------------------------------------
  # 公開實例變數
  #--------------------------------------------------------------------------
  attr_accessor :class_jp
  attr_accessor :jp_counter
  
  #--------------------------------------------------------------------------
  # alias 方法：setup
  #--------------------------------------------------------------------------
  alias setup_actor_jpbase setup unless $@
  def setup(actor_id)
    setup_actor_jpbase(actor_id)
    @class_jp = {}
    @class_jp[@class_id] = 0
  end
  
  #--------------------------------------------------------------------------
  # alias 方法：level_up
  #--------------------------------------------------------------------------
  alias level_up_jpbase level_up unless $@
  def level_up
    level_up_jpbase
    random = rand(YEZ::JOB::JP_GAIN_ACTIONS[:level_r])
    gain_jp(random + YEZ::JOB::JP_GAIN_ACTIONS[:level])
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：class_jp
  #--------------------------------------------------------------------------
  def class_jp
    @class_jp = {} if @class_jp == nil
    for i in 1..$data_classes.size
      @class_jp[i] = 0 if @class_jp[i] == nil
    end
    return @class_jp
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：gain_jp
  #--------------------------------------------------------------------------
  def gain_jp(value, class_id = @class_id)
    for state in states; value *= state.jp_rate / 100.0; end
    if $game_temp.in_battle
      @jp_counter = 0 if @jp_counter == nil
      @jp_counter += Integer(value)
    end
    class_jp[class_id] += Integer(value)
    class_jp[class_id] = [[class_jp[class_id], YEZ::JOB::JP_MAX].min, 0].max
    return unless $imported["JobSystemClasses"]
    return unless class_id == @class_id
    return unless (subclass_id != 0)
    value = Integer(YEZ::JOB::SUBCLASS_JP_MULTIPLIER * value)
    class_jp[subclass_id] += Integer(value)
    class_jp[subclass_id] = [[class_jp[subclass_id], YEZ::JOB::JP_MAX].min, 0].max
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：lose_jp
  #--------------------------------------------------------------------------
  def lose_jp(value, class_id = @class_id)
    class_jp[class_id] -= value
    class_jp[class_id] = [[class_jp[class_id], YEZ::JOB::JP_MAX].min, 0].max
  end
  
end # Game_Actor

#===============================================================================
# Game_Enemy
#===============================================================================

class Game_Enemy < Game_Battler
  
  #--------------------------------------------------------------------------
  # alias 方法：perform_collapse
  #--------------------------------------------------------------------------
  alias perform_collapse_jpbase perform_collapse unless $@
  def perform_collapse
    if $game_temp.in_battle and dead?
      for member in $game_party.existing_members
        member.gain_jp(enemy.jp_gain)
      end
    end
    perform_collapse_jpbase
  end
  
end # Game_Enemy

#===============================================================================
# Game_Party
#===============================================================================

class Game_Party < Game_Unit
  
  #--------------------------------------------------------------------------
  # alias 方法：setup_starting_members
  #--------------------------------------------------------------------------
  alias setup_starting_members_jpbase setup_starting_members unless $@
  def setup_starting_members
    setup_starting_members_jpbase
    $game_switches[YEZ::JOB::LEARN_ENABLE_SWITCH] = true
  end
  
end # Game_Party

#===============================================================================
# Scene_Skill
#===============================================================================

class Scene_Skill < Scene_Base
  
  #--------------------------------------------------------------------------
  # 新增方法：start_learnskill_selection
  #--------------------------------------------------------------------------
  def start_learnskill_selection
    @learnskill_window.y = @status_window.height
    @learnskill_window.y += @help_window.height if @help_window.visible
    @learnskill_window.active = true
    @command_window.active = false
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：update_learnskill_selection
  #--------------------------------------------------------------------------
  def update_learnskill_selection
    @learnskill_window.update
    if @last_learnskill_index != @learnskill_window.index
      @last_learnskill_index = @learnskill_window.index
      @learndata_window.refresh(@learnskill_window.skill, @status_window.class)
    end
    if Input.trigger?(Input::B)
      Sound.play_cancel
      if @class_window != nil
        @class_window.y = @learnskill_window.y
        @class_window.active = true
        @class_window.update_help
        @classdata_window.y = @class_window.y
        @learnskill_window.active = false
        @learnskill_window.y = 416*3
        @learndata_window.y = 416*3
      else
        @learnskill_window.active = false
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
      @learnskill_window.refresh
      @learndata_window.refresh(@learnskill_window.skill, @status_window.class)
    elsif $TEST and Input.repeat?(Input::F7)
      Sound.play_equip
      value = YEZ::JOB::JP_COST * 10
      value *= 10 if Input.press?(Input::SHIFT)
      @actor.lose_jp(value + rand(value), @status_window.class)
      @status_window.refresh
      @learnskill_window.refresh
      @learndata_window.refresh(@learnskill_window.skill, @status_window.class)
    elsif $TEST and Input.repeat?(Input::F5)
      skill = @learnskill_window.skill
      return if skill == nil
      YEZ::JOB::LEARN_SOUND.play
      @actor.learn_skill(skill.id)
      @status_window.refresh
      @learnskill_window.refresh
      @learndata_window.refresh(skill, @status_window.class)
    elsif Input.trigger?(Input::C)
      skill = @learnskill_window.skill
      if skill == nil or !@learnskill_window.enabled_skill?(skill)
        Sound.play_buzzer
        return
      end
      YEZ::JOB::LEARN_SOUND.play
      @actor.learn_skill(skill.id)
      @actor.lose_jp(skill.jp_cost, @status_window.class)
      @status_window.refresh
      @learnskill_window.refresh
      @learndata_window.refresh(skill, @status_window.class)
    end
  end
  
end # Scene_Skill

#===============================================================================
# Scene_Battle
#===============================================================================

class Scene_Battle < Scene_Base
  
  #--------------------------------------------------------------------------
  # alias 方法：process_battle_start
  #--------------------------------------------------------------------------
  alias process_battle_start_jpbase process_battle_start unless $@
  def process_battle_start
    process_battle_start_jpbase
    for member in $game_party.members; member.jp_counter = 0; end
  end
    
  #--------------------------------------------------------------------------
  # alias 方法：execute_action_attack
  #--------------------------------------------------------------------------
  alias execute_action_attack_jpbase execute_action_attack unless $@
  def execute_action_attack
    if @active_battler.actor?
      random = rand(YEZ::JOB::JP_GAIN_ACTIONS[:attack_r])
      @active_battler.gain_jp(random + YEZ::JOB::JP_GAIN_ACTIONS[:attack])
    end
    execute_action_attack_jpbase
  end
  
  #--------------------------------------------------------------------------
  # alias 方法：execute_action_guard
  #--------------------------------------------------------------------------
  alias execute_action_guard_jpbase execute_action_guard unless $@
  def execute_action_guard
    if @active_battler.actor?
      random = rand(YEZ::JOB::JP_GAIN_ACTIONS[:defend_r])
      @active_battler.gain_jp(random + YEZ::JOB::JP_GAIN_ACTIONS[:defend])
    end
    execute_action_guard_jpbase
  end
  
  #--------------------------------------------------------------------------
  # alias 方法：execute_action_skill
  #--------------------------------------------------------------------------
  unless $imported["CustomSkillEffectsZeal"]
  alias execute_action_skill_jpbase execute_action_skill unless $@
  def execute_action_skill
    if @active_battler.actor?
      random = rand(YEZ::JOB::JP_GAIN_ACTIONS[:skill_r])
      @active_battler.gain_jp(random + YEZ::JOB::JP_GAIN_ACTIONS[:skill])
    end
    execute_action_skill_jpbase
  end  
  end
  
  #--------------------------------------------------------------------------
  # alias 方法：execute_action_item
  #--------------------------------------------------------------------------
  alias execute_action_item_jpbase execute_action_item unless $@
  def execute_action_item
    if @active_battler.actor?
      random = rand(YEZ::JOB::JP_GAIN_ACTIONS[:item_r])
      @active_battler.gain_jp(random + YEZ::JOB::JP_GAIN_ACTIONS[:item])
    end
    execute_action_item_jpbase
  end
  
  #--------------------------------------------------------------------------
  # alias 方法：display_exp_and_gold
  #--------------------------------------------------------------------------
  alias display_exp_and_gold_jpbase display_exp_and_gold unless $@
  def display_exp_and_gold
    display_exp_and_gold_jpbase
    if $imported["VictoryAftermath"] and YEZ::VICTORY::ENABLE_QUOTES
      show_jp_gained unless $game_switches[YEZ::VICTORY::SKIP_VICTORY_SWITCH]
    else
      for member in $game_party.members
        text = sprintf(YEZ::JOB::JP_VICTORY_MESSAGE, member.name, member.jp_counter)
        $game_message.texts.push(text)
      end
      wait_for_message
    end
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：show_jp_gained
  #--------------------------------------------------------------------------
  def show_jp_gained
    @exp_front_window.visible = false
    jp_total = 0
    for member in $game_troop.members
      next unless member.dead?
      jp_total += member.enemy.jp_gain
    end
    text = sprintf(YEZ::JOB::JP_MESSAGE, jp_total)
    @top_window.set_text(text, 1)
    @jp_gained_window = Window_JP_Victory.new
    if YEZ::VICTORY::ENABLE_QUOTES
      victory_actor_quote("JP")
    else
      for member in $game_party.members
        text = sprintf(YEZ::JOB::JP_VICTORY_MESSAGE, member.name, member.jp_counter)
        $game_message.texts.push(text)
      end
      wait_for_message
    end
    @jp_gained_window.dispose if @jp_gained_window != nil
    @jp_gained_window = nil
  end
  
end # Scene_Battle

#===============================================================================
# Window_JP_Victory
#===============================================================================

class Window_JP_Victory < Window_Base
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize
    super(0, 112, 544, 176)
    self.opacity = 0
    refresh
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    sw = self.width - 32
    dy = WLH*4
    dx = (sw/2) - $game_party.members.size*60
    for actor in $game_party.members
      self.contents.font.color = normal_color
      self.contents.font.size = Font.default_size
      draw_jp_earned(actor, dx, dy)
      dx += 120
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_jp_earned(actor, dx, dy)
    self.contents.font.color = text_color(YEZ::JOB::JP_COLOUR)
    icon = $imported["Icons"] ? YEZ::ICONS[:txtjp] : YEZ::JOB::JP_ICON
    draw_icon(icon, dx+84, dy)
    text = sprintf(YEZ::JOB::JP_GAINED, actor.jp_counter)
    self.contents.draw_text(dx, dy, 84, WLH, text, 2)
    dy += WLH
    draw_icon(icon, dx+84, dy)
    self.contents.font.color = normal_color
    text = actor.class_jp[actor.class_id]
    self.contents.draw_text(dx, dy, 84, WLH, text, 2)
  end
  
end # Window_JP_Victory

#===============================================================================
# Window_JP_Actor
#===============================================================================

class Window_JP_Actor < Window_Base
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize(actor)
    super(160, 0, 384, 128)
    @actor = actor
    refresh(@actor.class_id)
  end
  
  #--------------------------------------------------------------------------
  # class
  #--------------------------------------------------------------------------
  def class; return @class_id; end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh(class_id = nil)
    self.contents.clear
    @class_id = class_id if class_id != nil
    draw_actor_face(@actor, 0, 0, size = 96)
    #contents.fill_rect(0, 0, 84, 84, Color.new(0,0,0,200))
    #draw_face(@actor.face_name, @actor.face_index, 2, 2, 80)
    x = 104
    y = 0
    draw_actor_name(@actor, x, y)
#    draw_actor_class(@actor, x + 120, y)
    draw_actor_level(@actor, x, y + WLH * 1)
#    draw_actor_state(@actor, x, y + WLH * 2)
#    draw_stun_indicator(x, y + WLH * 3, @actor) if $imported["ClassStatDUR"]
    draw_actor_hp(@actor, x + 0, y +20 + WLH * 1, 120)
    draw_actor_mp(@actor, x + 0, y +20 + WLH * 2, 120)
    draw_actor_jp(@actor, x + 10, y -71 + WLH * 3, 120)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_actor_jp(actor, dx, dy, dw = 120)
    return if @class_id == nil
    icon = $imported["Icons"] ? YEZ::ICONS[:txtjp] : YEZ::JOB::JP_ICON
    draw_icon(icon, dx + dw - 24, dy)
    text = @actor.class_jp[@class_id]
    self.contents.draw_text(dx, dy, dw - 24, WLH, text, 2)
  end
  
end # Window_JP_Actor

#===============================================================================
# Window_LearnSkill
#===============================================================================

class Window_LearnSkill < Window_Selectable
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize(dx, dy, actor)
    super(dx, dy, 274, 416 - dy)###
    self.opacity = 0
    @actor = actor
    @column_max = 1
    self.index = 0
    refresh(@actor.class_id)
  end
  
  #--------------------------------------------------------------------------
  # class
  #--------------------------------------------------------------------------
  def class; return @class_id; end
    
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def skill; return @data[self.index]; end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh(class_id = nil)
    if class_id != nil
      @class_id = class_id
      self.index = 0
      @data = nil
    end
    if @data == nil
      @data = []
      skills = YEZ::JOB::CLASS_SKILLS_LIST[0]
      skills += YEZ::JOB::CLASS_SKILLS_LIST[@class_id] if
        YEZ::JOB::CLASS_SKILLS_LIST.include?(@class_id)
      if $imported["JobSystemClasses"]
        skills += YEZ::JOB::PRIMARY_ONLY_SKILLS_LIST[@class_id] if
          YEZ::JOB::PRIMARY_ONLY_SKILLS_LIST.include?(@class_id) and
          @actor.unlocked_1stclasses.include?(@class_id)
        skills += YEZ::JOB::SUBCLASS_ONLY_SKILLS_LIST[@class_id] if
          YEZ::JOB::SUBCLASS_ONLY_SKILLS_LIST.include?(@class_id) and
          @actor.unlocked_subclasses.include?(@class_id)
      end
      for skill_id in skills
        skill = $data_skills[skill_id]
        next unless include?(skill)
        @data.push(skill)
      end
    end
    @data.sort! { |a,b| a.id <=> b.id }
    @item_max = @data.size
    create_contents
    for i in 0...@item_max
      draw_item(i)
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def include?(skill)
    return false if skill == nil
    return true if @actor.skill_learn?(skill)
    return false if skill.jp_cost <= 0
    for switch_id in skill.jp_switches
      return false unless $game_switches[switch_id]
    end
    if $imported["JobSystemSkillLevels"]
      for key in skill.level_at
        return false if key[1] > @actor.skill_level(key[0])
      end
    end
    return true
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_item(index)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    self.contents.font.size = Font.default_size
    skill = @data[index]
    return if skill == nil
    enabled = enabled_skill?(skill)
    draw_item_name11(skill, rect.x, rect.y, enabled)
    draw_jp_cost(skill, rect.x + 196, rect.y, enabled)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_jp_cost(skill, dx, dy, enabled)
    dw = self.width - 32 - dx
    self.contents.font.size = YEZ::JOB::JP_SIZE
    if @actor.skill_learn?(skill)
      text = YEZ::JOB::LEARN_VOCAB[:learned_jp]
      self.contents.draw_text(dx, dy, dw-4, WLH, text, 2)
    else
      icon = $imported["Icons"] ? YEZ::ICONS[:txtjp] : YEZ::JOB::JP_ICON
      draw_icon(icon, dx + dw - 24, dy, enabled)
      text = skill.jp_cost
      self.contents.draw_text(dx, dy, dw - 24, WLH, text, 2)
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def enabled_skill?(skill)
    return false if @actor.class_jp[@class_id] < skill.jp_cost
    return false if @actor.level < skill.jp_level
    return false if @actor.skill_learn?(skill)
    for skill_id in skill.jp_skills
      return false unless @actor.skill_learn?($data_skills[skill_id])
    end
    if $imported["JobSystemPassives"]
      for state_id in skill.jp_passives
        return false unless @actor.learned_passives.include?(state_id)
      end
    end
    return true
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_text(skill == nil ? "" : skill.description)
  end
  
end # Window_LearnSkill

#===============================================================================
# Window_LearnData
#===============================================================================

class Window_LearnData < Window_Base
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize(x, y, skill, actor, class_id)
    super(x, y, 544 - x, 416 - y)
    self.opacity = 0
    @actor = actor
    @class_id = class_id
    refresh(skill, class_id)
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
    self.contents.font.size = YEZ::JOB::REQUIRE_SIZE
    if @actor.skill_learn?(@skill)
      text = YEZ::JOB::LEARN_VOCAB[:learned_data]
      self.contents.draw_text(0, WLH * 1, self.width-32, WLH, text, 1)
    else
      self.contents.font.color = system_color
      text = YEZ::JOB::LEARN_VOCAB[:requirements]
      self.contents.draw_text(0, WLH * 1, self.width-32, WLH, text, 1)
    end
    dy = WLH*2
    dy = draw_jp_cost(dy)
    dy = draw_jp_level(dy)
    dy = draw_jp_skills(dy)
    dy = draw_jp_passives(dy)
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
  def draw_jp_cost(dy)
    return dy if @skill.jp_cost <= 0
    draw_icon(YEZ::JOB::JP_ICON, 0, dy)
    self.contents.font.color = system_color
    text = YEZ::JOB::LEARN_VOCAB[:jp_cost]
    self.contents.draw_text(24, dy, self.width-56, WLH, text)
    if @actor.class_jp[@class_id] >= @skill.jp_cost or @actor.skill_learn?(@skill)
      self.contents.font.color = normal_color
    else
      self.contents.font.color = text_color(YEZ::JOB::REQUIRE_BAD)
    end
    self.contents.draw_text(24, dy, self.width-60, WLH, @skill.jp_cost, 2)
    return (dy + WLH)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_jp_level(dy)
    return dy if @skill.jp_level <= 0
    draw_icon(YEZ::JOB::LEVEL_ICON, 0, dy)
    self.contents.font.color = system_color
    text = YEZ::JOB::LEARN_VOCAB[:level]
    self.contents.draw_text(24, dy, self.width-56, WLH, text)
    if @actor.level >= @skill.jp_level or @actor.skill_learn?(@skill)
      self.contents.font.color = normal_color
    else
      self.contents.font.color = text_color(YEZ::JOB::REQUIRE_BAD)
    end
    self.contents.draw_text(24, dy, self.width-60, WLH, @skill.jp_level, 2)
    return (dy + WLH)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_jp_skills(dy)
    return dy if @skill.jp_skills == []
    for skill_id in @skill.jp_skills
      skill = $data_skills[skill_id]
      next if skill == nil
      draw_icon(skill.icon_index, 0, dy)
      if @actor.skill_learn?(@skill) or @actor.skill_learn?(skill)
        self.contents.font.color = normal_color
      else
        self.contents.font.color = text_color(YEZ::JOB::REQUIRE_BAD)
      end
      self.contents.draw_text(24, dy, 172, WLH, skill.name)
      dy += WLH
    end
    return dy
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_jp_passives(dy)
    return dy unless $imported["JobSystemPassives"]
    return dy if @skill.jp_passives == []
    for state_id in @skill.jp_passives
      state = $data_states[state_id]
      next if state == nil
      draw_icon(state.icon_index, 0, dy)
      if @actor.learned_passives.include?(state_id) or 
      @actor.skill_learn?(@skill)
        self.contents.font.color = normal_color
      else
        self.contents.font.color = text_color(YEZ::JOB::REQUIRE_BAD)
      end
      self.contents.draw_text(24, dy, 172, WLH, state.name)
      dy += WLH
    end
    return dy
  end
  
end # Window_LearnData

#===============================================================================
# 
# 
#===============================================================================