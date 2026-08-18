#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：AutoSetup_90_UserExtensions
# 【用途】AutoSetup 使用者擴充 Hook。只放「套用時的額外操作」，不要在此建立第二份正式 MasterSetup Data。
# 【主要機制】本專案 MasterSetup 會在後方覆寫／補齊正式資料；AutoSetup 各頁順序不可任意交換。
# 【主要影響】FS_DB_AUTOSET_USER_EXTENSIONS
# 【設定／可調參數】可在 self.apply 內對已由 MasterSetup 注入的 AutoSetup DATA 做專案外擴充；Forest Symphony 正式資料仍應回到 FS_MasterSetup 維護。
# 【依賴／載入順序】本頁是 CATEGORY_MODULES 的最後使用者 Hook；Scene_Title 真正 apply_all 時，MasterSetup Authority 已完成注入，因此這裡看到的是正式資料。
# 【呼叫方式／範例】範例：item = FS_DB_AUTOSET.ensure_record($data_items, 800, RPG::Item)；FS_DB_AUTOSET.set(item, :name, "自訂素材")。正式 FS 內容不要用此頁取代 MasterSetup。
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
# ■ FS_DB_AutoSetup_90_UserExtensions v1.3
#------------------------------------------------------------------------------
# 選用。放在 08_Enemies 之後、所有原始自訂腳本之前。
# 不在 01～08 管理範圍內的資料，也可以直接在資料庫新增。
#==============================================================================
module FS_DB_AUTOSET_USER_EXTENSIONS
  def self.apply
    # 例：
    # item = FS_DB_AUTOSET.ensure_record($data_items, 800, RPG::Item)
    # FS_DB_AUTOSET.set(item, :name, "自訂素材")
    # FS_DB_AUTOSET.merge_note(item, "user_item", 800, "<pick item>")
  end
end
