#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：AutoSetup_08_Enemies
# 【用途】AutoSetup Enemies 的 Engine Adapter；負責把已注入的 MasterSetup Authority Data 套入 RPG Maker VX 資料庫，不再保存第二份正式資料表。
# 【主要機制】本專案 MasterSetup 會在後方覆寫／補齊正式資料；AutoSetup 各頁順序不可任意交換。
# 【主要影響】FS_DB_AUTOSET_ENEMIES
# 【設定／可調參數】Phase 22 起，本頁 DATA／相關資料常數只保留型別正確的 Placeholder；正式數值一律修改對應的 FS_MasterSetup Data Authority，禁止在此維護第二份資料。
# 【依賴／載入順序】本頁先建立 Adapter 與 Placeholder；FS_MasterSetup 18 Apply 必須在 Scene_Title 載入資料庫前注入 Authority Data。FS_DB_AUTOSET.apply_all 會驗證 Authority Ready，缺少 MasterSetup 時直接報錯。
# 【呼叫方式／範例】通常不直接呼叫；Test/Validation 可讀 FS_DB_AUTOSET.authority_ready?。正式資料修改請改 FS_MasterSetup 對應分類，而非本頁 DATA。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【Phase 22 單一資料來源】舊 AutoSetup 內嵌資料已移至外部 Archive；Runtime 最終本來就會被 MasterSetup 18 整份取代，因此移除重複副本不改變正常啟動後的正式資料。
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
# ■ FS_DB_AutoSetup_08_Enemies v1.4.0
#------------------------------------------------------------------------------
# Enemy 500-550：菁英／Boss；551-565：Boss 核心；590-599：召喚成長源；
# Enemy 600-745：146 個 Pokémon 形態。
#
# 【保留】
# - 絕不寫入 battler_name / battler_hue，因此資料庫敵人圖像與色相照常有效。
# - Note 採受管理標籤合併；<action: ...>、移動、待機、受傷、倒下等 SBS Note 保留。
# - Element Rank / State Rank 不覆寫，讓資料庫與既有屬性系統繼續管理。
#==============================================================================
module FS_DB_AUTOSET_ENEMIES
  COMMON_VISUAL_NOTE = ""

  ANIMATE_LINE = /^\s*<\s*[-+]?(?:animate|animated)\s*>\s*$/i
  MIRROR_LINE  = /^\s*<\s*[-+]?(?:mirror|invert)\s*>\s*$/i
  SHADOW_LINE  = /^\s*<\s*shadow\s*:[^>]*>\s*$/i

  def self.with_common_visual_note(text)
    lines = text.to_s.gsub("\r", "").split("\n")
    lines = [] unless lines.is_a?(Array)
    lines.delete_if do |line|
      value = line.to_s
      value =~ ANIMATE_LINE || value =~ MIRROR_LINE || value =~ SHADOW_LINE
    end
    lines.push("<animated>")
    lines.push("<mirror>")
    lines.push("<shadow: off>")
    return FS_DB_AUTOSET.normalize_note_text(lines.join("\n"))
  end

  # 所有資料庫中已有名稱的 Enemy 都套用共同 SBS 顯示 Note。
  # 未受 DATA 管理的 Enemy 保留其餘全部 Note，只替換這三種顯示標籤。
  def self.apply_common_visual_note_to_all
    return unless $data_enemies.is_a?(Array)
    i = 1
    while i < $data_enemies.size
      obj = $data_enemies[i]
      if obj != nil && !obj.name.to_s.empty?
        obj.note = with_common_visual_note(obj.note)
        FS_DB_AUTOSET.invalidate_note_cache(obj)
      end
      i += 1
    end
  end
  DATA = {}
  GRAPHICS_SNAPSHOT = {}
  SBS_SNAPSHOT = {}

  def self.sbs_lines(text)
    holder = Struct.new(:note).new(text.to_s)
    return FS_DB_AUTOSET.visual_note_lines(holder, :enemy)
  end

  def self.make_drop(spec)
    drop = RPG::Enemy::DropItem.new
    return drop if spec == nil
    drop.kind = spec[:kind].to_i
    drop.item_id = spec[:item_id].to_i if drop.respond_to?(:item_id=)
    drop.weapon_id = spec[:weapon_id].to_i if spec[:weapon_id] && drop.respond_to?(:weapon_id=)
    drop.armor_id = spec[:armor_id].to_i if spec[:armor_id] && drop.respond_to?(:armor_id=)
    drop.denominator = spec[:denominator].to_i
    return drop
  end

  def self.make_action(spec)
    action = RPG::Enemy::Action.new
    action.kind = spec[:kind].to_i
    action.basic = spec[:basic].to_i
    action.skill_id = spec[:skill_id].to_i
    action.rating = spec[:rating].to_i
    action.condition_type = spec[:condition_type].to_i
    action.condition_param1 = spec[:condition_param1]
    action.condition_param2 = spec[:condition_param2]
    action.conditions_arrays = [] if action.respond_to?(:conditions_arrays=)
    return action
  end


  #--------------------------------------------------------------------------
  # ● 菁英／Boss 固定最終值
  #--------------------------------------------------------------------------
  # HP 由實際技能輸出與目標行動循環反推。
  # 能力值限制於同階合理範圍，避免 DEF／SPI 直接把傷害壓成裝飾。
  #--------------------------------------------------------------------------
  FIXED_BALANCE_OVERRIDES = {}

  def self.apply_fixed_balance_overrides
    FIXED_BALANCE_OVERRIDES.each do |id, values|
      next unless DATA.has_key?(id)
      values.each { |key, value| DATA[id][key] = value }
    end
  end

  def self.break_threshold_from_note(text)
    return $1.to_i if text.to_s =~ /<break_threshold\s*:\s*(\d+)>/i
    return 5
  end

  # 敵方 Pokémon HP 分級。召喚 Actor 的 HP ×14 不變。
  def self.enemy_hp_scale_from_note(text)
    threshold = break_threshold_from_note(text)
    return 6.0 if threshold <= 3
    return 6.5 if threshold <= 5
    return 7.0 if threshold <= 7
    return 8.0 if threshold <= 9
    return 10.0
  end

  def self.with_enemy_hp_scale(text)
    source = text.to_s.gsub(/<fs_hp_scale\s*:\s*[-\d.]+>/i, "")
    scale = enemy_hp_scale_from_note(source)
    source = source.strip
    return "<fs_hp_scale:#{scale}>" if source.empty?
    return source + "\n<fs_hp_scale:#{scale}>"
  end

  def self.apply
    apply_fixed_balance_overrides
    keys = DATA.keys
    keys = [] unless keys.is_a?(Array)
    keys.sort.each do |id|
      data = DATA[id]
      data = {} unless data.is_a?(Hash)
      FS_DB_AUTOSET.context("enemies", "Enemy ID #{id}")
      enemy = FS_DB_AUTOSET.ensure_record($data_enemies, id, RPG::Enemy)
      GRAPHICS_SNAPSHOT[id] = [enemy.battler_name, enemy.battler_hue]
      SBS_SNAPSHOT[id] = sbs_lines(enemy.note)
      fields = [:name, :maxhp, :maxmp, :atk, :def, :spi, :agi,
                :hit, :eva, :has_critical, :exp, :gold]
      fields.each { |key| FS_DB_AUTOSET.set(enemy, key, data[key]) }
      enemy.drop_item1 = make_drop(data[:drop1]) if enemy.respond_to?(:drop_item1=)
      enemy.drop_item2 = make_drop(data[:drop2]) if enemy.respond_to?(:drop_item2=)
      specs = data[:actions]
      specs = [] unless specs.is_a?(Array)
      enemy.actions = specs.collect { |spec| make_action(spec || {}) } if enemy.respond_to?(:actions=)
      managed_note = data[:note].to_s
      if id >= 590 && id <= 745 &&
         managed_note !~ /<\s*fs_growth_enemy_stats\s*>/i
        managed_note += "\n<fs_growth_enemy_stats>"
      end
      managed_note = with_enemy_hp_scale(managed_note) if id >= 600 && id <= 745
      managed_note = with_common_visual_note(managed_note)
      FS_DB_AUTOSET.replace_note(enemy, "enemy", id, managed_note, SBS_SNAPSHOT[id])
    end
    apply_common_visual_note_to_all
  end
end
