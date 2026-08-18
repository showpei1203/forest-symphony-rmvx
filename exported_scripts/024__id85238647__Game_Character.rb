#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Game_Character
# 【用途】地圖角色／事件／玩家移動核心，管理座標、方向、移動路線、跳躍與碰撞。
# 【主要機制】Game_Player、Game_Event、Game_Vehicle 等以它為基礎；事件移動擴充通常會重開啟此類。
# 【主要影響】Game_Character
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
# ** Game_Character
#------------------------------------------------------------------------------
#  這個類專門用來操控人物。
#  這個類作為 Game_Player 類和 Game_Event 類的父類使用。
#==============================================================================

class Game_Character
  #--------------------------------------------------------------------------
  # * 宣告執行個體變數
  #--------------------------------------------------------------------------
  attr_reader   :id                       # 編號
  attr_reader   :x                        # 地圖邏輯X座標
  attr_reader   :y                        # 地圖邏輯Y座標
  attr_reader   :real_x                   # 地圖X座標 (真實x值 * 256)
  attr_reader   :real_y                   # 地圖Y座標 (真實y值 * 256)
  attr_reader   :tile_id                  # 地圖元件ID (若為0則為非法值)
  attr_reader   :character_name           # 人物特徵圖圖檔名
  attr_reader   :character_index          # 人物特徵圖編號
  attr_reader   :opacity                  # 不透明度
  attr_reader   :blend_type               # 填充方式
  attr_reader   :direction                # 朝向
  attr_reader   :pattern                  # 模式
  attr_reader   :move_route_forcing       # 受制於移動軌跡指令的標幟
  attr_reader   :priority_type            # 優先順序類型
  attr_reader   :through                  # 事件可穿透
  attr_reader   :bush_depth               # 草木茂密度
  attr_accessor :animation_id             # 動畫編號
  attr_accessor :balloon_id               # 浮動圖示編號
  attr_accessor :transparent              # 主角人物特徵圖透明化標幟
  #--------------------------------------------------------------------------
  # * 物件初始化
  #--------------------------------------------------------------------------
  def initialize
    @id = 0
    @x = 0
    @y = 0
    @real_x = 0
    @real_y = 0
    @tile_id = 0
    @character_name = ""
    @character_index = 0
    @opacity = 255
    @blend_type = 0
    @direction = 2
    @pattern = 1
    @move_route_forcing = false
    @priority_type = 1
    @through = false
    @bush_depth = 0
    @animation_id = 0
    @balloon_id = 0
    @transparent = false
    @original_direction = 2               # 原始朝向
    @original_pattern = 1                 # 原始模式
    @move_type = 0                        # 自主移動的類型
    @move_speed = 4                       # 自主移動的速度
    @move_frequency = 6                   # 自主移動的頻率
    @move_route = nil                     # 移動軌跡
    @move_route_index = 0                 # 移動軌跡編號
    @original_move_route = nil            # 原始移動軌跡
    @original_move_route_index = 0        # 原始移動軌跡編號
    @walk_anime = true                    # 步行動畫
    @step_anime = false                   # 踏步動畫
    @direction_fix = false                # 方向鎖定
    @anime_count = 0                      # 動畫時長累計
    @stop_count = 0                       # 停步耗時累計
    @jump_count = 0                       # 跳躍耗時累計
    @jump_peak = 0                        # 跳躍頂點耗時累計
    @wait_count = 0                       # 等待時長累計
    @locked = false                       # 鎖定標幟
    @prelock_direction = 0                # 鎖定前的朝向
    @move_failed = false                  # 移動失敗標幟
  end
  #--------------------------------------------------------------------------
  # * 判定是否正在移動
  #    與邏輯座標相比較
  #--------------------------------------------------------------------------
  def moving?
    return (@real_x != @x * 256 or @real_y != @y * 256)
  end
  #--------------------------------------------------------------------------
  # * 判定是否正在跳躍
  #--------------------------------------------------------------------------
  def jumping?
    return @jump_count > 0
  end
  #--------------------------------------------------------------------------
  # * 判斷是否正在停步
  #--------------------------------------------------------------------------
  def stopping?
    return (not (moving? or jumping?))
  end
  #--------------------------------------------------------------------------
  # * 判定是否正在奔跑
  #--------------------------------------------------------------------------
  def dash?
    return false
  end
  #--------------------------------------------------------------------------
  # * 判定是否處於按下CTRL鍵後無視通行度的狀態[僅DEBUG模式]
  #--------------------------------------------------------------------------
  def debug_through?
    return false
  end
  #--------------------------------------------------------------------------
  # * 矯正姿勢
  #--------------------------------------------------------------------------
  def straighten
    @pattern = 1 if @walk_anime or @step_anime
    @anime_count = 0
  end
  #--------------------------------------------------------------------------
  # * 強制移動軌跡
  #     move_route : 新的移動軌跡
  #--------------------------------------------------------------------------
  def force_move_route(move_route)
    if @original_move_route == nil
      @original_move_route = @move_route
      @original_move_route_index = @move_route_index
    end
    @move_route = move_route
    @move_route_index = 0
    @move_route_forcing = true
    @prelock_direction = 0
    @wait_count = 0
    move_type_custom
  end
  #--------------------------------------------------------------------------
  # * 判定座標是否匹配
  #     x : X座標
  #     y : Y座標
  #--------------------------------------------------------------------------
  def pos?(x, y)
    return (@x == x and @y == y)
  end
  #--------------------------------------------------------------------------
  # * 判定座標是否匹配、判定“關閉"事件可穿透"” (nt = 不穿透)
  #     x : X座標
  #     y : Y座標
  #--------------------------------------------------------------------------
  def pos_nt?(x, y)
    return (pos?(x, y) and not @through)
  end
  #--------------------------------------------------------------------------
  # * 判定通行度
  #     x : X座標
  #     y : Y座標
  #--------------------------------------------------------------------------
  def passable?(x, y)
    x = $game_map.round_x(x)                        # 橫向迴圈調校
    y = $game_map.round_y(y)                        # 縱向迴圈調校
    return false unless $game_map.valid?(x, y)      # 在地圖範圍外？
    return true if @through or debug_through?       # 開啟"事件可穿透"？
    return false unless map_passable?(x, y)         # 地圖不可通行？
    return false if collide_with_characters?(x, y)  # 與其它事件相衝突？
    return true                                     # 可以通行
  end
  #--------------------------------------------------------------------------
  # * 判定地圖是否可以通行
  #     x : X座標
  #     y : Y座標
  #    獲取指定座標的地圖元件的通行度資訊。
  #--------------------------------------------------------------------------
  def map_passable?(x, y)
    return $game_map.passable?(x, y)
  end
  #--------------------------------------------------------------------------
  # * 判定人物是否相衝突
  #     x : X座標
  #     y : Y座標
  #    檢測普通人物衝突情況，包括主角和交通工具。
  #--------------------------------------------------------------------------
  def collide_with_characters?(x, y)
    for event in $game_map.events_xy(x, y)          # 匹配事件的方位
      unless event.through                          # 關閉"事件可穿透"？
        return true if self.is_a?(Game_Event)       # 自己就是個事件
        return true if event.priority_type == 1     # 目標是普通事件
      end
    end
    if @priority_type == 1                          # 自己就是個事件
      return true if $game_player.pos_nt?(x, y)     # 匹配主角的方位
      return true if $game_map.boat.pos_nt?(x, y)   # 匹配舟的方位
      return true if $game_map.ship.pos_nt?(x, y)   # 匹配船的方位
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * 鎖定 (停止正在執行的事件內容)
  #--------------------------------------------------------------------------
  def lock
    unless @locked
      @prelock_direction = @direction
      turn_toward_player
      @locked = true
    end
  end
  #--------------------------------------------------------------------------
  # * 解鎖
  #--------------------------------------------------------------------------
  def unlock
    if @locked
      @locked = false
      set_direction(@prelock_direction)
    end
  end
  #--------------------------------------------------------------------------
  # * 移動到指定方位
  #     x : X座標
  #     y : Y座標
  #--------------------------------------------------------------------------
  def moveto(x, y)
    @x = x % $game_map.width
    @y = y % $game_map.height
    @real_x = @x * 256
    @real_y = @y * 256
    @prelock_direction = 0
    straighten
    update_bush_depth
  end
  #--------------------------------------------------------------------------
  # * 更改方向為指定的方向
  #     direction : 方向
  #--------------------------------------------------------------------------
  def set_direction(direction)
    if not @direction_fix and direction != 0
      @direction = direction
      @stop_count = 0
    end
  end
  #--------------------------------------------------------------------------
  # * 判定物件類型
  #--------------------------------------------------------------------------
  def object?
    return (@tile_id > 0 or @character_name[0, 1] == '!')
  end
  #--------------------------------------------------------------------------
  # * 獲取畫面X座標資訊
  #--------------------------------------------------------------------------
  def screen_x
    return ($game_map.adjust_x(@real_x) + 8007) / 8 - 1000 + 16
  end
  #--------------------------------------------------------------------------
  # * 獲取畫面Y座標資訊
  #--------------------------------------------------------------------------
  def screen_y
    y = ($game_map.adjust_y(@real_y) + 8007) / 8 - 1000 + 32
    y -= 4 unless object?
    if @jump_count >= @jump_peak
      n = @jump_count - @jump_peak
    else
      n = @jump_peak - @jump_count
    end
    return y - (@jump_peak * @jump_peak - n * n) / 2
  end
  #--------------------------------------------------------------------------
  # * 獲取畫面Z座標資訊
  #--------------------------------------------------------------------------
  def screen_z
    if @priority_type == 2
      return 200
    elsif @priority_type == 0
      return 60
    elsif @tile_id > 0
      pass = $game_map.passages[@tile_id]
      if pass & 0x10 == 0x10    # [☆]
        return 160
      else
        return 40
      end
    else
      return 100
    end
  end
  #--------------------------------------------------------------------------
  # * 更新幀
  #--------------------------------------------------------------------------
  def update
    if jumping?                 # 跳躍中
      update_jump
    elsif moving?               # 移動中
      update_move
    else                        # 處於停止狀態
      update_stop
    end
    if @wait_count > 0          # 等待中
      @wait_count -= 1
    elsif @move_route_forcing   # 受制於移動軌跡中
      move_type_custom
    elsif not @locked           # 未解鎖
      update_self_movement
    end
    update_animation
  end
  #--------------------------------------------------------------------------
  # * 更新物件跳躍時的內容資訊
  #--------------------------------------------------------------------------
  def update_jump
    @jump_count -= 1
    @real_x = (@real_x * @jump_count + @x * 256) / (@jump_count + 1)
    @real_y = (@real_y * @jump_count + @y * 256) / (@jump_count + 1)
    update_bush_depth
  end
  #--------------------------------------------------------------------------
  # * 更新物件移動時的內容資訊
  #--------------------------------------------------------------------------
  def update_move
    distance = 2 ** @move_speed   # 換算成移動距離
    distance *= 2 if dash?        # 如果處於奔跑狀態則其值翻倍
    @real_x = [@real_x - distance, @x * 256].max if @x * 256 < @real_x
    @real_x = [@real_x + distance, @x * 256].min if @x * 256 > @real_x
    @real_y = [@real_y - distance, @y * 256].max if @y * 256 < @real_y
    @real_y = [@real_y + distance, @y * 256].min if @y * 256 > @real_y
    update_bush_depth unless moving?
    if @walk_anime
      @anime_count += 1.5
    elsif @step_anime
      @anime_count += 1
    end
  end
  #--------------------------------------------------------------------------
  # * 更新物件處於停止狀態時的內容資訊
  #--------------------------------------------------------------------------
  def update_stop
    if @step_anime
      @anime_count += 1
    elsif @pattern != @original_pattern
      @anime_count += 1.5
    end
    @stop_count += 1 unless @locked
  end
  #--------------------------------------------------------------------------
  # * 更新物件處於受制于移動軌跡時的內容資訊
  #--------------------------------------------------------------------------
  def update_self_movement
    if @stop_count > 30 * (5 - @move_frequency)
      case @move_type
      when 1;  move_type_random
      when 2;  move_type_toward_player
      when 3;  move_type_custom
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 更新動畫時長資訊
  #--------------------------------------------------------------------------
  def update_animation
    speed = @move_speed + (dash? ? 1 : 0)
    if @anime_count > 18 - speed * 2
      if not @step_anime and @stop_count > 0
        @pattern = @original_pattern
      else
        @pattern = (@pattern + 1) % 4
      end
      @anime_count = 0
    end
  end
  #--------------------------------------------------------------------------
  # * 更新草木茂密度資訊
  #--------------------------------------------------------------------------
  def update_bush_depth
    if object? or @priority_type != 1 or @jump_count > 0
      @bush_depth = 0
    else
      bush = $game_map.bush?(@x, @y)
      if bush and not moving?
        @bush_depth = 8
      elsif not bush
        @bush_depth = 0
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 移動類型：隨機移動
  #--------------------------------------------------------------------------
  def move_type_random
    case rand(6)
    when 0..1;  move_random
    when 2..4;  move_forward
    when 5;     @stop_count = 0
    end
  end
  #--------------------------------------------------------------------------
  # * 移動類型：接近主角
  #--------------------------------------------------------------------------
  def move_type_toward_player
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    if sx.abs + sy.abs >= 20
      move_random
    else
      case rand(6)
      when 0..3;  move_toward_player
      when 4;     move_random
      when 5;     move_forward
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 移動類型：自訂
  #--------------------------------------------------------------------------
  def move_type_custom
    if stopping?
      command = @move_route.list[@move_route_index]   # 獲取移動指令資訊
      @move_failed = false
      if command.code == 0                            # 指令清單末端
        if @move_route.repeat                         # [重複執行]
          @move_route_index = 0
        elsif @move_route_forcing                     # 受制於移動軌跡中
          @move_route_forcing = false                 # 取消移動軌跡
          @move_route = @original_move_route          # 還原移動軌跡編號
          @move_route_index = @original_move_route_index
          @original_move_route = nil
        end
      else
        case command.code
        when 1    # 向下移動
          move_down
        when 2    # 向左移動
          move_left
        when 3    # 向右移動
          move_right
        when 4    # 向上移動
          move_up
        when 5    # 向左下移動
          move_lower_left
        when 6    # 向右下移動
          move_lower_right
        when 7    # 向左上移動
          move_upper_left
        when 8    # 向右上移動
          move_upper_right
        when 9    # 隨機移動
          move_random
        when 10   # 靠近主角
          move_toward_player
        when 11   # 遠離主角
          move_away_from_player
        when 12   # 前進一步
          move_forward
        when 13   # 後退一步
          move_backward
        when 14   # 跳躍
          jump(command.parameters[0], command.parameters[1])
        when 15   # 等待幀……
          @wait_count = command.parameters[0] - 1
        when 16   # 臉向下
          turn_down
        when 17   # 臉向左
          turn_left
        when 18   # 臉向右
          turn_right
        when 19   # 臉向上
          turn_up
        when 20   # 向右旋轉90°
          turn_right_90
        when 21   # 向左旋轉90°
          turn_left_90
        when 22   # 旋轉180°
          turn_180
        when 23   # 隨機旋轉90°
          turn_right_or_left_90
        when 24   # 隨機轉換方向
          turn_random
        when 25   # 面向主角
          turn_toward_player
        when 26   # 背向主角
          turn_away_from_player
        when 27   # 打開開關
          $game_switches[command.parameters[0]] = true
          $game_map.need_refresh = true
        when 28   # 關閉開關
          $game_switches[command.parameters[0]] = false
          $game_map.need_refresh = true
        when 29   # 變更移動速度
          @move_speed = command.parameters[0]
        when 30   # 變更移動頻率
          @move_frequency = command.parameters[0]
        when 31   # 開啟步行動畫
          @walk_anime = true
        when 32   # 關閉步行動畫
          @walk_anime = false
        when 33   # 開啟踏步動畫
          @step_anime = true
        when 34   # 關閉踏步動畫
          @step_anime = false
        when 35   # 開啟方向鎖定
          @direction_fix = true
        when 36   # 關閉方向鎖定
          @direction_fix = false
        when 37   # 開啟"事件可穿透"
          @through = true
        when 38   # 關閉"事件可穿透"
          @through = false
        when 39   # 開啟事件圖形透明
          @transparent = true
        when 40   # 關閉事件圖形透明
          @transparent = false
        when 41   # 更改事件圖形
          set_graphic(command.parameters[0], command.parameters[1])
        when 42   # 更改不透明度
          @opacity = command.parameters[0]
        when 43   # 更改填充方式
          @blend_type = command.parameters[0]
        when 44   # 播放音效
          command.parameters[0].play
        when 45   # 插入RGSS腳本語句
          eval(command.parameters[0])
        end
        if not @move_route.skippable and @move_failed
          return  # 關閉[無視路障] & 移動失敗
        end
        @move_route_index += 1
      end
    end
  end

  #--------------------------------------------------------------------------
  # * 累計步數
  #--------------------------------------------------------------------------
  def increase_steps
    @stop_count = 0
    update_bush_depth
  end
  #--------------------------------------------------------------------------
  # * 計算與主角的橫向距離
  #--------------------------------------------------------------------------
  def distance_x_from_player 
    sx = @x - $game_player.x
    if $game_map.loop_horizontal?            # 橫向滾動地圖？
      if sx == 1 - $game_map.width 
        sx += $game_map.width  
      elsif sx.abs > $game_map.width / 2     # 大於地圖寬度的1/2？
        sx -= $game_map.width                # 減去地圖寬度
      end
    end
    return sx
  end
  #--------------------------------------------------------------------------
  # * 計算與主角的縱向距離
  #--------------------------------------------------------------------------
  def distance_y_from_player
    sy = @y - $game_player.y
    if $game_map.loop_vertical?              # 縱向滾動地圖？
      if sy == 1 - $game_map.height
        sy += $game_map.height     
      elsif sy.abs > $game_map.height / 2    # 大於地圖高度的1/2？
        sy -= $game_map.height               # 減去地圖高度
      end
    end
    return sy
  end
  #--------------------------------------------------------------------------
  # * 向下移動
  #     turn_ok : 允許原地轉向
  #--------------------------------------------------------------------------
  def move_down(turn_ok = true)
    if passable?(@x, @y+1)                  # 可通行？
      turn_down
      @y = $game_map.round_y(@y+1)
      @real_y = (@y-1)*256
      increase_steps
      @move_failed = false
    else                                    # 不可通行？
      turn_down if turn_ok
      check_event_trigger_touch(@x, @y+1)   # 一觸即發的事件被觸發？
      @move_failed = true
    end
  end
  #--------------------------------------------------------------------------
  # * 向左移動
  #     turn_ok : 允許原地轉向
  #--------------------------------------------------------------------------
  def move_left(turn_ok = true)
    if passable?(@x-1, @y)                  # 可通行？
      turn_left
      @x = $game_map.round_x(@x-1)
      @real_x = (@x+1)*256
      increase_steps
      @move_failed = false
    else                                    # 不可通行？
      turn_left if turn_ok
      check_event_trigger_touch(@x-1, @y)   # 一觸即發的事件被觸發？
      @move_failed = true
    end
  end
  #--------------------------------------------------------------------------
  # * 向右移動
  #     turn_ok : 允許原地轉向
  #--------------------------------------------------------------------------
  def move_right(turn_ok = true)
    if passable?(@x+1, @y)                  # 可通行？
      turn_right
      @x = $game_map.round_x(@x+1)
      @real_x = (@x-1)*256
      increase_steps
      @move_failed = false
    else                                    # 不可通行？
      turn_right if turn_ok
      check_event_trigger_touch(@x+1, @y)   # 一觸即發的事件被觸發？
      @move_failed = true
    end
  end
  #--------------------------------------------------------------------------
  # * 向上移動
  #     turn_ok : 允許原地轉向
  #--------------------------------------------------------------------------
  def move_up(turn_ok = true)
    if passable?(@x, @y-1)                  # 可通行？
      turn_up
      @y = $game_map.round_y(@y-1)
      @real_y = (@y+1)*256
      increase_steps
      @move_failed = false
    else                                    # 不可通行？
      turn_up if turn_ok
      check_event_trigger_touch(@x, @y-1)   # 一觸即發的事件被觸發？
      @move_failed = true
    end
  end
  #--------------------------------------------------------------------------
  # * 向左下移動
  #--------------------------------------------------------------------------
  def move_lower_left
    unless @direction_fix
      @direction = (@direction == 6 ? 4 : @direction == 8 ? 2 : @direction)
    end
    if (passable?(@x, @y+1) and passable?(@x-1, @y+1)) or
       (passable?(@x-1, @y) and passable?(@x-1, @y+1))
      @x -= 1
      @y += 1
      increase_steps
      @move_failed = false
    else
      @move_failed = true
    end
  end
  #--------------------------------------------------------------------------
  # * 向右下移動
  #--------------------------------------------------------------------------
  def move_lower_right
    unless @direction_fix
      @direction = (@direction == 4 ? 6 : @direction == 8 ? 2 : @direction)
    end
    if (passable?(@x, @y+1) and passable?(@x+1, @y+1)) or
       (passable?(@x+1, @y) and passable?(@x+1, @y+1))
      @x += 1
      @y += 1
      increase_steps
      @move_failed = false
    else
      @move_failed = true
    end
  end
  #--------------------------------------------------------------------------
  # * 向左上移動
  #--------------------------------------------------------------------------
  def move_upper_left
    unless @direction_fix
      @direction = (@direction == 6 ? 4 : @direction == 2 ? 8 : @direction)
    end
    if (passable?(@x, @y-1) and passable?(@x-1, @y-1)) or
       (passable?(@x-1, @y) and passable?(@x-1, @y-1))
      @x -= 1
      @y -= 1
      increase_steps
      @move_failed = false
    else
      @move_failed = true
    end
  end
  #--------------------------------------------------------------------------
  # * 向右上移動
  #--------------------------------------------------------------------------
  def move_upper_right
    unless @direction_fix
      @direction = (@direction == 4 ? 6 : @direction == 2 ? 8 : @direction)
    end
    if (passable?(@x, @y-1) and passable?(@x+1, @y-1)) or
       (passable?(@x+1, @y) and passable?(@x+1, @y-1))
      @x += 1
      @y -= 1
      increase_steps
      @move_failed = false
    else
      @move_failed = true
    end
  end
  #--------------------------------------------------------------------------
  # * 隨機移動
  #--------------------------------------------------------------------------
  def move_random
    case rand(4)
    when 0;  move_down(false)
    when 1;  move_left(false)
    when 2;  move_right(false)
    when 3;  move_up(false)
    end
  end
  #--------------------------------------------------------------------------
  # * 靠近主角
  #--------------------------------------------------------------------------
  def move_toward_player
    sx = distance_x_from_player
    sy = distance_y_from_player
    if sx != 0 or sy != 0
      if sx.abs > sy.abs                  # 橫向距離更長？
        sx > 0 ? move_left : move_right   # 優先處理左-右移動
        if @move_failed and sy != 0
          sy > 0 ? move_up : move_down
        end
      else                                # 縱向距離更長？
        sy > 0 ? move_up : move_down      # 優先處理上-下移動
        if @move_failed and sx != 0
          sx > 0 ? move_left : move_right
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 遠離主角
  #--------------------------------------------------------------------------
  def move_away_from_player
    sx = distance_x_from_player
    sy = distance_y_from_player
    if sx != 0 or sy != 0
      if sx.abs > sy.abs                  # 橫向距離更長？
        sx > 0 ? move_right : move_left   # 優先處理左-右移動
        if @move_failed and sy != 0
          sy > 0 ? move_down : move_up
        end
      else                                # 縱向距離更長？
        sy > 0 ? move_down : move_up      # 優先處理上-下移動
        if @move_failed and sx != 0
          sx > 0 ? move_right : move_left
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 前進一步
  #--------------------------------------------------------------------------
  def move_forward
    case @direction
    when 2;  move_down(false)
    when 4;  move_left(false)
    when 6;  move_right(false)
    when 8;  move_up(false)
    end
  end
  #--------------------------------------------------------------------------
  # * 後退一步
  #--------------------------------------------------------------------------
  def move_backward
    last_direction_fix = @direction_fix
    @direction_fix = true
    case @direction
    when 2;  move_up(false)
    when 4;  move_right(false)
    when 6;  move_left(false)
    when 8;  move_down(false)
    end
    @direction_fix = last_direction_fix
  end
  #--------------------------------------------------------------------------
  # * 跳躍
  #     x_plus : X座標增值
  #     y_plus : Y座標增值
  #--------------------------------------------------------------------------
  def jump(x_plus, y_plus)
    if x_plus.abs > y_plus.abs            # 橫向距離更長？
      x_plus < 0 ? turn_left : turn_right
    elsif x_plus.abs > y_plus.abs         # 縱向距離更長？
      y_plus < 0 ? turn_up : turn_down
    end
    @x += x_plus
    @y += y_plus
    distance = Math.sqrt(x_plus * x_plus + y_plus * y_plus).round
    @jump_peak = 10 + distance - @move_speed
    @jump_count = @jump_peak * 2
    @stop_count = 0
    straighten
  end
  #--------------------------------------------------------------------------
  # * 臉向下
  #--------------------------------------------------------------------------
  def turn_down
    set_direction(2)
  end
  #--------------------------------------------------------------------------
  # * 臉向左
  #--------------------------------------------------------------------------
  def turn_left
    set_direction(4)
  end
  #--------------------------------------------------------------------------
  # * 臉向右
  #--------------------------------------------------------------------------
  def turn_right
    set_direction(6)
  end
  #--------------------------------------------------------------------------
  # * 臉向上
  #--------------------------------------------------------------------------
  def turn_up
    set_direction(8)
  end
  #--------------------------------------------------------------------------
  # * 向右旋轉90°
  #--------------------------------------------------------------------------
  def turn_right_90
    case @direction
    when 2;  turn_left
    when 4;  turn_up
    when 6;  turn_down
    when 8;  turn_right
    end
  end
  #--------------------------------------------------------------------------
  # * 向左旋轉90°
  #--------------------------------------------------------------------------
  def turn_left_90
    case @direction
    when 2;  turn_right
    when 4;  turn_down
    when 6;  turn_up
    when 8;  turn_left
    end
  end
  #--------------------------------------------------------------------------
  # * 旋轉180°
  #--------------------------------------------------------------------------
  def turn_180
    case @direction
    when 2;  turn_up
    when 4;  turn_right
    when 6;  turn_left
    when 8;  turn_down
    end
  end
  #--------------------------------------------------------------------------
  # * 隨機旋轉90°
  #--------------------------------------------------------------------------
  def turn_right_or_left_90
    case rand(2)
    when 0;  turn_right_90
    when 1;  turn_left_90
    end
  end
  #--------------------------------------------------------------------------
  # * 隨機旋轉方向
  #--------------------------------------------------------------------------
  def turn_random
    case rand(4)
    when 0;  turn_up
    when 1;  turn_right
    when 2;  turn_left
    when 3;  turn_down
    end
  end
  #--------------------------------------------------------------------------
  # * 面向主角
  #--------------------------------------------------------------------------
  def turn_toward_player
    sx = distance_x_from_player
    sy = distance_y_from_player
    if sx.abs > sy.abs                    # 橫向距離更長？
      sx > 0 ? turn_left : turn_right
    elsif sx.abs < sy.abs                 # 縱向距離更長？
      sy > 0 ? turn_up : turn_down
    end
  end
  #--------------------------------------------------------------------------
  # * 背向主角
  #--------------------------------------------------------------------------
  def turn_away_from_player
    sx = distance_x_from_player
    sy = distance_y_from_player
    if sx.abs > sy.abs                    # 橫向距離更長？
      sx > 0 ? turn_right : turn_left
    elsif sx.abs < sy.abs                 # 縱向距離更長？
      sy > 0 ? turn_down : turn_up
    end
  end
  #--------------------------------------------------------------------------
  # * 更改圖形
  #     character_name  : 新人物特徵圖圖檔名
  #     character_index : 新人物特徵圖編號
  #--------------------------------------------------------------------------
  def set_graphic(character_name, character_index)
    @tile_id = 0
    @character_name = character_name
    @character_index = character_index
  end
end
