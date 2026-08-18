#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_LegacyScripts_SafetyPatch v1.0.14
# 【用途】Forest Symphony 相容／修正頁「FS_LegacyScripts_SafetyPatch v1.0.14」，針對既有系統補正專案需要的行為。
# 【主要機制】通常透過 alias／class reopen 包裝前方實作；它不是可任意搬動的獨立功能，需維持在被修正腳本之後。
# 【主要影響】Window_Base、Window_RingMenu、Scene_RM、Scene_RM2、Game_Party、Scene_Guide、Guide_Book
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：CHARACTER_EXTS、MENU_NEGATIVE_STATE_IDS、VEHICLE_TYPES、SHADOW_SWITCH、PAR_SWITCH、GROUND_SWITCH、SHADOW2_SWITCH、HIDDEN_OVERLAY_SWITCHES。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 37 個 alias／方法包裝，載入順序具有語意；登記 $imported：FS Legacy Scripts Safety Patch、MainMenuMelody、ISS-ParaPassa；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁直接引用：Audio/SE/。刪除／改名素材前必須反查其他腳本與 Data／事件是否共用。
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
# ■ FS_LegacyScripts_SafetyPatch v1.0.14
#------------------------------------------------------------------------------
# 對應：RPG Maker VX / RGSS2
# 安裝：放在本次檢查的所有腳本下方、Main 上方。
#
# 修正範圍：
#  1. Ring Menu：指令重複執行、強制回地圖、nil dispose、跨兩格游標。
#  2. Holy87 Guide：缺檔/空分類報錯、初始陣列被共用、Bitmap 洩漏。
#  3. Pick Item Event：空背包 nil 報錯、<pick item> 判定顛倒。
#  4. Ultimate Overlay：Shadow2 錯誤 viewport、更新與釋放安全化。
#  5. Animated Parallax：幀數 0、錯誤 dispose Cache bitmap。
#  6. Multiple Fogs：舊存檔 nil、色調 G/B 對調、錯誤 dispose Cache bitmap。
#  7. Variable Map Window：clear 無效、每幀重繪、舊存檔初始化。
#  8. Advanced Fog：舊存檔缺少附加資料時 EOFError。
#  9. Chest Popup：公共事件 event_id=0、錯誤資料 ID、視窗座標與 dispose。
# 10. Neo Light：無事件頁、零震幅 rand(0)、燈光 Sprite 缺失。
# 11. 氣候系統：500 sprites 浪費、空自訂圖、炸彈 bitmap 名稱錯誤、Cache dispose。
# 12. Quest/YEM/Ring 行走圖：修正原點、圖檔後綴與狀態列選擇。
# 13. KGC_ReproduceFunctions：舊存檔 @item_use_count 與旗標 ensure。
# 14. 乗り物拡張：instant_call 失敗殘留、事件乗り物消失、$riding_data nil。
# 15. Chest Popup：固定顯示為「[ICON] 物品名稱 x 數量」，並禁止戰鬥事件切走 Scene。
# 16. Holy87 Popup：支援 Scene_Battle，戰鬥結束可把未顯示完的 Popup 帶回地圖。
# 17. Message Queue：補舊存檔 queue=nil，並釋放每則訊息建立的 Bitmap。
# 18. 選配腳本缺席防護：不因 Scene_Menu／Scene_File／乗り物方法不存在而啟動崩潰。
# 19. Holy87 Popup 僅接受地圖與戰鬥通知，避免商店／選單操作延遲跳出。
# 20. ISS ParaPassa × 乗り物拡張：飛行／穿透狀態不得越出非循環地圖邊界。
# 21. 大型飛行船視覺模式：自動隱藏 Par／Shadow／Ground，套用雲霧並於降落還原。
# 22. ATS／Quest Journal：繁中 UTF-8 逐字換行、控制碼保護、左右對齊與任務行高。
#==============================================================================

$imported = {} if $imported == nil
$imported["FS Legacy Scripts Safety Patch"] = 1.14

module FS_LEGACY_SAFE
  CHARACTER_EXTS = [".png", ".jpg", ".bmp"]

  def self.safe_dispose(object)
    return if object == nil
    return unless object.respond_to?(:dispose)
    return if object.respond_to?(:disposed?) && object.disposed?
    object.dispose
  rescue
  end

  def self.character_exists?(name)
    return false if name == nil || name == ""
    path = "Graphics/Characters/" + name
    CHARACTER_EXTS.each do |ext|
      return true if FileTest.exist?(path + ext)
    end
    return false
  end

  # 選單中視為「負面狀態」的 State ID。
  # 延續原 Main Menu 腳本的設定：死亡使用 State 1，其他負面狀態為 2～12。
  MENU_NEGATIVE_STATE_IDS = (2..12).to_a

  # 回傳 [bitmap, src_rect, cw, ch, 實際檔名]
  #
  # 重要：
  #   _1、_2、_3 是不同用途的角色圖檔，不是三個步行動畫欄位。
  #   動畫仍取同一張圖內的第 1～3 欄。
  #
  # use_suffix=true 僅作舊呼叫相容：
  #   若 name 本身沒有 _1/_2/_3，最多只嘗試 name_1。
  def self.character_frame(name, index, pattern = 1, direction = 0,
                           use_suffix = false)
    return nil if name == nil || name == ""
    pattern = [[pattern.to_i, 0].max, 2].min
    direction = [[direction.to_i, 0].max, 3].min
    actual_name = name

    if use_suffix
      base = name.sub(/_[123]$/, "")
      suffix = base + "_1"
      actual_name = suffix if character_exists?(suffix)
    end

    bitmap = Cache.character(actual_name)
    sign = actual_name[/^[\!\$]./]
    if sign != nil && sign.include?('$')
      cw = bitmap.width / 3
      ch = bitmap.height / 4
      sx = pattern * cw
      sy = direction * ch
    else
      cw = bitmap.width / 12
      ch = bitmap.height / 8
      n = index.to_i
      sx = (n % 4 * 3 + pattern) * cw
      sy = (n / 4 * 4 + direction) * ch
    end
    return [bitmap, Rect.new(sx, sy, cw, ch), cw, ch, actual_name]
  rescue
    return nil
  end

  def self.menu_negative_state?(actor)
    return false if actor == nil
    states = actor.states rescue []
    states.each do |state|
      next if state == nil
      return true if MENU_NEGATIVE_STATE_IDS.include?(state.id)
    end
    return false
  end

  # MENU 專用角色圖規則：
  #   正常       → character_name_1 的最上方一排
  #   負面狀態   → character_name_1 的第 3 排
  #   死亡       → character_name_2 的最後一排
  def self.actor_menu_frame(actor, pattern = 1)
    return nil if actor == nil
    original_name = actor.character_name.to_s
    base_name = original_name.sub(/_[123]$/, "")
    index = actor.character_index

    if actor.dead?
      actual_name = base_name + "_2"
      direction = 3
    elsif menu_negative_state?(actor)
      actual_name = base_name + "_1"
      direction = 2
    else
      actual_name = base_name + "_1"
      direction = 0
    end

    unless character_exists?(actual_name)
      fallback_name = base_name + "_1"
      actual_name = character_exists?(fallback_name) ? fallback_name : original_name
    end

    return character_frame(actual_name, index, pattern, direction, false)
  end

  def self.apply_actor_menu_sprite(sprite, actor, pattern = 1)
    return false if sprite == nil || actor == nil
    return false if sprite.respond_to?(:disposed?) && sprite.disposed?
    data = actor_menu_frame(actor, pattern)
    return false if data == nil
    sprite.bitmap = data[0]
    sprite.src_rect.set(data[1].x, data[1].y, data[1].width, data[1].height)
    # 原 Main Menu / Quest / Save 的 x、y 都是以左上角定位。
    sprite.ox = 0
    sprite.oy = 0
    return true
  end

  def self.animation_pattern(counter, interval = 15)
    interval = 1 if interval.to_i < 1
    sequence = [1, 2, 1, 0]
    return sequence[(counter.to_i / interval.to_i) % sequence.size]
  end

  def self.apply_character_sprite(sprite, name, index, pattern = 1,
                                  direction = 0, use_suffix = false,
                                  origin_mode = :top_left)
    return false if sprite == nil
    return false if sprite.respond_to?(:disposed?) && sprite.disposed?
    data = character_frame(name, index, pattern, direction, use_suffix)
    return false if data == nil
    sprite.bitmap = data[0]
    sprite.src_rect.set(data[1].x, data[1].y, data[1].width, data[1].height)
    if origin_mode == :bottom_center
      sprite.ox = data[2] / 2
      sprite.oy = data[3]
    else
      sprite.ox = 0
      sprite.oy = 0
    end
    return true
  end

  def self.safe_screen_print_dispose
    return unless defined?($screen_print)
    safe_dispose($screen_print)
    $screen_print = nil if $screen_print.respond_to?(:disposed?) && $screen_print.disposed?
  rescue
  end

  def self.default_fog_data
    return { 1 => ["fog", -5, -5, 128, 2] }
  end
end

#==============================================================================
# ■ 共用行走圖繪製
#==============================================================================
class Window_Base < Window
  def albert_update_character_animation(key = :default, interval = 15)
    @albert_character_animation ||= {}
    @albert_character_animation[key] ||= 0
    @albert_character_animation[key] += 1
    return FS_LEGACY_SAFE.animation_pattern(@albert_character_animation[key], interval)
  end

  def albert_draw_character_pattern(character_name, character_index, x, y,
                                    pattern = 1, direction = 0,
                                    opacity = 255, use_suffix = false)
    data = FS_LEGACY_SAFE.character_frame(character_name, character_index,
                                          pattern, direction, use_suffix)
    return if data == nil
    contents.blt(x - data[2] / 2, y - data[3], data[0], data[1], opacity)
  end

  def albert_draw_character_anim(character_name, character_index, x, y,
                                 key = :default, interval = 15,
                                 direction = 0, opacity = 255,
                                 use_suffix = false)
    pattern = albert_update_character_animation(key, interval)
    albert_draw_character_pattern(character_name, character_index, x, y,
                                  pattern, direction, opacity, use_suffix)
  end

  # Ring Menu 原腳本改寫過此方法；統一接回安全繪製。
  def draw_character(character_name, character_index, x, y, enabled = true)
    opacity = enabled ? 255 : 128
    albert_draw_character_pattern(character_name, character_index, x, y,
                                  1, 0, opacity, false)
  end
end

#==============================================================================
# ■ Ring Menu
#==============================================================================
if defined?(Window_RingMenu)
  class Window_RingMenu < Window_Base
    alias fs_legacy_ring_initialize initialize unless method_defined?(:fs_legacy_ring_initialize)
    def initialize(*args)
      fs_legacy_ring_initialize(*args)
      @disabled = Array.new(@item_max || 0, false)
      @index = 0 if @item_max.to_i <= 0
      @index %= @item_max if @item_max.to_i > 0
    end

    def enabled?(index = @index)
      return false if index == nil
      return false if index < 0 || index >= @item_max.to_i
      return !@disabled[index]
    end

    def disable_item(index)
      return if index == nil || index < 0 || index >= @item_max.to_i
      @disabled[index] = true
    end

    def cursor_right2
      return if @items == nil || @items.empty?
      @index = (@index - 2) % @items.size
      @mode = MOVER
      @steps = MOVING_FRAMES
    end

    def cursor_left2
      return if @items == nil || @items.empty?
      @index = (@index + 2) % @items.size
      @mode = MOVEL
      @steps = MOVING_FRAMES
    end
  end
end

if defined?(Scene_RM)
  class Scene_RM < Scene_Base
    def update_command_selection
      if Input.trigger?(Input::B)
        Sound.play_cancel
        $scene = Scene_Map.new
      elsif Input.trigger?(Input::C)
        unless @command_window && @command_window.enabled?
          Sound.play_buzzer
          return
        end
        Sound.play_decision
        old_scene = $scene
        command = $game_ring_menu[@command_window.index]
        eval(command[2]) if command && command[2]
        $scene = Scene_Map.new if $scene.equal?(old_scene)
      end
    rescue Exception => e
      Sound.play_buzzer
      p "Ring Menu error: #{e.class}: #{e.message}"
    end

    def terminate
      super
      dispose_menu_background rescue nil
      FS_LEGACY_SAFE.safe_dispose(@command_window)
    end
  end
end

if defined?(Scene_RM2)
  class Scene_RM2 < Scene_Base
    def update_command_selection
      if Input.trigger?(Input::B)
        Sound.play_cancel
        FS_LEGACY_SAFE.safe_screen_print_dispose
        $scene = Scene_Map.new
      elsif Input.trigger?(Input::C)
        unless @command_window && @command_window.enabled?
          Sound.play_buzzer
          return
        end
        Sound.play_decision
        old_scene = $scene
        command = $game_ring_cm[@command_window.index]
        eval(command[2]) if command && command[2]
        FS_LEGACY_SAFE.safe_screen_print_dispose
        $scene = Scene_Map.new if $scene.equal?(old_scene)
      end
    rescue Exception => e
      Sound.play_buzzer
      p "Ring Menu 2 error: #{e.class}: #{e.message}"
    end

    def terminate
      super
      dispose_menu_background rescue nil
      FS_LEGACY_SAFE.safe_dispose(@menuback_sprite2)
      FS_LEGACY_SAFE.safe_dispose(@command_window)
    end
  end
end

#==============================================================================
# ■ Holy87 Guide
#==============================================================================
if defined?(H87_Guide)
  module H87_Guide
    def load_text(path, filename)
      return ["[H]Guide data is missing.\n"] if filename == nil || filename.to_s.empty?
      filepath = path.to_s + filename.to_s + ".txt"
      unless FileTest.exist?(filepath)
        begin
          File.open("GuideMissing.log", "a") do |file|
            file.write("Missing: " + filepath + "\n")
          end
        rescue
        end
        return ["[H]找不到指南檔案\n", filepath + "\n"]
      end
      array = []
      File.open(filepath, "r") { |file| file.each_line { |line| array << line.to_s } }
      return array
    rescue Exception => e
      return ["[H]指南讀取失敗\n", e.message.to_s + "\n"]
    end

    def self.text_pages(index)
      content = Guide_Contents[index]
      return [] unless content.is_a?(Array)
      return [] if content.size <= 2
      return content[2, content.size - 2].compact
    end
  end
end

if defined?(Game_Party) && defined?(H87_Guide)
  class Game_Party < Game_Unit
    def setup_initial_contents
      source = H87_Guide::InitialContents || []
      @guide_unlocked = source.clone
    end
  end
end

if defined?(Scene_Guide)
  class Scene_Guide < Scene_Base
    def create_list_window
      h = Graphics.height - @help_window.height
      @list_window = Window_GuideList.new(Graphics.width, @help_window)
      @list_window.y = Graphics.height
      @list_window.height = h
      if @index == nil
        @listY = @help_window.height
        @list_window.active = true
      else
        @list_window.active = false
      end
    end

    def show_guide(index)
      pages = H87_Guide.text_pages(index)
      if index == nil || pages.empty?
        Sound.play_buzzer
        @list_window.active = true if @list_window
        return
      end
      @list_window.active = false
      @listY = Graphics.height
      @helpY = 0 - @help_window.height
      @guide_book.set_text(pages)
      $game_party.add_readed(index)
    end

    def terminate
      super
      dispose_menu_background rescue nil
      [@background, @help_window, @list_window].each do |obj|
        FS_LEGACY_SAFE.safe_dispose(obj)
      end
      @guide_book.dispose if @guide_book rescue nil
    end
  end
end

if defined?(Guide_Book)
  class Guide_Book
    def fs_dispose_sprite_bitmap(sprite)
      return if sprite == nil
      bitmap = sprite.bitmap
      sprite.bitmap = nil rescue nil
      FS_LEGACY_SAFE.safe_dispose(bitmap)
      FS_LEGACY_SAFE.safe_dispose(sprite)
    end

    def page_next
      return if actual_page >= page_number
      @active_page += 1
      old = @page_sprite.bitmap
      @page_sprite.bitmap = create_page_bitmap
      FS_LEGACY_SAFE.safe_dispose(old)
    end

    def page_prev
      return if actual_page <= 1
      @active_page -= 1
      old = @page_sprite.bitmap
      @page_sprite.bitmap = create_page_bitmap
      FS_LEGACY_SAFE.safe_dispose(old)
    end

    def clear_pages
      return if @pages == nil
      @pages.each { |page| fs_dispose_sprite_bitmap(page) }
      @pages.clear
    end

    alias fs_legacy_guide_set_text set_text unless method_defined?(:fs_legacy_guide_set_text)
    def set_text(page_array)
      old_page_sprite = @page_sprite
      @page_sprite = nil
      fs_dispose_sprite_bitmap(old_page_sprite)
      fs_legacy_guide_set_text(page_array || [])
    end

    def dispose
      clear_pages
      fs_dispose_sprite_bitmap(@page_sprite)
      @page_sprite = nil
      @setup = false
    end

    def hide
      return unless @setup
      @showing = false
      @pages.each { |page| page.visible = false } if @pages
      @page_sprite.visible = false if @page_sprite && !@page_sprite.disposed?
    end
  end
end

#==============================================================================
# ■ Shanghai Pick Item Event
#==============================================================================
if defined?(Window_Pick_Item)
  class Window_Pick_Item < Window_Selectable
    def refresh
      @data = []
      $game_party.items.each do |item|
        next if item == nil
        valid_type = case @type
        when :item, :items
          item.is_a?(RPG::Item)
        when :weapon, :weapons
          item.is_a?(RPG::Weapon)
        when :armor, :armors, :armour, :armours
          item.is_a?(RPG::Armor)
        else
          false
        end
        next unless valid_type
        next if item.pick_item       # 原說明：標籤代表不可選
        @data << item if include?(item)
      end
      @item_max = @data.size
      self.index = @item_max == 0 ? -1 : [[self.index, 0].max, @item_max - 1].min
      create_contents
      for i in 0...@item_max
        draw_item(i)
      end
    end

    def item
      return nil if @data == nil || self.index == nil || self.index < 0
      return @data[self.index]
    end

    def enabled?(item)
      return false if item == nil
      return false if item.id == 201
      return false if item.respond_to?(:pick_item) && item.pick_item
      return true
    end
  end
end

if defined?(Window_Pick_Item_Help)
  class Window_Pick_Item_Help < Window_Base
    def refresh
      contents.clear
      item = @last_item = @pick_item_window.item
      return if item == nil
      draw_icon(item.icon_index, 0, 0)
      contents.draw_text(24, 0, contents.width - 24, WLH, item.name.to_s)
    end
  end
end

if defined?(Scene_Map) && defined?(Window_Pick_Item)
  class Scene_Map < Scene_Base
    def fs_dispose_pick_item_windows
      FS_LEGACY_SAFE.safe_dispose(@pick_item_help)
      FS_LEGACY_SAFE.safe_dispose(@pick_item_window)
      @pick_item_help = nil
      @pick_item_window = nil
    end

    def pick_item_event(type = :item)
      valid = [:item, :items, :weapon, :weapons,
               :armor, :armors, :armour, :armours]
      return 0 unless valid.include?(type)
      value = 0
      begin
        @pick_item_window = Window_Pick_Item.new(type)
        @pick_item_help = Window_Pick_Item_Help.new(@pick_item_window)
        @pick_item_window.open
        @pick_item_help.open
        loop do
          update_basic
          @pick_item_window.update
          @pick_item_help.update
          if Input.trigger?(Input::B)
            Sound.play_cancel
            break
          elsif Input.trigger?(Input::C)
            item = @pick_item_window.item
            if @pick_item_window.enabled?(item)
              Sound.play_decision
              value = item.id
              break
            else
              Sound.play_buzzer
            end
          end
        end
        @pick_item_window.close
        @pick_item_help.close
        loop do
          update_basic
          @pick_item_window.update
          @pick_item_help.update
          break if @pick_item_window.openness == 0
        end
      ensure
        fs_dispose_pick_item_windows
      end
      return value
    end
  end
end

#==============================================================================
# ■ Ultimate Overlay Mapping
#==============================================================================
if defined?(Overlay_Map)
  class Overlay_Map
    alias fs_legacy_overlay_initialize initialize unless method_defined?(:fs_legacy_overlay_initialize)
    def initialize
      fs_legacy_overlay_initialize
      # 原腳本把 Shadow2 建在 @shadow_viewport，導致專用 viewport 完全沒作用。
      if @shadow2 && @shadow2_viewport
        old = @shadow2
        bmp = old.bitmap
        visible = old.visible
        tone = old.tone.clone
        FS_LEGACY_SAFE.safe_dispose(old)
        @shadow2 = Sprite.new(@shadow2_viewport)
        @shadow2.bitmap = bmp
        @shadow2.z = -1
        @shadow2.opacity = 65
        @shadow2.blend_type = 2
        @shadow2.visible = visible
        @shadow2.tone = tone
      end
    end

    def update
      screen = $game_map.screen
      dx = $game_map.display_x / 8
      dy = $game_map.display_y / 8
      data = [
        [@light,  @light_viewport,  HK_UOM::LightSwitch],
        [@shadow, @shadow_viewport, HK_UOM::ShadowSwitch],
        [@shadow2,@shadow2_viewport,HK_UOM::ShadowSwitch2],
        [@par,    @par_viewport,    HK_UOM::ParSwitch]
      ]
      data.each do |sprite, viewport, switch_id|
        next if sprite == nil || sprite.disposed?
        sprite.visible = $game_switches[switch_id]
        sprite.tone = screen.tone
        sprite.ox = dx
        sprite.oy = dy
        if viewport
          # RGSS2 的 Viewport 沒有 disposed? 方法。
          # 直接呼叫會在進入地圖前產生 NoMethodError。
          begin
            viewport.ox = screen.shake
            viewport.color = screen.flash_color
          rescue
            # Viewport 已被釋放或無效時略過本幀更新。
          end
        end
      end
    end

    def dispose
      [[@light, @light_viewport], [@shadow, @shadow_viewport],
       [@shadow2, @shadow2_viewport], [@par, @par_viewport]].each do |pair|
        FS_LEGACY_SAFE.safe_dispose(pair[0])
        FS_LEGACY_SAFE.safe_dispose(pair[1])
      end
    end
  end
end

# Ground 檔名原本硬寫小寫 ground，與設定 GroundMap 不一致。
if defined?(Spriteset_Map) && defined?(HK_UOM)
  class Spriteset_Map
    alias fs_legacy_uom_initialize initialize unless method_defined?(:fs_legacy_uom_initialize)
    def initialize
      path = "Overlays/" + HK_UOM::GroundMap + $game_map.map_id.to_s + ".png"
      @GroundON = FileTest.exist?(path)
      fs_legacy_uom_initialize
    end
  end
end

#==============================================================================
# ■ Animated Parallax
#==============================================================================
if defined?(Game_Map) && defined?(Game_Map::MAAP_SUPPORTED_EXTENSIONS)
  class Game_Map
    def setup_parallax_frames
      last_map_bmps = @maap_parallax_frames.nil? ? [] : @maap_parallax_frames
      @maap_parallax_index = 0
      @maap_parallax_frames = [@parallax_name]
      @maap_parallax_frame_timer = 0
      setting = MAAP_PARALLAX_ANIMATION_FRAMES[@map_id]
      if setting.is_a?(Array) && setting.size > 0
        @maap_parallax_frame_limit = setting[0]
      else
        @maap_parallax_frame_limit = setting
      end
      @maap_parallax_frame_limit = 1 if @maap_parallax_frame_limit.to_i < 1
      if @parallax_name && @parallax_name[/_(\d+)$/]
        frame_id = $1.to_i + 1
        base_name = @parallax_name.sub(/_\d+$/, "")
        while maap_check_extensions("Graphics/Parallaxes/#{base_name}_#{frame_id}")
          @maap_parallax_frames << "#{base_name}_#{frame_id}"
          frame_id += 1
        end
      end
      # Cache 內的 bitmap 不由此腳本 dispose，避免其他 Plane 正在使用時被清掉。
      if MAAP_PRELOAD_PARALLAXES
        (@maap_parallax_frames - last_map_bmps).each { |bmp| Cache.parallax(bmp) }
        Graphics.frame_reset
      end
    end
  end
end

#==============================================================================
# ■ Multiple Fogs
#==============================================================================
if defined?(Game_Map) && defined?(Wora_Multiple_Fog)
  class Game_Map
    def fs_init_multiple_fog_data
      @fog_path ||= 'Graphics/Pictures/'
      @fog_reset = true if @fog_reset == nil
      [:@mulfog_name, :@mulfog_hue, :@mulfog_opacity,
       :@mulfog_blend_type, :@mulfog_zoom, :@mulfog_sx, :@mulfog_sy,
       :@mulfog_ox, :@mulfog_oy, :@mulfog_tone, :@mulfog_tone_target,
       :@mulfog_tone_duration, :@mulfog_opacity_duration,
       :@mulfog_opacity_target].each do |ivar|
        instance_variable_set(ivar, []) if instance_variable_get(ivar) == nil
      end
    end

    alias fs_legacy_mulfog_update update unless method_defined?(:fs_legacy_mulfog_update)
    def update
      fs_init_multiple_fog_data
      fs_legacy_mulfog_update
    end
  end

  class Wora_Multiple_Fog
    def load_fog(id)
      $game_map.fs_init_multiple_fog_data
      raw_name = $game_map.mulfog_name[id]
      return false if raw_name == nil || raw_name == ''
      @name = raw_name.sub($game_map.fog_path.to_s, '')
      @hue = $game_map.mulfog_hue[id] || 0
      @opacity = $game_map.mulfog_opacity[id] || 64
      @blend = $game_map.mulfog_blend_type[id] || 0
      @zoom = $game_map.mulfog_zoom[id] || 200
      @sx = $game_map.mulfog_sx[id] || 0
      @sy = $game_map.mulfog_sy[id] || 0
      tn = $game_map.mulfog_tone[id] || Tone.new(0,0,0,0)
      @tone = [tn.red, tn.green, tn.blue, tn.gray]
      return true
    end
  end

  class Spriteset_Map
    def update_parallax
      wora_mulfog_sprmap_updpal
      $game_map.fs_init_multiple_fog_data
      $game_map.mulfog_name.each_index do |i|
        next if $game_map.mulfog_name[i] == nil
        if @mulfog_name[i] != $game_map.mulfog_name[i] ||
           @mulfog_hue[i] != $game_map.mulfog_hue[i]
          @mulfog_name[i] = $game_map.mulfog_name[i]
          @mulfog_hue[i] = $game_map.mulfog_hue[i]
          if @mulfog[i] == nil
            @mulfog[i] = Plane.new(@viewport1)
            @mulfog[i].z = 3000
          end
          @mulfog[i].bitmap = nil
          if @mulfog_name[i] != ''
            @mulfog[i].bitmap = Cache.load_bitmap('', @mulfog_name[i], @mulfog_hue[i] || 0)
          end
          Graphics.frame_reset
        end
        next if @mulfog[i] == nil || @mulfog[i].bitmap == nil
        zoom = ($game_map.mulfog_zoom[i] || 100) / 100.0
        @mulfog[i].zoom_x = zoom
        @mulfog[i].zoom_y = zoom
        @mulfog[i].opacity = $game_map.mulfog_opacity[i] || 0
        @mulfog[i].blend_type = $game_map.mulfog_blend_type[i] || 0
        @mulfog[i].ox = $game_map.display_x / 8.0 + ($game_map.mulfog_ox[i] || 0)
        @mulfog[i].oy = $game_map.display_y / 8.0 + ($game_map.mulfog_oy[i] || 0)
        @mulfog[i].tone = $game_map.mulfog_tone[i] || Tone.new(0,0,0,0)
        @mulfog[i].z = 3000
      end
    end

    def dispose_parallax
      if @mulfog
        @mulfog.each do |fog|
          next if fog == nil
          fog.bitmap = nil
          FS_LEGACY_SAFE.safe_dispose(fog)
        end
      end
      wora_mulfog_sprmap_dispal
    end
  end
end

#==============================================================================
# ■ Variable Map Window
#==============================================================================
if defined?(Game_System)
  class Game_System
    def fs_init_variable_window_data
      @shown_variables ||= []
      @variable_window_open = false if @variable_window_open == nil
      @variable_corner ||= 0
      @variable_width ||= 160
    end
  end
end

if defined?(Game_Interpreter) && defined?(Window_Variable)
  class Game_Interpreter
    def variable_window_clear
      $game_system.fs_init_variable_window_data
      $game_system.shown_variables.clear
      if $scene.is_a?(Scene_Map) && $scene.variable_window
        $scene.variable_window.refresh
        $scene.variable_window.close
      end
      $game_system.variable_window_open = false
    end
  end
end

if defined?(Window_Variable)
  class Window_Variable < Window_Selectable
    def refresh
      $game_system.fs_init_variable_window_data
      self.width = $game_system.variable_width
      @data = $game_system.shown_variables.clone
      @value = []
      @data.each { |id| @value[id] = $game_variables[id] }
      @item_max = @data.size
      self.height = [@item_max, 1].max * 24 + 32
      create_contents
      for i in 0...@item_max
        draw_item(i)
      end
      update_corner
    end

    def update
      super
      $game_system.fs_init_variable_window_data
      refresh if @data != $game_system.shown_variables
      @data.compact.each do |variable|
        next if @value[variable] == $game_variables[variable]
        @value[variable] = $game_variables[variable]
        index = @data.index(variable)
        draw_item(index) if index
      end
      update_corner
    end

    def draw_item(index)
      return if index == nil
      rect = item_rect(index)
      contents.clear_rect(rect)
      current_id = @data[index]
      return if current_id == nil
      name = sprintf("%s:", $data_system.variables[current_id].to_s)
      amount = $game_variables[current_id].to_s
      contents.font.color = system_color
      contents.draw_text(rect, name, 0)
      contents.font.color = normal_color
      contents.draw_text(rect, amount, 2)
    end
  end
end

#==============================================================================
# ■ Advanced Fog 舊存檔
#==============================================================================
if defined?(Scene_File) && Scene_File.method_defined?(:shuu_fog_read)
  class Scene_File < Scene_Base
    def read_save_data(file)
      shuu_fog_read(file)
      begin
        $fog_data = Marshal.load(file)
        $fog_transition = Marshal.load(file)
      rescue EOFError
        $fog_data = FS_LEGACY_SAFE.default_fog_data
        $fog_transition = 0
      end
      $fog_data ||= FS_LEGACY_SAFE.default_fog_data
      $fog_transition ||= 0
    end
  end
end

if defined?(Shuu_Fog)
  module Shuu_Fog
    class << self
      alias fs_legacy_fog_change change unless method_defined?(:fs_legacy_fog_change)
      def change(*args)
        $fog_data ||= FS_LEGACY_SAFE.default_fog_data
        $fog_transition ||= 0
        fs_legacy_fog_change(*args)
      end
    end
  end
end

#==============================================================================
# ■ Chest Item Pop-Up
#------------------------------------------------------------------------------
# 1. 公共事件 event_id=0 時，使用玩家位置。
# 2. 戰鬥中執行「增減金錢／物品」時，不切換到 Chest_Popup Scene。
# 3. 名稱窗統一顯示：
#      [ICON] 物品名稱 x 10
#    金錢則顯示：
#      [ICON] 1000G
#==============================================================================
if defined?(Game_Interpreter) && defined?(Chest_Popup)
  class Game_Interpreter
    def get_x
      event = $game_map.events[@event_id] rescue nil
      return event.screen_x if event
      return $game_player.screen_x
    end

    def get_y
      event = $game_map.events[@event_id] rescue nil
      return event.screen_y if event
      return $game_player.screen_y
    end

    def command_125
      value = operate_value(@params[0], @params[1], @params[2])
      can_popup = $scene.is_a?(Scene_Map) &&
                  $game_switches[POPUP_SWITCH] != AUTO_POPUP &&
                  @params[0] == 0
      if can_popup
        $scene = Chest_Popup.new(get_x, get_y, 0, value, 1)
      end
      chest_pop_command_125
    end

    def command_126
      value = operate_value(@params[1], @params[2], @params[3])
      item = $data_items[@params[0]]
      can_popup = $scene.is_a?(Scene_Map) &&
                  item != nil &&
                  $game_switches[POPUP_SWITCH] != AUTO_POPUP &&
                  @params[1] == 0
      if can_popup
        $scene = Chest_Popup.new(get_x, get_y, 1, value, @params[0])
      end
      chest_pop_command_126
    end

    def command_127
      value = operate_value(@params[1], @params[2], @params[3])
      item = $data_weapons[@params[0]]
      can_popup = $scene.is_a?(Scene_Map) &&
                  item != nil &&
                  $game_switches[POPUP_SWITCH] != AUTO_POPUP &&
                  @params[1] == 0
      if can_popup
        $scene = Chest_Popup.new(get_x, get_y, 2, value, @params[0])
      end
      chest_pop_command_127
    end

    def command_128
      value = operate_value(@params[1], @params[2], @params[3])
      item = $data_armors[@params[0]]
      can_popup = $scene.is_a?(Scene_Map) &&
                  item != nil &&
                  $game_switches[POPUP_SWITCH] != AUTO_POPUP &&
                  @params[1] == 0
      if can_popup
        $scene = Chest_Popup.new(get_x, get_y, 3, value, @params[0])
      end
      chest_pop_command_128
    end
  end
end

if defined?(Name_Window)
  class Name_Window < Window_Base
    def initialize(x, y, desc, no_desc, desc_size, gold = false, icon = 0)
      text = desc.to_s
      icon_id = icon.to_i
      super(0, y, 64, WLH + 32)

      icon_space = icon_id > 0 ? 28 : 0
      text_width = self.contents.text_size(text).width
      final_width = text_width + icon_space + 32
      final_width = 64 if final_width < 64
      max_width = Graphics.width - 16
      final_width = max_width if final_width > max_width

      self.width = final_width
      self.x = ((Graphics.width - self.width) / 2) + TEXT_WINDOW_X_OFFSET
      self.x = 0 if self.x < 0
      self.x = Graphics.width - self.width if self.x + self.width > Graphics.width
      create_contents

      draw_icon(icon_id, 0, 0) if icon_id > 0
      draw_x = icon_space
      draw_width = self.contents.width - draw_x
      self.contents.draw_text(draw_x, 0, draw_width, WLH, text, 0)
    end
  end
end

if defined?(Chest_Popup)
  class Chest_Popup < Scene_Base
    alias fs_legacy_chest_format_initialize initialize unless
      method_defined?(:fs_legacy_chest_format_initialize)

    def initialize(x, y, type, amount, index, add = false)
      fs_legacy_chest_format_initialize(x, y, type, amount, index, add)

      amount_text = amount.to_i.to_s
      case type
      when 0
        @icon_index = GOLD_ICON
        @desc = amount_text + Vocab.gold.to_s
        @gold = true
      when 1
        item = $data_items[index]
        @desc = item.name.to_s + " x " + amount_text if item
        @gold = false
      when 2
        item = $data_weapons[index]
        @desc = item.name.to_s + " x " + amount_text if item
        @gold = false
      when 3
        item = $data_armors[index]
        @desc = item.name.to_s + " x " + amount_text if item
        @gold = false
      end
      @no_desc = false
      @desc_size = amount.to_i.abs >= 10 ? 2 : 1
    end

    def terminate
      FS_LEGACY_SAFE.safe_dispose(@popup_window)
      FS_LEGACY_SAFE.safe_dispose(@menuback_sprite)
      FS_LEGACY_SAFE.safe_dispose(@name_window)
    end

    def show_name
      x = Graphics.width / 2
      y = $game_player.screen_y < Graphics.height / 2 ?
          [Graphics.height - 72, 0].max : 16
      @name_window = Name_Window.new(x, y, @desc, @no_desc,
                                     @desc_size, @gold, @icon_index)
      wait_for_close
      Audio.se_play('Audio/SE/' + CLOSE_SOUND, CLOSE_SOUND_VOLUME,
                    CLOSE_SOUND_PITCH) if WAIT_FOR_BUTTON && PLAY_CLOSE
      if USE_OVERLAY
        $game_map.screen.pictures[1].move(1, @x, @y, 100, 100, 0, 0, 10)
        wait(20)
        $game_map.screen.pictures[1].erase
      end
    end
  end
end

#==============================================================================
# ■ Neo Light Effects / Reinforce
#==============================================================================
if defined?(Neo_Light) && defined?(Game_Event)
  class Game_Event < Game_Character
    def fs_neo_rand(value)
      value = value.to_i
      return 0 if value <= 0
      return rand(value)
    end

    def update_light
      return if @nl_effect == false || @nl_effect == nil
      return unless @nl_sprite.is_a?(Sprite)
      return if @nl_sprite.disposed?
      effect = Effects[@nl_effect]
      return if effect == nil
      @nl_sprite.visible = !$game_switches[Neo_Light_Switch]
      @nl_sprite.x = screen_x
      @nl_sprite.y = screen_y - 16
      if @follow_light
        @nl_sprite.opacity = effect.opacity + fs_neo_rand(effect.opacity_oscillation)
        @nl_sprite.angle = 57.3 * Math.atan2(screen_x - $game_player.screen_x,
                                             screen_y - $game_player.screen_y)
      else
        @nl_sprite.x += fs_neo_rand(effect.ax.to_i * 2) - effect.ax.to_i
        @nl_sprite.y += fs_neo_rand(effect.ay.to_i * 2) - effect.ay.to_i
        @nl_sprite.opacity = effect.opacity + fs_neo_rand(effect.opacity_oscillation)
        @nl_sprite.angle += effect.angle
        @nl_sprite.angle -= 360 if @nl_sprite.angle >= 360
      end
      if effect.hue_oscillation && @nl_sprite.bitmap
        @nl_sprite.bitmap.hue_change(effect.hue_oscillation)
      end
    end

    # Neo Light Reinforce 的 initialize 在事件沒有有效頁面時，
    # 會直接執行 @list.size。此時 @list 可能是 nil。
    #
    # 不能在補丁末端直接重寫 Game_Event#initialize 並呼叫 nlr_initialize，
    # 因為 Neo Light 之後仍有「對事件使用物品、事件感應範圍、事件旋轉、
    # NPC 自言自語、乗り物拡張、Area+」等 initialize alias。
    # 直接繞過它們會造成 @sensor_range 等欄位未初始化。
    #
    # tig_eto_initialize 是 Neo Light Reinforce 之後第一個 alias 入口。
    # 只替換這個橋接方法，便能修掉 @list=nil，同時保留後面完整 alias 鏈。
    if private_method_defined?(:tig_eto_initialize) ||
       method_defined?(:tig_eto_initialize)
      def tig_eto_initialize(map_id, event)
        if self.class.private_method_defined?(:nlr_initialize) ||
           self.class.method_defined?(:nlr_initialize)
          nlr_initialize(map_id, event)
        elsif self.class.private_method_defined?(:nle_ini) ||
              self.class.method_defined?(:nle_ini)
          nle_ini(map_id, event)
        else
          @map_id = map_id
          @event = event
          @id = event ? event.id : 0
          @erased = false
          @starting = false
          @through = true
          moveto(event.x, event.y) if event
          refresh if event
        end
        @follow_light = false
        list = @list || []
        list.each do |command|
          next unless command && command.code == 108
          if command.parameters == ["Follow Player"]
            @follow_light = true
            break
          end
        end
      end
      private :tig_eto_initialize
    end

    # 舊存檔或舊版補丁曾建立的不完整 Game_Event，先補齊感應器欄位。
    alias fs_legacy_event_update_defaults update unless
      method_defined?(:fs_legacy_event_update_defaults)
    def update
      @sensor_range = 0 if @sensor_range == nil
      @key_act = false if @key_act == nil
      @key_act_old = @key_act if @key_act_old == nil
      fs_legacy_event_update_defaults
    end
  end
end

#==============================================================================
# ■ 氣候系統
#==============================================================================
if defined?(Spriteset_Weather)
  class Spriteset_Weather
    alias fs_legacy_weather_initialize initialize unless method_defined?(:fs_legacy_weather_initialize)
    def initialize(viewport = nil)
      fs_legacy_weather_initialize(viewport)
      # @max 上限只有 40，原腳本卻建立 500 個 Sprite。
      if @sprites && @sprites.size > 41
        @sprites[41, @sprites.size - 41].each { |sprite| FS_LEGACY_SAFE.safe_dispose(sprite) }
        @sprites = @sprites[0, 41]
        @current_pose = @current_pose[0, 41] if @current_pose
        @info = @info[0, 41] if @info
        @countarray = @countarray[0, 41] if @countarray
      end
    end

    alias fs_legacy_weather_type_set type= unless method_defined?(:fs_legacy_weather_type_set)
    def type=(type)
      # 自訂天氣沒有圖片時不允許進入 type 15。
      type = 0 if type.to_i == 15 && (!defined?($WEATHER_IMAGES) || $WEATHER_IMAGES.empty?)
      fs_legacy_weather_type_set(type)
      bitmap = case @type
      when 52 then @waterbomb_bitmap
      when 53 then @icybomb_bitmap
      when 54 then @flarebomb_bitmap
      else nil
      end
      if bitmap && @sprites
        @sprites.each { |sprite| sprite.bitmap = bitmap if sprite && !sprite.disposed? }
      end
    end

    def update_user_defined
      @user_bitmaps = []
      names = defined?($WEATHER_IMAGES) ? $WEATHER_IMAGES : []
      names.each { |name| @user_bitmaps << RPG::Cache.picture(name) }
      return if @user_bitmaps.empty?
      (@sprites || []).each do |sprite|
        next if sprite == nil || sprite.disposed?
        sprite.bitmap = @user_bitmaps[rand(@user_bitmaps.size)]
      end
    end

    alias fs_legacy_weather_update update unless method_defined?(:fs_legacy_weather_update)
    def update
      fs_legacy_weather_update
      if [17, 52, 53, 54].include?(@type) && @countarray && @sprites
        for i in 1..@max.to_i
          sprite = @sprites[i]
          if @countarray[i] == 0 && sprite && sprite.opacity == 0
            @countarray[i] = 1
          end
        end
      end
    end

    def dispose
      (@sprites || []).each { |sprite| FS_LEGACY_SAFE.safe_dispose(sprite) }
      instance_variables.each do |ivar|
        next if ivar.to_s == "@sprites" || ivar.to_s == "@user_bitmaps"
        value = instance_variable_get(ivar)
        if value.is_a?(Bitmap)
          FS_LEGACY_SAFE.safe_dispose(value)
        elsif value.is_a?(Array)
          value.each do |obj|
            FS_LEGACY_SAFE.safe_dispose(obj) if obj.is_a?(Bitmap)
          end
        end
      end
      @user_bitmaps = []  # Cache.picture 的 bitmap 不由此處 dispose
      $WEATHER_UPDATE = true
    end
  end
end

#==============================================================================
# ■ ATS 對話框定位：使用同一套行走圖尺寸判定，不 clone Cache bitmap
#==============================================================================
if defined?(Window_Message) && Window_Message.method_defined?(:position_to_character)
  class Window_Message < Window_Selectable
    def position_to_character(character_id, type)
      whatever_fits = (type == 4)
      type = 0 if whatever_fits
      character = character_id == 0 ? $game_player : $game_map.events[character_id]
      return if character == nil
      return unless character.screen_x.between?(0, Graphics.width) &&
                    character.screen_y.between?(0, Graphics.height)
      data = FS_LEGACY_SAFE.character_frame(character.character_name,
                                            character.character_index,
                                            1, 0, false)
      c_wdth = data ? data[2] : 32
      c_hght = data ? data[3] : 32
      x = nil
      y = nil
      if type % 2 == 0
        x = [character.screen_x - self.width / 2, 0].max
        x = Graphics.width - self.width if x + self.width > Graphics.width
      else
        y = [character.screen_y - (self.height + c_hght) / 2, 0].max
        y = Graphics.height - self.height if y + self.height > Graphics.height
      end
      case type
      when 0
        if whatever_fits && character.screen_y - c_hght - self.height < 0
          position_to_character(character_id, 2)
          return
        end
        y = [character.screen_y - c_hght - self.height, 0].max
      when 1
        x = [character.screen_x - c_wdth / 2 - self.width, 0].max
      when 2
        y = [character.screen_y, Graphics.height - self.height].min
      when 3
        x = [character.screen_x + c_wdth / 2, Graphics.width - self.width].min
      end
      $game_message.message_x = x
      $game_message.message_y = y
      if character_id >= 0 && $game_message.speech_tag_index >= 0
        set_speech_sprite_position(character.screen_x, character.screen_y,
                                   c_wdth, c_hght, type)
        position_to_character(character_id, 2) if whatever_fits && !@speechtag_sprite.visible
      end
    end
  end
end

#==============================================================================
# ■ YEM Item Overhaul 行走圖
#==============================================================================
if defined?(Window_ItemStatus)
  class Window_ItemStatus < Window_Base
    def draw_member(actor, dx, dy)
      return if actor == nil
      if @item.is_a?(RPG::Weapon) || @item.is_a?(RPG::Armor)
        opacity = actor.equippable?(@item) ? 255 : 128
      elsif @item.is_a?(RPG::Item)
        opacity = @item.for_friend? ? 255 : 128
      else
        opacity = 255
      end
      data = FS_LEGACY_SAFE.actor_menu_frame(actor, 1)
      return if data == nil
      contents.blt(dx - data[2] / 2, dy - data[3],
                   data[0], data[1], opacity)
    end

    def draw_party_members
      old_battle = $game_temp.in_battle
      $game_temp.in_battle = true
      begin
        size = $game_party.members.size
        dx = (contents.width - size * 64) / 2 - 48
        dy = contents.height * 3 / 4 - 10
        $game_party.members.each do |member|
          next if member == nil
          rect = Rect.new(dx - 15, dy - 35, 68, 40)
          contents.fill_rounded_rect(rect, Color.new(0,0,0,128))
          draw_member(member, dx, dy)
          draw_actor_hp_gauge(member, dx + 20, dy - 40, 25)
          draw_actor_mp_gauge(member, dx + 20, dy - 25, 25)
          draw_actor_state(member, dx - 13, dy + 3, 25)
          dx += 84
        end
      ensure
        $game_temp.in_battle = old_battle
      end
    end
  end
end

#==============================================================================
# ■ YEM Main Menu 行走圖
#==============================================================================
if defined?(Scene_Menu) && defined?(YEM) && defined?(YEM::MENU) &&
   defined?($imported) && $imported && $imported["MainMenuMelody"]
  class Scene_Menu < Scene_Base
    def update_actor_selection
      actor = $game_party.members[@status_window.index]
      if actor && @as && !@as.disposed?
        @as_flame = 0 if Input.trigger?(Input::RIGHT) || Input.trigger?(Input::LEFT)
        @as_flame ||= 0
        pattern = FS_LEGACY_SAFE.animation_pattern(@as_flame, 15)
        FS_LEGACY_SAFE.apply_actor_menu_sprite(@as, actor, pattern)
        @as.y = 235
        @as.x = 214 + @status_window.index * 110
        @as_flame = (@as_flame + 1) % 60
      end

      if @cursor && !@cursor.disposed?
        @cursor_flame ||= 0
        if @cursor_flame <= 30
          @cursor_flame = 0 if @cursor_flame == 30
          @cursor.src_rect.set(0, 0, 32, 32) if @cursor_flame == 29
          @cursor.src_rect.set(0, 32, 32, 32) if @cursor_flame == 15
          @cursor_flame += 1
        end
        @cursor.x = 180 + @status_window.index * 110
      end

      if Input.trigger?(Input::B)
        Sound.play_cancel
        end_actor_selection
        @status_window.close if YEM::MENU::ON_SCREEN_MENU
      elsif $TEST && Input.trigger?(Input::F5)
        Sound.play_recovery
        $game_party.members.each do |member|
          member.hp += member.maxhp
          member.mp += member.maxmp
        end
        @status_window.refresh
      elsif Input.trigger?(Input::C)
        $game_party.last_actor_index = @status_window.index
        Sound.play_decision
        FS_LEGACY_SAFE.safe_dispose(@as)
        FS_LEGACY_SAFE.safe_dispose(@cursor)
        command = @command_window.method
        case command
        when :skill
          $scene = Scene_Skill.new(@status_window.index)
        when :equip
          $scene = Scene_Equip.new(@status_window.index)
        when :status
          $scene = Scene_Status.new(@status_window.index)
        else
          if YEM::MENU::IMPORTED_COMMANDS.include?(command)
            array = YEM::MENU::IMPORTED_COMMANDS[command]
            $scene = eval(array[5] + ".new(@status_window.index)")
          end
        end
      end
    end
  end
end

#==============================================================================
# ■ Neo Save 行走圖
#==============================================================================
if defined?(Scene_File) &&
   Scene_File.method_defined?(:update_savefile_selection) &&
   defined?(SFC_Window_Width) && defined?(SFC_Text_Confirm) &&
   defined?(SFC_Text_Cancel)
  class Scene_File < Scene_Base
    alias fs_legacy_save_update_selection update_savefile_selection unless method_defined?(:fs_legacy_save_update_selection)
    def update_savefile_selection
      if @as && !@as.disposed? && @window_slotdetail
        @as_flame = 0 if Input.trigger?(Input::UP) || Input.trigger?(Input::DOWN)
        @as_flame ||= 0
        pattern = FS_LEGACY_SAFE.animation_pattern(@as_flame, 15)
        exists = @window_slotdetail.file_exist?(@last_slot_index + 1)
        name = exists ? "$actor01#" : "$actor01_5"
        FS_LEGACY_SAFE.apply_character_sprite(@as, name, 0, pattern, 0, false)
        @as.z = 9999
        @as.y = 63 + @last_slot_index * 24
        @as_flame = (@as_flame + 1) % 60
      end

      if Input.trigger?(Input::C)
        if @saving && @window_slotdetail.file_exist?(@last_slot_index + 1)
          Sound.play_decision
          @confirm_window = Window_Command.new(SFC_Window_Width,
                                                [SFC_Text_Confirm, SFC_Text_Cancel])
          @confirm_window.x = ((544 - @confirm_window.width) / 2) + SFC_Window_X_Offset
          @confirm_window.y = ((416 - @confirm_window.height) / 2) + SFC_Window_Y_Offset
        else
          determine_savefile
        end
      elsif Input.trigger?(Input::B)
        Sound.play_cancel
        return_scene
      end
    end
  end
end

#==============================================================================
# ■ Quest Journal 行走圖與 Cache bitmap 所有權
#==============================================================================
if defined?(Scene_Quest)
  class Scene_Quest < Scene_Base
    def update_category_window
      if Input.trigger?(Input::LEFT) || Input.trigger?(Input::RIGHT)
        add_int = Input.trigger?(Input::LEFT) ? -1 : 1
        @category_index = (@category_index + add_int) % QuestData::CATEGORIES.size
        Sound.play_cursor
        @category_window.refresh(@category_index)
        @list_window.change_list(QuestData::CATEGORIES[@category_index])
        @info_window.refresh(@list_window.quest)
        @com_count = 0
        @js_flame = 0
      end

      menu_names = ["Quest01", "Quest02", "Quest03"]
      if @as && !@as.disposed?
        if @category_index < menu_names.size
          @as.visible = true
          @as.bitmap = Cache.menu(menu_names[@category_index])
        else
          @as.visible = false
        end
      end

      @com_count ||= 0
      if @as && @as.visible && @com_count <= 10
        @as.x += 3 if @com_count == 8
        @as.x -= 3 if @com_count == 5
        @as.x += 3 if @com_count == 2
        @as.x -= 3 if @com_count == 0
        @com_count += 1
      end
      @light2.x = [34, 91, 148][@category_index] || 148 if @light2

      exact_names = ["$actor01_1", "$actor01_5", "$actor01_7"]
      if @js && !@js.disposed?
        if @category_index < exact_names.size
          @js.visible = true
          @js_flame ||= 0
          pattern = FS_LEGACY_SAFE.animation_pattern(@js_flame, 15)
          FS_LEGACY_SAFE.apply_character_sprite(@js,
                                                exact_names[@category_index],
                                                0, pattern, 0, false)
          @js_flame = (@js_flame + 1) % 60
        else
          @js.visible = false
        end
      end
    end

    def terminate
      super
      dispose_menu_background rescue nil
      if @bg_sprite
        @bg_sprite.bitmap = nil   # Cache.picture 不在此 dispose
        FS_LEGACY_SAFE.safe_dispose(@bg_sprite)
      end
      [@label_window, @category_window, @list_window, @info_window,
       @help_window, @as, @light, @light2, @js].each do |obj|
        FS_LEGACY_SAFE.safe_dispose(obj)
      end
      fireflies(0) rescue nil
    end
  end
end

if defined?(Scene_QuestPurchase)
  class Scene_QuestPurchase < Scene_Quest
    def terminate
      dispose_menu_background rescue nil
      if @bg_sprite
        @bg_sprite.bitmap = nil
        FS_LEGACY_SAFE.safe_dispose(@bg_sprite)
      end
      [@label_window, @list_window, @info_window, @gold_window,
       @light, @light2].each { |obj| FS_LEGACY_SAFE.safe_dispose(obj) }
    end
  end
end

#==============================================================================
# ■ KGC_ReproduceFunctions
#==============================================================================
if defined?(Game_Battler) && Game_Battler.method_defined?(:item_effect_KGC_ReproduceFunctions)
  class Game_Battler
    alias fs_legacy_kgc_item_effect_current item_effect unless method_defined?(:fs_legacy_kgc_item_effect_current)
    def item_effect(user, item)
      old_flag = $game_temp.exec_skill_on_item
      begin
        fs_legacy_kgc_item_effect_current(user, item)
      ensure
        $game_temp.exec_skill_on_item = old_flag if item && item.respond_to?(:exec_skill?) && item.exec_skill?
      end
    end
  end
end

if defined?(Game_Party) && Game_Party.method_defined?(:lose_item_KGC_ReproduceFunctions)
  class Game_Party < Game_Unit
    alias fs_legacy_kgc_lose_item_current lose_item unless method_defined?(:fs_legacy_kgc_lose_item_current)
    def lose_item(item, n, include_equip = false)
      @item_use_count ||= {}
      fs_legacy_kgc_lose_item_current(item, n, include_equip)
    end
  end
end

#==============================================================================
# ■ 乗り物拡張
#==============================================================================
if defined?(Riding_Data)
  $riding_data = Riding_Data.new if !defined?($riding_data) || $riding_data == nil
end

if defined?(Game_Vehicle) && Game_Vehicle.method_defined?(:instant_call)
  class Game_Vehicle < Game_Character
    def instant_call
      @instant = true
      result = call
      @instant = false unless result
      return result
    end

    def instant_call_here
      @instant = true
      result = call(false, true)
      @instant = false unless result
      return result
    end

    alias fs_legacy_vehicle_update update unless method_defined?(:fs_legacy_vehicle_update)
    def update
      $riding_data = Riding_Data.new if defined?(Riding_Data) && $riding_data == nil
      fs_legacy_vehicle_update
    rescue NameError => e
      # Advanced Fog 不存在時，不應讓交通工具下降直接崩潰。
      if e.message.to_s.include?("Shuu_Fog")
        super
      else
        raise
      end
    end
  end
end

#------------------------------------------------------------------------------
# Shuu Fog 第一次建立時，直接建立 Fog Plane 並從第一幀淡入。
# 原始 change 流程適合「舊 Fog 淡出 → 新 Fog 淡入」；
# 當地圖原本完全沒有 Fog 時，先做一輪不存在的淡出就沒有意義。
#------------------------------------------------------------------------------
if defined?(Spriteset_Map)
  class Spriteset_Map
    def fs_flight_first_fog_fade_in(transition, name,
                                    speed_x, speed_y,
                                    opacity, blend)
      return false unless defined?($game_map) && $game_map
      return false unless defined?($fog_data) &&
                          $fog_data.is_a?(Hash)
      return false unless respond_to?(:change_fog)

      map_id = $game_map.map_id
      return false if map_id == nil || map_id <= 0

      data = [
        name.to_s,
        speed_x.to_i,
        speed_y.to_i,
        opacity.to_i,
        blend.to_i
      ]
      $fog_data[map_id] = data
      $fog_transition = 0

      # 直接建立實際 Plane，省略「淡出不存在舊 Fog」的階段。
      change_fog

      frames = transition.to_i
      frames = 1 if frames < 1
      @sprite_fog.opacity = 0 if @sprite_fog
      @change_transition = frames
      @starting_opacity = 0
      @destination_opacity = opacity.to_i
      @scompare = 0
      @appare = 0
      @rapp_change = 0.0
      @new_rapp_change =
        @destination_opacity.to_f / frames.to_f

      # 保持與目前資料不同，讓 update_change_fog 負責淡入。
      @data_fog = []
      return true
    rescue
      return false
    end
  end
end

if defined?(Game_Player)
  class Game_Player < Game_Character
    alias fs_legacy_vehicle_player_update update unless method_defined?(:fs_legacy_vehicle_player_update)
    def update
      $riding_data = Riding_Data.new if defined?(Riding_Data) && $riding_data == nil
      # 舊存檔補值
      @not_encounter_vehicle_id ||= Expansion_Vehicle::NOT_ENCOUNTER_VEHICIE_ID if defined?(Expansion_Vehicle)
      @event_vehicle_lock = false if @event_vehicle_lock == nil
      fs_legacy_vehicle_player_update
    end

    if method_defined?(:get_on_event)
      alias fs_legacy_get_on_event get_on_event unless method_defined?(:fs_legacy_get_on_event)
      def get_on_event(event_id, test = false)
        vehicle = $game_map.events[event_id] rescue nil
        return false if vehicle == nil
        fs_legacy_get_on_event(event_id, test)
      end
    end

    if method_defined?(:update_event_vehicle)
      alias fs_legacy_update_event_vehicle update_event_vehicle unless method_defined?(:fs_legacy_update_event_vehicle)
      def update_event_vehicle
        if @vehicle_event_data && !$game_map.events[@vehicle_event_data[3]]
          @vehicle_event_data = nil
          @vehicle_getting_on = false
          @vehicle_getting_off = false
          @transparent = false
          return
        end
        fs_legacy_update_event_vehicle
      end
    end

    def compulsory_off_event_vehicle(erase = false)
      vehicle = $game_map.event_vehicle rescue nil
      if vehicle && vehicle.riding_type?
        ride_off_character
      else
        @transparent = false
      end
      @vehicle_getting_off_wait = true
      @vehicle_hide = false
      @vehicle_event_data = nil
      update_bush_depth
      vehicle.erase if erase && vehicle
    end
  end
end

if defined?(Sprite_Character) && Sprite_Character.method_defined?(:tig_ev_update_bitmap)
  class Sprite_Character < Sprite_Base
    alias fs_legacy_vehicle_sprite_update_bitmap update_bitmap unless method_defined?(:fs_legacy_vehicle_sprite_update_bitmap)
    def update_bitmap
      if @ride_sprite && !@ride_sprite.disposed? && @character &&
         @character.respond_to?(:rided_character) && @character.rided_character
        new_name = riding_pct_name rescue nil
        new_index = riding_pct_index rescue nil
        if @riding_pct_name != new_name || @riding_pct_index != new_index
          FS_LEGACY_SAFE.safe_dispose(@ride_sprite)
          @ride_sprite = nil
        end
      end
      fs_legacy_vehicle_sprite_update_bitmap
    end
  end
end

#==============================================================================
# ■ 啟動時補齊舊存檔/直接測試環境資料
#==============================================================================
if defined?(Scene_Map) && Scene_Map.method_defined?(:start)
  class Scene_Map < Scene_Base
    alias fs_legacy_final_start start unless method_defined?(:fs_legacy_final_start)
    def start
      $game_system.fs_init_variable_window_data if $game_system && $game_system.respond_to?(:fs_init_variable_window_data)
      $game_map.fs_init_multiple_fog_data if $game_map && $game_map.respond_to?(:fs_init_multiple_fog_data)
      $fog_data ||= FS_LEGACY_SAFE.default_fog_data if defined?(Shuu_Fog)
      $fog_transition ||= 0 if defined?(Shuu_Fog)
      $riding_data = Riding_Data.new if defined?(Riding_Data) && $riding_data == nil
      fs_legacy_final_start
    end
  end
end


#==============================================================================
# ■ Sistema Popup di Holy87：地圖／戰鬥共用 Popup 管理器
#------------------------------------------------------------------------------
# 原腳本只在 Scene_Map 接受 Popup.show，因此戰鬥中的：
#   ・手動 Popup.show
#   ・取得物品／金錢
#   ・Holy87 Delay 技能冷卻完成
#   ・升級 Popup
# 都不會顯示。
#
# 本補丁將 Popup.show 先放入共用佇列，再由 Scene_Map 或 Scene_Battle 顯示。
# Chest_Popup Scene 中的 gain_item 會被忽略，避免 Chest 與 Holy87 重複提示。
#==============================================================================
if defined?(H87_Popup) && defined?(Popup) && defined?(Window_Map_Popup)
  module FS_H87_POPUP_QUEUE
    @data = []

    def self.data
      @data ||= []
      return @data
    end

    def self.push(text, icon = 0, tone = nil)
      safe_tone = nil
      if tone != nil && tone.respond_to?(:[])
        safe_tone = [tone[0].to_i, tone[1].to_i,
                     tone[2].to_i, tone[3].to_i]
      end
      data.push([text.to_s, icon.to_i, safe_tone])
    end

    def self.shift
      return data.shift
    end

    def self.unshift_many(entries)
      return if entries == nil || entries.empty?
      @data = entries + data
    end

    def self.clear
      data.clear
    end
  end

  class FS_H87_Popup_Manager
    include H87_Popup

    def initialize
      @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport.z = 9998
      @entries = []
      @disposed = false
    end

    def update
      return if @disposed

      request = FS_H87_POPUP_QUEUE.shift
      while request != nil
        add(request[0], request[1], request[2])
        request = FS_H87_POPUP_QUEUE.shift
      end

      @entries.clone.each do |entry|
        window = entry[0]
        image = entry[1]

        if window == nil || image == nil ||
           window.disposed? || image.disposed?
          dispose_entry(entry)
          next
        end

        target_x = H87_Popup::Distanzax.to_i
        if H87_Popup::Altezza.to_i > Graphics.height / 2
          target_y = H87_Popup::Altezza.to_i -
                     H87_Popup::Distanzay.to_i - entry[3].to_i
        else
          target_y = H87_Popup::Altezza.to_i +
                     H87_Popup::Distanzay.to_i + entry[3].to_i
        end

        speed = H87_Popup::Speed.to_i
        speed = 1 if speed < 1
        window.x = approach(window.x, target_x, speed)
        window.y = approach(window.y, target_y, speed)
        image.x = image_x(window, image)
        image.y = image_y(window, image)

        entry[2] += 1
        hold = H87_Popup::Time.to_i * Graphics.frame_rate
        hold = 0 if hold < 0
        if entry[2] > hold
          fade = H87_Popup::Fade.to_i
          fade = 1 if fade < 1
          window.contents_opacity =
            [window.contents_opacity - fade, 0].max
          image.opacity = [image.opacity - fade, 0].max
        end

        dispose_entry(entry) if image.opacity <= 0
      end
    end

    def add(text, icon = 0, tone = nil)
      return if @disposed

      image = Sprite.new(@viewport)
      image.bitmap = Cache.picture(H87_Popup::Grafica)
      image.tone = Tone.new(tone[0], tone[1], tone[2], tone[3]) if tone
      image.z = 0

      width = image.width
      width = 64 if width < 64
      window = Window_Map_Popup.new(width, text.to_s, icon.to_i)
      window.viewport = @viewport
      window.opacity = 0
      window.contents_opacity = 255
      window.x = -window.width
      window.y = H87_Popup::Altezza.to_i
      window.z = 1

      image.x = image_x(window, image)
      image.y = image_y(window, image)

      move_old_entries
      @entries.push([window, image, 0, 0, text.to_s, icon.to_i, tone])
    rescue
      FS_LEGACY_SAFE.safe_dispose(window) if defined?(window)
      if defined?(image) && image
        image.bitmap = nil rescue nil
        FS_LEGACY_SAFE.safe_dispose(image)
      end
    end

    def dispose(preserve = false)
      return if @disposed

      if preserve
        requests = []
        @entries.each do |entry|
          requests.push([entry[4], entry[5], entry[6]])
        end
        FS_H87_POPUP_QUEUE.unshift_many(requests)
      end

      @entries.clone.each { |entry| dispose_entry(entry) }
      @entries.clear
      FS_LEGACY_SAFE.safe_dispose(@viewport)
      @viewport = nil
      @disposed = true
    end

    private

    def approach(value, target, speed)
      return target if value == target
      delta = (target - value) / speed
      delta = target > value ? 1 : -1 if delta == 0
      result = value + delta
      if target > value
        result = target if result > target
      else
        result = target if result < target
      end
      return result
    end

    def image_x(window, image)
      return window.x + (window.width - image.width) / 2
    end

    def image_y(window, image)
      return window.y + (window.height - image.height) / 2
    end

    def move_old_entries
      @entries.each do |entry|
        image = entry[1]
        next if image == nil || image.disposed?
        entry[3] += image.height + H87_Popup::Distanzay.to_i
      end
    end

    def dispose_entry(entry)
      return if entry == nil
      window = entry[0]
      image = entry[1]
      FS_LEGACY_SAFE.safe_dispose(window)
      if image
        image.bitmap = nil rescue nil
        FS_LEGACY_SAFE.safe_dispose(image)
      end
      @entries.delete(entry)
    end
  end

  module Popup
    def self.show(text, icon = 0, tone = nil)
      # Chest Item Popup 已自行顯示名稱與數量，避免再排入 Holy87。
      return if defined?(Chest_Popup) && $scene.is_a?(Chest_Popup)
      valid_scene = false
      valid_scene = true if defined?(Scene_Map) && $scene.is_a?(Scene_Map)
      valid_scene = true if defined?(Scene_Battle) && $scene.is_a?(Scene_Battle)
      return unless valid_scene
      FS_H87_POPUP_QUEUE.push(text, icon, tone)
    end

    def self.esegui(sound)
      return if sound == nil || sound.to_s.empty?
      return if defined?(Chest_Popup) && $scene.is_a?(Chest_Popup)
      if $scene.is_a?(Scene_Map) ||
         (defined?(Scene_Battle) && $scene.is_a?(Scene_Battle))
        RPG::SE.new(sound.to_s, 80, 100).play
      end
    rescue
    end
  end

  if defined?(Scene_Map) && Scene_Map.method_defined?(:start) &&
     Scene_Map.method_defined?(:update) && Scene_Map.method_defined?(:terminate)
    class Scene_Map < Scene_Base
      alias fs_h87_safe_map_start start unless
        method_defined?(:fs_h87_safe_map_start)
      def start
        fs_h87_safe_map_start
        @fs_h87_popup_manager = FS_H87_Popup_Manager.new
      end

      alias fs_h87_safe_map_update update unless
        method_defined?(:fs_h87_safe_map_update)
      def update
        fs_h87_safe_map_update
        @fs_h87_popup_manager.update if @fs_h87_popup_manager
      end

      alias fs_h87_safe_map_terminate terminate unless
        method_defined?(:fs_h87_safe_map_terminate)
      def terminate
        if @fs_h87_popup_manager
          @fs_h87_popup_manager.dispose(false)
          @fs_h87_popup_manager = nil
        end
        fs_h87_safe_map_terminate
      end
    end
  end

  if defined?(Scene_Battle) && Scene_Battle.method_defined?(:start) &&
     Scene_Battle.method_defined?(:update) && Scene_Battle.method_defined?(:terminate)
    class Scene_Battle < Scene_Base
      alias fs_h87_safe_battle_start start unless
        method_defined?(:fs_h87_safe_battle_start)
      def start
        fs_h87_safe_battle_start
        @fs_h87_popup_manager = FS_H87_Popup_Manager.new
      end

      alias fs_h87_safe_battle_update update unless
        method_defined?(:fs_h87_safe_battle_update)
      def update
        fs_h87_safe_battle_update
        @fs_h87_popup_manager.update if @fs_h87_popup_manager
      end

      alias fs_h87_safe_battle_terminate terminate unless
        method_defined?(:fs_h87_safe_battle_terminate)
      def terminate
        preserve = $scene.is_a?(Scene_Map)
        if @fs_h87_popup_manager
          @fs_h87_popup_manager.dispose(preserve)
          @fs_h87_popup_manager = nil
        end
        fs_h87_safe_battle_terminate
      end
    end

    if defined?(Game_Actor)
      class Game_Actor < Game_Battler
        def display_level_up(new_skills)
          popup_scene = $scene.is_a?(Scene_Map) ||
                        $scene.is_a?(Scene_Battle)
          if popup_scene && H87_Popup::MostraLevel
            text = sprintf("%s %s%d!", @name, Vocab::level, @level)
            Popup.show(text, H87_Popup::IconaLevel, H87_Popup::LivSup)
            Popup.esegui(H87_Popup::SuonoLevel)
            if H87_Popup::MostraPoteri
              new_skills.each do |skill|
                next if skill == nil
                text = sprintf("%s %s", skill.name, H87_Popup::Learn)
                Popup.show(text, skill.icon_index, H87_Popup::NuoveSkill)
              end
            end
          else
            $game_message.new_page
            text = sprintf(Vocab::LevelUp, @name, Vocab::level, @level)
            $game_message.texts.push(text)
            new_skills.each do |skill|
              text = sprintf(Vocab::ObtainSkill, skill.name)
              $game_message.texts.push(text)
            end
          end
        end
      end
    end
  end
end

#==============================================================================
# ■ Message Queue v1.0：實際用途與安全修正
#------------------------------------------------------------------------------
# 目前所有自動 MSG_* 設定均為 false，因此它不會自動提示金錢、物品等。
# 專案目前實際用途是：
#   $game_map.queue.push("文字")
# 顯示地圖最上方的 FIFO 橫幅；隨機地城樓層提示會使用這個功能。
#==============================================================================
if defined?(Marc_Queue) && Marc_Queue.method_defined?(:update) &&
   Marc_Queue.method_defined?(:dispose)
  class Game_Map
    def queue
      @queue ||= []
      return @queue
    end

    def queue=(value)
      @queue = value || []
    end
  end

  class Marc_Queue < Sprite_Base
    alias fs_legacy_queue_bitmap_update update unless
      method_defined?(:fs_legacy_queue_bitmap_update)
    def update
      old_bitmap = self.bitmap
      fs_legacy_queue_bitmap_update
      if old_bitmap != nil && old_bitmap != self.bitmap
        FS_LEGACY_SAFE.safe_dispose(old_bitmap)
      end
    end

    alias fs_legacy_queue_bitmap_dispose dispose unless
      method_defined?(:fs_legacy_queue_bitmap_dispose)
    def dispose
      old_bitmap = self.bitmap
      self.bitmap = nil
      FS_LEGACY_SAFE.safe_dispose(old_bitmap)
      fs_legacy_queue_bitmap_dispose
    end
  end
end


#==============================================================================
# ■ ISS ParaPassa × 飛行交通工具：高度感知邊界
#------------------------------------------------------------------------------
# 地面角色的座標 y 是腳底所在格。
# 飛行船顯示時則使用：
#   screen_y = ground_screen_y - altitude
#
# 大型飛行船最高 altitude = 64 px，也就是向上偏移 2 格。
# 因此飛行狀態的合法 Y 範圍不能仍是 0...map.height：
#
#   空中顯示上限：y >= ceil(altitude / 32)
#   空中顯示下限：y <= map.height - 1 + ceil(altitude / 32)
#
# 這會讓飛行圖像在上下兩端保持對稱：
#   ・不會從上方飛出畫面
#   ・可以向下飛到視覺上的真正底端
#
# 降落仍限定在原始地圖座標 0...height，虛擬空域不能降落。
#==============================================================================
if defined?(Game_Player) &&
   defined?($imported) &&
   $imported &&
   $imported["ISS-ParaPassa"] &&
   (Game_Player.method_defined?(:move_passable?) ||
    Game_Player.private_method_defined?(:move_passable?))

  class Game_Player < Game_Character
    alias fs_legacy_edge_guard_move_passable move_passable? unless
      method_defined?(:fs_legacy_edge_guard_move_passable) ||
      private_method_defined?(:fs_legacy_edge_guard_move_passable)

    alias fs_legacy_edge_guard_airship_land_ok airship_land_ok? unless
      method_defined?(:fs_legacy_edge_guard_airship_land_ok) ||
      private_method_defined?(:fs_legacy_edge_guard_airship_land_ok)

    def fs_flight_vehicle_for_edge
      return nil unless [2, 4].include?(@vehicle_type.to_i)
      return now_vehicle if respond_to?(:now_vehicle)
      return $game_map.vehicles[@vehicle_type] if
        $game_map && $game_map.respond_to?(:vehicles)
      return nil
    rescue
      return nil
    end

    def fs_flight_edge_offset_tiles
      vehicle = fs_flight_vehicle_for_edge
      return 0 if vehicle == nil
      altitude = vehicle.altitude.to_i
      return 0 if altitude <= 0
      return (altitude + 31) / 32
    rescue
      return 0
    end

    def fs_flight_visual_y_bounds
      offset = fs_flight_edge_offset_tiles
      return [offset, $game_map.height - 1 + offset]
    end

    def move_passable?(xo, yo, xt, yt)
      if $game_map
        unless $game_map.loop_horizontal?
          return false if xt < 0 || xt >= $game_map.width
        end

        unless $game_map.loop_vertical?
          min_y, max_y = fs_flight_visual_y_bounds
          return false if yt < min_y || yt > max_y
        end

        # 飛行船本來就是穿透地形。當座標位於地圖下方的虛擬空域時，
        # 不再交給 ParaPassa 讀取不存在的 Tile 資料。
        if [2, 4].include?(@vehicle_type.to_i) && @through
          return true
        end
      end

      return fs_legacy_edge_guard_move_passable(xo, yo, xt, yt)
    end

    def airship_land_ok?(x, y)
      return false unless $game_map
      return false unless $game_map.valid?(x, y)
      return fs_legacy_edge_guard_airship_land_ok(x, y)
    end
  end
end


#==============================================================================
# ■ 大型飛行船：自動管理 Overlay 與雲層 Fog
#------------------------------------------------------------------------------
# 目的：
#   ・登上大型飛行船時，不讓 Par／Shadow／Ground 壓在飛行角色上。
#   ・自動套用低透明度 Fog，呈現飛在雲端的效果。
#   ・降落時恢復起飛前的各圖層開關與原本 Fog。
#   ・地圖轉移中仍維持飛行效果，降落後恢復各地圖原始 Fog。
#
# 公共事件可移除：
#   Shuu_Fog.change(60,"fog",1,0,35,0)
#   Switch 202／203／204 的 OFF 操作
#   若有第二 Shadow，Switch 205 的 OFF 操作
#
# 仍可保留：
#   騎乘物選擇、召喚動畫、角色圖變更、等待、乘降指令等劇情演出。
#==============================================================================
module FS_FLIGHT_VISUAL
  # 乗り物拡張：
  #   2 = 標準飛行船
  #   4 = 大型飛行船
  #   5 = 魔法飛毯
  #
  # 本專案 Ring Menu 實際使用大型飛行船，因此預設只處理 4。
  VEHICLE_TYPES = [4]

  # Ultimate Overlay Mapping
  SHADOW_SWITCH  = 202
  PAR_SWITCH     = 203
  GROUND_SWITCH  = 204
  SHADOW2_SWITCH = 205

  HIDDEN_OVERLAY_SWITCHES = [
    SHADOW_SWITCH,
    PAR_SWITCH,
    GROUND_SWITCH,
    SHADOW2_SWITCH
  ]

  # 與原公共事件設定一致
  FOG_TRANSITION = 75

  # 原公共事件會在乘降前先啟動 Fog 並等待 15 幀。
  # 腳本版第一次建立 Fog Plane 時，改用 15 幀直接淡入，
  # 避免第一趟起飛看起來完全沒有雲層。
  FIRST_FOG_FADE_IN = 20


  FOG_NAME       = "fog"
  FOG_SPEED_X    = 1
  FOG_SPEED_Y    = 0
  FOG_OPACITY    = 55
  FOG_BLEND      = 0

  RESTORE_TRANSITION = 60

  def self.flight_vehicle_type?(vehicle_type)
    return VEHICLE_TYPES.include?(vehicle_type.to_i)
  end

  def self.fog_available?
    return false unless defined?(Shuu_Fog)
    return false unless defined?($fog_data)
    return $fog_data.is_a?(Hash)
  end
end

if defined?(Game_Player)
  class Game_Player < Game_Character
    def fs_flight_visual_active?
      return @fs_flight_visual_active == true
    end


    def fs_flight_current_spriteset
      return nil unless defined?($scene) && $scene
      return nil unless defined?(Scene_Map) &&
                        $scene.is_a?(Scene_Map)
      return $scene.instance_variable_get("@spriteset")
    rescue
      return nil
    end

    def fs_flight_visual_begin
      return if fs_flight_visual_active?
      return unless $game_switches && $game_map

      @fs_flight_overlay_states = {}
      FS_FLIGHT_VISUAL::HIDDEN_OVERLAY_SWITCHES.each do |switch_id|
        @fs_flight_overlay_states[switch_id] =
          $game_switches[switch_id]
      end

      @fs_flight_fog_states = {}
      @fs_flight_visual_active = true
      @fs_flight_visual_landing = false
      @fs_flight_fog_restore_started = false
      @fs_flight_visual_map_id = nil
      fs_flight_visual_apply_current_map
    end

    def fs_flight_visual_apply_current_map
      return unless fs_flight_visual_active?
      return unless $game_map && $game_switches

      map_id = $game_map.map_id
      return if map_id == nil || map_id <= 0

      FS_FLIGHT_VISUAL::HIDDEN_OVERLAY_SWITCHES.each do |switch_id|
        $game_switches[switch_id] = false
      end

      if FS_FLIGHT_VISUAL.fog_available?
        @fs_flight_fog_states = {} if @fs_flight_fog_states == nil

        unless @fs_flight_fog_states.has_key?(map_id)
          existed = $fog_data.has_key?(map_id)
          old_data = nil
          if existed && $fog_data[map_id] != nil
            old_data = $fog_data[map_id].clone
          end
          @fs_flight_fog_states[map_id] = [existed, old_data]
        end

        old_visible_fog =
          existed &&
          old_data != nil &&
          old_data[0].to_s != ""

        first_fog_started = false
        unless old_visible_fog
          spriteset = fs_flight_current_spriteset
          if spriteset &&
             spriteset.respond_to?(:fs_flight_first_fog_fade_in)
            first_fog_started =
              spriteset.fs_flight_first_fog_fade_in(
                FS_FLIGHT_VISUAL::FIRST_FOG_FADE_IN,
                FS_FLIGHT_VISUAL::FOG_NAME,
                FS_FLIGHT_VISUAL::FOG_SPEED_X,
                FS_FLIGHT_VISUAL::FOG_SPEED_Y,
                FS_FLIGHT_VISUAL::FOG_OPACITY,
                FS_FLIGHT_VISUAL::FOG_BLEND
              )
          end
        end

        unless first_fog_started
          Shuu_Fog.change(
            FS_FLIGHT_VISUAL::FOG_TRANSITION,
            FS_FLIGHT_VISUAL::FOG_NAME,
            FS_FLIGHT_VISUAL::FOG_SPEED_X,
            FS_FLIGHT_VISUAL::FOG_SPEED_Y,
            FS_FLIGHT_VISUAL::FOG_OPACITY,
            FS_FLIGHT_VISUAL::FOG_BLEND
          )
        end
      end

      @fs_flight_visual_map_id = map_id
    end

    # 降落開始時只啟動 Fog 還原，不立刻結束飛行視覺狀態。
    # 大型飛行船在 altitude 歸零前，@vehicle_type 仍然是 4；
    # 若此時把 active 清掉，下一幀 sync 會誤判為重新起飛。
    def fs_flight_visual_start_landing
      return unless fs_flight_visual_active?
      return if @fs_flight_visual_landing == true
      @fs_flight_visual_landing = true
      fs_flight_visual_start_fog_restore
    end

    def fs_flight_visual_start_fog_restore
      return if @fs_flight_fog_restore_started == true
      return unless FS_FLIGHT_VISUAL.fog_available?
      return unless @fs_flight_fog_states && $game_map

      current_map_id = $game_map.map_id
      state = @fs_flight_fog_states[current_map_id]
      return if state == nil

      existed = state[0]
      old_data = state[1]

      if existed && old_data != nil
        Shuu_Fog.change(
          FS_FLIGHT_VISUAL::RESTORE_TRANSITION,
          old_data[0],
          old_data[1],
          old_data[2],
          old_data[3],
          old_data[4]
        )
      else
        Shuu_Fog.change(
          FS_FLIGHT_VISUAL::RESTORE_TRANSITION,
          "", 0, 0, 0, 0
        )
        @fs_flight_pending_fog_delete_map_id =
          current_map_id
      end

      @fs_flight_fog_restore_started = true
    end

    def fs_flight_visual_restore
      return unless fs_flight_visual_active?

      if $game_switches && @fs_flight_overlay_states
        @fs_flight_overlay_states.each do |switch_id, value|
          $game_switches[switch_id] = value
        end
      end

      if FS_FLIGHT_VISUAL.fog_available? &&
         @fs_flight_fog_states &&
         $game_map
        current_map_id = $game_map.map_id

        # 非目前地圖直接還原資料，不需要做畫面轉場。
        @fs_flight_fog_states.each do |map_id, state|
          next if map_id == current_map_id
          existed = state[0]
          old_data = state[1]
          if existed
            $fog_data[map_id] =
              old_data == nil ? nil : old_data.clone
          else
            $fog_data.delete(map_id)
          end
        end

        # 若降落開始時尚未排程 Fog 還原，現在才補做。
        # 已排程時絕不重設 Shuu Fog 的 transition。
        fs_flight_visual_start_fog_restore unless
          @fs_flight_fog_restore_started == true
      end

      @fs_flight_visual_active = false
      @fs_flight_visual_landing = false
      @fs_flight_fog_restore_started = false
      @fs_flight_visual_map_id = nil
      @fs_flight_overlay_states = nil
      @fs_flight_fog_states = nil
    end

    def fs_flight_visual_cleanup_blank_fog
      map_id = @fs_flight_pending_fog_delete_map_id
      return if map_id == nil
      return unless FS_FLIGHT_VISUAL.fog_available?
      return unless $game_map && $game_map.map_id == map_id
      return unless defined?($fog_transition)
      return unless $fog_transition.to_i == 0

      fog_data = $fog_data[map_id]
      if fog_data != nil && fog_data[0].to_s == ""
        $fog_data.delete(map_id)
      end
      @fs_flight_pending_fog_delete_map_id = nil
    end

    def fs_flight_visual_sync
      vehicle_type = @vehicle_type.to_i

      if FS_FLIGHT_VISUAL.flight_vehicle_type?(vehicle_type)
        unless @fs_flight_visual_landing == true
          fs_flight_visual_begin unless fs_flight_visual_active?

          if fs_flight_visual_active? &&
             $game_map &&
             @fs_flight_visual_map_id != $game_map.map_id
            fs_flight_visual_apply_current_map
          end
        end
      elsif fs_flight_visual_active?
        # 強制下車、舊存檔修復或其他腳本直接改 vehicle_type 時也能還原。
        fs_flight_visual_restore
      end

      fs_flight_visual_cleanup_blank_fog
    end

    if method_defined?(:get_on_big_airship) ||
       private_method_defined?(:get_on_big_airship)
      alias fs_flight_visual_get_on_big_airship get_on_big_airship unless
        method_defined?(:fs_flight_visual_get_on_big_airship) ||
        private_method_defined?(:fs_flight_visual_get_on_big_airship)

      def get_on_big_airship
        result = fs_flight_visual_get_on_big_airship
        fs_flight_visual_begin
        return result
      end
    end

    if method_defined?(:get_off_vehicle) ||
       private_method_defined?(:get_off_vehicle)
      alias fs_flight_visual_get_off_vehicle get_off_vehicle unless
        method_defined?(:fs_flight_visual_get_off_vehicle) ||
        private_method_defined?(:fs_flight_visual_get_off_vehicle)

      def get_off_vehicle
        old_vehicle_type = @vehicle_type
        result = fs_flight_visual_get_off_vehicle
        if result &&
           FS_FLIGHT_VISUAL.flight_vehicle_type?(old_vehicle_type)
          fs_flight_visual_start_landing
        end
        return result
      end
    end

    if method_defined?(:update) ||
       private_method_defined?(:update)
      alias fs_flight_visual_update update unless
        method_defined?(:fs_flight_visual_update) ||
        private_method_defined?(:fs_flight_visual_update)

      def update
        fs_flight_visual_update
        fs_flight_visual_sync
      end
    end
  end
end


#==============================================================================
# ■ ATS／Quest Journal：繁體中文 UTF-8 排版相容
#------------------------------------------------------------------------------
# 原始問題：
#   ・RGSS2 的 String#size 與 String#[i,1] 以 UTF-8 byte 為單位。
#   ・原 ATS／Quest formatter 只把半形空白視為單字邊界。
#   ・無空白繁中因此會被當成一個超長英文單字。
#   ・Quest 左右對齊又以 byte 數分配間距，並有 objectives 行高 -10。
#
# 修正：
#   ・以完整 UTF-8 字元量測，不拆中文字與控制碼參數。
#   ・繁中可逐字換行；英文仍優先在空白處換行。
#   ・避免句首出現大多數閉合標點、句尾留下開啟標點。
#   ・Quest blank_width 依可見字元／圖示數量計算。
#   ・Description／Objectives 使用 font_size + 4 的實際行高。
#==============================================================================
module FS_CJK_TEXT
  NO_LINE_START_TEXT = "，。！？；：、）》】」』〕〉］｝％%…‥—～・,.!?;:)]}”’"
  NO_LINE_END_TEXT   = "（《【「『〔〈［｛([{“‘"

  begin
    NO_LINE_START = NO_LINE_START_TEXT.scan(/./u)
    NO_LINE_END   = NO_LINE_END_TEXT.scan(/./u)
  rescue
    NO_LINE_START = NO_LINE_START_TEXT.scan(/./m)
    NO_LINE_END   = NO_LINE_END_TEXT.scan(/./m)
  end

  def self.chars(text)
    return [] if text == nil || text == ""
    begin
      return text.scan(/./u)
    rescue
      return text.scan(/./m)
    end
  end

  def self.utf8_char_at(text, index)
    return [nil, 0] if text == nil || index == nil || index >= text.size
    first = text[index, 1]
    return [nil, 0] if first == nil || first == ""
    byte = first.unpack("C")[0]
    length = 1
    if byte >= 0xF0
      length = 4
    elsif byte >= 0xE0
      length = 3
    elsif byte >= 0xC0
      length = 2
    end
    value = text[index, length]
    value = first if value == nil || value == ""
    return [value, value.size]
  rescue
    return [text[index, 1], 1]
  end

  def self.multibyte?(character)
    return false if character == nil || character == ""
    return character.size > 1
  end

  def self.no_line_start?(character)
    return NO_LINE_START.include?(character)
  end

  def self.no_line_end?(character)
    return NO_LINE_END.include?(character)
  end

  def self.break_before?(character, previous_character)
    return false unless multibyte?(character)
    return false if no_line_start?(character)
    return false if previous_character != nil &&
                    no_line_end?(previous_character)
    return true
  end

  def self.line_height(font_size)
    size = font_size.to_i
    size = 1 if size < 1
    return size + 4
  end
end

#==============================================================================
# ■ ATS P_Formatter_ATS：UTF-8 安全的單行格式判定
#==============================================================================
if defined?(P_Formatter_ATS)
  class P_Formatter_ATS
    alias fs_cjk_original_format_by_line format_by_line unless
      method_defined?(:fs_cjk_original_format_by_line) ||
      private_method_defined?(:fs_cjk_original_format_by_line)

    def fs_cjk_ats_token_at(index)
      code = @string[index, 1]
      return nil if code == nil || code == ""

      if @curly_args_codes.include?(code)
        close_index = @string.index("}", index + 1)
        length = close_index == nil ? 1 : close_index - index + 1
        return [@string[index, length], length, :control, code]
      elsif @args_codes.include?(code)
        close_index = @string.index(">", index + 1)
        length = close_index == nil ? 1 : close_index - index + 1
        kind = code == "\x0d" ? :icon : :control
        return [@string[index, length], length, kind, code]
      elsif @no_args_codes.include?(code)
        kind = ["\x00", "\x1d"].include?(code) ? :newline :
               (code == "\x09" ? :tab : :control)
        return [code, 1, kind, code]
      end

      character, length = FS_CJK_TEXT.utf8_char_at(@string, index)
      kind = character == " " ? :space : :visible
      return [character, length, kind, character]
    end

    def fs_cjk_ats_apply_control(raw, code, line_width)
      width = 0
      count = 0
      new_line_width = line_width
      argument = nil
      if raw != nil && raw[/<(.*?)>/m]
        argument = $1.to_s
      end

      case code
      when "\x0d"
        width = 24
        count = 1
      when "\x0e"
        @bitmap.font.bold = (argument.to_i == 0)
      when "\x0f"
        @bitmap.font.italic = (argument.to_i == 0)
      when "\x10"
        @bitmap.font.shadow = (argument.to_i == 0)
      when "\x13"
        names = @bitmap.font.name
        names = [names] unless names.is_a?(Array)
        @bitmap.font.name = ([argument] + names).uniq
      when "\x14"
        size = argument.to_i
        @bitmap.font.size = size if size > 0
      when "\xb1"
        new_line_width = argument.to_i
      end
      return [width, count, new_line_width]
    end

    def fs_cjk_ats_result(line_width, draw_count, justify, force_break)
      @line_width = line_width
      @l_draw_count = draw_count
      @justify = justify
      @force_break = force_break
      blank = @max_width - line_width
      blank = 0 if blank < 0
      divisor = [draw_count.to_f - 1.0, 1.0].max
      @line_space = blank.to_f / divisor
      return @line_space, draw_count, justify
    end

    def fs_cjk_ats_insert_break(index, replace_length)
      if replace_length.to_i > 0
        @string[index, replace_length] = "\x00"
      else
        @string[index, 0] = "\x00"
      end
    end

    def format_by_line(string, width)
      @string = string
      @max_width = width.to_i
      @max_width = 1 if @max_width < 1
      justify = $game_message.justified_text
      return 0, 0, justify if @string == nil || @string.empty?

      line_width = 0
      draw_count = 0
      last_candidate = nil
      cluster_start = 0
      previous_visible = nil
      index = 0

      while index < @string.size
        token = fs_cjk_ats_token_at(index)
        break if token == nil
        raw, length, kind, value = token

        if kind == :newline
          return fs_cjk_ats_result(line_width, draw_count, false, true)
        end

        before_width = line_width
        before_count = draw_count
        before_cluster = cluster_start
        token_width = 0
        token_count = 0

        if kind == :control
          result = fs_cjk_ats_apply_control(raw, value, line_width)
          token_width = result[0]
          token_count = result[1]
          line_width = result[2]
        elsif kind == :tab
          line_width = ((line_width / 32) + 1) * 32
        elsif kind == :icon
          result = fs_cjk_ats_apply_control(raw, value, line_width)
          token_width = result[0]
          token_count = result[1]
        elsif kind == :space
          last_candidate = [index, length, line_width, draw_count]
          token_width = @bitmap.text_size(raw).width
          token_count = 1
        else
          if FS_CJK_TEXT.break_before?(raw, previous_visible) &&
             before_cluster > 0
            last_candidate = [before_cluster, 0,
                              line_width, draw_count]
          end
          token_width = @bitmap.text_size(raw).width
          token_count = 1
        end

        line_width += token_width
        draw_count += token_count

        if line_width > @max_width && draw_count > 0
          if last_candidate != nil && last_candidate[0] > 0
            fs_cjk_ats_insert_break(last_candidate[0],
                                    last_candidate[1])
            return fs_cjk_ats_result(last_candidate[2],
                                     last_candidate[3], justify, false)
          elsif before_cluster > 0
            fs_cjk_ats_insert_break(before_cluster, 0)
            return fs_cjk_ats_result(before_width,
                                     before_count, justify, false)
          end
        end

        if kind == :visible || kind == :icon || kind == :space
          cluster_start = index + length
          previous_visible = raw if kind == :visible
        end
        index += length
      end

      @string[@string.size, 0] = "\x00"
      return fs_cjk_ats_result(line_width, draw_count, false, false)
    rescue
      return fs_cjk_original_format_by_line(string, width)
    end
  end
end

#==============================================================================
# ■ Quest Journal Formatter_SpecialCodes：UTF-8 逐字換行
#==============================================================================
if defined?(Paragrapher) &&
   Paragrapher.const_defined?(:Formatter_SpecialCodes) &&
   Paragrapher.const_defined?(:Formatted_Text)
  module Paragrapher
    class Formatter_SpecialCodes < Formatter
      alias fs_cjk_original_format format unless
        method_defined?(:fs_cjk_original_format) ||
        private_method_defined?(:fs_cjk_original_format)

      def fs_cjk_qj_token_at(text, index)
        code = text[index, 1]
        return nil if code == nil || code == ""

        if args_codes.include?(code)
          close_index = text.index(">", index + 1)
          length = close_index == nil ? 1 : close_index - index + 1
          kind = code == "\x02" ? :icon : :control
          return [text[index, length], length, kind, code, nil, 0, 0]
        elsif no_args_codes.include?(code)
          return [code, 1, :control, code, nil, 0, 0]
        elsif code == "\n"
          return [code, 1, :newline, code, nil, 0, 0]
        end

        character, length = FS_CJK_TEXT.utf8_char_at(text, index)
        kind = character == " " ? :space : :visible
        return [character, length, kind, character, character, 0, 0]
      end

      def fs_cjk_qj_apply_token(token, bitmap)
        kind = token[2]
        code = token[3]
        raw = token[0]
        width = 0
        count = 0

        if kind == :icon
          width = 24
          count = 1
        elsif kind == :space || kind == :visible
          width = bitmap.text_size(raw).width
          count = 1
        elsif kind == :control
          case code
          when "\x03" then bitmap.font.bold = true
          when "\x04" then bitmap.font.italic = true
          when "\x05" then bitmap.font.shadow = true
          when "\x07" then bitmap.font.bold = false
          when "\x08" then bitmap.font.italic = false
          when "\x09" then bitmap.font.shadow = false
          end
        end

        token[5] = width
        token[6] = count
        return token
      end

      def fs_cjk_qj_metrics(tokens)
        width = 0
        count = 0
        candidate = nil
        cluster_start = 0
        previous_visible = nil

        for index in 0...tokens.size
          token = tokens[index]
          kind = token[2]
          if kind == :space
            candidate = [index, width, count, 1]
          elsif kind == :visible
            character = token[4]
            if FS_CJK_TEXT.break_before?(character, previous_visible) &&
               cluster_start > 0
              candidate = [cluster_start, width, count, 0]
            end
          end

          width += token[5].to_i
          count += token[6].to_i

          if [:space, :visible, :icon].include?(kind)
            cluster_start = index + 1
            previous_visible = token[4] if kind == :visible
          end
        end
        return [width, count, candidate]
      end

      def fs_cjk_qj_last_cluster_start(tokens)
        cluster_start = 0
        last_start = nil
        for index in 0...tokens.size
          kind = tokens[index][2]
          if [:space, :visible, :icon].include?(kind)
            last_start = cluster_start
            cluster_start = index + 1
          end
        end
        return last_start
      end

      def fs_cjk_qj_remove_leading_spaces(tokens)
        loop do
          break if tokens.empty?
          break unless tokens[0][2] == :space
          tokens.shift
        end
        return tokens
      end

      def fs_cjk_qj_push_line(lines, blanks, tokens,
                              width, count, hard_break, final_line)
        raw = ""
        tokens.each { |token| raw += token[0].to_s }
        line_chars = FS_CJK_TEXT.chars(raw)
        lines.push(line_chars)

        if hard_break || final_line || count.to_i <= 1
          blanks.push(0)
        else
          blank = @max_width - width.to_i
          blank = 0 if blank < 0
          # Artist_SpecialCodes 會在每個可見字元／圖示後加一次 spacing。
          blanks.push(blank.to_f / count.to_f)
        end
      end

      def format(string, specifications)
        converted = convert_special_characters(string == nil ? "" : string.dup)

        numeric_specs = specifications.is_a?(Numeric)
        if specifications.is_a?(Bitmap)
          bitmap = specifications
          @max_width = bitmap.width
        elsif numeric_specs
          @max_width = specifications.to_i
          @max_width = 1 if @max_width < 1
          bitmap = Bitmap.new(@max_width, 32)
        else
          return fs_cjk_original_format(string, specifications)
        end

        source_tokens = []
        index = 0
        while index < converted.size
          token = fs_cjk_qj_token_at(converted, index)
          break if token == nil
          source_tokens.push(fs_cjk_qj_apply_token(token, bitmap))
          index += token[1]
        end

        lines = []
        blanks = []
        line_tokens = []

        source_tokens.each do |token|
          if token[2] == :newline
            line_tokens.push(token)
            metrics = fs_cjk_qj_metrics(line_tokens)
            fs_cjk_qj_push_line(lines, blanks, line_tokens,
                                metrics[0], metrics[1], true, false)
            line_tokens = []
            next
          end

          line_tokens.push(token)
          loop do
            metrics = fs_cjk_qj_metrics(line_tokens)
            width = metrics[0]
            count = metrics[1]
            candidate = metrics[2]
            break if width <= @max_width || count <= 1

            split_index = nil
            drop_count = 0
            if candidate != nil && candidate[0].to_i > 0
              split_index = candidate[0].to_i
              drop_count = candidate[3].to_i
            else
              split_index = fs_cjk_qj_last_cluster_start(line_tokens)
            end

            break if split_index == nil || split_index <= 0

            prefix = line_tokens[0, split_index]
            suffix_start = split_index + drop_count
            suffix_length = line_tokens.size - suffix_start
            suffix = suffix_length > 0 ?
                     line_tokens[suffix_start, suffix_length] : []
            prefix_metrics = fs_cjk_qj_metrics(prefix)
            fs_cjk_qj_push_line(lines, blanks, prefix,
                                prefix_metrics[0], prefix_metrics[1],
                                false, false)
            line_tokens = fs_cjk_qj_remove_leading_spaces(suffix)
          end
        end

        if !line_tokens.empty? || lines.empty?
          metrics = fs_cjk_qj_metrics(line_tokens)
          fs_cjk_qj_push_line(lines, blanks, line_tokens,
                              metrics[0], metrics[1], false, true)
        else
          blanks[-1] = 0 unless blanks.empty?
        end
        blanks[-1] = 0 unless blanks.empty?

        if numeric_specs
          old_font = bitmap.font.dup
          bitmap.dispose unless bitmap.disposed?
          bitmap = Bitmap.new(@max_width,
                              [lines.size * Window_Base::WLH, 1].max)
          bitmap.font = old_font
        end

        return Formatted_Text.new(lines, blanks, bitmap)
      rescue
        return fs_cjk_original_format(string, specifications)
      end
    end
  end
end

#==============================================================================
# ■ Quest Journal：Description／Objectives／Rewards 實際行高
#==============================================================================
if defined?(Window_QuestInfo) && defined?(QuestData)
  class Window_QuestInfo < Window_Base
    alias fs_cjk_original_calculate_height_req calculate_height_req unless
      method_defined?(:fs_cjk_original_calculate_height_req) ||
      private_method_defined?(:fs_cjk_original_calculate_height_req)

    def calculate_height_req(section)
      case section
      when :description
        if @paragrapher && !@quest.description.empty?
          bmp = Bitmap.new(contents.width - 16, WLH)
          bmp.font = contents.font.dup
          bmp.font.size = QuestData::DESC_FONTSIZE
          @desc_ft = @paragrapher.formatter.format(
            @quest.description, bmp)
          line_height = FS_CJK_TEXT.line_height(bmp.font.size)
          return (@desc_ft.lines.size * line_height) +
                 ((3 * WLH) / 2) + 4
        end
        return 0
      when :objectives
        if @paragrapher && !@quest.revealed_objectives.empty?
          tw = contents.text_size(QuestData::OBJECTIVE_BULLET).width
          bmp = Bitmap.new(contents.width - 12 - tw, WLH)
          bmp.font = contents.font.dup
          bmp.font.size = QuestData::OBJ_FONTSIZE
          line_height = FS_CJK_TEXT.line_height(bmp.font.size)
          height = 0
          @objs_ft = []
          for objective_index in @quest.revealed_objectives
            ft = @paragrapher.formatter.format(
              @quest.objectives[objective_index].dup, bmp)
            height += (ft.lines.size * line_height) + 4
            @objs_ft.push(ft)
          end
          return height + 2
        end
        return 0
      when :rewards
        unless @quest.rewards.empty?
          reward_line_height = [WLH, 24].max
          return (reward_line_height * (@quest.rewards.size + 1)) + 8
        end
        return 0
      end
      return fs_cjk_original_calculate_height_req(section)
    end

    def draw_description(y)
      return y if !@paragrapher || @quest.description.empty?

      line_height = FS_CJK_TEXT.line_height(
        @desc_ft.bitmap.font.size)
      height = @desc_ft.lines.size * line_height
      font = @desc_ft.bitmap.font.dup
      @desc_ft.bitmap.dispose unless @desc_ft.bitmap.disposed?
      @desc_ft.bitmap = Bitmap.new(self.contents.width, height)
      @desc_ft.bitmap.font = font

      set_font(1)
      rect = Rect.new(2, y + (WLH / 2),
                      self.contents.width - 4, height + WLH)
      rect2 = Rect.new(4, y + (WLH / 2) + 2,
                       self.contents.width - 8,
                       height + WLH - 4)
      if Bitmap.method_defined?(:fill_rounded_rect)
        self.contents.fill_rounded_rect(
          rect, Color.new(65, 117, 120))
        self.contents.fill_rounded_rect(
          rect2, Color.new(0, 0, 0, 88))
      else
        self.contents.fill_rect(rect, self.contents.font.color)
        self.contents.clear_rect(rect2)
      end

      @paragrapher.artist.draw(
        @desc_ft, QuestData::JUSTIFY_PARAGRAPHS)
      self.contents.blt(8, y + WLH,
                        @desc_ft.bitmap, @desc_ft.bitmap.rect)
      @desc_ft.bitmap.dispose unless @desc_ft.bitmap.disposed?
      @desc_ft = nil
      return rect.y + rect.height + 4
    end

    def draw_objectives(y)
      return y if !@paragrapher ||
                  @quest.revealed_objectives.empty?

      set_font(1)
      self.contents.draw_text(
        32, y, contents.width - 32, WLH,
        QuestData::VOCAB_OBJECTIVES)
      tw = self.contents.text_size(
        QuestData::OBJECTIVE_BULLET).width
      y += WLH
      source_bitmap = @objs_ft[0].bitmap

      for index in 0...@quest.revealed_objectives.size
        set_font(1)
        self.contents.draw_text(
          8, y, tw, WLH, QuestData::OBJECTIVE_BULLET)
        set_font(0)

        ft = @objs_ft[index]
        line_height = FS_CJK_TEXT.line_height(
          source_bitmap.font.size)
        height = ft.lines.size * line_height
        ft.bitmap = Bitmap.new(contents.width, height)
        ft.bitmap.font = source_bitmap.font.dup
        objective = @quest.revealed_objectives[index]
        ft.bitmap.font.color = text_color(
          @quest.objective_complete?(objective) ?
          QuestData::COLOURS[:complete] :
          (@quest.objective_failed?(objective) ?
           QuestData::COLOURS[:failed] :
           QuestData::COLOURS[:active]))
        @paragrapher.artist.draw(
          ft, QuestData::JUSTIFY_PARAGRAPHS)
        self.contents.blt(12 + tw, y + 2,
                          ft.bitmap, ft.bitmap.rect)
        y += height + 4
        ft.bitmap.dispose unless ft.bitmap.disposed?
      end

      source_bitmap.dispose unless source_bitmap.disposed?
      @objs_ft.clear
      return y + 2
    end
  end
end


#==============================================================================
# ■ Quest Journal：Rewards icon 垂直對齊與底部安全留白
#------------------------------------------------------------------------------
# 問題：最後一行獎勵若含 24x24 icon，原腳本以 WLH 緊貼 bitmap 底端繪製，
#       會出現最後一行 icon 底部被切掉 1~數 px 的情況。
# 修正：
#   1. rewards 區塊高度額外加 8 px。
#   2. draw_rewards 最後保留 6 px 底部留白。
#==============================================================================
module FS_QUEST_REWARD_LAYOUT
  # Quest rewards 專用。負數代表 icon 上移。
  ICON_Y_OFFSET = -1
end

if defined?(Window_QuestInfo)
  class Window_QuestInfo < Window_Base
    alias fs_cjk_rewards_original_draw_rewards draw_rewards unless
      method_defined?(:fs_cjk_rewards_original_draw_rewards) ||
      private_method_defined?(:fs_cjk_rewards_original_draw_rewards)

    def draw_rewards(y)
      return y if @quest.rewards.empty?
      y += 25 if $scene.is_a?(Scene_QuestPurchase)
      set_font(1)
      self.contents.draw_text(32, y, contents.width - 32, WLH,
                              QuestData::VOCAB_REWARDS)
      x = QuestData::REWARD_BULLET.empty? ? 8 :
          12 + (contents.text_size(QuestData::REWARD_BULLET).width)
      y += WLH
      reward_line_height = [WLH, 24].max
      for reward in @quest.rewards
        set_font(1)
        self.contents.draw_text(8, y, 100, WLH, QuestData::REWARD_BULLET)
        set_font(0)
        self.contents.font.size = QuestData::REWARD_FONTSIZE
        if reward.is_a?(Array)
          item = nil
          case reward[0]
          when 0 then item = $data_items[reward[1]]
          when 1 then item = $data_weapons[reward[1]]
          when 2 then item = $data_armors[reward[1]]
          when 3
            draw_icon(QuestData::ICONS[:gold], x,
                      y + FS_QUEST_REWARD_LAYOUT::ICON_Y_OFFSET)
            self.contents.font.color = normal_color
            self.contents.draw_text(x + 24, y, contents.width - x - 24,
                                    WLH, reward[1].to_s)
            if QuestData::DRAW_VOCAB_GOLD
              tw = self.contents.text_size(reward[1].to_s).width
              self.contents.font.color = system_color
              self.contents.draw_text(x + tw + 28, y,
                                      contents.width - x - 28 - tw,
                                      WLH, Vocab::gold)
            end
          when 4
            draw_icon(QuestData::ICONS[:exp], x,
                      y + FS_QUEST_REWARD_LAYOUT::ICON_Y_OFFSET)
            self.contents.font.color = normal_color
            self.contents.draw_text(x + 24, y, contents.width - x - 24,
                                    WLH, reward[1].to_s)
            tw = self.contents.text_size(reward[1].to_s).width
            self.contents.font.color = system_color
            self.contents.draw_text(x + tw + 28, y,
                                    contents.width - x - 28 - tw,
                                    WLH, QuestData::VOCAB_EXP)
          end
          if item != nil
            # Quest rewards 專用繪製，不修改全域 draw_item_name。
            draw_icon(item.icon_index, x,
                      y + FS_QUEST_REWARD_LAYOUT::ICON_Y_OFFSET)
            contents.font.color = normal_color
            contents.draw_text(x + 24, y,
                               contents.width - x - 24,
                               WLH, item.name)
            unless reward[2].nil?
              contents.font.color = system_color
              tw = contents.text_size(item.name).width + 28
              contents.draw_text(x + tw, y, 100, WLH,
                                 "#{QuestData::ITEM_NUMBER_PREFACE}#{reward[2]}")
            end
          end
        else
          set_font(0)
          if Object.const_defined?(:Paragrapher) &&
             Paragrapher.const_defined?(:Formatter_SpecialCodes)
            bmp = Bitmap.new(contents.width - x, WLH)
            bmp.font = contents.font.dup
            bmp.font.size = QuestData::REWARD_FONTSIZE
            @paragrapher.paragraph(reward, bmp)
            self.contents.blt(x, y, bmp, bmp.rect)
            bmp.dispose unless bmp.disposed?
          else
            self.contents.draw_text(x, y, contents.width - x, WLH, reward)
          end
        end
        y += reward_line_height
      end
      return y + 6
    end
  end
end
