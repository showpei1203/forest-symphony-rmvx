#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Scene_Item
# 【用途】VX 物品場景，顯示物品清單並處理使用目標與 Common Event。
# 【主要機制】由 RGSS2 Scene 流程自動建立／更新；本專案後續 Menu／Battle／UI Patch 可能重開啟同類別。
# 【主要影響】Scene_Item
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
# ** Scene_Item
#------------------------------------------------------------------------------
#  這個類用來執行顯示用品畫面的程式。
#==============================================================================

class Scene_Item < Scene_Base
  #--------------------------------------------------------------------------
  # * 程式開始
  #--------------------------------------------------------------------------
  def start
    super
    create_menu_background
    @viewport = Viewport.new(0, 0, 544, 416)
    @help_window = Window_Help.new
    @help_window.viewport = @viewport
    @item_window = Window_Item.new(0, 56, 544, 360)
    @item_window.viewport = @viewport
    @item_window.help_window = @help_window
    @item_window.active = false
    @target_window = Window_MenuStatus.new(0, 0)
    hide_target_window
  end
  #--------------------------------------------------------------------------
  # * 程式終止
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_menu_background
    @viewport.dispose
    @help_window.dispose
    @item_window.dispose
    @target_window.dispose
  end
  #--------------------------------------------------------------------------
  # * 返回之前的畫面
  #--------------------------------------------------------------------------
  def return_scene
    $scene = Scene_Menu.new(0)
  end
  #--------------------------------------------------------------------------
  # * 更新幀
  #--------------------------------------------------------------------------
  def update
    super
    update_menu_background
    @help_window.update
    @item_window.update
    @target_window.update
    if @item_window.active
      update_item_selection
    elsif @target_window.active
      update_target_selection
    end
  end
  #--------------------------------------------------------------------------
  # * 更新物品選擇指令輸入資訊
  #--------------------------------------------------------------------------
  def update_item_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      return_scene
    elsif Input.trigger?(Input::C)
      @item = @item_window.item
      if @item != nil
        $game_party.last_item_id = @item.id
      end
      if $game_party.item_can_use?(@item)
        Sound.play_decision
        determine_item
      else
        Sound.play_buzzer
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 判定物品是否可用
  #--------------------------------------------------------------------------
  def determine_item
    if @item.for_friend?
      show_target_window(@item_window.index % 2 == 0)
      if @item.for_all?
        @target_window.index = 99
      else
        if $game_party.last_target_index < @target_window.item_max
          @target_window.index = $game_party.last_target_index
        else
          @target_window.index = 0
        end
      end
    else
      use_item_nontarget
    end
  end
  #--------------------------------------------------------------------------
  # * 更新目標選擇指令輸入資訊
  #--------------------------------------------------------------------------
  def update_target_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      if $game_party.item_number(@item) == 0    # 物品用盡
        @item_window.refresh                    # 重建物品視窗內容
      end
      hide_target_window
    elsif Input.trigger?(Input::C)
      if not $game_party.item_can_use?(@item)
        Sound.play_buzzer
      else
        determine_target
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 判定物品是否可以施用於目標
  #    若無效（如施用增加HP的物品於瀕死者），播放“無效”SE。
  #--------------------------------------------------------------------------
  def determine_target
    used = false
    if @item.for_all?
      for target in $game_party.members
        target.item_effect(target, @item)
        used = true unless target.skipped
      end
    else
      $game_party.last_target_index = @target_window.index
      target = $game_party.members[@target_window.index]
      target.item_effect(target, @item)
      used = true unless target.skipped
    end
    if used
      use_item_nontarget
    else
      Sound.play_buzzer
    end
  end
  #--------------------------------------------------------------------------
  # * 顯示目標選擇視窗
  #     right : 視窗右對齊標幟（如果為false，則視窗左對齊）
  #--------------------------------------------------------------------------
  def show_target_window(right)
    @item_window.active = false
    width_remain = 544 - @target_window.width
    @target_window.x = right ? width_remain : 0
    @target_window.visible = true
    @target_window.active = true
    if right
      @viewport.rect.set(0, 0, width_remain, 416)
      @viewport.ox = 0
    else
      @viewport.rect.set(@target_window.width, 0, width_remain, 416)
      @viewport.ox = @target_window.width
    end
  end
  #--------------------------------------------------------------------------
  # * 隱藏目標選擇視窗
  #--------------------------------------------------------------------------
  def hide_target_window
    @item_window.active = true
    @target_window.visible = false
    @target_window.active = false
    @viewport.rect.set(0, 0, 544, 416)
    @viewport.ox = 0
  end
  #--------------------------------------------------------------------------
  # * 使用物品（物品效果應用目標為非我方單人）
  #--------------------------------------------------------------------------
  def use_item_nontarget
    Sound.play_use_item
    $game_party.consume_item(@item)
    @item_window.draw_item(@item_window.index)
    @target_window.refresh
    if $game_party.all_dead?
      $scene = Scene_Gameover.new
    elsif @item.common_event_id > 0
      $game_temp.common_event_id = @item.common_event_id
      $scene = Scene_Map.new
    end
  end
end
