#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FFXIII Layout｜Shanghai Simple Script - Final Fantasy 13 Main Menu
# 【依賴】必須放在 Yanfly Engine Melody 的 Main Menu Melody 後方。本頁重開 Window_Base、數個 Menu Window 與 Scene_Menu，並直接修改 YEM::MENU::MENU_RIGHT_SIDE。
# 【用途】把主選單改成 FFXIII 風格：角色直式立繪、職業色、HP/MP/EXP/JP、地點／時間／金錢、命令背景與動態光效。
# 【主要設定】SSS::MENU_BACK_IMAGE='MenuBack'；MENU_BACK_ITEM_IMAGE='MenuBackItem'（原文件要求 160x24）；MENU_HELP_TEXT_COLOR；MENU_LOCATION；MENU_ACTOR_IMAGES（Actor ID→104x288 System 圖）；MENU_CLASS_COLORS（Class ID→Window 色號）；MENU_HELP_WINDOW（命令文字→說明）。
# 【角色圖範例】MENU_ACTOR_IMAGES[1]='menu_喬伊'；新增角色時需增加 Actor ID 對應，圖片放 Graphics/System/，原版設計尺寸 104x288。
# 【目前固定素材】Graphics/System/MenuBack、MenuBackItem、MenuBack_a、MenuBack_b、circle、menu_喬伊／米亞／艾卓／薇娜／艾薇／泰勒等；Graphics/Pictures/le.png。Scene_Menu 另使用 Cache.menu() 讀取命令圖像，實際檔名由 Menu Melody 命令設定決定。
# 【Help 文字】MENU_HELP_WINDOW 的 Key 必須與實際主選單 command string 完全一致；現在部分 Key 是空白字串組合，這屬現行專案資料，不要因「看起來怪」就重排。
# 【執行方式】由 Scene_Menu 自動生效，沒有獨立事件 Script Call。start/terminate/update_command_selection 都以 alias 接在 Main Menu Melody 後。
# 【載入順序】Main Menu Melody → 本 FFXIII Layout → 後續 FS Menu/UI Patch。若直接搬到 YEM Main Menu Melody 前方，Window／Scene API 不完整會失效。
# 【音效備註】頁內多個 piano*/Accept/guitar Audio.se_play 行目前是註解，不是 Runtime 固定素材；素材刪除仍要反查其他腳本／事件。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、實際資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址保留；Phase 19 Archive 另保存翻譯前 byte-exact 原稿。
# 4. 本輪只整理文件／註解；Runtime code 與載入順序不得因翻譯而改變。
#==============================================================================
#===============================================================================
# 
# Last Date Updated: 2010.06.02
# Level: Normal
# 
#===============================================================================
# 使用說明
# -----------------------------------------------------------------------------
# 
#===============================================================================
 
$imported = {} if $imported == nil
$imported["FinalFantasy13Menu"] = true
 
module SSS
  MENU_BACK_IMAGE = "MenuBack"
 
  MENU_BACK_ITEM_IMAGE = "MenuBackItem"
 
  MENU_HELP_TEXT_COLOR = Color.new(255, 255, 255)
 
  MENU_LOCATION = " %s"
 
  MENU_ACTOR_IMAGES ={
    1 => "menu_喬伊",
    2 => "menu_米亞",
    3 => "menu_艾卓",
    4 => "menu_薇娜",
    5 => "menu_艾薇",
    6 => "menu_泰勒",
    7 => "menu_wiegraf",
    8 => "menu_rk",
    18 => "menu_樹寶",
    19 => "menu_蝠寶",
    20 => "menu_鼠寶",
  } # 詳見頁首繁中維護說明
 
  MENU_CLASS_COLORS ={
    1 => 2,
    2 => 6,
    3 => 18,
    4 => 4,
    5 => 13,
    6 => 8,
    7 => 18,
    8 => 25,
    9 => 2,
  } # 詳見頁首繁中維護說明
 
  MENU_HELP_WINDOW ={
    ""     => "查看各式各樣的物品",
    " "   => "可以查看與使用各種技能",
    "  "    => "更換隊伍成員身上的裝備",
    "    "    => "檢視隊伍中成員的資料",
    "     "    => "Manage party's formation.",
    "      "    => "各式任務的明細列表",
    "       "     => "變更隊伍中的成員",
    "        " => "儲存當下遊戲進度",
    "         "   => "遊戲系統的變更",
  } # 詳見頁首繁中維護說明
end
 
#==============================================================================
#==============================================================================
 
class Window_Base < Window
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias initialize_sss_ff13_menu_window_base initialize unless $@
  def initialize(x, y, width, height)
    initialize_sss_ff13_menu_window_base(x, y, width, height)
    self.opacity = 0 if $scene.is_a?(Scene_Menu)
  end
end
 
#==============================================================================
#==============================================================================
 
class Window_MenuHelp < Window_Help
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def set_text(text, align = 0)
    if text != @text or align != @align
      self.contents.clear
      self.contents.font.shadow = false
      self.contents.font.color = SSS::MENU_HELP_TEXT_COLOR
      self.contents.font.size = 18#
      self.contents.draw_text(94, -5, self.width - 40, WLH, text, align)
      #self.contents.draw_text(4, 0, self.width - 40, WLH, text, align)
      @text = text
      @align = align
    end
  end
end
 
#==============================================================================
#==============================================================================
 
class Window_MainMenuParty < Window_Selectable
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x-24, y, Graphics.width-x+32, Graphics.height-y)
    self.active = false
    @column_max = [4, 4].max
    @spacing = -6
    @count2 = 0
    refresh
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    $game_temp.in_battle = true # 詳見頁首繁中維護說明
    @data = $game_party.members
    @item_max = @data.size
    create_contents
    for i in 0...@item_max
      draw_item(i)
    end
    $game_temp.in_battle = false # 詳見頁首繁中維護說明
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_item(index)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    actor = @data[index]
    unless actor.nil?
      draw_actor_image(actor, rect)
      draw_actor_name(actor, rect)
      draw_actor_state(actor, rect.x+2, 292 - WLH*7/2 - 40, 96)
      draw_actor_class(actor, rect)
      draw_actor_level(actor, rect)
      draw_actor_hp(actor, rect)
      draw_actor_exp_gauge(actor, rect.x+2, y+213, 50)
      draw_actor_jp(actor, rect.x+3, y-12, 96)
      draw_actor_mp(actor, rect)
    end
  end
####  

  def draw_actor_jp(actor, dx, dy, dw = 50)
    return if actor.class_id == nil
    icon = $imported["Icons"] ? YEZ::ICONS[:txtjp] : YEZ::JOB::JP_ICON
    draw_icon(icon, dx + dw - 22, dy+225)
    text = actor.class_jp[actor.class_id]
    self.contents.font.size = 15
    self.contents.draw_text(dx+6, dy+229, dw - 24, WLH, text, 2)
  end
  
  def draw_actor_exp_gauge(actor, x, y, width = 180)
    diff = [actor.next_diff_exp, 1].max
    rest = [actor.next_rest_exp, 1].max
    draw_gauge(KGC::GenericGauge::EXP_IMAGE,
      x, y, width, diff - rest, diff,
      KGC::GenericGauge::EXP_OFFSET,
      KGC::GenericGauge::EXP_LENGTH,
      KGC::GenericGauge::EXP_SLOPE
    )
  end
####
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_actor_image(actor, rect)
    filename = SSS::MENU_ACTOR_IMAGES[actor.id]
    return if filename.nil?
    bitmap = Cache.system(filename)
    image_rect = Rect.new(0, 0, 100, 284)#284
    #image_rect = Rect.new(2, 2, rect.width-4, 284)
    #self.contents.blt(rect.x+2, rect.y+2, bitmap, image_rect)
    self.contents.blt(rect.x, rect.y, bitmap, image_rect)####
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_actor_name(actor, rect)
    name = actor.name
    self.contents.font.size = Font.default_size # 詳見頁首繁中維護說明
    self.contents.font.color = normal_color
    self.contents.draw_text(rect.x-9, WLH*3/2-22, rect.width, WLH, name, 1)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_actor_class(actor, rect)
    name = actor.class.name
    self.contents.font.size = Font.default_size - 4
    color_id = SSS::MENU_CLASS_COLORS[actor.class.id].to_i
    self.contents.font.color = text_color(color_id)
    self.contents.draw_text(rect.x-9, WLH*0-2, rect.width, WLH, name, 1)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_actor_level(actor, rect)
    self.contents.font.size = Font.default_size - 4
    self.contents.font.color = power_up_color
    yy = 292 - WLH*7/2 - 8
    self.contents.draw_text(rect.x+4, yy, rect.width-8, WLH, Vocab.level_a, 0)
    #draw_icon(217, rect.x+4, yy)#274
    self.contents.font.color = normal_color
    self.contents.font.size += 2
    self.contents.draw_text(rect.x+4+26, yy-1, rect.width-8, WLH, actor.level, 0)
  end
  #--------------------------------------------------------------------------
  # * Draw Actor HP再這兒調整
  #--------------------------------------------------------------------------
    def draw_actor_hp(actor, rect)
    self.contents.font.color = system_color
    yy = 288 - WLH*5/2 - 6#yy = 288 - WLH*5/2 - 4，調整位置
    #draw_actor_hp_gauge(actor, rect.x+4, yy, rect.width-8)    
      draw_slant_bar(rect.x+4,yy+12,actor.hp,actor.maxhp,rect.width-30,8,
        SLANT_BARS::DEFAULT_HP_BAR_COLOR,SLANT_BARS::DEFAULT_HP_END_COLOR)
        
    self.contents.font.size = Font.default_size + 2 # 詳見頁首繁中維護說明
    #self.contents.draw_text(rect.x+4, yy, rect.width-8, WLH, Vocab::hp_a)
    #draw_icon(272, rect.x+4, yy)
    
    self.contents.font.size -= 4
    self.contents.font.color = normal_color
    self.contents.draw_text(rect.x+4, yy+2, 30, WLH, "")
    self.contents.font.size += 4
    
    self.contents.font.color = hp_color(actor)
    last_font_size = self.contents.font.size
    xr = rect.x+4 + 86 # 詳見頁首繁中維護說明
      self.contents.font.size = 17
      self.contents.draw_text(xr - 71, yy, 26, WLH, actor.hp, 2)
      self.contents.font.color = normal_color
      self.contents.draw_text(xr - 48, yy, 12, WLH, "/", 1)#xr - 44
      self.contents.draw_text(xr - 28, yy, 26, WLH, actor.maxhp, 2)#xr - 32
  end
  #--------------------------------------------------------------------------
  def draw_actor_hp_gauge(actor, x, y, width)
    gw = width * actor.hp / actor.maxhp
    gc1 = hp_gauge_color1
    gc2 = hp_gauge_color2
    self.contents.fill_rect(x, y + WLH - 10, width, 6, gauge_back_color)
    self.contents.gradient_fill_rect(x, y + WLH - 10, gw, 6, gc1, gc2)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_actor_mp(actor, rect)
    self.contents.font.color = system_color
    yy = 300 - WLH*4/2 - 12
    #draw_actor_mp_gauge(actor, rect.x+4, yy, rect.width-8)
      draw_slant_bar(rect.x+4,yy+12,actor.mp,actor.maxmp,rect.width-30,8,
        SLANT_BARS::DEFAULT_MP_BAR_COLOR,SLANT_BARS::DEFAULT_MP_END_COLOR)
    #self.contents.draw_text(rect.x+4, yy, rect.width-67, WLH, MP_Types[actor.class.id - 1])
    #self.contents.draw_icon(MP_Types[actor.class.id - 1], rect.x+4, yy)
    
    self.contents.font.size = Font.default_size - 4 # 詳見頁首繁中維護說明
    self.contents.font.color = normal_color
    case actor.class.id
    when 1, 2
      self.contents.draw_text(rect.x+4, yy+1, 26, WLH, "")
    when 3
      self.contents.draw_text(rect.x+4, yy+1, 26, WLH, "")
    when 4..6, 7
      self.contents.draw_text(rect.x+4, yy+1, 26, WLH, "")
    end
    
    self.contents.font.color = mp_color(actor)
    last_font_size = self.contents.font.size
    xr = rect.x+4 + 86
      self.contents.font.size = 17
      self.contents.draw_text(xr - 70, yy, 26, WLH, actor.mp, 2)
      self.contents.font.color = normal_color
      self.contents.draw_text(xr - 44, yy, 12, WLH, "/", 1)
      self.contents.draw_text(xr - 32, yy, 26, WLH, actor.maxmp, 2)
  end
  #--------------------------------------------------------------------------
def draw_actor_mp_gauge(actor, x, y, width)
    gw = width * actor.mp / actor.maxmp
    gc1 = mp_gauge_color1(actor)#mp_gauge_color1(actor)
    gc2 = mp_gauge_color2(actor)#mp_gauge_color2(actor)
    self.contents.fill_rect(x, y + WLH - 8, width, 6, gauge_back_color)
    self.contents.gradient_fill_rect(x, y + WLH - 8, gw, 6, gc1, gc2)
  end 

  #--------------------------------------------------------------------------
  # * Item Rect這邊調間距
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = Rect.new(0, 0, 0, 0)
    rect.width = 116 # 詳見頁首繁中維護說明
    rect.height = 288#288
    rect.x = index % @column_max * (rect.width + @spacing) # 詳見頁首繁中維護說明
    rect.y = index / @column_max * WLH # 詳見頁首繁中維護說明
    return rect
  end
  
  def update_cursor
    if @index < 0               # 無光標
      self.cursor_rect.empty
    elsif @index < @column_max    # 正常狀態
      self.cursor_rect.set((index * 110)-2, -2, 104, 288)
    end

      if @count2 <= 10
          self.cursor_rect.x += 4 if @count2 == 2
          self.cursor_rect.x-= 4 if @count2 == 4
          self.cursor_rect.x += 4 if @count2 == 6
          self.cursor_rect.x -= 4 if @count2 == 8
          @count2 += 1
      end  
  end
end
 
#==============================================================================
#==============================================================================
 
class Window_MenuTimer < Window_Base
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize
    super(0, Graphics.height - 60, 120, 56)
    self.contents.font.size = Font.default_size - 1
    self.contents.font.shadow = false
    self.contents.font.color = SSS::MENU_HELP_TEXT_COLOR
    refresh
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    format = "%03d:%02d:%02d"
    @game_time = Graphics.frame_count / Graphics.frame_rate
    hours = @game_time / 3600
    minutes = @game_time / 60 % 60
    seconds = @game_time % 60
    text = sprintf(format, hours, minutes, seconds)
    #self.contents.draw_text(0, 0, contents.width-4, WLH, text, 2)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update
    super
    refresh if @game_time != (Graphics.frame_count / Graphics.frame_rate)
  end
end
 
#==============================================================================
#==============================================================================
 
class Window_MenuGold < Window_Base
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize
    super(430, Graphics.height - 38, 120, 56) # 詳見頁首繁中維護說明
    self.contents.font.size = Font.default_size - 1
    self.contents.font.shadow = false
    self.contents.font.color = SSS::MENU_HELP_TEXT_COLOR
    refresh
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    text = sprintf("%d%s", $game_party.gold, Vocab.gold)
    self.contents.draw_text(0, 0, contents.width-4, WLH, text, 0)
  end
end
 
#==============================================================================
#==============================================================================
 
class Window_MenuLocation < Window_Base
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize        #2-16
    super(Graphics.width/2+86, Graphics.height - 60, Graphics.width/2+16, 56)
    self.contents.font.size = Font.default_size - 1
    self.contents.font.shadow = false
    self.contents.font.color = SSS::MENU_HELP_TEXT_COLOR
    refresh
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    text = sprintf(SSS::MENU_LOCATION, $game_map.map_name)
    self.contents.draw_text(4, 0, contents.width, WLH, text, 0)
  end
end
 
#===============================================================================
#===============================================================================
 
YEM::MENU::USE_ICONS = false
YEM::MENU::MENU_RIGHT_SIDE = false
YEM::MENU::ON_SCREEN_MENU = false
YEM::MENU::USE_MULTI_VARIABLE_WINDOW = false
 
#==============================================================================
#==============================================================================
 
class Scene_Menu < Scene_Base
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias start_sss_ff13_menu start unless $@
  def start
    start_sss_ff13_menu
    start_ff13_menu_style
    fireflies(7)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias terminate_sss_ff13_menu terminate unless $@
  def terminate
    @help_window.dispose
    @location_window.dispose
    @menu_timer_window.dispose
    @menubackitem_sprite.bitmap.dispose
    @menubackitem_sprite.dispose
    @menuback_sprite.dispose#++
    @menuback_sprite.bitmap.dispose#++
    @menuback_sprite2.dispose#++
    @menuback_sprite2.bitmap.dispose#++
    @menuback_sprite3.dispose#++
    @menuback_sprite3.bitmap.dispose#++
    @light.dispose
    @light2.dispose
    terminate_sss_ff13_menu
    fireflies(0)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def create_menu_background
    @menuback_sprite = Sprite.new
    @menuback_sprite.bitmap = Cache.system("MenuBack_a")
    @menuback_sprite2 = Sprite.new
    @menuback_sprite2.bitmap = Cache.system("MenuBack_b")
    @menuback_sprite2.z -= 2
    @menuback_sprite3 = Sprite.new
    @menuback_sprite3.bitmap = Cache.system("circle")
    @menuback_sprite3.z += 3
    @menuback_sprite3.angle +=-1
    @menuback_sprite3.blend_type=1
    @menuback_sprite3.x=-56# - 50#####
    @menuback_sprite3.y=195
    @menuback_sprite3.opacity=150
    @menuback_sprite3.ox=130
    @menuback_sprite3.oy=130
    
    @light = Sprite.new
		@light.bitmap = Cache.picture("le.png")
		@light.visible = true
    @light.x = 407 # 詳見頁首繁中維護說明
    @light.y = -20 # 詳見頁首繁中維護說明
    @light.zoom_x = 200 / 100.0
    @light.zoom_y = 200 / 100.0
    @light.opacity = 100
    @light.tone = Tone.new(255,-100,-255, 0)
    @light.blend_type = 1
		@light.z = 1000
    
    @light2 = Sprite.new
		@light2.bitmap = Cache.picture("le.png")
		@light2.visible = true
    @light2.zoom_x = 100 / 100.0
    @light2.zoom_y = 50 / 100.0
    @light2.opacity = 70
    @light2.tone = Tone.new(200,200,100, 100)
    @light2.blend_type = 1
		@light2.z = 2#1000

    #####################################################################
    @sprites = [] # 詳見頁首繁中維護說明
    images_name = # 詳見頁首繁中維護說明
    ["Menu01","Menu02","Menu03","Menu04","Menu05","Menu06","Menu07","Menu08"]
    for i in 0...images_name.size
     @sprites[i] = Sprite.new
     @sprites[i].bitmap = Cache.menu(images_name[i])
     @sprites[i].x = (i * -10)+30+90 if i>=4
     @sprites[i].x = (i * 10)-30+80 if i<4
     @sprites[i].y = (i * @sprites[i].height*1.307 + (Graphics.height - @sprites[i].height)/1.5 )-171
     @sprites[i].opacity = 255
     @sprites[i].z = 9999
     @sprites[i].tone = Tone.new(0,0,0,255)
    end
    ####################################################################
    update_menu_background
  end
  
  ######################################################################
  def set_tone(index)
    for i in 0..8
      @sprites[i].tone = Tone.new(0,0,0,255)
    end
    @sprites[index].tone = Tone.new(0,0,0)
    
    #RPG::SE.new("pianoC", 70, 100).play if index == 0
    #Audio.se_play("Audio/SE/pianoC",70,100) if index == 0
    #Audio.se_play("Audio/SE/Accept",70,100) if index == 1
    #Audio.se_play("Audio/SE/pianoE",70,100) if index == 2
    #Audio.se_play("Audio/SE/pianoF",70,100) if index == 3
    #Audio.se_play("Audio/SE/pianoG",70,100) if index == 4
    #Audio.se_play("Audio/SE/pianoA",70,100) if index == 5
    #Audio.se_play("Audio/SE/pianoB",70,100) if index == 6
    #Audio.se_play("Audio/SE/pianoC2",70,100) if index == 7
    #Audio.se_play("Audio/SE/guitar",70,100) if index == 8
  end
  ######################################################################
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_menu_background
    super
    @menubackitem_sprite.update unless @menubackitem_sprite.nil?
    @menu_timer_window.update unless @menu_timer_window.nil?
    @menuback_sprite3.angle+=0.6
    @light.opacity = rand(20) + 90
    @light.x = 407 + rand(3) - 3
    @light.y = -20 + rand(3) - 3
#    Audio.se_play("Audio/SE/pianoC",70,100) if @command_window.index == 0
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def create_menu_back_items
    @menubackitem_sprite = Sprite.new
    width = 160 # 詳見頁首繁中維護說明
    height = @command_window.height-32 # 詳見頁首繁中維護說明
    @menubackitem_sprite.bitmap = Bitmap.new(width, height)
    bitmap = Cache.system(SSS::MENU_BACK_ITEM_IMAGE)
    rect = Rect.new(0, 0, 160, 24)
    y = 0
    loop do
      break if y >= height
      @menubackitem_sprite.bitmap.blt(0, y, bitmap, rect)
      y += 24#y += 24這邊改圖片間距離
    end
    @menubackitem_sprite.y = @command_window.y+16#y+16
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def start_ff13_menu_style
    @gold_window.dispose
    @gold_window = Window_MenuGold.new
    @gold_window.x -= 185
    @gold_window.y -= 13
    @menu_timer_window = Window_MenuTimer.new
    @location_window = Window_MenuLocation.new
    @location_window.x += 10
    @location_window.y +=8
    @help_window = Window_MenuHelp.new
    @help_window.x += 48
    @help_window.y -= 12
    @help_window.width -= 48
    @help_window.create_contents
    @help_window.contents.font.size = Font.default_size - 4
    @command_window.y = @help_window.height - 9#不用調整
    @status_window.dispose
    x = @command_window.width
    y = @help_window.height-9
    @status_window = Window_MainMenuParty.new(x, y)
    @status_window.y -= 9
    @command_window.x -= 4
    @help_window.y += 12
    #set_tone(@command_window.index)
    update_help_window
    create_menu_back_items
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias update_command_selection_sss_ff13_menu update_command_selection unless $@
  def update_command_selection
    update_help_window
    update_command_selection_sss_ff13_menu
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_help_window
    
    return if @help_window_index == @command_window.index
    @help_window_index = @command_window.index
    commands = @command_window.commands
    text = SSS::MENU_HELP_WINDOW[commands[@help_window_index]].to_s
    @help_window.set_text(text)
#    Audio.se_play("Audio/SE/pianoC",60,70) if @command_window.index == 0
#    Audio.se_play("Audio/SE/pianoD",60,70) if @command_window.index == 1
#    Audio.se_play("Audio/SE/pianoE",60,70) if @command_window.index == 2
#    Audio.se_play("Audio/SE/pianoF",60,70) if @command_window.index == 3
#    Audio.se_play("Audio/SE/pianoG",60,70) if @command_window.index == 4
#    Audio.se_play("Audio/SE/pianoA",60,70) if @command_window.index == 5
#    Audio.se_play("Audio/SE/pianoB",60,70) if @command_window.index == 6
#    Audio.se_play("Audio/SE/pianoC2",60,70) if @command_window.index == 7
#    Audio.se_play("Audio/SE/guitar",60,70) if @command_window.index == 8
  end
end
 
#===============================================================================
# 
# 
#===============================================================================