#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Window_Selectable
# 【用途】可選取視窗父類，處理 index、游標、捲動與鍵盤輸入。
# 【主要機制】由各 Scene 建立並逐幀更新；後續 UI 插件通常以 class reopen／alias 擴充。
# 【主要影響】Window_Selectable
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
# ** Window_Selectable
#------------------------------------------------------------------------------
#  這種視窗具有游標移動和內容滾動顯示等功能。
#==============================================================================

class Window_Selectable < Window_Base
  #--------------------------------------------------------------------------
  # * 宣告執行個體變數
  #--------------------------------------------------------------------------
  attr_reader   :item_max                 # 條目數
  attr_reader   :column_max               # 縱欄數
  attr_reader   :index                    # 游標位置
  attr_reader   :help_window              # 關聯的動態説明視窗
  #--------------------------------------------------------------------------
  # * 物件初始化
  #     x       : 視窗X座標
  #     y       : 視窗Y座標
  #     width   : 視窗寬度
  #     height  : 視窗高度
  #     spacing : 條目水準分佈時的間距大小
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height, spacing = 32)
    @item_max = 1
    @column_max = 1
    @index = -1
    @spacing = spacing
    @count = 11
    @count2 = 11
    super(x, y, width, height)
  end
  #--------------------------------------------------------------------------
  # * 創建視窗內容
  #--------------------------------------------------------------------------
  def create_contents
    self.contents.dispose
    self.contents = Bitmap.new(width - 32, [height - 32, row_max * WLH].max)
  end
  #--------------------------------------------------------------------------
  # * 設置游標位置
  #     index : 新的游標位置
  #--------------------------------------------------------------------------
  def index=(index)
    @index = index
    update_cursor
    call_update_help
  end
  #--------------------------------------------------------------------------
  # * 獲取總橫行數
  #--------------------------------------------------------------------------
  def row_max
    return (@item_max + @column_max - 1) / @column_max
  end
  #--------------------------------------------------------------------------
  # * 獲取首個橫行的資訊
  #--------------------------------------------------------------------------
  def top_row
    return self.oy / WLH
  end
  #--------------------------------------------------------------------------
  # * 設置首個橫行[在螢幕最頂部顯示的橫行]
  #     row : 在螢幕最頂部顯示的橫行
  #--------------------------------------------------------------------------
  def top_row=(row)
    row = 0 if row < 0
    row = row_max - 1 if row > row_max - 1
    self.oy = row * WLH
  end
  #--------------------------------------------------------------------------
  # * 獲取一頁可以顯示的橫行數
  #--------------------------------------------------------------------------
  def page_row_max
    return (self.height - 32) / WLH
  end
  #--------------------------------------------------------------------------
  # * 獲取一頁可以顯示的條目數
  #--------------------------------------------------------------------------
  def page_item_max
    return page_row_max * @column_max
  end
  #--------------------------------------------------------------------------
  # * 獲取最後一橫行的資訊
  #--------------------------------------------------------------------------
  def bottom_row
    return top_row + page_row_max - 1
  end
  #--------------------------------------------------------------------------
  # * 設置最後一行的資訊[在螢幕最底部顯示的橫行]
  #     row : 在螢幕最底部顯示的橫行
  #--------------------------------------------------------------------------
  def bottom_row=(row)
    self.top_row = row - (page_row_max - 1)
  end
  #--------------------------------------------------------------------------
  # * 獲取顯示條目所用的矩形區域資訊
  #     index : 條目編號
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = Rect.new(0, 0, 0, 0)
    rect.width = (contents.width + @spacing) / @column_max - @spacing
    rect.height = WLH
    rect.x = index % @column_max * (rect.width + @spacing)
    rect.y = index / @column_max * WLH
    return rect
  end
  #--------------------------------------------------------------------------
  # * 關聯動態説明視窗
  #     help_window : 新的説明視窗
  #--------------------------------------------------------------------------
  def help_window=(help_window)
    @help_window = help_window
    call_update_help
  end
  #--------------------------------------------------------------------------
  # * 判定游標是否可以移動
  #--------------------------------------------------------------------------
  def cursor_movable?
    return false if (not visible or not active)
    return false if (index < 0 or index > @item_max or @item_max == 0)
    return false if (@opening or @closing)
    return true
  end
  #--------------------------------------------------------------------------
  # * 游標下移
  #     wrap : 允許自動換行
  #--------------------------------------------------------------------------
  def cursor_down(wrap = false)
    if (@index < @item_max - @column_max) or (wrap and @column_max == 1)
      @index = (@index + @column_max) % @item_max
    end
  end
  #--------------------------------------------------------------------------
  # * 游標上移
  #     wrap : 允許自動換行
  #--------------------------------------------------------------------------
  def cursor_up(wrap = false)
    if (@index >= @column_max) or (wrap and @column_max == 1)
      @index = (@index - @column_max + @item_max) % @item_max
    end
  end
  #--------------------------------------------------------------------------
  # * 游標右移
  #     wrap : 允許自動換行
  #--------------------------------------------------------------------------
  def cursor_right(wrap = false)
    if (@column_max >= 2) and
       (@index < @item_max - 1 or (wrap and page_row_max == 1))
      @index = (@index + 1) % @item_max
    end
  end
  #--------------------------------------------------------------------------
  # * 游標左移
  #     wrap : 允許自動換行
  #--------------------------------------------------------------------------
  def cursor_left(wrap = false)
    if (@column_max >= 2) and
       (@index > 0 or (wrap and page_row_max == 1))
      @index = (@index - 1 + @item_max) % @item_max
    end
  end
  #--------------------------------------------------------------------------
  # * 游標移至下一頁
  #--------------------------------------------------------------------------
  def cursor_pagedown
    if top_row + page_row_max < row_max
      @index = [@index + page_item_max, @item_max - 1].min
      self.top_row += page_row_max
    end
  end
  #--------------------------------------------------------------------------
  # * 游標移至上一頁
  #--------------------------------------------------------------------------
  def cursor_pageup
    if top_row > 0
      @index = [@index - page_item_max, 0].max
      self.top_row -= page_row_max
    end
  end
  #--------------------------------------------------------------------------
  # * 更新幀
  #--------------------------------------------------------------------------
  def update
    super
    if cursor_movable?
      last_index = @index
      if @count <= 10
          self.cursor_rect.y += 2 if @count == 2
          self.cursor_rect.y-= 2 if @count == 4
          self.cursor_rect.y += 2 if @count == 6
          self.cursor_rect.y -= 2 if @count == 8
          @count += 1
      end
      if @count2 <= 10
          self.cursor_rect.x += 4 if @count2 == 2
          self.cursor_rect.x-= 4 if @count2 == 4
          self.cursor_rect.x += 4 if @count2 == 6
          self.cursor_rect.x -= 4 if @count2 == 8
          @count2 += 1
      end  
      if Input.repeat?(Input::DOWN)
        cursor_down(Input.trigger?(Input::DOWN)) 
        @count = 0
      end
      if Input.repeat?(Input::UP)
        cursor_up(Input.trigger?(Input::UP))
        @count = 0
      end
      if Input.repeat?(Input::RIGHT)
        cursor_right(Input.trigger?(Input::RIGHT))
        @count2 = 0
      end
      if Input.repeat?(Input::LEFT)
        cursor_left(Input.trigger?(Input::LEFT))
        @count2 = 0
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
  # * 更新游標繪製
  #--------------------------------------------------------------------------
  def update_cursor
    if @index < 0                   # 游標位置編號小於零
      self.cursor_rect.empty        # 清除游標顯示
    else                            # 游標位置編號大於等於零
      row = @index / @column_max    # 獲取當前行資訊
      if row < top_row              # 如果要顯示的行在螢幕最頂部顯示的行之前
        self.top_row = row          # 視窗內容向上滾動
      end
      if row > bottom_row           # 如果要顯示的行在螢幕最底部顯示的行之後
        self.bottom_row = row       # 視窗內容向下滾動
      end
      rect = item_rect(@index)      # 獲取被選擇的條目的矩形區域資訊
      rect.y -= self.oy             # 匹配矩形區域以滾動位置
      self.cursor_rect = rect       # 更新游標矩形
    end
  end
  #--------------------------------------------------------------------------
  # * 調用動態説明視窗內容更新的方法
  #--------------------------------------------------------------------------
  def call_update_help
    if self.active and @help_window != nil
       update_help
    end
  end
  #--------------------------------------------------------------------------
  # * 更新動態説明視窗內容資訊（其內容由本類的子類定義）
  #--------------------------------------------------------------------------
  def update_help
  end
end
