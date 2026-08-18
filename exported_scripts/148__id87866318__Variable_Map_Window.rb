#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Variable Map Window
# 【用途】UI／選單元件「Variable Map Window」。
# 【主要機制】擴充 Window／Scene／Sprite 顯示或操作；最終外觀可能由後載入 FS UI Patch 接管。
# 【主要影響】Game_System、Game_Interpreter、Window_Variable、Scene_Map
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】含 4 個 alias／方法包裝，載入順序具有語意；登記 $imported：VariableMapWindow。
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
#===============================================================================
# 
# Shanghai Simple Script - Variable Map Window
# Last Date Updated: 2010.05.17
# Level: Normal
# 
# This script allows for multiple variables and automatically updates itself
# when the variables themselves change.
#===============================================================================
# Instructions
# -----------------------------------------------------------------------------
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials but above ▼ Main. Remember to save.
# 
# To use this variable window, use these event calls. Works on map only.
# 
# variable_window_clear
# - Clears all of the variable window and closes it.
# 
# variable_window_open
# - Opens the variable window, but only if it has variables.
# 
# variable_window_close
# - Closes the variable window.
# 
# variable_window_add(variable_id)
# - Adds the variable_id to the variable window.
# 
# variable_window_remove(variable_id)
# - Removes the variable_id from the variable window.
# 
# variable_window_upper_left
# variable_window_upper_right
# variable_window_lower_left
# variable_window_lower_right
# - Moves the variable window to that location.
# 
# variable_window_width(x)
# - Changes the variable window's width to x.
#===============================================================================
 
$imported = {} if $imported == nil
$imported["VariableMapWindow"] = true
 
#==============================================================================
# ** Game_System
#==============================================================================
 
class Game_System
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :shown_variables
  attr_accessor :variable_window_open
  attr_accessor :variable_corner
  attr_accessor :variable_width
end
 
#==============================================================================
# ** Game_Interpreter
#==============================================================================
 
class Game_Interpreter
  #--------------------------------------------------------------------------
  # * Variable Window Clear
  #--------------------------------------------------------------------------
  def variable_window_clear
    return unless $scene.is_a?(Scene_Map)
    $scene.variable_window.data = []
    $scene.variable_window.refresh
    $scene.variable_window.close
  end
  #--------------------------------------------------------------------------
  # * Variable Window Open
  #--------------------------------------------------------------------------
  def variable_window_open
    return unless $scene.is_a?(Scene_Map)
    $scene.variable_window.open if $scene.variable_window.data != []
    $game_system.variable_window_open = true
  end
  #--------------------------------------------------------------------------
  # * Variable Window Close
  #--------------------------------------------------------------------------
  def variable_window_close
    return unless $scene.is_a?(Scene_Map)
    $scene.variable_window.close
    $game_system.variable_window_open = false
  end
  #--------------------------------------------------------------------------
  # * Variable Window Add
  #--------------------------------------------------------------------------
  def variable_window_add(variable_id)
    return unless $scene.is_a?(Scene_Map)
    return unless variable_id.is_a?(Integer)
    return if $game_variables[variable_id].nil?
    return if $game_system.shown_variables.include?(variable_id)
    $game_system.shown_variables.push(variable_id)
    $scene.variable_window.refresh
  end
  #--------------------------------------------------------------------------
  # * Variable Window Remove
  #--------------------------------------------------------------------------
  def variable_window_remove(variable_id)
    return unless $scene.is_a?(Scene_Map)
    return unless $game_system.shown_variables.include?(variable_id)
    $game_system.shown_variables.delete(variable_id)
    $scene.variable_window.refresh
  end
  #--------------------------------------------------------------------------
  # * Variable Window Upper Left
  #--------------------------------------------------------------------------
  def variable_window_upper_left
    return unless $scene.is_a?(Scene_Map)
    $game_system.variable_corner = 0
  end
  #--------------------------------------------------------------------------
  # * Variable Window Upper Right
  #--------------------------------------------------------------------------
  def variable_window_upper_right
    return unless $scene.is_a?(Scene_Map)
    $game_system.variable_corner = 1
  end
  #--------------------------------------------------------------------------
  # * Variable Window Lower Left
  #--------------------------------------------------------------------------
  def variable_window_lower_left
    return unless $scene.is_a?(Scene_Map)
    $game_system.variable_corner = 2
  end
  #--------------------------------------------------------------------------
  # * Variable Window Lower Right
  #--------------------------------------------------------------------------
  def variable_window_lower_right
    return unless $scene.is_a?(Scene_Map)
    $game_system.variable_corner = 3
  end
  #--------------------------------------------------------------------------
  # * Variable Window Width
  #--------------------------------------------------------------------------
  def variable_window_width(value)
    return unless $scene.is_a?(Scene_Map)
    $game_system.variable_width = [160, value].max
    $scene.variable_window.refresh
  end
end
 
#==============================================================================
# ** Window_Variable
#==============================================================================
 
class Window_Variable < Window_Selectable
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :data
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    $game_system.shown_variables = [] if $game_system.shown_variables.nil?
    super(0, 0, 160, 56)
    self.openness = 0 if $game_system.shown_variables.empty?
    self.openness = 0 unless $game_system.variable_window_open
    #self.z = 999
    refresh
    update_corner
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    $game_system.variable_width = 160 if $game_system.variable_width.nil?
    self.width = $game_system.variable_width
    @data = $game_system.shown_variables
    @value = [] if @value.nil?
    for variable in @data
      next if $game_variables[variable].nil?
      @value[variable] = $game_variables[variable]
    end
    @item_max = @data.size
    self.height = [@item_max, 1].max * 24 + 32
    create_contents
    for i in 0...@item_max
      draw_item(i)
    end
    update_corner
  end
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def update
    super
    refresh if @data != $game_system.shown_variables
    for variable in @data.compact
      next if variable == nil
      next if $game_variables[variable].nil?
      next if @value[variable] == $game_variables[variable]
      draw_item(@data.index(variable))
    end
    update_corner
  end
  #--------------------------------------------------------------------------
  # * Update Corner
  #--------------------------------------------------------------------------
  def update_corner
    $game_system.variable_corner = 0 if $game_system.variable_corner.nil?
    case $game_system.variable_corner
    when 0
      self.x = 0
      self.y = 0
    when 1
      self.x = Graphics.width - self.width
      self.y = 0
    when 2
      self.x = 0
      self.y = Graphics.height - self.height
    when 3
      self.x = Graphics.width - self.width
      self.y = Graphics.height - self.height
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #--------------------------------------------------------------------------
  def draw_item(index)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    current_id = @data[index]
    return if $game_variables[current_id].nil?
    name = sprintf("%s:", $data_system.variables[current_id])
    amount = $game_variables[current_id]
    self.contents.font.color = system_color
    self.contents.draw_text(rect, name, 0)
    self.contents.font.color = normal_color
    self.contents.draw_text(rect, amount, 2)
  end
end
 
#==============================================================================
# ** Scene_Map
#==============================================================================
 
class Scene_Map < Scene_Base
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :variable_window
  #--------------------------------------------------------------------------
  # * Start processing
  #--------------------------------------------------------------------------
  alias start_sss_variable_map_window start unless $@
  def start
    start_sss_variable_map_window
    @variable_window = Window_Variable.new
  end
  #--------------------------------------------------------------------------
  # * Termination Processing
  #--------------------------------------------------------------------------
  alias terminate_sss_variable_map_window terminate unless $@
  def terminate
    @variable_window.dispose unless @variable_window.nil?
    @variable_window = nil
    terminate_sss_variable_map_window
  end
  #--------------------------------------------------------------------------
  # * Basic Update Processing
  #--------------------------------------------------------------------------
  alias update_basic_sss_variable_map_window update_basic unless $@
  def update_basic
    update_basic_sss_variable_map_window
    @variable_window.update unless @variable_window.nil?
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  alias update_sss_variable_map_window update unless $@
  def update
    update_sss_variable_map_window
    @variable_window.update unless @variable_window.nil?
  end
end
 
#===============================================================================
# 
# END OF FILE
# 
#===============================================================================