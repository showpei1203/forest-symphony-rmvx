#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Spriteset_Map
# 【用途】建立地圖 Tilemap、Parallax、Character、Fog／Weather、Picture 與 Timer 等視覺層。
# 【主要機制】由對應 Spriteset 或 Scene 自動建立；視覺插件可能在後方擴充 update／dispose。
# 【主要影響】Spriteset_Map
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】保持目前已驗證的相對順序；搬動前先反查 class reopen／alias／事件入口。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁直接引用：TileA1、TileA2、TileA3、TileA4、TileA5、TileB、TileC、TileD、TileE、Shadow。刪除／改名素材前必須反查其他腳本與 Data／事件是否共用。
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
# ** Spriteset_Map
#------------------------------------------------------------------------------
#  這個類用來把地圖畫面的精靈物設和地圖元件等元素集合到一起。
#  這個類作為 Scene_Map 類的內部類使用。
#==============================================================================

class Spriteset_Map
  #--------------------------------------------------------------------------
  # * 物件初始化
  #--------------------------------------------------------------------------
  def initialize
    create_viewports
    create_tilemap
    create_parallax
    create_characters
    create_shadow
    create_weather
    create_pictures
    create_timer
    update
  end
  #--------------------------------------------------------------------------
  # * 創建視口
  #--------------------------------------------------------------------------
  def create_viewports
    @viewport1 = Viewport.new(0, 0, 544, 416)
    @viewport2 = Viewport.new(0, 0, 544, 416)
    @viewport3 = Viewport.new(0, 0, 544, 416)
    @viewport2.z = 50
    @viewport3.z = 100
  end
  #--------------------------------------------------------------------------
  # * 創建元件地圖
  #--------------------------------------------------------------------------
  def create_tilemap
    @tilemap = Tilemap.new(@viewport1)
    @tilemap.bitmaps[0] = Cache.system("TileA1")
    @tilemap.bitmaps[1] = Cache.system("TileA2")
    @tilemap.bitmaps[2] = Cache.system("TileA3")
    @tilemap.bitmaps[3] = Cache.system("TileA4")
    @tilemap.bitmaps[4] = Cache.system("TileA5")
    @tilemap.bitmaps[5] = Cache.system("TileB")
    @tilemap.bitmaps[6] = Cache.system("TileC")
    @tilemap.bitmaps[7] = Cache.system("TileD")
    @tilemap.bitmaps[8] = Cache.system("TileE")
    @tilemap.map_data = $game_map.data
    @tilemap.passages = $game_map.passages
  end
  #--------------------------------------------------------------------------
  # * 創建遠景圖
  #--------------------------------------------------------------------------
  def create_parallax
    @parallax = Plane.new(@viewport1)
    @parallax.z = -100
  end
  #--------------------------------------------------------------------------
  # * 創建人物活動塊
  #--------------------------------------------------------------------------
  def create_characters
    @character_sprites = []
    for i in $game_map.events.keys.sort
      sprite = Sprite_Character.new(@viewport1, $game_map.events[i])
      @character_sprites.push(sprite)
    end
    for vehicle in $game_map.vehicles
      sprite = Sprite_Character.new(@viewport1, vehicle)
      @character_sprites.push(sprite)
    end
    @character_sprites.push(Sprite_Character.new(@viewport1, $game_player))
  end
  #--------------------------------------------------------------------------
  # * 創建飛艇陰影的精靈物設
  #--------------------------------------------------------------------------
  def create_shadow
    @shadow_sprite = Sprite.new(@viewport1)
    @shadow_sprite.bitmap = Cache.system("Shadow")
    @shadow_sprite.ox = @shadow_sprite.bitmap.width / 2
    @shadow_sprite.oy = @shadow_sprite.bitmap.height
    @shadow_sprite.z = 180
  end
  #--------------------------------------------------------------------------
  # * 創建天氣圖形
  #--------------------------------------------------------------------------
  def create_weather
    @weather = Spriteset_Weather.new(@viewport2)
  end
  #--------------------------------------------------------------------------
  # * 創建顯示圖片所用的精靈物設
  #--------------------------------------------------------------------------
  def create_pictures
    @picture_sprites = []
    for i in 1..20
      @picture_sprites.push(Sprite_Picture.new(@viewport2,
        $game_map.screen.pictures[i]))
    end
  end
  #--------------------------------------------------------------------------
  # * 創建計時器所用之精靈物設
  #--------------------------------------------------------------------------
  def create_timer
    @timer_sprite = Sprite_Timer.new(@viewport2)
  end
  #--------------------------------------------------------------------------
  # * 清除顯示資訊
  #--------------------------------------------------------------------------
  def dispose
    dispose_tilemap
    dispose_parallax
    dispose_characters
    dispose_shadow
    dispose_weather
    dispose_pictures
    dispose_timer
    dispose_viewports
  end
  #--------------------------------------------------------------------------
  # * 清除元件地圖顯示資訊
  #--------------------------------------------------------------------------
  def dispose_tilemap
    @tilemap.dispose
  end
  #--------------------------------------------------------------------------
  # * 清除遠景圖顯示資訊
  #--------------------------------------------------------------------------
  def dispose_parallax
    @parallax.dispose
  end
  #--------------------------------------------------------------------------
  # * 清除人物活動塊顯示資訊
  #--------------------------------------------------------------------------
  def dispose_characters
    for sprite in @character_sprites
      sprite.dispose
    end
  end
  #--------------------------------------------------------------------------
  # * 清除飛艇陰影精靈物設的顯示資訊
  #--------------------------------------------------------------------------
  def dispose_shadow
    @shadow_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # * 清除天氣圖形顯示資訊
  #--------------------------------------------------------------------------
  def dispose_weather
    @weather.dispose
  end
  #--------------------------------------------------------------------------
  # * 清除圖片所用之精靈物設的顯示資訊
  #--------------------------------------------------------------------------
  def dispose_pictures
    for sprite in @picture_sprites
      sprite.dispose
    end
  end
  #--------------------------------------------------------------------------
  # * 清除計時器所用的精靈物設顯示資訊
  #--------------------------------------------------------------------------
  def dispose_timer
    @timer_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # * 清除視口顯示資訊
  #--------------------------------------------------------------------------
  def dispose_viewports
    @viewport1.dispose
    @viewport2.dispose
    @viewport3.dispose
  end
  #--------------------------------------------------------------------------
  # * 更新幀
  #--------------------------------------------------------------------------
  def update
    update_tilemap
    update_parallax
    update_characters
    update_shadow
    update_weather
    update_pictures
    update_timer
    update_viewports
  end
  #--------------------------------------------------------------------------
  # * 更新元件地圖顯示資訊
  #--------------------------------------------------------------------------
  def update_tilemap
    @tilemap.ox = $game_map.display_x / 8
    @tilemap.oy = $game_map.display_y / 8
    @tilemap.update
  end
  #--------------------------------------------------------------------------
  # * 更新遠景圖顯示資訊
  #--------------------------------------------------------------------------
  def update_parallax
    if @parallax_name != $game_map.parallax_name
      @parallax_name = $game_map.parallax_name
      if @parallax.bitmap != nil
        @parallax.bitmap.dispose
        @parallax.bitmap = nil
      end
      if @parallax_name != ""
        @parallax.bitmap = Cache.parallax(@parallax_name)
      end
      Graphics.frame_reset
    end
    @parallax.ox = $game_map.calc_parallax_x(@parallax.bitmap)
    @parallax.oy = $game_map.calc_parallax_y(@parallax.bitmap)
  end
  #--------------------------------------------------------------------------
  # * 更新人物活動塊顯示資訊
  #--------------------------------------------------------------------------
  def update_characters
    for sprite in @character_sprites
      sprite.update
    end
  end
  #--------------------------------------------------------------------------
  # * 更新飛艇陰影精靈物設的顯示資訊
  #--------------------------------------------------------------------------
  def update_shadow
    airship = $game_map.airship
    @shadow_sprite.x = airship.screen_x
    @shadow_sprite.y = airship.screen_y + airship.altitude
    @shadow_sprite.opacity = airship.altitude * 8
    @shadow_sprite.update
  end
  #--------------------------------------------------------------------------
  # * 更新天氣圖形顯示資訊
  #--------------------------------------------------------------------------
  def update_weather
    @weather.type = $game_map.screen.weather_type
    @weather.max = $game_map.screen.weather_max
    @weather.ox = $game_map.display_x / 8
    @weather.oy = $game_map.display_y / 8
    @weather.update
  end
  #--------------------------------------------------------------------------
  # * 更新圖片所用之精靈物設的顯示資訊
  #--------------------------------------------------------------------------
  def update_pictures
    for sprite in @picture_sprites
      sprite.update
    end
  end
  #--------------------------------------------------------------------------
  # * 更新計時器所用的精靈物設顯示資訊
  #--------------------------------------------------------------------------
  def update_timer
    @timer_sprite.update
  end
  #--------------------------------------------------------------------------
  # * 更新視口顯示資訊
  #--------------------------------------------------------------------------
  def update_viewports
    @viewport1.tone = $game_map.screen.tone
    @viewport1.ox = $game_map.screen.shake
    @viewport2.color = $game_map.screen.flash_color
    @viewport3.color.set(0, 0, 0, 255 - $game_map.screen.brightness)
    @viewport1.update
    @viewport2.update
    @viewport3.update
  end
end
