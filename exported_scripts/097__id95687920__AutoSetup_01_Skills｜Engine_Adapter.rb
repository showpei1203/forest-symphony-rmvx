#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：AutoSetup_01_Skills
# 【用途】AutoSetup Skills 的 Engine Adapter；負責把已注入的 MasterSetup Authority Data 套入 RPG Maker VX 資料庫，不再保存第二份正式資料表。
# 【主要機制】本專案 MasterSetup 會在後方覆寫／補齊正式資料；AutoSetup 各頁順序不可任意交換。
# 【主要影響】FS_DB_AUTOSET_SKILLS
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
# ■ FS_DB_AutoSetup_01_Skills v1.4.0
#------------------------------------------------------------------------------
# 設定 Skill 82、100～192、300～458、600～771 中手冊實際使用的技能。
# v1.3.7 已依 RPG Maker VX 原生 Scope 0～11 全表校正所有受管技能。
# 保留 Icon、動畫、使用訊息、說明與 Note 中未被本檔管理的 <action: ...>。
# 清除受管 Skill 舊資料殘留的召喚、目標改寫與錯誤 WAIT 動作標籤。
# Skill 82／110／120 由本檔指定正確 SBS Action。
# 「光」映射妖精 Element 21；「音」映射一般 Element 4。
#==============================================================================
module FS_DB_AUTOSET_SKILLS

  # RPG Maker VX 正式 Scope 對照：
  # 0 無／特殊
  # 1 敵單體
  # 2 敵全體
  # 3 敵單體連續
  # 4 隨機敵單體
  # 5 隨機敵二體
  # 6 隨機敵三體
  # 7 我方單體
  # 8 我方全體
  # 9 我方戰鬥不能單體
  # 10 我方戰鬥不能全體
  # 11 使用者
  SCOPE_NAMES = {
    0 => "無／特殊",
    1 => "敵單體",
    2 => "敵全體",
    3 => "敵單體連續",
    4 => "隨機敵單體",
    5 => "隨機敵二體",
    6 => "隨機敵三體",
    7 => "我方單體",
    8 => "我方全體",
    9 => "我方戰鬥不能單體",
    10 => "我方戰鬥不能全體",
    11 => "使用者"
  }

  # 個別指定是演出設計，不是清理舊 Note 的補丁。
  ACTION_OVERRIDES = {}

  def self.passive_note?(note)
    text = note.to_s
    return true if text =~ /<\s*PASSIVE_SKILL\s*>/i
    return true if text =~ /<\s*mechanic_passive\s*>/i
    return false
  end

  def self.needs_default_action?(data)
    return false unless data.is_a?(Hash)
    return false if data[:scope].to_i == 0
    return false if data[:occasion].to_i == 3
    return false if passive_note?(data[:note])
    return true
  end

  def self.authoritative_note_for(id, data)
    note = data[:note].to_s.gsub("\r", "")
    return note if note =~ /<\s*action\s*:/i
    action = ACTION_OVERRIDES[id]
    action = "SKILL_USE" if action == nil && needs_default_action?(data)
    return note if action == nil
    return "<action:#{action}>\n#{note}"
  end

  DATA = {}


  #--------------------------------------------------------------------------
  # ● v1.4.0 實際公式平衡覆寫
  #--------------------------------------------------------------------------
  # 290 筆受管技能已依實際傷害管線稽核。
  #
  # 保留：
  # - 六主角正傷害技能
  # - 映體／Robot／追擊技能
  # - 一般 Pokémon 正傷害技能
  #
  # 重算：
  # - 14 筆治療技能
  # - 52 筆菁英／Boss 正傷害技能
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
      data = DATA[id]
      data = {} unless data.is_a?(Hash)
      FS_DB_AUTOSET.context("skills", "Skill ID #{id}")
      skill = FS_DB_AUTOSET.ensure_record($data_skills, id, RPG::Skill)
      data.each do |key, value|
        next if key == :note
        FS_DB_AUTOSET.set(skill, key, value)
      end
      FS_DB_AUTOSET.replace_note(skill, "skill", id, authoritative_note_for(id, data))
    end
    install_runtime_patch
  end

  # 在 Scene_Title 真正載入資料庫時才包住最終版 skill_effect。
  # 這能避免後方戰鬥腳本重新定義方法後，把本補丁蓋掉。
  def self.install_runtime_patch
    return if $fs_db_autoset_skill_effect_patch
    Game_Battler.class_eval do
      alias fs_db_autoset_skill_effect skill_effect
      def skill_effect(user, skill)
        fs_db_autoset_skill_effect(user, skill)
        return if user == nil || skill == nil
        skill.note.to_s.scan(/<fs_user_add_state\s*:\s*(\d+)\s*>/i) do |data|
          user.add_state(data[0].to_i)
        end
      end
    end
    $fs_db_autoset_skill_effect_patch = true
  end
end
