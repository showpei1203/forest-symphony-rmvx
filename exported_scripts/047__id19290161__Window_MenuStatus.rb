#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Window_MenuStatus
# 【用途】UI／選單元件「Window_MenuStatus」。
# 【主要機制】擴充 Window／Scene／Sprite 顯示或操作；最終外觀可能由後載入 FS UI Patch 接管。
# 【主要影響】Window_MenuStatus
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
# ** Window_MenuStatus
#------------------------------------------------------------------------------
#  本視窗顯示于ESC選單畫面中，用於顯示在隊主角們的基本狀態。
#==============================================================================

class Window_MenuStatus < Window_Selectable
  #--------------------------------------------------------------------------
  # * 物件初始化
  #     x : 視窗X座標
  #     y : 視窗Y座標
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y, 384, 416)
    refresh
    self.active = false
    self.index = -1
  end
  #--------------------------------------------------------------------------
  # * 更新內容顯示
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    @item_max = $game_party.members.size
    for actor in $game_party.members
      draw_actor_face(actor, 2, actor.index * 96 + 2, 92)
      x = 104
      y = actor.index * 96 + WLH / 2
      draw_actor_name(actor, x, y)
      draw_actor_class(actor, x + 120, y)
      draw_actor_level(actor, x, y + WLH * 1)
      draw_actor_state(actor, x, y + WLH * 2)
      draw_actor_hp(actor, x + 120, y + WLH * 1)
      draw_actor_mp(actor, x + 120, y + WLH * 2)
    end
  end
  #--------------------------------------------------------------------------
  # * 更新游標繪製
  #--------------------------------------------------------------------------
  def update_cursor
    if @index < 0               # 無光標
      self.cursor_rect.empty
    elsif @index < @item_max    # 正常狀態
      self.cursor_rect.set(0, @index * 96, contents.width, 96)
    elsif @index >= 100         # 使用者自身
      self.cursor_rect.set(0, (@index - 100) * 96, contents.width, 96)
    else                        # 全體隊員
      self.cursor_rect.set(0, 0, contents.width, @item_max * 96)
    end
  end
end
