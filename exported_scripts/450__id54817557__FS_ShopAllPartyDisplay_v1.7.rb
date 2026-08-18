#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_ShopAllPartyDisplay v1.7
# 【用途】Forest Symphony 專用 Runtime／資料腳本「FS_ShopAllPartyDisplay v1.7」。
# 【主要機制】屬目前正式專案功能的一部分；具體責任以本頁定義的類別、模組與方法，以及 LoadOrder Guide 為準。
# 【主要影響】Window_FSShopFooterHelp、Game_Temp、Game_Party、Window_ShopStatus、Game_Interpreter、FS_SHOP_ALL_PARTY
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：MAIN_ACTOR_IDS、USE_SUFFIX_1、SHOW_DISABLED_GRAPHIC、ENABLED_OPACITY、DISABLED_OPACITY、DISABLED_PATTERN、ANIMATION_INTERVAL、ANIMATION_SEQUENCE。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 5 個 alias／方法包裝，載入順序具有語意；登記 $imported：FS Shop All Party Display；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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
# -*- coding: utf-8 -*-
#==============================================================================
# ■ FS_ShopAllPartyDisplay v1.7
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2 / Ruby 1.8.1
#
# v1.7：
#   1. 依最新需求恢復A鍵特殊詳情頁。
#   2. 底部提示窗仍只顯示SHIFT捲動，不重複顯示詳情操作。
#   3. 底部提示窗與金錢窗統一為56px高、y=348。
#   4. 保留clear_rect動畫殘影修正。
#   5. 不含任何背景遮罩。
#
# 放置位置：
#   Window_ShopBuy FS v1.3
#   FS_ShopAllPartyDisplay v1.5
#   FS_ShopStatusDetail v1.0
#==============================================================================
$imported = {} if $imported == nil
$imported["FS Shop All Party Display"] = "1.7"

module FS_SHOP_ALL_PARTY
  VERSION = "1.7"

  MAIN_ACTOR_IDS = [1, 2, 3, 4, 5, 6]

  USE_SUFFIX_1          = true
  SHOW_DISABLED_GRAPHIC = true
  ENABLED_OPACITY       = 255
  DISABLED_OPACITY      = 128
  DISABLED_PATTERN      = 1
  ANIMATION_INTERVAL    = 10
  ANIMATION_SEQUENCE    = [1, 2, 1, 0]

  # 底部區域為 y=336～416，共80px。
  # 兩個56px視窗垂直置中：336 + (80 - 56) / 2 = 348。
  SHOW_FOOTER_HELP = true
  BOTTOM_AREA_TOP = 336
  BOTTOM_AREA_HEIGHT = 80
  BOTTOM_WINDOW_HEIGHT = 56
  BOTTOM_WINDOW_Y = BOTTOM_AREA_TOP +
    (BOTTOM_AREA_HEIGHT - BOTTOM_WINDOW_HEIGHT) / 2

  FOOTER_X = 0
  FOOTER_WIDTH = 384
  GOLD_WINDOW_X = 384
  GOLD_WINDOW_WIDTH = 160

  FOOTER_BACK_OPACITY = 200
  FOOTER_FONT_SIZE = 16

  SCROLL_HINT_MIN_MEMBERS = 4
  SCROLL_HINT_TEXT = "可按住SHIFT＋上下查看"
  EQUIPMENT_HINT_TEXT = "顯示可裝備角色與能力變化"
  ITEM_HINT_TEXT = "選擇商品查看效果"
  EMPTY_HINT_TEXT = "選擇商品查看說明"

  def self.mode?
    return false if $game_temp == nil
    return $game_temp.fs_shop_all_party_mode
  end

  def self.push_actor_id(result, value)
    if value.respond_to?(:id)
      id = value.id.to_i
    else
      id = value.to_i
    end
    return if id <= 0
    return unless MAIN_ACTOR_IDS.include?(id)
    result.push(id) unless result.include?(id)
  end

  def self.collect_from_actor_list(result, list)
    return if list == nil
    for value in list
      push_actor_id(result, value)
    end
  end

  #--------------------------------------------------------------------------
  # ● 取得商店全隊ID
  #--------------------------------------------------------------------------
  # 只在refresh前呼叫一次。事件已正確安排3+3隊伍後，不需要商店
  # 每幀重新盤點人口。
  def self.collect_party_actor_ids
    result = []
    return result if $game_party == nil

    raw_ids = $game_party.instance_variable_get(:@actors) rescue nil
    collect_from_actor_list(result, raw_ids)

    if $game_party.respond_to?(:all_members)
      begin
        collect_from_actor_list(result, $game_party.all_members)
      rescue
      end
    end

    if $game_party.respond_to?(:battle_members)
      begin
        collect_from_actor_list(result, $game_party.battle_members)
      rescue
      end
    end

    if $game_party.respond_to?(:stand_by_members)
      begin
        collect_from_actor_list(result, $game_party.stand_by_members)
      rescue
      end
    end

    if $game_party.respond_to?(:standby_members)
      begin
        collect_from_actor_list(result, $game_party.standby_members)
      rescue
      end
    end

    return result
  end

  def self.refresh_party_cache
    @cached_actor_ids = collect_party_actor_ids
    return @cached_actor_ids
  end

  def self.cached_actor_ids
    @cached_actor_ids = [] if @cached_actor_ids == nil
    return @cached_actor_ids
  end

  def self.shop_members(refresh_cache = false)
    refresh_party_cache if refresh_cache || @cached_actor_ids == nil
    result = []
    return result if $game_actors == nil
    for actor_id in cached_actor_ids
      actor = $game_actors[actor_id]
      result.push(actor) unless actor == nil
    end
    return result
  end

  def self.with_mode
    refresh_party_cache if @cached_actor_ids == nil
    return yield if $game_temp == nil
    old_value = $game_temp.fs_shop_all_party_mode
    begin
      $game_temp.fs_shop_all_party_mode = true
      return yield
    ensure
      $game_temp.fs_shop_all_party_mode = old_value
    end
  end

  def self.status_content_height(window)
    count = shop_members(false).size
    count = 1 if count < 1
    calculated = Window_Base::WLH * (count + 1) * 2
    minimum = window.height - 32
    return [calculated, minimum].max
  end

  def self.animation_pattern(counter)
    interval = ANIMATION_INTERVAL.to_i
    interval = 1 if interval < 1
    sequence = ANIMATION_SEQUENCE
    return 1 if sequence == nil || sequence.empty?
    index = (counter.to_i / interval) % sequence.size
    return sequence[index].to_i
  end

  def self.character_exists?(name)
    return false if name == nil || name == ""
    if defined?(FS_LEGACY_SAFE) &&
       FS_LEGACY_SAFE.respond_to?(:character_exists?)
      return FS_LEGACY_SAFE.character_exists?(name)
    end
    path = "Graphics/Characters/" + name
    return true if FileTest.exist?(path + ".png")
    return true if FileTest.exist?(path + ".jpg")
    return true if FileTest.exist?(path + ".bmp")
    return false
  end

  #--------------------------------------------------------------------------
  # ● 取得角色圖指定影格
  #--------------------------------------------------------------------------
  # prefer_suffix為true時優先使用 character_name + "_1"。
  def self.character_frame(actor, pattern, prefer_suffix = USE_SUFFIX_1)
    return nil if actor == nil
    name = actor.character_name.to_s
    index = actor.character_index.to_i

    if defined?(FS_LEGACY_SAFE) &&
       FS_LEGACY_SAFE.respond_to?(:character_frame)
      data = FS_LEGACY_SAFE.character_frame(
        name, index, pattern, 0, prefer_suffix)
      return data unless data == nil
    end

    actual_name = name
    if prefer_suffix
      base = name.sub(/_[123]$/, "")
      suffix = base + "_1"
      actual_name = suffix if character_exists?(suffix)
    end

    bitmap = Cache.character(actual_name)
    sign = actual_name[/^[\!\$]./]
    if sign != nil && sign.include?('$')
      cw = bitmap.width / 3
      ch = bitmap.height / 4
      sx = pattern.to_i * cw
      sy = 0
    else
      cw = bitmap.width / 12
      ch = bitmap.height / 8
      sx = (index % 4 * 3 + pattern.to_i) * cw
      sy = (index / 4 * 4) * ch
    end
    return [bitmap, Rect.new(sx, sy, cw, ch), cw, ch, actual_name]
  rescue
    return nil
  end

  def self.ids_text(list)
    ids = []
    return ids.inspect if list == nil
    for actor in list
      if actor.respond_to?(:id)
        ids.push(actor.id)
      else
        ids.push(actor.to_i)
      end
    end
    return ids.inspect
  end

  def self.write_debug_report
    file = File.open("FS_Shop_Party_Report.txt", "wb")
    file.write("FS Shop All Party Display v#{VERSION}\r\n")
    raw_ids = $game_party.instance_variable_get(:@actors) rescue []
    file.write("raw @actors: " + raw_ids.inspect + "\r\n")

    if $game_party.respond_to?(:all_members)
      file.write("all_members: " +
        ids_text($game_party.all_members) + "\r\n")
    end
    if $game_party.respond_to?(:battle_members)
      file.write("battle_members: " +
        ids_text($game_party.battle_members) + "\r\n")
    end
    if $game_party.respond_to?(:stand_by_members)
      file.write("stand_by_members: " +
        ids_text($game_party.stand_by_members) + "\r\n")
    end
    if $game_party.respond_to?(:standby_members)
      file.write("standby_members: " +
        ids_text($game_party.standby_members) + "\r\n")
    end

    refresh_party_cache
    file.write("cached_actor_ids: " + cached_actor_ids.inspect + "\r\n")
    file.write("shop_members: " + ids_text(shop_members(false)) + "\r\n")
    file.close
    return true
  rescue
    return false
  end
end


#==============================================================================
# ■ Window_FSShopFooterHelp
#------------------------------------------------------------------------------
# 填補商店左下角原本的空白區，與右側金錢視窗形成完整底列。
#==============================================================================
class Window_FSShopFooterHelp < Window_Base
  def initialize
    super(
      FS_SHOP_ALL_PARTY::FOOTER_X,
      FS_SHOP_ALL_PARTY::BOTTOM_WINDOW_Y,
      FS_SHOP_ALL_PARTY::FOOTER_WIDTH,
      FS_SHOP_ALL_PARTY::BOTTOM_WINDOW_HEIGHT)
    self.back_opacity = FS_SHOP_ALL_PARTY::FOOTER_BACK_OPACITY
    @text = nil
    refresh("")
  end

  def refresh(text)
    text = text.to_s
    return if @text == text
    @text = text
    self.contents.clear
    self.contents.font.size =
      FS_SHOP_ALL_PARTY::FOOTER_FONT_SIZE
    self.contents.font.color = normal_color
    self.contents.draw_text(
      4, 0, self.contents.width - 8, WLH, text, 1)
  end
end

class Game_Temp
  def fs_shop_all_party_mode
    return @fs_shop_all_party_mode == true
  end

  def fs_shop_all_party_mode=(value)
    @fs_shop_all_party_mode = (value == true)
  end
end

class Game_Party < Game_Unit
  unless method_defined?(:fs_shop_all_party_members_base_v17)
    alias fs_shop_all_party_members_base_v17 members
  end

  def members
    if FS_SHOP_ALL_PARTY.mode?
      return FS_SHOP_ALL_PARTY.shop_members(false)
    end
    return fs_shop_all_party_members_base_v17
  end
end

class Window_ShopStatus < Window_Base
  unless method_defined?(:fs_shop_all_party_refresh_base_v17)
    alias fs_shop_all_party_refresh_base_v17 refresh
  end

  unless method_defined?(:fs_shop_all_party_update_base_v17)
    alias fs_shop_all_party_update_base_v17 update
  end

  unless method_defined?(:fs_shop_actor_draw_parameter_base_v17)
    alias fs_shop_actor_draw_parameter_base_v17 draw_actor_parameter_change
  end

  unless method_defined?(:fs_shop_all_party_dispose_base_v17)
    alias fs_shop_all_party_dispose_base_v17 dispose
  end

  #--------------------------------------------------------------------------
  # ● 建立內容
  #--------------------------------------------------------------------------
  def create_contents
    fs_shop_dispose_actor_slots
    if self.contents != nil && !self.contents.disposed?
      self.contents.dispose
    end
    bitmap_height = FS_SHOP_ALL_PARTY.status_content_height(self)
    self.contents = Bitmap.new(self.width - 32, bitmap_height)
  end

  def fs_shop_ensure_all_party_contents
    expected = FS_SHOP_ALL_PARTY.status_content_height(self)
    if self.contents == nil || self.contents.disposed? ||
       self.contents.height != expected
      old_oy = self.oy
      create_contents
      max_oy = [self.contents.height - (self.height - 32), 0].max
      self.oy = [[old_oy, 0].max, max_oy].min
    end
  end

  # v1.7恢復特殊詳情頁。
  def fs_shop_detail_page_open?
    return false unless respond_to?(:fs_detail_page)
    return fs_detail_page.to_i != 0
  end

  def fs_shop_dispose_actor_slots
    return if @fs_shop_actor_slots == nil
    for slot in @fs_shop_actor_slots
      bitmap = slot[:background]
      next if bitmap == nil
      next if bitmap.respond_to?(:disposed?) && bitmap.disposed?
      bitmap.dispose
    end
    @fs_shop_actor_slots.clear
  rescue
    @fs_shop_actor_slots = []
  end

  #--------------------------------------------------------------------------
  # ● 更新內容
  #--------------------------------------------------------------------------
  # v1.1方式：只在refresh時重新整理隊伍快取。
  def refresh(*args)
    fs_shop_dispose_actor_slots
    @fs_shop_actor_slots = []
    @fs_shop_animation_counter = 0
    @fs_shop_animation_pattern = 1

    FS_SHOP_ALL_PARTY.refresh_party_cache

    FS_SHOP_ALL_PARTY.with_mode do
      fs_shop_ensure_all_party_contents
      fs_shop_all_party_refresh_base_v17(*args)
    end
  end

  #--------------------------------------------------------------------------
  # ● 壓制原商店靜止角色圖
  #--------------------------------------------------------------------------
  def draw_actor_graphic(*args)
    return if @fs_shop_suppress_original_actor_graphic
    super
  end

  def draw_character(*args)
    return if @fs_shop_suppress_original_actor_graphic
    super
  end

  #--------------------------------------------------------------------------
  # ● 繪製角色參數
  #--------------------------------------------------------------------------
  def draw_actor_parameter_change(actor, x, y)
    enabled = false
    enabled = actor.equippable?(@item) if @item != nil

    # 先讓YEM畫名稱與能力值，但攔截它可能走到的兩種角色圖入口。
    @fs_shop_suppress_original_actor_graphic = true
    begin
      fs_shop_actor_draw_parameter_base_v17(actor, x, y)
    ensure
      @fs_shop_suppress_original_actor_graphic = false
    end

    return if @item == nil || @item.is_a?(RPG::Item)
    return unless enabled || FS_SHOP_ALL_PARTY::SHOW_DISABLED_GRAPHIC

    sprite_x = x + 50
    sprite_y = y + 27

    # 即使其他腳本繞過攔截直接畫圖，也清除一次原角色圖範圍。
    fs_shop_clear_residual_actor_graphic(actor, sprite_x, sprite_y)

    # 清除範圍可能碰到較長角色名稱，重新畫一次名稱確保完整。
    self.contents.font.color = normal_color
    self.contents.font.color.alpha =
      enabled ? FS_SHOP_ALL_PARTY::ENABLED_OPACITY :
      FS_SHOP_ALL_PARTY::DISABLED_OPACITY
    self.contents.draw_text(x, y, 200, WLH, actor.name)

    fs_shop_register_actor_graphic(
      actor, sprite_x, sprite_y, enabled)
  end

  #--------------------------------------------------------------------------
  # ● 清除原本的靜止圖
  #--------------------------------------------------------------------------
  def fs_shop_clear_residual_actor_graphic(actor, x, y)
    frames = []
    original = FS_SHOP_ALL_PARTY.character_frame(
      actor, FS_SHOP_ALL_PARTY::DISABLED_PATTERN, false)
    animated = FS_SHOP_ALL_PARTY.character_frame(
      actor, FS_SHOP_ALL_PARTY::DISABLED_PATTERN, true)
    frames.push(original) unless original == nil
    frames.push(animated) unless animated == nil
    return if frames.empty?

    width = 0
    height = 0
    for data in frames
      width = data[2].to_i if data[2].to_i > width
      height = data[3].to_i if data[3].to_i > height
    end
    return if width <= 0 || height <= 0

    left = x.to_i - width / 2
    top = y.to_i - height
    self.contents.clear_rect(left, top, width, height)
  rescue
  end

  #--------------------------------------------------------------------------
  # ● 登錄角色動畫槽
  #--------------------------------------------------------------------------
  def fs_shop_register_actor_graphic(actor, x, y, enabled)
    pattern = enabled ? @fs_shop_animation_pattern.to_i :
      FS_SHOP_ALL_PARTY::DISABLED_PATTERN
    data = FS_SHOP_ALL_PARTY.character_frame(actor, pattern, true)

    if data == nil
      draw_character(
        actor.character_name, actor.character_index, x, y)
      return
    end

    cw = data[2].to_i
    ch = data[3].to_i
    left = x.to_i - cw / 2
    top = y.to_i - ch
    return if cw <= 0 || ch <= 0
    return if left < 0 || top < 0
    return if left + cw > self.contents.width
    return if top + ch > self.contents.height

    background = Bitmap.new(cw, ch)
    background.blt(
      0, 0, self.contents, Rect.new(left, top, cw, ch))

    slot = {
      :actor => actor,
      :left => left,
      :top => top,
      :enabled => enabled,
      :background => background
    }
    @fs_shop_actor_slots.push(slot)
    fs_shop_draw_actor_slot(slot, pattern)
  rescue
  end

  def fs_shop_draw_actor_slot(slot, pattern)
    return if slot == nil || self.contents == nil
    return if self.contents.disposed?

    background = slot[:background]
    if background != nil &&
       !(background.respond_to?(:disposed?) && background.disposed?)
      # 背景快照含大量透明像素。單純blt不會用透明像素擦掉舊影格，
      # 所以必須先清空整個角色格，再把文字／背景快照貼回去。
      self.contents.clear_rect(
        slot[:left], slot[:top],
        background.width, background.height)
      self.contents.blt(
        slot[:left], slot[:top], background, background.rect)
    end

    actor = slot[:actor]
    data = FS_SHOP_ALL_PARTY.character_frame(
      actor, pattern, true)
    return if data == nil

    opacity = slot[:enabled] ?
      FS_SHOP_ALL_PARTY::ENABLED_OPACITY :
      FS_SHOP_ALL_PARTY::DISABLED_OPACITY

    self.contents.blt(
      slot[:left], slot[:top], data[0], data[1], opacity)
  rescue
  end

  def fs_shop_update_actor_animation
    return unless self.visible
    return if fs_shop_detail_page_open?
    return if @fs_shop_actor_slots == nil ||
      @fs_shop_actor_slots.empty?

    @fs_shop_animation_counter =
      @fs_shop_animation_counter.to_i + 1

    pattern = FS_SHOP_ALL_PARTY.animation_pattern(
      @fs_shop_animation_counter)
    return if pattern == @fs_shop_animation_pattern

    @fs_shop_animation_pattern = pattern
    for slot in @fs_shop_actor_slots
      next unless slot[:enabled]
      fs_shop_draw_actor_slot(slot, pattern)
    end
  end

  # 只更新動畫，不再檢查隊伍人數。
  def update
    fs_shop_all_party_update_base_v17
    fs_shop_update_actor_animation
    fs_shop_update_footer_help
  end

  #--------------------------------------------------------------------------
  # ● 底部操作提示列
  #--------------------------------------------------------------------------
  def fs_shop_footer_equipment?
    return false if @item == nil
    return true if @item.is_a?(RPG::Weapon)
    return true if @item.is_a?(RPG::Armor)
    return false
  end

  def fs_shop_footer_text
    if fs_shop_footer_equipment?
      count = FS_SHOP_ALL_PARTY.shop_members(false).size
      if count >= FS_SHOP_ALL_PARTY::SCROLL_HINT_MIN_MEMBERS
        return FS_SHOP_ALL_PARTY::SCROLL_HINT_TEXT
      end
      return FS_SHOP_ALL_PARTY::EQUIPMENT_HINT_TEXT
    end

    return FS_SHOP_ALL_PARTY::ITEM_HINT_TEXT unless @item == nil
    return FS_SHOP_ALL_PARTY::EMPTY_HINT_TEXT
  end

  def fs_shop_ensure_footer_help
    return unless FS_SHOP_ALL_PARTY::SHOW_FOOTER_HELP

    if @fs_shop_footer_help == nil ||
       @fs_shop_footer_help.disposed?
      @fs_shop_footer_help = Window_FSShopFooterHelp.new
      @fs_shop_footer_help.z = self.z + 20
    end

    @fs_shop_footer_help.visible = self.visible
    @fs_shop_footer_help.refresh(fs_shop_footer_text)
    @fs_shop_footer_help.update
  end

  def fs_shop_update_footer_help
    fs_shop_ensure_footer_help
  end

  def fs_shop_dispose_footer_help
    return if @fs_shop_footer_help == nil
    @fs_shop_footer_help.dispose unless
      @fs_shop_footer_help.disposed?
    @fs_shop_footer_help = nil
  rescue
    @fs_shop_footer_help = nil
  end

  def dispose
    fs_shop_dispose_actor_slots
    fs_shop_dispose_footer_help
    fs_shop_all_party_dispose_base_v17
  end
end

class Game_Interpreter
  def fs_shop_party_report
    result = FS_SHOP_ALL_PARTY.write_debug_report
    if $game_message != nil
      text = result ? "商店隊伍報告已輸出。" :
        "商店隊伍報告輸出失敗。"
      $game_message.texts.push(text)
    end
    return result
  end
end
