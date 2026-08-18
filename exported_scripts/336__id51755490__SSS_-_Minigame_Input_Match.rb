#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：SSS - Minigame Input Match
# 【用途】保留的 Runtime 元件「SSS - Minigame Input Match」。
# 【主要機制】主要定義／擴充 Game_Interpreter、Sprite_InputTimer、Spriteset_Map、Spriteset_Battle；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Game_Interpreter、Sprite_InputTimer、Spriteset_Map、Spriteset_Battle、Scene_Map、Scene_Battle、SSS
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：INPUT_MATCH_SHEET、INPUT_START、INPUT_TICK、INPUT_CORRECT、INPUT_WRONG、INPUT_PERFECT、INPUT_ALMOST、INPUT_MISSED。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 2 個 alias／方法包裝，載入順序具有語意；登記 $imported：MinigameInputMatch。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁直接引用：Up、Cursor、Decision2、Buzzer1、Chime2、Buzzer2。刪除／改名素材前必須反查其他腳本與 Data／事件是否共用。
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
# Shanghai Simple Script - Minigame Input Match
# Last Date Updated: 2010.05.24
# Level: Normal
# 
# This is a minigame script. The game gives you a sequence to input and the
# player follows the sequence. Easy as that.
#===============================================================================
# Instructions
# -----------------------------------------------------------------------------
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials but above ▼ Main. Remember to save.
# 
# Do a script call for
#   @i = "236C"
#   $game_variables[1] = input_match(@i,x)
# 
# i is the input sequence you want the player to match. x is the amount of time
# given to the player. For the input string, the following items are allowed:
# 
# 7  8  9  L  R                      UL  U  UR  Q  W
# 4     6  X  Y  Z   Translates to    L     R   A  S  D
# 1  2  3  A  B  C                   DL  D  DR  Sh Z  X
# 
# Don't confuse them. The score that's returned to the variable is a percent
# score of how well the player matched input sequence.
#===============================================================================

$imported = {} if $imported == nil
$imported["MinigameInputMatch"] = true

module SSS
  # This is the filename for the input match mini game spritesheet. Place it
  # inside of Graphics\System to work.
  INPUT_MATCH_SHEET = "MiniGameInputMatch"
  # These are the sound effects used for the input match mini game.
  INPUT_START   = RPG::SE.new("Up", 80, 150)
  INPUT_TICK    = RPG::SE.new("Cursor", 80, 150)
  INPUT_CORRECT = RPG::SE.new("Decision2", 80, 150)
  INPUT_WRONG   = RPG::SE.new("Buzzer1", 80, 150)
  INPUT_PERFECT = RPG::SE.new("Chime2", 80, 120)
  INPUT_ALMOST  = RPG::SE.new("Decision2", 80, 100)
  INPUT_MISSED  = RPG::SE.new("Buzzer2", 80, 100)
  
module SPRITESET
  #--------------------------------------------------------------------------
  # * Input Match Game
  #--------------------------------------------------------------------------
  def input_match(string = "236C", time = 0)
    @time = time
    @time = string.size * 30 if time < 1
    @input_string = []
    @ebuffer = 10
    string.size.times do
      c = string.slice!(/./m)
      case c
      when "1"; @input_string.push(:i1)
      when "2"; @input_string.push(:i2)
      when "3"; @input_string.push(:i3)
      when "4"; @input_string.push(:i4)
      when "6"; @input_string.push(:i6)
      when "7"; @input_string.push(:i7)
      when "8"; @input_string.push(:i8)
      when "9"; @input_string.push(:i9)
      when "A"; @input_string.push(:kA)
      when "B"; @input_string.push(:kB)
      when "C"; @input_string.push(:kC)
      when "X"; @input_string.push(:kX)
      when "Y"; @input_string.push(:kY)
      when "Z"; @input_string.push(:kZ)
      when "L"; @input_string.push(:kL)
      when "R"; @input_string.push(:kR)
      else; next
      end
    end
    @correct_input = 0
    @current_input = 0
    create_input_match_sprites
  end
  #--------------------------------------------------------------------------
  # * Create Input Match Sprites
  #--------------------------------------------------------------------------
  def create_input_match_sprites
    # Make Input Dummy Window
    w = @input_string.size * 48 + 32
    y = (Graphics.height - 80) / 2
    x = (Graphics.width - w) / 2
    @input_match_dummy_window = Window_Base.new(x, y, w, 80)
    @input_match_dummy_window.viewport = @viewport3
    # Make Input Timer
    @buffer = 40
    @input_timer = Sprite_InputTimer.new(@viewport3, @input_match_dummy_window)
    # Make Input Sprites
    @image = Cache.system(SSS::INPUT_MATCH_SHEET)
    bitmap = Bitmap.new(@input_string.size * 48, 24)
    bitmap_x = 12
    for input_id in @input_string
      case input_id
      when :i1; rect = Rect.new(  0, 48, 24, 24)
      when :i2; rect = Rect.new( 24, 48, 24, 24)
      when :i3; rect = Rect.new( 48, 48, 24, 24)
      when :i4; rect = Rect.new(  0, 24, 24, 24)
      when :i6; rect = Rect.new( 48, 24, 24, 24)
      when :i7; rect = Rect.new(  0,  0, 24, 24)
      when :i8; rect = Rect.new( 24,  0, 24, 24)
      when :i9; rect = Rect.new( 48,  0, 24, 24)
      when :kA; rect = Rect.new( 72, 48, 24, 24)
      when :kB; rect = Rect.new( 96, 48, 24, 24)
      when :kC; rect = Rect.new(120, 48, 24, 24)
      when :kX; rect = Rect.new( 72, 24, 24, 24)
      when :kY; rect = Rect.new( 96, 24, 24, 24)
      when :kZ; rect = Rect.new(120, 24, 24, 24)
      when :kL; rect = Rect.new( 72,  0, 24, 24)
      when :kR; rect = Rect.new( 96,  0, 24, 24)
      else; next
      end
      bitmap.blt(bitmap_x, 0, @image, rect)
      bitmap_x += 48
    end
    @input_match_sprite = Sprite_Base.new(@viewport3)
    @input_match_sprite.bitmap = bitmap
    @input_match_sprite.z = @input_match_dummy_window.z + 1
    @input_match_sprite.x = @input_match_dummy_window.x + 16
    @input_match_sprite.y = @input_match_dummy_window.y + 40
  end
  #--------------------------------------------------------------------------
  # * Dispose Input Match Sprites
  #--------------------------------------------------------------------------
  def dispose_input_match_sprites
    unless @input_match_dummy_window.nil?
      @input_match_dummy_window.dispose
      @input_match_dummy_window = nil
    end
    unless @input_timer.nil?
      @input_timer.dispose
      @input_timer = nil
    end
    unless @input_match_sprite.nil?
      @input_match_sprite.bitmap.dispose
      @input_match_sprite.dispose
      @input_match_sprite = nil
    end
    unless @input_result_sprite.nil?
      @input_result_sprite.bitmap.dispose
      @input_result_sprite.dispose
      @input_result_sprite = nil
    end
  end
  #--------------------------------------------------------------------------
  # * Update Input Match
  #--------------------------------------------------------------------------
  def update_input_match
    if @buffer > 0
      @buffer -= 1
      @input_timer.update
      @input_match_sprite.update
      SSS::INPUT_START.play if @buffer == 0
      return
    end
    @time -= 1 unless @time < 1
    SSS::INPUT_TICK.play if @time % 60 == 0
    update_input_match_button
    @input_match_sprite.update
    @input_timer.update
  end
  #--------------------------------------------------------------------------
  # * Update Input Match Button
  #--------------------------------------------------------------------------
  def update_input_match_button
    if Input.trigger?(Input::A)
      key = :kA
    elsif Input.trigger?(Input::B)
      key = :kB
    elsif Input.trigger?(Input::C)
      key = :kC
    elsif Input.trigger?(Input::X)
      key = :kX
    elsif Input.trigger?(Input::Y)
      key = :kY
    elsif Input.trigger?(Input::Z)
      key = :kZ
    elsif Input.trigger?(Input::L)
      key = :kL
    elsif Input.trigger?(Input::R)
      key = :kR
    elsif Input.dir8 != 0
      case Input.dir8
      when 1; key = :i1
      when 2; key = :i2
      when 3; key = :i3
      when 4; key = :i4
      when 6; key = :i6
      when 7; key = :i7
      when 8; key = :i8
      when 9; key = :i9
      else; return
      end
    else
      return
    end
    check_input_key(key)
  end
  #--------------------------------------------------------------------------
  # * Check Input Key
  #--------------------------------------------------------------------------
  def check_input_key(key)
    good = key == @input_string[@current_input]
    if good
      @correct_input += 1
      SSS::INPUT_CORRECT.play
      rect = Rect.new(24, 24, 24, 24)
    else
      if [:i1, :i2, :i3, :i4, :i6, :i7, :i8, :i9].include?(key) and @ebuffer > 0
        @ebuffer -= 1
        return if @ebuffer > 0
      end
      SSS::INPUT_WRONG.play
      rect = Rect.new(120, 0, 24, 24)
    end
    @ebuffer = 10
    @input_match_sprite.bitmap.blt(@current_input * 48 + 12, 0, @image, rect)
    @current_input += 1
  end
  #--------------------------------------------------------------------------
  # * Break Input Match
  #--------------------------------------------------------------------------
  def break_input_match
    return true if @current_input == @input_string.size
    return true if @time < 1
    return false
  end
  #--------------------------------------------------------------------------
  # * Input Match Results
  #--------------------------------------------------------------------------
  def input_match_results
    @buffer = 60
    loop do
      $scene.update_basic
      @buffer -= 1
      break if @buffer < 1
    end
    score = (@correct_input * 100 / @input_string.size)
    case score
    when 100
      rect = Rect.new(144,  0, 96, 24)
      SSS::INPUT_PERFECT.play
    when 60..99
      rect = Rect.new(144, 24, 96, 24)
      SSS::INPUT_ALMOST.play
    else
      rect = Rect.new(144, 48, 96, 24)
      SSS::INPUT_MISSED.play
    end
    # Make Input Results Sprite
    @input_result_sprite = Sprite_Base.new(@viewport3)
    @input_result_sprite.bitmap = Bitmap.new(96, 24)
    @input_result_sprite.bitmap.blt(0, 0, @image, rect)
    @input_result_sprite.zoom_x = @input_result_sprite.zoom_y = 2.0
    @input_result_sprite.ox = 48
    @input_result_sprite.oy = 24
    @input_result_sprite.z = 300
    @input_result_sprite.x = Graphics.width / 2
    @input_result_sprite.y = Graphics.height / 2
    @input_result_sprite.opacity = 0
    raise = 20
    raise.times do 
      @input_result_sprite.opacity += 16
      @input_result_sprite.y -= 2
      @input_result_sprite.update
      $scene.update_basic
    end
    loop do
      @input_result_sprite.opacity -= 4
      @input_result_sprite.update
      $scene.update_basic
      break if @input_result_sprite.opacity < 1
    end
    # Dispose
    dispose_input_match_sprites
    return score
  end
end
end

#==============================================================================
# ** Game_Interpreter
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # * Input Match
  #--------------------------------------------------------------------------
  def input_match(string = "236C", time = 0)
    return false unless $scene.is_a?(Scene_Map) or $scene.is_a?(Scene_Battle)
    return $scene.input_match(string, time)
  end
end

#==============================================================================
# ** Sprite_Timer
#==============================================================================

class Sprite_InputTimer < Sprite
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(viewport, window)
    super(viewport)
    self.bitmap = Bitmap.new(88, 48)
    self.bitmap.font.name = Font.default_name
    self.bitmap.font.size = 24
    self.x = window.x + (window.width - 88) / 2
    self.y = window.y
    self.z = 200
    self.visible = true
    update
  end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    self.bitmap.dispose
    super
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    if $scene.spriteset.time != @last_time
      self.bitmap.clear
      @last_time = $scene.spriteset.time
      sec = @last_time / 60
      nan = @last_time % 60
      SSS::INPUT_TICK.play if sec == nan and sec == 0
      text = sprintf("%02d:%02d", sec, nan)
      self.bitmap.font.color.set(255, 255, 255)
      self.bitmap.draw_text(self.bitmap.rect, text, 1)
    end
  end
end

#==============================================================================
# ** Spriteset_Map
#==============================================================================

class Spriteset_Map
  include SSS::SPRITESET
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :time
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  alias dispose_sss_spriteset_map_input_match dispose unless $@
  def dispose
    dispose_sss_spriteset_map_input_match
    dispose_input_match_sprites
  end
end

#==============================================================================
# ** Spriteset_Battle
#==============================================================================

class Spriteset_Battle
  include SSS::SPRITESET
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :time
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  alias dispose_sss_spriteset_battle_input_match dispose unless $@
  def dispose
    dispose_sss_spriteset_battle_input_match
    dispose_input_match_sprites
  end
end

#==============================================================================
# ** Scene_Map
#==============================================================================

class Scene_Map < Scene_Base
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :spriteset
  #--------------------------------------------------------------------------
  # * Input Match Game
  #--------------------------------------------------------------------------
  def input_match(string = "236C", time = 0)
    @spriteset.input_match(string, time)
    loop do
      update_basic
      @spriteset.update_input_match
      break if @spriteset.break_input_match
    end
    return @spriteset.input_match_results
  end
end

#==============================================================================
# ** Scene_Battle
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :spriteset
  #--------------------------------------------------------------------------
  # * Input Match Game
  #--------------------------------------------------------------------------
  def input_match(string = "236C", time = 0)
    @spriteset.input_match(string, time)
    loop do
      update_basic
      @spriteset.update_input_match
      break if @spriteset.break_input_match
    end
    return @spriteset.input_match_results
  end
end

#===============================================================================
# 
# END OF FILE
# 
#===============================================================================