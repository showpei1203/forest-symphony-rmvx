#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_Z21_Eventeer_Authority v1.1
# 【用途】Forest Symphony 正式 Authority「FS_Z21_Eventeer_Authority v1.1」，集中管理此功能目前應修改的主要實作。
# 【主要機制】本頁可能由既有 Base／第三方插件一路 Patch 而來；修改時仍需查看 LoadOrder Guide／Authority Map，確認是否還有後載入 wrapper。
# 【主要影響】Game_Event、Game_Interpreter、Game_SelfVariables、Scene_Title、Scene_File、Game_Character、Game_Player
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：BOOL、OFFSET、AREAEVENT。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 8 個 alias／方法包裝，載入順序具有語意；登記 $imported：FS Z21 Self Variable Fix；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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
# PHASE 8 AUTHORITY: FS_Z21_Eventeer_Authority v1.1
# Z21 Eventeer/Self Variable 原系統＋FS Self Variable 正式修正。
# Original load order: 170:Z-Systems-Self Variable -> 171:FS_Z21_SelfVariableFix v1.1
#==============================================================================
# PHASE8 ORIGINAL PAGE: 170 | Z-Systems-Self Variable
#==============================================================================
                            #======================#
                            #  Z-Systems by: Zetu  #
#===========================#======================#===========================#
#                   *  *  *  Z 21 :: Eventeer v1.01  *  *  *                   #
#=#==========================================================================#=#
  #  Version 1.01                                                            #
  #  Scripted Event Conditions                                               #
  #  * (In Event Comment) Place <bool: *> to add a scripted condition to     #
  #    event page.                                                           #
  #  Sprite Offset                                                           #
  #  * (In Event Comment) Place <x/y += *> to add/subtract displayed x/y     #
  #    coordinate of page's sprite.                                          #
  #  Event Area Expander                                                     #
  #  * (In Area Name) Place <event ext: *> to cause event id *'s event       #
  #    trigger (player touch and action button) to be in area, instead of    #
  #    the event's x/y coordinate.                                           #
  #  Self Variable                                                           #
  #  * Now events can have self variables (not just switches).  Use          #
  #    self_var in script call (or (EVENT).self_var) to access an event's    #
  #    self variable.                                                        #
  #==========================================================================#

module Z21
  
  module REGEXP
    BOOL      = /<(?:bool|condition)[ :]*(.*)>/i
    OFFSET    = /<(x|y)[: ]*(.*)>/i
    AREAEVENT = /<event *ext[: ]*(.*)>/
  end
  
end

class Game_Event
  
  alias z21conditions_met? conditions_met? unless $@
  def conditions_met?(page)
    return false unless z21regexp_conditions_met?(page)
    return z21conditions_met?(page)
  end
  
  def z21regexp_conditions_met?(page)
    for line in page.list
      next unless line.code == 108
      line.parameters[0].scan(Z21::REGEXP::BOOL){|condition|
        return false unless eval(condition[0])
      }
    end
    return true
  end
  
end

class Game_Interpreter
  def event
    return $game_map.events[@event_id]
  end
  def self_var
    return event.self_var
  end
end

class Game_Event
  
  def self_var
    return $self_var[@event.id, @map.map_id]
  end
  
  def self_var=(new_value)
    $self_var[@event.id, @map.map_id] = new_value
  end
  
end

class Game_SelfVariables
  
  def initialize
    @data = {}
  end
  
  def [](key)
    return @data[key].nil? ? 0 : @data[key]
  end
  
  def []=(key, value)
    @data[key] = value
  end
  
end

class Scene_Title < Scene_Base
  
  alias z21create_game_objects create_game_objects unless $@
  def create_game_objects
    z21create_game_objects
    $self_var = Game_SelfVariables.new
  end
  
end

class Scene_File < Scene_Base
  
  alias z21write_save_data write_save_data unless $@
  def write_save_data(file)
    z21write_save_data(file)
    Marshal.dump($game_player,         file)
  end
  
  alias z21read_save_data read_save_data
  def read_save_data(file)
    z21read_save_data(file)
    $self_var = Marshal.load(file)
  end
  
end

class Game_Character
  
  alias z21screen_x screen_x unless $@
  def screen_x
    return z21screen_x + z21_offset_x
  end
  
  alias z21screen_y screen_y unless $@
  def screen_y
    return z21screen_y + z21_offset_y
  end
  
  def z21_offset_x
    return 0 unless self.is_a?(Game_Event)
    return z21_offset[0]
  end
  
  def z21_offset_y
    return 0 unless self.is_a?(Game_Event)
    return z21_offset[1]
  end
  
  def z21_offset
    param = [0, 0]
    return param if @page.nil?
    for line in @page.list
      next unless line.code == 108
      line.parameters[0].scan(Z21::REGEXP::OFFSET){|matches|
        for match in matches
          case $1.upcase
          when "X"
            param[0] += $2.to_i
          when "Y"
            param[1] += $2.to_i
          end
        end
      }
    end
    return param
  end
  
end

class Game_Player < Game_Character
  
  alias z21check_event_trigger_touch check_event_trigger_touch unless $@
  def check_event_trigger_touch(x, y)
    if area_bind.size != 0
      return false if $game_map.interpreter.running?
      for id in area_bind
        event = $game_map.events[id]
        next if event.nil?
        event.start
      end
    else
      return z21check_event_trigger_touch(x, y)
    end
  end
  
  alias z21check_event_trigger_here check_event_trigger_here unless $@
  def check_event_trigger_here(triggers)
    if area_bind.size != 0
      return false if $game_map.interpreter.running?
      result = false
      for id in area_bind
        event = $game_map.events[id]
        next if event.nil?
        next unless triggers.include?(event.trigger)
        next if event.priority_type == 1
        event.start
        result = true if event.starting
      end
      return result
    else
      return z21check_event_trigger_here(triggers)
    end
  end
  
  def area_control?(test_id)
    area.name.scan(Z21::REGEXP::AREAEVENT){
      id = $1.to_s
    }
    return id == test_id
  end
  
  def area_bind
    for area in $data_areas.values
      id = area_event_id(area)
      if in_area?(area) and id != 0
        return id
      end
    end
  end
        
  def area_event_id(area)
    result = []
    for area in $data_areas.values
      area.name.scan(Z21::REGEXP::AREAEVENT){
        result.push($1.to_i)
      }
    end
    return result
  end
  
end

#==============================================================================
# PHASE8 ORIGINAL PAGE: 171 | FS_Z21_SelfVariableFix v1.1
#==============================================================================
#==============================================================================
# ■ FS_Z21_SelfVariableFix v1.1
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2
#
# 修正 Z-Systems Eventeer v1.01 的 Self Variable 存取錯誤：
#   $self_var[a, b] = value
# 會被 Ruby 解析成 []=(a, b, value)，但 Game_SelfVariables#[]= 只接受
# (key, value) 兩個參數。
#
# 正確 Key：
#   [event_id, map_id]
#
# 【事件腳本】
#   self.self_var = 123
#   p self.self_var
#
# 【安裝位置】
#   Z-Systems-Self Variable
#   Game_SelfVariables
#   FS_Z21_SelfVariableFix v1.1
#   ...
#   FS_SaveCompatibilityCore
#   Main
#==============================================================================

$imported = {} if $imported == nil
$imported["FS Z21 Self Variable Fix"] = 1.1

class Game_Event
  def self_var
    return 0 if $self_var == nil
    return $self_var[[@id, @map_id]]
  end

  def self_var=(new_value)
    if $self_var == nil && defined?(Game_SelfVariables)
      $self_var = Game_SelfVariables.new
    end
    return new_value if $self_var == nil
    $self_var[[@id, @map_id]] = new_value
    $game_map.need_refresh = true if $game_map != nil
    return new_value
  end
end

class Game_Interpreter
  def self_var
    target = event
    return 0 if target == nil
    return target.self_var
  end

  def self_var=(new_value)
    target = event
    return new_value if target == nil
    target.self_var = new_value
    return new_value
  end
end
