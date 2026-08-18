#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Game_Picture
# 【用途】保存單張事件 Picture 的位置、縮放、不透明度、混合、色調與旋轉。
# 【主要機制】Game_Screen 建立並更新多個 Game_Picture；Spriteset 端負責實際顯示。
# 【主要影響】Game_Picture
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
# ** Game_Picture
#------------------------------------------------------------------------------
#  這個類用來操控事件指令裡調用顯示的圖片。這個類在 Game_Screen 類的內部使用。
#  在地圖介面上通過事件指令顯示的圖片和在作戰時通過事件指令顯示的圖片分開操控。
#==============================================================================

class Game_Picture
  #--------------------------------------------------------------------------
  # * 宣告執行個體變數
  #--------------------------------------------------------------------------
  attr_reader   :number                   # 圖片編號
  attr_reader   :name                     # 圖檔名
  attr_reader   :origin                   # 原點
  attr_reader   :x                        # X座標
  attr_reader   :y                        # Y座標
  attr_reader   :zoom_x                   # 橫向放大率
  attr_reader   :zoom_y                   # 縱向放大率
  attr_reader   :opacity                  # 不透明度
  attr_reader   :blend_type               # 填充方式
  attr_reader   :tone                     # 色調
  attr_reader   :angle                    # 旋轉角度
  #--------------------------------------------------------------------------
  # * 物件初始化
  #     number : 圖片編號
  #--------------------------------------------------------------------------
  def initialize(number)
    @number = number
    @name = ""
    @origin = 0
    @x = 0.0
    @y = 0.0
    @zoom_x = 100.0
    @zoom_y = 100.0
    @opacity = 255.0
    @blend_type = 1
    @duration = 0
    @target_x = @x
    @target_y = @y
    @target_zoom_x = @zoom_x
    @target_zoom_y = @zoom_y
    @target_opacity = @opacity
    @tone = Tone.new(0, 0, 0, 0)
    @tone_target = Tone.new(0, 0, 0, 0)
    @tone_duration = 0
    @angle = 0
    @rotate_speed = 0
  end
  #--------------------------------------------------------------------------
  # * 顯示圖片
  #     name       : 圖檔名
  #     origin     : 原點
  #     x          : X座標
  #     y          : Y座標
  #     zoom_x     : 橫向放大率
  #     zoom_y     : 縱向放大率
  #     opacity    : 不透明度
  #     blend_type : 填充方式
  #--------------------------------------------------------------------------
  def show(name, origin, x, y, zoom_x, zoom_y, opacity, blend_type)
    @name = name
    @origin = origin
    @x = x.to_f
    @y = y.to_f
    @zoom_x = zoom_x.to_f
    @zoom_y = zoom_y.to_f
    @opacity = opacity.to_f
    @blend_type = blend_type
    @duration = 0
    @target_x = @x
    @target_y = @y
    @target_zoom_x = @zoom_x
    @target_zoom_y = @zoom_y
    @target_opacity = @opacity
    @tone = Tone.new(0, 0, 0, 0)
    @tone_target = Tone.new(0, 0, 0, 0)
    @tone_duration = 0
    @angle = 0
    @rotate_speed = 0
  end
  #--------------------------------------------------------------------------
  # * 移動圖片[並設置其參數]
  #     origin     : 圓點
  #     x          : X座標
  #     y          : Y座標
  #     zoom_x     : 橫向放大率
  #     zoom_y     : 縱向放大率
  #     opacity    : 不透明度
  #     blend_type : 填充方式
  #     duration   : 持續時間
  #--------------------------------------------------------------------------
  def move(origin, x, y, zoom_x, zoom_y, opacity, blend_type, duration)
    @origin = origin
    @target_x = x.to_f
    @target_y = y.to_f
    @target_zoom_x = zoom_x.to_f
    @target_zoom_y = zoom_y.to_f
    @target_opacity = opacity.to_f
    @blend_type = blend_type
    @duration = duration
  end
  #--------------------------------------------------------------------------
  # * 改變轉速
  #     speed : 旋轉速度
  #--------------------------------------------------------------------------
  def rotate(speed)
    @rotate_speed = speed
  end
  #--------------------------------------------------------------------------
  # * 開始改變色調
  #     tone     : 色調
  #     duration : 持續時間
  #--------------------------------------------------------------------------
  def start_tone_change(tone, duration)
    @tone_target = tone.clone
    @tone_duration = duration
    if @tone_duration == 0
      @tone = @tone_target.clone
    end
  end
  #--------------------------------------------------------------------------
  # * 擦除圖片
  #--------------------------------------------------------------------------
  def erase
    @name = ""
  end
  #--------------------------------------------------------------------------
  # * 更新幀
  #--------------------------------------------------------------------------
  def update
    if @duration >= 1
      d = @duration
      @x = (@x * (d - 1) + @target_x) / d
      @y = (@y * (d - 1) + @target_y) / d
      @zoom_x = (@zoom_x * (d - 1) + @target_zoom_x) / d
      @zoom_y = (@zoom_y * (d - 1) + @target_zoom_y) / d
      @opacity = (@opacity * (d - 1) + @target_opacity) / d
      @duration -= 1
    end
    if @tone_duration >= 1
      d = @tone_duration
      @tone.red = (@tone.red * (d - 1) + @tone_target.red) / d
      @tone.green = (@tone.green * (d - 1) + @tone_target.green) / d
      @tone.blue = (@tone.blue * (d - 1) + @tone_target.blue) / d
      @tone.gray = (@tone.gray * (d - 1) + @tone_target.gray) / d
      @tone_duration -= 1
    end
    if @rotate_speed != 0
      @angle += @rotate_speed / 2.0
      while @angle < 0
        @angle += 360
      end
      @angle %= 360
    end
  end
end
