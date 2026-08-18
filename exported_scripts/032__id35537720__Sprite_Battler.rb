#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Sprite_Battler
# 【用途】把 Game_Battler 顯示為戰鬥 Sprite，處理 Battler 圖、白閃、Blink、Collapse 與位置。
# 【主要機制】由對應 Spriteset 或 Scene 自動建立；視覺插件可能在後方擴充 update／dispose。
# 【主要影響】Sprite_Battler
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：WHITEN、BLINK、APPEAR、DISAPPEAR、COLLAPSE。核心方法除非已確認依賴鏈，不建議直接覆寫。
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
# ** Sprite_Battler
#------------------------------------------------------------------------------
#  一個用來顯示參戰者身圖圖形的精靈物設。
#  它監視 Game_Battler 類的一個實例並同步改變自身的顯示狀態。
#==============================================================================

class Sprite_Battler < Sprite_Base
  #--------------------------------------------------------------------------
  # * 常量
  #--------------------------------------------------------------------------
  WHITEN    = 1                      # 白色閃光（開始行動）
  BLINK     = 2                      # 閃爍（造成傷害）
  APPEAR    = 3                      # 圖像顯出（出現/復活）
  DISAPPEAR = 4                      # 圖像消失（撤退）
  COLLAPSE  = 5                      # 圖像分解（瀕死/掛掉）
  #--------------------------------------------------------------------------
  # * 宣告執行個體變數
  #--------------------------------------------------------------------------
  attr_accessor :battler
  #--------------------------------------------------------------------------
  # * 物件初始化
  #     viewport : 顯示視口
  #     battler  : 參戰者（Game_Battler）
  #--------------------------------------------------------------------------
  def initialize(viewport, battler = nil)
    super(viewport)
    @battler = battler
    @battler_visible = false
    @effect_type = 0            # 作用效果類型
    @effect_duration = 0        # 作用效果持續時間
  end
  #--------------------------------------------------------------------------
  # * 清除顯示
  #--------------------------------------------------------------------------
  def dispose
    if self.bitmap != nil
      self.bitmap.dispose
    end
    super
  end
  #--------------------------------------------------------------------------
  # * 更新幀
  #--------------------------------------------------------------------------
  def update
    super
    if @battler == nil
      self.bitmap = nil
    else
      @use_sprite = @battler.use_sprite?
      if @use_sprite
        self.x = @battler.screen_x
        self.y = @battler.screen_y
        self.z = @battler.screen_z
        update_battler_bitmap
      end
      setup_new_effect
      update_effect
    end
  end
  #--------------------------------------------------------------------------
  # * 更新要轉印的原始點陣圖
  #--------------------------------------------------------------------------
  def update_battler_bitmap
    if @battler.battler_name != @battler_name or
       @battler.battler_hue != @battler_hue
      @battler_name = @battler.battler_name
      @battler_hue = @battler.battler_hue
      self.bitmap = Cache.battler(@battler_name, @battler_hue)
      @width = bitmap.width
      @height = bitmap.height
      self.ox = @width / 2
      self.oy = @height
      if @battler.dead? or @battler.hidden
        self.opacity = 0
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 設置新作用效果
  #--------------------------------------------------------------------------
  def setup_new_effect
    if @battler.white_flash
      @effect_type = WHITEN
      @effect_duration = 16
      @battler.white_flash = false
    end
    if @battler.blink
      @effect_type = BLINK
      @effect_duration = 20
      @battler.blink = false
    end
    if not @battler_visible and @battler.exist?
      @effect_type = APPEAR
      @effect_duration = 16
      @battler_visible = true
    end
    if @battler_visible and @battler.hidden
      @effect_type = DISAPPEAR
      @effect_duration = 32
      @battler_visible = false
    end
    if @battler.collapse
      @effect_type = COLLAPSE
      @effect_duration = 48
      @battler.collapse = false
      @battler_visible = false
    end
    if @battler.animation_id != 0
      animation = $data_animations[@battler.animation_id]
      mirror = @battler.animation_mirror
      start_animation(animation, mirror)
      @battler.animation_id = 0
    end
  end
  #--------------------------------------------------------------------------
  # * 更新作用效果顯示
  #--------------------------------------------------------------------------
  def update_effect
    if @effect_duration > 0
      @effect_duration -= 1
      case @effect_type
      when WHITEN
        update_whiten
      when BLINK
        update_blink
      when APPEAR
        update_appear
      when DISAPPEAR
        update_disappear
      when COLLAPSE
        update_collapse
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 更新白色閃光效果顯示
  #--------------------------------------------------------------------------
  def update_whiten
    self.blend_type = 0
    self.color.set(255, 255, 255, 128)
    self.opacity = 255
    self.color.alpha = 128 - (16 - @effect_duration) * 10
  end
  #--------------------------------------------------------------------------
  # * 更新閃爍效果顯示
  #--------------------------------------------------------------------------
  def update_blink
    self.blend_type = 0
    self.color.set(0, 0, 0, 0)
    self.opacity = 255
    self.visible = (@effect_duration % 10 < 5)
  end
  #--------------------------------------------------------------------------
  # * 更新圖像顯出效果顯示
  #--------------------------------------------------------------------------
  def update_appear
    self.blend_type = 0
    self.color.set(0, 0, 0, 0)
    self.opacity = (16 - @effect_duration) * 16
  end
  #--------------------------------------------------------------------------
  # * 更新圖像消失效果顯示
  #--------------------------------------------------------------------------
  def update_disappear
    self.blend_type = 0
    self.color.set(0, 0, 0, 0)
    self.opacity = 256 - (32 - @effect_duration) * 10
  end
  #--------------------------------------------------------------------------
  # * 更新圖像分解效果顯示
  #--------------------------------------------------------------------------
  def update_collapse
    self.blend_type = 1
    self.color.set(255, 128, 128, 128)
    self.opacity = 256 - (48 - @effect_duration) * 6
  end
end
