#==============================================================================
# 【Forest Symphony｜繁體中文完整說明】
#------------------------------------------------------------------------------
# 腳本：RingMenu_Core v1.1｜Common Event Ring Menu
# 【來源】原 Ring Menu：Syvkal v1.1（2008-06-23）；Xaiko 改為 Common Event Ring Menu 並加入第二組 Ring Menu（2010～2011）。
# 【用途】提供 Scene_RM 與 Scene_RM2 兩套環形指令選單；每個項目由「文字＋Picture icon＋字串形式的 Ruby command」組成，確認後以 `eval` 執行。
# 【第一組 `$game_ring_menu`】對話→CE145、騎乘→CE146、伐木→CE147、挖礦→CE153、採集→CE154、野地考察→Scene_File。
# 【第二組 `$game_ring_cm`】書庫→CE145、騎乘→CE146、熊型態→CE147、狼型態→CE148、橡木聖地→CE149、地圖→CE150。
# 【解鎖條件】Scene_RM 同時依 Variable 4、Switch 32/141、Item 155/171/184 等條件禁用項目；Scene_RM2 依 Switch 139～144。這些 ID 已是事件介面，調整前先查《變數／開關完整整理》。
# 【動畫設定】STARTUP_FRAMES=20、MOVING_FRAMES=15、RING_R=68；Window_RingMenu 狀態 START/WAIT/MOVER/MOVEL 控制進場與左右旋轉。
# 【素材】`Locked` 與 `cm_1..cm_6` 使用 Graphics/Pictures；Window 以 Picture Bitmap 當 icon，不是 Iconset index。
# 【Load Order】Scene_Title#create_game_objects 建立兩組全域 menu table；後方 `FS_RingMenuActions v1.3` 仍會整合現行 Ring Menu 行為，因此本頁是 Core，不是最後 Authority。
# 【呼叫範例】現有事件可直接 `$scene = Scene_RM.new` 或 `$scene = Scene_RM2.new`；實際專案 Data 已有這兩個 Scene 入口。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址保留；Phase 21 Archive 另保存修改前 byte-exact 原稿。
# 4. 本輪除 Friendly Monsters GoldFix 回寫外，只整理文件／架構標記；其餘 Runtime code 與載入順序不得因翻譯改變。
#==============================================================================
#==============================================================================
# Version 1.1
# 06-23-08
#
# 2010
#
# 2011
#==============================================================================

   #===================================================#
   #  **  設定區  **  #
   #===================================================#
  
  STARTUP_FRAMES = 20
  MOVING_FRAMES = 15
  RING_R = 68
  ICON_DISABLE= Cache::picture('Locked')
  
  
   #-------------------以下勿任意修改-------------------#
  
  class Scene_Title < Scene_Base
    alias game_objects_original create_game_objects
    def create_game_objects
      game_objects_original
  
   #-------------------以下勿任意修改-------------------#
  
  

  $game_ring_menu = [
  
   ["對話", Cache::picture('cm_5'), 
   "$game_temp.common_event_id = 145"],
  
   ["騎乘", Cache::picture('cm_4'), 
   "$game_temp.common_event_id = 146"],
  
   ["伐木", Cache::picture('cm_3'), 
   "$game_temp.common_event_id = 147"],
  
   ["挖礦", Cache::picture('cm_2'), 
   "$game_temp.common_event_id = 153"],
  
  
   ["採集", Cache::picture('cm_1'), 
   "$game_temp.common_event_id = 154"],
  
   ["野地考察", Cache::picture('cm_6'), "$scene = Scene_File.new(false, false, false)"]
  
   #["", Cache::picture('cm_2'), "$scene = Scene_End.new"],
   #["", Cache::picture('cm_2'), "$scene = Scene_End.new"]
  
   ] # 詳見頁首繁中說明
   
   $game_ring_cm = [
  
   ["書庫", Cache::picture('cm_5'), 
   "$game_temp.common_event_id = 145"],
  
   ["騎乘", Cache::picture('cm_4'), 
   "$game_temp.common_event_id = 146"],
  
   ["熊型態", Cache::picture('cm_3'), 
   "$game_temp.common_event_id = 147"],
  
   ["狼型態", Cache::picture('cm_2'), 
   "$game_temp.common_event_id = 148"],
  
  
   ["橡木聖地", Cache::picture('cm_1'), 
   "$game_temp.common_event_id = 149"],
  
   ["地圖", Cache::picture('cm_6'), 
   "$game_temp.common_event_id = 150"]
  
   ] # 詳見頁首繁中說明
  
   #===================================================#
   #  **  設定區結束  **  #
   #===================================================#
  end
end
#==============================================================================
#------------------------------------------------------------------------------
#==============================================================================




class Scene_RM < Scene_Base
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize(menu_index = 0, move = true)
    @move = move
    @menu_index = menu_index
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def start
    super
    @menuback_sprite = Plane.new
    @menuback_sprite.bitmap = $game_temp.background_bitmap
    @menuback_sprite.color.set(16, 16, 16, 184)
    create_command_window
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_menu_background
    @command_window.dispose
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update
    super
    update_menu_background
    @command_window.update
    if @command_window.active
      update_command_selection
    end
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def create_command_window
    commands = []
    for i in 0...$game_ring_menu.size
      commands.push($game_ring_menu[i][0])
    end
    icons = []
    for i in 0...$game_ring_menu.size
      icons.push($game_ring_menu[i][1])
    end
    @command_window = Window_RingMenu.new(240,174,commands, icons, @move, @menu_index)

    #-------
    #-------
    if $game_variables[4] == 98 # 詳見頁首繁中說明
      @command_window.disable_item(3)
      @command_window.disable_item(4)
    elsif $game_variables[4] == 99 # 詳見頁首繁中說明
      @command_window.disable_item(0)
      @command_window.disable_item(2)
      @command_window.disable_item(3)
      @command_window.disable_item(4)
    else
    
    if $game_party.has_item?($data_items[155]) == false # 詳見頁首繁中說明
      @command_window.disable_item(0)
    end
    if $game_switches[32] == false # 詳見頁首繁中說明
      @command_window.disable_item(1)
    end
    if $game_switches[141] == false # 詳見頁首繁中說明
      @command_window.disable_item(2)
    end
    if $game_party.has_item?($data_items[171]) == false # 詳見頁首繁中說明
      @command_window.disable_item(3)
    end
    if $game_party.has_item?($data_items[184]) == false # 詳見頁首繁中說明
      @command_window.disable_item(4)
    end
    
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_command_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      $scene = Scene_Map.new
    elsif Input.trigger?(Input::C)
      if $game_variables[4] == 98
      Sound.play_decision
      eval($game_ring_menu[@command_window.index][2])
      $scene = Scene_Map.new
      elsif $game_variables[4] == 99 and @command_window.index == 1
      Sound.play_decision
      eval($game_ring_menu[@command_window.index][2])
      $scene = Scene_Map.new
      else
      if $game_party.has_item?($data_items[155]) == false and @command_window.index == 0 # 詳見頁首繁中說明
      Sound.play_buzzer
      return
      elsif $game_switches[32] == false and @command_window.index == 1
        Sound.play_buzzer
        return
      elsif $game_switches[141] == false and @command_window.index == 2
        Sound.play_buzzer
        return
      elsif $game_party.has_item?($data_items[171]) == false and @command_window.index == 3
        Sound.play_buzzer
        return
      elsif $game_party.has_item?($data_items[184]) == false and @command_window.index == 4
        Sound.play_buzzer
        return
      end
      end
      Sound.play_decision
      eval($game_ring_menu[@command_window.index][2])
      $scene = Scene_Map.new
    end
  end
end


#----------------------------
#----------------------------


class Scene_RM2 < Scene_Base
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize(menu_index = 0, move = true)
    @move = move
    @menu_index = menu_index
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def start
    super
    @menuback_sprite = Plane.new # 詳見頁首繁中說明
    
    @menuback_sprite.bitmap = $game_temp.background_bitmap
    @menuback_sprite.color.set(16, 16, 16, 128)
    @menuback_sprite.z=99
    @menuback_sprite2 = Sprite.new
    @menuback_sprite2.bitmap = Cache.picture("lufia_capsule")
    @menuback_sprite2.z = 100
    create_command_window
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_menu_background
    @menuback_sprite2.dispose
    @command_window.dispose
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update
    super
    update_menu_background
    @command_window.update
    if @command_window.active
      update_command_selection
    end
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def create_command_window
    commands = []
    for i in 0...$game_ring_cm.size
      commands.push($game_ring_cm[i][0])
    end
    icons = []
    for i in 0...$game_ring_cm.size
      icons.push($game_ring_cm[i][1])
    end
    @command_window = Window_RingMenu.new(240,174,commands,icons,@move,@menu_index)
            #(232, 164, ...240,174
    #-------
    #-------
    if $game_switches[139] == false #書庫
      @command_window.disable_item(0)
    end
    if $game_switches[140] == false #騎乘
      @command_window.disable_item(1)
    end
    if $game_switches[141] == false #熊
      @command_window.disable_item(2)
    end
    if $game_switches[142] == false #狼
      @command_window.disable_item(3)
    end
    if $game_switches[143] == false #休息
      @command_window.disable_item(4)
    end
    if $game_switches[144] == false #地圖
      @command_window.disable_item(5)
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_command_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      $scene = Scene_Map.new
      $screen_print.dispose
    elsif Input.trigger?(Input::C)
      if $game_variables[4] == 98
      Sound.play_decision
      eval($game_ring_cm[@command_window.index][2])
      $scene = Scene_Map.new
      $screen_print.dispose
      elsif $game_variables[4] == 99 and @command_window.index == 1
      Sound.play_decision
      eval($game_ring_cm[@command_window.index][2])
      $scene = Scene_Map.new
      else
      if $game_switches[139] == false and @command_window.index == 0
      Sound.play_buzzer
      return
      elsif $game_switches[140] == false and @command_window.index == 1
        Sound.play_buzzer
        return
      elsif $game_switches[141] == false and @command_window.index == 2
        Sound.play_buzzer
        return
      elsif $game_switches[142] == false and @command_window.index == 3
        Sound.play_buzzer
        return
      elsif $game_switches[143] == false and @command_window.index == 4
        Sound.play_buzzer
        return
      elsif $game_switches[144] == false and @command_window.index == 5
        Sound.play_buzzer
        return
      end
      end
      Sound.play_decision
      eval($game_ring_cm[@command_window.index][2])
      $scene = Scene_Map.new
      $screen_print.dispose
    end
  end
end




#----------------------------
#----------------------------




#==============================================================================
#------------------------------------------------------------------------------
#==============================================================================

class Window_RingMenu < Window_Base  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  attr_accessor :index
  attr_reader   :item_max
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  START = 1
  WAIT  = 2
  MOVER = 3
  MOVEL = 4
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize(center_x, center_y, commands, items, move = true, index = 0, character = false)
    super(0, 0, 544, 416)
    self.contents = Bitmap.new(width-32, height-32)
    self.opacity = 0
    @move = move
    @char = character
    @startup = STARTUP_FRAMES
    @commands = commands
    @item_max = commands.size
    @index = index
    @items = items
    @disabled = []
    for i in 0...commands.size-1
      @disabled[i] = false
    end
    @cx = center_x
    @cy = center_y
    start_setup
    refresh
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def start_setup
    @mode = START
    @steps = @startup
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def disable_item(index)
    @disabled[index] = true
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def animation?
    return @mode != WAIT
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def cursor_movable?
    return false if (not visible or not active)
    return false if (@opening or @closing)
    return false if animation?
    return true
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def cursor_right
    @index -= 1
    @index = @items.size - 1 if @index < 0
    @mode = MOVER
    @steps = MOVING_FRAMES
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def cursor_left
    @index += 1
    @index = 0 if @index >= @items.size
    @mode = MOVEL
    @steps = MOVING_FRAMES
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def cursor_right2
    @index -= 2
    @index = @items.size - 1 if @index < 0
    @mode = MOVER
    @steps = MOVING_FRAMES
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def cursor_left2
    @index += 2
    @index = 0 if @index >= @items.size
    @mode = MOVEL
    @steps = MOVING_FRAMES
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update
    super
    if self.active
      if cursor_movable?
        last_index = @index
        if Input.repeat?(Input::DOWN) or Input.repeat?(Input::RIGHT)
          cursor_right
        end
        if Input.repeat?(Input::UP) or Input.repeat?(Input::LEFT)
          cursor_left
        end
        if @index != last_index
          Sound.play_cursor
        end
      end
      refresh
    end
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh    
    self.contents.clear
    case @mode
    when START
      refresh_start
    when WAIT
      refresh_wait
    when MOVER
      refresh_move(1)
    when MOVEL
      refresh_move(0)
    end
    rect = Rect.new(18, 172, self.contents.width-32, 32)
    self.contents.draw_text(rect, @commands[@index], 1)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh_start
    d1 = 2.0 * Math::PI / @item_max
    d2 = 1.0 * Math::PI / @startup
    for i in 0...@item_max
      j = i - @index
      if @move
        r = RING_R - 1.0 * RING_R * @steps / @startup
        d = d1 * j + d2 * @steps
      else
        r = RING_R
        d = d1 * j
      end
      x = @cx + ( r * Math.sin( d ) ).to_i
      y = @cy - ( r * Math.cos( d ) ).to_i
      draw_item(x, y, i)
    end
    @steps -= 1
    if @steps < 1
      @mode = WAIT
    end
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh_wait
    d = 2.0 * Math::PI / @item_max
    for i in 0...@item_max
      j = i - @index
      x = @cx + ( RING_R * Math.sin( d * j ) ).to_i
      y = @cy - ( RING_R * Math.cos( d * j ) ).to_i
      draw_item(x, y, i)
    end
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh_move( mode )
    d1 = 2.0 * Math::PI / @item_max
    d2 = d1 / MOVING_FRAMES
    d2 *= -1 if mode != 0
    for i in 0...@item_max
      j = i - @index
      d = d1 * j + d2 * @steps
      x = @cx + ( RING_R * Math.sin( d ) ).to_i
      y = @cy - ( RING_R * Math.cos( d ) ).to_i
      draw_item(x, y, i)
    end
    @steps -= 1
    if @steps < 1
      @mode = WAIT
    end
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_item(x, y, index)
    if @char
      if @index == index
        draw_character(@items[index].character_name, @items[index].character_index , x, y)
        if @mode == WAIT
          draw_actor_hp_ring(@items[index], @cx, @cy-16, 50, 6, 84, 270, true)
          draw_actor_mp_ring(@items[index], @cx, @cy-16, 50, 6, 84, 180, false)
          draw_actor_exp_ring(@items[index], @cx, @cy-16, 50, 6, 155, 12, false)
        end
      else
        draw_character(@items[index].character_name, @items[index].character_index , x, y, false)
      end
    else
      rect = Rect.new(0, 0, @items[index].width, @items[index].height)
      if @index == index
        self.contents.blt( x, y, @items[index], rect )
        if @disabled[@index]
          self.contents.blt( x, y, ICON_DISABLE, rect )
        end
      else
        self.contents.blt( x, y, @items[index], rect, 128 )
      end
    end
  end
end

#==============================================================================
#------------------------------------------------------------------------------
#==============================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_character(character_name, character_index, x, y, enabled = true)
    return if character_name == nil
    bitmap = Cache.character(character_name)
    sign = character_name[/^[\!\$]./]
    if sign != nil and sign.include?('$')
      cw = bitmap.width / 3
      ch = bitmap.height / 4
    else
      cw = bitmap.width / 12
      ch = bitmap.height / 8
    end
    n = character_index
    src_rect = Rect.new((n%4*3+1)*cw, (n/4*4)*ch, cw, ch)
    self.contents.blt(x - cw / 2, y - ch, bitmap, src_rect, enabled ? 255 : 128)
  end
end