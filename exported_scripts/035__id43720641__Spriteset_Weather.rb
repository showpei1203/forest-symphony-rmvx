#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Spriteset_Weather
# 【用途】顯示雨、風暴、雪等天氣 Sprite。
# 【主要機制】由對應 Spriteset 或 Scene 自動建立；視覺插件可能在後方擴充 update／dispose。
# 【主要影響】Spriteset_Weather
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
#==============================================================================
# ** Spriteset_Weather
#------------------------------------------------------------------------------
#  天氣特效（雨、風、雪）專用類，作為 Spriteset_Map 的內部類使用。
#==============================================================================

class Spriteset_Weather
  #--------------------------------------------------------------------------
  # * 宣告執行個體變數
  #--------------------------------------------------------------------------
  attr_reader :type
  attr_reader :max
  attr_reader :ox
  attr_reader :oy
  #--------------------------------------------------------------------------
  # * 物件初始化
  #--------------------------------------------------------------------------
  def initialize(viewport = nil)
    @type = 0
    @max = 0
    @ox = 0
    @oy = 0
    color1 = Color.new(255, 255, 255, 160)
    color2 = Color.new(255, 255, 255, 80)
    @rain_bitmap = Bitmap.new(7, 56)
    for i in 0..6
      @rain_bitmap.fill_rect(6-i, i*8, 1, 8, color1)
    end
    @storm_bitmap = Bitmap.new(34, 64)
    for i in 0..31
      @storm_bitmap.fill_rect(33-i, i*2, 1, 2, color2)
      @storm_bitmap.fill_rect(32-i, i*2, 1, 2, color1)
      @storm_bitmap.fill_rect(31-i, i*2, 1, 2, color2)
    end
    @snow_bitmap = Bitmap.new(6, 6)
    @snow_bitmap.fill_rect(0, 1, 6, 4, color2)
    @snow_bitmap.fill_rect(1, 0, 4, 6, color2)
    @snow_bitmap.fill_rect(1, 2, 4, 2, color1)
    @snow_bitmap.fill_rect(2, 1, 2, 4, color1)
    @sprites = []
    for i in 1..40
      sprite = Sprite.new(viewport)
      sprite.visible = false
      sprite.opacity = 0
      @sprites.push(sprite)
    end
  end
  #--------------------------------------------------------------------------
  # * 清除顯示
  #--------------------------------------------------------------------------
  def dispose
    for sprite in @sprites
      sprite.dispose
    end
    @rain_bitmap.dispose
    @storm_bitmap.dispose
    @snow_bitmap.dispose
  end
  #--------------------------------------------------------------------------
  # * 設置天氣類型
  #     type : 新的天氣類型
  #--------------------------------------------------------------------------
  def type=(type)
    return if @type == type
    @type = type
    case @type
    when 1
      bitmap = @rain_bitmap
    when 2
      bitmap = @storm_bitmap
    when 3
      bitmap = @snow_bitmap
    else
      bitmap = nil
    end
    for i in 0...@sprites.size
      sprite = @sprites[i]
      sprite.visible = (i <= @max)
      sprite.bitmap = bitmap
    end
  end
  #--------------------------------------------------------------------------
  # * 設置起點X座標
  #     ox : 起點X座標
  #--------------------------------------------------------------------------
  def ox=(ox)
    return if @ox == ox;
    @ox = ox
    for sprite in @sprites
      sprite.ox = @ox
    end
  end
  #--------------------------------------------------------------------------
  # * 設置起點Y座標
  #     oy : 起點Y座標
  #--------------------------------------------------------------------------
  def oy=(oy)
    return if @oy == oy;
    @oy = oy
    for sprite in @sprites
      sprite.oy = @oy
    end
  end
  #--------------------------------------------------------------------------
  # * 設置天氣圖形數量上限
  #     max : 天氣精靈物設數量上限
  #--------------------------------------------------------------------------
  def max=(max)
    return if @max == max;
    @max = [[max, 0].max, 40].min
    for i in 1..40
      sprite = @sprites[i]
      sprite.visible = (i <= @max) if sprite != nil
    end
  end
  #--------------------------------------------------------------------------
  # * 更新幀
  #--------------------------------------------------------------------------
  def update
    return if @type == 0
    for i in 1..@max
      sprite = @sprites[i]
      if sprite == nil
        break
      end
      if @type == 1
        sprite.x -= 2
        sprite.y += 16
        sprite.opacity -= 8
      end
      if @type == 2
        sprite.x -= 8
        sprite.y += 16
        sprite.opacity -= 12
      end
      if @type == 3
        sprite.x -= 2
        sprite.y += 8
        sprite.opacity -= 8
      end
      x = sprite.x - @ox
      y = sprite.y - @oy
      if sprite.opacity < 64
        sprite.x = rand(800) - 100 + @ox
        sprite.y = rand(600) - 200 + @oy
        sprite.opacity = 255
      end
    end
  end
end
