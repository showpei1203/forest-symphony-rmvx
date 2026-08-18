#==============================================================================
# 【Forest Symphony｜繁體中文完整說明】
#------------------------------------------------------------------------------
# 腳本：Mastermind_Core v1.0｜Mini Game
# 【來源】Zylos (rmrk.net)，Mastermind (VX) v1.0，2011-03-21。
# 【用途】經典 Mastermind 猜色碼小遊戲：每回合玩家選 4 個顏色（共 6 色），黑釘代表顏色＋位置正確，白釘代表顏色正確但位置錯；猜中或 8 回合用完即結束。
# 【正式事件入口】`call_mastermind`。Game_Interpreter 會把 `$game_temp.next_scene="mastermind"`，Scene_Map 在角色停止移動後切換 Scene_Mastermind。專案 Data 已有此入口，所以不可退休。
# 【設定】Win_Lose=true 顯示勝敗比；Side=true；Black_Background=false；Game_Music=false；Game_BGM=`Airship.MID`；Win=`Applause.OGG`、Loss=`Collapse2.OGG`，可各用 SE/ME。
# 【保存】Game_System#wins / losses 記錄累積勝敗，屬 Save Data；改欄位時需測舊存檔。
# 【素材】Graphics/Pictures/mm_board、mm_answer、mm_side、mm_color1..、mm_black、mm_white；可選 Audio/BGM/Airship.MID、Audio/SE/Applause.OGG、Audio/SE/Collapse2.OGG（依設定與 Type）。
# 【Load Order】alias Game_System#initialize 與 Scene_Map#update_scene_change；保持現行位置。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址保留；Phase 21 Archive 另保存修改前 byte-exact 原稿。
# 4. 本輪除 Friendly Monsters GoldFix 回寫外，只整理文件／架構標記；其餘 Runtime code 與載入順序不得因翻譯改變。
#==============================================================================
#==============================================================================
#  Mastermind (VX)
#  版本：1.0
#  作者：Zylos (rmrk.net)
#  日期：2011-03-21
#------------------------------------------------------------------------------
#
#
#------------------------------------------------------------------------------
#   
#
#       http://rmrk.net/index.php/topic,42143.0.html
#
#
#
#==============================================================================

module Mastermind_Options
  #============================================================================
  # 可調整區域：
  #============================================================================
  
  Win_Lose = true # 詳見頁首繁中說明
  Side = true # 詳見頁首繁中說明
  Black_Background = false # 詳見頁首繁中說明
  Game_Music = false # 詳見頁首繁中說明
  Game_BGM = "Airship.MID" # 詳見頁首繁中說明
  Win_Sound = "Applause.OGG" # 詳見頁首繁中說明
  Win_Sound_Type = "SE" # 詳見頁首繁中說明
  Loss_Sound = "Collapse2.OGG" # 詳見頁首繁中說明
  Loss_Sound_Type = "SE" # 詳見頁首繁中說明

  #============================================================================
  # 可調整區域結束
  #============================================================================
end

#==============================================================================
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#==============================================================================

class Game_System
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  attr_accessor :wins # 詳見頁首繁中說明
  attr_accessor :losses # 詳見頁首繁中說明
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias_method :winlossratio, :initialize
  def initialize
    winlossratio
    @wins = 0
    @losses = 0
  end
end

#==============================================================================
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def call_mastermind
    $game_temp.next_scene = "mastermind"
  end
end

#==============================================================================
#------------------------------------------------------------------------------
#==============================================================================

class Scene_Map
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias_method :scene_change, :update_scene_change
  def update_scene_change
    return if $game_player.moving?    
    if $game_temp.next_scene == "mastermind"
      call_mastermind
    else
      scene_change
    end
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------  
  def call_mastermind
    $game_temp.next_scene = nil
    $scene = Scene_Mastermind.new
  end
end

#==============================================================================
#------------------------------------------------------------------------------
#==============================================================================

class Window_MastermindRatio < Window_Base
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y, 135, 80)
    refresh
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.font.color = system_color
    self.contents.draw_text(4, 0, 90, WLH, "Wins:")
    self.contents.font.color = normal_color
    self.contents.draw_text(4, 0, 90, WLH, $game_system.wins, 2)
    self.contents.font.color = system_color
    self.contents.draw_text(4, 0, 90, WLH*2.6, "Losses:")
    self.contents.font.color = normal_color
    self.contents.draw_text(4, 0, 90, WLH*2.6, $game_system.losses, 2)
  end
end

#==============================================================================
#------------------------------------------------------------------------------
#==============================================================================

class Scene_Mastermind < Scene_Base
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def start
    super
    if Mastermind_Options::Game_Music == true
      @last_bgm = RPG::BGM::last
      @last_bgs = RPG::BGS::last
      RPG::BGS.stop
      temp_sound = "Audio/BGM/" + Mastermind_Options::Game_BGM
      Audio.bgm_play(temp_sound, 100, 100)
    end
    @play_vocab = "Play game?"
    @cancel_vocab = "Quit"
    create_menu_background if Mastermind_Options::Black_Background == false
    create_command_window
    create_command_window_2
    if Mastermind_Options::Win_Lose == true
      @winloss = Window_MastermindRatio.new(5.5, 10)
    end
    @board_sprite = Sprite.new(Viewport.new(0, 0, 544, 416))
    @board_sprite.bitmap = Cache.picture("mm_board")
    @board_sprite.x = 0
    @board_sprite.y = 0
    @board_sprite.z = 1
    @answer_sprite = Sprite.new
    @answer_sprite.bitmap = Cache.picture("mm_answer")
    @answer_sprite.x = 212
    @answer_sprite.y = -25
    @answer_sprite.z = 10
    if Mastermind_Options::Side == true
      @side_sprite = Sprite.new
      @side_sprite.bitmap = Cache.picture("mm_side")
      @side_sprite.x = 399 + (146 - @side_sprite.width) / 2
      @side_sprite.y = (416 - @side_sprite.height) / 2
      @side_sprite.z = 1
    end
    @color_sprite = []
    @peg_sprite = []
    @guess = []
    @guess_used = []
    @answer = []
    @answer_used = []
    @color_index = 0
    @peg_index = 0
    @game_mode = "start"
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def post_start
    super
    open_command_window
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def wait(duration)
    for i in 0...duration
      Graphics.update
    end
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def pre_terminate
    super
    close_command_window
    close_command_window_2
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_menu_background if Mastermind_Options::Black_Background == false
    dispose_command_window
    @board_sprite.dispose
    @answer_sprite.dispose
    @side_sprite.dispose if Mastermind_Options::Side == true
    @winloss.dispose if Mastermind_Options::Win_Lose == true
    if @color_index != 0
      for i in 0...@color_index
        @color_sprite[i].dispose
      end
      for i in 0...@peg_index
        @peg_sprite[i].dispose
      end
    end
    if Mastermind_Options::Game_Music == true
      @last_bgm.play
      @last_bgs.play
    end
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update
    super
    update_menu_background if Mastermind_Options::Black_Background == false
    @command_window.update
    @command_window_2.update
    @winloss.update if Mastermind_Options::Win_Lose == true
    if @game_mode == "start"
      if Input.trigger?(Input::C)
        case @command_window.index
        when 0
          Sound.play_decision
          close_command_window
          cover_answer
        when 1
          Sound.play_cancel
          $scene= Scene_Map.new
        end
      end
    elsif @game_mode == "color"
      if Input.trigger?(Input::B)
        if @guess_index == 0
          Sound.play_cancel
          close_command_window_2
          @play_vocab = "Continue"
          @cancel_vocab = "Quit"
          @command_window.index = 0
          @command_window.dispose
          create_command_window
          open_command_window 
          open_command_window
          @game_mode = "quit"
        else
          case @guess_index
          when 1
            @guess[0] = -1
          when 2
            @guess[1] = -1
          when 3
            @guess[2] = -1
          end
          @guess_index -= 1
          @color_index -= 1
          Sound.play_cancel
          @color_sprite[@color_index].dispose
        end
      end
      if Input.trigger?(Input::C)
        if @guess_index != 4
          Sound.play_decision
          @go = @command_window_2.index
          @guess[@guess_index] = @go
          @color_sprite[@color_index] = Sprite.new
          @color_sprite[@color_index].bitmap=Cache.picture("mm_color"+@go.to_s)
          @color_sprite[@color_index].x = 228 + (@guess_index * 35)
          @color_sprite[@color_index].y = 360 - (@round_index * 40)
          @color_sprite[@color_index].z = 2
          @guess_index += 1
          @color_index += 1
          if @guess_index == 4
            @game_mode = "peg"
            close_command_window_2
            @command_window.index = 0
            @command_window_2.index = 0
            wait(15)
            check_colors
          end
        end
      end
    elsif @game_mode == "quit"
      if Input.trigger?(Input::C)
        case @command_window.index
        when 0
          Sound.play_decision
          close_command_window
          open_command_window_2
          @game_mode = "color"
        when 1
          Sound.play_cancel
          $scene= Scene_Map.new
        end  
      end
    elsif @game_mode == "win" or @game_mode == "lose"
      if @command_window.openness == 255
        if Input.trigger?(Input::C)
        case @command_window.index
        when 0
          Sound.play_decision
          opac = 250
          close_command_window
          wait(8)
          begin
            opac -= 10
            for i in 0...@color_index
              @color_sprite[i].opacity = opac
            end
            for i in 0...@peg_index
              @peg_sprite[i].opacity = opac
            end
            wait(2)
          end until opac == 0
          for i in 0...@color_index
            @color_sprite[i].dispose
          end
          for i in 0...@peg_index
            @peg_sprite[i].dispose
          end
          wait(10)
          cover_answer
        when 1
          Sound.play_cancel
          $scene= Scene_Map.new
        end
      end
      end
    end  
  end  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_menu_background
    super
    @menuback_sprite.tone.set(0, 0, 0, 128)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def cover_answer
    @round_index = 0
    @color_index = 0
    @peg_index = 0
    @guess[0] = -1
    @guess[1] = -1
    @guess[2] = -1
    @guess[3] = -1
    @guess_used[0] = false
    @guess_used[1] = false
    @guess_used[2] = false
    @guess_used[3] = false
    @guess_index = 0
    @answer[0] = -1
    @answer[1] = -1
    @answer[2] = -1
    @answer[3] = -1
    @answer_used[0] = false
    @answer_used[1] = false
    @answer_used[2] = false
    @answer_used[3] = false
    @peg_hole = 0
    @j = 0
    @k = 0    
    @distance = 19 - (@answer_sprite.y)
    @iindex = 0
    RPG::ME.stop
    RPG::SE.stop
    for i in 0...4
      Sound.play_cursor
      temp_answer = rand(5)
      @color_sprite[i] = Sprite.new
      @color_sprite[i].bitmap=Cache.picture("mm_color"+temp_answer.to_s)
      @color_sprite[i].x = 228 + (i * 35)
      @color_sprite[i].y = 29
      @color_sprite[i].z = 2
      @color_index += 1
      wait(10)
    end
    while @distance > 0
      @answer_sprite.y += 1
      temp_answer = rand(5)
      @color_sprite[@iindex].bitmap=Cache.picture("mm_color"+temp_answer.to_s)
      @iindex += 1
      if @iindex == 4
        @iindex = 0
      end
      @distance = 19 - (@answer_sprite.y)
      Sound.play_cursor
      wait(2)
    end
    for i in 0...4
      @answer[i] = rand(5)
      @color_sprite[i].bitmap=Cache.picture("mm_color"+@answer[i].to_s)
      @color_sprite[i].z = 2
    end
    open_command_window_2
    @game_mode = "color"
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def uncover_answer
    begin
      @answer_sprite.y -= 1
      wait(2)
    end until @answer_sprite.y == -25
    @play_vocab = "Rematch"
    @cancel_vocab = "Quit"
    @command_window.dispose
    create_command_window
    open_command_window  
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def check_colors
    for i in 0...4
      if @guess[i] == @answer[i]
        @guess_used[i] = true
        @answer_used[i] = true
        @peg_sprite[@peg_index] = Sprite.new
        @peg_sprite[@peg_index].bitmap = Cache.picture("mm_black")
        case @peg_hole
        when 0
          @peg_sprite[@peg_index].x = 184
          @peg_sprite[@peg_index].y = 358 - (@round_index * 40)
        when 1
          @peg_sprite[@peg_index].x = 198
          @peg_sprite[@peg_index].y = 358 - (@round_index * 40)
        when 2
          @peg_sprite[@peg_index].x = 184
          @peg_sprite[@peg_index].y = 372 - (@round_index * 40)
        when 3
          @peg_sprite[@peg_index].x = 198
          @peg_sprite[@peg_index].y = 372 - (@round_index * 40)
        end
        @peg_sprite[@peg_index].z = 2
        @peg_index += 1
        @peg_hole += 1
        if @peg_hole == 4
          @game_mode = "win"
        end
      end
    end
    while @j <= 3
      if @j != @k
        if @guess[@j] == @answer[@k]
          if @guess_used[@j] == false
            if @answer_used[@k] == false
              @guess_used[@j] = true
              @answer_used[@k] = true
              @peg_sprite[@peg_index] = Sprite.new
              @peg_sprite[@peg_index].bitmap = Cache.picture("mm_white")
              case @peg_hole
              when 0
                @peg_sprite[@peg_index].x = 184
                @peg_sprite[@peg_index].y = 358 - (@round_index * 40)
              when 1
                @peg_sprite[@peg_index].x = 198
                @peg_sprite[@peg_index].y = 358 - (@round_index * 40)
              when 2
                @peg_sprite[@peg_index].x = 184
                @peg_sprite[@peg_index].y = 372 - (@round_index * 40)
              when 3
                @peg_sprite[@peg_index].x = 198
                @peg_sprite[@peg_index].y = 372 - (@round_index * 40)
              end
              @peg_sprite[@peg_index].z = 2
              @peg_index += 1
              @peg_hole += 1
            end
          end
        end
      end
      @k += 1
      if @k == 4
        @j += 1
        @k = 0
      end
    end
    @guess[0] = -1
    @guess[1] = -1
    @guess[2] = -1
    @guess[3] = -1
    @guess_used[0] = false
    @guess_used[1] = false
    @guess_used[2] = false
    @guess_used[3] = false
    @guess_index = 0
    @answer_used[0] = false
    @answer_used[1] = false
    @answer_used[2] = false
    @answer_used[3] = false
    @peg_hole = 0
    @j = 0
    @k = 0
    wait(15)
    if @round_index == 7 and @game_mode != "win"
      @game_mode = "lose"
      if Mastermind_Options::Loss_Sound_Type == "SE"
        temp_sound = "Audio/SE/" + Mastermind_Options::Loss_Sound
        Audio.se_play(temp_sound, 100, 100)
      elsif Mastermind_Options::Loss_Sound_Type == "ME"
        temp_sound = "Audio/ME/" + Mastermind_Options::Loss_Sound        
        Audio.me_play(temp_sound, 100, 100)
      end
      $game_system.losses += 1
      @winloss.refresh if Mastermind_Options::Win_Lose == true
      uncover_answer
    elsif @game_mode == "win"
      if Mastermind_Options::Win_Sound_Type == "SE"
        temp_sound = "Audio/SE/" + Mastermind_Options::Win_Sound
        Audio.se_play(temp_sound, 100, 100)
      elsif Mastermind_Options::Win_Sound_Type == "ME"
        temp_sound = "Audio/ME/" + Mastermind_Options::Win_Sound        
        Audio.me_play(temp_sound, 100, 100)
      end
      $game_system.wins += 1
      @winloss.refresh if Mastermind_Options::Win_Lose == true
      uncover_answer
    else
      @round_index += 1
      open_command_window_2
      @game_mode = "color"
    end
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def create_command_window
    s1 = @play_vocab
    s2 = @cancel_vocab
    @command_window = Window_Command.new(142, [s1, s2])
    @command_window.x = (544 - @command_window.width) / 2
    @command_window.y = (416 - @command_window.height) / 2
    @command_window.openness = 0
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def dispose_command_window
    @command_window.dispose
    @command_window_2.dispose
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def open_command_window
    @command_window.open
    begin
      @command_window.update
      Graphics.update
    end until @command_window.openness == 255
    @command_window.active = true
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def close_command_window
    @command_window.close
    begin
      @command_window.update
      Graphics.update
    end until @command_window.openness == 0
    @command_window.active = false
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def create_command_window_2
    s1 = "Red"
    s2 = "Orange"
    s3 = "Yellow"
    s4 = "Green"
    s5 = "Blue"
    s6 = "Purple"
    @command_window_2 = Window_Command.new(105, [s1, s2, s3, s4, s5, s6])
    @command_window_2.x = (146 - @command_window_2.width) / 2
    if Mastermind_Options::Win_Lose == false
      @command_window_2.y = (416 - @command_window_2.height) / 2
    else
      @command_window_2.y = 210
    end
    @command_window_2.openness = 0
    @command_window_2.active = false
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def open_command_window_2
    @command_window_2.open
    begin
      @command_window_2.update
      Graphics.update
    end until @command_window_2.openness == 255
    @command_window_2.active = true
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def close_command_window_2
    @command_window_2.close
    begin
      @command_window_2.update
      Graphics.update
    end until @command_window_2.openness == 0
    @command_window_2.active = false
  end
end