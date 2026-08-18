#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：氣候系統（MAWS - Modified Advanced Weather Script VX v1.1）
# 【用途】擴充 RPG Maker VX 的地圖天氣，提供雨、暴風、雪、落葉、花瓣、隕石、灰燼、泡泡、星芒、酸雨、血雨等 54 種效果，並支援自訂天氣圖片。
# 【來源】基於 Ccoa 的 Advanced Weather Script VX；修改：Agckuu Coceg；VX 協助：DerWulfman。
# 【主要影響】Spriteset_Weather、Scene_Map、Spriteset_Map；會建立並更新大量天氣 Sprite，天氣 power 越高負荷越大。
# 【載入順序】維持目前已驗證位置。若另用解析度腳本，原作註明需檢查／移除本頁 HEIGHT、WIDTH 固定值。
# 【基本呼叫】事件「腳本」使用：screen.weather(type, power, hue)
#   - type：天氣類型 ID。
#   - power：0～40；0 表示無天氣，原作者說明 40 約等於 400 個 Sprite。
#   - hue：色相值。
# 【範例】screen.weather(1, 10, 0)  # 雨；power=10、hue=0
# 【天氣 ID】
#   1雨、2暴風雨、3雪、4冰雹、5雷雨、6褐色落葉、7褐色吹葉、8褐色旋葉、9綠色落葉、10櫻花瓣、11玫瑰花瓣、12羽毛、13血雨、14閃光、15自訂天氣、16吹雪、17流星雨、18落灰、19泡泡、20泡泡2、21向上閃光。
#   22綠色吹葉、23綠色旋葉、24黃色落葉、25黃色吹葉、26黃色旋葉、27油雨、28金雨、29火焰流星雨。
#   30彩色星芒v2、31向上彩色星芒v2、32彩色星芒雨v2、33單色星芒、34向上單色星芒、35單色星芒雨。
#   36金色雷雨、37金色暴風、38油暴風、39酸雨、40酸雷雨、41酸暴風、42褐色調雨、43褐色調雷雨、44褐色調暴風、45寫實暴風、46緋紅閃電血雨、47血暴風、48血色暴雪。
#   49紅楓落葉、50紅楓吹葉、51紅楓旋葉、52水彈、53冰彈、54火焰彈。
# 【自訂天氣 type=15】
#   $WEATHER_UPDATE：自訂圖片陣列變更後設 true，要求 Runtime 更新。
#   $WEATHER_IMAGES：使用的圖片名稱陣列。
#   $WEATHER_X / $WEATHER_Y：每次更新的水平／垂直位移；正值右／下，負值左／上。
#   $WEATHER_FADE：每次更新降低的透明度；0 不淡出，255 立即消失。
#   $WEATHER_ANIMATED：true 時依序循環 $WEATHER_IMAGES。
# 【解析度】HEIGHT=416、WIDTH=544 為 VX 標準尺寸；若使用 Ccoa 解析度腳本，原作要求檢查這兩個常數。
# 【相關素材】本頁直接播放 Audio/SE/Thunder1、Audio/SE/Thunder9；其他粒子多由程式建立 Bitmap 或由自訂天氣圖片提供。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本頁所有維護說明集中於腳本最前方；下方程式識別字、Notetag、Action Key、方法名不可翻譯改名。
# 2. 原作者、版本、Credits、License、網址等來源資訊保留；完整翻譯前原稿另存 Phase 16 Archive。
# 3. 範例只使用原文件已明示的 API／Notetag，或由既有方法簽章可直接證實的呼叫方式。
# 4. 本輪只改註解／說明，不改任何可執行 Ruby；載入順序仍以 FS LoadOrder Guide／Authority Map 為準。
#==============================================================================
$WEATHER_UPDATE = false
$WEATHER_IMAGES = []
$WEATHER_X = 0
$WEATHER_Y = 0
$WEATHER_FADE = 0
$WEATHER_ANIMATED = false

  HEIGHT = 416
  WIDTH = 544

#==============================================================================
#------------------------------------------------------------------------------

class Spriteset_Weather
  #--------------------------------------------------------------------------
  # * 公開實例變數
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
    
    @count = 0
    @current_pose = []
    @info = []
    @countarray = []
    
    make_bitmaps
    
    @sprites = []
    
    for i in 1..500
      sprite = Sprite.new(viewport)
      sprite.visible = false
      sprite.opacity = 0
      @sprites.push(sprite)
      @current_pose.push(0)
      @info.push(rand(50))
      @countarray.push(rand(15))
    end
    
  end
   #--------------------------------------------------------------------------
  # * 釋放資源
  #--------------------------------------------------------------------------
  def dispose
    for sprite in @sprites
      sprite.dispose
    end
    @rain_bitmap.dispose
    @storm_bitmap.dispose
    @snow_bitmap.dispose
    @hail_bitmap.dispose
    @petal_bitmap.dispose
    @blood_rain_bitmap.dispose
    @oil_rain_bitmap.dispose
    @golden_rain_bitmap.dispose
    @golden_storm_bitmap.dispose
    @acid_rain_bitmap.dispose
    @acid_storm_bitmap.dispose
    @sepia_rain_bitmap.dispose
    @sepia_storm_bitmap.dispose
    @blood_storm_bitmap.dispose
    @bloodblizz_bitmap.dispose
    @meteor_bitmap.dispose
    @flame_meteor_bitmap.dispose
    @waterbomb_bitmap.dispose
    @icybomb_bitmap.dispose
    @flarebomb_bitmap.dispose
    for image in @autumn_leaf_bitmaps
      image.dispose
    end
    for image in @green_leaf_bitmaps
      image.dispose
    end
    for image in @yellow_leaf_bitmaps
      image.dispose
    end
    for image in @redmaple_leaf_bitmaps
      image.dispose
    end
    for image in @rose_bitmaps
      image.dispose
    end
    for image in @feather_bitmaps
      image.dispose
    end
    for image in @sparkle_bitmaps
      image.dispose
    end
    for image in @starburst_bitmaps
      image.dispose
    end
    for image in @monostarburst_bitmaps
      image.dispose
    end
    for image in @user_bitmaps
      image.dispose
    end
    $WEATHER_UPDATE = true
  end
  #--------------------------------------------------------------------------
  # * 設定天氣類型
  # type：新的天氣類型
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
   when 4
      bitmap = @hail_bitmap
    when 5
      bitmap = @rain_bitmap
      @thunder = true
    when 6
      bitmap = @autumn_leaf_bitmaps[0]
    when 7
      bitmap = @autumn_leaf_bitmaps[0]
    when 8
      bitmap = @autumn_leaf_bitmaps[0]
    when 9
      bitmap = @green_leaf_bitmaps[0]
    when 10
      bitmap = @petal_bitmap
    when 11
      bitmap = @rose_bitmaps[0]
    when 12
      bitmap = @feather_bitmaps[0]
    when 13
      bitmap = @blood_rain_bitmap
    when 14
      bitmap = @sparkle_bitmaps[0]
    when 15
        bitmap = @user_bitmaps[rand(@user_bitmaps.size)]
    when 16
      bitmap = @snow_bitmap
    when 17
      bitmap = @meteor_bitmap
    when 18
      bitmap = @ash_bitmaps[rand(@ash_bitmaps.size)]
    when 19
      bitmap = @bubble_bitmaps[rand(@bubble_bitmaps.size)]
    when 21
      bitmap = @sparkle_bitmaps[0]
    when 22
      bitmap = @green_leaf_bitmaps[0]
    when 23
      bitmap = @green_leaf_bitmaps[0]
    when 24
      bitmap = @yellow_leaf_bitmaps[0]
    when 25
      bitmap = @yellow_leaf_bitmaps[0]
    when 26
      bitmap = @yellow_leaf_bitmaps[0]
    when 27
       bitmap = @oil_rain_bitmap
    when 28
       bitmap = @golden_rain_bitmap
    when 29
       bitmap = @flame_meteor_bitmap
    when 30
      bitmap = @starburst_bitmaps[0]
    when 31
      bitmap = @starburst_bitmaps[0]
    when 32
      bitmap = @starburst_bitmaps[0]
    when 33
      bitmap = @monostarburst_bitmaps[0]
    when 34
      bitmap = @monostarburst_bitmaps[0]
    when 35
      bitmap = @monostarburst_bitmaps[0]
    when 36
      bitmap = @golden_rain_bitmap
      @golden_thunder = true
    when 37
      bitmap = @golden_storm_bitmap
    when 38
      bitmap = @oil_storm_bitmap
    when 39
      bitmap = @acid_rain_bitmap
    when 40
      bitmap = @acid_rain_bitmap
      @acid_thunder = true
    when 41
      bitmap = @acid_storm_bitmap
    when 42
      bitmap = @sepia_rain_bitmap
    when 43
      bitmap = @sepia_rain_bitmap
      @sepia_thunder = true
    when 44
      bitmap = @sepia_storm_bitmap
    when 45
      bitmap = @storm_bitmap
      @real_storm = true
    when 46
      bitmap = @blood_rain_bitmap
      @crimson_thunder = true
    when 47
      bitmap = @blood_storm_bitmap
    when 48
      bitmap = @bloodblizz_bitmap
    when 49
      bitmap = @redmaple_leaf_bitmaps[0]
    when 50
      bitmap = @redmaple_leaf_bitmaps[0]
    when 51
      bitmap = @redmaple_leaf_bitmaps[0]
    when 52
      bitmap = @waterbomb_bitmaps
    when 53
      bitmap = @icybomb_bitmaps
    when 54
      bitmap = @flarebomb_bitmaps
    else
      bitmap = nil
    end
    
    if @type != 5
      @thunder = false
    end
    
    if @type != 36
      @golden_thunder = false
    end
    
    if @type != 40
      @acid_thunder = false
    end
    
    if @type != 43
      @sepia_thunder = false
    end
    
    if @type != 45
      @real_storm = false
    end
    
    if @type != 46
      @crimson_thunder = false
    end
    
    for i in 0...@sprites.size
      sprite = @sprites[i]
      sprite.visible = (i <= @max)
      if @type == 19
        sprite.bitmap = @bubble_bitmaps[rand(@bubble_bitmaps.size)]
      elsif @type == 20
        sprite.bitmap = @bubble2_bitmaps[rand(@bubble2_bitmaps.size)]
      elsif @type == 3
        r = rand(@snow_bitmaps.size)
        @info[i] = r
        sprite.bitmap = @snow_bitmaps[r]
      else
        sprite.bitmap = bitmap
      end
    end
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def ox=(ox)
    return if @ox == ox;
    @ox = ox
    for sprite in @sprites
      sprite.ox = @ox
    end
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def oy=(oy)
    return if @oy == oy;
    @oy = oy
    for sprite in @sprites
      sprite.oy = @oy
    end
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def max=(max)
    return if @max == max;
    @max = [[max, 0].max, 40].min
    for i in 1..40
      sprite = @sprites[i]
      sprite.visible = (i <= @max) if sprite != nil
      if @type == 19
          sprite.bitmap = @bubble_bitmaps[rand(@bubble_bitmaps.size)]
        elsif @type == 20
          sprite.bitmap = @bubble2_bitmaps[rand(@bubble2_bitmaps.size)]
        elsif @type == 3
          r = rand(@snow_bitmaps.size)
          @info[i] = r
          sprite.bitmap = @snow_bitmaps[r]
        end
    end
  end
#--------------------------------------------------------------------------
#--------------------------------------------------------------------------
  def update
    return if @type == 0
    for i in 1..@max
      sprite = @sprites[i]
      if @type == 1 or @type == 5 or @type == 13 or @type == 27 or @type == 28 or @type == 36 or @type == 39 or @type == 40 or @type == 42 or @type == 43 or @type == 46
        if sprite.opacity <= 150
          if @current_pose[i] == 0
            sprite.y += @rain_bitmap.height
            sprite.x -= @rain_bitmap.width
            if @type == 1 or @type == 5
              sprite.bitmap = @rain_splash
            else
              sprite.bitmap = @blood_rain_splash
            end
            if @type == 27
              sprite.bitmap = @oil_rain_splash
            end
            if @type == 28
              sprite.bitmap = @golden_rain_splash
            end
            if @type == 36
              sprite.bitmap = @golden_rain_splash
            end
            if @type == 39
              sprite.bitmap = @acid_rain_splash
            end
            if @type == 40
              sprite.bitmap = @acid_rain_splash
            end
            if @type == 42
              sprite.bitmap = @sepia_rain_splash
            end
            if @type == 43
              sprite.bitmap = @sepia_rain_splash
            end
            if @type == 46
              sprite.bitmap = @blood_rain_splash
            end
            @current_pose[i] = 1
          end
        else
          if @current_pose[i] == 1
            if @type == 1 or @type == 5
              sprite.bitmap = @rain_bitmap
            else
              sprite.bitmap = @blood_rain_bitmap
            end
            if @type == 27
              sprite.bitmap = @oil_rain_bitmap
            end
            if @type == 28
              sprite.bitmap = @golden_rain_bitmap
            end
            if @type == 36
              sprite.bitmap = @golden_rain_bitmap
            end
            if @type == 39
              sprite.bitmap = @acid_rain_bitmap
            end
            if @type == 40
              sprite.bitmap = @acid_rain_bitmap
            end
            if @type == 42
              sprite.bitmap = @sepia_rain_bitmap
            end
            if @type == 43
              sprite.bitmap = @sepia_rain_bitmap
            end
            if @type == 46
              sprite.bitmap = @blood_rain_bitmap
            end
            @current_pose[i] = 0
          end
          sprite.x -= 2
          sprite.y += 16
          if @thunder and (rand(8000 - @max) == 0)
            $game_map.screen.start_flash(Color.new(255, 255, 255, 255), 5)
            Audio.se_play("Audio/SE/Thunder1")
          end
        if @golden_thunder and (rand(8000 - @max) == 0)
            $game_map.screen.start_flash(Color.new(255, 255, 255, 255), 5)
            Audio.se_play("Audio/SE/Thunder1")
          end
       if @acid_thunder and (rand(5000 - @max) == 0)
            $game_map.screen.start_flash(Color.new(255, 255, 255, 255), 5)
            Audio.se_play("Audio/SE/Thunder1")
          end
       if @sepia_thunder and (rand(8000 - @max) == 0)
            $game_map.screen.start_flash(Color.new(169, 152, 142, 255), 5)
            Audio.se_play("Audio/SE/Thunder1")
          end
       if @sepia_thunder and (rand(8000 - @max) == 0)
            $game_map.screen.start_flash(Color.new(169, 152, 142, 255), 5)
            Audio.se_play("Audio/SE/Thunder1")
          end
       if @crimson_thunder and (rand(8000 - @max) == 0)
          $game_map.screen.start_flash(Color.new(141, 9, 9, 255), 5)
          Audio.se_play("Audio/SE/Thunder1")
          end
        end
        sprite.opacity -= 8
      end
      if @type == 2 or @type == 37 or @type == 38 or @type == 41 or @type == 44 or @type == 45 or @type == 47
        sprite.x -= 8
        sprite.y += 16
        sprite.opacity -= 12
      end
        if @real_storm and (rand(5000 - @max) == 0)
        $game_map.screen.start_flash(Color.new(255, 255, 255, 255), 5)
        $game_map.screen.start_shake(9, 4, 5)
        Audio.se_play("Audio/SE/Thunder9")
      end
      if @type == 3
        case @info[i]
        when 0
          sprite.y += 1
        when 1
          sprite.y += 3
        when 2
          sprite.y += 5
        when 3
          sprite.y += 7
        end
        sprite.opacity -= 3
      end
      if @type == 4
        sprite.x -= 1
        sprite.y += 18
        sprite.opacity -= 15
      end
      if @type == 6
        @count = rand(20)
        if @count == 0
          sprite.bitmap = @autumn_leaf_bitmaps[@current_pose[i]]
          @current_pose[i] = (@current_pose[i] + 1) % @autumn_leaf_bitmaps.size
        end
        sprite.x -= 1
        sprite.y += 1
      end
      if @type == 7
        @count = rand(20)
        if @count == 0
          sprite.bitmap = @autumn_leaf_bitmaps[@current_pose[i]]
          @current_pose[i] = (@current_pose[i] + 1) % @autumn_leaf_bitmaps.size
        end
        sprite.x -= 10
        sprite.y += (rand(4) - 2)
      end
      if @type == 8
        @count = rand(20)
        if @count == 0
          sprite.bitmap = @autumn_leaf_bitmaps[@current_pose[i]]
          @current_pose[i] = (@current_pose[i] + 1) % @autumn_leaf_bitmaps.size
        end
        if @info[i] != 0
          if @info[i] >= 1 and @info[i] <= 10
            sprite.x -= 3
            sprite.y -= 1
          elsif @info[i] >= 11 and @info[i] <= 16
            sprite.x -= 1
            sprite.y -= 2
          elsif @info[i] >= 17 and @info[i] <= 20
            sprite.y -= 3
          elsif @info[i] >= 21 and @info[i] <= 30
            sprite.y -= 2
            sprite.x += 1
          elsif @info[i] >= 31 and @info[i] <= 36
            sprite.y -= 1
            sprite.x += 3
          elsif @info[i] >= 37 and @info[i] <= 40
            sprite.x += 5
          elsif @info[i] >= 41 and @info[i] <= 46
            sprite.y += 1
            sprite.x += 3
          elsif @info[i] >= 47 and @info[i] <= 58
            sprite.y += 2
            sprite.x += 1
          elsif @info[i] >= 59 and @info[i] <= 64
            sprite.y += 3
          elsif @info[i] >= 65 and @info[i] <= 70
            sprite.x -= 1
            sprite.y += 2
          elsif @info[i] >= 71 and @info[i] <= 81
            sprite.x -= 3
            sprite.y += 1
          elsif @info[i] >= 82 and @info[i] <= 87
            sprite.x -= 5
          end
          @info[i] = (@info[i] + 1) % 88
        else
          if rand(200) == 0
            @info[i] = 1
          end
          sprite.x -= 5
          sprite.y += 1
        end
      end
        if @type == 49
        @count = rand(20)
        if @count == 0
          sprite.bitmap = @redmaple_leaf_bitmaps[@current_pose[i]]
          @current_pose[i] = (@current_pose[i] + 1) % @redmaple_leaf_bitmaps.size
        end
        sprite.x -= 1
        sprite.y += 1
      end
      if @type == 50
        @count = rand(20)
        if @count == 0
          sprite.bitmap = @redmaple_leaf_bitmaps[@current_pose[i]]
          @current_pose[i] = (@current_pose[i] + 1) % @redmaple_leaf_bitmaps.size
        end
        sprite.x -= 10
        sprite.y += (rand(4) - 2)
      end
      if @type == 51
        @count = rand(20)
        if @count == 0
          sprite.bitmap = @redmaple_leaf_bitmaps[@current_pose[i]]
          @current_pose[i] = (@current_pose[i] + 1) % @redmaple_leaf_bitmaps.size
        end
        if @info[i] != 0
          if @info[i] >= 1 and @info[i] <= 10
            sprite.x -= 3
            sprite.y -= 1
          elsif @info[i] >= 11 and @info[i] <= 16
            sprite.x -= 1
            sprite.y -= 2
          elsif @info[i] >= 17 and @info[i] <= 20
            sprite.y -= 3
          elsif @info[i] >= 21 and @info[i] <= 30
            sprite.y -= 2
            sprite.x += 1
          elsif @info[i] >= 31 and @info[i] <= 36
            sprite.y -= 1
            sprite.x += 3
          elsif @info[i] >= 37 and @info[i] <= 40
            sprite.x += 5
          elsif @info[i] >= 41 and @info[i] <= 46
            sprite.y += 1
            sprite.x += 3
          elsif @info[i] >= 47 and @info[i] <= 58
            sprite.y += 2
            sprite.x += 1
          elsif @info[i] >= 59 and @info[i] <= 64
            sprite.y += 3
          elsif @info[i] >= 65 and @info[i] <= 70
            sprite.x -= 1
            sprite.y += 2
          elsif @info[i] >= 71 and @info[i] <= 81
            sprite.x -= 3
            sprite.y += 1
          elsif @info[i] >= 82 and @info[i] <= 87
            sprite.x -= 5
          end
          @info[i] = (@info[i] + 1) % 88
        else
          if rand(200) == 0
            @info[i] = 1
          end
          sprite.x -= 5
          sprite.y += 1
        end
      end
      if @type == 9
        if @countarray[i] == 0
          @current_pose[i] = (@current_pose[i] + 1) % @green_leaf_bitmaps.size
          sprite.bitmap = @green_leaf_bitmaps[@current_pose[i]]
          @countarray[i] = rand(15)
        end
        @countarray[i] = (@countarray[i] + 1) % 15
        sprite.y += 1
      end
      if @type == 10
        if @info[i] < 25
          sprite.x -= 1
        else
          sprite.x += 1
        end
        @info[i] = (@info[i] + 1) % 50
        sprite.y += 1
      end
      if @type == 11
        @count = rand(20)
        if @count == 0
          sprite.bitmap = @rose_bitmaps[@current_pose[i]]
          @current_pose[i] = (@current_pose[i] + 1) % @rose_bitmaps.size
        end
        if @info[i] % 2 == 0
          if @info[i] < 10
            sprite.x -= 1
          elsif
            sprite.x += 1
          end
        end
        sprite.y += 1
      end
      if @type == 12
        if @countarray[i] == 0
          @current_pose[i] = (@current_pose[i] + 1) % @feather_bitmaps.size
          sprite.bitmap = @feather_bitmaps[@current_pose[i]]
        end
        @countarray[i] = (@countarray[i] + 1) % 15
        if rand(100) == 0
          sprite.x -= 1
        end
        if rand(100) == 0
          sprite.y -= 1
        end
        if @info[i] < 50
          if rand(2) == 0
            sprite.x -= 1
          else
            sprite.y -= 1
          end
        else
          if rand(2) == 0
            sprite.x += 1
          else
            sprite.y += 1
          end
        end
        @info[i] = (@info[i] + 1) % 100
      end
      
       if @type == 30
        if @countarray[i] == 0
          @current_pose[i] = (@current_pose[i] + 1) % @starburst_bitmaps.size
          sprite.bitmap = @starburst_bitmaps[@current_pose[i]]
        end
        @countarray[i] = (@countarray[i] + 1) % 15
        sprite.y += 1
        sprite.opacity -= 1
      end
      if @type == 31
        if @countarray[i] == 0
          @current_pose[i] = (@current_pose[i] + 1) % @starburst_bitmaps.size
          sprite.bitmap = @starburst_bitmaps[@current_pose[i]]
        end
        @countarray[i] = (@countarray[i] + 1) % 15
        sprite.y -= 1
        sprite.opacity -= 1
      end
      if @type == 32
        if @countarray[i] == 0
          @current_pose[i] = (@current_pose[i] + 1) % @starburst_bitmaps.size
          sprite.bitmap = @starburst_bitmaps[@current_pose[i]]
        end
        @countarray[i] = (@countarray[i] + 1) % 15
        sprite.x -= 2
        sprite.y += 8
        sprite.opacity -= 1
      end     
      
      if @type == 33
        if @countarray[i] == 0
          @current_pose[i] = (@current_pose[i] + 1) % @monostarburst_bitmaps.size
          sprite.bitmap = @monostarburst_bitmaps[@current_pose[i]]
        end
        @countarray[i] = (@countarray[i] + 1) % 15
        sprite.y += 1
        sprite.opacity -= 1
      end
      if @type == 34
        if @countarray[i] == 0
          @current_pose[i] = (@current_pose[i] + 1) % @monostarburst_bitmaps.size
          sprite.bitmap = @monostarburst_bitmaps[@current_pose[i]]
        end
        @countarray[i] = (@countarray[i] + 1) % 15
        sprite.y -= 1
        sprite.opacity -= 1
      end
      if @type == 35
        if @countarray[i] == 0
          @current_pose[i] = (@current_pose[i] + 1) % @monostarburst_bitmaps.size
          sprite.bitmap = @monostarburst_bitmaps[@current_pose[i]]
        end
        @countarray[i] = (@countarray[i] + 1) % 15
        sprite.x -= 2
        sprite.y += 8
        sprite.opacity -= 1
      end           
        if @type == 29
        if @countarray[i] > 0
          if rand(20) == 0
            sprite.bitmap = @flame_impact_bitmap
            @countarray[i] = -5
          else
            sprite.x -= 6
            sprite.y += 10
          end
        else
          @countarray[i] += 1
          if @countarray[i] == 0
            sprite.bitmap = @flame_meteor_bitmap
            sprite.opacity = 0
            @count_array = 1
          end
        end
      end
      if @type == 18
        sprite.y += 2
        case @countarray[i] % 3
        when 0
          sprite.x -= 1
        when 1
          sprite.x += 1
        end
      end      
      
      if @type == 14
        if @countarray[i] == 0
          @current_pose[i] = (@current_pose[i] + 1) % @sparkle_bitmaps.size
          sprite.bitmap = @sparkle_bitmaps[@current_pose[i]]
        end
        @countarray[i] = (@countarray[i] + 1) % 15
        sprite.y += 1
        sprite.opacity -= 1
      end
      if @type == 15
        if $WEATHER_UPDATE
          update_user_defined
          $WEATHER_UPDATE = false
        end
        if $WEATHER_ANIMATED and @countarray[i] == 0
          @current_pose[i] = (@current_pose[i] + 1) % @user_bitmaps.size
          sprite.bitmap = @user_bitmaps[@current_pose[i]]
        end
        sprite.x += $WEATHER_X
        sprite.y += $WEATHER_Y
        sprite.opacity -= $WEATHER_FADE
      end
      if @type == 16
        sprite.x -= 10
        sprite.y += 6
        sprite.opacity -= 4
      end
      if @type == 48
        sprite.x -= 10
        sprite.y += 6
        sprite.opacity -= 4
      end
      if @type == 52
        if @countarray[i] > 0
          if rand(20) == 0
            sprite.bitmap = @waterbomb_impact_bitmap
            @countarray[i] = -5
          else
            sprite.x -= 3
            sprite.y += 5
          end
        else
          @countarray[i] += 1
          if @countarray[i] == 0
            sprite.bitmap = @waterbomb_bitmap
            sprite.opacity = 0
            @count_array = 1
          end
        end
      end
        if @type == 53
        if @countarray[i] > 0
          if rand(20) == 0
            sprite.bitmap = @icybomb_impact_bitmap
            @countarray[i] = -5
          else
            sprite.x -= 3
            sprite.y += 5
          end
        else
          @countarray[i] += 1
          if @countarray[i] == 0
            sprite.bitmap = @icybomb_bitmap
            sprite.opacity = 0
            @count_array = 1
          end
        end
      end
      if @type == 54
        if @countarray[i] > 0
          if rand(20) == 0
            sprite.bitmap = @flarebomb_impact_bitmap
            @countarray[i] = -5
          else
            sprite.x -= 3
            sprite.y += 5
          end
        else
          @countarray[i] += 1
          if @countarray[i] == 0
            sprite.bitmap = @flarebomb_bitmap
            sprite.opacity = 0
            @count_array = 1
          end
        end
      end
      if @type == 17
        if @countarray[i] > 0
          if rand(20) == 0
            sprite.bitmap = @impact_bitmap
            @countarray[i] = -5
          else
            sprite.x -= 6
            sprite.y += 10
          end
        else
          @countarray[i] += 1
          if @countarray[i] == 0
            sprite.bitmap = @meteor_bitmap
            sprite.opacity = 0
            @count_array = 1
          end
        end
      end
      if @type == 18
        sprite.y += 2
        case @countarray[i] % 3
        when 0
          sprite.x -= 1
        when 1
          sprite.x += 1
        end
      end
      if @type == 19 or @type == 20
        switch = rand(75) + rand(75) + 1
        if @info[i] < switch / 2
          sprite.x -= 1
        else
          sprite.x += 1
        end
        @info[i] = (@info[i] + 1) % switch
        sprite.y -= 1
        if switch % 2 == 0
          sprite.opacity -= 1
        end
      end
      if @type == 21
        if @countarray[i] == 0
          @current_pose[i] = (@current_pose[i] + 1) % @sparkle_bitmaps.size
          sprite.bitmap = @sparkle_bitmaps[@current_pose[i]]
        end
        @countarray[i] = (@countarray[i] + 1) % 15
        sprite.y -= 1
        sprite.opacity -= 1
      end
         if @type == 24
        @count = rand(20)
        if @count == 0
          sprite.bitmap = @yellow_leaf_bitmaps[@current_pose[i]]
          @current_pose[i] = (@current_pose[i] + 1) % @yellow_leaf_bitmaps.size
        end
        sprite.x -= 1
        sprite.y += 1
      end
       if @type == 22
        @count = rand(20)
        if @count == 0
          sprite.bitmap = @green_leaf_bitmaps[@current_pose[i]]
          @current_pose[i] = (@current_pose[i] + 1) % @green_leaf_bitmaps.size
        end
        sprite.x -= 10
        sprite.y += (rand(4) - 2)
      end      
      if @type == 23
        @count = rand(20)
        if @count == 0
          sprite.bitmap = @green_leaf_bitmaps[@current_pose[i]]
          @current_pose[i] = (@current_pose[i] + 1) % @green_leaf_bitmaps.size
        end
        if @info[i] != 0
          if @info[i] >= 1 and @info[i] <= 10
            sprite.x -= 3
            sprite.y -= 1
          elsif @info[i] >= 11 and @info[i] <= 16
            sprite.x -= 1
            sprite.y -= 2
          elsif @info[i] >= 17 and @info[i] <= 20
            sprite.y -= 3
          elsif @info[i] >= 21 and @info[i] <= 30
            sprite.y -= 2
            sprite.x += 1
          elsif @info[i] >= 31 and @info[i] <= 36
            sprite.y -= 1
            sprite.x += 3
          elsif @info[i] >= 37 and @info[i] <= 40
            sprite.x += 5
          elsif @info[i] >= 41 and @info[i] <= 46
            sprite.y += 1
            sprite.x += 3
          elsif @info[i] >= 47 and @info[i] <= 58
            sprite.y += 2
            sprite.x += 1
          elsif @info[i] >= 59 and @info[i] <= 64
            sprite.y += 3
          elsif @info[i] >= 65 and @info[i] <= 70
            sprite.x -= 1
            sprite.y += 2
          elsif @info[i] >= 71 and @info[i] <= 81
            sprite.x -= 3
            sprite.y += 1
          elsif @info[i] >= 82 and @info[i] <= 87
            sprite.x -= 5
          end
          @info[i] = (@info[i] + 1) % 88
        else
          if rand(200) == 0
            @info[i] = 1
          end
          sprite.x -= 5
          sprite.y += 1
        end
      end
        if @type == 24
        @count = rand(20)
        if @count == 0
          sprite.bitmap = @yellow_leaf_bitmaps[@current_pose[i]]
          @current_pose[i] = (@current_pose[i] + 1) % @yellow_leaf_bitmaps.size
        end
        sprite.x -= 1
        sprite.y += 1
      end      
     if @type == 25
        @count = rand(20)
        if @count == 0
          sprite.bitmap = @yellow_leaf_bitmaps[@current_pose[i]]
          @current_pose[i] = (@current_pose[i] + 1) % @yellow_leaf_bitmaps.size
        end
        sprite.x -= 10
        sprite.y += (rand(4) - 2)
      end 
       if @type == 26
        @count = rand(20)
        if @count == 0
          sprite.bitmap = @yellow_leaf_bitmaps[@current_pose[i]]
          @current_pose[i] = (@current_pose[i] + 1) % @yellow_leaf_bitmaps.size
        end
        if @info[i] != 0
          if @info[i] >= 1 and @info[i] <= 10
            sprite.x -= 3
            sprite.y -= 1
          elsif @info[i] >= 11 and @info[i] <= 16
            sprite.x -= 1
            sprite.y -= 2
          elsif @info[i] >= 17 and @info[i] <= 20
            sprite.y -= 3
          elsif @info[i] >= 21 and @info[i] <= 30
            sprite.y -= 2
            sprite.x += 1
          elsif @info[i] >= 31 and @info[i] <= 36
            sprite.y -= 1
            sprite.x += 3
          elsif @info[i] >= 37 and @info[i] <= 40
            sprite.x += 5
          elsif @info[i] >= 41 and @info[i] <= 46
            sprite.y += 1
            sprite.x += 3
          elsif @info[i] >= 47 and @info[i] <= 58
            sprite.y += 2
            sprite.x += 1
          elsif @info[i] >= 59 and @info[i] <= 64
            sprite.y += 3
          elsif @info[i] >= 65 and @info[i] <= 70
            sprite.x -= 1
            sprite.y += 2
          elsif @info[i] >= 71 and @info[i] <= 81
            sprite.x -= 3
            sprite.y += 1
          elsif @info[i] >= 82 and @info[i] <= 87
            sprite.x -= 5
          end
          @info[i] = (@info[i] + 1) % 88
        else
          if rand(200) == 0
            @info[i] = 1
          end
          sprite.x -= 5
          sprite.y += 1
        end
      end
      
      x = sprite.x - @ox
      y = sprite.y - @oy
      if sprite.opacity < 64 or x < -50 or x > 750 or y < -300 or y > 500
        sprite.x = rand(800) - 50 + @ox
        sprite.y = rand(800) - 200 + @oy
        sprite.opacity = 255
      end
    end
  end
#-------------------------------------------------------------------------------  
  def make_bitmaps
    color1 = Color.new(255, 255, 255, 255)
    color2 = Color.new(255, 255, 255, 128)
    @rain_bitmap = Bitmap.new(7, 56)
    for i in 0..6
      @rain_bitmap.fill_rect(6-i, i*8, 1, 8, color1)
    end
    @rain_splash = Bitmap.new(8, 5)
    @rain_splash.fill_rect(1, 0, 6, 1, color2)
    @rain_splash.fill_rect(1, 4, 6, 1, color2)
    @rain_splash.fill_rect(0, 1, 1, 3, color2)
    @rain_splash.fill_rect(7, 1, 1, 3, color2)
    @rain_splash.set_pixel(1, 0, color1)
    @rain_splash.set_pixel(0, 1, color1)
#-------------------------------------------------------------------------------    
    @storm_bitmap = Bitmap.new(34, 64)
    for i in 0..31
      @storm_bitmap.fill_rect(33-i, i*2, 1, 2, color2)
      @storm_bitmap.fill_rect(32-i, i*2, 1, 2, color1)
      @storm_bitmap.fill_rect(31-i, i*2, 1, 2, color2)
    end
#-------------------------------------------------------------------------------    
    @snow_bitmap = Bitmap.new(6, 6)
    @snow_bitmap.fill_rect(0, 1, 6, 4, color2)
    @snow_bitmap.fill_rect(1, 0, 4, 6, color2)
    @snow_bitmap.fill_rect(1, 2, 4, 2, color1)
    @snow_bitmap.fill_rect(2, 1, 2, 4, color1)
    @sprites = []   
    @snow_bitmaps = []
    
    color3 = Color.new(255, 255, 255, 204)
    @snow_bitmaps[0] = Bitmap.new(3, 3)
    @snow_bitmaps[0].fill_rect(0, 0, 3, 3, color2)
    @snow_bitmaps[0].fill_rect(0, 1, 3, 1, color3)
    @snow_bitmaps[0].fill_rect(1, 0, 1, 3, color3)
    @snow_bitmaps[0].set_pixel(1, 1, color1)
    
    @snow_bitmaps[1] = Bitmap.new(4, 4)
    @snow_bitmaps[1].fill_rect(0, 1, 4, 2, color2)
    @snow_bitmaps[1].fill_rect(1, 0, 2, 4, color2)
    @snow_bitmaps[1].fill_rect(1, 1, 2, 2, color1)
    
    @snow_bitmaps[2] = Bitmap.new(5, 5)
    @snow_bitmaps[1].fill_rect(0, 1, 5, 3, color3)
    @snow_bitmaps[1].fill_rect(1, 0, 3, 5, color3)
    @snow_bitmaps[1].fill_rect(1, 1, 3, 3, color2)
    @snow_bitmaps[1].fill_rect(2, 1, 3, 1, color1)
    @snow_bitmaps[1].fill_rect(1, 2, 1, 3, color1)
    
    @snow_bitmaps[3] = Bitmap.new(7, 7)
    @snow_bitmaps[1].fill_rect(1, 1, 5, 5, color3)
    @snow_bitmaps[1].fill_rect(2, 0, 7, 3, color3)
    @snow_bitmaps[1].fill_rect(0, 2, 3, 7, color3)
    @snow_bitmaps[1].fill_rect(2, 1, 5, 3, color2)
    @snow_bitmaps[1].fill_rect(1, 2, 3, 5, color2)
    @snow_bitmaps[1].fill_rect(2, 2, 3, 3, color1)
    @snow_bitmaps[1].fill_rect(3, 1, 5, 1, color1)
    @snow_bitmaps[1].fill_rect(1, 3, 1, 5, color1)
#-------------------------------------------------------------------------------    
    
    blueGrey  = Color.new(215, 227, 227, 150)
    grey      = Color.new(214, 217, 217, 150)
    lightGrey = Color.new(233, 233, 233, 250)
    lightBlue = Color.new(222, 239, 243, 250)
    
    @hail_bitmap = Bitmap.new(4, 4)
    @hail_bitmap.fill_rect(1, 0, 2, 1, blueGrey)
    @hail_bitmap.fill_rect(0, 1, 1, 2, blueGrey)
    @hail_bitmap.fill_rect(3, 1, 1, 2, grey)
    @hail_bitmap.fill_rect(1, 3, 2, 1, grey)
    @hail_bitmap.fill_rect(1, 1, 2, 2, lightGrey)
    @hail_bitmap.set_pixel(1, 1, lightBlue)
    
#-------------------------------------------------------------------------------    
 
    color3 = Color.new(255, 167, 192, 255)
    color4 = Color.new(213, 106, 136, 255)
    @petal_bitmap = Bitmap.new(4, 4)
    @petal_bitmap.fill_rect(0, 3, 1, 1, color3)
    @petal_bitmap.fill_rect(1, 2, 1, 1, color3)
    @petal_bitmap.fill_rect(2, 1, 1, 1, color3)
    @petal_bitmap.fill_rect(3, 0, 1, 1, color3)
    @petal_bitmap.fill_rect(1, 3, 1, 1, color4)
    @petal_bitmap.fill_rect(2, 2, 1, 1, color4)
    @petal_bitmap.fill_rect(3, 1, 1, 1, color4)
    
#-------------------------------------------------------------------------------    
    
    brightOrange = Color.new(248, 88, 0, 255)  
    orangeBrown  = Color.new(144, 80, 56, 255)
    burntRed     = Color.new(152, 0, 0, 255)
    paleOrange   = Color.new(232, 160, 128, 255)
    darkBrown    = Color.new(72, 40, 0, 255)
    
    @autumn_leaf_bitmaps = []
    
    @autumn_leaf_bitmaps.push(Bitmap.new(8, 8))
    @autumn_leaf_bitmaps[0].set_pixel(5, 1, orangeBrown)
    @autumn_leaf_bitmaps[0].set_pixel(6, 1, brightOrange)
    @autumn_leaf_bitmaps[0].set_pixel(7, 1, paleOrange)
    @autumn_leaf_bitmaps[0].set_pixel(3, 2, orangeBrown)
    @autumn_leaf_bitmaps[0].fill_rect(4, 2, 2, 1, brightOrange)
    @autumn_leaf_bitmaps[0].set_pixel(6, 2, paleOrange)
    @autumn_leaf_bitmaps[0].set_pixel(2, 3, orangeBrown)
    @autumn_leaf_bitmaps[0].set_pixel(3, 3, brightOrange)
    @autumn_leaf_bitmaps[0].fill_rect(4, 3, 2, 1, paleOrange)
    @autumn_leaf_bitmaps[0].set_pixel(1, 4, orangeBrown)
    @autumn_leaf_bitmaps[0].set_pixel(2, 4, brightOrange)
    @autumn_leaf_bitmaps[0].set_pixel(3, 4, paleOrange)
    @autumn_leaf_bitmaps[0].set_pixel(1, 5, brightOrange)
    @autumn_leaf_bitmaps[0].set_pixel(2, 5, paleOrange)
    @autumn_leaf_bitmaps[0].set_pixel(0, 6, orangeBrown)
    @autumn_leaf_bitmaps[0].set_pixel(1, 6, paleOrange)
    @autumn_leaf_bitmaps[0].set_pixel(0, 7, paleOrange)
    
    @autumn_leaf_bitmaps.push(Bitmap.new(8, 8))
    @autumn_leaf_bitmaps[1].set_pixel(3, 0, brightOrange)
    @autumn_leaf_bitmaps[1].set_pixel(7, 0, brightOrange)
    @autumn_leaf_bitmaps[1].set_pixel(3, 1, orangeBrown)
    @autumn_leaf_bitmaps[1].set_pixel(4, 1, burntRed)
    @autumn_leaf_bitmaps[1].set_pixel(6, 1, brightOrange)
    @autumn_leaf_bitmaps[1].set_pixel(0, 2, paleOrange)
    @autumn_leaf_bitmaps[1].set_pixel(1, 2, brightOrange)
    @autumn_leaf_bitmaps[1].set_pixel(2, 2, orangeBrown)
    @autumn_leaf_bitmaps[1].set_pixel(3, 2, burntRed)
    @autumn_leaf_bitmaps[1].set_pixel(4, 2, orangeBrown)
    @autumn_leaf_bitmaps[1].set_pixel(5, 2, brightOrange)
    @autumn_leaf_bitmaps[1].fill_rect(1, 3, 3, 1, orangeBrown)
    @autumn_leaf_bitmaps[1].fill_rect(4, 3, 2, 1, brightOrange)
    @autumn_leaf_bitmaps[1].set_pixel(6, 3, orangeBrown)
    @autumn_leaf_bitmaps[1].set_pixel(2, 4, burntRed)
    @autumn_leaf_bitmaps[1].fill_rect(3, 4, 3, 1, brightOrange)
    @autumn_leaf_bitmaps[1].set_pixel(6, 4, burntRed)
    @autumn_leaf_bitmaps[1].set_pixel(7, 4, darkBrown)
    @autumn_leaf_bitmaps[1].set_pixel(1, 5, orangeBrown)
    @autumn_leaf_bitmaps[1].fill_rect(2, 5, 2, 1, brightOrange)
    @autumn_leaf_bitmaps[1].set_pixel(4, 5, orangeBrown)
    @autumn_leaf_bitmaps[1].set_pixel(5, 5, burntRed)
    @autumn_leaf_bitmaps[1].fill_rect(1, 6, 2, 1, brightOrange)
    @autumn_leaf_bitmaps[1].fill_rect(4, 6, 2, 1, burntRed)
    @autumn_leaf_bitmaps[1].set_pixel(0, 7, brightOrange)
    @autumn_leaf_bitmaps[1].set_pixel(5, 7, darkBrown)
    
    @autumn_leaf_bitmaps.push(Bitmap.new(8, 8))
    @autumn_leaf_bitmaps[2].set_pixel(7, 1, paleOrange)
    @autumn_leaf_bitmaps[2].set_pixel(6, 2, paleOrange)
    @autumn_leaf_bitmaps[2].set_pixel(7, 2, orangeBrown)
    @autumn_leaf_bitmaps[2].set_pixel(5, 3, paleOrange)
    @autumn_leaf_bitmaps[2].set_pixel(6, 3, brightOrange)
    @autumn_leaf_bitmaps[2].set_pixel(4, 4, paleOrange)
    @autumn_leaf_bitmaps[2].set_pixel(5, 4, brightOrange)
    @autumn_leaf_bitmaps[2].set_pixel(6, 4, orangeBrown)
    @autumn_leaf_bitmaps[2].fill_rect(2, 5, 2, 1, paleOrange)
    @autumn_leaf_bitmaps[2].set_pixel(4, 5, brightOrange)
    @autumn_leaf_bitmaps[2].set_pixel(5, 5, orangeBrown)
    @autumn_leaf_bitmaps[2].set_pixel(1, 6, paleOrange)
    @autumn_leaf_bitmaps[2].fill_rect(2, 6, 2, 1, brightOrange)
    @autumn_leaf_bitmaps[2].set_pixel(4, 6, orangeBrown)
    @autumn_leaf_bitmaps[2].set_pixel(0, 7, paleOrange)
    @autumn_leaf_bitmaps[2].set_pixel(1, 7, brightOrange)
    @autumn_leaf_bitmaps[2].set_pixel(2, 7, orangeBrown)
    
    @autumn_leaf_bitmaps.push(Bitmap.new(8, 8))
    @autumn_leaf_bitmaps[3].set_pixel(3, 0, brightOrange)
    @autumn_leaf_bitmaps[3].set_pixel(7, 0, brightOrange)
    @autumn_leaf_bitmaps[3].set_pixel(3, 1, orangeBrown)
    @autumn_leaf_bitmaps[3].set_pixel(4, 1, burntRed)
    @autumn_leaf_bitmaps[3].set_pixel(6, 1, brightOrange)
    @autumn_leaf_bitmaps[3].set_pixel(0, 2, paleOrange)
    @autumn_leaf_bitmaps[3].set_pixel(1, 2, brightOrange)
    @autumn_leaf_bitmaps[3].set_pixel(2, 2, orangeBrown)
    @autumn_leaf_bitmaps[3].set_pixel(3, 2, burntRed)
    @autumn_leaf_bitmaps[3].set_pixel(4, 2, orangeBrown)
    @autumn_leaf_bitmaps[3].set_pixel(5, 2, brightOrange)
    @autumn_leaf_bitmaps[3].fill_rect(1, 3, 3, 1, orangeBrown)
    @autumn_leaf_bitmaps[3].fill_rect(4, 3, 2, 1, brightOrange)
    @autumn_leaf_bitmaps[3].set_pixel(6, 3, orangeBrown)
    @autumn_leaf_bitmaps[3].set_pixel(2, 4, burntRed)
    @autumn_leaf_bitmaps[3].fill_rect(3, 4, 3, 1, brightOrange)
    @autumn_leaf_bitmaps[3].set_pixel(6, 4, burntRed)
    @autumn_leaf_bitmaps[3].set_pixel(7, 4, darkBrown)
    @autumn_leaf_bitmaps[3].set_pixel(1, 5, orangeBrown)
    @autumn_leaf_bitmaps[3].fill_rect(2, 5, 2, 1, brightOrange)
    @autumn_leaf_bitmaps[3].set_pixel(4, 5, orangeBrown)
    @autumn_leaf_bitmaps[3].set_pixel(5, 5, burntRed)
    @autumn_leaf_bitmaps[3].fill_rect(1, 6, 2, 1, brightOrange)
    @autumn_leaf_bitmaps[3].fill_rect(4, 6, 2, 1, burntRed)
    @autumn_leaf_bitmaps[3].set_pixel(0, 7, brightOrange)
    @autumn_leaf_bitmaps[3].set_pixel(5, 7, darkBrown)
    
#-------------------------------------------------------------------------------

    
    @redmaple_leaf_bitmaps = []
    brightRed = Color.new(255, 0, 0, 255)
    midRed    = Color.new(179, 17, 17, 255)
    darkRed   = Color.new(141, 9, 9, 255)
    
    @redmaple_leaf_bitmaps.push(Bitmap.new(8, 8))
    @redmaple_leaf_bitmaps[0].set_pixel(5, 1, darkRed)
    @redmaple_leaf_bitmaps[0].set_pixel(6, 1, brightRed)
    @redmaple_leaf_bitmaps[0].set_pixel(7, 1, midRed)
    @redmaple_leaf_bitmaps[0].set_pixel(3, 2, darkRed)
    @redmaple_leaf_bitmaps[0].fill_rect(4, 2, 2, 1, brightRed)
    @redmaple_leaf_bitmaps[0].set_pixel(6, 2, midRed)
    @redmaple_leaf_bitmaps[0].set_pixel(2, 3, darkRed)
    @redmaple_leaf_bitmaps[0].set_pixel(3, 3, brightRed)
    @redmaple_leaf_bitmaps[0].fill_rect(4, 3, 2, 1, midRed)
    @redmaple_leaf_bitmaps[0].set_pixel(1, 4, brightRed)
    @redmaple_leaf_bitmaps[0].set_pixel(2, 4, brightRed)
    @redmaple_leaf_bitmaps[0].set_pixel(3, 4, midRed)
    @redmaple_leaf_bitmaps[0].set_pixel(1, 5, brightRed)
    @redmaple_leaf_bitmaps[0].set_pixel(2, 5, midRed)
    @redmaple_leaf_bitmaps[0].set_pixel(0, 6, darkRed)
    @redmaple_leaf_bitmaps[0].set_pixel(1, 6, midRed)
    @redmaple_leaf_bitmaps[0].set_pixel(0, 7, midRed)
    
    @redmaple_leaf_bitmaps.push(Bitmap.new(8, 8))
    @redmaple_leaf_bitmaps[1].set_pixel(3, 0, brightRed)
    @redmaple_leaf_bitmaps[1].set_pixel(7, 0, brightRed)
    @redmaple_leaf_bitmaps[1].set_pixel(3, 1, darkRed)
    @redmaple_leaf_bitmaps[1].set_pixel(4, 1, burntRed)
    @redmaple_leaf_bitmaps[1].set_pixel(6, 1, brightRed)
    @redmaple_leaf_bitmaps[1].set_pixel(0, 2, midRed)
    @redmaple_leaf_bitmaps[1].set_pixel(1, 2, brightRed)
    @redmaple_leaf_bitmaps[1].set_pixel(2, 2, darkRed)
    @redmaple_leaf_bitmaps[1].set_pixel(3, 2, burntRed)
    @redmaple_leaf_bitmaps[1].set_pixel(4, 2, darkRed)
    @redmaple_leaf_bitmaps[1].set_pixel(5, 2, brightRed)
    @redmaple_leaf_bitmaps[1].fill_rect(1, 3, 3, 1, darkRed)
    @redmaple_leaf_bitmaps[1].fill_rect(4, 3, 2, 1, brightRed)
    @redmaple_leaf_bitmaps[1].set_pixel(6, 3, darkRed)
    @redmaple_leaf_bitmaps[1].set_pixel(2, 4, burntRed)
    @redmaple_leaf_bitmaps[1].fill_rect(3, 4, 3, 1, brightRed)
    @redmaple_leaf_bitmaps[1].set_pixel(6, 4, burntRed)
    @redmaple_leaf_bitmaps[1].set_pixel(7, 4, darkRed)
    @redmaple_leaf_bitmaps[1].set_pixel(1, 5, darkRed)
    @redmaple_leaf_bitmaps[1].fill_rect(2, 5, 2, 1, brightRed)
    @redmaple_leaf_bitmaps[1].set_pixel(4, 5, darkRed)
    @redmaple_leaf_bitmaps[1].set_pixel(5, 5, burntRed)
    @redmaple_leaf_bitmaps[1].fill_rect(1, 6, 2, 1, brightRed)
    @redmaple_leaf_bitmaps[1].fill_rect(4, 6, 2, 1, burntRed)
    @redmaple_leaf_bitmaps[1].set_pixel(0, 7, brightRed)
    @autumn_leaf_bitmaps[1].set_pixel(5, 7, darkRed)
    
    @redmaple_leaf_bitmaps.push(Bitmap.new(8, 8))
    @redmaple_leaf_bitmaps[2].set_pixel(7, 1, midRed)
    @redmaple_leaf_bitmaps[2].set_pixel(6, 2, midRed)
    @redmaple_leaf_bitmaps[2].set_pixel(7, 2, darkRed)
    @redmaple_leaf_bitmaps[2].set_pixel(5, 3, midRed)
    @redmaple_leaf_bitmaps[2].set_pixel(6, 3, brightRed)
    @redmaple_leaf_bitmaps[2].set_pixel(4, 4, midRed)
    @redmaple_leaf_bitmaps[2].set_pixel(5, 4, brightRed)
    @redmaple_leaf_bitmaps[2].set_pixel(6, 4, darkRed)
    @redmaple_leaf_bitmaps[2].fill_rect(2, 5, 2, 1, midRed)
    @redmaple_leaf_bitmaps[2].set_pixel(4, 5, brightRed)
    @redmaple_leaf_bitmaps[2].set_pixel(5, 5, darkRed)
    @redmaple_leaf_bitmaps[2].set_pixel(1, 6, midRed)
    @redmaple_leaf_bitmaps[2].fill_rect(2, 6, 2, 1, brightRed)
    @redmaple_leaf_bitmaps[2].set_pixel(4, 6, darkRed)
    @redmaple_leaf_bitmaps[2].set_pixel(0, 7, midRed)
    @redmaple_leaf_bitmaps[2].set_pixel(1, 7, brightRed)
    @redmaple_leaf_bitmaps[2].set_pixel(2, 7, darkRed)
    
    @redmaple_leaf_bitmaps.push(Bitmap.new(8, 8))
    @redmaple_leaf_bitmaps[3].set_pixel(3, 0, brightRed)
    @redmaple_leaf_bitmaps[3].set_pixel(7, 0, brightRed)
    @redmaple_leaf_bitmaps[3].set_pixel(3, 1, darkRed)
    @redmaple_leaf_bitmaps[3].set_pixel(4, 1, burntRed)
    @redmaple_leaf_bitmaps[3].set_pixel(6, 1, brightRed)
    @redmaple_leaf_bitmaps[3].set_pixel(0, 2, midRed)
    @redmaple_leaf_bitmaps[3].set_pixel(1, 2, brightRed)
    @redmaple_leaf_bitmaps[3].set_pixel(2, 2, darkRed)
    @redmaple_leaf_bitmaps[3].set_pixel(3, 2, burntRed)
    @redmaple_leaf_bitmaps[3].set_pixel(4, 2, darkRed)
    @redmaple_leaf_bitmaps[3].set_pixel(5, 2, brightRed)
    @redmaple_leaf_bitmaps[3].fill_rect(1, 3, 3, 1, darkRed)
    @redmaple_leaf_bitmaps[3].fill_rect(4, 3, 2, 1, brightRed)
    @redmaple_leaf_bitmaps[3].set_pixel(6, 3, darkRed)
    @redmaple_leaf_bitmaps[3].set_pixel(2, 4, burntRed)
    @redmaple_leaf_bitmaps[3].fill_rect(3, 4, 3, 1, brightRed)
    @redmaple_leaf_bitmaps[3].set_pixel(6, 4, burntRed)
    @redmaple_leaf_bitmaps[3].set_pixel(7, 4, darkRed)
    @redmaple_leaf_bitmaps[3].set_pixel(1, 5, darkRed)
    @redmaple_leaf_bitmaps[3].fill_rect(2, 5, 2, 1, brightRed)
    @redmaple_leaf_bitmaps[3].set_pixel(4, 5, darkRed)
    @redmaple_leaf_bitmaps[3].set_pixel(5, 5, burntRed)
    @redmaple_leaf_bitmaps[3].fill_rect(1, 6, 2, 1, brightRed)
    @redmaple_leaf_bitmaps[3].fill_rect(4, 6, 2, 1, burntRed)
    @redmaple_leaf_bitmaps[3].set_pixel(0, 7, brightRed)
    @redmaple_leaf_bitmaps[3].set_pixel(5, 7, darkRed)
#-------------------------------------------------------------------------------    

    @green_leaf_bitmaps = []
    darkGreen  = Color.new(62, 76, 31, 255)
    midGreen   = Color.new(76, 91, 43, 255)
    khaki      = Color.new(105, 114, 66, 255)
    lightGreen = Color.new(128, 136, 88, 255)
    mint       = Color.new(146, 154, 106, 255)
    
    @green_leaf_bitmaps[0] = Bitmap.new(8, 8)
    @green_leaf_bitmaps[0].set_pixel(1, 0, darkGreen)
    @green_leaf_bitmaps[0].set_pixel(1, 1, midGreen)
    @green_leaf_bitmaps[0].set_pixel(2, 1, darkGreen)
    @green_leaf_bitmaps[0].set_pixel(2, 2, khaki)
    @green_leaf_bitmaps[0].set_pixel(3, 2, darkGreen)
    @green_leaf_bitmaps[0].set_pixel(4, 2, khaki)
    @green_leaf_bitmaps[0].fill_rect(2, 3, 3, 1, midGreen)
    @green_leaf_bitmaps[0].set_pixel(5, 3, khaki)
    @green_leaf_bitmaps[0].fill_rect(2, 4, 2, 1, midGreen)
    @green_leaf_bitmaps[0].set_pixel(4, 4, darkGreen)
    @green_leaf_bitmaps[0].set_pixel(5, 4, lightGreen)
    @green_leaf_bitmaps[0].set_pixel(6, 4, khaki)
    @green_leaf_bitmaps[0].set_pixel(3, 5, midGreen)
    @green_leaf_bitmaps[0].set_pixel(4, 5, darkGreen)
    @green_leaf_bitmaps[0].set_pixel(5, 5, khaki)
    @green_leaf_bitmaps[0].set_pixel(6, 5, lightGreen)
    @green_leaf_bitmaps[0].set_pixel(4, 6, midGreen)
    @green_leaf_bitmaps[0].set_pixel(5, 6, darkGreen)
    @green_leaf_bitmaps[0].set_pixel(6, 6, lightGreen)
    @green_leaf_bitmaps[0].set_pixel(6, 7, khaki)
    
    @green_leaf_bitmaps[1] = Bitmap.new(8, 8)
    @green_leaf_bitmaps[1].fill_rect(1, 1, 1, 2, midGreen)
    @green_leaf_bitmaps[1].fill_rect(2, 2, 2, 1, khaki)
    @green_leaf_bitmaps[1].set_pixel(4, 2, lightGreen)
    @green_leaf_bitmaps[1].fill_rect(2, 3, 2, 1, darkGreen)
    @green_leaf_bitmaps[1].fill_rect(4, 3, 2, 1, lightGreen)
    @green_leaf_bitmaps[1].set_pixel(2, 4, midGreen)
    @green_leaf_bitmaps[1].set_pixel(3, 4, darkGreen)
    @green_leaf_bitmaps[1].set_pixel(4, 4, khaki)
    @green_leaf_bitmaps[1].fill_rect(5, 4, 2, 1, lightGreen)
    @green_leaf_bitmaps[1].set_pixel(3, 5, midGreen)
    @green_leaf_bitmaps[1].set_pixel(4, 5, darkGreen)
    @green_leaf_bitmaps[1].set_pixel(5, 5, khaki)
    @green_leaf_bitmaps[1].set_pixel(6, 5, lightGreen)
    @green_leaf_bitmaps[1].set_pixel(5, 6, darkGreen)
    @green_leaf_bitmaps[1].fill_rect(6, 6, 2, 1, khaki)
    
    @green_leaf_bitmaps[2] = Bitmap.new(8, 8)
    @green_leaf_bitmaps[2].set_pixel(1, 1, darkGreen)
    @green_leaf_bitmaps[2].fill_rect(1, 2, 2, 1, midGreen)
    @green_leaf_bitmaps[2].set_pixel(2, 3, midGreen)
    @green_leaf_bitmaps[2].set_pixel(3, 3, darkGreen)
    @green_leaf_bitmaps[2].set_pixel(4, 3, midGreen)
    @green_leaf_bitmaps[2].fill_rect(2, 4, 2, 1, midGreen)
    @green_leaf_bitmaps[2].set_pixel(4, 4, darkGreen)
    @green_leaf_bitmaps[2].set_pixel(5, 4, lightGreen)
    @green_leaf_bitmaps[2].set_pixel(3, 5, midGreen)
    @green_leaf_bitmaps[2].set_pixel(4, 5, darkGreen)
    @green_leaf_bitmaps[2].fill_rect(5, 5, 2, 1, khaki)
    @green_leaf_bitmaps[2].fill_rect(4, 6, 2, 1, midGreen)
    @green_leaf_bitmaps[2].set_pixel(6, 6, lightGreen)
    @green_leaf_bitmaps[2].set_pixel(6, 7, khaki)
    
    @green_leaf_bitmaps[3] = Bitmap.new(8, 8)
    @green_leaf_bitmaps[3].fill_rect(0, 3, 1, 2, darkGreen)
    @green_leaf_bitmaps[3].set_pixel(1, 4, midGreen)
    @green_leaf_bitmaps[3].set_pixel(2, 4, khaki)
    @green_leaf_bitmaps[3].set_pixel(3, 4, lightGreen)
    @green_leaf_bitmaps[3].set_pixel(4, 4, darkGreen)
    @green_leaf_bitmaps[3].set_pixel(7, 4, midGreen)
    @green_leaf_bitmaps[3].set_pixel(1, 5, darkGreen)
    @green_leaf_bitmaps[3].set_pixel(2, 5, midGreen)
    @green_leaf_bitmaps[3].set_pixel(3, 5, lightGreen)
    @green_leaf_bitmaps[3].set_pixel(4, 5, mint)
    @green_leaf_bitmaps[3].set_pixel(5, 5, lightGreen)
    @green_leaf_bitmaps[3].set_pixel(6, 5, khaki)
    @green_leaf_bitmaps[3].set_pixel(7, 5, midGreen)
    @green_leaf_bitmaps[3].fill_rect(2, 6, 2, 1, midGreen)
    @green_leaf_bitmaps[3].set_pixel(4, 6, lightGreen)
    @green_leaf_bitmaps[3].set_pixel(5, 6, khaki)
    @green_leaf_bitmaps[3].set_pixel(6, 6, midGreen)
    
    @green_leaf_bitmaps[4] = Bitmap.new(8, 8)
    @green_leaf_bitmaps[4].set_pixel(6, 2, midGreen)
    @green_leaf_bitmaps[4].set_pixel(7, 2, darkGreen)
    @green_leaf_bitmaps[4].fill_rect(4, 3, 2, 1, midGreen)
    @green_leaf_bitmaps[4].set_pixel(6, 3, khaki)
    @green_leaf_bitmaps[4].set_pixel(2, 4, darkGreen)
    @green_leaf_bitmaps[4].fill_rect(3, 4, 2, 1, khaki)
    @green_leaf_bitmaps[4].set_pixel(5, 4, lightGreen)
    @green_leaf_bitmaps[4].set_pixel(6, 4, khaki)
    @green_leaf_bitmaps[4].set_pixel(1, 5, midGreen)
    @green_leaf_bitmaps[4].set_pixel(2, 5, khaki)
    @green_leaf_bitmaps[4].set_pixel(3, 5, lightGreen)
    @green_leaf_bitmaps[4].set_pixel(4, 5, mint)
    @green_leaf_bitmaps[4].set_pixel(5, 5, midGreen)
    @green_leaf_bitmaps[4].set_pixel(2, 6, darkGreen)
    @green_leaf_bitmaps[4].fill_rect(3, 6, 2, 1, midGreen)
    
    @green_leaf_bitmaps[5] = Bitmap.new(8, 8)
    @green_leaf_bitmaps[5].fill_rect(6, 2, 2, 1, midGreen)
    @green_leaf_bitmaps[5].fill_rect(4, 3, 2, 1, midGreen)
    @green_leaf_bitmaps[5].set_pixel(6, 3, khaki)
    @green_leaf_bitmaps[5].set_pixel(3, 4, midGreen)
    @green_leaf_bitmaps[5].set_pixel(4, 4, khaki)
    @green_leaf_bitmaps[5].set_pixel(5, 4, lightGreen)
    @green_leaf_bitmaps[5].set_pixel(6, 4, mint)
    @green_leaf_bitmaps[5].set_pixel(1, 5, midGreen)
    @green_leaf_bitmaps[5].set_pixel(2, 5, khaki)
    @green_leaf_bitmaps[5].fill_rect(3, 5, 2, 1, mint)
    @green_leaf_bitmaps[5].set_pixel(5, 5, lightGreen)
    @green_leaf_bitmaps[5].set_pixel(2, 6, midGreen)
    @green_leaf_bitmaps[5].set_pixel(3, 6, khaki)
    @green_leaf_bitmaps[5].set_pixel(4, 6, lightGreen)
    
    @green_leaf_bitmaps[6] = Bitmap.new(8, 8)
    @green_leaf_bitmaps[6].fill_rect(6, 1, 1, 2, midGreen)
    @green_leaf_bitmaps[6].fill_rect(4, 2, 2, 1, midGreen)
    @green_leaf_bitmaps[6].fill_rect(6, 2, 1, 2, darkGreen)
    @green_leaf_bitmaps[6].fill_rect(3, 3, 2, 1, midGreen)
    @green_leaf_bitmaps[6].set_pixel(5, 3, khaki)
    @green_leaf_bitmaps[6].set_pixel(2, 4, midGreen)
    @green_leaf_bitmaps[6].set_pixel(3, 4, khaki)
    @green_leaf_bitmaps[6].set_pixel(4, 4, lightGreen)
    @green_leaf_bitmaps[6].set_pixel(5, 4, midGreen)
    @green_leaf_bitmaps[6].set_pixel(1, 5, midGreen)
    @green_leaf_bitmaps[6].set_pixel(2, 5, khaki)
    @green_leaf_bitmaps[6].fill_rect(3, 5, 2, 1, midGreen)
    @green_leaf_bitmaps[6].set_pixel(1, 6, darkGreen)
    @green_leaf_bitmaps[6].set_pixel(2, 6, midGreen)
    
    @green_leaf_bitmaps[7] = Bitmap.new(8, 8)
    @green_leaf_bitmaps[7].set_pixel(6, 1, midGreen)
    @green_leaf_bitmaps[7].fill_rect(4, 2, 3, 2, midGreen)
    @green_leaf_bitmaps[7].set_pixel(3, 3, darkGreen)
    @green_leaf_bitmaps[7].set_pixel(2, 4, darkGreen)
    @green_leaf_bitmaps[7].set_pixel(3, 4, midGreen)
    @green_leaf_bitmaps[7].fill_rect(4, 4, 2, 1, khaki)
    @green_leaf_bitmaps[7].set_pixel(1, 5, darkGreen)
    @green_leaf_bitmaps[7].set_pixel(2, 5, midGreen)
    @green_leaf_bitmaps[7].fill_rect(3, 5, 2, 1, lightGreen)
    @green_leaf_bitmaps[7].set_pixel(2, 6, midGreen)
    @green_leaf_bitmaps[7].set_pixel(3, 6, lightGreen)
    
    @green_leaf_bitmaps[8] = Bitmap.new(8, 8)
    @green_leaf_bitmaps[8].fill_rect(6, 1, 1, 2, midGreen)
    @green_leaf_bitmaps[8].fill_rect(4, 2, 2, 1, midGreen)
    @green_leaf_bitmaps[8].fill_rect(6, 2, 1, 2, darkGreen)
    @green_leaf_bitmaps[8].fill_rect(3, 3, 2, 1, midGreen)
    @green_leaf_bitmaps[8].set_pixel(5, 3, khaki)
    @green_leaf_bitmaps[8].set_pixel(2, 4, midGreen)
    @green_leaf_bitmaps[8].set_pixel(3, 4, khaki)
    @green_leaf_bitmaps[8].set_pixel(4, 4, lightGreen)
    @green_leaf_bitmaps[8].set_pixel(5, 4, midGreen)
    @green_leaf_bitmaps[8].set_pixel(1, 5, midGreen)
    @green_leaf_bitmaps[8].set_pixel(2, 5, khaki)
    @green_leaf_bitmaps[8].fill_rect(3, 5, 2, 1, midGreen)
    @green_leaf_bitmaps[8].set_pixel(1, 6, darkGreen)
    @green_leaf_bitmaps[8].set_pixel(2, 6, midGreen)
    
    @green_leaf_bitmaps[9] = Bitmap.new(8, 8)
    @green_leaf_bitmaps[9].fill_rect(6, 2, 2, 1, midGreen)
    @green_leaf_bitmaps[9].fill_rect(4, 3, 2, 1, midGreen)
    @green_leaf_bitmaps[9].set_pixel(6, 3, khaki)
    @green_leaf_bitmaps[9].set_pixel(3, 4, midGreen)
    @green_leaf_bitmaps[9].set_pixel(4, 4, khaki)
    @green_leaf_bitmaps[9].set_pixel(5, 4, lightGreen)
    @green_leaf_bitmaps[9].set_pixel(6, 4, mint)
    @green_leaf_bitmaps[9].set_pixel(1, 5, midGreen)
    @green_leaf_bitmaps[9].set_pixel(2, 5, khaki)
    @green_leaf_bitmaps[9].fill_rect(3, 5, 2, 1, mint)
    @green_leaf_bitmaps[9].set_pixel(5, 5, lightGreen)
    @green_leaf_bitmaps[9].set_pixel(2, 6, midGreen)
    @green_leaf_bitmaps[9].set_pixel(3, 6, khaki)
    @green_leaf_bitmaps[9].set_pixel(4, 6, lightGreen)
    
    @green_leaf_bitmaps[10] = Bitmap.new(8, 8)
    @green_leaf_bitmaps[10].set_pixel(6, 2, midGreen)
    @green_leaf_bitmaps[10].set_pixel(7, 2, darkGreen)
    @green_leaf_bitmaps[10].fill_rect(4, 3, 2, 1, midGreen)
    @green_leaf_bitmaps[10].set_pixel(6, 3, khaki)
    @green_leaf_bitmaps[10].set_pixel(2, 4, darkGreen)
    @green_leaf_bitmaps[10].fill_rect(3, 4, 2, 1, khaki)
    @green_leaf_bitmaps[10].set_pixel(5, 4, lightGreen)
    @green_leaf_bitmaps[10].set_pixel(6, 4, khaki)
    @green_leaf_bitmaps[10].set_pixel(1, 5, midGreen)
    @green_leaf_bitmaps[10].set_pixel(2, 5, khaki)
    @green_leaf_bitmaps[10].set_pixel(3, 5, lightGreen)
    @green_leaf_bitmaps[10].set_pixel(4, 5, mint)
    @green_leaf_bitmaps[10].set_pixel(5, 5, midGreen)
    @green_leaf_bitmaps[10].set_pixel(2, 6, darkGreen)
    @green_leaf_bitmaps[10].fill_rect(3, 6, 2, 1, midGreen)
    
    @green_leaf_bitmaps[11] = Bitmap.new(8, 8)
    @green_leaf_bitmaps[11].fill_rect(0, 3, 1, 2, darkGreen)
    @green_leaf_bitmaps[11].set_pixel(1, 4, midGreen)
    @green_leaf_bitmaps[11].set_pixel(2, 4, khaki)
    @green_leaf_bitmaps[11].set_pixel(3, 4, lightGreen)
    @green_leaf_bitmaps[11].set_pixel(4, 4, darkGreen)
    @green_leaf_bitmaps[11].set_pixel(7, 4, midGreen)
    @green_leaf_bitmaps[11].set_pixel(1, 5, darkGreen)
    @green_leaf_bitmaps[11].set_pixel(2, 5, midGreen)
    @green_leaf_bitmaps[11].set_pixel(3, 5, lightGreen)
    @green_leaf_bitmaps[11].set_pixel(4, 5, mint)
    @green_leaf_bitmaps[11].set_pixel(5, 5, lightGreen)
    @green_leaf_bitmaps[11].set_pixel(6, 5, khaki)
    @green_leaf_bitmaps[11].set_pixel(7, 5, midGreen)
    @green_leaf_bitmaps[11].fill_rect(2, 6, 2, 1, midGreen)
    @green_leaf_bitmaps[11].set_pixel(4, 6, lightGreen)
    @green_leaf_bitmaps[11].set_pixel(5, 6, khaki)
    @green_leaf_bitmaps[11].set_pixel(6, 6, midGreen)
    
    @green_leaf_bitmaps[12] = Bitmap.new(8, 8)
    @green_leaf_bitmaps[12].set_pixel(1, 1, darkGreen)
    @green_leaf_bitmaps[12].fill_rect(1, 2, 2, 1, midGreen)
    @green_leaf_bitmaps[12].set_pixel(2, 3, midGreen)
    @green_leaf_bitmaps[12].set_pixel(3, 3, darkGreen)
    @green_leaf_bitmaps[12].set_pixel(4, 3, midGreen)
    @green_leaf_bitmaps[12].fill_rect(2, 4, 2, 1, midGreen)
    @green_leaf_bitmaps[12].set_pixel(4, 4, darkGreen)
    @green_leaf_bitmaps[12].set_pixel(5, 4, lightGreen)
    @green_leaf_bitmaps[12].set_pixel(3, 5, midGreen)
    @green_leaf_bitmaps[12].set_pixel(4, 5, darkGreen)
    @green_leaf_bitmaps[12].fill_rect(5, 5, 2, 1, khaki)
    @green_leaf_bitmaps[12].fill_rect(4, 6, 2, 1, midGreen)
    @green_leaf_bitmaps[12].set_pixel(6, 6, lightGreen)
    @green_leaf_bitmaps[12].set_pixel(6, 7, khaki)
#-------------------------------------------------------------------------------    

    @rose_bitmaps = []
    
    @rose_bitmaps[0] = Bitmap.new(3, 3)
    @rose_bitmaps[0].fill_rect(1, 0, 2, 1, brightRed)
    @rose_bitmaps[0].fill_rect(0, 1, 1, 2, brightRed)
    @rose_bitmaps[0].fill_rect(1, 1, 2, 2, midRed)
    @rose_bitmaps[0].set_pixel(2, 2, darkRed)
    
    @rose_bitmaps[1] = Bitmap.new(3, 3)
    @rose_bitmaps[1].set_pixel(0, 1, midRed)
    @rose_bitmaps[1].set_pixel(1, 1, brightRed)
    @rose_bitmaps[1].fill_rect(1, 2, 1, 2, midRed)
#-------------------------------------------------------------------------------    

    @feather_bitmaps = []
    white = Color.new(255, 255, 255, 255)
    
    @feather_bitmaps[0] = Bitmap.new(3, 3)
    @feather_bitmaps[0].set_pixel(0, 2, white)
    @feather_bitmaps[0].set_pixel(1, 2, grey)
    @feather_bitmaps[0].set_pixel(2, 1, grey)
    
    @feather_bitmaps[0] = Bitmap.new(3, 3)
    @feather_bitmaps[0].set_pixel(0, 0, white)
    @feather_bitmaps[0].set_pixel(0, 1, grey)
    @feather_bitmaps[0].set_pixel(1, 2, grey)
    
    @feather_bitmaps[0] = Bitmap.new(3, 3)
    @feather_bitmaps[0].set_pixel(2, 0, white)
    @feather_bitmaps[0].set_pixel(1, 0, grey)
    @feather_bitmaps[0].set_pixel(0, 1, grey)
    
    @feather_bitmaps[0] = Bitmap.new(3, 3)
    @feather_bitmaps[0].set_pixel(2, 2, white)
    @feather_bitmaps[0].set_pixel(2, 1, grey)
    @feather_bitmaps[0].set_pixel(1, 0, grey)
#-------------------------------------------------------------------------------    
    
    @blood_rain_bitmap = Bitmap.new(7, 56)
    for i in 0..6
      @blood_rain_bitmap.fill_rect(6-i, i*8, 1, 8, darkRed)
    end
    @blood_rain_splash = Bitmap.new(8, 5)
    @blood_rain_splash.fill_rect(1, 0, 6, 1, darkRed)
    @blood_rain_splash.fill_rect(1, 4, 6, 1, darkRed)
    @blood_rain_splash.fill_rect(0, 1, 1, 3, darkRed)
    @blood_rain_splash.fill_rect(7, 1, 1, 3, darkRed)
#-------------------------------------------------------------------------------

    
    @blood_storm_bitmap = Bitmap.new(34, 64)
    for i in 0..31
      @blood_storm_bitmap.fill_rect(33-i, i*2, 1, 2, darkRed)
      @blood_storm_bitmap.fill_rect(32-i, i*2, 1, 2, darkRed)
      @blood_storm_bitmap.fill_rect(31-i, i*2, 1, 2, darkRed)
    end
    
#------------------------------------------------------------------------------- 

    @bloodblizz_bitmap = Bitmap.new(6, 6)
    @bloodblizz_bitmap.fill_rect(0, 1, 6, 4, midRed)
    @bloodblizz_bitmap.fill_rect(1, 0, 4, 6, midRed)
    @bloodblizz_bitmap.fill_rect(1, 2, 4, 2, darkRed)
    @bloodblizz_bitmap.fill_rect(2, 1, 2, 4, darkRed)
    @sprites = []   
    @bloodblizz_bitmaps = []
    
    @bloodblizz_bitmaps[0] = Bitmap.new(3, 3)
    @bloodblizz_bitmaps[0].fill_rect(0, 0, 3, 3, midRed)
    @bloodblizz_bitmaps[0].fill_rect(0, 1, 3, 1, darkRed)
    @bloodblizz_bitmaps[0].fill_rect(1, 0, 1, 3, darkRed)
    @bloodblizz_bitmaps[0].set_pixel(1, 1, darkRed)
    
    @bloodblizz_bitmaps[1] = Bitmap.new(4, 4)
    @bloodblizz_bitmaps[1].fill_rect(0, 1, 4, 2, midRed)
    @bloodblizz_bitmaps[1].fill_rect(1, 0, 2, 4, midRed)
    @bloodblizz_bitmaps[1].fill_rect(1, 1, 2, 2, darkRed)
    
    @bloodblizz_bitmaps[2] = Bitmap.new(5, 5)
    @bloodblizz_bitmaps[1].fill_rect(0, 1, 5, 3, darkRed)
    @bloodblizz_bitmaps[1].fill_rect(1, 0, 3, 5, darkRed)
    @bloodblizz_bitmaps[1].fill_rect(1, 1, 3, 3, midRed)
    @bloodblizz_bitmaps[1].fill_rect(2, 1, 3, 1, darkRed)
    @bloodblizz_bitmaps[1].fill_rect(1, 2, 1, 3, darkRed)
    
    @bloodblizz_bitmaps[3] = Bitmap.new(7, 7)
    @bloodblizz_bitmaps[1].fill_rect(1, 1, 5, 5, darkRed)
    @bloodblizz_bitmaps[1].fill_rect(2, 0, 7, 3, darkRed)
    @bloodblizz_bitmaps[1].fill_rect(0, 2, 3, 7, darkRed)
    @bloodblizz_bitmaps[1].fill_rect(2, 1, 5, 3, midRed)
    @bloodblizz_bitmaps[1].fill_rect(1, 2, 3, 5, midRed)
    @bloodblizz_bitmaps[1].fill_rect(2, 2, 3, 3, darkRed)
    @bloodblizz_bitmaps[1].fill_rect(3, 1, 5, 1, darkRed)
    @bloodblizz_bitmaps[1].fill_rect(1, 3, 1, 5, darkRed)
#-------------------------------------------------------------------------------  

    
    darkgrey = Color.new(15, 15, 15, 255)
    black = Color.new(0, 0, 0, 255)
    
    @oil_rain_bitmap = Bitmap.new(7, 56)
    for i in 0..6
    @oil_rain_bitmap.fill_rect(6-i, i*8, 1, 8, darkgrey)
      end
    @oil_rain_splash = Bitmap.new(8, 5)
    @oil_rain_splash.fill_rect(1, 0, 6, 1, darkgrey)
    @oil_rain_splash.fill_rect(1, 4, 6, 1, darkgrey)
    @oil_rain_splash.fill_rect(0, 1, 1, 3, black)
    @oil_rain_splash.fill_rect(7, 1, 1, 3, black)
#-------------------------------------------------------------------------------

    
      @oil_storm_bitmap = Bitmap.new(34, 64)
    for i in 0..31
      @oil_storm_bitmap.fill_rect(33-i, i*2, 1, 2, darkgrey)
      @oil_storm_bitmap.fill_rect(32-i, i*2, 1, 2, darkgrey)
      @oil_storm_bitmap.fill_rect(31-i, i*2, 1, 2, darkgrey)
    end
#------------------------------------------------------------------------------- 

    
    darkYellow  = Color.new(110, 104, 3, 255)
    midYellow   = Color.new(205, 194, 23, 255)
    darkYellowtwo  = Color.new(186, 176, 14, 255)
    lightYellow = Color.new(218, 207, 36, 255)
    lightYellowtwo = Color.new(227, 217, 56, 255)   
    
    @golden_rain_bitmap = Bitmap.new(7, 56)
    for i in 0..6
    @golden_rain_bitmap.fill_rect(6-i, i*8, 1, 8, lightYellow)
      end
    @golden_rain_splash = Bitmap.new(8, 5)
    @golden_rain_splash.fill_rect(1, 0, 6, 1, lightYellow)
    @golden_rain_splash.fill_rect(1, 4, 6, 1, lightYellow)
    @golden_rain_splash.fill_rect(0, 1, 1, 3, lightYellow)
    @golden_rain_splash.fill_rect(7, 1, 1, 3, lightYellow)
#------------------------------------------------------------------------------- 


      @golden_storm_bitmap = Bitmap.new(34, 64)
    for i in 0..31
      @golden_storm_bitmap.fill_rect(33-i, i*2, 1, 2, lightYellow)
      @golden_storm_bitmap.fill_rect(32-i, i*2, 1, 2, lightYellow)
      @golden_storm_bitmap.fill_rect(31-i, i*2, 1, 2, lightYellow)
    end
#-------------------------------------------------------------------------------

          
    @acid_rain_bitmap = Bitmap.new(7, 56)
    for i in 0..6
    @acid_rain_bitmap.fill_rect(6-i, i*8, 1, 8, midGreen)
      end
    @acid_rain_splash = Bitmap.new(8, 5)
    @acid_rain_splash.fill_rect(1, 0, 6, 1, white)
    @acid_rain_splash.fill_rect(1, 4, 6, 1, white)
    @acid_rain_splash.fill_rect(0, 1, 1, 3, white)
    @acid_rain_splash.fill_rect(7, 1, 1, 3, white)
#-------------------------------------------------------------------------------


      @acid_storm_bitmap = Bitmap.new(34, 64)
    for i in 0..31
      @acid_storm_bitmap.fill_rect(33-i, i*2, 1, 2, khaki)
      @acid_storm_bitmap.fill_rect(32-i, i*2, 1, 2, khaki)
      @acid_storm_bitmap.fill_rect(31-i, i*2, 1, 2, midGreen)
    end
#------------------------------------------------------------------------------- 

    
    sepia_color = Color.new(167, 149, 139, 255)
    sepia_colortwo = Color.new(100, 75, 63, 255)
    
    @sepia_rain_bitmap = Bitmap.new(7, 56)
    for i in 0..6
    @sepia_rain_bitmap.fill_rect(6-i, i*8, 1, 8, sepia_colortwo)
      end
    @sepia_rain_splash = Bitmap.new(8, 5)
    @sepia_rain_splash.fill_rect(1, 0, 6, 1, sepia_colortwo)
    @sepia_rain_splash.fill_rect(1, 4, 6, 1, sepia_color)
    @sepia_rain_splash.fill_rect(0, 1, 1, 3, sepia_colortwo)
    @sepia_rain_splash.fill_rect(7, 1, 1, 3, sepia_color)
#-------------------------------------------------------------------------------


      @sepia_storm_bitmap = Bitmap.new(34, 64)
    for i in 0..31
      @sepia_storm_bitmap.fill_rect(33-i, i*2, 1, 2, sepia_colortwo)
      @sepia_storm_bitmap.fill_rect(32-i, i*2, 1, 2, sepia_colortwo)
      @sepia_storm_bitmap.fill_rect(31-i, i*2, 1, 2, sepia_color)
    end
#-------------------------------------------------------------------------------


    @yellow_leaf_bitmaps = []
    
    @yellow_leaf_bitmaps[0] = Bitmap.new(8, 8)
    @yellow_leaf_bitmaps[0].set_pixel(1, 0, darkYellow)
    @yellow_leaf_bitmaps[0].set_pixel(1, 1, midYellow)
    @yellow_leaf_bitmaps[0].set_pixel(2, 1, darkYellow)
    @yellow_leaf_bitmaps[0].set_pixel(2, 2, darkYellowtwo)
    @yellow_leaf_bitmaps[0].set_pixel(3, 2, darkYellow)
    @yellow_leaf_bitmaps[0].set_pixel(4, 2, darkYellowtwo)
    @yellow_leaf_bitmaps[0].fill_rect(2, 3, 3, 1, midYellow)
    @yellow_leaf_bitmaps[0].set_pixel(5, 3, darkYellowtwo)
    @yellow_leaf_bitmaps[0].fill_rect(2, 4, 2, 1, midYellow)
    @yellow_leaf_bitmaps[0].set_pixel(4, 4, darkYellow)
    @yellow_leaf_bitmaps[0].set_pixel(5, 4, lightYellow)
    @yellow_leaf_bitmaps[0].set_pixel(6, 4, darkYellowtwo)
    @yellow_leaf_bitmaps[0].set_pixel(3, 5, midYellow)
    @yellow_leaf_bitmaps[0].set_pixel(4, 5, darkYellow)
    @yellow_leaf_bitmaps[0].set_pixel(5, 5, darkYellowtwo)
    @yellow_leaf_bitmaps[0].set_pixel(6, 5, lightYellow)
    @yellow_leaf_bitmaps[0].set_pixel(4, 6, midYellow)
    @yellow_leaf_bitmaps[0].set_pixel(5, 6, darkYellow)
    @yellow_leaf_bitmaps[0].set_pixel(6, 6, lightYellow)
    @yellow_leaf_bitmaps[0].set_pixel(6, 7, darkYellowtwo)
    
    @yellow_leaf_bitmaps[1] = Bitmap.new(8, 8)
    @yellow_leaf_bitmaps[1].fill_rect(1, 1, 1, 2, midYellow)
    @yellow_leaf_bitmaps[1].fill_rect(2, 2, 2, 1, darkYellowtwo)
    @yellow_leaf_bitmaps[1].set_pixel(4, 2, lightYellow)
    @yellow_leaf_bitmaps[1].fill_rect(2, 3, 2, 1, darkYellow)
    @yellow_leaf_bitmaps[1].fill_rect(4, 3, 2, 1, lightYellow)
    @yellow_leaf_bitmaps[1].set_pixel(2, 4, midYellow)
    @yellow_leaf_bitmaps[1].set_pixel(3, 4, darkYellow)
    @yellow_leaf_bitmaps[1].set_pixel(4, 4, darkYellowtwo)
    @yellow_leaf_bitmaps[1].fill_rect(5, 4, 2, 1, lightYellow)
    @yellow_leaf_bitmaps[1].set_pixel(3, 5, midYellow)
    @yellow_leaf_bitmaps[1].set_pixel(4, 5, darkYellow)
    @yellow_leaf_bitmaps[1].set_pixel(5, 5, darkYellowtwo)
    @yellow_leaf_bitmaps[1].set_pixel(6, 5, lightYellow)
    @yellow_leaf_bitmaps[1].set_pixel(5, 6, darkYellow)
    @yellow_leaf_bitmaps[1].fill_rect(6, 6, 2, 1, darkYellowtwo)
    
    @yellow_leaf_bitmaps[2] = Bitmap.new(8, 8)
    @yellow_leaf_bitmaps[2].set_pixel(1, 1, darkYellow)
    @yellow_leaf_bitmaps[2].fill_rect(1, 2, 2, 1, midYellow)
    @yellow_leaf_bitmaps[2].set_pixel(2, 3, midYellow)
    @yellow_leaf_bitmaps[2].set_pixel(3, 3, darkYellow)
    @yellow_leaf_bitmaps[2].set_pixel(4, 3, midYellow)
    @yellow_leaf_bitmaps[2].fill_rect(2, 4, 2, 1, midYellow)
    @yellow_leaf_bitmaps[2].set_pixel(4, 4, darkYellow)
    @yellow_leaf_bitmaps[2].set_pixel(5, 4, lightYellow)
    @yellow_leaf_bitmaps[2].set_pixel(3, 5, midYellow)
    @yellow_leaf_bitmaps[2].set_pixel(4, 5, darkYellow)
    @yellow_leaf_bitmaps[2].fill_rect(5, 5, 2, 1, darkYellowtwo)
    @yellow_leaf_bitmaps[2].fill_rect(4, 6, 2, 1, midYellow)
    @yellow_leaf_bitmaps[2].set_pixel(6, 6, lightYellow)
    @yellow_leaf_bitmaps[2].set_pixel(6, 7, darkYellowtwo)
    
    @yellow_leaf_bitmaps[3] = Bitmap.new(8, 8)
    @yellow_leaf_bitmaps[3].fill_rect(0, 3, 1, 2, darkYellow)
    @yellow_leaf_bitmaps[3].set_pixel(1, 4, midYellow)
    @yellow_leaf_bitmaps[3].set_pixel(2, 4, darkYellowtwo)
    @yellow_leaf_bitmaps[3].set_pixel(3, 4, lightYellow)
    @yellow_leaf_bitmaps[3].set_pixel(4, 4, darkYellow)
    @yellow_leaf_bitmaps[3].set_pixel(7, 4, midYellow)
    @yellow_leaf_bitmaps[3].set_pixel(1, 5, darkYellow)
    @yellow_leaf_bitmaps[3].set_pixel(2, 5, midYellow)
    @yellow_leaf_bitmaps[3].set_pixel(3, 5, lightYellow)
    @yellow_leaf_bitmaps[3].set_pixel(4, 5, lightYellowtwo)
    @yellow_leaf_bitmaps[3].set_pixel(5, 5, lightYellow)
    @yellow_leaf_bitmaps[3].set_pixel(6, 5, darkYellowtwo)
    @yellow_leaf_bitmaps[3].set_pixel(7, 5, midYellow)
    @yellow_leaf_bitmaps[3].fill_rect(2, 6, 2, 1, midYellow)
    @yellow_leaf_bitmaps[3].set_pixel(4, 6, lightYellow)
    @yellow_leaf_bitmaps[3].set_pixel(5, 6, darkYellowtwo)
    @yellow_leaf_bitmaps[3].set_pixel(6, 6, midYellow)
    
    @yellow_leaf_bitmaps[4] = Bitmap.new(8, 8)
    @yellow_leaf_bitmaps[4].set_pixel(6, 2, midYellow)
    @yellow_leaf_bitmaps[4].set_pixel(7, 2, darkYellow)
    @yellow_leaf_bitmaps[4].fill_rect(4, 3, 2, 1, midYellow)
    @yellow_leaf_bitmaps[4].set_pixel(6, 3, darkYellowtwo)
    @yellow_leaf_bitmaps[4].set_pixel(2, 4, darkYellow)
    @yellow_leaf_bitmaps[4].fill_rect(3, 4, 2, 1, darkYellowtwo)
    @yellow_leaf_bitmaps[4].set_pixel(5, 4, lightYellow)
    @yellow_leaf_bitmaps[4].set_pixel(6, 4, darkYellowtwo)
    @yellow_leaf_bitmaps[4].set_pixel(1, 5, midYellow)
    @yellow_leaf_bitmaps[4].set_pixel(2, 5, darkYellowtwo)
    @yellow_leaf_bitmaps[4].set_pixel(3, 5, lightYellow)
    @yellow_leaf_bitmaps[4].set_pixel(4, 5, lightYellowtwo)
    @yellow_leaf_bitmaps[4].set_pixel(5, 5, midYellow)
    @yellow_leaf_bitmaps[4].set_pixel(2, 6, darkYellow)
    @yellow_leaf_bitmaps[4].fill_rect(3, 6, 2, 1, midYellow)
    
    @yellow_leaf_bitmaps[5] = Bitmap.new(8, 8)
    @yellow_leaf_bitmaps[5].fill_rect(6, 2, 2, 1, midYellow)
    @yellow_leaf_bitmaps[5].fill_rect(4, 3, 2, 1, midYellow)
    @yellow_leaf_bitmaps[5].set_pixel(6, 3, darkYellowtwo)
    @yellow_leaf_bitmaps[5].set_pixel(3, 4, midYellow)
    @yellow_leaf_bitmaps[5].set_pixel(4, 4, darkYellowtwo)
    @yellow_leaf_bitmaps[5].set_pixel(5, 4, lightYellow)
    @yellow_leaf_bitmaps[5].set_pixel(6, 4, lightYellowtwo)
    @yellow_leaf_bitmaps[5].set_pixel(1, 5, midYellow)
    @yellow_leaf_bitmaps[5].set_pixel(2, 5, darkYellowtwo)
    @yellow_leaf_bitmaps[5].fill_rect(3, 5, 2, 1, lightYellowtwo)
    @yellow_leaf_bitmaps[5].set_pixel(5, 5, lightYellow)
    @yellow_leaf_bitmaps[5].set_pixel(2, 6, midYellow)
    @yellow_leaf_bitmaps[5].set_pixel(3, 6, darkYellowtwo)
    @yellow_leaf_bitmaps[5].set_pixel(4, 6, lightYellow)
    
    @yellow_leaf_bitmaps[6] = Bitmap.new(8, 8)
    @yellow_leaf_bitmaps[6].fill_rect(6, 1, 1, 2, midYellow)
    @yellow_leaf_bitmaps[6].fill_rect(4, 2, 2, 1, midYellow)
    @yellow_leaf_bitmaps[6].fill_rect(6, 2, 1, 2, darkYellow)
    @yellow_leaf_bitmaps[6].fill_rect(3, 3, 2, 1, midYellow)
    @yellow_leaf_bitmaps[6].set_pixel(5, 3, darkYellowtwo)
    @yellow_leaf_bitmaps[6].set_pixel(2, 4, midYellow)
    @yellow_leaf_bitmaps[6].set_pixel(3, 4, darkYellowtwo)
    @yellow_leaf_bitmaps[6].set_pixel(4, 4, lightYellow)
    @yellow_leaf_bitmaps[6].set_pixel(5, 4, midYellow)
    @yellow_leaf_bitmaps[6].set_pixel(1, 5, midYellow)
    @yellow_leaf_bitmaps[6].set_pixel(2, 5, darkYellowtwo)
    @yellow_leaf_bitmaps[6].fill_rect(3, 5, 2, 1, midYellow)
    @yellow_leaf_bitmaps[6].set_pixel(1, 6, darkYellow)
    @yellow_leaf_bitmaps[6].set_pixel(2, 6, midYellow)
    
    @yellow_leaf_bitmaps[7] = Bitmap.new(8, 8)
    @yellow_leaf_bitmaps[7].set_pixel(6, 1, midYellow)
    @yellow_leaf_bitmaps[7].fill_rect(4, 2, 3, 2, midYellow)
    @yellow_leaf_bitmaps[7].set_pixel(3, 3, darkYellow)
    @yellow_leaf_bitmaps[7].set_pixel(2, 4, darkYellow)
    @yellow_leaf_bitmaps[7].set_pixel(3, 4, midYellow)
    @yellow_leaf_bitmaps[7].fill_rect(4, 4, 2, 1, darkYellowtwo)
    @yellow_leaf_bitmaps[7].set_pixel(1, 5, darkYellow)
    @yellow_leaf_bitmaps[7].set_pixel(2, 5, midYellow)
    @yellow_leaf_bitmaps[7].fill_rect(3, 5, 2, 1, lightYellow)
    @yellow_leaf_bitmaps[7].set_pixel(2, 6, midYellow)
    @yellow_leaf_bitmaps[7].set_pixel(3, 6, lightYellow)
    
    @yellow_leaf_bitmaps[8] = Bitmap.new(8, 8)
    @yellow_leaf_bitmaps[8].fill_rect(6, 1, 1, 2, midYellow)
    @yellow_leaf_bitmaps[8].fill_rect(4, 2, 2, 1, midYellow)
    @yellow_leaf_bitmaps[8].fill_rect(6, 2, 1, 2, darkYellow)
    @yellow_leaf_bitmaps[8].fill_rect(3, 3, 2, 1, midYellow)
    @yellow_leaf_bitmaps[8].set_pixel(5, 3, darkYellowtwo)
    @yellow_leaf_bitmaps[8].set_pixel(2, 4, midYellow)
    @yellow_leaf_bitmaps[8].set_pixel(3, 4, darkYellowtwo)
    @yellow_leaf_bitmaps[8].set_pixel(4, 4, lightYellow)
    @yellow_leaf_bitmaps[8].set_pixel(5, 4, midYellow)
    @yellow_leaf_bitmaps[8].set_pixel(1, 5, midYellow)
    @yellow_leaf_bitmaps[8].set_pixel(2, 5, darkYellowtwo)
    @yellow_leaf_bitmaps[8].fill_rect(3, 5, 2, 1, midYellow)
    @yellow_leaf_bitmaps[8].set_pixel(1, 6, darkYellow)
    @yellow_leaf_bitmaps[8].set_pixel(2, 6, midYellow)
    
    @yellow_leaf_bitmaps[9] = Bitmap.new(8, 8)
    @yellow_leaf_bitmaps[9].fill_rect(6, 2, 2, 1, midYellow)
    @yellow_leaf_bitmaps[9].fill_rect(4, 3, 2, 1, midYellow)
    @yellow_leaf_bitmaps[9].set_pixel(6, 3, darkYellowtwo)
    @yellow_leaf_bitmaps[9].set_pixel(3, 4, midYellow)
    @yellow_leaf_bitmaps[9].set_pixel(4, 4, darkYellowtwo)
    @yellow_leaf_bitmaps[9].set_pixel(5, 4, lightYellow)
    @yellow_leaf_bitmaps[9].set_pixel(6, 4, lightYellowtwo)
    @yellow_leaf_bitmaps[9].set_pixel(1, 5, midYellow)
    @yellow_leaf_bitmaps[9].set_pixel(2, 5, darkYellowtwo)
    @yellow_leaf_bitmaps[9].fill_rect(3, 5, 2, 1, lightYellowtwo)
    @yellow_leaf_bitmaps[9].set_pixel(5, 5, lightYellow)
    @yellow_leaf_bitmaps[9].set_pixel(2, 6, midYellow)
    @yellow_leaf_bitmaps[9].set_pixel(3, 6, darkYellowtwo)
    @yellow_leaf_bitmaps[9].set_pixel(4, 6, lightYellow)
    
    @yellow_leaf_bitmaps[10] = Bitmap.new(8, 8)
    @yellow_leaf_bitmaps[10].set_pixel(6, 2, midYellow)
    @yellow_leaf_bitmaps[10].set_pixel(7, 2, darkYellow)
    @yellow_leaf_bitmaps[10].fill_rect(4, 3, 2, 1, midYellow)
    @yellow_leaf_bitmaps[10].set_pixel(6, 3, darkYellowtwo)
    @yellow_leaf_bitmaps[10].set_pixel(2, 4, darkYellow)
    @yellow_leaf_bitmaps[10].fill_rect(3, 4, 2, 1, darkYellowtwo)
    @yellow_leaf_bitmaps[10].set_pixel(5, 4, lightYellow)
    @yellow_leaf_bitmaps[10].set_pixel(6, 4, darkYellowtwo)
    @yellow_leaf_bitmaps[10].set_pixel(1, 5, midYellow)
    @yellow_leaf_bitmaps[10].set_pixel(2, 5, darkYellowtwo)
    @yellow_leaf_bitmaps[10].set_pixel(3, 5, lightYellow)
    @yellow_leaf_bitmaps[10].set_pixel(4, 5, lightYellowtwo)
    @yellow_leaf_bitmaps[10].set_pixel(5, 5, midYellow)
    @yellow_leaf_bitmaps[10].set_pixel(2, 6, darkYellow)
    @yellow_leaf_bitmaps[10].fill_rect(3, 6, 2, 1, midYellow)
    
    @yellow_leaf_bitmaps[11] = Bitmap.new(8, 8)
    @yellow_leaf_bitmaps[11].fill_rect(0, 3, 1, 2, darkYellow)
    @yellow_leaf_bitmaps[11].set_pixel(1, 4, midYellow)
    @yellow_leaf_bitmaps[11].set_pixel(2, 4, darkYellowtwo)
    @yellow_leaf_bitmaps[11].set_pixel(3, 4, lightYellow)
    @yellow_leaf_bitmaps[11].set_pixel(4, 4, darkYellow)
    @yellow_leaf_bitmaps[11].set_pixel(7, 4, midYellow)
    @yellow_leaf_bitmaps[11].set_pixel(1, 5, darkYellow)
    @yellow_leaf_bitmaps[11].set_pixel(2, 5, midYellow)
    @yellow_leaf_bitmaps[11].set_pixel(3, 5, lightYellow)
    @yellow_leaf_bitmaps[11].set_pixel(4, 5, lightYellowtwo)
    @yellow_leaf_bitmaps[11].set_pixel(5, 5, lightYellow)
    @yellow_leaf_bitmaps[11].set_pixel(6, 5, darkYellowtwo)
    @yellow_leaf_bitmaps[11].set_pixel(7, 5, midYellow)
    @yellow_leaf_bitmaps[11].fill_rect(2, 6, 2, 1, midYellow)
    @yellow_leaf_bitmaps[11].set_pixel(4, 6, lightYellow)
    @yellow_leaf_bitmaps[11].set_pixel(5, 6, darkYellowtwo)
    @yellow_leaf_bitmaps[11].set_pixel(6, 6, midYellow)
    
    @yellow_leaf_bitmaps[12] = Bitmap.new(8, 8)
    @yellow_leaf_bitmaps[12].set_pixel(1, 1, darkYellow)
    @yellow_leaf_bitmaps[12].fill_rect(1, 2, 2, 1, midYellow)
    @yellow_leaf_bitmaps[12].set_pixel(2, 3, midYellow)
    @yellow_leaf_bitmaps[12].set_pixel(3, 3, darkYellow)
    @yellow_leaf_bitmaps[12].set_pixel(4, 3, midYellow)
    @yellow_leaf_bitmaps[12].fill_rect(2, 4, 2, 1, midYellow)
    @yellow_leaf_bitmaps[12].set_pixel(4, 4, darkYellow)
    @yellow_leaf_bitmaps[12].set_pixel(5, 4, lightYellow)
    @yellow_leaf_bitmaps[12].set_pixel(3, 5, midYellow)
    @yellow_leaf_bitmaps[12].set_pixel(4, 5, darkYellow)
    @yellow_leaf_bitmaps[12].fill_rect(5, 5, 2, 1, darkYellowtwo)
    @yellow_leaf_bitmaps[12].fill_rect(4, 6, 2, 1, midYellow)
    @yellow_leaf_bitmaps[12].set_pixel(6, 6, lightYellow)
    @yellow_leaf_bitmaps[12].set_pixel(6, 7, darkYellowtwo)
    
#-------------------------------------------------------------------------------    
    @sparkle_bitmaps = []
    
    lightBlue = Color.new(181, 244, 255, 255)
    midBlue   = Color.new(126, 197, 235, 255)
    darkBlue  = Color.new(77, 136, 225, 255)
    
    @sparkle_bitmaps[0] = Bitmap.new(7, 7)
    @sparkle_bitmaps[0].set_pixel(3, 3, darkBlue)
    
    @sparkle_bitmaps[1] = Bitmap.new(7, 7)
    @sparkle_bitmaps[1].fill_rect(3, 2, 1, 3, darkBlue)
    @sparkle_bitmaps[1].fill_rect(2, 3, 3, 1, darkBlue)
    @sparkle_bitmaps[1].set_pixel(3, 3, midBlue)
    
    @sparkle_bitmaps[2] = Bitmap.new(7, 7)
    @sparkle_bitmaps[2].set_pixel(1, 1, darkBlue)
    @sparkle_bitmaps[2].set_pixel(5, 1, darkBlue)
    @sparkle_bitmaps[2].set_pixel(2, 2, midBlue)
    @sparkle_bitmaps[2].set_pixel(4, 2, midBlue)
    @sparkle_bitmaps[2].set_pixel(3, 3, lightBlue)
    @sparkle_bitmaps[2].set_pixel(2, 4, midBlue)
    @sparkle_bitmaps[2].set_pixel(4, 4, midBlue)
    @sparkle_bitmaps[2].set_pixel(1, 5, darkBlue)
    @sparkle_bitmaps[2].set_pixel(5, 5, darkBlue)
    
    @sparkle_bitmaps[3] = Bitmap.new(7, 7)
    @sparkle_bitmaps[3].fill_rect(3, 1, 1, 5, darkBlue)
    @sparkle_bitmaps[3].fill_rect(1, 3, 5, 1, darkBlue)
    @sparkle_bitmaps[3].fill_rect(3, 2, 1, 3, midBlue)
    @sparkle_bitmaps[3].fill_rect(2, 3, 3, 1, midBlue)
    @sparkle_bitmaps[3].set_pixel(3, 3, lightBlue)
    
    @sparkle_bitmaps[4] = Bitmap.new(7, 7)
    @sparkle_bitmaps[4].fill_rect(2, 2, 3, 3, midBlue)
    @sparkle_bitmaps[4].fill_rect(3, 2, 1, 3, darkBlue)
    @sparkle_bitmaps[4].fill_rect(2, 3, 3, 1, darkBlue)
    @sparkle_bitmaps[4].set_pixel(3, 3, lightBlue)
    @sparkle_bitmaps[4].set_pixel(1, 1, darkBlue)
    @sparkle_bitmaps[4].set_pixel(5, 1, darkBlue)
    @sparkle_bitmaps[4].set_pixel(1, 5, darkBlue)
    @sparkle_bitmaps[4].set_pixel(5, 1, darkBlue)
    
    @sparkle_bitmaps[5] = Bitmap.new(7, 7)
    @sparkle_bitmaps[5].fill_rect(2, 1, 3, 5, darkBlue)
    @sparkle_bitmaps[5].fill_rect(1, 2, 5, 3, darkBlue)
    @sparkle_bitmaps[5].fill_rect(2, 2, 3, 3, midBlue)
    @sparkle_bitmaps[5].fill_rect(3, 1, 1, 5, midBlue)
    @sparkle_bitmaps[5].fill_rect(1, 3, 5, 1, midBlue)
    @sparkle_bitmaps[5].fill_rect(3, 2, 1, 3, lightBlue)
    @sparkle_bitmaps[5].fill_rect(2, 3, 3, 1, lightBlue)
    @sparkle_bitmaps[5].set_pixel(3, 3, white)
    
    @sparkle_bitmaps[6] = Bitmap.new(7, 7)
    @sparkle_bitmaps[6].fill_rect(2, 1, 3, 5, midBlue)
    @sparkle_bitmaps[6].fill_rect(1, 2, 5, 3, midBlue)
    @sparkle_bitmaps[6].fill_rect(3, 0, 1, 7, darkBlue)
    @sparkle_bitmaps[6].fill_rect(0, 3, 7, 1, darkBlue)
    @sparkle_bitmaps[6].fill_rect(2, 2, 3, 3, lightBlue)
    @sparkle_bitmaps[6].fill_rect(3, 2, 1, 3, midBlue)
    @sparkle_bitmaps[6].fill_rect(2, 3, 3, 1, midBlue)
    @sparkle_bitmaps[6].set_pixel(3, 3, white)
#-------------------------------------------------------------------------------    
    
    @meteor_bitmap = Bitmap.new(14, 12)
    @meteor_bitmap.fill_rect(0, 8, 5, 4, paleOrange)
    @meteor_bitmap.fill_rect(1, 7, 6, 4, paleOrange)
    @meteor_bitmap.set_pixel(7, 8, paleOrange)
    @meteor_bitmap.fill_rect(1, 8, 2, 2, brightOrange)
    @meteor_bitmap.set_pixel(2, 7, brightOrange)
    @meteor_bitmap.fill_rect(3, 6, 2, 1, brightOrange)
    @meteor_bitmap.set_pixel(3, 8, brightOrange)
    @meteor_bitmap.set_pixel(3, 10, brightOrange)
    @meteor_bitmap.set_pixel(4, 9, brightOrange)
    @meteor_bitmap.fill_rect(5, 5, 1, 5, brightOrange)
    @meteor_bitmap.fill_rect(6, 4, 1, 5, brightOrange)
    @meteor_bitmap.fill_rect(7, 3, 1, 5, brightOrange)
    @meteor_bitmap.fill_rect(8, 6, 1, 2, brightOrange)
    @meteor_bitmap.set_pixel(9, 5, brightOrange)
    @meteor_bitmap.set_pixel(3, 8, midRed)
    @meteor_bitmap.fill_rect(4, 7, 1, 2, midRed)
    @meteor_bitmap.set_pixel(4, 5, midRed)
    @meteor_bitmap.set_pixel(5, 4, midRed)
    @meteor_bitmap.set_pixel(5, 6, midRed)
    @meteor_bitmap.set_pixel(6, 5, midRed)
    @meteor_bitmap.set_pixel(6, 7, midRed)
    @meteor_bitmap.fill_rect(7, 4, 1, 3, midRed)
    @meteor_bitmap.fill_rect(8, 3, 1, 3, midRed)
    @meteor_bitmap.fill_rect(9, 2, 1, 3, midRed)
    @meteor_bitmap.fill_rect(10, 1, 1, 3, midRed)
    @meteor_bitmap.fill_rect(11, 0, 1, 3, midRed)
    @meteor_bitmap.fill_rect(12, 0, 1, 2, midRed)
    @meteor_bitmap.set_pixel(13, 0, midRed)
    
    
    @impact_bitmap = Bitmap.new(22, 11)
    @impact_bitmap.fill_rect(0, 5, 1, 2, brightOrange)
    @impact_bitmap.set_pixel(1, 4, brightOrange)
    @impact_bitmap.set_pixel(1, 6, brightOrange)
    @impact_bitmap.set_pixel(2, 3, brightOrange)
    @impact_bitmap.set_pixel(2, 7, brightOrange)
    @impact_bitmap.set_pixel(3, 2, midRed)
    @impact_bitmap.set_pixel(3, 7, midRed)
    @impact_bitmap.set_pixel(4, 2, brightOrange)
    @impact_bitmap.set_pixel(4, 8, brightOrange)
    @impact_bitmap.set_pixel(5, 2, midRed)
    @impact_bitmap.fill_rect(5, 8, 3, 1, brightOrange)
    @impact_bitmap.set_pixel(6, 1, midRed)
    @impact_bitmap.fill_rect(7, 1, 8, 1, brightOrange)
    @impact_bitmap.fill_rect(7, 9, 8, 1, midRed)
#-------------------------------------------------------------------------------    
    
    @flame_meteor_bitmap = Bitmap.new(14, 12)
    @flame_meteor_bitmap.fill_rect(0, 8, 5, 4, brightOrange)
    @flame_meteor_bitmap.fill_rect(1, 7, 6, 4, brightOrange)
    @flame_meteor_bitmap.set_pixel(7, 8, brightOrange)
    @flame_meteor_bitmap.fill_rect(1, 8, 2, 2, midYellow)
    @flame_meteor_bitmap.set_pixel(2, 7, midYellow)
    @flame_meteor_bitmap.fill_rect(3, 6, 2, 1, midYellow)
    @flame_meteor_bitmap.set_pixel(3, 8, midYellow)
    @flame_meteor_bitmap.set_pixel(3, 10, midYellow)
    @flame_meteor_bitmap.set_pixel(4, 9, midYellow)
    @flame_meteor_bitmap.fill_rect(5, 5, 1, 5, midYellow)
    @flame_meteor_bitmap.fill_rect(6, 4, 1, 5, midYellow)
    @flame_meteor_bitmap.fill_rect(7, 3, 1, 5, midYellow)
    @flame_meteor_bitmap.fill_rect(8, 6, 1, 2, midYellow)
    @flame_meteor_bitmap.set_pixel(9, 5, midYellow)
    @flame_meteor_bitmap.set_pixel(3, 8, lightYellow)
    @flame_meteor_bitmap.fill_rect(4, 7, 1, 2, lightYellowtwo)
    @flame_meteor_bitmap.set_pixel(4, 5, lightYellow)
    @flame_meteor_bitmap.set_pixel(5, 4, lightYellow)
    @flame_meteor_bitmap.set_pixel(5, 6, lightYellow)
    @flame_meteor_bitmap.set_pixel(6, 5, lightYellow)
    @flame_meteor_bitmap.set_pixel(6, 7, lightYellow)
    @flame_meteor_bitmap.fill_rect(7, 4, 1, 3, lightYellow)
    @flame_meteor_bitmap.fill_rect(8, 3, 1, 3, lightYellow)
    @flame_meteor_bitmap.fill_rect(9, 2, 1, 3, lightYellow)
    @flame_meteor_bitmap.fill_rect(10, 1, 1, 3, lightYellow)
    @flame_meteor_bitmap.fill_rect(11, 0, 1, 3, lightYellow)
    @flame_meteor_bitmap.fill_rect(12, 0, 1, 2, lightYellow)
    @flame_meteor_bitmap.set_pixel(13, 0, lightYellow)
    
    
    @flame_impact_bitmap = Bitmap.new(22, 11)
    @flame_impact_bitmap.fill_rect(0, 5, 1, 2, midYellow)
    @flame_impact_bitmap.set_pixel(1, 4, midYellow)
    @flame_impact_bitmap.set_pixel(1, 6, midYellow)
    @flame_impact_bitmap.set_pixel(2, 3, midYellow)
    @flame_impact_bitmap.set_pixel(2, 7, midYellow)
    @flame_impact_bitmap.set_pixel(3, 2, midYellow)
    @flame_impact_bitmap.set_pixel(3, 7, lightYellow)
    @flame_impact_bitmap.set_pixel(4, 2, brightOrange)
    @flame_impact_bitmap.set_pixel(4, 8, brightOrange)
    @flame_impact_bitmap.set_pixel(5, 2, lightYellow)
    @flame_impact_bitmap.fill_rect(5, 8, 3, 1, midYellow)
    @flame_impact_bitmap.set_pixel(6, 1, lightYellow)
    @flame_impact_bitmap.fill_rect(7, 1, 8, 1, midYellow)
    @flame_impact_bitmap.fill_rect(7, 9, 8, 1, lightYellow)
#-------------------------------------------------------------------------------    
    
    
    @ash_bitmaps = []
    @ash_bitmaps[0] = Bitmap.new(3, 3)
    @ash_bitmaps[0].fill_rect(0, 1, 1, 3, lightGrey)
    @ash_bitmaps[0].fill_rect(1, 0, 3, 1, lightGrey)
    @ash_bitmaps[0].set_pixel(1, 1, white)
    @ash_bitmaps[1] = Bitmap.new(3, 3)
    @ash_bitmaps[1].fill_rect(0, 1, 1, 3, grey)
    @ash_bitmaps[1].fill_rect(1, 0, 3, 1, grey)
    @ash_bitmaps[1].set_pixel(1, 1, lightGrey)
#-------------------------------------------------------------------------------    

    
    @bubble_bitmaps = []
    darkBlue  = Color.new(77, 136, 225, 160)
    aqua = Color.new(197, 253, 254, 160)
    lavender = Color.new(225, 190, 244, 160)
    
    @bubble_bitmaps[0] = Bitmap.new(24, 24)
    @bubble_bitmaps[0].fill_rect(0, 9, 24, 5, darkBlue)
    @bubble_bitmaps[0].fill_rect(1, 6, 22, 11, darkBlue)
    @bubble_bitmaps[0].fill_rect(2, 5, 20, 13, darkBlue)
    @bubble_bitmaps[0].fill_rect(3, 4, 18, 15, darkBlue)
    @bubble_bitmaps[0].fill_rect(4, 3, 16, 17, darkBlue)
    @bubble_bitmaps[0].fill_rect(5, 2, 14, 19, darkBlue)
    @bubble_bitmaps[0].fill_rect(6, 1, 12, 21, darkBlue)
    @bubble_bitmaps[0].fill_rect(9, 0, 5, 24, darkBlue)
    @bubble_bitmaps[0].fill_rect(2, 11, 20, 4, aqua)
    @bubble_bitmaps[0].fill_rect(3, 7, 18, 10, aqua)
    @bubble_bitmaps[0].fill_rect(4, 6, 16, 12, aqua)
    @bubble_bitmaps[0].fill_rect(5, 5, 14, 14, aqua)
    @bubble_bitmaps[0].fill_rect(6, 4, 12, 16, aqua)
    @bubble_bitmaps[0].fill_rect(9, 2, 4, 20, aqua)
    @bubble_bitmaps[0].fill_rect(5, 10, 1, 7, lavender)
    @bubble_bitmaps[0].fill_rect(6, 14, 1, 5, lavender)
    @bubble_bitmaps[0].fill_rect(7, 15, 1, 4, lavender)
    @bubble_bitmaps[0].fill_rect(8, 16, 1, 4, lavender)
    @bubble_bitmaps[0].fill_rect(9, 17, 1, 3, lavender)
    @bubble_bitmaps[0].fill_rect(10, 18, 4, 3, lavender)
    @bubble_bitmaps[0].fill_rect(14, 18, 1, 2, lavender)
    @bubble_bitmaps[0].fill_rect(13, 5, 4, 4, white)
    @bubble_bitmaps[0].fill_rect(14, 4, 2, 1, white)
    @bubble_bitmaps[0].set_pixel(17, 6, white)
    
    @bubble_bitmaps[1] = Bitmap.new(14, 15)
    @bubble_bitmaps[1].fill_rect(0, 4, 14, 7, darkBlue)
    @bubble_bitmaps[1].fill_rect(1, 3, 12, 9, darkBlue)
    @bubble_bitmaps[1].fill_rect(2, 2, 10, 11, darkBlue)
    @bubble_bitmaps[1].fill_rect(3, 1, 8, 13, darkBlue)
    @bubble_bitmaps[1].fill_rect(5, 0, 4, 15, darkBlue)
    @bubble_bitmaps[1].fill_rect(1, 5, 12, 4, aqua)
    @bubble_bitmaps[1].fill_rect(2, 4, 10, 6, aqua)
    @bubble_bitmaps[1].fill_rect(3, 3, 8, 8, aqua)
    @bubble_bitmaps[1].fill_rect(4, 2, 6, 10, aqua)
    @bubble_bitmaps[1].fill_rect(1, 5, 12, 4, aqua)
    @bubble_bitmaps[1].fill_rect(3, 9, 1, 2, lavender)
    @bubble_bitmaps[1].fill_rect(4, 10, 1, 2, lavender)
    @bubble_bitmaps[1].fill_rect(5, 11, 4, 1, lavender)
    @bubble_bitmaps[1].fill_rect(6, 12, 2, 1, white)
    @bubble_bitmaps[1].fill_rect(8, 3, 2, 2, white)
    @bubble_bitmaps[1].set_pixel(7, 4, white)
    @bubble_bitmaps[1].set_pixel(8, 5, white)
    
    @bubble2_bitmaps = Array.new
    darkSteelGray = Color.new(145, 150, 155, 160)
    midSteelGray = Color.new(180, 180, 185, 160)
    lightSteelGray = Color.new(225, 225, 235, 160)
    steelBlue = Color.new(145, 145, 165, 160)
    lightSteelBlue = Color.new(165, 170, 180, 160)
    transparentWhite = Color.new(255, 255, 255, 160)
    
    @bubble2_bitmaps[0] = Bitmap.new(6, 6)
    @bubble2_bitmaps[0].fill_rect(0, 0, 6, 6, darkSteelGray)
    @bubble2_bitmaps[0].fill_rect(0, 2, 6, 2, midSteelGray)
    @bubble2_bitmaps[0].fill_rect(2, 0, 2, 6, midSteelGray)
    @bubble2_bitmaps[0].fill_rect(2, 2, 2, 2, lightSteelGray)
    
    @bubble2_bitmaps[1] = Bitmap.new(8, 8)
    @bubble2_bitmaps[1].fill_rect(0, 2, 2, 4, steelBlue)
    @bubble2_bitmaps[1].fill_rect(2, 0, 4, 2, darkSteelGray)
    @bubble2_bitmaps[1].fill_rect(6, 2, 2, 2, darkSteelGray)
    @bubble2_bitmaps[1].fill_rect(2, 6, 2, 2, darkSteelGray)
    @bubble2_bitmaps[1].fill_rect(6, 4, 2, 2, midSteelGray)
    @bubble2_bitmaps[1].fill_rect(4, 6, 2, 2, midSteelGray)
    @bubble2_bitmaps[1].fill_rect(4, 4, 2, 2, lightSteelBlue)
    @bubble2_bitmaps[1].fill_rect(2, 4, 2, 2, lightSteelGray)
    @bubble2_bitmaps[1].fill_rect(4, 2, 2, 2, lightSteelGray)
    @bubble2_bitmaps[1].fill_rect(2, 2, 2, 2, transparentWhite)
    
    @bubble2_bitmaps[2] = Bitmap.new(8, 10)
    @bubble2_bitmaps[2].fill_rect(8, 2, 2, 4, steelBlue)
    @bubble2_bitmaps[2].fill_rect(2, 0, 8, 2, darkSteelGray)
    @bubble2_bitmaps[2].fill_rect(2, 6, 8, 2, darkSteelGray)
    @bubble2_bitmaps[2].fill_rect(4, 0, 2, 2, midSteelGray)
    @bubble2_bitmaps[2].fill_rect(4, 6, 2, 2, midSteelGray)
    @bubble2_bitmaps[2].fill_rect(0, 2, 2, 2, midSteelGray)
    @bubble2_bitmaps[2].fill_rect(0, 4, 2, 2, lightSteelBlue)
    @bubble2_bitmaps[2].fill_rect(2, 2, 6, 4, lightSteelGray)
    @bubble2_bitmaps[2].fill_rect(2, 2, 4, 2, transparentWhite)
    @bubble2_bitmaps[2].fill_rect(4, 4, 2, 2, transparentWhite)
    
    @bubble2_bitmaps[3] = Bitmap.new(14, 14)
    @bubble2_bitmaps[3].fill_rect(4, 0, 4, 2, steelBlue)
    @bubble2_bitmaps[3].fill_rect(0, 4, 2, 4, steelBlue)
    @bubble2_bitmaps[3].fill_rect(12, 4, 2, 4, steelBlue)
    @bubble2_bitmaps[3].fill_rect(8, 0, 2, 2, darkSteelGray)
    @bubble2_bitmaps[3].fill_rect(0, 6, 2, 2, darkSteelGray)
    @bubble2_bitmaps[3].fill_rect(12, 6, 2, 2, darkSteelGray)
    @bubble2_bitmaps[3].fill_rect(4, 12, 6, 2, darkSteelGray)
    @bubble2_bitmaps[3].fill_rect(8, 0, 2, 2, darkSteelGray)
    @bubble2_bitmaps[3].fill_rect(2, 2, 10, 10, midSteelGray)
    @bubble2_bitmaps[3].fill_rect(6, 12, 2, 2, midSteelGray)
    @bubble2_bitmaps[3].fill_rect(2, 4, 10, 6, lightSteelGray)
    @bubble2_bitmaps[3].fill_rect(4, 2, 2, 2, lightSteelGray)
    @bubble2_bitmaps[3].fill_rect(6, 10, 4, 2, lightSteelGray)
    @bubble2_bitmaps[3].fill_rect(6, 4, 2, 2, transparentWhite)
    @bubble2_bitmaps[3].fill_rect(4, 6, 2, 2, transparentWhite)
#------------------------------------------------------------------------------- 
    
    
    @waterbomb_bitmap = Bitmap.new(8, 8)
    @waterbomb_bitmap.fill_rect(0, 2, 2, 4, aqua)
    @waterbomb_bitmap.fill_rect(2, 0, 4, 2, aqua)
    @waterbomb_bitmap.fill_rect(6, 2, 2, 2, aqua)
    @waterbomb_bitmap.fill_rect(2, 6, 2, 2, aqua)
    @waterbomb_bitmap.fill_rect(6, 4, 2, 2, aqua)
    @waterbomb_bitmap.fill_rect(4, 6, 2, 2, aqua)
    @waterbomb_bitmap.fill_rect(4, 4, 2, 2, aqua)
    @waterbomb_bitmap.fill_rect(2, 4, 2, 2, aqua)
    @waterbomb_bitmap.fill_rect(4, 2, 2, 2, aqua)
    @waterbomb_bitmap.fill_rect(2, 2, 2, 2, aqua)

    
    
    @waterbomb_impact_bitmap = Bitmap.new(8, 5)
    @waterbomb_impact_bitmap.fill_rect(1, 0, 6, 1, aqua)
    @waterbomb_impact_bitmap.fill_rect(1, 4, 6, 1, aqua)
    @waterbomb_impact_bitmap.fill_rect(0, 1, 1, 3, aqua)
    @waterbomb_impact_bitmap.fill_rect(7, 1, 1, 3, aqua)
    @waterbomb_impact_bitmap.set_pixel(1, 0, aqua)
    @waterbomb_impact_bitmap.set_pixel(0, 1, aqua)
#------------------------------------------------------------------------------- 

    
    
    @icybomb_bitmap = Bitmap.new(8, 8)
    @icybomb_bitmap.fill_rect(0, 2, 2, 4, lightBlue)
    @icybomb_bitmap.fill_rect(2, 0, 4, 2, lightBlue)
    @icybomb_bitmap.fill_rect(6, 2, 2, 2, lightBlue)
    @icybomb_bitmap.fill_rect(2, 6, 2, 2, lightBlue)
    @icybomb_bitmap.fill_rect(6, 4, 2, 2, lightBlue)
    @icybomb_bitmap.fill_rect(4, 6, 2, 2, lightBlue)
    @icybomb_bitmap.fill_rect(4, 4, 2, 2, lightBlue)
    @icybomb_bitmap.fill_rect(2, 4, 2, 2, lightBlue)
    @icybomb_bitmap.fill_rect(4, 2, 2, 2, lightBlue)
    @icybomb_bitmap.fill_rect(2, 2, 2, 2, lightBlue)

    
    
    @icybomb_impact_bitmap = Bitmap.new(8, 5)
    @icybomb_impact_bitmap.fill_rect(1, 0, 6, 1, lightBlue)
    @icybomb_impact_bitmap.fill_rect(1, 4, 6, 1, lightBlue)
    @icybomb_impact_bitmap.fill_rect(0, 1, 1, 3, lightBlue)
    @icybomb_impact_bitmap.fill_rect(7, 1, 1, 3, lightBlue)
    @icybomb_impact_bitmap.set_pixel(1, 0, lightBlue)
    @icybomb_impact_bitmap.set_pixel(0, 1, lightBlue)
#-------------------------------------------------------------------------------

    
    
    @flarebomb_bitmap = Bitmap.new(8, 8)
    @flarebomb_bitmap.fill_rect(0, 2, 2, 4, midYellow)
    @flarebomb_bitmap.fill_rect(2, 0, 4, 2, midYellow)
    @flarebomb_bitmap.fill_rect(6, 2, 2, 2, midYellow)
    @flarebomb_bitmap.fill_rect(2, 6, 2, 2, brightOrange)
    @flarebomb_bitmap.fill_rect(6, 4, 2, 2, brightOrange)
    @flarebomb_bitmap.fill_rect(4, 6, 2, 2, midYellow)
    @flarebomb_bitmap.fill_rect(4, 4, 2, 2, brightOrange)
    @flarebomb_bitmap.fill_rect(2, 4, 2, 2, midYellow)
    @flarebomb_bitmap.fill_rect(4, 2, 2, 2, midYellow)
    @flarebomb_bitmap.fill_rect(2, 2, 2, 2, midYellow)

    
    @flarebomb_impact_bitmap = Bitmap.new(8, 5)
    @flarebomb_impact_bitmap.fill_rect(1, 0, 6, 1, brightOrange)
    @flarebomb_impact_bitmap.fill_rect(1, 4, 6, 1, brightOrange)
    @flarebomb_impact_bitmap.fill_rect(0, 1, 1, 3, midYellow)
    @flarebomb_impact_bitmap.fill_rect(7, 1, 1, 3, midYellow)
    @flarebomb_impact_bitmap.set_pixel(1, 0, midYellow)
    @flarebomb_impact_bitmap.set_pixel(0, 1, midYellow)
#------------------------------------------------------------------------------- 


    @starburst_bitmaps = []
    
    starburst_yellow = Color.new(233, 210, 142, 255)
    starburst_yellowtwo = Color.new(219, 191, 95, 255)
    starburst_lightyellow = Color.new(242, 229, 190, 255)
    starburst_pink = Color.new(241, 185, 187, 255)
    starburst_red = Color.new(196, 55, 84, 255)
    starburst_redtwo = Color.new(178, 15, 56, 255)
    starburst_cyan = Color.new (189, 225, 242, 255)
    starburst_blue = Color.new (102, 181, 221, 255)
    starburst_bluetwo = Color.new (5, 88, 168, 255)
    starburst_lightgreen = Color.new(205, 246, 205, 255)
    starburst_green = Color.new(88, 221, 89, 255)
    starburst_greentwo = Color.new(44, 166, 0, 255)
    starburst_purple = Color.new(216, 197, 255, 255)
    starburst_violet = Color.new(155, 107, 255, 255)
    starburst_violettwo = Color.new(71, 0, 222, 255)
    starburst_lightorange = Color.new(255, 220, 177, 255)
    starburst_orange = Color.new(255, 180, 85, 255)
    starburst_orangetwo = Color.new(222, 124, 0, 255)
    
    @starburst_bitmaps[0] = Bitmap.new(8, 8)
    @starburst_bitmaps[0].set_pixel(3, 3, starburst_lightyellow)
    
    @starburst_bitmaps[1] = Bitmap.new(8, 8)
    @starburst_bitmaps[1].fill_rect(3, 2, 1, 3, starburst_yellow)
    @starburst_bitmaps[1].fill_rect(2, 3, 3, 1, starburst_yellow)
    @starburst_bitmaps[1].set_pixel(3, 3, starburst_lightyellow)
    
    @starburst_bitmaps[2] = Bitmap.new(7, 7)
    @starburst_bitmaps[2].set_pixel(1, 1, starburst_yellow)
    @starburst_bitmaps[2].set_pixel(5, 1, starburst_yellow)
    @starburst_bitmaps[2].set_pixel(2, 2, starburst_yellowtwo)
    @starburst_bitmaps[2].set_pixel(4, 2, starburst_yellow)
    @starburst_bitmaps[2].set_pixel(3, 3, starburst_lightyellow)
    @starburst_bitmaps[2].set_pixel(2, 4, starburst_yellowtwo)
    @starburst_bitmaps[2].set_pixel(4, 4, starburst_yellowtwo)
    @starburst_bitmaps[2].set_pixel(1, 5, starburst_yellow)
    @starburst_bitmaps[2].set_pixel(5, 5, starburst_yellow)
    
    @starburst_bitmaps[3] = Bitmap.new(7, 7)
    @starburst_bitmaps[3].fill_rect(3, 1, 1, 5, starburst_yellow)
    @starburst_bitmaps[3].fill_rect(1, 3, 5, 1, starburst_yellowtwo)
    @starburst_bitmaps[3].fill_rect(3, 2, 1, 3, starburst_yellow)
    @starburst_bitmaps[3].fill_rect(2, 3, 3, 1, starburst_yellowtwo)
    @starburst_bitmaps[3].set_pixel(3, 3, starburst_lightyellow)
    
    @starburst_bitmaps[4] = Bitmap.new(7, 7)
    @starburst_bitmaps[4].fill_rect(2, 2, 3, 3, starburst_yellow)
    @starburst_bitmaps[4].fill_rect(3, 2, 1, 3, starburst_yellow)
    @starburst_bitmaps[4].fill_rect(2, 3, 3, 1, starburst_yellowtwo)
    @starburst_bitmaps[4].set_pixel(3, 3, starburst_lightyellow)
    @starburst_bitmaps[4].set_pixel(1, 1, starburst_yellow)
    @starburst_bitmaps[4].set_pixel(5, 1, starburst_yellow)
    @starburst_bitmaps[4].set_pixel(1, 5, starburst_yellowtwo)
    @starburst_bitmaps[4].set_pixel(5, 1, starburst_yellowtwo)
    
    @starburst_bitmaps[5] = Bitmap.new(8, 8)
    @starburst_bitmaps[5].fill_rect(3, 2, 1, 3, starburst_yellow)
    @starburst_bitmaps[5].fill_rect(2, 3, 3, 1, starburst_yellow)
    @starburst_bitmaps[5].set_pixel(3, 3, starburst_lightyellow)
    
    @starburst_bitmaps[6] = Bitmap.new(8, 8)
    @starburst_bitmaps[6].fill_rect(3, 2, 1, 3, starburst_green)
    @starburst_bitmaps[6].fill_rect(2, 3, 3, 1, starburst_green)
    @starburst_bitmaps[6].set_pixel(3, 3, starburst_lightgreen)
    
    @starburst_bitmaps[7] = Bitmap.new(7, 7)
    @starburst_bitmaps[7].set_pixel(1, 1, starburst_greentwo)
    @starburst_bitmaps[7].set_pixel(5, 1, starburst_greentwo)
    @starburst_bitmaps[7].set_pixel(2, 2, starburst_greentwo)
    @starburst_bitmaps[7].set_pixel(4, 2, starburst_greentwo)
    @starburst_bitmaps[7].set_pixel(3, 3, starburst_green)
    @starburst_bitmaps[7].set_pixel(2, 4, starburst_green)
    @starburst_bitmaps[7].set_pixel(4, 4, starburst_green)
    @starburst_bitmaps[7].set_pixel(1, 5, starburst_green)
    @starburst_bitmaps[7].set_pixel(5, 5, starburst_lightgreen)
    
    @starburst_bitmaps[8] = Bitmap.new(7, 7)
    @starburst_bitmaps[8].fill_rect(3, 1, 1, 5, starburst_greentwo)
    @starburst_bitmaps[8].fill_rect(1, 3, 5, 1, starburst_greentwo)
    @starburst_bitmaps[8].fill_rect(3, 2, 1, 3, starburst_green)
    @starburst_bitmaps[8].fill_rect(2, 3, 3, 1, starburst_green)
    @starburst_bitmaps[8].set_pixel(3, 3, starburst_lightgreen)
        
    @starburst_bitmaps[9] = Bitmap.new(7, 7)
    @starburst_bitmaps[9].fill_rect(2, 1, 3, 5, starburst_greentwo)
    @starburst_bitmaps[9].fill_rect(1, 2, 5, 3, starburst_greentwo)
    @starburst_bitmaps[9].fill_rect(2, 2, 3, 3, starburst_green)
    @starburst_bitmaps[9].fill_rect(3, 1, 1, 5, starburst_green)
    @starburst_bitmaps[9].fill_rect(1, 3, 5, 1, starburst_green)
    @starburst_bitmaps[9].fill_rect(3, 2, 1, 3, starburst_lightgreen)
    @starburst_bitmaps[9].fill_rect(2, 3, 3, 1, starburst_lightgreen)
    @starburst_bitmaps[9].set_pixel(3, 3, starburst_lightgreen)
    
    @starburst_bitmaps[10] = Bitmap.new(7, 7)
    @starburst_bitmaps[10].fill_rect(2, 2, 3, 3, starburst_greentwo)
    @starburst_bitmaps[10].fill_rect(3, 2, 1, 3, starburst_greentwo)
    @starburst_bitmaps[10].fill_rect(2, 3, 3, 1, starburst_green)
    @starburst_bitmaps[10].set_pixel(3, 3, starburst_lightgreen)
    @starburst_bitmaps[10].set_pixel(1, 1, starburst_green)
    @starburst_bitmaps[10].set_pixel(5, 1, starburst_green)
    @starburst_bitmaps[10].set_pixel(1, 5, starburst_greentwo)
    @starburst_bitmaps[10].set_pixel(5, 1, starburst_greentwo)
        
    @starburst_bitmaps[11] = Bitmap.new(8, 8)
    @starburst_bitmaps[11].fill_rect(3, 2, 1, 3, starburst_green)
    @starburst_bitmaps[11].fill_rect(2, 3, 3, 1, starburst_green)
    @starburst_bitmaps[11].set_pixel(3, 3, starburst_lightgreen)
    
    @starburst_bitmaps[12] = Bitmap.new(8, 8)
    @starburst_bitmaps[12].fill_rect(3, 2, 1, 3, starburst_blue)
    @starburst_bitmaps[12].fill_rect(2, 3, 3, 1, starburst_blue)
    @starburst_bitmaps[12].set_pixel(3, 3, starburst_cyan)
    
    @starburst_bitmaps[13] = Bitmap.new(7, 7)
    @starburst_bitmaps[13].set_pixel(1, 1, starburst_bluetwo)
    @starburst_bitmaps[13].set_pixel(5, 1, starburst_bluetwo)
    @starburst_bitmaps[13].set_pixel(2, 2, starburst_bluetwo)
    @starburst_bitmaps[13].set_pixel(4, 2, starburst_bluetwo)
    @starburst_bitmaps[13].set_pixel(3, 3, starburst_blue)
    @starburst_bitmaps[13].set_pixel(2, 4, starburst_blue)
    @starburst_bitmaps[13].set_pixel(4, 4, starburst_blue)
    @starburst_bitmaps[13].set_pixel(1, 5, starburst_blue)
    @starburst_bitmaps[13].set_pixel(5, 5, starburst_cyan)
    
    @starburst_bitmaps[14] = Bitmap.new(7, 7)
    @starburst_bitmaps[14].fill_rect(3, 1, 1, 5, starburst_bluetwo)
    @starburst_bitmaps[14].fill_rect(1, 3, 5, 1, starburst_bluetwo)
    @starburst_bitmaps[14].fill_rect(3, 2, 1, 3, starburst_blue)
    @starburst_bitmaps[14].fill_rect(2, 3, 3, 1, starburst_blue)
    @starburst_bitmaps[14].set_pixel(3, 3, starburst_cyan)
        
    @starburst_bitmaps[15] = Bitmap.new(7, 7)
    @starburst_bitmaps[15].fill_rect(2, 1, 3, 5, starburst_bluetwo)
    @starburst_bitmaps[15].fill_rect(1, 2, 5, 3, starburst_bluetwo)
    @starburst_bitmaps[15].fill_rect(2, 2, 3, 3, starburst_blue)
    @starburst_bitmaps[15].fill_rect(3, 1, 1, 5, starburst_blue)
    @starburst_bitmaps[15].fill_rect(1, 3, 5, 1, starburst_blue)
    @starburst_bitmaps[15].fill_rect(3, 2, 1, 3, starburst_cyan)
    @starburst_bitmaps[15].fill_rect(2, 3, 3, 1, starburst_cyan)
    @starburst_bitmaps[15].set_pixel(3, 3, starburst_cyan)
    
    @starburst_bitmaps[16] = Bitmap.new(8, 8)
    @starburst_bitmaps[16].fill_rect(3, 2, 1, 3, starburst_blue)
    @starburst_bitmaps[16].fill_rect(2, 3, 3, 1, starburst_blue)
    @starburst_bitmaps[16].set_pixel(3, 3, starburst_cyan)
    
    @starburst_bitmaps[17] = Bitmap.new(8, 8)
    @starburst_bitmaps[17].fill_rect(3, 2, 1, 3, starburst_violet)
    @starburst_bitmaps[17].fill_rect(2, 3, 3, 1, starburst_violet)
    @starburst_bitmaps[17].set_pixel(3, 3, starburst_purple)
    
    @starburst_bitmaps[18] = Bitmap.new(7, 7)
    @starburst_bitmaps[18].set_pixel(1, 1, starburst_violettwo)
    @starburst_bitmaps[18].set_pixel(5, 1, starburst_violettwo)
    @starburst_bitmaps[18].set_pixel(2, 2, starburst_violettwo)
    @starburst_bitmaps[18].set_pixel(4, 2, starburst_violettwo)
    @starburst_bitmaps[18].set_pixel(3, 3, starburst_violet)
    @starburst_bitmaps[18].set_pixel(2, 4, starburst_violet)
    @starburst_bitmaps[18].set_pixel(4, 4, starburst_violet)
    @starburst_bitmaps[18].set_pixel(1, 5, starburst_violet)
    @starburst_bitmaps[18].set_pixel(5, 5, starburst_purple)
    
    @starburst_bitmaps[19] = Bitmap.new(7, 7)
    @starburst_bitmaps[19].fill_rect(3, 1, 1, 5, starburst_violettwo)
    @starburst_bitmaps[19].fill_rect(1, 3, 5, 1, starburst_violettwo)
    @starburst_bitmaps[19].fill_rect(3, 2, 1, 3, starburst_violet)
    @starburst_bitmaps[19].fill_rect(2, 3, 3, 1, starburst_violet)
    @starburst_bitmaps[19].set_pixel(3, 3, starburst_violet)
        
    @starburst_bitmaps[20] = Bitmap.new(7, 7)
    @starburst_bitmaps[20].fill_rect(2, 1, 3, 5, starburst_violettwo)
    @starburst_bitmaps[20].fill_rect(1, 2, 5, 3, starburst_violettwo)
    @starburst_bitmaps[20].fill_rect(2, 2, 3, 3, starburst_violet)
    @starburst_bitmaps[20].fill_rect(3, 1, 1, 5, starburst_violet)
    @starburst_bitmaps[20].fill_rect(1, 3, 5, 1, starburst_violet)
    @starburst_bitmaps[20].fill_rect(3, 2, 1, 3, starburst_purple)
    @starburst_bitmaps[20].fill_rect(2, 3, 3, 1, starburst_purple)
    @starburst_bitmaps[20].set_pixel(3, 3, starburst_purple)
    
    @starburst_bitmaps[21] = Bitmap.new(7, 7)
    @starburst_bitmaps[21].fill_rect(2, 1, 3, 5, starburst_violet)
    @starburst_bitmaps[21].fill_rect(1, 2, 5, 3, starburst_violet)
    @starburst_bitmaps[21].fill_rect(3, 0, 1, 7, starburst_violettwo)
    @starburst_bitmaps[21].fill_rect(0, 3, 7, 1, starburst_violettwo)
    @starburst_bitmaps[21].fill_rect(2, 2, 3, 3, starburst_purple)
    @starburst_bitmaps[21].fill_rect(3, 2, 1, 3, starburst_violet)
    @starburst_bitmaps[21].fill_rect(2, 3, 3, 1, starburst_violet)
    @starburst_bitmaps[21].set_pixel(3, 3, starburst_purple)
    
    @starburst_bitmaps[22] = Bitmap.new(8, 8)
    @starburst_bitmaps[22].fill_rect(3, 2, 1, 3, starburst_violet)
    @starburst_bitmaps[22].fill_rect(2, 3, 3, 1, starburst_violet)
    @starburst_bitmaps[22].set_pixel(3, 3, starburst_purple)
    
    @starburst_bitmaps[23] = Bitmap.new(8, 8)
    @starburst_bitmaps[23].fill_rect(3, 2, 1, 3, starburst_red)
    @starburst_bitmaps[23].fill_rect(2, 3, 3, 1, starburst_red)
    @starburst_bitmaps[23].set_pixel(3, 3, starburst_pink)
    
    @starburst_bitmaps[24] = Bitmap.new(7, 7)
    @starburst_bitmaps[24].set_pixel(1, 1, starburst_redtwo)
    @starburst_bitmaps[24].set_pixel(5, 1, starburst_redtwo)
    @starburst_bitmaps[24].set_pixel(2, 2, starburst_redtwo)
    @starburst_bitmaps[24].set_pixel(4, 2, starburst_redtwo)
    @starburst_bitmaps[24].set_pixel(3, 3, starburst_red)
    @starburst_bitmaps[24].set_pixel(2, 4, starburst_red)
    @starburst_bitmaps[24].set_pixel(4, 4, starburst_red)
    @starburst_bitmaps[24].set_pixel(1, 5, starburst_red)
    @starburst_bitmaps[24].set_pixel(5, 5, starburst_pink)
    
    @starburst_bitmaps[25] = Bitmap.new(7, 7)
    @starburst_bitmaps[25].fill_rect(3, 1, 1, 5, starburst_redtwo)
    @starburst_bitmaps[25].fill_rect(1, 3, 5, 1, starburst_redtwo)
    @starburst_bitmaps[25].fill_rect(3, 2, 1, 3, starburst_red)
    @starburst_bitmaps[25].fill_rect(2, 3, 3, 1, starburst_red)
    @starburst_bitmaps[25].set_pixel(3, 3, starburst_pink)
        
    @starburst_bitmaps[26] = Bitmap.new(7, 7)
    @starburst_bitmaps[26].fill_rect(2, 1, 3, 5, starburst_redtwo)
    @starburst_bitmaps[26].fill_rect(1, 2, 5, 3, starburst_redtwo)
    @starburst_bitmaps[26].fill_rect(2, 2, 3, 3, starburst_red)
    @starburst_bitmaps[26].fill_rect(3, 1, 1, 5, starburst_red)
    @starburst_bitmaps[26].fill_rect(1, 3, 5, 1, starburst_red)
    @starburst_bitmaps[26].fill_rect(3, 2, 1, 3, starburst_pink)
    @starburst_bitmaps[26].fill_rect(2, 3, 3, 1, starburst_pink)
    @starburst_bitmaps[26].set_pixel(3, 3, starburst_pink)
    
    @starburst_bitmaps[27] = Bitmap.new(7, 7)
    @starburst_bitmaps[27].fill_rect(2, 1, 3, 5, starburst_red)
    @starburst_bitmaps[27].fill_rect(1, 2, 5, 3, starburst_red)
    @starburst_bitmaps[27].fill_rect(3, 0, 1, 7, starburst_redtwo)
    @starburst_bitmaps[27].fill_rect(0, 3, 7, 1, starburst_redtwo)
    @starburst_bitmaps[27].fill_rect(2, 2, 3, 3, starburst_pink)
    @starburst_bitmaps[27].fill_rect(3, 2, 1, 3, starburst_red)
    @starburst_bitmaps[27].fill_rect(2, 3, 3, 1, starburst_red)
    @starburst_bitmaps[27].set_pixel(3, 3, starburst_pink)
    
    @starburst_bitmaps[28] = Bitmap.new(8, 8)
    @starburst_bitmaps[28].fill_rect(3, 2, 1, 3, starburst_red)
    @starburst_bitmaps[28].fill_rect(2, 3, 3, 1, starburst_red)
    @starburst_bitmaps[28].set_pixel(3, 3, starburst_pink)
    
    @starburst_bitmaps[29] = Bitmap.new(8, 8)
    @starburst_bitmaps[29].fill_rect(3, 2, 1, 3, starburst_orange)
    @starburst_bitmaps[29].fill_rect(2, 3, 3, 1, starburst_orange)
    @starburst_bitmaps[29].set_pixel(3, 3, starburst_lightorange)
    
    @starburst_bitmaps[30] = Bitmap.new(7, 7)
    @starburst_bitmaps[30].set_pixel(1, 1, starburst_orangetwo)
    @starburst_bitmaps[30].set_pixel(5, 1, starburst_orangetwo)
    @starburst_bitmaps[30].set_pixel(2, 2, starburst_orangetwo)
    @starburst_bitmaps[30].set_pixel(4, 2, starburst_orangetwo)
    @starburst_bitmaps[30].set_pixel(3, 3, starburst_orange)
    @starburst_bitmaps[30].set_pixel(2, 4, starburst_orange)
    @starburst_bitmaps[30].set_pixel(4, 4, starburst_orange)
    @starburst_bitmaps[30].set_pixel(1, 5, starburst_orange)
    @starburst_bitmaps[30].set_pixel(5, 5, starburst_lightorange)
    
    @starburst_bitmaps[31] = Bitmap.new(7, 7)
    @starburst_bitmaps[31].fill_rect(3, 1, 1, 5, starburst_orangetwo)
    @starburst_bitmaps[31].fill_rect(1, 3, 5, 1, starburst_orangetwo)
    @starburst_bitmaps[31].fill_rect(3, 2, 1, 3, starburst_orange)
    @starburst_bitmaps[31].fill_rect(2, 3, 3, 1, starburst_orange)
    @starburst_bitmaps[31].set_pixel(3, 3, starburst_lightorange)
        
    @starburst_bitmaps[32] = Bitmap.new(7, 7)
    @starburst_bitmaps[32].fill_rect(2, 1, 3, 5, starburst_orangetwo)
    @starburst_bitmaps[32].fill_rect(1, 2, 5, 3, starburst_orangetwo)
    @starburst_bitmaps[32].fill_rect(2, 2, 3, 3, starburst_orange)
    @starburst_bitmaps[32].fill_rect(3, 1, 1, 5, starburst_orange)
    @starburst_bitmaps[32].fill_rect(1, 3, 5, 1, starburst_orange)
    @starburst_bitmaps[32].fill_rect(3, 2, 1, 3, starburst_lightorange)
    @starburst_bitmaps[32].fill_rect(2, 3, 3, 1, starburst_lightorange)
    @starburst_bitmaps[32].set_pixel(3, 3, starburst_lightorange)
    
    @starburst_bitmaps[33] = Bitmap.new(7, 7)
    @starburst_bitmaps[33].fill_rect(2, 1, 3, 5, starburst_orange)
    @starburst_bitmaps[33].fill_rect(1, 2, 5, 3, starburst_orange)
    @starburst_bitmaps[33].fill_rect(3, 0, 1, 7, starburst_orangetwo)
    @starburst_bitmaps[33].fill_rect(0, 3, 7, 1, starburst_orangetwo)
    @starburst_bitmaps[33].fill_rect(2, 2, 3, 3, starburst_lightorange)
    @starburst_bitmaps[33].fill_rect(3, 2, 1, 3, starburst_orange)
    @starburst_bitmaps[33].fill_rect(2, 3, 3, 1, starburst_orange)
    @starburst_bitmaps[33].set_pixel(3, 3, starburst_lightorange)
    
    @starburst_bitmaps[34] = Bitmap.new(8, 8)
    @starburst_bitmaps[34].fill_rect(3, 2, 1, 3, starburst_orange)
    @starburst_bitmaps[34].fill_rect(2, 3, 3, 1, starburst_orange)
    @starburst_bitmaps[34].set_pixel(3, 3, starburst_lightorange)
    
    @starburst_bitmaps[35] = Bitmap.new(8, 8)
    @starburst_bitmaps[35].set_pixel(3, 3, starburst_lightorange)    
#-------------------------------------------------------------------------------      
    @monostarburst_bitmaps = []
    
    @monostarburst_bitmaps[0] = Bitmap.new(8, 8)
    @monostarburst_bitmaps[0].set_pixel(3, 3, starburst_lightyellow)
    
    @monostarburst_bitmaps[1] = Bitmap.new(8, 8)
    @monostarburst_bitmaps[1].fill_rect(3, 2, 1, 3, starburst_yellow)
    @monostarburst_bitmaps[1].fill_rect(2, 3, 3, 1, starburst_yellow)
    @monostarburst_bitmaps[1].set_pixel(3, 3, starburst_lightyellow)
    
    @monostarburst_bitmaps[2] = Bitmap.new(7, 7)
    @monostarburst_bitmaps[2].set_pixel(1, 1, starburst_yellowtwo)
    @monostarburst_bitmaps[2].set_pixel(5, 1, starburst_yellowtwo)
    @monostarburst_bitmaps[2].set_pixel(2, 2, starburst_yellowtwo)
    @monostarburst_bitmaps[2].set_pixel(4, 2, starburst_yellowtwo)
    @monostarburst_bitmaps[2].set_pixel(3, 3, starburst_yellow)
    @monostarburst_bitmaps[2].set_pixel(2, 4, starburst_yellow)
    @monostarburst_bitmaps[2].set_pixel(4, 4, starburst_yellow)
    @monostarburst_bitmaps[2].set_pixel(1, 5, starburst_yellow)
    @monostarburst_bitmaps[2].set_pixel(5, 5, starburst_lightyellow)
    
    @monostarburst_bitmaps[3] = Bitmap.new(7, 7)
    @monostarburst_bitmaps[3].fill_rect(3, 1, 1, 5, starburst_yellowtwo)
    @monostarburst_bitmaps[3].fill_rect(1, 3, 5, 1, starburst_yellowtwo)
    @monostarburst_bitmaps[3].fill_rect(3, 2, 1, 3, starburst_yellow)
    @monostarburst_bitmaps[3].fill_rect(2, 3, 3, 1, starburst_yellow)
    @monostarburst_bitmaps[3].set_pixel(3, 3, starburst_lightyellow)
        
    @monostarburst_bitmaps[4] = Bitmap.new(7, 7)
    @monostarburst_bitmaps[4].fill_rect(2, 1, 3, 5, starburst_yellowtwo)
    @monostarburst_bitmaps[4].fill_rect(1, 2, 5, 3, starburst_yellowtwo)
    @monostarburst_bitmaps[4].fill_rect(2, 2, 3, 3, starburst_yellow)
    @monostarburst_bitmaps[4].fill_rect(3, 1, 1, 5, starburst_yellow)
    @monostarburst_bitmaps[4].fill_rect(1, 3, 5, 1, starburst_yellow)
    @monostarburst_bitmaps[4].fill_rect(3, 2, 1, 3, starburst_lightyellow)
    @monostarburst_bitmaps[4].fill_rect(2, 3, 3, 1, starburst_lightyellow)
    @monostarburst_bitmaps[4].set_pixel(3, 3, starburst_lightyellow)
    
    @monostarburst_bitmaps[5] = Bitmap.new(7, 7)
    @monostarburst_bitmaps[5].fill_rect(2, 1, 3, 5, starburst_yellow)
    @monostarburst_bitmaps[5].fill_rect(1, 2, 5, 3, starburst_yellow)
    @monostarburst_bitmaps[5].fill_rect(3, 0, 1, 7, starburst_yellowtwo)
    @monostarburst_bitmaps[5].fill_rect(0, 3, 7, 1, starburst_yellowtwo)
    @monostarburst_bitmaps[5].fill_rect(2, 2, 3, 3, starburst_lightyellow)
    @monostarburst_bitmaps[5].fill_rect(3, 2, 1, 3, starburst_yellow)
    @monostarburst_bitmaps[5].fill_rect(2, 3, 3, 1, starburst_yellow)
    @monostarburst_bitmaps[5].set_pixel(3, 3, starburst_lightyellow)
    
    @monostarburst_bitmaps[6] = Bitmap.new(8, 8)
    @monostarburst_bitmaps[6].fill_rect(3, 2, 1, 3, starburst_yellow)
    @monostarburst_bitmaps[6].fill_rect(2, 3, 3, 1, starburst_yellow)
    @monostarburst_bitmaps[6].set_pixel(3, 3, starburst_lightyellow)
    
    @monostarburst_bitmaps[7] = Bitmap.new(8, 8)
    @monostarburst_bitmaps[7].set_pixel(3, 3, starburst_lightyellow) 
#-------------------------------------------------------------------------------    
    
    @user_bitmaps = []
    update_user_defined
  end
  
  def update_user_defined
    for image in @user_bitmaps
      image.dispose
    end
    
    for name in $WEATHER_IMAGES
      @user_bitmaps.push(RPG::Cache.picture(name))
    end
    for sprite in @sprites
      sprite.bitmap = @user_bitmaps[rand(@user_bitmaps.size)]
    end
  end
end

class Scene_Map
  def weather
    @spriteset.weather  
  end
end

class Spriteset_Map
  attr_accessor :weather
end