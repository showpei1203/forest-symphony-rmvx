#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Sprite_Base
# 【用途】VX Sprite 動畫父類，管理 RPG::Animation 播放、Cell Sprite 與 Flash。
# 【主要機制】由對應 Spriteset 或 Scene 自動建立；視覺插件可能在後方擴充 update／dispose。
# 【主要影響】Sprite_Base
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
# ** Sprite_Base
#------------------------------------------------------------------------------
#  一個具有處理動畫顯示功能的活動塊物設（精靈物設）。
#==============================================================================

class Sprite_Base < Sprite
  #--------------------------------------------------------------------------
  # * 類變數
  #--------------------------------------------------------------------------
  @@animations = []
  @@_reference_count = {}
  #--------------------------------------------------------------------------
  # * 物件初始化
  #     viewport : 顯示視口
  #--------------------------------------------------------------------------
  def initialize(viewport = nil)
    super(viewport)
    @use_sprite = true          # 精靈物設使用標幟
    @animation_duration = 0     # 動畫播放持續時間
  end
  #--------------------------------------------------------------------------
  # * 清除顯示
  #--------------------------------------------------------------------------
  def dispose
    super
    dispose_animation
  end
  #--------------------------------------------------------------------------
  # * 更新幀
  #--------------------------------------------------------------------------
  def update
    super
    if @animation != nil
      @animation_duration -= 1
      if @animation_duration % 4 == 0
        update_animation
      end
    end
    @@animations.clear
  end
  #--------------------------------------------------------------------------
  # * 判定動畫正在顯示
  #--------------------------------------------------------------------------
  def animation?
    return @animation != nil
  end
  #--------------------------------------------------------------------------
  # * 開始播放動畫
  #--------------------------------------------------------------------------
  def start_animation(animation, mirror = false)
    dispose_animation
    @animation = animation
    return if @animation == nil
    @animation_mirror = mirror
    @animation_duration = @animation.frame_max * 4 + 1
    load_animation_bitmap
    @animation_sprites = []
    if @animation.position != 3 or not @@animations.include?(animation)
      if @use_sprite
        for i in 0..15
          sprite = ::Sprite.new(viewport)
          sprite.visible = false
          @animation_sprites.push(sprite)
        end
        unless @@animations.include?(animation)
          @@animations.push(animation)
        end
      end
    end
    if @animation.position == 3
      if viewport == nil
        @animation_ox = 544 / 2
        @animation_oy = 416 / 2
      else
        @animation_ox = viewport.rect.width / 2
        @animation_oy = viewport.rect.height / 2
      end
    else
      @animation_ox = x - ox + width / 2
      @animation_oy = y - oy + height / 2
      if @animation.position == 0
        @animation_oy -= height / 2
      elsif @animation.position == 2
        @animation_oy += height / 2
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 載入並讀取動畫膠片圖檔
  #--------------------------------------------------------------------------
  def load_animation_bitmap
    animation1_name = @animation.animation1_name
    animation1_hue = @animation.animation1_hue
    animation2_name = @animation.animation2_name
    animation2_hue = @animation.animation2_hue
    @animation_bitmap1 = Cache.animation(animation1_name, animation1_hue)
    @animation_bitmap2 = Cache.animation(animation2_name, animation2_hue)
    if @@_reference_count.include?(@animation_bitmap1)
      @@_reference_count[@animation_bitmap1] += 1
    else
      @@_reference_count[@animation_bitmap1] = 1
    end
    if @@_reference_count.include?(@animation_bitmap2)
      @@_reference_count[@animation_bitmap2] += 1
    else
      @@_reference_count[@animation_bitmap2] = 1
    end
    Graphics.frame_reset
  end
  #--------------------------------------------------------------------------
  # * 清除動畫顯示
  #--------------------------------------------------------------------------
  def dispose_animation
    if @animation_bitmap1 != nil
      @@_reference_count[@animation_bitmap1] -= 1
      if @@_reference_count[@animation_bitmap1] == 0
        @animation_bitmap1.dispose
      end
    end
    if @animation_bitmap2 != nil
      @@_reference_count[@animation_bitmap2] -= 1
      if @@_reference_count[@animation_bitmap2] == 0
        @animation_bitmap2.dispose
      end
    end
    if @animation_sprites != nil
      for sprite in @animation_sprites
        sprite.dispose
      end
      @animation_sprites = nil
      @animation = nil
    end
    @animation_bitmap1 = nil
    @animation_bitmap2 = nil
  end
  #--------------------------------------------------------------------------
  # * 更新動畫內容顯示
  #--------------------------------------------------------------------------
  def update_animation
    if @animation_duration > 0
      frame_index = @animation.frame_max - (@animation_duration + 3) / 4
      animation_set_sprites(@animation.frames[frame_index])
      for timing in @animation.timings
        if timing.frame == frame_index
          animation_process_timing(timing)
        end
      end
    else
      dispose_animation
    end
  end
  #--------------------------------------------------------------------------
  # * 設置動畫精靈物設
  #     frame : 幀數據（RPG::Animation::Frame）
  #--------------------------------------------------------------------------
  def animation_set_sprites(frame)
    cell_data = frame.cell_data
    for i in 0..15
      sprite = @animation_sprites[i]
      next if sprite == nil
      pattern = cell_data[i, 0]
      if pattern == nil or pattern == -1
        sprite.visible = false
        next
      end
      if pattern < 100
        sprite.bitmap = @animation_bitmap1
      else
        sprite.bitmap = @animation_bitmap2
      end
      sprite.visible = true
      sprite.src_rect.set(pattern % 5 * 192, pattern % 100 / 5 * 192, 192, 192)
      position = @animation.position
      if position == 3
        if self.viewport != nil
          sprite.x = self.viewport.rect.width / 2
          sprite.y = self.viewport.rect.height / 2
        else
          sprite.x = 272
          sprite.y = 208
        end
      else
        sprite.x = self.x - self.ox + self.src_rect.width / 2
        sprite.y = self.y - self.oy + self.src_rect.height / 2
        sprite.y -= self.src_rect.height / 2 if position == 0
        sprite.y += self.src_rect.height / 2 if position == 2
      end
      if @animation_mirror
        sprite.x -= cell_data[i, 1]
        sprite.y += cell_data[i, 2]
        sprite.angle = (360 - cell_data[i, 4])
        sprite.mirror = (cell_data[i, 5] == 0)
      else
        sprite.x += cell_data[i, 1]
        sprite.y += cell_data[i, 2]
        sprite.angle = cell_data[i, 4]
        sprite.mirror = (cell_data[i, 5] == 1)
      end
      sprite.z = self.z + 300 + i
      sprite.ox = 96
      sprite.oy = 96
      sprite.zoom_x = cell_data[i, 3] / 100.0
      sprite.zoom_y = cell_data[i, 3] / 100.0
      sprite.opacity = cell_data[i, 6] * self.opacity / 255.0
      sprite.blend_type = cell_data[i, 7]
    end
  end
  #--------------------------------------------------------------------------
  # * 動畫精靈物設所需橫座標數值的設定
  #--------------------------------------------------------------------------
  def x=(x)
    sx = x - self.x
    if sx != 0
      if @animation_sprites != nil
        for i in 0..15
          @animation_sprites[i].x += sx
        end
      end
    end
    super
  end
  #--------------------------------------------------------------------------
  # * 動畫精靈物設所需縱座標數值的設定
  #--------------------------------------------------------------------------
  def y=(y)
    sy = y - self.y
    if sy != 0
      if @animation_sprites != nil
        for i in 0..15
          @animation_sprites[i].y += sy
        end
      end
    end
    super
  end
  #--------------------------------------------------------------------------
  # * SE播放以及畫面閃爍的處理
  #     timing : 時間安排資料（RPG::Animation::Timing）
  #--------------------------------------------------------------------------
  def animation_process_timing(timing)
    timing.se.play
    case timing.flash_scope
    when 1
      self.flash(timing.flash_color, timing.flash_duration * 4)
    when 2
      if viewport != nil
        viewport.flash(timing.flash_color, timing.flash_duration * 4)
      end
    when 3
      self.flash(nil, timing.flash_duration * 4)
    end
  end
end
