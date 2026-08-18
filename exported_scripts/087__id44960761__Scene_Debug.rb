#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Scene_Debug
# 【用途】VX Debug 場景，測試模式下編輯開關／變數。
# 【主要機制】由 RGSS2 Scene 流程自動建立／更新；本專案後續 Menu／Battle／UI Patch 可能重開啟同類別。
# 【主要影響】Scene_Debug
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
# ** Scene_Debug
#------------------------------------------------------------------------------
#  這個類用來執行顯示DEBUG畫面的程式。
#==============================================================================

class Scene_Debug < Scene_Base
  #--------------------------------------------------------------------------
  # * 程式開始
  #--------------------------------------------------------------------------
  def start
    super
    create_menu_background
    @left_window = Window_DebugLeft.new(0, 0)
    @right_window = Window_DebugRight.new(176, 0)
    @help_window = Window_Base.new(176, 272, 368, 144)
    @left_window.top_row = $game_temp.debug_top_row
    @left_window.index = $game_temp.debug_index
    @right_window.mode = @left_window.mode
    @right_window.top_id = @left_window.top_id
  end
  #--------------------------------------------------------------------------
  # * 程式終止
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_menu_background
    $game_map.refresh
    @left_window.dispose
    @right_window.dispose
    @help_window.dispose
  end
  #--------------------------------------------------------------------------
  # * 更新幀
  #--------------------------------------------------------------------------
  def update
    super
    update_menu_background
    @right_window.mode = @left_window.mode
    @right_window.top_id = @left_window.top_id
    @left_window.update
    @right_window.update
    $game_temp.debug_top_row = @left_window.top_row
    $game_temp.debug_index = @left_window.index
    if @left_window.active
      update_left_input
    elsif @right_window.active
      update_right_input
    end
  end
  #--------------------------------------------------------------------------
  # * 更新左視窗輸入資訊
  #--------------------------------------------------------------------------
  def update_left_input
    if Input.trigger?(Input::B)
      Sound.play_cancel
      $scene = Scene_Map.new
      return
    elsif Input.trigger?(Input::C)
      Sound.play_decision
      wlh = 24
      if @left_window.mode == 0
        text1 = "C (Enter) : 開啟 / 關閉"
        @help_window.contents.draw_text(4, 0, 336, wlh, text1)
      else
        text1 = "< (Left)    :  -1"
        text2 = "> (Right)   :  +1"
        text3 = "L (Pageup)   : -10"
        text4 = "R (Pagedown) : +10"
        @help_window.contents.draw_text(4, wlh * 0, 336, wlh, text1)
        @help_window.contents.draw_text(4, wlh * 1, 336, wlh, text2)
        @help_window.contents.draw_text(4, wlh * 2, 336, wlh, text3)
        @help_window.contents.draw_text(4, wlh * 3, 336, wlh, text4)
      end
      @left_window.active = false
      @right_window.active = true
      @right_window.index = 0
    end
  end
  #--------------------------------------------------------------------------
  # * 更新右視窗輸入資訊
  #--------------------------------------------------------------------------
  def update_right_input
    if Input.trigger?(Input::B)
      Sound.play_cancel
      @left_window.active = true
      @right_window.active = false
      @right_window.index = -1
      @help_window.contents.clear
    else
      current_id = @right_window.top_id + @right_window.index
      if @right_window.mode == 0
        if Input.trigger?(Input::C)
          Sound.play_decision
          $game_switches[current_id] = (not $game_switches[current_id])
          @right_window.refresh
        end
      elsif @right_window.mode == 1
        last_value = $game_variables[current_id]
        if Input.repeat?(Input::RIGHT)
          $game_variables[current_id] += 1
        elsif Input.repeat?(Input::LEFT)
          $game_variables[current_id] -= 1
        elsif Input.repeat?(Input::R)
          $game_variables[current_id] += 10
        elsif Input.repeat?(Input::L)
          $game_variables[current_id] -= 10
        end
        if $game_variables[current_id] > 99999999
          $game_variables[current_id] = 99999999
        elsif $game_variables[current_id] < -99999999
          $game_variables[current_id] = -99999999
        end
        if $game_variables[current_id] != last_value
          Sound.play_cursor
          @right_window.draw_item(@right_window.index)
        end
      end
    end
  end
end
