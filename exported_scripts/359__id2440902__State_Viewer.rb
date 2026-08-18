#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：State Viewer v1.1
# 【來源】modern algebra（rmrk.net），2011-03-02。
# 【用途】為 State 增加說明文字，並提供專用 Scene_StateView 列出狀態名稱、Icon 與效果說明。可由事件、Status Scene 或支援的 Menu System 進入。
# 【State Notetag】\DESC[說明文字]：設定 State 描述；例如 \DESC[每回合持續損失 HP]。\DESC_HIDE：完全不在 State Viewer 顯示，可用於 dummy／內部 State。Notetag 是 Runtime 格式，不可改名。
# 【Script Call】$scene = Scene_StateView.new 可直接開啟列表。Scene 亦支援 return_scene／return_args，用於從 Status／Menu 返回原畫面。
# 【設定】MASV_STATUS_ACCESS=false；MASV_STATUS_KEY=Input::SHIFT；MASV_MENU_ACCESS=false；MASV_MENU_INDEX=4；MASV_MENU_ICON=240；MASV_LABEL='State List'；MASV_SHOW_LABEL=true；FontName=Font.default_name、FontSize=32、Color=16、Align=1；MASV_SHOW_ALL_STATES=true。
# 【揭露模式】MASV_SHOW_ALL_STATES=true 時顯示所有未隱藏 State；false 時只顯示曾被 Actor／Enemy 實際附加過的 State。Game_System#masv_states_afflicted 保存已見 State ID，Game_Battler#add_state 會自動登錄。
# 【Menu 相容】腳本內建 Default Menu、YEM Menu、FSCMS、Phantasia-Esque CMS 的自動入口，但目前 MASV_MENU_ACCESS=false，因此不應為了「沒在選單看到」就判定腳本未使用；事件仍可直接 Script Call。
# 【載入順序】若另一腳本先提供 State#description，本頁會尊重既有方法；若使用 Menu Script，原作者要求 State Viewer 位於 Menu Script 後方。Phase 18 掃描顯示 State Viewer API 幾乎自包含，沒有值得冒風險的跨頁 alias 可收斂，因此保留獨立 Scene。
# 【相關素材】使用 State Iconset 與一般 Window Skin，沒有固定專用圖片／音效檔名。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、實際資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址等來源資訊保留；Phase 18 Archive 另保存翻譯前 byte-exact 原稿。
# 4. 本輪只整理註解／說明，不修改任何可執行 Ruby；載入順序仍以 FS LoadOrder／Authority 文件為準。
#==============================================================================
#==============================================================================
#    Version: 1.1
#    Author: modern algebra (rmrk.net)
#    Date: March 2, 2011
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# 說明：
#
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# 使用說明：
#
#
#      $scene = Scene_StateView.new
#
#      \DESC[x]
#
#      \DESC[This state drains HP every turn]
#
#      \DESC_HIDE
#
#==============================================================================
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
# 設定
#``````````````````````````````````````````````````````````````````````````````
MASV_STATUS_ACCESS = false
  MASV_STATUS_KEY = Input::SHIFT
MASV_MENU_ACCESS = false
  MASV_MENU_INDEX = 4
  MASV_MENU_ICON = 240
MASV_LABEL = "State List"
MASV_SHOW_LABEL = true
  MASV_LABEL_FONTNAME = Font.default_name
  MASV_LABEL_FONTSIZE = 32
  MASV_LABEL_COLOR = 16
  MASV_LABEL_ALIGN = 1
MASV_SHOW_ALL_STATES = true
#``````````````````````````````````````````````````````````````````````````````
# 設定區結束
#//////////////////////////////////////////////////////////////////////////////

#==============================================================================
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# 變更摘要：
#==============================================================================

class RPG::State
  unless self.method_defined? (:description) 
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def description
      return self.note[/\\DESC\[(.+?)\]/i].nil? ? "" : $1.to_s
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def desc_exclude?
    return !self.note[/\\DESC_HIDE/i].nil?
  end
end

#==============================================================================
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# 變更摘要：
#==============================================================================

class Game_System
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_reader :masv_states_afflicted
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias molbr_stvw_inze_4rp8 initialize
  def initialize (*args)
    @masv_states_afflicted = []
    molbr_stvw_inze_4rp8 (*args) # 執行原方法
  end
end

#==============================================================================
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# 變更摘要：
#==============================================================================

class Game_Battler
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias morala_stvw_adstat_5fc1 add_state
  def add_state (state_id, *args)
    $game_system.masv_states_afflicted.push (state_id) unless $game_system.masv_states_afflicted.include? (state_id)
    morala_stvw_adstat_5fc1 (state_id, *args) # 執行原方法
  end
end

#==============================================================================
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#==============================================================================

class Window_StateView < Window_Base
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def create_contents
    self.contents.dispose
    hght = 0
    $data_states.each { |state| hght += 24 if !state.nil? && !state.desc_exclude?  && (MASV_SHOW_ALL_STATES || $game_system.masv_states_afflicted.include? (state.id)) }
    hght = 32 if hght == 0
    self.contents = Bitmap.new(width - 32, hght)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def refresh
    contents.clear
    y = 0
    for state in $data_states
      next if state.nil? || state.desc_exclude? || (!MASV_SHOW_ALL_STATES && !$game_system.masv_states_afflicted.include? (state.id))
      draw_item (y, state)
      y += 24
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def draw_item (y, state)
    # 繪製圖示
    draw_icon(state.icon_index, 0, y)
    # 繪製名稱
    self.contents.font.color = system_color
    self.contents.draw_text (28, y, 108, 24, state.name)
    self.contents.font.color = normal_color
    self.contents.draw_text (142, y, contents.width - 142, 24, state.description)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def update
    super
    if Input.press? (Input::DOWN) && ((self.oy + self.height - 32) < contents.height)
      self.oy += 3
    elsif Input.press? (Input::UP) && self.oy != 0
      self.oy -= 3
    end
  end
end

#==============================================================================
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#==============================================================================

class Window_StateLabel < Window_Base
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def initialize (*args)
    super (*args)
    color = text_color (MASV_LABEL_COLOR)
    contents.fill_rect (0, MASV_LABEL_FONTSIZE - 4, contents.width, 2, color)
    contents.font = Font.new (MASV_LABEL_FONTNAME, MASV_LABEL_FONTSIZE)
    contents.font.color = color
    contents.draw_text (12, 0, contents.width - 24, MASV_LABEL_FONTSIZE, MASV_LABEL, MASV_LABEL_ALIGN)
  end
end

#==============================================================================
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#==============================================================================

class Scene_StateView < Scene_Base
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def initialize (from_class = $scene.class, from_args = [])
    @from_class = from_class
    @from_args = from_args.empty? && from_class.is_a? (Scene_Menu) ? [MASV_MENU_INDEX] : from_args
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def start
    super
    create_menu_background
    if MASV_SHOW_LABEL
      @dummy_window = Window_StateLabel.new (0, 0, Graphics.width, Graphics.height)
      svh = 32 + (((@dummy_window.contents.height - MASV_LABEL_FONTSIZE) / 24)*24)
      @states_window = Window_StateView.new (0, Graphics.height - svh, Graphics.width, svh)
      @states_window.opacity = 0
    else
      @states_window = Window_StateView.new (0, 0, Graphics.width, Graphics.height)
    end
    @states_window.refresh
    @states_window.active = true
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def terminate
    super
    @dummy_window.dispose if MASV_SHOW_LABEL
    @states_window.dispose
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def update
    super
    if @states_window.active
      if Input.trigger? (Input::C) || Input.trigger? (Input::B)
        Sound.play_cancel
        return_scene
      end
      @states_window.update
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def return_scene
    $scene = @from_class.new (*@from_args)
  end
end

#==============================================================================
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# 變更摘要：
#==============================================================================

class Scene_Status
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias mal_sv_update_9ic3 update
  def update (*args, &block)
    mal_sv_update_9ic3 (*args, &block) # 執行原方法
    if MASV_STATUS_ACCESS && Input.trigger? (MASV_STATUS_KEY)
      $scene = Scene_StateView.new (Scene_Status, [@actor_index])
    end
  end
end

if MASV_MENU_ACCESS
  if $imported && $imported["MainMenuMelody"]
    YEM::MENU::MENU_COMMANDS.insert (MASV_MENU_INDEX, :stateview)
    YEM::MENU::MENU_ICONS[:stateview] = MASV_MENU_ICON
    YEM::MENU::IMPORTED_COMMANDS[:stateview] = [nil, nil, false, MASV_MENU_ICON, MASV_LABEL, "Scene_StateView"]
  elsif Game_System.method_defined? (:fscms_command_list) 
    ModernAlgebra::FSCMS_CUSTOM_COMMANDS[:stateview] = [MASV_LABEL, MASV_MENU_ICON, -1, false, Scene_StateView, "Scene_Menu, [#{MASV_MENU_INDEX}]"]
    ModernAlgebra::FSCMS_COMMANDLIST.insert (MASV_MENU_INDEX, :stateview)
  elsif Game_System.method_defined? (:tpcms_command_list)
    Phantasia_CMS::CUSTOM_COMMANDS[:stateview] = [MASV_LABEL, MASV_MENU_ICON, -1, false, Scene_StateView, "Scene_Menu, [#{MASV_MENU_INDEX}]"]
    Phantasia_CMS::COMMANDLIST.insert (MASV_MENU_INDEX, :stateview)
  else
    #========================================================================
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # 變更摘要：
    #========================================================================
    unless Window_Command.method_defined? (:ma_disabled_commands) 
      class Window_Command
        #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        attr_reader :ma_disabled_commands
        #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        alias ma_stateview_initz_8yg1 initialize
        def initialize (*args)
          @ma_disabled_commands = []
          ma_stateview_initz_8yg1 (*args) # 執行原方法
        end
        #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        alias modalg_sttvw_itmdraw_7in3 draw_item
        def draw_item (index, enabled = true, *args)
          # 執行原方法
          modalg_sttvw_itmdraw_7in3 (index, enabled, *args)
          enabled ? @ma_disabled_commands.delete (index) : @ma_disabled_commands.push (index)
        end
      end
    end
    #==========================================================================
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # 變更摘要：
    #==========================================================================
    
    class Scene_Menu
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      alias malba_stview_iniz_5rx2 initialize
      def initialize (menu_index = 0, *args)
        malba_stview_iniz_5rx2 (menu_index, *args)
        $scene.is_a? (Scene_StateView) ? @menu_index = MASV_MENU_INDEX : (@menu_index += 1 if @menu_index >= MASV_MENU_INDEX)
      end
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      alias modabra_sv_cmmndwin_create_3tb8 create_command_window
      def create_command_window (*args)
        modabra_sv_cmmndwin_create_3tb8 (*args) # 執行原方法
        c = @command_window.commands
        c.insert (MASV_MENU_INDEX, MASV_LABEL)
        width = @command_window.width
        disabled = @command_window.ma_disabled_commands
        @command_window.dispose
        @command_window = @command_window.class.new (width, c)
        @command_window.index = @menu_index
        disabled.each { |i| 
          i += 1 if i >= MASV_MENU_INDEX
          @command_window.draw_item (i, false)
        }
      end
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      alias modgra_sttview_updcomnd_3rg8 update_command_selection
      def update_command_selection (*args)
        if @command_window.index == MASV_MENU_INDEX && Input.trigger? (Input::C)
          Sound.play_decision
          $scene = Scene_StateView.new (Scene_Menu, [@command_window.index])
          return
        end
        change = @command_window.index > MASV_MENU_INDEX
        @command_window.index -= 1 if change
        modgra_sttview_updcomnd_3rg8 (*args) # 執行原方法
        @command_window.index += 1 if change
      end
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      alias mdrnab_viewstate_actupd_5fc9 update_actor_selection
      def update_actor_selection (*args)
        change = @command_window.index > MASV_MENU_INDEX
        @command_window.index -= 1 if change
        mdrnab_viewstate_actupd_5fc9 (*args) # 執行原方法
        @command_window.index += 1 if change
      end
    end
  end
end