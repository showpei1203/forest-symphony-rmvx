#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_MasterSetup 18 Apply
# 【用途】MasterSetup Authority → AutoSetup Engine 的唯一正式 Apply Bridge。把 00～17 定義的 Authority Data 注入既有 Adapter，並在成功後標記 FS_DB_AUTOSET Authority Ready。
# 【主要機制】腳本載入階段只替換 AutoSetup 模組常數，不直接寫入 $data_*；Scene_Title 載入資料庫後，FS_DB_AUTOSET.apply_all 才把正式 Authority Data 套入 RPG:: 資料。
# 【主要影響】FS_MASTER_SETUP
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】必須位於 MasterSetup 00～17 後、19／20 Guard 前；且必須在 Scene_Title#load_database 之前載入。Phase 22 起若握手未成功，AutoSetup Core 會拒絕 apply_all 並直接報錯。
# 【呼叫方式／範例】正常啟動自動執行，不需事件呼叫。Validation 可檢查 FS_DB_AUTOSET.authority_ready? == true。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【Phase 22 單一資料來源】本頁成功後，AutoSetup 01～06／08 的 Placeholder 會被正式 MasterSetup 常數整份取代。
# 【Setup 分類】APPLY BRIDGE / AUTHORITY HANDSHAKE
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
# ■ FS_MasterSetup 18 Apply
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2
# 載入順序：18 / 20
# 分類用途：把所有分類資料一次套回 AutoSetup 引擎
#
# 本頁由 FS_MasterSetup_AllData_v1_1 自動等值拆分。
# 請依編號順序放置，並停用原本未拆分的整合頁，避免資料重複套用。
#==============================================================================

module FS_MASTER_SETUP

  #============================================================================
  # ■ 資料常數套用器
  #============================================================================

  def self.deep_copy(value)
    return Marshal.load(Marshal.dump(value))
  rescue
    return value
  end

  def self.resolve_module(path)
    current = Object
    path.to_s.split("::").each do |name|
      next if name == nil || name.empty?
      return nil unless current.const_defined?(name)
      current = current.const_get(name)
    end
    return current
  rescue
    return nil
  end

  def self.replace_constant(module_path, constant_name, value)
    mod = resolve_module(module_path)
    return false if mod == nil

    name = constant_name.to_s
    copy = deep_copy(value)

    if mod.const_defined?(name)
      old = mod.const_get(name)
      if old.is_a?(Hash) && copy.is_a?(Hash)
        old.replace(copy)
        return true
      elsif old.is_a?(Array) && copy.is_a?(Array)
        old.replace(copy)
        return true
      end
      mod.send(:remove_const, name)
    end

    mod.const_set(name, copy)
    return true
  rescue
    return false
  end

  def self.apply_authoritative_data!
    replace_constant("FS_DB_AUTOSET_SKILLS", "ACTION_OVERRIDES", SKILLS::ACTION_OVERRIDES)
    replace_constant("FS_DB_AUTOSET_SKILLS", "DATA", SKILLS::DATA)
    replace_constant("FS_DB_AUTOSET_SKILLS", "BALANCE_OVERRIDES", SKILLS::BALANCE_OVERRIDES)

    replace_constant("FS_DB_AUTOSET_STATES", "DATA", STATES::DATA)
    replace_constant("FS_DB_AUTOSET_STATES", "PRESERVE_IDS", STATES::PRESERVE_IDS)

    replace_constant("FS_DB_AUTOSET_ITEMS", "DATA", ITEMS::DATA)

    replace_constant("FS_DB_AUTOSET_WEAPONS", "DATA", WEAPONS::DATA)
    replace_constant("FS_DB_AUTOSET_WEAPONS", "NORMAL_POWER", WEAPONS::NORMAL_POWER)

    replace_constant("FS_DB_AUTOSET_ARMORS", "DATA", ARMORS::DATA)
    replace_constant("FS_DB_AUTOSET_ARMORS", "UNTOUCHED_SOUL_RANGE", ARMORS::UNTOUCHED_SOUL_RANGE)
    replace_constant("FS_DB_AUTOSET_ARMORS", "BALANCE_OVERRIDES", ARMORS::BALANCE_OVERRIDES)

    replace_constant("FS_DB_AUTOSET_CLASS_LEARNINGS", "EQUIP_PERMISSIONS", CLASSES::EQUIP_PERMISSIONS)
    replace_constant("FS_DB_AUTOSET_CLASS_LEARNINGS", "DATA", CLASSES::DATA)
    replace_constant("FS_DB_AUTOSET_CLASS_LEARNINGS", "JP_CLASS_SKILLS", CLASSES::JP_CLASS_SKILLS)

    replace_constant("FS_DB_AUTOSET_ENEMIES", "COMMON_VISUAL_NOTE", ENEMIES::COMMON_VISUAL_NOTE)
    replace_constant("FS_DB_AUTOSET_ENEMIES", "DATA", ENEMIES::DATA)
    replace_constant("FS_DB_AUTOSET_ENEMIES", "FIXED_BALANCE_OVERRIDES", ENEMIES::FIXED_BALANCE_OVERRIDES)

    BOSS_RUNTIME.constants.each do |name|
      replace_constant("FS_DB_AUTOSET_BOSS_RUNTIME", name, BOSS_RUNTIME.const_get(name))
    end
    RUNTIME_SUPPORT.constants.each do |name|
      replace_constant("FS_DB_RUNTIME_SUPPORT", name, RUNTIME_SUPPORT.const_get(name))
    end
    FIELD_WEATHER.constants.each do |name|
      replace_constant("FS_FIELD_WEATHER", name, FIELD_WEATHER.const_get(name))
    end

    replace_constant("FS_ITEM_CLASS_AUTOSET", "SUMMON_CLASS", ITEM_CLASS::SUMMON_CLASS)
    replace_constant("FS_ITEM_CLASS_AUTOSET", "ACCESSORY_CLASS", ITEM_CLASS::ACCESSORY_CLASS)
    replace_constant("FS_AUTOSET_WEAPON_NAME_FIX", "NAMES", WEAPON_NAME_FIX::NAMES)

    PLAYER_TEXT.constants.each do |name|
      replace_constant("FS_AUTOSET_PLAYER_TEXT_V12", name, PLAYER_TEXT.const_get(name))
    end

    replace_constant("FS_SOULMARK_RESONANCE", "ELEMENT_NAMES", SOULMARK::ELEMENT_NAMES)
    replace_constant("FS_SOULMARK_RESONANCE", "HARMFUL_STATES", SOULMARK::HARMFUL_STATES)
    replace_constant("FS_SOULMARK_RESONANCE", "BUFF_STATES", SOULMARK::BUFF_STATES)
    replace_constant("FS_SOULMARK_RESONANCE", "SOUL_ARTS", SOULMARK::SOUL_ARTS)
    replace_constant("FS_SOULMARK_RESONANCE", "RESONANCE_ITEMS", SOULMARK::RESONANCE_ITEMS)
    replace_constant("FS_SOULMARK_RESONANCE", "RESONANCE_WEAPONS", SOULMARK::RESONANCE_WEAPONS)
    replace_constant("FS_SOULMARK_RESONANCE", "RESONANCE_RECIPES", SOULMARK::RESONANCE_RECIPES)

    # 重新執行原本位於後段的文字／武器名稱覆蓋，避免主表換回後遺失。
    if defined?(FS_AUTOSET_WEAPON_NAME_FIX) &&
       FS_AUTOSET_WEAPON_NAME_FIX.respond_to?(:apply_to_autoset_data)
      FS_AUTOSET_WEAPON_NAME_FIX.apply_to_autoset_data
    end
    if defined?(FS_AUTOSET_PLAYER_TEXT_V12) &&
       FS_AUTOSET_PLAYER_TEXT_V12.respond_to?(:apply_data_overrides)
      FS_AUTOSET_PLAYER_TEXT_V12.apply_data_overrides
    end

    return true
  end

  def self.summary
    result = []
    result.push("Master Setup v#{VERSION}")
    result.push("Skills: #{SKILLS::DATA.size}")
    result.push("States: #{STATES::DATA.size}")
    result.push("Items: #{ITEMS::DATA.size}")
    result.push("Weapons: #{WEAPONS::DATA.size}")
    result.push("Armors: #{ARMORS::DATA.size}")
    result.push("Classes: #{CLASSES::DATA.size}")
    result.push("Enemies: #{ENEMIES::DATA.size}")
    result.push("Soul Arts: #{SOULMARK::SOUL_ARTS.size}")
    return result
  end

  def self.print_report
    summary.each { |line| p line }
    if defined?(FS_AUTOSET_SUPPORT_STATE_DATA_FIX)
      FS_AUTOSET_SUPPORT_STATE_DATA_FIX.print_report
    end
    if defined?(FS_SOUL_ART_INTEGRITY_FIX)
      FS_SOUL_ART_INTEGRITY_FIX.print_report
    end
  end
end

if FS_MASTER_SETUP.apply_authoritative_data!
  if defined?(FS_DB_AUTOSET) && FS_DB_AUTOSET.respond_to?(:mark_authoritative_data_ready)
    FS_DB_AUTOSET.mark_authoritative_data_ready("FS_MASTER_SETUP", FS_MASTER_SETUP::VERSION)
  end
end
