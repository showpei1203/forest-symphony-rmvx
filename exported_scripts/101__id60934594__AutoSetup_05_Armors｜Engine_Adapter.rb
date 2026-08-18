#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：AutoSetup_05_Armors
# 【用途】AutoSetup Armors 的 Engine Adapter；負責把已注入的 MasterSetup Authority Data 套入 RPG Maker VX 資料庫，不再保存第二份正式資料表。
# 【主要機制】本專案 MasterSetup 會在後方覆寫／補齊正式資料；AutoSetup 各頁順序不可任意交換。
# 【主要影響】FS_DB_AUTOSET_ARMORS
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
# ■ FS_DB_AutoSetup_05_Armors v1.4.0
#------------------------------------------------------------------------------
# 設定 Armor 220～333，明確跳過 Armor 600～665。
# 220～295：<equip type: 特殊>，kind 5。
# 296～315：<equip type: 身體>，kind 2。
# 316～333：<equip type: 飾品>，kind 4。
# 同時建立 Sword4 Armor 220～285 的素材配方。
#==============================================================================
module FS_DB_AUTOSET_ARMORS
  DATA = {}
  UNTOUCHED_SOUL_RANGE = (0..-1)


  #--------------------------------------------------------------------------
  # ● 突擊束甲 ATK 尺度修正
  #--------------------------------------------------------------------------
  # 舊值 45／100／180／280／400 是早期傷害尺度遺留。
  # 新值與同階 DEF 對齊：8／18／30／46／64。
  #--------------------------------------------------------------------------
  BALANCE_OVERRIDES = {}

  def self.apply_balance_overrides
    BALANCE_OVERRIDES.each do |id, values|
      next unless DATA.has_key?(id)
      values.each { |key, value| DATA[id][key] = value }
    end
  end

  def self.apply
    apply_balance_overrides
    keys = DATA.keys
    keys = [] unless keys.is_a?(Array)
    keys.sort.each do |id|
      next if UNTOUCHED_SOUL_RANGE.include?(id)
      data = DATA[id]
      data = {} unless data.is_a?(Hash)
      FS_DB_AUTOSET.context("armors", "Armor ID #{id}")
      armor = FS_DB_AUTOSET.ensure_record($data_armors, id, RPG::Armor)
      data.each do |key, value|
        next if [:note, :recipe_item, :recipe_qty].include?(key)
        FS_DB_AUTOSET.set(armor, key, value)
      end
      FS_DB_AUTOSET.replace_note(armor, "armor", id, data[:note])
      if data[:recipe_item] && defined?(Sword4_Synthesize)
        Sword4_Synthesize[2] = {} if Sword4_Synthesize[2] == nil
        Sword4_Synthesize[2][id] = [
          {data[:recipe_item] => data[:recipe_qty]}, {}, {}, 100]
      end
    end
  end
end
