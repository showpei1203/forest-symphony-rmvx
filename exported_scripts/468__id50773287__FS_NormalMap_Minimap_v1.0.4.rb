#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_NormalMap_Minimap v1.0.4
# 【用途】Forest Symphony 專用 Runtime／資料腳本「FS_NormalMap_Minimap v1.0.4」。
# 【主要機制】屬目前正式專案功能的一部分；具體責任以本頁定義的類別、模組與方法，以及 LoadOrder Guide 為準。
# 【主要影響】Game_System、Game_Temp、Game_Map、Spriteset_Map、FS_NormalMap_Minimap
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：DEFAULT_MAP_ENABLED、DISABLED_MAP_IDS、MAP_SETTINGS、DEFAULT_SETTINGS、WALKABLE_CODES、BLOCKED_CODES、WATER_CODES、ICON_TYPES。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 6 個 alias／方法包裝，載入順序具有語意；登記 $imported：FS_NormalMap_Minimap；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
# 【呼叫方式／範例】<MAP_ICON:quest>；<MAP_ICON_A:shop>；<MAP_ICON_B:none>
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
# ■ FS_NormalMap_Minimap v1.0.4
#------------------------------------------------------------------------------
#  Forest Symphony 一般地圖專用小地圖
#  適用：RPG Maker VX / RGSS2
#------------------------------------------------------------------------------
# 【腳本位置】
#
#   FS_RandomDungeon_v0_9_1_FS
#   FS_NormalMap_Minimap_v1_0
#   Main
#
#  本腳本必須放在隨機迷宮腳本下方。
#
#==============================================================================
# 【核心用途】
#==============================================================================
#
#  1. 一般地圖可使用探索式小地圖。
#  2. 由輪盤選單呼叫開關，不強制綁定按鍵。
#  3. 每張 Map ID 各自保存探索進度。
#  4. 使用 ParaPassa 的地圖資料判斷地面、牆壁與水域。
#  5. 支援事件名稱與目前事件頁註釋的動態標記。
#  6. 支援 Self Switch A～D 改變事件標記。
#  7. 未列入設定的一般地圖預設可使用，Map 48 永久停用。
#  8. 進入 FS Random Dungeon 時自動關閉本小地圖。
#  9. 離開隨機迷宮後不會自動恢復，玩家需用輪盤重新開啟。
# 10. Spriteset_Map 初始化鏈被其他腳本截斷時，自動補齊執行狀態。
# 11. 延遲初始化只使用 RGSS2 舊 Ruby 可用的方法。
# 12. 玩家標記、地形與事件標記分層更新，避免整張 Bitmap 重畫。
# 13. 地形與動態事件解析建立快取，降低大型地圖卡頓。
#
#==============================================================================
# 【輪盤選單指令】
#==============================================================================
#
#  切換小地圖：
#
#    FS_NORMAL_MINIMAP.toggle
#
#  強制開啟：
#
#    FS_NORMAL_MINIMAP.show
#
#  強制關閉：
#
#    FS_NORMAL_MINIMAP.hide
#
#  查詢是否顯示：
#
#    FS_NORMAL_MINIMAP.visible?
#
#  查詢目前地圖能否使用：
#
#    FS_NORMAL_MINIMAP.available?
#
#  切換大型地圖：
#
#    FS_NORMAL_MINIMAP.fullmap_toggle
#
#==============================================================================
# 【基本事件標記】
#==============================================================================
#
#  一般 NPC：
#
#    村長<MAP_ICON:npc>
#
#  任務 NPC：
#
#    採藥人<MAP_ICON:quest>
#
#  商店：
#
#    道具店<MAP_ICON:shop>
#
#  旅館：
#
#    旅館老闆<MAP_ICON:inn>
#
#  恢復點：
#
#    聖地<MAP_ICON:heal>
#
#  寶箱：
#
#    木箱<MAP_ICON:treasure>
#
#  出入口：
#
#    北門<MAP_ICON:exit>
#
#  傳送點：
#
#    傳送陣<MAP_ICON:warp>
#
#  Boss：
#
#    頭目<MAP_ICON:boss>
#
#  魂刻：
#
#    魂響<MAP_ICON:soul>
#
#  不顯示：
#
#    <MAP_ICON:none>
#
#==============================================================================
# 【Self Switch 動態標記】
#==============================================================================
#
#  任務完成後變成一般 NPC：
#
#    採藥人<MAP_ICON:quest><MAP_ICON_A:npc>
#
#  Self Switch A 關閉：quest
#  Self Switch A 開啟：npc
#
#  任務完成後標記消失：
#
#    告示牌<MAP_ICON:quest><MAP_ICON_A:none>
#
#  多階段範例：
#
#    神秘商人
#    <MAP_ICON:quest>
#    <MAP_ICON_A:shop>
#    <MAP_ICON_B:none>
#
#  判定優先順序：D → C → B → A → 預設。
#
#  也支援：
#
#    <MAP_ICON_A:hide>
#
#  hide 與 none 效果相同。
#
#==============================================================================
# 【事件頁註釋動態標記】
#==============================================================================
#
#  事件名稱不必包含 MAP_ICON。
#  在目前有效事件頁的「註釋」中加入：
#
#    <MAP_ICON:quest>
#
#  第二頁註釋：
#
#    <MAP_ICON:npc>
#
#  第三頁註釋：
#
#    <MAP_ICON:none>
#
#  判定優先順序：
#
#    目前事件頁註釋
#    → Self Switch 專用標籤
#    → 事件名稱預設標籤
#
#  因此一般開關、變數、物品與角色條件造成事件換頁時，
#  小地圖標記也會跟著改變。
#
#==============================================================================
# 【事件名稱與標籤】
#==============================================================================
#
#  標記旁使用的名稱，預設為移除所有 <MAP_...> 後的事件名稱。
#
#  例如：
#
#    魯卡村村長<MAP_ICON:npc>
#
#  顯示名稱為：魯卡村村長
#
#  自訂名稱：
#
#    <MAP_LABEL:村長>
#
#  目前事件頁的 MAP_LABEL 會優先於事件名稱。
#
#==============================================================================
# 【永遠顯示】
#==============================================================================
#
#  預設事件必須先被玩家探索，才會顯示在小地圖。
#
#  城鎮商店、旅館或固定出口若希望一開始就顯示：
#
#    道具店<MAP_ICON:shop><MAP_ICON_ALWAYS>
#
#==============================================================================
# 【隱藏條件簡寫】
#==============================================================================
#
#  Self Switch A 開啟後隱藏：
#
#    寶箱<MAP_ICON:treasure><MAP_ICON_HIDE_SELF:A>
#
#  等同：
#
#    寶箱<MAP_ICON:treasure><MAP_ICON_A:none>
#
#==============================================================================
# 【探索指令】
#==============================================================================
#
#  揭露目前整張地圖：
#
#    FS_NORMAL_MINIMAP.reveal_all
#
#  清除目前地圖探索：
#
#    FS_NORMAL_MINIMAP.clear_exploration
#
#  清除指定 Map ID：
#
#    FS_NORMAL_MINIMAP.clear_exploration(5)
#
#  查詢探索率：
#
#    FS_NORMAL_MINIMAP.explored_percent
#
#  強制刷新標記：
#
#    FS_NORMAL_MINIMAP.refresh
#
#==============================================================================

$imported = {} if $imported == nil
$imported["FS_NormalMap_Minimap"] = "1.0.4"

module FS_NormalMap_Minimap
  VERSION = "1.0.4"

  #==========================================================================
  # ■ 地圖設定
  #--------------------------------------------------------------------------
  #  未列入 MAP_SETTINGS 的一般地圖，預設啟用。
  #  Map 48 與其他不需要小地圖的地圖，放入 DISABLED_MAP_IDS。
  #==========================================================================
  DEFAULT_MAP_ENABLED = true

  # 永遠停用一般地圖小地圖的 Map ID。
  DISABLED_MAP_IDS = [48]

  MAP_SETTINGS = {
    # 魯卡村範例：
    # 5 => {
    #   :enabled     => true,
    #   :reveal_mode => :explore,
    #   :display_name => "魯卡村"
    # },

    # 全開式城鎮地圖範例：
    # 7 => {
    #   :enabled     => true,
    #   :reveal_mode => :full,
    #   :display_name => "拓荒營地"
    # },

    # 隨機迷宮模板，明確停用。
    48 => {
      :enabled => false
    }
  }

  DEFAULT_SETTINGS = {
    :enabled                  => DEFAULT_MAP_ENABLED,
    :reveal_mode              => :explore, # :explore / :full
    :display_name             => nil,
    :cell_source              => :parapassa, # :parapassa / :passability

    :reveal_radius            => 3,
    :marker_requires_explored => true,
    :show_player              => true,
    :show_event_labels        => true,

    :minimap_width            => 178,
    :minimap_height           => 138,
    :minimap_anchor           => :top_right,
    :minimap_offset_x         => 8,
    :minimap_offset_y         => 8,
    :minimap_padding          => 7,
    :minimap_opacity          => 185,

    :fullmap_width            => 520,
    :fullmap_height           => 360,
    :fullmap_opacity          => 225,
    :fullmap_list_width       => 155,

    # 輪盤呼叫為主，所以預設不綁定按鍵。
    :toggle_key               => nil,
    :fullmap_key              => nil,

    # 顯示層簽名檢查。簽名已不再掃描全部事件，因此可維持較短間隔。
    :refresh_interval         => 4,

    # 移動中的事件每隔多少幀檢查一次位置。
    # Self Switch／Switch／Variable 造成的換頁由 Game_Map#refresh 即時通知。
    :marker_scan_interval     => 60,

    :show_types => [
      :npc, :quest, :shop, :inn, :heal,
      :treasure, :exit, :warp, :boss, :soul
    ]
  }

  # ParaPassa 通行層代碼。
  WALKABLE_CODES = [769]
  BLOCKED_CODES  = [768]
  WATER_CODES    = [784]

  ICON_TYPES = [
    :npc, :quest, :shop, :inn, :heal,
    :treasure, :exit, :warp, :boss, :soul
  ]

  ICON_COLORS = {
    :npc      => Color.new(235, 235, 235, 255),
    :quest    => Color.new(255, 214, 65, 255),
    :shop     => Color.new(242, 145, 56, 255),
    :inn      => Color.new(123, 171, 255, 255),
    :heal     => Color.new(72, 235, 155, 255),
    :treasure => Color.new(255, 184, 44, 255),
    :exit     => Color.new(255, 91, 91, 255),
    :warp     => Color.new(178, 100, 255, 255),
    :boss     => Color.new(230, 54, 75, 255),
    :soul     => Color.new(65, 184, 255, 255)
  }

  ICON_LABELS = {
    :npc      => "NPC",
    :quest    => "任務",
    :shop     => "商店",
    :inn      => "旅館",
    :heal     => "恢復",
    :treasure => "寶箱",
    :exit     => "出入口",
    :warp     => "傳送",
    :boss     => "Boss",
    :soul     => "魂刻"
  }

  FLOOR_COLOR   = Color.new(150, 158, 142, 255)
  WALL_COLOR    = Color.new(58, 61, 68, 255)
  WATER_COLOR   = Color.new(43, 112, 157, 255)
  UNKNOWN_COLOR = Color.new(85, 89, 93, 255)
  PLAYER_COLOR  = Color.new(255, 255, 255, 255)

  #==========================================================================
  # ■ 設定與狀態
  #==========================================================================
  def self.settings(map_id = nil)
    map_id = $game_map.map_id if map_id == nil && $game_map != nil
    map_id = map_id.to_i
    specific = MAP_SETTINGS[map_id] || {}
    result = DEFAULT_SETTINGS.merge(specific)
    result[:enabled] = false if DISABLED_MAP_IDS.include?(map_id)
    return result
  end

  def self.random_dungeon_active?
    return false unless defined?(FS_RandomDungeon)
    return false unless FS_RandomDungeon.respond_to?(:active?)
    return FS_RandomDungeon.active?
  rescue Exception
    return false
  end

  def self.map_enabled?(map_id = nil)
    return false if $game_map == nil
    map_id = $game_map.map_id if map_id == nil
    return false if map_id.to_i <= 0
    return settings(map_id)[:enabled] != false
  end

  def self.available?(map_id = nil)
    return false if random_dungeon_active?
    return map_enabled?(map_id)
  end

  def self.system_ready?
    return $game_system != nil
  end

  def self.visible_flag
    return false unless system_ready?
    return $game_system.fs_normal_minimap_visible == true
  end

  def self.visible?
    return available? && visible_flag && !fullmap_visible?
  end

  def self.fullmap_visible?
    return false if $game_temp == nil
    return available? && $game_temp.fs_normal_fullmap_visible == true
  end

  def self.show
    return false unless available?
    $game_system.fs_normal_minimap_visible = true
    $game_temp.fs_normal_fullmap_visible = false if $game_temp != nil
    refresh
    return true
  end

  def self.hide
    if $game_system != nil
      $game_system.fs_normal_minimap_visible = false
    end
    if $game_temp != nil
      $game_temp.fs_normal_fullmap_visible = false
    end
    refresh
    return true
  end

  def self.toggle
    return false unless available?
    return visible_flag ? hide : show
  end

  def self.fullmap_toggle
    return false unless available?
    return false if $game_temp == nil
    $game_temp.fs_normal_fullmap_visible =
      !$game_temp.fs_normal_fullmap_visible
    refresh
    return $game_temp.fs_normal_fullmap_visible
  end

  def self.refresh
    return false if $game_temp == nil
    $game_temp.fs_normal_minimap_revision =
      $game_temp.fs_normal_minimap_revision.to_i + 1
    invalidate_marker_cache
    return true
  end

  def self.bump_marker_revision
    return false if $game_temp == nil
    $game_temp.fs_normal_marker_revision =
      $game_temp.fs_normal_marker_revision.to_i + 1
    invalidate_marker_cache
    return true
  end

  def self.marker_revision
    return 0 if $game_temp == nil
    return $game_temp.fs_normal_marker_revision.to_i
  end

  def self.invalidate_marker_cache
    @fs_nm_marker_cache_map_id = nil
    @fs_nm_marker_cache_revision = nil
    @fs_nm_marker_cache_entries = nil
    @fs_nm_marker_cache_signature = nil
  end

  def self.invalidate_terrain_cache
    @fs_nm_terrain_cache_key = nil
    @fs_nm_terrain_cache = nil
  end

  #==========================================================================
  # ■ 顯示狀態診斷
  #==========================================================================
  def self.availability_report
    map_id = $game_map == nil ? 0 : $game_map.map_id.to_i
    return {
      :map_id                => map_id,
      :map_enabled           => map_enabled?(map_id),
      :random_dungeon_active => random_dungeon_active?,
      :available             => available?(map_id),
      :visible_flag          => visible_flag,
      :fullmap_visible       => fullmap_visible?,
      :settings              => settings(map_id)
    }
  end

  def self.current_map_name
    cfg = settings
    name = cfg[:display_name].to_s
    return name unless name.empty?
    if defined?($data_mapinfos) && $data_mapinfos != nil
      info = $data_mapinfos[$game_map.map_id]
      return info.name.to_s if info != nil
    end
    return sprintf("MAP%03d", $game_map.map_id)
  end

  #==========================================================================
  # ■ 探索紀錄
  #==========================================================================
  def self.exploration_table
    return {} unless system_ready?
    $game_system.fs_normal_minimap_exploration ||= {}
    return $game_system.fs_normal_minimap_exploration
  end

  def self.map_exploration(map_id = nil)
    map_id = $game_map.map_id if map_id == nil
    table = exploration_table
    table[map_id.to_i] ||= {}
    return table[map_id.to_i]
  end

  def self.exploration_revision(map_id = nil)
    return 0 unless system_ready?
    map_id = $game_map.map_id if map_id == nil
    revisions = $game_system.fs_normal_minimap_exploration_revision
    revisions ||= {}
    $game_system.fs_normal_minimap_exploration_revision = revisions
    revisions[map_id.to_i] ||= 0
    return revisions[map_id.to_i]
  end

  def self.bump_exploration_revision(map_id = nil)
    return unless system_ready?
    map_id = $game_map.map_id if map_id == nil
    revisions = $game_system.fs_normal_minimap_exploration_revision
    revisions ||= {}
    revisions[map_id.to_i] = revisions[map_id.to_i].to_i + 1
    $game_system.fs_normal_minimap_exploration_revision = revisions
    refresh
  end

  def self.index(x, y)
    return x.to_i + y.to_i * $game_map.width.to_i
  end

  def self.valid_coordinate?(x, y)
    return false if $game_map == nil
    return false if x.to_i < 0 || y.to_i < 0
    return false if x.to_i >= $game_map.width.to_i
    return false if y.to_i >= $game_map.height.to_i
    return true
  end

  def self.explored?(x, y, map_id = nil)
    return true if settings(map_id)[:reveal_mode] == :full
    return false unless valid_coordinate?(x, y)
    return map_exploration(map_id)[index(x, y)] == true
  end

  def self.reveal_cell(x, y)
    return false unless valid_coordinate?(x, y)
    store = map_exploration
    id = index(x, y)
    return false if store[id]
    store[id] = true
    return true
  end

  def self.reveal_position(x = nil, y = nil)
    return false unless available?
    return false if $game_player == nil
    cfg = settings
    return false if cfg[:reveal_mode] == :full
    x = $game_player.x if x == nil
    y = $game_player.y if y == nil
    radius = cfg[:reveal_radius].to_i
    radius = 0 if radius < 0
    changed = false
    for dy in -radius..radius
      for dx in -radius..radius
        next if dx * dx + dy * dy > radius * radius + 1
        changed = true if reveal_cell(x + dx, y + dy)
      end
    end
    bump_exploration_revision if changed
    return changed
  end

  def self.reveal_all(map_id = nil)
    return false if $game_map == nil
    map_id = $game_map.map_id if map_id == nil
    return false if map_id.to_i != $game_map.map_id.to_i
    store = map_exploration(map_id)
    changed = false
    for y in 0...$game_map.height
      for x in 0...$game_map.width
        id = index(x, y)
        next if store[id]
        store[id] = true
        changed = true
      end
    end
    bump_exploration_revision(map_id) if changed
    return changed
  end

  def self.clear_exploration(map_id = nil)
    return false unless system_ready?
    map_id = $game_map.map_id if map_id == nil && $game_map != nil
    return false if map_id == nil
    exploration_table[map_id.to_i] = {}
    bump_exploration_revision(map_id)
    reveal_position if $game_map != nil && map_id.to_i == $game_map.map_id.to_i
    return true
  end

  def self.walkable_cell?(x, y)
    type = cell_type(x, y)
    return type == :floor || type == :water
  end

  def self.explored_percent
    return 0 unless available?
    return 100 if settings[:reveal_mode] == :full
    total = 0
    found = 0
    for y in 0...$game_map.height
      for x in 0...$game_map.width
        next unless walkable_cell?(x, y)
        total += 1
        found += 1 if explored?(x, y)
      end
    end
    return 0 if total <= 0
    return ((found * 100.0) / total).to_i
  end

  #==========================================================================
  # ■ 地形判斷
  #==========================================================================
  def self.passage_code(x, y)
    return nil if $game_map == nil || $game_map.data == nil
    return $game_map.data[x, y, 2]
  rescue Exception
    return nil
  end

  def self.passability_fallback?(x, y)
    return false if $game_map == nil
    [0x01, 0x02, 0x04, 0x08].each do |flag|
      begin
        return true if $game_map.passable?(x, y, flag)
      rescue Exception
      end
    end
    return false
  end

  def self.raw_cell_type(x, y)
    return :wall unless valid_coordinate?(x, y)
    cfg = settings
    if cfg[:cell_source] == :parapassa
      code = passage_code(x, y)
      return :water if WATER_CODES.include?(code)
      return :floor if WALKABLE_CODES.include?(code)
      return :wall if BLOCKED_CODES.include?(code)
    end
    return passability_fallback?(x, y) ? :floor : :wall
  end

  def self.prepare_terrain_cache
    return if $game_map == nil
    cfg = settings
    key = [
      $game_map.map_id.to_i,
      $game_map.width.to_i,
      $game_map.height.to_i,
      cfg[:cell_source]
    ]
    return if @fs_nm_terrain_cache_key == key &&
              @fs_nm_terrain_cache != nil

    cache = []
    for y in 0...$game_map.height
      for x in 0...$game_map.width
        cache[index(x, y)] = raw_cell_type(x, y)
      end
    end
    @fs_nm_terrain_cache_key = key
    @fs_nm_terrain_cache = cache
  end

  def self.cell_type(x, y)
    return :wall unless valid_coordinate?(x, y)
    prepare_terrain_cache
    value = @fs_nm_terrain_cache[index(x, y)]
    return value == nil ? :wall : value
  end

  def self.cell_color(type)
    case type
    when :floor
      return FLOOR_COLOR
    when :water
      return WATER_COLOR
    when :wall
      return WALL_COLOR
    else
      return UNKNOWN_COLOR
    end
  end

  #==========================================================================
  # ■ 事件標記解析
  #==========================================================================
  def self.normalize_icon(value)
    return nil if value == nil
    name = value.to_s.downcase.strip
    return :none if name == "none" || name == "hide"
    symbol = name.to_sym
    return symbol if ICON_TYPES.include?(symbol)
    return nil
  end

  def self.tag_value(text, tag_name)
    return nil if text == nil
    pattern = /<#{tag_name}\s*:\s*([^>]+)>/i
    match = pattern.match(text.to_s)
    return nil if match == nil
    return match[1].to_s.strip
  end

  def self.has_tag?(text, tag_name)
    return false if text == nil
    return text.to_s =~ /<#{tag_name}\s*>/i ? true : false
  end

  def self.page_comment_text(game_event)
    list = nil
    if game_event.respond_to?(:list)
      list = game_event.list
    else
      list = game_event.instance_variable_get(:@list)
    end
    return "" if list == nil
    result = []
    list.each do |command|
      next if command == nil
      next unless command.code == 108 || command.code == 408
      result.push(command.parameters[0].to_s)
    end
    return result.join("\n")
  end

  def self.event_data(game_event)
    return game_event.event if game_event.respond_to?(:event)
    return game_event.instance_variable_get(:@event)
  end

  def self.event_name(game_event)
    data = event_data(game_event)
    return "" if data == nil
    return data.name.to_s
  end

  def self.event_page_index(game_event)
    data = event_data(game_event)
    page = game_event.instance_variable_get(:@page)
    return -1 if data == nil || page == nil || data.pages == nil
    data.pages.each_with_index do |candidate, index_id|
      return index_id if candidate.equal?(page)
    end
    return -1
  end

  def self.self_switch_on?(event_id, letter)
    return false if $game_self_switches == nil
    key = [$game_map.map_id, event_id.to_i, letter.to_s.upcase]
    return $game_self_switches[key] == true
  end

  def self.page_icon(game_event)
    text = page_comment_text(game_event)
    value = tag_value(text, "MAP_ICON")
    return [false, nil] if value == nil
    return [true, normalize_icon(value)]
  end

  def self.self_switch_icon(game_event)
    name = event_name(game_event)

    hide_letter = tag_value(name, "MAP_ICON_HIDE_SELF")
    if hide_letter != nil && self_switch_on?(game_event.id, hide_letter)
      return [true, :none]
    end

    ["D", "C", "B", "A"].each do |letter|
      value = tag_value(name, "MAP_ICON_#{letter}")
      next if value == nil
      next unless self_switch_on?(game_event.id, letter)
      return [true, normalize_icon(value)]
    end
    return [false, nil]
  end

  def self.default_icon(game_event)
    value = tag_value(event_name(game_event), "MAP_ICON")
    return normalize_icon(value)
  end

  def self.current_icon(game_event)
    found, icon = page_icon(game_event)
    return icon if found

    found, icon = self_switch_icon(game_event)
    return icon if found

    return default_icon(game_event)
  end

  def self.marker_always?(game_event)
    return true if has_tag?(page_comment_text(game_event), "MAP_ICON_ALWAYS")
    return true if has_tag?(event_name(game_event), "MAP_ICON_ALWAYS")
    return false
  end

  def self.marker_label(game_event)
    page_label = tag_value(page_comment_text(game_event), "MAP_LABEL")
    return page_label unless page_label == nil || page_label.empty?

    name_label = tag_value(event_name(game_event), "MAP_LABEL")
    return name_label unless name_label == nil || name_label.empty?

    clean = event_name(game_event).gsub(/<MAP_[^>]+>/i, "")
    clean = clean.gsub(/\s+/, " ").strip
    return clean.empty? ? "事件#{game_event.id}" : clean
  end

  def self.event_erased?(game_event)
    return game_event.erased? if game_event.respond_to?(:erased?)
    return game_event.instance_variable_get(:@erased) == true
  rescue Exception
    return false
  end

  def self.build_marker_entries
    return [] unless available?
    return [] if $game_map.events == nil
    cfg = settings
    shown = cfg[:show_types] || ICON_TYPES
    entries = []
    $game_map.events.each_value do |game_event|
      next if game_event == nil
      next if event_erased?(game_event)
      next if game_event.instance_variable_get(:@page) == nil
      icon = current_icon(game_event)
      next if icon == nil || icon == :none
      next unless shown.include?(icon)
      entries.push({
        :event_id  => game_event.id,
        :type      => icon,
        :label     => marker_label(game_event),
        :event     => game_event,
        :always    => marker_always?(game_event),
        :page      => event_page_index(game_event)
      })
    end
    return entries
  end

  def self.marker_entries
    return [] unless available?
    map_id = $game_map.map_id.to_i
    revision = marker_revision
    if @fs_nm_marker_cache_map_id == map_id &&
       @fs_nm_marker_cache_revision == revision &&
       @fs_nm_marker_cache_entries != nil
      return @fs_nm_marker_cache_entries
    end

    @fs_nm_marker_cache_entries = build_marker_entries
    @fs_nm_marker_cache_map_id = map_id
    @fs_nm_marker_cache_revision = revision
    @fs_nm_marker_cache_signature = nil
    return @fs_nm_marker_cache_entries
  end

  def self.marker_visible?(entry)
    return true if entry[:always]
    return true if settings[:marker_requires_explored] == false
    game_event = entry[:event]
    return false if game_event == nil
    return explored?(game_event.x, game_event.y)
  end

  def self.visible_marker_entries
    result = []
    marker_entries.each do |entry|
      result.push(entry) if marker_visible?(entry)
    end
    return result
  end

  def self.marker_signature
    revision = marker_revision
    if @fs_nm_marker_cache_signature != nil &&
       @fs_nm_marker_cache_revision == revision
      return @fs_nm_marker_cache_signature
    end

    values = []
    marker_entries.each do |entry|
      game_event = entry[:event]
      next if game_event == nil
      values.push([
        entry[:event_id], entry[:type], entry[:label],
        game_event.x, game_event.y,
        entry[:always], entry[:page]
      ])
    end
    @fs_nm_marker_cache_signature = values.inspect
    return @fs_nm_marker_cache_signature
  end

  # 只供低頻檢查移動事件的位置。Self Switch 與換頁不靠這個輪詢。
  def self.live_marker_position_signature
    values = []
    marker_entries.each do |entry|
      game_event = entry[:event]
      next if game_event == nil
      values.push([entry[:event_id], game_event.x, game_event.y])
    end
    return values.inspect
  end

  #==========================================================================
  # ■ 輸入
  #==========================================================================
  def self.input_triggered?(key_name)
    return false if key_name == nil
    begin
      key_code = Input.const_get(key_name.to_s)
      return Input.trigger?(key_code)
    rescue Exception
      return false
    end
  end

  #==========================================================================
  # ■ 繪圖
  #==========================================================================
  def self.map_geometry(width, height, padding, list_width = 0,
                        header_height = 0)
    map_w = [$game_map.width.to_i, 1].max
    map_h = [$game_map.height.to_i, 1].max
    usable_w = width - padding * 2 - list_width
    usable_h = height - padding * 2 - header_height
    usable_w = 1 if usable_w < 1
    usable_h = 1 if usable_h < 1
    scale_x = usable_w.to_f / map_w.to_f
    scale_y = usable_h.to_f / map_h.to_f
    cell = [scale_x, scale_y].min.floor
    cell = 1 if cell < 1
    draw_w = map_w * cell
    draw_h = map_h * cell
    origin_x = padding + (usable_w - draw_w) / 2
    origin_y = header_height + padding + (usable_h - draw_h) / 2
    return [cell, origin_x, origin_y]
  end

  def self.draw_marker(bitmap, px, py, size, color)
    marker = [size, 4].max
    half = marker / 2
    bitmap.fill_rect(px - half, py - half, marker, marker,
                     Color.new(0, 0, 0, 230))
    inner = [marker - 2, 1].max
    bitmap.fill_rect(px - half + 1, py - half + 1,
                     inner, inner, color)
  end

  def self.create_map_bitmap(full_map = false)
    return nil unless available?
    cfg = settings

    if full_map
      width = cfg[:fullmap_width].to_i
      height = cfg[:fullmap_height].to_i
      opacity = cfg[:fullmap_opacity].to_i
      list_width = cfg[:fullmap_list_width].to_i
      width = 520 if width <= 0
      height = 360 if height <= 0
      list_width = 155 if list_width < 0
      padding = 10
      header_height = 34
    else
      width = cfg[:minimap_width].to_i
      height = cfg[:minimap_height].to_i
      opacity = cfg[:minimap_opacity].to_i
      list_width = 0
      width = 178 if width <= 0
      height = 138 if height <= 0
      padding = cfg[:minimap_padding].to_i
      padding = 7 if padding < 0
      header_height = 0
    end

    opacity = 0 if opacity < 0
    opacity = 255 if opacity > 255

    bitmap = Bitmap.new(width, height)
    bitmap.fill_rect(0, 0, width, height,
                     Color.new(0, 0, 0, opacity))
    border = Color.new(235, 235, 235, [opacity / 2, 55].max)
    bitmap.fill_rect(0, 0, width, 1, border)
    bitmap.fill_rect(0, height - 1, width, 1, border)
    bitmap.fill_rect(0, 0, 1, height, border)
    bitmap.fill_rect(width - 1, 0, 1, height, border)

    if full_map
      bitmap.font.size = 18
      bitmap.font.bold = true
      title = current_map_name + "｜探索 " +
              explored_percent.to_i.to_s + "%"
      bitmap.draw_text(12, 3, width - 24, 28, title, 0)
    end

    geometry = map_geometry(
      width, height, padding, list_width, header_height
    )
    cell = geometry[0]
    origin_x = geometry[1]
    origin_y = geometry[2]

    for y in 0...$game_map.height
      for x in 0...$game_map.width
        next unless explored?(x, y)
        bitmap.fill_rect(
          origin_x + x * cell,
          origin_y + y * cell,
          cell, cell,
          cell_color(cell_type(x, y))
        )
      end
    end

    visible_marker_entries.each do |entry|
      game_event = entry[:event]
      next if game_event == nil
      color = ICON_COLORS[entry[:type]] || Color.new(255,255,255,255)
      px = origin_x + game_event.x.to_i * cell + cell / 2
      py = origin_y + game_event.y.to_i * cell + cell / 2
      draw_marker(bitmap, px, py, [cell + 2, 5].max, color)
    end

    # 玩家標記由獨立 Sprite 顯示，移動時不重畫整張地圖。

    if full_map && list_width > 0
      draw_marker_list(bitmap, width - list_width, header_height,
                       list_width, height - header_height)
    end

    return bitmap
  end

  def self.draw_marker_list(bitmap, x, y, width, height)
    bitmap.fill_rect(x, y, 1, height,
                     Color.new(235, 235, 235, 70))
    bitmap.font.size = 16
    bitmap.font.bold = true
    bitmap.draw_text(x + 9, y + 5, width - 15, 24, "已發現地標", 0)

    entries = visible_marker_entries
    entries.sort! do |a, b|
      a[:label].to_s <=> b[:label].to_s
    end

    line_y = y + 34
    max_lines = [(height - 42) / 24, 0].max
    entries[0, max_lines].each do |entry|
      color = ICON_COLORS[entry[:type]] || Color.new(255,255,255,255)
      bitmap.fill_rect(x + 10, line_y + 7, 10, 10,
                       Color.new(0,0,0,220))
      bitmap.fill_rect(x + 12, line_y + 9, 6, 6, color)
      bitmap.font.size = 14
      bitmap.font.bold = false
      label = entry[:label].to_s
      bitmap.draw_text(x + 26, line_y, width - 32, 24, label, 0)
      line_y += 24
    end
  end

  def self.minimap_position_for_size(width, height)
    cfg = settings
    offset_x = cfg[:minimap_offset_x].to_i
    offset_y = cfg[:minimap_offset_y].to_i
    anchor = cfg[:minimap_anchor] || :top_right
    case anchor
    when :top_left
      return [offset_x, offset_y]
    when :bottom_left
      return [offset_x, Graphics.height - height - offset_y]
    when :bottom_right
      return [Graphics.width - width - offset_x,
              Graphics.height - height - offset_y]
    else
      return [Graphics.width - width - offset_x, offset_y]
    end
  end

  def self.minimap_position(bitmap)
    return minimap_position_for_size(bitmap.width, bitmap.height)
  end

  def self.player_marker_bitmap
    bitmap = Bitmap.new(8, 8)
    bitmap.fill_rect(0, 0, 8, 8, Color.new(0, 0, 0, 230))
    bitmap.fill_rect(2, 2, 4, 4, PLAYER_COLOR)
    return bitmap
  end

  def self.player_marker_position(full_map = false)
    return nil unless available?
    return nil if $game_player == nil
    cfg = settings

    if full_map
      width = cfg[:fullmap_width].to_i
      height = cfg[:fullmap_height].to_i
      list_width = cfg[:fullmap_list_width].to_i
      width = 520 if width <= 0
      height = 360 if height <= 0
      list_width = 155 if list_width < 0
      padding = 10
      header_height = 34
      panel_x = (Graphics.width - width) / 2
      panel_y = (Graphics.height - height) / 2
    else
      width = cfg[:minimap_width].to_i
      height = cfg[:minimap_height].to_i
      width = 178 if width <= 0
      height = 138 if height <= 0
      list_width = 0
      padding = cfg[:minimap_padding].to_i
      padding = 7 if padding < 0
      header_height = 0
      panel = minimap_position_for_size(width, height)
      panel_x = panel[0]
      panel_y = panel[1]
    end

    geometry = map_geometry(
      width, height, padding, list_width, header_height
    )
    cell = geometry[0]
    origin_x = geometry[1]
    origin_y = geometry[2]
    x = panel_x + origin_x + $game_player.x.to_i * cell + cell / 2 - 4
    y = panel_y + origin_y + $game_player.y.to_i * cell + cell / 2 - 4
    return [x, y]
  end

  def self.display_signature(full_map = false)
    return "inactive" unless available?
    return [
      full_map,
      $game_map.map_id,
      exploration_revision,
      marker_signature,
      $game_temp == nil ? 0 : $game_temp.fs_normal_minimap_revision,
      visible_flag,
      fullmap_visible?
    ].inspect
  end
end

#==============================================================================
# ■ Game_System
#==============================================================================
class Game_System
  attr_accessor :fs_normal_minimap_visible
  attr_accessor :fs_normal_minimap_exploration
  attr_accessor :fs_normal_minimap_exploration_revision

  unless method_defined?(:fs_nm_initialize_v104)
    alias fs_nm_initialize_v104 initialize
  end

  def initialize
    fs_nm_initialize_v104
    @fs_normal_minimap_visible = false
    @fs_normal_minimap_exploration = {}
    @fs_normal_minimap_exploration_revision = {}
  end
end

#==============================================================================
# ■ Game_Temp
#==============================================================================
class Game_Temp
  attr_accessor :fs_normal_fullmap_visible
  attr_accessor :fs_normal_minimap_revision
  attr_accessor :fs_normal_marker_revision

  unless method_defined?(:fs_nm_initialize_v104)
    alias fs_nm_initialize_v104 initialize
  end

  def initialize
    fs_nm_initialize_v104
    @fs_normal_fullmap_visible = false
    @fs_normal_minimap_revision = 0
    @fs_normal_marker_revision = 0
  end
end


#==============================================================================
# ■ Game_Map：事件換頁時刷新小地圖標記快取
#==============================================================================
class Game_Map
  unless method_defined?(:fs_nm_refresh_v104)
    alias fs_nm_refresh_v104 refresh
  end

  def refresh
    fs_nm_refresh_v104
    if defined?(FS_NormalMap_Minimap)
      FS_NormalMap_Minimap.bump_marker_revision
    end
  end
end

#==============================================================================
# ■ Spriteset_Map
#==============================================================================
class Spriteset_Map
  unless method_defined?(:fs_nm_initialize_v104)
    alias fs_nm_initialize_v104 initialize
  end

  def initialize
    fs_nm_initialize_v104
    fs_nm_initialize_minimap
    fs_nm_update_minimap
  end

  unless method_defined?(:fs_nm_update_v104)
    alias fs_nm_update_v104 update
  end

  def update
    fs_nm_update_v104
    fs_nm_update_minimap
  end

  unless method_defined?(:fs_nm_dispose_v104)
    alias fs_nm_dispose_v104 dispose
  end

  def dispose
    fs_nm_dispose_minimap
    fs_nm_dispose_v104
  end

  def fs_nm_initialize_minimap
    @fs_nm_minimap_sprite = nil
    @fs_nm_minimap_signature = nil
    @fs_nm_fullmap_sprite = nil
    @fs_nm_fullmap_signature = nil
    @fs_nm_player_sprite = nil
    @fs_nm_full_player_sprite = nil
    @fs_nm_last_x = nil
    @fs_nm_last_y = nil
    @fs_nm_update_counter = 0
    @fs_nm_marker_scan_counter = 0
    @fs_nm_last_marker_position_signature = nil
    @fs_nm_runtime_ready = true
  end

  #------------------------------------------------------------------------
  # 其他地圖腳本可能重新定義 Spriteset_Map#initialize，卻沒有延續 alias。
  # update 每次先確認本腳本狀態，缺少時自行補齊。
  #------------------------------------------------------------------------
  def fs_nm_ensure_runtime_state
    return if @fs_nm_runtime_ready == true

    # RGSS2 的舊 Ruby 不支援部分新版 instance-variable 檢查方法。
    # 未建立的 instance variable 直接讀取時會安全回傳 nil，
    # 所以只需補齊必須是數字的計數器即可。
    @fs_nm_update_counter = @fs_nm_update_counter.to_i
    @fs_nm_marker_scan_counter = @fs_nm_marker_scan_counter.to_i
    @fs_nm_runtime_ready = true
  end

  def fs_nm_update_minimap
    fs_nm_ensure_runtime_state
    # 進入隨機迷宮時永久關閉一般地圖小地圖。
    if FS_NormalMap_Minimap.random_dungeon_active?
      FS_NormalMap_Minimap.hide if FS_NormalMap_Minimap.visible_flag
      fs_nm_refresh_sprites
      return
    end

    unless FS_NormalMap_Minimap.available?
      fs_nm_refresh_sprites
      return
    end

    cfg = FS_NormalMap_Minimap.settings
    if FS_NormalMap_Minimap.input_triggered?(cfg[:toggle_key])
      FS_NormalMap_Minimap.toggle
    end
    if FS_NormalMap_Minimap.input_triggered?(cfg[:fullmap_key])
      FS_NormalMap_Minimap.fullmap_toggle
    end

    if $game_player != nil &&
       (@fs_nm_last_x != $game_player.x ||
        @fs_nm_last_y != $game_player.y)
      FS_NormalMap_Minimap.reveal_position
      @fs_nm_last_x = $game_player.x
      @fs_nm_last_y = $game_player.y
    end

    fs_nm_update_player_sprites

    @fs_nm_marker_scan_counter = @fs_nm_marker_scan_counter.to_i + 1
    scan_interval = cfg[:marker_scan_interval].to_i
    scan_interval = 60 if scan_interval <= 0
    if @fs_nm_marker_scan_counter >= scan_interval
      @fs_nm_marker_scan_counter = 0
      current_signature =
        FS_NormalMap_Minimap.live_marker_position_signature
      if @fs_nm_last_marker_position_signature != current_signature
        @fs_nm_last_marker_position_signature = current_signature
        FS_NormalMap_Minimap.bump_marker_revision
      end
    end

    @fs_nm_update_counter = @fs_nm_update_counter.to_i + 1
    interval = cfg[:refresh_interval].to_i
    interval = 4 if interval <= 0
    return if @fs_nm_update_counter < interval
    @fs_nm_update_counter = 0
    fs_nm_refresh_sprites
  end

  def fs_nm_refresh_sprites
    fs_nm_ensure_runtime_state
    fs_nm_refresh_minimap_sprite
    fs_nm_refresh_fullmap_sprite
    fs_nm_update_player_sprites
  end

  def fs_nm_refresh_minimap_sprite
    visible = FS_NormalMap_Minimap.visible?
    signature = FS_NormalMap_Minimap.display_signature(false)

    if visible
      if @fs_nm_minimap_sprite == nil ||
         @fs_nm_minimap_signature != signature
        fs_nm_dispose_sprite(@fs_nm_minimap_sprite)
        bitmap = FS_NormalMap_Minimap.create_map_bitmap(false)
        if bitmap != nil
          @fs_nm_minimap_sprite = Sprite.new(@viewport2)
          @fs_nm_minimap_sprite.bitmap = bitmap
          position = FS_NormalMap_Minimap.minimap_position(bitmap)
          @fs_nm_minimap_sprite.x = position[0]
          @fs_nm_minimap_sprite.y = position[1]
          @fs_nm_minimap_sprite.z = 180
        end
        @fs_nm_minimap_signature = signature
      end
    elsif @fs_nm_minimap_sprite != nil
      fs_nm_dispose_sprite(@fs_nm_minimap_sprite)
      @fs_nm_minimap_sprite = nil
      @fs_nm_minimap_signature = nil
    end
  end

  def fs_nm_refresh_fullmap_sprite
    visible = FS_NormalMap_Minimap.fullmap_visible?
    signature = FS_NormalMap_Minimap.display_signature(true)

    if visible
      if @fs_nm_fullmap_sprite == nil ||
         @fs_nm_fullmap_signature != signature
        fs_nm_dispose_sprite(@fs_nm_fullmap_sprite)
        bitmap = FS_NormalMap_Minimap.create_map_bitmap(true)
        if bitmap != nil
          @fs_nm_fullmap_sprite = Sprite.new(@viewport2)
          @fs_nm_fullmap_sprite.bitmap = bitmap
          @fs_nm_fullmap_sprite.x =
            (Graphics.width - bitmap.width) / 2
          @fs_nm_fullmap_sprite.y =
            (Graphics.height - bitmap.height) / 2
          @fs_nm_fullmap_sprite.z = 220
        end
        @fs_nm_fullmap_signature = signature
      end
    elsif @fs_nm_fullmap_sprite != nil
      fs_nm_dispose_sprite(@fs_nm_fullmap_sprite)
      @fs_nm_fullmap_sprite = nil
      @fs_nm_fullmap_signature = nil
    end
  end

  def fs_nm_update_player_sprites
    cfg = FS_NormalMap_Minimap.settings

    minimap_visible = FS_NormalMap_Minimap.visible? &&
                      cfg[:show_player] != false
    if minimap_visible
      if @fs_nm_player_sprite == nil
        @fs_nm_player_sprite = Sprite.new(@viewport2)
        @fs_nm_player_sprite.bitmap =
          FS_NormalMap_Minimap.player_marker_bitmap
        @fs_nm_player_sprite.z = 181
      end
      position = FS_NormalMap_Minimap.player_marker_position(false)
      if position != nil
        @fs_nm_player_sprite.x = position[0]
        @fs_nm_player_sprite.y = position[1]
        @fs_nm_player_sprite.visible = true
      end
    elsif @fs_nm_player_sprite != nil
      fs_nm_dispose_sprite(@fs_nm_player_sprite)
      @fs_nm_player_sprite = nil
    end

    full_visible = FS_NormalMap_Minimap.fullmap_visible? &&
                   cfg[:show_player] != false
    if full_visible
      if @fs_nm_full_player_sprite == nil
        @fs_nm_full_player_sprite = Sprite.new(@viewport2)
        @fs_nm_full_player_sprite.bitmap =
          FS_NormalMap_Minimap.player_marker_bitmap
        @fs_nm_full_player_sprite.z = 221
      end
      position = FS_NormalMap_Minimap.player_marker_position(true)
      if position != nil
        @fs_nm_full_player_sprite.x = position[0]
        @fs_nm_full_player_sprite.y = position[1]
        @fs_nm_full_player_sprite.visible = true
      end
    elsif @fs_nm_full_player_sprite != nil
      fs_nm_dispose_sprite(@fs_nm_full_player_sprite)
      @fs_nm_full_player_sprite = nil
    end
  end

  def fs_nm_dispose_sprite(sprite)
    return if sprite == nil
    if sprite.bitmap != nil && !sprite.bitmap.disposed?
      sprite.bitmap.dispose
    end
    sprite.dispose unless sprite.disposed?
  end

  def fs_nm_dispose_minimap
    fs_nm_ensure_runtime_state
    fs_nm_dispose_sprite(@fs_nm_minimap_sprite)
    fs_nm_dispose_sprite(@fs_nm_fullmap_sprite)
    fs_nm_dispose_sprite(@fs_nm_player_sprite)
    fs_nm_dispose_sprite(@fs_nm_full_player_sprite)
    @fs_nm_minimap_sprite = nil
    @fs_nm_fullmap_sprite = nil
    @fs_nm_player_sprite = nil
    @fs_nm_full_player_sprite = nil
    @fs_nm_minimap_signature = nil
    @fs_nm_fullmap_signature = nil
  end
end

#==============================================================================
# ■ Wheel Menu Alias
#------------------------------------------------------------------------------
#  輪盤選單只需呼叫：
#
#    FS_NORMAL_MINIMAP.toggle
#==============================================================================
FS_NORMAL_MINIMAP = FS_NormalMap_Minimap unless defined?(FS_NORMAL_MINIMAP)
