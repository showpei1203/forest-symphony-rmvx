#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Game_Interpreter
# 【用途】VX 事件直譯器，執行 Event Command、分支、訊息、傳送、戰鬥與 Script 指令。
# 【主要機制】地圖／Common Event／Troop Event 都依賴此類；跨地圖事件、任務、商店等插件常在此增加 Script Call。
# 【主要影響】Game_Interpreter
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
# ** Game_Interpreter
#------------------------------------------------------------------------------
#  這個類是用來執行事件指令的直譯器。 
#  這個類作為 Game_Map、Game_Troop 和 Game_Event 的內部類使用。
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # * 物件初始化
  #     depth : 嵌套深度
  #     main  : 主標幟
  #--------------------------------------------------------------------------
  def initialize(depth = 0, main = false)
    @depth = depth
    @main = main
    if @depth > 100
      print("全域事件呼叫的數量大於上限值100。")
      exit
    end
    clear
  end
  #--------------------------------------------------------------------------
  # * 清零
  #--------------------------------------------------------------------------
  def clear
    @map_id = 0                       # 開始時的地圖編號
    @original_event_id = 0            # 開始時的事件編號
    @event_id = 0                     # 事件編號
    @list = nil                       # 要執行的內容
    @index = 0                        # 索引
    @message_waiting = false          # 等待文本顯示完畢
    @moving_character = nil           # 人物移動
    @wait_count = 0                   # 等待次數統計
    @child_interpreter = nil          # 子直譯器
    @branch = {}                      # 分歧資料
  end
  #--------------------------------------------------------------------------
  # * 事件設置
  #     list     : 待執行的指令
  #     event_id : 事件編號
  #--------------------------------------------------------------------------
  def setup(list, event_id = 0)
    clear                             # 內部直譯器狀態清零
    @map_id = $game_map.map_id        # 記憶地圖編號
    @original_event_id = event_id     # 記憶事件編號
    @event_id = event_id              # 記憶事件編號
    @list = list                      # 記憶要執行的內容
    @index = 0                        # 初始化索引
    cancel_menu_call                  # 禁止呼叫ESC選單
  end
  #--------------------------------------------------------------------------
  # * 禁止呼叫ESC選單
  #   控制下列兩種情形並使其無效:
  #   1 玩家正在事件指令操控下移動的時候按下取消鍵。
  #   2 事件指令正在執行的時候嘗試呼叫ESC選單。
  #--------------------------------------------------------------------------
  def cancel_menu_call
    if @main and $game_temp.next_scene == "menu" and $game_temp.menu_beep
      $game_temp.next_scene = nil
      $game_temp.menu_beep = false
    end
  end
  #--------------------------------------------------------------------------
  # * 判定奔跑狀態
  #--------------------------------------------------------------------------
  def running?
    return @list != nil
  end
  #--------------------------------------------------------------------------
  # * 開始設置事件
  #--------------------------------------------------------------------------
  def setup_starting_event
    if $game_map.need_refresh             # 若需要，則刷新地圖介面顯示
      $game_map.refresh
    end
    if $game_temp.common_event_id > 0     # 暫時停止呼叫公共事件？
      setup($data_common_events[$game_temp.common_event_id].list)
      $game_temp.common_event_id = 0
      return
    end
    for event in $game_map.events.values  # 地圖事件
      if event.starting                   # 如果找到了起始事件
        event.clear_starting              # 清除起始標幟
        setup(event.list, event.id)       # 設置事件
        return
      end
    end
    for event in $data_common_events.compact      # 全域事件
      if event.trigger == 1 and                   # 自動執行？
         $game_switches[event.switch_id] == true  # 控制開關被開啟？
        setup(event.list)                         # 設置事件
        return
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 更新幀
  #--------------------------------------------------------------------------
  def update
    loop do
      if $game_map.map_id != @map_id        # 地圖不通？
        @event_id = 0                       # 使事件編號為0
      end
      if @child_interpreter != nil          # 如果子直譯器存在
        @child_interpreter.update           # 更新子直譯器資訊
        if @child_interpreter.running?      # 子直譯器執行中？
          return                            # 返回
        else                                # 執行結束後
          @child_interpreter = nil          # 子直譯器清零
        end
      end
      if @message_waiting                   # 等待文本訊息顯示完畢
        return
      end
      if @moving_character != nil           # 等待移動結束
        if @moving_character.move_route_forcing
          return
        end
        @moving_character = nil
      end
      if @wait_count > 0                    # 等待
        @wait_count -= 1
        return
      end
      if $game_troop.forcing_battler != nil # 強制下達作戰指令
        return
      end
      if $game_temp.next_scene != nil       # 開場畫面
        return
      end
      if @list == nil                       # 若內容清單為空
        setup_starting_event if @main       # 設置玩家起點事件
        return if @list == nil              # 什麼都沒設置
      end
      return if execute_command == false    # 執行事件指令
      @index += 1                           # 指數遞增
    end
  end
  #--------------------------------------------------------------------------
  # * 主角反覆運算程式（編號）
  #     param : 若值大於等於零則指定某個索引，若值為-1則指定全體主角。
  #--------------------------------------------------------------------------
  def iterate_actor_id(param)
    if param == 0       # 全體
      for actor in $game_party.members do yield actor end
    else                # 單體
      actor = $game_actors[param]
      yield actor unless actor == nil
    end
  end
  #--------------------------------------------------------------------------
  # * 主角反覆運算程式（索引）
  #     param : 若值大於等於零則指定某個索引，若值為-1則指定全體主角。
  #--------------------------------------------------------------------------
  def iterate_actor_index(param)
    if param == -1      # 全體
      for actor in $game_party.members do yield actor end
    else                # 單體
      actor = $game_party.members[param]
      yield actor unless actor == nil
    end
  end
  #--------------------------------------------------------------------------
  # * 敵人反覆運算程式（索引）
  #     param : 若值大於等於零則指定某個索引，若值為-1則指定全體主角。
  #--------------------------------------------------------------------------
  def iterate_enemy_index(param)
    if param == -1      # 全體
      for enemy in $game_troop.members do yield enemy end
    else                # 單體
      enemy = $game_troop.members[param]
      yield enemy unless enemy == nil
    end
  end
  #--------------------------------------------------------------------------
  # * 參戰者反覆運算程式（作用於整個隊伍）
  #     param1 : 若值為零則為敵人隊伍，若值為1則為主角隊。
  #     param : 若值大於等於零則指定某個索引，若值為-1則指定全體主角。
  #--------------------------------------------------------------------------
  def iterate_battler(param1, param2)
    if $game_temp.in_battle
      if param1 == 0      # 敵人
        iterate_enemy_index(param2) do |enemy| yield enemy end
      else                # 主角
        iterate_actor_index(param2) do |enemy| yield enemy end
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 獲取螢幕指令目標
  #--------------------------------------------------------------------------
  def screen
    if $game_temp.in_battle
      return $game_troop.screen
    else
      return $game_map.screen
    end
  end
  #--------------------------------------------------------------------------
  # * 執行事件指令
  #--------------------------------------------------------------------------
  def execute_command
    if @index >= @list.size-1
      command_end
      return true
    else
      @params = @list[@index].parameters
      @indent = @list[@index].indent
      case @list[@index].code
      when 101  # 顯示文本
        return command_101
      when 102  # 顯示選項
        return command_102
      when 402  # 當選擇[**]的時候
        return command_402
      when 403  # 當按下取消鍵的時候
        return command_403
      when 103  # 顯示數字輸入框
        return command_103
      when 111  # 定義條件分歧
        return command_111
      when 411  # 其他情況
        return command_411
      when 112  # 迴圈
        return command_112
      when 413  # 迴圈執行上述指令
        return command_413
      when 113  # 取消迴圈
        return command_113
      when 115  # 中斷事件處理
        return command_115
      when 117  # 呼叫全域事件
        return command_117
      when 118  # 作標記
        return command_118
      when 119  # 跳轉至標記……
        return command_119
      when 121  # 控制系統開關
        return command_121
      when 122  # 控制系統變數
        return command_122
      when 123  # 控制獨立開關
        return command_123
      when 124  # 控制計時器
        return command_124
      when 125  # 增減資金
        return command_125
      when 126  # 增減物品
        return command_126
      when 127  # 增減武器
        return command_127
      when 128  # 增減防具
        return command_128
      when 129  # 隊伍人事變動
        return command_129
      when 132  # 更改作戰BGM
        return command_132
      when 133  # 更改作戰結束ME
        return command_133
      when 134  # 啟用/禁用存檔
        return command_134
      when 135  # 啟用/禁用ESC選單
        return command_135
      when 136  # 啟用/禁用地雷遇敵模式
        return command_136
      when 201  # 場所移動
        return command_201
      when 202  # 調整交通工具位置
        return command_202
      when 203  # 移動事件座標
        return command_203
      when 204  # 地圖視域移動
        return command_204
      when 205  # 設置移動軌跡
        return command_205
      when 206  # 交通工具乘降
        return command_206
      when 211  # 更改主角步行圖透明選項
        return command_211
      when 212  # 播放動畫
        return command_212
      when 213  # 顯示浮動圖示
        return command_213
      when 214  # 暫時刪除本事件
        return command_214
      when 221  # 畫面漸隱[淡入]
        return command_221
      when 222  # 畫面漸顯[淡出]
        return command_222
      when 223  # 更改畫面色調
        return command_223
      when 224  # 閃屏
        return command_224
      when 225  # 顫屏
        return command_225
      when 230  # 等待幀……
        return command_230
      when 231  # 顯示圖片
        return command_231
      when 232  # 移動圖片並更改其參數
        return command_232
      when 233  # 旋轉圖片
        return command_233
      when 234  # 圖片色調……
        return command_234
      when 235  # 圖片消失
        return command_235
      when 236  # 天氣配置
        return command_236
      when 241  # 播放 BGM
        return command_241
      when 242  # 淡出 BGM
        return command_242
      when 245  # 播放 BGS
        return command_245
      when 246  # 淡出 BGS
        return command_246
      when 249  # 播放 ME
        return command_249
      when 250  # 播放 SE
        return command_250
      when 251  # 停止播放當前所有 SE
        return command_251
      when 301  # 作戰處理
        return command_301
      when 601  # 若贏
        return command_601
      when 602  # 若逃跑撤退
        return command_602
      when 603  # 若輸
        return command_603
      when 302  # 交易處理
        return command_302
      when 303  # 名稱輸入處理
        return command_303
      when 311  # HP調整
        return command_311
      when 312  # MP調整
        return command_312
      when 313  # 狀態校正
        return command_313
      when 314  # 恢復健康
        return command_314
      when 315  # 主角EXP調整
        return command_315
      when 316  # 主角等級調整
        return command_316
      when 317  # 主角能力參數調整
        return command_317
      when 318  # 主角技能調整
        return command_318
      when 319  # 主角裝備調整
        return command_319
      when 320  # 修改主角名稱
        return command_320
      when 321  # 主角職業變更
        return command_321
      when 322  # 更改主角步行圖/臉圖
        return command_322
      when 323  # 更改交通工具步行圖
        return command_323
      when 331  #  調整敵人HP
        return command_331
      when 332  #  調整敵人MP
        return command_332
      when 333  # 調整敵人狀態
        return command_333
      when 334  # 恢復敵人健康
        return command_334
      when 335  # 敵方增加敵人
        return command_335
      when 336  # 敵方敵人變身
        return command_336
      when 337  # 作戰動畫顯示
        return command_337
      when 339  # 強行下達指令
        return command_339
      when 340  # 結束作戰
        return command_340
      when 351  # 打開ESC選單介面
        return command_351
      when 352  # 打開存檔介面
        return command_352
      when 353  # 遊戲結束
        return command_353
      when 354  # 返回標題畫面
        return command_354
      when 355  # 插入RGSS腳本語句
        return command_355
      else      # 其他
        return true
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 終止事件
  #--------------------------------------------------------------------------
  def command_end
    @list = nil                             # 清空指令內容清單
    if @main and @event_id > 0              # 主地圖事件？
      $game_map.events[@event_id].unlock    # 事件鎖清零
    end
  end
  #--------------------------------------------------------------------------
  # * 跳過指令
  #--------------------------------------------------------------------------
  def command_skip
    while @list[@index+1].indent > @indent  # 更深層次的縮進
      @index += 1                           # 指數遞增
    end
  end
  #--------------------------------------------------------------------------
  # * 獲取事件資訊
  #     param : 若是-1則為主角，若是0則為當前事件，若大於零則為事件編號。
  #--------------------------------------------------------------------------
  def get_character(param)
    case param
    when -1   # 主角
      return $game_player
    when 0    # 當前事件
      events = $game_map.events
      return events == nil ? nil : events[@event_id]
    else      # 事件編號
      events = $game_map.events
      return events == nil ? nil : events[param]
    end
  end
  #--------------------------------------------------------------------------
  # * 計算運算結果
  #     operation    : 要進行的操作 (0: 增, 1: 減)
  #     operand_type : 操作方式 (0: 非變數 1: 變數)
  #     operand      : 運算域 (變數編號或數字)
  #--------------------------------------------------------------------------
  def operate_value(operation, operand_type, operand)
    if operand_type == 0
      value = operand
    else
      value = $game_variables[operand]
    end
    if operation == 1
      value = -value
    end
    return value
  end
  #--------------------------------------------------------------------------
  # * 顯示文本
  #--------------------------------------------------------------------------
  def command_101
    unless $game_message.busy
      $game_message.face_name = @params[0]
      $game_message.face_index = @params[1]
      $game_message.background = @params[2]
      $game_message.position = @params[3]
      @index += 1
      while @list[@index].code == 401       # 文本資料
        $game_message.texts.push(@list[@index].parameters[0])
        @index += 1
      end
      if @list[@index].code == 102          # 顯示選項
        setup_choices(@list[@index].parameters)
      elsif @list[@index].code == 103       # 數字輸入處理
        setup_num_input(@list[@index].parameters)
      end
      set_message_waiting                   # 設置文本等候狀態
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * 設置文本等候狀態標幟並回撥
  #--------------------------------------------------------------------------
  def set_message_waiting
    @message_waiting = true
    $game_message.main_proc = Proc.new { @message_waiting = false }
  end
  #--------------------------------------------------------------------------
  # * 顯示選項
  #--------------------------------------------------------------------------
  def command_102
    unless $game_message.busy
      setup_choices(@params)                # 設置
      set_message_waiting                   # 設置文本等候狀態
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * 選項設置
  #--------------------------------------------------------------------------
  def setup_choices(params)
    if $game_message.texts.size <= 4 - params[0].size
      $game_message.choice_start = $game_message.texts.size
      $game_message.choice_max = params[0].size
      for s in params[0]
        $game_message.texts.push(s)
      end
      $game_message.choice_cancel_type = params[1]
      $game_message.choice_proc = Proc.new { |n| @branch[@indent] = n }
      @index += 1
    end
  end
  #--------------------------------------------------------------------------
  # * 當選擇[**]的情況下
  #--------------------------------------------------------------------------
  def command_402
    if @branch[@indent] == @params[0]       # 如果選項匹配
      @branch.delete(@indent)               # 清除分歧資料
      return true                           # 繼續
    else                                    # 如果條件不匹配
      return command_skip                   # 跳過指令
    end
  end
  #--------------------------------------------------------------------------
  # * 當按下取消鍵的情況下
  #--------------------------------------------------------------------------
  def command_403
    if @branch[@indent] == 4                # 若取消選擇
      @branch.delete(@indent)               # 清除分歧資料
      return true                           # 繼續
    else                                    # 如果條件不匹配
      return command_skip                   # 跳過指令
    end
  end
  #--------------------------------------------------------------------------
  # * 輸入數字
  #--------------------------------------------------------------------------
  def command_103
    unless $game_message.busy
      setup_num_input(@params)              # 設置
      set_message_waiting                   # 設置文本等候狀態
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * 輸入數字的設置
  #--------------------------------------------------------------------------
  def setup_num_input(params)
    if $game_message.texts.size < 4
      $game_message.num_input_variable_id = params[0]
      $game_message.num_input_digits_max = params[1]
      @index += 1
    end
  end
  #--------------------------------------------------------------------------
  # * 定義條件分歧
  #--------------------------------------------------------------------------
  def command_111
    result = false
    case @params[0]
    when 0  # 開關
      result = ($game_switches[@params[1]] == (@params[2] == 0))
    when 1  # 系統變數
      value1 = $game_variables[@params[1]]
      if @params[2] == 0
        value2 = @params[3]
      else
        value2 = $game_variables[@params[3]]
      end
      case @params[4]
      when 0  # value1 = value2
        result = (value1 == value2)
      when 1  # value1 >= value2
        result = (value1 >= value2)
      when 2  # value1 <= value2
        result = (value1 <= value2)
      when 3  # value1 > value2
        result = (value1 > value2)
      when 4  # value1 < value2
        result = (value1 < value2)
      when 5  # value1 不等於 value2
        result = (value1 != value2)
      end
    when 2  # 獨立開關
      if @original_event_id > 0
        key = [@map_id, @original_event_id, @params[1]]
        if @params[2] == 0
          result = ($game_self_switches[key] == true)
        else
          result = ($game_self_switches[key] != true)
        end
      end
    when 3  # 計時器
      if $game_system.timer_working
        sec = $game_system.timer / Graphics.frame_rate
        if @params[2] == 0
          result = (sec >= @params[1])
        else
          result = (sec <= @params[1])
        end
      end
    when 4  # 主角
      actor = $game_actors[@params[1]]
      if actor != nil
        case @params[2]
        when 0  # 在隊
          result = ($game_party.members.include?(actor))
        when 1  # 名稱
          result = (actor.name == @params[3])
        when 2  # 技能
          result = (actor.skill_learn?($data_skills[@params[3]]))
        when 3  # 武器
          result = (actor.weapons.include?($data_weapons[@params[3]]))
        when 4  # 護具
          result = (actor.armors.include?($data_armors[@params[3]]))
        when 5  # 狀態
          result = (actor.state?(@params[3]))
        end
      end
    when 5  # 敵人
      enemy = $game_troop.members[@params[1]]
      if enemy != nil
        case @params[2]
        when 0  # 出現
          result = (enemy.exist?)
        when 1  # 狀態
          result = (enemy.state?(@params[3]))
        end
      end
    when 6  # 人物
      character = get_character(@params[1])
      if character != nil
        result = (character.direction == @params[2])
      end
    when 7  # 所攜資金
      if @params[2] == 0
        result = ($game_party.gold >= @params[1])
      else
        result = ($game_party.gold <= @params[1])
      end
    when 8  # 所攜物品
      result = $game_party.has_item?($data_items[@params[1]])
    when 9  # 所攜武器
      result = $game_party.has_item?($data_weapons[@params[1]], @params[2])
    when 10  # 所攜護具
      result = $game_party.has_item?($data_armors[@params[1]], @params[2])
    when 11  # 按鈕按下時的處理
      result = Input.press?(@params[1])
    when 12  # 執行RGSS腳本語句
      result = eval(@params[1])
    when 13  # 交通工具
      result = ($game_player.vehicle_type == @params[1])
    end
    @branch[@indent] = result     # 將判定結果存儲於 HASH 表內
    if @branch[@indent] == true
      @branch.delete(@indent)
      return true
    end
    return command_skip
  end
  #--------------------------------------------------------------------------
  # * 其餘的情況下
  #--------------------------------------------------------------------------
  def command_411
    if @branch[@indent] == false
      @branch.delete(@indent)
      return true
    end
    return command_skip
  end
  #--------------------------------------------------------------------------
  # * 迴圈
  #--------------------------------------------------------------------------
  def command_112
    return true
  end
  #--------------------------------------------------------------------------
  # * 迴圈執行上述指令
  #--------------------------------------------------------------------------
  def command_413
    begin
      @index -= 1
    end until @list[@index].indent == @indent
    return true
  end
  #--------------------------------------------------------------------------
  # * 取消迴圈
  #--------------------------------------------------------------------------
  def command_113
    loop do
      @index += 1
      if @index >= @list.size-1
        return true
      end
      if @list[@index].code == 413 and    # 指令[迴圈執行上述指令]
         @list[@index].indent < @indent   # 淺層縮進
        return true
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 退出事件處理進程
  #--------------------------------------------------------------------------
  def command_115
    command_end
    return true
  end
  #--------------------------------------------------------------------------
  # * 呼叫全域事件
  #--------------------------------------------------------------------------
  def command_117
    common_event = $data_common_events[@params[0]]
    if common_event != nil
      @child_interpreter = Game_Interpreter.new(@depth + 1)
      @child_interpreter.setup(common_event.list, @event_id)
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * 標記
  #--------------------------------------------------------------------------
  def command_118
    return true
  end
  #--------------------------------------------------------------------------
  # * 跳轉至標記
  #--------------------------------------------------------------------------
  def command_119
    label_name = @params[0]
    for i in 0...@list.size
      if @list[i].code == 118 and @list[i].parameters[0] == label_name
        @index = i
        return true
      end
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * 控制開關
  #--------------------------------------------------------------------------
  def command_121
    for i in @params[0] .. @params[1]   # 批量控制
      $game_switches[i] = (@params[2] == 0)
    end
    $game_map.need_refresh = true
    return true
  end
  #--------------------------------------------------------------------------
  # * 控制系統變數
  #--------------------------------------------------------------------------
  def command_122
    value = 0
    case @params[3]  # 運算物件
    when 0  # 常數
      value = @params[4]
    when 1  # 系統變數
      value = $game_variables[@params[4]]
    when 2  # 亂數
      value = @params[4] + rand(@params[5] - @params[4] + 1)
    when 3  # 物品
      value = $game_party.item_number($data_items[@params[4]])
    when 4  # 主角
      actor = $game_actors[@params[4]]
      if actor != nil
        case @params[5]
        when 0  # 等級
          value = actor.level
        when 1  # 經驗值
          value = actor.exp
        when 2  # HP值
          value = actor.hp
        when 3  # MP值
          value = actor.mp
        when 4  # HP上限值
          value = actor.maxhp
        when 5  # MP上限值
          value = actor.maxmp
        when 6  # 攻擊力
          value = actor.atk
        when 7  # 防禦力
          value = actor.def
        when 8  # 精神意志力
          value = actor.spi
        when 9  # 敏捷力
          value = actor.agi
        end
      end
    when 5  # 敵人
      enemy = $game_troop.members[@params[4]]
      if enemy != nil
        case @params[5]
        when 0  # HP值
          value = enemy.hp
        when 1  # MP值
          value = enemy.mp
        when 2  # HP上限值
          value = enemy.maxhp
        when 3  # MP上限值
          value = enemy.maxmp
        when 4  # 攻擊力
          value = enemy.atk
        when 5  # 防禦力
          value = enemy.def
        when 6  # 精神意志力
          value = enemy.spi
        when 7  # 敏捷力
          value = enemy.agi
        end
      end
    when 6  # 角色/事件
      character = get_character(@params[4])
      if character != nil
        case @params[5]
        when 0  # 地圖X座標
          value = character.x
        when 1  # 地圖Y座標
          value = character.y
        when 2  # 朝向
          value = character.direction
        when 3  # 螢幕X座標
          value = character.screen_x
        when 4  # 螢幕Y座標
          value = character.screen_y
        end
      end
    when 7  # 其他
      case @params[4]
      when 0  # 地圖編號
        value = $game_map.map_id
      when 1  # 在隊人數
        value = $game_party.members.size
      when 2  # 所攜資金
        value = $game_party.gold
      when 3  # 累計步數
        value = $game_party.steps
      when 4  # 累計遊戲時間
        value = Graphics.frame_count / Graphics.frame_rate
      when 5  # 計時器
        value = $game_system.timer / Graphics.frame_rate
      when 6  # 累計存檔次數
        value = $game_system.save_count
      end
    end
    for i in @params[0] .. @params[1]   # 批量控制
      case @params[2]  # 操作
      when 0  # 代入
        $game_variables[i] = value
      when 1  # 加
        $game_variables[i] += value
      when 2  # 減
        $game_variables[i] -= value
      when 3  # 乘
        $game_variables[i] *= value
      when 4  # 除
        $game_variables[i] /= value if value != 0
      when 5  # 取模運算
        $game_variables[i] %= value if value != 0
      end
      if $game_variables[i] > 99999999    # 檢查上限
        $game_variables[i] = 99999999
      end
      if $game_variables[i] < -99999999   # 檢查下限
        $game_variables[i] = -99999999
      end
    end
    $game_map.need_refresh = true
    return true
  end
  #--------------------------------------------------------------------------
  # * 控制獨立開關
  #--------------------------------------------------------------------------
  def command_123
    if @original_event_id > 0
      key = [@map_id, @original_event_id, @params[0]]
      $game_self_switches[key] = (@params[1] == 0)
    end
    $game_map.need_refresh = true
    return true
  end
  #--------------------------------------------------------------------------
  # * 控制計時器
  #--------------------------------------------------------------------------
  def command_124
    if @params[0] == 0  # 開始計時
      $game_system.timer = @params[1] * Graphics.frame_rate
      $game_system.timer_working = true
    end
    if @params[0] == 1  # 停止計時
      $game_system.timer_working = false
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * 增減資金
  #--------------------------------------------------------------------------
  def command_125
    value = operate_value(@params[0], @params[1], @params[2])
    $game_party.gain_gold(value)
    return true
  end
  #--------------------------------------------------------------------------
  # * 增減物品
  #--------------------------------------------------------------------------
  def command_126
    value = operate_value(@params[1], @params[2], @params[3])
    $game_party.gain_item($data_items[@params[0]], value)
    $game_map.need_refresh = true
    return true
  end
  #--------------------------------------------------------------------------
  # * 增減武器
  #--------------------------------------------------------------------------
  def command_127
    value = operate_value(@params[1], @params[2], @params[3])
    $game_party.gain_item($data_weapons[@params[0]], value, @params[4])
    return true
  end
  #--------------------------------------------------------------------------
  # * 增減防具
  #--------------------------------------------------------------------------
  def command_128
    value = operate_value(@params[1], @params[2], @params[3])
    $game_party.gain_item($data_armors[@params[0]], value, @params[4])
    return true
  end
  #--------------------------------------------------------------------------
  # * 隊伍人事變動
  #--------------------------------------------------------------------------
  def command_129
    actor = $game_actors[@params[0]]
    if actor != nil
      if @params[1] == 0    # 入隊
        if @params[2] == 1  # 初始化參數
          $game_actors[@params[0]].setup(@params[0])
        end
        $game_party.add_actor(@params[0])
      else                  # 離隊
        $game_party.remove_actor(@params[0])
      end
      $game_map.need_refresh = true
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * 更改作戰BGM
  #--------------------------------------------------------------------------
  def command_132
    $game_system.battle_bgm = @params[0]
    return true
  end
  #--------------------------------------------------------------------------
  # * 更改作戰勝利ME
  #--------------------------------------------------------------------------
  def command_133
    $game_system.battle_end_me = @params[0]
    return true
  end
  #--------------------------------------------------------------------------
  # * 啟用/禁用存檔
  #--------------------------------------------------------------------------
  def command_134
    $game_system.save_disabled = (@params[0] == 0)
    return true
  end
  #--------------------------------------------------------------------------
  # * 啟用/禁用ESC選單
  #--------------------------------------------------------------------------
  def command_135
    $game_system.menu_disabled = (@params[0] == 0)
    return true
  end
  #--------------------------------------------------------------------------
  # * 啟用/禁用地雷遇敵模式
  #--------------------------------------------------------------------------
  def command_136
    $game_system.encounter_disabled = (@params[0] == 0)
    $game_player.make_encounter_count
    return true
  end
  #--------------------------------------------------------------------------
  # * 場所移動
  #--------------------------------------------------------------------------
  def command_201
    return true if $game_temp.in_battle
    if $game_player.transfer? or            # 場所移動中？
       $game_message.visible                # 文本正在顯示？
      return false
    end
    if @params[0] == 0                      # 直接指定
      map_id = @params[1]
      x = @params[2]
      y = @params[3]
      direction = @params[4]
    else                                    # 用系統變數指定
      map_id = $game_variables[@params[1]]
      x = $game_variables[@params[2]]
      y = $game_variables[@params[3]]
      direction = @params[4]
    end
    $game_player.reserve_transfer(map_id, x, y, direction)
    @index += 1
    return false
  end
  #--------------------------------------------------------------------------
  # * 調整交通工具位置
  #--------------------------------------------------------------------------
  def command_202
    if @params[1] == 0                      # 直接指定
      map_id = @params[2]
      x = @params[3]
      y = @params[4]
    else                                    # 用系統變數指定
      map_id = $game_variables[@params[2]]
      x = $game_variables[@params[3]]
      y = $game_variables[@params[4]]
    end
    if @params[0] == 0                      # 舟
      $game_map.boat.set_location(map_id, x, y)
    elsif @params[0] == 1                   # 船
      $game_map.ship.set_location(map_id, x, y)
    else                                    # 飛艇
      $game_map.airship.set_location(map_id, x, y)
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * 移動事件座標
  #--------------------------------------------------------------------------
  def command_203
    character = get_character(@params[0])
    if character != nil
      if @params[1] == 0                      # 直接指定
        character.moveto(@params[2], @params[3])
      elsif @params[1] == 1                   # 用系統變數指定
        new_x = $game_variables[@params[2]]
        new_y = $game_variables[@params[3]]
        character.moveto(new_x, new_y)
      else                                    # 與其它事件交換位置
        old_x = character.x
        old_y = character.y
        character2 = get_character(@params[2])
        if character2 != nil
          character.moveto(character2.x, character2.y)
          character2.moveto(old_x, old_y)
        end
      end
      case @params[4]   # 方向
      when 8  # 向上
        character.turn_up
      when 6  # 向右
        character.turn_right
      when 2  # 向下
        character.turn_down
      when 4  # 向左
        character.turn_left
      end
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * 地圖視域移動
  #--------------------------------------------------------------------------
  def command_204
    return true if $game_temp.in_battle
    return false if $game_map.scrolling?
    $game_map.start_scroll(@params[0], @params[1], @params[2])
    return true
  end
  #--------------------------------------------------------------------------
  # * 設置移動軌跡
  #--------------------------------------------------------------------------
  def command_205
    if $game_map.need_refresh
      $game_map.refresh
    end
    character = get_character(@params[0])
    if character != nil
      character.force_move_route(@params[1])
      @moving_character = character if @params[1].wait
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * 交通工具乘/降
  #--------------------------------------------------------------------------
  def command_206
    $game_player.get_on_off_vehicle
    return true
  end
  #--------------------------------------------------------------------------
  # * 更改主角步行圖透明選項
  #--------------------------------------------------------------------------
  def command_211
    $game_player.transparent = (@params[0] == 0)
    return true
  end
  #--------------------------------------------------------------------------
  # * 播放動畫
  #--------------------------------------------------------------------------
  def command_212
    character = get_character(@params[0])
    if character != nil
      character.animation_id = @params[1]
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * 顯示浮動圖示
  #--------------------------------------------------------------------------
  def command_213
    character = get_character(@params[0])
    if character != nil
      character.balloon_id = @params[1]
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * 暫時刪除本事件
  #--------------------------------------------------------------------------
  def command_214
    if @event_id > 0
      $game_map.events[@event_id].erase
    end
    @index += 1
    return false
  end
  #--------------------------------------------------------------------------
  # * 畫面漸隱[淡出]
  #--------------------------------------------------------------------------
  def command_221
    if $game_message.visible
      return false
    else
      screen.start_fadeout(30)
      @wait_count = 30
      return true
    end
  end
  #--------------------------------------------------------------------------
  # * 畫面漸顯[淡入]
  #--------------------------------------------------------------------------
  def command_222
    if $game_message.visible
      return false
    else
      screen.start_fadein(30)
      @wait_count = 30
      return true
    end
  end
  #--------------------------------------------------------------------------
  # * 更改畫面色調
  #--------------------------------------------------------------------------
  def command_223
    screen.start_tone_change(@params[0], @params[1])
    @wait_count = @params[1] if @params[2]
    return true
  end
  #--------------------------------------------------------------------------
  # * 閃屏
  #--------------------------------------------------------------------------
  def command_224
    screen.start_flash(@params[0], @params[1])
    @wait_count = @params[1] if @params[2]
    return true
  end
  #--------------------------------------------------------------------------
  # * 顫屏
  #--------------------------------------------------------------------------
  def command_225
    screen.start_shake(@params[0], @params[1], @params[2])
    @wait_count = @params[2] if @params[3]
    return true
  end
  #--------------------------------------------------------------------------
  # * 等待幀
  #--------------------------------------------------------------------------
  def command_230
    @wait_count = @params[0]
    return true
  end
  #--------------------------------------------------------------------------
  # * 顯示圖片
  #--------------------------------------------------------------------------
  def command_231
    if @params[3] == 0    # 直接指定
      x = @params[4]
      y = @params[5]
    else                  # 用系統變數指定
      x = $game_variables[@params[4]]
      y = $game_variables[@params[5]]
    end
    screen.pictures[@params[0]].show(@params[1], @params[2],
      x, y, @params[6], @params[7], @params[8], @params[9])
    return true
  end
  #--------------------------------------------------------------------------
  # * 移動圖片並更改其參數
  #--------------------------------------------------------------------------
  def command_232
    if @params[3] == 0    # 直接指定
      x = @params[4]
      y = @params[5]
    else                  # 用系統變數指定
      x = $game_variables[@params[4]]
      y = $game_variables[@params[5]]
    end
    screen.pictures[@params[0]].move(@params[2], x, y, @params[6],
      @params[7], @params[8], @params[9], @params[10])
    @wait_count = @params[10] if @params[11]
    return true
  end
  #--------------------------------------------------------------------------
  # * 旋轉圖片
  #--------------------------------------------------------------------------
  def command_233
    screen.pictures[@params[0]].rotate(@params[1])
    return true
  end
  #--------------------------------------------------------------------------
  # * 圖片色調
  #--------------------------------------------------------------------------
  def command_234
    screen.pictures[@params[0]].start_tone_change(@params[1], @params[2])
    @wait_count = @params[2] if @params[3]
    return true
  end
  #--------------------------------------------------------------------------
  # * 圖片消失
  #--------------------------------------------------------------------------
  def command_235
    screen.pictures[@params[0]].erase
    return true
  end
  #--------------------------------------------------------------------------
  # * 天氣配置
  #--------------------------------------------------------------------------
  def command_236
    return true if $game_temp.in_battle
    screen.weather(@params[0], @params[1], @params[2])
    @wait_count = @params[2] if @params[3]
    return true
  end
  #--------------------------------------------------------------------------
  # * 播放BGM
  #--------------------------------------------------------------------------
  def command_241
    @params[0].play
    return true
  end
  #--------------------------------------------------------------------------
  # * 淡出BGM
  #--------------------------------------------------------------------------
  def command_242
    RPG::BGM.fade(@params[0] * 1000)
    return true
  end
  #--------------------------------------------------------------------------
  # * 播放BGS
  #--------------------------------------------------------------------------
  def command_245
    @params[0].play
    return true
  end
  #--------------------------------------------------------------------------
  # * 淡出BGS
  #--------------------------------------------------------------------------
  def command_246
    RPG::BGS.fade(@params[0] * 1000)
    return true
  end
  #--------------------------------------------------------------------------
  # * 播放ME
  #--------------------------------------------------------------------------
  def command_249
    @params[0].play
    return true
  end
  #--------------------------------------------------------------------------
  # * 播放SE
  #--------------------------------------------------------------------------
  def command_250
    @params[0].play
    return true
  end
  #--------------------------------------------------------------------------
  # * 停止播放當前所有SE
  #--------------------------------------------------------------------------
  def command_251
    RPG::SE.stop
    return true
  end
  #--------------------------------------------------------------------------
  # * 作戰處理
  #--------------------------------------------------------------------------
  def command_301
    return true if $game_temp.in_battle
    if @params[0] == 0                      # 直接指定
      troop_id = @params[1]
    else                                    # 用變數指定
      troop_id = $game_variables[@params[1]]
    end
    if $data_troops[troop_id] != nil
      $game_troop.setup(troop_id)
      $game_troop.can_escape = @params[2]
      $game_troop.can_lose = @params[3]
      $game_temp.battle_proc = Proc.new { |n| @branch[@indent] = n }
      $game_temp.next_scene = "battle"
    end
    @index += 1
    return false
  end
  #--------------------------------------------------------------------------
  # * 作戰勝利的情況下
  #--------------------------------------------------------------------------
  def command_601
    if @branch[@indent] == 0
      @branch.delete(@indent)
      return true
    end
    return command_skip
  end
  #--------------------------------------------------------------------------
  # * 撤退的情況下
  #--------------------------------------------------------------------------
  def command_602
    if @branch[@indent] == 1
      @branch.delete(@indent)
      return true
    end
    return command_skip
  end
  #--------------------------------------------------------------------------
  # * 作戰失敗的情況下
  #--------------------------------------------------------------------------
  def command_603
    if @branch[@indent] == 2
      @branch.delete(@indent)
      return true
    end
    return command_skip
  end
  #--------------------------------------------------------------------------
  # * 交易處理
  #--------------------------------------------------------------------------
  def command_302
    $game_temp.next_scene = "shop"
    $game_temp.shop_goods = [@params]
    $game_temp.shop_purchase_only = @params[2]
    loop do
      @index += 1
      if @list[@index].code == 605 # 下一條事件指令在本指令後兩行以上的情況下
        $game_temp.shop_goods.push(@list[@index].parameters)
      else
        return false
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 名稱輸入處理
  #--------------------------------------------------------------------------
  def command_303
    if $data_actors[@params[0]] != nil
      $game_temp.next_scene = "name"
      $game_temp.name_actor_id = @params[0]
      $game_temp.name_max_char = @params[1]
    end
    @index += 1
    return false
  end
  #--------------------------------------------------------------------------
  # * MP調整
  #--------------------------------------------------------------------------
  def command_311
    value = operate_value(@params[1], @params[2], @params[3])
    iterate_actor_id(@params[0]) do |actor|
      next if actor.dead?
      if @params[4] == false and actor.hp + value <= 0
        actor.hp = 1    # 若不允許主角進入瀕死狀態則設為1
      else
        actor.hp += value
      end
      actor.perform_collapse
    end
    if $game_party.all_dead?
      $game_temp.next_scene = "gameover"
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * MP調整
  #--------------------------------------------------------------------------
  def command_312
    value = operate_value(@params[1], @params[2], @params[3])
    iterate_actor_id(@params[0]) do |actor|
      actor.mp += value
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * 狀態調整
  #--------------------------------------------------------------------------
  def command_313
    iterate_actor_id(@params[0]) do |actor|
      if @params[1] == 0
        actor.add_state(@params[2])
        actor.perform_collapse
      else
        actor.remove_state(@params[2])
      end
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * 恢復健康
  #--------------------------------------------------------------------------
  def command_314
    iterate_actor_id(@params[0]) do |actor|
      actor.recover_all
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * 主角EXP調整
  #--------------------------------------------------------------------------
  def command_315
    value = operate_value(@params[1], @params[2], @params[3])
    iterate_actor_id(@params[0]) do |actor|
      actor.change_exp(actor.exp + value, @params[4])
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * 主角等級調整
  #--------------------------------------------------------------------------
  def command_316
    value = operate_value(@params[1], @params[2], @params[3])
    iterate_actor_id(@params[0]) do |actor|
      actor.change_level(actor.level + value, @params[4])
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * 主角能力參數調整
  #--------------------------------------------------------------------------
  def command_317
    value = operate_value(@params[2], @params[3], @params[4])
    actor = $game_actors[@params[0]]
    if actor != nil
      case @params[1]
      when 0  # HP上限值
        actor.maxhp += value
      when 1  # MP上限值
        actor.maxmp += value
      when 2  # 攻擊力
        actor.atk += value
      when 3  # 防禦力
        actor.def += value
      when 4  # 精神意志力
        actor.spi += value
      when 5  # 敏捷力
        actor.agi += value
      end
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * 主角技能調整
  #--------------------------------------------------------------------------
  def command_318
    actor = $game_actors[@params[0]]
    if actor != nil
      if @params[1] == 0
        actor.learn_skill(@params[2])
      else
        actor.forget_skill(@params[2])
      end
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * 主角裝備調整
  #--------------------------------------------------------------------------
  def command_319
    actor = $game_actors[@params[0]]
    if actor != nil
      actor.change_equip_by_id(@params[1], @params[2])
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * 修改主角名稱
  #--------------------------------------------------------------------------
  def command_320
    actor = $game_actors[@params[0]]
    if actor != nil
      actor.name = @params[1]
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * 主角職業變更
  #--------------------------------------------------------------------------
  def command_321
    actor = $game_actors[@params[0]]
    if actor != nil and $data_classes[@params[1]] != nil
      actor.class_id = @params[1]
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * 更改主角步行圖/臉圖
  #--------------------------------------------------------------------------
  def command_322
    actor = $game_actors[@params[0]]
    if actor != nil
      actor.set_graphic(@params[1], @params[2], @params[3], @params[4])
    end
    $game_player.refresh
    return true
  end
  #--------------------------------------------------------------------------
  # * 更改交通工具步行圖
  #--------------------------------------------------------------------------
  def command_323
    if @params[0] == 0                      # 舟
      $game_map.boat.set_graphic(@params[1], @params[2])
    elsif @params[0] == 1                   # 船
      $game_map.ship.set_graphic(@params[1], @params[2])
    else                                    # 飛艇
      $game_map.airship.set_graphic(@params[1], @params[2])
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * 調整敵人HP
  #--------------------------------------------------------------------------
  def command_331
    value = operate_value(@params[1], @params[2], @params[3])
    iterate_enemy_index(@params[0]) do |enemy|
      if enemy.hp > 0
        if @params[4] == false and enemy.hp + value <= 0
          enemy.hp = 1    # 如果不允許敵人掛掉則設為1
        else
          enemy.hp += value
        end
        enemy.perform_collapse
      end
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * 調整敵人MP
  #--------------------------------------------------------------------------
  def command_332
    value = operate_value(@params[1], @params[2], @params[3])
    iterate_enemy_index(@params[0]) do |enemy|
      enemy.mp += value
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * 調整敵人狀態
  #--------------------------------------------------------------------------
  def command_333
    iterate_enemy_index(@params[0]) do |enemy|
      if @params[2] == 1                    # 如果改變了允許掛掉的狀態
        enemy.immortal = false              # 清除[不敗之身]標幟
      end
      if @params[1] == 0
        enemy.add_state(@params[2])
        enemy.perform_collapse
      else
        enemy.remove_state(@params[2])
      end
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * 恢復敵人健康
  #--------------------------------------------------------------------------
  def command_334
    iterate_enemy_index(@params[0]) do |enemy|
      enemy.recover_all
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * 敵方增加敵人
  #--------------------------------------------------------------------------
  def command_335
    enemy = $game_troop.members[@params[0]]
    if enemy != nil and enemy.hidden
      enemy.hidden = false
      $game_troop.make_unique_names
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * 敵方敵人變身
  #--------------------------------------------------------------------------
  def command_336
    enemy = $game_troop.members[@params[0]]
    if enemy != nil
      enemy.transform(@params[1])
      $game_troop.make_unique_names
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * 顯示作戰動畫
  #--------------------------------------------------------------------------
  def command_337
    iterate_battler(0, @params[0]) do |battler|
      next unless battler.exist?
      battler.animation_id = @params[1]
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * 強制下達指令
  #--------------------------------------------------------------------------
  def command_339
    iterate_battler(@params[0], @params[1]) do |battler|
      next unless battler.exist?
      battler.action.kind = @params[2]
      if battler.action.kind == 0
        battler.action.basic = @params[3]
      else
        battler.action.skill_id = @params[3]
      end
      if @params[4] == -2                   # 選取最後的目標
        battler.action.decide_last_target
      elsif @params[4] == -1                # 隨機選取
        battler.action.decide_random_target
      elsif @params[4] >= 0                 # 指定編號
        battler.action.target_index = @params[4]
      end
      battler.action.forcing = true
      $game_troop.forcing_battler = battler
      @index += 1
      return false
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * 結束作戰
  #--------------------------------------------------------------------------
  def command_340
    $game_temp.next_scene = "map"
    @index += 1
    return false
  end
  #--------------------------------------------------------------------------
  # * 打開ESC選單畫面
  #--------------------------------------------------------------------------
  def command_351
    $game_temp.next_scene = "menu"
    $game_temp.menu_beep = false
    @index += 1
    return false
  end
  #--------------------------------------------------------------------------
  # * 打開存檔畫面
  #--------------------------------------------------------------------------
  def command_352
    $game_temp.next_scene = "save"
    @index += 1
    return false
  end
  #--------------------------------------------------------------------------
  # * 遊戲結束
  #--------------------------------------------------------------------------
  def command_353
    $game_temp.next_scene = "gameover"
    return false
  end
  #--------------------------------------------------------------------------
  # * 返回標題畫面
  #--------------------------------------------------------------------------
  def command_354
    $game_temp.next_scene = "title"
    return false
  end
  #--------------------------------------------------------------------------
  # * 執行RGSS腳本語句
  #--------------------------------------------------------------------------
  def command_355
    script = @list[@index].parameters[0] + "\n"
    loop do
      # 下一條事件指令在本指令後兩行以上的情況下
      if @list[@index+1].code == 655
        script += @list[@index+1].parameters[0] + "\n"
      else
        break
      end
      @index += 1
    end
    eval(script)
    return true
  end
end
