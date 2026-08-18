#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_BattleTargetUI_Authority v1.4.1
# 【用途】Forest Symphony 正式 Authority「FS_BattleTargetUI_Authority v1.4.1」，集中管理此功能目前應修改的主要實作。
# 【主要機制】本頁可能由既有 Base／第三方插件一路 Patch 而來；修改時仍需查看 LoadOrder Guide／Authority Map，確認是否還有後載入 wrapper。
# 【主要影響】Window_Help、Window_AlbertBattleStateDetail、AlbertBattleStateHUDManager、Game_Interpreter、Sprite_AlbertBattleStateHUD、FS_BattleTargetOverlayController、Scene_Battle
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：CAPTURE_AREA_WIDTH、CAPTURE_FONT_SIZE、CAPTURE_MIN_SIZE、CAPTURE_BACKGROUND_ENABLED、CAPTURE_BACKGROUND_COLOR、CAPTURE_BACKGROUND_PAD_X、CAPTURE_BACKGROUND_PAD_Y、NAME_FONT_SIZE。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 9 個 alias／方法包裝，載入順序具有語意；登記 $imported：FS Battle Target HUD Layout Patch、FS_BattleTargetHUD_NameCenterFix、FS BattleStateHUD Lifecycle TargetOverlay；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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
# PHASE6 ORIGINAL PAGE: 492 | FS_BattleTargetHUD_LayoutPatch v1.4.1
#==============================================================================
# -*- coding: utf-8 -*-

#===============================================================================

# ■ FS_BattleTargetHUD_LayoutPatch v1.4.1

#-------------------------------------------------------------------------------

# RPG Maker VX / RGSS2

#

# 【功能】

# 1. 重排戰鬥目標 Help Window：

#    - 左側保留魂刻擷取率。

#    - 中央把「敵人名稱＋屬性 Icon」視為同一組，依實際寬度置中。

#    - 右側狀態 Icon 改為靠右排列。

#    - 長名稱會先縮字，再以省略號收尾，不再壓住屬性 Icon。

# 2. 重製 Battle State HUD detail：

#    - 寬度擴至接近全畫面。

#    - 依內容自動調整高度。

#    - 每個 State 獨立成列，文字自動換行。

#    - Icon 固定保留 24px，不再和文字互相覆蓋。

#    - 背景改為單層透明黑圓角，不畫外框。

#

# 【放置位置】

#   DynamicCaptureRate、Battle State HUD Core 與其所有補丁之下，Main 之上。

#===============================================================================



$imported = {} if $imported == nil

$imported["FS Battle Target HUD Layout Patch"] = "1.4.1"



module FS_BATTLE_TARGET_HUD_LAYOUT

  #--------------------------------------------------------------------------

  # 上方目標資訊列

  #--------------------------------------------------------------------------

  CAPTURE_AREA_WIDTH   = 132

  CAPTURE_FONT_SIZE    = 16

  CAPTURE_MIN_SIZE     = 13

  # 只有真正可擷取的敵人才畫此區。
  # 半透明黑底只出現在擷取率文字後方。
  CAPTURE_BACKGROUND_ENABLED = true
  CAPTURE_BACKGROUND_COLOR   = Color.new(0, 0, 0, 150)
  CAPTURE_BACKGROUND_PAD_X   = 3
  CAPTURE_BACKGROUND_PAD_Y   = 2



  NAME_FONT_SIZE       = 19

  NAME_MIN_SIZE        = 13

  NAME_ELEMENT_GAP     = 5

  SIDE_GAP             = 6



  # false：上方Help Window不再畫狀態Icon，避免壓到召喚物HUD。
  # 戰場上的獨立BattleStateHUD不受影響。
  SHOW_HELP_STATE_ICONS = false

  MAX_STATE_SLOTS      = 6

  STATE_ICON_SIZE      = 24



  #--------------------------------------------------------------------------

  # 詳細資訊窗

  #--------------------------------------------------------------------------

  DETAIL_MIN_WIDTH      = 220
  DETAIL_MAX_WIDTH      = 520
  DETAIL_SIDE_MARGIN    = 8
  DETAIL_WIDTH_PADDING  = 18

  # Command人物立繪／環形指令的右側保留區。
  #
  # Command顯示時：
  #   短內容先維持全畫面置中。
  #   只有置中後右端超過x=410，才向左移到安全範圍。
  #
  # DETAIL_COMMAND_LEFT_X是最左邊界，不再是固定X座標。
  DETAIL_COMMAND_LEFT_X     = 16
  DETAIL_COMMAND_SAFE_RIGHT = 410

  # Command顯示時固定視窗下緣，內容增加時向上長高。
  DETAIL_COMMAND_BOTTOM_Y   = 358
  DETAIL_COMMAND_TOP_LIMIT  = 82

  DETAIL_TOP_Y          = 110
  DETAIL_BOTTOM_RESERVE = 72
  DETAIL_CURSOR_OFFSET_Y = 24

  # 預設位置。當上下兩處都不會遮住目標時，維持下方，
  # 避免只有某一隻敵人因些微Y差異突然跳到上方。
  DETAIL_DEFAULT_BOTTOM = true

  # 判斷HUD是否遮住目標時，額外保留的安全距離。
  DETAIL_TARGET_SAFE_X  = 24
  DETAIL_TARGET_SAFE_Y  = 16

  DETAIL_MIN_HEIGHT     = 58
  DETAIL_MAX_HEIGHT     = 270

  DETAIL_BG_COLOR      = Color.new(0, 0, 0, 246)

  DETAIL_CORNER_RADIUS = 10



  DETAIL_FONT_SIZES    = [16, 15, 14, 13]

  DETAIL_ROW_GAP       = 3

  DETAIL_ICON_GAP      = 4

  DETAIL_LABEL_MAX     = 112



  def self.clamp(value, min_value, max_value)

    value = min_value if value < min_value

    value = max_value if value > max_value

    return value

  end

end



#===============================================================================

# ■ Window_Help

#-------------------------------------------------------------------------------

# 重新配置敵人名稱、屬性 Icon、狀態 Icon 與魂刻擷取率。

#===============================================================================



if defined?(Window_Help) && Window_Help.method_defined?(:set_text_n01add)

  class Window_Help < Window_Base

    unless method_defined?(:fs_bthud_v10_old_set_text_n01add)

      alias fs_bthud_v10_old_set_text_n01add set_text_n01add

    end



    def set_text_n01add(member)

      # 保留原腳本的掃描群組、擷取率更新等副作用，之後再統一重畫。

      fs_bthud_v10_old_set_text_n01add(member)

      fs_bthud_v10_redraw_target_header(member)

    end



    def fs_bthud_v10_redraw_target_header(member)

      return if self.contents == nil

      self.contents.clear

      return if member == nil || member.dead?



      old_size   = self.contents.font.size

      old_bold   = self.contents.font.bold

      old_shadow = self.contents.font.shadow

      old_color  = self.contents.font.color



      self.contents.font.shadow = true



      content_width = self.contents.width

      capture_width = fs_bthud_v10_draw_capture_rate(member, 0)



      states = []

      state_slots = 0

      state_width = 0

      state_x = content_width

      if FS_BATTLE_TARGET_HUD_LAYOUT::SHOW_HELP_STATE_ICONS

        states = fs_bthud_v10_visible_states(member)

        state_slots = [states.size,

          FS_BATTLE_TARGET_HUD_LAYOUT::MAX_STATE_SLOTS].min

        state_width = state_slots *

          FS_BATTLE_TARGET_HUD_LAYOUT::STATE_ICON_SIZE

        state_x = content_width - state_width

        state_x = capture_width if state_x < capture_width

        fs_bthud_v10_draw_states(states, state_x, state_slots)

      end



      left_x = capture_width

      left_x += FS_BATTLE_TARGET_HUD_LAYOUT::SIDE_GAP if left_x > 0

      right_x = state_x

      right_x -= FS_BATTLE_TARGET_HUD_LAYOUT::SIDE_GAP if state_slots > 0

      right_x = content_width if right_x > content_width



      fs_bthud_v10_draw_name_and_elements(member, left_x, right_x)



      self.contents.font.size = old_size

      self.contents.font.bold = old_bold

      self.contents.font.shadow = old_shadow

      self.contents.font.color = old_color

    end



    #-------------------------------------------------------------------------

    # 左側魂刻擷取率

    #-------------------------------------------------------------------------

    def fs_bthud_v10_draw_capture_rate(member, x)

      return 0 unless member.is_a?(Game_Enemy)

      return 0 unless defined?(Albert_CaptureRate)

      return 0 unless Albert_CaptureRate::HELP_SHOW



      rate = nil

      if member.respond_to?(:albert_current_capture_rate)

        begin

          rate = member.albert_current_capture_rate

        rescue

          rate = nil

        end

      end



      # 不可擷取敵人完全不顯示擷取率文字，也不畫背景。
      # 不再受DynamicCaptureRate::HELP_SHOW_UNAVAILABLE影響。
      return 0 if rate == nil



      width = FS_BATTLE_TARGET_HUD_LAYOUT::CAPTURE_AREA_WIDTH

      width = [width, self.contents.width].min



      label = Albert_CaptureRate::HELP_LABEL.to_s

      value = Albert_CaptureRate.rate_text(rate) + "%"



      size = FS_BATTLE_TARGET_HUD_LAYOUT::CAPTURE_FONT_SIZE

      min_size = FS_BATTLE_TARGET_HUD_LAYOUT::CAPTURE_MIN_SIZE

      self.contents.font.bold = true



      loop do

        self.contents.font.size = size

        total = self.contents.text_size(label + "：" + value).width

        break if total <= width || size <= min_size

        size -= 1

      end



      # 最低字級仍放不下時，只縮短標籤，不犧牲數值。

      if self.contents.text_size(label + "：" + value).width > width

        label = "擷取率"

      end



      label_text = label + "："

      label_width = self.contents.text_size(label_text).width

      value_width = self.contents.text_size(value).width

      total_width = label_width + value_width

      draw_x = x + [(width - total_width) / 2, 0].max



      if FS_BATTLE_TARGET_HUD_LAYOUT::CAPTURE_BACKGROUND_ENABLED
        pad_x = FS_BATTLE_TARGET_HUD_LAYOUT::CAPTURE_BACKGROUND_PAD_X
        pad_y = FS_BATTLE_TARGET_HUD_LAYOUT::CAPTURE_BACKGROUND_PAD_Y
        bg_x = x + pad_x
        bg_y = pad_y
        bg_w = [width - pad_x * 2, 1].max
        bg_h = [WLH - pad_y * 2, 1].max
        self.contents.fill_rect(
          bg_x, bg_y, bg_w, bg_h,
          FS_BATTLE_TARGET_HUD_LAYOUT::CAPTURE_BACKGROUND_COLOR)
      end



      self.contents.font.color = system_color

      self.contents.draw_text(draw_x, 0, label_width, WLH, label_text, 0)

      self.contents.font.color = normal_color

      self.contents.draw_text(draw_x + label_width, 0, value_width + 2, WLH, value, 0)



      return width

    end



    #-------------------------------------------------------------------------

    # 可顯示的狀態

    #-------------------------------------------------------------------------

    def fs_bthud_v10_visible_states(member)

      result = []

      for state in member.states

        next if state == nil

        if state.respond_to?(:extension)

          next if state.extension.include?("HIDEICON")

        end

        next if state.icon_index.to_i <= 0

        result.push(state)

      end

      return result

    end



    #-------------------------------------------------------------------------

    # 右側狀態 Icon

    #-------------------------------------------------------------------------

    def fs_bthud_v10_draw_states(states, x, slots)

      return if slots <= 0



      icon_slots = slots

      overflow = states.size - slots

      if overflow > 0 && slots >= 2

        icon_slots -= 1

      end



      i = 0

      while i < icon_slots

        draw_icon(states[i].icon_index, x + i * 24, 0, true)

        i += 1

      end



      if overflow > 0 && slots >= 2

        bx = x + icon_slots * 24

        self.contents.fill_rect(bx + 2, 2, 20, 20, Color.new(0, 0, 0, 150))



        old_size = self.contents.font.size

        old_bold = self.contents.font.bold

        old_color = self.contents.font.color



        self.contents.font.size = 12

        self.contents.font.bold = true

        self.contents.font.color = normal_color

        self.contents.draw_text(bx, 0, 24, 24, "+#{overflow + 1}", 1)



        self.contents.font.size = old_size

        self.contents.font.bold = old_bold

        self.contents.font.color = old_color

      end

    end



    #-------------------------------------------------------------------------

    # 中央名稱＋屬性 Icon

    #-------------------------------------------------------------------------

    def fs_bthud_v10_draw_name_and_elements(member, left_x, right_x)

      width = right_x - left_x

      return if width <= 8



      elements = []

      if member.respond_to?(:primary_element)

        value = member.primary_element

        elements.push(value) if value != nil

      end

      if member.respond_to?(:secondary_element)

        value = member.secondary_element

        if value != nil && !elements.include?(value)

          elements.push(value)

        end

      end

      elements = elements[0, 2]



      element_width = elements.size * 24

      if element_width > 0

        element_width += FS_BATTLE_TARGET_HUD_LAYOUT::NAME_ELEMENT_GAP

      end



      name = member.name.to_s

      name_limit = width - element_width

      name_limit = 16 if name_limit < 16



      size = FS_BATTLE_TARGET_HUD_LAYOUT::NAME_FONT_SIZE

      min_size = FS_BATTLE_TARGET_HUD_LAYOUT::NAME_MIN_SIZE

      self.contents.font.bold = false

      loop do

        self.contents.font.size = size

        break if self.contents.text_size(name).width <= name_limit || size <= min_size

        size -= 1

      end



      name = fs_bthud_v10_fit_text(name, name_limit)

      name_width = self.contents.text_size(name).width

      group_width = name_width + element_width

      group_x = left_x + [(width - group_width) / 2, 0].max



      self.contents.font.color = normal_color

      self.contents.draw_text(group_x, 0, name_width + 2, WLH, name, 0)



      icon_x = group_x + name_width

      icon_x += FS_BATTLE_TARGET_HUD_LAYOUT::NAME_ELEMENT_GAP if elements.size > 0

      for element in elements

        if respond_to?(:draw_element)

          draw_element(element, icon_x, 0)

        elsif Window_Base.const_defined?(:ELEMENT_ICON_TABLE)

          table = Window_Base.const_get(:ELEMENT_ICON_TABLE)

          icon_id = table[element]

          draw_icon(icon_id, icon_x, 0, true) if icon_id != nil && icon_id.to_i > 0

        end

        icon_x += 24

      end

    end



    #-------------------------------------------------------------------------

    # 依實際像素寬度截字

    #-------------------------------------------------------------------------

    def fs_bthud_v10_fit_text(text, max_width)

      return "" if max_width <= 0

      return text if self.contents.text_size(text).width <= max_width



      ellipsis = "…"

      chars = text.to_s.scan(/./m)

      while !chars.empty?

        candidate = chars.join("") + ellipsis

        return candidate if self.contents.text_size(candidate).width <= max_width

        chars.pop

      end

      return ellipsis

    end

  end

end

#==============================================================================
# ■ Window_AlbertBattleStateDetail
#------------------------------------------------------------------------------
# v1.3.0：
#   1. 不再固定DETAIL_Y。
#   2. 優先讀取目標Cursor與戰場State HUD Sprite。
#   3. 上下兩個候選位置中，選擇距離目前目標較遠者。
#   4. 寬度依目前內容自動伸縮。
#==============================================================================

if defined?(Window_AlbertBattleStateDetail)
  class Window_AlbertBattleStateDetail < Window_Base

    unless method_defined?(:fs_bthud_v13_old_initialize)
      alias fs_bthud_v13_old_initialize initialize
    end

    attr_reader :fs_bthud_anchor_sprite

    def initialize
      @fs_bthud_anchor_sprite = nil
      fs_bthud_v13_old_initialize

      @fs_bthud_v14_last_command_mode =
        fs_bthud_v14_command_ui_visible?

      fs_bthud_v13_resize(
        FS_BATTLE_TARGET_HUD_LAYOUT::DETAIL_MIN_WIDTH,
        FS_BATTLE_TARGET_HUD_LAYOUT::DETAIL_MIN_HEIGHT)

      update_placement
    end

    #--------------------------------------------------------------------------
    # ● 右側Command UI是否正在顯示
    #--------------------------------------------------------------------------
    def fs_bthud_v14_command_ui_visible?
      return false unless $scene.is_a?(Scene_Battle)

      begin
        flag =
          $scene.instance_variable_get(
            :@actor_command_window_on)

        return true if flag
      rescue
      end

      # 某些流程會先切換flag，再讓人物圖淡出。
      # 此處以實際人物圖透明度作短暫備援。
      for name in [
          :@bf, :@bf2, :@face_sprite, :@char_sprite]

        begin
          sprite = $scene.instance_variable_get(name)
          next if sprite == nil
          next if sprite.respond_to?(:disposed?) &&
                  sprite.disposed?
          next unless sprite.respond_to?(:opacity)

          return true if sprite.opacity.to_i > 0
        rescue
        end
      end

      return false
    rescue
      return false
    end

    #--------------------------------------------------------------------------
    # ● 目前模式可用寬度
    #--------------------------------------------------------------------------
    def fs_bthud_v14_active_max_width
      if fs_bthud_v14_command_ui_visible?
        width =
          FS_BATTLE_TARGET_HUD_LAYOUT::
            DETAIL_COMMAND_SAFE_RIGHT -
          FS_BATTLE_TARGET_HUD_LAYOUT::
            DETAIL_COMMAND_LEFT_X

        return [
          width,
          FS_BATTLE_TARGET_HUD_LAYOUT::DETAIL_MIN_WIDTH
        ].max
      end

      screen_width =
        Graphics.width -
        FS_BATTLE_TARGET_HUD_LAYOUT::DETAIL_SIDE_MARGIN * 2

      return [
        FS_BATTLE_TARGET_HUD_LAYOUT::DETAIL_MAX_WIDTH,
        screen_width
      ].min
    end

    def fs_bthud_v14_layout_mode_key
      return fs_bthud_v14_command_ui_visible? ?
        :command_safe : :normal
    end

    #--------------------------------------------------------------------------
    # ● Command顯示／關閉時強制重排一次
    #--------------------------------------------------------------------------
    unless method_defined?(:fs_bthud_v14_old_update)
      alias fs_bthud_v14_old_update update
    end

    def update
      mode = fs_bthud_v14_layout_mode_key
      changed =
        @fs_bthud_v14_last_command_mode != mode

      @fs_bthud_v14_last_command_mode = mode

      result = fs_bthud_v14_old_update

      if changed && @battler != nil &&
         respond_to?(:force_refresh)

        force_refresh(true)
      else
        update_placement
      end

      return result
    end

    def create_background_sprite
      if @background_sprite != nil &&
         !@background_sprite.disposed?

        if @background_sprite.bitmap != nil &&
           !@background_sprite.bitmap.disposed?
          @background_sprite.bitmap.dispose
        end

        @background_sprite.dispose
      end

      @background_sprite = Sprite.new
      @background_sprite.z = self.z - 1
      fs_bthud_v13_redraw_background
    end

    def fs_bthud_v13_redraw_background
      return if @background_sprite == nil ||
                @background_sprite.disposed?

      if @background_sprite.bitmap != nil &&
         !@background_sprite.bitmap.disposed?
        @background_sprite.bitmap.dispose
      end

      bmp = Bitmap.new(self.width, self.height)
      rect = Rect.new(0, 0, self.width, self.height)
      color = FS_BATTLE_TARGET_HUD_LAYOUT::DETAIL_BG_COLOR
      radius =
        FS_BATTLE_TARGET_HUD_LAYOUT::DETAIL_CORNER_RADIUS

      if bmp.respond_to?(:fill_rounded_rect)
        bmp.fill_rounded_rect(rect, color, radius)
      else
        bmp.fill_rect(rect, color)
      end

      @background_sprite.bitmap = bmp
      sync_background_sprite if
        respond_to?(:sync_background_sprite)
    end

    def fs_bthud_anchor_sprite=(sprite)
      return if @fs_bthud_anchor_sprite.equal?(sprite)

      @fs_bthud_anchor_sprite = sprite

      # RGSS2／Ruby 1.8.1沒有instance_variable_defined?。
      # 直接設為nil即可，Ruby會自動建立這個實例變數。
      @last_detail_placement_key = nil

      update_placement
    end

    def fs_bthud_v132_cursor_x
      return nil unless $scene.is_a?(Scene_Battle)
      return nil unless defined?($in_target) && $in_target

      cursor =
        $scene.instance_variable_get(:@cursor)

      return nil if cursor == nil
      return nil if cursor.respond_to?(:disposed?) &&
                    cursor.disposed?
      return nil unless cursor.respond_to?(:x)

      return cursor.x.to_i
    rescue
      return nil
    end

    def detail_target_screen_x
      cursor_x = fs_bthud_v132_cursor_x
      return cursor_x unless cursor_x == nil

      sprite = @fs_bthud_anchor_sprite

      if sprite != nil &&
         (!sprite.respond_to?(:disposed?) ||
          !sprite.disposed?) &&
         sprite.respond_to?(:x)

        begin
          value = sprite.x.to_i
          return value if value != 0
        rescue
        end
      end

      battler = @battler

      if battler != nil &&
         battler.respond_to?(:position_x)
        begin
          value = battler.position_x.to_i
          return value if value != 0
        rescue
        end
      end

      if battler != nil &&
         battler.respond_to?(:base_position_x)
        begin
          value = battler.base_position_x.to_i
          return value if value != 0
        rescue
        end
      end

      if @battler_sprite != nil &&
         (!@battler_sprite.respond_to?(:disposed?) ||
          !@battler_sprite.disposed?) &&
         @battler_sprite.respond_to?(:x)

        begin
          value = @battler_sprite.x.to_i
          return value if value != 0
        rescue
        end
      end

      if battler != nil &&
         battler.respond_to?(:screen_x)
        return battler.screen_x.to_i
      end

      return nil
    rescue
      return nil
    end

    def fs_bthud_v13_cursor_y
      return nil unless $scene.is_a?(Scene_Battle)
      return nil unless defined?($in_target) && $in_target

      cursor =
        $scene.instance_variable_get(:@cursor)

      return nil if cursor == nil
      return nil if cursor.respond_to?(:disposed?) &&
                    cursor.disposed?
      return nil unless cursor.respond_to?(:y)

      return cursor.y.to_i +
        FS_BATTLE_TARGET_HUD_LAYOUT::DETAIL_CURSOR_OFFSET_Y
    rescue
      return nil
    end

    def detail_target_screen_y
      cursor_y = fs_bthud_v13_cursor_y
      return cursor_y unless cursor_y == nil

      sprite = @fs_bthud_anchor_sprite

      if sprite != nil &&
         (!sprite.respond_to?(:disposed?) ||
          !sprite.disposed?) &&
         sprite.respond_to?(:y)

        begin
          value = sprite.y.to_i
          return value if value != 0
        rescue
        end
      end

      battler = @battler

      if battler != nil &&
         battler.respond_to?(:position_y)
        begin
          value = battler.position_y.to_i
          return value if value != 0
        rescue
        end
      end

      if battler != nil &&
         battler.respond_to?(:base_position_y)
        begin
          value = battler.base_position_y.to_i
          return value if value != 0
        rescue
        end
      end

      if @battler_sprite != nil &&
         (!@battler_sprite.respond_to?(:disposed?) ||
          !@battler_sprite.disposed?) &&
         @battler_sprite.respond_to?(:y)

        begin
          value = @battler_sprite.y.to_i
          return value if value != 0
        rescue
        end
      end

      if battler != nil &&
         battler.respond_to?(:screen_y)
        return battler.screen_y.to_i
      end

      return nil
    rescue
      return nil
    end

    def fs_bthud_v132_target_inside_window?(
      target_x, target_y, window_y)

      return false if target_x == nil || target_y == nil

      window_x = (Graphics.width - self.width) / 2

      safe_x =
        FS_BATTLE_TARGET_HUD_LAYOUT::DETAIL_TARGET_SAFE_X

      safe_y =
        FS_BATTLE_TARGET_HUD_LAYOUT::DETAIL_TARGET_SAFE_Y

      left   = window_x - safe_x
      right  = window_x + self.width + safe_x
      top    = window_y - safe_y
      bottom = window_y + self.height + safe_y

      return false if target_x < left
      return false if target_x > right
      return false if target_y < top
      return false if target_y > bottom

      return true
    end

    def fs_bthud_v13_dynamic_y
      top_y = FS_BATTLE_TARGET_HUD_LAYOUT::DETAIL_TOP_Y

      bottom_y =
        Graphics.height -
        FS_BATTLE_TARGET_HUD_LAYOUT::DETAIL_BOTTOM_RESERVE -
        self.height

      bottom_y = top_y if bottom_y < top_y

      default_y =
        FS_BATTLE_TARGET_HUD_LAYOUT::DETAIL_DEFAULT_BOTTOM ?
        bottom_y : top_y

      target_x = detail_target_screen_x
      target_y = detail_target_screen_y

      return default_y if target_x == nil || target_y == nil

      top_blocked =
        fs_bthud_v132_target_inside_window?(
          target_x, target_y, top_y)

      bottom_blocked =
        fs_bthud_v132_target_inside_window?(
          target_x, target_y, bottom_y)

      # 只有下方真的遮住目標時才往上移。
      if bottom_blocked && !top_blocked
        return top_y
      end

      # 只有上方真的遮住目標時維持下方。
      if top_blocked && !bottom_blocked
        return bottom_y
      end

      # 上下都安全，或上下都會重疊時，維持統一預設位置。
      return default_y
    end

    def fs_bthud_v141_command_x
      centered_x =
        (Graphics.width - self.width) / 2

      safe_right =
        FS_BATTLE_TARGET_HUD_LAYOUT::
          DETAIL_COMMAND_SAFE_RIGHT

      min_x =
        FS_BATTLE_TARGET_HUD_LAYOUT::
          DETAIL_COMMAND_LEFT_X

      # 置中後仍未進入Command保留區，維持置中。
      if centered_x + self.width <= safe_right
        return [centered_x, min_x].max
      end

      # 只有會壓到Command時才左移，而且只移到剛好不重疊。
      shifted_x = safe_right - self.width
      shifted_x = min_x if shifted_x < min_x

      return shifted_x
    end

    def update_placement
      if fs_bthud_v14_command_ui_visible?
        self.x = fs_bthud_v141_command_x

        command_y =
          FS_BATTLE_TARGET_HUD_LAYOUT::
            DETAIL_COMMAND_BOTTOM_Y -
          self.height

        top_limit =
          FS_BATTLE_TARGET_HUD_LAYOUT::
            DETAIL_COMMAND_TOP_LIMIT

        command_y = top_limit if command_y < top_limit
        self.y = command_y
      else
        self.x = (Graphics.width - self.width) / 2
        self.y = fs_bthud_v13_dynamic_y
      end

      sync_background_sprite if
        respond_to?(:sync_background_sprite)
    end

    def fs_bthud_v13_resize(new_width, new_height)
      max_width = fs_bthud_v14_active_max_width

      new_width =
        FS_BATTLE_TARGET_HUD_LAYOUT.clamp(
          new_width,
          FS_BATTLE_TARGET_HUD_LAYOUT::DETAIL_MIN_WIDTH,
          max_width)

      new_height =
        FS_BATTLE_TARGET_HUD_LAYOUT.clamp(
          new_height,
          FS_BATTLE_TARGET_HUD_LAYOUT::DETAIL_MIN_HEIGHT,
          FS_BATTLE_TARGET_HUD_LAYOUT::DETAIL_MAX_HEIGHT)

      changed =
        self.width != new_width ||
        self.height != new_height

      return unless changed

      self.width = new_width
      self.height = new_height
      create_contents
      fs_bthud_v13_redraw_background
      update_placement
    end

    def fs_bthud_v13_desired_width(
      states, info_rows, font_size)

      old_size = self.contents.font.size
      self.contents.font.size = font_size

      max_content_width = 0

      for row in info_rows
        label = row[0].to_s
        value = row[1].to_s

        label_w =
          self.contents.text_size(label).width + 8

        label_w =
          FS_BATTLE_TARGET_HUD_LAYOUT::DETAIL_LABEL_MAX if
          label_w >
          FS_BATTLE_TARGET_HUD_LAYOUT::DETAIL_LABEL_MAX

        row_width =
          label_w +
          self.contents.text_size(value).width

        max_content_width = row_width if
          row_width > max_content_width
      end

      for state in states
        text =
          AlbertBattleStateHUD.detail_text(
            @battler, state)

        next if text == nil || text == ""

        icon =
          AlbertBattleStateHUD.hud_icon(state)

        icon_width = icon.to_i > 0 ?
          24 +
          FS_BATTLE_TARGET_HUD_LAYOUT::DETAIL_ICON_GAP :
          0

        row_width =
          icon_width +
          self.contents.text_size(text.to_s).width

        max_content_width = row_width if
          row_width > max_content_width
      end

      self.contents.font.size = old_size

      desired =
        max_content_width +
        32 +
        FS_BATTLE_TARGET_HUD_LAYOUT::DETAIL_WIDTH_PADDING

      return FS_BATTLE_TARGET_HUD_LAYOUT.clamp(
        desired,
        FS_BATTLE_TARGET_HUD_LAYOUT::DETAIL_MIN_WIDTH,
        fs_bthud_v14_active_max_width)
    end

    def redraw(states, info_rows)
      preferred_font =
        FS_BATTLE_TARGET_HUD_LAYOUT::DETAIL_FONT_SIZES[0]

      desired_width =
        fs_bthud_v13_desired_width(
          states, info_rows, preferred_font)

      fs_bthud_v13_resize(
        desired_width,
        FS_BATTLE_TARGET_HUD_LAYOUT::DETAIL_MIN_HEIGHT)

      chosen = nil
      max_content_height =
        FS_BATTLE_TARGET_HUD_LAYOUT::DETAIL_MAX_HEIGHT - 32

      for size in
          FS_BATTLE_TARGET_HUD_LAYOUT::DETAIL_FONT_SIZES

        line_h = size + 7
        self.contents.font.size = size

        layout =
          fs_bthud_v13_build_layout(
            states, info_rows, line_h)

        chosen = [size, line_h, layout]

        break if layout[1] <= max_content_height
      end

      font_size = chosen[0]
      line_h = chosen[1]
      entries = chosen[2][0]
      total_height = chosen[2][1]

      target_height = total_height + 36

      fs_bthud_v13_resize(
        desired_width, target_height)

      self.contents.clear

      old_size = self.contents.font.size
      old_bold = self.contents.font.bold
      old_color = self.contents.font.color

      self.contents.font.size = font_size
      self.contents.font.bold = false
      self.contents.font.color = normal_color

      y = 0
      bottom = self.contents.height
      hidden_rows = 0

      for entry in entries
        row_height = entry[:height]

        if y + row_height > bottom
          hidden_rows += 1
          next
        end

        if entry[:type] == :info
          fs_bthud_v13_draw_info_entry(
            entry, y, line_h)
        else
          fs_bthud_v13_draw_state_entry(
            entry, y, line_h)
        end

        y += row_height +
          FS_BATTLE_TARGET_HUD_LAYOUT::DETAIL_ROW_GAP
      end

      if hidden_rows > 0 && bottom >= line_h
        self.contents.font.color = system_color
        self.contents.draw_text(
          0,
          bottom - line_h,
          self.contents.width,
          line_h,
          "其餘 #{hidden_rows} 項",
          2)
      end

      self.contents.font.size = old_size
      self.contents.font.bold = old_bold
      self.contents.font.color = old_color

      fs_bthud_v13_redraw_background
      update_placement
    end

    def fs_bthud_v13_build_layout(
      states, info_rows, line_h)

      entries = []
      total_height = 0
      content_width = self.width - 32

      for row in info_rows
        label = row[0].to_s
        value = row[1].to_s

        label_w =
          self.contents.text_size(label).width + 8

        label_w =
          FS_BATTLE_TARGET_HUD_LAYOUT::DETAIL_LABEL_MAX if
          label_w >
          FS_BATTLE_TARGET_HUD_LAYOUT::DETAIL_LABEL_MAX

        value_width = content_width - label_w
        value_width = 40 if value_width < 40

        lines =
          fs_bthud_v13_wrap_text(
            value, value_width)

        lines = [""] if lines.empty?
        height = lines.size * line_h

        entries.push({
          :type => :info,
          :label => label,
          :label_w => label_w,
          :lines => lines,
          :height => height
        })

        total_height += height +
          FS_BATTLE_TARGET_HUD_LAYOUT::DETAIL_ROW_GAP
      end

      for state in states
        text =
          AlbertBattleStateHUD.detail_text(
            @battler, state)

        next if text == nil || text == ""

        icon =
          AlbertBattleStateHUD.hud_icon(state)

        text_x = icon.to_i > 0 ?
          24 +
          FS_BATTLE_TARGET_HUD_LAYOUT::DETAIL_ICON_GAP :
          0

        text_width = content_width - text_x
        text_width = 40 if text_width < 40

        lines =
          fs_bthud_v13_wrap_text(
            text.to_s, text_width)

        lines = [""] if lines.empty?
        height = [lines.size * line_h, 24].max

        entries.push({
          :type => :state,
          :icon => icon.to_i,
          :text_x => text_x,
          :lines => lines,
          :height => height
        })

        total_height += height +
          FS_BATTLE_TARGET_HUD_LAYOUT::DETAIL_ROW_GAP
      end

      if total_height > 0
        total_height -=
          FS_BATTLE_TARGET_HUD_LAYOUT::DETAIL_ROW_GAP
      end

      return [entries, total_height]
    end

    def fs_bthud_v13_wrap_text(text, max_width)
      return [text.to_s] if max_width <= 0

      chars = text.to_s.scan(/./m)
      lines = []
      line = ""

      for char in chars
        if char == "\n"
          lines.push(line)
          line = ""
          next
        end

        candidate = line + char

        if line != "" &&
           self.contents.text_size(candidate).width >
           max_width

          lines.push(line)
          line = char
        else
          line = candidate
        end
      end

      lines.push(line) if
        line != "" || lines.empty?

      return lines
    end

    def fs_bthud_v13_draw_info_entry(
      entry, y, line_h)

      label_w = entry[:label_w]
      lines = entry[:lines]

      self.contents.font.color = system_color
      self.contents.draw_text(
        0, y, label_w, line_h,
        entry[:label], 0)

      self.contents.font.color = normal_color

      i = 0
      while i < lines.size
        self.contents.draw_text(
          label_w,
          y + i * line_h,
          self.contents.width - label_w,
          line_h,
          lines[i],
          0)
        i += 1
      end
    end

    def fs_bthud_v13_draw_state_entry(
      entry, y, line_h)

      if entry[:icon] > 0
        draw_icon(entry[:icon], 0, y, true)
      end

      self.contents.font.color = normal_color

      i = 0
      while i < entry[:lines].size
        self.contents.draw_text(
          entry[:text_x],
          y + i * line_h,
          self.contents.width - entry[:text_x],
          line_h,
          entry[:lines][i],
          0)
        i += 1
      end
    end

    def fs_bthud_v13_debug_lines
      lines = []
      lines.push(
        "Target=#{@battler == nil ? 'nil' : @battler.name}")
      lines.push("TargetX=#{detail_target_screen_x}")
      lines.push("TargetY=#{detail_target_screen_y}")
      lines.push("WindowX=#{self.x}")
      lines.push("WindowY=#{self.y}")
      lines.push("WindowW=#{self.width}")
      lines.push("WindowH=#{self.height}")
      lines.push(
        "LayoutMode=#{fs_bthud_v14_layout_mode_key}")
      lines.push(
        "ActiveMaxWidth=#{fs_bthud_v14_active_max_width}")
      lines.push(
        "CommandAdaptiveX=#{fs_bthud_v141_command_x}")
      return lines
    end
  end
end

if defined?(AlbertBattleStateHUDManager)
  class AlbertBattleStateHUDManager

    unless method_defined?(
        :fs_bthud_v13_old_selected_target_set)

      alias_method(
        :fs_bthud_v13_old_selected_target_set,
        :selected_target=)
    end

    def selected_target=(target)
      send(
        :fs_bthud_v13_old_selected_target_set,
        target)

      if @detail_window != nil &&
         @detail_window.respond_to?(
           :fs_bthud_anchor_sprite=)

        sprite = target == nil ?
          nil :
          @sprites[target.object_id]

        @detail_window.fs_bthud_anchor_sprite =
          sprite
      end
    end

    unless method_defined?(:fs_bthud_v13_old_update)
      alias fs_bthud_v13_old_update update
    end

    def update
      fs_bthud_v13_old_update

      if @detail_window != nil &&
         @selected_target != nil &&
         @detail_window.respond_to?(
           :fs_bthud_anchor_sprite=)

        @detail_window.fs_bthud_anchor_sprite =
          @sprites[@selected_target.object_id]
      end
    end
  end
end

class Game_Interpreter
  def fs_bthud_adaptive_layout_report
    unless $scene.is_a?(Scene_Battle)
      $game_message.texts.push(
        "此指令只能在戰鬥中執行。")
      return false
    end

    manager =
      $scene.instance_variable_get(
        :@albert_battle_state_hud)

    return false if manager == nil

    window =
      manager.instance_variable_get(
        :@detail_window)

    return false if window == nil
    return false unless window.respond_to?(
      :fs_bthud_v13_debug_lines)

    lines = []
    lines.push(
      "FS BattleTargetHUD Adaptive Layout v1.4.0")
    lines.push("=" * 72)
    lines.concat(
      window.fs_bthud_v13_debug_lines)

    File.open(
      "FS_BattleTargetHUD_Adaptive_Report.txt",
      "wb") do |file|

      file.write(lines.join("\r\n"))
    end

    $game_message.texts.push(
      "HUD自適應報告已輸出。")
    return true
  rescue
    return false
  end
end

#==============================================================================
# PHASE6 ORIGINAL PAGE: 493 | FS_BattleTargetHUD_NameCenterFix
#==============================================================================
# -*- coding: utf-8 -*-
#==============================================================================
# ** FS_BattleTargetHUD_NameCenterFix v1.0
#------------------------------------------------------------------------------
#  Forest Symphony／RPG Maker VX／RGSS2／Ruby 1.8
#------------------------------------------------------------------------------
# 功能：
#   修正 FS Battle Target HUD Layout Patch 中，敵人名稱會因左側魂刻擷取率
#   與右側狀態 Icon 寬度不對稱而偏向右側的問題。
#
# 新規則：
#   1. 敵人名稱文字本身固定以 Help Window 的水平正中央為中心。
#   2. 屬性 Icon 排在名稱右側，不再把「名稱＋Icon」整組拿去置中。
#   3. 空間不足時，自動縮小／截短名稱，避免壓到擷取率或狀態 Icon。
#
# 安裝位置：
#   放在「FS Battle Target HUD Layout Patch」之下、Main 之上。
#==============================================================================

$imported = {} if $imported == nil
$imported["FS_BattleTargetHUD_NameCenterFix"] = "1.0"

if defined?(Window_Help) &&
   Window_Help.method_defined?(:fs_bthud_v10_draw_name_and_elements)

  class Window_Help < Window_Base
    #--------------------------------------------------------------------------
    # ● 名稱固定置於整個 Help Window 正中央，屬性 Icon 接在右側
    #--------------------------------------------------------------------------
    def fs_bthud_v10_draw_name_and_elements(member, left_x, right_x)
      return if self.contents == nil

      content_width = self.contents.width
      center_x = content_width / 2

      elements = []
      if member.respond_to?(:primary_element)
        value = member.primary_element
        elements.push(value) if value != nil
      end
      if member.respond_to?(:secondary_element)
        value = member.secondary_element
        if value != nil && !elements.include?(value)
          elements.push(value)
        end
      end
      elements = elements[0, 2]

      icon_width = elements.size * 24
      icon_gap = elements.empty? ? 0 :
        FS_BATTLE_TARGET_HUD_LAYOUT::NAME_ELEMENT_GAP
      element_width = icon_gap + icon_width

      # 名稱必須以 center_x 為中心，因此左右可用空間要取較小的一邊。
      # 右側還要預留屬性 Icon 的寬度。
      left_room = center_x - left_x
      right_room = right_x - center_x - element_width
      half_limit = [left_room, right_room].min
      name_limit = half_limit * 2
      return if name_limit <= 8

      name = member.name.to_s
      size = FS_BATTLE_TARGET_HUD_LAYOUT::NAME_FONT_SIZE
      min_size = FS_BATTLE_TARGET_HUD_LAYOUT::NAME_MIN_SIZE
      self.contents.font.bold = false

      loop do
        self.contents.font.size = size
        break if self.contents.text_size(name).width <= name_limit ||
                 size <= min_size
        size -= 1
      end

      name = fs_bthud_v10_fit_text(name, name_limit)
      name_width = self.contents.text_size(name).width
      name_x = center_x - name_width / 2

      self.contents.font.color = normal_color
      self.contents.draw_text(name_x, 0, name_width + 2, WLH, name, 0)

      icon_x = name_x + name_width + icon_gap
      for element in elements
        if respond_to?(:draw_element)
          draw_element(element, icon_x, 0)
        elsif Window_Base.const_defined?(:ELEMENT_ICON_TABLE)
          table = Window_Base.const_get(:ELEMENT_ICON_TABLE)
          icon_id = table[element]
          if icon_id != nil && icon_id.to_i > 0
            draw_icon(icon_id, icon_x, 0, true)
          end
        end
        icon_x += 24
      end
    end
  end
end

#==============================================================================
# PHASE6 ORIGINAL PAGE: 494 | FS_BattleStateHUD_Lifecycle_TargetOverlay v1.1
#==============================================================================
# -*- coding: utf-8 -*-
#==============================================================================
# ■ FS_BattleStateHUD_Lifecycle_TargetOverlay v1.1
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2 / Ruby 1.8.1
#
# 功能：
#   1. 進入戰果結算 display_result 時，立即Dispose BattleStateHUD。
#   2. 敵／我Battler行動中（Tankentai active == true）時，
#      隱藏該Battler自己的戰場State Icon。
#   3. 單體選擇敵／我目標時，使用Graphics/Pictures/Overlay1作為遮罩，
#      暗化其他區域並高光目前目標。
#   4. 遮罩支援淡入／淡出、切換目標、取消選取與戰鬥結束Dispose。
#   5. 同時掛入Scene_Battle#update與#update_basic，
#      Tankentai等待／動作迴圈期間也能正常更新。
#
# 放置位置：
#   BattleStateHUD Core v2.5.1
#   StateStackSlipBridge v3.2
#   FS_BattleTargetHUD_LayoutPatch v1.3.2
#   FS_BattleTargetHUD_NameCenterFix
#   本腳本
#   Main
#
# 必要素材：
#   Graphics/Pictures/Overlay1.png
#
# 注意：
#   本腳本不修改Overlay1圖檔。
#   遮罩效果、透明洞形狀與覆蓋範圍完全由Overlay1本身決定。
#==============================================================================

$imported = {} if $imported == nil
$imported["FS BattleStateHUD Lifecycle TargetOverlay"] = "1.1"

module FS_BATTLE_STATE_TARGET_OVERLAY

  #--------------------------------------------------------------------------
  # ● State Icon生命週期
  #--------------------------------------------------------------------------
  HIDE_ICON_WHILE_ACTING = true
  DISPOSE_HUD_ON_RESULT  = true

  #--------------------------------------------------------------------------
  # ● 目標遮罩
  #--------------------------------------------------------------------------
  ENABLE_TARGET_OVERLAY = true

  # Graphics/Pictures內的圖片名稱。
  OVERLAY_NAME = "Overlay1"

  # 使用獨立Viewport。
  # 戰場角色通常在較低Viewport，Window通常在更高z。
  OVERLAY_VIEWPORT_Z = 50
  OVERLAY_SPRITE_Z   = 0

  # 右側Command UI固定在遮罩上方。
  COMMAND_BAR_Z       = 8990
  COMMAND_PORTRAIT_Z  = 9000
  COMMAND_TEXT_BG_Z   = 9998
  COMMAND_ICON_Z      = 9999

  # 目標游標位於所有Command圖示上方。
  TARGET_CURSOR_Z = 9

  OVERLAY_MAX_OPACITY = 255
  OVERLAY_FADE_SPEED  = 32

  OVERLAY_BLEND_TYPE = 0

  # Overlay1中心相對於Battler座標的微調。
  TARGET_OFFSET_X = 0
  TARGET_OFFSET_Y = 0

  # false：使用Tankentai position_x／position_y。
  # true ：若能找到Sprite_Battler，優先使用Sprite的x／y。
  PREFER_BATTLER_SPRITE_POSITION = false

  #--------------------------------------------------------------------------
  # ● 判斷Battler是否正在實際行動
  #--------------------------------------------------------------------------
  def self.battler_acting?(battler)
    return false if battler == nil
    return false unless HIDE_ICON_WHILE_ACTING

    if battler.respond_to?(:active)
      begin
        return battler.active ? true : false
      rescue
      end
    end

    return false
  end
end

#==============================================================================
# ■ Sprite_AlbertBattleStateHUD
#------------------------------------------------------------------------------
# 行動中的Battler只隱藏自己的State Icon。
# 不影響其他敵我角色，也不改變Command Window圖層規則。
#==============================================================================

if defined?(Sprite_AlbertBattleStateHUD)

  class Sprite_AlbertBattleStateHUD < Sprite

    # 最終覆寫。
    def update_visibility
      should_show = false

      if @battler != nil &&
         @battler.exist? &&
         @has_visible_states

        should_show =
          AlbertBattleStateHUD.hud_visible?($scene)

        if FS_BATTLE_STATE_TARGET_OVERLAY.battler_acting?(
            @battler)

          should_show = false
        end
      end

      self.visible = should_show if
        self.visible != should_show
    end
  end
end

#==============================================================================
# ■ FS_BattleTargetOverlayController
#------------------------------------------------------------------------------
# 直接使用Chest Item Pop-Up同一張Overlay1。
# 圖片原點設在Bitmap中心，座標跟隨目前單體選取目標。
#==============================================================================

class FS_BattleTargetOverlayController

  def initialize(scene)
    @scene = scene
    @last_update_frame = -1
    @last_target = nil

    @viewport = Viewport.new(
      0, 0, Graphics.width, Graphics.height)
    @viewport.z =
      FS_BATTLE_STATE_TARGET_OVERLAY::OVERLAY_VIEWPORT_Z

    @sprite = Sprite.new(@viewport)
    @sprite.bitmap = Cache.picture(
      FS_BATTLE_STATE_TARGET_OVERLAY::OVERLAY_NAME)

    @sprite.ox = @sprite.bitmap.width / 2
    @sprite.oy = @sprite.bitmap.height / 2
    @sprite.z =
      FS_BATTLE_STATE_TARGET_OVERLAY::OVERLAY_SPRITE_Z
    @sprite.blend_type =
      FS_BATTLE_STATE_TARGET_OVERLAY::OVERLAY_BLEND_TYPE
    @sprite.opacity = 0
    @sprite.visible = false
  rescue
    dispose
  end

  def disposed?
    return true if @sprite == nil
    return true if @sprite.disposed?
    return false
  rescue
    return true
  end

  def dispose
    if @sprite != nil && !@sprite.disposed?
      # Cache.picture的Bitmap由Cache管理，不能在此dispose。
      @sprite.bitmap = nil
      @sprite.dispose
    end
    @sprite = nil

    if @viewport != nil && !@viewport.disposed?
      @viewport.dispose
    end
    @viewport = nil
  rescue
  end

  def update
    return if disposed?
    return if @last_update_frame == Graphics.frame_count

    @last_update_frame = Graphics.frame_count

    unless FS_BATTLE_STATE_TARGET_OVERLAY::ENABLE_TARGET_OVERLAY
      hide_immediately
      return
    end

    target = selected_single_target

    if target != nil
      update_cursor_z
      update_target(target)
      fade_in
    else
      fade_out
    end
  end

  #--------------------------------------------------------------------------
  # ● 目前是否為單體目標選擇
  #--------------------------------------------------------------------------
  def selected_single_target
    return nil if @scene == nil

    # Tankentai正式目標選擇。
    in_target =
      defined?($in_target) && $in_target

    members =
      @scene.instance_variable_get(:@target_members)
    index =
      @scene.instance_variable_get(:@index)

    if in_target &&
       members.is_a?(Array) &&
       !members.empty? &&
       index != nil &&
       index >= 0 &&
       index < members.size

      target = members[index]
      return target if target.is_a?(Game_Battler)
    end

    # VX標準敵方選擇Window備援。
    enemy_window =
      @scene.instance_variable_get(:@target_enemy_window)

    if enemy_window != nil &&
       !enemy_window.disposed? &&
       enemy_window.active &&
       enemy_window.respond_to?(:enemy)

      target = enemy_window.enemy
      return target if target.is_a?(Game_Battler)
    end

    # VX標準我方選擇Window備援。
    actor_window =
      @scene.instance_variable_get(:@target_actor_window)

    if actor_window != nil &&
       !actor_window.disposed? &&
       actor_window.active

      actor_index = actor_window.index

      if actor_index != nil && actor_index >= 0
        target = $game_party.members[actor_index]
        return target if target.is_a?(Game_Battler)
      end
    end

    return nil
  rescue
    return nil
  end

  #--------------------------------------------------------------------------
  # ● 目標座標
  #--------------------------------------------------------------------------
  def target_position(target)
    if FS_BATTLE_STATE_TARGET_OVERLAY::
       PREFER_BATTLER_SPRITE_POSITION

      sprite = battler_sprite(target)
      if sprite != nil
        return [sprite.x.to_i, sprite.y.to_i]
      end
    end

    if target.respond_to?(:position_x) &&
       target.respond_to?(:position_y)

      begin
        x = target.position_x.to_i
        y = target.position_y.to_i
        return [x, y] if x != 0 || y != 0
      rescue
      end
    end

    if target.respond_to?(:base_position_x) &&
       target.respond_to?(:base_position_y)

      begin
        x = target.base_position_x.to_i
        y = target.base_position_y.to_i
        return [x, y] if x != 0 || y != 0
      rescue
      end
    end

    sprite = battler_sprite(target)
    if sprite != nil
      return [sprite.x.to_i, sprite.y.to_i]
    end

    if target.respond_to?(:screen_x) &&
       target.respond_to?(:screen_y)

      return [
        target.screen_x.to_i,
        target.screen_y.to_i
      ]
    end

    return [Graphics.width / 2, Graphics.height / 2]
  rescue
    return [Graphics.width / 2, Graphics.height / 2]
  end

  def battler_sprite(target)
    return nil if target == nil
    return nil if @scene == nil

    spriteset =
      @scene.instance_variable_get(:@spriteset)
    return nil if spriteset == nil

    groups = []

    begin
      groups.push(
        spriteset.instance_variable_get(:@actor_sprites))
    rescue
    end

    begin
      groups.push(
        spriteset.instance_variable_get(:@enemy_sprites))
    rescue
    end

    for group in groups
      next unless group.is_a?(Array)

      for sprite in group
        next if sprite == nil
        next if sprite.respond_to?(:disposed?) &&
                sprite.disposed?
        next unless sprite.respond_to?(:battler)

        return sprite if sprite.battler.equal?(target)
      end
    end

    return nil
  rescue
    return nil
  end

  #--------------------------------------------------------------------------
  # ● 更新遮罩位置
  #--------------------------------------------------------------------------
  def update_target(target)
    position = target_position(target)

    @sprite.x =
      position[0] +
      FS_BATTLE_STATE_TARGET_OVERLAY::TARGET_OFFSET_X

    @sprite.y =
      position[1] +
      FS_BATTLE_STATE_TARGET_OVERLAY::TARGET_OFFSET_Y

    @last_target = target
    @sprite.visible = true
  end

  #--------------------------------------------------------------------------
  # ● 確保目標游標位於遮罩上方
  #--------------------------------------------------------------------------
  def update_cursor_z
    cursor =
      @scene.instance_variable_get(:@cursor)

    return if cursor == nil
    return if cursor.respond_to?(:disposed?) &&
              cursor.disposed?
    return unless cursor.respond_to?(:z=)

    cursor.z =
      FS_BATTLE_STATE_TARGET_OVERLAY::TARGET_CURSOR_Z
  rescue
  end

  #--------------------------------------------------------------------------
  # ● 淡入／淡出
  #--------------------------------------------------------------------------
  def fade_in
    @sprite.visible = true

    opacity =
      @sprite.opacity +
      FS_BATTLE_STATE_TARGET_OVERLAY::OVERLAY_FADE_SPEED

    max =
      FS_BATTLE_STATE_TARGET_OVERLAY::OVERLAY_MAX_OPACITY

    opacity = max if opacity > max
    @sprite.opacity = opacity
  end

  def fade_out
    return unless @sprite.visible

    opacity =
      @sprite.opacity -
      FS_BATTLE_STATE_TARGET_OVERLAY::OVERLAY_FADE_SPEED

    if opacity <= 0
      hide_immediately
    else
      @sprite.opacity = opacity
    end
  end

  def hide_immediately
    return if @sprite == nil

    @sprite.opacity = 0
    @sprite.visible = false
    @last_target = nil
  end
end

#==============================================================================
# ■ Scene_Battle
#------------------------------------------------------------------------------
# 1. start建立目標遮罩。
# 2. update與update_basic都更新，支援Tankentai等待／行動迴圈。
# 3. display_result開始前Dispose HUD與遮罩。
# 4. terminate再做一次安全Dispose。
#==============================================================================

if defined?(Scene_Battle)

  class Scene_Battle < Scene_Base

    unless method_defined?(
        :fs_bshud_overlay_old_start_v11)

      alias fs_bshud_overlay_old_start_v11 start
    end

    def start
      fs_bshud_overlay_old_start_v11

      fs_bshud_overlay_dispose_controller_v11

      @fs_battle_target_overlay =
        FS_BattleTargetOverlayController.new(self)
    end

    unless method_defined?(
        :fs_bshud_overlay_old_update_v11)

      alias fs_bshud_overlay_old_update_v11 update
    end

    def update
      result = fs_bshud_overlay_old_update_v11

      fs_bshud_overlay_update_visuals_v11

      return result
    end

    if method_defined?(:update_basic) &&
       !method_defined?(
         :fs_bshud_overlay_old_update_basic_v11)

      alias fs_bshud_overlay_old_update_basic_v11 update_basic

      def update_basic(*args)
        result =
          fs_bshud_overlay_old_update_basic_v11(*args)

        fs_bshud_overlay_update_visuals_v11

        return result
      end
    end

    # 真正進入戰果Window前Dispose。
    if method_defined?(:display_result) &&
       !method_defined?(
         :fs_bshud_overlay_old_display_result_v11)

      alias fs_bshud_overlay_old_display_result_v11 display_result

      def display_result
        if FS_BATTLE_STATE_TARGET_OVERLAY::
           DISPOSE_HUD_ON_RESULT

          fs_bshud_overlay_dispose_battle_hud_v11
        end

        fs_bshud_overlay_dispose_controller_v11

        return fs_bshud_overlay_old_display_result_v11
      end
    end

    unless method_defined?(
        :fs_bshud_overlay_old_terminate_v11)

      alias fs_bshud_overlay_old_terminate_v11 terminate
    end

    def terminate
      fs_bshud_overlay_dispose_controller_v11

      return fs_bshud_overlay_old_terminate_v11
    end

    def fs_bshud_overlay_update_visuals_v11
      # Tankentai的行動等待可能只呼叫update_basic。
      # 在這裡補更新Manager，讓active切換能即時隱藏State Icon。
      if @albert_battle_state_hud != nil
        begin
          @albert_battle_state_hud.update
        rescue
        end
      end

      fs_bshud_overlay_sync_command_ui_z_v11

      if @fs_battle_target_overlay != nil
        begin
          @fs_battle_target_overlay.update
        rescue
        end
      end
    end

    #--------------------------------------------------------------------------
    # ● 右側人物立繪與Command圖示固定於Overlay1上方
    #--------------------------------------------------------------------------
    def fs_bshud_overlay_sync_command_ui_z_v11
      return if @fs_bshud_ui_z_last_frame ==
                Graphics.frame_count

      @fs_bshud_ui_z_last_frame =
        Graphics.frame_count

      if @bf != nil &&
         (!@bf.respond_to?(:disposed?) || !@bf.disposed?)
        @bf.z =
          FS_BATTLE_STATE_TARGET_OVERLAY::
            COMMAND_PORTRAIT_Z
      end

      if @bf2 != nil &&
         (!@bf2.respond_to?(:disposed?) || !@bf2.disposed?)
        @bf2.z =
          FS_BATTLE_STATE_TARGET_OVERLAY::
            COMMAND_BAR_Z
      end

      if @face_sprite != nil &&
         (!@face_sprite.respond_to?(:disposed?) ||
          !@face_sprite.disposed?)
        @face_sprite.z =
          FS_BATTLE_STATE_TARGET_OVERLAY::
            COMMAND_PORTRAIT_Z
      end

      if @char_sprite != nil &&
         (!@char_sprite.respond_to?(:disposed?) ||
          !@char_sprite.disposed?)
        @char_sprite.z =
          FS_BATTLE_STATE_TARGET_OVERLAY::
            COMMAND_PORTRAIT_Z
      end

      if @sprites.is_a?(Array)
        for sprite in @sprites
          next if sprite == nil
          next if sprite.respond_to?(:disposed?) &&
                  sprite.disposed?

          sprite.z =
            FS_BATTLE_STATE_TARGET_OVERLAY::
              COMMAND_ICON_Z
        end
      end

      if @text_bg_sprite != nil &&
         (!@text_bg_sprite.respond_to?(:disposed?) ||
          !@text_bg_sprite.disposed?)
        @text_bg_sprite.z =
          FS_BATTLE_STATE_TARGET_OVERLAY::
            COMMAND_TEXT_BG_Z
      end

      if @text_sprites.is_a?(Array)
        for sprite in @text_sprites
          next if sprite == nil
          next if sprite.respond_to?(:disposed?) &&
                  sprite.disposed?

          sprite.z =
            FS_BATTLE_STATE_TARGET_OVERLAY::
              COMMAND_ICON_Z
        end
      end
    rescue
    end

    def fs_bshud_overlay_dispose_battle_hud_v11
      return if @albert_battle_state_hud == nil

      begin
        @albert_battle_state_hud.dispose
      rescue
      end

      @albert_battle_state_hud = nil
    end

    def fs_bshud_overlay_dispose_controller_v11
      if @fs_battle_target_overlay != nil
        begin
          @fs_battle_target_overlay.dispose
        rescue
        end
      end

      @fs_battle_target_overlay = nil
    end
  end
end

#==============================================================================
# ■ 診斷指令
#==============================================================================

class Game_Interpreter

  # 戰鬥事件腳本：
  #   fs_battle_visual_report
  #
  # 輸出目前State HUD、Active Battler與目標遮罩狀態。
  def fs_battle_visual_report
    unless $scene.is_a?(Scene_Battle)
      $game_message.texts.push(
        "此指令只能在戰鬥中執行。")
      return false
    end

    lines = []
    lines.push(
      "FS BattleStateHUD Lifecycle TargetOverlay v1.1")
    lines.push("=" * 72)

    manager =
      $scene.instance_variable_get(
        :@albert_battle_state_hud)

    overlay =
      $scene.instance_variable_get(
        :@fs_battle_target_overlay)

    lines.push(
      "HUD Manager=#{manager == nil ? 'nil' : manager.class}")

    lines.push(
      "Overlay=#{overlay == nil ? 'nil' : overlay.class}")

    for name in [
        :@bf, :@bf2, :@face_sprite, :@char_sprite]

      sprite = $scene.instance_variable_get(name)

      if sprite == nil
        lines.push("#{name}=nil")
      else
        lines.push(
          "#{name} z=#{sprite.z} " +
          "opacity=#{sprite.opacity}")
      end
    end

    command_sprites =
      $scene.instance_variable_get(:@sprites)

    if command_sprites.is_a?(Array)
      command_sprites.each_with_index do |sprite, index|
        next if sprite == nil
        lines.push(
          "@sprites[#{index}] z=#{sprite.z} " +
          "opacity=#{sprite.opacity}")
      end
    end

    battlers = []
    battlers.concat($game_party.members)
    battlers.concat($game_troop.members)

    for battler in battlers
      next if battler == nil

      active = if battler.respond_to?(:active)
                 battler.active ? true : false
               else
                 false
               end

      lines.push(
        "#{battler.class} #{battler.name} active=#{active}")
    end

    File.open(
      "FS_BattleVisual_Report.txt", "wb") do |file|

      file.write(lines.join("\r\n"))
    end

    $game_message.texts.push(
      "戰鬥視覺報告已輸出。")

    return true
  rescue
    return false
  end
end
