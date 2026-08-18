#==============================================================================
# 【Forest Symphony｜繁體中文完整說明】
#------------------------------------------------------------------------------
# 腳本：ChestItemPopup_Core v2.1
# 【來源】OriginalWij，Chest Item Pop-Up v2.1。
# 【用途】攔截事件的「增減金錢／物品／武器／防具」指令，在事件角色座標顯示取得圖示與名稱視窗；也能直接以 Scene Call 顯示指定內容。
# 【自動模式】`AUTO_POPUP=true`：預設每次取得都彈出；此時 `POPUP_SWITCH` 開啟代表暫時停用。若 AUTO_POPUP=false，邏輯相反。現在 POPUP_SWITCH=0，改動前需確認 VX 對 Switch 0 的實際使用方式。
# 【直接呼叫】`$scene = Chest_Popup.new(x, y, type, amount, index, add=false)`；type：0 Gold、1 Item、2 Weapon、3 Armor；add=true 時同時加入 Inventory。
# 【範例】`$scene = Chest_Popup.new($game_player.screen_x,$game_player.screen_y,1,1,5,true)` 顯示 Item 5 x1 並加入背包。多種不同物品連續顯示時，原作者要求事件之間至少 WAIT(1)。
# 【主要設定】GOLD_ICON=205；POPUP_SOUND=`BSZ, Get Item`；ONLY_SHOW_ONE=true；SHOW_POPUP_TEXT=true；WAIT_FOR_BUTTON=true，C/B 關閉；USE_OVERLAY=true；OVERLAY=`Overlay1`。
# 【素材】Graphics/Pictures/Overlay1；Audio/SE/BSZ, Get Item。CLOSE_SOUND=Cancel 目前 PLAY_CLOSE=false。
# 【Load Order】alias Game_Interpreter command_125～128，並建立獨立 Chest_Popup Scene；事件增減物品流程若另有後載入攔截器，需實機測彈出與 Inventory 是否各只執行一次。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址保留；Phase 21 Archive 另保存修改前 byte-exact 原稿。
# 4. 本輪除 Friendly Monsters GoldFix 回寫外，只整理文件／架構標記；其餘 Runtime code 與載入順序不得因翻譯改變。
#==============================================================================
#==============================================================================
#==============================================================================
# 作者：OriginalWij
# 版本：2.1
#==============================================================================

#==============================================================================
# 版本紀錄：
#
# v1.0
#
# v1.1
#
# v1.2a
#
# v1.3
#
# v2.0
#
# v2.1
#==============================================================================

#==============================================================================
#
#   $scene = Chest_Popup.new(x, y, type, amount, index, add = false)
#==============================================================================
#==============================================================================

  AUTO_POPUP = true
  POPUP_SWITCH = 0
  GOLD_ICON = 205
  PLAY_POPUP_SOUND = true
    POPUP_SOUND = 'BSZ, Get Item'
    POPUP_SOUND_VOLUME = 100
    POPUP_SOUND_PITCH = 100
  PLAY_CLOSE = false
    CLOSE_SOUND = 'Cancel'
    CLOSE_SOUND_VOLUME = 80
    CLOSE_SOUND_PITCH = 100
  ONLY_SHOW_ONE = true
  SHOW_POPUP_TEXT = true
    SHOW_POPUP_TEXT_ICON = true
    TEXT_WINDOW_Y = 1800
    TEXT_WINDOW_X_OFFSET = 0
    WAIT_FOR_BUTTON = true
    BUTTON_TO_WAIT_FOR1 = Input::C
    BUTTON_TO_WAIT_FOR2 = Input::B
    WAIT_FOR_TIME = 10
  USE_OVERLAY = true
  OVERLAY = 'Overlay1'
  
#==============================================================================
# Game_Interpreter
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # 取得 X 座標
  #--------------------------------------------------------------------------
  def get_x
    events = $game_map.events
    x_coord = events[@event_id]
    return x_coord.screen_x
  end
  #--------------------------------------------------------------------------
  # 取得 Y 座標
  #--------------------------------------------------------------------------
  def get_y
    events = $game_map.events
    y_coord = events[@event_id]
    return y_coord.screen_y
  end
  #--------------------------------------------------------------------------
  # 變更金錢
  #--------------------------------------------------------------------------
  alias chest_pop_command_125 command_125 unless $@
  def command_125
    value = operate_value(@params[0], @params[1], @params[2])
    if $game_switches[POPUP_SWITCH] != AUTO_POPUP and @params[0] == 0
      x_value = get_x
      y_value = get_y
      $scene = Chest_Popup.new(x_value, y_value, 0, value, 1)
    end
    chest_pop_command_125    
  end
  #--------------------------------------------------------------------------
  # 變更物品
  #--------------------------------------------------------------------------
  alias chest_pop_command_126 command_126 unless $@
  def command_126
    value = operate_value(@params[1], @params[2], @params[3])
    if $game_switches[POPUP_SWITCH] != AUTO_POPUP and @params[1] == 0
      x_value = get_x
      y_value = get_y
      $scene = Chest_Popup.new(x_value, y_value, 1, value, @params[0])
    end
    chest_pop_command_126
  end
  #--------------------------------------------------------------------------
  # 變更武器
  #--------------------------------------------------------------------------
  alias chest_pop_command_127 command_127 unless $@
  def command_127
    value = operate_value(@params[1], @params[2], @params[3])
    if $game_switches[POPUP_SWITCH] != AUTO_POPUP and @params[1] == 0
      x_value = get_x
      y_value = get_y
      $scene = Chest_Popup.new(x_value, y_value, 2, value, @params[0])
    end
    chest_pop_command_127
  end
  #--------------------------------------------------------------------------
  # 變更防具
  #--------------------------------------------------------------------------
  alias chest_pop_command_128 command_128 unless $@
  def command_128
    value = operate_value(@params[1], @params[2], @params[3])
    if $game_switches[POPUP_SWITCH] != AUTO_POPUP and @params[1] == 0
      x_value = get_x
      y_value = get_y
      $scene = Chest_Popup.new(x_value, y_value, 3, value, @params[0])
    end
    chest_pop_command_128
  end
end

#==============================================================================
#==============================================================================

class Item_Popup_Window < Window_Base
  #--------------------------------------------------------------------------
  # 初始化
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(0, 0, 544, 416)
    self.opacity = 0
    @x = x - 26
    @y = y - 56
  end
  #--------------------------------------------------------------------------
  # 顯示彈出圖示
  #--------------------------------------------------------------------------
  def pop_up(icon_index, x, y)
    self.contents.clear
    #draw_item_name(index, x, y, true)###
    draw_icon(icon_index, x, y, true)
  end
end

#==============================================================================
# 名稱視窗
#==============================================================================

class Name_Window < Window_Base
  #--------------------------------------------------------------------------
  # 初始化
  #--------------------------------------------------------------------------
  def initialize(x, y, desc, no_desc, desc_size, gold = false, icon = 0)
    width = desc.size * 12
    super(x, y, width, WLH + 32)
    self.width = self.contents.text_size(desc).width + 32
    self.x = ((544 - self.width) / 2) + TEXT_WINDOW_X_OFFSET
    create_contents
    if SHOW_POPUP_TEXT_ICON
      if no_desc
        draw_icon(icon, 0, 0) unless gold
      else
        if desc_size == 2
          draw_icon(icon, 46, 0) unless gold
        else
          draw_icon(icon, 34, 0) unless gold
        end
      end
    end
    self.contents.draw_text(0, 0, width, WLH, desc, 0) unless gold
    self.contents.draw_text(4, 0, width, WLH, desc, 0) if gold
    draw_icon(GOLD_ICON, width - 66, 0, true) if gold
  end
end

#==============================================================================
#==============================================================================

class Scene_Base
  #--------------------------------------------------------------------------
  # 初始化
  #--------------------------------------------------------------------------
  def initialize
    @disable_blur = false
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def disable_blur(enabled = false)
    @disable_blur = enabled
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def snapshot_for_background
    $game_temp.background_bitmap.dispose
    $game_temp.background_bitmap = Graphics.snap_to_bitmap
    $game_temp.background_bitmap.blur unless @disable_blur
  end
end

#==============================================================================
#==============================================================================

class Chest_Popup < Scene_Base
  #--------------------------------------------------------------------------
  # 初始化
  #--------------------------------------------------------------------------
  def initialize(x, y, type, amount, index, add = false)
    $game_switches[POPUP_SWITCH] = !AUTO_POPUP
    $scene.disable_blur(true)
    @x = x
    @y = y
    if USE_OVERLAY
      $game_map.screen.pictures[1].show(OVERLAY, 1, @x, @y, 100, 100, 0, 0)
      $game_map.screen.pictures[1].move(1, @x, @y, 100, 100, 255, 0, 10)
      wait(10) # 詳見頁首繁中說明
    end
    @amount = amount
    @gold = false
    @no_desc = false
    @desc_size = 1
    @desc_size = 2 if amount > 9
    case type
    when 0 # 詳見頁首繁中說明
      @desc_size = 1
      $game_party.gain_gold(amount) if add
      @icon_index = GOLD_ICON
      @desc_amount = ''
      @desc = @amount.to_s
      @amount = 1
      @gold = true
    when 1 # 詳見頁首繁中說明
      $game_party.gain_item($data_items[index], amount) if add
      @icon_index = $data_items[index].icon_index
      @desc_amount = @amount.to_s + ''
      if @amount == 1
        @desc_amount = '   '
        @no_desc = true
      end
      @desc = $data_items[index].name
      @amount = 1 if ONLY_SHOW_ONE
    when 2 # 詳見頁首繁中說明
      $game_party.gain_item($data_weapons[index], amount) if add
      @icon_index = $data_weapons[index].icon_index
      @desc_amount = @amount.to_s + ''
      if @amount == 1
        @desc_amount = '   '
        @no_desc = true
      end
      @desc = $data_weapons[index].name
      @amount = 1 if ONLY_SHOW_ONE
    when 3 # 詳見頁首繁中說明
      $game_party.gain_item($data_armors[index], amount) if add
      @icon_index = $data_armors[index].icon_index
      @desc_amount = @amount.to_s + ''
      if @amount == 1
        @desc_amount = '   '
        @no_desc = true
      end
      @desc = $data_armors[index].name
      @amount = 1 if ONLY_SHOW_ONE
    end
    if @gold
      @desc = @desc + '     '
    else
      if SHOW_POPUP_TEXT_ICON
        @desc = @desc_amount + '   ' + @desc
      else
        @desc = @desc_amount + '   ' + @desc
      end
    end
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def start
    create_background
    @popup_window = Item_Popup_Window.new(@x, @y)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def terminate
    @popup_window.dispose
    @menuback_sprite.dispose
    @name_window.dispose if SHOW_POPUP_TEXT
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def return_scene
    $scene.disable_blur(false)
    $game_switches[POPUP_SWITCH] = false
    $scene = Scene_Map.new
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update
    super
    @popup_window.update
    @menuback_sprite.update
    do_popup
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_basic
    Graphics.update              
    Input.update                  
    $game_map.screen.update              
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def wait(duration)
    for i in 0...duration
      update_basic
    end
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def wait_for_close
    count = 0
    loop do
      update_basic
      count += 1
      break if Input.trigger?(BUTTON_TO_WAIT_FOR1) and WAIT_FOR_BUTTON
      break if Input.trigger?(BUTTON_TO_WAIT_FOR2) and WAIT_FOR_BUTTON
      break if count >= WAIT_FOR_TIME and !WAIT_FOR_BUTTON
    end  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def create_background
    @menuback_sprite = Sprite.new
    @menuback_sprite.bitmap = $game_temp.background_bitmap
    @menuback_sprite.update
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def show_name
    x = 272
    y = TEXT_WINDOW_Y
    cy = $game_player.screen_y - y
    cy *= -1 if cy < 0
    if cy < 128
      if $game_player.screen_y < TEXT_WINDOW_Y
        y = TEXT_WINDOW_Y + (TEXT_WINDOW_Y / 2)
      else
        y = TEXT_WINDOW_Y - (TEXT_WINDOW_Y / 2)
      end
    end
    @name_window = Name_Window.new(x, y, @desc, @no_desc, @desc_size, @gold, @icon_index)
    wait_for_close
    Audio.se_play('Audio/SE/' + CLOSE_SOUND, CLOSE_SOUND_VOLUME, CLOSE_SOUND_PITCH) if WAIT_FOR_BUTTON and PLAY_CLOSE
    if USE_OVERLAY
      $game_map.screen.pictures[1].move(1, @x, @y, 100, 100, 0, 0, 10)
      wait(20)
      $game_map.screen.pictures[1].erase
    end
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def do_popup
    for i in 1..@amount
      Audio.se_play('Audio/SE/' + POPUP_SOUND, POPUP_SOUND_VOLUME, POPUP_SOUND_PITCH) if PLAY_POPUP_SOUND
      for i in 0..4
        @popup_window.pop_up(@icon_index, @x - 26, @y - (i * 4) - 48)
        @popup_window.update
        wait(2)
      end
      wait(5) if i != @amount and !ONLY_SHOW_ONE
    end
    wait(5)
    show_name if SHOW_POPUP_TEXT
    return_scene
  end
end