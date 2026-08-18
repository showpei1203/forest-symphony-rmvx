#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：AutoSetup_02_States
# 【用途】AutoSetup States 的 Engine Adapter；負責把已注入的 MasterSetup Authority Data 套入 RPG Maker VX 資料庫，不再保存第二份正式資料表。
# 【主要機制】本專案 MasterSetup 會在後方覆寫／補齊正式資料；AutoSetup 各頁順序不可任意交換。
# 【主要影響】FS_DB_AUTOSET_STATES
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
# ■ FS_DB_AutoSetup_02_States v1.3.6
#------------------------------------------------------------------------------
# 設定手冊列出的 State。State 2、3、36 完全保留現有資料。
# State 1 只校正核心數值，保留原名、Icon、訊息與 Note。
# MAXHP／MAXMP 倍率改用現有 YEZ Custom Status Properties Note。
#==============================================================================
module FS_DB_AUTOSET_STATES
  DATA = {}
  PRESERVE_IDS = []

  def self.apply
    keys = DATA.keys
    keys = [] unless keys.is_a?(Array)
    keys.sort.each do |id|
      data = DATA[id]
      data = {} unless data.is_a?(Hash)
      FS_DB_AUTOSET.context("states", "State ID #{id}")
      state = FS_DB_AUTOSET.ensure_record($data_states, id, RPG::State)
      data.each do |key, value|
        next if key == :note || value == nil
        FS_DB_AUTOSET.set(state, key, value)
      end
      if data.has_key?(:note)
        visual = FS_DB_AUTOSET.visual_note_lines(state, :state)
        FS_DB_AUTOSET.replace_note(state, "state", id, data[:note], visual)
      end
    end
  end
end
