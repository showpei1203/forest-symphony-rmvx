#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：AutoSetup_07_Audit
# 【用途】Setup／資料庫完整性 Audit。檢查 AutoSetup 套用結果、MasterSetup Authority Ready、Scope／Note／Enemy／Weather／Equipment 等關鍵資料是否一致。
# 【主要機制】本專案 MasterSetup 會在後方覆寫／補齊正式資料；AutoSetup 各頁順序不可任意交換。
# 【主要影響】FS_DB_AUTOSET_AUDIT
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】位於 AutoSetup Adapter 後即可定義；真正執行 Audit 時必須已完成 MasterSetup 18 Apply 與 Scene_Title database load。
# 【呼叫方式／範例】事件／測試腳本可使用 FS_DB_AUTOSET_AUDIT.print_report 或 FS_DB_AUTOSET_AUDIT.write_report。後續 Test Harness 的 SetupIntegrity 會直接重用本 Audit。
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
# ■ FS_DB_AutoSetup_07_Audit v1.4.0
#------------------------------------------------------------------------------
# 事件腳本：FS_DB_AUTOSET_AUDIT.print_report / write_report
#==============================================================================
module FS_DB_AUTOSET_AUDIT
  def self.lines
    result = []
    result.push("FS DB AutoSetup version: #{$fs_db_autoset_version || 'NOT APPLIED'}")
    if defined?(FS_DB_AUTOSET) && FS_DB_AUTOSET.respond_to?(:authority_ready?)
      if FS_DB_AUTOSET.authority_ready?
        result.push("MasterSetup Authority: READY #{FS_DB_AUTOSET.authority_source} v#{FS_DB_AUTOSET.authority_version}")
      else
        result.push("ERROR MasterSetup Authority: NOT READY")
      end
    end

    if defined?(FS_BATTLE_BALANCE)
      result.push("Battle Balance Core: OK")
      p1 = FS_BATTLE_BALANCE.note_number($data_weapons[100],
        "normal_power", 0)
      p5 = FS_BATTLE_BALANCE.note_number($data_weapons[104],
        "normal_power", 0)
      result.push("Normal power tier 1/5: #{p1}/#{p5}")
      result.push("Critical damage: #{FS_BATTLE_BALANCE::CRITICAL_RATE}%")
      result.push("Element product cap: #{FS_BATTLE_BALANCE::ELEMENT_RATE_MAX}%")
    else
      result.push("ERROR Battle Balance Core missing")
    end

    if $data_armors && $data_armors[315]
      result.push("Assault armor tier 5 ATK: #{$data_armors[315].atk}")
    end

    if $data_skills && $data_skills[110]
      s = $data_skills[110]
      result.push("Healing Touch B/AF/SF: #{s.base_damage}/#{s.atk_f}/#{s.spi_f}")
    end

    # Scope 與 Enemy 共通 SBS Note
    bad_scopes = []
    if defined?(FS_DB_AUTOSET_SKILLS) && $data_skills
      FS_DB_AUTOSET_SKILLS::DATA.keys.each do |skill_id|
        skill = $data_skills[skill_id]
        next if skill == nil
        expected = FS_DB_AUTOSET_SKILLS::DATA[skill_id][:scope].to_i
        bad_scopes.push([skill_id, skill.scope, expected]) if skill.scope != expected
      end
    end
    result.push(bad_scopes.empty? ?
      "Managed skill scopes: OK" :
      "ERROR managed skill scopes: #{bad_scopes.inspect}")

    missing_enemy_visual = []
    if $data_enemies
      i = 1
      while i < $data_enemies.size
        enemy = $data_enemies[i]
        if enemy != nil && !enemy.name.to_s.empty?
          text = enemy.note.to_s
          ok = text =~ /<\s*(?:animate|animated)\s*>/i &&
               text =~ /<\s*mirror\s*>/i &&
               text =~ /<\s*shadow\s*:\s*off\s*>/i
          missing_enemy_visual.push(i) unless ok
        end
        i += 1
      end
    end
    result.push(missing_enemy_visual.empty? ?
      "All named enemies animated/mirror/shadow-off: OK" :
      "ERROR enemy visual notes missing: #{missing_enemy_visual.inspect}")

    if defined?(FS_DB_AUTOSET)
      note_mismatches = FS_DB_AUTOSET.authoritative_note_mismatches
      result.push(note_mismatches.empty? ?
        "Authoritative managed Notes: OK" :
        "ERROR managed Note drift: #{note_mismatches.inspect}")
    end

    # 受管技能不得殘留 Enemy Summon Skill 標籤。
    stale_summon_skills = []
    if defined?(FS_DB_AUTOSET_SKILLS) && $data_skills
      FS_DB_AUTOSET_SKILLS::DATA.keys.each do |skill_id|
        skill = $data_skills[skill_id]
        next if skill == nil
        if skill.note.to_s =~ /\\SUMMON_ENEMY\[[^\]]*\]/i
          stale_summon_skills.push(skill_id)
        end
      end
    end
    result.push(stale_summon_skills.empty? ?
      "Managed skill enemy-summon tags: clean" :
      "ERROR stale enemy-summon tags: #{stale_summon_skills.inspect}")

    bad_wait = []
    bad_target_override = []
    if defined?(FS_DB_AUTOSET_SKILLS) && $data_skills
      FS_DB_AUTOSET_SKILLS::DATA.keys.each do |skill_id|
        skill = $data_skills[skill_id]
        next if skill == nil
        data = FS_DB_AUTOSET_SKILLS::DATA[skill_id]
        if FS_DB_AUTOSET_SKILLS.functional_skill?(data) &&
           skill.note.to_s =~ /<\s*action\s*:\s*WAIT\s*>/i
          bad_wait.push(skill_id)
        end
        if skill.note.to_s =~ /<\s*(?:EVERYBODY|PHOENIX|TARGETALLFOE|TARGETALLALLY|TARGETRANDOMFOE|TARGETRANDOMALLY|RANDOMFOE|RANDOMALLY|MULTI_FOE|MULTI_ALLY|ALLBUTUSER|PICK_CUSTOM)\b/i
          bad_target_override.push(skill_id)
        elsif skill.respond_to?(:extension) &&
              skill.extension.include?("TARGETALL")
          bad_target_override.push(skill_id)
        end
      end
    end
    result.push(bad_wait.empty? ?
      "Managed functional skill WAIT actions: clean" :
      "ERROR functional skills still using WAIT: #{bad_wait.inspect}")
    result.push(bad_target_override.empty? ?
      "Managed skill target overrides: clean" :
      "ERROR stale target overrides: #{bad_target_override.uniq.inspect}")

    if defined?(FS_DB_AUTOSET_BOSS_RUNTIME)
      result.push("Enemy stat mode 1: #{FS_DB_AUTOSET_BOSS_RUNTIME.stat_mode($data_enemies[1], 1)}") if $data_enemies && $data_enemies[1]
      result.push("Enemy stat mode 500: #{FS_DB_AUTOSET_BOSS_RUNTIME.stat_mode($data_enemies[500], 500)}") if $data_enemies && $data_enemies[500]
      result.push("Enemy stat mode 600: #{FS_DB_AUTOSET_BOSS_RUNTIME.stat_mode($data_enemies[600], 600)}") if $data_enemies && $data_enemies[600]
    end

    # 特殊欄與 Class 許可
    if $data_classes && $data_classes[1]
      c = $data_classes[1]
      missing_special = ((220..295).to_a + (600..665).to_a).find_all { |id|
        !c.armor_set.include?(id)
      }
      result.push(missing_special.empty? ?
        "Class 1 special armor permissions: OK" :
        "ERROR Class 1 missing special armors: #{missing_special.inspect}")
    end

    special_bad_kind = []
    if $data_armors
      ((220..295).to_a + (600..665).to_a).each do |id|
        armor = $data_armors[id]
        next if armor == nil || armor.name.to_s.empty?
        special_bad_kind.push([id, armor.kind]) unless armor.kind == 5
      end
    end
    result.push(special_bad_kind.empty? ?
      "Special armor kind 5: OK" :
      "ERROR special armor kind mismatch: #{special_bad_kind.inspect}")

    if defined?(FS_DB_AUTOSET)
      holes = FS_DB_AUTOSET.database_holes
      result.push(holes.empty? ?
        "Database arrays: dense / no nil holes" :
        "ERROR database nil holes: #{holes.inspect}")
      counts = FS_DB_AUTOSET.placeholder_counts
      result.push("Database safe placeholders: #{counts.inspect}")
    else
      result.push("ERROR FS_DB_AUTOSET missing")
    end
    skill = $data_skills[82] rescue nil
    result.push(skill != nil && skill.note.to_s =~ /<steal>/i ? "Skill 82 Steal tag: OK" : "ERROR Skill 82 <steal>")
    result.push(skill != nil && skill.note.to_s =~ /<action:\s*汲取>/i ? "Skill 82 SBS action: OK" : "MANUAL Skill 82 add <action: 汲取>")

    if defined?(YEZ::JOB) && YEZ::JOB.const_defined?("CLASS_SKILLS_LIST")
      list = YEZ::JOB::CLASS_SKILLS_LIST[1] || []
      result.push(list.include?(101) && list.include?(109) ? "YEZ Class 1 JP list: OK" : "ERROR YEZ Class 1 JP list")
    else
      result.push("ERROR YEZ Job CLASS_SKILLS_LIST missing")
    end

    changed = []
    for id in 600..665
      armor = $data_armors[id] rescue nil
      next if armor == nil
      changed.push(id) if armor.note.to_s.include?("FS_AUTOSET_BEGIN armor")
    end
    result.push(changed.empty? ? "Armor 600-665: untouched" : "ERROR Armor 600-665 managed: #{changed.inspect}")

    if defined?(FS_DB_AUTOSET_ENEMIES)
      nil_action_arrays = []
      graphics_errors = []
      sbs_errors = []
      keys = FS_DB_AUTOSET_ENEMIES::DATA.keys
      keys = [] unless keys.is_a?(Array)
      keys.sort.each do |id|
        enemy = $data_enemies[id] rescue nil
        next if enemy == nil
        snap = FS_DB_AUTOSET_ENEMIES::GRAPHICS_SNAPSHOT[id]
        graphics_errors.push(id) if snap != nil && [enemy.battler_name, enemy.battler_hue] != snap
        old_lines = FS_DB_AUTOSET_ENEMIES::SBS_SNAPSHOT[id]
        old_lines = [] unless old_lines.is_a?(Array)
        now = enemy.note.to_s.split(/[\r\n]+/).collect { |x| x.strip }
        old_lines.each { |line| sbs_errors.push([id,line]) unless now.include?(line) }
        actions = enemy.actions
        actions = [] unless actions.is_a?(Array)
        actions.each do |action|
          nil_action_arrays.push(id) if action.respond_to?(:conditions_arrays) && action.conditions_arrays == nil
        end
      end
      result.push(nil_action_arrays.empty? ? "Enemy action arrays: nil-safe" : "ERROR nil action arrays: #{nil_action_arrays.uniq.inspect}")
      result.push(graphics_errors.empty? ? "Enemy graphics/hue: preserved" : "ERROR Enemy graphics: #{graphics_errors.inspect}")
      result.push(sbs_errors.empty? ? "Enemy SBS Note: preserved" : "ERROR Enemy SBS Note: #{sbs_errors.inspect}")
    end

    if defined?(YEM::EQUIP) && YEM::EQUIP.const_defined?("TYPE_RULES")
      result.push(YEM::EQUIP::TYPE_RULES.has_key?(:special) ? "Equip :special alias: OK" : "ERROR Equip :special alias")
    end

    weather_errors = []
    for id in 153..158
      state = $data_states[id] rescue nil
      if state == nil || state.atk_rate != 100 || state.def_rate != 100 ||
         state.spi_rate != 100 || state.agi_rate != 100 ||
         state.note.to_s !~ /<field_weather>/i
        weather_errors.push(id)
      end
    end
    result.push(weather_errors.empty? ? "Weather State 153-158: OK" : "ERROR Weather States: #{weather_errors.inspect}")
    [[452,156],[455,157],[458,158]].each do |pair|
      skill = $data_skills[pair[0]] rescue nil
      ok = skill != nil && skill.note.to_s =~ /<field effect:\s*#{pair[1]}>/i
      result.push(ok ? "Skill #{pair[0]} field #{pair[1]}: OK" : "ERROR Skill #{pair[0]} field tag")
    end
    skill320 = $data_skills[320] rescue nil
    result.push(skill320 != nil && skill320.note.to_s =~ /<field_context_weather>/i ? "Skill 320 context weather: OK" : "ERROR Skill 320 context weather")
    enemy550 = $data_enemies[550] rescue nil
    ids550 = enemy550 == nil ? [] : (enemy550.actions || []).collect { |a| a.skill_id }.sort
    result.push(ids550 == [410,456,457,458] ? "Enemy 550 actions: repaired" : "ERROR Enemy 550 actions: #{ids550.inspect}")
    invalid_actions = []
    if defined?(FS_DB_AUTOSET_ENEMIES)
      FS_DB_AUTOSET_ENEMIES::DATA.keys.each do |eid|
        enemy = $data_enemies[eid] rescue nil
        next if enemy == nil
        (enemy.actions || []).each { |a| invalid_actions.push([eid,a.skill_id]) if a.kind == 1 && a.skill_id.to_i > 771 }
      end
    end
    result.push(invalid_actions.empty? ? "Enemy action Skill IDs: valid" : "ERROR Enemy action Skill IDs: #{invalid_actions.inspect}")
    result.push("Field Weather: #{defined?(FS_FIELD_WEATHER) ? 'installed' : 'NOT INSTALLED'}")

    result.push("Boss Runtime: #{defined?(FS_DB_AUTOSET_BOSS_RUNTIME) ? 'installed' : 'NOT INSTALLED'}")
    result.push("Runtime Support: #{defined?(FS_DB_RUNTIME_SUPPORT) ? 'installed' : 'NOT INSTALLED'}")
    return result
  end

  def self.print_report
    lines.each { |line| p line }
  end

  def self.write_report
    File.open("FS_DB_AutoSetup_Report.txt", "wb") do |file|
      lines.each { |line| file.write(line.to_s + "\r\n") }
    end
  end
end
