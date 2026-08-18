#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Scrolling Window_Help
# 【用途】UI／選單元件「Scrolling Window_Help」。
# 【主要機制】擴充 Window／Scene／Sprite 顯示或操作；最終外觀可能由後載入 FS UI Patch 接管。
# 【主要影響】Window_Helpxxx、COZZIEKUNS、SCROLLING_WINDOW_HELP
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：SCROLL_SPEED、SCROLL_REFRESH_RATE、SCROLL_INITIAL_WAIT。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 1 個 alias／方法包裝，載入順序具有語意。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【英文說明中文化】本頁頂部已用繁體中文整理／翻譯原說明中與維護直接相關的用途、機制、設定、順序、呼叫與範例；下方原文保留作作者授權、完整細節與歷史查核依據。
# 【來源／授權】Cozziekuns (rmrk)。原作者 Credits／License／網址等原文仍保留在下方。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 範例只記錄原文件、既有事件或程式碼能證實的入口；沒有入口就明寫自動執行。
# 3. 原作者署名、授權與原始說明保留在下方；中文化不代表取得原作權。
# 4. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
#==============================================================================
#===============================================================================
# Scrolling Window_Help
#-------------------------------------------------------------------------------
# Version: 1.1a
# Author: Cozziekuns (rmrk)
# Last Date Updated: 12/6/2011
#===============================================================================
# Description:
#-------------------------------------------------------------------------------
# This script allows you to auto scroll the text in Window_Help if it becomes
# too long for the window to hold. Originally, RPG Maker would auto resize the
# text to make it thin and aesthetically displeasing to the eye.
#===============================================================================
# Updates
# ------------------------------------------------------------------------------
# o 12/06/2011 - Started Script
# o 09/07/2011 - Updated script with a bugfix.
#===============================================================================
# Instructions
# ------------------------------------------------------------------------------
# Copy and paste this script above Main Process but below Materials, and
# edit the modules to your liking.
#===============================================================================

module COZZIEKUNS
  module SCROLLING_WINDOW_HELP
    SCROLL_SPEED = 1
    SCROLL_REFRESH_RATE = 1
    SCROLL_INITIAL_WAIT = 60
  end
end

class Window_Helpxxx < Window_Base

  alias coz_scrolltxt_wh_14199_initialize initialize
  def initialize(*args)
    coz_scrolltxt_wh_14199_initialize
    @scroll = false
    @frames = 0
  end

  def set_text(text, align = 0)
    if text != @text or align != @align
      text_width =
        contents.text_size(text).width + 40 >
        self.contents.width - 40
      text_width = false if align != 0

      if text_width
        old_contents = self.contents
        self.contents = Bitmap.new(
          self.width + old_contents.text_size(text).width + 8,
          self.height - 32)
        old_contents.dispose if old_contents != nil &&
                                !old_contents.disposed?
        @scroll = true
      else
        old_contents = self.contents
        self.contents = Bitmap.new(
          self.width - 32,
          self.height - 32)
        old_contents.dispose if old_contents != nil &&
                                !old_contents.disposed?
        @scroll = false
      end

      self.ox = 0
      self.contents.clear
      self.contents.font.color = normal_color

      draw_width = if text_width
                     self.contents.text_size(text).width
                   else
                     self.width - 40
                   end

      self.contents.draw_text(
        4, 0, draw_width, WLH, text, align)

      @text = text
      @align = align
      @frames = 0
    end
  end

  def update
    @frames += 1
    refresh =
      COZZIEKUNS::SCROLLING_WINDOW_HELP::SCROLL_REFRESH_RATE
    wait =
      COZZIEKUNS::SCROLLING_WINDOW_HELP::SCROLL_INITIAL_WAIT
    speed =
      COZZIEKUNS::SCROLLING_WINDOW_HELP::SCROLL_SPEED

    if @scroll == true
      if Graphics.frame_count % refresh == 0 &&
         @frames >= wait
        self.ox += speed
      end

      if self.ox >= self.contents.text_size(@text).width
        self.ox =
          -self.contents.text_size(@text).width / 2
      end
    end
  end
end
