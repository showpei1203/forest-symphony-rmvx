#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Game_Screen
# 【用途】管理畫面淡入淡出、色調、閃爍、震動、天氣與事件圖片狀態。
# 【主要機制】Game_Map 與 Game_Troop 各自持有一份 Game_Screen，逐幀更新視覺狀態。
# 【主要影響】Game_Screen
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
# ** Game_Screen
#------------------------------------------------------------------------------
#  這個類用來操控螢幕上保留的資訊， 例如色調的改變以及閃屏等。
#  這個類在 Game_Map 類和 Game_Troop 類的內部使用。
#==============================================================================

class Game_Screen
  #--------------------------------------------------------------------------
  # * 宣告執行個體變數
  #--------------------------------------------------------------------------
  attr_reader   :brightness               # 亮度
  attr_reader   :tone                     # 色調
  attr_reader   :flash_color              # 閃爍顏色
  attr_reader   :shake                    # 顫動定位
  attr_reader   :pictures                 # 圖片
  attr_reader   :weather_type             # 天氣類型
  attr_reader   :weather_max              # 最大天氣圖片數量[天氣密度]
  #--------------------------------------------------------------------------
  # * 物件初始化
  #--------------------------------------------------------------------------
  def initialize
    clear
  end
  #--------------------------------------------------------------------------
  # * 清零
  #--------------------------------------------------------------------------
  def clear
    @brightness = 255
    @fadeout_duration = 0
    @fadein_duration = 0
    @tone = Tone.new(0, 0, 0, 0)
    @tone_target = Tone.new(0, 0, 0, 0)
    @tone_duration = 0
    @flash_color = Color.new(0, 0, 0, 0)
    @flash_duration = 0
    @shake_power = 0
    @shake_speed = 0
    @shake_duration = 0
    @shake_direction = 1
    @shake = 0
    @pictures = []
    for i in 0..20
      @pictures.push(Game_Picture.new(i))
    end
    @weather_type = 0
    @weather_max = 0.0
    @weather_type_target = 0
    @weather_max_target = 0.0
    @weather_duration = 0
  end
  #--------------------------------------------------------------------------
  # * 開始漸隱[淡出][Fade Out]
  #     duration : 持續時間
  #--------------------------------------------------------------------------
  def start_fadeout(duration)
    @fadeout_duration = duration
    @fadein_duration = 0
  end
  #--------------------------------------------------------------------------
  # * 開始漸顯[淡入][Fade In]
  #     duration : 持續時間
  #--------------------------------------------------------------------------
  def start_fadein(duration)
    @fadein_duration = duration
    @fadeout_duration = 0
  end
  #--------------------------------------------------------------------------
  # * 開始變更色調
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
  # * 開始閃屏
  #     color    : 閃爍顏色
  #     duration : 持續時間
  #--------------------------------------------------------------------------
  def start_flash(color, duration)
    @flash_color = color.clone
    @flash_duration = duration
  end
  #--------------------------------------------------------------------------
  # * 開始顫屏
  #     power    : 強度
  #     speed    : 頻度
  #     duration : 持續時間
  #--------------------------------------------------------------------------
  def start_shake(power, speed, duration)
    @shake_power = power
    @shake_speed = speed
    @shake_duration = duration
  end
  #--------------------------------------------------------------------------
  # * 設置天氣
  #     type     : 天氣種類
  #     power    : 天氣強度[天氣密度]
  #     duration : 持續時間
  #--------------------------------------------------------------------------
  def weather(type, power, duration)
    @weather_type_target = type
    if @weather_type_target != 0
      @weather_type = @weather_type_target
    end
    if @weather_type_target == 0
      @weather_max_target = 0.0
    else
      @weather_max_target = (power + 1) * 4.0
    end
    @weather_duration = duration
    if @weather_duration == 0
      @weather_type = @weather_type_target
      @weather_max = @weather_max_target
    end
  end
  #--------------------------------------------------------------------------
  # * 更新幀
  #--------------------------------------------------------------------------
  def update
    update_fadeout
    update_fadein
    update_tone
    update_flash
    update_shake
    update_weather
    update_pictures
  end
  #--------------------------------------------------------------------------
  # * 刷新[淡出]
  #--------------------------------------------------------------------------
  def update_fadeout
    if @fadeout_duration >= 1
      d = @fadeout_duration
      @brightness = (@brightness * (d - 1)) / d
      @fadeout_duration -= 1
    end
  end
  #--------------------------------------------------------------------------
  # * 刷新[淡入]
  #--------------------------------------------------------------------------
  def update_fadein
    if @fadein_duration >= 1
      d = @fadein_duration
      @brightness = (@brightness * (d - 1) + 255) / d
      @fadein_duration -= 1
    end
  end
  #--------------------------------------------------------------------------
  # * 刷新[色調]
  #--------------------------------------------------------------------------
  def update_tone
    if @tone_duration >= 1
      d = @tone_duration
      @tone.red = (@tone.red * (d - 1) + @tone_target.red) / d
      @tone.green = (@tone.green * (d - 1) + @tone_target.green) / d
      @tone.blue = (@tone.blue * (d - 1) + @tone_target.blue) / d
      @tone.gray = (@tone.gray * (d - 1) + @tone_target.gray) / d
      @tone_duration -= 1
    end
  end
  #--------------------------------------------------------------------------
  # * 刷新[閃爍]
  #--------------------------------------------------------------------------
  def update_flash
    if @flash_duration >= 1
      d = @flash_duration
      @flash_color.alpha = @flash_color.alpha * (d - 1) / d
      @flash_duration -= 1
    end
  end
  #--------------------------------------------------------------------------
  # * 刷新[顫動]
  #--------------------------------------------------------------------------
  def update_shake
    if @shake_duration >= 1 or @shake != 0
      delta = (@shake_power * @shake_speed * @shake_direction) / 10.0
      if @shake_duration <= 1 and @shake * (@shake + delta) < 0
        @shake = 0
      else
        @shake += delta
      end
      if @shake > @shake_power * 2
        @shake_direction = -1
      end
      if @shake < - @shake_power * 2
        @shake_direction = 1
      end
      if @shake_duration >= 1
        @shake_duration -= 1
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 刷新[天氣]
  #--------------------------------------------------------------------------
  def update_weather
    if @weather_duration >= 1
      d = @weather_duration
      @weather_max = (@weather_max * (d - 1) + @weather_max_target) / d
      @weather_duration -= 1
      if @weather_duration == 0
        @weather_type = @weather_type_target
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 刷新[圖片]
  #--------------------------------------------------------------------------
  def update_pictures
    for picture in @pictures
      picture.update
    end
  end
end
