#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_NonBattleValidation v2.6
# 【用途】Forest Symphony 非戰鬥／架構稽核工具；Phase 22 建立 SetupIntegrity；Phase 23 新增 AI Testability；Phase 24/25 加入 Skill Cost / Skill Effect；Phase 26 加入 Damage Pipeline；Phase 27 加入 Residual/Drain；Phase 28 加入 Element FinalAuthority 完整性檢查。
# 【主要機制】屬目前正式專案功能的一部分；具體責任以本頁定義的類別、模組與方法，以及 LoadOrder Guide 為準。
# 【主要影響】FS_NONBATTLE_VALIDATION
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：REPORT_FILE、QUEST_IDS。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】登記 $imported：FS NonBattle Validation、FS Save Compatibility Core、FS Z21 Self Variable Fix、EquipmentOverhaul、AlbertEquipmentComboSummonOpening；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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
# ■ FS_NonBattleValidation v2.6
#------------------------------------------------------------------------------
# Forest Symphony / RPG Maker VX / RGSS2
#
# 用途：
#   對以下系統做非破壞式執行期稽核：
#   1. Ring Menu / Scene_RM2
#   2. QJ2 任務資料與目標邏輯
#   3. 隨機地城 / 一般小地圖
#   4. 交通工具 / Fog / Overlay
#   5. 商店價格 / 合成 / 鍛造 / 裝備資料\n#   6. 已退休 Legacy 子系統不得重新載入（目前：Dismantle）
#
# 使用：
#   FS_NONBATTLE_VALIDATION.run
#   FS_NONBATTLE_VALIDATION.snapshot("標籤")
#
# 產生：
#   FS_NonBattleValidationReport.txt
#
# 本腳本不自動執行，也不會永久修改遊戲資料。
#==============================================================================

$imported = {} if $imported == nil
$imported["FS NonBattle Validation"] = 2.60

module FS_NONBATTLE_VALIDATION
  VERSION = "2.6"
  REPORT_FILE = "FS_NonBattleValidationReport.txt"
  QUEST_IDS = [1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 108, 109, 110]

  def self.class_name(object)
    return "nil" if object == nil
    begin
      return Object.instance_method(:class).bind(object).call.to_s
    rescue
      return object.class.to_s rescue "unknown"
    end
  end

  def self.bool_text(value)
    return value ? "YES" : "NO"
  end

  def self.safe_call(default = nil)
    begin
      return yield
    rescue Exception => e
      return "#{e.class}: #{e.message}"
    end
  end

  def self.lines
    @lines ||= []
  end

  def self.put(text = "")
    lines << text.to_s
  end

  def self.section(title)
    put("")
    put("[" + title.to_s + "]")
  end

  def self.check(label, result, detail = nil)
    text = result ? "OK   " : "WARN "
    text += label.to_s
    text += " | " + detail.to_s if detail != nil && detail.to_s != ""
    put(text)
  end

  def self.run
    @lines = []
    put("Forest Symphony Non-Battle Validation Report")
    put("Version: #{VERSION}")
    put("Generated: #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}")
    audit_runtime
    audit_setup_integrity
    audit_ai_testability
    audit_skill_cost_authority
    audit_skill_effect_pipeline
    audit_damage_pipeline
    audit_residual_pipeline
    audit_element_authority
    audit_ring_menu
    audit_quest
    audit_enemy_book
    audit_dungeon_minimap
    audit_vehicle_fog_overlay
    audit_shop_craft_equip
    File.open(REPORT_FILE, "w") do |file|
      lines.each { |line| file.write(line.to_s + "\n") }
    end
    p "已建立 #{REPORT_FILE}"
    return lines
  rescue Exception => e
    p "FS_NONBATTLE_VALIDATION.run error: #{e.class}: #{e.message}"
    return []
  end

  def self.snapshot(label = "snapshot")
    data = []
    data << "Snapshot: #{label}"
    data << "Time: #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"
    data << "Scene: #{class_name($scene)}"
    data << "Map ID: #{safe_call(0) { $game_map.map_id }}"
    data << "Ring commands: #{safe_call(0) { $game_ring_cm.size }}"
    data << "screen_print: #{class_name(defined?($screen_print) ? $screen_print : nil)}"
    data << "Quest object: #{safe_call("nil") { class_name($game_party.quests) }}"
    data << "Quest list count: #{safe_call(0) { $game_party.quests.list.size }}"
    data << "RD active: #{safe_call(false) { FS_RANDOM_DUNGEON.active? }}"
    data << "Normal minimap visible: #{safe_call(false) { FS_NORMAL_MINIMAP.visible? }}"
    data << "Riding data: #{class_name(defined?($riding_data) ? $riding_data : nil)}"
    data << "Fog data: #{class_name(defined?($fog_data) ? $fog_data : nil)}"
    data << "Overlay switches 201-205: " +
      (201..205).collect { |id|
        "#{id}=#{safe_call(false) { $game_switches[id] }}"
      }.join(", ")
    File.open(REPORT_FILE, "a") do |file|
      file.write("\n")
      data.each { |line| file.write(line.to_s + "\n") }
    end
    p "已追加 Snapshot: #{label}"
    return data
  rescue Exception => e
    p "FS_NONBATTLE_VALIDATION.snapshot error: #{e.class}: #{e.message}"
    return []
  end

  def self.audit_runtime
    section("Runtime")
    check("Scene_Map exists", defined?(Scene_Map) != nil)
    check("Scene_Title exists", defined?(Scene_Title) != nil)
    check("$game_system", $game_system != nil, class_name($game_system))
    check("$game_party", $game_party != nil, class_name($game_party))
    check("$game_map", $game_map != nil, class_name($game_map))
    check("$game_player", $game_player != nil, class_name($game_player))
    save_core_version = nil
    begin
      save_core_version = $imported["FS Save Compatibility Core"] if $imported
    rescue
      save_core_version = nil
    end
    check("FS Save Compatibility Core",
          save_core_version != nil,
          save_core_version)
    z21_version = nil
    begin
      z21_version = $imported["FS Z21 Self Variable Fix"] if $imported
    rescue
      z21_version = nil
    end
    check("FS Z21 Self Variable Fix",
          z21_version != nil,
          z21_version == nil ? "未偵測到 v1.1 載入標記" : z21_version)
    check("Game_Event#self_var",
          Game_Event.method_defined?(:self_var))
    check("Game_Event#self_var=",
          Game_Event.method_defined?(:self_var=))

    # Phase 13：BattleStateHUD extra_info_rows 必須由 Core 單一擁有。
    if defined?(AlbertBattleStateHUD)
      hud_singletons = AlbertBattleStateHUD.singleton_methods.collect { |m| m.to_s }
      check("BattleStateHUD extra_info_rows exists",
            hud_singletons.include?("extra_info_rows"))
      legacy_aliases = [
        "albert_profile_old_extra_info_rows",
        "albert_break_zero_hide_original_rows",
        "fs_mc_original_extra_info_rows"
      ]
      loaded_aliases = legacy_aliases.select { |name| hud_singletons.include?(name) }
      check("BattleStateHUD legacy extra_info wrappers removed",
            loaded_aliases.empty?,
            loaded_aliases.inspect)
      check("BattleStateHUD clone row provider available",
            hud_singletons.include?("clone_stability_rows"),
            "provided by FS_ActorProfile")
    else
      check("BattleStateHUD Authority exists", false, "AlbertBattleStateHUD missing")
    end
  end

  #--------------------------------------------------------------------------
  # ● Phase 22：Setup / MasterSetup 單一資料來源完整性
  #--------------------------------------------------------------------------
  def self.audit_setup_integrity
    section("Setup Integrity")

    ready = safe_call(false) { FS_DB_AUTOSET.authority_ready? }
    source = safe_call("nil") { FS_DB_AUTOSET.authority_source }
    version = safe_call("nil") { FS_DB_AUTOSET.authority_version }
    check("MasterSetup Authority READY", ready, "#{source} v#{version}")

    check("AutoSetup Engine >= 1.5.0",
          safe_call(false) { FS_DB_AUTOSET::VERSION.to_s >= "1.5.0" },
          safe_call("missing") { FS_DB_AUTOSET::VERSION })
    check("FS_MASTER_SETUP exists", defined?(FS_MASTER_SETUP) != nil)

    pairs = []
    if defined?(FS_MASTER_SETUP)
      pairs = [
        ["Skills", FS_DB_AUTOSET_SKILLS::DATA, FS_MASTER_SETUP::SKILLS::DATA],
        ["States", FS_DB_AUTOSET_STATES::DATA, FS_MASTER_SETUP::STATES::DATA],
        ["Items", FS_DB_AUTOSET_ITEMS::DATA, FS_MASTER_SETUP::ITEMS::DATA],
        ["Weapons", FS_DB_AUTOSET_WEAPONS::DATA, FS_MASTER_SETUP::WEAPONS::DATA],
        ["Armors", FS_DB_AUTOSET_ARMORS::DATA, FS_MASTER_SETUP::ARMORS::DATA],
        ["Classes", FS_DB_AUTOSET_CLASS_LEARNINGS::DATA, FS_MASTER_SETUP::CLASSES::DATA],
        ["Enemies", FS_DB_AUTOSET_ENEMIES::DATA, FS_MASTER_SETUP::ENEMIES::DATA],
      ]
    end
    # MasterSetup 是設計期單一資料來源；Scene_Title 載入完成後，
    # Runtime Bridge / Post-Apply Guard 允許在 Adapter 投影上補資料或改寫欄位。
    # 因此執行期不應再要求 Adapter == MasterSetup byte-equivalent，
    # 而應驗證：MasterSetup 的所有受管 ID 都仍存在於 Runtime Adapter。
    pairs.each do |entry|
      label, adapter_data, master_data = entry
      missing = safe_call([]) { master_data.keys - adapter_data.keys }
      extra = safe_call([]) { adapter_data.keys - master_data.keys }
      changed = safe_call([]) {
        (master_data.keys & adapter_data.keys).select { |id| adapter_data[id] != master_data[id] }
      }
      detail = safe_call("compare error") {
        "AutoSetup=#{adapter_data.size} MasterSetup=#{master_data.size} " +
        "missing=#{missing.size} extra=#{extra.size} changed=#{changed.size}"
      }
      check("Setup #{label} runtime projection covers MasterSetup",
            missing.empty?, detail)
      if extra.size > 0 || changed.size > 0
        put("INFO Setup #{label} runtime projection enriched | " + detail)
      end
    end

    aux = []
    if defined?(FS_MASTER_SETUP)
      aux = [
        ["Skill ACTION_OVERRIDES", FS_DB_AUTOSET_SKILLS::ACTION_OVERRIDES, FS_MASTER_SETUP::SKILLS::ACTION_OVERRIDES],
        ["Skill BALANCE_OVERRIDES", FS_DB_AUTOSET_SKILLS::BALANCE_OVERRIDES, FS_MASTER_SETUP::SKILLS::BALANCE_OVERRIDES],
        ["State PRESERVE_IDS", FS_DB_AUTOSET_STATES::PRESERVE_IDS, FS_MASTER_SETUP::STATES::PRESERVE_IDS],
        ["Weapon NORMAL_POWER", FS_DB_AUTOSET_WEAPONS::NORMAL_POWER, FS_MASTER_SETUP::WEAPONS::NORMAL_POWER],
        ["Armor UNTOUCHED_SOUL_RANGE", FS_DB_AUTOSET_ARMORS::UNTOUCHED_SOUL_RANGE, FS_MASTER_SETUP::ARMORS::UNTOUCHED_SOUL_RANGE],
        ["Armor BALANCE_OVERRIDES", FS_DB_AUTOSET_ARMORS::BALANCE_OVERRIDES, FS_MASTER_SETUP::ARMORS::BALANCE_OVERRIDES],
        ["Class EQUIP_PERMISSIONS", FS_DB_AUTOSET_CLASS_LEARNINGS::EQUIP_PERMISSIONS, FS_MASTER_SETUP::CLASSES::EQUIP_PERMISSIONS],
        ["Class JP_CLASS_SKILLS", FS_DB_AUTOSET_CLASS_LEARNINGS::JP_CLASS_SKILLS, FS_MASTER_SETUP::CLASSES::JP_CLASS_SKILLS],
        ["Enemy COMMON_VISUAL_NOTE", FS_DB_AUTOSET_ENEMIES::COMMON_VISUAL_NOTE, FS_MASTER_SETUP::ENEMIES::COMMON_VISUAL_NOTE],
        ["Enemy FIXED_BALANCE_OVERRIDES", FS_DB_AUTOSET_ENEMIES::FIXED_BALANCE_OVERRIDES, FS_MASTER_SETUP::ENEMIES::FIXED_BALANCE_OVERRIDES],
      ]
    end
    aux.each do |entry|
      check("Setup #{entry[0]}", safe_call(false) { entry[1] == entry[2] })
    end
  rescue Exception => e
    check("SetupIntegrity exception", false, "#{e.class}: #{e.message}")
  end

  #--------------------------------------------------------------------------
  # ● Phase 23：AI Authority / Deterministic RNG 測試性
  #--------------------------------------------------------------------------
  def self.audit_ai_testability
    section("AI Testability")

    rng_exists = defined?(FS_AI_RANDOM) != nil
    check("FS_AI_RANDOM exists", rng_exists)
    if rng_exists
      check("AI deterministic mode default OFF",
            safe_call(false) { !FS_AI_RANDOM.enabled? })
      result = safe_call(false) { FS_AI_RANDOM.self_test }
      check("AI deterministic RNG self-test", result,
            "seed=12345 => [6,5,3,573]")
    end

    check("EnemyActionPattern core",
          Game_Enemy.method_defined?(:eac_make_action))
    check("EnemyActionDistribution final wrapper",
          Game_Enemy.method_defined?(:fs_ead_original_make_action))
    check("Actor AutoBattle Authority",
          Game_Actor.method_defined?(:process_ai_package))
    check("Mechanic AI Hook Provider",
          Game_Actor.method_defined?(:albert_mx_ai_filter_actions))
    check("RandomTarget Authority",
          defined?(ALBERT_RANDOM_TARGET_INTEGRATION) != nil)
    check("Boss Runtime AI Provider",
          Game_Enemy.method_defined?(:fs_db_autoset_runtime_candidate_actions_enemy))
  rescue Exception => e
    check("AI Testability exception", false, "#{e.class}: #{e.message}")
  end

  #--------------------------------------------------------------------------
  # ● Phase 24：Skill Cost Authority / 去重完整性
  #--------------------------------------------------------------------------
  def self.audit_skill_cost_authority
    section("Skill Cost Authority")

    version = nil
    begin
      version = $imported["FS Skill Cost Authority"] if $imported
    rescue
      version = nil
    end
    check("FS Skill Cost Authority", version != nil, version)
    check("Skill Cost Authority v2+",
          version != nil && version.to_s >= "2.0.0", version)

    check("Final calc_mp_cost exists", Game_Battler.method_defined?(:calc_mp_cost))
    check("Legacy SkillCostNoKGC wrapper retired",
          !Game_Battler.method_defined?(:albert_skill_cost_nokgc_skill_can_use))
    check("YEZ calc_mp_cost alias retired",
          !Game_Battler.method_defined?(:calc_mp_cost_jpsl))
    check("Skill Level cost modifier provider",
          Game_Battler.method_defined?(:apply_level_cost))
    check("Battle timing bridge",
          Scene_Battle.method_defined?(:fs_skill_cost_timing_bridge_execute_action_skill))
    check("Old menu angry alias retired",
          !Scene_Skill.method_defined?(:fs_sc_allfix_use_skill_nontarget_without_angry))

    if defined?(FS_SKILL_COST_ALLFIX)
      check("Battle payment policy",
            FS_SKILL_COST_ALLFIX.respond_to?(:pay_battle_legacy_costs))
      check("Menu payment policy",
            FS_SKILL_COST_ALLFIX.respond_to?(:pay_menu_standard_costs))
    end
  rescue Exception => e
    check("Skill Cost Authority exception", false, "#{e.class}: #{e.message}")
  end

  #--------------------------------------------------------------------------
  # ● Phase 25：Skill Effect Pipeline 去層完整性
  #--------------------------------------------------------------------------
  def self.audit_skill_effect_pipeline
    section("Skill Effect Pipeline")
    check("skill_effect exists", Game_Battler.method_defined?(:skill_effect))
    check("CharacterMechanic duplicate alias retired", !Game_Battler.method_defined?(:albert_cc_v13_old_skill_effect))
    check("MechanicExpansion OD12 duplicate alias retired", !Game_Battler.method_defined?(:albert_mx_od12_old_skill_effect))
    check("MechanicExpansion OD12 before provider", Game_Battler.method_defined?(:albert_mx_od12_capture_skill_effect_context))
    check("MechanicExpansion OD12 after provider", Game_Battler.method_defined?(:albert_mx_od12_after_skill_effect))
    check("StateEffects duplicate alias retired", !Game_Battler.method_defined?(:albert_sev27_skill_effect))
    check("IvyClone display duplicate alias retired", !Game_Battler.method_defined?(:albert_ic_display_old_skill_effect))
    installer_ok = defined?(FS_DB_AUTOSET_SKILLS) &&
                   FS_DB_AUTOSET_SKILLS.respond_to?(:install_runtime_patch)
    installed = defined?($fs_db_autoset_skill_effect_patch) &&
                $fs_db_autoset_skill_effect_patch == true
    check("AutoSetup skill effect installer", installer_ok && installed,
          "provider=#{installer_ok} installed=#{installed}")
  rescue Exception => e
    check("Skill Effect Pipeline exception", false, "#{e.class}: #{e.message}")
  end

  #--------------------------------------------------------------------------
  # ● Phase 26：Damage Pipeline / Direct Override 完整性
  #--------------------------------------------------------------------------
  def self.audit_damage_pipeline
    section("Damage Pipeline")
    check("BattleFormula calc_hit", Game_Battler.method_defined?(:calc_hit))
    check("BattleFormula calc_eva", Game_Battler.method_defined?(:calc_eva))
    check("YEZ calc_hit_jpsl retired", !Game_Battler.method_defined?(:calc_hit_jpsl))

    preserve = false
    if defined?(ALBERT_BATTLE_RUNTIME_FIX) &&
       ALBERT_BATTLE_RUNTIME_FIX.const_defined?(:PRESERVE_KGC_IGNORE_EVA)
      preserve = ALBERT_BATTLE_RUNTIME_FIX::PRESERVE_KGC_IGNORE_EVA ? true : false
    end
    check("KGC ignore_eva preserved by final calc_eva", preserve)

    check("Skill damage pipeline exists", Game_Battler.method_defined?(:make_obj_damage_value))
    check("Attack damage pipeline exists", Game_Battler.method_defined?(:make_attack_damage_value))
    check("Execute damage pipeline exists", Game_Battler.method_defined?(:execute_damage))
    check("Integer damage safety", Game_Battler.method_defined?(:albert_normalize_damage_integer))
    check("Final element guard", defined?(FS_ELEMENT_FINAL) != nil)
    check("Support-state outer damage wrapper", Game_Battler.method_defined?(:fs_ssr_old_make_obj_damage_value))
  rescue Exception => e
    check("Damage Pipeline exception", false, "#{e.class}: #{e.message}")
  end

  #--------------------------------------------------------------------------
  # ● Phase 27：Residual / Drain / Leech 完整性
  #--------------------------------------------------------------------------
  def self.audit_residual_pipeline
    section("Residual / Drain / Leech")
    residual = nil
    if defined?(ALBERT_STATE_EFFECTS_V2) &&
       ALBERT_STATE_EFFECTS_V2.const_defined?(:RESIDUAL_AUTHORITY_VERSION)
      residual = ALBERT_STATE_EFFECTS_V2::RESIDUAL_AUTHORITY_VERSION
    end
    check("StateEffects residual authority", residual != nil, residual)
    check("Final HP slip", Scene_Battle.method_defined?(:hp_slip_damage))
    check("Final MP slip", Scene_Battle.method_defined?(:mp_slip_damage))
    check("Leech Seed single runtime implementation", Game_Battler.method_defined?(:albert_csp_leech_seed))
    if defined?(ALBERT_BATTLE_UTILITY_FIX)
      legacy = ALBERT_BATTLE_UTILITY_FIX.const_defined?(:LEECH_SEED_RATE) ||
               ALBERT_BATTLE_UTILITY_FIX.const_defined?(:LEECH_SEED_MAX_DAMAGE)
      check("Legacy BattleUtility leech formula retired", !legacy)
    end
    check("VX absorb effect exists", Game_Battler.method_defined?(:make_obj_absorb_effect))
    check("SoulMark post drain provider", defined?(FS_SOULMARK_RESONANCE) && FS_SOULMARK_RESONANCE.respond_to?(:apply_soul_post_effect))
  rescue Exception => e
    check("Residual Pipeline exception", false, "#{e.class}: #{e.message}")
  end

  #--------------------------------------------------------------------------
  # ● Phase 28：Element FinalAuthority 完整性
  #--------------------------------------------------------------------------
  def self.audit_element_authority
    section("Element Authority")
    version = nil
    if $imported && $imported["FS Element Rate Final Authority"] != nil
      version = $imported["FS Element Rate Final Authority"]
    end
    check("Element FinalAuthority v2+", version != nil && version.to_f >= 2.0, version)
    check("FS_ELEMENT_FINAL exists", defined?(FS_ELEMENT_FINAL) != nil)
    if defined?(FS_ELEMENT_FINAL)
      check("Final single-rate core", FS_ELEMENT_FINAL.respond_to?(:rate_for))
      check("Final multi-rate core", FS_ELEMENT_FINAL.respond_to?(:max_rate_for))
      check("KGC equipment option bridge", FS_ELEMENT_FINAL.respond_to?(:apply_actor_equipment_options))
    end
    check("KGC dead element wrapper retired", !Game_Actor.method_defined?(:element_rate_KGC_AddEquipmentOptions))
    check("ActorGrowth dead element wrapper retired", !Game_Actor.method_defined?(:albert_actor_enemy_growth_element_rate))
    check("BattleBalance dead element alias retired", !Game_Battler.method_defined?(:fs_balance_v12_original_element_rate))
    check("ElementType provider available", Game_Battler.method_defined?(:pokemon_element_rate))
  rescue Exception => e
    check("Element Authority exception", false, "#{e.class}: #{e.message}")
  end

  def self.audit_ring_menu
    section("Ring Menu")
    check("Scene_RM2 exists", defined?(Scene_RM2) != nil)
    check("Window_RingMenu exists", defined?(Window_RingMenu) != nil)
    check("FS_RING_MENU_ACTIONS exists",
          defined?(FS_RING_MENU_ACTIONS) != nil)
    ring = defined?($game_ring_cm) ? $game_ring_cm : nil
    check("$game_ring_cm is Array", ring.is_a?(Array), class_name(ring))
    return unless ring.is_a?(Array)

    expected_names = ["魂譜", "交織", "騎乘", "橡木聖地", "小地圖", "檔案庫"]
    expected_actions = [
      :soul_book, :synthesize, :ride, :oak_sanctuary, :minimap, :library
    ]
    check("Ring command count", ring.size == 6, ring.size)
    ring.each_with_index do |entry, index|
      valid = entry.is_a?(Array) && entry.size >= 3
      check("Ring command #{index} structure", valid,
            valid ? entry[0].to_s : class_name(entry))
      next unless valid
      name_ok = entry[0].to_s == expected_names[index] ||
                (index == 3 && entry[0].to_s == "返回原處")
      action_ok = entry[2] == expected_actions[index]
      check("Ring command #{index} name", name_ok, entry[0])
      check("Ring command #{index} action", action_ok, entry[2])
      check("Ring command #{index} has no Common Event eval",
            entry[2].is_a?(Symbol))
    end

    check("Scene_SoulBookSelect", defined?(Scene_SoulBookSelect) != nil)
    check("Scene_CharacterBook", defined?(Scene_CharacterBook) != nil)
    check("Scene_EnemyBook", defined?(Scene_EnemyBook) != nil)
    check("Sword_Synthesize", defined?(Sword_Synthesize) != nil)
    check("Scene_FSRideSelect", defined?(Scene_FSRideSelect) != nil)
    check("FS_OAK_SANCTUARY", defined?(FS_OAK_SANCTUARY) != nil)
    check("FS_NORMAL_MINIMAP", defined?(FS_NORMAL_MINIMAP) != nil)
    check("Sword_Library", defined?(Sword_Library) != nil)
    if defined?(Window_RingMenu)
      check("Window_RingMenu#enabled?",
            Window_RingMenu.method_defined?(:enabled?))
    end
  end

  def self.audit_quest
    section("Quest Journal")
    check("QuestData exists", defined?(QuestData) != nil)
    check("Game_Quest exists", defined?(Game_Quest) != nil)
    check("Game_Quests exists", defined?(Game_Quests) != nil)

    quests = safe_call(nil) { $game_party.quests }
    check("$game_party.quests", quests != nil, class_name(quests))
    if quests == nil
      put("WARN Old save may require @quests migration.")
      return
    end

    QUEST_IDS.each do |id|
      q = safe_call(nil) { Game_Quest.new(id) }
      if q == nil
        check("Quest #{id} construct", false)
        next
      end
      name_ok = q.name.to_s != "" && q.name.to_s != "??????"
      check("Quest #{id} data", name_ok,
            "#{q.name} / objectives=#{q.objectives.size}")
      primes = q.prime_objectives || []
      invalid = primes.find { |obj_id|
        obj_id.to_i < 0 || obj_id.to_i >= q.objectives.size
      }
      check("Quest #{id} prime objective range", invalid == nil,
            invalid == nil ? primes.inspect : "invalid=#{invalid}")
      if q.common_event_id.to_i > 0
        common = $data_common_events[q.common_event_id.to_i] rescue nil
        check("Quest #{id} completion common event",
              common != nil,
              q.common_event_id)
      end
    end

    # 非破壞式測試：只建立暫時 Game_Quest，不加入 $game_party。
    probe = safe_call(nil) { Game_Quest.new(1) }
    if probe && probe.objectives.size > 0
      probe.reveal_objective(0)
      reveal_ok = probe.objective_revealed?(0)
      probe.complete_objective(0)
      complete_ok = probe.objective_complete?(0)
      probe2 = Game_Quest.new(1)
      probe2.fail_objective(0)
      fail_ok = probe2.objective_failed?(0)
      check("Quest objective reveal logic", reveal_ok)
      check("Quest objective complete logic", complete_ok)
      check("Quest objective fail logic", fail_ok)
    end
  end

  def self.audit_enemy_book
    section("Enemy Book")
    check("FS_ENEMY_BOOK exists", defined?(FS_ENEMY_BOOK) != nil)
    check("Scene_EnemyBook exists", defined?(Scene_EnemyBook) != nil)
    return unless defined?(FS_ENEMY_BOOK)
    ids = safe_call([]) { FS_ENEMY_BOOK.enemy_ids }
    known = safe_call([]) { ids.find_all { |id| FS_ENEMY_BOOK.encountered?(id) } }
    defeated = safe_call([]) { ids.find_all { |id| FS_ENEMY_BOOK.defeated?(id) } }
    check("Enemy book has entries", ids.size > 0, ids.size)
    put("INFO Encountered enemy records: #{known.size}")
    put("INFO Defeated enemy records: #{defeated.size}")
    put("INFO Enemy records are stored in Game_System / Game_Party and follow each save slot.")
  end

  def self.audit_dungeon_minimap
    section("Random Dungeon / Normal Minimap")
    check("FS_RandomDungeon exists", defined?(FS_RandomDungeon) != nil)
    check("FS_RANDOM_DUNGEON facade exists",
          defined?(FS_RANDOM_DUNGEON) != nil)
    check("FS_NormalMap_Minimap exists",
          defined?(FS_NormalMap_Minimap) != nil)
    check("FS_NORMAL_MINIMAP facade exists",
          defined?(FS_NORMAL_MINIMAP) != nil)

    if defined?(FS_RandomDungeon)
      check("Random Dungeon version",
            FS_RandomDungeon.const_defined?("VERSION"),
            safe_call("") { FS_RandomDungeon::VERSION })
    end
    if defined?(FS_NormalMap_Minimap)
      check("Normal Minimap version",
            FS_NormalMap_Minimap.const_defined?("VERSION"),
            safe_call("") { FS_NormalMap_Minimap::VERSION })
      disabled = safe_call([]) { FS_NormalMap_Minimap::DISABLED_MAP_IDS }
      check("Random Dungeon template map disabled",
            disabled.include?(48),
            disabled.inspect)
    end

    check("Current normal minimap availability",
          safe_call(false) { FS_NORMAL_MINIMAP.available? },
          "Map #{safe_call(0) { $game_map.map_id }}")
    put("INFO Normal minimap visible: " +
        safe_call(false) { FS_NORMAL_MINIMAP.visible? }.to_s)
    put("INFO Normal minimap saved flag: " +
        safe_call(false) { FS_NormalMap_Minimap.visible_flag }.to_s)
    put("INFO Random dungeon active: " +
        safe_call(false) { FS_RANDOM_DUNGEON.active? }.to_s)
    put("INFO Entering a random dungeon intentionally turns the normal minimap flag OFF.")
  end

  def self.audit_vehicle_fog_overlay
    section("Vehicle / Fog / Overlay")
    check("Expansion vehicle module",
          defined?(Expansion_Vehicle) != nil)
    check("Riding_Data class", defined?(Riding_Data) != nil)
    check("$riding_data",
          defined?($riding_data) && $riding_data != nil,
          class_name(defined?($riding_data) ? $riding_data : nil))
    check("HK_UOM overlay module", defined?(HK_UOM) != nil)
    check("Shuu_Fog module", defined?(Shuu_Fog) != nil)
    check("$fog_data Hash",
          defined?($fog_data) && $fog_data.is_a?(Hash),
          class_name(defined?($fog_data) ? $fog_data : nil))
    if defined?(FS_OAK_SANCTUARY)
      put("INFO Oak sanctuary inside: " + FS_OAK_SANCTUARY.inside?.to_s)
      put("INFO Oak return data: " +
          safe_call("nil") { $game_system.fs_oak_return_data.inspect })
    end

    if defined?(HK_UOM)
      ids = [
        safe_call(nil) { HK_UOM::LightSwitch },
        safe_call(nil) { HK_UOM::ShadowSwitch },
        safe_call(nil) { HK_UOM::ParSwitch },
        safe_call(nil) { HK_UOM::GroundSwitch },
        safe_call(nil) { HK_UOM::ShadowSwitch2 }
      ]
      put("INFO Overlay switch IDs: #{ids.inspect}")
      put("WARN Vehicle script also writes switches 202, 203, 204; " +
          "verify takeoff/landing restores prior overlay state.")
    end

    (201..205).each do |id|
      put("INFO Switch #{id}: " + safe_call(false) {
        $game_switches[id]
      }.to_s)
    end
  end

  def self.audit_shop_craft_equip
    section("Shop / Craft / Equipment")

    # 商店價格疊加檢查：暫時修改後立即還原。
    item = nil
    if defined?($data_items) && $data_items
      item = $data_items.compact.find { |obj|
        obj.respond_to?(:price) && obj.respond_to?(:real_price) &&
        obj.real_price.to_i > 0
      }
    end

    if item && $game_system.respond_to?(:new_price)
      old_abs = $game_system.new_price["item"][item.id]
      old_percent = item.respond_to?(:quotation_percent) ?
                    item.quotation_percent : nil
      begin
        $game_system.new_price["item"][item.id] = nil
        item.quotation_percent = 50 if item.respond_to?(:quotation_percent=)
        expected = item.real_price.to_i * 50 / 100
        actual = item.price.to_i
        check("Percentage price modifier survives Item Price Changer",
              actual == expected,
              "item=#{item.id} base=#{item.real_price} expected=#{expected} actual=#{actual}")
      ensure
        $game_system.new_price["item"][item.id] = old_abs
        item.quotation_percent = old_percent if
          old_percent != nil && item.respond_to?(:quotation_percent=)
      end
    else
      put("INFO Shop price audit skipped | no positive-price item or price storage unavailable")
    end

    check("Sword synthesis module", defined?(Sword) != nil)
    if defined?(Sword)
      check("Sword4_Synthesize data",
            Sword.const_defined?("Sword4_Synthesize"),
            safe_call("") { Sword::Sword4_Synthesize.size })
    end
    check("Blacksmith module", defined?(Blacksmith) != nil)
    # Phase 4 cleanup: Dismantle was proven to have no Map/CommonEvent/Database
    # entry point and was intentionally retired. Its complete source is preserved
    # retirement record is preserved after Main; full source is kept externally.
    check("Dismantle intentionally retired",
          defined?(Dismantle) == nil,
          defined?(Dismantle) == nil ? "not loaded" : "unexpectedly loaded")

    check("YEM Equipment Overhaul",
          $imported && $imported["EquipmentOverhaul"] != nil)
    combo_loaded = false
    combo_detail = nil
    begin
      combo_loaded = true if $imported &&
        $imported["AlbertEquipmentComboSummonOpening"] != nil
      combo_loaded = true if defined?(Albert_EquipmentCombo_UI)
      combo_detail = $imported["AlbertEquipmentComboSummonOpening"] if
        $imported && $imported["AlbertEquipmentComboSummonOpening"] != nil
    rescue
      combo_loaded = false
    end
    check("EquipmentCombo", combo_loaded, combo_detail)
    check("YEM Equipment safety patch",
          defined?(ALBERT_YEM_EQUIP_SAFE) != nil)
    core_safe_version = safe_call(nil) { $imported["FS YEM Equipment CoreSafe"] }
    check("YEM Equipment CoreSafe >= 1.1",
          core_safe_version != nil && core_safe_version.to_f >= 1.1,
          core_safe_version)
    late_core_retired = safe_call(false) {
      ALBERT_YEM_EQUIP_SAFE.const_defined?(:CORE_OVERRIDES_RETIRED) &&
      ALBERT_YEM_EQUIP_SAFE::CORE_OVERRIDES_RETIRED
    }
    check("Late YEM Game_Actor core overrides retired",
          late_core_retired, late_core_retired)
    resonance_headgear_ok = defined?(FS_SOULMARK_RESONANCE) &&
                            FS_SOULMARK_RESONANCE.respond_to?(:apply_resonance_headgears)
    check("Resonance headgear authority", resonance_headgear_ok,
          resonance_headgear_ok ? "FS_SOULMARK_RESONANCE" : "missing apply_resonance_headgears")

    head_bad = []
    special_bad = []
    if defined?($data_armors) && $data_armors
      (220..285).each do |id|
        armor = $data_armors[id]
        next if armor == nil
        head_bad << id unless armor.kind.to_i == 1
      end
      [(286..295), (600..665)].each do |range|
        range.each do |id|
          armor = $data_armors[id]
          next if armor == nil
          special_bad << id unless armor.kind.to_i == 5
        end
      end
    end
    check("Armor 220-285 head kind", head_bad.empty?,
          head_bad.inspect)
    check("Armor 286-295 / 600-665 special kind",
          special_bad.empty?,
          special_bad.inspect)


    # Phase 12：Compact ID Database Authority 稽核。
    compact_ok = defined?(ForestSymphonyDB) &&
                 ForestSymphonyDB.const_defined?(:ARMOR_TO_ACTOR) &&
                 ForestSymphonyDB.const_defined?(:PROFILES)
    check("FS DatabaseSupport CompactID authority", compact_ok)

    if compact_ok
      expected_mapping = {286=>7,287=>8,288=>9,289=>10,290=>11,
                          291=>12,292=>13,293=>14,294=>15,295=>16}
      check("Compact summon armor mapping 286-295",
            ForestSymphonyDB::ARMOR_TO_ACTOR == expected_mapping,
            ForestSymphonyDB::ARMOR_TO_ACTOR.inspect)

      robot_skills = []
      for actor_id in 12..16
        profile = ForestSymphonyDB::PROFILES[actor_id] rescue nil
        data = profile == nil ? nil : profile[:robot_protocol]
        robot_skills << (data == nil ? 0 : data[:skill].to_i)
      end
      check("Robot protocol skills use CompactID 185-189",
            robot_skills == [185,186,187,188,189],
            robot_skills.inspect)
    end

    legacy_v20_loaded = Game_Actor.method_defined?(:fsdb_change_level_v20) ||
                        Game_Actor.method_defined?(:fsdb_robot_fixed_old_make_action_v20)
    check("DatabaseSupport v2.0 intentionally retired",
          !legacy_v20_loaded,
          legacy_v20_loaded ? "legacy v2.0 method still loaded" : "not loaded")

    legacy_robot_wrapper = Game_Actor.method_defined?(:fsdb_robot_fixed_old_make_action_v21)
    check("DatabaseSupport Robot make_action wrapper removed",
          !legacy_robot_wrapper,
          legacy_robot_wrapper ? "v2.1 robot wrapper still loaded" : "owned by AutoBattleAI v2.2")

    # Phase 29：Equipment / ArmorMapping Authority。
    eqskill_version = safe_call(nil) { $imported["FS Equipment Skill Authority"] }
    check("FS Equipment Skill Authority >= 2.1",
          eqskill_version != nil && eqskill_version.to_s >= "2.1",
          eqskill_version)
    old_eqskill_aliases = [
      :ma_skill_teaching_items_equipment_change,
      :change_equip_KGC_PassiveSkill,
      :skills_sss_equipment_skills,
      :albert_eqskill_final_skills
    ]
    loaded_eqskill_aliases = old_eqskill_aliases.select { |name|
      Game_Actor.method_defined?(name)
    }
    check("Legacy Equipment skill/passive wrappers retired",
          loaded_eqskill_aliases.empty?,
          loaded_eqskill_aliases.inspect)
    check("Equipment passive final refresh hook",
          Game_Actor.method_defined?(:albert_refresh_equipment_passive_skills))

    if defined?(ArmorMapping) && $game_system != nil &&
       $game_system.respond_to?(:armor_mapping)
      mapping = safe_call({}) { ArmorMapping.mapping }
      legacy_pairs = {101=>8,103=>7,105=>9,
                      732=>7,733=>8,734=>9,735=>10,736=>11,
                      737=>12,738=>13,739=>14,740=>15,741=>16}
      stale = legacy_pairs.keys.select { |id| mapping[id] == legacy_pairs[id] }
      check("Legacy ArmorMapping normalized", stale.empty?, stale.inspect)
      compact = {286=>7,287=>8,288=>9,289=>10,290=>11,
                 291=>12,292=>13,293=>14,294=>15,295=>16}
      compact_bad = compact.keys.select { |id| mapping[id] != compact[id] }
      check("Runtime Compact ArmorMapping 286-295",
            compact_bad.empty?, compact_bad.inspect)
    else
      check("ArmorMapping runtime storage", false, "missing")
    end

    # Phase 31：Equipment Combat / Combo Authority。
    equip_runtime_version = safe_call(nil) { $imported["FS Equipment Runtime Authority"] }
    check("FS Equipment Runtime Authority >= 1.2",
          equip_runtime_version != nil && equip_runtime_version.to_s >= "1.2",
          equip_runtime_version)
    combo_final_version = safe_call(nil) { $imported["FS EquipmentCombo Opening Skill Fix"] }
    check("EquipmentCombo OpeningSkill Final >= 2.0",
          combo_final_version != nil && combo_final_version.to_s >= "2.0",
          combo_final_version)
    check("EquipmentCombo state ownership storage API",
          Game_Actor.method_defined?(:albert_combo_register_owned_summon_states) &&
          Game_Actor.method_defined?(:albert_combo_clear_owned_summon_states))
    check("BattleIntegrity prepare wrapper retired",
          !Scene_Battle.method_defined?(:albert_bif_old_prepare_equipment_combo_battle_effects))
  end
end
