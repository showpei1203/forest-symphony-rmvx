#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Game_Map
# 【用途】VX 地圖核心，載入 Map rvdata、事件、交通工具、捲動、遠景、通行與更新流程。
# 【主要機制】Map／Event／Fog／Lighting／RandomDungeon 等系統大量依賴此類，屬不可隨意重排的核心。
# 【主要影響】Game_Map
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
# ** Game_Map
#------------------------------------------------------------------------------
#  這個類用來操控地圖，包含了地圖滾動設置和通行度判定等資訊。
#  這個類的實例被全域變數 $game_map 所引用。
#==============================================================================

class Game_Map
  #--------------------------------------------------------------------------
  # * 宣告執行個體變數
  #--------------------------------------------------------------------------
  attr_reader   :screen                   # 地圖畫面狀態
  attr_reader   :interpreter              # 地圖事件直譯器
  attr_reader   :display_x                # 地圖畫面顯示X座標 * 256
  attr_reader   :display_y                # 地圖畫面顯示Y座標 * 256
  attr_reader   :parallax_name            # 遠景圖檔名
  attr_reader   :passages                 # 通行度設定表
  attr_reader   :events                   # 事件
  attr_reader   :vehicles                 # 交通工具
  attr_accessor :need_refresh             # 更新內容資訊需求標幟
  attr_accessor :map                      # 用於辨識地圖的標幟
  #--------------------------------------------------------------------------
  # * 物件初始化
  #--------------------------------------------------------------------------
  def initialize
    @screen = Game_Screen.new
    @interpreter = Game_Interpreter.new(0, true)
    @map_id = 0
    @display_x = 0
    @display_y = 0
    create_vehicles
  end
  #--------------------------------------------------------------------------
  # * 設置
  #     map_id : 地圖編號
  #--------------------------------------------------------------------------
  def setup(map_id)
    @map_id = map_id
    @map = load_data(sprintf("Data/Map%03d.rvdata", @map_id))
    @display_x = 0
    @display_y = 0
    @passages = $data_system.passages
    referesh_vehicles
    setup_events
    setup_scroll
    setup_parallax
    @need_refresh = false
  end
  #--------------------------------------------------------------------------
  # * 創建交通工具
  #--------------------------------------------------------------------------
  def create_vehicles
    @vehicles = []
    @vehicles[0] = Game_Vehicle.new(0)    # 舟
    @vehicles[1] = Game_Vehicle.new(1)    # 船
    @vehicles[2] = Game_Vehicle.new(2)    # 飛艇
  end
  #--------------------------------------------------------------------------
  # * 更新交通工具內容資訊
  #--------------------------------------------------------------------------
  def referesh_vehicles
    for vehicle in @vehicles
      vehicle.refresh
    end
  end
  #--------------------------------------------------------------------------
  # * 登上舟
  #--------------------------------------------------------------------------
  def boat
    return @vehicles[0]
  end
  #--------------------------------------------------------------------------
  # * 登上船
  #--------------------------------------------------------------------------
  def ship
    return @vehicles[1]
  end
  #--------------------------------------------------------------------------
  # * 登上空艇
  #--------------------------------------------------------------------------
  def airship
    return @vehicles[2]
  end
  #--------------------------------------------------------------------------
  # * 事件設置
  #--------------------------------------------------------------------------
  def setup_events
    @events = {}          # 地圖事件
    for i in @map.events.keys
      @events[i] = Game_Event.new(@map_id, @map.events[i])
    end
    @common_events = {}   # 全域事件
    for i in 1...$data_common_events.size
      @common_events[i] = Game_CommonEvent.new(i)
    end
  end
  #--------------------------------------------------------------------------
  # * 滾動設置
  #--------------------------------------------------------------------------
  def setup_scroll
    @scroll_direction = 2
    @scroll_rest = 0
    @scroll_speed = 4
    @margin_x = (width - 17) * 256 / 2      # 畫面未顯示的部分的寬度 /2
    @margin_y = (height - 13) * 256 / 2     # 畫面未顯示的部分的高度 /2
  end
  #--------------------------------------------------------------------------
  # * 遠景設置
  #--------------------------------------------------------------------------
  def setup_parallax
    @parallax_name = @map.parallax_name
    @parallax_loop_x = @map.parallax_loop_x
    @parallax_loop_y = @map.parallax_loop_y
    @parallax_sx = @map.parallax_sx
    @parallax_sy = @map.parallax_sy
    @parallax_x = 0
    @parallax_y = 0
  end
  #--------------------------------------------------------------------------
  # * 設置顯示位置
  #     x : 地圖畫面顯示X座標 (*256)
  #     y : 地圖畫面顯示Y座標 (*256)
  #--------------------------------------------------------------------------
  def set_display_pos(x, y)
    @display_x = (x + @map.width * 256) % (@map.width * 256)
    @display_y = (y + @map.height * 256) % (@map.height * 256)
    @parallax_x = x
    @parallax_y = y
  end
  #--------------------------------------------------------------------------
  # * 計算遠景圖顯示的X座標
  #     bitmap : 遠景圖
  #--------------------------------------------------------------------------
  def calc_parallax_x(bitmap)
    if bitmap == nil
      return 0
    elsif @parallax_loop_x
      return @parallax_x / 16
    elsif loop_horizontal?
      return 0
    else
      w1 = bitmap.width - 544
      w2 = @map.width * 32 - 544
      if w1 <= 0 or w2 <= 0
        return 0
      else
        return @parallax_x * w1 / w2 / 8
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 計算遠景圖顯示的Y座標
  #     bitmap : 遠景圖
  #--------------------------------------------------------------------------
  def calc_parallax_y(bitmap)
    if bitmap == nil
      return 0
    elsif @parallax_loop_y
      return @parallax_y / 16
    elsif loop_vertical?
      return 0
    else
      h1 = bitmap.height - 416
      h2 = @map.height * 32 - 416
      if h1 <= 0 or h2 <= 0
        return 0
      else
        return @parallax_y * h1 / h2 / 8
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 獲取地圖編號資訊
  #--------------------------------------------------------------------------
  def map_id
    return @map_id
  end
  #--------------------------------------------------------------------------
  # * 獲取地圖寬度資訊
  #--------------------------------------------------------------------------
  def width
    return @map.width
  end
  #--------------------------------------------------------------------------
  # * 獲取地圖高度資訊
  #--------------------------------------------------------------------------
  def height
    return @map.height
  end
  #--------------------------------------------------------------------------
  # * 橫向滾動地圖？
  #--------------------------------------------------------------------------
  def loop_horizontal?
    return (@map.scroll_type == 2 or @map.scroll_type == 3)
  end
  #--------------------------------------------------------------------------
  # * 縱向滾動地圖？
  #--------------------------------------------------------------------------
  def loop_vertical?
    return (@map.scroll_type == 1 or @map.scroll_type == 3)
  end
  #--------------------------------------------------------------------------
  # * 獲取地圖是否禁用奔跑的資訊
  #--------------------------------------------------------------------------
  def disable_dash?
    return @map.disable_dashing
  end
  #--------------------------------------------------------------------------
  # * 獲取地雷遇敵隊伍列表資訊
  #--------------------------------------------------------------------------
  def encounter_list
    return @map.encounter_list
  end
  #--------------------------------------------------------------------------
  # * 獲取地雷遇敵剩餘步數資訊
  #--------------------------------------------------------------------------
  def encounter_step
    return @map.encounter_step
  end
  #--------------------------------------------------------------------------
  # * 獲取地圖資料
  #--------------------------------------------------------------------------
  def data
    return @map.data
  end
  #--------------------------------------------------------------------------
  # * 計算X座標並減去地圖畫面顯示座標
  #     x : X座標
  #--------------------------------------------------------------------------
  def adjust_x(x)
    if loop_horizontal? and x < @display_x - @margin_x
      return x - @display_x + @map.width * 256
    else
      return x - @display_x
    end
  end
  #--------------------------------------------------------------------------
  # * 計算y座標並減去地圖畫面顯示座標
  #     y : Y座標
  #--------------------------------------------------------------------------
  def adjust_y(y)
    if loop_vertical? and y < @display_y - @margin_y
      return y - @display_y + @map.height * 256
    else
      return y - @display_y
    end
  end
  #--------------------------------------------------------------------------
  # * 計算迴圈調校後的X座標
  #     x : X座標
  #--------------------------------------------------------------------------
  def round_x(x)
    if loop_horizontal?
      return (x + width) % width
    else
      return x
    end
  end
  #--------------------------------------------------------------------------
  # * 計算迴圈調校後的Y座標
  #     y : Y座標
  #--------------------------------------------------------------------------
  def round_y(y)
    if loop_vertical?
      return (y + height) % height
    else
      return y
    end
  end
  #--------------------------------------------------------------------------
  # * 計算指定方向的一格的X座標
  #     x         : X座標
  #     direction : 方向（下，左，右，上） (2,4,6,8)
  #--------------------------------------------------------------------------
  def x_with_direction(x, direction)
    return round_x(x + (direction == 6 ? 1 : direction == 4 ? -1 : 0))
  end
  #--------------------------------------------------------------------------
  # * 計算指定方向的一格的Y座標
  #     y         : Y座標
  #     direction : 方向（下，左，右，上） (2,4,6,8)
  #--------------------------------------------------------------------------
  def y_with_direction(y, direction)
    return round_y(y + (direction == 2 ? 1 : direction == 8 ? -1 : 0))
  end
  #--------------------------------------------------------------------------
  # * 獲取指定座標所在的事件陣列資訊
  #     x : X座標
  #     y : Y座標
  #--------------------------------------------------------------------------
  def events_xy(x, y)
    result = []
    for event in $game_map.events.values
      result.push(event) if event.pos?(x, y)
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * 自動切換BGM/BGS
  #--------------------------------------------------------------------------
  def autoplay
    @map.bgm.play if @map.autoplay_bgm unless $game_player.in_vehicle?
    @map.bgs.play if @map.autoplay_bgs
  end
  #--------------------------------------------------------------------------
  # * 更新內容資訊
  #--------------------------------------------------------------------------
  def refresh
    if @map_id > 0
      for event in @events.values
        event.refresh
      end
      for common_event in @common_events.values
        common_event.refresh
      end
    end
    @need_refresh = false
  end
  #--------------------------------------------------------------------------
  # * 向下滾動
  #     distance : 滾動距離
  #--------------------------------------------------------------------------
  def scroll_down(distance)
    if loop_vertical?
      @display_y += distance
      @display_y %= @map.height * 256
      @parallax_y += distance
    else
      last_y = @display_y
      @display_y = [@display_y + distance, (height - 13) * 256].min
      @parallax_y += @display_y - last_y
    end
  end
  #--------------------------------------------------------------------------
  # * 向左滾動
  #     distance : 滾動距離
  #--------------------------------------------------------------------------
  def scroll_left(distance)
    if loop_horizontal?
      @display_x += @map.width * 256 - distance
      @display_x %= @map.width * 256
      @parallax_x -= distance
    else
      last_x = @display_x
      @display_x = [@display_x - distance, 0].max
      @parallax_x += @display_x - last_x
    end
  end
  #--------------------------------------------------------------------------
  # * 向右滾動
  #     distance : 滾動距離
  #--------------------------------------------------------------------------
  def scroll_right(distance)
    if loop_horizontal?
      @display_x += distance
      @display_x %= @map.width * 256
      @parallax_x += distance
    else
      last_x = @display_x
      @display_x = [@display_x + distance, (width - 17) * 256].min
      @parallax_x += @display_x - last_x
    end
  end
  #--------------------------------------------------------------------------
  # * 向上滾動
  #     distance : 滾動距離
  #--------------------------------------------------------------------------
  def scroll_up(distance)
    if loop_vertical?
      @display_y += @map.height * 256 - distance
      @display_y %= @map.height * 256
      @parallax_y -= distance
    else
      last_y = @display_y
      @display_y = [@display_y - distance, 0].max
      @parallax_y += @display_y - last_y
    end
  end
  #--------------------------------------------------------------------------
  # * 判定座標合法性
  #     x : X座標
  #     y : Y座標
  #--------------------------------------------------------------------------
  def valid?(x, y)
    return (x >= 0 and x < width and y >= 0 and y < height)
  end
  #--------------------------------------------------------------------------
  # * 判斷通行度
  #     x    : X座標
  #     y    : Y座標
  #     flag : 用於查詢的通行度標幟
  #            (預設0x01，只有在駕駛交通工具的時候才改變)
  #--------------------------------------------------------------------------
  def passable?(x, y, flag = 0x01)
    for event in events_xy(x, y)            # 匹配座標的事件
      next if event.tile_id == 0            # 該事件圖形為空
      next if event.priority_type > 0       # 未被設為[在普通事件下方]
      next if event.through                 # “事件可穿透”屬性
      pass = @passages[event.tile_id]       # 獲取通行度屬性資訊
      next if pass & 0x10 == 0x10           # [☆] : 不影響通行度
      return true if pass & flag == 0x00    # [○] : 可以通行
      return false if pass & flag == flag   # [×] : 不可以通行
    end
    for i in [2, 1, 0]                      # 為了按從上到下的地圖層次順序
      tile_id = @map.data[x, y, i]          # 獲取地圖元件編號資訊
      return false if tile_id == nil        # 獲取地圖元件資訊失敗：不可通行
      pass = @passages[tile_id]             # 獲取通行度屬性資訊
      next if pass & 0x10 == 0x10           # [☆] : 不影響通行度
      return true if pass & flag == 0x00    # [○] : 可以通行
      return false if pass & flag == flag   # [×] : 不可以通行
    end
    return false                            # 不可通行
  end
  #--------------------------------------------------------------------------
  # * 判斷舟航行通行度
  #     x    : X座標
  #     y    : Y座標
  #--------------------------------------------------------------------------
  def boat_passable?(x, y)
    return passable?(x, y, 0x02)
  end
  #--------------------------------------------------------------------------
  # * 判斷船航行通行度
  #     x    : X座標
  #     y    : Y座標
  #--------------------------------------------------------------------------
  def ship_passable?(x, y)
    return passable?(x, y, 0x04)
  end
  #--------------------------------------------------------------------------
  # * 判斷飛艇登陸通行度
  #     x    : X座標
  #     y    : Y座標
  #--------------------------------------------------------------------------
  def airship_land_ok?(x, y)
    return passable?(x, y, 0x08)
  end
  #--------------------------------------------------------------------------
  # * 判斷草木茂密處的通行度
  #     x    : X座標
  #     y    : Y座標
  #--------------------------------------------------------------------------
  def bush?(x, y)
    return false unless valid?(x, y)
    return @passages[@map.data[x, y, 1]] & 0x40 == 0x40
  end
  #--------------------------------------------------------------------------
  # * 判斷具有櫃檯屬性的地圖元件
  #     x    : X座標
  #     y    : Y座標
  #--------------------------------------------------------------------------
  def counter?(x, y)
    return false unless valid?(x, y)
    return @passages[@map.data[x, y, 0]] & 0x80 == 0x80
  end
  #--------------------------------------------------------------------------
  # * 開始滾動地圖視域
  #     direction : 滾動方向
  #     distance  : 滾動距離
  #     speed     : 滾動速度
  #--------------------------------------------------------------------------
  def start_scroll(direction, distance, speed)
    @scroll_direction = direction
    @scroll_rest = distance * 256
    @scroll_speed = speed
  end
  #--------------------------------------------------------------------------
  # * 判定地圖視域是否正在滾動
  #--------------------------------------------------------------------------
  def scrolling?
    return @scroll_rest > 0
  end
  #--------------------------------------------------------------------------
  # * 更新幀
  #--------------------------------------------------------------------------
  def update
    refresh if $game_map.need_refresh
    update_scroll
    update_events
    update_vehicles
    update_parallax
    @screen.update
  end
  #--------------------------------------------------------------------------
  # * 更新地圖視域滾動資訊
  #--------------------------------------------------------------------------
  def update_scroll
    if @scroll_rest > 0                 # 滾動中？
      distance = 2 ** @scroll_speed     # 將轉速轉換為距離
      case @scroll_direction
      when 2  # 向下
        scroll_down(distance)
      when 4  # 向左
        scroll_left(distance)
      when 6  # 向右
        scroll_right(distance)
      when 8  # 向上
        scroll_up(distance)
      end
      @scroll_rest -= distance          # 減掉滾動過的距離
    end
  end
  #--------------------------------------------------------------------------
  # * 更新事件資訊
  #--------------------------------------------------------------------------
  def update_events
    for event in @events.values
      event.update
    end
    for common_event in @common_events.values
      common_event.update
    end
  end
  #--------------------------------------------------------------------------
  # * 更新交通工具資訊
  #--------------------------------------------------------------------------
  def update_vehicles
    for vehicle in @vehicles
      vehicle.update
    end
  end
  #--------------------------------------------------------------------------
  # * 更新遠景圖資訊
  #--------------------------------------------------------------------------
  def update_parallax
    @parallax_x += @parallax_sx * 4 if @parallax_loop_x
    @parallax_y += @parallax_sy * 4 if @parallax_loop_y
  end
end
