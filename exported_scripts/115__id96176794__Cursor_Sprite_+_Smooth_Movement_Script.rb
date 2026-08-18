#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Cursor Sprite + Smooth Movement Script
# 【用途】保留的 Runtime 元件「Cursor Sprite + Smooth Movement Script」。
# 【主要機制】主要定義／擴充 Sprite_WindowCursor、Window_Selectable、STRRGSS2；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Sprite_WindowCursor、Window_Selectable、STRRGSS2
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：WCURSOR_FN、WCURSOR_X、WCURSOR_Y、WAIT。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 3 個 alias／方法包裝，載入順序具有語意。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【英文說明中文化】本頁頂部已用繁體中文整理／翻譯原說明中與維護直接相關的用途、機制、設定、順序、呼叫與範例；下方原文保留作作者授權、完整細節與歷史查核依據。
# 【來源／授權】strcat。原作者 Credits／License／網址等原文仍保留在下方。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 範例只記錄原文件、既有事件或程式碼能證實的入口；沒有入口就明寫自動執行。
# 3. 原作者署名、授權與原始說明保留在下方；中文化不代表取得原作權。
# 4. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
#==============================================================================
#==============================================================================
# Cursor Sprite + Smooth Movement Script
#==============================================================================
# Author  : strcat
# Version : 1.2
# Date    : 29 / 01 / 2008 
#------------------------------------------------------------------------------ 
# This script will create a new cursor sprite,and add a smooth movement to 
# the cursor,thus making your game look better 
#------------------------------------------------------------------------------
#==============================================================================
# ** STRRGSS2
#==============================================================================
module STRRGSS2
  # Cursor graphic file name
  WCURSOR_FN = "Window_cursor"
  # position of the cursor(x, y)
  WCURSOR_X = 0
  WCURSOR_Y = 0
end
class Sprite_WindowCursor < Sprite
  WAIT = 22    # numbers of frame for cursor update delay.
  CW   = 24   # cursor width
  CH   = 24   # cursor height
end
#==============================================================================
# ** Window_Selectable
#==============================================================================
class Window_Selectable < Window_Base
  #--------------------------------------------------------------------------
  #  * Update Cursor
  #--------------------------------------------------------------------------
  def update_se_cursor
    cr = self.cursor_rect
    r = Rect.new(0, 0, 0, 0)
    y = (self.cursor_rect.height - 24) / 2
    v = nil
    v = self.viewport if self.viewport != nil
    @strcursor.viewport = v
    @strcursor.x = self.x + 16 + cr.x - 24 + STRRGSS2::WCURSOR_X
    @strcursor.y = self.y + 16 + cr.y + y  + STRRGSS2::WCURSOR_Y 
    @strcursor.z = self.z + 16
    @strcursor.opacity += 64
    @strcursor.opacity = self.opacity if @strcursor.opacity > self.opacity 
    @strcursor.visible = ((cr != r) and self.openness == 255)
    @strcursor.visible = false unless self.visible
    @strcursor.blink = (not self.active)
    @strcursor.update
  end
  def update_cursor_str(r,rect)
    self.cursor_rect = r
    rect = Rect.new(0, 0, 0, 0) if @index < 0
    mx = self.cursor_rect.x - rect.x
    if mx >= -1 and mx <= 1
      self.cursor_rect.x = rect.x
    elsif mx != 0
      x = self.cursor_rect.x - (mx/2.0)
      self.cursor_rect.x = x
    end
    my = self.cursor_rect.y - rect.y
    if my >= -1 and my <= 1
      self.cursor_rect.y = rect.y
    elsif my != 0
      y = self.cursor_rect.y - (my/2.0)
      self.cursor_rect.y = y
    end
    self.cursor_rect.width = rect.width
    self.cursor_rect.height = rect.height
  end
  def visible=(v)
    super
    @strcursor.visible = v
  end
  def active=(v)
    super
    @strcursor.visible = false
  end
  def dispose
    @strcursor.dispose
    super
  end
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias initialize_str05m initialize
  def initialize(x, y, width, height, spacing = 32)
    initialize_str05m(x, y, width, height, spacing)
    file = STRRGSS2::WCURSOR_FN
    v = nil
    v = self.viewport if self.viewport != nil
    @strcursor = Sprite_WindowCursor.new(file, v)
    @f_set = false
  end
  alias update_str05m update
  def update
    update_se_cursor unless @opening
    update_str05m
  end
  alias update_cursor_str05m update_cursor
  def update_cursor
    r = self.cursor_rect.clone unless @f_set
    update_cursor_str05m
    update_cursor_str(r, self.cursor_rect.clone) unless @f_set
    @f_set = false
  end
  #--------------------------------------------------------------------------
  # * Get Index
  #--------------------------------------------------------------------------
  def index=(index)
    @f_set = true
    @index = index
    update_cursor
    call_update_help
  end
end
#==============================================================================
# ** Sprite_WindowCursor
#==============================================================================
class Sprite_WindowCursor < Sprite
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :blink
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(name,viewport)
    super(viewport)
    self.bitmap = Cache.system(name)
    self.src_rect.set(0, 0, CW, CH)
    self.opacity = 0
    @xx = -8
    @wait = WAIT
    @count = 0
    @blink = false
  end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    super
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    @xx += 1 if @xx != 0
    self.x += @xx
    @count += 1
    self.visible = false if @blink and (@count % 4) == 0
    @wait -= 1
    return if @wait > 0
    @wait = WAIT
    self.src_rect.x += CW
    self.src_rect.x = 0 if (self.bitmap.width <= self.src_rect.x)
  end
end