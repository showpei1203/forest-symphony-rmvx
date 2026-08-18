#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：MenuWindow_NoCursor｜Selectable + Command Core
# 【用途】UI／選單元件「MenuWindow_NoCursor｜Selectable + Command Core」。
# 【主要機制】擴充 Window／Scene／Sprite 顯示或操作；最終外觀可能由後載入 FS UI Patch 接管。
# 【主要影響】Window_Selectable_New、Window_Command_New
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
# PHASE 8 AUTHORITY: MenuWindow_NoCursor｜Selectable + Command Core
# Main Menu Melody 使用的無游標 Selectable/Command 基礎類。
# Original load order: 192:Window_Selectable_menu -> 193:Window_Command_menu
#==============================================================================
# PHASE8 ORIGINAL PAGE: 192 | Window_Selectable_menu
#==============================================================================
#==============================================================================
# ■ Window_Selectable
#------------------------------------------------------------------------------
# 　拥有光标的移动以及滚动功能的窗口类。
#   此为光标不显示之用。
#==============================================================================

class Window_Selectable_New < Window_Base
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_reader   :item_max                 # 选项数
  attr_reader   :column_max               # 行数
  attr_reader   :index                    # 光标位置
  attr_reader   :help_window              # 帮助窗口
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #     x      : 窗口 X 座标
  #     y      : 窗口 Y 座标
  #     width  : 窗口宽度
  #     height : 窗口高度
  #     spacing : 横向排列时栏间空格
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height, spacing = 32)
    @item_max = 1
    @column_max = 1
    @index = -1
    @spacing = spacing
    super(x, y, width, height)
  end
  #--------------------------------------------------------------------------
  # ● 生成窗口内容
  #--------------------------------------------------------------------------
  def create_contents
    self.contents.dispose
    self.contents = Bitmap.new(width - 32, [height - 32, row_max * WLH].max)
  end
  #--------------------------------------------------------------------------
  # ● 设置光标位置
  #     index : 新光标位置
  #--------------------------------------------------------------------------
  def index=(index)
    @index = index
    update_cursor
    call_update_help
  end
  #--------------------------------------------------------------------------
  # ● 计算行数
  #--------------------------------------------------------------------------
  def row_max
    return (@item_max + @column_max - 1) / @column_max
  end
  #--------------------------------------------------------------------------
  # ● 获取首行
  #--------------------------------------------------------------------------
  def top_row
    return self.oy / WLH 
  end
  #--------------------------------------------------------------------------
  # ● 设置首行
  #     row : 显示在最上的行
  #--------------------------------------------------------------------------
  def top_row=(row)
    row = 0 if row < 0
    row = row_max - 1 if row > row_max - 1
    self.oy = row * WLH
  end
  #--------------------------------------------------------------------------
  # ● 获取一页能显示的行数
  #--------------------------------------------------------------------------
  def page_row_max
    return (self.height - 32) / WLH
  end
  #--------------------------------------------------------------------------
  # ● 获取一页能显示的选项
  #--------------------------------------------------------------------------
  def page_item_max
    return page_row_max * @column_max
  end
  #--------------------------------------------------------------------------
  # ● 获取末行
  #--------------------------------------------------------------------------
  def bottom_row
    return top_row + page_row_max - 1
  end
  #--------------------------------------------------------------------------
  # ● 设置末行
  #     row : 显示在最底的行
  #--------------------------------------------------------------------------
  def bottom_row=(row)
    self.top_row = row - (page_row_max - 1)
  end
  #--------------------------------------------------------------------------
  # ● 设置选项矩形
  #     index : 项目编号
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = Rect.new(0, 0, 0, 0)
    rect.width = (contents.width + @spacing) / @column_max - @spacing
    rect.height = WLH#WLH
    rect.x = index % @column_max * (rect.width + @spacing)
    rect.y = index / @column_max * 32
    #rect.y = index / @column_max * WLH
    return rect
  end
  #--------------------------------------------------------------------------
  # ● 设置帮助窗口
  #     help_window : 新帮助窗口
  #--------------------------------------------------------------------------
  def help_window=(help_window)
    @help_window = help_window
    call_update_help
  end
  #--------------------------------------------------------------------------
  # ● 判断光标是否能够移动
  #--------------------------------------------------------------------------
  def cursor_movable?
    return false if (not visible or not active)
    return false if (index < 0 or index > @item_max or @item_max == 0)
    return false if (@opening or @closing)
    return true
  end
  #--------------------------------------------------------------------------
  # ● 光标下移
  #     wrap : 允许循环
  #--------------------------------------------------------------------------
  def cursor_down(wrap = false)
    if (@index < @item_max - @column_max) or (wrap and @column_max == 1)
      @index = (@index + @column_max) % @item_max
    end
  end
  #--------------------------------------------------------------------------
  # ● 光标上移
  #     wrap : 允许循环
  #--------------------------------------------------------------------------
  def cursor_up(wrap = false)
    if (@index >= @column_max) or (wrap and @column_max == 1)
      @index = (@index - @column_max + @item_max) % @item_max
    end
  end
  #--------------------------------------------------------------------------
  # ● 光标右移
  #     wrap : 允许循环
  #--------------------------------------------------------------------------
  def cursor_right(wrap = false)
    if (@column_max >= 2) and
       (@index < @item_max - 1 or (wrap and page_row_max == 1))
      @index = (@index + 1) % @item_max
    end
  end
  #--------------------------------------------------------------------------
  # ● 光标左移
  #     wrap : 允许循环
  #--------------------------------------------------------------------------
  def cursor_left(wrap = false)
    if (@column_max >= 2) and
       (@index > 0 or (wrap and page_row_max == 1))
      @index = (@index - 1 + @item_max) % @item_max
    end
  end
  #--------------------------------------------------------------------------
  # ● 光标移至下一页
  #--------------------------------------------------------------------------
  def cursor_pagedown
    if top_row + page_row_max < row_max
      @index = [@index + page_item_max, @item_max - 1].min
      self.top_row += page_row_max
    end
  end
  #--------------------------------------------------------------------------
  # ● 光标移至上一页
  #--------------------------------------------------------------------------
  def cursor_pageup
    if top_row > 0
      @index = [@index - page_item_max, 0].max
      self.top_row -= page_row_max
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    super
    if cursor_movable?
      last_index = @index
      if Input.repeat?(Input::DOWN)
        cursor_down(Input.trigger?(Input::DOWN))
      end
      if Input.repeat?(Input::UP)
        cursor_up(Input.trigger?(Input::UP))
      end
      if Input.repeat?(Input::RIGHT)
        cursor_right(Input.trigger?(Input::RIGHT))
      end
      if Input.repeat?(Input::LEFT)
        cursor_left(Input.trigger?(Input::LEFT))
      end
      if Input.repeat?(Input::R)
        cursor_pagedown
      end
      if Input.repeat?(Input::L)
        cursor_pageup
      end
      if @index != last_index
        Sound.play_cursor
      end
    end
    update_cursor
    call_update_help
  end
  #--------------------------------------------------------------------------
  # ● 更新光标
  #--------------------------------------------------------------------------
  def update_cursor
    if @index < 0                   # 当光标位置小于0
      self.cursor_rect.empty        # 隐藏光标
    else                            # 当光标位置为0或大于
      row = @index / @column_max    # 获取当前行
      if row < top_row              # 若先于首行
        self.top_row = row          # 向上滚动
      end
      if row > bottom_row           # 若後于末行
        self.bottom_row = row       # 向下滚动
      end
      rect = item_rect(@index)      # 获取所选项目矩形
      rect.y -= self.oy             # 设矩形为滚动位置
      self.cursor_rect = rect       # 更新光标矩形
      #-----------
      self.cursor_rect.empty        # 隐藏光标
      #-----------
    end
  end
  #--------------------------------------------------------------------------
  # ● 呼叫更新帮助窗口
  #--------------------------------------------------------------------------
  def call_update_help
    if self.active and @help_window != nil
       update_help
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新帮助窗口（子类定义）
  #--------------------------------------------------------------------------
  def update_help
  end
end

#==============================================================================
# PHASE8 ORIGINAL PAGE: 193 | Window_Command_menu
#==============================================================================
#==============================================================================
# ■ Window_Command
#------------------------------------------------------------------------------
# 　菜单的命令选择行窗口。
#   此为光标不显示之用。
#==============================================================================

class Window_Command_New < Window_Selectable_New
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_reader   :commands                 # 命令
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #     x      : 窗口 X 座标
  #     y      : 窗口 Y 座标
  #     width  : 窗口宽度
  #     height : 窗口高度
  #     spacing : 横向排列时栏间空格
  #--------------------------------------------------------------------------
  def initialize(width, commands, column_max = 1, row_max = 0, spacing = 32)
    if row_max == 0
      row_max = (commands.size + column_max - 1) / column_max
    end
    super(0, 0, width, row_max * WLH + 32+40, spacing)
    @commands = commands
    @item_max = commands.size
    @column_max = column_max
    refresh
    self.index = 0
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    for i in 0...@item_max
      draw_item(i)
    end
  end
  #--------------------------------------------------------------------------
  # ● 绘制项目
  #     index   : 项目位置
  #     enabled : 有效标志，false时项目半透明化
  #--------------------------------------------------------------------------
  def draw_item(index, enabled = true)
    rect = item_rect(index)
    rect.x += 4
    rect.width -= 8
    self.contents.clear_rect(rect)
    self.contents.font.color = normal_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    self.contents.draw_text(rect, @commands[index])
  end
end
