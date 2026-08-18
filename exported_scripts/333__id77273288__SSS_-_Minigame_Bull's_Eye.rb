#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：SSS - Minigame Bull's Eye
# 【用途】保留的 Runtime 元件「SSS - Minigame Bull's Eye」。
# 【主要機制】主要定義／擴充 Game_Interpreter、Spriteset_Map、Spriteset_Battle、Scene_Map；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Game_Interpreter、Spriteset_Map、Spriteset_Battle、Scene_Map、Scene_Battle、SSS、SPRITESET
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：BULLS_EYE_SHEET、BULLS_EYE_SHOOT、BULLS_EYE_CLICK、BULLS_EYE_PERFECT、BULLS_EYE_ALMOST、BULLS_EYE_MISSED。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 2 個 alias／方法包裝，載入順序具有語意；登記 $imported：MinigameBullsEye。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁直接引用：Bow1、Cursor、Chime2、Decision2、Buzzer2。刪除／改名素材前必須反查其他腳本與 Data／事件是否共用。
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
# Shanghai Simple Script - Minigame Bull's Eye
# Last Date Updated: 2010.05.18
# Level: Normal
# 
# This is a minigame script. It's easy to play. Press Z when the cursor is right
# above the bull's eye or within the red region.
#===============================================================================
# Instructions
# -----------------------------------------------------------------------------
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials but above ▼ Main. Remember to save.
# 用到的圖片  ： MiniGameBullseye
# Do a script call for
#   $game_variables[1] = bulls_eye_game(x, y)
# 
# x is the percentage range allowed for error and y is the cursor speed.
# Works with Battle Engine Melody.
#===============================================================================

$imported = {} if $imported == nil
$imported["MinigameBullsEye"] = true

module SSS
  # This is the filename for the bull's eye mini game spritesheet. Place it
  # inside of Graphics\System to work.
  BULLS_EYE_SHEET = "MiniGameBullseye"
  # These are the sound effects used for the bull's eye mini game.
  BULLS_EYE_SHOOT = RPG::SE.new("Bow1", 80, 100)
  BULLS_EYE_CLICK = RPG::SE.new("Cursor", 40, 150)
  BULLS_EYE_PERFECT = RPG::SE.new("Chime2", 80, 120)
  BULLS_EYE_ALMOST  = RPG::SE.new("Decision2", 80, 100)
  BULLS_EYE_MISSED  = RPG::SE.new("Buzzer2", 80, 100)
  
module SPRITESET
  #--------------------------------------------------------------------------
  # * Bulls Eye Game
  #--------------------------------------------------------------------------
  def bulls_eye_game(percent = 15, speed = 10)
    @bulls_eye_percent = percent
    @bulls_eye_speed = speed
    create_bulls_eye_sprites
  end
  #--------------------------------------------------------------------------
  # * Create Bulls Eye Sprites
  #--------------------------------------------------------------------------
  def create_bulls_eye_sprites
    @bulls_eye_sprite = Sprite_Base.new(@viewport3)
    bitmap1 = Bitmap.new(512, 72)
    bitmap2 = Cache.system(SSS::BULLS_EYE_SHEET)
    # Make the Main Body
    rect = Rect.new(0, 0, 512, 24)
    bitmap1.blt(0, 24, bitmap2, rect)
    # Make the Target Safe Zone
    rect = Rect.new(0, 24, 0, 24)
    rect.width = @bulls_eye_percent * 512 / 100
    rect.x = (512 - rect.width) / 2
    bitmap1.blt(rect.x, 24, bitmap2, rect)
    # Make the Target Center
    rect = Rect.new(488, 48, 24, 24)
    bitmap1.blt(244, 24, bitmap2, rect)
    # Make the Instructions
    rect = Rect.new(312, 48, 176, 24)
    bitmap1.blt(168, 48, bitmap2, rect)
    # Apply Sprite
    @bulls_eye_sprite.bitmap = bitmap1
    @bulls_eye_sprite.x = (Graphics.width - 512) / 2
    @bulls_eye_sprite.y = Graphics.height - 200
    # Arrow Sprite
    @arrow_shoot_sprite = Sprite_Base.new(@viewport3)
    @arrow_shoot_sprite.bitmap = Bitmap.new(24, 24)
    rect = Rect.new(0, 48, 24, 24)
    @arrow_shoot_sprite.bitmap.blt(0, 0, bitmap2, rect)
    @arrow_shoot_sprite.ox = 12
    @arrow_shoot_sprite.oy = 24
    @arrow_shoot_sprite.x = @bulls_eye_sprite.x
    @arrow_shoot_sprite.y = @bulls_eye_sprite.y + 24
    # Make Sounds
    @shoot_sound = SSS::BULLS_EYE_SHOOT
    @click_sound = SSS::BULLS_EYE_CLICK
    @bulls_eye_direction = 0
  end
  #--------------------------------------------------------------------------
  # * Dispose Bulls Eye Sprites
  #--------------------------------------------------------------------------
  def dispose_bulls_eye_sprites
    unless @bulls_eye_sprite.nil?
      @bulls_eye_sprite.dispose
      @bulls_eye_sprite = nil
    end
    unless @arrow_shoot_sprite.nil?
      @arrow_shoot_sprite.dispose
      @arrow_shoot_sprite = nil
    end
    unless @results_sprite.nil?
      @results_sprite.dispose
      @results_sprite = nil
    end
  end
  #--------------------------------------------------------------------------
  # * Update Bulls Eye Sprites
  #--------------------------------------------------------------------------
  def update_bulls_eye_sprites
    @bulls_eye_sprite.update
    if @bulls_eye_direction == 0
      m = Graphics.width - @bulls_eye_sprite.x
      @arrow_shoot_sprite.x = [@arrow_shoot_sprite.x + @bulls_eye_speed, m].min
      @bulls_eye_direction = 1 if @arrow_shoot_sprite.x >= m
    else
      m = @bulls_eye_sprite.x
      @arrow_shoot_sprite.x = [@arrow_shoot_sprite.x - @bulls_eye_speed, m].max
      @bulls_eye_direction = 0 if @arrow_shoot_sprite.x <= m
    end
    @click_sound.play if @bulls_eye_speed >= 0
    @arrow_shoot_sprite.update
  end
  #--------------------------------------------------------------------------
  # * Create Bulls Eye Results
  #--------------------------------------------------------------------------
  def create_bulls_eye_results
    @results_sprite = Sprite_Base.new(@viewport3)
    @results_sprite.bitmap = Bitmap.new(96, 24)
    bitmap = Cache.system(SSS::BULLS_EYE_SHEET)
    mx = @bulls_eye_sprite.x
    perfect_location = (mx+244)..(mx+268)
    almost_percent = (@bulls_eye_percent * 512 / 100) / 2
    almost_location1 = 512/2 - almost_percent
    almost_location2 = 512/2 + almost_percent
    if (mx+244..mx+268) === @arrow_shoot_sprite.x
      SSS::BULLS_EYE_PERFECT.play
      @result = 2
      rect = Rect.new(24, 48, 96, 24)
    elsif (mx+almost_location1..mx+almost_location2) === @arrow_shoot_sprite.x
      SSS::BULLS_EYE_ALMOST.play
      @result = 1
      rect = Rect.new(120, 48, 96, 24)
    else
      SSS::BULLS_EYE_MISSED.play
      @result = 0
      rect = Rect.new(216, 48, 96, 24)
    end
    @results_sprite.bitmap.blt(0, 0, bitmap, rect)
    @results_sprite.ox = 48
    @results_sprite.x = Graphics.width / 2
    @results_sprite.y = @bulls_eye_sprite.y - 24
  end
  #--------------------------------------------------------------------------
  # * Stop Bulls Eye Sprites
  #--------------------------------------------------------------------------
  def stop_bulls_eye_sprites
    @bulls_eye_speed = 0
    @shoot_sound.play
    wait = 60
    loop do
      wait -= 1
      $scene.update_basic
      @results_sprite.update unless @results_sprite.nil?
      case wait
      when 40
        create_bulls_eye_results
      when 0
        break
      end
    end
    dispose_bulls_eye_sprites
    return @result
  end
end
end

#==============================================================================
# ** Game_Interpreter
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # * Bulls Eye Game
  #--------------------------------------------------------------------------
  def bulls_eye(percent = 15, speed = 10)
    return false unless $scene.is_a?(Scene_Map) or $scene.is_a?(Scene_Battle)
    return $scene.bulls_eye(percent, speed)
  end
end

#==============================================================================
# ** Spriteset_Map
#==============================================================================

class Spriteset_Map
  include SSS::SPRITESET
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  alias dispose_sss_spriteset_map_bulls_eye dispose unless $@
  def dispose
    dispose_sss_spriteset_map_bulls_eye
    dispose_bulls_eye_sprites
  end
end

#==============================================================================
# ** Spriteset_Battle
#==============================================================================

class Spriteset_Battle
  include SSS::SPRITESET
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  alias dispose_sss_spriteset_battle_bulls_eye dispose unless $@
  def dispose
    dispose_sss_spriteset_battle_bulls_eye
    dispose_bulls_eye_sprites
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
  # * Bulls Eye Game
  #--------------------------------------------------------------------------
  def bulls_eye(percent = 15, speed = 10)
    @spriteset.bulls_eye_game(percent, speed)
    loop do
      update_basic
      @spriteset.update_bulls_eye_sprites
      break if Input.trigger?(Input::C)
    end
    return @spriteset.stop_bulls_eye_sprites
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
  # * Bulls Eye Game
  #--------------------------------------------------------------------------
  def bulls_eye(percent = 15, speed = 10)
    @spriteset.bulls_eye_game(percent, speed)
    loop do
      update_basic
      @spriteset.update_bulls_eye_sprites
      break if Input.trigger?(Input::C)
    end
    return @spriteset.stop_bulls_eye_sprites
  end
end

#===============================================================================
# 
# END OF FILE
# 
#===============================================================================