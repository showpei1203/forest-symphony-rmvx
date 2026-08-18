#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：YEZ Status Command Menu
# 【用途】重寫 VX Status Scene，讓狀態畫面同時成為角色資料樞紐，可查看基本能力、屬性／狀態抗性、技能、裝備、Formation、Mastery、Biography 等頁面並切換 Actor。
# 【來源】Yanfly Engine Zealous - Status Command Menu；Last Date Updated: 2009.12.29。
# 【主要設定】COMMANDS 決定頁籤與順序；USE_ICONS 控制命令圖示；EXP_TEXT／PERCENT_EXP／EXP_GAUGE_1/2 控制 EXP；USE_BG_IMAGE／BG_FILE_NAME 控制背景。
# 【COMMANDS】常用 :parameters、:affinities、:skills、:equips、:biography；:formations 需 Formation Macros，:mastery 需 Weapon Mastery Skills。
# 【Parameters】PARAMETERS[:column1_stats]/[:column2_stats] 可使用 :hp、:mp、:blank、:atk、:def、:spi、:res、:dex、:agi、:hit、:eva、:cri、:dur、:luk、:odds 等支援欄位。
# 【Affinities】AFFINITIES[:states_shown]、[:elements_shown] 決定顯示 ID；:element_icons 綁元素圖示；:rank_colour 控制抗性級別顏色；:absorb 為吸收符號。
# 【Biography】ACTOR_BIOS／CLASS_BIOS 提供角色／職業文字。Biography 可使用 \N[x] 取得可改名 Actor 名稱，使用 | 強制換行；Class Bio 亦支援 \V[x] 變數。Actor 沒個人 Biography 時會回退到 Class Bio。
# 【FS 素材】目前使用 MenuBack、MenuBack_status_、MenuBack_status_a、MenuBack_status_艾薇 等 Graphics/System 背景／角色特化素材。實際頁面已被 FS 深度客製，修改前先確認這些動態檔名規則。
# 【相容性】原作者列出 YEZ DEX/RES、Class DUR、Formation Macros；頁面亦檢查 Weapon Mastery、Distribute Parameter 等 $imported。整個 Status Menu Scene 屬覆寫型腳本，不能隨意前後移。
# 【呼叫方式】一般由主選單 :status 進入；不需要事件 Script Call。若要新增 Status 子頁，優先擴充 COMMANDS 與對應 handler，而非另造 Scene_Status 分支。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 維護說明集中於腳本最前方；程式識別字、Notetag、Script Call、Action Key 不可翻譯改名。
# 2. 原作者、版本、Credits、License、網址等來源資訊保留；翻譯前 byte-exact 原稿另存 Phase 17 Archive。
# 3. 範例只列原文件或既有程式能直接證實的入口，不捏造 API。
# 4. 本輪除註解／說明外不修改任何可執行 Ruby；載入順序仍以 FS LoadOrder Guide／Authority Map 為準。
#==============================================================================
#===============================================================================
# 
# Yanfly Engine Zealous - Status Command Menu
# Last Date Updated: 2009.12.29
# 
# 
#===============================================================================
# -----------------------------------------------------------------------------
#===============================================================================
# -----------------------------------------------------------------------------
# 
#===============================================================================
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
#===============================================================================

$imported = {} if $imported == nil
$imported["StatusCommandMenu"] = true

module YEZ
  module STATUS
    
    #===========================================================================
    # -------------------------------------------------------------------------
    #===========================================================================
    COMMANDS =[
      :parameters,  # ATK、DEF、SPI、AGI 等基本能力。
      :affinities,  # 屬性與狀態抗性。
    ] # 此結構不可刪除。
    
    USE_ICONS = false
    
    EXP_TEXT    = "EXP"
    PERCENT_EXP = "%1.2f%%"
    EXP_GAUGE_1 = 28
    EXP_GAUGE_2 = 29
    
    USE_BG_IMAGE = true
    BG_FILE_NAME = "MenuBack"
    
    PARAMETERS ={
      :title => "",
      :icon  => 103,
      :page_title    => "基本數值",
      :column1_stats => [:atk, :def, :spi, :agi],
      :column2_stats => [:hit, :eva, :cri],
    } # 此結構不可刪除。
    
    AFFINITIES ={
      :title => "",
      :icon  => 100,
      :states_shown   => [2..10],
      :states_title   => "狀態耐性",
      :elements_shown => [4..21],
      :elements_title => "屬性耐性",
      :element_icons  => {
       # 1 => 485,
        4 => 3988,
        5 => 3989,
        6 => 3990,
        7 => 3991,
        8 => 3992,
        9 => 3993,
        10 => 4004,
        11 => 4005,
        12 => 4006,
        13 => 4007,
        14 => 4008,
        15 => 4009,
        16 => 4020,
        17 => 4021,
        18 => 4022,
        19 => 4023,
        20 => 4024,
        21 => 4025,
      }, # 此結構不可刪除。
      :rank_colour => {
        :srank => 18,
        :arank => 2,
        :brank => 14,
        :crank => 6,
        :drank => 3,
        :erank => 4,
        :frank => 5,
      }, # 此結構不可刪除。
      :rank_size => 16,
      :absorb    => "*",
    } # 此結構不可刪除。
    
    SKILLS ={
      :title => "技能",
      :icon  => 159,
      :battle_only => true,  
    } # 此結構不可刪除。
    
    EQUIPS ={
      :title => "裝備",
      :icon  => 44,
      :page_title => "裝備",
      :param => [:hp, :mp, :atk, :def, :spi, :agi]
    } # 此結構不可刪除。
    
    BIOGRAPHY ={
      :title => "狀態資料",
      :icon  => 141,
      :font_size => 18,
      :actor_bio => "%s的簡介",
      :class_des => "%s 介紹",
    } # 此結構不可刪除。
    
      # BIRTHDAY = "Birthday: "  # 歷史停用範例：生日標籤
      # AGE      = "Age: "       # 歷史停用範例：年齡標籤
      # ORIGIN   = "Origin: "    # 歷史停用範例：出身標籤
      # GENDER   = "Gender: "    # 歷史停用範例：性別標籤
      # HEIGHT   = "Height: "    # 歷史停用範例：身高標籤
      # WEIGHT   = "Weight: "    # 歷史停用範例：體重標籤
    
    ACTOR_BIOS ={
    # ID => 簡介
       1 => '   年齡：15歲|' +
            '     生日：3月12日|' +
            '       身高：165cm|' +
            '         體重：54kg                   出身：魯卡村|' +
            '           星座：雙魚座                 興趣：種樹、家具製作|' +
            '             血型：O                        喜歡的食物：奶油菠菜濃湯|' ,
       2 => '   年齡：15歲|' +
            '     生日：12月20日|' +
            '       身高：157cm|' +
            '         體重：45kg                   出身：魯卡村|' +
            '           星座：射手座                 興趣：購物、收集娃娃|' +
            '             血型：A                        喜歡的食物：薯泥沙拉|' ,
       18 => '神奇的生靈，不知道從何而來。',
       19 => '神奇的生靈，不知道從何而來。',
       20 => '神奇的生靈，不知道從何而來。',
    } # 此結構不可刪除。
    
    CLASS_BIOS ={
    # ID => 簡介
       1 => 'Knights are quick and powerful characters|' +
            'that excel in both melee and magic.',
       2 => 'Warriors are very dedicated to close ranged|' +
            'physical combat.',
       3 => 'Priests focus on healing and aiding their|' +
            "party members. Don't let \\N[3] fool you.",
       4 => 'Magicians excel in the magical arts and also|' +
            'excel at blasting their enemies to bits.',
       5 => 'Magicians excel in the magical arts and also|' +
            'excel at blasting their enemies to bits.',
       6 => 'Magicians excel in the magical arts and also|' +
            'excel at blasting their enemies to bits.',
       7 => 'Magicians excel in the magical arts and also|' +
            'excel at blasting their enemies to bits.',
       8 => 'Magicians excel in the magical arts and also|' +
            'excel at blasting their enemies to bits.',
    } # 此結構不可刪除。
    
  end
end

#===============================================================================
# ----------------------------------------------------------------------------
#===============================================================================

module YEZ
  module STATUS
    
    IMPORTED_COMMANDS ={
    } # 此結構不可刪除。
    
  end
end

#===============================================================================
#===============================================================================

module YEZ::STATUS
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
  AFFINITIES[:states_shown] = convert_integer_array(AFFINITIES[:states_shown])
  AFFINITIES[:elements_shown] = convert_integer_array(AFFINITIES[:elements_shown])
end

module Vocab
  def self.hit; return "命中"; end
  def self.eva; return "閃躲"; end
  def self.cri; return "爆擊"; end
  def self.odds;return "AGR"; end
    
  def self.hit_text; return "Hit Rate"; end
  def self.eva_text; return "Evasion"; end
  def self.cri_text; return "Critical"; end
end

#===============================================================================
#===============================================================================

class Scene_Status < Scene_Base

  #--------------------------------------------------------------------------
  # 覆寫方法：start
  #--------------------------------------------------------------------------
  def start
    super
    $game_temp.status_index = 0 if $game_temp.status_index == nil
    @actor = $game_party.members[@actor_index]
    @command_window = Window_Status_Command.new(@actor)
    @command_window.windowskin = Cache.windows("windowX")
    @actor_window = Window_Status_Actor.new(@actor)
    @dummy_window = Window_Base.new(0, 128, 544, 288)
    @com_count = 11
    create_menu_background
    create_mini_windows
    $game_party.last_actor_index = @actor_index
  end
  
  #--------------------------------------------------------------------------
  # 覆寫方法：create_menu_background
  #--------------------------------------------------------------------------
  def create_menu_background
    if YEZ::STATUS::USE_BG_IMAGE
    @menuback_sprite.dispose if @menuback_sprite != nil
    @menuback_sprite2.dispose if @menuback_sprite2 != nil
    @menuback_sprite = Sprite.new
    @menuback_sprite.bitmap = Cache.system("MenuBack_status_a")
    @menuback_sprite2 = Sprite.new
    @menuback_sprite2.bitmap = Cache.system("MenuBack_status_" + @actor.name)
    @menuback_sprite2.z -= 2
      @command_window.opacity = 0###
      @actor_window.opacity = 0###
      @dummy_window.opacity = 0###
    #####################################################################
    @sprites = []
    images_name =
    ["Status01","Status02"]
    for i in 0...images_name.size
     @sprites[i] = Sprite.new
     @sprites[i].bitmap = Cache.menu(images_name[i])
     @sprites[i].x = 28#(i * 10)-20 if i<4
     @sprites[i].y = (i * 27) + 40
     @sprites[i].opacity = 255
     @sprites[i].z = 9999
     @sprites[i].tone = Tone.new(0,0,0,255)
     @sprites[i].zoom_x = @sprites[i].zoom_y = 1.0############
    end
    ####################################################################
    @light = Sprite.new
		@light.bitmap = Cache.picture("le.png")
		@light.visible = true
    @light.x = 407
    @light.y = -20
    @light.zoom_x = 200 / 100.0
    @light.zoom_y = 200 / 100.0
    @light.opacity = 100
    @light.tone = Tone.new(255,-100,-255, 0)
    @light.blend_type = 1
		@light.z = 1000
    
    @light2 = Sprite.new
		@light2.bitmap = Cache.picture("le.png")
		@light2.visible = true
    @light2.x = 10
    @light2.y = 31
    @light2.zoom_x = 150 / 100.0
    @light2.zoom_y = 55 / 100.0
    @light2.opacity = 100
    @light2.tone = Tone.new(200,200,100, 100)
    @light2.blend_type = 1
		@light2.z = 1000
    
    fireflies(5)
    ####################################################################

      update_menu_background
    else
      super
    end
  end
  
  #--------------------------------------------------------------------------
  # 覆寫方法：terminate
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_menu_background
    dispose_mini_windows
    @command_window.dispose
    @actor_window.dispose
    @dummy_window.dispose
    for i in 0..1
      @sprites[i].dispose
    end
    @light.dispose
    @light2.dispose
    fireflies(0)
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： return_scene
  #--------------------------------------------------------------------------
  alias return_scene_status_scm return_scene unless $@
  def return_scene
    $game_temp.status_oy = nil
    $game_temp.status_index = nil
    $game_temp.status_calc_width = nil
    return_scene_status_scm
  end
  
  #--------------------------------------------------------------------------
  # 覆寫方法：update
  #--------------------------------------------------------------------------
  def update
    update_menu_background
    update_mini_windows if $game_temp.status_index != @command_window.index
    ################################
    @light.opacity = rand(20) + 90
    @light.x = 407 + rand(3) - 3
    @light.y = -20 + rand(3) - 3
    
    @light2.opacity = rand(40) + 70
    @light2.x = 10
    @light2.y = (@command_window.index * 30) + 31
    ################################
    for i in 0..1
      @sprites[i].tone = Tone.new(0,0,0,255)
      @sprites[i].y = (i * 27) + 40
      @sprites[i].color.set(255, 255, 255, 0) if Input.trigger?(Input::UP)
      @sprites[i].color.set(255, 255, 255, 0) if Input.trigger?(Input::DOWN)
      @sprites[i].y = (i * 27) + 40 if Input.trigger?(Input::UP)
      @sprites[i].y = (i * 27) + 40 if Input.trigger?(Input::DOWN)
    end
    @sprites[@command_window.index].tone = Tone.new(0,0,0)
    @com_count = 0 if Input.trigger?(Input::UP)
    @com_count = 0 if Input.trigger?(Input::DOWN)
    if @com_count <= 10
      @sprites[@command_window.index].y += 3 if @com_count == 9
      @sprites[@command_window.index].y -= 3 if @com_count == 0
      @sprites[@command_window.index].color.set(255, 255, 255, 0) if @com_count == 9
      @sprites[@command_window.index].color.set(200, 255, 255, 160) if @com_count == 4
      @com_count +=1
    end
#################################################

    @command_window.update
    @affinity_window.update
    if Input.trigger?(Input::C)
      determine_scene_change
    elsif Input.trigger?(Input::B)
      Sound.play_cancel
      return_scene
    elsif Input.repeat?(Input::RIGHT)
      Sound.play_cursor
      $game_temp.status_oy = @command_window.oy
      next_actor
    elsif Input.repeat?(Input::LEFT)
      Sound.play_cursor
      $game_temp.status_oy = @command_window.oy
      prev_actor
    end
    super
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：create_mini_windows
  #--------------------------------------------------------------------------
  def create_mini_windows
    @mini_windows = {}; n = 0
    for command in YEZ::STATUS::COMMANDS
      case command
      when :parameters
        @parameter_window = Window_Status_Parameter.new(@actor)
        @parameter_window.opacity = 0
        #@parameter_window.skin = Cache.system("MenuBack_status_艾薇")###
        @mini_windows[n] = @parameter_window
        ####################
      when :affinities
        #@affinity_window = Window_Status_Affinity.new(@actor)原始
        @affinity_window = Window_StatusDetail.new(@actor)###
        @affinity_window.category = :element_resist
        @affinity_window.opacity = 0
        @affinity_window.y -= 15
        @mini_windows[n] = @affinity_window
        ####################
      when :skills
        @skill_window = Window_Status_Skill.new(@actor)
        @mini_windows[n] = @skill_window
      when :equips
        @equip_window = Window_Status_Equips.new(@actor)
        @mini_windows[n] = @equip_window
        #####################
      when :biography
        @biography_window = Window_StatusDetail2.new(@actor)
        @biography_window.category = :state_resist
        @mini_windows[n] = @biography_window
        #####################
      when :formations
        next unless $imported["FormationMacros"]
        next unless $game_switches[YEZ::MACRO::ENABLE_SWITCH]
        @formation_window = Window_Formation.new(@actor)
        @formation_window.opacity = 0
        @mini_windows[n] = @formation_window
      when :mastery
        next unless $imported["WeaponMasterySkills"]
        @mastery_window = Window_Mastery.new(0, 128, @actor, true)
        @mastery_window.opacity = 0
        @mini_windows[n] = @mastery_window
        
      else
        return_check = true
        for key in YEZ::STATUS::IMPORTED_COMMANDS
          if key[0] == command
            return_check = false
            found_key = key[0]
          end
        end
        next if return_check
        command_array = YEZ::STATUS::IMPORTED_COMMANDS[found_key]
        if command_array[0] != nil
          next unless $game_switches[command_array[0]]
        end
        if command_array[3] != nil
          window = eval(command_array[3])
          window.x = 0
          window.y = 128
          window.width = 544
          window.height = 288
          window.create_contents
          window.refresh
        else
          window = Window_Base.new(0, 128, 544, 288)
          
        end
        window.opacity = 0
        @mini_windows[n] = window
        
      end
      n += 1
    end
    update_mini_windows
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：update_mini_windows
  #--------------------------------------------------------------------------
  def update_mini_windows
    $game_temp.status_index = @command_window.index
    for i in 0..(@mini_windows.size-1)
      @mini_windows[i].visible = false
    end
    return unless @mini_windows.include?($game_temp.status_index)
    @mini_windows[$game_temp.status_index].visible = true
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：dispose_mini_windows
  #--------------------------------------------------------------------------
  def dispose_mini_windows
    for i in 0..(@mini_windows.size-1)
      @mini_windows[i].dispose
      @mini_windows[i] = nil
    end
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：determine_scene_change
  #--------------------------------------------------------------------------
  def determine_scene_change
    case @command_window.item
    when :parameters
      return unless $imported["DistributeParameter"]
      Sound.play_decision
      $scene = Scene_DistributeParameter.new(@actor.index)
    when :skills
      Sound.play_decision
      $scene = Scene_Skill.new(@actor.index)
    when :equips
      Sound.play_decision
      $scene = Scene_Equip.new(@actor.index)
    when :formations
      return unless $imported["FormationMacros"]
      return unless $game_switches[YEZ::MACRO::ENABLE_SWITCH]
      Sound.play_decision
      $scene = Scene_Formation.new(@actor.index)
    when :mastery
      return unless $imported["WeaponMasterySkills"]
      Sound.play_decision
      $scene = Scene_Mastery.new(@actor.index)
      
    else
      return unless YEZ::STATUS::IMPORTED_COMMANDS.include?(@command_window.item)
      command_array = YEZ::STATUS::IMPORTED_COMMANDS[@command_window.item]
      if command_array[4] != nil
        Sound.play_decision
        $scene = eval(command_array[4] + ".new(@actor_index)")
      end
      
    end
  end
  
end

#===============================================================================
#===============================================================================

class Scene_Skill < Scene_Base
  
  #--------------------------------------------------------------------------
  # alias 方法： return_scene
  #--------------------------------------------------------------------------
  alias return_scene_skill_scm return_scene unless $@
  def return_scene
    if $game_temp.status_index != nil
      $scene = Scene_Status.new(@actor_index)
    else
      return_scene_skill_scm
    end
  end
  
end

#===============================================================================
#===============================================================================

class Scene_Equip < Scene_Base
  
  #--------------------------------------------------------------------------
  # alias 方法： return_scene
  #--------------------------------------------------------------------------
  alias return_scene_equip_scm return_scene unless $@
  def return_scene
    if $game_temp.status_index != nil
      $scene = Scene_Status.new(@actor_index)
    else
      return_scene_equip_scm
    end
  end
  
end

#===============================================================================
#===============================================================================

class Game_Temp
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  attr_accessor :status_index
  attr_accessor :status_oy
  attr_accessor :status_calc_width
  attr_accessor :status_ele_width
  attr_accessor :status_st_width
  
end
#===============================================================================
#===============================================================================

class Window_Status_Actor < Window_Base
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize(actor)
    super(110, 0, 384, 128)
    @actor = actor
    refresh
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    #draw_actor_face(@actor, 0, 0, size = 96)
    x = 0
    y = 0
    #self.contents.fill_rounded_rect(rect, Color.new(0, 0, 0, 78))
    self.contents.font.color = text_color(8)
    #self.contents.draw_text(x, y, 42, WLH, "姓名:")
    #self.contents.draw_text(x+224, y, 48, WLH, "狀態:")
    #self.contents.draw_text(x+264, y+70, 48, WLH, '疲勞:')
    #draw_actor_state(@actor, x+294, 0, 96)
    self.contents.font.color = normal_color
    self.contents.font.size = Font.default_size - 2
    x = 36
    y = 5
    case @actor.name
    when "喬伊"
      self.contents.draw_text(x, y, 178, WLH, "喬伊")
      #self.contents.draw_text(x+268, y+70, 48, WLH, $game_variables[90])
    when "艾薇"
      self.contents.draw_text(x, y, 178, WLH, "艾薇")
    when "艾卓"
      self.contents.draw_text(x, y, 178, WLH, "艾卓")
    when "薇娜"
      self.contents.draw_text(x, y, 178, WLH, "薇娜")
    when "米亞"
      self.contents.draw_text(x, y, 178, WLH, "米亞")
    when "泰勒"
      self.contents.draw_text(x, y, 178, WLH, "泰勒")
    when "Wiegraf"
      self.contents.draw_text(x, y, 178, WLH, "Wiegraf")
    when "Rk"
      self.contents.draw_text(x, y, 178, WLH, "'Rk'")
    end
    self.contents.font.size = Font.default_size - 3
    x = 0
    y = 0
    draw_actor_graphic(@actor, x+15, WLH+10)
    draw_actor_level3(@actor, x+48+36, y+7 + WLH * 0)
    #draw_actor_class(@actor, x + 72, y + WLH)
#    draw_stun_indicator(x, y + WLH * 3, @actor) if $imported["ClassStatDUR"]
    x = 104
    draw_actor_hp(@actor, x-104, y+4 + WLH * 1, 120)
    draw_actor_mp(@actor, x-104, y-2 + WLH * 2, 120)
    draw_exp_info(0,15)
    draw_actor_jp(@actor, x-54, y+0 + WLH * 3)
    self.contents.font.size = Font.default_size
    
    #######
    ###############
    @data = @actor.equips.clone
    self.contents.font.size = 16
    self.contents.font.color = normal_color; dy = 0; dx = 166
    for i in 0..(@actor.equip_type.size)
      self.contents.font.color = normal_color
      item = @data[i]
      if item == nil
        text = YEM::EQUIP::VOCAB[:noequip]
        self.contents.font.color.alpha = 128
        self.contents.draw_text(dx, dy, 196, WLH, text)
      else
        draw_item_name10(item, dx, dy)
      end
      dy += WLH
      dy -= WLH * 4 if i == 3
      if i >= 3
        dx = 246
      end
    end
    self.contents.font.size = 19
    def equip_type
      return YEM::EQUIP::TYPE_LIST
    end
    ###############
    #######
    
  end
  
  def draw_exp_info(x, y)
    s_next = sprintf(Vocab::ExpNext, Vocab::level)
    self.contents.font.color = system_color
    #self.contents.draw_text(x, y + WLH * 0, 180, WLH, Vocab::ExpTotal)
    self.contents.draw_text(x, y + WLH * 2, 180, WLH, s_next)
    #draw_actor_exp(@actor, x, y + WLH * 1)
    draw_actor_next_exp(@actor, x, y-20 + WLH * 3,60)
  end
  
  def draw_actor_jp(actor, dx, dy, dw = 50)
    return if actor.class_id == nil
    icon = $imported["Icons"] ? YEZ::ICONS[:txtjp] : YEZ::JOB::JP_ICON
    draw_icon(icon, dx + dw, dy)
    text = actor.class_jp[actor.class_id]
    self.contents.font.size = 15
    self.contents.draw_text(dx, dy, dw, WLH, text, 2)
  end
  
    #--------------------------------------------------------------------------
  # * 繪製主角等級
  #     actor : 主角
  #     x     : 繪製區域X座標
  #     y     : 繪製區域Y座標
  #--------------------------------------------------------------------------
  def draw_actor_level3(actor, x, y)
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 32, WLH, Vocab::level_a)
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 16, y, 24, WLH, actor.level, 2)
  end
end

#===============================================================================
#===============================================================================

class Window_Status_Parameter < Window_Base
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize(actor)
    super(0, 128, 544, 288)
    #self.skin = Cache.system("MenuBack_status_艾薇")
    #self.skin.size(0,65)
    self.opacity = 255###=0
    @actor = actor
    refresh
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    rect = Rect.new (10, 0, 122,192)###
    self.contents.fill_rounded_rect(rect, Color.new(0, 0, 0, 128))###
    #self.contents.fill_rect(10, 0, 122, 192, Color.new(0, 0, 0, 128))
    sw = self.width - 32
    self.contents.font.color = system_color
    text = YEZ::STATUS::PARAMETERS[:page_title]
    self.contents.draw_text(48, 0, sw/2-48, WLH, text, 0)
    dx = 50; dy = WLH
    array = YEZ::STATUS::PARAMETERS[:column1_stats]
    draw_column(dx, dy, array)
    array = YEZ::STATUS::PARAMETERS[:column2_stats]
    #draw_column(dx-24, dy*4, array)###
    draw_column(dx, dy*5, array)
  end  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_column(dx, dy, array)
    dx += 48-30
    stat_width = calc_width(array)
    
    for item in array
      dw = 60
      text = ""
      stat = ""
      icon = 0
      case item
      when :blank
      when :hp
        text = Vocab.hp
        stat = @actor.maxhp
        icon = $imported["Icons"] ? YEZ::ICONS[:hp] : 272
      when :mp
        text = Vocab.mp
        stat = @actor.maxmp
        icon = $imported["Icons"] ? YEZ::ICONS[:mp] : 273
      when :atk
        text = Vocab.atk
        text2 = "攻擊"
        stat = @actor.atk
        icon = $imported["Icons"] ? YEZ::ICONS[:atk] : 276
      when :def
        text = Vocab.def
        text2 = "防禦"
        stat = @actor.def
        icon = $imported["Icons"] ? YEZ::ICONS[:def] : 277
      when :spi
        text = Vocab.spi
        text2 = "精神"
        stat = @actor.spi
        icon = $imported["Icons"] ? YEZ::ICONS[:spi] : 278
      when :agi
        text = Vocab.agi
        text2 = "敏捷"
        stat = @actor.agi
        icon = $imported["Icons"] ? YEZ::ICONS[:agi] : 281
      when :dex
        next unless $imported["BattlerStatDEX"]
        text = Vocab.dex
        stat = @actor.dex
        icon = $imported["Icons"] ? YEZ::ICONS[:dex] : 0
      when :res
        next unless $imported["BattlerStatRES"]
        text = Vocab.res
        stat = @actor.res
        icon = $imported["Icons"] ? YEZ::ICONS[:res] : 0
      when :hit
        text2 = "命中"
        icon = $imported["Icons"] ? YEZ::ICONS[:hit] : 0
        stat = sprintf("%d%%",[[@actor.hit, 0].max, 99].min)
      when :eva
        text2 = "閃躲"
        icon = $imported["Icons"] ? YEZ::ICONS[:eva] : 0
        stat = sprintf("%d%%",[[@actor.eva, 0].max, 99].min)
      when :cri
        text2 = "爆擊"
        icon = $imported["Icons"] ? YEZ::ICONS[:cri] : 0
        stat = sprintf("%d%%",[[@actor.cri, 0].max, 99].min)
      when :odds
        text = Vocab.odds
        icon = $imported["Icons"] ? YEZ::ICONS[:odds] : 0
        stat = @actor.odds
      when :dur
        next unless $imported["ClassStatDUR"]
        text = Vocab.dur
        stat = @actor.max_dur
        icon = $imported["Icons"] ? YEZ::ICONS[:dur] : 0
      when :luk
        next unless $imported["ClassStatLUK"]
        text = Vocab.luk
        stat = @actor.luk
        icon = $imported["Icons"] ? YEZ::ICONS[:luk] : 0
        
      else; next
      end
      
      draw_icon(text.to_i, dx, dy)
      self.contents.font.color = system_color
      self.contents.draw_text(dx + 29-80, dy, dw + 20, WLH, text2, 0)
      self.contents.font.color = normal_color
      self.contents.draw_text(dx + 114-80, dy, stat_width, WLH, stat, 2)
      
      dy += WLH
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def calc_width(array)
    return $game_temp.status_calc_width if $game_temp.status_calc_width != nil
    n = 0
    for actor in $game_party.members
      for item in array
        text = ""
        case item
        when :hp;   text = actor.maxhp
        when :mp;   text = actor.maxmp
        when :atk;  text = actor.atk
        when :def;  text = actor.def
        when :spi;  text = actor.spi
        when :agi;  text = actor.agi
        when :res;  text = actor.res if $imported["BattlerStatRES"]
        when :dex;  text = actor.dex if $imported["BattlerStatDEX"]
        when :hit;  text = sprintf("%d%%", [[actor.hit, 0].max, 99].min)
        when :eva;  text = sprintf("%d%%", [[actor.eva, 0].max, 99].min)
        when :cri;  text = sprintf("%d%%", [[actor.cri, 0].max, 99].min)
        when :dur;  text = actor.dur if $imported["ClassStatDUR"]
        when :luk;  text = actor.luk if $imported["BattlerStatLUK"]
        when :odds; text = actor.odds
        else; next
        end
        n = [n, contents.text_size(text).width].max
      end
    end
    $game_temp.status_calc_width = n
    return n
  end
  
end

#===============================================================================
#===============================================================================

class Window_Status_Affinity < Window_Base
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize(actor)
    super(0, 128, 544, 288)
    self.opacity = 255
    @actor = actor
    refresh
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    
    draw_elemental_affinity
    draw_status_resistances
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_elemental_affinity
    
    self.contents.font.size = Font.default_size
    affinities = YEZ::STATUS::AFFINITIES
    dx = 48; dy = 0; sw = self.width-32
    if affinities[:elements_shown].size < 10
      self.contents.font.color = system_color
      text = affinities[:elements_title]
      self.contents.draw_text(dx, dy, sw/2-24, WLH, text, 0)
      dy += WLH
    end
    dw = calc_ele_width(affinities[:elements_shown])
    for ele_id in affinities[:elements_shown]
      next if ele_id > $data_system.elements.size
      draw_icon(affinities[:element_icons][ele_id], dx, dy)
      name = $data_system.elements[ele_id]
      self.contents.font.color = normal_color
      self.contents.font.size = Font.default_size - 2
      self.contents.draw_text(dx+32, dy, dw+10, WLH, name, 0)
      self.contents.font.color = affinity_colour(@actor.element_rate(ele_id))
      self.contents.font.size = affinities[:rank_size]
      self.contents.draw_text(dx+34+dw, dy, 60, WLH, element_rate(ele_id), 2)
      if @actor.element_rate(ele_id) < 0
        self.contents.draw_text(dx+94+dw, dy, 60, WLH, affinities[:absorb])
      end
      dy += WLH
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_status_resistances
    self.contents.font.size = Font.default_size
    affinities = YEZ::STATUS::AFFINITIES
    dx = (self.width - 32)/2 + 24; dy = 0; sw = self.width-32
    if affinities[:states_shown].size < 10
      self.contents.font.color = system_color
      text = affinities[:states_title]
      self.contents.draw_text(dx, dy, sw/2-24, WLH, text, 0)
      dy += WLH
    end
    dw = calc_state_width(affinities[:states_shown])
    for state_id in affinities[:states_shown]
      state = $data_states[state_id]
      next if state == nil
      draw_icon(state.icon_index, dx, dy)
      self.contents.font.color = normal_color
      self.contents.font.size = Font.default_size - 2
      self.contents.draw_text(dx+32, dy, dw+20, WLH, state.name, 0)
      self.contents.font.color = rank_colour(@actor.state_probability(state_id))
      resist = sprintf("%d%%", @actor.state_probability(state_id))
      self.contents.font.size = affinities[:rank_size]
      ###
if @actor.state_resist?(state_id) == false
self.contents.draw_text(dx+44+dw, dy, 60, WLH, resist, 2)
end
self.contents.draw_text(dx+48+dw, dy, 60, WLH, "被動免疫", 2) if @actor.state_resist?(state_id)
      dy += WLH
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def calc_ele_width(elements)
    return $game_temp.status_ele_width if $game_temp.status_ele_width != nil
    n = 0
    for ele_id in elements
      next if ele_id > $data_system.elements.size
      text = $data_system.elements[ele_id]
      n = [n, contents.text_size(text).width].max
    end
    $game_temp.status_ele_width = n
    return n
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def calc_state_width(states)
    return $game_temp.status_st_width if $game_temp.status_st_width != nil
    n = 0
    for state_id in states
      state = $data_states[state_id]
      next if state == nil
      text = state.name
      n = [n, contents.text_size(text).width].max
    end
    $game_temp.status_st_width = n
    return n
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def affinity_colour(amount)
    if amount > 200; n = YEZ::STATUS::AFFINITIES[:rank_colour][:srank]
    elsif amount > 150; n = YEZ::STATUS::AFFINITIES[:rank_colour][:arank]
    elsif amount > 100; n = YEZ::STATUS::AFFINITIES[:rank_colour][:brank]
    elsif amount > 50; n = YEZ::STATUS::AFFINITIES[:rank_colour][:crank]
    elsif amount > 25; n = YEZ::STATUS::AFFINITIES[:rank_colour][:drank]
    elsif amount > 0; n = YEZ::STATUS::AFFINITIES[:rank_colour][:erank]
    else; n = YEZ::STATUS::AFFINITIES[:rank_colour][:frank]
    end
    return text_color(n)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def rank_colour(amount)
    if amount > 100; n = YEZ::STATUS::AFFINITIES[:rank_colour][:srank]
    elsif amount > 80; n = YEZ::STATUS::AFFINITIES[:rank_colour][:arank]
    elsif amount > 60; n = YEZ::STATUS::AFFINITIES[:rank_colour][:brank]
    elsif amount > 40; n = YEZ::STATUS::AFFINITIES[:rank_colour][:crank]
    elsif amount > 20; n = YEZ::STATUS::AFFINITIES[:rank_colour][:drank]
    elsif amount > 0; n = YEZ::STATUS::AFFINITIES[:rank_colour][:erank]
    else; n = YEZ::STATUS::AFFINITIES[:rank_colour][:frank]
    end
    return text_color(n)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def element_rate(ele_id)
    rate = @actor.element_rate(ele_id)
    if rate >= 0; text = sprintf("%+d%%", rate -100)
    elsif rate < 0; text = sprintf("%d%%", -rate)
    end
    return text
  end
  
end

#===============================================================================
#===============================================================================

class Window_Status_Skill < Window_Skill
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize(actor)
    $game_temp.in_battle = true if YEZ::STATUS::SKILLS[:battle_only]
    super(0, 128, 544, 288, actor)
    self.opacity = 0
    self.index = -1
    $game_temp.in_battle = false if YEZ::STATUS::SKILLS[:battle_only]
  end
  
end

#===============================================================================
#===============================================================================

class Window_Status_Equips < Window_Status_Parameter
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    draw_equipments(32, 0)
    draw_column((self.width-32)/2-24, WLH, YEZ::STATUS::EQUIPS[:param])
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_equipments(x, y)
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 120, WLH, YEZ::STATUS::EQUIPS[:page_title])
    if $imported["EquipExtension"]
      item_number = [@actor.equips.size, @actor.armor_number + 1].min
      item_number.times { |i|
        draw_item_name(@actor.equips[i], x + 16, y + WLH * (i + 1)) }
    else
      for i in 0..4
        draw_item_name(@actor.equips[i], x + 16, y + WLH * (i + 1))
      end
    end
  end
  
end

#===============================================================================
#===============================================================================

class Window_Status_Biography < Window_Base
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize(actor)
    super(0, 128, 544, 288)
    self.opacity = 0
    @actor = actor
    refresh
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    if YEZ::STATUS::ACTOR_BIOS.include?(@actor.id)
      draw_actor_bio
    elsif YEZ::STATUS::CLASS_BIOS.include?(@actor.class_id)
      draw_class_bio
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_actor_bio
    self.contents.font.color = normal_color; dy = 0
    text = sprintf(YEZ::STATUS::BIOGRAPHY[:actor_bio], @actor.name)
    self.contents.draw_text(0, dy, self.width-32, WLH*2, text, 1)
    self.contents.font.size = YEZ::STATUS::BIOGRAPHY[:font_size]
    text = YEZ::STATUS::ACTOR_BIOS[@actor.id]
    txsize = YEZ::STATUS::BIOGRAPHY[:font_size] + 4
    nwidth = 544
    dx = 48; dy = WLH*2
    text.gsub!(/\\V\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
    text.gsub!(/\\V\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
    text.gsub!(/\\N\[([0-9]+)\]/i) { $game_actors[$1.to_i].name }
    lines = text.split(/(?:[|]|\\n)/i)
    lines.each_with_index { |l, i|
      l.gsub!(/\\__(\[\d+\])/i) { "\\N#{$1}" }
      self.contents.draw_text(dx - 24, i * txsize + dy, nwidth, WLH, l, 0)}
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_class_bio
    self.contents.font.color = normal_color; dy = 0
    text = sprintf(YEZ::STATUS::BIOGRAPHY[:class_des], @actor.class.name)
    self.contents.draw_text(0, dy, self.width-32, WLH*2, text, 1)
    self.contents.font.size = YEZ::STATUS::BIOGRAPHY[:font_size]
    text = YEZ::STATUS::CLASS_BIOS[@actor.class.id]
    txsize = YEZ::STATUS::BIOGRAPHY[:font_size] + 4
    nwidth = 544
    dx = 48; dy = WLH*2
    text.gsub!(/\\V\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
    text.gsub!(/\\V\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
    text.gsub!(/\\N\[([0-9]+)\]/i) { $game_actors[$1.to_i].name }
    lines = text.split(/(?:[|]|\\n)/i)
    lines.each_with_index { |l, i|
      l.gsub!(/\\__(\[\d+\])/i) { "\\N#{$1}" }
      self.contents.draw_text(dx - 24, i * txsize + dy, nwidth, WLH, l, 0)}
  end
  
end

#===============================================================================
#===============================================================================

class Window_Status_Command < Window_Command
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize(actor)
    @actor = actor
    create_command_list
    super(160, @commands)
    self.height = 128
    self.oy = $game_temp.status_oy if $game_temp.status_oy != nil
    self.index = $game_temp.status_index if $game_temp.status_index != nil
    if $game_temp.status_index != nil and $game_temp.status_index > (@commands.size-1)
      self.index = @commands.size-1
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def create_command_list
    @commands = []
    for command in YEZ::STATUS::COMMANDS
      case command
      when :parameters; @commands.push(command)
      when :affinities; @commands.push(command)
      when :skills; @commands.push(command)
      when :equips; @commands.push(command)
      when :biography
        if !YEZ::STATUS::ACTOR_BIOS.include?(@actor.id)
          next if !YEZ::STATUS::CLASS_BIOS.include?(@actor.class_id)
        end
        @commands.push(command)
      when :formations
        next unless $imported["FormationMacros"]
        next unless $game_switches[YEZ::MACRO::ENABLE_SWITCH]
        @commands.push(command)
      when :mastery
        next unless $imported["WeaponMasterySkills"]
        @commands.push(command)
        
      else
        next unless YEZ::STATUS::IMPORTED_COMMANDS.include?(command)
        if YEZ::STATUS::IMPORTED_COMMANDS[command][0] != nil
          next unless $game_switches[YEZ::STATUS::IMPORTED_COMMANDS[command][0]]
        end
        @commands.push(command)
      end
      #---
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def item; return @commands[index]; end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_item(index, enabled = true)
    rect = item_rect(index)
    rect.x += 4
    rect.width -= 8
    self.contents.clear_rect(rect)
    self.contents.font.color = normal_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    case @commands[index]
    when :parameters
      text = YEZ::STATUS::PARAMETERS[:title]
      icon = YEZ::STATUS::PARAMETERS[:icon]
    when :affinities
      text = YEZ::STATUS::AFFINITIES[:title]
      icon = YEZ::STATUS::AFFINITIES[:icon]
    when :skills
      text = YEZ::STATUS::SKILLS[:title]
      icon = YEZ::STATUS::SKILLS[:icon]
    when :equips
      text = YEZ::STATUS::EQUIPS[:title]
      icon = YEZ::STATUS::EQUIPS[:icon]
    when :biography
      text = YEZ::STATUS::BIOGRAPHY[:title]
      icon = YEZ::STATUS::BIOGRAPHY[:icon]
    when :formations
      return unless $imported["FormationMacros"]
      return unless $game_switches[YEZ::MACRO::ENABLE_SWITCH]
      text = YEZ::MACRO::TITLE
      icon = YEZ::MACRO::ICON
    when :mastery
      return unless $imported["WeaponMasterySkills"]
      text = YEZ::WEAPON_MASTERY::TITLE
      icon = YEZ::WEAPON_MASTERY::ICON
      
    else
      return unless YEZ::STATUS::IMPORTED_COMMANDS.include?(@commands[index])
      text = YEZ::STATUS::IMPORTED_COMMANDS[@commands[index]][1]
      icon = YEZ::STATUS::IMPORTED_COMMANDS[@commands[index]][2]
      
    end
    #---
    align = 1
    if YEZ::STATUS::USE_ICONS
      rect.x += 24
      rect.width -= 24
      align = 0
    end
    self.contents.draw_text(rect, text, align)
    return unless YEZ::STATUS::USE_ICONS
    draw_icon(icon, rect.x-24, rect.y)
  end
  
end

#===============================================================================
# 
# 
#===============================================================================