#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Scene_Name
# 【用途】VX 名稱輸入場景，管理角色名稱編輯與文字輸入。
# 【主要機制】由 RGSS2 Scene 流程自動建立／更新；本專案後續 Menu／Battle／UI Patch 可能重開啟同類別。
# 【主要影響】Scene_Name
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
# ** Scene_Name
#------------------------------------------------------------------------------
#  這個類用來執行顯示名稱輸入畫面的程式。
#==============================================================================

class Scene_Name < Scene_Base
  #--------------------------------------------------------------------------
  # * 程式開始
  #--------------------------------------------------------------------------
  def start
    super
    create_menu_background
    @actor = $game_actors[$game_temp.name_actor_id]
    @edit_window = Window_NameEdit.new(@actor, $game_temp.name_max_char)
    @input_window = Window_NameInput.new
  end
  #--------------------------------------------------------------------------
  # * 程式終止
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_menu_background
    @edit_window.dispose
    @input_window.dispose
  end
  #--------------------------------------------------------------------------
  # * 返回之前的畫面
  #--------------------------------------------------------------------------
  def return_scene
    $scene = Scene_Map.new
  end
  #--------------------------------------------------------------------------
  # * 更新幀
  #--------------------------------------------------------------------------
  def update
    super
    update_menu_background
    @edit_window.update
    @input_window.update
    if Input.repeat?(Input::B)
      if @edit_window.index > 0             # 不在最左邊
        Sound.play_cancel
        @edit_window.back
      end
    elsif Input.trigger?(Input::C)
      if @input_window.is_decision          # 如果游標在[確定]命令項上
        if @edit_window.name == ""          # 如果名稱為空
          @edit_window.restore_default      # 調用資料庫定義的名稱
          if @edit_window.name == ""
            Sound.play_buzzer
          else
            Sound.play_decision
          end
        else
          Sound.play_decision
          @actor.name = @edit_window.name   # 更改主角名稱
          return_scene
        end
      elsif @input_window.character != ""   # 如果文本不為空
        if @edit_window.index == @edit_window.max_char    # 在最右邊
          Sound.play_buzzer
        else
          Sound.play_decision
          @edit_window.add(@input_window.character)       # 增加文本字元
        end
      end
    end
  end
end
