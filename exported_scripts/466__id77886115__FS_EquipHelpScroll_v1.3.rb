#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_EquipHelpScroll v1.3
# 【用途】Forest Symphony 專用 Runtime／資料腳本「FS_EquipHelpScroll v1.3」。
# 【主要機制】屬目前正式專案功能的一部分；具體責任以本頁定義的類別、模組與方法，以及 LoadOrder Guide 為準。
# 【主要影響】Window_EquipHelp、Scene_Equip、Window_Equip、Window_Equip_Item、Game_Interpreter、FS_EQUIP_HELP_SCROLL
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：SCROLL_SPEED、SCROLL_REFRESH_RATE、SCROLL_INITIAL_WAIT、LEFT_PADDING、RIGHT_PADDING、COMBO_ACTIVE_COLOR、COMBO_INACTIVE_COLOR。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 2 個 alias／方法包裝，載入順序具有語意；登記 $imported：FS Equip Help Scroll；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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
# ■ FS_EquipHelpScroll v1.3
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2 / Ruby 1.8.1
#
# 只處理Scene_Equip的Help Window。
#
# 不修改全域Window_Help，因此不會被：
#   FS_HELP_WINDOW_FIT_V12
# 每幀重新量字與縮字。
#
# 原理與Cozziekuns技能Help相同：
#   文字改變時建立一次Bitmap並繪製一次。
#   每幀只更新ox。
#
# v1.3：
#   【組合效果：已達成】使用綠色。
#   【組合效果：未達成】使用紅色。
#   後方裝備說明維持一般文字色。
#   跑馬燈仍只移動同一張Bitmap，不增加每幀負擔。
#
# 放置位置：
#   所有Scene_Equip、Window_Help與FS_HELP_WINDOW_FIT_V12之後
#   Main之前
#==============================================================================

$imported = {} if $imported == nil
$imported["FS Equip Help Scroll"] = "1.3"

module FS_EQUIP_HELP_SCROLL

  SCROLL_SPEED = 1
  SCROLL_REFRESH_RATE = 1
  SCROLL_INITIAL_WAIT = 60

  LEFT_PADDING = 4
  RIGHT_PADDING = 40

  # 組合效果狀態前綴顏色。
  COMBO_ACTIVE_COLOR   = Color.new(96, 255, 128, 255)
  COMBO_INACTIVE_COLOR = Color.new(255, 96, 96, 255)

  def self.combo_prefix_data(text)
    return nil unless defined?(Albert_EquipmentCombo_UI)

    active_prefix =
      "【#{Albert_EquipmentCombo_UI::HELP_LABEL}：" +
      "#{Albert_EquipmentCombo_UI::HELP_ACTIVE}】"

    inactive_prefix =
      "【#{Albert_EquipmentCombo_UI::HELP_LABEL}：" +
      "#{Albert_EquipmentCombo_UI::HELP_INACTIVE}】"

    if text.to_s.index(active_prefix) == 0
      return [active_prefix, COMBO_ACTIVE_COLOR]
    end

    if text.to_s.index(inactive_prefix) == 0
      return [inactive_prefix, COMBO_INACTIVE_COLOR]
    end

    return nil
  rescue
    return nil
  end

  def self.expand_text(text)
    result = text.to_s.clone

    result.gsub!(/\\V\[([0-9]+)\]/i) do
      $game_variables[$1.to_i].to_s
    end

    result.gsub!(/\\N\[([0-9]+)\]/i) do
      actor = $game_actors[$1.to_i]
      actor == nil ? "" : actor.name.to_s
    end

    return result
  rescue
    return text.to_s
  end
end

#==============================================================================
# ■ Window_EquipHelp
#------------------------------------------------------------------------------
# 專用類別直接覆寫set_text，完全不經過全域Window_Help的自動縮字鏈。
#==============================================================================
class Window_EquipHelp < Window_Help

  def initialize
    super
    @fs_equip_scroll = false
    @fs_equip_scroll_frames = 0
    @fs_equip_scroll_text = nil
    @fs_equip_scroll_align = nil
    @fs_equip_scroll_text_width = 0
    @fs_equip_scroll_last_update_frame = -1
  end

  def set_text(text, align = 0)
    text = FS_EQUIP_HELP_SCROLL.expand_text(text)

    # 最重要的防Lag判定：
    # Window_Selectable每幀都會呼叫update_help，
    # 相同文字在任何量字、Bitmap.new之前直接返回。
    return if text == @fs_equip_scroll_text &&
              align == @fs_equip_scroll_align

    @fs_equip_scroll_text = text
    @fs_equip_scroll_align = align
    @text = text
    @align = align

    self.ox = 0
    @fs_equip_scroll_frames = 0

    old_contents = self.contents
    old_font_name = old_contents.font.name
    old_font_bold = old_contents.font.bold
    old_font_italic = old_contents.font.italic
    old_font_shadow = old_contents.font.shadow

    old_contents.font.size = Font.default_size
    text_width = old_contents.text_size(text).width
    visible_width = self.width - FS_EQUIP_HELP_SCROLL::RIGHT_PADDING

    should_scroll =
      align.to_i == 0 &&
      text_width + FS_EQUIP_HELP_SCROLL::LEFT_PADDING >
      visible_width

    bitmap_width = if should_scroll
                     self.width + text_width + 8
                   else
                     self.width - 32
                   end

    self.contents = Bitmap.new(
      bitmap_width,
      self.height - 32)

    old_contents.dispose if old_contents != nil &&
                            !old_contents.disposed?

    self.contents.font.name = old_font_name
    self.contents.font.size = Font.default_size
    self.contents.font.bold = old_font_bold
    self.contents.font.italic = old_font_italic
    self.contents.font.shadow = old_font_shadow
    self.contents.font.color = normal_color

    draw_width = should_scroll ? text_width : visible_width

    prefix_data =
      FS_EQUIP_HELP_SCROLL.combo_prefix_data(text)

    if prefix_data != nil && align.to_i == 0
      prefix = prefix_data[0]
      prefix_color = prefix_data[1]
      prefix_width =
        self.contents.text_size(prefix).width

      rest = text.to_s.sub(prefix, "")

      self.contents.font.color = prefix_color
      self.contents.draw_text(
        FS_EQUIP_HELP_SCROLL::LEFT_PADDING,
        0,
        prefix_width,
        WLH,
        prefix,
        0)

      self.contents.font.color = normal_color
      self.contents.draw_text(
        FS_EQUIP_HELP_SCROLL::LEFT_PADDING +
          prefix_width,
        0,
        [draw_width - prefix_width, 1].max,
        WLH,
        rest,
        0)
    else
      self.contents.font.color = normal_color
      self.contents.draw_text(
        FS_EQUIP_HELP_SCROLL::LEFT_PADDING,
        0,
        draw_width,
        WLH,
        text,
        align)
    end

    @fs_equip_scroll = should_scroll
    @fs_equip_scroll_text_width = text_width
  end

  def update
    # Scene_Equip補丁會明確呼叫；若其他腳本也呼叫，單幀只更新一次。
    return if @fs_equip_scroll_last_update_frame ==
              Graphics.frame_count

    @fs_equip_scroll_last_update_frame =
      Graphics.frame_count

    super

    @fs_equip_scroll_frames += 1
    return unless @fs_equip_scroll

    refresh = [
      FS_EQUIP_HELP_SCROLL::SCROLL_REFRESH_RATE.to_i,
      1
    ].max

    wait = FS_EQUIP_HELP_SCROLL::SCROLL_INITIAL_WAIT.to_i
    speed = FS_EQUIP_HELP_SCROLL::SCROLL_SPEED.to_i
    speed = 1 if speed <= 0

    return if @fs_equip_scroll_frames < wait
    return unless Graphics.frame_count % refresh == 0

    self.ox += speed

    if self.ox >= @fs_equip_scroll_text_width
      self.ox = -@fs_equip_scroll_text_width / 2
    end
  end
end

#==============================================================================
# ■ Scene_Equip
#------------------------------------------------------------------------------
# 原Scene_Equip沒有更新@help_window，原碼甚至把該行註解掉。
# 啟動後換成專用視窗，並在每幀明確更新一次。
#==============================================================================
if defined?(Scene_Equip)

  class Scene_Equip < Scene_Base

    unless method_defined?(:fs_equip_help_scroll_start_v10)
      alias fs_equip_help_scroll_start_v10 start
    end

    def start
      fs_equip_help_scroll_start_v10
      fs_equip_help_scroll_replace_window_v10
    end

    unless method_defined?(:fs_equip_help_scroll_update_v10)
      alias fs_equip_help_scroll_update_v10 update
    end

    def update
      fs_equip_help_scroll_update_v10

      if @help_window != nil &&
         !@help_window.disposed? &&
         @help_window.is_a?(Window_EquipHelp)
        @help_window.update
      end
    end

    def fs_equip_help_scroll_replace_window_v10
      old_window = @help_window
      return if old_window.is_a?(Window_EquipHelp)

      new_window = Window_EquipHelp.new

      if old_window != nil
        new_window.x = old_window.x
        new_window.y = old_window.y
        new_window.z = old_window.z
        new_window.opacity = old_window.opacity
        new_window.back_opacity = old_window.back_opacity
        new_window.contents_opacity = old_window.contents_opacity
        new_window.visible = old_window.visible
        new_window.active = old_window.active
        new_window.openness = old_window.openness

        begin
          new_window.tone = old_window.tone
        rescue
        end
      end

      @help_window = new_window

      if @windows.is_a?(Array)
        for window in @windows
          next if window == nil
          if window.respond_to?(:help_window=)
            window.help_window = @help_window
          end
        end
      end

      if @equip_window != nil &&
         @equip_window.respond_to?(:help_window=)
        @equip_window.help_window = @help_window
      end

      if @item_window != nil &&
         @item_window.respond_to?(:help_window=)
        @item_window.help_window = @help_window
      end

      if @aptitude_window != nil &&
         @aptitude_window.respond_to?(:help_window=)
        @aptitude_window.help_window = @help_window
      end

      if old_window != nil && !old_window.disposed?
        old_window.dispose
      end

      if @item_window != nil && @item_window.active
        @item_window.update_help
      elsif @aptitude_window != nil && @aptitude_window.active
        @aptitude_window.update_help
      elsif @equip_window != nil
        @equip_window.update_help
      end
    end
  end
end

#==============================================================================
# ■ 鳴刻冠Help單次更新 v1.2
#------------------------------------------------------------------------------
# v1.1使用include嘗試覆寫update_help，但類別自身方法優先於include模組，
# 所以原EquipmentCombo雙重update_help仍在執行。
#
# v1.2直接重新定義Window_Equip與Window_Equip_Item#update_help。
#==============================================================================

module FS_EQUIP_HELP_SCROLL

  def self.current_item(window)
    return nil if window == nil

    if window.respond_to?(:item)
      begin
        return window.item
      rescue
      end
    end

    begin
      data = window.instance_variable_get(:@data)
      index = window.index
      return data[index] if data.is_a?(Array) &&
                            index != nil &&
                            index >= 0
    rescue
    end

    return nil
  end

  def self.final_help_text(actor, item)
    return "" if item == nil

    if defined?(Albert_EquipmentCombo_UI) &&
       Albert_EquipmentCombo_UI.respond_to?(:help_text)
      begin
        return Albert_EquipmentCombo_UI.help_text(
          actor, item).to_s
      rescue
      end
    end

    return item.description.to_s
  end

  def self.new_item_before(item)
    return nil unless defined?(FS_GALV_NEW_ITEM)
    return nil unless FS_GALV_NEW_ITEM.respond_to?(:new_item?)

    begin
      return FS_GALV_NEW_ITEM.new_item?(item)
    rescue
      return nil
    end
  end

  def self.touch_new_item(window, item, before_new)
    return if window == nil || item == nil

    if window.respond_to?(:fs_nitem_touch_current)
      begin
        window.fs_nitem_touch_current(before_new)
        return
      rescue
      end
    end

    if defined?(FS_GALV_NEW_ITEM) &&
       FS_GALV_NEW_ITEM.respond_to?(:mark_seen)
      begin
        FS_GALV_NEW_ITEM.mark_seen(item)
      rescue
      end
    end
  end

  def self.update_window_help(window)
    return if window == nil

    help_window =
      window.instance_variable_get(:@help_window)
    actor =
      window.instance_variable_get(:@actor)

    return if help_window == nil

    current = current_item(window)
    before_new = new_item_before(current)
    text = final_help_text(actor, current)

    # 唯一一次set_text。
    help_window.set_text(text)

    touch_new_item(window, current, before_new)
  end
end

if defined?(Window_Equip)
  class Window_Equip < Window_Selectable
    def update_help
      FS_EQUIP_HELP_SCROLL.update_window_help(self)
    end
  end
end

if defined?(Window_Equip_Item)
  class Window_Equip_Item < Window_Selectable
    def update_help
      FS_EQUIP_HELP_SCROLL.update_window_help(self)
    end
  end
end

class Game_Interpreter
  def fs_equip_help_method_report
    lines = []
    lines.push("FS Equip Help Method Report v1.2")
    lines.push("=" * 72)

    if defined?(Window_Equip)
      owner = Window_Equip.instance_method(:update_help).owner
      lines.push("Window_Equip#update_help owner=#{owner}")
    end

    if defined?(Window_Equip_Item)
      owner = Window_Equip_Item.instance_method(:update_help).owner
      lines.push("Window_Equip_Item#update_help owner=#{owner}")
    end

    File.open("FS_EquipHelp_Method_Report.txt", "wb") do |file|
      file.write(lines.join("\r\n"))
    end

    $game_message.texts.push(
      "裝備Help方法報告已輸出。")
    return true
  rescue
    return false
  end
end
