#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Window_Message
# 【用途】VX 訊息視窗核心，顯示文字、臉圖、選項與數字輸入。
# 【主要機制】由各 Scene 建立並逐幀更新；後續 UI 插件通常以 class reopen／alias 擴充。
# 【主要影響】Window_Message
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：MAX_LINE。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】保持目前已驗證的相對順序；搬動前先反查 class reopen／alias／事件入口。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁直接引用：MessageBack。刪除／改名素材前必須反查其他腳本與 Data／事件是否共用。
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
# ** Window_Message
#------------------------------------------------------------------------------
#  本視窗用來顯示文本訊息。
#==============================================================================

class Window_Message < Window_Selectable
  #--------------------------------------------------------------------------
  # * 常數
  #--------------------------------------------------------------------------
  MAX_LINE = 4                            # 行數上限
  #--------------------------------------------------------------------------
  # * 物件初始化
  #--------------------------------------------------------------------------
  def initialize
    super(0, 288, 544, 128)
    self.z = 200
    self.active = false
    self.index = -1
    self.openness = 0
    @opening = false            # 視窗展開的標幟
    @closing = false            # 視窗合攏的標幟
    @text = nil                 # 剩餘的要顯示的文本
    @contents_x = 0             # 要繪製的下一個字元的X座標
    @contents_y = 0             # 要繪製的下一個字元的Y座標
    @line_count = 0             # 到目前為止已經繪製的行數總計
    @wait_count = 0             # 等待次數總計
    @background = 0             # 視窗風格類型（0-普通，1-圖片，2-透明背景）
    @position = 2               # 視窗顯示位置
    @show_fast = false          # 快速前進標幟
    @line_show_fast = false     # 按行快速前進標幟
    @pause_skip = false         # 輸入待命省略標幟
    create_gold_window
    create_number_input_window
    create_back_sprite
  end
  #--------------------------------------------------------------------------
  # * 清除視窗
  #--------------------------------------------------------------------------
  def dispose
    super
    dispose_gold_window
    dispose_number_input_window
    dispose_back_sprite
  end
  #--------------------------------------------------------------------------
  # * 更新幀
  #--------------------------------------------------------------------------
  def update
    super
    update_gold_window
    update_number_input_window
    update_back_sprite
    update_show_fast
    unless @opening or @closing             # 視窗不是處於正在展開或合攏的狀態
      if @wait_count > 0                    # 等待于文本範圍內
        @wait_count -= 1
      elsif self.pause                      # 等待文本量增加
        input_pause
      elsif self.active                     # 輸入選擇資訊
        input_choice
      elsif @number_input_window.visible    # 輸入數字資訊
        input_number
      elsif @text != nil                    # 存在更多的文本
        update_message                        # 更新訊息
      elsif continue?                       # 文本持續顯示中
        start_message                         # 訊息顯示開始
        open                                  # 展開視窗
        $game_message.visible = true
      else                                  # 不再繼續顯示文本
        close                                 # 合攏視窗
        $game_message.visible = @closing
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 創建所攜資金資訊視窗
  #--------------------------------------------------------------------------
  def create_gold_window
    @gold_window = Window_Gold.new(384, 0)
    @gold_window.openness = 0
  end
  #--------------------------------------------------------------------------
  # * 創建數字輸入視窗
  #--------------------------------------------------------------------------
  def create_number_input_window
    @number_input_window = Window_NumberInput.new
    @number_input_window.visible = false
  end
  #--------------------------------------------------------------------------
  # * 繪製視窗底部皮膚圖片（精靈物設）
  #--------------------------------------------------------------------------
  def create_back_sprite
    @back_sprite = Sprite.new
    @back_sprite.bitmap = Cache.system("MessageBack")
    @back_sprite.visible = (@background == 1)
    @back_sprite.z = 190
  end
  #--------------------------------------------------------------------------
  # * 清除所攜資金資訊視窗
  #--------------------------------------------------------------------------
  def dispose_gold_window
    @gold_window.dispose
  end
  #--------------------------------------------------------------------------
  # * 清除數字輸入視窗
  #--------------------------------------------------------------------------
  def dispose_number_input_window
    @number_input_window.dispose
  end
  #--------------------------------------------------------------------------
  # * 清除視窗底部皮膚圖片
  #--------------------------------------------------------------------------
  def dispose_back_sprite
    @back_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # * 更新所攜資金資訊視窗所顯示的資訊
  #--------------------------------------------------------------------------
  def update_gold_window
    @gold_window.update
  end
  #--------------------------------------------------------------------------
  # * 更新數字輸入視窗所顯示的資訊
  #--------------------------------------------------------------------------
  def update_number_input_window
    @number_input_window.update
  end
  #--------------------------------------------------------------------------
  # * 重新繪製視窗底部皮膚圖片
  #--------------------------------------------------------------------------
  def update_back_sprite
    @back_sprite.visible = (@background == 1)
    @back_sprite.y = y - 16
    @back_sprite.opacity = openness
    @back_sprite.update
  end
  #--------------------------------------------------------------------------
  # * 更新快速前進標幟
  #--------------------------------------------------------------------------
  def update_show_fast
    if self.pause or self.openness < 255
      @show_fast = false
    elsif Input.trigger?(Input::C) and @wait_count < 2
      @show_fast = true
    elsif not Input.press?(Input::C)
      @show_fast = false
    end
    if @show_fast and @wait_count > 0
      @wait_count -= 1
    end
  end
  #--------------------------------------------------------------------------
  # * 判定是否應該持續顯示下一條訊息
  #--------------------------------------------------------------------------
  def continue?
    return true if $game_message.num_input_variable_id > 0
    return false if $game_message.texts.empty?
    if self.openness > 0 and not $game_temp.in_battle
      return false if @background != $game_message.background
      return false if @position != $game_message.position
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * 訊息顯示開始
  #--------------------------------------------------------------------------
  def start_message
    @text = ""
    for i in 0...$game_message.texts.size
      @text += "•" if i >= $game_message.choice_start
      @text += $game_message.texts[i].clone + "\x00"
    end
    @item_max = $game_message.choice_max
    convert_special_characters
    reset_window
    new_page
  end
  #--------------------------------------------------------------------------
  # * 繪製新訊息頁
  #--------------------------------------------------------------------------
  def new_page
    contents.clear
    if $game_message.face_name.empty?
      @contents_x = 0
    else
      name = $game_message.face_name
      index = $game_message.face_index
      draw_face(name, index, 0, 0)
      @contents_x = 112
    end
    @contents_y = 0
    @line_count = 0
    @show_fast = false
    @line_show_fast = false
    @pause_skip = false
    contents.font.color = text_color(0)
  end
  #--------------------------------------------------------------------------
  # * 繪製新行
  #--------------------------------------------------------------------------
  def new_line
    if $game_message.face_name.empty?
      @contents_x = 0
    else
      @contents_x = 112
    end
    @contents_y += WLH
    @line_count += 1
    @line_show_fast = false
  end
  #--------------------------------------------------------------------------
  # * 轉換特殊控制符
  #--------------------------------------------------------------------------
  def convert_special_characters
    @text.gsub!(/\\V\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
    @text.gsub!(/\\V\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
    @text.gsub!(/\\N\[([0-9]+)\]/i) { $game_actors[$1.to_i].name }
    @text.gsub!(/\\C\[([0-9]+)\]/i) { "\x01[#{$1}]" }
    @text.gsub!(/\\G/)              { "\x02" }
    @text.gsub!(/\\\./)             { "\x03" }
    @text.gsub!(/\\\|/)             { "\x04" }
    @text.gsub!(/\\!/)              { "\x05" }
    @text.gsub!(/\\>/)              { "\x06" }
    @text.gsub!(/\\</)              { "\x07" }
    @text.gsub!(/\\\^/)             { "\x08" }
    @text.gsub!(/\\\\/)             { "\\" }
  end
  #--------------------------------------------------------------------------
  # * 設置視窗顯示類型及視窗位置
  #--------------------------------------------------------------------------
  def reset_window
    @background = $game_message.background
    @position = $game_message.position
    if @background == 0   # 普通視窗
      self.opacity = 255
    else                  # 圖片視窗和透明視窗的情況下
      self.opacity = 0
    end
    case @position
    when 0  # 螢幕上部
      self.y = 0
      @gold_window.y = 360
    when 1  # 螢幕中心
      self.y = 144
      @gold_window.y = 0
    when 2  # 螢幕底部
      self.y = 288
      @gold_window.y = 0
    end
  end
  #--------------------------------------------------------------------------
  # * 訊息顯示結束
  #--------------------------------------------------------------------------
  def terminate_message
    self.active = false
    self.pause = false
    self.index = -1
    @gold_window.close
    @number_input_window.active = false
    @number_input_window.visible = false
    $game_message.main_proc.call if $game_message.main_proc != nil
    $game_message.clear
  end
  #--------------------------------------------------------------------------
  # * 更新文本訊息內容顯示
  #--------------------------------------------------------------------------
  def update_message
    loop do
      c = @text.slice!(/./m)            # 獲取下一個字元資訊
      case c
      when nil                          # 沒有要繪製的文本了
        finish_message                  # 結束更新
        break
      when "\x00"                       # 換至新行
        new_line
        if @line_count >= MAX_LINE      # 當前頁的文本行數已經達到上限
          unless @text.empty?           # 在沒有有更多內容的情況下
            self.pause = true           # 文本暫停顯示，等待按鍵輸入
            break
          end
        end
      when "\x01"                       # \C[n]  (更改字元顏色)
        @text.sub!(/\[([0-9]+)\]/, "")
        contents.font.color = text_color($1.to_i)
        next
      when "\x02"                       # \G  (顯示所攜資金)
        @gold_window.refresh
        @gold_window.open
      when "\x03"                       # \.  (等待0.25秒)
        @wait_count = 15
        break
      when "\x04"                       # \|  (等待1秒)
        @wait_count = 60
        break
      when "\x05"                       # \!  (文本暫停顯示，等待按鍵輸入)
        self.pause = true
        break
      when "\x06"                       # \>  (啟用文本快速顯示功能)
        @line_show_fast = true
      when "\x07"                       # \<  (禁用文本快速顯示功能)
        @line_show_fast = false
      when "\x08"                       # \^  (不等待按鍵輸入)
        @pause_skip = true
      else                              # 普通字元
        contents.draw_text(@contents_x, @contents_y, 40, WLH, c)
        c_width = contents.text_size(c).width
        @contents_x += c_width
      end
      break unless @show_fast or @line_show_fast
    end
  end
  #--------------------------------------------------------------------------
  # * 停止更新文本訊息內容顯示
  #--------------------------------------------------------------------------
  def finish_message
    if $game_message.choice_max > 0
      start_choice
    elsif $game_message.num_input_variable_id > 0
      start_number_input
    elsif @pause_skip
      terminate_message
    else
      self.pause = true
    end
    @wait_count = 10
    @text = nil
  end
  #--------------------------------------------------------------------------
  # * 開始準備接收選項輸入資訊
  #--------------------------------------------------------------------------
  def start_choice
    self.active = true
    self.index = 0
  end
  #--------------------------------------------------------------------------
  # * 開始準備接收數字輸入資訊
  #--------------------------------------------------------------------------
  def start_number_input
    digits_max = $game_message.num_input_digits_max
    number = $game_variables[$game_message.num_input_variable_id]
    @number_input_window.digits_max = digits_max
    @number_input_window.number = number
    if $game_message.face_name.empty?
      @number_input_window.x = x
    else
      @number_input_window.x = x + 112
    end
    @number_input_window.y = y + @contents_y
    @number_input_window.active = true
    @number_input_window.visible = true
    @number_input_window.update
  end
  #--------------------------------------------------------------------------
  # * 更新游標繪製
  #--------------------------------------------------------------------------
  def update_cursor
    if @index >= 0
      x = $game_message.face_name.empty? ? 0 : 112
      y = ($game_message.choice_start + @index) * WLH
      self.cursor_rect.set(x, y, contents.width - x, WLH)
    else
      self.cursor_rect.empty
    end
  end
  #--------------------------------------------------------------------------
  # * 持續顯示的文本資訊的輸入處理
  #--------------------------------------------------------------------------
  def input_pause
    if Input.trigger?(Input::B) or Input.trigger?(Input::C)
      self.pause = false
      if @text != nil and not @text.empty?
        new_page if @line_count >= MAX_LINE
      else
        terminate_message
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 接收選項輸入資訊
  #--------------------------------------------------------------------------
  def input_choice
    if Input.trigger?(Input::B)
      if $game_message.choice_cancel_type > 0
        Sound.play_cancel
        $game_message.choice_proc.call($game_message.choice_cancel_type - 1)
        terminate_message
      end
    elsif Input.trigger?(Input::C)
      Sound.play_decision
      $game_message.choice_proc.call(self.index)
      terminate_message
    end
  end
  #--------------------------------------------------------------------------
  # * 數字輸入處理
  #--------------------------------------------------------------------------
  def input_number
    if Input.trigger?(Input::C)
      Sound.play_decision
      $game_variables[$game_message.num_input_variable_id] =
        @number_input_window.number
      $game_map.need_refresh = true
      terminate_message
    end
  end
end
