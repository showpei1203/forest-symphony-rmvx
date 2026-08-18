#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：YEM Main Menu Melody
# 【用途】Yanfly Engine Melody 主選單框架。負責選單命令排序、自訂 Common Event／Imported Scene 指令、多變數資訊窗與大量 KGC／YERD 相容入口；FS 又在其上做了自訂圖像化 Menu。
# 【版本／來源】Yanfly Engine Melody - Main Menu Melody；Last Date Updated: 2010.06.13。原作者說明指出概念延伸自 KGC Custom Menu Command。
# 【主要設定】MENU_COMMANDS 決定順序；USE_ICONS／MENU_ICONS 控制圖示；MAX_ROWS、ALIGN、MENU_RIGHT_SIDE、ON_SCREEN_MENU 控制基本版面。
# 【內建 Command Symbol】可使用 :items、:skill、:equip、:status、:save、:system；並支援 :kgc_largeparty、:kgc_apviewer、:kgc_skillcp、:kgc_difficulty、:kgc_distribute、:kgc_enemyguide、:kgc_outline 與部分 YERD command（需對應腳本存在）。
# 【Common Event】COMMON_EVENTS 的格式：symbol => [HideSw, DisbSw, Debug?, CommonEventID, Icon, Title]。把 symbol 同時加入 MENU_COMMANDS 才會出現。
# 【Imported Scene】IMPORTED_COMMANDS 的格式：symbol => [HideSw, DisbSw, Actor?, Icon, Title, SceneName]；SceneName 目前以字串指定，例如 "Scene_Quest"。HideSw／DisbSw 設 nil 表示不使用該 Switch。
# 【Multi Variable Window】USE_MULTI_VARIABLE_WINDOW 啟用下方資訊窗；VARIABLES_SHOWN 決定顯示順序，0=金錢，負值為內建 Time／Steps／Map 等資訊，正值為遊戲變數；VARIABLES_HASH 設定圖示與文字。
# 【測試捷徑】原文件定義：$TEST／$BTEST 下，主選單開啟時按 F5 可將全隊 HP／MP 補滿。此為 Debug 行為，不應當成正式玩家功能。
# 【FS 圖像化 Menu】本頁目前直接建立 Graphics/System/menus/menu01～menu08 等圖像，並有專案自訂座標／Sprite 流程。修改 Menu 外觀時先反查後方 Ring Menu／FS Integration，避免把 YEM Base 當成唯一 UI Authority。
# 【呼叫方式】通常由 Scene_Map 開啟 Scene_Menu，自動建立命令。新增選單 Scene 應先在 IMPORTED_COMMANDS 登記，再把 symbol 加到 MENU_COMMANDS；不要直接在 Window_MenuCommand 硬插 index。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 維護說明集中於腳本最前方；程式識別字、Notetag、Script Call、Action Key 不可翻譯改名。
# 2. 原作者、版本、Credits、License、網址等來源資訊保留；翻譯前 byte-exact 原稿另存 Phase 17 Archive。
# 3. 範例只列原文件或既有程式能直接證實的入口，不捏造 API。
# 4. 本輪除註解／說明外不修改任何可執行 Ruby；載入順序仍以 FS LoadOrder Guide／Authority Map 為準。
#==============================================================================
#===============================================================================
# 
# Yanfly Engine Melody - Main Menu Melody
# Last Date Updated: 2010.06.13
# 
# 
#===============================================================================
# -----------------------------------------------------------------------------
#===============================================================================
# -----------------------------------------------------------------------------
# 
# 
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
#===============================================================================

$imported = {} if $imported == nil
$imported["MainMenuMelody"] = true

module YEM
  module MENU
    
    #===========================================================================
    # -------------------------------------------------------------------------
    # 
    # 
    # 
    # 
    # 
    #===========================================================================
    MENU_COMMANDS =[ # 依照上方說明設定。
      :items,          # 預設道具選單
      :status,         # 預設狀態選單
      :skill,          # 預設技能選單
      :equip,          # 預設裝備選單
      :kgc_largeparty ,
      :quests1,
      :save,           # 預設存檔選單
      :system,         # 預設結束遊戲選單
    ] # 此結構不可刪除。
    
    USE_ICONS = false
    
    MENU_ICONS ={ # 若未指定圖示，會使用 unused 的備用圖示。
      :unused => 8678,
      :items  => 8677,
      :skill  => 8675,
      :equip  => 8673,
      :status => 8680,
      :save   => 8686,
      :system => 8687,
    } # 此結構不可刪除。
    
    MAX_ROWS = 10
    
    ALIGN = 1
    
    MENU_RIGHT_SIDE = false
    
    ON_SCREEN_MENU = false
    
    #===========================================================================
    # -------------------------------------------------------------------------
    # 
    #===========================================================================
    COMMON_EVENTS ={ # 依照上方說明設定。
      :event1  => [   nil,    nil,   true,     11,  101, "Debug"],
      :event2  => [   nil,    nil,  false,     12,  117, "Camp"],
    } # 此結構不可刪除。
      
    #===========================================================================
    # -------------------------------------------------------------------------
    # 
    # $scene = Scene_Quest.new
    #===========================================================================
    IMPORTED_COMMANDS ={ # 依照上方說明設定。
     :party  => [     nil,   nil,  false,   8678,   "Party", "Scene_Party"],
     :quests1=> [     nil,   nil,  false,  8688,   "      ", "Scene_Quest"],
     :faction => [    10,     11,  false,  100, "Factions", "Scene_Factions"],
     :row     => [   nil,    nil,  false,  101,     "Rows", "Scene_Row"],
     :record  => [   nil,    nil,  false,  102,  "Records", "Scene_Record"],
     :craft   => [   nil,    nil,  false,  103, "Crafting", "Scene_Crafting"],
    } # 此結構不可刪除。
    
    #===========================================================================
    # -------------------------------------------------------------------------
    #===========================================================================
    USE_MULTI_VARIABLE_WINDOW = true
    
    VARIABLES_SHOWN = [-5, 1, 0]
    VARIABLES_ICONS = false
    VARIABLES_HASH  ={ # 注意：索引 0 必須存在。
          -5 => [ 153, "Map"],
          -2 => [  48, "Steps"],
          -1 => [ 188, "Time"],
           0 => [ 205, "Cr."],
    }# 此結構不可刪除。
    
  end
end

#===============================================================================
#===============================================================================

#===============================================================================
#===============================================================================

class Scene_Menu < Scene_Base
  
  #--------------------------------------------------------------------------
  # 新增方法：create_command_list
  #--------------------------------------------------------------------------
  def create_command_list
    vocab = []
    commands = []
    icons = []
    index_list = {}
    YEM::MENU::MENU_COMMANDS.each_with_index { |c,i|
      case c
      when :items
        index_list[:items] = commands.size
        vocab.push("")#vocab.push(Vocab.item)
        
      when :skill
        index_list[:skill] = commands.size
        vocab.push(" ")#vocab.push(Vocab.skill)
        
      when :equip
        index_list[:equip] = commands.size
        vocab.push("  ")#vocab.push(Vocab.equip)
        
      when :status
        index_list[:status] = commands.size
        vocab.push("    ")#vocab.push(Vocab.status)
        
      when :save
        index_list[:save] = commands.size
        vocab.push("        ")#vocab.push(Vocab.save)
        
      when :system
        index_list[:system] = commands.size
        vocab.push(Vocab.game_end)
        
        
      when :kgc_largeparty
        next unless $imported["LargeParty"]
        index_list[:partyform] = commands.size
        @__command_partyform_index = commands.size
        vocab.push(Vocab.partyform)
        
      when :kgc_apviewer
        next unless $imported["EquipLearnSkill"]
        index_list[:ap_viewer] = commands.size
        @__command_ap_viewer_index = commands.size
        vocab.push(Vocab.ap_viewer)
        
      when :kgc_skillcp
        next unless $imported["SkillCPSystem"]
        index_list[:set_battle_skill] = commands.size
        @__command_set_battle_skill_index = commands.size
        vocab.push(Vocab.set_battle_skill)
        
      when :kgc_difficulty
        next unless $imported["BattleDifficulty"]
        index_list[:set_difficulty] = commands.size
        @__command_set_difficulty_index = commands.size
        vocab.push(KGC::BattleDifficulty.get[:name])
        
      when :kgc_distribute
        next unless $imported["DistributeParameter"]
        index_list[:distribute_parameter] = commands.size
        @__command_distribute_parameter_index = commands.size
        vocab.push(Vocab.distribute_parameter)
        
      when :kgc_enemyguide
        next unless $imported["EnemyGuide"]
        index_list[:enemy_guide] = commands.size
        @__command_enemy_guide_index = commands.size
        vocab.push(Vocab.enemy_guide)
        
      when :kgc_outline
        next unless $imported["Outline"]
        index_list[:outline] = commands.size
        @__command_outline_index = commands.size
        vocab.push(Vocab.outline)
        
        
      when :yerd_classchange
        next unless $imported["SubclassSelectionSystem"]
        next unless YE::SUBCLASS::MENU_CLASS_CHANGE_OPTION
        next unless $game_switches[YE::SUBCLASS::ENABLE_CLASS_CHANGE_SWITCH]
        index_list[:classchange] = commands.size
        @command_class_change = commands.size
        vocab.push(YE::SUBCLASS::MENU_CLASS_CHANGE_TITLE)

      when :yerd_learnskill
        next unless $imported["SubclassSelectionSystem"]
        next unless YE::SUBCLASS::USE_JP_SYSTEM and 
        YE::SUBCLASS::LEARN_SKILL_OPTION
        next unless $game_switches[YE::SUBCLASS::ENABLE_LEARN_SKILLS_SWITCH]
        index_list[:learnskill] = commands.size
        @command_learn_skill = commands.size
        vocab.push(YE::SUBCLASS::LEARN_SKILL_TITLE)
        
      when :yerd_equipslots
        next unless $imported["EquipSkillSlots"]
        next unless $game_switches[YE::EQUIPSKILL::ENABLE_SLOTS_SWITCH]
        index_list[:equipskill] = commands.size
        @command_equip_skill = commands.size
        vocab.push(YE::EQUIPSKILL::MENU_TITLE)
        
      when :yerd_bestiary
        next unless $imported["DisplayScannedEnemy"]
        next unless $game_switches[YE::MENU::MONSTER::BESTIARY_SWITCH]
        index_list[:bestiary] = commands.size
        @command_bestiary = commands.size
        vocab.push(YE::MENU::MONSTER::BESTIARY_TITLE)
        
      else
        if YEM::MENU::COMMON_EVENTS.include?(c)
          common_event = YEM::MENU::COMMON_EVENTS[c]
          next if !$TEST and common_event[2]
          next if common_event[0] != nil and $game_switches[common_event[0]]
          index_list[c] = commands.size
          vocab.push(common_event[5])
        elsif YEM::MENU::IMPORTED_COMMANDS.include?(c)
          command_array = YEM::MENU::IMPORTED_COMMANDS[c]
          next if command_array[0] != nil and $game_switches[command_array[0]]
          index_list[c] = commands.size
          vocab.push(command_array[4])
        else; next
        end
        
      end
      commands.push(c)
      icons.push(menu_icon(c))
    }
    $game_temp.menu_command_index = index_list
    @menu_array = [vocab, commands, icons]
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：menu_icon
  #--------------------------------------------------------------------------
  def menu_icon(command)
    if YEM::MENU::MENU_ICONS.include?(command)
      return YEM::MENU::MENU_ICONS[command]
    elsif YEM::MENU::COMMON_EVENTS.include?(command)
      return YEM::MENU::COMMON_EVENTS[command][4]
    elsif YEM::MENU::IMPORTED_COMMANDS.include?(command)
      return YEM::MENU::IMPORTED_COMMANDS[command][3]
    else
      return YEM::MENU::MENU_ICONS[:unused]
    end
  end
  
  #--------------------------------------------------------------------------
  # 覆寫方法： create_command_window這邊改大小
  #--------------------------------------------------------------------------
  def create_command_window
    create_command_list
    @command_window = Window_MenuCommand.new(@menu_array)
    @command_window.height = [@command_window.height,
      YEM::MENU::MAX_ROWS * 24 + 132].min#24 + 32
    @command_window.index = [@menu_index, @menu_array[0].size - 1].min
    @command_window.width = 160
    @command_window.height = 480
    @command_window.x = 14#-100#14
    @command_window.y = 0
    @command_window.opacity = 0
    @com_count = 11
    @com_count2 = 0
      
    @old_index = @menu_index
=begin
     case @menu_index
    when 0
      @pic_now = 0
      @command_window.contents = Bitmap.new("Graphics/System/menus/menu01")
    when 1
      @command_window.contents = Bitmap.new("Graphics/System/menus/menu02")
    when 2
      @command_window.contents = Bitmap.new("Graphics/System/menus/menu03")
    when 3
      @command_window.contents = Bitmap.new("Graphics/System/menus/menu04")
    when 4
      @command_window.contents = Bitmap.new("Graphics/System/menus/menu05")
    when 5
      @command_window.contents = Bitmap.new("Graphics/System/menus/menu06")
    when 6
      @command_window.contents = Bitmap.new("Graphics/System/menus/menu07")
    when 7
      @command_window.contents = Bitmap.new("Graphics/System/menus/menu08")
    end
=end
  @light2.x = @sprites[@command_window.index].x + rand(3) - 3
  @light2.y = @sprites[@command_window.index].y - 16 + rand(3) - 3 +14
  end
  
  #--------------------------------------------------------------------------
  # 覆寫方法：update_command_selection
  #--------------------------------------------------------------------------
  def update_command_selection
    ################################
    for i in 0..7
      @sprites[i].tone = Tone.new(0,0,0,255)
      @sprites[i].y = (i * @sprites[i].height*1.307 + (Graphics.height - @sprites[i].height)/1.5 )-171
      
      @sprites[i].color.set(255, 255, 255, 0) if Input.trigger?(Input::UP)
      @sprites[i].color.set(255, 255, 255, 0) if Input.trigger?(Input::DOWN)
      @sprites[i].y = (i * @sprites[i].height*1.307 + (Graphics.height - @sprites[i].height)/1.5 )-171  if Input.trigger?(Input::UP)
      @sprites[i].y = (i * @sprites[i].height*1.307 + (Graphics.height - @sprites[i].height)/1.5 )-171  if Input.trigger?(Input::DOWN)
    end
    @sprites[@command_window.index].tone = Tone.new(0,0,0)
    @com_count = 0 if Input.trigger?(Input::UP)
    @com_count = 0 if Input.trigger?(Input::DOWN)
    @com_count2 = 0 if Input.trigger?(Input::UP)
    @com_count2 = 0 if Input.trigger?(Input::DOWN)
    if @com_count <= 10
      @sprites[@command_window.index].color.set(255, 255, 255, 0) if @com_count == 9
      @sprites[@command_window.index].color.set(200, 255, 255, 160) if @com_count == 4
      @sprites[@command_window.index].y += 3 if @com_count == 9
      @sprites[@command_window.index].y -= 3 if @com_count == 0
      @com_count +=1
    end

    #if @com_count2 > 119
    #end
    @light2.opacity = rand(40) + 70# + 190
    @light2.x = @sprites[@command_window.index].x + rand(2) - 3
    @light2.y = @sprites[@command_window.index].y - 16 + rand(2) - 3 + 14

    #################################
    if Input.trigger?(Input::B)
      check_debug_enable
      Sound.play_cancel
      $scene = Scene_Map.new
    elsif $TEST and Input.trigger?(Input::F5)
      Sound.play_recovery
      for member in $game_party.members
        member.hp += member.maxhp
        member.mp += member.maxmp
      end
      @status_window.refresh
    elsif Input.trigger?(Input::C)
      @sprites[@command_window.index].color.set(200, 255, 255, 160)
      @sprites[@command_window.index].y = (@command_window.index * @sprites[@command_window.index].height*1.307 + (Graphics.height - @sprites[@command_window.index].height)/1.5 )-171
      command = @command_window.method
      case command
      when :items
        Sound.play_decision
        $scene = Scene_Item.new
      when :skill, :equip, :status
        Sound.play_decision
        start_actor_selection
      when :save
        if $game_system.save_disabled
          Sound.play_buzzer
        else
          Sound.play_decision
          $game_temp.menu_command_index[:save]
          $scene = Scene_File.new(true, false, false)
        end
      when :system
        Sound.play_decision
        $scene = Scene_End.new
      else
        if YEM::MENU::COMMON_EVENTS.include?(command)
          array = YEM::MENU::COMMON_EVENTS[command]
          if array[1] != nil and $game_switches[array[1]]
            Sound.play_buzzer
          else
            Sound.play_decision
            $game_temp.common_event_id = array[3]
            $scene = Scene_Map.new
          end
        elsif YEM::MENU::IMPORTED_COMMANDS.include?(command)
          array = YEM::MENU::IMPORTED_COMMANDS[command]
          if array[1] != nil and $game_switches[array[1]]
            Sound.play_buzzer
          else
            Sound.play_decision
            if array[2]
              start_actor_selection
            else
              $scene = eval(array[5] + ".new")
            end
          end
        end
        
      end # if case check
    end # end if
  end # end update_command_selection
  
  #--------------------------------------------------------------------------
  # 覆寫方法：update_actor_selection
  #--------------------------------------------------------------------------
  def update_actor_selection
    
      x = $game_party.members[@status_window.index]
      x_id = x.instance_variable_get(:@actor_id)
      @as_flame = 0 if Input.trigger?(Input::RIGHT)
      @as_flame = 0 if Input.trigger?(Input::LEFT)
      @as.bitmap = Cache.character("$actor01_1") if x_id == 1#喬伊
      @as.bitmap = Cache.character("$actor5_1") if x_id == 2#米亞
      @as.bitmap = Cache.character("$actor03_1") if x_id == 3#艾卓
      @as.bitmap = Cache.character("$Verna_1") if x_id == 4#薇娜
      @as.bitmap = Cache.character("$actor6_1") if x_id == 5#艾薇
      @as.bitmap = Cache.character("$actor40_1") if x_id == 6#泰勒
      @as.y = 235
      @as.x = 214 if @status_window.index ==0
      @as.x = 324 if @status_window.index ==1
      @as.x = 434 if @status_window.index ==2
      
       #####
      if @as_flame <= 60
       @as_flame = 0 if @as_flame == 60
       #$game_party.members[@status_window.index].state?(1)
       ##############
       j = 0
       j = 64 if $game_party.members[@status_window.index].state?(1)
       j = 64 if $game_party.members[@status_window.index].state?(2)
       j = 64 if $game_party.members[@status_window.index].state?(3)
       j = 64 if $game_party.members[@status_window.index].state?(4)
       j = 64 if $game_party.members[@status_window.index].state?(5)
       j = 64 if $game_party.members[@status_window.index].state?(6)
       j = 64 if $game_party.members[@status_window.index].state?(7)
       j = 64 if $game_party.members[@status_window.index].state?(8)
       j = 64 if $game_party.members[@status_window.index].state?(9)
       j = 64 if $game_party.members[@status_window.index].state?(10)
       j = 64 if $game_party.members[@status_window.index].state?(11)
       j = 64 if $game_party.members[@status_window.index].state?(12)
       #######
       #############
       @as.src_rect.set(0,  j, 32, 32) if @as_flame == 45
       @as.src_rect.set(32,  j, 32, 32) if @as_flame == 30
       @as.src_rect.set(64,  j, 32, 32) if @as_flame == 15
       @as.src_rect.set(32,  j, 32, 32) if @as_flame == 0
      @as_flame += 1
      end    #####


      
      if @cursor_flame <= 30
      @cursor_flame = 0 if @cursor_flame == 30
      @cursor.src_rect.set(0,  0, 32, 32) if @cursor_flame == 29
      @cursor.src_rect.set(0, 32, 32, 32) if @cursor_flame == 15
      @cursor_flame += 1
      end

      @cursor.x = 180 if @status_window.index ==0
      @cursor.x = 290 if @status_window.index ==1
      @cursor.x = 400 if @status_window.index ==2

    if Input.trigger?(Input::B)
      Sound.play_cancel
      end_actor_selection
      @status_window.close if YEM::MENU::ON_SCREEN_MENU
    elsif $TEST and Input.trigger?(Input::F5)
      Sound.play_recovery
      for member in $game_party.members
        member.hp += member.maxhp
        member.mp += member.maxmp
      end
      @status_window.refresh
    elsif Input.trigger?(Input::C)
      $game_party.last_actor_index = @status_window.index
      Sound.play_decision
      @as.dispose
      @cursor.dispose
      command = @command_window.method
      case command
      when :skill
        $scene = Scene_Skill.new(@status_window.index)
      when :equip
        $scene = Scene_Equip.new(@status_window.index)
      when :status
        $scene = Scene_Status.new(@status_window.index)
      else
        if YEM::MENU::IMPORTED_COMMANDS.include?(command)
          array = YEM::MENU::IMPORTED_COMMANDS[command]
          $scene = eval(array[5] + ".new(@status_window.index)")
        end
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # 覆寫方法：start
  #--------------------------------------------------------------------------
  def start
    super
    create_menu_background
    create_command_window
    if YEM::MENU::USE_MULTI_VARIABLE_WINDOW
      @gold_window = Window_MultiVariableWindow.new
    else
      @gold_window = Window_Gold.new(0, 360)
    end
    @status_window = Window_MenuStatus.new(160, 0)#(160, 0)
    @right_side = YEM::MENU::MENU_RIGHT_SIDE
    if YEM::MENU::ON_SCREEN_MENU
      @gold_window.y = @command_window.height
      @status_window.openness = 0
      @right_side = true if $game_player.screen_x <= 176
      @right_side = false if $game_player.screen_x >= 368
      $game_temp.on_screen_menu = false
    end
    if @right_side
      @status_window.x = 0
      @command_window.x = 384
      @gold_window.x = 384
    end
    @count = 0
  end
  #--------------------------------------------------------------------------
  # alias 方法： start_actor_selection
  #--------------------------------------------------------------------------
  alias start_actor_selection_mmz start_actor_selection unless $@
  def start_actor_selection
    if YEM::MENU::ON_SCREEN_MENU
      @status_window.open
    end
    start_actor_selection_mmz
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：create_menu_background
  #--------------------------------------------------------------------------
  if YEM::MENU::ON_SCREEN_MENU
  def create_menu_background
    @menuback_sprite = Spriteset_Map.new
  end
  end
  
end

#==============================================================================
#==============================================================================
$imported["CustomMenuCommand"] = true
class Game_Temp
  attr_accessor :menu_command_index
  attr_accessor :next_scene_actor_index
  attr_accessor :on_screen_menu
  
  alias initialize_KGC_CustomMenuCommand initialize unless $@
  def initialize
    initialize_KGC_CustomMenuCommand
    @menu_command_index = {}
    @next_scene_actor_index = 0
  end
end

module KGC
module Commands
  module_function
  def call_item
    return if $game_temp.in_battle
    $game_temp.next_scene = :menu_item
    $game_temp.next_scene_actor_index = 0
    $game_temp.menu_command_index = {}
  end
  def call_skill(actor_index = 0)
    return if $game_temp.in_battle
    $game_temp.next_scene = :menu_skill
    $game_temp.next_scene_actor_index = actor_index
    $game_temp.menu_command_index = {}
  end
  def call_equip(actor_index = 0)
    return if $game_temp.in_battle
    $game_temp.next_scene = :menu_equip
    $game_temp.next_scene_actor_index = actor_index
    $game_temp.menu_command_index = {}
  end
  def call_status(actor_index = 0)
    return if $game_temp.in_battle
    $game_temp.next_scene = :menu_status
    $game_temp.next_scene_actor_index = actor_index
    $game_temp.menu_command_index = {}
  end
end
end

class Game_Interpreter
  include KGC::Commands
end

class Scene_Map < Scene_Base
  alias update_scene_change_KGC_CustomMenuCommand update_scene_change unless $@
  def update_scene_change
    return if $game_player.moving?
    case $game_temp.next_scene
    when :menu_item
      call_menu_item
    when :menu_skill
      call_menu_skill
    when :menu_equip
      call_menu_equip
    when :menu_status
      call_menu_status
    else
      update_scene_change_KGC_CustomMenuCommand
    end
  end
  alias call_menu_mmz call_menu unless $@
  def call_menu
    $game_temp.on_screen_menu = true if YEM::MENU::ON_SCREEN_MENU
    call_menu_mmz
  end
  def call_menu_item
    $game_temp.next_scene = nil
    $scene = Scene_Item.new
  end
  def call_menu_skill
    $game_temp.next_scene = nil
    $scene = Scene_Skill.new($game_temp.next_scene_actor_index)
    $game_temp.next_scene_actor_index = 0
  end
  def call_menu_equip
    $game_temp.next_scene = nil
    $scene = Scene_Equip.new($game_temp.next_scene_actor_index)
    $game_temp.next_scene_actor_index = 0
  end
  def call_menu_status
    $game_temp.next_scene = nil
    $scene = Scene_Status.new($game_temp.next_scene_actor_index)
    $game_temp.next_scene_actor_index = 0
  end
end

class Scene_Menu < Scene_Base
  def check_debug_enable
    return unless Input.press?(Input::F5)
    return unless Input.press?(Input::F9)
    $TEST = true
  end
end

class Scene_Item < Scene_Base
  def return_scene
    if $game_temp.menu_command_index.has_key?(:items)
      $scene = Scene_Menu.new($game_temp.menu_command_index[:items])
    else
      $scene = Scene_Map.new
    end
  end
end

class Scene_Skill < Scene_Base
  def return_scene
    if $game_temp.menu_command_index.has_key?(:skill)
      $scene = Scene_Menu.new($game_temp.menu_command_index[:skill])
    else
      $scene = Scene_Map.new
    end
  end
end

class Scene_Equip < Scene_Base
  def return_scene
    if $game_temp.menu_command_index.has_key?(:equip)
      $scene = Scene_Menu.new($game_temp.menu_command_index[:equip])
    else
      $scene = Scene_Map.new
    end
  end
end

class Scene_Status < Scene_Base
  def return_scene
    if $game_temp.menu_command_index.has_key?(:status)
      $scene = Scene_Menu.new($game_temp.menu_command_index[:status])
    else
      $scene = Scene_Map.new
    end
  end
end

class Scene_File < Scene_Base
  alias return_scene_KGC_CustomMenuCommand return_scene unless $@
  def return_scene
    if @from_title || @from_event
      return_scene_KGC_CustomMenuCommand
    elsif $game_temp.menu_command_index.has_key?(:save)
      $scene = Scene_Menu.new($game_temp.menu_command_index[:save])
    else
      $scene = Scene_Map.new
    end
  end
end

class Scene_End < Scene_Base
  def return_scene
    if $game_temp.menu_command_index.has_key?(:system)
      $scene = Scene_Menu.new($game_temp.menu_command_index[:system])
    else
      $scene = Scene_Map.new
    end
  end
end

#===============================================================================
#===============================================================================

class Game_Map
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  unless method_defined?(:map_name)
  def map_name
    data = load_data("Data/MapInfos.rvdata") 
    text = data[@map_id].name.gsub(/\[.*\]/) { "" }
    return text
  end
  end
  
end

#===============================================================================
#===============================================================================

class Game_Actor < Game_Battler
  
  #--------------------------------------------------------------------------
  # 新增方法：now_exp
  #--------------------------------------------------------------------------
  def now_exp
    return @exp - @exp_list[@level]
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：next_exp
  #--------------------------------------------------------------------------
  def next_exp
    return @exp_list[@level+1] > 0 ? @exp_list[@level+1] - @exp_list[@level] : 0
  end
  
end

#===============================================================================
#===============================================================================

class Window_MultiVariableWindow < Window_Selectable
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize
    dh = 32 + 24 * YEM::MENU::VARIABLES_SHOWN.size
    dy = Graphics.height - dh
    super(0, dy, 160, dh)
    refresh
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh
    @data = []
    for i in YEM::MENU::VARIABLES_SHOWN
      next unless YEM::MENU::VARIABLES_HASH.include?(i)
      @time_index = @data.size if i == -1
      @data.push(i)
    end
    @item_max = @data.size
    create_contents
    for i in 0...@item_max
      draw_item(i)
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_item(index)
    rect = item_rect(index)
    sw = self.width - 32
    dy = WLH * index
    self.contents.clear_rect(rect)
    i = @data[index]
    case i
    when -5
      self.contents.draw_text(0, dy, sw, WLH, $game_map.map_name, 1)
      
    when -2
      if YEM::MENU::VARIABLES_ICONS
        text = $game_party.steps
        self.contents.draw_text(0, dy, sw-24, WLH, text, 2)
        draw_icon(YEM::MENU::VARIABLES_HASH[-2][0], sw-24, dy)
      else
        text = YEM::MENU::VARIABLES_HASH[-2][1]
        value = $game_party.steps
        cx = contents.text_size(text).width
        self.contents.font.color = normal_color
        self.contents.draw_text(0, dy, sw-cx-2, WLH, value, 2)
        self.contents.font.color = system_color
        self.contents.draw_text(0, dy, sw, WLH, text, 2)
      end
      
    when -1
      if YEM::MENU::VARIABLES_ICONS
        text = game_time
        self.contents.draw_text(0, dy, sw-24, WLH, text, 2)
        draw_icon(YEM::MENU::VARIABLES_HASH[-1][0], sw-24, dy)
      else
        self.contents.font.color = normal_color
        text = game_time
        self.contents.draw_text(0, dy, sw, WLH, text, 1)
      end
      
    when 0
      if YEM::MENU::VARIABLES_ICONS
        text = $game_party.gold
        self.contents.draw_text(0, dy, sw-24, WLH, text, 2)
        draw_icon(YEM::MENU::VARIABLES_HASH[0][0], sw-24, dy)
      else
        draw_currency_value($game_party.gold, 4, dy, 120)
      end
      
    else
      if YEM::MENU::VARIABLES_ICONS
        text = $game_variables[i]
        self.contents.draw_text(0, dy, sw-24, WLH, text, 2)
        draw_icon(YEM::MENU::VARIABLES_HASH[i][0], sw-24, dy)
      else
        text = YEM::MENU::VARIABLES_HASH[i][1]
        value = $game_variables[i]
        cx = contents.text_size(text).width
        self.contents.font.color = normal_color
        self.contents.draw_text(0, dy, sw-cx-2, WLH, value, 2)
        self.contents.font.color = system_color
        self.contents.draw_text(0, dy, sw, WLH, text, 2)
      end
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def game_time
    gametime = Graphics.frame_count / Graphics.frame_rate
    hours = gametime / 3600
    minutes = gametime / 60 % 60
    seconds = gametime % 60
    result = sprintf("%d:%02d:%02d", hours, minutes, seconds)
    return result
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  if YEM::MENU::VARIABLES_SHOWN.include?(-1)
  def update
    if game_time != (Graphics.frame_count / Graphics.frame_rate)
      draw_item(@time_index)
    end
    super
  end
  end
  
end

#===============================================================================
#===============================================================================

#class Window_MenuCommand < Window_Command
  class Window_MenuCommand < Window_Command_New
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize(array)
    @data = array[1]
    @icons = array[2]
    super(160, array[0])
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh
    create_contents
    for i in 0...@item_max
      draw_item(i)
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def method; return @data[self.index]; end
    
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_item(index, enabled = true)
    rect = item_rect(index)
    rect.x += 4
    rect.width -= 8
    self.contents.clear_rect(rect)
    self.contents.font.color = normal_color
    #---
    text = @commands[index]
    icon = @icons[index]
    case @data[index]
    when :items, :skill, :equip, :status, :kgc_apviewer, :kgc_skillcp,
      :kgc_distribute, :yerd_classchange, :yerd_learnskill, :yerd_equipslots
      enabled = ($game_party.members.size == 0 ? false : true)
    when :save
      enabled = !$game_system.save_disabled
    when :kgc_largeparty
      enabled = ($game_party.members.size == 0 ? false : true)
      enabled = false if !$game_party.partyform_enable?
    else
      if YEM::MENU::COMMON_EVENTS.include?(@data[index])
        if YEM::MENU::COMMON_EVENTS[@data[index]][1] != nil
          switch_id = YEM::MENU::COMMON_EVENTS[@data[index]][1]
          enabled = !$game_switches[switch_id]
        end
      elsif YEM::MENU::IMPORTED_COMMANDS.include?(@data[index])
        if YEM::MENU::IMPORTED_COMMANDS[@data[index]][1] != nil
          switch_id = YEM::MENU::IMPORTED_COMMANDS[@data[index]][1]
          enabled = !$game_switches[switch_id]
        end
      end
    end
    #---
    self.contents.font.color.alpha = enabled ? 255 : 128
    dx = rect.x; dy = rect.y; dw = rect.width
    if YEM::MENU::USE_ICONS and icon.is_a?(Integer)
      draw_icon(icon, 0, dy, enabled)
      dx += 20; dw -= 20
    end
    self.contents.draw_text(dx, dy, dw, WLH, text, YEM::MENU::ALIGN)
  end
  
end

#===============================================================================
# 
# 
#===============================================================================