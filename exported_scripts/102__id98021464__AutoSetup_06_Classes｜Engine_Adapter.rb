#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：AutoSetup_06_ClassLearnings
# 【用途】AutoSetup ClassLearnings 的 Engine Adapter；負責把已注入的 MasterSetup Authority Data 套入 RPG Maker VX 資料庫，不再保存第二份正式資料表。
# 【主要機制】本專案 MasterSetup 會在後方覆寫／補齊正式資料；AutoSetup 各頁順序不可任意交換。
# 【主要影響】FS_DB_AUTOSET_CLASS_LEARNINGS
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
# ■ FS_DB_AutoSetup_06_ClassLearnings v1.3.3
#------------------------------------------------------------------------------
# 六主角只自動學會起始技能；其餘技能由 YEZ JP 選單購買。
# 映體、Robot、Pokémon 仍使用 Class Learnings 自動學習。
# 保留 Class 名稱、位置、屬性與狀態抗性。
# 追加本專案 Weapon 100～129、Armor 220～333、600～665 的正確可裝備清單。
#==============================================================================
module FS_DB_AUTOSET_CLASS_LEARNINGS
  #--------------------------------------------------------------------------
  # ● 六主角可裝備清單
  #
  # 原 YEM 裝備候選清單必須同時通過：
  # 1. 隊伍持有該物品
  # 2. Armor kind 與欄位種類一致
  # 3. Class armor_set／weapon_set 包含該 ID
  #
  # 舊版只建立裝備資料，沒有把新 ID 加入 Class，因此候選清單完全看不到。
  # 本表只「追加」ID，不刪除資料庫原有許可。
  #--------------------------------------------------------------------------
  EQUIP_PERMISSIONS = {}

  def self.append_unique(target, values)
    return unless target.is_a?(Array)
    values = [] unless values.is_a?(Array)
    values.each do |id|
      id = id.to_i
      next if id <= 0
      target.push(id) unless target.include?(id)
    end
    target.sort!
  end

  def self.apply_equip_permissions
    EQUIP_PERMISSIONS.keys.sort.each do |class_id|
      config = EQUIP_PERMISSIONS[class_id]
      config = {} unless config.is_a?(Hash)
      klass = FS_DB_AUTOSET.ensure_record($data_classes, class_id, RPG::Class)

      klass.weapon_set = [] unless klass.weapon_set.is_a?(Array)
      klass.armor_set  = [] unless klass.armor_set.is_a?(Array)

      append_unique(klass.weapon_set, config[:weapons])
      append_unique(klass.armor_set,  config[:armors])
    end
  end
  DATA = {}
  JP_CLASS_SKILLS = {}

  def self.apply_job_class_skills
    return unless defined?(YEZ)
    return unless defined?(YEZ::JOB)
    if YEZ::JOB.const_defined?("CLASS_SKILLS")
      target = YEZ::JOB::CLASS_SKILLS
      JP_CLASS_SKILLS.each { |id, list| target[id] = list.clone }
    end
    if YEZ::JOB.const_defined?("CLASS_SKILLS_LIST")
      target = YEZ::JOB::CLASS_SKILLS_LIST
      JP_CLASS_SKILLS.each { |id, list| target[id] = list.clone }
    end
  end

  def self.apply
    apply_equip_permissions
    keys = DATA.keys
    keys = [] unless keys.is_a?(Array)
    keys.sort.each do |class_id|
      FS_DB_AUTOSET.context("class learnings", "Class ID #{class_id}")
      klass = FS_DB_AUTOSET.ensure_record($data_classes, class_id, RPG::Class)
      list = []
      pairs = DATA[class_id]
      pairs = [] unless pairs.is_a?(Array)
      pairs.each do |pair|
        next unless pair.is_a?(Array) && pair.size >= 2
        learning = RPG::Class::Learning.new
        learning.level = pair[0]
        learning.skill_id = pair[1]
        list.push(learning)
      end
      klass.learnings = list
    end
    apply_job_class_skills
  end
end
