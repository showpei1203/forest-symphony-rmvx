#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_SaveCompatibilityCore v1.1a
# 【用途】Forest Symphony 相容／修正頁「FS_SaveCompatibilityCore v1.1a」，針對既有系統補正專案需要的行為。
# 【主要機制】統一 Save Extension、舊存檔相容與 Runtime object audit；Phase 29 起在新遊戲及每次讀檔後都執行 ArmorMapping normalization，確保舊 Mapping 真正完成遷移。
# 【主要影響】Scene_File、Scene_Title、Game_Battler、FS_SAVE_COMPAT
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：MAGIC、LOG_FILE。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 6 個 alias／方法包裝，載入順序具有語意；登記 $imported：FS Save Compatibility Core；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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
# ■ FS_SaveCompatibilityCore v1.1a
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2
#
# 安裝位置：
#   Neo Save System V（請換成 FS 修正版）
#   ATS 3.0
#   Z-Systems Self Variable
#   FS_LegacyScripts_SafetyPatch v1.0.14
#   FS_ATS_DialogueExtension v1.7
#   本腳本
#   Main
#
# 功能：
#   1. 統一存檔附加資料為一個有版本標記的 Hash。
#   2. 相容既有 Fog／Self Variable／ATS 舊存檔尾端資料。
#   3. 修正 Z-Systems Self Variable 原腳本誤存 $game_player 的問題。
#   4. 修正 Legacy Safety Patch 最終 read_save_data 繞過 ATS／Self Variable。
#   5. 舊存檔缺少 ATS 時安全建立 Game_ATS。
#   6. Scene_Title#create_game_objects 完成後做核心物件稽核。
#   7. 修正 <jp growth +n> 點卡偶發加到錯誤 Class JP 桶或未生效。
#   8. Phase 29：新遊戲與每次讀檔都正規化 ArmorMapping，移除仍完全吻合的
#      101/103/105 與 732～741 歷史 Mapping，再補入 CompactID 286～295。
#==============================================================================

$imported = {} if $imported == nil
$imported["FS Save Compatibility Core"] = 1.11

module FS_SAVE_COMPAT
  VERSION = 1
  MAGIC   = "FS_SAVE_EXTENSION_V1"
  LOG_FILE = "FS_SaveCompatibility.log"

  #--------------------------------------------------------------------------
  # ● 安全紀錄
  #--------------------------------------------------------------------------
  def self.log(text)
    return unless $TEST
    begin
      File.open(LOG_FILE, "a") { |file| file.write(text.to_s + "\n") }
    rescue
    end
  end

  #--------------------------------------------------------------------------
  # ● 安全呼叫
  #--------------------------------------------------------------------------
  # 僅用於相容／稽核路徑：區塊成功時回傳結果；若舊存檔物件或第三方
  # 擴充在讀取時發生例外，記錄 TEST log 並回傳指定預設值，避免相容性
  # 稽核本身反過來讓新遊戲／讀檔崩潰。
  def self.safe_call(default = nil)
    begin
      return yield
    rescue Exception => error
      log("safe_call failed: #{error.class}: #{error.message}")
      return default
    end
  end

  #--------------------------------------------------------------------------
  # ● 預設 Fog
  #--------------------------------------------------------------------------
  def self.default_fog_data
    if defined?(FS_LEGACY_SAFE) &&
       FS_LEGACY_SAFE.respond_to?(:default_fog_data)
      return FS_LEGACY_SAFE.default_fog_data
    end
    return { 1 => ["fog", -5, -5, 128, 2] }
  end

  #--------------------------------------------------------------------------
  # ● 建立缺少的附加物件
  #--------------------------------------------------------------------------
  def self.ensure_extension_objects
    $fog_data = default_fog_data if $fog_data == nil
    $fog_transition = 0 if $fog_transition == nil

    if defined?(Game_SelfVariables) && $self_var == nil
      $self_var = Game_SelfVariables.new
    end

    if defined?(Game_ATS) && $game_ats == nil
      $game_ats = Game_ATS.new
    end
    $ats_default = $game_ats if defined?(Game_ATS) && $ats_default == nil
  end

  #--------------------------------------------------------------------------
  # ● 建立新版附加資料
  #--------------------------------------------------------------------------
  def self.make_payload
    ensure_extension_objects
    return {
      :fs_save_magic  => MAGIC,
      :fs_save_version => VERSION,
      :fog_data       => $fog_data,
      :fog_transition => $fog_transition,
      :self_variables => $self_var,
      :game_ats       => $game_ats
    }
  end

  #--------------------------------------------------------------------------
  # ● 套用新版附加資料
  #--------------------------------------------------------------------------
  def self.apply_payload(payload)
    return false unless payload.is_a?(Hash)
    return false unless payload[:fs_save_magic] == MAGIC

    $fog_data = payload[:fog_data]
    $fog_transition = payload[:fog_transition]
    $self_var = payload[:self_variables] if defined?(Game_SelfVariables)
    if defined?(Game_ATS)
      $game_ats = payload[:game_ats]
      $ats_default = $game_ats
    end
    ensure_extension_objects
    return true
  end

  #--------------------------------------------------------------------------
  # ● 讀取檔尾所有 Marshal 物件
  #--------------------------------------------------------------------------
  def self.read_tail_objects(file)
    result = []
    loop do
      begin
        result << Marshal.load(file)
      rescue EOFError
        break
      end
    end
    return result
  end

  #--------------------------------------------------------------------------
  # ● 舊格式辨識
  #--------------------------------------------------------------------------
  def self.apply_legacy_tail(objects)
    ensure_extension_objects
    return if objects == nil || objects.empty?

    # Advanced Fog 舊格式固定為前兩項。
    if objects[0].is_a?(Hash)
      $fog_data = objects[0]
    end
    if objects.size >= 2 && objects[1].is_a?(Numeric)
      $fog_transition = objects[1]
    end

    objects.each do |object|
      next if object == nil
      if defined?(Game_SelfVariables) && object.is_a?(Game_SelfVariables)
        $self_var = object
      elsif defined?(Game_ATS) && object.is_a?(Game_ATS)
        $game_ats = object
        $ats_default = object
      elsif defined?(Game_Player) && object.is_a?(Game_Player)
        # Z-Systems Self Variable v1.01 的原始 Bug：
        # write_save_data 寫入 $game_player，read_save_data 卻當成 $self_var。
        # 這個重複 Game_Player 只忽略，不能覆蓋真正 $game_player。
        log("Legacy tail: ignored duplicated Game_Player from Self Variable bug.")
      end
    end

    ensure_extension_objects
  end

  #--------------------------------------------------------------------------
  # ● 讀取新版或舊版附加資料
  #--------------------------------------------------------------------------
  def self.read_extension(file)
    objects = read_tail_objects(file)
    if objects.size == 1 && apply_payload(objects[0])
      return :new
    end

    # 某些過渡版本可能在舊尾端之後又附加新版 Hash。
    objects.reverse_each do |object|
      if apply_payload(object)
        return :mixed
      end
    end

    apply_legacy_tail(objects)
    return objects.empty? ? :base_only : :legacy
  rescue Exception => error
    log("read_extension failed: #{error.class}: #{error.message}")
    ensure_extension_objects
    return :recovered
  end

  #--------------------------------------------------------------------------
  # ● 新遊戲／讀檔後全域物件稽核
  #--------------------------------------------------------------------------
  def self.audit_runtime_objects(source = :unknown)
    ensure_extension_objects
    missing = []

    core_objects = {
      "$game_temp"          => $game_temp,
      "$game_message"       => $game_message,
      "$game_system"        => $game_system,
      "$game_switches"      => $game_switches,
      "$game_variables"     => $game_variables,
      "$game_self_switches" => $game_self_switches,
      "$game_actors"        => $game_actors,
      "$game_party"         => $game_party,
      "$game_troop"         => $game_troop,
      "$game_map"           => $game_map,
      "$game_player"        => $game_player
    }
    core_objects.each { |name, object| missing << name if object == nil }

    if defined?(Game_Condition_Members) && $game_condition_members == nil
      $game_condition_members = Game_Condition_Members.new
      missing << "$game_condition_members(rebuilt)"
    end
    if defined?(Riding_Data) && $riding_data == nil
      $riding_data = Riding_Data.new
      missing << "$riding_data(rebuilt)"
    end
    if defined?(ISS::ParaPassa::Parallax_Passages) && $game_parapassa == nil
      $game_parapassa = ISS::ParaPassa::Parallax_Passages.new
      missing << "$game_parapassa(rebuilt)"
    end

    # Ring Menu 的陣列由原腳本在 create_game_objects 建立。
    # 稽核失敗時先給空陣列避免 nil 崩潰，同時留下報告。
    if defined?(Scene_RM2) && $game_ring_cm == nil
      $game_ring_cm = []
      missing << "$game_ring_cm(rebuilt empty)"
    end
    if defined?(Scene_RM) && $game_ring_menu == nil
      $game_ring_menu = []
      missing << "$game_ring_menu(rebuilt empty)"
    end

    # Phase 29：ArmorMapping normalization 必須在讀檔後也執行。
    # 舊版只在 mapping == nil 時 rebuild，會讓非 nil 的 101/103/105 或
    # 732～741 歷史 Mapping 永久跟著舊存檔。rebuild 本身只移除值仍完全
    # 吻合歷史資料的 key，因此不會誤刪玩家／其他系統已改寫的自訂值。
    if defined?(ForestSymphonyDB) &&
       ForestSymphonyDB.respond_to?(:rebuild_armor_mapping) &&
       $game_system != nil &&
       $game_system.respond_to?(:armor_mapping)
      before_mapping = nil
      begin
        before_mapping = $game_system.armor_mapping == nil ? nil :
                         $game_system.armor_mapping.dup
      rescue
        before_mapping = nil
      end
      if ForestSymphonyDB.rebuild_armor_mapping
        after_mapping = FS_SAVE_COMPAT.safe_call(nil) { $game_system.armor_mapping.dup }
        if before_mapping != after_mapping
          label = before_mapping == nil ? "armor_mapping(rebuilt)" :
                                          "armor_mapping(normalized)"
          missing << label
        end
      end
    end

    if missing.empty?
      log("Runtime audit #{source}: OK")
    else
      log("Runtime audit #{source}: #{missing.join(', ')}")
    end
    return missing
  end

  #--------------------------------------------------------------------------
  # ● JP 點卡應寫入的 Class ID
  #--------------------------------------------------------------------------
  def self.jp_target_class_id(actor)
    return 0 if actor == nil
    if defined?(ALBERT_SUMMON_SKILL_LEVEL_UI) &&
       ALBERT_SUMMON_SKILL_LEVEL_UI.respond_to?(:jp_class_id)
      class_id = ALBERT_SUMMON_SKILL_LEVEL_UI.jp_class_id(actor).to_i
      return class_id if class_id > 0
    end
    return actor.class_id.to_i if actor.respond_to?(:class_id)
    return 0
  end
end

#==============================================================================
# ■ Scene_File：統一存檔格式
#==============================================================================

if defined?(Scene_File)
  class Scene_File < Scene_Base
    # Advanced Fog 建立的 shuu_fog_write/read 指向原始 Scene_File 核心格式，
    # 正好可避開後續舊式尾端追加鏈。
    unless method_defined?(:fs_save_compat_core_write)
      if method_defined?(:shuu_fog_write)
        alias fs_save_compat_core_write shuu_fog_write
      else
        alias fs_save_compat_core_write write_save_data
      end
    end

    unless method_defined?(:fs_save_compat_core_read)
      if method_defined?(:shuu_fog_read)
        alias fs_save_compat_core_read shuu_fog_read
      else
        alias fs_save_compat_core_read read_save_data
      end
    end

    def write_save_data(file)
      fs_save_compat_core_write(file)
      Marshal.dump(FS_SAVE_COMPAT.make_payload, file)
    end

    def read_save_data(file)
      fs_save_compat_core_read(file)
      format = FS_SAVE_COMPAT.read_extension(file)

      # KGC Passive Skill 原本只在 read_save_data 後做重建；
      # 統一讀檔後仍需保留這一步。
      if defined?(KGC::Commands) &&
         KGC::Commands.respond_to?(:restore_passive_rev)
        KGC::Commands.restore_passive_rev
      end
      Graphics.frame_reset
      FS_SAVE_COMPAT.audit_runtime_objects("load/#{format}")
    end
  end
end

#==============================================================================
# ■ Scene_Title：create_game_objects 最終稽核
#==============================================================================

if defined?(Scene_Title) && Scene_Title.method_defined?(:create_game_objects)
  class Scene_Title < Scene_Base
    unless method_defined?(:fs_save_compat_create_game_objects)
      alias fs_save_compat_create_game_objects create_game_objects
    end

    def create_game_objects
      fs_save_compat_create_game_objects
      FS_SAVE_COMPAT.audit_runtime_objects(:new_game)
    end
  end
end

#==============================================================================
# ■ JP 點卡可靠性修正
#------------------------------------------------------------------------------
# 原 YEZ Job System 會在 item_growth_effect 直接呼叫 gain_jp。
# 本補丁在最終 item_effect 外層暫時把 @jp_growth 設為 0，讓舊鏈不加 JP，
# 然後只對 UI 真正使用的 Class JP 桶加一次，避免隱藏桶或重複增加。
#==============================================================================

if defined?(Game_Battler) && Game_Battler.method_defined?(:item_effect)
  class Game_Battler
    attr_reader :fs_last_jp_card_gain

    unless method_defined?(:fs_save_compat_item_effect)
      alias fs_save_compat_item_effect item_effect
    end

    def item_effect(user, item)
      growth = 0
      if item != nil && item.respond_to?(:jp_growth)
        growth = item.jp_growth.to_i
      end
      return fs_save_compat_item_effect(user, item) if growth == 0 || !actor?

      class_id = FS_SAVE_COMPAT.jp_target_class_id(self)
      old_growth = item.instance_variable_get(:@jp_growth)
      had_growth = item.instance_variable_defined?(:@jp_growth)
      item.instance_variable_set(:@jp_growth, 0)

      result = nil
      begin
        result = fs_save_compat_item_effect(user, item)
      ensure
        if had_growth
          item.instance_variable_set(:@jp_growth, old_growth)
        else
          item.remove_instance_variable(:@jp_growth) rescue nil
        end
      end

      @fs_last_jp_card_gain = 0
      unless @skipped || @missed || @evaded || class_id <= 0
        before = class_jp[class_id].to_i
        gain_jp(growth, class_id)
        after = class_jp[class_id].to_i
        @fs_last_jp_card_gain = after - before
      end
      return result
    end
  end
end
