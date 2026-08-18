#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Window_Equip
# 【用途】UI／選單元件「Window_Equip」。
# 【主要機制】擴充 Window／Scene／Sprite 顯示或操作；最終外觀可能由後載入 FS UI Patch 接管。
# 【主要影響】Window_Equip
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
# ** Window_Equip
#------------------------------------------------------------------------------
#  本視窗顯示於整備畫面中，用來顯示主角目前身上的裝備資訊。
#==============================================================================

class Window_Equip < Window_Selectable
  #--------------------------------------------------------------------------
  # * 物件初始化
  #     x      : 視窗X座標
  #     y      : 視窗Y座標
  #     actor  : 主角
  #--------------------------------------------------------------------------
  def initialize(x, y, actor)
    super(x, y, 336, WLH * 5 + 32)
    @actor = actor
    refresh
    self.index = 0
  end
  #--------------------------------------------------------------------------
  # * 獲取條目資訊
  #--------------------------------------------------------------------------
  def item
    return @data[self.index]
  end
  #--------------------------------------------------------------------------
  # * 更新內容顯示
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    @data = []
    for item in @actor.equips do @data.push(item) end
    @item_max = @data.size
    self.contents.font.color = system_color
    if @actor.two_swords_style
      self.contents.draw_text(4, WLH * 0, 92, WLH, Vocab::weapon1)
      self.contents.draw_text(4, WLH * 1, 92, WLH, Vocab::weapon2)
    else
      self.contents.draw_text(4, WLH * 0, 92, WLH, Vocab::weapon)
      self.contents.draw_text(4, WLH * 1, 92, WLH, Vocab::armor1)
    end
    self.contents.draw_text(4, WLH * 2, 92, WLH, Vocab::armor2)
    self.contents.draw_text(4, WLH * 3, 92, WLH, Vocab::armor3)
    self.contents.draw_text(4, WLH * 4, 92, WLH, Vocab::armor4)
    draw_item_name(@data[0], 92, WLH * 0)
    draw_item_name(@data[1], 92, WLH * 1)
    draw_item_name(@data[2], 92, WLH * 2)
    draw_item_name(@data[3], 92, WLH * 3)
    draw_item_name(@data[4], 92, WLH * 4)
  end
  #--------------------------------------------------------------------------
  # * 更新動態説明視窗內容資訊
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_text(item == nil ? "" : item.description)
  end
end
