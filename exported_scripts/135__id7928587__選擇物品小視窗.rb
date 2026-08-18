#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：選擇物品小視窗
# 【用途】UI／選單元件「選擇物品小視窗」。
# 【主要機制】擴充 Window／Scene／Sprite 顯示或操作；最終外觀可能由後載入 FS UI Patch 接管。
# 【主要影響】RPG::BaseItem、Game_Interpreter、Window_Pick_Item、Window_Pick_Item_Help、Scene_Map、SSS
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：PICK_ITEM_ROWS、PICK_ITEM_COLS。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 1 個 alias／方法包裝，載入順序具有語意；登記 $imported：PickItemEvent。
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
# Shanghai Simple Script - Pick Item Event
# Last Date Updated: 2010.05.25
# Level: Easy
# 
# This script prompts open a window to allow the player to select an item,
# weapon, or armor from the inventory to give the NPC, show the NPC, or whatever
# floats your boat. Works only on the map.
#===============================================================================
# Instructions
# -----------------------------------------------------------------------------
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ? Materials but above ? Main. Remember to save.
# 
# These commands go into the script call event. Use any one of these.
#   $game_variables[1] = pick_item_event
#   $game_variables[1] = pick_weapon_event
#   $game_variables[1] = pick_armor_event
# 
# This will return the selected item's item ID, weapon ID, or armor ID to the
# game variable you stored. 0 is returned if the player cancels.
# 
# <pick item>
# Place this tagin the noteboxes of your items, weapons, or armors to make
# you unable to select those items for the pick item event.
#===============================================================================
 
$imported = {} if $imported == nil
$imported["PickItemEvent"] = true
 
module SSS
  # This sets how many items will be shown by rows and columns.
  PICK_ITEM_ROWS = 1
  PICK_ITEM_COLS = 7
end
 
#==============================================================================
# RPG::BaseItem
#==============================================================================
 
class RPG::BaseItem
  #--------------------------------------------------------------------------
  # key_item
  #--------------------------------------------------------------------------
  def pick_item
    return @pick_item if @pick_item != nil
    @pick_item = false
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when /<(?:PICK_ITEM|pick item)>/i
        @pick_item = true
      end
    }
    return @pick_item
  end
end
 
#==============================================================================
# ** Game_Interpreter
#==============================================================================
 
class Game_Interpreter
  #--------------------------------------------------------------------------
  # * Pick Item Event
  #--------------------------------------------------------------------------
  def pick_item_event
    return 0 unless $scene.is_a?(Scene_Map)
    return $scene.pick_item_event(:item)
  end
  #--------------------------------------------------------------------------
  # * Pick Weapon Event
  #--------------------------------------------------------------------------
  def pick_weapon_event
    return 0 unless $scene.is_a?(Scene_Map)
    return $scene.pick_item_event(:weapon)
  end
  #--------------------------------------------------------------------------
  # * Pick Armor Event
  #--------------------------------------------------------------------------
  def pick_armor_event
    return 0 unless $scene.is_a?(Scene_Map)
    return $scene.pick_item_event(:armor)
  end
end
 
#==============================================================================
# ** Window_Pick_Item
#==============================================================================
 
class Window_Pick_Item < Window_Selectable
  #--------------------------------------------------------------------------
  # * initialize
  #--------------------------------------------------------------------------
  def initialize(type)
    @type = type
    w = SSS::PICK_ITEM_COLS * 24 + 32
    x = Graphics.width - w
    h = [SSS::PICK_ITEM_ROWS * 24 + 32, Graphics.height - 184].min
    y = Graphics.height - h - 128
    super(x, y, w, h)
    self.index = 0
    self.openness = 0
    @column_max = SSS::PICK_ITEM_COLS
    @spacing = 0
    refresh
  end
  #--------------------------------------------------------------------------
  # * Item
  #--------------------------------------------------------------------------
  def item
    return @data[self.index]
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    @data = []
    case @type
    when :item, :items
      for item in $game_party.items
        next unless item.is_a?(RPG::Item)
        next unless item.pick_item
        @data.push(item) if include?(item)
      end
    when :weapon, :weapons
      for item in $game_party.items
        next unless item.is_a?(RPG::Weapon)
        @data.push(item) if include?(item)
      end
    when :armor, :armors, :armour, :armours
      for item in $game_party.items
        next unless item.is_a?(RPG::Armor)
        @data.push(item) if include?(item)
      end
    end
    @item_max = @data.size
    create_contents
    for i in 0...@item_max
      draw_item(i)
    end
  end
  #--------------------------------------------------------------------------
  # * Include?
  #--------------------------------------------------------------------------
  def include?(item)
    return false if item.nil?
    return true
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #--------------------------------------------------------------------------
  def draw_item(index)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    item = @data[index]
    unless item.nil?
      icon = item.icon_index
      draw_icon(icon, rect.x, rect.y, enabled?(item))
      draw_item_amount(item, rect.clone)
    end
  end
  #--------------------------------------------------------------------------
  # * Enabled?
  #--------------------------------------------------------------------------
  def enabled?(item)
    return false if item.nil?
    return false if item.id == 201#泰勒鐵鎚
    return true if item.pick_item###
    return true
  end
  #--------------------------------------------------------------------------
  # * Draw Item Amount
  #--------------------------------------------------------------------------
  def draw_item_amount(item, rect)
    self.contents.font.size = 12
    number = $game_party.item_number(item)
    self.contents.font.color.alpha = enabled?(item) ? 255 : 128
    self.contents.draw_text(rect.x, rect.y + WLH/3, 24, WLH * 2/3, number, 2)
  end
end
 
#==============================================================================
# ** Window_Pick_Item_Help
#==============================================================================
 
class Window_Pick_Item_Help < Window_Base
  #--------------------------------------------------------------------------
  # * Initialize
  #--------------------------------------------------------------------------
  def initialize(pick_item_window)
    @pick_item_window = pick_item_window
    y = @pick_item_window.y - 56
    w = [@pick_item_window.width, 200].max
    x = Graphics.width - w
    super(x, y, w, 56)
    self.openness = 0
    refresh
  end
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def update
    super
    refresh if @last_item != @pick_item_window.item
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    item = @last_item = @pick_item_window.item
    draw_icon(item.icon_index, 0, 0)
    self.contents.draw_text(24, 0, contents.width - 24, WLH, item.name)
  end
end
 
#==============================================================================
# ** Scene_Map
#==============================================================================
 
class Scene_Map < Scene_Base
  #--------------------------------------------------------------------------
  # * Termination Processing
  #--------------------------------------------------------------------------
  alias terminate_sss_pick_item_event terminate unless $@
  def terminate
    unless @pick_item_window.nil?
      @pick_item_window.dispose
      @pick_item_window = nil
      @pick_item_help.dispose
      @pick_item_help = nil
    end
    terminate_sss_pick_item_event
  end
  #--------------------------------------------------------------------------
  # * Pick Item Event
  #--------------------------------------------------------------------------
  def pick_item_event(type = :item)
    case type
    when :item, :items, :weapon, :weapons, :armor, :armors, :armour, :armours
      @pick_item_window = Window_Pick_Item.new(type)
      @pick_item_help = Window_Pick_Item_Help.new(@pick_item_window)
    else
      return 0
    end
    value = 0
    @pick_item_window.open
    @pick_item_help.open
    loop do
      update_basic
      @pick_item_window.update
      @pick_item_help.update
      if Input.trigger?(Input::B)
        Sound.play_cancel
        value = 0
        break
      elsif Input.trigger?(Input::C)
        item = @pick_item_window.item
        if @pick_item_window.enabled?(item)
          Sound.play_decision
          value = item.id
          break
        else
          Sound.play_buzzer
        end
      end
    end
    @pick_item_window.close
    @pick_item_help.close
    loop do
      update_basic
      @pick_item_window.update
      @pick_item_help.update
      break if @pick_item_window.openness == 0
    end
    @pick_item_window.dispose
    @pick_item_window = nil
    @pick_item_help.dispose
    @pick_item_help = nil
    return value
  end
end
 
#===============================================================================
# 
# END OF FILE
# 
#===============================================================================