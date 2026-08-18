#==============================================================================
# 【Forest Symphony｜繁體中文完整說明】
#------------------------------------------------------------------------------
# 腳本：YEM Controlled Encounter Rates
# 【來源】Yanfly Engine Melody，Controlled Encounter Rates，2010-06-30。
# 【用途】把 VX 隨機遇敵倒數改成較穩定的平均抽樣，並加入 Repel（暫停遇敵）、Lure（加速遇敵）與可選的畫面遇敵指示器。
# 【地形減值】BUSH_REDUCTION=1、NORM_REDUCTION=1，代表每步對 encounter countdown 的基本扣減。
# 【事件 Variables】STEPS_REMAINING_VARIABLE=61：剩餘倒數；REPEL_STEPS_VARIABLE=62，歸零時 Common Event 13；LURE_STEPS_VARIABLE=63、LURE_RATE_VARIABLE=64，歸零時 Common Event 14。這些 ID 已是正式事件介面，修改前必須反查 Data。
# 【倒數】ENCOUNTER_ROLLS=4：建立新倒數時抽樣次數並取平均；MINIMUM_FREE_STEPS=10：戰鬥後至少提供的免戰步數。
# 【事件用法】例如把 Variable 62 設為 100 可提供約 100 步 Repel；把 Variable 63 設為 60、Variable 64 設為 4，接下來 60 步會以較高扣減率逼近遇敵。Common Event ID 設 0 可停用歸零事件。
# 【指示器】USE_INDICATOR=false，所以目前不載入 Encounter0/Encounter1。若改 true，需要 Graphics/System/Encounter0 與 Encounter1，並由 INDICATOR_X/Y_POSITION、INDICATOR_COLOURS 控制位置與色彩。專案目前未找到這兩個素材，啟用前必須先補檔。
# 【Load Order】alias Spriteset_Map initialize/dispose/update 與 Game_Player 遇敵方法；屬地圖 Runtime，不應與一般 Encounter Event Script 混用或任意移到 Map 整合層最後。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、實際資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址保留；Phase 20 Archive 另保存修改前 byte-exact 原稿。
# 4. 除 EnemySummon SafePosition 責任回寫外，本輪只整理文件／註解；其他 Runtime code 與載入順序不得因翻譯而改變。
#==============================================================================
#===============================================================================
# 
# Last Date Updated: 2010.06.30
# Level: Normal
# 
# 
#===============================================================================
# -----------------------------------------------------------------------------
#===============================================================================
# 使用說明
# -----------------------------------------------------------------------------
# 
# 
#===============================================================================

$imported = {} if $imported == nil
$imported["ControlledEncounterRates"] = true

module YEM
  module ENCOUNTER
    
    #===========================================================================
    # --------------------------------------------------------------------------
    #===========================================================================
    
    BUSH_REDUCTION = 1 # 詳見頁首繁中說明
    NORM_REDUCTION = 1 # 詳見頁首繁中說明
    
    STEPS_REMAINING_VARIABLE = 61
    
    REPEL_STEPS_VARIABLE = 62
    REPEL_COMMON_EVENT   = 13 # 詳見頁首繁中說明
    
    LURE_STEPS_VARIABLE  = 63
    LURE_RATE_VARIABLE   = 64
    LURE_COMMON_EVENT    = 14 # 詳見頁首繁中說明
    
    #===========================================================================
    # --------------------------------------------------------------------------
    #===========================================================================
    
    ENCOUNTER_ROLLS = 4
    
    MINIMUM_FREE_STEPS = 10
    
    #===========================================================================
    # --------------------------------------------------------------------------
    #===========================================================================
    
    USE_INDICATOR = false
    
    INDICATOR_BACK_IMAGE = "Encounter0"
    
    INDICATOR_MAIN_IMAGE = "Encounter1"
    
    INDICATOR_X_POSITION = -12
    INDICATOR_Y_POSITION = Graphics.height - 36
    
    INDICATOR_COLOURS ={
      100 => [  0,   0, 200],
       90 => [ 50,  50, 200],
       80 => [100, 200, 250],
       70 => [150, 250, 150],
       60 => [200, 200, 100],
       50 => [250, 175, 100],
       40 => [250, 150,  75],
       30 => [250, 100,  50],
       20 => [250,   0,   0],
       10 => [250,   0,   0],
    } # 詳見頁首繁中說明
    
  end # 詳見頁首繁中說明
end # 詳見頁首繁中說明

#===============================================================================
#===============================================================================

#===============================================================================
#===============================================================================

class Spriteset_Map
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias initialize_cer initialize unless $@
  def initialize
    initialize_cer
    create_encounter_indicator
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def create_encounter_indicator
    return unless YEM::ENCOUNTER::USE_INDICATOR
    return unless $scene.is_a?(Scene_Map)
    @indicator_back_sprite = Sprite_Base.new(@viewport3)
    bitmap = Cache.system(YEM::ENCOUNTER::INDICATOR_BACK_IMAGE)
    @indicator_back_sprite.bitmap = bitmap
    @indicator_back_sprite.x = YEM::ENCOUNTER::INDICATOR_X_POSITION
    @indicator_back_sprite.y = YEM::ENCOUNTER::INDICATOR_Y_POSITION
    @indicator_main_sprite = Sprite_Base.new(@viewport3)
    bitmap = Cache.system(YEM::ENCOUNTER::INDICATOR_MAIN_IMAGE)
    @indicator_main_sprite.bitmap = bitmap
    @indicator_main_sprite.x = YEM::ENCOUNTER::INDICATOR_X_POSITION
    @indicator_main_sprite.y = YEM::ENCOUNTER::INDICATOR_Y_POSITION
    update_encounter_indicator(true)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias dispose_cer dispose unless $@
  def dispose
    dispose_cer
    dispose_encounter_indicator
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def dispose_encounter_indicator
    @indicator_back_sprite.dispose unless @indicator_back_sprite == nil
    @indicator_main_sprite.dispose unless @indicator_main_sprite == nil
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias update_cer update unless $@
  def update
    update_cer
    update_encounter_indicator
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_encounter_indicator(instant = false)
    update_back_indicator
    update_main_indicator(instant)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_back_indicator
    return if @indicator_back_sprite == nil
    adjust_indicator_opacity(@indicator_back_sprite)
    @indicator_back_sprite.update
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_main_indicator(instant = false)
    return if @indicator_main_sprite == nil
    change_main_indicator_colour
    update_indicator_colour(instant)
    adjust_indicator_opacity(@indicator_main_sprite)
    @indicator_main_sprite.update
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def change_main_indicator_colour
    return if @indicator_main_sprite == nil
    return if $game_map.encounter_step <= 0
    return if @encounter_count == $game_player.encounter_count_calc
    @encounter_count = $game_player.encounter_count_calc
    count = $game_player.encounter_count - 1
    count += $game_variables[YEM::ENCOUNTER::REPEL_STEPS_VARIABLE]
    if $game_variables[YEM::ENCOUNTER::LURE_STEPS_VARIABLE] > 0
      count -= [$game_variables[YEM::ENCOUNTER::LURE_RATE_VARIABLE], 1].max
    end
    percent = count * 100 / $game_map.encounter_step
    @indicator_colour = YEM::ENCOUNTER::INDICATOR_COLOURS[100]
    for i in [100, 90, 80, 70, 60, 50, 40, 30, 20, 10]
      next if i == nil
      break if percent > i
      @indicator_colour = YEM::ENCOUNTER::INDICATOR_COLOURS[i]
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_indicator_colour(instant = false)
    return if @indicator_colour == nil
    if instant
      a1 = @indicator_colour[0]
      a2 = @indicator_colour[1]
      a3 = @indicator_colour[2]
    else
      #---
      s = 4
      if @indicator_main_sprite.color.red > @indicator_colour[0]
        a1 = [@indicator_main_sprite.color.red-s, @indicator_colour[0]].max
      else
        a1 = [@indicator_main_sprite.color.red+s, @indicator_colour[0]].min
      end
      #---
      if @indicator_main_sprite.color.green > @indicator_colour[1]
        a2 = [@indicator_main_sprite.color.green-s, @indicator_colour[1]].max
      else
        a2 = [@indicator_main_sprite.color.green+s, @indicator_colour[1]].min
      end
      #---
      if @indicator_main_sprite.color.blue > @indicator_colour[2]
        a3 = [@indicator_main_sprite.color.blue-s, @indicator_colour[2]].max
      else
        a3 = [@indicator_main_sprite.color.blue+s, @indicator_colour[2]].min
      end
      #---
    end
    @indicator_main_sprite.color.set(a1, a2, a3, 128)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def adjust_indicator_opacity(sprite)
    return if sprite == nil
    if $game_map.encounter_step <= 0
      opacity_rate = -8
    elsif $game_map.encounter_list == [] or $game_message.visible
      opacity_rate = -255
    else
      opacity_rate = 8
    end
    sprite.opacity += opacity_rate
  end
  
end # 詳見頁首繁中說明

#===============================================================================
#===============================================================================

class Game_Player < Game_Character
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias encounter_count_cer encounter_count unless $@
  def encounter_count_calc
    n = encounter_count_cer
    n += $game_variables[YEM::ENCOUNTER::REPEL_STEPS_VARIABLE]
    if $game_variables[YEM::ENCOUNTER::LURE_STEPS_VARIABLE] > 0
      n -= [$game_variables[YEM::ENCOUNTER::LURE_RATE_VARIABLE], 1].max
    end
    return n
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def make_encounter_count
    return if $game_map.map_id <= 0
    n = $game_map.encounter_step
    sum = 0
    YEM::ENCOUNTER::ENCOUNTER_ROLLS.times do sum += rand(n) end
    @encounter_count = sum/YEM::ENCOUNTER::ENCOUNTER_ROLLS
    @encounter_count += YEM::ENCOUNTER::MINIMUM_FREE_STEPS
    @encounter_count = [@encounter_count, 1].max
  end

  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_encounter
    if $game_variables[YEM::ENCOUNTER::REPEL_STEPS_VARIABLE] > 0
      $game_variables[YEM::ENCOUNTER::REPEL_STEPS_VARIABLE] -= 1
      return unless $game_variables[YEM::ENCOUNTER::REPEL_STEPS_VARIABLE] <= 0
      $game_temp.common_event_id = YEM::ENCOUNTER::REPEL_COMMON_EVENT
      return
    end
    #---
    return if $TEST and Input.press?(Input::CTRL)
    return if in_vehicle?
    #---
    if $game_map.bush?(@x, @y)
      @encounter_count -= YEM::ENCOUNTER::BUSH_REDUCTION
    else
      @encounter_count -= YEM::ENCOUNTER::NORM_REDUCTION
    end
    #---
    if $game_variables[YEM::ENCOUNTER::LURE_STEPS_VARIABLE] > 0
      $game_variables[YEM::ENCOUNTER::LURE_STEPS_VARIABLE] -= 1
      rate = [$game_variables[YEM::ENCOUNTER::LURE_RATE_VARIABLE], 1].max
      @encounter_count -= rate
      if $game_variables[YEM::ENCOUNTER::LURE_STEPS_VARIABLE] <= 0
        $game_temp.common_event_id = YEM::ENCOUNTER::LURE_COMMON_EVENT
      end
    end
    #---
    $game_variables[YEM::ENCOUNTER::STEPS_REMAINING_VARIABLE] = @encounter_count
  end
  
end # 詳見頁首繁中說明

#===============================================================================
# 
# 
#===============================================================================