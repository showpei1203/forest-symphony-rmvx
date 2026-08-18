#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：YEM Restored Functions
# 【用途】保留的 Runtime 元件「YEM Restored Functions」。
# 【主要機制】主要定義／擴充 Game_Screen、Game_Picture、Game_Map、Game_Character；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Game_Screen、Game_Picture、Game_Map、Game_Character、Game_Interpreter、Sprite_Picture、Spriteset_Map
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：PICTURE_MIRROR_SWITCH、PICTURE_NUMBER_VARIABLE、MAXIMUM_PICTURES、STOP_ALL_SWITCH。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 15 個 alias／方法包裝，載入順序具有語意；登記 $imported：RestoredFunctions。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【英文說明中文化】本頁頂部已用繁體中文整理／翻譯原說明中與維護直接相關的用途、機制、設定、順序、呼叫與範例；下方原文保留作作者授權、完整細節與歷史查核依據。
# 【來源／授權】若下方有原作者署名、Credits、License 或網址，必須保留；本中文維護說明不取代原授權。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 範例只記錄原文件、既有事件或程式碼能證實的入口；沒有入口就明寫自動執行。
# 3. 原作者署名、授權與原始說明保留在下方；中文化不代表取得原作權。
# 4. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
#==============================================================================
#===============================================================================
# 
# Yanfly Engine Melody - Restored Functions
# Last Date Updated: 2010.05.12
# Level: Easy, Normal
# 
# This script mostly encompasses any retired and removed functions from former
# RPG Makers and weren't reintroduced back into RPG Maker VX when released. In
# this script will be a number of ways to let those functions work once again.
# Any case, this script is just a small compilation of smaller scripts I've
# before made in the past and will most likely just add more to these when I
# come up with anything new.
# 
#===============================================================================
# Updates
# -----------------------------------------------------------------------------
# o 2010.05.12 - Converted to Melody format.
# o 2010.02.05 - Restored Function: Diagonal Map Scrolling.
# o 2010.01.12 - Started Script and Finished.
#===============================================================================
# Instructions
# -----------------------------------------------------------------------------
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials but above ▼ Main. Remember to save.
# 
# 1. Scroll down below and bind the proper switches and variables to each given
#    constant. This is extremely important to get this script working.
# 2. If you're loading a saved game, just enter a new map and re-enter to get
#    pictures working. This only happens after installing the script for the
#    very first time.
# 
# -----------------------------------------------------------------------------
# Diagonal Map Scrolling
# -----------------------------------------------------------------------------
#   scroll_lower_left(x)
#   scroll_lower_right(x)
#   scroll_upper_left(x)
#   scroll_upper_right(x)
# This will scroll the map screen by x tiles in those diagonal directions. If
# used as (x, y), then y will be the move speed at which the map will scroll.
# 4 is the default move speed, 1 is the slowest, 7 is the fastest.
#===============================================================================

$imported = {} if $imported == nil
$imported["RestoredFunctions"] = true

module YEM
  module FUNCTION
    
    # This switch adjusts whether or not the next picture being modified will
    # be mirrored. If the switch is on, the picture is mirrored. If it is off,
    # the picture will be displayed normally.
    PICTURE_MIRROR_SWITCH = 4
    
    # This variable adjusts which picture number is being modified. This will
    # allow you to go over 20 pictures and all of them will update accordingly.
    # Whatever number the variable is, the next picture modified will use that
    # number instead unless the variable is under 20 in value.
    PICTURE_NUMBER_VARIABLE = 1
    MAXIMUM_PICTURES = 50
    
    # This switch, when on, will stop all events on the map from moving by
    # themselves unless moved through an evented move route.
    STOP_ALL_SWITCH = 11
    
  end # FUNCTION
end # YEM

#===============================================================================
# Editting anything past this point may potentially result in causing computer
# damage, incontinence, explosion of user's head, coma, death, and/or halitosis.
# Therefore, edit at your own risk.
#===============================================================================

#===============================================================================
# Game_Screen
#===============================================================================

class Game_Screen
  
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :pictures
  
  #--------------------------------------------------------------------------
  # alias method: clear
  #--------------------------------------------------------------------------
  alias clear_game_screen_rf clear unless $@
  def clear
    clear_game_screen_rf
    for i in 21..(YEM::FUNCTION::MAXIMUM_PICTURES)
      @pictures.push(Game_Picture.new(i))
    end
  end
  
end # Game_Screen

#===============================================================================
# Game_Picture
#===============================================================================

class Game_Picture
  
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :mirror

  #--------------------------------------------------------------------------
  # alias method: initialize
  #--------------------------------------------------------------------------
  alias initialize_game_picture_rf initialize unless $@
  def initialize(number)
    initialize_game_picture_rf(number)
    @mirror = false
  end
  
  #--------------------------------------------------------------------------
  # alias method: show
  #--------------------------------------------------------------------------
  alias show_game_picture_rf show unless $@
  def show(*args)
    show_game_picture_rf(*args)
    @mirror = $game_switches[YEM::FUNCTION::PICTURE_MIRROR_SWITCH]
  end
  
  #--------------------------------------------------------------------------
  # alias method: move
  #--------------------------------------------------------------------------
  alias move_game_picture_rf move unless $@
  def move(*args)
    move_game_picture_rf(*args)
    @mirror = $game_switches[YEM::FUNCTION::PICTURE_MIRROR_SWITCH]
  end
  
  #--------------------------------------------------------------------------
  # alias method: rotate
  #--------------------------------------------------------------------------
  alias rotate_game_picture_rf move unless $@
  def rotate(*args)
    rotate_game_picture_rf(*args)
    @mirror = $game_switches[YEM::FUNCTION::PICTURE_MIRROR_SWITCH]
  end
  
  #--------------------------------------------------------------------------
  # alias method: rotastart_tone_changete
  #--------------------------------------------------------------------------
  alias start_tone_change_game_picture_rf move unless $@
  def start_tone_change(*args)
    start_tone_change_game_picture_rf(*args)
    @mirror = $game_switches[YEM::FUNCTION::PICTURE_MIRROR_SWITCH]
  end
  
end # Game_Picture

#===============================================================================
# Game_Map
#===============================================================================

class Game_Map
  
  #--------------------------------------------------------------------------
  # overwrite method: update_scroll
  #--------------------------------------------------------------------------
  def update_scroll
    if @scroll_rest > 0
      distance = 2 ** @scroll_speed
      case @scroll_direction
      when 1  # Down Left
        scroll_down(distance)
        scroll_left(distance)
      when 2  # Down
        scroll_down(distance)
      when 3  # Down Right
        scroll_down(distance)
        scroll_right(distance)
      when 4  # Left
        scroll_left(distance)
      when 6  # Right
        scroll_right(distance)
      when 7  # Up Left
        scroll_up(distance)
        scroll_left(distance)
      when 8  # Up
        scroll_up(distance)
      when 9  # Up Right
        scroll_up(distance)
        scroll_right(distance)
      end
      @scroll_rest -= distance
    end
  end
  
end # Game_Map

#===============================================================================
# Game_Character
#===============================================================================

class Game_Character

  #--------------------------------------------------------------------------
  # alias method: update_self_movement
  #--------------------------------------------------------------------------
  alias update_self_movement_rf update_self_movement unless $@
  def update_self_movement
    return if $game_switches[YEM::FUNCTION::STOP_ALL_SWITCH]
    update_self_movement_rf
  end
  
end # Game_Character

#===============================================================================
# Game_Interpreter
#===============================================================================

class Game_Interpreter
  
  #--------------------------------------------------------------------------
  # alias method: command_231 (Show Picture)
  #--------------------------------------------------------------------------
  alias command_231_rf command_231 unless $@
  def command_231
    @params[0] = $game_variables[YEM::FUNCTION::PICTURE_NUMBER_VARIABLE] > 20 ?
      $game_variables[YEM::FUNCTION::PICTURE_NUMBER_VARIABLE] : @params[0]
    @params[0] = [[@params[0], 1].max, YEM::FUNCTION::MAXIMUM_PICTURES].min
    return command_231_rf
  end
  
  #--------------------------------------------------------------------------
  # alias method: command_232 (Move Picture)
  #--------------------------------------------------------------------------
  alias command_232_rf command_232 unless $@
  def command_232
    @params[0] = $game_variables[YEM::FUNCTION::PICTURE_NUMBER_VARIABLE] > 20 ?
      $game_variables[YEM::FUNCTION::PICTURE_NUMBER_VARIABLE] : @params[0]
    @params[0] = [[@params[0], 1].max, YEM::FUNCTION::MAXIMUM_PICTURES].min
    return command_232_rf
  end
  
  #--------------------------------------------------------------------------
  # alias method: command_233 (Rotate Picture)
  #--------------------------------------------------------------------------
  alias command_233_rf command_233 unless $@
  def command_233
    @params[0] = $game_variables[YEM::FUNCTION::PICTURE_NUMBER_VARIABLE] > 20 ?
      $game_variables[YEM::FUNCTION::PICTURE_NUMBER_VARIABLE] : @params[0]
    @params[0] = [[@params[0], 1].max, YEM::FUNCTION::MAXIMUM_PICTURES].min
    return command_233_rf
  end
  
  #--------------------------------------------------------------------------
  # alias method: command_234 (Tint Picture)
  #--------------------------------------------------------------------------
  alias command_234_rf command_234 unless $@
  def command_234
    @params[0] = $game_variables[YEM::FUNCTION::PICTURE_NUMBER_VARIABLE] > 20 ?
      $game_variables[YEM::FUNCTION::PICTURE_NUMBER_VARIABLE] : @params[0]
    @params[0] = [[@params[0], 1].max, YEM::FUNCTION::MAXIMUM_PICTURES].min
    return command_234_rf
  end
  
  #--------------------------------------------------------------------------
  # alias method: command_235 (Erase Picture)
  #--------------------------------------------------------------------------
  alias command_235_rf command_235 unless $@
  def command_235
    @params[0] = $game_variables[YEM::FUNCTION::PICTURE_NUMBER_VARIABLE] > 20 ?
      $game_variables[YEM::FUNCTION::PICTURE_NUMBER_VARIABLE] : @params[0]
    @params[0] = [[@params[0], 1].max, YEM::FUNCTION::MAXIMUM_PICTURES].min
    return command_235_rf
  end
  
  #--------------------------------------------------------------------------
  # script call method: scroll_lower_left
  #--------------------------------------------------------------------------
  def scroll_lower_left(distance, speed = 4)
    $game_map.start_scroll(1, distance, speed)
  end
  
  #--------------------------------------------------------------------------
  # script call method: scroll_lower_right
  #--------------------------------------------------------------------------
  def scroll_lower_right(distance, speed = 4)
    $game_map.start_scroll(3, distance, speed)
  end
  
  #--------------------------------------------------------------------------
  # script call method: scroll_upper_left
  #--------------------------------------------------------------------------
  def scroll_upper_left(distance, speed = 4)
    $game_map.start_scroll(7, distance, speed)
  end
  
  #--------------------------------------------------------------------------
  # script call method: scroll_upper_right
  #--------------------------------------------------------------------------
  def scroll_upper_right(distance, speed = 4)
    $game_map.start_scroll(9, distance, speed)
  end
  
end # Game_Interpreter

#===============================================================================
# Sprite_Picture
#===============================================================================

class Sprite_Picture < Sprite
  
  #--------------------------------------------------------------------------
  # alias method: update
  #--------------------------------------------------------------------------
  alias update_sprite_picture_rf update unless $@
  def update
    if @picture == nil
      $game_map.screen.clear
      return
    end
    update_sprite_picture_rf
    self.mirror = @picture.mirror
  end
  
end # Sprite_Picture

#===============================================================================
# Spriteset_Map
#===============================================================================

class Spriteset_Map
  
  #--------------------------------------------------------------------------
  # alias method: create_pictures
  #--------------------------------------------------------------------------
  alias create_pictures_spriteset_map_rf create_pictures unless $@
  def create_pictures
    create_pictures_spriteset_map_rf
    for i in 21..(YEM::FUNCTION::MAXIMUM_PICTURES)
      @picture_sprites.push(Sprite_Picture.new(@viewport2,
        $game_map.screen.pictures[i]))
    end
  end
  
end # Spriteset_Map

#===============================================================================
# Spriteset_Battle
#===============================================================================

class Spriteset_Battle
  
  #--------------------------------------------------------------------------
  # alias method: create_pictures
  #--------------------------------------------------------------------------
  alias create_pictures_spriteset_battle_rf create_pictures unless $@
  def create_pictures
    create_pictures_spriteset_battle_rf
    for i in 21..(YEM::FUNCTION::MAXIMUM_PICTURES)
      @picture_sprites.push(Sprite_Picture.new(@viewport2,
        $game_map.screen.pictures[i]))
    end
  end
  
end # Spriteset_Battle

#===============================================================================
# 
# END OF FILE
# 
#===============================================================================