#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：戰鬥訊息
# 【用途】戰鬥系統元件「戰鬥訊息」。
# 【主要機制】負責戰鬥流程、數值、AI、演出或相容的一部分；可能透過 alias 疊加既有方法。
# 【主要影響】Window_BattleMessage
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：TEXT_B_COLOR、INFO、BTWIDTH、MOVE、SPEED、W_OPACITY、BTHEIGHT、N_WINDOW。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 3 個 alias／方法包裝，載入順序具有語意。
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
###############################################################################
## Modified by Reedo on December 13, 2009 to add background image option
###############################################################################
class Window_BattleMessage < Window_Message
  # Changing the back color (from left to right in a gradient)
  TEXT_B_COLOR = [Color.new(0,0,0,160), Color.new(0,0,0,0)]
  INFO      = "" # Text in the window 
  BTWIDTH   = 400       # Width.  Old height was 350.
  MOVE      = true      # Redimensionate the lines?
  SPEED     = 40        # Redimension Speed
  W_OPACITY = 20        # Trasparency 1~255
  BTHEIGHT  = 96       # Height of the window.  Old height was 96.
  # 
  N_WINDOW  = false     # The window will be not trasparent?
  GRAPHIC_NAME = "Battle_Message"    # The window will use a background graphic if a picture
                        # name is specified instead of 'nil'.
  GRAPHIC_OPACITY = 255 # The opacity of the picture, if used.
  STRETCH_GRAPHIC = false # Set true to fit the graphic to the window; leave
                          # false to draw graphic at original size (with clipped)
  GRAPHIC_X = 0         # Specify the left of the graphic in the window
  GRAPHIC_Y = -10        # Specify the top of the grpahic in the window
                        # 16 was the default top of the gradient
  #--------------------------------------------------------------------------
  # ? ?????
  #--------------------------------------------------------------------------
  alias initialize_str11b initialize
  def initialize
    initialize_str11b
    self.x = 0
    self.y = 10
    #self.width = 350
    self.back_opacity = 0
    self.opacity = 0
    self.visible = true

    unless N_WINDOW 
      @b_sprite = Sprite.new(self.viewport)
      bitmap = Bitmap.new(BTWIDTH, BTHEIGHT + 16)
      if GRAPHIC_NAME != nil
        img = Cache.picture(GRAPHIC_NAME)
        dst = Rect.new(0, 16, BTWIDTH, BTHEIGHT)
        src = Rect.new(0, 0, img.width, img.height)
        if STRETCH_GRAPHIC
          bitmap.stretch_blt(dst, img, src, GRAPHIC_OPACITY)
        else
          bitmap.blt(GRAPHIC_X, GRAPHIC_Y, img, src, GRAPHIC_OPACITY)
        end
      else
        bitmap.gradient_fill_rect(0, 16, BTWIDTH, BTHEIGHT, TEXT_B_COLOR[0], TEXT_B_COLOR[1])
      end
      bitmap.font.shadow = false
      bitmap.font.size = 16
      bitmap.draw_text(2, 2, BTWIDTH, 16, INFO)
      @b_sprite.bitmap = bitmap
      @b_sprite.x = self.x
      @b_sprite.y = self.y
      @b_sprite.src_rect.height = 16
      @b_sprite.opacity = 0
      @str11f = false
    end
  end
  alias dispose_str11b dispose
  def dispose
    dispose_str11b
    unless N_WINDOW 
      @b_sprite.bitmap.dispose
      @b_sprite.dispose
    end
  end
  alias update_str11b update
  def update
    update_str11b
    
    unless N_WINDOW 
      if self.visible and (@lines.size > 0 and not @str11f) or
         (@text != nil or self.pause or @index > -1)
        @b_sprite.opacity += W_OPACITY
        h = @b_sprite.src_rect.height
        if @text != nil
          @l = 4
        else
          unless self.pause or @index > -1
            @l = @lines.size
          else
            @l = 4
          end
        end
        if MOVE
          if SPEED == 1
            @b_sprite.src_rect.height = 16 + (@l * 24)
          else
            s = (SPEED - 1)
            @b_sprite.src_rect.height = (h + ((16 + (@l * 24)) * s)) / SPEED
          end
        else
          @b_sprite.src_rect.height = BTHEIGHT + 16
        end
      else
        @b_sprite.opacity -= W_OPACITY
      end
      
      # **新增這一行來調整游標長度**
      self.cursor_rect.width = 200  # 減少寬度
      
    else
      if self.visible
        self.back_opacity += W_OPACITY
        self.opacity += W_OPACITY
        self.back_opacity = 200 if self.back_opacity > 200
      else
        self.back_opacity -= W_OPACITY
        self.opacity -= W_OPACITY
      end
    end
  end
end