#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：呼叫事件（跨地圖）
# 【用途】地圖／事件元件「呼叫事件（跨地圖）」。
# 【主要機制】擴充 Game_Map／Game_Event／Game_Character／Spriteset_Map 或事件 Script Call。
# 【主要影響】Game_Event、Game_Interpreter
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】保持目前已驗證的相對順序；搬動前先反查 class reopen／alias／事件入口。
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
#============================================================
# ? [VX] ? Call Event ?
# * Missing features from RM2K
#------------------------------------------------------------
# ? by Woratana [woratana@hotmail.com]
# ? Thaiware RPG Maker Community
# ? Released Date: 04/05/2008
#------------------------------------------------------------
=begin

+[How to use: Version 2]+
=========================================================================
>> Call event from other map by call script:
  
callev(event id, page you want, map ID)
------------------------------------------------------------------------
e.g. callev(5,2,1)
^ to call event commands list from 'page 2' of 'event ID 5' in Map ID '1'
------------------------------------------------------------------------
>> Call event in current map by call script:
  
callev(event id, page you want)
------------------------------------------------------------------------
>> If you want to call event in current page that it's running,
set 'page you want' to 0
------------------------------------------------------------------------
*Note: You CANNOT call erased event!
========================================================================
=end
#------------------------------------------------------------

# Make variable 'event' readable from outside
class Game_Event; attr_reader :event; end
class Game_Interpreter
  def callev(evid = 0,page = 0, id_map = $game_map.map_id)
    return if evid == 0
    if id_map != $game_map.map_id
      # Load new map data if event is not from current map
      dest_map = load_data(sprintf("Data/Map%03d.rvdata", id_map))
      if page == 0
        # Get first page if user haven't set page
        inter_event = dest_map.events[evid].pages[0]
      else
        inter_event = dest_map.events[evid].pages[page - 1]
      end
    else
      # Use $game_map if event is in current map
      if page == 0
        inter_event = $game_map.events[evid]
      else
        inter_event = $game_map.events[evid].event.pages[page - 1]
      end
    end
    # Add new child_interpreter to run commands
    @child_interpreter = Game_Interpreter.new(@depth + 1)
    # Add commands from target event
    @child_interpreter.setup(inter_event.list, @event_id)
  end
end