#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：AutoSetup_00_Core
# 【用途】Forest Symphony 資料庫 AutoSetup Engine Core v1.5.0；只負責資料寫入、Note 正規化、錯誤報告與 Scene_Title 套用入口，不再持有正式專案 Data Authority。
# 【主要機制】本專案 MasterSetup 會在後方覆寫／補齊正式資料；AutoSetup 各頁順序不可任意交換。
# 【主要影響】Scene_Title、FS_DB_AUTOSET
# 【設定／可調參數】CATEGORY_MODULES 與 Engine 行為可在本頁維護；Skills／States／Items／Weapons／Armors／Classes／Enemies 的正式資料請只修改 FS_MasterSetup。
# 【依賴／載入順序】必須位於各 AutoSetup Adapter 前。Phase 22 起 apply_all 會先檢查 MasterSetup Authority Ready；FS_MasterSetup 18 Apply 必須在 Scene_Title#load_database 執行前完成握手。
# 【呼叫方式／範例】通常由 Scene_Title 自動呼叫。驗證可使用 FS_DB_AUTOSET.authority_ready?、authority_source、authority_version；手動 FS_DB_AUTOSET.apply_all 前也必須已完成 MasterSetup 注入。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【Phase 22 架構】AutoSetup = Engine／Adapter；MasterSetup = 唯一正式 Data Authority；18 Apply = Authority Data → AutoSetup Engine Bridge。
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
# ■ FS_DB_AutoSetup_00_Core v1.5.0
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2
#
# 【安裝位置】
# 放在「預設腳本之後、所有自訂腳本之前」。01～08、90 緊接本檔。
# 09、10 放在相關原始腳本／補丁之下；11 必須放在最末端、Main 之上。
#
# 【v1.3.1】
# - 修正以高 ID 擴充資料庫時產生大量 nil 空洞的根本問題。
# - 空洞會建立為安全的空白 RPG 資料物件；Item Almanac 等舊腳本可正常遍歷。
# - 空白 Item／Weapon／Armor 自動加入 <Almanac out>，不會污染物品圖鑑。
# - 最終套用後再次掃描 Skill／State／Item／Weapon／Armor／Class／Enemy 陣列。
#
# 【沿用 v1.3】
# - 所有資料列舉改為 nil-safe。
# - 錯誤訊息會指出類別、資料 ID 與欄位。
# - 錯誤時輸出 FS_DB_AutoSetup_Error.txt。
# - 受管資料的功能 Note 改為「腳本權威模式」，不再合併資料庫舊 Note。
# - 只保留嚴格白名單內的 SBS 視覺 Note，以及 Icon／動畫／敵人圖像。
# - 受管欄位每次載入都以 DATA 內容覆寫，不再沿用舊 ID 的功能設定。
# - 新增 Field Effects 天候安全層、優先權、來源與屬性傷害修正。
#==============================================================================
$imported = {} if $imported == nil
$imported["FS DB AutoSetup"] = "1.5.0"

module FS_DB_AUTOSET
  VERSION = "1.5.0"

  # Phase 22：MasterSetup 單一資料來源握手。
  @authority_ready = false
  @authority_source = nil
  @authority_version = nil

  def self.mark_authoritative_data_ready(source, version = nil)
    @authority_ready = true
    @authority_source = source.to_s
    @authority_version = version.to_s
    return true
  end

  def self.authority_ready?
    return @authority_ready == true
  end

  def self.authority_source
    return @authority_source
  end

  def self.authority_version
    return @authority_version
  end

  def self.ensure_authoritative_data!
    return true if authority_ready?
    raise RuntimeError,
      "FS DB AutoSetup: MasterSetup Authority Data 未完成注入。請確認 FS_MasterSetup 00～18 的載入順序與 18 Apply。"
  end
  CATEGORY_MODULES = [
    "FS_DB_AUTOSET_SKILLS",
    "FS_DB_AUTOSET_STATES",
    "FS_DB_AUTOSET_ITEMS",
    "FS_DB_AUTOSET_WEAPONS",
    "FS_DB_AUTOSET_ARMORS",
    "FS_DB_AUTOSET_CLASS_LEARNINGS",
    "FS_DB_AUTOSET_ENEMIES",
    "FS_DB_AUTOSET_USER_EXTENSIONS"
  ]

  @current_category = "boot"
  @current_context = "none"
  @errors = []
  @applying = false
  @authoritative_notes = {}

  def self.context(category = nil, text = nil)
    @current_category = category.to_s unless category == nil
    @current_context = text.to_s unless text == nil
  end

  def self.current_context
    return "#{@current_category} / #{@current_context}"
  end

  def self.errors
    @errors = [] unless @errors.is_a?(Array)
    return @errors
  end

  PLACEHOLDER_MARKER = "# FS_AUTOSET_PLACEHOLDER"
  ALMANAC_OUT_TAG = "<Almanac out>"

  #--------------------------------------------------------------------------
  # ● 建立資料物件
  #   placeholder = true 時，代表它只是為了填補資料庫 ID 空洞。
  #--------------------------------------------------------------------------
  def self.build_record(klass, id, placeholder = false)
    obj = klass.new
    obj.id = id if obj.respond_to?(:id=)

    if placeholder
      obj.instance_variable_set(:@fs_autoset_placeholder, true)

      # 避免空白資料被舊物品圖鑑列入。
      if obj.respond_to?(:note) && obj.respond_to?(:note=)
        lines = obj.note.to_s.split(/[\r\n]+/)
        lines = [] unless lines.is_a?(Array)
        lines.push(ALMANAC_OUT_TAG) unless lines.any? { |line|
          line.to_s.strip =~ /^<\s*Almanac out\s*>$/i
        }
        lines.push(PLACEHOLDER_MARKER)
        obj.note = lines.join("\n")
      end

      # 空白 State 不應出現在狀態選單／狀態圖鑑。
      obj.priority = 0 if obj.respond_to?(:priority=)

      # 空白 Skill／Item 設為不可使用；名稱仍保持空白。
      obj.occasion = 3 if obj.respond_to?(:occasion=)
    end
    return obj
  end

  #--------------------------------------------------------------------------
  # ● 將先前的空白占位物件轉成正式受管資料
  #--------------------------------------------------------------------------
  def self.activate_record(obj)
    return obj if obj == nil
    return obj unless obj.instance_variable_get(:@fs_autoset_placeholder)

    obj.instance_variable_set(:@fs_autoset_placeholder, false)
    if obj.respond_to?(:note) && obj.respond_to?(:note=)
      lines = obj.note.to_s.split(/[\r\n]+/)
      lines = [] unless lines.is_a?(Array)
      lines.delete_if do |line|
        text = line.to_s.strip
        text == PLACEHOLDER_MARKER ||
          text =~ /^<\s*Almanac out\s*>$/i
      end
      obj.note = lines.join("\n")
    end
    invalidate_note_cache(obj)
    return obj
  end

  #--------------------------------------------------------------------------
  # ● 將 1...id 之間的 nil 補成空白資料物件
  #
  # RPG Maker VX 經由資料庫「變更最大條目數」建立高 ID 時，中間格會是
  # 真正的 RPG 資料物件；AutoSetup 舊版只 push(nil)，破壞了許多舊腳本
  # 「1...size 每格都不是 nil」的假設。
  #--------------------------------------------------------------------------
  def self.densify_group(group, id, klass)
    raise "database group is nil" if group == nil
    group.push(nil) while group.size <= id

    i = 1
    while i < id
      group[i] = build_record(klass, i, true) if group[i] == nil
      i += 1
    end
  end

  def self.ensure_record(group, id, klass)
    self.context(@current_category, "ensure #{klass} ID #{id}")
    densify_group(group, id, klass)

    if group[id] == nil
      group[id] = build_record(klass, id, false)
    else
      activate_record(group[id])
    end
    return group[id]
  end

  #--------------------------------------------------------------------------
  # ● 目前會被 AutoSetup 擴充的資料庫陣列
  #--------------------------------------------------------------------------
  def self.database_group_specs
    result = []
    result.push(["Skill",  $data_skills,  RPG::Skill])  if defined?($data_skills)  && $data_skills
    result.push(["State",  $data_states,  RPG::State])  if defined?($data_states)  && $data_states
    result.push(["Item",   $data_items,   RPG::Item])   if defined?($data_items)   && $data_items
    result.push(["Weapon", $data_weapons, RPG::Weapon]) if defined?($data_weapons) && $data_weapons
    result.push(["Armor",  $data_armors,  RPG::Armor])  if defined?($data_armors)  && $data_armors
    result.push(["Class",  $data_classes, RPG::Class])  if defined?($data_classes) && $data_classes
    result.push(["Enemy",  $data_enemies, RPG::Enemy])  if defined?($data_enemies) && $data_enemies
    return result
  end

  #--------------------------------------------------------------------------
  # ● 最終安全封口
  #   即使 UserExtensions 或其他分類腳本直接擴充了陣列，也不留下 nil。
  #--------------------------------------------------------------------------
  def self.seal_database_arrays
    database_group_specs.each do |spec|
      name, group, klass = spec
      next if group == nil
      self.context("database safety", "#{name} dense scan")

      i = 1
      while i < group.size
        group[i] = build_record(klass, i, true) if group[i] == nil
        i += 1
      end
    end
  end

  def self.database_holes
    result = []
    database_group_specs.each do |spec|
      name, group, klass = spec
      next if group == nil
      i = 1
      while i < group.size
        result.push([name, i]) if group[i] == nil
        i += 1
      end
    end
    return result
  end

  def self.placeholder_counts
    result = {}
    database_group_specs.each do |spec|
      name, group, klass = spec
      count = 0
      next if group == nil
      i = 1
      while i < group.size
        obj = group[i]
        count += 1 if obj != nil &&
          obj.instance_variable_get(:@fs_autoset_placeholder)
        i += 1
      end
      result[name] = count
    end
    return result
  end

  def self.set(obj, key, value)
    return if obj == nil
    object_id = obj.respond_to?(:id) ? obj.id : "?"
    self.context(@current_category, "#{obj.class} ID #{object_id} field #{key}")
    setter = (key.to_s + "=").to_sym
    obj.send(setter, value) if obj.respond_to?(setter)
  end

  #--------------------------------------------------------------------------
  # ● 腳本權威 Note
  #
  # 受管資料不再與資料庫舊 Note 合併。最終 Note 只由：
  # 1. 分類腳本 DATA 內的 Note
  # 2. 嚴格白名單的 SBS 視覺 Note
  # 組成。任何舊 JP、Scope、Target、State、AI、Steal、Combo 等標籤都不保留。
  #--------------------------------------------------------------------------
  VISUAL_NOTE_PATTERNS = {
    :skill => [
      /^<\s*(?:flygraphic|graphic)\s*:[^>]+>$/i
    ],
    :item => [
      /^<\s*(?:action|flygraphic|graphic)\s*:[^>]+>$/i
    ],
    :weapon => [
      /^<\s*(?:action|flygraphic|graphic)\s*:[^>]+>$/i
    ],
    :state => [
      /^<\s*action\s*:[^>]+>$/i
    ],
    :enemy => [
      /^<\s*(?:unarmed|standby|pinch|guard|hurt|evade|escape|start|interrupt|dead|shadow|weapon|collapse|idle|move|motion|anime|animation|damage|sbs)\s*:[^>]+>$/i,
      /^<\s*-?atb\s+gauge\s*>$/i
    ]
  }

  def self.normalize_note_text(text)
    lines = text.to_s.gsub("\r", "").split("\n")
    lines = [] unless lines.is_a?(Array)
    result = []
    lines.each do |line|
      value = line.to_s.rstrip
      next if value.strip.empty?
      result.push(value) unless result.include?(value)
    end
    return result.join("\n")
  end

  def self.visual_note_lines(obj, kind)
    return [] if obj == nil || !obj.respond_to?(:note)
    patterns = VISUAL_NOTE_PATTERNS[kind] || []
    result = []
    obj.note.to_s.split(/[\r\n]+/).each do |line|
      value = line.to_s.strip
      next if value.empty?
      keep = patterns.any? { |pattern| value =~ pattern }
      result.push(value) if keep && !result.include?(value)
    end
    return result
  end

  def self.replace_note(obj, category, id, managed, visual_lines = [])
    return if obj == nil || !obj.respond_to?(:note) || !obj.respond_to?(:note=)
    self.context(category, "#{obj.class} ID #{id} authoritative note")
    visuals = visual_lines.is_a?(Array) ? visual_lines : []
    text = normalize_note_text((visuals + [managed.to_s]).join("\n"))
    obj.note = text
    @authoritative_notes[[category.to_s, id.to_i]] = text
    invalidate_note_cache(obj)
  end

  def self.authoritative_note_mismatches
    result = []
    @authoritative_notes.each do |key, expected|
      category, id = key
      group = case category
              when "skill" then $data_skills
              when "state" then $data_states
              when "item" then $data_items
              when "weapon" then $data_weapons
              when "armor" then $data_armors
              when "enemy" then $data_enemies
              else nil
              end
      next if group == nil || group[id] == nil
      actual = normalize_note_text(group[id].note.to_s)
      result.push([category, id]) if actual != expected
    end
    return result
  end

  # 舊 API 僅留給未轉換的 UserExtensions。正式 01～08 不再使用。
  def self.note_tag_key(line)
    text = line.to_s.strip
    return nil unless text =~ /^<\s*(.*?)\s*>$/
    body = $1.to_s.downcase.strip
    return "passive_skill" if body == "passive_skill" || body == "/passive_skill"
    return body.split(":", 2)[0].strip if body.include?(":")
    words = body.split(/\s+/)
    while words.size > 1 && words[-1] =~ /^[\+\-]?\d/
      words.pop
    end
    return words.join(" ")
  end

  def self.remove_old_block(text, category, id)
    pat = /(?:\r?\n)?# FS_AUTOSET_BEGIN #{category} #{id}\r?\n.*?# FS_AUTOSET_END #{category} #{id}(?:\r?\n)?/m
    return text.to_s.gsub(pat, "\n")
  end

  def self.merge_note(obj, category, id, managed)
    return if obj == nil || !obj.respond_to?(:note) || !obj.respond_to?(:note=)
    self.context(category, "#{obj.class} ID #{id} note")
    old = remove_old_block(obj.note.to_s, category, id)
    managed = managed.to_s.gsub("\r", "")
    keys = []
    lines = managed.split("\n")
    lines = [] unless lines.is_a?(Array)
    lines.each do |line|
      key = note_tag_key(line)
      keys.push(key) if key != nil && !keys.include?(key)
    end
    old = old.gsub(/<PASSIVE_SKILL>.*?<\/PASSIVE_SKILL>/im, "") if keys.include?("passive_skill")

    kept = []
    old_lines = old.split(/[\r\n]+/)
    old_lines = [] unless old_lines.is_a?(Array)
    old_lines.each do |line|
      key = note_tag_key(line)
      next if key != nil && keys.include?(key)
      kept.push(line)
    end
    kept.delete_if { |line| line.to_s.strip.empty? }

    block = ["# FS_AUTOSET_BEGIN #{category} #{id}"]
    lines.each { |line| block.push(line) unless line.to_s.empty? }
    block.push("# FS_AUTOSET_END #{category} #{id}")
    obj.note = (kept + block).join("\n")
    invalidate_note_cache(obj)
  end

  NOTE_CACHE_VARIABLES = [
    "@passive",
    "@field_effect",
    "@remove_field_effect",
    "@fs_field_weather_data",
    "@action_key",
    "@extensions",
    "@everybody",
    "@phoenix",
    "@targetallfoe",
    "@targetrandomfoe",
    "@randomfoe",
    "@multifoe",
    "@allbutuser",
    "@targetallally",
    "@targetrandomally",
    "@randomally",
    "@multially",
    "@pickcustom",
    "@parsed_note",
    "@charge_values",
    "@recharge_value",
    "@charge_bonus",
    "@atb_base"
  ]

  def self.invalidate_note_cache(obj)
    return if obj == nil
    variables = obj.instance_variables
    variables = [] unless variables.is_a?(Array)
    variables.each do |ivar|
      name = ivar.to_s
      if name =~ /^@cached/ || name =~ /^@__.*cache/ ||
         NOTE_CACHE_VARIABLES.include?(name)
        begin
          obj.instance_variable_set(ivar, nil)
        rescue
        end
      end
    end
  end

  def self.write_error_report(category, error)
    lines = []
    lines.push("FS DB AutoSetup v#{VERSION} ERROR")
    lines.push("Category: #{category}")
    lines.push("Context: #{current_context}")
    lines.push("Error: #{error.class}: #{error.message}")
    backtrace = error.backtrace
    backtrace = $@ if backtrace == nil
    backtrace = [] unless backtrace.is_a?(Array)
    backtrace.each { |line| lines.push(line.to_s) }
    errors.push(lines.join("\n"))
    begin
      File.open("FS_DB_AutoSetup_Error.txt", "wb") do |file|
        file.write(lines.join("\r\n"))
      end
    rescue
    end
  end

  def self.apply_category(name)
    return unless Object.const_defined?(name)
    mod = Object.const_get(name)
    return unless mod.respond_to?(:apply)
    self.context(name, "start")
    begin
      mod.apply
      self.context(name, "done")
    rescue Exception => error
      write_error_report(name, error)
      raise RuntimeError,
        "FS DB AutoSetup failed: #{name} / #{current_context} / #{error.message}"
    end
  end

  def self.apply_all
    ensure_authoritative_data!
    return if @applying
    @applying = true
    begin
      modules = CATEGORY_MODULES
      modules = [] unless modules.is_a?(Array)
      modules.each { |name| apply_category(name) }
      seal_database_arrays
      $fs_db_autoset_version = VERSION
    ensure
      @applying = false
    end
  end
end

class Scene_Title < Scene_Base
  alias fs_db_autoset_load_database load_database unless method_defined?(:fs_db_autoset_load_database)
  def load_database
    fs_db_autoset_load_database
    FS_DB_AUTOSET.apply_all
  end

  alias fs_db_autoset_load_bt_database load_bt_database unless method_defined?(:fs_db_autoset_load_bt_database)
  def load_bt_database
    fs_db_autoset_load_bt_database
    FS_DB_AUTOSET.apply_all
  end
end
