#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_SaveCompatibilityTest v1.0
# 【用途】Forest Symphony 相容／修正頁「FS_SaveCompatibilityTest v1.0」，針對既有系統補正專案需要的行為。
# 【主要機制】通常透過 alias／class reopen 包裝前方實作；它不是可任意搬動的獨立功能，需維持在被修正腳本之後。
# 【主要影響】FS_SAVE_COMPAT_TEST
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：REPORT_FILE、CORE_OBJECT_COUNT。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】登記 $imported：FS Save Compatibility Test、FS Save Compatibility Core；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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
# ■ FS_SaveCompatibilityTest v1.0
#------------------------------------------------------------------------------
# 手動執行的統一存檔相容測試。平時不自動執行。
#
# 安裝位置：
#   FS_SaveCompatibilityCore v1.0
#   本腳本
#   Main
#
# 使用方式（事件腳本）：
#   FS_SAVE_COMPAT_TEST.run
#
# 會建立：
#   FS_SaveCompatibilityReport.txt
#
# 測試內容：
#   1. Scene_Title#create_game_objects 核心物件狀態。
#   2. 搜尋 Neo Save 的所有存檔欄位。
#   3. 確認核心 14 個 Marshal 物件可讀。
#   4. 判斷新版單一 Hash 尾端、舊 Fog／Self Variable／ATS 尾端。
#   5. 找出舊 Self Variable 誤存 Game_Player 的存檔。
#   6. 確認 ATS、Fog、Self Variable 是否存在。
#
# 注意：本測試只讀取，不改寫任何存檔。
#==============================================================================

$imported = {} if $imported == nil
$imported["FS Save Compatibility Test"] = 1.00

module FS_SAVE_COMPAT_TEST
  REPORT_FILE = "FS_SaveCompatibilityReport.txt"
  CORE_OBJECT_COUNT = 14

  def self.save_files
    if defined?(Wora_NSS)
      pattern = Wora_NSS::SAVE_PATH.to_s +
                Wora_NSS::SAVE_FILE_NAME.to_s.gsub(/\{ID\}/i, "*")
      return Dir.glob(pattern).sort
    end
    return Dir.glob("Save*.rvdata").sort
  end

  def self.class_name(object)
    return "nil" if object == nil
    return object.class.to_s
  rescue
    return "unknown"
  end

  def self.runtime_lines
    lines = []
    lines << "[Runtime object audit]"
    if defined?(FS_SAVE_COMPAT)
      missing = FS_SAVE_COMPAT.audit_runtime_objects(:manual_test)
      lines << (missing.empty? ? "OK" : "Recovered/Missing: #{missing.join(', ')}")
    else
      lines << "ERROR: FS_SaveCompatibilityCore is not installed."
    end

    globals = [
      ["$game_system", $game_system],
      ["$game_message", $game_message],
      ["$game_actors", $game_actors],
      ["$game_party", $game_party],
      ["$game_map", $game_map],
      ["$game_player", $game_player],
      ["$fog_data", $fog_data],
      ["$fog_transition", $fog_transition],
      ["$self_var", $self_var],
      ["$game_ats", $game_ats],
      ["$game_condition_members", $game_condition_members],
      ["$riding_data", $riding_data],
      ["$game_parapassa", $game_parapassa],
      ["$game_ring_cm", $game_ring_cm]
    ]
    globals.each do |name, object|
      lines << sprintf("%-28s %s", name, class_name(object))
    end
    lines << ""
    return lines
  end

  def self.read_all_marshaled(file_name)
    objects = []
    File.open(file_name, "rb") do |file|
      loop do
        begin
          objects << Marshal.load(file)
        rescue EOFError
          break
        end
      end
    end
    return objects
  end

  def self.analyze_file(file_name)
    lines = []
    lines << "[Save] #{file_name}"
    begin
      objects = read_all_marshaled(file_name)
      lines << "Marshal object count: #{objects.size}"
      if objects.size < CORE_OBJECT_COUNT
        lines << "ERROR: core data is incomplete. Expected at least #{CORE_OBJECT_COUNT}."
        lines << ""
        return lines
      end

      core = objects[0, CORE_OBJECT_COUNT]
      tail = objects[CORE_OBJECT_COUNT, objects.size - CORE_OBJECT_COUNT] || []
      lines << "Core classes: " + core.collect { |obj| class_name(obj) }.join(" / ")
      lines << "Tail count: #{tail.size}"
      lines << "Tail classes: " + (tail.empty? ? "none" : tail.collect { |obj| class_name(obj) }.join(" / "))

      new_payload = nil
      tail.each do |object|
        if object.is_a?(Hash) &&
           object[:fs_save_magic] == FS_SAVE_COMPAT::MAGIC
          new_payload = object
          break
        end
      end

      if new_payload
        lines << "Format: NEW unified extension"
        lines << "Extension version: #{new_payload[:fs_save_version]}"
        lines << "Fog: #{class_name(new_payload[:fog_data])}"
        lines << "Self Variable: #{class_name(new_payload[:self_variables])}"
        lines << "ATS: #{class_name(new_payload[:game_ats])}"
      else
        lines << "Format: LEGACY or base-only"
        if tail.empty?
          lines << "WARN: no extension data. Fog/Self Variable/ATS will use defaults."
        end

        has_fog = tail.size >= 2 && tail[0].is_a?(Hash) && tail[1].is_a?(Numeric)
        has_self = false
        has_ats = false
        duplicate_player = false
        tail.each do |object|
          has_self = true if defined?(Game_SelfVariables) && object.is_a?(Game_SelfVariables)
          has_ats = true if defined?(Game_ATS) && object.is_a?(Game_ATS)
          duplicate_player = true if defined?(Game_Player) && object.is_a?(Game_Player)
        end
        lines << "Legacy Fog pair: #{has_fog ? 'YES' : 'NO'}"
        lines << "Legacy Self Variable: #{has_self ? 'YES' : 'NO'}"
        lines << "Legacy ATS: #{has_ats ? 'YES' : 'NO'}"
        if duplicate_player
          lines << "WARN: duplicated Game_Player found. This is the original Z-Systems Self Variable save bug."
        end
        unless has_self
          lines << "WARN: Self Variables were not preserved in this save."
        end
        unless has_ats
          lines << "WARN: ATS permanent settings were not preserved in this save."
        end
      end
    rescue Exception => error
      lines << "ERROR: #{error.class}: #{error.message}"
    end
    lines << ""
    return lines
  end

  def self.run
    lines = []
    lines << "Forest Symphony Save Compatibility Report"
    lines << "Generated: #{Time.now}"
    lines << "Core patch: " + ($imported["FS Save Compatibility Core"] ? "installed" : "missing")
    lines << ""
    lines.concat(runtime_lines)

    files = save_files
    if files.empty?
      lines << "No save files found."
      lines << "Create at least one save, then run this test again."
    else
      files.each { |file_name| lines.concat(analyze_file(file_name)) }
    end

    File.open(REPORT_FILE, "wb") do |file|
      file.write(lines.join("\r\n"))
    end
    p "Save compatibility test complete: #{REPORT_FILE}"
    return lines
  rescue Exception => error
    p "Save compatibility test failed: #{error.class}: #{error.message}"
    return []
  end
end
