#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：ErrorLogger
# 【用途】保留的 Runtime 元件「ErrorLogger」。
# 【主要機制】主要定義／擴充 RPG::BaseItem、ErrorLogger、DebugLogger；下方原始說明與程式碼保留作細節依據。
# 【主要影響】RPG::BaseItem、ErrorLogger、DebugLogger
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：LOG_FILE、DEBUG_FILE。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】保持目前已驗證的相對順序；搬動前先反查 class reopen／alias／事件入口。
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
#===============================================================================
# 整合腳本 - 技能、裝備設定、戰鬥相關
# 來源: 技能與裝備設定相關腳本, 戰鬥用腳本, 戰鬥創意相關腳本
# 重複部分已刪除，確保相容性
#===============================================================================

module ErrorLogger
  LOG_FILE = "error_log.txt"
  
  def self.log(error, context = "")
    File.open(LOG_FILE, "a") do |file|
      file.puts "========================================"
      file.puts "[#{Time.now}] ERROR: #{error.message}"
      file.puts "Context: #{context}"
      file.puts error.backtrace.join("\n")
      file.puts "========================================"
    end
  end
end

#===============================================================================
# RPG BaseItem - 擴展技能與裝備設定
#===============================================================================

class RPG::BaseItem
  def yanfly_cache_cts 
    @everybody = false; @phoenix = false; @targetallfoe = false
    @targetrandomfoe = 0; @randomfoe = 0; @multifoe = 0; @allbutuser = false
    @targetallally = false; @targetrandomally = 0; @randomally = 0
    @multially = 0; @pickcustom = 0
    
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when /<(?:EVERYBODY|every body)>/i
        @everybody = true
      when /<(?:PHOENIX|fenix)>/i
        @phoenix = true
      when /<(?:TARGETALLFOE|target all foe)>/i
        @targetallfoe = true
      when /<(?:TARGETRANDOMFOE|target random foe)\s*(\d+)>/i
        @targetrandomfoe = $1.to_i
      when /<(?:RANDOMFOE|random foe)\s*(\d+)>/i
        @randomfoe = $1.to_i
      when /<(?:MULTI_FOE|multi foe|multifoe)\s*(\d+)>/i
        @multifoe = $1.to_i
      when /<(?:ALLBUTUSER|all but user)>/i
        @allbutuser = true
      when /<(?:TARGETALLALLY|target all ally)>/i
        @targetallally = true
      when /<(?:TARGETRANDOMALLY|target random ally)\s*(\d+)>/i
        @targetrandomally = $1.to_i
      when /<(?:RANDOMALLY|random ally)\s*(\d+)>/i
        @randomally = $1.to_i
      when /<(?:MULTI_ALLY|multially|multi ally)\s*(\d+)>/i
        @multially = $1.to_i
      when /<(?:PICK_CUSTOM|pick custom)\s*(\d+)>/i
        @pickcustom = $1.to_i
      end
    }
  end 
end



module DebugLogger
  DEBUG_FILE = "debug_log.txt"
  
  def self.print(message)
    File.open(DEBUG_FILE, "a") do |file|
      file.puts "[#{Time.now}] DEBUG: #{message}"
    end
  end
end