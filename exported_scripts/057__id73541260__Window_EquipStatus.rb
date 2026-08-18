#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Window_EquipStatus
# 【用途】UI／選單元件「Window_EquipStatus」。
# 【主要機制】擴充 Window／Scene／Sprite 顯示或操作；最終外觀可能由後載入 FS UI Patch 接管。
# 【主要影響】Window_EquipStatus
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
# ** Window_EquipStatus
#------------------------------------------------------------------------------
#  本視窗顯示於整備畫面中，用於顯示更換裝備前後主角各項參數的變化等內容。
#==============================================================================

class Window_EquipStatus < Window_Base
  #--------------------------------------------------------------------------
  # * 物件初始化
  #     x      : 視窗X座標
  #     y      : 視窗Y座標
  #     actor  : 主角
  #--------------------------------------------------------------------------
  def initialize(x, y, actor)
    super(x, y, 208, WLH * 5 + 32)
    @actor = actor
    refresh
  end
  #--------------------------------------------------------------------------
  # * 更新內容顯示
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    draw_actor_name(@actor, 4, 0)
    draw_parameter(0, WLH * 1, 0)
    draw_parameter(0, WLH * 2, 1)
    draw_parameter(0, WLH * 3, 2)
    draw_parameter(0, WLH * 4, 3)
  end
  #--------------------------------------------------------------------------
  # * 裝備更換後設置主角參數內容
  #     new_atk : 裝備更換後主角的攻擊力
  #     new_def : 裝備更換後主角的防禦力
  #     new_spi : 裝備更換後主角的精神意志力
  #     new_agi : 裝備更換後主角的敏捷力
  #--------------------------------------------------------------------------
  def set_new_parameters(new_atk, new_def, new_spi, new_agi)
    if @new_atk != new_atk or @new_def != new_def or
       @new_spi != new_spi or @new_agi != new_agi
      @new_atk = new_atk
      @new_def = new_def
      @new_spi = new_spi
      @new_agi = new_agi
      refresh
    end
  end
  #--------------------------------------------------------------------------
  # * 設置裝備更換後的參數值的文本顏色
  #     old_value : 裝備更換前的參數值
  #     new_value : 裝備更換後的參數值
  #--------------------------------------------------------------------------
  def new_parameter_color(old_value, new_value)
    if new_value > old_value      # 參數值更大
      return power_up_color
    elsif new_value == old_value  # 參數值不變
      return normal_color
    else                          # 參數值更小
      return power_down_color
    end
  end
  #--------------------------------------------------------------------------
  # * 繪製主角參數
  #     x     : 繪製區域X座標
  #     y     : 繪製區域Y座標
  #     type  : 主角參數種類（0-3）
  #--------------------------------------------------------------------------
  def draw_parameter(x, y, type)
    case type
    when 0
      name = Vocab::atk
      value = @actor.atk
      new_value = @new_atk
    when 1
      name = Vocab::def
      value = @actor.def
      new_value = @new_def
    when 2
      name = Vocab::spi
      value = @actor.spi
      new_value = @new_spi
    when 3
      name = Vocab::agi
      value = @actor.agi
      new_value = @new_agi
    end
    self.contents.font.color = system_color
    self.contents.draw_text(x + 4, y, 80, WLH, name)
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 90, y, 30, WLH, value, 2)
    self.contents.font.color = system_color
    self.contents.draw_text(x + 122, y, 20, WLH, ">", 1)
    if new_value != nil
      self.contents.font.color = new_parameter_color(value, new_value)
      self.contents.draw_text(x + 142, y, 30, WLH, new_value, 2)
    end
  end
end
