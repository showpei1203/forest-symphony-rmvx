#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Window_DebugRight
# 【用途】UI／選單元件「Window_DebugRight」。
# 【主要機制】擴充 Window／Scene／Sprite 顯示或操作；最終外觀可能由後載入 FS UI Patch 接管。
# 【主要影響】Window_DebugRight
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
# ** Window_DebugRight
#------------------------------------------------------------------------------
#  本視窗顯示於DEBUG畫面右側，用來顯示開關和系統變數的內容資訊。
#==============================================================================

class Window_DebugRight < Window_Selectable
  #--------------------------------------------------------------------------
  # * 宣告執行個體變數
  #--------------------------------------------------------------------------
  attr_reader   :mode                     # 模式（0：開關，1：系統變數）
  attr_reader   :top_id                   # 顯示於行頭的ID
  #--------------------------------------------------------------------------
  # * 物件初始化
  #     x : 視窗X座標
  #     y : 視窗Y座標
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y, 368, 10 * WLH + 32)
    self.index = -1
    self.active = false
    @item_max = 10
    @mode = 0
    @top_id = 1
    refresh
  end
  #--------------------------------------------------------------------------
  # * 更新內容顯示
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    for i in 0...@item_max
      draw_item(i)
    end
  end
  #--------------------------------------------------------------------------
  # * 繪製條目
  #     index : 條目編號
  #--------------------------------------------------------------------------
  def draw_item(index)
    current_id = @top_id + index
    id_text = sprintf("%04d:", current_id)
    id_width = self.contents.text_size(id_text).width
    if @mode == 0
      name = $data_system.switches[current_id]
      status = $game_switches[current_id] ? "[已開啟]" : "[已關閉]"
    else
      name = $data_system.variables[current_id]
      status = $game_variables[current_id]
    end
    if name == nil
      name = ""
    end
    rect = item_rect(index)
    rect.x += 4
    rect.width -= 8
    self.contents.clear_rect(rect)
    self.contents.font.color = normal_color
    self.contents.draw_text(rect, id_text)
    rect.x += id_width
    rect.width -= id_width + 60
    self.contents.draw_text(rect, name)
    rect.width += 60
    self.contents.draw_text(rect, status, 2)
  end
  #--------------------------------------------------------------------------
  # * 模式設置
  #     id : 新模式
  #--------------------------------------------------------------------------
  def mode=(mode)
    if @mode != mode
      @mode = mode
      refresh
    end
  end
  #--------------------------------------------------------------------------
  # * 設置在行頭顯示的編號
  #     id : 新編號
  #--------------------------------------------------------------------------
  def top_id=(id)
    if @top_id != id
      @top_id = id
      refresh
    end
  end
end
