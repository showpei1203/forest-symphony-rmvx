#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：图片窗口背景
# 【用途】保留的 Runtime 元件「图片窗口背景」。
# 【主要機制】主要定義／擴充 Skin、Window_Base；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Skin、Window_Base
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
#=============================================================================
#图片窗口背景
#作者:kissye
#
#注意事项
#使用这个脚本后,Window类里不能再用@skin变量
#
#使用方法
#自己写窗口的时候,令
#self.skin = Cache.文件夹名字("图片名字")
#或者在外部更改,令
#变量 = 窗口.new
#变量.skin = Cache.文件夹名字("图片名字")
#
#更新
#更改Skin为Sprite_Base子类,于是所有Sprite_Base类属性方法包括动画都可以直接调用
#不过真的有需要咩......
#
#Sprite属性举例,如更改图片透明度设置,令
#self.skin.opacity = 透明度
#此外可以设置图片大小,默认与窗口同样大小.
#self.skin.size(x方向变化, y方向变化)
#此数字可以为负.例如
#self.skin.size(-5, -5)
#那么图片大小比窗口上下左右都小了5像素
#=============================================================================
class Skin < Sprite_Base
  def initialize(bitmap, window)
    super(window.viewport)
    @sx = 0
    @sy = 0
    @rectbitmap = Rect.new(0, 0, bitmap.width, bitmap.height)
    @rectself = Rect.new(0, 0, window.width, window.height)
    @origwidth = window.width
    @origheight = window.height
    self.x = window.x
    self.yy = window.y
    self.z = window.z - 10
    self.visible = window.visible
    self.openness = window.openness
    @bitmap = bitmap
    drawback
  end
  #---------------------------------------------------------------------------
  def drawback
    unless @rectself.width == 0 or @rectself.height == 0
      if self.bitmap != nil
        self.bitmap.dispose
      end
      self.bitmap = Bitmap.new(@rectself.width, @rectself.height)
      self.bitmap.stretch_blt(@rectself, @bitmap, @rectbitmap)
    end
  end
  #------------------------------------------------------------------------
  def x=(value)
    @origx = value
    value -= @sx
    super(value)
  end
  #------------------------------------------------------------------------
  def yy=(value)
    @origy = value
    value -= @sy
    self.y = value
  end
  #-------------------------------------------------------------------------
  def width=(value)
    @rectself.width = value + @sx * 2
    @origwidth = value
    drawback
  end
  #-------------------------------------------------------------------------
  def height=(value)
    @rectself.height = value + @sy * 2
    @origheight = value
    drawback
  end
  #-------------------------------------------------------------------------
  def dispose
    self.bitmap.dispose
    super
  end
  #---------------------------------------------------------------------------
  def z=(value)
    value -= 10
    super(value)
  end
  #--------------------------------------------------------------------------
  def openness=(value)
    self.zoom_y = value / 255.0
    self.y = (1.0 - self.zoom_y) * @rectself.height / 2 + @origy - @sy
  end
  #--------------------------------------------------------------------------
  def size(x, y)
    @sx = x
    @sy = y
    self.x = @origx
    self.y = @origy - y
    @rectself.width = @origwidth + x * 2
    @rectself.height = @origheight + y * 2
    drawback
  end
end
#=========================================================================
class Window_Base < Window
  #-------------------------------------------------------------
  def dispose
    super
    if @skin != nil
      @skin.dispose
    end
  end
  #------------------------------------------------------------
  def x=(value)
    super
    if @skin != nil
      @skin.x = value
    end
  end
  #-----------------------------------------------------------
  def y=(value)
    super
    if @skin != nil
      @skin.yy = value
    end
  end
  #-----------------------------------------------------------
  def z=(value)
    super
    if @skin != nil
      @skin.z = value
    end
  end
  #----------------------------------------------------------
  def width=(value)
    if @skin != nil
      @skin.width = value
    end
    super
  end
  #----------------------------------------------------------
  def height=(value)
    if @skin != nil
      @skin.height = value
    end
    super
  end
  #--------------------------------------------------------------
  def visible=(value)
    super
    if @skin != nil
      @skin.visible = value
    end
  end
  #------------------------------------------------------------
  def skin=(value)
    self.opacity = 0
    self.back_opacity = 0
    if @skin != nil
      @skin.dispose
    end
    @skin = Skin.new(value, self)
  end
  #------------------------------------------------------------------
  def openness=(value)
    super
    if @skin != nil
      @skin.openness = self.openness
    end
  end
  #-------------------------------------------------------------------
  def viewport=(value)
    super
    if @skin != nil
      @skin.viewport = value
    end
  end
  #---------------------------------------------------------------------
  def skin
    if @skin != nil
      return @skin
    end
  end
end
