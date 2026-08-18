#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：YEM System Game Options
# 【來源】Yanfly Engine Melody - System Game Options，最後更新 2010-06-12。
# 【用途】以系統選項選單完整取代 VX 原本 Scene_End。可調整 BGM／BGS／SFX 音量、Windowskin，以及 Battle Engine Melody 的 ATB／動畫／游標等選項；也能控制 Auto Dash 與 Instant Text。
# 【目前啟用命令】COMMANDS 目前依序為 :bgm_volume、:bgs_volume、:sfx_volume、:return_title、:return_menu；其他 :windowskin／:auto_dash／:atb_* 等入口仍保留，但目前被註解停用。
# 【COMMANDS 可用 Symbol】原系統支援 :blank、:volume_bgm/:bgm_volume、:volume_bgs/:bgs_volume、:volume_sfx/:sfx_volume、:animations、:autocursor、:skill_help、:next_actor、:atb_active、:atb_speed、:auto_dash、:instant_text、:windowskin、:return_title、:return_menu；實際分支以本頁程式為準。
# 【變數／Switch】OPTIONS 目前使用：BGM Var2／Mute Sw5、BGS Var3／Mute Sw6、SFX Var4／Mute Sw7、ATB Type Var5、ATB Speed Var6、Animation Sw8、AutoCursor Sw9、NextActor Sw10、SkillHelp Sw11、AutoDash Sw12、InstantText Sw13、Windowskin Var7。啟用新命令前先確認這些 ID 沒被 FS 事件另作他用。
# 【Windowskin】DEFAULT_SKIN_VALUE=14；WINDOW_HASH 每筆格式為 [檔名, BackOpacity, Bold, Italic, Shadow, FontSize, FontSet]，素材放在 Graphics/Windows/。目前表內包含 Red～Black、Window3、windowSKINNNN、Windo77w 等檔名。
# 【Font】DEFAULT 為一般字型 fallback，WRITING 為書寫字型 fallback。玩家缺第一順位字型時會往後嘗試。
# 【Audio】本頁重開 RPG::BGM／ME／BGS／SE#play，把 Game_System 的選項音量納入實際播放；因此不是只有 UI。改音量邏輯時必須同時測地圖、選單、戰鬥與 ME。
# 【相容性／載入順序】原作者明示「完整取代 Scene_End」，任何另一個 Scene_End 完整覆寫都會衝突；Battle Engine Melody 有專用相容分支。FS 後方 Menu／Options 修改需沿現有 Scene_End 鏈整合，不可另起一套。
# 【呼叫方式】正常由主選單「系統／結束」入口進入 Scene_End；不建議事件直接呼叫內部 Window_SystemOptions。若要新增玩家選項，優先增加 COMMANDS／OPTIONS 與對應 handler。
# 【相關素材】Graphics/Windows/*；Audio 本身仍由資料庫／事件指定 BGM/BGS/SE/ME 檔名，本頁只調整播放音量。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、實際資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址等來源資訊保留；Phase 18 Archive 另保存翻譯前 byte-exact 原稿。
# 4. 本輪只整理註解／說明，不修改任何可執行 Ruby；載入順序仍以 FS LoadOrder／Authority 文件為準。
#==============================================================================
#===============================================================================
# 
# Last Date Updated: 2010.06.12
# 
# 
#===============================================================================
# Updates
# -----------------------------------------------------------------------------
#===============================================================================
# 使用說明
# -----------------------------------------------------------------------------
# 
# 
#===============================================================================
# 相容性
# -----------------------------------------------------------------------------
#===============================================================================

$imported = {} if $imported == nil
$imported["SystemGameOptions"] = true

module YEM
  module SYSTEM
    
    TITLE = "         "
    ICON  = 134
    
    #===========================================================================
    # --------------------------------------------------------------------------
    #===========================================================================
    
    COMMANDS =[
      :bgm_volume,
      :bgs_volume,
      :sfx_volume,
      :return_title,
      :return_menu,
    ] # 此結構不可刪除。
    
     OPTIONS ={
      :bgm_variable  => 2,
      :bgm_mute_sw   => 5,
        :bgm_volume  => "背景音樂",
        :bgm_des     => "調整背景音樂(左右鍵調整)",
      :bgs_variable  => 3,
      :bgs_mute_sw   => 6,
        :bgs_volume  => "背景音效",
        :bgs_des     => "調整背景音效(左右鍵調整)",
      :sfx_variable  => 4,
      :sfx_mute_sw   => 7,
        :sfx_volume  => "效果音樂",
        :sfx_des     => "調整效果音樂(左右鍵調整)",
        :mute        => "靜音",
        :audio       => "Audio %d%%",
      :atb_avariable => 5,
        :atb_aname   => "ActiveType",
        :wait_0      => "Full",
        :wait_0_des  => "ATB Gauge does not stop with battle menus open.",
        :wait_1      => "Semi",
        :wait_1_des  => "ATB Gauge stops during target selection.",
        :wait_2      => "Stop",
        :wait_2_des  => "ATB Gauge stops with battle menus open.",
        :wait_3      => "Wait",
        :wait_3_des  => "ATB Gauge stops with any member ready for action.",
      :atb_svariable => 6,
        :atb_sname   => "Turn Speed",
        :atb_s_des   => "Adjusts battle speed. Higher values are faster.",
      :animation_sw  => 8,
        :animations  => "Animations",
        :ani_des     => "Enables/Disables battle animations.",
        :ani_show    => "Show",
        :ani_hide    => "Hide",
      :autocursor_sw => 9,
        :autocursor  => "AutoCursor",
        :curmem_des  => "Enables/Disables cursor memory for actions.",
        :curmem_on   => "Memory",
        :curmem_off  => "Reset",
      :next_actor_sw => 10,
        :next_actor  => "Next Actor",
        :next_des    => "Move to next actor after selecting commands",
        :next_on     => "Auto",
        :next_off    => "Manual",
      :skill_help_sw => 11,
        :skill_help  => "Skill Help",
        :help_des    => "Display skill descriptions during battle phase.",
        :help_on     => "Enabled",
        :help_off    => "Disable",
      :auto_dash_sw  => 12,
        :auto_dash   => "跑步",
        :dash_des    => "調整角色跑步與否",
        :dash_on     => "跑步開",
        :dash_off    => "跑步關",
      :inst_text_sw  => 13,
        :instant_text => "文",
        :inst_des    => "Text appears all at once instead of one by one.",
        :inst_on     => "Instant",
        :inst_off    => "Normal",
      :return_title  => "返回標題",
        :retitle_des => "回到標題畫面",
      :return_menu   => "返回選單",
        :remenu_des  => "回到遊戲的主選單",
      :window_var    => 7,
        :windowskin  => "Windowskin",
        :wind_des    => "Changes the windowskin used for the game.",
    } # 此結構不可刪除。
    
    DEFAULT = ["微軟正黑體","UmePlus Gothic", "Verdana", "Arial", "Courier New"]
    WRITING = ["Comic Sans MS", "Lucida Handwriting", "Arial"]
    
    DEFAULT_SKIN_VALUE  = 14
    WINDOW_HASH ={
              1 => [     "Red",  200, false,  false,   true,   20, DEFAULT],
              2 => [  "Orange",  200, false,  false,   true,   20, DEFAULT],
              3 => [  "Yellow",  200, false,  false,   true,   20, DEFAULT],
              4 => [   "Green",  200, false,  false,   true,   20, DEFAULT],
              5 => [    "Cyan",  200, false,  false,   true,   20, DEFAULT],
              6 => [    "Navy",  200, false,  false,   true,   20, DEFAULT],
              7 => [    "Blue",  200, false,  false,   true,   20, DEFAULT],
              8 => [  "Violet",  200, false,  false,   true,   20, DEFAULT],
              9 => [  "Purple",  200, false,  false,   true,   20, DEFAULT],
             10 => [    "Pink",  200, false,  false,   true,   20, DEFAULT],
             11 => [    "Grey",  200, false,  false,   true,   20, DEFAULT],
             12 => [   "Black",  200, false,  false,   true,   20, DEFAULT],
             13 => [   "Window3",  255, true,  false,  true,   20, DEFAULT],
             14 => [   "windowSKINNNN",  255, true,  false,  true,   20, DEFAULT],#windowgs
             15 => [   "Windo77w",  255, true,  false,  true,   20, DEFAULT],
    } # 此結構不可刪除。
    
  end # SYSTEM
end # YEM

#===============================================================================
#===============================================================================

#===============================================================================
# Vocab
#===============================================================================

module Vocab

  #--------------------------------------------------------------------------
  # 覆寫方法：self.game_end
  #--------------------------------------------------------------------------
  def self.game_end
    return YEM::SYSTEM::TITLE
  end
  
end # Vocab

#===============================================================================
#===============================================================================

module Icon
  
  #--------------------------------------------------------------------------
  # 新增方法：self.system
  #--------------------------------------------------------------------------
  def self.system
    return YEM::SYSTEM::ICON
  end
  
end # Icon

#===============================================================================
#===============================================================================

module Cache
  
  #--------------------------------------------------------------------------
  # 新增方法：self.windows
  #--------------------------------------------------------------------------
  def self.windows(filename); load_bitmap("Graphics/Windows/", filename); end
  
end # Cache
YEM::SYSTEM::WINDOWSKIN_VARIABLE = YEM::SYSTEM::OPTIONS[:window_var]
#===============================================================================
# RPG::BGM
#===============================================================================
unless $imported["BattleEngineMelody"]
module RPG
class BGM < AudioFile
  
  #--------------------------------------------------------------------------
  # 覆寫方法：play
  #--------------------------------------------------------------------------
  def play
    if @name.empty?
      Audio.bgm_stop
      @@last = BGM.new
    else
      vol = @volume
      if $game_variables != nil
        options = YEM::SYSTEM::OPTIONS
        vol = vol * $game_variables[options[:bgm_variable]] / 100
        vol = [[vol, 0].max, 100].min
        vol = 0 if $game_switches[options[:bgm_mute_sw]]
      end
      Audio.bgm_play("Audio/BGM/" + @name, vol, @pitch)
      @@last = self
    end
  end
  
end # BGM
class ME < AudioFile
  
  #--------------------------------------------------------------------------
  # 覆寫方法：play
  #--------------------------------------------------------------------------
  def play
    if @name.empty?
      Audio.me_stop
    else
      vol = @volume
      if $game_variables != nil
        options = YEM::SYSTEM::OPTIONS
        vol = vol * $game_variables[options[:bgm_variable]] / 100
        vol = [[vol, 0].max, 100].min
        vol = 0 if $game_switches[options[:bgm_mute_sw]]
      end
      Audio.me_play("Audio/ME/" + @name, vol, @pitch)
    end
  end
  
end # ME
class BGS < AudioFile
  
  #--------------------------------------------------------------------------
  # 覆寫方法：play
  #--------------------------------------------------------------------------
  def play
    if @name.empty?
      Audio.bgs_stop
      @@last = BGS.new
    else
      vol = @volume
      if $game_variables != nil
        options = YEM::SYSTEM::OPTIONS
        vol = vol * $game_variables[options[:bgs_variable]] / 100
        vol = [[vol, 0].max, 100].min
        vol = 0 if $game_switches[options[:bgs_mute_sw]]
      end
      Audio.bgs_play("Audio/BGS/" + @name, vol, @pitch)
      @@last = self
    end
  end
  
end # BGS
class SE < AudioFile
  
  #--------------------------------------------------------------------------
  # 覆寫方法：play
  #--------------------------------------------------------------------------
  def play
    unless @name.empty?
      vol = @volume
      if $game_variables != nil
        options = YEM::SYSTEM::OPTIONS
        vol = vol * $game_variables[options[:sfx_variable]] / 100
        vol = [[vol, 0].max, 100].min
        vol = 0 if $game_switches[options[:sfx_mute_sw]]
      end
      Audio.se_play("Audio/SE/" + @name, vol, @pitch)
    end
  end
  
end # SE
end # RPG
end # $imported["BattleEngineMelody"]
#===============================================================================
# Game_System
#===============================================================================

class Game_System
  
  #--------------------------------------------------------------------------
  # 新增方法：create_system_options
  #--------------------------------------------------------------------------
  def create_system_options
    return if @created_system_options
    @created_system_options = true
    options = YEM::SYSTEM::OPTIONS
    $game_variables[options[:bgm_variable]] = 100
    $game_variables[options[:bgs_variable]] = 100
    $game_variables[options[:sfx_variable]] = 100
    $game_switches[options[:bgm_mute_sw]] = false
    $game_switches[options[:bgs_mute_sw]] = false
    $game_switches[options[:sfx_mute_sw]] = false
    $game_switches[options[:animation_sw]] = true
    $game_switches[options[:autocursor_sw]] = true
    $game_switches[options[:next_actor_sw]] = true
    $game_switches[options[:skill_help_sw]] = false
    $game_switches[options[:auto_dash_sw]] = false
    $game_switches[options[:inst_text_sw]] = false
    $game_variables[YEM::SYSTEM::WINDOWSKIN_VARIABLE] = 
      YEM::SYSTEM::DEFAULT_SKIN_VALUE
  end
  
end # Game_System

#===============================================================================
# Game_Player
#===============================================================================

class Game_Player < Game_Character
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias dash_sgo dash? unless $@
  def dash?
    if $game_switches[YEM::SYSTEM::OPTIONS[:auto_dash_sw]]
      return false if @move_route_forcing
      return false if $game_map.disable_dash?
      return false if in_vehicle?
      return false if Input.press?(Input::A)
      return true
    else
      return dash_sgo
    end
  end
  
end # Game_Player

#===============================================================================
# Window
#===============================================================================

class Window
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_windowskin
    return if $game_variables == nil
    variable = YEM::SYSTEM::WINDOWSKIN_VARIABLE
    if $game_variables[variable] == 0
      $game_variables[variable] = YEM::SYSTEM::DEFAULT_SKIN_VALUE
    elsif !YEM::SYSTEM::WINDOW_HASH.include?($game_variables[variable])
      $game_variables[variable] = YEM::SYSTEM::DEFAULT_SKIN_VALUE
    end
    skin = YEM::SYSTEM::WINDOW_HASH[$game_variables[variable]]
    change_settings(skin)
  end
  
  #--------------------------------------------------------------------------
  # change_settings
  #--------------------------------------------------------------------------
  def change_settings(skin)
    self.windowskin = Cache.windows(skin[0])
    self.back_opacity = skin[1]
    self.contents.font.bold = Font.default_bold = skin[2]
    self.contents.font.italic = Font.default_italic = skin[3]
    self.contents.font.shadow = Font.default_shadow = skin[4]
    self.contents.font.size = Font.default_size = skin[5]
    self.contents.font.name = Font.default_name = skin[6]
    self.contents.font.color = normal_color
  end
  
end # Window

#===============================================================================
# Window_Base
#===============================================================================

class Window_Base < Window
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias initialize_window_sgo initialize unless $@
  def initialize(x, y, width, height)
    initialize_window_sgo(x, y, width, height)
    self.update_windowskin
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias create_contents_base_sgo create_contents unless $@
  def create_contents
    create_contents_base_sgo
    self.contents.font.color = normal_color
  end
  
end # Window_Base

#===============================================================================
# Window_Selectable
#===============================================================================

class Window_Selectable < Window_Base
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias create_contents_selectable_sgo create_contents unless $@
  def create_contents
    create_contents_selectable_sgo
    self.contents.font.color = normal_color
  end
  
end # Window_Selectable

#===============================================================================
# Window_SaveFile
#===============================================================================

class Window_SaveFile < Window_Base
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias refresh_savefile_mso refresh unless $@
  def refresh
    if @file_exist
      n = @game_variables[YEM::SYSTEM::WINDOWSKIN_VARIABLE]
      if n == 0 or !YEM::SYSTEM::WINDOW_HASH.include?(n)
        n = YEM::SYSTEM::DEFAULT_SKIN_VALUE
      end
      skin = YEM::SYSTEM::WINDOW_HASH[n]
      change_settings(skin)
    end
    refresh_savefile_mso
  end
  
end # Window_SaveFile

#===============================================================================
# Window_Message
#===============================================================================

class Window_Message < Window_Selectable
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias update_show_fast_sgo update_show_fast unless $@
  def update_show_fast
    if $game_switches[YEM::SYSTEM::OPTIONS[:inst_text_sw]]
      if self.pause or self.openness < 255
        @show_fast = false
      else
        @show_fast = true
      end
      if @show_fast and @wait_count > 0
        @wait_count -= 1
      end
    else
      update_show_fast_sgo
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias new_page_sgo new_page unless $@
  def new_page
    self.update_windowskin
    new_page_sgo
  end
  
end # Window_Message

#===============================================================================
# Window_SystemOptions
#===============================================================================

class Window_SystemOptions < Window_Selectable
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(help_window)
    dy = help_window.height
    dh = Graphics.height - dy
    super(0, dy, Graphics.width, dh)
    self.index = 0
    refresh
    @help_window = help_window
    update_help
  end
  
  #--------------------------------------------------------------------------
  # item
  #--------------------------------------------------------------------------
  def item; return @data[self.index]; end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    @data = []
    for command in YEM::SYSTEM::COMMANDS
      case command
      when :windowskin, :animations, :bgm_volume, :sfx_volume, :bgs_volume,
      :auto_dash, :instant_text, :blank, :return_title, :return_menu
      when :skill_help, :atb_active, :atb_speeds, :autocursor, :next_actor
        next unless $imported["BattleEngineMelody"]
        if [:atb_active, :atb_speeds].include?(command)
          type = $game_variables[YEM::BATTLE_ENGINE::BATTLE_TYPE_VARIABLE]
          next unless type == 2
        end
      else; next
      end
      @data.push(command)
    end
    @item_max = @data.size
    create_contents
    for i in 0...@item_max; draw_item(i); end
  end
  
  #--------------------------------------------------------------------------
  # draw_item
  #--------------------------------------------------------------------------
  def draw_item(index)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    obj = @data[index]
    return if obj == nil
    case obj
    when :windowskin
      draw_window_item(obj, rect.clone)
    when :bgm_volume, :sfx_volume, :bgs_volume
      draw_volume_item(obj, rect.clone)
    when :animations, :autocursor, :next_actor, :skill_help,
    :auto_dash, :instant_text
      draw_switch_item(obj, rect.clone)
    when :atb_active, :atb_speeds
      draw_atb_item(obj, rect.clone)
    when :return_title, :return_menu
      draw_solo_item(obj, rect.clone)
    end
  end
  
  #--------------------------------------------------------------------------
  # draw_window_item
  #--------------------------------------------------------------------------
  def draw_window_item(obj, rect)
    title = YEM::SYSTEM::OPTIONS[:windowskin]
    self.contents.font.color = normal_color
    self.contents.draw_text(rect.x, rect.y, rect.width/2, WLH, title, 1)
    dx = rect.x + rect.width/2
    skin_id = $game_variables[YEM::SYSTEM::WINDOWSKIN_VARIABLE]
    skin_name = YEM::SYSTEM::WINDOW_HASH[skin_id][0]
    dx = rect.x + rect.width/2
    self.contents.draw_text(dx, rect.y, rect.width/2, WLH, skin_name, 1)
  end
  
  #--------------------------------------------------------------------------
  # draw_volume_item
  #--------------------------------------------------------------------------
  def draw_volume_item(obj, rect)
    options = YEM::SYSTEM::OPTIONS
    case obj
    when :bgm_volume
      title = options[:bgm_volume]
      value = $game_variables[options[:bgm_variable]]
      mute  = $game_switches[options[:bgm_mute_sw]]
    when :bgs_volume
      title = options[:bgs_volume]
      value = $game_variables[options[:bgs_variable]]
      mute  = $game_switches[options[:bgs_mute_sw]]
    when :sfx_volume
      title = options[:sfx_volume]
      value = $game_variables[options[:sfx_variable]]
      mute  = $game_switches[options[:sfx_mute_sw]]
    else; return
    end
    value = sprintf(options[:audio], value)
    self.contents.font.color = normal_color
    self.contents.draw_text(rect.x, rect.y, rect.width/2, WLH, title, 1)
    self.contents.font.color.alpha = mute ? 128 : 255
    dx = rect.x + rect.width/2
    self.contents.draw_text(dx, rect.y, rect.width/4, WLH, value, 1)
    self.contents.font.color.alpha = mute ? 255 : 128
    dx = rect.x + rect.width*3/4
    self.contents.draw_text(dx, rect.y, rect.width/4, WLH, options[:mute], 1)
  end
  
  #--------------------------------------------------------------------------
  # draw_switch_item
  #--------------------------------------------------------------------------
  def draw_switch_item(obj, rect)
    options = YEM::SYSTEM::OPTIONS
    title = options[obj]
    case obj
    when :animations
      name1 = options[:ani_show]
      name2 = options[:ani_hide]
      toggle = $game_switches[options[:animation_sw]]
    when :autocursor
      name1 = options[:curmem_on]
      name2 = options[:curmem_off]
      toggle = $game_switches[options[:autocursor_sw]]
    when :next_actor
      name1 = options[:next_on]
      name2 = options[:next_off]
      toggle = $game_switches[options[:next_actor_sw]]
    when :skill_help
      name1 = options[:help_on]
      name2 = options[:help_off]
      toggle = $game_switches[options[:skill_help_sw]]
    when :cinematics
      name1 = options[:cinem_on]
      name2 = options[:cinem_off]
      toggle = $game_switches[options[:cinematics_sw]]
    when :auto_dash
      name1 = options[:dash_on]
      name2 = options[:dash_off]
      toggle = $game_switches[options[:auto_dash_sw]]
    when :instant_text
      name1 = options[:inst_on]
      name2 = options[:inst_off]
      toggle = $game_switches[options[:inst_text_sw]]
    else; return
    end
    self.contents.font.color = normal_color
    self.contents.draw_text(rect.x, rect.y, rect.width/2, WLH, title, 1)
    self.contents.font.color.alpha = toggle ? 255 : 128
    dx = rect.x + rect.width/2
    self.contents.draw_text(dx, rect.y, rect.width/4, WLH, name1, 1)
    self.contents.font.color.alpha = toggle ? 128 : 255
    dx = rect.x + rect.width*3/4
    self.contents.draw_text(dx, rect.y, rect.width/4, WLH, name2, 1)
  end
  
  #--------------------------------------------------------------------------
  # draw_atb_item
  #--------------------------------------------------------------------------
  def draw_atb_item(obj, rect)
    options = YEM::SYSTEM::OPTIONS
    case obj
    when :atb_active
      title = options[:atb_aname]
      value = $game_variables[options[:atb_avariable]]
      #---
      self.contents.font.color = normal_color
      name1 = options[:wait_0]
      dx = rect.x + rect.width/2
      self.contents.font.color.alpha = (value == 0) ? 255 : 128
      self.contents.draw_text(dx, rect.y, rect.width/8, WLH, name1, 1)
      name2 = options[:wait_1]
      dx = rect.x + rect.width*5/8
      self.contents.font.color.alpha = (value == 1) ? 255 : 128
      self.contents.draw_text(dx, rect.y, rect.width/8, WLH, name2, 1)
      name3 = options[:wait_2]
      dx = rect.x + rect.width*6/8
      self.contents.font.color.alpha = (value == 2) ? 255 : 128
      self.contents.draw_text(dx, rect.y, rect.width/8, WLH, name3, 1)
      name4 = options[:wait_3]
      dx = rect.x + rect.width*7/8
      self.contents.font.color.alpha = (value == 3) ? 255 : 128
      self.contents.draw_text(dx, rect.y, rect.width/8, WLH, name4, 1)
      #---
    when :atb_speeds
      title = options[:atb_sname]
      value = $game_variables[options[:atb_svariable]] - 1
      #---
      for i in 0...10
        self.contents.font.color = normal_color
        name = (i + 1).to_s
        dx = rect.x + rect.width * (10 + i)/20
        self.contents.font.color.alpha = (value == i) ? 255 : 128
        self.contents.draw_text(dx, rect.y, rect.width/20, WLH, name, 1)
      end
      #---
    else; return
    end
    self.contents.font.color = normal_color
    self.contents.draw_text(rect.x, rect.y, rect.width/2, WLH, title, 1)
  end
  
  #--------------------------------------------------------------------------
  # draw_solo_item
  #--------------------------------------------------------------------------
  def draw_solo_item(obj, rect)
    options = YEM::SYSTEM::OPTIONS
    case obj
    when :return_title, :return_menu
      text = options[obj]
    else; return
    end
    self.contents.font.color = normal_color
    self.contents.draw_text(rect.x, rect.y, rect.width, WLH, text, 1)
  end
  
  #--------------------------------------------------------------------------
  # update
  #--------------------------------------------------------------------------
  def update
    super
    if Input.trigger?(Input::C)
      input_case_c
    elsif Input.repeat?(Input::LEFT)
      input_case_left
    elsif Input.repeat?(Input::RIGHT)
      input_case_right
    end
  end
  
  #--------------------------------------------------------------------------
  # input_case_c
  #--------------------------------------------------------------------------
  def input_case_c
    options = YEM::SYSTEM::OPTIONS
    case item
    when :windowskin
      Sound.play_decision
      $scene.open_skins_window
      return
    when :bgm_volume; switch = options[:bgm_mute_sw]
    when :bgs_volume; switch = options[:bgs_mute_sw]
    when :sfx_volume; switch = options[:sfx_mute_sw]
    when :animations; switch = options[:animation_sw]
    when :autocursor; switch = options[:autocursor_sw]
    when :next_actor; switch = options[:next_actor_sw]
    when :skill_help; switch = options[:skill_help_sw]
    when :cinematics; switch = options[:cinematics_sw]
    when :auto_dash;  switch = options[:auto_dash_sw]
    when :instant_text; switch = options[:inst_text_sw]
    when :return_title
      $scene.command_to_title
      return
    when :return_menu
      Sound.play_decision
      $scene.return_scene
      return
    else; return
    end
    $game_switches[switch] = !$game_switches[switch]
    Sound.play_decision
    RPG::BGM::last.play if item == :bgm_volume
    RPG::BGS::last.play if item == :bgs_volume
    draw_item(self.index)
  end
  
  #--------------------------------------------------------------------------
  # input_case_left
  #--------------------------------------------------------------------------
  def input_case_left
    options = YEM::SYSTEM::OPTIONS
    ignore = false
    case item
    when :bgm_volume, :bgs_volume, :sfx_volume
      value = Input.press?(Input::SHIFT) ? 10 : 1
      case item
      when :bgm_volume; variable = options[:bgm_variable]
      when :bgs_volume; variable = options[:bgs_variable]
      when :sfx_volume; variable = options[:sfx_variable]
      end
      return if $game_variables[variable] == 0
      $game_variables[variable] -= value
      $game_variables[variable] = [$game_variables[variable], 0].max
      ignore = true
    when :atb_active
      variable = options[:atb_avariable]
      return if $game_variables[variable] == 0
      $game_variables[variable] -= 1
      $game_variables[variable] = [$game_variables[variable], 0].max
      ignore = true
    when :atb_speeds
      variable = options[:atb_svariable]
      return if $game_variables[variable] == 1
      $game_variables[variable] -= 1
      $game_variables[variable] = [$game_variables[variable], 1].max
      ignore = true
    when :animations; switch = options[:animation_sw]
    when :autocursor; switch = options[:autocursor_sw]
    when :next_actor; switch = options[:next_actor_sw]
    when :skill_help; switch = options[:skill_help_sw]
    when :cinematics; switch = options[:cinematics_sw]
    when :auto_dash;  switch = options[:auto_dash_sw]
    when :instant_text; switch = options[:inst_text_sw]
    else; return
    end
    unless ignore
      return if $game_switches[switch]
      $game_switches[switch] = true
    end
    Sound.play_cursor
    RPG::BGM::last.play if item == :bgm_volume
    RPG::BGS::last.play if item == :bgs_volume
    draw_item(self.index)
  end
  
  #--------------------------------------------------------------------------
  # input_case_right
  #--------------------------------------------------------------------------
  def input_case_right
    options = YEM::SYSTEM::OPTIONS
    ignore = false
    case item
    when :bgm_volume, :bgs_volume, :sfx_volume
      value = Input.press?(Input::SHIFT) ? 10 : 1
      case item
      when :bgm_volume; variable = options[:bgm_variable]
      when :bgs_volume; variable = options[:bgs_variable]
      when :sfx_volume; variable = options[:sfx_variable]
      end
      return if $game_variables[variable] == 100
      $game_variables[variable] += value
      $game_variables[variable] = [$game_variables[variable], 100].min
      ignore = true
    when :atb_active
      variable = options[:atb_avariable]
      return if $game_variables[variable] == 3
      $game_variables[variable] += 1
      $game_variables[variable] = [$game_variables[variable], 3].min
      ignore = true
    when :atb_speeds
      variable = options[:atb_svariable]
      return if $game_variables[variable] == 10
      $game_variables[variable] += 1
      $game_variables[variable] = [$game_variables[variable], 10].min
      ignore = true
    when :animations; switch = options[:animation_sw]
    when :autocursor; switch = options[:autocursor_sw]
    when :next_actor; switch = options[:next_actor_sw]
    when :skill_help; switch = options[:skill_help_sw]
    when :cinematics; switch = options[:cinematics_sw]
    when :auto_dash;  switch = options[:auto_dash_sw]
    when :instant_text; switch = options[:inst_text_sw]
    else; return
    end
    unless ignore
      return if !$game_switches[switch]
      $game_switches[switch] = false
    end
    Sound.play_cursor
    RPG::BGM::last.play if item == :bgm_volume
    RPG::BGS::last.play if item == :bgs_volume
    draw_item(self.index)
  end
  
  #--------------------------------------------------------------------------
  # update_help
  #--------------------------------------------------------------------------
  def update_help
    case item
    when :bgm_volume; type = :bgm_des
    when :bgs_volume; type = :bgs_des
    when :sfx_volume; type = :sfx_des
    when :animations; type = :ani_des
    when :autocursor; type = :curmem_des
    when :next_actor; type = :next_des
    when :skill_help; type = :help_des
    when :cinematics; type = :cinem_des
    when :windowskin; type = :wind_des
    when :auto_dash;  type = :dash_des
    when :instant_text; type = :inst_des
    when :return_title; type = :retitle_des
    when :return_menu;  type = :remenu_des
    when :atb_active
      case $game_variables[YEM::SYSTEM::OPTIONS[:atb_avariable]]
      when 0; type = :wait_0_des
      when 1; type = :wait_1_des
      when 2; type = :wait_2_des
      when 3: type = :wait_3_des
      end
    when :atb_speeds; type = :atb_s_des
    else; type = nil
    end
    text = YEM::SYSTEM::OPTIONS[type].to_s
    @help_window.set_text(text, 1)
  end
  
end # Window_SystemOptions

#===============================================================================
# Window_Skins
#===============================================================================

class Window_Skins < Window_Selectable
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize
    dx = Graphics.width/4
    dw = Graphics.width/2
    dh = Graphics.height - 112
    super(dx, 56, dw, dh)
    @column_max = 1
    self.index = 0
    self.back_opacity = 255
    self.openness = 0
    self.active = false
    refresh
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    @data = []
    variable = $game_variables[YEM::SYSTEM::WINDOWSKIN_VARIABLE]
    hash = YEM::SYSTEM::WINDOW_HASH.sort{ |a,b| a[0] <=> b[0] }
    for key in hash
      @data.push(key[0])
      self.index = key[0] - 1 if key[0] == $game_variables[variable]
    end
    @item_max = @data.size
    create_contents
    for i in 0...@item_max
      draw_item(i)
    end
  end
  
  #--------------------------------------------------------------------------
  # draw_item
  #--------------------------------------------------------------------------
  def draw_item(index)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    rect.width -= 4
    text = YEM::SYSTEM::WINDOW_HASH[@data[index]][0]
    self.contents.draw_text(rect, text, 1)
  end
  
end # Window_Skins

#===============================================================================
# Scene_Title
#===============================================================================

class Scene_Title < Scene_Base
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias create_game_objects_sgo create_game_objects unless $@
  def create_game_objects
    create_game_objects_sgo
    $game_system.create_system_options
  end
  
end # Scene_Title

#===============================================================================
# Scene_Map
#===============================================================================

class Scene_Map < Scene_Base
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias start_sgo start unless $@
  def start
    $game_system.create_system_options
    start_sgo
  end
  
end # Scene_Map

#===============================================================================
# Scene_Battle
#===============================================================================

class Scene_Battle < Scene_Base
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  unless $imported["BattleEngineMelody"]
  alias display_normal_animation_sgo display_normal_animation unless $@
  def display_normal_animation(targets, animation_id, mirror = false)
    return if $game_switches[YEM::SYSTEM::OPTIONS[:animation_sw]]
    display_normal_animation_sgo(targets, animation_id, mirror)
  end
  end # $imported["BattleEngineMelody"]
  
end # Scene_Battle

#===============================================================================
# Scene_End
#===============================================================================

class Scene_End < Scene_Base
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  attr_accessor :window_var
  
  #--------------------------------------------------------------------------
  # 覆寫方法：start
  #--------------------------------------------------------------------------
  def start
    super
    create_menu_background
    @window_var = YEM::SYSTEM::WINDOWSKIN_VARIABLE
    @help_window = Window_Help.new
    @help_window.opacity=0
    @help_window.y = 100
    @options_window = Window_SystemOptions.new(@help_window)
    @options_window.opacity=0
    @options_window.y = 150
    @skins_window = Window_Skins.new
  end
  
  #--------------------------------------------------------------------------
  # 覆寫方法：post_start
  #--------------------------------------------------------------------------
  def post_start; super; end
  
  #--------------------------------------------------------------------------
  # 覆寫方法：pre_terminate
  #--------------------------------------------------------------------------
  def pre_terminate; super; end
    
  #--------------------------------------------------------------------------
  # 覆寫方法：close_command_window
  #--------------------------------------------------------------------------
  def close_command_window; end
  
  #--------------------------------------------------------------------------
  # 覆寫方法：terminate
  #--------------------------------------------------------------------------
  def terminate
    super
    @help_window.dispose
    @options_window.dispose
    @skins_window.dispose
    dispose_menu_background
  end
  
  #--------------------------------------------------------------------------
  # 覆寫方法：update
  #--------------------------------------------------------------------------
  def update
    super
    @help_window.update
    @skins_window.update
    update_menu_background
    if @options_window.active
      update_options_window
    elsif @skins_window.active
      update_skins_window
    end
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：update_options_window
  #--------------------------------------------------------------------------
  def update_options_window
    @options_window.update
    if Input.trigger?(Input::B)
      Sound.play_cancel
      return_scene
    end
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：open_skins_window
  #--------------------------------------------------------------------------
  def open_skins_window
    @skins_window.open
    @skins_window.index = $game_variables[YEM::SYSTEM::WINDOWSKIN_VARIABLE] - 1
    @skins_window.active = true
    @options_window.active = false
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：update_skins_window
  #--------------------------------------------------------------------------
  def update_skins_window
    if @last_index != @skins_window.index
      @last_index = @skins_window.index
      update_skins
    end
    if Input.trigger?(Input::B)
      Sound.play_cancel
      @skins_window.close
      @skins_window.active = false
      @options_window.active = true
    elsif Input.trigger?(Input::C)
      Sound.play_decision
      @skins_window.close
      @skins_window.active = false
      @options_window.active = true
    end
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：update_skins
  #--------------------------------------------------------------------------
  def update_skins
    $game_variables[@window_var] = @skins_window.index + 1
    @options_window.update_windowskin
    @options_window.refresh
    @help_window.update_windowskin
    @help_window.set_text("")
    @options_window.update_help
    @skins_window.update_windowskin
    @skins_window.back_opacity = 255
    @skins_window.refresh
    @options_window.draw_item(@options_window.index)
  end
  
end # Scene_End

#===============================================================================
# 
# END OF FILE
# 
#===============================================================================