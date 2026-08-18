#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Scene_Equip
# 【用途】VX 裝備場景，顯示裝備欄位、可裝備物與參數變化。
# 【主要機制】由 RGSS2 Scene 流程自動建立／更新；本專案後續 Menu／Battle／UI Patch 可能重開啟同類別。
# 【主要影響】Scene_Equip
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：EQUIP_TYPE_MAX。核心方法除非已確認依賴鏈，不建議直接覆寫。
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
# ** Scene_Equip
#------------------------------------------------------------------------------
#  這個類用來執行顯示整備畫面的程式。
#==============================================================================

class Scene_Equip < Scene_Base
  #--------------------------------------------------------------------------
  # * 常數
  #--------------------------------------------------------------------------
  EQUIP_TYPE_MAX = 5                      # 裝備部位數
  #--------------------------------------------------------------------------
  # * 物件初始化
  #     actor_index : 主角編號
  #     equip_index : 裝備部位編號
  #--------------------------------------------------------------------------
  def initialize(actor_index = 0, equip_index = 0)
    @actor_index = actor_index
    @equip_index = equip_index
  end
  #--------------------------------------------------------------------------
  # * 程式開始
  #--------------------------------------------------------------------------
  def start
    super
    create_menu_background
    @actor = $game_party.members[@actor_index]
    @help_window = Window_Help.new
    create_item_windows
    @equip_window = Window_Equip.new(208, 56, @actor)
    @equip_window.help_window = @help_window
    @equip_window.index = @equip_index
    @status_window = Window_EquipStatus.new(0, 56, @actor)
  end
  #--------------------------------------------------------------------------
  # * 程式終止
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_menu_background
    @help_window.dispose
    @equip_window.dispose
    @status_window.dispose
    dispose_item_windows
  end
  #--------------------------------------------------------------------------
  # * 返回之前的畫面
  #--------------------------------------------------------------------------
  def return_scene
    $scene = Scene_Menu.new(2)
  end
  #--------------------------------------------------------------------------
  # * 切換畫面內容至下一個主角
  #--------------------------------------------------------------------------
  def next_actor
    @actor_index += 1
    @actor_index %= $game_party.members.size
    $scene = Scene_Equip.new(@actor_index, @equip_window.index)
  end
  #--------------------------------------------------------------------------
  # * 切換視窗畫面至上一個主角
  #--------------------------------------------------------------------------
  def prev_actor
    @actor_index += $game_party.members.size - 1
    @actor_index %= $game_party.members.size
    $scene = Scene_Equip.new(@actor_index, @equip_window.index)
  end
  #--------------------------------------------------------------------------
  # * 更新幀
  #--------------------------------------------------------------------------
  def update
    super
    update_menu_background
    @help_window.update
    update_equip_window
    update_status_window
    update_item_windows
    if @equip_window.active
      update_equip_selection
    elsif @item_window.active
      update_item_selection
    end
  end
  #--------------------------------------------------------------------------
  # * 創建物品視窗
  #--------------------------------------------------------------------------
  def create_item_windows
    @item_windows = []
    for i in 0...EQUIP_TYPE_MAX
      @item_windows[i] = Window_EquipItem.new(0, 208, 544, 208, @actor, i)
      @item_windows[i].help_window = @help_window
      @item_windows[i].visible = (@equip_index == i)
      @item_windows[i].y = 208
      @item_windows[i].height = 208
      @item_windows[i].active = false
      @item_windows[i].index = -1
    end
  end
  #--------------------------------------------------------------------------
  # * 清除物品視窗
  #--------------------------------------------------------------------------
  def dispose_item_windows
    for window in @item_windows
      window.dispose
    end
  end
  #--------------------------------------------------------------------------
  # * 更新物品視窗內容
  #--------------------------------------------------------------------------
  def update_item_windows
    for i in 0...EQUIP_TYPE_MAX
      @item_windows[i].visible = (@equip_window.index == i)
      @item_windows[i].update
    end
    @item_window = @item_windows[@equip_window.index]
  end
  #--------------------------------------------------------------------------
  # * 更新裝備視窗內容
  #--------------------------------------------------------------------------
  def update_equip_window
    @equip_window.update
  end
  #--------------------------------------------------------------------------
  # * 更新狀態視窗內容
  #--------------------------------------------------------------------------
  def update_status_window
    if @equip_window.active
      @status_window.set_new_parameters(nil, nil, nil, nil)
    elsif @item_window.active
      temp_actor = @actor.clone
      temp_actor.change_equip(@equip_window.index, @item_window.item, true)
      new_atk = temp_actor.atk
      new_def = temp_actor.def
      new_spi = temp_actor.spi
      new_agi = temp_actor.agi
      @status_window.set_new_parameters(new_atk, new_def, new_spi, new_agi)
    end
    @status_window.update
  end
  #--------------------------------------------------------------------------
  # * 更新裝備部位選擇指令輸入資訊
  #--------------------------------------------------------------------------
  def update_equip_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      return_scene
    elsif Input.trigger?(Input::R)
      Sound.play_cursor
      next_actor
    elsif Input.trigger?(Input::L)
      Sound.play_cursor
      prev_actor
    elsif Input.trigger?(Input::C)
      if @actor.fix_equipment
        Sound.play_buzzer
      else
        Sound.play_decision
        @equip_window.active = false
        @item_window.active = true
        @item_window.index = 0
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 更新物品選擇指令輸入資訊
  #--------------------------------------------------------------------------
  def update_item_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      @equip_window.active = true
      @item_window.active = false
      @item_window.index = -1
    elsif Input.trigger?(Input::C)
      Sound.play_equip
      @actor.change_equip(@equip_window.index, @item_window.item)
      @equip_window.active = true
      @item_window.active = false
      @item_window.index = -1
      @equip_window.refresh
      for item_window in @item_windows
        item_window.refresh
      end
    end
  end
end
