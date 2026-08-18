#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Eventer's Toolbox
# 【用途】地圖／事件元件「Eventer's Toolbox」。
# 【主要機制】擴充 Game_Map／Game_Event／Game_Character／Spriteset_Map 或事件 Script Call。
# 【主要影響】Game_Map
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】含 1 個 alias／方法包裝，載入順序具有語意。
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
#==============================================================================
# ** RMVX Eventer's Toolbox
#------------------------------------------------------------------------------
# * Includes several different utilities to make eventing easier.
# 10-03-2008 (dd-mm-yyyy) © Hevendor of rmxp.org
# Version 0.2.2
# Latest update: N/A
#==============================================================================

#==============================================================================
# * INSTRUCTIONS
# Remember when you had to set player coords, event coords to variables
# just to check where your events were, where rocks were etc.?
# Not anymore! Rock-pushing puzzles? Made easy!
# Use each of these commands wherever you want, though they are designed to use
# in a conditional branch event command. An example follows:
# @>Conditional Branch: $game_map.standing_on_tile?(5, 13)
#     @> Do stuff, will happen if you ARE standing on the coords 5,13
#   Else
#     @> Do the rest of stuff, will happen if you ARE NOT standing on 5,13
#------------------------------------------------------------------------------
# * COMMANDS
# $game_map.standing_on_tile?(x, y)
#   - checks if player is standing on map coordinates (x, y)
#
# $game_map.standing_on_event?(id)
#   - checks if player is standing on event (id)
#
# $game_map.adjacent_tile?(x, y, standing)
#   - checks if player is adjacent to tile (x, y).
#   - if standing = false, it will check only if you are adjacent
#   - if standing = true, it will check if you are adjacent OR standing on tile
#
# $game_map.cross_adjacent_event?(id, n)
#   - checks if player is in a cross range of event ID, where n is the radius
# of the cross. To check if player is adjacent to event, use n=1
#
# $game_map.event_adjacent_event?(id, id2, n)
#   - checks if event (id) is adjacent to event (id2), where n is the radius
# of the cross. To check if the events are directly adjacent, use n=1.
#
# $game_map.event_standing_coords?(id, x, y)
#   - checks if event (id) is standing on map coordinates (x, y).
#==============================================================================

class Game_Map
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :px
  attr_accessor :py
  #--------------------------------------------------------------------------
  # * Alias Definitions
  #--------------------------------------------------------------------------
  alias hev_rmvx_toolbox_initialize initialize
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    hev_rmvx_toolbox_initialize
    @px = 0
    @py = 0
  end
  #--------------------------------------------------------------------------
  # * Player standing on map coords (x, y)?
  #--------------------------------------------------------------------------  
  def standing_on_tile?(x, y)
   if $game_player.x == x and $game_player.y == y
     return true
   else 
     return false
    end
  end
  #--------------------------------------------------------------------------
  # * Player standing on event (id)?
  #--------------------------------------------------------------------------  
  def standing_on_event?(id)
    if $game_player.x == @events[id].x && $game_player.y == @events[id].y
      return true
    else
      return false
    end
  end
  #--------------------------------------------------------------------------
  # * Is player adjacent (or standing on) to tile (x, y)?
  #--------------------------------------------------------------------------  
  def adjacent_tile?(x, y, standing)
     @px = $game_player.x
     @py = $game_player.y
    if standing = false
     if (@px != x && @py != y) || (@px == x && @py == y)
      return false
     end
    end
    if standing = true
     if (@px != x && @py != y)
       return false
     end
    end
    if @px < x 
      if (x - @px) <= 1
        return true
      end
    end
    if @px > x 
      if (@px - x) - @px <= 1
        return true
      end
    end
    if @py > y 
      if (@py - y) <= 1
        return true
      end
    end
    if @py < y
      if (y - @py) <= 1
        return true
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Is player (n) tiles adjacent to event (id) [in a cross pattern]?
  #--------------------------------------------------------------------------  
  def cross_adjacent_event?(id, n)
     @px = $game_player.x
     @py = $game_player.y
    if (@px != @events[id].x && @py != @events[id].y) || (@px == @events[id].x && @py == @events[id].y)
      return false
    end
    if @px < @events[id].x 
      if (@events[id].x - @px) <= n
        return true
      end
    end
    if @px > @events[id].x 
      if (@px - @events[id].x) - @px <= n
        return true
      end
    end
    if @py > @events[id].y 
      if (@py - @events[id].y) <= n
        return true
      end
    end
    if @py < @events[id].y
      if (@events[id].y - @py) <= n
        return true
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Is player (n) tiles adjacent to event (id) in facing direction?
  # included by Xaiko
  #--------------------------------------------------------------------------  
  def facing_adjacent_event?(id, n)
     @px = $game_player.x
     @py = $game_player.y
    if (@px != @events[id].x && @py != @events[id].y) || (@px == @events[id].x && @py == @events[id].y)
      return false
    end
    if @direction == 8
     if @px < @events[id].x 
      if (@events[id].x - @px) <= n
        return true
      end
     end
    elsif @direction == 4
     if @px > @events[id].x 
      if (@px - @events[id].x) - @px <= n
        return true
      end
    end
    elsif @direction == 6
     if @py > @events[id].y 
      if (@py - @events[id].y) <= n
        return true
      end
    end
    elsif @direction == 2
     if @py < @events[id].y
      if (@events[id].y - @py) <= n
        return true
      end
     end
    end
  end
  #--------------------------------------------------------------------------
  # * Is event (id) adjacent to event (id2?)
  #--------------------------------------------------------------------------  
  def event_adjacent_event?(id, id2, n)
    if @events[id].x != @events[id2].x && @events[id].y != @events[id2].y
      return false
    end
    if @events[id].x == @events[id2].x && @events[id].y == @events[id2].y
      return false
    end
    if @events[id].x < @events[id2].x 
      if (@events[id2].x - @events[id].x) <= n
        return true
      end
    end
    if @events[id].x > @events[id2].x 
      if (@events[id].x - @events[id2].x) - @events[id].x <= n
        return true
      end
    end
    if @events[id].y > @events[id2].y 
      if (@events[id].y - @events[id2].y) <= n
        return true
      end
    end
    if @events[id].y < @events[id2].y
      if (@events[id2].y - @events[id].y) <= n
        return true
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Is event (id) standing on map coords. (x, y)?
  #--------------------------------------------------------------------------    
  def event_standing_coords?(id, x, y)
    if @events[id].x == x && @events[id].y == y
      return true
    else
      return false
    end
  end
end