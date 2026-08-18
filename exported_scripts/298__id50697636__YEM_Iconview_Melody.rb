#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：YEM Iconview Melody
# 【用途】保留的 Runtime 元件「YEM Iconview Melody」。
# 【主要機制】主要定義／擴充 Window_Command、Window_Iconview、Window_IconPageList、Window_Icondata；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Window_Command、Window_Iconview、Window_IconPageList、Window_Icondata、Scene_Title、Scene_Iconview、YEM
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：COMMAND_NAME。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 2 個 alias／方法包裝，載入順序具有語意；登記 $imported：IconviewMelody。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁直接引用：IconSet。刪除／改名素材前必須反查其他腳本與 Data／事件是否共用。
# 【英文說明中文化】本頁頂部已用繁體中文整理／翻譯原說明中與維護直接相關的用途、機制、設定、順序、呼叫與範例；下方原文保留作作者授權、完整細節與歷史查核依據。
# 【來源／授權】loading up the icons on a static sheet and figuring out what those icons。原作者 Credits／License／網址等原文仍保留在下方。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 範例只記錄原文件、既有事件或程式碼能證實的入口；沒有入口就明寫自動執行。
# 3. 原作者署名、授權與原始說明保留在下方；中文化不代表取得原作權。
# 4. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
#==============================================================================
#===============================================================================
# 
# Yanfly Engine Melody - Iconview Melody
# Last Date Updated: 2010.05.24
# Level: Easy
# 
# Don't know how to use Photoshop's X and Y coordinates to count your icons or
# just too lazy to do it? Well, you can use this tool to make your life easier
# by loading up the icons on a static sheet and figuring out what those icons
# are indexed as. This script will mark 256 icons per page and allows you to
# scroll through those pages as lagless as possible. The icons are displayed
# in columns of 16 icons each, following exactly the way your IconSet is made
# (or should be made).
# 
#===============================================================================
# Updates
# -----------------------------------------------------------------------------
# o 2010.05.24 - Started Script and Finished.
#===============================================================================
# Instructions
# -----------------------------------------------------------------------------
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials but above ▼ Main. Remember to save.
# 
# Iconview only appears in testplay mode. If for some reason your game does not
# use the command window in the title screen, there is an alternative way of
# entering the Iconview scene by pressing F9 at the title screen.
#===============================================================================

$imported = {} if $imported == nil
$imported["IconviewMelody"] = true

module YEM
  module ICONVIEW
    
    # If for some reason you wish to change the name of the command that
    # appears on the title screen, edit this constant.
    COMMAND_NAME = "IconView"
    
  end # ICONVIEW
end # YEM

#===============================================================================
# Editting anything past this point may potentially result in causing computer
# damage, incontinence, explosion of user's head, coma, death, and/or halitosis.
# Therefore, edit at your own risk.
#===============================================================================

#===============================================================================
# Window_Command
#===============================================================================

class Window_Command < Window_Selectable
  
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :commands
  attr_accessor :item_max
  
end # Window_Command

#===============================================================================
# Window_Iconview
#===============================================================================

class Window_Iconview < Window_Selectable
  
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :max_pages
  attr_accessor :page
  attr_accessor :image
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize
    super(Graphics.width - 416, 0, 416, 416)
    self.z += 1
    @item_max = 256
    @column_max = 16
    @page = @index = @spacing = 0
    @image = Cache.system("IconSet")
    @max_pages = (@image.height / 384.0).ceil
    @icon_sprite = Sprite.new
    @icon_sprite.bitmap = Bitmap.new(384, 384)
    @icon_sprite.x = self.x + 16
    @icon_sprite.y = self.y + 16
    @icon_sprite.z = self.z - 1
    self.opacity = self.back_opacity = 0
    refresh
  end
  
  #--------------------------------------------------------------------------
  # dispose
  #--------------------------------------------------------------------------
  def dispose
    @icon_sprite.bitmap.dispose
    @icon_sprite.dispose
    super
  end
  
  #--------------------------------------------------------------------------
  # update
  #--------------------------------------------------------------------------
  def update
    super
    return unless @max_pages > 1
    if Input.repeat?(Input::L)
      Sound.play_cursor
      image_page_up
    elsif Input.repeat?(Input::R)
      Sound.play_cursor
      image_page_down
    end
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    @icon_sprite.bitmap.dispose
    @icon_sprite.bitmap = Bitmap.new(384, 384)
    rect = Rect.new(0, @page * 384, 384, 384)
    @icon_sprite.bitmap.blt(0, 0, @image, rect)
  end
  
  #--------------------------------------------------------------------------
  # cursor_down
  #--------------------------------------------------------------------------
  def cursor_down(wrap)
    if @index < 240
      @index += 16
    elsif wrap
      @index -= 240
    end
  end
  
  #--------------------------------------------------------------------------
  # cursor_up
  #--------------------------------------------------------------------------
  def cursor_up(wrap)
    if @index >= 16
      @index -= 16
    elsif wrap
      @index += 240
    end
  end
  
  #--------------------------------------------------------------------------
  # cursor_right
  #--------------------------------------------------------------------------
  def cursor_right(wrap)
    if @index % 16 < 15
      @index += 1
    elsif wrap
      @index -= 15
    end
  end
  
  #--------------------------------------------------------------------------
  # cursor_left
  #--------------------------------------------------------------------------
  def cursor_left(wrap)
    if @index % 16 > 0
      @index -= 1
    elsif wrap
      @index += 15
    end
  end
  
  #--------------------------------------------------------------------------
  # image_page_up
  #--------------------------------------------------------------------------
  def image_page_up
    @page = @page == 0 ? @max_pages - 1 : @page - 1
    refresh
  end
  
  #--------------------------------------------------------------------------
  # image_page_down
  #--------------------------------------------------------------------------
  def image_page_down
    @page = @page == @max_pages - 1 ? 0 : @page + 1
    refresh
  end
  
end # Window_Iconview

#===============================================================================
# Window_IconPageList
#===============================================================================

class Window_IconPageList < Window_Selectable
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(icon_window)
    @icon_window = icon_window
    super(0, 128, Graphics.width-@icon_window.width, @icon_window.height-128)
    self.active = false
    self.index = 0
    refresh
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    @item_max = @icon_window.max_pages
    create_contents
    for i in 0...@item_max; draw_item(i); end
  end
  
  #--------------------------------------------------------------------------
  # draw_item
  #--------------------------------------------------------------------------
  def draw_item(index)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    text = sprintf("Page%d", index+1)
    self.contents.draw_text(rect, text, 1)
  end
  
  #--------------------------------------------------------------------------
  # update
  #--------------------------------------------------------------------------
  def update
    super
    if self.index != @icon_window.page
      self.index = @icon_window.page
    end
  end
  
end # Window_IconPageList

#===============================================================================
# Window_Icondata
#===============================================================================

class Window_Icondata < Window_Base
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(iconview_window)
    @iconview_window = iconview_window
    super(0, 0, Graphics.width - @iconview_window.width, 128)
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    text = 256 * @iconview_window.page + @iconview_window.index
    text = sprintf("ID:%d", text)
    self.contents.draw_text(0, WLH*0, contents.width, WLH, text, 1)
    text = @iconview_window.image.height / 24 * 16
    text = sprintf("Total:%d", text)
    self.contents.draw_text(0, WLH*1, contents.width, WLH, text, 1)
    text = "L:PageUp"
    self.contents.draw_text(0, WLH*2, contents.width, WLH, text, 1)
    text = "R:PageDn"
    self.contents.draw_text(0, WLH*3, contents.width, WLH, text, 1)
  end
  
  #--------------------------------------------------------------------------
  # update
  #--------------------------------------------------------------------------
  def update
    super
    if @last_index != @iconview_window.index or 
    @last_page != @iconview_window.page
      @last_index = @iconview_window.index
      @last_page = @iconview_window.page
      refresh
    end
  end
  
end # Window_Icondata

#===============================================================================
# Scene_Title
#===============================================================================

class Scene_Title < Scene_Base

  #--------------------------------------------------------------------------
  # alias method: create_command_window
  #--------------------------------------------------------------------------
  alias create_command_window_iconview create_command_window unless $@
  def create_command_window
    create_command_window_iconview
    return unless $TEST
    return if @command_window == nil
    @command_window.commands.push(YEM::ICONVIEW::COMMAND_NAME)
    @command_window.item_max += 1
    @command_window.create_contents
    @command_window.height += 24
    @command_window.y -= 24
    @command_window.refresh
    x = @command_window.commands.index(Vocab.continue)
    @command_window.draw_item(x, false) unless @continue_enabled
  end
  
  #--------------------------------------------------------------------------
  # alias method: update
  #--------------------------------------------------------------------------
  alias update_iconview update unless $@
  def update
    text = YEM::ICONVIEW::COMMAND_NAME
    if (Input.trigger?(Input::C) and @command_window != nil and
    @command_window.commands[@command_window.index] == text) or 
    Input.press?(Input::F9)
      command_iconview
    else
      update_iconview
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: command_iconview
  #--------------------------------------------------------------------------
  def command_iconview
    return unless $TEST
    Sound.play_decision
    $scene = Scene_Iconview.new
  end
  
end # Scene_Title

#===============================================================================
# Scene_Iconview
#===============================================================================

class Scene_Iconview < Scene_Base
  
  #--------------------------------------------------------------------------
  # start
  #--------------------------------------------------------------------------
  def start
    super
    create_menu_background
    @iconview_window = Window_Iconview.new
    dx = @iconview_window.x
    dy = @iconview_window.y
    dw = @iconview_window.width
    dh = @iconview_window.height
    @dummy_window = Window_Base.new(dx, dy, dw, dh)
    @data_window = Window_Icondata.new(@iconview_window)
    @page_window = Window_IconPageList.new(@iconview_window)
  end
  
  #--------------------------------------------------------------------------
  # terminate
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_menu_background
    @iconview_window.dispose
    @dummy_window.dispose
    @data_window.dispose
    @page_window.dispose
  end
  
  #--------------------------------------------------------------------------
  # update
  #--------------------------------------------------------------------------
  def update
    super
    update_menu_background
    @iconview_window.update
    @data_window.update
    @page_window.update
    if Input.trigger?(Input::B)
      Sound.play_cancel
      $scene = Scene_Title.new
    end
  end
  
end # Scene_Iconview

#===============================================================================
# 
# END OF FILE
# 
#===============================================================================