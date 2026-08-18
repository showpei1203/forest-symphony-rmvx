#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Window_SaveFile
# 【用途】UI／選單元件「Window_SaveFile」。
# 【主要機制】擴充 Window／Scene／Sprite 顯示或操作；最終外觀可能由後載入 FS UI Patch 接管。
# 【主要影響】Window_SaveFile
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
# ** Window_SaveFile
#------------------------------------------------------------------------------
#  本視窗顯示於進度存取畫面中，用於顯示每個進度檔位元的進度資訊。
#==============================================================================

class Window_SaveFile < Window_Base
  #--------------------------------------------------------------------------
  # * 宣告執行個體變數
  #--------------------------------------------------------------------------
  attr_reader   :filename                 # 檔案名
  attr_reader   :file_exist               # 檔案存在性標幟
  attr_reader   :time_stamp               # 時間戳記
  attr_reader   :selected                 # 檔位元處於被選中的狀態
  #--------------------------------------------------------------------------
  # * 物件初始化
  #     file_index : 檔位（默認0-3）
  #     filename   : 檔案名
  #--------------------------------------------------------------------------
  def initialize(file_index, filename)
    super(0, 56 + file_index % 4 * 90, 544, 90)
    @file_index = file_index
    @filename = filename
    load_gamedata
    refresh
    @selected = false
  end
  #--------------------------------------------------------------------------
  # * 讀取部分所需的遊戲資料
  #    預設情況下，開關和系統變數用不到（可以在此擴充例如顯示所在方位等功能）
  #--------------------------------------------------------------------------
  def load_gamedata
    @time_stamp = Time.at(0)
    @file_exist = FileTest.exist?(@filename)
    if @file_exist
      file = File.open(@filename, "r")
      @time_stamp = file.mtime
      begin
        @characters     = Marshal.load(file)
        @frame_count    = Marshal.load(file)
        @last_bgm       = Marshal.load(file)
        @last_bgs       = Marshal.load(file)
        @game_system    = Marshal.load(file)
        @game_message   = Marshal.load(file)
        @game_switches  = Marshal.load(file)
        @game_variables = Marshal.load(file)
        @total_sec = @frame_count / Graphics.frame_rate
      rescue
        @file_exist = false
      ensure
        file.close
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 更新內容顯示
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.font.color = normal_color
    name = Vocab::File + " #{@file_index + 1}"
    self.contents.draw_text(4, 0, 200, WLH, name)
    @name_width = contents.text_size(name).width
    if @file_exist
      draw_party_characters(152, 58)
      draw_playtime(0, 34, contents.width - 4, 2)
    end
  end
  #--------------------------------------------------------------------------
  # * 並排繪製隊伍主角的人物特徵圖
  #     x     : 繪製區域X座標
  #     y     : 繪製區域Y座標
  #--------------------------------------------------------------------------
  def draw_party_characters(x, y)
    for i in 0...@characters.size
      name = @characters[i][0]
      index = @characters[i][1]
      draw_character(name, index, x + i * 48, y)
    end
  end
  #--------------------------------------------------------------------------
  # * 繪製遊戲耗時
  #     x     : 繪製區域X座標
  #     y     : 繪製區域Y座標
  #     width : 寬度
  #     align : 對齊方式
  #--------------------------------------------------------------------------
  def draw_playtime(x, y, width, align)
    hour = @total_sec / 60 / 60
    min = @total_sec / 60 % 60
    sec = @total_sec % 60
    time_string = sprintf("%02d:%02d:%02d", hour, min, sec)
    self.contents.font.color = normal_color
    self.contents.draw_text(x, y, width, WLH, time_string, 2)
  end
  #--------------------------------------------------------------------------
  # * 設置檔位元是否處於被選擇的狀態
  #     selected : 被選擇？（true = 被選擇，false = 為被選擇）
  #--------------------------------------------------------------------------
  def selected=(selected)
    @selected = selected
    update_cursor
  end
  #--------------------------------------------------------------------------
  # * 更新游標繪製
  #--------------------------------------------------------------------------
  def update_cursor
    if @selected
      self.cursor_rect.set(0, 0, @name_width + 8, WLH)
    else
      self.cursor_rect.empty
    end
  end
end
