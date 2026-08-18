#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Sprite_Character
# 【用途】把 Game_Character 顯示為地圖 Sprite，處理 Character/Tileset、Bush、Balloon 與動畫。
# 【主要機制】由對應 Spriteset 或 Scene 自動建立；視覺插件可能在後方擴充 update／dispose。
# 【主要影響】Sprite_Character
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：BALLOON_WAIT。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】保持目前已驗證的相對順序；搬動前先反查 class reopen／alias／事件入口。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁直接引用：TileB、TileC、TileD、TileE、Balloon。刪除／改名素材前必須反查其他腳本與 Data／事件是否共用。
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
# ** Sprite_Character
#------------------------------------------------------------------------------
#  一個用來顯示人物的精靈物設。
#  它監視 Game_Character 類的一個實例並同步改變自身的顯示狀態。
#==============================================================================

class Sprite_Character < Sprite_Base
  #--------------------------------------------------------------------------
  # * 常數
  #--------------------------------------------------------------------------
  BALLOON_WAIT = 12                  # 等待浮動圖示末幀的耗時
  #--------------------------------------------------------------------------
  # * 宣告執行個體變數
  #--------------------------------------------------------------------------
  attr_accessor :character
  #--------------------------------------------------------------------------
  # * 物件初始化
  #     viewport  : 顯示視口
  #     character : 事件（Game_Character）
  #--------------------------------------------------------------------------
  def initialize(viewport, character = nil)
    super(viewport)
    @character = character
    @balloon_duration = 0
    update
  end
  #--------------------------------------------------------------------------
  # * 清除顯示
  #--------------------------------------------------------------------------
  def dispose
    dispose_balloon
    super
  end
  #--------------------------------------------------------------------------
  # * 更新幀
  #--------------------------------------------------------------------------
  def update
    super
    update_bitmap
    self.visible = (not @character.transparent)
    update_src_rect
    self.x = @character.screen_x
    self.y = @character.screen_y
    self.z = @character.screen_z
    self.opacity = @character.opacity
    self.blend_type = @character.blend_type
    self.bush_depth = @character.bush_depth
    update_balloon
    if @character.animation_id != 0
      animation = $data_animations[@character.animation_id]
      start_animation(animation)
      @character.animation_id = 0
    end
    if @character.balloon_id != 0
      @balloon_id = @character.balloon_id
      start_balloon
      @character.balloon_id = 0
    end
  end
  #--------------------------------------------------------------------------
  # * 獲取包含指定地圖元件的資訊的地圖元件圖像
  #     tile_id : Tile ID
  #--------------------------------------------------------------------------
  def tileset_bitmap(tile_id)
    set_number = tile_id / 256
    return Cache.system("TileB") if set_number == 0
    return Cache.system("TileC") if set_number == 1
    return Cache.system("TileD") if set_number == 2
    return Cache.system("TileE") if set_number == 3
    return nil
  end
  #--------------------------------------------------------------------------
  # * 更新要轉印的原始點陣圖
  #--------------------------------------------------------------------------
  def update_bitmap
    if @tile_id != @character.tile_id or
       @character_name != @character.character_name or
       @character_index != @character.character_index
      @tile_id = @character.tile_id
      @character_name = @character.character_name
      @character_index = @character.character_index
      if @tile_id > 0
        sx = (@tile_id / 128 % 2 * 8 + @tile_id % 8) * 32;
        sy = @tile_id % 256 / 8 % 16 * 32;
        self.bitmap = tileset_bitmap(@tile_id)
        self.src_rect.set(sx, sy, 32, 32)
        self.ox = 16
        self.oy = 32
      else
        self.bitmap = Cache.character(@character_name)
        sign = @character_name[/^[\!\$]./]
        if sign != nil and sign.include?('$')
          @cw = bitmap.width / 3
          @ch = bitmap.height / 4
        else
          @cw = bitmap.width / 12
          @ch = bitmap.height / 8
        end
        self.ox = @cw / 2
        self.oy = @ch
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 更新要轉印的原始矩形區域
  #--------------------------------------------------------------------------
  def update_src_rect
    if @tile_id == 0
      index = @character.character_index
      pattern = @character.pattern < 3 ? @character.pattern : 1
      sx = (index % 4 * 3 + pattern) * @cw
      sy = (index / 4 * 4 + (@character.direction - 2) / 2) * @ch
      self.src_rect.set(sx, sy, @cw, @ch)
    end
  end
  #--------------------------------------------------------------------------
  # * 開始顯示浮動圖示
  #--------------------------------------------------------------------------
  def start_balloon
    dispose_balloon
    @balloon_duration = 8 * 8 + BALLOON_WAIT
    @balloon_sprite = ::Sprite.new(viewport)
    @balloon_sprite.bitmap = Cache.system("Balloon")
    @balloon_sprite.ox = 16
    @balloon_sprite.oy = 32
    update_balloon
  end
  #--------------------------------------------------------------------------
  # * 更新浮動圖示顯示內容
  #--------------------------------------------------------------------------
  def update_balloon
    if @balloon_duration > 0
      @balloon_duration -= 1
      if @balloon_duration == 0
        dispose_balloon
      else
        @balloon_sprite.x = x
        @balloon_sprite.y = y - height
        @balloon_sprite.z = z + 200
        if @balloon_duration < BALLOON_WAIT
          sx = 7 * 32
        else
          sx = (7 - (@balloon_duration - BALLOON_WAIT) / 8) * 32
        end
        sy = (@balloon_id - 1) * 32
        @balloon_sprite.src_rect.set(sx, sy, 32, 32)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 清除浮動圖示顯示
  #--------------------------------------------------------------------------
  def dispose_balloon
    if @balloon_sprite != nil
      @balloon_sprite.dispose
      @balloon_sprite = nil
    end
  end
end
