#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Slanted Gauges
# 【用途】保留的 Runtime 元件「Slanted Gauges」。
# 【主要機制】主要定義／擴充 Window_Base、SLANT_BARS；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Window_Base、SLANT_BARS
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：USE_WINDOWSKIN、DEFAULT_HP_BAR_COLOR、DEFAULT_HP_END_COLOR、DEFAULT_MP_BAR_COLOR、DEFAULT_MP_END_COLOR。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】保持目前已驗證的相對順序；搬動前先反查 class reopen／alias／事件入口。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【英文說明中文化】本頁頂部已用繁體中文整理／翻譯原說明中與維護直接相關的用途、機制、設定、順序、呼叫與範例；下方原文保留作作者授權、完整細節與歷史查核依據。
# 【來源／授權】Kylock (Based on SephirothSpawn's Original Slanted Bars)。原作者 Credits／License／網址等原文仍保留在下方。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 範例只記錄原文件、既有事件或程式碼能證實的入口；沒有入口就明寫自動執行。
# 3. 原作者署名、授權與原始說明保留在下方；中文化不代表取得原作權。
# 4. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
#==============================================================================
#==============================================================================
# ■ SephirothSpawn's Slanted bars in VX
#     25.4.2008
#------------------------------------------------------------------------------
#  Script by: Kylock (Based on SephirothSpawn's Original Slanted Bars)
#==============================================================================
#    Inspired by Syvkal (http://rmvxpuniverse.com) who ported Cogwheel Style
#  bars to VX, I realized how much I missed Seph's Slanted Bars.  So here they
#  are.  Just add this script and it'll automagically transform your HP and MP
#  bars.  Bar colors are easily customized in the following module.
#==============================================================================
#  Change Log
#  1.0 - Original Release.
#  1.1 - Added option to use default window skin colors.
#==============================================================================

module SLANT_BARS
  USE_WINDOWSKIN = false  # If set to true, the colors will be taken from the
                          #  current system skin and the following settings
                          #  will be ignored.
  
  DEFAULT_HP_BAR_COLOR = Color.new(180,55,0,255)   # Beginning color of HP bar
  DEFAULT_HP_END_COLOR = Color.new(255,160,100,255) # Ending color of HP bar
  
  DEFAULT_MP_BAR_COLOR = Color.new(50,60,170,255)   # Begenning color of MP bar
  DEFAULT_MP_END_COLOR = Color.new(50,180,220,255) # Ending color of MP bar
end

class Window_Base < Window
  #==========================================================================
  # * Draw Slant Bar(by SephirothSpawn)
  #==========================================================================
  def draw_slant_bar(x, y, min, max, width = 152, height = 6,
    bar_color = Color.new(150, 0, 0, 255),
    end_color = Color.new(255, 255, 60, 255))
    # Draw Border
    for i in 0..height#for i in 0..height
      self.contents.fill_rect(x + i, y + height - i, width + 1, 1,#x + i, y + height - i
        Color.new(50, 50, 50, 125))
    end
    # Draw Background
    for i in 1..(height - 1)#for i in 1..(height - 1)
      r = 100 * (height - i) / height + 0 * i / height
      g = 100 * (height - i) / height + 0 * i / height
      b = 100 * (height - i) / height + 0 * i / height
      a = 255 * (height - i) / height + 255 * i / height
      self.contents.fill_rect(x + i, y + height - i, width, 1,
        Color.new(r, b, g, a))
    end
    # Draws Bar
    for i in 1..( (min / max.to_f) * width - 1)
      for j in 1..(height - 1)#for j in 1..(height - 1)
        r = bar_color.red * (width - i) / width + end_color.red * i / width
        g = bar_color.green * (width - i) / width + end_color.green * i / width
        b = bar_color.blue * (width - i) / width + end_color.blue * i / width
        a = bar_color.alpha * (width - i) / width + end_color.alpha * i / width
        self.contents.fill_rect(x + i + j, y + height - j, 1, 1,
          Color.new(r, g, b, a))
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Draw HP gauge
  #     actor : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #     width : Width
  #--------------------------------------------------------------------------
  def draw_actor_hp_gauge(actor, x, y, width = 131)#width = 131
    if SLANT_BARS::USE_WINDOWSKIN
      draw_slant_bar(x-3,y+13,actor.hp,actor.maxhp,width,8,#x-3,y+13
        hp_gauge_color1,hp_gauge_color2)
    else
      draw_slant_bar(x-3,y+13,actor.hp,actor.maxhp,width,8,
        SLANT_BARS::DEFAULT_HP_BAR_COLOR,SLANT_BARS::DEFAULT_HP_END_COLOR)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw MP Gauge
  #     actor : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #     width : Width
  #--------------------------------------------------------------------------
  def draw_actor_mp_gauge(actor, x, y, width = 131)
    if SLANT_BARS::USE_WINDOWSKIN
      draw_slant_bar(x-3,y+13,actor.mp,actor.maxmp,width,8,
        mp_gauge_color1,mp_gauge_color2)
    else
      draw_slant_bar(x-3,y+13,actor.mp,actor.maxmp,width,8,
        mp_gauge_color1(actor),mp_gauge_color2(actor))
    end
  end
end