#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Ev.Cmds for Sequences Add-on v1.0
# 【作者】Mr. Bubble。
# 【用途】替 RPG Tankentai Sideview Battle System 的 ANIME Action Sequence 增加「事件式畫面命令」，讓戰鬥動作可以控制 Picture、Weather、Flash、Tone、Shake、Fade。
# 【載入順序】原作者要求放在 Sideview 與 ATB 腳本下方。本頁會 N01::ANIME.merge!(EVENT_COMMANDS_FOR_SEQUENCES) 並 alias Sprite_Battler#action，故必須維持現行已驗證順序。
# 【Show Picture】["show_pic", id, file, origin, x, y, zoom_x, zoom_y, opacity, blend]。id=1～20；file 來自 Graphics/Pictures；origin 0=左上、1=中心；opacity 0～255；blend 0正常／1加算／2減算。範例 Key：SHOW_PICTURE_1。
# 【Move Picture】["move_pic", id, origin, x, y, zoom_x, zoom_y, opacity, blend, time]，time 以 1/60 秒幀數計。範例：MOVE_PICTURE_1。
# 【Rotate Picture】["rotate_pic", id, speed]；正值逆時針、負值順時針。範例：ROTATE_PICTURE_1(CCW/CW)。
# 【Tint Picture】["tint_pic", id, red, green, blue, gray, time]；RGB -255～255、gray 0～255。範例：TINT_PICTURE_1_RED/GREEN/BLUE/GRAY。
# 【Erase Picture】["erase_pic", id]。範例：ERASE_PICTURE_1。
# 【Flash】["flash", red, green, blue, strength, time]；顏色／strength 0～255。範例：RED_FLASH。
# 【Tint Screen】["tint_screen", red, green, blue, gray, time]；不影響 Window／Picture，而且 Action Sequence 結束不會自動恢復。範例：NORMAL_SCREEN_COLOR 可回復一般色調。
# 【Shake】["shake", power, speed, time]，power／speed 1～10。範例：SHAKE_SCREEN、SHAKE_SCREEN_MILD。
# 【特殊 Key】CLEAR_ALL_PICTURES 清除 1～20 Event Pictures；FADEOUT／FADEIN 使用 Graphics fade，腳本內目前 time=60。
# 【Weather】Runtime 支援 action type "weather"，參數為 type/power/time，實際呼叫 $game_troop.screen.weather(type, power, time)。
# 【範例】不要直接呼叫 Sprite_Battler#show_picture；在 SBS ANIME hash 中使用本頁已定義 Key 或依上述格式新增 Key，讓 action dispatcher 正常管理時序。
# 【相關素材】SHOW_PICTURE_1 範例使用 Graphics/Pictures/Actor2-3；其他 Picture 名稱由各 ANIME Key 決定，沒有單一固定素材清單。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 維護說明集中於腳本最前方；程式識別字、Notetag、Script Call、Action Key 不可翻譯改名。
# 2. 原作者、版本、Credits、License、網址等來源資訊保留；翻譯前 byte-exact 原稿另存 Phase 17 Archive。
# 3. 範例只列原文件或既有程式能直接證實的入口，不捏造 API。
# 4. 本輪除註解／說明外不修改任何可執行 Ruby；載入順序仍以 FS LoadOrder Guide／Authority Map 為準。
#==============================================================================
#==============================================================================
#   v1.0
#------------------------------------------------------------------------------
# By Mr. Bubble
#==============================================================================
#==============================================================================


module N01

  EVENT_COMMANDS_FOR_SEQUENCES = {
 #--------------------------------------------------------------------------
 #--------------------------------------------------------------------------
  #
  #
  #          [0=以圖片左上角作為座標基準。]
  #          [1=以圖片中心作為座標基準。]
  
  "SHOW_PICTURE_1" => ["show_pic", 1, "Actor2-3", 1, 272, 208, 100, 100, 255, 0],

 #--------------------------------------------------------------------------
 #--------------------------------------------------------------------------
  #
  #          [0=以圖片左上角作為座標基準。]
  #          [1=以圖片中心作為座標基準。]
  
  "MOVE_PICTURE_1" => ["move_pic", 1,   1,  -125, 208, 100, 100, 255,    1,  60],

 #--------------------------------------------------------------------------
 #--------------------------------------------------------------------------
  #

  "ROTATE_PICTURE_1(CCW)"     => ["rotate_pic",   1,   5],
  "ROTATE_PICTURE_1(CW)"      => ["rotate_pic",   1,  -5],

 #--------------------------------------------------------------------------
 #--------------------------------------------------------------------------
  #

  "TINT_PICTURE_1_RED"     => ["tint_pic",  1,  255,   0,   0,  100,    45],
  "TINT_PICTURE_1_GREEN"   => ["tint_pic",  1,    0, 255,   0,  100,    45],
  "TINT_PICTURE_1_BLUE"    => ["tint_pic",  1,    0,   0, 255,  100,    45],
  "TINT_PICTURE_1_GRAY"    => ["tint_pic",  1,    0,   0,   0,  255,    45],

 #--------------------------------------------------------------------------
 #--------------------------------------------------------------------------
  #
  
  "ERASE_PICTURE_1"   => ["erase_pic",  1],

 #--------------------------------------------------------------------------
 #--------------------------------------------------------------------------
  #

  "RED_FLASH"         => ["flash",  255,      0,     0,      64,     6],

 #--------------------------------------------------------------------------
 #--------------------------------------------------------------------------
  #
  
  "TINT_SCREEN_RED"       => ["tint_screen", 200,   0,   0,  100,    45],
  "TINT_SCREEN_BLUE"      => ["tint_screen",   0,   0, 200,  100,    45],
  "TINT_SCREEN_BLACK"     => ["tint_screen",  -50,  -50,  -50,  150,    45],
  "NORMAL_SCREEN_COLOR"   => ["tint_screen",   0,   0,   0,    0,    45],
  
 #--------------------------------------------------------------------------
 #--------------------------------------------------------------------------
  #
  
  "SHAKE_SCREEN2"      => ["shake",   10,   10,    10],
  "SHAKE_SCREEN"       => ["shake",   10,    10,    20],
  "SHAKE_SCREEN_MILD"  => ["shake",   1,    10,    30],
  "SHAKE_SCREEN_MILD2"  => ["shake",   2,    10,    30],
  "SHAKE_SCREEN_MILD3"  => ["shake",   4,    10,    30],

 #--------------------------------------------------------------------------
 #--------------------------------------------------------------------------

 #==========================================================================
 #--------------------------------------------------------------------------
 #--------------------------------------------------------------------------
 #==========================================================================

  "CLEAR_ALL_PICTURES"   => ["script", " 
  
    for i in 1..20
      $game_troop.screen.pictures[i].erase
    end
  
  "],

  "FADEOUT"   => ["script", " 

  time = 60
  Graphics.fadeout(time)

  "],
  
  "FADEIN"    => ["script", "
  
  time = 60
  Graphics.fadein(time)
  
  "],

}
  ANIME.merge!(EVENT_COMMANDS_FOR_SEQUENCES)
end

class Sprite_Battler < Sprite_Base
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def show_picture
    id = @active_action[1]
    name = @active_action[2]
    origin = @active_action[3]
    x = @active_action[4]
    y = @active_action[5]
    zoom_x = @active_action[6]
    zoom_y = @active_action[7]
    opacity = @active_action[8]
    blend_type = @active_action[9]
    # 執行顯示圖片
    $game_troop.screen.pictures[id].show(name, origin, x, y,zoom_x, zoom_y, 
opacity, blend_type)
  end

  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def move_picture
    id = @active_action[1]
    origin = @active_action[2]
    x = @active_action[3]
    y = @active_action[4]
    zoom_x = @active_action[5]
    zoom_y = @active_action[6]
    opacity = @active_action[7]
    blend_type = @active_action[8]
    duration = @active_action[9]
    # 執行移動圖片
    $game_troop.screen.pictures[id].move(origin, x, y, zoom_x, zoom_y, opacity, 
blend_type, duration)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def erase_picture
    $game_troop.screen.pictures[@active_action[1]].erase
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def rotate_picture
    id = @active_action[1]
    rotate_value = @active_action[2]
    # 執行旋轉圖片
    $game_troop.screen.pictures[id].rotate(rotate_value)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def tint_picture
    id = @active_action[1]
    red = @active_action[2]
    green = @active_action[3]
    blue = @active_action[4]
    gray = @active_action[5]
    duration = @active_action[6]
    # 執行圖片色調
    $game_troop.screen.pictures[id].start_tone_change(Tone.new(
red, green, blue, gray), duration)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def set_weather_effects
    type = @active_action[1]
    power = @active_action[2]
    time = @active_action[3]
    # 執行天氣效果
    $game_troop.screen.weather(type, power, time)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def flash_screen
    red = @active_action[1]
    green = @active_action[2]
    blue = @active_action[3]
    strength = @active_action[4]
    time = @active_action[5]
    # 執行畫面閃光
    $game_troop.screen.start_flash(Color.new(red,green, blue, strength), time)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def tint_screen
    red = @active_action[1]
    green = @active_action[2]
    blue = @active_action[3]
    gray = @active_action[4]
    time = @active_action[5]
    # 執行畫面色調
    $game_troop.screen.start_tone_change(Tone.new(red, green, blue, gray), time)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def screen_shake
    power = @active_action[1]
    speed = @active_action[2]
    duration = @active_action[3]
    # 執行畫面震動
    $game_troop.screen.start_shake(power, speed, duration)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias event_commands_for_sbs_addon_action action
  def action     
    return if @active_action == nil
    action = @active_action[0]    
    # 畫面震動效果
    return screen_shake if action == "shake"
    # 顯示事件圖片
    return show_picture if action == "show_pic"
    # 移動事件圖片
    return move_picture if action == "move_pic"
    # 消除事件圖片
    return erase_picture if action == "erase_pic"
    # 旋轉事件圖片
    return rotate_picture if action == "rotate_pic"
    # 改變事件圖片色調
    return tint_picture if action == "tint_pic"
    # 設定天氣效果
    return set_weather_effects if action == "weather"
    # 畫面閃光效果
    return flash_screen if action == "flash"
    return tint_screen if action == "tint_screen"
    
    event_commands_for_sbs_addon_action 
    
  end
end