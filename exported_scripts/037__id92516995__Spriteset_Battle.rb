#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Spriteset_Battle
# 【用途】建立戰鬥背景、Battler、Animation、Picture 與 Weather 等戰鬥視覺層。
# 【主要機制】由對應 Spriteset 或 Scene 自動建立；視覺插件可能在後方擴充 update／dispose。
# 【主要影響】Spriteset_Battle
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】保持目前已驗證的相對順序；搬動前先反查 class reopen／alias／事件入口。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁直接引用：BattleFloor。刪除／改名素材前必須反查其他腳本與 Data／事件是否共用。
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
# ** Spriteset_Battle
#------------------------------------------------------------------------------
#  這個類用來把作戰畫面的精靈物設集合到一起。
#  這個類作為 Scene_Battle 類的內部類使用。
#==============================================================================

class Spriteset_Battle
  #--------------------------------------------------------------------------
  # * 物件初始化
  #--------------------------------------------------------------------------
  def initialize
    create_viewports
    create_battleback
    create_battlefloor
    create_enemies
    create_actors
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
  # * 創建作戰背景精靈物設
  #--------------------------------------------------------------------------
  def create_battleback
    source = $game_temp.background_bitmap
    bitmap = Bitmap.new(640, 480)
    bitmap.stretch_blt(bitmap.rect, source, source.rect)
    bitmap.radial_blur(90, 12)
    @battleback_sprite = Sprite.new(@viewport1)
    @battleback_sprite.bitmap = bitmap
    @battleback_sprite.ox = 320
    @battleback_sprite.oy = 240
    @battleback_sprite.x = 272
    @battleback_sprite.y = 176
    @battleback_sprite.wave_amp = 8
    @battleback_sprite.wave_length = 240
    @battleback_sprite.wave_speed = 120
  end
  #--------------------------------------------------------------------------
  # * 創建作戰地面圖形精靈物設
  #--------------------------------------------------------------------------
  def create_battlefloor
    @battlefloor_sprite = Sprite.new(@viewport1)
    @battlefloor_sprite.bitmap = Cache.system("BattleFloor")
    @battlefloor_sprite.x = 0
    @battlefloor_sprite.y = 192
    @battlefloor_sprite.z = 1
    @battlefloor_sprite.opacity = 128
  end
  #--------------------------------------------------------------------------
  # * 創建敵人精靈物設
  #--------------------------------------------------------------------------
  def create_enemies
    @enemy_sprites = []
    for enemy in $game_troop.members.reverse
      @enemy_sprites.push(Sprite_Battler.new(@viewport1, enemy))
    end
  end
  #--------------------------------------------------------------------------
  # * 創建參戰主角精靈物設
  #    預設情況下不顯示主角參戰圖，不過如果需要的話，
  #    會建立一個虛擬的精靈物設並用相同的方式處理敵人隊伍和我方隊伍。
  #--------------------------------------------------------------------------
  def create_actors
    @actor_sprites = []
    @actor_sprites.push(Sprite_Battler.new(@viewport1))
    @actor_sprites.push(Sprite_Battler.new(@viewport1))
    @actor_sprites.push(Sprite_Battler.new(@viewport1))
    @actor_sprites.push(Sprite_Battler.new(@viewport1))
  end
  #--------------------------------------------------------------------------
  # * 創建顯示圖片所用之精靈物設
  #--------------------------------------------------------------------------
  def create_pictures
    @picture_sprites = []
    for i in 1..20
      @picture_sprites.push(Sprite_Picture.new(@viewport2,
        $game_troop.screen.pictures[i]))
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
    dispose_battleback_bitmap
    dispose_battleback
    dispose_battlefloor
    dispose_enemies
    dispose_actors
    dispose_pictures
    dispose_timer
    dispose_viewports
  end
  #--------------------------------------------------------------------------
  # * 清除作戰背景圖的顯示資訊
  #--------------------------------------------------------------------------
  def dispose_battleback_bitmap
    @battleback_sprite.bitmap.dispose
  end
  #--------------------------------------------------------------------------
  # * 清除作戰背景之精靈物設的顯示資訊
  #--------------------------------------------------------------------------
  def dispose_battleback
    @battleback_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # * 清除作戰地面圖形之精靈物設的顯示資訊
  #--------------------------------------------------------------------------
  def dispose_battlefloor
    @battlefloor_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # * 清除敵人之精靈物設的顯示資訊
  #--------------------------------------------------------------------------
  def dispose_enemies
    for sprite in @enemy_sprites
      sprite.dispose
    end
  end
  #--------------------------------------------------------------------------
  # * 清除參戰主角之精靈物設的顯示資訊
  #--------------------------------------------------------------------------
  def dispose_actors
    for sprite in @actor_sprites
      sprite.dispose
    end
  end
  #--------------------------------------------------------------------------
  # * 清楚圖片所用之精靈物設的顯示資訊
  #--------------------------------------------------------------------------
  def dispose_pictures
    for sprite in @picture_sprites
      sprite.dispose
    end
  end
  #--------------------------------------------------------------------------
  # * 清除計時器所用之精靈物設的顯示資訊
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
    update_battleback
    update_battlefloor
    update_enemies
    update_actors
    update_pictures
    update_timer
    update_viewports
  end
  #--------------------------------------------------------------------------
  # * 更新作戰背景之精靈物設的顯示資訊
  #--------------------------------------------------------------------------
  def update_battleback
    @battleback_sprite.update
  end
  #--------------------------------------------------------------------------
  # * 更新作戰地面圖形之精靈物設的顯示資訊
  #--------------------------------------------------------------------------
  def update_battlefloor
    @battlefloor_sprite.update
  end
  #--------------------------------------------------------------------------
  # * 更新敵人之精靈物設的顯示資訊
  #--------------------------------------------------------------------------
  def update_enemies
    for sprite in @enemy_sprites
      sprite.update
    end
  end
  #--------------------------------------------------------------------------
  # * 更新參戰主角之精靈物設的顯示資訊
  #--------------------------------------------------------------------------
  def update_actors
    @actor_sprites[0].battler = $game_party.members[0]
    @actor_sprites[1].battler = $game_party.members[1]
    @actor_sprites[2].battler = $game_party.members[2]
    @actor_sprites[3].battler = $game_party.members[3]
    for sprite in @actor_sprites
      sprite.update
    end
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
  # * 更新計時器所用之精靈物設的顯示資訊
  #--------------------------------------------------------------------------
  def update_timer
    @timer_sprite.update
  end
  #--------------------------------------------------------------------------
  # * 更新視口顯示資訊
  #--------------------------------------------------------------------------
  def update_viewports
    @viewport1.tone = $game_troop.screen.tone
    @viewport1.ox = $game_troop.screen.shake
    @viewport2.color = $game_troop.screen.flash_color
    @viewport3.color.set(0, 0, 0, 255 - $game_troop.screen.brightness)
    @viewport1.update
    @viewport2.update
    @viewport3.update
  end
  #--------------------------------------------------------------------------
  # * 判斷是否正在播放動畫
  #--------------------------------------------------------------------------
  def animation?
    for sprite in @enemy_sprites + @actor_sprites
      return true if sprite.animation?
    end
    return false
  end
end
