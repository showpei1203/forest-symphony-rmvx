#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Icy-Variable Bars
# 【用途】保留的 Runtime 元件「Icy-Variable Bars」。
# 【主要機制】主要定義／擴充 Game_Character、Game_Interpreter、Sprite_Character、ICY；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Game_Character、Game_Interpreter、Sprite_Character、ICY、EVENT_BARS
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：MAINBAR、THEBAR、OFFSET_X、OFFSET_Y、Z_OFFSET、OPACITY。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 3 個 alias／方法包裝，載入順序具有語意；登記 $imported：FS Event Variable Bars。
# 【呼叫方式／範例】icy_set_varbar(0, true, 2, 15, "SmlMainBarHP", "SmlMainBar")；icy_set_varbar(0, false)
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
# -*- coding: utf-8 -*-
#==============================================================================
# ■ FS_EventVariableBars v1.0
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2 / Ruby 1.8.1
#
# 完整取代：
#   Icy-Variable Bars
#
# 保留原指令：
#   icy_set_varbar(char_index, active, variable_id, max_value,
#                  value_bar_name, base_bar_name)
#
# char_index：
#   -1 = 玩家
#    0 = 本事件
#    1以上 = 該事件ID
#
# 圖檔位置：
#   Graphics/Pictures/
#
# 範例：
#   icy_set_varbar(0, true, 2, 15, "SmlMainBarHP", "SmlMainBar")
#
# 關閉：
#   icy_set_varbar(0, false)
#
# 修正舊版問題：
#   1. 變數改變後沒有更新@presentvalue，導致此後每幀重畫Bitmap。
#   2. max_value為0時會除以0。
#   3. Game_Character沒有初始化欄位，所有角色每幀嘗試建立空Bar。
#   4. Sprite dispose時沒有釋放自己建立的Bitmap。
#   5. 變數超出0～max時沒有夾值。
#==============================================================================

$imported = {} if $imported == nil
$imported["FS Event Variable Bars"] = "1.0"

module ICY
  module EVENT_BARS
    MAINBAR = "SmlMainBar"
    THEBAR  = "SmlMainBarHP"

    OFFSET_X = 0
    OFFSET_Y = 0
    Z_OFFSET = 200
    OPACITY  = 255
  end
end

class Game_Character

  attr_accessor :icy_bar
  attr_accessor :icy_hpbar
  attr_accessor :icy_maxvar
  attr_accessor :icy_varval
  attr_accessor :icy_active

  unless method_defined?(:fs_event_varbar_initialize_v10)
    alias fs_event_varbar_initialize_v10 initialize
  end

  def initialize
    fs_event_varbar_initialize_v10
    @icy_bar = nil
    @icy_hpbar = nil
    @icy_maxvar = 0
    @icy_varval = 0
    @icy_active = false
  end
end

class Game_Interpreter

  def icy_set_varbar(char_index = 0, active = false, hpvar = 0,
                     maxvalue = 0,
                     varbarname = ICY::EVENT_BARS::THEBAR,
                     mainbarz = ICY::EVENT_BARS::MAINBAR)
    char_index = @event_id if char_index == 0
    target = if char_index == -1
               $game_player
             else
               $game_map.events[char_index]
             end
    return false if target == nil

    target.icy_active = active == true

    if target.icy_active
      target.icy_bar = mainbarz.to_s
      target.icy_hpbar = varbarname.to_s
      target.icy_maxvar = [maxvalue.to_i, 1].max
      target.icy_varval = [hpvar.to_i, 0].max
    end

    return true
  end

  def icy_remove_varbar(char_index = 0)
    return icy_set_varbar(char_index, false)
  end
end

class Sprite_Character

  unless method_defined?(:fs_event_varbar_dispose_v10)
    alias fs_event_varbar_dispose_v10 dispose
  end

  def dispose
    fs_event_varbar_dispose
    fs_event_varbar_dispose_v10
  end

  unless method_defined?(:fs_event_varbar_update_v10)
    alias fs_event_varbar_update_v10 update
  end

  def update
    fs_event_varbar_update_v10
    fs_event_varbar_update
  end

  def fs_event_varbar_active?
    return false if @character == nil
    return false unless @character.icy_active == true
    return false if @character.icy_bar == nil
    return false if @character.icy_hpbar == nil
    return false if @character.icy_bar.to_s.empty?
    return false if @character.icy_hpbar.to_s.empty?
    return false if @character.icy_maxvar.to_i <= 0
    return true
  end

  def fs_event_varbar_config_signature
    return [
      @character.icy_bar.to_s,
      @character.icy_hpbar.to_s,
      @character.icy_varval.to_i,
      @character.icy_maxvar.to_i
    ]
  end

  def fs_event_varbar_value
    variable_id = @character.icy_varval.to_i
    value = $game_variables[variable_id].to_i
    max_value = [@character.icy_maxvar.to_i, 1].max
    value = 0 if value < 0
    value = max_value if value > max_value
    return value
  end

  def fs_event_varbar_update
    unless fs_event_varbar_active?
      fs_event_varbar_dispose
      return
    end

    signature = fs_event_varbar_config_signature
    if @fs_event_varbar_sprite == nil ||
       @fs_event_varbar_sprite.disposed? ||
       @fs_event_varbar_signature != signature
      return unless fs_event_varbar_create
    end

    value = fs_event_varbar_value
    if @fs_event_varbar_last_value != value
      fs_event_varbar_redraw(value)
    end

    fs_event_varbar_update_position
  end

  def fs_event_varbar_create
    fs_event_varbar_dispose

    begin
      @fs_event_varbar_base = Cache.picture(@character.icy_bar.to_s)
      @fs_event_varbar_value_bitmap =
        Cache.picture(@character.icy_hpbar.to_s)
    rescue
      @fs_event_varbar_base = nil
      @fs_event_varbar_value_bitmap = nil
      return false
    end

    return false if @fs_event_varbar_base == nil
    return false if @fs_event_varbar_value_bitmap == nil

    width = [@fs_event_varbar_base.width,
             @fs_event_varbar_value_bitmap.width].max
    height = [@fs_event_varbar_base.height,
              @fs_event_varbar_value_bitmap.height].max

    @fs_event_varbar_sprite = Sprite.new(viewport)
    @fs_event_varbar_sprite.bitmap = Bitmap.new(width, height)
    @fs_event_varbar_sprite.opacity = ICY::EVENT_BARS::OPACITY
    @fs_event_varbar_signature = fs_event_varbar_config_signature
    @fs_event_varbar_last_value = nil

    fs_event_varbar_redraw(fs_event_varbar_value)
    fs_event_varbar_update_position
    return true
  end

  def fs_event_varbar_redraw(value)
    return if @fs_event_varbar_sprite == nil
    return if @fs_event_varbar_sprite.disposed?
    bitmap = @fs_event_varbar_sprite.bitmap
    return if bitmap == nil || bitmap.disposed?

    bitmap.clear
    bitmap.blt(0, 0, @fs_event_varbar_base,
               @fs_event_varbar_base.rect)

    max_value = [@character.icy_maxvar.to_i, 1].max
    width = @fs_event_varbar_value_bitmap.width *
      value.to_i / max_value
    width = 0 if width < 0
    width = @fs_event_varbar_value_bitmap.width if
      width > @fs_event_varbar_value_bitmap.width

    if width > 0
      rect = Rect.new(
        0, 0, width, @fs_event_varbar_value_bitmap.height)
      bitmap.blt(0, 0, @fs_event_varbar_value_bitmap, rect)
    end

    @fs_event_varbar_last_value = value
  end

  def fs_event_varbar_update_position
    return if @fs_event_varbar_sprite == nil
    return if @fs_event_varbar_sprite.disposed?
    bitmap = @fs_event_varbar_sprite.bitmap
    return if bitmap == nil || bitmap.disposed?

    @fs_event_varbar_sprite.x =
      self.x - bitmap.width / 2 + ICY::EVENT_BARS::OFFSET_X
    @fs_event_varbar_sprite.y =
      self.y - self.height - bitmap.height +
      ICY::EVENT_BARS::OFFSET_Y
    @fs_event_varbar_sprite.z =
      self.z + ICY::EVENT_BARS::Z_OFFSET
    @fs_event_varbar_sprite.visible = self.visible
  end

  def fs_event_varbar_dispose
    if @fs_event_varbar_sprite != nil
      unless @fs_event_varbar_sprite.disposed?
        bitmap = @fs_event_varbar_sprite.bitmap
        if bitmap != nil && !bitmap.disposed?
          bitmap.dispose
        end
        @fs_event_varbar_sprite.dispose
      end
    end

    @fs_event_varbar_sprite = nil
    @fs_event_varbar_base = nil
    @fs_event_varbar_value_bitmap = nil
    @fs_event_varbar_signature = nil
    @fs_event_varbar_last_value = nil
  end
end
