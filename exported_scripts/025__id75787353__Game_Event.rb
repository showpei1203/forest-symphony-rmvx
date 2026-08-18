#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Game_Event
# 【用途】地圖事件 Runtime，管理事件頁條件、觸發、移動設定與並行 Interpreter。
# 【主要機制】依開關／變數／獨立開關／物品／角色條件切換事件頁；地圖事件插件大量依賴此類。
# 【主要影響】Game_Event
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
#==============================================================================
# ** Game_Event
#------------------------------------------------------------------------------
#  這個類專門用來處理事件的事件執行部分，
#  它所控制的功能包括並行處理的事件的執行以及事件頁切換所借由的決定條件。
#  這個類作為 Game_Map 類的內部類使用。
#==============================================================================

class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # * 宣告執行個體變數
  #--------------------------------------------------------------------------
  attr_reader   :trigger                  # 觸發方式
  attr_reader   :list                     # 待執行的指令
  attr_reader   :starting                 # 判定開始執行的標幟
  #--------------------------------------------------------------------------
  # * 物件初始化
  #     map_id : 地圖編號
  #     event  : 地圖事件快(RPG::Event)
  #--------------------------------------------------------------------------
  def initialize(map_id, event)
    super()
    @map_id = map_id
    @event = event
    @id = @event.id
    @erased = false
    @starting = false
    @through = true
    moveto(@event.x, @event.y)            # 移動至初始位置
    refresh
  end
  #--------------------------------------------------------------------------
  # * 將判定開始執行的標幟清零
  #--------------------------------------------------------------------------
  def clear_starting
    @starting = false
  end
  #--------------------------------------------------------------------------
  # * 開始執行事件內容
  #--------------------------------------------------------------------------
  def start
    return if @list.size <= 1                   # 待執行的內容為空？
    @starting = true
    lock if @trigger < 3
    unless $game_map.interpreter.running?
      $game_map.interpreter.setup_starting_event
    end
  end
  #--------------------------------------------------------------------------
  # * 暫時刪除本事件
  #--------------------------------------------------------------------------
  def erase
    @erased = true
    refresh
  end
  #--------------------------------------------------------------------------
  # * 判定事件頁的條件是否被滿足
  #--------------------------------------------------------------------------
  def conditions_met?(page)
    c = page.condition
    if c.switch1_valid      # 開關 1
      return false if $game_switches[c.switch1_id] == false
    end
    if c.switch2_valid      # 開關 2
      return false if $game_switches[c.switch2_id] == false
    end
    if c.variable_valid     # 系統變數
      return false if $game_variables[c.variable_id] < c.variable_value
    end
    if c.self_switch_valid  # 獨立開關
      key = [@map_id, @event.id, c.self_switch_ch]
      return false if $game_self_switches[key] != true
    end
    if c.item_valid         # 指定物品是否擁有
      item = $data_items[c.item_id]
      return false if $game_party.item_number(item) == 0
    end
    if c.actor_valid        # 指定主角是否在隊
      actor = $game_actors[c.actor_id]
      return false unless $game_party.members.include?(actor)
    end
    return true   # 條件被滿足
  end
  #--------------------------------------------------------------------------
  # * 設置事件頁
  #--------------------------------------------------------------------------
  def setup(new_page)
    @page = new_page
    if @page == nil
      @tile_id = 0
      @character_name = ""
      @character_index = 0
      @move_type = 0
      @through = true
      @trigger = nil
      @list = nil
      @interpreter = nil
    else
      @tile_id = @page.graphic.tile_id
      @character_name = @page.graphic.character_name
      @character_index = @page.graphic.character_index
      if @original_direction != @page.graphic.direction
        @direction = @page.graphic.direction
        @original_direction = @direction
        @prelock_direction = 0
      end
      if @original_pattern != @page.graphic.pattern
        @pattern = @page.graphic.pattern
        @original_pattern = @pattern
      end
      @move_type = @page.move_type
      @move_speed = @page.move_speed
      @move_frequency = @page.move_frequency
      @move_route = @page.move_route
      @move_route_index = 0
      @move_route_forcing = false
      @walk_anime = @page.walk_anime
      @step_anime = @page.step_anime
      @direction_fix = @page.direction_fix
      @through = @page.through
      @priority_type = @page.priority_type
      @trigger = @page.trigger
      @list = @page.list
      @interpreter = nil
      if @trigger == 4                       # 事件觸發方式為[隨行處理]？
        @interpreter = Game_Interpreter.new  # 隨行處理
      end
    end
    update_bush_depth
  end
  #--------------------------------------------------------------------------
  # * 更新內容資訊
  #--------------------------------------------------------------------------
  def refresh
    new_page = nil
    unless @erased                          # 事件沒有被暫時刪除
      for page in @event.pages.reverse      # 從編號最大的事件頁開始
        next unless conditions_met?(page)   # 判定條件是否被滿足
        new_page = page
        break
      end
    end
    if new_page != @page            # 事件頁被改變？
      clear_starting                # 將判定開始執行的標幟清零
      setup(new_page)               # 設置事件頁
      check_event_trigger_auto      # 檢查自動觸發的事件
    end
  end
  #--------------------------------------------------------------------------
  # * 判定借由主角或事件觸發的事件的內容是否被觸發
  #--------------------------------------------------------------------------
  def check_event_trigger_touch(x, y)
    return if $game_map.interpreter.running?
    if @trigger == 2 and $game_player.pos?(x, y)
      start if not jumping? and @priority_type == 1
    end
  end
  #--------------------------------------------------------------------------
  # * 判定自動觸發的事件內容是否被觸發
  #--------------------------------------------------------------------------
  def check_event_trigger_auto
    start if @trigger == 3
  end
  #--------------------------------------------------------------------------
  # * 更新幀
  #--------------------------------------------------------------------------
  def update
    super
    check_event_trigger_auto                    # 檢查自動觸發的事件
    if @interpreter != nil                      # 非隨行處理？
      unless @interpreter.running?              # 尚未執行？
        @interpreter.setup(@list, @event.id)    # 設置之
      end
      @interpreter.update                       # 更新直譯器
    end
  end
end
