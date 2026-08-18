#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Window_Status
# 【用途】UI／選單元件「Window_Status」。
# 【主要機制】擴充 Window／Scene／Sprite 顯示或操作；最終外觀可能由後載入 FS UI Patch 接管。
# 【主要影響】Window_Status
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
# ** Window_Status
#------------------------------------------------------------------------------
#  本視窗顯示於狀態畫面中，用於顯示主角的詳細狀態。
#==============================================================================

class Window_Status < Window_Base
  #--------------------------------------------------------------------------
  # * 物件初始化
  #     actor : 主角
  #--------------------------------------------------------------------------
  def initialize(actor)
    super(0, 0, 544, 416)
    @actor = actor
    refresh
  end
  #--------------------------------------------------------------------------
  # * 更新內容顯示
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    draw_actor_name(@actor, 4, 0)
    draw_actor_class(@actor, 128, 0)
    draw_actor_face(@actor, 8, 32)
    draw_basic_info(128, 32)
    draw_parameters(32, 160)
    draw_exp_info(288, 32)
    draw_equipments(288, 160)
  end
  #--------------------------------------------------------------------------
  # * 繪製主角基礎狀態資訊
  #     x     : 繪製區域X座標
  #     y     : 繪製區域Y座標
  #--------------------------------------------------------------------------
  def draw_basic_info(x, y)
    draw_actor_level(@actor, x, y + WLH * 0)
    draw_actor_state(@actor, x, y + WLH * 1)
    draw_actor_hp(@actor, x, y + WLH * 2)
    draw_actor_mp(@actor, x, y + WLH * 3)
  end
  #--------------------------------------------------------------------------
  # * 繪製主角各項參數資訊
  #     x     : 繪製區域X座標
  #     y     : 繪製區域Y座標
  #--------------------------------------------------------------------------
  def draw_parameters(x, y)
    draw_actor_parameter(@actor, x, y + WLH * 0, 0)
    draw_actor_parameter(@actor, x, y + WLH * 1, 1)
    draw_actor_parameter(@actor, x, y + WLH * 2, 2)
    draw_actor_parameter(@actor, x, y + WLH * 3, 3)
  end
  #--------------------------------------------------------------------------
  # * 繪製主角經驗值資訊
  #     x     : 繪製區域X座標
  #     y     : 繪製區域Y座標
  #--------------------------------------------------------------------------
  def draw_exp_info(x, y)
    s1 = @actor.exp_s
    s2 = @actor.next_rest_exp_s
    s_next = sprintf(Vocab::ExpNext, Vocab::level)
    self.contents.font.color = system_color
    self.contents.draw_text(x, y + WLH * 0, 180, WLH, Vocab::ExpTotal)
    self.contents.draw_text(x, y + WLH * 2, 180, WLH, s_next)
    self.contents.font.color = normal_color
    self.contents.draw_text(x, y + WLH * 1, 180, WLH, s1, 2)
    self.contents.draw_text(x, y + WLH * 3, 180, WLH, s2, 2)
  end
  #--------------------------------------------------------------------------
  # * 繪製主角當前裝備資訊
  #     x     : 繪製區域X座標
  #     y     : 繪製區域Y座標
  #--------------------------------------------------------------------------
  def draw_equipments(x, y)
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 120, WLH, Vocab::equip)
    for i in 0..4
      draw_item_name(@actor.equips[i], x + 16, y + WLH * (i + 1))
    end
  end
end
