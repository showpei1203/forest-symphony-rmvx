#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_YEM_EquipmentUI_SafetyPatch v1.1
# 【用途】Forest Symphony 裝備 UI／召喚預覽／Optimize 相容頁「FS_YEM_EquipmentUI_SafetyPatch v1.1」，針對既有系統補正專案需要的行為。
# 【主要機制】通常透過 alias／class reopen 包裝前方實作；它不是可任意搬動的獨立功能，需維持在被修正腳本之後。
# 【主要影響】Game_Actor、Game_Party、Window_Equip_Item、Window_Equip_Item_mini、Window_EquipStat、Scene_Equip、ALBERT_YEM_EQUIP_SAFE
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：SUMMON_FRAME_SEQUENCE、SUMMON_FRAME_WAIT、SUMMON_CHAR_X、SUMMON_CHAR_Y、OPTIMIZE_NOTICE_TIME。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】登記 $imported：Albert YEM Equipment Overhaul Safety Patch；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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
# ■ FS_YEM_EquipmentUI_SafetyPatch v1.1
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2
#
# 放置位置：
#   YEM Equipment Overhaul、EquipmentCombo、DynamicCaptureRate 等相關補丁之下，
#   Main 之上。建議放在目前「DynamicCaptureRate」之下。
#
# Phase 30 責任：
#   - equip_type／equip_type=／欄位增刪／purge／equip_legal_slot 已回寫 YEM Core。
#   - 本頁只保留後載相容責任，不再覆寫 Game_Actor 的六個核心欄位方法。
# 修正內容：
#   1. 清除裝備清單的 equippable 快取，避免切換角色後沿用上一人的結果。
#   6. 修正召喚物詳細頁：
#      - 選到「卸下裝備(nil)」不再報錯。
#      - 不再對真正的召喚 Actor 呼叫 setup / recover_all。
#      - 使用 character_name + "_1" 的 3x4 行走圖做 VX 式待機動畫。
#   7. 裝備詳細視窗只在可見且為召喚物頁時更新動畫。
#   8. 移除 end_item_selection 對公用事件 25 的依賴。
#   9. 強化自動換裝：
#      - 支援動態欄位。
#      - 尊重 fixed equipment 與 locked_equips。
#      - 防止 TYPE_RULES / OPTIMIZE_SETTINGS 缺值時直接報錯。
#      - 保留 HP / MP 比例。
#  10. 提供安全的裝備畫面短暫提示訊息，不建立巢狀 Window_Message loop。
#
# 注意：
#   原 YEM Equipment Overhaul 內 update_command_selection 的 when :optimize
#   分支仍需依本文說明做一次直接替換，因為那一段內嵌了公用事件 25
#   與手動 Window_Message loop，不適合用小型 alias 安全移除。
#==============================================================================

$imported = {} if $imported == nil
$imported["Albert YEM Equipment Overhaul Safety Patch"] = 1.1

module ALBERT_YEM_EQUIP_SAFE
  CORE_OVERRIDES_RETIRED = true
  SUMMON_FRAME_SEQUENCE = [1, 0, 1, 2]
  SUMMON_FRAME_WAIT     = 20
  SUMMON_CHAR_X         = 180
  SUMMON_CHAR_Y         = 100
  OPTIMIZE_NOTICE_TIME  = 90

  def self.valid_type?(type)
    return false unless defined?(YEM)
    return false unless defined?(YEM::EQUIP)
    return false unless defined?(YEM::EQUIP::TYPE_RULES)
    return YEM::EQUIP::TYPE_RULES.has_key?(type)
  end
end

#==============================================================================
# ■ Game_Actor Core Safety（Phase 30 已回寫 YEM Equipment Overhaul）
#------------------------------------------------------------------------------
# 以下六個方法已由 YEM CoreSafe v1.1 直接提供，本頁不再重複定義：
#   equip_type / equip_type= / add_equip_type / delete_last_equip_type
#   purge_unequippable / equip_legal_slot
# ALBERT_YEM_EQUIP_SAFE 保留，因 SetupRuntime_10 與本頁 UI 仍使用其 API／常數。
#==============================================================================

#==============================================================================
# ■ Galv New Item 舊存檔防呆
#==============================================================================
if defined?(Galv_Nitem)
  class Game_Party < Game_Unit
    def nitems
      @nitems = {} unless @nitems.is_a?(Hash)
      @nitems[:item]   = [] unless @nitems[:item].is_a?(Array)
      @nitems[:weapon] = [] unless @nitems[:weapon].is_a?(Array)
      @nitems[:armor]  = [] unless @nitems[:armor].is_a?(Array)
      return @nitems
    end
  end
end

#==============================================================================
# ■ Window_Equip_Item
#==============================================================================
if defined?(Window_Equip_Item)
  class Window_Equip_Item < Window_Selectable

    unless method_defined?(:albert_yem_safe_item_actor_set)
      alias_method :albert_yem_safe_item_actor_set, :actor=
    end

    def actor=(new_actor)
      @equippables = {}
      albert_yem_safe_item_actor_set(new_actor)
    end

    unless method_defined?(:albert_yem_safe_item_refresh)
      alias_method :albert_yem_safe_item_refresh, :refresh
    end

    def refresh(type, debug = false)
      @equippables = {}
      albert_yem_safe_item_refresh(type, debug)
    end
  end
end

#==============================================================================
# ■ Window_Equip_Item_mini
#==============================================================================
if defined?(Window_Equip_Item_mini)
  class Window_Equip_Item_mini < Window_Selectable

    unless method_defined?(:albert_yem_safe_mini_actor_set)
      alias_method :albert_yem_safe_mini_actor_set, :actor=
    end

    def actor=(new_actor)
      @equippables = {}
      albert_yem_safe_mini_actor_set(new_actor)
    end

    unless method_defined?(:albert_yem_safe_mini_refresh)
      alias_method :albert_yem_safe_mini_refresh, :refresh
    end

    def refresh(type, debug = false)
      @equippables = {}
      albert_yem_safe_mini_refresh(type, debug)
    end
  end
end

#==============================================================================
# ■ Window_EquipStat
#==============================================================================
if defined?(Window_EquipStat)
  class Window_EquipStat < Window_Base

    unless method_defined?(:albert_yem_safe_stat_initialize)
      alias_method :albert_yem_safe_stat_initialize, :initialize
    end

    def initialize(window, actor)
      @albert_frame_sequence = ALBERT_YEM_EQUIP_SAFE::SUMMON_FRAME_SEQUENCE
      @albert_frame_index = 0
      @albert_frame_count = 0
      @albert_preview_key = nil
      @frame = @albert_frame_sequence[@albert_frame_index]
      @summon_mode = false
      albert_yem_safe_stat_initialize(window, actor)
    end

    unless method_defined?(:albert_yem_safe_stat_actor_set)
      alias_method :albert_yem_safe_stat_actor_set, :actor=
    end

    def actor=(new_actor)
      @albert_preview_key = nil
      @albert_frame_index = 0
      @albert_frame_count = 0
      @frame = @albert_frame_sequence[@albert_frame_index]
      @summon_mode = false
      albert_yem_safe_stat_actor_set(new_actor)
    end

    #--------------------------------------------------------------------------
    # ○ 取得裝備對應的召喚 Actor ID
    #--------------------------------------------------------------------------
    def albert_summon_actor_id(equip)
      return nil if equip == nil
      return nil unless defined?(ArmorMapping)
      return nil unless ArmorMapping.respond_to?(:mapping)

      begin
        mapping = ArmorMapping.mapping
      rescue
        return nil
      end

      return nil unless mapping.is_a?(Hash)

      actor_id = mapping[equip.id]
      return nil if actor_id == nil
      return nil if actor_id <= 0
      return nil if $data_actors[actor_id] == nil

      return actor_id
    end

    #--------------------------------------------------------------------------
    # ○ 安全刷新
    #--------------------------------------------------------------------------
    def refresh(equip = nil, equip_index = nil)
      preview_key = [
        equip == nil ? nil : equip.class.to_s,
        equip == nil ? 0 : equip.id,
        equip_index
      ]

      if @albert_preview_key != preview_key
        @albert_preview_key = preview_key
        @albert_frame_index = 0
        @albert_frame_count = 0
        @frame = @albert_frame_sequence[@albert_frame_index]
      end

      self.contents.clear
      @equip = equip
      @equip_index = equip_index
      @clone = nil
      @summon = nil
      @summon_mode = false

      return if @actor == nil
      return if @equip_index == nil

      # 有實際裝備時才檢查 equippable?。
      # nil 代表「預覽卸下裝備」，不可再呼叫 @equip.id。
      if @equip != nil && !@actor.equippable?(@equip)
        return
      end

      actor_id = albert_summon_actor_id(@equip)

      if actor_id != nil
        @summon_mode = true
        @summon = $game_actors[actor_id]
        draw_summon_stats
        return
      end

      # 一般裝備預覽使用深複製，避免 test 換裝污染真正角色。
      begin
        @clone = Marshal.load(Marshal.dump(@actor))
      rescue
        @clone = nil
      end

      if @clone != nil
        @clone.change_equip(@equip_index, @equip, true)
      end

      draw_actor_stats
      draw_clone_stats if @clone != nil
    end

    #--------------------------------------------------------------------------
    # ○ 召喚物詳細頁
    #   不再呼叫 @summon.setup(actor_id) / recover_all，
    #   只讀取真正召喚 Actor 的現況。
    #--------------------------------------------------------------------------
    def draw_summon_stats
      return if @summon == nil

      contents.font.color = text_color(1)
      contents.draw_text(0, 0, 90, 50, @summon.name.to_s, 0)

      contents.font.color = normal_color
      contents.draw_text(30, 20, 50, 50, @summon.level.to_s, 0)
      contents.draw_text(0, 20, 50, 50, "Lv", 0)

      draw_actor_hp(@summon, 0, 50, 80)
      draw_actor_mp_gauge(@summon, 0, 70, 80)
      contents.draw_text(30, 60, 50, 50, @summon.maxmp.to_s, 2)

      contents.font.color = text_color(1)
      contents.draw_text(0, 90, 50, 50, "攻擊", 0)
      contents.draw_text(0, 110, 50, 50, "防禦", 0)
      contents.draw_text(0, 130, 50, 50, "精神", 0)
      contents.draw_text(0, 150, 50, 50, "敏捷", 0)

      contents.font.color = normal_color
      contents.draw_text(60, 90, 50, 50, @summon.atk.to_s, 0)
      contents.draw_text(60, 110, 50, 50, @summon.def.to_s, 0)
      contents.draw_text(60, 130, 50, 50, @summon.spi.to_s, 0)
      contents.draw_text(60, 150, 50, 50, @summon.agi.to_s, 0)

      draw_actor_face(@summon, 100, 10)

      albert_draw_summon_character(
        @summon,
        ALBERT_YEM_EQUIP_SAFE::SUMMON_CHAR_X,
        ALBERT_YEM_EQUIP_SAFE::SUMMON_CHAR_Y
      )
    end

    #--------------------------------------------------------------------------
    # ○ 使用 character_name + "_1" 的單角色 3x4 行走圖
    #   VX 待機循環：[1, 0, 1, 2]
    #--------------------------------------------------------------------------
    def albert_draw_summon_character(actor, x, y)
      return if actor == nil
      character_name = actor.character_name.to_s
      return if character_name.empty?

      begin
        bitmap = Cache.character(character_name + "_1")
        cw = bitmap.width / 3
        ch = bitmap.height / 4

        return if cw <= 0 || ch <= 0

        frame = @albert_frame_sequence[@albert_frame_index]
        src_rect = Rect.new(frame * cw, 0, cw, ch)
        self.contents.blt(x - cw / 2, y - ch, bitmap, src_rect)
      rescue
        # 若沒有 _1 圖檔，退回 VX 原本的角色圖顯示。
        draw_actor_graphic(actor, x, y)
      end
    end

    #--------------------------------------------------------------------------
    # ○ 動畫更新
    #--------------------------------------------------------------------------
    def update
      super

      return unless @summon_mode
      return unless self.visible

      @albert_frame_count += 1
      return if @albert_frame_count < ALBERT_YEM_EQUIP_SAFE::SUMMON_FRAME_WAIT

      @albert_frame_count = 0
      @albert_frame_index += 1
      @albert_frame_index %= @albert_frame_sequence.size
      @frame = @albert_frame_sequence[@albert_frame_index]

      refresh(@equip, @equip_index)
    end
  end
end

#==============================================================================
# ■ Scene_Equip
#==============================================================================
if defined?(Scene_Equip)
  class Scene_Equip < Scene_Base

    #--------------------------------------------------------------------------
    # ○ 主更新：額外更新召喚物詳細頁動畫與短暫提示
    #--------------------------------------------------------------------------
    unless method_defined?(:albert_yem_safe_scene_update)
      alias_method :albert_yem_safe_scene_update, :update
    end

    def update
      albert_yem_safe_scene_update

      if @stat_window != nil && !@stat_window.disposed?
        @stat_window.update
      end

      albert_update_equip_notice
    end

    #--------------------------------------------------------------------------
    # ○ 安全短暫提示
    #--------------------------------------------------------------------------
    def albert_show_equip_notice(text, frames = nil)
      frames = ALBERT_YEM_EQUIP_SAFE::OPTIMIZE_NOTICE_TIME if frames == nil
      @albert_equip_notice_text = text.to_s
      @albert_equip_notice_frames = [frames.to_i, 1].max
    end

    def albert_update_equip_notice
      return if @albert_equip_notice_frames == nil
      return if @albert_equip_notice_frames <= 0

      # 一旦離開 command window，就停止覆蓋裝備／物品說明。
      if @command_window == nil || !@command_window.active
        @albert_equip_notice_frames = 0
        return
      end

      @albert_equip_notice_frames -= 1

      if @help_window != nil && !@help_window.disposed?
        @help_window.set_text(@albert_equip_notice_text)
      end
    end

    #--------------------------------------------------------------------------
    # ○ 結束裝備選擇
    #   完全移除舊公用事件 25。
    #--------------------------------------------------------------------------
    def end_item_selection
      type = @equip_window.equip_type

      if @mini_item_window != nil && type != nil
        @mini_item_window.refresh(type, false)
      end

      @item_window_oy = {} if @item_window_oy == nil
      @item_window_index = {} if @item_window_index == nil

      if type != nil
        @item_window_oy[type] = @item_window.oy
        index_to_save = @last_item_index
        index_to_save = @item_window.index if index_to_save == nil
        @item_window_index[type] = index_to_save
      end

      @item_window.active = false
      @equip_window.active = true
      @last_item_index = nil

      @equip_window.refresh
      @equip_window.y = @item_window.y
      @item_window.y = Graphics.height * 3

      @equip_window.update_help
      @stat_window.refresh if @stat_window != nil
    end

    #--------------------------------------------------------------------------
    # ○ 取得 slot 對應的 type
    #--------------------------------------------------------------------------
    def albert_equip_type_for_slot(slot)
      return :weapon if slot == 0
      return :weapon if slot == 1 && @actor.two_swords_style
      return @actor.equip_type[slot - 1]
    end

    #--------------------------------------------------------------------------
    # ○ 是否為鎖定欄位
    #--------------------------------------------------------------------------
    def albert_equip_slot_locked?(slot)
      return false unless @actor.respond_to?(:locked_equips)
      return @actor.locked_equips.include?(slot)
    end

    #--------------------------------------------------------------------------
    # ○ 安全自動換裝
    #--------------------------------------------------------------------------
    def perform_optimize
      if @actor.fix_equipment
        Sound.play_buzzer
        albert_show_equip_notice("裝備已固定，無法自動換裝")
        return false
      end

      Sound.play_equip

      hp_rate = @actor.hp.to_f / [@actor.maxhp, 1].max
      mp_rate = @actor.mp.to_f / [@actor.maxmp, 1].max

      slot_count = @actor.equip_type.size + 1

      # 只卸下「允許自動換裝」且「未鎖定」的欄位。
      for slot in 0...slot_count
        next if albert_equip_slot_locked?(slot)

        type = albert_equip_type_for_slot(slot)
        rule = YEM::EQUIP::TYPE_RULES[type]
        next if rule == nil
        next unless rule[3]

        @actor.change_equip(slot, nil)
      end

      # 再依欄位順序選出最佳裝備。
      for slot in 0...slot_count
        next if albert_equip_slot_locked?(slot)

        type = albert_equip_type_for_slot(slot)
        rule = YEM::EQUIP::TYPE_RULES[type]
        next if rule == nil
        next unless rule[3]

        item = optimal_equip(slot, type)
        next if item == nil

        @actor.change_equip(slot, item)
      end

      @status_window.refresh(@equip_window.index) if @status_window != nil
      @equip_window.refresh if @equip_window != nil
      @stat_window.refresh if @stat_window != nil

      @actor.hp = Integer(@actor.maxhp * hp_rate)
      @actor.mp = Integer(@actor.maxmp * mp_rate)

      albert_show_equip_notice("已自動換上裝備")
      return true
    end

    #--------------------------------------------------------------------------
    # ○ 安全最佳裝備搜尋
    #--------------------------------------------------------------------------
    def optimal_equip(slot, type)
      rule = YEM::EQUIP::TYPE_RULES[type]
      return nil if rule == nil

      if slot == 1 &&
         @actor.weapons[0] != nil &&
         @actor.weapons[0].two_handed
        return nil
      end

      equips = []

      if type == :weapon
        for item in $game_party.equip_weapons
          next if item == nil
          next unless @actor.equippable?(item)
          equips.push(item)
        end
      else
        for item in $game_party.equip_armours
          next if item == nil
          next unless item.kind == rule[1]
          next unless @actor.equippable?(item)
          equips.push(item)
        end
      end

      return nil if equips.empty?

      order_type = YEM::EQUIP::OPTIMIZE_SETTINGS.has_key?(type) ?
        type : :unlisted
      order = YEM::EQUIP::OPTIMIZE_SETTINGS[order_type]
      order = [] if order == nil

      result = equips.clone

      for param in order
        comp_proc = YEM::EQUIP::COMP_PARAM_PROC[param]
        get_proc = YEM::EQUIP::GET_PARAM_PROC[param]

        next if comp_proc == nil
        next if get_proc == nil

        equips.sort! { |a, b| comp_proc.call(a, b) }
        highest = equips[0]

        result = equips.find_all { |item|
          get_proc.call(highest) == get_proc.call(item)
        }

        break if result.size == 1
        equips = result.clone
      end

      return nil if result.empty?

      result.sort! { |a, b| b.id - a.id }
      return result[0]
    end
  end
end
