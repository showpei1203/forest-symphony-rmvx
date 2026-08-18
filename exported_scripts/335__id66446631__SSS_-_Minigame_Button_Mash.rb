#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：SSS - Minigame Button Mash
# 【用途】保留的 Runtime 元件「SSS - Minigame Button Mash」。
# 【主要機制】主要定義／擴充 Sprite_MashTimer、Game_Interpreter、Spriteset_Map、Spriteset_Battle；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Sprite_MashTimer、Game_Interpreter、Spriteset_Map、Spriteset_Battle、Scene_Map、Scene_Battle、SSS
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：BUTTON_MASH_SHEET、BUTTON_MASH_TEXT、MASH_START、MASH_TICK。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 2 個 alias／方法包裝，載入順序具有語意；登記 $imported：MinigameButtonMash。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁直接引用：Up、Cursor。刪除／改名素材前必須反查其他腳本與 Data／事件是否共用。
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
# Shanghai Simple Script - Minigame Button Mash
# Last Date Updated: 2010.05.18
# Level: Normal
# 
# This is the all purpose button mashing minigame. This minigame sets a timer
# and the animation to be played for the button mashing event. It will return
# the amount of times the button has been mashed.
#===============================================================================
# Instructions
# -----------------------------------------------------------------------------
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials but above ▼ Main. Remember to save.
# 用到圖案 MiniGameButtonMash
# Use the following event script call:
#   $game_variables[1] = button_mash(t,a,b)
# 
# Replace t with the time in seconds. a is the animation ID you wish to play
# whenever the player mashes the button. b is the button you want pressed as
# a string. Use the following table below to determine proper buttons:
# 
# L  R                      Q  W
# X  Y  Z   Translates to   A  S  D
# A  B  C                   Sh Z  X
# 
# Here's an example.
#   $game_variables[1] = button_mash(5,79,"C")
#===============================================================================

$imported = {} if $imported == nil
$imported["MinigameButtonMash"] = true

module SSS
  # This is the filename for the button mash mini game spritesheet. Place it
  # inside of Graphics\System to work.
  BUTTON_MASH_SHEET = "MiniGameButtonMash"
  BUTTON_MASH_TEXT  = "%s×"
  # These are the sound effects used for the button mash mini game.
  MASH_START   = RPG::SE.new("Up", 80, 150)
  MASH_TICK    = RPG::SE.new("Cursor", 80, 150)
  
module SPRITESET
  #--------------------------------------------------------------------------
  # * Button Mash Game
  #--------------------------------------------------------------------------
  def button_mash_game(time = 5, animation = 1, button = "Z")
    @time = [time, 1].max * 60
    @button_mash_animation = $data_animations[animation]
    case button.upcase
    when "A", "B", "C", "X", "Y", "Z", "L", "R"
      @mash_button = eval("Input::" + button.upcase)
    else
      @mash_button = Input::Z
    end
    @disposable_sprites = []
    @start_buffer = 60
    @times_mashed = 0
    create_button_mash_sprites(button)
  end
  #--------------------------------------------------------------------------
  # * Create Button Mash Sprites
  #--------------------------------------------------------------------------
  def create_button_mash_sprites(button)
    # Create Giant Button Sprite
    @button_sprite = Sprite_Base.new(@viewport2)
    @button_sprite.bitmap = Bitmap.new(48, 48)
    bitmap = Cache.system(SSS::BUTTON_MASH_SHEET)
    case button.upcase
    when "L"; rect = Rect.new( 0, 24, 24, 24)
    when "R"; rect = Rect.new(24, 24, 24, 24)
    when "X"; rect = Rect.new( 0, 48, 24, 24)
    when "Y"; rect = Rect.new(24, 48, 24, 24)
    when "Z"; rect = Rect.new(48, 48, 24, 24)
    when "A"; rect = Rect.new( 0, 72, 24, 24)
    when "B"; rect = Rect.new(24, 72, 24, 24)
    else; rect = Rect.new(48, 72, 24, 24)
    end
    @button_sprite.bitmap.stretch_blt(Rect.new(0, 0, 48, 48), bitmap, rect)
    @button_sprite.ox = @button_sprite.oy = 24
    @button_sprite.x = Graphics.width/2
    @button_sprite.y = Graphics.height/2
    @button_sprite.z = 100
    # Create Giant Hand Sprite
    @finger_sprite = Sprite_Base.new(@viewport3)
    @finger_sprite.bitmap = Bitmap.new(48, 48)
    rect = Rect.new(48, 24, 24, 24)
    @finger_sprite.bitmap.stretch_blt(Rect.new(0, 0, 48, 48), bitmap, rect)
    @finger_sprite.oy = 48
    @finger_sprite.x = Graphics.width/2
    @finger_sprite.y = Graphics.height/3
    @finger_sprite.z = 500
    # Create Instructions Sprite
    @instruction_sprite = Sprite_Base.new(@viewport3)
    @instruction_sprite.bitmap = Bitmap.new(72, 24)
    @instruction_sprite.bitmap.blt(0, 0, bitmap, Rect.new(0, 0, 72, 24))
    @instruction_sprite.ox = 36
    @instruction_sprite.x = Graphics.width/2
    @instruction_sprite.y = Graphics.height-152
    @instruction_sprite.z = 99
    # Create Timer
    @mash_timer_sprite = Sprite_MashTimer.new(@viewport3)
    # Create Times Mashed Sprite
    @mash_number_sprite = Sprite_Base.new(@viewport3)
    @mash_number_sprite.bitmap = Bitmap.new(Graphics.width/4, 48)
    @mash_number_sprite.bitmap.font.size = 32
    t = sprintf(SSS::BUTTON_MASH_TEXT, "0")
    @mash_number_sprite.bitmap.draw_text(0, 0, Graphics.width/4, 48, t, 1)
    @mash_number_sprite.ox = Graphics.width/8
    @mash_number_sprite.oy = 24
    @mash_number_sprite.x = Graphics.width/4
    @mash_number_sprite.y = Graphics.height/4-12
  end
  #--------------------------------------------------------------------------
  # * Dispose Button Mash Sprites
  #--------------------------------------------------------------------------
  def dispose_button_mash_sprites
    unless @button_sprite.nil?
      @button_sprite.bitmap.dispose
      @button_sprite.dispose
      @button_sprite = nil
    end
    unless @finger_sprite.nil?
      @finger_sprite.bitmap.dispose
      @finger_sprite.dispose
      @finger_sprite = nil
    end
    unless @instruction_sprite.nil?
      @instruction_sprite.bitmap.dispose
      @instruction_sprite.dispose
      @instruction_sprite = nil
    end
    unless @mash_timer_sprite.nil?
      @mash_timer_sprite.dispose
      @mash_timer_sprite = nil
    end
    unless @mash_number_sprite.nil?
      @mash_number_sprite.bitmap.dispose
      @mash_number_sprite.dispose
      @mash_number_sprite = nil
    end
    @disposable_sprites = [] if @disposable_sprites.nil?
    for sprite in @disposable_sprites
      sprite.bitmap.dispose
      sprite.dispose
    end
    @disposable_sprites = []
  end
  #--------------------------------------------------------------------------
  # * Update Button Mash
  #--------------------------------------------------------------------------
  def update_button_mash
    if @start_buffer > 0
      @start_buffer -= 1
      SSS::MASH_START.play if @start_buffer < 1
      return
    end
    @time -= 1 if @time > 0
    if Input.trigger?(@mash_button) and @time > 0
      @finger_sprite.y = Graphics.height/2
      button_mash_animation
    else
      @finger_sprite.y = [@finger_sprite.y - 8, Graphics.height/3].max
    end
    @button_sprite.update
    @finger_sprite.update
    @instruction_sprite.update
    @mash_timer_sprite.update
    @mash_number_sprite.update
    for sprite in @disposable_sprites
      sprite.update
    end
  end
  #--------------------------------------------------------------------------
  # * Button Mash Animation
  #--------------------------------------------------------------------------
  def button_mash_animation
    sprite = Sprite_Base.new(@viewport2)
    sprite.bitmap = Bitmap.new(48, 48)
    sprite.ox = sprite.oy = 24
    sprite.x = Graphics.width/2
    sprite.y = Graphics.height/2
    Sound.play_cursor if @button_mash_animation.nil?
    sprite.start_animation(@button_mash_animation)
    @disposable_sprites.push(sprite)
    @times_mashed += 1
    # Redraw Mash Number
    @mash_number_sprite.bitmap.dispose
    @mash_number_sprite.bitmap = Bitmap.new(Graphics.width/4, 48)
    @mash_number_sprite.bitmap.font.size = 32
    t = sprintf(SSS::BUTTON_MASH_TEXT, @times_mashed.to_s)
    @mash_number_sprite.bitmap.draw_text(0, 0, Graphics.width/4, 48, t, 1)
    @mash_number_sprite.ox = Graphics.width/8
    @mash_number_sprite.oy = 24
    @mash_number_sprite.x = Graphics.width/4
    @mash_number_sprite.y = Graphics.height/4-12
  end
  #--------------------------------------------------------------------------
  # * Break Button Mash
  #--------------------------------------------------------------------------
  def break_button_mash
    return false unless @finger_sprite.y == Graphics.height/3
    return false if @time > 0
    for sprite in @disposable_sprites
      return false if sprite.animation?
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Finish Button Mash
  #--------------------------------------------------------------------------
  def finish_button_mash
    loop do
      $scene.update_basic
      @button_sprite.opacity -= 4
      @finger_sprite.opacity -= 4
      @instruction_sprite.opacity -= 4
      @mash_timer_sprite.opacity -= 4
      @mash_number_sprite.opacity -= 4
      @button_sprite.update
      @finger_sprite.update
      @instruction_sprite.update
      @mash_timer_sprite.update
      @mash_number_sprite.update
      break if @button_sprite.opacity < 1
    end
    dispose_button_mash_sprites
    return @times_mashed
  end
end
end

#==============================================================================
# ** Sprite_MashTimer
#==============================================================================

class Sprite_MashTimer < Sprite
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(viewport)
    super(viewport)
    self.bitmap = Bitmap.new(88, 48)
    self.bitmap.font.name = Font.default_name
    self.bitmap.font.size = 24
    self.ox = 44
    self.oy = 24
    self.x = Graphics.width/2
    self.y = Graphics.height/4-12
    self.z = 500
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
      SSS::MASH_TICK.play if nan == 0
      text = sprintf("%02d:%02d", sec, nan)
      self.bitmap.font.color.set(255, 255, 255)
      self.bitmap.draw_text(self.bitmap.rect, text, 1)
    end
  end
end

#==============================================================================
# ** Game_Interpreter
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # * Button Mash Game
  #--------------------------------------------------------------------------
  def button_mash(time = 5, animation = 1, button = "Z")
    return 0 unless $scene.is_a?(Scene_Map) or $scene.is_a?(Scene_Battle)
    return $scene.button_mash(time, animation, button)
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
  alias dispose_sss_spriteset_map_button_mash dispose unless $@
  def dispose
    dispose_sss_spriteset_map_button_mash
    dispose_button_mash_sprites
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
  alias dispose_sss_spriteset_battle_button_mash dispose unless $@
  def dispose
    dispose_sss_spriteset_battle_button_mash
    dispose_button_mash_sprites
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
  # * Button Mash Game
  #--------------------------------------------------------------------------
  def button_mash(time = 5, animation = 1, button = "Z")
    @spriteset.button_mash_game(time, animation, button)
    loop do
      update_basic
      @spriteset.update_button_mash
      break if @spriteset.break_button_mash
    end
    return @spriteset.finish_button_mash
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
  # * Button Mash Game
  #--------------------------------------------------------------------------
  def button_mash(time = 5, animation = 1, button = "Z")
    @spriteset.button_mash_game(time, animation, button)
    loop do
      update_basic
      @spriteset.update_button_mash
      break if @spriteset.break_button_mash
    end
    return @spriteset.finish_button_mash
  end
end

#===============================================================================
# 
# END OF FILE
# 
#===============================================================================