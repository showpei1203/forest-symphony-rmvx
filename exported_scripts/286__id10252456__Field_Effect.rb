#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Field Effect
# 【用途】保留的 Runtime 元件「Field Effect」。
# 【主要機制】主要定義／擴充 RPG::UsableItem、Game_Temp、Game_Battler、Spriteset_Battle；下方原始說明與程式碼保留作細節依據。
# 【主要影響】RPG::UsableItem、Game_Temp、Game_Battler、Spriteset_Battle、SSS
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：FIELD_EFFECT_X、FIELD_EFFECT_Y、FIELD_EFFECT_OPACITY、FIELD_EFFECT_VANISH。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 6 個 alias／方法包裝，載入順序具有語意；登記 $imported：FieldEffects、BattleEngineMelody。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁直接引用：Iconset。刪除／改名素材前必須反查其他腳本與 Data／事件是否共用。
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
# Shanghai Simple Script - Field Effects
# Last Date Updated: 2010.06.19
# Level: Normal
# 
# This script allows some skills to place status effects that affect the entire
# enemy party and ally party. Only one field effect can exist at a time.
#===============================================================================
# Instructions
# -----------------------------------------------------------------------------
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials but above ▼ Main. Remember to save.
# 
# <field effect: x>
# Place this in a skill or item's notebox to make it replace the current field
# effect with state x.
# 
# <remove field effect>
# Place this in a skill or item's notebox to make it clear the field effect.
#===============================================================================
 
$imported = {} if $imported == nil
$imported["FieldEffects"] = true
 
module SSS
  # This places where the field effect icon appears on the screen. This is the
  # center of the field effect icon, which is 48x48 in size.
  FIELD_EFFECT_X = 300
  FIELD_EFFECT_Y = 60
  # This adjusts the field effect base opacity and the vanish rate.
  FIELD_EFFECT_OPACITY = 255
  FIELD_EFFECT_VANISH  = 8
end
 
#==============================================================================
# RPG::UsableItem
#==============================================================================
 
class RPG::UsableItem < RPG::BaseItem
  #--------------------------------------------------------------------------
  # * Field Effect
  #--------------------------------------------------------------------------
  def field_effect
    return @field_effect if @field_effect != nil
    @field_effect = 0
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when /<(?:FIELD_EFFECT|field effect):[ ](\d+)>/i
        @field_effect = $data_states[$1.to_i]
        @remove_field_effect = false
      end
    }
    return @field_effect
  end
  #--------------------------------------------------------------------------
  # * Remove Field Effect
  #--------------------------------------------------------------------------
  def remove_field_effect
    return @remove_field_effect if @remove_field_effect != nil
    @remove_field_effect = false
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when /<(?:REMOVE_FIELD_EFFECT|remove field effect)>/i
        @remove_field_effect = true
        @field_effect = 0
      end
    }
    return @remove_field_effect
  end
end
 
#==============================================================================
# ** Game_Temp
#==============================================================================
 
class Game_Temp
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :field_effect
end
 
#==============================================================================
# ** Game_Battler
#==============================================================================
 
class Game_Battler
  #--------------------------------------------------------------------------
  # * Get Current States as an Object Array
  #--------------------------------------------------------------------------
  alias states_sss_field_effects states unless $@
  def states
    result = states_sss_field_effects
    result.push($game_temp.field_effect) unless $game_temp.field_effect.nil?
    return result
  end
  #--------------------------------------------------------------------------
  # * Apply Skill Effects
  #--------------------------------------------------------------------------
  alias skill_effect_sss_field_effects skill_effect unless $@
  def skill_effect(user, skill)
    skill_effect_sss_field_effects(user, skill)
    return unless $scene.is_a?(Scene_Battle)
    $game_temp.field_effect = skill.field_effect unless skill.field_effect == 0
    $game_temp.field_effect = nil if skill.remove_field_effect
  end
  #--------------------------------------------------------------------------
  # * Apply Item Effects
  #--------------------------------------------------------------------------
  alias item_effect_sss_field_effects item_effect unless $@
  def item_effect(user, item)
    item_effect_sss_field_effects(user, item)
    return unless $scene.is_a?(Scene_Battle)
    $game_temp.field_effect = item.field_effect unless item.field_effect == 0
    $game_temp.field_effect = nil if item.remove_field_effect
  end
end
 
#==============================================================================
# ** Spriteset_Battle
#==============================================================================
 
class Spriteset_Battle
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias initialize_sss_field_effects initialize unless $@
  def initialize
    $game_temp.field_effect = nil
    @field_effect = nil
    initialize_sss_field_effects
  end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  alias dispose_sss_field_effects dispose unless $@
  def dispose
    dispose_sss_field_effects
    dispose_field_effect
    $game_temp.field_effect = nil
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  alias update_sss_field_effects update unless $@
  def update
    update_sss_field_effects
    update_field_effects
  end
  #--------------------------------------------------------------------------
  # * Update Field Effects
  #--------------------------------------------------------------------------
  def update_field_effects
    create_field_effect if @field_effect != $game_temp.field_effect
    dispose_field_effect if @field_effect.nil?
    pulse_field_effect unless @field_effect.nil?
  end
  #--------------------------------------------------------------------------
  # * Battle Engine Melody Update States
  #--------------------------------------------------------------------------
  def battle_engine_melody_update_states
    return unless $imported["BattleEngineMelody"]
    for member in $game_party.members + $game_troop.members
      member.clear_battle_cache
      member.update_maxhp = true
      member.update_maxmp = true
      member.update_states = true
      member.update_commands = true
    end
  end
  #--------------------------------------------------------------------------
  # * Create Field Effect
  #--------------------------------------------------------------------------
  def create_field_effect
    dispose_field_effect
    battle_engine_melody_update_states
    @field_effect = $game_temp.field_effect
    @field_effect_sprite = Sprite_Base.new(@viewport3)
    @field_effect_sprite.bitmap = Bitmap.new(24,24)
    bitmap = Cache.system("Iconset")
    icon_index = $game_temp.field_effect.icon_index
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    opacity = SSS::FIELD_EFFECT_OPACITY
    @field_effect_sprite.bitmap.blt(0, 0, bitmap, rect, opacity)
    @field_effect_sprite.ox = 12
    @field_effect_sprite.oy = 12
    @field_effect_sprite.x = SSS::FIELD_EFFECT_X
    @field_effect_sprite.y = SSS::FIELD_EFFECT_Y
    @field_effect_sprite.zoom_x = 2.0
    @field_effect_sprite.zoom_y = 2.0
    @pulse_effect_sprite = Sprite_Base.new(@viewport3)
    @pulse_effect_sprite.bitmap = Bitmap.new(24,24)
    @pulse_effect_sprite.bitmap.blt(0, 0, bitmap, rect, opacity)
    @pulse_effect_sprite.ox = 12
    @pulse_effect_sprite.oy = 12
    @pulse_effect_sprite.x = SSS::FIELD_EFFECT_X
    @pulse_effect_sprite.y = SSS::FIELD_EFFECT_Y
    @pulse_effect_sprite.z = @field_effect_sprite.z + 1
    @pulse_effect_sprite.zoom_x = 2.0
    @pulse_effect_sprite.zoom_y = 2.0
  end
  #--------------------------------------------------------------------------
  # * Dispose Field Effect
  #--------------------------------------------------------------------------
  def dispose_field_effect
    return if @field_effect_sprite.nil?
    @field_effect = $game_temp.field_effect
    battle_engine_melody_update_states
    @field_effect_sprite.dispose
    @field_effect_sprite = nil
    @pulse_effect_sprite.dispose
    @pulse_effect_sprite = nil
  end
  #--------------------------------------------------------------------------
  # * Pulse Field Effect
  #--------------------------------------------------------------------------
  def pulse_field_effect
    @pulse_effect_sprite.zoom_x += 0.1
    @pulse_effect_sprite.zoom_y += 0.1
    @pulse_effect_sprite.opacity -= SSS::FIELD_EFFECT_VANISH
    opacity = SSS::FIELD_EFFECT_OPACITY
    @pulse_effect_sprite.opacity = opacity if @pulse_effect_sprite.zoom_x > 8.0
    @pulse_effect_sprite.zoom_x = 2.0 if @pulse_effect_sprite.zoom_x > 8.0
    @pulse_effect_sprite.zoom_y = 2.0 if @pulse_effect_sprite.zoom_y > 8.0
    @field_effect_sprite.update
    @pulse_effect_sprite.update
  end
end
 
#===============================================================================
# 
# END OF FILE
# 
#============================================================================