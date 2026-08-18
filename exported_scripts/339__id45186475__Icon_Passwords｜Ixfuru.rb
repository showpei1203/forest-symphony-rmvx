#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Icon Passwords｜Ixfuru
# 【來源／Credits】Ixfuru 的 RGSS2 實作，概念來自 RPGMakerVX.net 使用者 new 與 efeberk 的 RGSS3 Icon Passwords；依原作者要求使用時三者都應列入 Credits。
# 【用途】以 IconSet 圖示序列作為密碼。Scene_IconPassword 會依 PASSWORDS 設定建立多個 Icon 選擇視窗；輸入正確後可開 Switch、轉移地圖、開 Self Switch。
# 【事件 Script Call】$scene = Scene_IconPassword.new(password_id)。例如 $scene = Scene_IconPassword.new(0) 呼叫 PASSWORDS[0]。
# 【PASSWORDS 格式】password_id => {:all_icons=>[可選 Icon ID], :correct_icons=>[正確順序], :switch_id=>SwitchID, :header_string=>'提示', :transfer=>[map_id,x,y,direction], :self_switch=>[map_id,event_id,'A'~'D']}。header_string 可省略，會使用 DEFAULT_HEADER_STRING。
# 【限制】correct_icons 內每個 ID 必須也存在 all_icons；可以重複。原作者建議可選 Icon 約 8~10 個、密碼不要超過約 10 位，否則多個視窗可能超出畫面。
# 【成功效果】正確密碼會把 switch_id 指定 Switch 打開；transfer 非空時可立即轉移，direction 使用 VX 方向碼 2下／4左／6右／8上；self_switch 非空時開指定 Event Self Switch。
# 【目前資料】PASSWORDS[0]：可選 96~103、正解 [101,96,100]、Switch 25、Self Switch [1,4,'A']；PASSWORDS[1]：正解 [96,96,96]、Switch 25。第一組 header_string='Unlock the Chest' 是實際遊戲字串，目前仍維持原值。
# 【SE／素材】Graphics/System/Iconset；NO_MATCH_SE=['Buzzer2',80,100]、MATCH_SE=['Chime2',80,100]、WINDOW_CONTROL_SE=['Switch1',80,100]。
# 【設定警告】PASSWORDS Hash 不可刪；新增密碼只增加新 ID。switch_id 在 Scene 初始化／失敗流程的實際重設行為請以 Runtime 為準，改成共用 Switch 前務必實機測試。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、實際資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址保留；Phase 19 Archive 另保存翻譯前 byte-exact 原稿。
# 4. 本輪只整理文件／註解；Runtime code 與載入順序不得因翻譯而改變。
#==============================================================================
################################################################################
#                                  By: Ixfuru
################################################################################
#===============================================================================
#
#                 $scene = Scene_IconPassword.new(password_id)
#
#
#
#        password_id => {:all_icons => [icon_ids],
#
#
#
#                            [6, 7, 7, 7 , 6]
#
# 
#
#
#
#
#
#
#
################################################################################
#
#
#             $scene = Scene_IconPassword.new(password_id)
#
################################################################################
#                         CREDITS
#
################################################################################
module Ixfuru
  module IconPasswords
    
    PASSWORDS = { # 詳見頁首繁中維護說明
    
          
    0 => {:all_icons => [96, 97, 98, 99, 100, 101, 102, 103],
          :correct_icons => [101, 96, 100], # 詳見頁首繁中維護說明
          :switch_id => 25,
          :header_string => "Unlock the Chest",
          :transfer => [],
          :self_switch => [1, 4, "A"]},
    1 => {:all_icons => [96, 97, 98, 99, 100, 101, 102, 103],
          :correct_icons => [96, 96, 96], # 詳見頁首繁中維護說明
          :switch_id => 25,
          :header_string => "解鎖",
          :transfer => [],
          :self_switch => [1, 4, ""]},
          
          
    }
    
    NO_MATCH_SE = ["Buzzer2", 80, 100] # 密碼錯誤時播放的 SE
    MATCH_SE = ["Chime2", 80, 100] # 密碼正確時播放的 SE
    WINDOW_CONTROL_SE = ["Switch1", 80, 100] # 切換 Icon 視窗時播放的 SE
    DEFAULT_HEADER_STRING = "輸入正確的圖案" # 未指定 header_string 時顯示的預設文字
    
    
  end
end

#===============================================================================
#===============================================================================
class IconPassword
  
  attr_accessor :icons
  attr_accessor :password_id
  attr_reader :all_icons
  attr_reader :code
  attr_accessor :header_string
  attr_reader :transfer
  
  def initialize(password_id)
    @password_id = password_id
    @all_icons = Ixfuru::IconPasswords::PASSWORDS[@password_id][:all_icons]
    @code = Ixfuru::IconPasswords::PASSWORDS[@password_id][:correct_icons]
    if Ixfuru::IconPasswords::PASSWORDS[@password_id].has_key?(:header_string)
      @header_string = Ixfuru::IconPasswords::PASSWORDS[@password_id][:header_string]
    else
      @header_string = Ixfuru::IconPasswords::DEFAULT_HEADER_STRING
    end
    @transfer = Ixfuru::IconPasswords::PASSWORDS[@password_id][:transfer]
    @icons = []
  end
  
  #-----------------------------------------------------------------------------
  # 取得全部 Icon
  #-----------------------------------------------------------------------------
  def get_all_icons
    return @all_icons
  end
  
  #-----------------------------------------------------------------------------
  # 密碼是否吻合
  #-----------------------------------------------------------------------------
  def match?
    return true if @icons == @code
    return false
  end
  
end

#===============================================================================
#===============================================================================
class Window_PasswordHeader < Window_Base
  
  attr_accessor :string
  
  def initialize(string)
    super(100, 108, 344, 56)
    @string = string
    refresh
  end
  
  def refresh
    self.contents.clear
    self.contents.font.color = system_color
    self.contents.draw_text(0, 0, self.width - 32, WLH, @string, 1)
  end
  
end

#===============================================================================
#===============================================================================
class Window_PasswordInstructions < Window_Base
  
  def initialize
    super(100, 220, 344, 56)
    @instructions = "< > : 左右移動, SPC : 確定, X : 離開"
    refresh
  end
  
  def refresh
    self.contents.clear
    self.contents.font.color = system_color
    self.contents.draw_text(0, 0, self.width - 32, WLH, @instructions, 1)
  end
  
end


#===============================================================================
#===============================================================================
class Window_Icon < Window_Selectable
  
  attr_accessor :icons
  
  def initialize(password_id, x)
    super(x, 164, 56, 56)
    @icons = Ixfuru::IconPasswords::PASSWORDS[password_id][:all_icons]
    @item_max = @icons.size
    refresh
    self.active = false
    self.index = 0
  end
  
  def icon_id
    return @icons[self.index]
  end
  
  def refresh
    create_contents
    for i in 0...@item_max
      draw_each(i)
    end
  end
  
  def draw_each(index)
    rect = item_rect(index)
    draw_icon(@icons[index], rect.x, rect.y, activated?)
  end
  
  def activated?
    self.active
  end
  
end

#===============================================================================
#===============================================================================
class Scene_IconPassword < Scene_Base
  
  def initialize(password_id)
    $game_switches[Ixfuru::IconPasswords::PASSWORDS[password_id][:switch_id]] = false
    @password_id = password_id
    @comparitor = IconPassword.new(@password_id)
    @win_index = 0
    @win_max = @comparitor.code.size
    @windows = []
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def start
    super
    create_menu_background
    @win_header = Window_PasswordHeader.new(@comparitor.header_string)
    @win_instructions = Window_PasswordInstructions.new
    start_x = window_start_x
    for i in 0...@win_max
      window = Window_Icon.new(@password_id, start_x + (i * 56))
      @windows.push(window)
    end
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def window_start_x
    x = 272 - (@win_max * 28)
    return x
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def return_scene
    $scene = Scene_Map.new
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def update_code
    icons = []
    for window in @windows
      icons.push(window.icon_id)
    end
    @comparitor.icons = icons
  end
  
  #-----------------------------------------------------------------------------
  # 更新
  #-----------------------------------------------------------------------------
  def update
    super
    update_code
    deactivate_windows
    update_comparitor
    update_window
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def deactivate_windows
    for window in @windows
      window.active = false
    end
    @windows[@win_index].active = true
    for window in @windows
      window.refresh
    end
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def play_code_match
    se = Ixfuru::IconPasswords::MATCH_SE
    RPG::SE.new(se[0], se[1], se[2]).play
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def play_no_match
    se = Ixfuru::IconPasswords::NO_MATCH_SE
    RPG::SE.new(se[0], se[1], se[2]).play
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def play_new_window
    se = Ixfuru::IconPasswords::WINDOW_CONTROL_SE
    RPG::SE.new(se[0], se[1], se[2]).play
  end
  
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def update_comparitor
    if Input.trigger?(Input::C)
      if @comparitor.match?
        play_code_match
        unless $game_switches[Ixfuru::IconPasswords::PASSWORDS[@password_id][:switch_id]] == 0
          $game_switches[Ixfuru::IconPasswords::PASSWORDS[@password_id][:switch_id]] = true
        end
        ss_base = Ixfuru::IconPasswords::PASSWORDS[@password_id][:self_switch]
        unless ss_base.empty? 
          key = [ss_base[0], ss_base[1], ss_base[2]]
          $game_self_switches[key] = true
          $game_map.refresh
        end
        unless @comparitor.transfer.empty?
          m = @comparitor.transfer[0]
          x = @comparitor.transfer[1]
          y = @comparitor.transfer[2]
          dir = @comparitor.transfer[3]
          $game_player.reserve_transfer(m, x, y, dir)
        end
        return_scene
      else
        play_no_match
      end
    elsif Input.trigger?(Input::B)
      Sound.play_cancel
      return_scene
    end
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def update_window
    @windows[@win_index].update
    if Input.trigger?(Input::LEFT)
      play_new_window
      if @win_index == 0
        @win_index = @win_max - 1
      else
        @win_index -= 1
      end
    elsif Input.trigger?(Input::RIGHT)
      play_new_window
      if @win_index == @win_max - 1
        @win_index = 0
      else
        @win_index += 1
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def terminate
    super
    dispose_menu_background
    @win_header.dispose
    @win_instructions.dispose
    for window in @windows
      window.dispose
    end
  end
  
end