#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Bitmap Addons｜Core + Extension Authority
# 【來源】modern algebra（rmrk.net），Bitmap Addons v1.5，2009-08-21。Phase 8 已將原 Bitmap Addons 與 Bitmap Addons-2 依原 94→95 順序收斂為本 Authority。
# 【用途】擴充 RGSS2 Bitmap 的幾何繪圖、灰階、透明度控制與圓角處理。FS 多個 Menu／HUD／Status／Battle UI 會直接呼叫 fill_rounded_rect，因此這不是可有可無的美術小工具。
# 【Ellipse】Ellipse.new(x, y, a, b=nil)：x/y 為左上位置；a/b 為橢圓半徑方向尺寸，b=nil 時以 a 建立圓。Ellipse#within?(x,y) 可判斷座標是否位於橢圓內。
# 【Bitmap API】outline_ellipse(ellipse, colour=font.color, width=1, steps=nil) 畫外框；fill_ellipse(ellipse, colour=font.color, steps=nil) 填滿橢圓；fill_rounded_rect(rect, colour=font.color, w=8) 畫圓角矩形；draw_line(x0,y0,x1,y1,colour=font.color) 畫直線；greyscale(rect) 將指定 Rect 灰階化。
# 【BLT 擴充】bitmap.ma_default_opacity=0..255 可設定 blt／stretch_blt 預設透明度；bitmap.ma_default_greyscale=true/false 可讓來源 Rect 先灰階再繪製，不必覆寫 draw_character 等既有方法。
# 【FS Extension】Bitmap#hypot(x,y) 提供 RGSS2 相容距離計算；Bitmap#draw_rounded_mask(rect) 使用固定 radius=8 把四角設為透明，最後會 dispose 暫存 mask Bitmap。
# 【演算法備註】橢圓繪製使用參數式與 Ramanujan 圓周近似；draw_line 使用 Bresenham 演算法。這些屬底層繪圖，不建議為 UI 外觀需求直接改核心數學流程。
# 【載入順序】必須在所有使用上述 Bitmap API 的 UI／Save／Battle 類腳本之前。Phase 17 掃描確認多個後續頁直接呼叫 fill_rounded_rect；不能搬到 Main 後方或退休。
# 【呼叫範例】rect=Rect.new(0,0,120,40); bitmap.fill_rounded_rect(rect, Color.new(0,0,0,128), 8)。ellipse=Ellipse.new(10,10,24,12); bitmap.fill_ellipse(ellipse)。
# 【相關素材】無固定 Graphics／Audio 素材；本頁只操作 Bitmap／Color／Rect。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、實際資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址等來源資訊保留；Phase 18 Archive 另保存翻譯前 byte-exact 原稿。
# 4. 本輪只整理註解／說明，不修改任何可執行 Ruby；載入順序仍以 FS LoadOrder／Authority 文件為準。
#==============================================================================
#==============================================================================
# PHASE 8 Authority：Bitmap Addons｜Core + Extension Authority
# Bitmap 共用擴充與第二段 extension；保持原 94→95 執行順序。
# 原始載入順序：94 Bitmap Addons → 95 Bitmap Addons-2
#==============================================================================
# PHASE8 原始頁：94｜Bitmap Addons
#==============================================================================
#==============================================================================
#  Version: 1.5
#  Author: modern algebra (rmrk.net)
#  Date: August 21, 2009
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# 說明：
#      outline_ellipse
#      fill_ellipse
#      fill_rounded_rect
#      draw_line
#      greyscale
#
#
#
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# 使用說明：
#
#     Ellipse.new (x, y, a, b)
#
#
#      outline_ellipse (ellipse[, colour, width, steps])
#
#      fill_ellipse (ellipse[, colour, steps])
#
#      fill_rounded_rect (ellipse[, colour, w)
#
#      draw_line
#
#      greyscale (rect)
#==============================================================================
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#==============================================================================

class Ellipse < Rect
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_reader   :h
  attr_reader   :k
  alias a width
  alias b height
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def initialize (x, y, a, b = nil)
    b = a if b.nil?
    super (x, y, a, b)
    @h = x + a
    @k = y + b
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def within? (x, y)
    x_square = ((x - @h)*(x - @h)).to_f / (a*a)
    y_square = ((y - @k)*(y - @k)).to_f / (b*b)
    return (x_square + y_square) <= 1
  end
end

#==============================================================================
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# 變更摘要：
#==============================================================================

class Bitmap
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_accessor :ma_default_opacity
  attr_accessor :ma_default_greyscale
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias mdnabr_dfltopac_init_bmpadon_2lh3 initialize unless $@
  def initialize (*args)
    # 初始化公開實例變數
    @ma_default_opacity = 255
    @ma_default_greyscale = false
    # 執行原方法
    mdnabr_dfltopac_init_bmpadon_2lh3 (*args)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias mnalgba_bitmapaddons_opacdflt_blt_2hb5 blt unless $@
  def blt (x, y, src_bmp, src_rect, opacity = @ma_default_opacity, grey = @ma_default_greyscale, *args)
    if grey
      src_bmp = src_bmp.dup
      src_bmp.greyscale (src_rect)
    end
    # 執行原方法
    mnalgba_bitmapaddons_opacdflt_blt_2hb5 (x, y, src_bmp, src_rect, opacity, *args)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias modrnalgbra_strtchblt_bmpdons_opc_0lk2 stretch_blt unless $@
  def stretch_blt (dest_rect, src_bmp, src_rect, opacity = @ma_default_opacity, grey = @ma_default_greyscale, *args)
    if grey
      src_bmp = src_bmp.dup
      src_bmp.greyscale (src_rect)
    end
    # 執行原方法
    modrnalgbra_strtchblt_bmpdons_opc_0lk2 (dest_rect, src_bmp, src_rect, opacity, *args)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def outline_ellipse (ellipse, colour = font.color, width = 1, steps = 0)
    a, b = ellipse.a, ellipse.b
    steps = Math::PI*(3*(a + b) - Math.sqrt((3*a + b)*(a + 3*b))) if steps == 0
    radian_modifier = (2*Math::PI) / steps
    for i in 0...steps
      t = (radian_modifier*i) % (2*Math::PI)
      x = (ellipse.h + (a*Math.cos(t)))
      y = (ellipse.k + (b*Math.sin(t)))
      set_pixel (x, y, colour)
    end
    if width > 1
      ellipse = Ellipse.new (ellipse.x + 1, ellipse.y + 1, ellipse.a - 1, ellipse.b - 1)
      outline_ellipse (ellipse, colour, width - 1, steps)
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def fill_ellipse (ellipse, colour = font.color, steps = 0)
    a, b = ellipse.a, ellipse.b
    steps = Math::PI*(3*(a + b) - Math.sqrt((3*a + b)*(a + 3*b))) if steps == 0
    radian_modifier = (2*Math::PI) / steps
    for i in 0...(steps / 2)
      t = (radian_modifier*i)
      x = ellipse.h + (a*Math.cos(t))
      y = ellipse.k - (b*Math.sin(t))
      fill_rect (x, y, 1, 2*(ellipse.k - y), colour)
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def fill_rounded_rect (rect, colour = font.color, w = 8)
    fill_rect (rect.x + w, rect.y, rect.width - 2*w, rect.height, colour)
    fill_rect (rect.x, rect.y + w, w, rect.height - 2*w, colour)
    x = rect.x + rect.width - w
    fill_rect (x, rect.y + w, w, rect.height - 2*w, colour)
    circle = Ellipse.new (0, 0, w)
    for i in 0...w
      for j in 0...w
        set_pixel (rect.x + i, rect.y + j, colour) if circle.within? (i, j)
        set_pixel (rect.x + rect.width - w + i, rect.y + j, colour) if circle.within? (i + w, j)
        set_pixel (rect.x + i, rect.y + rect.height - w + j, colour) if circle.within? (i, j + w)
        set_pixel (rect.x + rect.width - w + i, rect.y + rect.height - w + j, colour) if circle.within? (i + w, j + w)
      end
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #``````````````````````````````````````````````````````````````````````````
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def draw_line (x0, y0, x1, y1, colour = font.color)
    steep = (y1 - y0).abs > (x1 - x0).abs
    if steep
      tmp = x0
      x0, y0 = y0, tmp
      tmp = x1
      x1, y1 = y1, tmp
    end
    if x0 > x1
      tmp = x0
      x0, x1 = x1, tmp
      tmp = y0
      y0, y1 = y1, tmp
    end
    ystep = y0 < y1 ? 1 : -1
    deltax = x1 - x0
    deltay = (y1 - y0).abs
    error = deltax / 2
    y = y0
    for x in x0.to_i...x1.to_i
      steep ? set_pixel (y, x, colour) : set_pixel (x, y, colour)
      error -= deltay
      if error < 0
        y += ystep
        error += deltax
      end
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def greyscale (rect = Rect.new (0, 0, self.width, self.height))
    for i in rect.x...rect.x + rect.width
      for j in rect.y...rect.y + rect.height
        colour = self.get_pixel (i,j)
        grey_pixel = (colour.red*0.3 + colour.green*0.59 + colour.blue*0.11)
        colour.red = colour.green = colour.blue = grey_pixel
        self.set_pixel (i,j,colour)
      end
    end
  end
end

#==============================================================================
# PHASE8 原始頁：95｜Bitmap Addons-2
#==============================================================================
class Bitmap
  # 計算兩點之間的距離（RGSS2 兼容）
  def hypot(x, y)
    Math.sqrt(x * x + y * y)
  end

  # 讓圖片四個邊角變透明，形成圓角效果
  def draw_rounded_mask(rect)
    radius = 8  # 固定圓角半徑

    # 建立遮罩 Bitmap（與圖片大小相同）
    mask = Bitmap.new(rect.width, rect.height)
    mask.fill_rect(0, 0, rect.width, rect.height, Color.new(255, 255, 255)) # 白色遮罩

    # 在四個角落繪製透明區域
    for i in 0...radius
      for j in 0...radius
        if hypot(i - radius, j - radius) > radius
          mask.set_pixel(i, j, Color.new(0, 0, 0, 0)) # 左上
          mask.set_pixel(rect.width - 1 - i, j, Color.new(0, 0, 0, 0)) # 右上
          mask.set_pixel(i, rect.height - 1 - j, Color.new(0, 0, 0, 0)) # 左下
          mask.set_pixel(rect.width - 1 - i, rect.height - 1 - j, Color.new(0, 0, 0, 0)) # 右下
        end
      end
    end

    # 遍歷圖片，根據遮罩應用透明效果
    (0...rect.width).each do |i|
      (0...rect.height).each do |j|
        if mask.get_pixel(i, j).alpha == 0
          set_pixel(i, j, Color.new(0, 0, 0, 0))  # 設為透明
        end
      end
    end

    # 釋放遮罩 Bitmap
    mask.dispose
  end
end
