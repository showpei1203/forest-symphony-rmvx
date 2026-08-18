#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：贪吃蛇小游戏
# 【用途】保留的 Runtime 元件「贪吃蛇小游戏」。
# 【主要機制】主要定義／擴充 Scene_Snake；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Scene_Snake
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
# ■ Scene_Snake
#------------------------------------------------------------------------------
# 　贪吃蛇小游戏
#==============================================================================

class Scene_Snake
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize
     $SIZE = 30 # 图块大小
     $WIDTH = 30 * 16 #界面宽度
     $HEIGHT = 30 * 16 #界面高度
     @score = 0 # 初始分数
     @level = 1 # 初始化难度等级
     @max_length =  35 # 初始化贪吃蛇最大长度
     @array_snake = [[3,6],[4,6],[5,6],[6,6],[7,6],[8,6],[9,6]] # 初始化贪吃蛇
     @speed = 7 # 初始化速度,数值越大，移动速度越慢
     @direction = "left"  # 初始化方向
     @run = false # 初始化贪吃蛇是否为运动状态
     @time_count = 0 # 计时器
     @food_exist = false # 标记食物是否存在
  end
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    # 贪吃蛇背景
    @sprite = Sprite.new
    @sprite.bitmap = Bitmap.new(640,480)
    @sprite.bitmap.fill_rect(0, 0, 640, 480, Color.new(0,0,0))
    # 初始化屏幕
    @sprite_clear = Sprite.new
    @sprite_clear.bitmap = Bitmap.new($WIDTH,$HEIGHT)
    @sprite_clear.bitmap.fill_rect(0, 0, $WIDTH, $HEIGHT, Color.new(0,255,255))
    @sprite_clear.bitmap.fill_rect(2, 2, $WIDTH - 4, $HEIGHT - 4, Color.new(0,0,0))
    # 显示得分
    @sprite_score = Sprite.new
    @sprite_score.bitmap = Bitmap.new(640 - $WIDTH,$HEIGHT)
    @sprite_score.x = 480
    @sprite_score.y = 0
    refresh_score
    # 初始化蛇的图形
    @sprite_snake = []
    for i in 0...@array_snake.length
      @sprite_snake[i] = Sprite.new
      @sprite_snake[i].bitmap = Bitmap.new($SIZE,$SIZE)
      @sprite_snake[i].x = @array_snake[i][0] * $SIZE
      @sprite_snake[i].y = @array_snake[i][1] * $SIZE
      @sprite_snake[i].bitmap.clear
      @sprite_snake[i].bitmap.fill_rect(0, 0, $SIZE, $SIZE, Color.new(0,0,0))
      @sprite_snake[i].bitmap.fill_rect(2, 2, $SIZE - 4, $SIZE - 4, Color.new(150,150,150))
      @sprite_snake[i].bitmap.fill_rect(5, 5, $SIZE - 10, $SIZE - 10, Color.new(255,255,255))
    end
    # 描绘食物
    @sprite_food = Sprite.new
    @sprite_food.bitmap = Bitmap.new($SIZE,$SIZE)
    # 执行过渡
    Graphics.transition
    # 主循环
    loop do
      # 刷新游戏画面
      Graphics.update
      # 刷新输入信息
      Input.update
      # 刷新画面情报
      update
      # 如果画面被切换的话就中断循环
      if $scene != self
        break
      end
    end
    # 准备过渡
    Graphics.freeze
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    # 如果食物不存在则描绘食物
    if @food_exist == false
      draw_food # 描绘食物
      @food_exist = true
    end
    # 开始运动
    start_move
    # 如果贪吃蛇正在运动
    if @run
      if @time_count%@speed == 0
        move # 移动
        # 吃到食物
        if check_eat
          # 刷新得分
          @score += 1
          # 刷新等级
          if @score >= @level * 20
            @level += 1
            @speed -= 1
            if @level > 6
              p "恭喜你，你已成功通关！"
              exit
            end
          end
          refresh_score
          # 增加贪吃蛇长度
          if @array_snake.length < @max_length
            @array_snake.push([@array_snake[@array_snake.length-1][0],
            @array_snake[@array_snake.length-1][1]])
            @sprite_snake[@array_snake.length-1] = Sprite.new
            @sprite_snake[@array_snake.length-1].bitmap = Bitmap.new($SIZE,$SIZE)
          end
          @food_exist = false
        end
        # 如果撞到墙壁或自身则游戏结束
        if check_collision
          game_over
        end
      end
    end
    @time_count += 1
  end
  # 开始运动
  def start_move
    # 按下方向键后开始运动
    if Input.trigger?(Input::UP)
      unless @direction == "down"
        @run = true
        @direction = "up"
      end
    end
    if Input.trigger?(Input::DOWN)
      unless @direction == "up"
        @run = true
        @direction = "down"
      end
    end
    if Input.trigger?(Input::LEFT)
      unless @direction == "right"
        @run = true
        @direction = "left"
      end
    end
    if Input.trigger?(Input::RIGHT)
      unless @direction == "left"
        @run = true
        @direction = "right"
      end
    end
  end
  # 贪吃蛇移动
  def move
    case @direction
    when "up"
      for i in 1...@array_snake.length
        @array_snake[@array_snake.length-i][0] = @array_snake[@array_snake.length-i-1][0]
        @array_snake[@array_snake.length-i][1] = @array_snake[@array_snake.length-i-1][1]
      end
      @array_snake[0][1] -= 1
    when "down"
      for i in 1...@array_snake.length
        @array_snake[@array_snake.length-i][0] = @array_snake[@array_snake.length-i-1][0]
        @array_snake[@array_snake.length-i][1] = @array_snake[@array_snake.length-i-1][1]
      end
      @array_snake[0][1] += 1
    when "left"
      for i in 1...@array_snake.length
        @array_snake[@array_snake.length-i][0] = @array_snake[@array_snake.length-i-1][0]
        @array_snake[@array_snake.length-i][1] = @array_snake[@array_snake.length-i-1][1]
      end
      @array_snake[0][0] -= 1
    when "right"
      for i in 1...@array_snake.length
        @array_snake[@array_snake.length-i][0] = @array_snake[@array_snake.length-i-1][0]
        @array_snake[@array_snake.length-i][1] = @array_snake[@array_snake.length-i-1][1]
      end
      @array_snake[0][0] += 1
    end
    draw_snake # 描绘贪吃蛇
  end
  # 清屏
  def clear_screen
    @sprite_clear = Sprite.new
    @sprite_clear.bitmap = Bitmap.new($WIDTH,$HEIGHT)
    @sprite_clear.bitmap.clear
    @sprite_clear.bitmap.fill_rect(0, 0, $WIDTH, $HEIGHT, Color.new(0,255,255))
    @sprite_clear.bitmap.fill_rect(2, 2, $WIDTH - 4, $HEIGHT - 4, Color.new(0,0,0))
  end
  # 刷新得分
  def refresh_score
    @sprite_score.bitmap.clear
    @sprite_score.bitmap.font.size = 18
    @sprite_score.bitmap.draw_text(10, 0, 160, 32, "您的得分为：" + @score.to_s)
    @sprite_score.bitmap.draw_text(10, 32, 160, 32, "蛇身长度为：" + @array_snake.length.to_s)
    @sprite_score.bitmap.draw_text(10, 64, 160, 32, "当前等级为：" + @level.to_s) 
    @sprite_score.bitmap.draw_text(10, 440, 160, 32, "程序设计：flyfairy") 
  end
  # 描绘图块
  def draw_spriteset(x,y)
    @sprite_spriteset = Sprite.new
    @sprite_spriteset.bitmap = Bitmap.new($SIZE,$SIZE)
    @sprite_spriteset.x = x 
    @sprite_spriteset.y = y
    @sprite_spriteset.bitmap.clear
    @sprite_spriteset.bitmap.fill_rect(0, 0, $SIZE, $SIZE, Color.new(0,0,0))
    @sprite_spriteset.bitmap.fill_rect(2, 2, $SIZE - 4, $SIZE - 4, Color.new(150,150,150))
    @sprite_spriteset.bitmap.fill_rect(5, 5, $SIZE - 10, $SIZE - 10, Color.new(255,255,255))
  end
  # 生成食物坐标
  def creat_food
    loop do
      food_x = rand(16)
      food_y = rand(16)
      creat_succes = true # 标记是否成功生成的开关
      for i in 0...@array_snake.length
        if food_x == @array_snake[i][0] and food_y == @array_snake[i][1]
          creat_succes = false
        end
      end
      # 如果成功生成食物则中断循环
      if creat_succes
        return food_x * $SIZE,food_y * $SIZE
        break
      end
    end
  end
  # 描绘食物
  def draw_food
    @food_x,@food_y = creat_food
    @sprite_food.bitmap.clear
    @sprite_food.x = @food_x
    @sprite_food.y = @food_y
    @sprite_food.bitmap.fill_rect(0, 0, $SIZE, $SIZE, Color.new(0,0,0))
    @sprite_food.bitmap.fill_rect(2, 2, $SIZE - 4, $SIZE - 4, Color.new(50,50,200))
    @sprite_food.bitmap.fill_rect(5, 5, $SIZE - 10, $SIZE - 10, Color.new(250,50,50))
  end
  # 描绘蛇的图形
  def draw_snake
    for i in 0...@array_snake.length
      @sprite_snake[i].x = @array_snake[i][0] * $SIZE
      @sprite_snake[i].y = @array_snake[i][1] * $SIZE
      @sprite_snake[i].bitmap.clear
      @sprite_snake[i].bitmap.fill_rect(0, 0, $SIZE, $SIZE, Color.new(0,0,0))
      @sprite_snake[i].bitmap.fill_rect(2, 2, $SIZE - 4, $SIZE - 4, Color.new(150,150,150))
      @sprite_snake[i].bitmap.fill_rect(5, 5, $SIZE - 10, $SIZE - 10, Color.new(255,255,255))
    end
  end
  # 检测贪吃蛇是否撞到墙壁或自身
  def check_collision
    if @array_snake[0][0] < 0 or @array_snake[0][0] > 15 or
      @array_snake[0][1] < 0 or @array_snake[0][1] > 15 
      return true
    end
    for i in 1...@array_snake.length 
      if @array_snake[0][0] == @array_snake[i][0] and
        @array_snake[0][1] == @array_snake[i][1]
        return true
      end
    end
    return false
  end
  # 检测是否吃到食物
  def check_eat
    if @array_snake[0][0] == @food_x/$SIZE and @array_snake[0][1] == @food_y/$SIZE
      return true
    end
  end
  # 游戏结束的处理
  def game_over
    print "很遗憾，游戏结束!你的游戏得分为：#{@score}"
    exit
  end
end
