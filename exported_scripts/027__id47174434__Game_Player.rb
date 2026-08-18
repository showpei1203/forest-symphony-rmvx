#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Game_Player
# 【用途】玩家地圖角色，處理輸入移動、遇敵、事件觸發、交通工具與地圖捲動。
# 【主要機制】Scene_Map 與多個地圖插件會擴充此類；移動／事件行為修改後需實機測地圖。
# 【主要影響】Game_Player
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：CENTER_X、CENTER_Y。核心方法除非已確認依賴鏈，不建議直接覆寫。
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
# ** Game_Player
#------------------------------------------------------------------------------
#  這個類用來操控地圖，它所定義的內容包括決定事件執行的條件和地圖視域滾動功能。
#  這個類的實例被全域變數 $game_map 所引用。
#==============================================================================

class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # * 常數
  #--------------------------------------------------------------------------
  CENTER_X = (544 / 2 - 16) * 8     # 螢幕中心X座標 * 8
  CENTER_Y = (416 / 2 - 16) * 8     # 螢幕中心Y座標 * 8
  #--------------------------------------------------------------------------
  # * 宣告執行個體變數
  #--------------------------------------------------------------------------
  attr_reader   :vehicle_type       # 目前正在乘坐的交通工具類型
  #--------------------------------------------------------------------------
  # * 物件初始化
  #--------------------------------------------------------------------------
  def initialize
    super
    @vehicle_type = -1
    @vehicle_getting_on = false     # 判定登上交通工具的標幟
    @vehicle_getting_off = false    # 判定登下交通工具的標幟
    @transferring = false           # 場所移動標幟
    @new_map_id = 0                 # 目標地圖編號
    @new_x = 0                      # 目標地圖X座標
    @new_y = 0                      # 目標地圖Y座標
    @new_direction = 0              # 場所移動後的最終朝向
    @walking_bgm = nil              # 記憶場景BGM
  end
  #--------------------------------------------------------------------------
  # * 判定交通工具是否正在停止運動
  #--------------------------------------------------------------------------
  def stopping?
    return false if @vehicle_getting_on
    return false if @vehicle_getting_off
    return super
  end
  #--------------------------------------------------------------------------
  # * 場所移動設置預定
  #     map_id    : 地圖編號
  #     x         : 地圖X座標
  #     y         : 地圖Y座標
  #     direction : 場所移動後的最終朝向
  #--------------------------------------------------------------------------
  def reserve_transfer(map_id, x, y, direction)
    @transferring = true
    @new_map_id = map_id
    @new_x = x
    @new_y = y
    @new_direction = direction
  end
  #--------------------------------------------------------------------------
  # * 判定場所移動是否被預定設置
  #--------------------------------------------------------------------------
  def transfer?
    return @transferring
  end
  #--------------------------------------------------------------------------
  # * 執行場所移動指令
  #--------------------------------------------------------------------------
  def perform_transfer
    return unless @transferring
    @transferring = false
    set_direction(@new_direction)
    if $game_map.map_id != @new_map_id
      $game_map.setup(@new_map_id)     # 移動到其他地圖
    end
    moveto(@new_x, @new_y)
    @walking_bgm = $game_map.map.bgm
  end
  #--------------------------------------------------------------------------
  # * 判定地圖是否可以通行（總判定）
  #     x : 地圖X座標
  #     y : 地圖Y座標
  #--------------------------------------------------------------------------
  def map_passable?(x, y)
    case @vehicle_type
    when 0  # 舟
      return $game_map.boat_passable?(x, y)
    when 1  # 船
      return $game_map.ship_passable?(x, y)
    when 2  # 飛艇
      return true
    else    # 行走
      return $game_map.passable?(x, y)
    end
  end
  #--------------------------------------------------------------------------
  # * 判定地圖是否可行走
  #     x : 地圖X座標
  #     y : 地圖Y座標
  #--------------------------------------------------------------------------
  def can_walk?(x, y)
    last_vehicle_type = @vehicle_type   # 移除交通工具類型
    @vehicle_type = -1                  # 暫時設置為步行狀態
    result = passable?(x, y)            # 判定通行度
    @vehicle_type = last_vehicle_type   # 還原交通工具類型
    return result
  end
  #--------------------------------------------------------------------------
  # * 判定飛艇是否可著陸
  #     x : 地圖X座標
  #     y : 地圖Y座標
  #--------------------------------------------------------------------------
  def airship_land_ok?(x, y)
    unless $game_map.airship_land_ok?(x, y)
      return false    # 地圖通行度設定為不允許空艇著陸
    end
    unless $game_map.events_xy(x, y).empty?
      return false    # 有事件的地方無法著陸
    end
    return true       # 可以著陸
  end
  #--------------------------------------------------------------------------
  # * 判定是否正在駕駛某種交通工具
  #--------------------------------------------------------------------------
  def in_vehicle?
    return @vehicle_type >= 0
  end
  #--------------------------------------------------------------------------
  # * 判定是否正在駕駛空艇
  #--------------------------------------------------------------------------
  def in_airship?
    return @vehicle_type == 2
  end
  #--------------------------------------------------------------------------
  # * 跑步狀態判定
  #--------------------------------------------------------------------------
  def dash?
    return false if @move_route_forcing
    return false if $game_map.disable_dash?
    return false if in_vehicle?
    return Input.press?(Input::A)
  end
  #--------------------------------------------------------------------------
  # * 判定是否處於DEBUG狀態下無視通行度的狀態
  #--------------------------------------------------------------------------
  def debug_through?
    return false unless $TEST
    return Input.press?(Input::CTRL)
  end
  #--------------------------------------------------------------------------
  # * 將地圖顯示位置設置於螢幕正中央
  #     x : X座標
  #     y : Y座標
  #--------------------------------------------------------------------------
  def center(x, y)
    display_x = x * 256 - CENTER_X                    # 計算座標
    unless $game_map.loop_horizontal?                 # 不橫向迴圈？
      max_x = ($game_map.width - 17) * 256            # 計算最大值
      display_x = [0, [display_x, max_x].min].max     # 座標調校
    end
    display_y = y * 256 - CENTER_Y                    # 計算座標
    unless $game_map.loop_vertical?                   # 不縱向迴圈？
      max_y = ($game_map.height - 13) * 256           # 計算最大值
      display_y = [0, [display_y, max_y].min].max     # 座標調校
    end
    $game_map.set_display_pos(display_x, display_y)   # 調整地圖顯示位置
  end
  #--------------------------------------------------------------------------
  # * 移動至指定位置
  #     x : 地圖X座標
  #     y : 地圖Y座標
  #--------------------------------------------------------------------------
  def moveto(x, y)
    super
    center(x, y)                                      # 居中
    make_encounter_count                              # 初始化地雷遇敵模式
    if in_vehicle?                                    # 乘坐交通工具？
      vehicle = $game_map.vehicles[@vehicle_type]     # 獲取交通工具資訊
      vehicle.refresh                                 # 更新內容資訊
    end
  end
  #--------------------------------------------------------------------------
  # * 增加步數統計值
  #--------------------------------------------------------------------------
  def increase_steps
    super
    return if @move_route_forcing
    return if in_vehicle?
    $game_party.increase_steps
    $game_party.on_player_walk
  end
  #--------------------------------------------------------------------------
  # * 獲取地雷遇敵統計資訊
  #--------------------------------------------------------------------------
  def encounter_count
    return @encounter_count
  end
  #--------------------------------------------------------------------------
  # * 統計地雷遇敵資訊
  #--------------------------------------------------------------------------
  def make_encounter_count
    if $game_map.map_id != 0
      n = $game_map.encounter_step
      @encounter_count = rand(n) + rand(n) + 1  # 譬如擲兩個骰子
    end
  end
  #--------------------------------------------------------------------------
  # * 判定主角是否在雷區（遇敵區域）內
  #     area : 遇敵區域資料(RPG::Area)
  #--------------------------------------------------------------------------
  def in_area?(area)
    return false if area == nil
    return false if $game_map.map_id != area.map_id
    return false if @x < area.rect.x
    return false if @y < area.rect.y
    return false if @x >= area.rect.x + area.rect.width
    return false if @y >= area.rect.y + area.rect.height
    return true
  end
  #--------------------------------------------------------------------------
  # * 創建地雷遇敵隊伍編號
  #--------------------------------------------------------------------------
  def make_encounter_troop_id
    encounter_list = $game_map.encounter_list.clone
    for area in $data_areas.values
      encounter_list += area.encounter_list if in_area?(area)
    end
    if encounter_list.empty?
      make_encounter_count
      return 0
    end
    return encounter_list[rand(encounter_list.size)]
  end
  #--------------------------------------------------------------------------
  # * 更新內容資訊
  #--------------------------------------------------------------------------
  def refresh
    if $game_party.members.size == 0
      @character_name = ""
      @character_index = 0
    else
      actor = $game_party.members[0]   # 獲取領隊主角資訊
      @character_name = actor.character_name
      @character_index = actor.character_index
    end
  end
  #--------------------------------------------------------------------------
  # * 判定與主角處於相同位置的事件是否被觸發
  #     triggers : 觸發陣列
  #--------------------------------------------------------------------------
  def check_event_trigger_here(triggers)
    return false if $game_map.interpreter.running?
    result = false
    for event in $game_map.events_xy(@x, @y)
      if triggers.include?(event.trigger) and event.priority_type != 1
        event.start
        result = true if event.starting
      end
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * 判定正面的事件是否被觸發
  #     triggers : 觸發陣列
  #--------------------------------------------------------------------------
  def check_event_trigger_there(triggers)
    return false if $game_map.interpreter.running?
    result = false
    front_x = $game_map.x_with_direction(@x, @direction)
    front_y = $game_map.y_with_direction(@y, @direction)
    for event in $game_map.events_xy(front_x, front_y)
      if triggers.include?(event.trigger) and event.priority_type == 1
        event.start
        result = true
      end
    end
    if result == false and $game_map.counter?(front_x, front_y)
      front_x = $game_map.x_with_direction(front_x, @direction)
      front_y = $game_map.y_with_direction(front_y, @direction)
      for event in $game_map.events_xy(front_x, front_y)
        if triggers.include?(event.trigger) and event.priority_type == 1
          event.start
          result = true
        end
      end
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * 判定一觸即發的事件是否被觸發
  #     x : 地圖X座標
  #     y : 地圖Y座標
  #--------------------------------------------------------------------------
  def check_event_trigger_touch(x, y)
    x -=  $game_map.width if $game_map.loop_horizontal? and x == $game_map.width
    y -=  $game_map.height if $game_map.loop_vertical? and y == $game_map.height
    return false if $game_map.interpreter.running?
    result = false
    for event in $game_map.events_xy(x, y)
      if [1,2].include?(event.trigger) and event.priority_type == 1
        event.start
        result = true
      end
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * 通過方向鍵輸入資訊來處理主角移動
  #--------------------------------------------------------------------------
  def move_by_input
    return unless movable?
    return if $game_map.interpreter.running?
    case Input.dir4
    when 2;  move_down
    when 4;  move_left
    when 6;  move_right
    when 8;  move_up
    end
  end
  #--------------------------------------------------------------------------
  # * 判定通行度
  #--------------------------------------------------------------------------
  def movable?
    return false if moving?                     # 移動中？
    return false if @move_route_forcing         # 受移動軌跡指令控制？
    return false if @vehicle_getting_on         # 正在登上交通工具？
    return false if @vehicle_getting_off        # 正在登下交通工具？
    return false if $game_message.visible       # 正在顯示文本訊息？
    return false if in_airship? and not $game_map.airship.movable?
    return true
  end
  #--------------------------------------------------------------------------
  # * 更新幀
  #--------------------------------------------------------------------------
  def update
    last_real_x = @real_x
    last_real_y = @real_y
    last_moving = moving?
    move_by_input
    super
    update_scroll(last_real_x, last_real_y)
    update_vehicle
    update_nonmoving(last_moving)
  end
  #--------------------------------------------------------------------------
  # * 更新視域移動內容資訊
  #--------------------------------------------------------------------------
  def update_scroll(last_real_x, last_real_y)
    ax1 = $game_map.adjust_x(last_real_x)
    ay1 = $game_map.adjust_y(last_real_y)
    ax2 = $game_map.adjust_x(@real_x)
    ay2 = $game_map.adjust_y(@real_y)
    if ay2 > ay1 and ay2 > CENTER_Y
      $game_map.scroll_down(ay2 - ay1)
    end
    if ax2 < ax1 and ax2 < CENTER_X
      $game_map.scroll_left(ax1 - ax2)
    end
    if ax2 > ax1 and ax2 > CENTER_X
      $game_map.scroll_right(ax2 - ax1)
    end
    if ay2 < ay1 and ay2 < CENTER_Y
      $game_map.scroll_up(ay1 - ay2)
    end
  end
  #--------------------------------------------------------------------------
  # * 更新交通工具資訊
  #--------------------------------------------------------------------------
  def update_vehicle
    return unless in_vehicle?
    vehicle = $game_map.vehicles[@vehicle_type]
    if @vehicle_getting_on                    # 正在登上交通工具？
      if not moving?
        @direction = vehicle.direction        # 調整方向
        @move_speed = vehicle.speed           # 調整移動速度
        @vehicle_getting_on = false           # 完成登上交通工具的操作
        @transparent = true                   # 主角步行圖透明化處理
      end
    elsif @vehicle_getting_off                # 正在登下交通工具？
      if not moving? and vehicle.altitude == 0
        @vehicle_getting_off = false          # 完成登上交通工具的操作
        @vehicle_type = -1                    # 當前所乘交通工具值清零
        @transparent = false                  # 取消主角步行圖透明化處理
      end
    else                                      # 正在駕駛交通工具？
      vehicle.sync_with_player                # 與主角同時同方向移動
    end
  end
  #--------------------------------------------------------------------------
  # * 未移動時的處理
  #     last_moving : 事先移動了麼？
  #--------------------------------------------------------------------------
  def update_nonmoving(last_moving)
    return if $game_map.interpreter.running?
    return if moving?
    return if check_touch_event if last_moving
    if not $game_message.visible and Input.trigger?(Input::C)
      return if get_on_off_vehicle
      return if check_action_event
    end
    update_encounter if last_moving
  end
  #--------------------------------------------------------------------------
  # * 更新地雷遇敵倒數步數資訊
  #--------------------------------------------------------------------------
  def update_encounter
    return if $TEST and Input.press?(Input::CTRL)   # 測試遊戲中按下Ctrl鍵？
    return if in_vehicle?                           # 正在駕駛交通工具？
    if $game_map.bush?(@x, @y)                      # 在草木茂密處？
      @encounter_count -= 2                         # 倒數步數-2
    else                                            # 不在草木茂密處？
      @encounter_count -= 1                         # 倒數步數-1
    end
  end
  #--------------------------------------------------------------------------
  # * 判定一觸即發的事件 (重疊判定)
  #--------------------------------------------------------------------------
  def check_touch_event
    return false if in_airship?
    return check_event_trigger_here([1,2])
  end
  #--------------------------------------------------------------------------
  # * 判定按下[確定]鍵觸發的事件
  #--------------------------------------------------------------------------
  def check_action_event
    return false if in_airship?
    return true if check_event_trigger_here([0])
    return check_event_trigger_there([0,1,2])
  end
  #--------------------------------------------------------------------------
  # * 登上/登下交通工具
  #--------------------------------------------------------------------------
  def get_on_off_vehicle
    return false unless movable?
    if in_vehicle?
      return get_off_vehicle
    else
      return get_on_vehicle
    end
  end
  #--------------------------------------------------------------------------
  # * 登上交通工具
  #    假使條件：當前主角未在駕駛交通工具
  #--------------------------------------------------------------------------
  def get_on_vehicle
    front_x = $game_map.x_with_direction(@x, @direction)
    front_y = $game_map.y_with_direction(@y, @direction)
    if $game_map.airship.pos?(@x, @y)       # 與飛艇座標重疊？
      get_on_airship
      return true
    elsif $game_map.ship.pos?(front_x, front_y)   # 主角前面有舟？
      get_on_ship
      return true
    elsif $game_map.boat.pos?(front_x, front_y)   # 主角前面有船？
      get_on_boat
      return true
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * 登上舟
  #--------------------------------------------------------------------------
  def get_on_boat
    @vehicle_getting_on = true        # 正在登上交通工具的標幟
    @vehicle_type = 0                 # 設置交通工具種類
    force_move_forward                # 主角前進一步
    @walking_bgm = RPG::BGM::last     # 記憶場景BGM
    $game_map.boat.get_on             # 處理登上交通工具的進程
  end
  #--------------------------------------------------------------------------
  # * 登上船
  #--------------------------------------------------------------------------
  def get_on_ship
    @vehicle_getting_on = true        # 正在登上交通工具的標幟
    @vehicle_type = 1                 # 設置交通工具種類
    force_move_forward                # 主角前進一步
    @walking_bgm = RPG::BGM::last     # 記憶場景BGM
    $game_map.ship.get_on             # 處理登上交通工具的進程
  end
  #--------------------------------------------------------------------------
  # * 登上飛艇
  #--------------------------------------------------------------------------
  def get_on_airship
    @vehicle_getting_on = true        # 開始登上飛艇的操作標幟
    @vehicle_type = 2                 # 設置交通工具種類
    @through = true                   # 啟用通行度開放狀態
    @walking_bgm = RPG::BGM::last     # 記憶場景BGM
    $game_map.airship.get_on          # 處理登上交通工具的進程
  end
  #--------------------------------------------------------------------------
  # * 登下交通工具
  #    假使條件：當前主角正在駕駛交通工具
  #--------------------------------------------------------------------------
  def get_off_vehicle
    if in_airship?                                # 飛艇？
      return unless airship_land_ok?(@x, @y)      # 不能著陸？
    else                                          # 舟/船？
      front_x = $game_map.x_with_direction(@x, @direction)
      front_y = $game_map.y_with_direction(@y, @direction)
      return unless can_walk?(front_x, front_y)   # 不能登陸？
    end
    $game_map.vehicles[@vehicle_type].get_off     # 處理登下交通工具的進程
    if in_airship?                                # 飛艇？
      @direction = 2                              # 方向朝下
    else                                          # 舟/船？
      force_move_forward                          # 前進一步
      @transparent = false                        # 取消主角步行圖透明化處理
    end
    #$game_switches[203] = true
    @vehicle_getting_off = true                 # 開始登下交通工具的操作標幟
    @move_speed = 4                             # 還原主角移動速度
    @through = false                            # 禁用通行度開放狀態
    @walking_bgm.play                           # 還原場景BGM
    make_encounter_count                        # 初始化地雷遇敵資訊
  end
  #--------------------------------------------------------------------------
  # * 強制前進一步
  #--------------------------------------------------------------------------
  def force_move_forward
    @through = true         # 啟用通行度開放狀態
    move_forward            # 前進一步
    @through = false        # 禁用通行度開放狀態
  end
end
