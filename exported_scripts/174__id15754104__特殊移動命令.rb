#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：特殊移動命令
# 【用途】保留的 Runtime 元件「特殊移動命令」。
# 【主要機制】主要定義／擴充 Game_Character；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Game_Character
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
#===============================================================
# ● [VX] ◦ Improved & Special Move Commands ◦ □
#--------------------------------------------------------------
# ◦ by Woratana [woratana@hotmail.com]
# ◦ Released on: 20/03/2008
# ◦ Version: 1.0
#--------------------------------------------------------------
=begin
□=====□=====□=====□=====□=====□=====□=====□=====□=====□
                   + COMMANDS LIST +
□=====□=====□=====□=====□=====□=====□=====□=====□=====□
################################
● IMPROVED MOVE COMMANDS ●

□ SAFE JUMP:
Don't Jump if its destination is OUT OF THE SCREEN (or) NOT PASSABLE.
(Old jump will not check before jump)

□ IMPROVED RANDOM MOVE
Find the movable direction before move.
(Old random move will just skip to move in that frame, if its destination is not passable.)

□ IMPROVED COLLIDE_WITH_CHARACTERS CHECK
'Same as Characters' events are able to walk on other 'Below Characters' events.

● Note: If you don't want one of this improved command, just delete its part.
(I put all of their command name above their script part)
################################

################################
● SPECIAL(NEW) MOVE COMMANDS ●

++[HOW TO USE]++
● Open 'Move Route' window, (or event command 'Set Move Route')
Click 'Script...' and type the move command you want...

□ MOVE TOWARD POSITION X/Y
move_toward_pos(x,y)

□ MOVE AWAY FROM POSITION X/Y
move_away_from_pos(x,y)

□ MOVE TOWARD EVENT ID
move_toward_event(id)

□ MOVE AWAY FROM EVENT ID
move_away_from_event(id)

□ TURN TOWARD POSITION X/Y
turn_toward_pos(x,y)

□ TURN AWAY FROM POSITION X/Y
turn_away_from_pos(x,y)

□ TURN TOWARD EVENT ID
turn_toward_event(id)

□ TURN AWAY FROM EVENT ID
turn_away_from_event(id)
################################
=end
class Game_Character
  ##################################################################
  # IMPROVED MOVE COMMANDS
  ##################################################################
  #-------------------------------------------------------------
  # SAFE JUMP
  #-------------------------------------------------------------
  def jump(x_plus, y_plus)
    if x_plus.abs > y_plus.abs            # 横の距離のほうが長い
      x_plus < 0 ? turn_left : turn_right
    elsif x_plus.abs > y_plus.abs         # 縦の距離のほうが長い
      y_plus < 0 ? turn_up : turn_down
    end
    new_x = @x + x_plus
    new_y = @y + y_plus
    if (x_plus == 0 and y_plus == 0) or passable?(new_x, new_y)
      @x += x_plus
      @y += y_plus
      distance = Math.sqrt(x_plus * x_plus + y_plus * y_plus).round
      @jump_peak = 10 + distance - @move_speed
      @jump_count = @jump_peak * 2
      @stop_count = 0
      straighten
    end
  end
  
  #-------------------------------------------------------------
  # IMPROVED RANDOM MOVE
  #-------------------------------------------------------------
  def move_random
    safe = false
    checked = []
    while safe == false
      break if checked.include?(0) and checked.include?(1) and
      checked.include?(2) and checked.include?(3)
      case rand(4)
      when 0; return if checked.include?(0); checked.push 0
        if passable?(@x, @y + 1)
          safe = true; move_down(false)
        end
      when 1; return if checked.include?(1); checked.push 1
        if passable?(@x - 1, @y)
          safe = true; move_left(false)
        end
      when 2; return if checked.include?(2); checked.push 2
        if passable?(@x + 1, @y)
          safe = true; move_right(false)
        end
      when 3; return if checked.include?(3); checked.push 3
        if passable?(@x - 1, @y)
          safe = true; move_up(false)
        end
      end
    end
  end
  
  #----------------------------------------------------------------------
  # IMPROVED COLLIDE_WITH_CHARACTERS CHECK
  #----------------------------------------------------------------------
  def collide_with_characters?(x, y)
    for event in $game_map.events_xy(x, y)          # Matches event position
      unless event.through                          # Passage OFF?
        return true if event.priority_type == 1     # Target is normal char
      end
    end
    if @priority_type == 1                          # Self is normal char
      return true if $game_player.pos_nt?(x, y)     # Matches player position
      return true if $game_map.boat.pos_nt?(x, y)   # Matches boat position
      return true if $game_map.ship.pos_nt?(x, y)   # Matches ship position
    end
    return false
  end
  
  ##################################################################
  # SPECIAL(NEW) MOVE COMMANDS
  ##################################################################
  #--------------------------------------------------------------------------
  # * Move toward Position
  #--------------------------------------------------------------------------
  def move_toward_pos(x,y)
    sx = distance_x_from_pos(x)
    sy = distance_y_from_pos(y)
    if sx != 0 or sy != 0
      if sx.abs > sy.abs                  # Horizontal distance is longer
        sx > 0 ? move_left : move_right   # Prioritize left-right
        if @move_failed and sy != 0
          sy > 0 ? move_up : move_down
        end
      else                                # Vertical distance is longer
        sy > 0 ? move_up : move_down      # Prioritize up-down
        if @move_failed and sx != 0
          sx > 0 ? move_left : move_right
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Move away from Position
  #--------------------------------------------------------------------------
  def move_away_from_pos(x,y)
    sx = distance_x_from_pos(x)
    sy = distance_y_from_pos(y)
    if sx != 0 or sy != 0
      if sx.abs > sy.abs                  # Horizontal distance is longer
        sx > 0 ? move_right : move_left   # Prioritize left-right
        if @move_failed and sy != 0
          sy > 0 ? move_down : move_up
        end
      else                                # Vertical distance is longer
        sy > 0 ? move_down : move_up      # Prioritize up-down
        if @move_failed and sx != 0
          sx > 0 ? move_right : move_left
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Move toward Event
  #--------------------------------------------------------------------------
  def move_toward_event(id)
    move_toward_pos($game_map.events[id].x,$game_map.events[id].y)
  end
  #--------------------------------------------------------------------------
  # * Move away from Event
  #--------------------------------------------------------------------------
  def move_away_from_event(id)
    move_away_from_pos($game_map.events[id].x,$game_map.events[id].y)
  end
  #--------------------------------------------------------------------------
  # * Turn toward Position
  #--------------------------------------------------------------------------
  def turn_toward_pos(x,y)
    sx = distance_x_from_pos(x)
    sy = distance_y_from_pos(y)
    if sx.abs > sy.abs                    # Horizontal distance is longer
      sx > 0 ? turn_left : turn_right
    elsif sx.abs < sy.abs                 # Vertical distance is longer
      sy > 0 ? turn_up : turn_down
    end
  end
  #--------------------------------------------------------------------------
  # * Turn away from Position
  #--------------------------------------------------------------------------
  def turn_away_from_pos(x,y)
    sx = distance_x_from_pos(x)
    sy = distance_y_from_pos(y)
    if sx.abs > sy.abs                    # Horizontal distance is longer
      sx > 0 ? turn_right : turn_left
    elsif sx.abs < sy.abs                 # Vertical distance is longer
      sy > 0 ? turn_down : turn_up
    end
  end
  #--------------------------------------------------------------------------
  # * Turn toward Event
  #--------------------------------------------------------------------------
  def turn_toward_event(id)
    turn_toward_pos($game_map.events[id].x,$game_map.events[id].y)
  end
  #--------------------------------------------------------------------------
  # * Turn away from Event
  #--------------------------------------------------------------------------
  def turn_away_from_event(id)
    turn_away_from_pos($game_map.events[id].x,$game_map.events[id].y)
  end
  #--------------------------------------------------------------------------
  # * Calculate X Distance From Event
  #--------------------------------------------------------------------------
  def distance_x_from_pos(x)
    sx = @x - x
    if $game_map.loop_horizontal?         # When looping horizontally
      if sx.abs > $game_map.width / 2     # Larger than half the map width?
        sx -= $game_map.width             # Subtract map width
      end
    end
    return sx
  end
  #--------------------------------------------------------------------------
  # * Calculate Y Distance From Event
  #--------------------------------------------------------------------------
  def distance_y_from_pos(y)
    sy = @y - y
    if $game_map.loop_vertical?           # When looping vertically
      if sy.abs > $game_map.height / 2    # Larger than half the map height?
        sy -= $game_map.height            # Subtract map height
      end
    end
    return sy
  end
end