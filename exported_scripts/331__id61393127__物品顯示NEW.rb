#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：物品顯示NEW
# 【用途】物品／商店元件「物品顯示NEW」。
# 【主要機制】處理物品資料、交易、製作、庫存或 UI；事件入口與資料庫設定需要一起確認。
# 【主要影響】Game_Interpreter、Window_Base、Window_ItemList、Window_Item、Window_Equip_Item、Game_Party、Window_EquipItem
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：IMAGE、METHOD。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 8 個 alias／方法包裝，載入順序具有語意；登記 $imported：YEA-AceEquipEngine。
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
#------------------------------------------------------------------------------#
#  Galv's New Item Indication
#------------------------------------------------------------------------------#
#  For: RPGMAKER VX ACE
#  Version 1.5
#------------------------------------------------------------------------------#
#  2014-01-05 - Version 1.5 - compatibility fix
#  2013-07-16 - Version 1.4 - made key items work
#  2013-03-05 - Version 1.3 - fixed bug when all items are new when battle exit
#  2013-03-03 - Version 1.2 - added script call to manually remove 'new' images
#                           - fixed unequipping item creating 'new' images
#  2013-03-03 - Version 1.1 - fixed method 2 new not appearing for drops
#  2013-03-03 - Version 1.0 - release
#------------------------------------------------------------------------------#
#  Adds a 'new' image on items in the inventory that the player has recently
#  acquired. There are 2 methods for you to chose from as to when this image
#  appears and when it is removed and no longer counted as new.
#------------------------------------------------------------------------------#
#  SCRIPT CALL
#------------------------------------------------------------------------------#
#
#  clear_new(type)      # Manually removes 'new' images from selected type
#                       # type can be one of the following
#                       # :all    :item     :weapon    :armor
#------------------------------------------------------------------------------#
#  EXAMPLE:
#  clear_new(:item)     # all 'new' image on items will be cleared
#  clear_new(:all)      # all 'new' images on everything will be cleared
#------------------------------------------------------------------------------#
   
($imported ||= {})["Galv_New_Item_Indicator"] = true
module Galv_Nitem
     
#------------------------------------------------------------------------------# 
#  SETUP OPTIONS
#------------------------------------------------------------------------------#
   
  IMAGE = "new_indicator"    # Image located in /Graphics/System/
     
  METHOD = 1     # METHOD option can be 1 or 2 (see below)
   
#------------------------------------------------------------------------------# 
#
#   1: The 'new' image appears on items that the player hasn't seen before and
#      is only removed when the player moves the cursor over them (from any
#      scene)
#
#   2: The new image appears for items that are picked up and are removed
#      when the player leaves the item scene OR cursors over the item.
#      Any items picked up again will re-add the 'new' image for the player to
#      see what items they picked up recently. (So if you already had 4 potions
#      and pick up another, potions would have 'new' image again).
#
#------------------------------------------------------------------------------# 
#  END SETUP OPTIONS
#------------------------------------------------------------------------------#
   
end
   
class Game_Interpreter
  def clear_new(type)
    if type == :all
      $game_party.nitems[:weapon] = []
      $game_party.nitems[:armor] = []
      $game_party.nitems[:item] = []
    else
      $game_party.nitems[type] = []
    end
  end
end # Game_Interpreter
   
   
module Galv_GetCat
  def get_category(item)
    if item.is_a?(RPG::Item)
      return :item
    elsif item.is_a?(RPG::Weapon)
      return :weapon
    elsif item.is_a?(RPG::Armor)
      return :armor
    else
      return :none
    end
  end
end # Galv_GetCat


###################################
class Window_Base < Window
  include Galv_GetCat
  alias galv_nitem_wh_draw_item_name draw_item_name
  def draw_item_name(item, x, y, enabled = true)
    galv_nitem_wh_draw_item_name(item, x, y, enabled = true)
    return if item.nil?
    cat = get_category(item)
    return if cat == :none
    if Galv_Nitem::METHOD == 1 && !$game_party.nitems[cat][item.id] ||
        Galv_Nitem::METHOD == 2 && $game_party.nitems[cat][item.id]
      draw_item_new3(item, x, y)
    end
  end
  def draw_item_new3(item, x, y)
    bitmap = Cache.system(Galv_Nitem::IMAGE)
    rect = Rect.new(0, 0, 24, 24)
    contents.blt(x, y-6, bitmap, rect, 255)
  end
end
###################################
###############################################################################
#   Window_ItemList
###############################################################################
class Window_ItemList
  include Galv_GetCat
  alias galv_nitem_wh_set_item update_help
  def update_help
    
    galv_nitem_wh_set_item
    if Input.trigger?(Input::UP) || Input.trigger?(Input::DOWN) || Input.trigger?(Input::B) || @index == 0
    add_to_known_items(item)
    end
  end
     
  def add_to_known_items(item)
    category = get_category(item)
    return if category == :none
    if !$game_party.nitems[category][item.id] && Galv_Nitem::METHOD == 1      
      $game_party.nitems[category][item.id] = true
    elsif $game_party.nitems[category][item.id] && Galv_Nitem::METHOD == 2
      $game_party.nitems[category][item.id] = false
    end
    ################
    ###############
  end
end # Window_Help < Window_Base
####################################
class Window_Item
  include Galv_GetCat
  alias galv_nitem_wh_set_item_name update_help
  def update_help
    
    galv_nitem_wh_set_item_name
    if Input.trigger?(Input::UP) || Input.trigger?(Input::DOWN) || Input.trigger?(Input::B) || @index == 0
    add_to_known_items(item)
    end
  end
     
  def add_to_known_items(item)
    category = get_category(item)
    return if category == :none
    if !$game_party.nitems[category][item.id] && Galv_Nitem::METHOD == 1      
      $game_party.nitems[category][item.id] = true
    elsif $game_party.nitems[category][item.id] && Galv_Nitem::METHOD == 2
      $game_party.nitems[category][item.id] = false
    end
    ################
    ###############
  end
end
###################################
##############################################################################
#   Window_Equip_Item
###############################################################################
class Window_Equip_Item
  include Galv_GetCat
  alias galv_nitem_wh_set_item_name update_help
  def update_help
    
    galv_nitem_wh_set_item_name
    if Input.trigger?(Input::UP) || Input.trigger?(Input::DOWN) || Input.trigger?(Input::B) || @index == 0
    add_to_known_items(item)
    end
  end
     
  def add_to_known_items(item)
    category = get_category(item)
    return if category == :none
    if !$game_party.nitems[category][item.id] && Galv_Nitem::METHOD == 1      
      $game_party.nitems[category][item.id] = true
    elsif $game_party.nitems[category][item.id] && Galv_Nitem::METHOD == 2
      $game_party.nitems[category][item.id] = false
    end
    ################
    ###############
  end
end # Window_Help < Window_Base
###############################################################################   
###############################################################################
#   Window_Equip_Item
###############################################################################
class Window_Equip_Item < Window_Selectable
   alias galv_nitem_wi_draw_item_name draw_item
   def draw_item(index)
    galv_nitem_wi_draw_item_name(index)
    item = @data[index]
    return if item.nil?
       
    cat = get_category(item)
    return if cat == :none
    rect = item_rect(index)
    if Galv_Nitem::METHOD == 1 && !$game_party.nitems[cat][item.id] ||
        Galv_Nitem::METHOD == 2 && $game_party.nitems[cat][item.id]
      draw_item_new2(item, rect.x, rect.y)
    end
  end
  
  def draw_item_new2(item, x, y)
    bitmap = Cache.system(Galv_Nitem::IMAGE)
    rect = Rect.new(0, 0, 24, 24)
    contents.blt(x, y-6, bitmap, rect, 255)
  end
end
##############################################################################
class Game_Party < Game_Unit
  attr_accessor :nitems
  include Galv_GetCat
     
  alias galv_nitem_gp_initialize initialize
  def initialize
    @nitems = {:item=>[],:weapon=>[],:armor=>[]}
    galv_nitem_gp_initialize
  end
     
  alias galv_nitem_gp_gain_item gain_item
  def gain_item(item, amount, include_equip = false)
    
    if Galv_Nitem::METHOD == 2 && item
      last_number = item_number(item)
      new_number = last_number + amount
       
      if [[new_number, 0].max, 99].min > last_number
        cat = get_category(item)
        return if cat == :none
        $game_party.nitems[cat][item.id] = true
      end
    end
    galv_nitem_gp_gain_item(item, amount, include_equip)
  end
end # Game_Party < Game_Unit
   
   
class Window_ItemList < Window_Selectable
  include Galv_GetCat
     
  alias galv_nitem_wi_draw_item draw_item
  def draw_item(index)
    galv_nitem_wi_draw_item(index)
    item = @data[index]
    return if item.nil?
       
    cat = get_category(item)
    return if cat == :none
    rect = item_rect(index)
    if Galv_Nitem::METHOD == 1 && !$game_party.nitems[cat][item.id] ||
        Galv_Nitem::METHOD == 2 && $game_party.nitems[cat][item.id]
      draw_item_new(item, rect.x, rect.y)
    end
  end
     
  def draw_item_new(item, x, y)
    bitmap = Cache.system(Galv_Nitem::IMAGE)
    rect = Rect.new(0, 0, 24, 24)
    contents.blt(x, y-6, bitmap, rect, 255)
  end
  
  ################

  ################
end # Window_ItemList < Window_Selectable
   
   
class Window_EquipItem
  # If Yanfly's Equip Engine:
  if $imported["YEA-AceEquipEngine"]
    def draw_item(index)
      item = @data[index]
      rect = item_rect(index)
      rect.width -= 4
      if item.nil?
        draw_remove_equip(rect)
        return
      end
      dw = contents.width - rect.x - 24
      draw_item_name(item, rect.x, rect.y, enable?(item), dw)
      draw_item_number(rect, item)
      cat = get_category(item)
      return if cat == :none
      if !$game_party.nitems[cat][item.id] && Galv_Nitem::METHOD == 1 ||
          $game_party.nitems[cat][item.id] && Galv_Nitem::METHOD == 2
        rect = item_rect(index)
        draw_item_new(item, rect.x, rect.y)
      end
    end
  end
end # Window_EquipItem (For Yanfly's Equip Script)
   
   
class Scene_Base
  def refresh_new
    @item_window.refresh if @item_window
  end
     
#  alias galv_nitem_sb_return_scene return_scene
#  def return_scene
#    clear_new if Galv_Nitem::METHOD == 2
#    galv_nitem_sb_return_scene
#  end
     
#  def clear_new
#    if SceneManager.scene_is?(Scene_Item)
#      $game_party.nitems[:weapon] = []
#      $game_party.nitems[:armor] = []
#      $game_party.nitems[:item] = []
#    end
#  end
end # Scene_Base
   
   
class Game_Actor < Game_Battler
  include Galv_GetCat
     
  # OVERWRITE
  def trade_item_with_party(new_item, old_item)
    return false if new_item && !$game_party.has_item?(new_item)
    $game_party.gain_item(old_item, 1)
    $game_party.lose_item(new_item, 1)
    unequipped_not_new(old_item)
    return true
  end
     
  def unequipped_not_new(item)
    cat = get_category(item)
    return if cat == :none || Galv_Nitem::METHOD == 1
    $game_party.nitems[cat][item.id] = false
  end
end # Game_Actor < Game_Battler
