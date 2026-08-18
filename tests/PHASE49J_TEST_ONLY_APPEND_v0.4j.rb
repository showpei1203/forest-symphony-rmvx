#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_AutoRegression_Harness v0.4i2
# 【用途】Forest Symphony 測試專用自動回歸入口。只在 RPG Maker VX 的 $TEST 模式
#         生效，提供地圖快捷鍵、統一 LOG、ASSERT、例外捕捉，以及可回復的戰鬥 Smoke
#         Fixture。正式遊戲完全不啟用。
# 【快捷鍵】Scene_Map 且 $TEST=true：
#         Shift + F9：執行非戰鬥回歸，整合 FS_NonBattleValidation 與 Harness self-check。
#         Ctrl  + F9：執行戰鬥 Smoke Regression，自動建立暫時 Fixture、進入戰鬥、
#                    做基本 ASSERT、短暫跑數十幀後自動退出並還原測試前遊戲狀態。
#         F9：維持 RPG Maker VX 原生 Debug，不被本頁取代。
# 【LOG】FS_AutoRegression_LATEST.log
#         主要標籤：[SUITE] [FIXTURE] [ASSERT] [VALIDATION] [RNG] [BATTLE]
#                   [PREBATTLE] [EQUIP] [REFRESH] [WAIT] [EXCEPTION] [SUMMARY]
# 【主要機制】
#   1. 快捷鍵只攔截 Scene_Map#update_call_debug，避免與戰鬥內 ATB 的 Ctrl/Shift 衝突。
#   2. 使用 latch 防止 Input.press?(F9) 長按時每幀重複啟動。
#   3. Battle Smoke 啟動前以「逐項 Marshal」保存真正會被戰鬥修改的核心遊戲資料；
#      Map／Player／Fog／ATS 等附加物件個別嘗試序列化，若含 Sprite／Bitmap／Viewport
#      等 RGSS native object 則只記錄 SKIP，不再讓整個 Snapshot 失敗。戰鬥結束或例外後，
#      在下一個 Scene_Map#start 執行前還原可安全保存的資料。
#   4. Battle Smoke 使用現有資料庫中第一個有效 Troop 與現有 Party；若 Party 為空，
#      暫時加入第一個有效 Actor。所有暫時改動都由 snapshot 還原。
#   5. Battle Fixture 可在 Snapshot 之後、Scene_Battle 之前透過 prepare_battle_fixture_on_map
#      完成裝備／物品前置，再由 prebattle_wait_frames 指定數個 Scene_Map frame 的等待。
#      等待完成才設定 next_scene="battle"，避免同一幀換裝後立刻進戰鬥。
#   6. Snapshot restore 後、Summary 前呼叫 after_battle_snapshot_restore，供 Fixture 驗證
#      測試裝備／物品已確實還原。
#   7. AI Decision RNG 在 Battle Smoke 中固定 seed=12345，正式遊戲仍使用原 Kernel.rand。
# 【目前範圍】v0.4i2 保留 Phase49B～49H SEALED semantic；Phase49I2 為 TEST-only lifecycle expectation fix。實機 0.4i1 已證明 Map/Ring/SoulBook/Menu 兩輪建立、重建與 terminate cleanup 全部正常，僅 hide 後 TEST 錯把 Normal Minimap 的正式 refresh_interval=4 視為單幀 immediate bitmap dispose。本版在 hide 後先驗 visible flag 即時 OFF 與 player marker 單幀清除，再於正式 refresh interval 內 bounded update 驗 minimap bitmap 清除；不修改任何 Formal Runtime。
#         Shift+F9 Nonbattle Runtime Semantic II：Ring Menu、Quest、Enemy Book、Normal
#         Minimap、Random Dungeon facade；Phase49C2 只修 TEST cleanup，使用 Ruby 1.8-safe
#         private remove_instance_variable 呼叫，確保原本不存在的 Game_Temp / module cache
#         ivar 在 fixture 後真正移除，並輸出 exact-restore mismatch 明細。
# 【呼叫方式／範例】測試模式可直接：
#         FS_TEST_HARNESS.run_nonbattle
#         FS_TEST_HARNESS.run_battle_smoke
#         FS_TEST_HARNESS.assert("標籤", condition, "detail")
# 【設定／可調參數】LOG_FILE、BATTLE_SMOKE_FRAMES、AI_SEED、COMBAT_SEED。
# 【依賴／載入順序】必須放在全部 Runtime、FS_NONBATTLE_VALIDATION 之後，Main 之前，
#         才能成為 Scene_Map / Scene_Battle 的最後測試包裝層。
# 【相關素材】不新增 Graphics／Audio。Battle Smoke 只使用現有 Actor、Troop、Enemy 與
#         Battleback 等資料；素材缺失仍會由真實 Runtime 暴露並寫入例外 LOG。
# 【安全規則】正式遊戲 $TEST=false 時快捷鍵入口直接停用；不得在正式流程自動啟用
#         deterministic RNG。Harness 的測試資料不得寫回 Data/*.rvdata。
# 【來源／授權】Forest Symphony 專案自製測試基礎設施；RGSS2 / Ruby 1.8 相容寫法。
#==============================================================================

$imported = {} if $imported == nil
$imported["FS AutoRegression Harness"] = "0.4i2"

module FS_TEST_HARNESS
  VERSION = "0.4j"
  LOG_FILE = "FS_AutoRegression_LATEST.log"
  BATTLE_SMOKE_FRAMES = 360
  ACTION_QUEUE_FRAME = 2
  POST_ACTION_SETTLE_FRAMES = 24
  AI_SEED = 12345
  COMBAT_SEED = 149

  @hotkey_latched = false
  @suite = nil
  @pass_count = 0
  @fail_count = 0
  @warning_count = 0
  @battle_active = false
  @battle_frame = 0
  @battle_snapshot = nil
  @pending_restore = false
  @battle_result = nil
  @battle_fixture_queued = false
  @battle_action_executed = false
  @battle_action_complete_frame = nil
  @battle_forced_subject_object_id = nil
  @battle_forced_target_object_id = nil
  @battle_damage_seen = false
  @battle_combat_rng_count = 0
  @battle_combat_rng_trace = []
  @battle_exit_requested_by_harness = false
  @battle_exit_in_progress = false
  @battle_transition_pending = false
  @battle_transition_wait_total = 0
  @battle_transition_wait_done = 0
  @battle_transition_started_frame = nil

  def self.test_mode?
    return (defined?($TEST) != nil && $TEST == true)
  end

  def self.time_text
    return Time.now.strftime("%Y-%m-%d %H:%M:%S")
  rescue
    return Time.now.to_s
  end

  def self.reset_log
    File.open(LOG_FILE, "w") do |file|
      file.write("Forest Symphony AutoRegression Log\n")
      file.write("Harness Version: #{VERSION}\n")
      file.write("Generated: #{time_text}\n")
      file.write("=" * 78 + "\n")
    end
  end

  def self.log(text = "")
    File.open(LOG_FILE, "a") do |file|
      file.write(text.to_s + "\n")
    end
  rescue Exception
    # LOG 自己失敗時不能再遞迴寫 LOG。
  end

  def self.begin_suite(name)
    reset_log
    @suite = name.to_s
    @pass_count = 0
    @fail_count = 0
    @warning_count = 0
    log("[SUITE] #{@suite}")
    log("[START] #{time_text}")
    return true
  end

  def self.assert(label, result, detail = nil)
    ok = (result == true)
    if ok
      @pass_count += 1
      text = "[ASSERT] PASS #{label}"
    else
      @fail_count += 1
      text = "[ASSERT] FAIL #{label}"
    end
    text += " | #{detail}" if detail != nil && detail.to_s != ""
    log(text)
    return ok
  end

  def self.warn(label, detail = nil)
    @warning_count += 1
    text = "[WARN] #{label}"
    text += " | #{detail}" if detail != nil && detail.to_s != ""
    log(text)
  end

  def self.exception(error, where = nil)
    @fail_count += 1
    text = "[EXCEPTION]"
    text += " where=#{where}" if where != nil
    text += " #{error.class}: #{error.message}"
    log(text)
    begin
      if error.backtrace != nil
        error.backtrace[0, 20].each { |line| log("[TRACE] #{line}") }
      end
    rescue
    end
  end

  def self.finish_suite(status = nil)
    if status == nil
      status = @fail_count.to_i == 0 ? "PASS" : "FAIL"
    end
    log("[SUMMARY] suite=#{@suite} result=#{status} pass=#{@pass_count} fail=#{@fail_count} warn=#{@warning_count}")
    log("[END] #{time_text}")
    notify("FS AutoRegression #{status}：#{LOG_FILE}")
    @suite = nil
    return status
  end

  def self.notify(text)
    begin
      if defined?($game_message) && $game_message != nil &&
         $game_message.respond_to?(:texts) && $game_message.texts != nil
        $game_message.texts.push(text.to_s)
      end
    rescue
    end
  end

  #--------------------------------------------------------------------------
  # ● Test Harness 狀態訊息判定
  #--------------------------------------------------------------------------
  # FS 的 PASS/FAIL 通知目前仍借用 Game_Message 顯示。VX 原生 Scene_Map
  # 在 Game_Message.visible 時不會呼叫 update_call_debug，因此若上一個測試結果
  # 還停在畫面上，下一次 Ctrl/Shift+F9 會完全收不到。
  #
  # 此處只允許自動清除「Harness 自己產生的通知」，正常事件對話絕不清除。
  #--------------------------------------------------------------------------
  def self.harness_notification_visible?
    return false unless defined?($game_message) && $game_message != nil
    return false unless $game_message.respond_to?(:texts)
    texts = $game_message.texts
    return false if texts == nil || texts.empty?
    has_fs_notice = false
    for text in texts
      next if text == nil || text.to_s.empty?
      if text.to_s.index("FS AutoRegression") == 0
        has_fs_notice = true
      else
        return false
      end
    end
    return has_fs_notice
  rescue
    return false
  end

  def self.clear_harness_notification
    return false unless harness_notification_visible?
    begin
      $game_message.clear if $game_message.respond_to?(:clear)
      $game_message.visible = false if $game_message.respond_to?(:visible=)
      log("[HOTKEY] previous harness notification cleared") if @suite != nil
      return true
    rescue
      return false
    end
  end

  #--------------------------------------------------------------------------
  # ● Scene_Map#update 前置快捷鍵探測
  #--------------------------------------------------------------------------
  # update_call_debug 位於 VX 的 `unless $game_message.visible` 內，不能作為唯一
  # Harness 入口。這個前置探測只在 Test Play 啟用，並仍由 latch 防止長按重複。
  # 一般事件訊息可見時不啟動測試；只有 Harness 自己的 PASS/FAIL 通知可自動清除。
  #--------------------------------------------------------------------------
  def self.pre_map_update_hotkey(scene)
    return false unless test_mode?
    f9 = Input.press?(Input::F9)
    shift = Input.press?(Input::SHIFT)
    ctrl = Input.press?(Input::CTRL)
    combo = f9 && (shift || ctrl)

    unless combo
      @hotkey_latched = false
      return false
    end

    if defined?($game_message) && $game_message != nil &&
       $game_message.respond_to?(:visible) && $game_message.visible
      if harness_notification_visible?
        clear_harness_notification
      else
        return false
      end
    end

    return handle_map_debug_hotkey(scene)
  rescue Exception => e
    begin_suite("HOTKEY_PREUPDATE_EXCEPTION") if @suite == nil
    exception(e, "pre_map_update_hotkey")
    finish_suite("FAIL")
    return true
  end

  #--------------------------------------------------------------------------
  # ● 地圖快捷鍵入口
  #--------------------------------------------------------------------------
  def self.handle_map_debug_hotkey(scene)
    return false unless test_mode?
    f9 = Input.press?(Input::F9)
    shift = Input.press?(Input::SHIFT)
    ctrl = Input.press?(Input::CTRL)
    combo = f9 && (shift || ctrl)
    unless combo
      @hotkey_latched = false
      return false
    end

    # 按住組合鍵時持續吞掉原 F9 Debug，直到放開為止。
    return true if @hotkey_latched
    @hotkey_latched = true

    if ctrl
      run_battle_smoke
    else
      run_nonbattle
    end
    return true
  rescue Exception => e
    begin_suite("HOTKEY_EXCEPTION") if @suite == nil
    exception(e, "handle_map_debug_hotkey")
    finish_suite("FAIL")
    return true
  end

  #--------------------------------------------------------------------------
  # ● Phase 33：第一批 Authority Fixtures
  #--------------------------------------------------------------------------
  def self.fixture_section(name)
    log("[FIXTURE] #{name}")
    begin
      yield
    rescue Exception => e
      exception(e, "fixture:#{name}")
    end
  end

  def self.assert_equal(label, expected, actual)
    detail = "expected=#{expected.inspect} actual=#{actual.inspect}"
    return assert(label, expected == actual, detail)
  end

  def self.run_authority_fixtures
    fixture_setup_authority
    fixture_ai_rng
    fixture_skill_cost_parser
    fixture_element_chart
    fixture_equipment_skill_parser
    fixture_armor_mapping
    fixture_combo_data_integrity
    return true
  rescue Exception => e
    exception(e, "run_authority_fixtures")
    return false
  end

  # Setup：不硬編碼資料筆數，直接驗證 Adapter 與 MasterSetup 單一資料來源鏡像。
  def self.fixture_setup_authority
    fixture_section("SETUP-AUTHORITY") do
      assert("Setup Authority READY",
             defined?(FS_DB_AUTOSET) && FS_DB_AUTOSET.authority_ready?,
             defined?(FS_DB_AUTOSET) ?
               "source=#{FS_DB_AUTOSET.authority_source} version=#{FS_DB_AUTOSET.authority_version}" :
               "FS_DB_AUTOSET missing")
      assert("MasterSetup exists", defined?(FS_MASTER_SETUP) != nil)
      if defined?(FS_DB_AUTOSET) && defined?(FS_MASTER_SETUP)
        pairs = [
          ["Skills",  FS_DB_AUTOSET_SKILLS::DATA,          FS_MASTER_SETUP::SKILLS::DATA],
          ["States",  FS_DB_AUTOSET_STATES::DATA,          FS_MASTER_SETUP::STATES::DATA],
          ["Items",   FS_DB_AUTOSET_ITEMS::DATA,           FS_MASTER_SETUP::ITEMS::DATA],
          ["Weapons", FS_DB_AUTOSET_WEAPONS::DATA,         FS_MASTER_SETUP::WEAPONS::DATA],
          ["Armors",  FS_DB_AUTOSET_ARMORS::DATA,          FS_MASTER_SETUP::ARMORS::DATA],
          ["Classes", FS_DB_AUTOSET_CLASS_LEARNINGS::DATA, FS_MASTER_SETUP::CLASSES::DATA],
          ["Enemies", FS_DB_AUTOSET_ENEMIES::DATA,         FS_MASTER_SETUP::ENEMIES::DATA]
        ]
        for entry in pairs
          label = entry[0]
          adapter = entry[1]
          master = entry[2]
          missing = master.keys - adapter.keys
          extra = adapter.keys - master.keys
          changed = (master.keys & adapter.keys).select { |id| adapter[id] != master[id] }
          assert("Setup #{label} runtime projection covers MasterSetup",
                 missing.empty?,
                 "adapter=#{adapter.size} master=#{master.size} " +
                 "missing=#{missing.size} extra=#{extra.size} changed=#{changed.size}")
          log("[SETUP] #{label} runtime_projection " +
              "adapter=#{adapter.size} master=#{master.size} " +
              "extra=#{extra.size} changed=#{changed.size}")
          assert("Setup #{label} non-empty", master.size > 0, master.size)
        end
      end
    end
  end

  # AI：固定 seed 的輸出與 trace 都必須可重現，結束後 deterministic mode 必須 OFF。
  def self.fixture_ai_rng
    fixture_section("AI-RNG") do
      assert("FS_AI_RANDOM exists", defined?(FS_AI_RANDOM) != nil)
      if defined?(FS_AI_RANDOM)
        assert("AI RNG default OFF", !FS_AI_RANDOM.enabled?)
        values = []
        begin
          FS_AI_RANDOM.enable(12345)
          values << FS_AI_RANDOM.rand(100,  :fixture_a)
          values << FS_AI_RANDOM.rand(10,   :fixture_b)
          values << FS_AI_RANDOM.rand(7,    :fixture_c)
          values << FS_AI_RANDOM.rand(1000, :fixture_d)
          assert_equal("AI RNG deterministic values", [6, 5, 3, 573], values)
          lines = FS_AI_RANDOM.trace_lines
          assert("AI RNG trace count", lines.size == 4, lines.size)
          log("[RNG] #{lines.join(' | ')}")
        ensure
          FS_AI_RANDOM.disable
        end
        assert("AI RNG restored OFF", !FS_AI_RANDOM.enabled?)
      end
    end
  end

  # Skill Cost：用本地 RPG::Skill 驗證 Parser，不改正式 $data_skills。
  def self.fixture_skill_cost_parser
    fixture_section("SKILL-COST") do
      assert("Skill Cost Authority exists", defined?(FS_SKILL_COST_ALLFIX) != nil)
      if defined?(FS_SKILL_COST_ALLFIX) && defined?(RPG::Skill)
        skill = RPG::Skill.new
        skill.mp_cost = 3
        skill.note = "<costo hp:12>\n" +
                     "<costo hp:10%>\n" +
                     "<costo mp:15>\n" +
                     "<costo mp:25%>\n" +
                     "<costo oro:30>\n" +
                     "<costo var:7>\n" +
                     "<usa oggetto:5>\n" +
                     "<costo angry:11>\n" +
                     "<costo state:9>"
        data = FS_SKILL_COST_ALLFIX.parse(skill, true)
        assert_equal("SkillCost hp fixed", 12, data[:hp])
        assert_equal("SkillCost hp percent", 10, data[:hp_per])
        assert_equal("SkillCost mp fixed", 15, data[:mp_fixed])
        assert_equal("SkillCost mp percent", 25, data[:mp_per])
        assert_equal("SkillCost gold", 30, data[:gold])
        assert_equal("SkillCost variable", 7, data[:var])
        assert_equal("SkillCost item", 5, data[:item])
        assert_equal("SkillCost angry", 11, data[:angry])
        assert_equal("SkillCost state", 9, data[:state])
        assert_equal("SkillCost fixed MP sync", 15, skill.mp_cost)
      end
    end
  end

  # Element：測純 Type Chart，避免建立／修改實際 Battler。
  def self.fixture_element_chart
    fixture_section("ELEMENT") do
      assert("Element FinalAuthority exists", defined?(FS_ELEMENT_FINAL) != nil)
      if defined?(FS_ELEMENT_FINAL)
        assert_equal("Grass -> Water", 2.0,
                     FS_ELEMENT_FINAL.type_multiplier(:grass, :water, nil))
        assert_equal("Electric -> Ground immunity", 0.0,
                     FS_ELEMENT_FINAL.type_multiplier(:electric, :ground, nil))
        assert_equal("Normal -> Ghost immunity", 0.0,
                     FS_ELEMENT_FINAL.type_multiplier(:normal, :ghost, nil))
        assert_equal("Fire -> Grass/Steel dual", 4.0,
                     FS_ELEMENT_FINAL.type_multiplier(:fire, :grass, :steel))
      end
    end
  end

  # Equipment Skill：本地 Armor 同時測 Modern Algebra 與 Shanghai 兩種 Parser。
  def self.fixture_equipment_skill_parser
    fixture_section("EQUIPMENT-SKILL") do
      assert("Equipment Skill Authority loaded",
             $imported && $imported["FS Equipment Skill Authority"] != nil,
             $imported ? $imported["FS Equipment Skill Authority"] : nil)
      if defined?(RPG::Armor)
        ids = [193, 194, 195]
        missing = ids.select { |id| $data_skills == nil || $data_skills[id] == nil }
        assert("Fixture skills 193-195 exist", missing.empty?, missing.inspect)
        if missing.empty?
          armor = RPG::Armor.new
          armor.note = "\\ls[193, 1]\n<equipskill: 194, 195>"
          teaching = armor.skill_ids
          dynamic = armor.skills.compact.collect { |skill| skill.id }
          assert_equal("Equipment \\ls parser", [[193, 1]], teaching)
          assert_equal("Equipment <equipskill> parser", [194, 195], dynamic.sort)
        end
      end
    end
  end

  # ArmorMapping：正式 Compact ID 必須存在，舊 mapping 不得復活。
  def self.fixture_armor_mapping
    fixture_section("ARMOR-MAPPING") do
      assert("ForestSymphonyDB exists", defined?(ForestSymphonyDB) != nil)
      assert("ArmorMapping exists", defined?(ArmorMapping) != nil)
      if defined?(ForestSymphonyDB)
        expected = {286=>7,287=>8,288=>9,289=>10,290=>11,
                    291=>12,292=>13,293=>14,294=>15,295=>16}
        assert_equal("Database Compact Armor mapping", expected,
                     ForestSymphonyDB::ARMOR_TO_ACTOR)
        if defined?(ArmorMapping) && ArmorMapping.respond_to?(:mapping)
          runtime = ArmorMapping.mapping
          bad = expected.keys.select { |id| runtime[id] != expected[id] }
          assert("Runtime Compact Armor mapping", bad.empty?, bad.inspect)
          legacy = {732=>7,733=>8,734=>9,735=>10,736=>11,
                    737=>12,738=>13,739=>14,740=>15,741=>16}
          stale = legacy.keys.select { |id| runtime[id] == legacy[id] }
          assert("Legacy Armor mapping absent", stale.empty?, stale.inspect)
        end
      end
    end
  end

  # EquipmentCombo：掃描正式資料庫中的 combo 標籤，所有引用都必須能解析。
  def self.fixture_combo_data_integrity
    fixture_section("EQUIPMENT-COMBO") do
      items = []
      [$data_weapons, $data_armors].each do |group|
        next if group == nil
        group.compact.each do |item|
          next unless item.respond_to?(:albert_combo_defined?)
          items << item if item.albert_combo_defined?
        end
      end
      assert("EquipmentCombo definitions found", items.size > 0, items.size)

      errors = []
      mapping = nil
      mapping = ArmorMapping.mapping if defined?(ArmorMapping) && ArmorMapping.respond_to?(:mapping)
      for item in items
        prefix = "#{item.class}##{item.id}:#{item.name}"
        actor_id = item.albert_combo_actor_id.to_i
        if actor_id > 0 && ($data_actors == nil || $data_actors[actor_id] == nil)
          errors << "#{prefix} actor=#{actor_id} missing"
        end
        item.albert_combo_required_armors.each do |id|
          errors << "#{prefix} armor=#{id} missing" if $data_armors == nil || $data_armors[id] == nil
        end
        item.albert_combo_required_weapons.each do |id|
          errors << "#{prefix} weapon=#{id} missing" if $data_weapons == nil || $data_weapons[id] == nil
        end
        item.albert_combo_skill_ids.each do |id|
          errors << "#{prefix} skill=#{id} missing" if $data_skills == nil || $data_skills[id] == nil
        end
        item.albert_combo_actor_state_ids.each do |id|
          errors << "#{prefix} actor_state=#{id} missing" if $data_states == nil || $data_states[id] == nil
        end
        item.albert_combo_summon_state_ids.each do |id|
          errors << "#{prefix} summon_state=#{id} missing" if $data_states == nil || $data_states[id] == nil
        end
        opening = item.albert_combo_summon_opening_skill_id.to_i
        if opening > 0 && ($data_skills == nil || $data_skills[opening] == nil)
          errors << "#{prefix} opening_skill=#{opening} missing"
        end

        summon_id = item.albert_combo_summon_actor_id.to_i
        if summon_id <= 0 && mapping != nil
          item.albert_combo_required_armors.each do |armor_id|
            if mapping[armor_id] != nil
              summon_id = mapping[armor_id].to_i
              break
            end
          end
        end
        if opening > 0
          if summon_id <= 0
            errors << "#{prefix} opening skill has no summon mapping"
          elsif $data_actors == nil || $data_actors[summon_id] == nil
            errors << "#{prefix} summon_actor=#{summon_id} missing"
          end
        end
      end

      assert("EquipmentCombo references valid", errors.empty?,
             errors.empty? ? "checked=#{items.size}" : errors[0, 8].join(" || "))
      log("[EQUIP] combo_items=#{items.size} errors=#{errors.size}")
    end
  end

  #--------------------------------------------------------------------------
  # ● Phase49B：大型飛行船 Overlay / Fog Runtime Semantic
  #--------------------------------------------------------------------------
  # TEST-only：不觸發真正地圖移動或 Save/Load。以 detached Game_Player 直接驗證
  # FS_FLIGHT_VISUAL 的保存／隱藏／降落還原／強制離開清理語意。
  def self.run_phase49b_vehicle_overlay_semantic
    fail_before = @fail_count.to_i
    log("[FIXTURE] PHASE49B-FLIGHT-VISUAL")

    provider_ready =
      defined?(FS_FLIGHT_VISUAL) != nil &&
      defined?(Game_Player) != nil &&
      defined?(Shuu_Fog) != nil &&
      defined?($fog_data) != nil &&
      $fog_data.is_a?(Hash) &&
      $game_switches != nil &&
      $game_map != nil
    assert("Phase49B Flight Visual provider/globals ready", provider_ready,
           provider_ready ? "vehicle_types=#{FS_FLIGHT_VISUAL::VEHICLE_TYPES.inspect}" : "provider missing")
    return false unless provider_ready

    method_names = [
      :fs_flight_visual_begin,
      :fs_flight_visual_start_landing,
      :fs_flight_visual_restore,
      :fs_flight_visual_cleanup_blank_fog,
      :fs_flight_visual_sync
    ]
    methods_ready = method_names.all? do |name|
      Game_Player.method_defined?(name) ||
        Game_Player.private_method_defined?(name)
    end
    switch_ids = FS_FLIGHT_VISUAL::HIDDEN_OVERLAY_SWITCHES
    methods_ready &&= (switch_ids == [202, 203, 204, 205])
    assert("Phase49B Flight Visual formal method/switch contract exact", methods_ready,
           "methods=#{method_names.inspect} switches=#{switch_ids.inspect}")

    map_id = $game_map.map_id.to_i
    map_ready = map_id > 0
    assert("Phase49B current Map/Fog slot usable", map_ready,
           "map_id=#{map_id} fog_hash=#{$fog_data.class}")
    return false unless methods_ready && map_ready

    formal_player_oid = $game_player.object_id
    detached = Game_Player.new
    class << detached
      def fs_flight_current_spriteset
        return nil
      end
    end
    assert("Phase49B detached Game_Player created without replacing formal player",
           detached.object_id != formal_player_oid && $game_player.object_id == formal_player_oid,
           "detached=#{detached.object_id} formal=#{formal_player_oid}")

    switch_before = {}
    switch_ids.each { |switch_id| switch_before[switch_id] = $game_switches[switch_id] }
    fog_had_before = $fog_data.has_key?(map_id)
    fog_before = nil
    if fog_had_before && $fog_data[map_id] != nil
      fog_before = Marshal.load(Marshal.dump($fog_data[map_id]))
    end
    fog_transition_before = $fog_transition

    saved_ok = true
    hidden_ok = true
    restored_ok = true
    fog_existing_ok = true
    pattern_rows = []
    no_fog_install_ok = false
    no_fog_cleanup_ok = false
    forced_off_ok = false
    error = nil

    begin
      16.times do |mask|
        expected = {}
        switch_ids.each_with_index do |switch_id, index|
          value = ((mask & (1 << index)) != 0)
          expected[switch_id] = value
          $game_switches[switch_id] = value
        end

        base_fog = ["phase49b_base", 3, -2, 77, 1]
        $fog_data[map_id] = base_fog.clone
        $fog_transition = 0
        player = Game_Player.new
        class << player
          def fs_flight_current_spriteset
            return nil
          end
        end

        player.fs_flight_visual_begin
        saved = player.instance_variable_get("@fs_flight_overlay_states")
        row_saved = switch_ids.all? do |switch_id|
          saved != nil && saved[switch_id] == expected[switch_id]
        end
        row_hidden = switch_ids.all? { |switch_id| $game_switches[switch_id] == false }
        flight_fog = [
          FS_FLIGHT_VISUAL::FOG_NAME,
          FS_FLIGHT_VISUAL::FOG_SPEED_X,
          FS_FLIGHT_VISUAL::FOG_SPEED_Y,
          FS_FLIGHT_VISUAL::FOG_OPACITY,
          FS_FLIGHT_VISUAL::FOG_BLEND
        ]
        row_flight_fog = ($fog_data[map_id] == flight_fog)

        player.fs_flight_visual_start_landing
        row_landing_fog = ($fog_data[map_id] == base_fog)
        player.fs_flight_visual_restore
        row_restored = switch_ids.all? do |switch_id|
          $game_switches[switch_id] == expected[switch_id]
        end
        row_clean =
          !player.fs_flight_visual_active? &&
          player.instance_variable_get("@fs_flight_overlay_states") == nil &&
          player.instance_variable_get("@fs_flight_fog_states") == nil

        saved_ok &&= row_saved
        hidden_ok &&= row_hidden
        restored_ok &&= (row_restored && row_clean)
        fog_existing_ok &&= (row_flight_fog && row_landing_fog && $fog_data[map_id] == base_fog)
        pattern_rows << [mask, row_saved, row_hidden, row_restored, row_flight_fog, row_landing_fog, row_clean]
      end

      # 原地圖沒有 Fog 的情況：降落後空白 transition 完成時必須刪除暫時 slot。
      no_fog_expected = {202=>true, 203=>false, 204=>true, 205=>false}
      no_fog_expected.each { |switch_id, value| $game_switches[switch_id] = value }
      $fog_data.delete(map_id)
      $fog_transition = 0
      no_fog_player = Game_Player.new
      class << no_fog_player
        def fs_flight_current_spriteset
          return nil
        end
      end
      no_fog_player.fs_flight_visual_begin
      expected_flight_fog = [
        FS_FLIGHT_VISUAL::FOG_NAME,
        FS_FLIGHT_VISUAL::FOG_SPEED_X,
        FS_FLIGHT_VISUAL::FOG_SPEED_Y,
        FS_FLIGHT_VISUAL::FOG_OPACITY,
        FS_FLIGHT_VISUAL::FOG_BLEND
      ]
      no_fog_install_ok =
        $fog_data.has_key?(map_id) &&
        $fog_data[map_id] == expected_flight_fog &&
        switch_ids.all? { |switch_id| $game_switches[switch_id] == false }
      no_fog_player.fs_flight_visual_start_landing
      no_fog_player.fs_flight_visual_restore
      no_fog_overlay_restore = no_fog_expected.all? do |switch_id, value|
        $game_switches[switch_id] == value
      end
      $fog_transition = 0
      no_fog_player.fs_flight_visual_cleanup_blank_fog
      no_fog_cleanup_ok =
        no_fog_overlay_restore &&
        !$fog_data.has_key?(map_id) &&
        no_fog_player.instance_variable_get("@fs_flight_pending_fog_delete_map_id") == nil

      # 非正常 get_off，而是其他 Runtime 直接把 vehicle_type 改離飛行型時，sync 也必須收尾。
      forced_expected = {202=>false, 203=>true, 204=>false, 205=>true}
      forced_expected.each { |switch_id, value| $game_switches[switch_id] = value }
      forced_fog = ["phase49b_force", -2, 3, 66, 2]
      $fog_data[map_id] = forced_fog.clone
      $fog_transition = 0
      forced_player = Game_Player.new
      class << forced_player
        def fs_flight_current_spriteset
          return nil
        end
      end
      forced_player.instance_variable_set("@vehicle_type", 4)
      forced_player.fs_flight_visual_sync
      forced_hidden = switch_ids.all? { |switch_id| $game_switches[switch_id] == false }
      forced_player.instance_variable_set("@vehicle_type", -1)
      forced_player.fs_flight_visual_sync
      forced_restored = forced_expected.all? do |switch_id, value|
        $game_switches[switch_id] == value
      end
      forced_off_ok =
        forced_hidden && forced_restored &&
        !forced_player.fs_flight_visual_active? &&
        $fog_data[map_id] == forced_fog
    rescue Exception => e
      error = e
      exception(e, "phase49b_vehicle_overlay_semantic")
    ensure
      switch_before.each { |switch_id, value| $game_switches[switch_id] = value }
      if fog_had_before
        $fog_data[map_id] = fog_before == nil ? nil : Marshal.load(Marshal.dump(fog_before))
      else
        $fog_data.delete(map_id)
      end
      $fog_transition = fog_transition_before
    end

    assert("Phase49B all 16 Overlay permutations snapshot exact", saved_ok,
           "rows=#{pattern_rows.inspect}")
    assert("Phase49B all 16 Overlay permutations hidden during flight", hidden_ok,
           "rows=#{pattern_rows.inspect}")
    assert("Phase49B all 16 Overlay permutations restore exact after landing", restored_ok,
           "rows=#{pattern_rows.inspect}")
    assert("Phase49B existing Fog is replaced for flight then restored exactly", fog_existing_ok,
           "rows=#{pattern_rows.inspect}")
    assert("Phase49B no-Fog takeoff installs flight Fog without visual Spriteset dependency",
           no_fog_install_ok)
    assert("Phase49B no-Fog landing removes temporary blank Fog slot after transition",
           no_fog_cleanup_ok)
    assert("Phase49B forced vehicle-type exit sync restores Overlay/Fog and deactivates",
           forced_off_ok)

    globals_ok = switch_ids.all? do |switch_id|
      $game_switches[switch_id] == switch_before[switch_id]
    end
    current_fog_had = $fog_data.has_key?(map_id)
    current_fog = current_fog_had ? $fog_data[map_id] : nil
    fog_restore_ok = (current_fog_had == fog_had_before)
    if fog_restore_ok && fog_had_before
      fog_restore_ok = (current_fog == fog_before)
    end
    globals_ok &&= fog_restore_ok && ($fog_transition == fog_transition_before)
    assert("Phase49B fixture restores Overlay/Fog globals exactly", globals_ok,
           "switches=#{switch_before.inspect} fog_had=#{fog_had_before} transition=#{fog_transition_before}")
    assert("Phase49B detached fixture preserves formal Game_Player identity",
           $game_player.object_id == formal_player_oid,
           "formal=#{formal_player_oid} current=#{$game_player.object_id}")

    ready =
      error == nil && saved_ok && hidden_ok && restored_ok &&
      fog_existing_ok && no_fog_install_ok && no_fog_cleanup_ok &&
      forced_off_ok && globals_ok && @fail_count.to_i == fail_before
    log("[PHASE49B_FLIGHT_VISUAL] permutations=16 saved=#{saved_ok} hidden=#{hidden_ok} restored=#{restored_ok} fog_existing=#{fog_existing_ok} no_fog_install=#{no_fog_install_ok} no_fog_cleanup=#{no_fog_cleanup_ok} forced_off=#{forced_off_ok} globals=#{globals_ok} ready=#{ready}")
    assert("Phase49B Vehicle / Overlay / Fog Runtime Semantic completed", ready,
           "fail_delta=#{@fail_count.to_i - fail_before}")
    return ready
  end

  #--------------------------------------------------------------------------
  # ● Phase49C：Ring / Quest / EnemyBook / Minimap / RandomDungeon Runtime Semantic
  #--------------------------------------------------------------------------
  # TEST-only：不執行真正地圖轉移、不進入 UI main loop、不碰 Save/Load。
  # 只呼叫正式 Runtime API，並在結束時還原 Scene、Switch、Game_System、
  # Game_Party、Game_Temp 與 Minimap module cache。
  # RGSS2 / Ruby 1.8-safe instance-variable existence helper.
  # Object#instance_variable_defined? is not available on the target runtime.
  def self.p49c_ivar_defined?(obj, name)
    target = name.to_s
    obj.instance_variables.each do |ivar|
      return true if ivar.to_s == target
    end
    return false
  end

  # RGSS2 / Ruby 1.8：remove_instance_variable 在目標 runtime 可能不是
  # 可用 explicit receiver 呼叫的 public method。透過 __send__ 呼叫 private
  # method，才能把 fixture 期間新建立、baseline 原本不存在的 ivar 真正刪除。
  def self.p49c_remove_ivar(obj, name)
    return true unless p49c_ivar_defined?(obj, name)
    begin
      obj.__send__(:remove_instance_variable, name)
    rescue Exception
      begin
        obj.instance_eval { remove_instance_variable(name) }
      rescue Exception
        return false
      end
    end
    return !p49c_ivar_defined?(obj, name)
  end

  # Phase49C5：whole-root Marshal restore 已撤除。
  # 原因：RGSS2/Ruby 1.8 的 live Game_System / Game_Party graph 內含 Hash、
  # 以及指向 $data_* RPG 物件的持久 reference。整體 Marshal.clone 後再遞迴
  # 拼回，會改變 Hash 內部排列，並把正式資料庫 reference 換成 clone。
  # 本 helper 只 snapshot fixture 真正 touched 的單一 ivar；Array/Hash 使用
  # shallow dup 保存原 table/order 與 nested object reference，restore 時透過
  # #replace 原地回復，保留原 container object identity。
  def self.p49c_snapshot_ivar_transactional(obj, name)
    defined_flag = p49c_ivar_defined?(obj, name)
    value = defined_flag ? obj.instance_variable_get(name) : nil
    copy = value
    if defined_flag && (value.is_a?(Array) || value.is_a?(Hash))
      begin
        copy = value.dup
      rescue Exception
        copy = value
      end
    end
    return {:defined=>defined_flag, :object=>value, :copy=>copy}
  end

  def self.p49c_restore_ivar_transactional(obj, name, snap)
    unless snap[:defined]
      return p49c_remove_ivar(obj, name)
    end
    original = snap[:object]
    copy = snap[:copy]
    begin
      if original.is_a?(Array) && copy.is_a?(Array)
        original.replace(copy)
        obj.instance_variable_set(name, original)
      elsif original.is_a?(Hash) && copy.is_a?(Hash)
        original.replace(copy)
        obj.instance_variable_set(name, original)
      else
        obj.instance_variable_set(name, original)
      end
      return true
    rescue Exception
      begin
        obj.instance_variable_set(name, original)
        return true
      rescue Exception
        return false
      end
    end
  end

  # Nested exploration table 的 current-map Hash 會被 reveal_cell 原地修改。
  # outer Hash 的 shallow dup 會保留同一個 child reference，因此 child 也要
  # 自己保存一份 shallow table，restore 時先原地 replace child，再 restore outer。
  def self.p49c_snapshot_hash_child(snap, key)
    return {:present=>false} unless snap && snap[:defined]
    table = snap[:object]
    return {:present=>false} unless table.is_a?(Hash)
    present = table.has_key?(key)
    return {:present=>false} unless present
    child = table[key]
    child_copy = child
    if child.is_a?(Array) || child.is_a?(Hash)
      begin
        child_copy = child.dup
      rescue Exception
        child_copy = child
      end
    end
    return {:present=>true, :object=>child, :copy=>child_copy}
  end

  def self.p49c_restore_hash_child(snap)
    return true unless snap && snap[:present]
    original = snap[:object]
    copy = snap[:copy]
    begin
      if original.is_a?(Array) && copy.is_a?(Array)
        original.replace(copy)
      elsif original.is_a?(Hash) && copy.is_a?(Hash)
        original.replace(copy)
      end
      return true
    rescue Exception
      return false
    end
  end

  # Phase49C6：mutation detector 不得再用 Marshal.load(whole-root) clone。
  # baseline 對每個 live ivar 當場保存：原 object reference + 當下 Marshal bytes。
  # 後續比較只 dump 現行 live value，避免 clone Hash / DB reference graph 造成假陽性。
  def self.p49c_guard_identity_required?(value)
    return false if value == nil || value == true || value == false
    return false if value.is_a?(Numeric) || value.is_a?(Symbol)
    return true
  end

  def self.p49c_snapshot_object_guard(obj)
    rows = {}
    obj.instance_variables.each do |raw|
      name = raw.to_s.to_sym
      value = obj.instance_variable_get(name)
      bytes = nil
      begin
        bytes = Marshal.dump(value)
      rescue Exception
        bytes = nil
      end
      rows[name] = {:object=>value, :bytes=>bytes}
    end
    return {:ivars=>rows}
  end

  def self.p49c_guard_mismatches(obj, guard, ignored = [])
    base = guard[:ivars] || {}
    names = base.keys.collect { |x| x.to_s }
    obj.instance_variables.each { |x| names << x.to_s }
    rows = []
    names.uniq.each do |text|
      name = text.to_sym
      next if ignored.include?(name)
      had = base.has_key?(name)
      now = p49c_ivar_defined?(obj, name)
      if had != now
        rows << [name, :defined, had, now]
        next
      end
      next unless had
      snap = base[name]
      current = obj.instance_variable_get(name)
      same_value = false
      if snap[:bytes] != nil
        begin
          same_value = (Marshal.dump(current) == snap[:bytes])
        rescue Exception
          same_value = false
        end
      else
        begin
          same_value = (current == snap[:object])
        rescue Exception
          same_value = current.equal?(snap[:object])
        end
      end
      unless same_value
        rows << [name, :value]
        next
      end
      if p49c_guard_identity_required?(snap[:object]) &&
         !current.equal?(snap[:object])
        rows << [name, :identity]
      end
    end
    return rows
  rescue Exception => e
    return [[:__diagnostic_error__, e.class.to_s]]
  end

  # Transaction restore 後的 semantic + identity 驗證。
  # Array/Hash 不要求 Marshal byte representation 完全相同，因 Ruby 1.8 Hash
  # 內部排列不是 gameplay semantic；但要求原 container identity + logical value exact。
  def self.p49c_transaction_mismatch(obj, name, snap)
    now_defined = p49c_ivar_defined?(obj, name)
    return [name, :defined, snap[:defined], now_defined] if now_defined != snap[:defined]
    return nil unless snap[:defined]
    current = obj.instance_variable_get(name)
    original = snap[:object]
    copy = snap[:copy]
    if original.is_a?(Array) || original.is_a?(Hash)
      return [name, :identity] unless current.equal?(original)
      begin
        return [name, :value] unless current == copy
      rescue Exception
        return [name, :value]
      end
    else
      begin
        return [name, :value] unless current == original
      rescue Exception
        return [name, :identity] unless current.equal?(original)
      end
      if p49c_guard_identity_required?(original) && !current.equal?(original)
        return [name, :identity]
      end
    end
    return nil
  end

  def self.p49c_hash_child_mismatch(snap)
    return nil unless snap && snap[:present]
    original = snap[:object]
    copy = snap[:copy]
    if original.is_a?(Array) || original.is_a?(Hash)
      begin
        return [:exploration_child, :value] unless original == copy
      rescue Exception
        return [:exploration_child, :value]
      end
    end
    return nil
  end

  def self.p49c_log_mutation_checkpoint(label, switch_guard, system_guard, party_guard)
    sw = p49c_guard_mismatches($game_switches, switch_guard)
    sy = p49c_guard_mismatches($game_system, system_guard)
    pa = p49c_guard_mismatches($game_party, party_guard)
    log("[PHASE49C_MUTATION_CHECKPOINT] phase=#{label} switch=#{sw.inspect} system=#{sy.inspect} party=#{pa.inspect}")
  end

  def self.run_phase49c_nonbattle_runtime_semantic_ii
    fail_before = @fail_count.to_i
    log("[FIXTURE] PHASE49C-NONBATTLE-RUNTIME-II")

    provider_ready =
      defined?(FS_RING_MENU_ACTIONS) != nil &&
      defined?(Game_Quest) != nil &&
      defined?(QuestData) != nil &&
      defined?(FS_QUEST_ECONOMY) != nil &&
      defined?(FS_ENEMY_BOOK) != nil &&
      defined?(KGC::Commands) != nil &&
      defined?(FS_NormalMap_Minimap) != nil &&
      defined?(FS_NORMAL_MINIMAP) != nil &&
      defined?(FS_RandomDungeon) != nil &&
      defined?(FS_RANDOM_DUNGEON) != nil &&
      $game_system != nil && $game_party != nil && $game_temp != nil &&
      $game_switches != nil && $game_map != nil && $game_player != nil
    assert("Phase49C runtime providers ready", provider_ready)
    return false unless provider_ready

    snapshot_ivar = lambda do |obj, name|
      p49c_snapshot_ivar_transactional(obj, name)
    end

    restore_ivar = lambda do |obj, name, snap|
      ok = p49c_restore_ivar_transactional(obj, name, snap)
      log("[PHASE49C_RESTORE_REMOVE_FAIL] object=#{obj.class} ivar=#{name}") unless ok
      ok
    end

    scene_before = $scene
    switch_guard_before = p49c_snapshot_object_guard($game_switches)
    system_guard_before = p49c_snapshot_object_guard($game_system)
    party_guard_before = p49c_snapshot_object_guard($game_party)

    # Game_Switches 本體只會改 @data；保存原 Array reference + shallow table，
    # restore 時原地 #replace，避免 false tombstone 也避免 whole-root clone。
    switch_data_snap = snapshot_ivar.call($game_switches, :@data)

    temp_ivars = [
      :@fs_ring_return_index, :@fs_ring_subscene, :@fs_ring_mount_task,
      :@fs_soulbook_from_ring, :@fs_oak_transfer_mode, :@fs_oak_transfer_task,
      :@fs_normal_fullmap_visible, :@fs_normal_minimap_revision,
      :@fs_normal_marker_revision, :@common_event_id
    ]
    temp_snaps = {}
    temp_ivars.each { |name| temp_snaps[name] = snapshot_ivar.call($game_temp, name) }

    # 僅列出 Phase49C substantive code 實際可能寫入的 Game_System ivar。
    # @almanac / @armor_mapping 等持久資料完全不 snapshot、不 restore。
    system_ivars = [
      :@fs_normal_minimap_visible, :@fs_normal_minimap_exploration,
      :@fs_normal_minimap_exploration_revision,
      :@enemy_encountered, :@enemy_defeated, :@defeat_count,
      :@fs_economy_data
    ]
    system_snaps = {}
    system_ivars.each { |name| system_snaps[name] = snapshot_ivar.call($game_system, name) }
    p49c_map_id = $game_map.map_id.to_i
    exploration_child_snap = p49c_snapshot_hash_child(
      system_snaps[:@fs_normal_minimap_exploration], p49c_map_id
    )

    # 僅列出 Enemy Book fixture 實際寫入的 Game_Party ivar。
    # @pages / @vendors 等正式持久容器完全不碰。
    party_ivars = [
      :@monsters_encounter, :@monsters_defeated
    ]
    party_snaps = {}
    party_ivars.each { |name| party_snaps[name] = snapshot_ivar.call($game_party, name) }

    minimap_cache_names = [
      :@fs_nm_marker_cache_map_id, :@fs_nm_marker_cache_revision,
      :@fs_nm_marker_cache_entries, :@fs_nm_marker_cache_signature,
      :@fs_nm_terrain_cache_key, :@fs_nm_terrain_cache
    ]
    minimap_cache_snaps = {}
    minimap_cache_names.each do |name|
      minimap_cache_snaps[name] = snapshot_ivar.call(FS_NormalMap_Minimap, name)
    end

    ring_ready = false
    quest_ready = false
    book_ready = false
    minimap_ready = false
    dungeon_ready = false
    mutation_scope_ok = true
    error = nil

    begin
      #--------------------------------------------------------------------
      # Ring Menu Symbol Dispatcher
      #--------------------------------------------------------------------
      expected_actions = [:soul_book, :synthesize, :ride, :oak_sanctuary, :minimap, :library]
      actual_actions = FS_RING_MENU_ACTIONS::COMMANDS.collect { |row| row[2] }
      ring_contract =
        actual_actions == expected_actions &&
        FS_RING_MENU_ACTIONS::UNLOCK_SWITCHES == [139, 140, 141, 142, 143, 144]
      assert("Phase49C Ring Menu Symbol contract exact", ring_contract,
             "actions=#{actual_actions.inspect}")

      unlock_ok = true
      FS_RING_MENU_ACTIONS::UNLOCK_SWITCHES.each_with_index do |switch_id, index|
        old = $game_switches[switch_id]
        $game_switches[switch_id] = false
        unlock_ok &&= (FS_RING_MENU_ACTIONS.unlocked?(index) == false)
        $game_switches[switch_id] = true
        unlock_ok &&= (FS_RING_MENU_ACTIONS.unlocked?(index) == true)
        $game_switches[switch_id] = old
      end
      assert("Phase49C Ring Menu all six unlock switches honor live state", unlock_ok)

      dispatch_rows = []
      dispatch_specs = [
        [:soul_book, 0, Scene_SoulBookSelect, :soul_book],
        [:synthesize, 1, Sword_Synthesize, :synthesize],
        [:ride, 2, Scene_FSRideSelect, :ride],
        [:library, 5, Sword_Library, :library]
      ]
      dispatch_specs.each do |spec|
        action, index, klass, subscene = spec
        $scene = scene_before
        result = FS_RING_MENU_ACTIONS.execute(action, index)
        scene_ok = $scene.is_a?(klass)
        return_ok = $game_temp.fs_ring_return_index.to_i == index
        subscene_ok = $game_temp.fs_ring_subscene == subscene
        special_ok = true
        if action == :soul_book
          special_ok = ($game_temp.fs_soulbook_from_ring == true)
        end
        dispatch_rows << [action, result, scene_ok, return_ok, subscene_ok, special_ok]
      end
      dispatch_ok = dispatch_rows.all? do |row|
        row[1] == true && row[2] && row[3] && row[4] && row[5]
      end
      assert("Phase49C Ring Menu four non-transfer actions dispatch to exact Scene", dispatch_ok,
             "rows=#{dispatch_rows.inspect}")

      map_available = FS_NORMAL_MINIMAP.available?
      assert("Phase49C Ring Menu minimap action has current-map Runtime availability",
             map_available, "map_id=#{$game_map.map_id}")
      minimap_dispatch_ok = false
      if map_available
        $game_system.fs_normal_minimap_visible = false
        $game_temp.fs_normal_fullmap_visible = false
        $scene = scene_before
        result = FS_RING_MENU_ACTIONS.execute(:minimap, 4)
        first = result == true && $scene.is_a?(Scene_Map) &&
          FS_NORMAL_MINIMAP.visible_flag && $game_temp.fs_ring_return_index.to_i == 4
        $scene = scene_before
        result2 = FS_RING_MENU_ACTIONS.execute(:minimap, 4)
        second = result2 == true && !FS_NORMAL_MINIMAP.visible_flag
        minimap_dispatch_ok = first && second
      end
      assert("Phase49C Ring Menu minimap action toggles through formal facade", minimap_dispatch_ok)
      ring_ready = ring_contract && unlock_ok && dispatch_ok && minimap_dispatch_ok
      log("[PHASE49C_RING] contract=#{ring_contract} unlock=#{unlock_ok} dispatch=#{dispatch_ok} minimap=#{minimap_dispatch_ok} ready=#{ring_ready}")
      p49c_log_mutation_checkpoint(:ring, switch_guard_before, system_guard_before, party_guard_before)

      #--------------------------------------------------------------------
      # Quest Runtime State Machine
      #--------------------------------------------------------------------
      quest20 = Game_Quest.new(20)
      row20 = FS_QUEST_ECONOMY.row_for(20)
      quest_data_ok = row20 != nil && quest20.name == row20[:name] &&
        quest20.objectives == row20[:objectives] &&
        quest20.prime_objectives == [0, 1, 2, 3, 4]
      assert("Phase49C Quest20 detached Game_Quest uses FS economy bridge data", quest_data_ok,
             "name=#{quest20.name} prime=#{quest20.prime_objectives.inspect}")

      quest20.reveal_objective(0, 1)
      reveal_ok = quest20.objective_revealed?(0, 1)
      quest20.fail_objective(1)
      fail_ok = quest20.objective_failed?(1) && quest20.failed?
      quest20.unfail_objective(1)
      quest20.complete_objective(0, 1, 2, 3, 4)
      complete_ok = quest20.complete? && !quest20.failed? &&
        quest20.objective_complete?(0, 1, 2, 3, 4)
      assert("Phase49C Quest reveal/fail/unfail/complete state machine exact",
             reveal_ok && fail_ok && complete_ok,
             "reveal=#{reveal_ok} fail=#{fail_ok} complete=#{complete_ok}")

      quest29 = Game_Quest.new(29)
      FS_QUEST_ECONOMY.apply_branch_to_journal(quest29, 1)
      branch1 = [quest29.description.to_s, quest29.objectives.clone, quest29.rewards.clone]
      FS_QUEST_ECONOMY.apply_branch_to_journal(quest29, 2)
      branch2 = [quest29.description.to_s, quest29.objectives.clone, quest29.rewards.clone]
      branch_ok = branch1 != branch2 && branch1[2].include?("黑市交易權") &&
        branch2[2].include?("記憶重構權") &&
        quest29.prime_objectives == [0, 1, 2, 3, 4]
      assert("Phase49C Quest29 branch projection changes detached journal exactly", branch_ok,
             "b1=#{branch1[2].inspect} b2=#{branch2[2].inspect}")

      common_before = $game_temp.common_event_id
      quest12 = Game_Quest.new(12)
      quest12.complete_objective(*quest12.prime_objectives)
      common_ok = quest12.complete? && $game_temp.common_event_id.to_i == 1 &&
        quest12.common_event_id.to_i == 0
      $game_temp.common_event_id = common_before
      assert("Phase49C Quest completion queues Common Event once then retires local id", common_ok,
             "temp=#{$game_temp.common_event_id} quest_ce=#{quest12.common_event_id}")
      quest_ready = quest_data_ok && reveal_ok && fail_ok && complete_ok && branch_ok && common_ok
      log("[PHASE49C_QUEST] data=#{quest_data_ok} state=#{reveal_ok && fail_ok && complete_ok} branch=#{branch_ok} common=#{common_ok} ready=#{quest_ready}")
      p49c_log_mutation_checkpoint(:quest, switch_guard_before, system_guard_before, party_guard_before)

      #--------------------------------------------------------------------
      # Enemy Book Runtime storage bridge
      #--------------------------------------------------------------------
      enemy_id = FS_ENEMY_BOOK.enemy_ids[0]
      enemy_ok = enemy_id != nil && $data_enemies[enemy_id] != nil
      assert("Phase49C Enemy Book usable visible Enemy resolved", enemy_ok,
             "enemy_id=#{enemy_id}")
      if enemy_ok
        KGC::Commands.set_enemy_encountered(enemy_id, false)
        KGC::Commands.set_enemy_defeated(enemy_id, false)
        $game_party.monsters_encounter[enemy_id] = 0
        $game_party.monsters_defeated[enemy_id] = 0
        baseline_unknown = !FS_ENEMY_BOOK.encountered?(enemy_id) && !FS_ENEMY_BOOK.defeated?(enemy_id)
        assert("Phase49C Enemy Book false baseline reads both formal stores", baseline_unknown)

        KGC::Commands.set_enemy_encountered(enemy_id, true)
        encountered_fallback = FS_ENEMY_BOOK.encountered?(enemy_id) &&
          FS_ENEMY_BOOK.encounter_count(enemy_id) == 1
        $game_party.monsters_encounter[enemy_id] = 3
        encountered_count = FS_ENEMY_BOOK.encounter_count(enemy_id) == 3
        assert("Phase49C Enemy Book encounter flag/count priority exact",
               encountered_fallback && encountered_count,
               "fallback=#{encountered_fallback} count=#{FS_ENEMY_BOOK.encounter_count(enemy_id)}")

        KGC::Commands.set_enemy_defeated(enemy_id, true)
        $game_party.monsters_defeated[enemy_id] = 0
        begin
          $game_system.defeat_count(enemy_id)
          defeat_store = $game_system.instance_variable_get("@defeat_count")
          defeat_store[enemy_id] = 0 if defeat_store.is_a?(Array)
        rescue
        end
        defeated_fallback = FS_ENEMY_BOOK.defeated?(enemy_id) &&
          FS_ENEMY_BOOK.defeat_count(enemy_id) >= 1
        $game_party.monsters_defeated[enemy_id] = 2
        defeated_count = FS_ENEMY_BOOK.defeat_count(enemy_id) == 2
        assert("Phase49C Enemy Book defeated flag/count priority exact",
               defeated_fallback && defeated_count,
               "fallback=#{defeated_fallback} count=#{FS_ENEMY_BOOK.defeat_count(enemy_id)}")

        types = FS_ENEMY_BOOK.types(enemy_id)
        affinity_ok = types.is_a?(Array) && !types.empty? &&
          FS_ENEMY_BOOK.weaknesses(enemy_id).is_a?(Array) &&
          FS_ENEMY_BOOK.resistances(enemy_id).is_a?(Array)
        assert("Phase49C Enemy Book affinity projection executable", affinity_ok,
               "types=#{types.inspect}")
        book_ready = baseline_unknown && encountered_fallback && encountered_count &&
          defeated_fallback && defeated_count && affinity_ok
      end
      log("[PHASE49C_ENEMY_BOOK] enemy=#{enemy_id} ready=#{book_ready}")
      p49c_log_mutation_checkpoint(:enemy_book, switch_guard_before, system_guard_before, party_guard_before)

      #--------------------------------------------------------------------
      # Normal Minimap + RandomDungeon facades
      #--------------------------------------------------------------------
      facade_ok = FS_NORMAL_MINIMAP.equal?(FS_NormalMap_Minimap) &&
        FS_RANDOM_DUNGEON.equal?(FS_RandomDungeon)
      assert("Phase49C Minimap/RandomDungeon facade aliases exact", facade_ok)

      report = FS_NORMAL_MINIMAP.availability_report
      report_ok = report[:map_id].to_i == $game_map.map_id.to_i &&
        report[:available] == FS_NORMAL_MINIMAP.available? &&
        report[:random_dungeon_active] == FS_RandomDungeon.active?
      assert("Phase49C Normal Minimap availability report matches live Runtime", report_ok,
             "report=#{report.inspect}")

      minimap_cycle_ok = false
      exploration_ok = false
      if FS_NORMAL_MINIMAP.available?
        $game_system.fs_normal_minimap_visible = false
        $game_temp.fs_normal_fullmap_visible = false
        show_ok = FS_NORMAL_MINIMAP.show && FS_NORMAL_MINIMAP.visible? &&
          FS_NORMAL_MINIMAP.visible_flag
        full_on = FS_NORMAL_MINIMAP.fullmap_toggle
        full_ok = full_on == true && FS_NORMAL_MINIMAP.fullmap_visible? &&
          !FS_NORMAL_MINIMAP.visible?
        full_off = FS_NORMAL_MINIMAP.fullmap_toggle
        hide_ok = full_off == false && FS_NORMAL_MINIMAP.hide &&
          !FS_NORMAL_MINIMAP.visible_flag && !FS_NORMAL_MINIMAP.fullmap_visible?
        minimap_cycle_ok = show_ok && full_ok && hide_ok

        px = $game_player.x.to_i
        py = $game_player.y.to_i
        coord_ok = FS_NORMAL_MINIMAP.valid_coordinate?(px, py)
        if coord_ok
          FS_NORMAL_MINIMAP.reveal_cell(px, py)
          exploration_ok = FS_NORMAL_MINIMAP.explored?(px, py)
        end
      end
      assert("Phase49C Normal Minimap show/fullmap/hide lifecycle exact", minimap_cycle_ok)
      assert("Phase49C Normal Minimap exploration storage accepts player cell", exploration_ok,
             "player=[#{$game_player.x},#{$game_player.y}]")
      minimap_ready = facade_ok && report_ok && minimap_cycle_ok && exploration_ok
      log("[PHASE49C_MINIMAP] facade=#{facade_ok} report=#{report_ok} cycle=#{minimap_cycle_ok} exploration=#{exploration_ok} ready=#{minimap_ready}")
      p49c_log_mutation_checkpoint(:minimap, switch_guard_before, system_guard_before, party_guard_before)

      dungeon_cfg = FS_RANDOM_DUNGEON.config(:field_cave_01)
      dungeon_contract = dungeon_cfg[:map_id].to_i == 48 &&
        FS_RANDOM_DUNGEON.floor_count_for(dungeon_cfg) == 3 &&
        FS_RANDOM_DUNGEON.floor_config(dungeon_cfg, 2)[:floor].to_i == 2
      assert("Phase49C RandomDungeon formal config/floor helpers exact", dungeon_contract,
             "map=#{dungeon_cfg[:map_id]} floors=#{FS_RANDOM_DUNGEON.floor_count_for(dungeon_cfg)}")

      seed_a = FS_RANDOM_DUNGEON.floor_seed(12345, 2)
      seed_b = FS_RANDOM_DUNGEON.floor_seed(12345, 2)
      seed_base = FS_RANDOM_DUNGEON.floor_seed(12345, 1)
      seed_ok = seed_a == seed_b && seed_base == 12345 && seed_a != seed_base
      assert("Phase49C RandomDungeon floor seed helper deterministic", seed_ok,
             "base=#{seed_base} floor2=#{seed_a}")

      inactive_ok = !FS_RANDOM_DUNGEON.active? &&
        FS_RANDOM_DUNGEON.current_run == nil &&
        FS_RANDOM_DUNGEON.current_state == nil &&
        !FS_NORMAL_MINIMAP.random_dungeon_active?
      assert("Phase49C RandomDungeon inactive Map keeps normal minimap authority", inactive_ok,
             "map_id=#{$game_map.map_id}")
      dungeon_ready = dungeon_contract && seed_ok && inactive_ok
      log("[PHASE49C_RANDOM_DUNGEON] config=#{dungeon_contract} seed=#{seed_ok} inactive=#{inactive_ok} ready=#{dungeon_ready}")
      p49c_log_mutation_checkpoint(:dungeon, switch_guard_before, system_guard_before, party_guard_before)
    rescue Exception => e
      error = e
      exception(e, "phase49c_nonbattle_runtime_semantic_ii")
    ensure
      # 先在任何 cleanup 之前量測真正 Runtime mutation scope。
      # 這能明確區分「正式 API 造成的副作用」與「TEST restore 自己造成的副作用」。
      pre_switch_mismatches = p49c_guard_mismatches($game_switches, switch_guard_before)
      pre_system_mismatches = p49c_guard_mismatches($game_system, system_guard_before)
      pre_party_mismatches = p49c_guard_mismatches($game_party, party_guard_before)
      allowed_system = [
        :@fs_normal_minimap_visible, :@fs_normal_minimap_exploration,
        :@fs_normal_minimap_exploration_revision,
        :@enemy_encountered, :@enemy_defeated, :@defeat_count,
        :@fs_economy_data
      ]
      allowed_party = [:@monsters_encounter, :@monsters_defeated]
      unexpected_system = pre_system_mismatches.select { |row| !allowed_system.include?(row[0]) }
      unexpected_party = pre_party_mismatches.select { |row| !allowed_party.include?(row[0]) }
      unexpected_switch = pre_switch_mismatches.select { |row| row[0] != :@data }
      mutation_scope_ok = unexpected_system.empty? && unexpected_party.empty? && unexpected_switch.empty?
      log("[PHASE49C_MUTATION_SCOPE] switch=#{pre_switch_mismatches.inspect} system=#{pre_system_mismatches.inspect} party=#{pre_party_mismatches.inspect} unexpected_switch=#{unexpected_switch.inspect} unexpected_system=#{unexpected_system.inspect} unexpected_party=#{unexpected_party.inspect} ready=#{mutation_scope_ok}")

      $scene = scene_before
      temp_ivars.each { |name| restore_ivar.call($game_temp, name, temp_snaps[name]) }

      # reveal_cell 會原地寫 current-map exploration child，必須先還原 child
      # 自身內容，再還原 outer Hash table；兩者 object identity 都保留。
      p49c_restore_hash_child(exploration_child_snap)
      system_ivars.each { |name| restore_ivar.call($game_system, name, system_snaps[name]) }
      party_ivars.each { |name| restore_ivar.call($game_party, name, party_snaps[name]) }
      restore_ivar.call($game_switches, :@data, switch_data_snap)

      # Module marker caches may contain live Game_Event references。直接恢復
      # baseline object reference，不做 Marshal clone。
      minimap_cache_names.each do |name|
        snap = minimap_cache_snaps[name]
        if snap[:defined]
          FS_NormalMap_Minimap.instance_variable_set(name, snap[:object])
        else
          p49c_remove_ivar(FS_NormalMap_Minimap, name)
        end
      end
    end

    global_restore_ok = false
    temp_restore_ok = true
    cache_restore_ok = true
    temp_mismatches = []
    cache_mismatches = []
    begin
      temp_ivars.each do |name|
        m = p49c_transaction_mismatch($game_temp, name, temp_snaps[name])
        if m != nil
          temp_restore_ok = false
          temp_mismatches << m
        end
      end
      minimap_cache_names.each do |name|
        snap = minimap_cache_snaps[name]
        now_defined = p49c_ivar_defined?(FS_NormalMap_Minimap, name)
        if now_defined != snap[:defined]
          cache_restore_ok = false
          cache_mismatches << [name, :defined, snap[:defined], now_defined]
        elsif snap[:defined]
          value_ok = false
          current_value = FS_NormalMap_Minimap.instance_variable_get(name)
          value_ok = current_value.equal?(snap[:object])
          unless value_ok
            begin
              value_ok = (Marshal.dump(current_value) == Marshal.dump(snap[:copy]))
            rescue Exception
              value_ok = (current_value == snap[:object])
            end
          end
          unless value_ok
            cache_restore_ok = false
            cache_mismatches << [name, :value]
          end
        end
      end
      switch_touched = []
      m = p49c_transaction_mismatch($game_switches, :@data, switch_data_snap)
      switch_touched << m if m != nil
      system_touched = []
      system_ivars.each do |name|
        m = p49c_transaction_mismatch($game_system, name, system_snaps[name])
        system_touched << m if m != nil
      end
      child_m = p49c_hash_child_mismatch(exploration_child_snap)
      system_touched << child_m if child_m != nil
      party_touched = []
      party_ivars.each do |name|
        m = p49c_transaction_mismatch($game_party, name, party_snaps[name])
        party_touched << m if m != nil
      end

      switch_untouched = p49c_guard_mismatches($game_switches, switch_guard_before, [:@data])
      system_untouched = p49c_guard_mismatches($game_system, system_guard_before, system_ivars)
      party_untouched = p49c_guard_mismatches($game_party, party_guard_before, party_ivars)
      switch_restore_ok = switch_touched.empty? && switch_untouched.empty?
      system_restore_ok = system_touched.empty? && system_untouched.empty?
      party_restore_ok = party_touched.empty? && party_untouched.empty?
      switch_mismatches = switch_touched + switch_untouched
      system_mismatches = system_touched + system_untouched
      party_mismatches = party_touched + party_untouched
      scene_restore_ok = $scene.equal?(scene_before)
      global_restore_ok = mutation_scope_ok && switch_restore_ok && system_restore_ok && party_restore_ok &&
        temp_restore_ok && cache_restore_ok && scene_restore_ok
      log("[PHASE49C_RESTORE_DETAIL] mutation_scope=#{mutation_scope_ok} switch=#{switch_restore_ok} switch_mismatch=#{switch_mismatches.inspect} system=#{system_restore_ok} system_mismatch=#{system_mismatches.inspect} party=#{party_restore_ok} party_mismatch=#{party_mismatches.inspect} temp=#{temp_restore_ok} temp_mismatch=#{temp_mismatches.inspect} cache=#{cache_restore_ok} cache_mismatch=#{cache_mismatches.inspect} scene=#{scene_restore_ok}")
    rescue Exception => e
      exception(e, "phase49c_global_restore_check")
    end
    assert("Phase49C fixture restores touched state + untouched guards exact", global_restore_ok,
           "switch=#{switch_restore_ok} system=#{system_restore_ok} party=#{party_restore_ok} temp=#{temp_restore_ok} cache=#{cache_restore_ok}")

    ready = error == nil && ring_ready && quest_ready && book_ready &&
      minimap_ready && dungeon_ready && global_restore_ok &&
      @fail_count.to_i == fail_before
    log("[PHASE49C_RUNTIME_II] ring=#{ring_ready} quest=#{quest_ready} enemy_book=#{book_ready} minimap=#{minimap_ready} random_dungeon=#{dungeon_ready} globals=#{global_restore_ok} ready=#{ready}")
    assert("Phase49C Ring / Quest / EnemyBook / Minimap / RandomDungeon Runtime Semantic completed",
           ready, "fail_delta=#{@fail_count.to_i - fail_before}")
    return ready
  end



  #--------------------------------------------------------------------------
  # ● Phase49D：Random Dungeon / Map-Event Runtime Semantic III
  #--------------------------------------------------------------------------
  # 原則：
  # 1. 真正使用 FS_RandomDungeon 正式 Generator / prepare / Game_Map apply。
  # 2. 不覆寫 :field_cave_01 正式 run；注入 TEST-only 臨時 key，測後移除。
  # 3. 不讓正式 $game_player perform_transfer；轉場 contract 用 detached Player 驗證。
  # 4. 不建立 Renderer Bitmap，避免碰正式 Runtime bitmap cache。
  # 5. 全部 global mutation 以 transaction 還原，並檢查既有 dungeon state identity。
  #--------------------------------------------------------------------------
  def self.p49d_floor_signature(state)
    return nil if state == nil
    return [
      state[:floor], state[:floor_count], state[:seed],
      state[:base_floor_seed], state[:schema_version],
      state[:map_id], state[:width], state[:height],
      state[:layout], state[:rooms], state[:room_types],
      state[:room_depths], state[:room_links],
      state[:entrance], state[:exit], state[:fixed_event_positions],
      state[:event_counts_resolved], state[:generation_warnings]
    ]
  end

  def self.p49d_find_cell(state, wanted)
    return nil if state == nil
    layout = state[:layout] || []
    width = state[:width].to_i
    layout.each_with_index do |value, index_id|
      if value == wanted
        return [index_id % width, index_id / width]
      end
    end
    return nil
  end

  def self.p49d_hash_refs_exact?(table, baseline)
    return false unless table.is_a?(Hash)
    return false unless table.size == baseline.size
    baseline.each do |key, value|
      return false unless table.has_key?(key)
      return false unless table[key].equal?(value)
    end
    return true
  end

  def self.run_phase49d_random_dungeon_map_event_semantic_iii
    return false unless test_mode?
    fail_before = @fail_count.to_i
    log("[FIXTURE] PHASE49D-RANDOM-DUNGEON-MAP-EVENT-III")

    provider_ok = (defined?(FS_RandomDungeon) != nil) &&
      (defined?(FS_RANDOM_DUNGEON) != nil) &&
      FS_RANDOM_DUNGEON.equal?(FS_RandomDungeon) &&
      (defined?(Game_Map) != nil) &&
      (defined?(Game_Player) != nil) &&
      (defined?(Game_SelfSwitches) != nil)
    assert("Phase49D RandomDungeon / Map / Player / SelfSwitch providers ready", provider_ok)
    return false unless provider_ok

    test_key = :__fs_phase49d_runtime_semantic__
    base_key = :field_cave_01
    dungeons = FS_RandomDungeon::DUNGEONS
    base_cfg = dungeons[base_key]
    cfg_ready = base_cfg.is_a?(Hash) && base_cfg[:map_id].to_i > 0 &&
      FS_RandomDungeon.floor_count_for(base_cfg) >= 3
    assert("Phase49D formal field_cave_01 config usable as TEST clone source", cfg_ready,
           base_cfg == nil ? "missing" : "map=#{base_cfg[:map_id]} floors=#{FS_RandomDungeon.floor_count_for(base_cfg)}")
    return false unless cfg_ready

    # Baseline guards. 臨時 key 若異常已存在，也完整保存而不是假設不存在。
    cfg_had = dungeons.has_key?(test_key)
    cfg_old = dungeons[test_key]
    dungeon_refs = {}
    dungeons.each { |key, value| dungeon_refs[key] = value }

    states = $game_system.fs_rd_states
    state_had = states.has_key?(test_key)
    state_old = states[test_key]
    state_refs = {}
    states.each { |key, value| state_refs[key] = value }

    temp_names = [
      :@fs_rd_pending_key, :@fs_rd_pending_floor, :@fs_rd_place_mode,
      :@fs_rd_place_player, :@fs_rd_force_setup,
      :@fs_rd_suppress_exit_reset, :@fs_rd_debug_visual,
      :@fs_rd_minimap_visible, :@fs_rd_fullmap_visible,
      :@common_event_id
    ]
    temp_snaps = {}
    temp_names.each do |name|
      temp_snaps[name] = p49c_snapshot_ivar_transactional($game_temp, name)
    end
    self_switch_snap = p49c_snapshot_ivar_transactional($game_self_switches, :@data)
    map_before = $game_map
    player_before = $game_player
    scene_before = $scene

    generation_ready = false
    replay_ready = false
    map_ready = false
    event_ready = false
    self_switch_ready = false
    transfer_ready = false
    reset_ready = false
    restore_ready = false
    run = nil
    state1 = nil
    state2 = nil
    state3 = nil
    detached_map = nil
    detached_player = nil
    detached_self_switches = nil
    signature_a = nil
    error = nil

    begin
      # TEST-only config。保留正式生成規則，但移除所有會改正式 Switch/Variable/CE 的環境詞綴。
      cfg = base_cfg.dup
      cfg[:floor_count] = 3
      cfg[:floor_affixes] = {}
      cfg[:affix_pool] = []
      cfg[:affixes_per_floor] = 0
      cfg[:progress_hud_enabled] = false
      cfg[:show_floor_notice_with_hud] = false
      cfg[:floor_notice_mode] = :never
      cfg[:show_affix_notice] = false
      cfg[:reset_mode] = :manual
      dungeons[test_key] = cfg
      isolated_cfg = dungeons[test_key].equal?(cfg) &&
        dungeons[base_key].equal?(base_cfg) && !cfg.equal?(base_cfg)
      assert("Phase49D TEST dungeon config isolated from formal field_cave_01", isolated_cfg,
             "test=#{test_key} base_identity=#{dungeons[base_key].object_id}")

      # 先清除上次測試殘留的 TEST key；不碰其他 dungeon key。
      states.delete(test_key)
      seed = 24681357
      state1 = FS_RandomDungeon.prepare(test_key, true, seed, 1)
      run = states[test_key]
      prepare_ok = state1 != nil && run != nil &&
        run[:key] == test_key && run[:base_seed].to_i == seed &&
        run[:current_floor].to_i == 1 && run[:floor_count].to_i == 3 &&
        run[:entry_count].to_i == 1 &&
        $game_temp.fs_rd_pending_key == test_key &&
        $game_temp.fs_rd_pending_floor.to_i == 1 &&
        $game_temp.fs_rd_place_player == true
      assert("Phase49D prepare builds isolated run + exact pending contract", prepare_ok,
             "seed=#{run == nil ? nil : run[:base_seed]} entry=#{run == nil ? nil : run[:entry_count]} pending=#{$game_temp.fs_rd_pending_key.inspect}/#{$game_temp.fs_rd_pending_floor.inspect}")

      cfg1 = FS_RandomDungeon.runtime_config(cfg, 1, state1[:seed])
      floor1_errors = FS_RandomDungeon.generation_validation_errors(state1, cfg1)
      floor1_ok = floor1_errors.empty? && state1[:generation_warnings].empty? &&
        state1[:rooms].is_a?(Array) && state1[:rooms].size >= 2 &&
        FS_RandomDungeon.valid_position?(state1, state1[:entrance]) &&
        FS_RandomDungeon.valid_position?(state1, state1[:exit]) &&
        state1[:entrance] != state1[:exit]
      assert("Phase49D floor1 generated topology independently validates", floor1_ok,
             "rooms=#{state1[:rooms].size} errors=#{floor1_errors.inspect} warnings=#{state1[:generation_warnings].inspect}")

      state2 = FS_RandomDungeon.ensure_floor_state(run, 2)
      state3 = FS_RandomDungeon.ensure_floor_state(run, 3)
      floors_ok = state2[:floor].to_i == 2 && state3[:floor].to_i == 3 &&
        state2[:floor_count].to_i == 3 && state3[:floor_count].to_i == 3 &&
        state2[:base_floor_seed].to_i == FS_RandomDungeon.floor_seed(seed, 2) &&
        state3[:base_floor_seed].to_i == FS_RandomDungeon.floor_seed(seed, 3) &&
        state1[:map_id].to_i == cfg[:map_id].to_i &&
        state2[:map_id].to_i == cfg[:map_id].to_i &&
        state3[:map_id].to_i == cfg[:map_id].to_i
      assert("Phase49D three-floor lifecycle uses floor_seed/map contract exact", floors_ok,
             "seeds=#{[state1[:base_floor_seed],state2[:base_floor_seed],state3[:base_floor_seed]].inspect}")

      all_floor_errors = []
      [state1, state2, state3].each do |state|
        rcfg = FS_RandomDungeon.runtime_config(cfg, state[:floor], state[:seed])
        errs = FS_RandomDungeon.generation_validation_errors(state, rcfg)
        all_floor_errors << [state[:floor], errs] unless errs.empty?
      end
      all_floor_valid = all_floor_errors.empty? &&
        [state1, state2, state3].all? { |state| (state[:generation_warnings] || []).empty? }
      assert("Phase49D all three generated floors pass formal topology validation", all_floor_valid,
             all_floor_errors.inspect)

      signature_a = [state1, state2, state3].collect { |state| p49d_floor_signature(state) }
      generation_ready = prepare_ok && floor1_ok && floors_ok && all_floor_valid
      log("[PHASE49D_GENERATION] floors=3 seed=#{seed} ready=#{generation_ready}")

      # Event plan 在相同 state/seed 下必須 deterministic，且不寫 state。
      template_map = FS_RandomDungeon.load_template_map(cfg)
      plans_ok = template_map != nil
      plan_sizes = []
      if plans_ok
        [state1, state2, state3].each do |state|
          rcfg = FS_RandomDungeon.runtime_config(cfg, state[:floor], state[:seed])
          a = FS_RandomDungeon.generated_event_plan(rcfg, state, template_map)
          b = FS_RandomDungeon.generated_event_plan(rcfg, state, template_map)
          plans_ok = false unless a == b
          plan_sizes << a.size
        end
      end
      assert("Phase49D generated-event plans deterministic per floor", plans_ok,
             "sizes=#{plan_sizes.inspect}")

      tags_ok =
        FS_RandomDungeon.event_enabled_on_floor_name?("<FS_RD_FLOOR:2>", 2) &&
        !FS_RandomDungeon.event_enabled_on_floor_name?("<FS_RD_FLOOR:2>", 1) &&
        FS_RandomDungeon.event_enabled_on_floor_name?("<FS_RD_FLOORS:1,3>", 3) &&
        FS_RandomDungeon.event_enabled_on_floor_name?("<FS_RD_FLOORS:2-4>", 4) &&
        FS_RandomDungeon.event_room_type_name("x<FS_RD_TREASURE>") == :treasure &&
        FS_RandomDungeon.event_progress_type_name("x<FS_RD_BOSS>") == :boss &&
        FS_RandomDungeon.completion_switch_for(cfg, "x<FS_RD_COMPLETE:C>", :battle) == "C"
      assert("Phase49D floor/event tag parser semantics exact", tags_ok)

      # 真正 reset 再以同 seed 重建三層，證明 prepare/generator replay。
      FS_RandomDungeon.reset(test_key)
      state1b = FS_RandomDungeon.prepare(test_key, true, seed, 1)
      run = states[test_key]
      state2b = FS_RandomDungeon.ensure_floor_state(run, 2)
      state3b = FS_RandomDungeon.ensure_floor_state(run, 3)
      signature_b = [state1b, state2b, state3b].collect { |state| p49d_floor_signature(state) }
      replay_ready = signature_a == signature_b
      assert("Phase49D same forced seed replays all three floor states exactly", replay_ready,
             "same=#{replay_ready}")
      state1, state2, state3 = state1b, state2b, state3b
      log("[PHASE49D_REPLAY] deterministic=#{replay_ready} ready=#{replay_ready}")

      # Detached Game_Map 真正走 setup(Map48) + pending key apply，正式 $game_map 不替換。
      detached_map = Game_Map.new
      detached_map.setup(cfg[:map_id].to_i)
      setup_consumed = detached_map.fs_rd_active? &&
        detached_map.fs_rd_key == test_key && detached_map.fs_rd_floor.to_i == 1 &&
        $game_temp.fs_rd_pending_key == nil && $game_temp.fs_rd_pending_floor == nil &&
        $game_temp.fs_rd_place_player == true
      assert("Phase49D detached Game_Map#setup consumes pending dungeon state", setup_consumed,
             "active=#{detached_map.fs_rd_active?} key=#{detached_map.fs_rd_key.inspect} floor=#{detached_map.fs_rd_floor}")

      state1 = detached_map.fs_rd_state
      map_identity_ok = state1 != nil && state1[:visited] == true &&
        detached_map.map_id.to_i == cfg[:map_id].to_i &&
        detached_map.instance_variable_get(:@map).width.to_i == state1[:width].to_i &&
        detached_map.instance_variable_get(:@map).height.to_i == state1[:height].to_i
      assert("Phase49D detached map dimensions/visited state follow generated floor", map_identity_ok,
             "map=#{detached_map.map_id} size=#{state1[:width]}x#{state1[:height]} visited=#{state1[:visited]}")

      passage_ok =
        detached_map.fs_rd_passage_code(FS_RandomDungeon::CELL_FLOOR) == FS_RandomDungeon::PASS_OPEN &&
        detached_map.fs_rd_passage_code(FS_RandomDungeon::CELL_ENTRANCE) == FS_RandomDungeon::PASS_OPEN &&
        detached_map.fs_rd_passage_code(FS_RandomDungeon::CELL_EXIT) == FS_RandomDungeon::PASS_OPEN &&
        detached_map.fs_rd_passage_code(FS_RandomDungeon::CELL_BRIDGE_H) == FS_RandomDungeon::PASS_OPEN &&
        detached_map.fs_rd_passage_code(FS_RandomDungeon::CELL_WATER) == FS_RandomDungeon::PASS_WATER &&
        detached_map.fs_rd_passage_code(FS_RandomDungeon::CELL_WALL) == FS_RandomDungeon::PASS_BLOCK
      assert("Phase49D Game_Map passage authority maps dungeon cells exact", passage_ok)

      map_data = detached_map.instance_variable_get(:@map).data
      entrance = state1[:entrance]
      exit_pos = state1[:exit]
      wall = p49d_find_cell(state1, FS_RandomDungeon::CELL_WALL)
      water = p49d_find_cell(state1, FS_RandomDungeon::CELL_WATER)
      collision_ok = map_data[entrance[0], entrance[1], 2] == FS_RandomDungeon::PASS_OPEN &&
        map_data[exit_pos[0], exit_pos[1], 2] == FS_RandomDungeon::PASS_OPEN
      collision_ok = false if wall != nil && map_data[wall[0], wall[1], 2] != FS_RandomDungeon::PASS_BLOCK
      collision_ok = false if water != nil && map_data[water[0], water[1], 2] != FS_RandomDungeon::PASS_WATER
      assert("Phase49D generated collision Table matches layout samples", collision_ok,
             "entrance=#{entrance.inspect} exit=#{exit_pos.inspect} wall=#{wall.inspect} water=#{water.inspect}")

      generated = state1[:generated_events] || []
      event_positions_ok = true
      used = {}
      generated.each do |desc|
        event_id = desc[:event_id].to_i
        ev = detached_map.events[event_id]
        if ev == nil
          event_positions_ok = false
          next
        end
        pos = [ev.x, ev.y]
        rpg_ev = ev.respond_to?(:event) ? ev.event : nil
        event_positions_ok = false unless FS_RandomDungeon.valid_position?(state1, pos)
        event_positions_ok = false if used[pos]
        event_positions_ok = false if rpg_ev == nil || !rpg_ev.name.to_s.include?("<FS_RD_GENERATED>")
        used[pos] = true
      end
      event_positions_ok = false if generated.empty?
      assert("Phase49D generated events exist, clone-tagged, unique and walkable", event_positions_ok,
             "generated=#{generated.size}")

      # 直接套用 floor2/floor3，驗 Map lifecycle 與 generated event refresh。
      detached_map.fs_rd_apply_state(test_key, run, state2)
      floor2_apply = detached_map.fs_rd_floor.to_i == 2 && run[:current_floor].to_i == 2 &&
        state2[:visited] == true && !(state2[:generated_events] || []).empty?
      detached_map.fs_rd_apply_state(test_key, run, state3)
      floor3_apply = detached_map.fs_rd_floor.to_i == 3 && run[:current_floor].to_i == 3 &&
        state3[:visited] == true && !(state3[:generated_events] || []).empty?
      assert("Phase49D detached map applies floor2/floor3 lifecycle + event refresh", floor2_apply && floor3_apply,
             "f2=#{floor2_apply} f3=#{floor3_apply}")

      # Encounter list 只由 RandomDungeon final filter 改寫。
      encounter_ok = true
      encounter_rows = []
      [state1, state2, state3].each do |state|
        detached_map.fs_rd_apply_state(test_key, run, state)
        original_list = detached_map.fs_rd_encounter_list_v098fs
        expected_list = FS_RandomDungeon.filter_encounter_troop_ids(original_list, state)
        actual_list = detached_map.encounter_list
        same = (actual_list == expected_list)
        encounter_ok = false unless same
        encounter_rows << [state[:floor], original_list.size, actual_list.size, same]
      end
      assert("Phase49D floor encounter_list equals formal final filter", encounter_ok,
             encounter_rows.inspect)
      map_ready = setup_consumed && map_identity_ok && passage_ok && collision_ok && encounter_ok

      # Self Switch floor virtualization。只使用 detached Game_SelfSwitches。
      detached_map.fs_rd_apply_state(test_key, run, state3)
      progress_desc = nil
      (state3[:generated_events] || []).each do |desc|
        if desc[:type] != nil && desc[:type] != :boss
          progress_desc = desc
          break
        end
      end
      event_ready = progress_desc != nil
      assert("Phase49D progress-capable generated event resolved for SelfSwitch test", event_ready,
             progress_desc == nil ? "none" : progress_desc.inspect)

      if progress_desc != nil
        event_id = progress_desc[:event_id].to_i
        map_saved = $game_map
        begin
          $game_map = detached_map
          detached_self_switches = Game_SelfSwitches.new
          native_key = [cfg[:map_id].to_i, event_id, "A"]
          virtual3 = detached_self_switches.fs_rd_virtual_key(native_key)
          virtual3_ok = virtual3.is_a?(Array) && virtual3.size >= 7 &&
            virtual3[3] == :fs_rd && virtual3[4] == test_key &&
            virtual3[5].to_i == run[:generation_id].to_i && virtual3[6].to_i == 3
          assert("Phase49D SelfSwitch virtual key binds dungeon/generation/floor", virtual3_ok,
                 virtual3.inspect)

          detached_self_switches[native_key] = true
          write_ok = detached_self_switches[native_key] == true &&
            detached_self_switches.instance_variable_get(:@data)[virtual3] == true &&
            state3[:completed_events][event_id] == progress_desc[:type]
          assert("Phase49D SelfSwitch write records floor-local event completion", write_ok,
                 "virtual=#{virtual3.inspect} completed=#{state3[:completed_events][event_id].inspect}")

          detached_map.fs_rd_apply_state(test_key, run, state2)
          virtual2 = detached_self_switches.fs_rd_virtual_key(native_key)
          isolation_ok = virtual2 != virtual3 && virtual2[6].to_i == 2 &&
            virtual3[6].to_i == 3 && detached_self_switches.instance_variable_get(:@data)[virtual3] == true &&
            detached_self_switches.instance_variable_get(:@data)[virtual2] != true
          assert("Phase49D same native SelfSwitch key isolates floor2 vs floor3", isolation_ok,
                 "f2=#{virtual2.inspect} f3=#{virtual3.inspect}")
          self_switch_ready = virtual3_ok && write_ok && isolation_ok
        ensure
          $game_map = map_saved
        end
      else
        assert("Phase49D SelfSwitch virtual key binds dungeon/generation/floor", false, "no progress event")
        assert("Phase49D SelfSwitch write records floor-local event completion", false, "no progress event")
        assert("Phase49D same native SelfSwitch key isolates floor2 vs floor3", false, "no progress event")
      end

      # Detached player 驗 floor transfer / external leave reservation，不 perform_transfer。
      map_saved = $game_map
      player_saved = $game_player
      begin
        $game_map = detached_map
        detached_map.fs_rd_apply_state(test_key, run, state2)
        detached_player = Game_Player.new
        $game_player = detached_player
        transfer_call = FS_RandomDungeon.request_floor_transfer(run, 3, :entrance)
        transfer_ok = transfer_call.equal?(state3) && run[:current_floor].to_i == 3 &&
          $game_temp.fs_rd_pending_key == test_key && $game_temp.fs_rd_pending_floor.to_i == 3 &&
          $game_temp.fs_rd_place_mode == :entrance && $game_temp.fs_rd_place_player == true &&
          $game_temp.fs_rd_force_setup == true &&
          detached_player.instance_variable_get(:@transferring) == true &&
          detached_player.instance_variable_get(:@new_map_id).to_i == cfg[:map_id].to_i
        assert("Phase49D request_floor_transfer reserves next floor without performing Scene transfer", transfer_ok,
               "pending=#{$game_temp.fs_rd_pending_floor} new_map=#{detached_player.instance_variable_get(:@new_map_id)}")

        leave_ok_call = FS_RandomDungeon.leave_to_map(map_before.map_id, player_before.x, player_before.y, 2, false)
        leave_ok = leave_ok_call == true && $game_temp.fs_rd_suppress_exit_reset == true &&
          detached_player.instance_variable_get(:@transferring) == true &&
          detached_player.instance_variable_get(:@new_map_id).to_i == map_before.map_id.to_i &&
          detached_player.instance_variable_get(:@new_x).to_i == player_before.x.to_i &&
          detached_player.instance_variable_get(:@new_y).to_i == player_before.y.to_i
        assert("Phase49D leave_to_map suppression + reserve contract exact", leave_ok,
               "map=#{detached_player.instance_variable_get(:@new_map_id)} pos=#{[detached_player.instance_variable_get(:@new_x),detached_player.instance_variable_get(:@new_y)].inspect}")
        transfer_ready = transfer_ok && leave_ok
      ensure
        $game_player = player_saved
        $game_map = map_saved
      end

      # reset(TEST key) 必須只清自己的 run/pending，不傷正式 key。
      $game_temp.fs_rd_pending_key = test_key
      $game_temp.fs_rd_pending_floor = 3
      $game_temp.fs_rd_place_player = true
      $game_temp.fs_rd_force_setup = true
      FS_RandomDungeon.reset(test_key)
      reset_ready = !states.has_key?(test_key) &&
        $game_temp.fs_rd_pending_key == nil && $game_temp.fs_rd_pending_floor == nil &&
        $game_temp.fs_rd_place_player == false && $game_temp.fs_rd_force_setup == false &&
        p49d_hash_refs_exact?(states, state_refs)
      assert("Phase49D reset removes only TEST run and restores pending lifecycle", reset_ready,
             "test_present=#{states.has_key?(test_key)} states=#{states.size}/#{state_refs.size}")

    rescue Exception => e
      error = e
      exception(e, "phase49d_runtime_semantic")
    ensure
      # 若中途例外，先清 TEST runtime/cache，再完整還原 global。
      begin
        current = states[test_key]
        FS_RandomDungeon::Runtime.clear_run(current) if current != nil
      rescue Exception
      end
      begin
        if state_had
          states[test_key] = state_old
        else
          states.delete(test_key)
        end
      rescue Exception
      end
      begin
        if cfg_had
          dungeons[test_key] = cfg_old
        else
          dungeons.delete(test_key)
        end
      rescue Exception
      end
      begin
        temp_names.each do |name|
          p49c_restore_ivar_transactional($game_temp, name, temp_snaps[name])
        end
        # SelfSwitch global 正常情況完全未改，不要無條件 Hash#replace。
        # 只有 TEST key 殘留/清除真的造成 logical mutation 時才 transaction restore。
        ss_before_restore = p49c_transaction_mismatch($game_self_switches, :@data, self_switch_snap)
        if ss_before_restore != nil
          p49c_restore_ivar_transactional($game_self_switches, :@data, self_switch_snap)
        end
      rescue Exception => e
        exception(e, "phase49d_restore")
      end
      $game_map = map_before
      $game_player = player_before
    end

    begin
      cfg_restore = cfg_had ? dungeons[test_key].equal?(cfg_old) : !dungeons.has_key?(test_key)
      dungeon_refs_ok = true
      dungeon_refs.each do |key, value|
        dungeon_refs_ok = false unless dungeons.has_key?(key) && dungeons[key].equal?(value)
      end
      dungeon_refs_ok = false unless dungeons.size == dungeon_refs.size

      state_restore = state_had ? states[test_key].equal?(state_old) : !states.has_key?(test_key)
      state_refs_ok = p49d_hash_refs_exact?(states, state_refs)
      temp_mismatch = []
      temp_names.each do |name|
        m = p49c_transaction_mismatch($game_temp, name, temp_snaps[name])
        temp_mismatch << m if m != nil
      end
      ss_mismatch = p49c_transaction_mismatch($game_self_switches, :@data, self_switch_snap)
      cache = FS_RandomDungeon::Runtime.instance_variable_get(:@cache)
      cache_clean = true
      if cache.is_a?(Hash)
        cache.keys.each do |key|
          if key.is_a?(Array) && key[0] == test_key
            cache_clean = false
            break
          end
        end
      end
      identity_ok = $game_map.equal?(map_before) && $game_player.equal?(player_before) && $scene.equal?(scene_before)
      restore_ready = cfg_restore && dungeon_refs_ok && state_restore && state_refs_ok &&
        temp_mismatch.empty? && ss_mismatch == nil && cache_clean && identity_ok
      log("[PHASE49D_RESTORE_DETAIL] config=#{cfg_restore && dungeon_refs_ok} state=#{state_restore && state_refs_ok} temp=#{temp_mismatch.empty?} temp_mismatch=#{temp_mismatch.inspect} self_switch=#{ss_mismatch == nil} cache=#{cache_clean} map_player_scene=#{identity_ok}")
      assert("Phase49D TEST config/run/temp/selfswitch/cache/global identities restored", restore_ready,
             "config=#{cfg_restore && dungeon_refs_ok} state=#{state_restore && state_refs_ok} temp=#{temp_mismatch.empty?} ss=#{ss_mismatch.inspect} cache=#{cache_clean} identity=#{identity_ok}")
    rescue Exception => e
      exception(e, "phase49d_restore_check")
      restore_ready = false
      assert("Phase49D TEST config/run/temp/selfswitch/cache/global identities restored", false, e.message)
    end

    ready = error == nil && generation_ready && replay_ready && plans_ok && tags_ok &&
      map_ready && event_ready && self_switch_ready && transfer_ready && reset_ready &&
      restore_ready && @fail_count.to_i == fail_before
    log("[PHASE49D_RUNTIME_III] generation=#{generation_ready} replay=#{replay_ready} plans=#{plans_ok} tags=#{tags_ok} map=#{map_ready} events=#{event_ready} self_switch=#{self_switch_ready} transfer=#{transfer_ready} reset=#{reset_ready} restore=#{restore_ready} ready=#{ready}")
    assert("Phase49D RandomDungeon / Map-Event Runtime Semantic III completed", ready,
           "fail_delta=#{@fail_count.to_i - fail_before}")
    return ready
  end


  #--------------------------------------------------------------------------
  # ● Phase49E：Real perform_transfer / Scene_Map lifecycle IV
  #--------------------------------------------------------------------------
  # Phase49D 已證明 reserve contract、detached Game_Map 與 SelfSwitch Authority。
  # 本段把測試再往前推一層：在完全 detached 的全域 sandbox 中，真正呼叫
  # Game_Player#perform_transfer，讓正式 Random Dungeon wrapper + VX native transfer
  # 一起跑完。正式 Map/Player/System/Temp/SelfSwitch object identity 在 ensure 後原樣恢復。
  #--------------------------------------------------------------------------
  def self.p49e_find_walkable_non_anchor(state, avoid = nil)
    return nil if state == nil
    avoid ||= []
    width = state[:width].to_i
    height = state[:height].to_i
    layout = state[:layout] || []
    for y in 1...(height - 1)
      for x in 1...(width - 1)
        pos = [x, y]
        next if avoid.include?(pos)
        value = layout[x + y * width]
        return pos if FS_RandomDungeon.walkable_cell?(value)
      end
    end
    return nil
  end

  def self.run_phase49e_real_transfer_lifecycle_iv
    return false unless test_mode?
    fail_before = @fail_count.to_i
    log("[FIXTURE] PHASE49E-REAL-TRANSFER-LIFECYCLE-IV")

    provider_ok = (defined?(FS_RandomDungeon) != nil) &&
      (defined?(Game_Map) != nil) &&
      (defined?(Game_Player) != nil) &&
      (defined?(Game_Temp) != nil) &&
      (defined?(Game_System) != nil) &&
      (defined?(Game_SelfSwitches) != nil)
    assert("Phase49E transfer providers ready", provider_ok)
    return false unless provider_ok

    test_key = :__fs_phase49e_transfer_semantic__
    base_key = :field_cave_01
    dungeons = FS_RandomDungeon::DUNGEONS
    base_cfg = dungeons[base_key]
    cfg_ready = base_cfg.is_a?(Hash) && base_cfg[:map_id].to_i > 0 &&
      FS_RandomDungeon.floor_count_for(base_cfg) >= 3
    assert("Phase49E field_cave_01 config usable as detached transfer source", cfg_ready,
           base_cfg == nil ? "missing" : "map=#{base_cfg[:map_id]} floors=#{FS_RandomDungeon.floor_count_for(base_cfg)}")
    return false unless cfg_ready

    cfg_had = dungeons.has_key?(test_key)
    cfg_old = dungeons[test_key]
    dungeon_refs = {}
    dungeons.each { |key, value| dungeon_refs[key] = value }

    map_before = $game_map
    player_before = $game_player
    temp_before = $game_temp
    system_before = $game_system
    self_switch_before = $game_self_switches
    scene_before = $scene

    detached_map = nil
    detached_player = nil
    detached_temp = nil
    detached_system = nil
    detached_self_switches = nil
    run = nil
    floor1 = nil
    floor2 = nil
    floor3 = nil
    return_map_id = map_before == nil ? 1 : map_before.map_id.to_i
    return_x = player_before == nil ? 0 : player_before.x.to_i
    return_y = player_before == nil ? 0 : player_before.y.to_i

    enter_ready = false
    floor1_ready = false
    next_ready = false
    previous_ready = false
    suppress_exit_ready = false
    suppress_consumed_ready = false
    resume_ready = false
    generic_exit_ready = false
    normal_exit_ready = false
    reset_cycle_ready = false
    restore_ready = false
    error = nil

    begin
      # TEST-only config。沿用正式 dungeon 規則，但關閉所有視覺／環境 side effects，
      # 並把 reset_mode 設成 :on_exit，直接驗證外部 transfer lifecycle。
      cfg = base_cfg.dup
      cfg[:floor_count] = 3
      cfg[:floor_affixes] = {}
      cfg[:affix_pool] = []
      cfg[:affixes_per_floor] = 0
      cfg[:progress_hud_enabled] = false
      cfg[:show_floor_notice_with_hud] = false
      cfg[:floor_notice_mode] = :never
      cfg[:show_affix_notice] = false
      cfg[:reset_mode] = :on_exit
      dungeons[test_key] = cfg

      # 建立完整 detached VX runtime globals。這些 object 在本 fixture 內才成為 global，
      # 因此 perform_transfer 會跑真正正式 wrapper/native method，卻不碰玩家 live map。
      detached_system = Game_System.new
      detached_temp = Game_Temp.new
      detached_self_switches = Game_SelfSwitches.new
      detached_map = Game_Map.new
      detached_player = Game_Player.new
      $game_system = detached_system
      $game_temp = detached_temp
      $game_self_switches = detached_self_switches
      $game_map = detached_map
      $game_player = detached_player

      sandbox_ok = !$game_system.equal?(system_before) &&
        !$game_temp.equal?(temp_before) && !$game_map.equal?(map_before) &&
        !$game_player.equal?(player_before) &&
        !$game_self_switches.equal?(self_switch_before) &&
        $scene.equal?(scene_before)
      assert("Phase49E detached global sandbox installed without replacing Scene", sandbox_ok,
             "map=#{$game_map.object_id} player=#{$game_player.object_id} system=#{$game_system.object_id}")

      seed = 86420931
      floor1 = FS_RandomDungeon.enter(test_key, true, seed, 1)
      run = $game_system.fs_rd_states[test_key]
      reserve_ok = floor1 != nil && run != nil &&
        $game_temp.fs_rd_pending_key == test_key &&
        $game_temp.fs_rd_pending_floor.to_i == 1 &&
        $game_temp.fs_rd_place_mode == :entrance &&
        $game_temp.fs_rd_place_player == true &&
        $game_player.instance_variable_get(:@transferring) == true &&
        $game_player.instance_variable_get(:@new_map_id).to_i == cfg[:map_id].to_i
      assert("Phase49E enter reserves real VX transfer to dungeon floor1", reserve_ok,
             "pending=#{$game_temp.fs_rd_pending_key.inspect}/#{$game_temp.fs_rd_pending_floor.inspect} new_map=#{$game_player.instance_variable_get(:@new_map_id)}")

      $game_player.perform_transfer
      run = FS_RandomDungeon.current_run
      floor1 = FS_RandomDungeon.current_state
      enter_ready = run != nil && floor1 != nil
      floor1_pos = floor1 == nil ? nil : floor1[:entrance]
      floor1_ready = enter_ready && $game_map.map_id.to_i == cfg[:map_id].to_i &&
        $game_map.fs_rd_active? && $game_map.fs_rd_floor.to_i == 1 &&
        [$game_player.x, $game_player.y] == floor1_pos &&
        $game_temp.fs_rd_pending_key == nil && $game_temp.fs_rd_pending_floor == nil &&
        $game_temp.fs_rd_place_player == false && $game_temp.fs_rd_place_mode == nil &&
        $game_temp.fs_rd_force_setup == false &&
        $game_player.instance_variable_get(:@transferring) != true
      assert("Phase49E perform_transfer enters floor1, places player and consumes pending flags", floor1_ready,
             "map=#{$game_map.map_id} floor=#{$game_map.fs_rd_floor} pos=#{[$game_player.x,$game_player.y].inspect} entrance=#{floor1_pos.inspect}")

      # 先移到另一合法格，next_floor 必須在 transfer 前保存 floor1 last_player_pos。
      saved_floor1_pos = p49e_find_walkable_non_anchor(
        floor1, [floor1[:entrance], floor1[:exit]]
      )
      if saved_floor1_pos != nil
        $game_player.moveto(saved_floor1_pos[0], saved_floor1_pos[1])
      end
      next_call = FS_RandomDungeon.next_floor
      floor2 = FS_RandomDungeon.ensure_floor_state(run, 2)
      next_reserve = next_call == true && saved_floor1_pos != nil &&
        floor1[:last_player_pos] == saved_floor1_pos &&
        run[:current_floor].to_i == 2 &&
        $game_temp.fs_rd_pending_floor.to_i == 2 &&
        $game_temp.fs_rd_force_setup == true &&
        $game_player.instance_variable_get(:@transferring) == true
      assert("Phase49E next_floor saves prior position and reserves same-map forced setup", next_reserve,
             "saved=#{floor1[:last_player_pos].inspect} pending=#{$game_temp.fs_rd_pending_floor.inspect}")

      $game_player.perform_transfer
      next_ready = next_reserve && $game_map.fs_rd_active? &&
        $game_map.fs_rd_floor.to_i == 2 &&
        [$game_player.x, $game_player.y] == floor2[:entrance] &&
        $game_temp.fs_rd_pending_key == nil &&
        $game_temp.fs_rd_force_setup == false
      assert("Phase49E real same-Map48 transfer applies floor2 and entrance placement", next_ready,
             "floor=#{$game_map.fs_rd_floor} pos=#{[$game_player.x,$game_player.y].inspect}")

      prev_call = FS_RandomDungeon.previous_floor
      prev_reserve = prev_call == true && run[:current_floor].to_i == 1 &&
        $game_temp.fs_rd_pending_floor.to_i == 1 &&
        $game_temp.fs_rd_place_mode == :exit
      $game_player.perform_transfer
      previous_ready = prev_reserve && $game_map.fs_rd_floor.to_i == 1 &&
        [$game_player.x, $game_player.y] == floor1[:exit]
      assert("Phase49E previous_floor real transfer returns floor1 at exit anchor", previous_ready,
             "floor=#{$game_map.fs_rd_floor} pos=#{[$game_player.x,$game_player.y].inspect} exit=#{floor1[:exit].inspect}")

      # 保存 resume 位置，接著用 count_as_exit=false 離開。這個 suppress flag 應是一次性。
      resume_pos = p49e_find_walkable_non_anchor(
        floor1, [floor1[:entrance], floor1[:exit], saved_floor1_pos]
      )
      resume_pos = saved_floor1_pos if resume_pos == nil
      if resume_pos != nil
        $game_player.moveto(resume_pos[0], resume_pos[1])
        FS_RandomDungeon.save_current_player_position
      end
      run[:pending_reset_reason] = nil
      suppress_call = FS_RandomDungeon.leave_to_map(
        return_map_id, return_x, return_y, 2, false
      )
      suppress_reserved = suppress_call == true &&
        $game_temp.fs_rd_suppress_exit_reset == true &&
        $game_player.instance_variable_get(:@transferring) == true
      $game_player.perform_transfer
      suppress_exit_ready = suppress_reserved && !$game_map.fs_rd_active? &&
        $game_map.map_id.to_i == return_map_id &&
        [$game_player.x, $game_player.y] == [return_x, return_y] &&
        run[:pending_reset_reason] == nil
      assert("Phase49E count_as_exit=false leaves dungeon without queuing :on_exit reset", suppress_exit_ready,
             "map=#{$game_map.map_id} pending_reset=#{run[:pending_reset_reason].inspect}")

      # suppress_exit_reset 是針對「這一次 transfer」的 policy，不應污染下一次 dungeon exit。
      suppress_consumed_ready = ($game_temp.fs_rd_suppress_exit_reset == false)
      assert("Phase49E suppress_exit_reset is consumed after the suppressed transfer", suppress_consumed_ready,
             "flag=#{$game_temp.fs_rd_suppress_exit_reset.inspect}")

      # 同 run 再進入 floor1；visited + last_player_pos 應走 :resume。
      reenter_state = FS_RandomDungeon.enter(test_key, false, nil, 1)
      resume_reserved = reenter_state != nil &&
        $game_temp.fs_rd_place_mode == :resume &&
        $game_player.instance_variable_get(:@transferring) == true
      $game_player.perform_transfer
      resume_ready = resume_reserved && $game_map.fs_rd_active? &&
        $game_map.fs_rd_floor.to_i == 1 && resume_pos != nil &&
        [$game_player.x, $game_player.y] == resume_pos
      assert("Phase49E re-entry resumes exact last valid floor position", resume_ready,
             "mode=#{$game_temp.fs_rd_place_mode.inspect} pos=#{[$game_player.x,$game_player.y].inspect} expected=#{resume_pos.inspect}")

      # 直接走 VX reserve_transfer，驗 Game_Player wrapper 自己能在普通離場時排入 :on_exit。
      # 若上一個 suppress flag 沒有被 consume，這裡會暴露真正的跨 transfer 污染。
      run[:pending_reset_reason] = nil
      $game_player.reserve_transfer(return_map_id, return_x, return_y, 2)
      $game_player.perform_transfer
      generic_exit_ready = !$game_map.fs_rd_active? &&
        run[:pending_reset_reason] == :exit
      assert("Phase49E generic VX external transfer queues :on_exit after prior suppressed exit", generic_exit_ready,
             "pending_reset=#{run[:pending_reset_reason].inspect} suppress=#{$game_temp.fs_rd_suppress_exit_reset.inspect}")

      # 後續測試獨立於上項：顯式恢復 one-shot policy，再驗 leave_to_map(count_as_exit=true)。
      $game_temp.fs_rd_suppress_exit_reset = false
      run[:pending_reset_reason] = nil
      FS_RandomDungeon.enter(test_key, false, nil, 1)
      $game_player.perform_transfer
      normal_call = FS_RandomDungeon.leave_to_map(
        return_map_id, return_x, return_y, 2, true
      )
      $game_player.perform_transfer
      normal_exit_ready = normal_call == true && !$game_map.fs_rd_active? &&
        run[:pending_reset_reason] == :exit &&
        $game_temp.fs_rd_suppress_exit_reset == false
      assert("Phase49E count_as_exit=true queues :on_exit and leaves suppress policy clear", normal_exit_ready,
             "pending_reset=#{run[:pending_reset_reason].inspect} suppress=#{$game_temp.fs_rd_suppress_exit_reset.inspect}")

      # 下一次 external entry 應消化 pending :exit reset，而不是讓 pending 永久卡住。
      reset_before = run[:reset_count].to_i
      entry_before = run[:entry_count].to_i
      FS_RandomDungeon.enter(test_key, false, nil, 1)
      run_after_reset = $game_system.fs_rd_states[test_key]
      reset_cycle_reserved = run_after_reset != nil &&
        run_after_reset[:pending_reset_reason] == nil &&
        run_after_reset[:last_reset_reason] == :exit &&
        run_after_reset[:reset_count].to_i == reset_before + 1 &&
        run_after_reset[:entry_count].to_i == entry_before + 1
      $game_player.perform_transfer
      reset_cycle_ready = reset_cycle_reserved && $game_map.fs_rd_active? &&
        $game_map.fs_rd_floor.to_i == 1
      assert("Phase49E next external entry consumes pending :on_exit reset cycle exactly once", reset_cycle_ready,
             "reset=#{run_after_reset == nil ? nil : run_after_reset[:reset_count]} reason=#{run_after_reset == nil ? nil : run_after_reset[:last_reset_reason].inspect} entry=#{run_after_reset == nil ? nil : run_after_reset[:entry_count]}")

      # TEST sandbox 自己收尾；真正 global identity 由 ensure 還原。
      FS_RandomDungeon.reset(test_key)
      sandbox_cleanup = !$game_system.fs_rd_states.has_key?(test_key) &&
        $game_temp.fs_rd_pending_key == nil &&
        $game_temp.fs_rd_pending_floor == nil
      assert("Phase49E detached dungeon state resets cleanly before global restore", sandbox_cleanup)

    rescue Exception => e
      error = e
      exception(e, "phase49e_real_transfer")
    ensure
      begin
        if $game_system != nil && $game_system.respond_to?(:fs_rd_states)
          current = $game_system.fs_rd_states[test_key]
          FS_RandomDungeon::Runtime.clear_run(current) if current != nil
          $game_system.fs_rd_states.delete(test_key)
        end
      rescue Exception
      end
      begin
        if cfg_had
          dungeons[test_key] = cfg_old
        else
          dungeons.delete(test_key)
        end
      rescue Exception
      end
      $game_map = map_before
      $game_player = player_before
      $game_temp = temp_before
      $game_system = system_before
      $game_self_switches = self_switch_before
    end

    begin
      cfg_restore = cfg_had ? dungeons[test_key].equal?(cfg_old) : !dungeons.has_key?(test_key)
      refs_ok = true
      dungeon_refs.each do |key, value|
        refs_ok = false unless dungeons.has_key?(key) && dungeons[key].equal?(value)
      end
      refs_ok = false unless dungeons.size == dungeon_refs.size
      cache = FS_RandomDungeon::Runtime.instance_variable_get(:@cache)
      cache_clean = true
      if cache.is_a?(Hash)
        cache.keys.each do |key|
          if key.is_a?(Array) && key[0] == test_key
            cache_clean = false
            break
          end
        end
      end
      identity_ok = $game_map.equal?(map_before) &&
        $game_player.equal?(player_before) && $game_temp.equal?(temp_before) &&
        $game_system.equal?(system_before) &&
        $game_self_switches.equal?(self_switch_before) && $scene.equal?(scene_before)
      restore_ready = cfg_restore && refs_ok && cache_clean && identity_ok
      log("[PHASE49E_RESTORE_DETAIL] config=#{cfg_restore && refs_ok} cache=#{cache_clean} globals=#{identity_ok}")
      assert("Phase49E detached transfer sandbox restores every formal global identity", restore_ready,
             "config=#{cfg_restore && refs_ok} cache=#{cache_clean} globals=#{identity_ok}")
    rescue Exception => e
      exception(e, "phase49e_restore_check")
      restore_ready = false
      assert("Phase49E detached transfer sandbox restores every formal global identity", false, e.message)
    end

    ready = error == nil && enter_ready && floor1_ready && next_ready &&
      previous_ready && suppress_exit_ready && suppress_consumed_ready &&
      resume_ready && generic_exit_ready && normal_exit_ready &&
      reset_cycle_ready && restore_ready && @fail_count.to_i == fail_before
    log("[PHASE49E_RUNTIME_IV] enter=#{enter_ready} floor1=#{floor1_ready} next=#{next_ready} previous=#{previous_ready} suppress_exit=#{suppress_exit_ready} suppress_consumed=#{suppress_consumed_ready} resume=#{resume_ready} generic_exit=#{generic_exit_ready} normal_exit=#{normal_exit_ready} reset_cycle=#{reset_cycle_ready} restore=#{restore_ready} ready=#{ready}")
    assert("Phase49E real perform_transfer / dungeon lifecycle IV completed", ready,
           "fail_delta=#{@fail_count.to_i - fail_before}")
    return ready
  end

  #--------------------------------------------------------------------------
  # ● Phase49F：Save / Load Runtime Semantic V
  #--------------------------------------------------------------------------
  # 真實呼叫 Scene_File#write_save_data/read_save_data，但只使用 TEST 專用臨時檔。
  # 測試涵蓋：
  #   1. 新版 unified extension 單一 Hash round-trip。
  #   2. 舊 Fog / Self Variable / ATS 尾端格式與 duplicated Game_Player bug 相容。
  #   3. base-only 存檔缺少 extension 時的安全重建。
  #   4. 讀檔後 ArmorMapping 舊資料 normalization。
  # 全程使用 detached global sandbox；ensure 後恢復所有正式 global identity，並刪除臨時檔。
  #--------------------------------------------------------------------------
  def self.p49f_official_save_signature
    result = []
    return result unless defined?(FS_SAVE_COMPAT_TEST)
    files = FS_SAVE_COMPAT_TEST.save_files
    for path in files
      begin
        result << [path.to_s, File.size(path).to_i, File.mtime(path).to_i]
      rescue
        result << [path.to_s, -1, -1]
      end
    end
    return result
  rescue
    return []
  end

  def self.run_phase49f_save_load_runtime_semantic_v
    return false unless test_mode?
    fail_before = @fail_count.to_i
    log("[FIXTURE] PHASE49F-SAVE-LOAD-RUNTIME-V")

    provider_ok = (defined?(Scene_File) != nil) &&
      (defined?(Scene_Title) != nil) &&
      (defined?(FS_SAVE_COMPAT) != nil) &&
      (defined?(FS_SAVE_COMPAT_TEST) != nil) &&
      Scene_File.method_defined?(:write_save_data) &&
      Scene_File.method_defined?(:read_save_data) &&
      Scene_File.method_defined?(:fs_save_compat_core_write) &&
      (defined?(Game_SelfVariables) != nil) &&
      (defined?(Game_ATS) != nil) &&
      (defined?(ForestSymphonyDB) != nil) &&
      ForestSymphonyDB.respond_to?(:rebuild_armor_mapping)
    assert("Phase49F Save/Load providers ready", provider_ok)
    return false unless provider_ok

    frame_before = Graphics.frame_count
    scene_before = $scene
    temp_before = $game_temp
    message_before = $game_message
    system_before = $game_system
    switches_before = $game_switches
    variables_before = $game_variables
    self_switches_before = $game_self_switches
    actors_before = $game_actors
    party_before = $game_party
    troop_before = $game_troop
    map_before = $game_map
    player_before = $game_player
    fog_data_before = $fog_data
    fog_transition_before = $fog_transition
    self_var_before = $self_var
    game_ats_before = $game_ats
    ats_default_before = $ats_default
    condition_before = $game_condition_members
    riding_before = $riding_data
    parapassa_before = $game_parapassa
    ring_cm_before = $game_ring_cm
    ring_menu_before = $game_ring_menu

    return_map_id = map_before == nil ? 1 : map_before.map_id.to_i
    return_map_id = 1 if return_map_id <= 0
    return_x = player_before == nil ? 0 : player_before.x.to_i
    return_y = player_before == nil ? 0 : player_before.y.to_i

    official_before = p49f_official_save_signature
    stamp = "#{Time.now.to_i}_#{Graphics.frame_count.to_i}"
    new_path = "FS_Phase49F_TEMP_NEW_#{stamp}.rvdata"
    legacy_path = "FS_Phase49F_TEMP_LEGACY_#{stamp}.rvdata"
    base_path = "FS_Phase49F_TEMP_BASE_#{stamp}.rvdata"
    temp_paths = [new_path, legacy_path, base_path]

    sandbox_ready = false
    sentinel_ready = false
    new_write_ready = false
    new_layout_ready = false
    new_payload_ready = false
    new_core_ready = false
    new_extension_ready = false
    audit_ready = false
    migration_ready = false
    legacy_layout_ready = false
    legacy_core_ready = false
    legacy_fog_ready = false
    legacy_extension_ready = false
    legacy_player_ready = false
    base_layout_ready = false
    base_core_ready = false
    base_recovery_ready = false
    official_untouched_ready = false
    cleanup_ready = false
    restore_ready = false
    error = nil

    begin
      # 以正式 Scene_Title#create_game_objects 建立 detached runtime，讓所有 create hooks
      # 以真實載入順序初始化；之後所有 save/load 都只操作這組 sandbox globals。
      Scene_Title.new.create_game_objects
      $game_map.setup(return_map_id)
      $game_player.moveto(return_x, return_y)
      sandbox_ready = !$game_temp.equal?(temp_before) &&
        !$game_system.equal?(system_before) && !$game_map.equal?(map_before) &&
        !$game_player.equal?(player_before) && $scene.equal?(scene_before)
      assert("Phase49F detached new-game sandbox installed through formal create_game_objects", sandbox_ready,
             "map=#{$game_map.object_id} player=#{$game_player.object_id} system=#{$game_system.object_id}")

      # 新格式 round-trip sentinel。
      switch_id = 499
      variable_id = 499
      self_key = [return_map_id, 999, "A"]
      self_var_key = [:phase49f, 1]
      $game_switches[switch_id] = true
      $game_variables[variable_id] = 493821
      $game_self_switches[self_key] = true
      $game_party.gain_gold(12345)
      $fog_data = { return_map_id => ["phase49f_fog", 1, 2, 33, 0] }
      $fog_transition = 17
      $self_var[self_var_key] = 97531
      $game_ats.instance_variable_set(:@fs_phase49f_marker, 86420)

      mapping = $game_system.armor_mapping
      mapping[101] = 8
      mapping[732] = 7
      mapping[65000] = 42
      sentinel_ready = $game_switches[switch_id] == true &&
        $game_variables[variable_id].to_i == 493821 &&
        $game_self_switches[self_key] == true && $game_party.gold.to_i == 12345 &&
        $self_var[self_var_key].to_i == 97531 &&
        $game_ats.instance_variable_get(:@fs_phase49f_marker).to_i == 86420 &&
        mapping[101] == 8 && mapping[732] == 7 && mapping[65000] == 42
      assert("Phase49F new-format sentinel state prepared", sentinel_ready)

      # 正式存檔是由 Scene_Map 離開後的 Menu / Scene_File 流程執行。
      # Scene_Map#terminate 會 dispose Spriteset_Map，而 Neo Light 的 dispose hook
      # 會把 Game_Event#@nl_sprite 清除。Phase49F 是 detached sandbox，沒有真正
      # 跑 Scene_Map main loop，因此在直接呼叫 Scene_File 前補上相同的正式 transient
      # cleanup；否則會把只存在於地圖顯示期的 Sprite 誤送進 Marshal，產生 TEST 假失敗。
      neo_light_before = []
      neo_light_after = []
      if $game_map != nil && $game_map.respond_to?(:events)
        $game_map.events.each do |event_id, event|
          next if event == nil
          sprite = nil
          begin
            sprite = event.instance_variable_get(:@nl_sprite)
          rescue Exception
            sprite = nil
          end
          neo_light_before << event_id if sprite != nil
        end
        if $game_map.respond_to?(:dispose_neolight)
          $game_map.dispose_neolight
        end
        $game_map.events.each do |event_id, event|
          next if event == nil
          sprite = nil
          begin
            sprite = event.instance_variable_get(:@nl_sprite)
          rescue Exception
            sprite = nil
          end
          neo_light_after << event_id if sprite != nil
        end
      end
      log("[PHASE49F_PRESAVE_TRANSIENT] neo_light_before=#{neo_light_before.inspect} neo_light_after=#{neo_light_after.inspect} ready=#{neo_light_after.empty?}")

      file_scene = Scene_File.new(false, false, false)
      File.open(new_path, "wb") { |file| file_scene.write_save_data(file) }
      new_write_ready = FileTest.exist?(new_path) && File.size(new_path).to_i > 0
      assert("Phase49F Scene_File writes isolated NEW save file", new_write_ready,
             "file=#{new_path} bytes=#{new_write_ready ? File.size(new_path) : 0}")

      new_objects = FS_SAVE_COMPAT_TEST.read_all_marshaled(new_path)
      core_count = FS_SAVE_COMPAT_TEST::CORE_OBJECT_COUNT.to_i
      new_tail = new_objects[core_count, new_objects.size - core_count] || []
      new_layout_ready = new_objects.size == core_count + 1 && new_tail.size == 1 &&
        new_tail[0].is_a?(Hash) &&
        new_tail[0][:fs_save_magic] == FS_SAVE_COMPAT::MAGIC
      assert("Phase49F NEW save has 14 core objects + one unified extension payload", new_layout_ready,
             "objects=#{new_objects.size} tail=#{new_tail.size}")

      payload = new_tail[0]
      new_payload_ready = payload != nil &&
        payload[:fs_save_version].to_i == FS_SAVE_COMPAT::VERSION.to_i &&
        payload[:fog_data] == $fog_data && payload[:fog_transition].to_i == 17 &&
        payload[:self_variables].is_a?(Game_SelfVariables) &&
        payload[:self_variables][self_var_key].to_i == 97531 &&
        payload[:game_ats].is_a?(Game_ATS) &&
        payload[:game_ats].instance_variable_get(:@fs_phase49f_marker).to_i == 86420
      assert("Phase49F unified extension payload preserves Fog/SelfVariable/ATS data", new_payload_ready)
      log("[PHASE49F_NEW_SAVE] objects=#{new_objects.size} tail=#{new_tail.size} payload=#{new_payload_ready}")

      # 故意破壞 current globals，再以真正 read_save_data 載回。
      $game_switches = Game_Switches.new
      $game_variables = Game_Variables.new
      $game_self_switches = Game_SelfSwitches.new
      $game_party = Game_Party.new
      $fog_data = nil
      $fog_transition = nil
      $self_var = nil
      $game_ats = nil
      $ats_default = nil
      $game_condition_members = nil
      $riding_data = nil
      $game_parapassa = nil
      $game_ring_cm = nil
      $game_ring_menu = nil

      File.open(new_path, "rb") { |file| file_scene.read_save_data(file) }
      new_core_ready = $game_switches[switch_id] == true &&
        $game_variables[variable_id].to_i == 493821 &&
        $game_self_switches[self_key] == true && $game_party.gold.to_i == 12345 &&
        $game_map.map_id.to_i == return_map_id &&
        [$game_player.x, $game_player.y] == [return_x, return_y]
      assert("Phase49F NEW read restores core Switch/Variable/SelfSwitch/Party/Map/Player state", new_core_ready,
             "gold=#{$game_party.gold} map=#{$game_map.map_id} pos=#{[$game_player.x,$game_player.y].inspect}")

      new_extension_ready = $fog_data == payload[:fog_data] &&
        $fog_transition.to_i == 17 && $self_var.is_a?(Game_SelfVariables) &&
        $self_var[self_var_key].to_i == 97531 && $game_ats.is_a?(Game_ATS) &&
        $game_ats.instance_variable_get(:@fs_phase49f_marker).to_i == 86420 &&
        $ats_default.equal?($game_ats)
      assert("Phase49F NEW read applies unified Fog/SelfVariable/ATS extension", new_extension_ready)

      audit_ready = $game_condition_members != nil && $riding_data != nil &&
        $game_parapassa != nil && $game_ring_cm.is_a?(Array) &&
        $game_ring_menu.is_a?(Array)
      assert("Phase49F post-load runtime audit rebuilds unsaved ancillary globals", audit_ready,
             "condition=#{$game_condition_members.class} riding=#{$riding_data.class} parapassa=#{$game_parapassa.class} ring_cm=#{$game_ring_cm.class}")

      loaded_mapping = $game_system.armor_mapping
      compact_ok = true
      ForestSymphonyDB::ARMOR_TO_ACTOR.each do |armor_id, actor_id|
        compact_ok = false unless loaded_mapping[armor_id] == actor_id
      end
      migration_ready = loaded_mapping[101] != 8 && loaded_mapping[732] != 7 &&
        loaded_mapping[65000] == 42 && compact_ok
      assert("Phase49F read audit normalizes legacy ArmorMapping while preserving custom data", migration_ready,
             "legacy101=#{loaded_mapping[101].inspect} legacy732=#{loaded_mapping[732].inspect} custom=#{loaded_mapping[65000].inspect}")

      # ---------------------------------------------------------------------
      # Legacy tail：14 core + Fog pair + duplicated Game_Player + SelfVar + ATS。
      # ---------------------------------------------------------------------
      legacy_switch_id = 498
      legacy_variable_id = 498
      $game_switches[legacy_switch_id] = true
      $game_variables[legacy_variable_id] = 24680
      legacy_base_pos = [return_x, return_y]
      $game_player.moveto(legacy_base_pos[0], legacy_base_pos[1])
      legacy_fog = { return_map_id => ["phase49f_legacy_fog", -2, 3, 88, 1] }
      legacy_transition = 44
      legacy_self = Game_SelfVariables.new
      legacy_self[[:legacy, 9]] = 13579
      legacy_ats = Game_ATS.new
      legacy_ats.instance_variable_set(:@fs_phase49f_legacy_marker, 975)
      duplicate_player = Game_Player.new
      duplicate_player.moveto(return_x + 1, return_y + 1)

      File.open(legacy_path, "wb") do |file|
        file_scene.fs_save_compat_core_write(file)
        Marshal.dump(legacy_fog, file)
        Marshal.dump(legacy_transition, file)
        Marshal.dump(duplicate_player, file)
        Marshal.dump(legacy_self, file)
        Marshal.dump(legacy_ats, file)
      end
      legacy_objects = FS_SAVE_COMPAT_TEST.read_all_marshaled(legacy_path)
      legacy_tail = legacy_objects[core_count, legacy_objects.size - core_count] || []
      legacy_layout_ready = legacy_objects.size == core_count + 5 &&
        legacy_tail[0].is_a?(Hash) && legacy_tail[1].is_a?(Numeric) &&
        legacy_tail[2].is_a?(Game_Player) &&
        legacy_tail[3].is_a?(Game_SelfVariables) && legacy_tail[4].is_a?(Game_ATS)
      assert("Phase49F LEGACY file fixture matches Fog/player-bug/SelfVariable/ATS tail layout", legacy_layout_ready,
             "objects=#{legacy_objects.size} tail=#{legacy_tail.collect{|o| o.class.to_s}.inspect}")

      $fog_data = nil
      $fog_transition = nil
      $self_var = nil
      $game_ats = nil
      $ats_default = nil
      $game_switches = Game_Switches.new
      $game_variables = Game_Variables.new
      File.open(legacy_path, "rb") { |file| file_scene.read_save_data(file) }

      legacy_core_ready = $game_switches[legacy_switch_id] == true &&
        $game_variables[legacy_variable_id].to_i == 24680
      assert("Phase49F LEGACY read restores base core objects", legacy_core_ready)

      legacy_fog_ready = $fog_data == legacy_fog &&
        $fog_transition.to_i == legacy_transition
      assert("Phase49F LEGACY read restores Advanced Fog pair", legacy_fog_ready,
             "fog=#{$fog_data.inspect} transition=#{$fog_transition.inspect}")

      legacy_extension_ready = $self_var.is_a?(Game_SelfVariables) &&
        $self_var[[:legacy, 9]].to_i == 13579 && $game_ats.is_a?(Game_ATS) &&
        $game_ats.instance_variable_get(:@fs_phase49f_legacy_marker).to_i == 975 &&
        $ats_default.equal?($game_ats)
      assert("Phase49F LEGACY read restores SelfVariable/ATS tail objects", legacy_extension_ready)

      legacy_player_ready = [$game_player.x, $game_player.y] == legacy_base_pos &&
        [$game_player.x, $game_player.y] != [duplicate_player.x, duplicate_player.y]
      assert("Phase49F LEGACY duplicated Game_Player tail is ignored", legacy_player_ready,
             "loaded=#{[$game_player.x,$game_player.y].inspect} duplicate=#{[duplicate_player.x,duplicate_player.y].inspect}")
      log("[PHASE49F_LEGACY] layout=#{legacy_layout_ready} core=#{legacy_core_ready} fog=#{legacy_fog_ready} extension=#{legacy_extension_ready} duplicate_ignored=#{legacy_player_ready}")

      # ---------------------------------------------------------------------
      # Base-only：沒有任何 extension tail，讀檔後應安全建立預設 extension objects。
      # ---------------------------------------------------------------------
      base_switch_id = 497
      base_variable_id = 497
      $game_switches[base_switch_id] = true
      $game_variables[base_variable_id] = 112233
      File.open(base_path, "wb") { |file| file_scene.fs_save_compat_core_write(file) }
      base_objects = FS_SAVE_COMPAT_TEST.read_all_marshaled(base_path)
      base_layout_ready = base_objects.size == core_count
      assert("Phase49F BASE-ONLY fixture contains exactly the 14 VX core objects", base_layout_ready,
             "objects=#{base_objects.size}")

      $fog_data = nil
      $fog_transition = nil
      $self_var = nil
      $game_ats = nil
      $ats_default = nil
      $game_switches = Game_Switches.new
      $game_variables = Game_Variables.new
      File.open(base_path, "rb") { |file| file_scene.read_save_data(file) }

      base_core_ready = $game_switches[base_switch_id] == true &&
        $game_variables[base_variable_id].to_i == 112233
      assert("Phase49F BASE-ONLY read restores core data", base_core_ready)

      base_recovery_ready = $fog_data.is_a?(Hash) &&
        $fog_transition.is_a?(Numeric) && $self_var.is_a?(Game_SelfVariables) &&
        $game_ats.is_a?(Game_ATS) && $ats_default.equal?($game_ats)
      assert("Phase49F BASE-ONLY read safely rebuilds missing Fog/SelfVariable/ATS extension", base_recovery_ready,
             "fog=#{$fog_data.class} self=#{$self_var.class} ats=#{$game_ats.class}")
      log("[PHASE49F_BASE_ONLY] layout=#{base_layout_ready} core=#{base_core_ready} recovery=#{base_recovery_ready}")

    rescue Exception => e
      error = e
      exception(e, "phase49f_save_load")
    ensure
      for path in temp_paths
        begin
          File.delete(path) if FileTest.exist?(path)
        rescue
        end
      end

      $game_temp = temp_before
      $game_message = message_before
      $game_system = system_before
      $game_switches = switches_before
      $game_variables = variables_before
      $game_self_switches = self_switches_before
      $game_actors = actors_before
      $game_party = party_before
      $game_troop = troop_before
      $game_map = map_before
      $game_player = player_before
      $fog_data = fog_data_before
      $fog_transition = fog_transition_before
      $self_var = self_var_before
      $game_ats = game_ats_before
      $ats_default = ats_default_before
      $game_condition_members = condition_before
      $riding_data = riding_before
      $game_parapassa = parapassa_before
      $game_ring_cm = ring_cm_before
      $game_ring_menu = ring_menu_before
      $scene = scene_before
      begin
        Graphics.frame_count = frame_before
      rescue
      end
    end

    official_after = p49f_official_save_signature
    official_untouched_ready = (official_after == official_before)
    assert("Phase49F official save-file set/size/mtime remains untouched", official_untouched_ready,
           "before=#{official_before.inspect} after=#{official_after.inspect}")

    cleanup_ready = true
    for path in temp_paths
      cleanup_ready = false if FileTest.exist?(path)
    end
    assert("Phase49F all TEST temporary save files are deleted", cleanup_ready,
           temp_paths.inspect)

    restore_ready = $game_temp.equal?(temp_before) &&
      $game_message.equal?(message_before) && $game_system.equal?(system_before) &&
      $game_switches.equal?(switches_before) && $game_variables.equal?(variables_before) &&
      $game_self_switches.equal?(self_switches_before) && $game_actors.equal?(actors_before) &&
      $game_party.equal?(party_before) && $game_troop.equal?(troop_before) &&
      $game_map.equal?(map_before) && $game_player.equal?(player_before) &&
      $fog_data.equal?(fog_data_before) && $self_var.equal?(self_var_before) &&
      $game_ats.equal?(game_ats_before) && $ats_default.equal?(ats_default_before) &&
      $game_condition_members.equal?(condition_before) && $riding_data.equal?(riding_before) &&
      $game_parapassa.equal?(parapassa_before) && $game_ring_cm.equal?(ring_cm_before) &&
      $game_ring_menu.equal?(ring_menu_before) && $scene.equal?(scene_before) &&
      Graphics.frame_count.to_i == frame_before.to_i &&
      $fog_transition == fog_transition_before
    log("[PHASE49F_RESTORE_DETAIL] official=#{official_untouched_ready} tempfiles=#{cleanup_ready} globals=#{restore_ready}")
    assert("Phase49F save/load sandbox restores every formal global identity", restore_ready)

    ready = error == nil && sandbox_ready && sentinel_ready && new_write_ready &&
      new_layout_ready && new_payload_ready && new_core_ready && new_extension_ready &&
      audit_ready && migration_ready && legacy_layout_ready && legacy_core_ready &&
      legacy_fog_ready && legacy_extension_ready && legacy_player_ready &&
      base_layout_ready && base_core_ready && base_recovery_ready &&
      official_untouched_ready && cleanup_ready && restore_ready &&
      @fail_count.to_i == fail_before
    log("[PHASE49F_RUNTIME_V] new=#{new_core_ready && new_extension_ready} payload=#{new_payload_ready} audit=#{audit_ready} migration=#{migration_ready} legacy=#{legacy_core_ready && legacy_fog_ready && legacy_extension_ready && legacy_player_ready} base_only=#{base_core_ready && base_recovery_ready} official=#{official_untouched_ready} cleanup=#{cleanup_ready} restore=#{restore_ready} ready=#{ready}")
    assert("Phase49F Save / Load Runtime Semantic V completed", ready,
           "fail_delta=#{@fail_count.to_i - fail_before}")
    return ready
  end

  #--------------------------------------------------------------------------
  # ● Phase49G：Economy / Shop / Craft Runtime Semantic VI
  #--------------------------------------------------------------------------
  # 使用 detached new-game globals，不進真正 Scene main loop。
  # 覆蓋現行商店 Authority，而不是舊 Price Changer 的 real_price/new_price 路線：
  #   FS_SHOP_GOODS / FS_REGION_SHOPS / FS_BLACK_MARKET / Scene_Shop
  #   Sword.sword4_gold_cost / FS_ECONOMY forge transaction
  #--------------------------------------------------------------------------
  class Phase49GWindowStub
    attr_accessor :index
    attr_accessor :number
    attr_accessor :active
    attr_accessor :visible
    attr_accessor :price_value
    attr_accessor :good

    def initialize
      @index = 0
      @number = 0
      @active = false
      @visible = false
      @price_value = 0
      @good = nil
      @refresh_count = 0
    end

    def price(target = nil)
      return @price_value.to_i
    end

    def current_good
      return @good
    end

    def refresh
      @refresh_count = @refresh_count.to_i + 1
      return true
    end

    def refresh_count
      return @refresh_count.to_i
    end
  end

  def self.p49g_find_positive_shop_target
    groups = []
    groups << [0, $data_items] if defined?($data_items) && $data_items != nil
    groups << [1, $data_weapons] if defined?($data_weapons) && $data_weapons != nil
    groups << [2, $data_armors] if defined?($data_armors) && $data_armors != nil
    for pair in groups
      type = pair[0]
      data = pair[1]
      i = 1
      while i < data.size
        obj = data[i]
        if obj != nil && obj.respond_to?(:price) && obj.price.to_i > 0
          count = 0
          begin
            count = $game_party.item_number(obj).to_i if $game_party != nil
          rescue
            count = 0
          end
          return [type, obj] if count <= 90
        end
        i += 1
      end
    end
    return nil
  rescue
    return nil
  end

  def self.run_phase49g_economy_shop_craft_runtime_semantic_vi
    return false unless test_mode?
    fail_before = @fail_count.to_i
    log("[FIXTURE] PHASE49G-ECONOMY-SHOP-CRAFT-VI")

    provider_ok = (defined?(FS_SHOP_GOODS) != nil) &&
      (defined?(FS_REGION_SHOPS) != nil) &&
      (defined?(FS_BLACK_MARKET) != nil) &&
      (defined?(FS_ECONOMY) != nil) &&
      (defined?(Scene_Shop) != nil) && Scene_Shop.method_defined?(:decide_number_input) &&
      (defined?(Sword) != nil) && Sword.respond_to?(:sword4_gold_cost) &&
      Sword.const_defined?(:Sword4_Synthesize)
    assert("Phase49G Economy / Shop / Craft providers ready", provider_ok)
    return false unless provider_ok

    frame_before = Graphics.frame_count
    scene_before = $scene
    temp_before = $game_temp
    message_before = $game_message
    system_before = $game_system
    switches_before = $game_switches
    variables_before = $game_variables
    self_switches_before = $game_self_switches
    actors_before = $game_actors
    party_before = $game_party
    troop_before = $game_troop
    map_before = $game_map
    player_before = $game_player
    fog_data_before = $fog_data
    fog_transition_before = $fog_transition
    self_var_before = $self_var
    game_ats_before = $game_ats
    ats_default_before = $ats_default
    condition_before = $game_condition_members
    riding_before = $riding_data
    parapassa_before = $game_parapassa
    ring_cm_before = $game_ring_cm
    ring_menu_before = $game_ring_menu

    sandbox_ready = false
    target_ready = false
    normal_price_ready = false
    bool_column_ready = false
    custom_price_ready = false
    profiles_ready = false
    camp_markup_ready = false
    luka_discount_ready = false
    habel_unlock_ready = false
    region_open_ready = false
    stock_ready = false
    purchase_ready = false
    chapter_reset_ready = false
    black_price_ready = false
    buy_ready = false
    sell_ready = false
    synth_gold_ready = false
    recipe_ready = false
    craft_resources_ready = false
    forge_guard_ready = false
    forge_short_ready = false
    forge_commit_ready = false
    restore_ready = false
    error = nil

    begin
      Scene_Title.new.create_game_objects
      sandbox_ready = !$game_temp.equal?(temp_before) &&
        !$game_system.equal?(system_before) && !$game_party.equal?(party_before) &&
        $scene.equal?(scene_before)
      assert("Phase49G detached economy sandbox installed through formal create_game_objects", sandbox_ready,
             "temp=#{$game_temp.object_id} system=#{$game_system.object_id} party=#{$game_party.object_id}")

      # 清乾淨 detached Economy service state，避免 Setup 預設值干擾語義。
      FS_ECONOMY::SERVICE_KEYS.each { |key| FS_ECONOMY.lock(key) }
      econ = FS_ECONOMY.data
      if econ != nil
        econ[:black_market_purchases] = {}
        econ[:craft_credit] = 0
        econ[:free_retune] = 0
        econ[:chapter] = 0
        econ[:headgear_level].delete(220) if econ[:headgear_level].is_a?(Hash)
        econ[:headgear_tuning].delete(220) if econ[:headgear_tuning].is_a?(Hash)
      end

      found = p49g_find_positive_shop_target
      target_ready = found != nil && found[1] != nil && found[1].price.to_i > 0
      assert("Phase49G positive-price database object resolved for live shop transaction", target_ready,
             found == nil ? "nil" : "type=#{found[0]} id=#{found[1].id} price=#{found[1].price}")
      return false unless target_ready
      target_type = found[0]
      target = found[1]
      target_id = target.id.to_i

      normal_row = [target_type, target_id]
      normal_price_ready = FS_SHOP_GOODS.item(normal_row).equal?(target) &&
        !FS_SHOP_GOODS.custom_price?(normal_row) &&
        FS_SHOP_GOODS.price(normal_row, target).to_i == target.price.to_i
      assert("Phase49G normal VX shop row resolves database price exactly", normal_price_ready,
             "id=#{target_id} db=#{target.price} actual=#{FS_SHOP_GOODS.price(normal_row,target)}")

      bool_row = [target_type, target_id, true, 1]
      bool_column_ready = !FS_SHOP_GOODS.custom_price?(bool_row) &&
        FS_SHOP_GOODS.price(bool_row, target).to_i == target.price.to_i
      assert("Phase49G VX boolean third column never masquerades as custom price", bool_column_ready,
             "custom=#{FS_SHOP_GOODS.custom_price?(bool_row)} actual=#{FS_SHOP_GOODS.price(bool_row,target)}")

      custom_row = [target_type, target_id, 1, 137]
      negative_row = [target_type, target_id, 1, -999]
      custom_price_ready = FS_SHOP_GOODS.custom_price?(custom_row) &&
        FS_SHOP_GOODS.price(custom_row, target).to_i == 137 &&
        FS_SHOP_GOODS.price(negative_row, target).to_i == 0
      assert("Phase49G FS custom-price row honors exact value and zero clamp", custom_price_ready,
             "custom=#{FS_SHOP_GOODS.price(custom_row,target)} negative=#{FS_SHOP_GOODS.price(negative_row,target)}")

      profiles = {}
      profile_keys = [:luka, :camp, :habel, :elf, :city]
      profiles_ready = true
      for key in profile_keys
        rows = FS_REGION_SHOPS.profile_goods(key)
        profiles[key] = rows
        profiles_ready = false if rows == nil || rows.empty?
        for row in rows
          profiles_ready = false unless row.is_a?(Array) && row.size >= 4 &&
            row[2] == 1 && FS_SHOP_GOODS.item(row) != nil && row[3].to_i >= 0
        end
      end
      assert("Phase49G all five region-shop profiles emit valid custom-price goods", profiles_ready,
             profile_keys.collect { |key| [key, (profiles[key] || []).size] }.inspect)

      luka_first = profiles[:luka][0]
      camp_first = profiles[:camp][0]
      camp_markup_ready = luka_first[0,2] == camp_first[0,2] &&
        luka_first[3].to_i == 600 && camp_first[3].to_i == 720
      assert("Phase49G camp first-tier transport markup is exact 120 percent", camp_markup_ready,
             "luka=#{luka_first.inspect} camp=#{camp_first.inspect}")

      FS_ECONOMY.unlock(:luka_return_credit)
      luka_discount = FS_REGION_SHOPS.profile_goods(:luka)
      luka_discount_ready = FS_REGION_SHOPS.discount_rate(:luka).to_i == 90 &&
        luka_discount[0][3].to_i == 540
      assert("Phase49G Luka return-credit discount projects into goods at 90 percent", luka_discount_ready,
             "rate=#{FS_REGION_SHOPS.discount_rate(:luka)} first=#{luka_discount[0].inspect}")

      habel_before = profiles[:habel]
      FS_ECONOMY.unlock(:habel_forging)
      habel_after = FS_REGION_SHOPS.profile_goods(:habel)
      habel_unlock_ready = FS_REGION_SHOPS.discount_rate(:habel).to_i == 90 &&
        habel_after.size > habel_before.size && habel_after[0][3].to_i == 1980
      assert("Phase49G Habel forging unlock adds higher tier and applies 90 percent pricing", habel_unlock_ready,
             "before=#{habel_before.size} after=#{habel_after.size} first=#{habel_after[0].inspect}")

      region_open_ready = FS_REGION_SHOPS.open(:luka,
        [[target_type, target_id, 777]], true) == true &&
        $game_temp.shop_purchase_only == true && $game_temp.fs_shop_key == :luka &&
        $game_temp.fs_shop_profile == :luka && $game_temp.next_scene == "shop" &&
        !$game_temp.shop_goods.empty? && $game_temp.shop_goods[-1][2] == 1 &&
        $game_temp.shop_goods[-1][3].to_i == 777
      assert("Phase49G region-shop open projects profile/extra goods/purchase-only contract", region_open_ready,
             "key=#{$game_temp.fs_shop_key.inspect} purchase_only=#{$game_temp.shop_purchase_only} tail=#{($game_temp.shop_goods[-1] rescue nil).inspect}")

      echo_good = [0, 200, 1, FS_BLACK_MARKET.echo_price(0)]
      fragment_good = [0, 600, 1, FS_BLACK_MARKET.fragment_price(0)]
      core_good = [0, 800, 1, FS_BLACK_MARKET.special_core_price(2)]
      stock_ready = FS_BLACK_MARKET.stock_for_good(echo_good).to_i == 1 &&
        FS_BLACK_MARKET.stock_for_good(fragment_good).to_i == 5 &&
        FS_BLACK_MARKET.stock_for_good(core_good).to_i == 1 &&
        FS_BLACK_MARKET.stock_for_good([1, target_id, 1, 1]).to_i == 0
      assert("Phase49G black-market stock classes map Echo/Fragment/Core exactly", stock_ready,
             "echo=#{FS_BLACK_MARKET.stock_for_good(echo_good)} frag=#{FS_BLACK_MARKET.stock_for_good(fragment_good)} core=#{FS_BLACK_MARKET.stock_for_good(core_good)}")

      FS_BLACK_MARKET.record_purchase(echo_good, 1)
      purchase_ready = FS_BLACK_MARKET.purchased(echo_good).to_i == 1 &&
        FS_BLACK_MARKET.remaining_for_good(echo_good).to_i == 0
      assert("Phase49G black-market purchase decrements chapter-local stock exactly", purchase_ready,
             "purchased=#{FS_BLACK_MARKET.purchased(echo_good)} remaining=#{FS_BLACK_MARKET.remaining_for_good(echo_good)}")

      FS_ECONOMY.chapter = 1
      chapter_reset_ready = FS_BLACK_MARKET.purchased(echo_good).to_i == 0 &&
        FS_BLACK_MARKET.remaining_for_good(echo_good).to_i == 1
      assert("Phase49G chapter change resets black-market purchase ledger", chapter_reset_ready,
             "chapter=#{FS_ECONOMY.chapter} purchased=#{FS_BLACK_MARKET.purchased(echo_good)}")

      black_price_ready = FS_BLACK_MARKET.echo_price(0).to_i == 2500 &&
        FS_BLACK_MARKET.echo_price(15).to_i == 4000 &&
        FS_BLACK_MARKET.fragment_price(0).to_i == 650 &&
        FS_BLACK_MARKET.fragment_price(15).to_i == 900 &&
        FS_BLACK_MARKET.special_core_price(2).to_i == 9000 &&
        FS_BLACK_MARKET.special_core_price(6).to_i == 12000
      assert("Phase49G black-market price ladders are deterministic by tier/actor", black_price_ready)

      # Scene_Shop 的正式 commit path，以 stub windows 隔離 UI，只讓交易方法本身運作。
      count_now = $game_party.item_number(target).to_i
      $game_party.lose_item(target, count_now) if count_now > 0
      $game_party.lose_gold($game_party.gold.to_i) if $game_party.gold.to_i > 0
      $game_party.gain_gold(5000)
      buy_scene = Scene_Shop.new
      command_stub = Phase49GWindowStub.new
      number_stub = Phase49GWindowStub.new
      buy_stub = Phase49GWindowStub.new
      gold_stub = Phase49GWindowStub.new
      status_stub = Phase49GWindowStub.new
      sell_stub = Phase49GWindowStub.new
      command_stub.index = 0
      number_stub.number = 3
      buy_stub.price_value = 137
      buy_stub.good = custom_row
      buy_scene.instance_variable_set(:@command_window, command_stub)
      buy_scene.instance_variable_set(:@number_window, number_stub)
      buy_scene.instance_variable_set(:@buy_window, buy_stub)
      buy_scene.instance_variable_set(:@gold_window, gold_stub)
      buy_scene.instance_variable_set(:@status_window, status_stub)
      buy_scene.instance_variable_set(:@sell_window, sell_stub)
      buy_scene.instance_variable_set(:@item, target)
      $game_temp.fs_shop_key = :luka
      buy_gold_before = $game_party.gold.to_i
      buy_scene.decide_number_input
      buy_ready = $game_party.item_number(target).to_i == 3 &&
        $game_party.gold.to_i == buy_gold_before - 411 &&
        gold_stub.refresh_count > 0 && buy_stub.refresh_count > 0 && status_stub.refresh_count > 0
      assert("Phase49G Scene_Shop buy commit uses Window_ShopBuy custom price exactly", buy_ready,
             "count=#{$game_party.item_number(target)} gold=#{$game_party.gold} expected=#{buy_gold_before-411}")

      sell_scene = Scene_Shop.new
      sell_command = Phase49GWindowStub.new
      sell_number = Phase49GWindowStub.new
      sell_buy = Phase49GWindowStub.new
      sell_gold = Phase49GWindowStub.new
      sell_status = Phase49GWindowStub.new
      sell_window = Phase49GWindowStub.new
      sell_command.index = 1
      sell_number.number = 2
      sell_scene.instance_variable_set(:@command_window, sell_command)
      sell_scene.instance_variable_set(:@number_window, sell_number)
      sell_scene.instance_variable_set(:@buy_window, sell_buy)
      sell_scene.instance_variable_set(:@gold_window, sell_gold)
      sell_scene.instance_variable_set(:@status_window, sell_status)
      sell_scene.instance_variable_set(:@sell_window, sell_window)
      sell_scene.instance_variable_set(:@item, target)
      sell_gold_before = $game_party.gold.to_i
      sell_gain = 2 * (target.price.to_i / 2)
      sell_scene.decide_number_input
      sell_ready = $game_party.item_number(target).to_i == 1 &&
        $game_party.gold.to_i == sell_gold_before + sell_gain &&
        sell_gold.refresh_count > 0 && sell_window.refresh_count > 0 && sell_status.refresh_count > 0
      assert("Phase49G Scene_Shop sell commit uses database half-price authority", sell_ready,
             "count=#{$game_party.item_number(target)} gain=#{sell_gain} gold=#{$game_party.gold}")

      synth_gold_ready = Sword.sword4_gold_cost([{}, {}, {}, 80]).to_i == 0 &&
        Sword.sword4_gold_cost([{}, {}, {}, 100, 1234]).to_i == 1234 &&
        Sword.sword4_gold_cost([{}, {}, {}, 100, -55]).to_i == 0
      assert("Phase49G Sword synthesis gold column preserves legacy-zero/custom/clamp semantics", synth_gold_ready)

      recipe = Sword::Sword4_Synthesize[2][220] rescue nil
      recipe_ready = recipe.is_a?(Array) && recipe.size >= 5 &&
        recipe[0].is_a?(Hash) && recipe[0][200].to_i == 2 && recipe[0][600].to_i == 4 &&
        recipe[1].is_a?(Hash) && recipe[1].empty? && recipe[2].is_a?(Hash) && recipe[2].empty? &&
        recipe[3].to_i == 100 && recipe[4].to_i == FS_ECONOMY.headgear_craft_gold(0).to_i &&
        recipe[4].to_i == 800
      assert("Phase49G live headgear recipe 220 matches Economy Authority projection", recipe_ready,
             recipe.inspect)

      armor = $data_armors[220] rescue nil
      echo_item = $data_items[200] rescue nil
      fragment_item = $data_items[600] rescue nil
      craft_resources_ready = armor != nil && echo_item != nil && fragment_item != nil
      assert("Phase49G headgear forge database resources exist", craft_resources_ready,
             "armor=#{armor == nil ? 'nil' : armor.name} echo=#{echo_item == nil ? 'nil' : echo_item.name} frag=#{fragment_item == nil ? 'nil' : fragment_item.name}")

      if craft_resources_ready
        FS_ECONOMY.lock(:habel_forging)
        $game_party.lose_item(armor, $game_party.item_number(armor)) if $game_party.item_number(armor) > 0
        forge_locked = FS_ECONOMY.forge_headgear(220) == :locked
        FS_ECONOMY.unlock(:habel_forging)
        forge_not_owned = FS_ECONOMY.forge_headgear(220) == :not_owned
        forge_guard_ready = forge_locked && forge_not_owned
        assert("Phase49G forge authority distinguishes locked and not-owned guards", forge_guard_ready,
               "locked=#{forge_locked} not_owned=#{forge_not_owned}")

        $game_party.gain_item(armor, 1)
        $game_party.lose_item(echo_item, $game_party.item_number(echo_item)) if $game_party.item_number(echo_item) > 0
        $game_party.lose_item(fragment_item, $game_party.item_number(fragment_item)) if $game_party.item_number(fragment_item) > 0
        $game_party.lose_gold($game_party.gold.to_i) if $game_party.gold.to_i > 0
        material_short = FS_ECONOMY.forge_headgear(220) == :material_short
        $game_party.gain_item(echo_item, 2)
        $game_party.gain_item(fragment_item, 6)
        gold_short = FS_ECONOMY.forge_headgear(220) == :gold_short
        forge_short_ready = material_short && gold_short
        assert("Phase49G forge authority distinguishes material-short and gold-short guards", forge_short_ready,
               "material=#{material_short} gold=#{gold_short}")

        FS_ECONOMY.lock(:zero_protocol_license)
        FS_ECONOMY.lock(:memory_reconstruction)
        FS_ECONOMY.data[:craft_credit] = 0
        $game_party.gain_gold(2500)
        forge_result = FS_ECONOMY.forge_headgear(220)
        forge_commit_ready = forge_result == :success && FS_ECONOMY.headgear_level(220).to_i == 1 &&
          $game_party.item_number(echo_item).to_i == 0 &&
          $game_party.item_number(fragment_item).to_i == 0 &&
          $game_party.gold.to_i == 0 && $game_party.has_item?(armor, true)
        assert("Phase49G forge transaction commits exact material/gold/state deltas", forge_commit_ready,
               "result=#{forge_result.inspect} level=#{FS_ECONOMY.headgear_level(220)} echo=#{$game_party.item_number(echo_item)} frag=#{$game_party.item_number(fragment_item)} gold=#{$game_party.gold}")
      else
        assert("Phase49G forge authority distinguishes locked and not-owned guards", false, "resources missing")
        assert("Phase49G forge authority distinguishes material-short and gold-short guards", false, "resources missing")
        assert("Phase49G forge transaction commits exact material/gold/state deltas", false, "resources missing")
      end

      log("[PHASE49G_SHOP] normal=#{normal_price_ready} bool=#{bool_column_ready} custom=#{custom_price_ready} profiles=#{profiles_ready} camp=#{camp_markup_ready} luka=#{luka_discount_ready} habel=#{habel_unlock_ready} open=#{region_open_ready}")
      log("[PHASE49G_BLACK_MARKET] stock=#{stock_ready} purchase=#{purchase_ready} chapter_reset=#{chapter_reset_ready} prices=#{black_price_ready}")
      log("[PHASE49G_TRANSACTIONS] buy=#{buy_ready} sell=#{sell_ready} synth_gold=#{synth_gold_ready} recipe=#{recipe_ready} forge=#{forge_commit_ready}")
    rescue Exception => e
      error = e
      exception(e, "phase49g_economy_shop_craft")
    ensure
      $game_temp = temp_before
      $game_message = message_before
      $game_system = system_before
      $game_switches = switches_before
      $game_variables = variables_before
      $game_self_switches = self_switches_before
      $game_actors = actors_before
      $game_party = party_before
      $game_troop = troop_before
      $game_map = map_before
      $game_player = player_before
      $fog_data = fog_data_before
      $fog_transition = fog_transition_before
      $self_var = self_var_before
      $game_ats = game_ats_before
      $ats_default = ats_default_before
      $game_condition_members = condition_before
      $riding_data = riding_before
      $game_parapassa = parapassa_before
      $game_ring_cm = ring_cm_before
      $game_ring_menu = ring_menu_before
      $scene = scene_before
      begin
        Graphics.frame_count = frame_before
      rescue
      end
    end

    restore_ready = $game_temp.equal?(temp_before) && $game_message.equal?(message_before) &&
      $game_system.equal?(system_before) && $game_switches.equal?(switches_before) &&
      $game_variables.equal?(variables_before) && $game_self_switches.equal?(self_switches_before) &&
      $game_actors.equal?(actors_before) && $game_party.equal?(party_before) &&
      $game_troop.equal?(troop_before) && $game_map.equal?(map_before) &&
      $game_player.equal?(player_before) && $fog_data.equal?(fog_data_before) &&
      $self_var.equal?(self_var_before) && $game_ats.equal?(game_ats_before) &&
      $ats_default.equal?(ats_default_before) && $game_condition_members.equal?(condition_before) &&
      $riding_data.equal?(riding_before) && $game_parapassa.equal?(parapassa_before) &&
      $game_ring_cm.equal?(ring_cm_before) && $game_ring_menu.equal?(ring_menu_before) &&
      $scene.equal?(scene_before) && $fog_transition == fog_transition_before &&
      Graphics.frame_count.to_i == frame_before.to_i
    log("[PHASE49G_RESTORE_DETAIL] globals=#{restore_ready}")
    assert("Phase49G economy sandbox restores every formal global identity", restore_ready)

    ready = error == nil && sandbox_ready && target_ready && normal_price_ready &&
      bool_column_ready && custom_price_ready && profiles_ready && camp_markup_ready &&
      luka_discount_ready && habel_unlock_ready && region_open_ready && stock_ready &&
      purchase_ready && chapter_reset_ready && black_price_ready && buy_ready && sell_ready &&
      synth_gold_ready && recipe_ready && craft_resources_ready && forge_guard_ready &&
      forge_short_ready && forge_commit_ready && restore_ready && @fail_count.to_i == fail_before
    log("[PHASE49G_RUNTIME_VI] shop=#{normal_price_ready && custom_price_ready && profiles_ready} black_market=#{stock_ready && purchase_ready && chapter_reset_ready} transactions=#{buy_ready && sell_ready} craft=#{synth_gold_ready && recipe_ready && forge_commit_ready} restore=#{restore_ready} ready=#{ready}")
    assert("Phase49G Economy / Shop / Craft Runtime Semantic VI completed", ready,
           "fail_delta=#{@fail_count.to_i - fail_before}")
    return ready
  end

  #--------------------------------------------------------------------------
  # ● Phase49H：Map / Event Runtime Semantic VII
  #--------------------------------------------------------------------------
  # TEST-only：使用 detached new-game globals + Map8，插入 synthetic RPG::Event。
  # 不寫 Data/Map*.rvdata，不保留 SelfSwitch/SelfVar/ObjectPlacement 狀態。
  # 覆蓋：
  #   - FS_Z21 Self Variable / Interpreter bridge / <bool> page condition
  #   - changeSelfSwitch -> Game_Map#refresh -> Minimap marker revision/cache
  #   - FS_ObjectPlacement 三物件對三位置、錯位、方向、完成、鎖定、保存、reset
  #--------------------------------------------------------------------------
  def self.p49h_make_page(comments = nil)
    page = RPG::Event::Page.new
    rows = []
    if comments != nil
      comments.each do |text|
        rows.push(RPG::EventCommand.new(108, 0, [text.to_s]))
      end
    end
    rows.push(RPG::EventCommand.new(0, 0, []))
    page.list = rows
    return page
  end

  def self.p49h_make_event_data(id, name, x, y, pages = nil)
    data = RPG::Event.new(x.to_i, y.to_i)
    data.id = id.to_i
    data.name = name.to_s
    data.pages = pages == nil ? [p49h_make_page] : pages
    return data
  end

  def self.p49h_marker_type_for(event_id)
    return nil unless defined?(FS_NORMAL_MINIMAP) && FS_NORMAL_MINIMAP.respond_to?(:marker_entries)
    rows = FS_NORMAL_MINIMAP.marker_entries
    rows.each do |entry|
      return entry[:type] if entry[:event_id].to_i == event_id.to_i
    end
    return nil
  rescue Exception
    return nil
  end

  def self.run_phase49h_map_event_runtime_semantic_vii
    return false unless test_mode?
    fail_before = @fail_count.to_i
    log("[FIXTURE] PHASE49H-MAP-EVENT-RUNTIME-VII")

    provider_ok = (defined?(Game_SelfVariables) != nil) &&
      (defined?(FS_ObjectPlacement) != nil) &&
      (defined?(FS_NORMAL_MINIMAP) != nil) &&
      (defined?(Game_Event) != nil) && (defined?(Game_Interpreter) != nil) &&
      Game_Event.method_defined?(:self_var) && Game_Event.method_defined?(:self_var=) &&
      Game_Interpreter.method_defined?(:changeSelfSwitch) &&
      Game_Interpreter.method_defined?(:fs_place_refresh)
    assert("Phase49H SelfVar / Event / ObjectPlacement / Minimap providers ready", provider_ok)
    return false unless provider_ok

    frame_before = Graphics.frame_count
    scene_before = $scene
    temp_before = $game_temp
    message_before = $game_message
    system_before = $game_system
    switches_before = $game_switches
    variables_before = $game_variables
    self_switches_before = $game_self_switches
    actors_before = $game_actors
    party_before = $game_party
    troop_before = $game_troop
    map_before = $game_map
    player_before = $game_player
    self_var_before = $self_var
    fog_data_before = $fog_data
    fog_transition_before = $fog_transition
    game_ats_before = $game_ats
    ats_default_before = $ats_default
    condition_before = $game_condition_members
    riding_before = $riding_data
    parapassa_before = $game_parapassa
    ring_cm_before = $game_ring_cm
    ring_menu_before = $game_ring_menu

    cache_names = [
      :@fs_nm_marker_cache_map_id,
      :@fs_nm_marker_cache_revision,
      :@fs_nm_marker_cache_entries,
      :@fs_nm_marker_cache_signature,
      :@fs_nm_terrain_cache_key,
      :@fs_nm_terrain_cache
    ]
    cache_snaps = {}
    cache_names.each do |name|
      cache_snaps[name] = p49c_snapshot_ivar_transactional(FS_NormalMap_Minimap, name)
    end

    test_group = :__phase49h_threeway__
    had_test_config = FS_ObjectPlacement::PUZZLES.has_key?(test_group)
    old_test_config = had_test_config ? FS_ObjectPlacement::PUZZLES[test_group] : nil

    sandbox_ready = false
    fixture_ready = false
    selfvar_ready = false
    interpreter_ready = false
    isolation_ready = false
    bool_baseline_ready = false
    selfvar_refresh_flag_ready = false
    page_flip_ready = false
    marker_refresh_ready = false
    page_marker_ready = false
    selfswitch_write_ready = false
    selfswitch_marker_ready = false
    parser_ready = false
    initial_ready = false
    wrong_ready = false
    direction_ready = false
    physical_ready = false
    completion_ready = false
    locks_ready = false
    persistence_ready = false
    reset_state_ready = false
    reset_switch_ready = false
    restore_ready = false
    error = nil

    synthetic_ids = []
    begin
      Scene_Title.new.create_game_objects
      $game_map.setup(8)
      sandbox_ready = !$game_temp.equal?(temp_before) && !$game_system.equal?(system_before) &&
        !$game_map.equal?(map_before) && !$game_player.equal?(player_before) &&
        $game_map.map_id.to_i == 8 && $game_map.width.to_i >= 6 && $game_map.height.to_i >= 5 &&
        $scene.equal?(scene_before)
      assert("Phase49H detached Map8 sandbox installed through formal create_game_objects/setup", sandbox_ready,
             "map=#{$game_map.object_id} size=#{$game_map.width}x#{$game_map.height}")
      return false unless sandbox_ready

      # Synthetic marker/page-condition event.
      conditional_id = 49001
      conditional_pages = [
        p49h_make_page,
        p49h_make_page(["<bool: self_var >= 5>", "<MAP_ICON:boss>", "<MAP_LABEL:Phase49H條件>"])
      ]
      conditional_data = p49h_make_event_data(
        conditional_id,
        "Phase49H條件 <MAP_ICON:quest> <MAP_LABEL:Phase49H條件>",
        1, 1, conditional_pages)
      conditional_event = Game_Event.new(8, conditional_data)
      $game_map.events[conditional_id] = conditional_event
      synthetic_ids.push(conditional_id)

      # Synthetic self-switch driven marker event.
      marker_id = 49002
      marker_data = p49h_make_event_data(
        marker_id,
        "Phase49H開關 <MAP_ICON:quest> <MAP_ICON_A:shop> <MAP_LABEL:Phase49H開關>",
        2, 1)
      marker_event = Game_Event.new(8, marker_data)
      $game_map.events[marker_id] = marker_event
      synthetic_ids.push(marker_id)

      # Synthetic three-object / four-slot fixture (fourth slot optional).
      object_rows = [
        [49010, "bird",   1, 2],
        [49011, "vase",   2, 2],
        [49012, "candle", 3, 2]
      ]
      slot_rows = [
        [49020, "bird",   1, 4, ""],
        [49021, "vase",   2, 4, ""],
        [49022, "candle", 3, 4, "2"],
        [49023, "*",      4, 4, "optional"]
      ]
      object_events = {}
      slot_events = {}
      object_rows.each do |row|
        id = row[0]
        data = p49h_make_event_data(id,
          "Phase49H物件 <FSOP_OBJECT:#{test_group}:#{row[1]}>", row[2], row[3])
        ev = Game_Event.new(8, data)
        $game_map.events[id] = ev
        synthetic_ids.push(id)
        object_events[row[1]] = ev
      end
      slot_rows.each do |row|
        id = row[0]
        tag = if row[4] == "optional"
          "<FSOP_SLOT:#{test_group}:#{row[1]}::optional>"
        elsif row[4].to_s.empty?
          "<FSOP_SLOT:#{test_group}:#{row[1]}>"
        else
          "<FSOP_SLOT:#{test_group}:#{row[1]}:#{row[4]}>"
        end
        data = p49h_make_event_data(id, "Phase49H位置 #{tag}", row[2], row[3])
        ev = Game_Event.new(8, data)
        $game_map.events[id] = ev
        synthetic_ids.push(id)
        slot_events[row[1]] = ev
      end

      FS_ObjectPlacement::PUZZLES[test_group] = {
        :quest_id => 0,
        :objective_id => -1,
        :next_objective_id => -1,
        :lock_when_complete => true,
        :object_lock_switch => "A",
        :wrong_policy => :allow,
        :ground_policy => :allow,
        :occupied_policy => :previous,
        :required_count => 0,
        :complete_switch => 4901,
        :progress_variable => 4902,
        :total_variable => 4903,
        :pickup_se => nil,
        :correct_se => nil,
        :wrong_se => nil,
        :ground_se => nil,
        :occupied_se => nil,
        :complete_se => nil
      }

      FS_NORMAL_MINIMAP.bump_marker_revision
      fixture_ready = synthetic_ids.all? { |id| $game_map.events[id] != nil } &&
        FS_ObjectPlacement::PUZZLES.has_key?(test_group) &&
        p49h_marker_type_for(conditional_id) == :quest &&
        p49h_marker_type_for(marker_id) == :quest
      assert("Phase49H synthetic Event/Page/ObjectPlacement fixture installed without Data mutation", fixture_ready,
             "events=#{synthetic_ids.size} marker=#{p49h_marker_type_for(conditional_id).inspect}/#{p49h_marker_type_for(marker_id).inspect}")

      # Self Variable direct event API.
      conditional_event.self_var = 2
      selfvar_ready = conditional_event.self_var.to_i == 2 &&
        $self_var[[conditional_id, 8]].to_i == 2
      assert("Phase49H Game_Event Self Variable read/write uses [event_id,map_id] storage key", selfvar_ready,
             "value=#{conditional_event.self_var} raw=#{$self_var[[conditional_id,8]]}")

      interpreter = Game_Interpreter.new
      interpreter.instance_variable_set(:@event_id, conditional_id)
      interpreter_ready = interpreter.self_var.to_i == 2 &&
        (interpreter.self_var = 4).to_i == 4 && conditional_event.self_var.to_i == 4
      assert("Phase49H Game_Interpreter self_var bridge reads/writes current event exactly", interpreter_ready,
             "event=#{conditional_id} value=#{conditional_event.self_var}")

      other_data = p49h_make_event_data(conditional_id, "Phase49H跨圖", 1, 1)
      other_event = Game_Event.new(9, other_data)
      other_event.self_var = 9
      isolation_ready = other_event.self_var.to_i == 9 && conditional_event.self_var.to_i == 4 &&
        $self_var[[conditional_id, 9]].to_i == 9 && $self_var[[conditional_id, 8]].to_i == 4
      assert("Phase49H Self Variable isolates identical event ids across map ids", isolation_ready,
             "map8=#{$self_var[[conditional_id,8]]} map9=#{$self_var[[conditional_id,9]]}")

      bool_baseline_ready = FS_NORMAL_MINIMAP.event_page_index(conditional_event).to_i == 0 &&
        p49h_marker_type_for(conditional_id) == :quest
      assert("Phase49H Eventeer <bool> condition keeps lower page active below threshold", bool_baseline_ready,
             "page=#{FS_NORMAL_MINIMAP.event_page_index(conditional_event)} marker=#{p49h_marker_type_for(conditional_id).inspect}")

      $game_map.need_refresh = false
      rev_before = FS_NORMAL_MINIMAP.marker_revision.to_i
      conditional_event.self_var = 5
      selfvar_refresh_flag_ready = $game_map.need_refresh == true
      assert("Phase49H Self Variable setter flags Game_Map refresh", selfvar_refresh_flag_ready,
             "need_refresh=#{$game_map.need_refresh}")

      $game_map.refresh
      page_flip_ready = FS_NORMAL_MINIMAP.event_page_index(conditional_event).to_i == 1
      assert("Phase49H Game_Map refresh re-evaluates Eventeer <bool> page after Self Variable threshold", page_flip_ready,
             "page=#{FS_NORMAL_MINIMAP.event_page_index(conditional_event)} self_var=#{conditional_event.self_var}")

      rev_after = FS_NORMAL_MINIMAP.marker_revision.to_i
      marker_refresh_ready = rev_after > rev_before && $game_map.need_refresh == false
      assert("Phase49H Game_Map#refresh consumes need_refresh and bumps Minimap marker revision", marker_refresh_ready,
             "revision=#{rev_before}->#{rev_after} need_refresh=#{$game_map.need_refresh}")

      page_marker_ready = p49h_marker_type_for(conditional_id) == :boss
      assert("Phase49H Minimap marker cache reflects page-driven icon change after Event refresh", page_marker_ready,
             "marker=#{p49h_marker_type_for(conditional_id).inspect}")

      marker_interpreter = Game_Interpreter.new
      marker_rev_before = FS_NORMAL_MINIMAP.marker_revision.to_i
      marker_interpreter.changeSelfSwitch(8, marker_id, "A", true)
      selfswitch_write_ready = $game_self_switches[[8, marker_id, "A"]] == true &&
        $game_map.need_refresh == true
      assert("Phase49H changeSelfSwitch writes native key and requests Map refresh", selfswitch_write_ready,
             "key=#{$game_self_switches[[8,marker_id,'A']].inspect} need_refresh=#{$game_map.need_refresh}")
      $game_map.refresh
      selfswitch_marker_ready = FS_NORMAL_MINIMAP.marker_revision.to_i > marker_rev_before &&
        p49h_marker_type_for(marker_id) == :shop
      assert("Phase49H SelfSwitch refresh invalidates Minimap cache and projects A-page marker icon", selfswitch_marker_ready,
             "revision=#{marker_rev_before}->#{FS_NORMAL_MINIMAP.marker_revision} marker=#{p49h_marker_type_for(marker_id).inspect}")

      # ObjectPlacement parser / baseline.
      objs = FS_ObjectPlacement.objects(test_group)
      slots = FS_ObjectPlacement.slots(test_group)
      optional_count = slots.select { |slot| slot[:optional] }.size
      parser_ready = objs.size == 3 && slots.size == 4 && optional_count == 1 &&
        FS_ObjectPlacement.required_count(test_group).to_i == 3
      assert("Phase49H ObjectPlacement parses three objects + three required/one optional slots", parser_ready,
             "objects=#{objs.size} slots=#{slots.size} optional=#{optional_count} required=#{FS_ObjectPlacement.required_count(test_group)}")

      FS_ObjectPlacement.refresh_group(test_group, nil, true)
      initial_ready = FS_ObjectPlacement.correct_count(test_group).to_i == 0 &&
        !FS_ObjectPlacement.completed?(test_group) &&
        $game_variables[4902].to_i == 0 && $game_variables[4903].to_i == 3 &&
        $game_switches[4901] == false
      assert("Phase49H ObjectPlacement initial progress/required/incomplete state exact", initial_ready,
             "progress=#{$game_variables[4902]}/#{$game_variables[4903]} complete=#{$game_switches[4901]}")

      bird = object_events["bird"]
      vase = object_events["vase"]
      candle = object_events["candle"]
      bird_slot = slot_events["bird"]
      vase_slot = slot_events["vase"]
      candle_slot = slot_events["candle"]
      optional_slot = slot_events["*"]

      bird_home = [bird.x, bird.y, bird.direction]
      vase_home = [vase.x, vase.y, vase.direction]
      candle_home = [candle.x, candle.y, candle.direction]

      FS_ObjectPlacement.move_event(bird, [vase_slot.x, vase_slot.y, 2])
      FS_ObjectPlacement.refresh_group(test_group, nil, true)
      wrong_ready = $game_self_switches[[8, vase_slot.id, "A"]] == false &&
        $game_self_switches[[8, vase_slot.id, "B"]] == true &&
        $game_self_switches[[8, vase_slot.id, "C"]] == true &&
        FS_ObjectPlacement.correct_count(test_group).to_i == 0
      assert("Phase49H wrong object on slot drives B/C SelfSwitch without false completion", wrong_ready,
             "A=#{$game_self_switches[[8,vase_slot.id,'A']]} B=#{$game_self_switches[[8,vase_slot.id,'B']]} C=#{$game_self_switches[[8,vase_slot.id,'C']]}")

      FS_ObjectPlacement.move_event(bird, bird_home)
      FS_ObjectPlacement.move_event(candle, [candle_slot.x, candle_slot.y, 4])
      FS_ObjectPlacement.refresh_group(test_group, nil, true)
      direction_ready = $game_self_switches[[8, candle_slot.id, "A"]] == false &&
        $game_self_switches[[8, candle_slot.id, "B"]] == true &&
        $game_self_switches[[8, candle_slot.id, "C"]] == true
      assert("Phase49H direction-constrained slot rejects otherwise matching object", direction_ready,
             "dir=#{candle.direction} A=#{$game_self_switches[[8,candle_slot.id,'A']]} B=#{$game_self_switches[[8,candle_slot.id,'B']]}")

      FS_ObjectPlacement.move_event(bird, [bird_slot.x, bird_slot.y, 2])
      FS_ObjectPlacement.move_event(vase, [vase_slot.x, vase_slot.y, 2])
      FS_ObjectPlacement.move_event(candle, [candle_slot.x, candle_slot.y, 2])
      physical_ready = FS_ObjectPlacement.correct_count(test_group).to_i == 3 &&
        FS_ObjectPlacement.physically_complete?(test_group) == true
      assert("Phase49H three distinct objects at matching slots satisfy physical completion", physical_ready,
             "correct=#{FS_ObjectPlacement.correct_count(test_group)} required=#{FS_ObjectPlacement.required_count(test_group)}")

      FS_ObjectPlacement.refresh_group(test_group, nil, true)
      completion_ready = FS_ObjectPlacement.completed?(test_group) == true &&
        $game_switches[4901] == true && $game_variables[4902].to_i == 3 &&
        $game_variables[4903].to_i == 3
      assert("Phase49H completed puzzle commits completed-state/switch/progress variables exact", completion_ready,
             "complete=#{FS_ObjectPlacement.completed?(test_group)} switch=#{$game_switches[4901]} progress=#{$game_variables[4902]}/#{$game_variables[4903]}")

      lock_ok = [bird, vase, candle].all? { |ev| $game_self_switches[[8, ev.id, "A"]] == true }
      slots_ok = [bird_slot, vase_slot, candle_slot].all? do |ev|
        $game_self_switches[[8, ev.id, "A"]] == true &&
        $game_self_switches[[8, ev.id, "B"]] == false &&
        $game_self_switches[[8, ev.id, "C"]] == true
      end
      optional_ok = $game_self_switches[[8, optional_slot.id, "A"]] == false &&
        $game_self_switches[[8, optional_slot.id, "B"]] == false &&
        $game_self_switches[[8, optional_slot.id, "C"]] == false
      locks_ready = lock_ok && slots_ok && optional_ok
      assert("Phase49H completion locks objects and projects required/optional slot A/B/C states", locks_ready,
             "locks=#{lock_ok} slots=#{slots_ok} optional=#{optional_ok}")

      saved_positions = {
        bird.id => [bird.x, bird.y, bird.direction],
        vase.id => [vase.x, vase.y, vase.direction],
        candle.id => [candle.x, candle.y, candle.direction]
      }
      bird.moveto(4, 1)
      vase.moveto(4, 2)
      candle.moveto(4, 3)
      [bird, vase, candle].each { |ev| FS_ObjectPlacement.restore_position(ev) }
      persistence_ready = [bird, vase, candle].all? do |ev|
        row = saved_positions[ev.id]
        ev.x == row[0] && ev.y == row[1] && ev.direction == row[2]
      end
      assert("Phase49H ObjectPlacement saved-position storage restores all three object coordinates/directions", persistence_ready,
             saved_positions.inspect)

      reset_result = FS_ObjectPlacement.reset(test_group, false, nil)
      home_ok = bird.x == bird_home[0] && bird.y == bird_home[1] &&
        vase.x == vase_home[0] && vase.y == vase_home[1] &&
        candle.x == candle_home[0] && candle.y == candle_home[1]
      pos_keys_absent = [bird, vase, candle].all? do |ev|
        !FS_ObjectPlacement.positions.has_key?(FS_ObjectPlacement.position_key(ev))
      end
      reset_state_ready = reset_result == :reset && home_ok && pos_keys_absent &&
        !FS_ObjectPlacement.completed?(test_group)
      assert("Phase49H ObjectPlacement reset returns homes and clears saved/completed state", reset_state_ready,
             "result=#{reset_result.inspect} homes=#{home_ok} positions_cleared=#{pos_keys_absent}")

      object_switches_clear = [bird, vase, candle].all? do |ev|
        $game_self_switches[[8, ev.id, "A"]] == false &&
        $game_self_switches[[8, ev.id, "D"]] == false
      end
      slot_switches_clear = [bird_slot, vase_slot, candle_slot, optional_slot].all? do |ev|
        $game_self_switches[[8, ev.id, "A"]] == false &&
        $game_self_switches[[8, ev.id, "B"]] == false &&
        $game_self_switches[[8, ev.id, "C"]] == false
      end
      reset_switch_ready = object_switches_clear && slot_switches_clear &&
        $game_switches[4901] == false && $game_variables[4902].to_i == 0 &&
        $game_variables[4903].to_i == 3
      assert("Phase49H reset clears object/slot SelfSwitches and progress/complete outputs exact", reset_switch_ready,
             "objects=#{object_switches_clear} slots=#{slot_switches_clear} vars=#{$game_variables[4902]}/#{$game_variables[4903]}")

      log("[PHASE49H_SELFVAR] direct=#{selfvar_ready} interpreter=#{interpreter_ready} isolation=#{isolation_ready} page=#{page_flip_ready}")
      log("[PHASE49H_MARKER] selfvar_refresh=#{marker_refresh_ready} page_icon=#{page_marker_ready} selfswitch=#{selfswitch_marker_ready}")
      log("[PHASE49H_OBJECTS] parser=#{parser_ready} wrong=#{wrong_ready} direction=#{direction_ready} complete=#{completion_ready} persist=#{persistence_ready} reset=#{reset_state_ready && reset_switch_ready}")
    rescue Exception => e
      error = e
      exception(e, "phase49h_map_event")
    ensure
      begin
        synthetic_ids.each do |id|
          $game_map.events.delete(id) if $game_map != nil && $game_map.events != nil
        end
      rescue Exception
      end
      begin
        if had_test_config
          FS_ObjectPlacement::PUZZLES[test_group] = old_test_config
        else
          FS_ObjectPlacement::PUZZLES.delete(test_group)
        end
      rescue Exception
      end
      begin
        $game_map.dispose_neolight if $game_map != nil && $game_map.respond_to?(:dispose_neolight)
      rescue Exception
      end

      $game_temp = temp_before
      $game_message = message_before
      $game_system = system_before
      $game_switches = switches_before
      $game_variables = variables_before
      $game_self_switches = self_switches_before
      $game_actors = actors_before
      $game_party = party_before
      $game_troop = troop_before
      $game_map = map_before
      $game_player = player_before
      $self_var = self_var_before
      $fog_data = fog_data_before
      $fog_transition = fog_transition_before
      $game_ats = game_ats_before
      $ats_default = ats_default_before
      $game_condition_members = condition_before
      $riding_data = riding_before
      $game_parapassa = parapassa_before
      $game_ring_cm = ring_cm_before
      $game_ring_menu = ring_menu_before
      $scene = scene_before
      Graphics.frame_count = frame_before

      cache_ok = true
      cache_names.each do |name|
        cache_ok = false unless p49c_restore_ivar_transactional(
          FS_NormalMap_Minimap, name, cache_snaps[name])
      end
      config_ok = if had_test_config
        FS_ObjectPlacement::PUZZLES[test_group].equal?(old_test_config)
      else
        !FS_ObjectPlacement::PUZZLES.has_key?(test_group)
      end
      globals_ok = $game_temp.equal?(temp_before) && $game_message.equal?(message_before) &&
        $game_system.equal?(system_before) && $game_switches.equal?(switches_before) &&
        $game_variables.equal?(variables_before) && $game_self_switches.equal?(self_switches_before) &&
        $game_actors.equal?(actors_before) && $game_party.equal?(party_before) &&
        $game_troop.equal?(troop_before) && $game_map.equal?(map_before) &&
        $game_player.equal?(player_before) && $self_var.equal?(self_var_before) &&
        $fog_data.equal?(fog_data_before) && $game_ats.equal?(game_ats_before) &&
        $ats_default.equal?(ats_default_before) && $game_condition_members.equal?(condition_before) &&
        $riding_data.equal?(riding_before) && $game_parapassa.equal?(parapassa_before) &&
        $game_ring_cm.equal?(ring_cm_before) && $game_ring_menu.equal?(ring_menu_before) &&
        $scene.equal?(scene_before) && $fog_transition == fog_transition_before &&
        Graphics.frame_count.to_i == frame_before.to_i
      restore_ready = cache_ok && config_ok && globals_ok
      log("[PHASE49H_RESTORE_DETAIL] config=#{config_ok} cache=#{cache_ok} globals=#{globals_ok}")
    end

    assert("Phase49H synthetic config/cache/globals restore exact", restore_ready)
    ready = error == nil && sandbox_ready && fixture_ready && selfvar_ready &&
      interpreter_ready && isolation_ready && bool_baseline_ready && selfvar_refresh_flag_ready &&
      page_flip_ready && marker_refresh_ready && page_marker_ready && selfswitch_write_ready &&
      selfswitch_marker_ready && parser_ready && initial_ready && wrong_ready && direction_ready &&
      physical_ready && completion_ready && locks_ready && persistence_ready && reset_state_ready &&
      reset_switch_ready && restore_ready && @fail_count.to_i == fail_before
    log("[PHASE49H_RUNTIME_VII] selfvar=#{selfvar_ready && interpreter_ready && isolation_ready && page_flip_ready} marker=#{marker_refresh_ready && page_marker_ready && selfswitch_marker_ready} objects=#{parser_ready && physical_ready && completion_ready && locks_ready && persistence_ready && reset_state_ready && reset_switch_ready} restore=#{restore_ready} ready=#{ready}")
    assert("Phase49H Map / Event Runtime Semantic VII completed", ready,
           "fail_delta=#{@fail_count.to_i - fail_before}")
    return ready
  end

  #--------------------------------------------------------------------------
  # ● Phase49I：Scene / UI Lifecycle Integrated Soak VIII
  #--------------------------------------------------------------------------
  # TEST-only：使用 detached new-game Map8 globals，連續兩輪真正呼叫各 Scene 的
  # start/update/terminate（不進 Scene_Base#main 無限迴圈），驗證 Map/Ring/SoulBook/
  # Menu 的 native Window/Sprite lifecycle、Neo Light 與 Normal Minimap 重建／清理，
  # 以及同一套 Cache/Scene 鏈第二輪仍可重開。
  #--------------------------------------------------------------------------
  def self.p49i_visual_disposed?(obj)
    return true if obj == nil
    if obj.is_a?(Array)
      obj.each do |row|
        return false unless p49i_visual_disposed?(row)
      end
      return true
    end
    if obj.respond_to?(:disposed?)
      return obj.disposed? == true
    end
    return true
  rescue
    return false
  end

  def self.p49i_scene_visuals_disposed?(scene, names)
    return false if scene == nil
    names.each do |name|
      obj = nil
      begin
        obj = scene.instance_variable_get(name)
      rescue
        obj = nil
      end
      return false unless p49i_visual_disposed?(obj)
    end
    return true
  rescue
    return false
  end

  # RGSS2 的 Viewport 沒有 disposed?；不能用不存在的查詢 API 判定 cleanup。
  # 這裡改驗 Spriteset 真正擁有、且可查詢生命週期的 Sprite/Plane/Weather/Timer，
  # 以及 Normal Minimap 自己的 Sprite reference。
  def self.p49i_spriteset_disposed?(spriteset)
    return false if spriteset == nil
    names = [:@parallax, :@character_sprites, :@shadow_sprite, :@weather,
             :@picture_sprites, :@timer_sprite, :@fs_nm_minimap_sprite,
             :@fs_nm_fullmap_sprite, :@fs_nm_player_sprite,
             :@fs_nm_full_player_sprite]
    observed = false
    names.each do |name|
      obj = nil
      begin
        obj = spriteset.instance_variable_get(name)
      rescue
        obj = nil
      end
      next if obj == nil
      if obj.is_a?(Array)
        observed = true unless obj.empty?
        return false unless p49i_visual_disposed?(obj)
      elsif obj.respond_to?(:disposed?)
        observed = true
        return false unless obj.disposed? == true
      end
    end
    return observed
  rescue
    return false
  end

  # Normal Minimap v1.0.4 的 bitmap refresh 不是 start 即時建立；
  # refresh_interval 預設 4，Spriteset_Map#initialize 第一次只累加 counter。
  # 用有限次正式 Spriteset_Map#update 模擬真實 visual frames，等到 Minimap 可見。
  def self.p49i_settle_minimap_visual(spriteset)
    return false if spriteset == nil
    cfg = FS_NormalMap_Minimap.settings
    interval = cfg[:refresh_interval].to_i
    interval = 4 if interval <= 0
    limit = interval + 2
    limit.times do
      sprite = spriteset.instance_variable_get(:@fs_nm_minimap_sprite) rescue nil
      if sprite != nil && sprite.respond_to?(:disposed?) && !sprite.disposed?
        return true
      end
      spriteset.update
    end
    sprite = spriteset.instance_variable_get(:@fs_nm_minimap_sprite) rescue nil
    return sprite != nil && sprite.respond_to?(:disposed?) && !sprite.disposed?
  rescue
    return false
  end

  def self.p49i_live_neolight_ids
    rows = []
    return rows if $game_map == nil || !$game_map.respond_to?(:events)
    $game_map.events.each do |id, ev|
      next if ev == nil
      sprite = nil
      begin
        sprite = ev.instance_variable_get(:@nl_sprite)
      rescue
        sprite = nil
      end
      if sprite != nil && sprite.respond_to?(:disposed?) && !sprite.disposed?
        rows.push(id.to_i)
      end
    end
    return rows.sort
  rescue
    return []
  end

  def self.p49i_force_dispose_scene(scene)
    return if scene == nil
    begin
      scene.instance_variables.each do |name|
        obj = scene.instance_variable_get(name) rescue nil
        list = obj.is_a?(Array) ? obj : [obj]
        list.each do |entry|
          next if entry == nil
          begin
            if entry.respond_to?(:dispose) &&
               (!entry.respond_to?(:disposed?) || !entry.disposed?)
              entry.dispose
            end
          rescue
          end
        end
      end
    rescue
    end
  end

  def self.run_phase49i_scene_ui_lifecycle_soak_viii
    return false unless test_mode?
    fail_before = @fail_count.to_i
    log("[FIXTURE] PHASE49I-SCENE-UI-LIFECYCLE-VIII")

    provider_ok = (defined?(Scene_Map) != nil) && (defined?(Scene_Menu) != nil) &&
      (defined?(Scene_RM2) != nil) && (defined?(Scene_SoulBookSelect) != nil) &&
      (defined?(FS_RING_MENU_ACTIONS) != nil) && (defined?(FS_NORMAL_MINIMAP) != nil) &&
      Scene_Map.method_defined?(:start) && Scene_Map.method_defined?(:terminate) &&
      Scene_Menu.method_defined?(:start) && Scene_Menu.method_defined?(:terminate) &&
      Scene_RM2.method_defined?(:start) && Scene_RM2.method_defined?(:terminate)
    assert("Phase49I Map/Menu/Ring/SoulBook/Minimap lifecycle providers ready", provider_ok)
    return false unless provider_ok

    frame_before = Graphics.frame_count
    brightness_before = Graphics.brightness
    scene_before = $scene
    temp_before = $game_temp
    message_before = $game_message
    system_before = $game_system
    switches_before = $game_switches
    variables_before = $game_variables
    self_switches_before = $game_self_switches
    actors_before = $game_actors
    party_before = $game_party
    troop_before = $game_troop
    map_before = $game_map
    player_before = $game_player
    self_var_before = $self_var
    fog_data_before = $fog_data
    fog_transition_before = $fog_transition
    game_ats_before = $game_ats
    ats_default_before = $ats_default
    condition_before = $game_condition_members
    riding_before = $riding_data
    parapassa_before = $game_parapassa
    ring_cm_before = $game_ring_cm
    ring_menu_before = $game_ring_menu
    screen_print_before = $screen_print

    cache_names = [
      :@fs_nm_marker_cache_map_id,
      :@fs_nm_marker_cache_revision,
      :@fs_nm_marker_cache_entries,
      :@fs_nm_marker_cache_signature,
      :@fs_nm_terrain_cache_key,
      :@fs_nm_terrain_cache
    ]
    cache_snaps = {}
    cache_names.each do |name|
      cache_snaps[name] = p49c_snapshot_ivar_transactional(FS_NormalMap_Minimap, name)
    end

    sandbox_ready = false
    ring_contract_ready = false
    rows = []
    active_scenes = []
    detached_temp = nil
    error = nil

    begin
      Scene_Title.new.create_game_objects
      detached_temp = $game_temp
      $game_map.setup(8)
      begin
        $game_party.setup_starting_members if $game_party.respond_to?(:setup_starting_members)
      rescue
      end
      begin
        x = [$game_player.x.to_i, $game_map.width.to_i - 1].min
        y = [$game_player.y.to_i, $game_map.height.to_i - 1].min
        x = 0 if x < 0
        y = 0 if y < 0
        $game_player.moveto(x, y)
        $game_player.make_encounter_count if $game_player.respond_to?(:make_encounter_count)
      rescue
      end
      FS_RING_MENU_ACTIONS::UNLOCK_SWITCHES.each { |id| $game_switches[id] = true }
      FS_RING_MENU_ACTIONS.build_commands
      FS_NORMAL_MINIMAP.show

      sandbox_ready = !$game_temp.equal?(temp_before) && !$game_system.equal?(system_before) &&
        !$game_map.equal?(map_before) && !$game_player.equal?(player_before) &&
        $game_map.map_id.to_i == 8 && FS_NORMAL_MINIMAP.available? &&
        FS_NORMAL_MINIMAP.visible? && $scene.equal?(scene_before)
      assert("Phase49I detached Map8 UI sandbox installed with Normal Minimap visible", sandbox_ready,
             "map=#{$game_map.object_id} visible=#{FS_NORMAL_MINIMAP.visible?}")
      return false unless sandbox_ready

      ring_contract_ready = $game_ring_cm.is_a?(Array) && $game_ring_cm.size == 6 &&
        FS_RING_MENU_ACTIONS::UNLOCK_SWITCHES.all? { |id| $game_switches[id] == true }
      assert("Phase49I Ring command assets/unlock contract prepared for real Scene start", ring_contract_ready,
             "commands=#{$game_ring_cm.size}")

      2.times do |cycle_index|
        row = {}
        row[:cycle] = cycle_index + 1

        # Map -> Ring
        map_scene = Scene_Map.new
        active_scenes.push(map_scene)
        $scene = map_scene
        map_scene.start
        map_ss = map_scene.instance_variable_get(:@spriteset)
        map_msg = map_scene.instance_variable_get(:@message_window)
        minimap_settled = p49i_settle_minimap_visual(map_ss)
        minimap_sprite = map_ss == nil ? nil : map_ss.instance_variable_get(:@fs_nm_minimap_sprite)
        neo_ids = p49i_live_neolight_ids
        row[:map_start] = map_ss != nil && map_msg != nil &&
          !p49i_visual_disposed?(map_msg) && minimap_settled && minimap_sprite != nil &&
          minimap_sprite.respond_to?(:disposed?) && !minimap_sprite.disposed? && !neo_ids.empty?
        row[:neo_ids] = neo_ids
        row[:map_start_minimap_settled] = minimap_settled

        FS_RING_MENU_ACTIONS.open_ring(0, false)
        ring_scene = $scene
        map_scene.terminate
        active_scenes.delete(map_scene)
        row[:map_to_ring_cleanup] = p49i_spriteset_disposed?(map_ss) &&
          p49i_visual_disposed?(map_msg) && p49i_live_neolight_ids.empty?

        # Ring -> SoulBook
        active_scenes.push(ring_scene)
        ring_scene.start
        ring_scene.update
        ring_cmd = ring_scene.instance_variable_get(:@command_window)
        ring_back = ring_scene.instance_variable_get(:@menuback_sprite2)
        row[:ring_start] = ring_cmd != nil && ring_back != nil &&
          !p49i_visual_disposed?(ring_cmd) && !p49i_visual_disposed?(ring_back) &&
          ring_cmd.respond_to?(:enabled?) && ring_cmd.enabled?(0)

        soul_dispatch = FS_RING_MENU_ACTIONS.execute(:soul_book, 0)
        soul_scene = $scene
        row[:soul_dispatch] = soul_dispatch == true && soul_scene.is_a?(Scene_SoulBookSelect) &&
          $game_temp.fs_soulbook_from_ring == true && $game_temp.fs_ring_subscene == :soul_book
        ring_scene.terminate
        active_scenes.delete(ring_scene)
        row[:ring_cleanup] = p49i_scene_visuals_disposed?(ring_scene,
          [:@command_window, :@menuback_sprite, :@menuback_sprite2])

        # SoulBook -> Ring
        active_scenes.push(soul_scene)
        soul_scene.start
        soul_scene.update
        soul_help = soul_scene.instance_variable_get(:@help_window)
        soul_cmd = soul_scene.instance_variable_get(:@command_window)
        row[:soul_start] = soul_help != nil && soul_cmd != nil &&
          !p49i_visual_disposed?(soul_help) && !p49i_visual_disposed?(soul_cmd)
        $game_temp.fs_soulbook_from_ring = false
        $game_temp.fs_ring_subscene = nil
        FS_RING_MENU_ACTIONS.open_ring(0, false)
        ring2 = $scene
        row[:soul_return] = ring2.is_a?(Scene_RM2) &&
          $game_temp.fs_ring_return_index.to_i == 0 &&
          $game_temp.fs_soulbook_from_ring == false && $game_temp.fs_ring_subscene == nil
        soul_scene.terminate
        active_scenes.delete(soul_scene)
        row[:soul_cleanup] = p49i_scene_visuals_disposed?(soul_scene,
          [:@help_window, :@command_window, :@menuback_sprite])

        # Ring -> Minimap -> Map
        active_scenes.push(ring2)
        ring2.start
        ring2.update
        ring2_cmd = ring2.instance_variable_get(:@command_window)
        row[:ring_reopen] = ring2_cmd != nil && ring2_cmd.respond_to?(:index) &&
          ring2_cmd.index.to_i == 0 && ring2_cmd.enabled?(4)
        FS_NORMAL_MINIMAP.hide
        map_dispatch = FS_RING_MENU_ACTIONS.execute(:minimap, 4)
        map2 = $scene
        row[:minimap_dispatch] = map_dispatch == true && map2.is_a?(Scene_Map) &&
          FS_NORMAL_MINIMAP.visible? && $game_temp.fs_ring_return_index.to_i == 4
        ring2.terminate
        active_scenes.delete(ring2)

        active_scenes.push(map2)
        map2.start
        map2_ss = map2.instance_variable_get(:@spriteset)
        map2_settled = p49i_settle_minimap_visual(map2_ss)
        map2_minimap = map2_ss == nil ? nil : map2_ss.instance_variable_get(:@fs_nm_minimap_sprite)
        row[:map_rebuild] = map2_ss != nil && map2_settled && map2_minimap != nil &&
          map2_minimap.respond_to?(:disposed?) && !map2_minimap.disposed? &&
          !p49i_live_neolight_ids.empty?
        row[:map_rebuild_minimap_settled] = map2_settled

        # Map -> Menu
        $game_temp.menu_beep = false
        map2.call_menu
        menu_scene = $scene
        map2.terminate
        active_scenes.delete(map2)
        row[:map_to_menu_cleanup] = menu_scene.is_a?(Scene_Menu) &&
          p49i_spriteset_disposed?(map2_ss) && p49i_live_neolight_ids.empty?

        active_scenes.push(menu_scene)
        menu_scene.start
        menu_scene.update
        menu_cmd = menu_scene.instance_variable_get(:@command_window)
        menu_gold = menu_scene.instance_variable_get(:@gold_window)
        menu_status = menu_scene.instance_variable_get(:@status_window)
        menu_sprites = menu_scene.instance_variable_get(:@sprites)
        item_max = menu_cmd != nil && menu_cmd.respond_to?(:item_max) ? menu_cmd.item_max.to_i : 0
        row[:menu_start] = menu_cmd != nil && menu_gold != nil && menu_status != nil &&
          menu_sprites.is_a?(Array) && menu_sprites.size >= item_max && menu_sprites.size >= 8 &&
          !p49i_visual_disposed?(menu_cmd) && !p49i_visual_disposed?(menu_status) &&
          menu_sprites.all? { |sp| sp == nil || !sp.disposed? }
        row[:menu_update] = menu_scene.instance_variable_get(:@command_window) == menu_cmd

        map3 = Scene_Map.new
        $scene = map3
        menu_scene.terminate
        active_scenes.delete(menu_scene)
        row[:menu_cleanup] = p49i_scene_visuals_disposed?(menu_scene,
          [:@command_window, :@gold_window, :@status_window, :@sprites,
           :@menubackitem_sprite, :@menuback_sprite, :@menuback_sprite2,
           :@menuback_sprite3, :@light, :@light2])

        # Return Map; hide minimap without replacing scene and ensure overlay is disposed.
        active_scenes.push(map3)
        map3.start
        map3_ss = map3.instance_variable_get(:@spriteset)
        map3_settled = p49i_settle_minimap_visual(map3_ss)
        map3_minimap = map3_ss == nil ? nil : map3_ss.instance_variable_get(:@fs_nm_minimap_sprite)
        row[:post_menu_map] = map3_ss != nil && map3_settled && map3_minimap != nil &&
          map3_minimap.respond_to?(:disposed?) && !map3_minimap.disposed? &&
          !p49i_live_neolight_ids.empty?
        row[:post_menu_minimap_settled] = map3_settled
        FS_NORMAL_MINIMAP.hide
        hide_flag_ready = !FS_NORMAL_MINIMAP.visible? && !FS_NORMAL_MINIMAP.visible_flag
        player_cleared_immediate = false
        if map3_ss != nil && map3_ss.respond_to?(:fs_nm_update_minimap)
          # Formal Minimap 每幀先更新 player marker，再依 refresh_interval 更新 bitmap。
          # 所以 hide 後 player marker 應於第一幀清除，而 minimap bitmap 允許在
          # 正式 refresh interval 內完成 dispose，不要求不存在的單幀 immediate cleanup。
          map3_ss.fs_nm_update_minimap
          hidden_player = map3_ss.instance_variable_get(:@fs_nm_player_sprite) rescue nil
          player_cleared_immediate = hidden_player == nil
          cfg = FS_NormalMap_Minimap.settings
          interval = cfg[:refresh_interval].to_i
          interval = 4 if interval <= 0
          (interval + 2).times do
            hidden_sprite = map3_ss.instance_variable_get(:@fs_nm_minimap_sprite) rescue nil
            break if hidden_sprite == nil
            map3_ss.fs_nm_update_minimap
          end
        end
        hidden_sprite = map3_ss == nil ? nil : (map3_ss.instance_variable_get(:@fs_nm_minimap_sprite) rescue nil)
        hidden_player = map3_ss == nil ? nil : (map3_ss.instance_variable_get(:@fs_nm_player_sprite) rescue nil)
        row[:hide_overlay_flag] = hide_flag_ready
        row[:hide_player_immediate] = player_cleared_immediate
        row[:hide_overlay] = hide_flag_ready && player_cleared_immediate && hidden_sprite == nil && hidden_player == nil

        $scene = Scene_Map.new
        map3.terminate
        active_scenes.delete(map3)
        row[:final_map_cleanup] = p49i_spriteset_disposed?(map3_ss) && p49i_live_neolight_ids.empty?

        # 下一輪重新顯示，證明 Cache/Bitmap 被前輪 dispose 後仍能重開。
        FS_NORMAL_MINIMAP.show
        rows.push(row)
      end
    rescue Exception => e
      error = e
      exception(e, "phase49i_scene_ui_lifecycle")
    ensure
      active_scenes.reverse_each { |scene| p49i_force_dispose_scene(scene) }
      begin
        $game_map.dispose_neolight if $game_map != nil && $game_map.respond_to?(:dispose_neolight)
      rescue
      end
      begin
        if detached_temp != nil && detached_temp.respond_to?(:background_bitmap)
          bmp = detached_temp.background_bitmap
          if bmp != nil && bmp.respond_to?(:disposed?) && !bmp.disposed?
            bmp.dispose
          end
        end
      rescue
      end

      cache_names.each do |name|
        p49c_restore_ivar_transactional(FS_NormalMap_Minimap, name, cache_snaps[name])
      end

      $game_temp = temp_before
      $game_message = message_before
      $game_system = system_before
      $game_switches = switches_before
      $game_variables = variables_before
      $game_self_switches = self_switches_before
      $game_actors = actors_before
      $game_party = party_before
      $game_troop = troop_before
      $game_map = map_before
      $game_player = player_before
      $self_var = self_var_before
      $fog_data = fog_data_before
      $fog_transition = fog_transition_before
      $game_ats = game_ats_before
      $ats_default = ats_default_before
      $game_condition_members = condition_before
      $riding_data = riding_before
      $game_parapassa = parapassa_before
      $game_ring_cm = ring_cm_before
      $game_ring_menu = ring_menu_before
      $screen_print = screen_print_before
      $scene = scene_before
      begin
        Graphics.frame_count = frame_before
        Graphics.brightness = brightness_before
      rescue
      end
    end

    map_start_ready = rows.size == 2 && rows.all? { |r| r[:map_start] }
    assert("Phase49I Scene_Map start + bounded visual settle creates Spriteset/Message/Minimap/NeoLight in both cycles", map_start_ready,
           rows.map { |r| [r[:cycle], r[:map_start_minimap_settled], r[:neo_ids]] }.inspect)
    map_ring_cleanup_ready = rows.size == 2 && rows.all? { |r| r[:map_to_ring_cleanup] }
    assert("Phase49I Map -> Ring terminate disposes map/minimap/NeoLight transients", map_ring_cleanup_ready)
    ring_start_ready = rows.size == 2 && rows.all? { |r| r[:ring_start] }
    assert("Phase49I Scene_RM2 start/update builds enabled Ring Window and background assets", ring_start_ready)
    soul_dispatch_ready = rows.size == 2 && rows.all? { |r| r[:soul_dispatch] }
    assert("Phase49I Ring -> SoulBook dispatch preserves exact return flags", soul_dispatch_ready)
    ring_cleanup_ready = rows.size == 2 && rows.all? { |r| r[:ring_cleanup] }
    assert("Phase49I Scene_RM2 terminate disposes Ring Window/background sprites", ring_cleanup_ready)
    soul_start_ready = rows.size == 2 && rows.all? { |r| r[:soul_start] }
    assert("Phase49I Scene_SoulBookSelect start/update builds live Help/Command windows", soul_start_ready)
    soul_return_ready = rows.size == 2 && rows.all? { |r| r[:soul_return] }
    assert("Phase49I SoulBook -> Ring return contract restores index/flags exactly", soul_return_ready)
    soul_cleanup_ready = rows.size == 2 && rows.all? { |r| r[:soul_cleanup] }
    assert("Phase49I Scene_SoulBookSelect terminate disposes all owned windows/background", soul_cleanup_ready)
    ring_reopen_ready = rows.size == 2 && rows.all? { |r| r[:ring_reopen] }
    assert("Phase49I Ring reopens after subscene with expected index and Minimap command enabled", ring_reopen_ready)
    minimap_dispatch_ready = rows.size == 2 && rows.all? { |r| r[:minimap_dispatch] }
    assert("Phase49I Ring Minimap action toggles visible and returns exact Scene_Map", minimap_dispatch_ready)
    map_rebuild_ready = rows.size == 2 && rows.all? { |r| r[:map_rebuild] }
    assert("Phase49I returned Scene_Map recreates Normal Minimap and NeoLight sprites", map_rebuild_ready)
    map_menu_cleanup_ready = rows.size == 2 && rows.all? { |r| r[:map_to_menu_cleanup] }
    assert("Phase49I Map -> Menu transition disposes map transients before menu start", map_menu_cleanup_ready)
    menu_start_ready = rows.size == 2 && rows.all? { |r| r[:menu_start] }
    assert("Phase49I Scene_Menu start creates core windows plus complete FF13/YEM command sprite set", menu_start_ready)
    menu_update_ready = rows.size == 2 && rows.all? { |r| r[:menu_update] }
    assert("Phase49I Scene_Menu update executes one frame without replacing command authority", menu_update_ready)
    menu_cleanup_ready = rows.size == 2 && rows.all? { |r| r[:menu_cleanup] }
    assert("Phase49I Scene_Menu terminate disposes core windows/FF13 visual sprites", menu_cleanup_ready)
    post_menu_ready = rows.size == 2 && rows.all? { |r| r[:post_menu_map] }
    assert("Phase49I Map reopens after Menu terminate with Minimap/NeoLight rebuilt", post_menu_ready)
    hide_overlay_ready = rows.size == 2 && rows.all? { |r| r[:hide_overlay] }
    assert("Phase49I Normal Minimap hide removes minimap/player sprites without scene replacement", hide_overlay_ready)
    final_cleanup_ready = rows.size == 2 && rows.all? { |r| r[:final_map_cleanup] }
    assert("Phase49I final Map terminate clears all map native transients in both cycles", final_cleanup_ready)
    repeat_ready = error == nil && rows.size == 2 && rows.all? do |r|
      r.values_at(:map_start, :map_to_ring_cleanup, :ring_start, :soul_dispatch,
        :ring_cleanup, :soul_start, :soul_return, :soul_cleanup, :ring_reopen,
        :minimap_dispatch, :map_rebuild, :map_to_menu_cleanup, :menu_start,
        :menu_update, :menu_cleanup, :post_menu_map, :hide_overlay,
        :final_map_cleanup).all? { |v| v == true }
    end
    assert("Phase49I two consecutive Map/Ring/SoulBook/Menu lifecycle cycles are repeatable", repeat_ready,
           "cycles=#{rows.size}")

    restore_ready = $game_temp.equal?(temp_before) && $game_message.equal?(message_before) &&
      $game_system.equal?(system_before) && $game_switches.equal?(switches_before) &&
      $game_variables.equal?(variables_before) && $game_self_switches.equal?(self_switches_before) &&
      $game_actors.equal?(actors_before) && $game_party.equal?(party_before) &&
      $game_troop.equal?(troop_before) && $game_map.equal?(map_before) &&
      $game_player.equal?(player_before) && $self_var.equal?(self_var_before) &&
      $fog_data.equal?(fog_data_before) && $fog_transition == fog_transition_before &&
      $game_ats.equal?(game_ats_before) && $ats_default.equal?(ats_default_before) &&
      $game_condition_members.equal?(condition_before) && $riding_data.equal?(riding_before) &&
      $game_parapassa.equal?(parapassa_before) && $game_ring_cm.equal?(ring_cm_before) &&
      $game_ring_menu.equal?(ring_menu_before) && $screen_print.equal?(screen_print_before) &&
      $scene.equal?(scene_before) && Graphics.frame_count.to_i == frame_before.to_i &&
      Graphics.brightness.to_i == brightness_before.to_i
    log("[PHASE49I_RESTORE_DETAIL] globals=#{restore_ready} cycles=#{rows.size}")
    assert("Phase49I scene/UI soak restores every formal global identity and Graphics state", restore_ready)
    log("[PHASE49I_MAP_DIAGNOSTIC] rows=#{rows.map { |r| [r[:cycle], r[:map_start_minimap_settled], r[:map_to_ring_cleanup], r[:map_rebuild_minimap_settled], r[:map_to_menu_cleanup], r[:post_menu_minimap_settled], r[:hide_overlay_flag], r[:hide_player_immediate], r[:hide_overlay], r[:final_map_cleanup]] }.inspect}")

    ready = sandbox_ready && ring_contract_ready && repeat_ready && restore_ready &&
      error == nil && @fail_count.to_i == fail_before
    log("[PHASE49I_RUNTIME_VIII] map=#{map_start_ready && map_rebuild_ready && post_menu_ready} ring=#{ring_start_ready && ring_cleanup_ready && ring_reopen_ready} soul=#{soul_dispatch_ready && soul_start_ready && soul_return_ready && soul_cleanup_ready} menu=#{menu_start_ready && menu_update_ready && menu_cleanup_ready} minimap=#{minimap_dispatch_ready && hide_overlay_ready} cleanup=#{map_ring_cleanup_ready && map_menu_cleanup_ready && final_cleanup_ready} repeat=#{repeat_ready} restore=#{restore_ready} ready=#{ready}")
    assert("Phase49I Scene / UI Lifecycle Integrated Soak VIII completed", ready,
           "fail_delta=#{@fail_count.to_i - fail_before}")
    return ready
  end

  #--------------------------------------------------------------------------
  # ● Phase49J：Integrated Nonbattle Repeatability Soak IX
  #--------------------------------------------------------------------------
  # TEST-only：既有 Phase49B-I 全綠後，以反向 I→H→G→F→E→D→C→B
  # 再跑一輪真實 semantic fixtures。目的不是增加 method-exists 數量，而是驗證
  # Save/Load、Scene/UI、Economy、Map/Event、Dungeon、Vehicle 等模組在同一 process
  # 被不同順序連續使用後，仍不會留下跨 fixture 污染。
  #--------------------------------------------------------------------------
  def self.run_phase49j_integrated_nonbattle_repeatability_soak_ix
    return false unless test_mode?
    fail_before = @fail_count.to_i
    log("[FIXTURE] PHASE49J-INTEGRATED-NONBATTLE-REPEATABILITY-IX")

    frame_before = Graphics.frame_count.to_i
    brightness_before = Graphics.brightness.to_i
    refs_before = [$game_temp, $game_message, $game_system, $game_switches,
      $game_variables, $game_self_switches, $game_actors, $game_party,
      $game_troop, $game_map, $game_player, $self_var, $fog_data,
      $game_ats, $ats_default, $game_condition_members, $riding_data,
      $game_parapassa, $game_ring_cm, $game_ring_menu, $screen_print, $scene]
    fog_transition_before = $fog_transition
    map_id_before = ($game_map == nil ? nil : $game_map.map_id.to_i)
    player_pos_before = ($game_player == nil ? nil : [$game_player.x.to_i, $game_player.y.to_i, $game_player.direction.to_i])
    gold_before = ($game_party == nil ? nil : $game_party.gold.to_i)
    minimap_visible_before = (defined?(FS_NORMAL_MINIMAP) != nil ? FS_NORMAL_MINIMAP.visible? : nil)
    minimap_full_before = (defined?(FS_NORMAL_MINIMAP) != nil ? FS_NORMAL_MINIMAP.fullmap_visible? : nil)
    ai_before = (defined?(FS_AI_RANDOM) != nil ? FS_AI_RANDOM.enabled? : nil)
    combat_before = (defined?(FS_COMBAT_RANDOM) != nil ? FS_COMBAT_RANDOM.enabled? : nil)

    temp_fields = [:@next_scene, :@common_event_id, :@fs_rd_pending_key,
      :@fs_rd_pending_floor, :@fs_rd_place_mode, :@fs_rd_force_setup,
      :@fs_rd_suppress_exit_reset]
    temp_snaps = {}
    if $game_temp != nil
      temp_fields.each do |name|
        temp_snaps[name] = p49c_snapshot_ivar_transactional($game_temp, name)
      end
    end

    log("[PHASE49J_REPLAY_BEGIN] order=I,H,G,F,E,D,C,B fail_before=#{fail_before}")
    results = []
    begin
      results << [:I, run_phase49i_scene_ui_lifecycle_soak_viii]
      results << [:H, run_phase49h_map_event_runtime_semantic_vii]
      results << [:G, run_phase49g_economy_shop_craft_runtime_semantic_vi]
      results << [:F, run_phase49f_save_load_runtime_semantic_v]
      results << [:E, run_phase49e_real_transfer_lifecycle_iv]
      results << [:D, run_phase49d_random_dungeon_map_event_semantic_iii]
      results << [:C, run_phase49c_nonbattle_runtime_semantic_ii]
      results << [:B, run_phase49b_vehicle_overlay_semantic]
    rescue Exception => e
      exception(e, "phase49j_reverse_replay")
    end

    replay_ready = results.size == 8 && results.all? { |row| row[1] == true } &&
      @fail_count.to_i == fail_before
    log("[PHASE49J_REPLAY_RESULTS] #{results.inspect} fail_delta=#{@fail_count.to_i - fail_before}")
    assert("Phase49J reverse-order Phase49I->B semantic replay completes with zero new failures",
           replay_ready, "results=#{results.inspect}")

    refs_after = [$game_temp, $game_message, $game_system, $game_switches,
      $game_variables, $game_self_switches, $game_actors, $game_party,
      $game_troop, $game_map, $game_player, $self_var, $fog_data,
      $game_ats, $ats_default, $game_condition_members, $riding_data,
      $game_parapassa, $game_ring_cm, $game_ring_menu, $screen_print, $scene]
    identities_ready = refs_before.size == refs_after.size
    refs_before.each_with_index do |obj, index|
      identities_ready = false unless obj.equal?(refs_after[index])
    end

    temp_ready = true
    if $game_temp != nil
      temp_fields.each do |name|
        mismatch = p49c_transaction_mismatch($game_temp, name, temp_snaps[name])
        temp_ready = false if mismatch != nil
      end
    end
    semantic_ready = Graphics.frame_count.to_i == frame_before &&
      Graphics.brightness.to_i == brightness_before &&
      $fog_transition == fog_transition_before &&
      ($game_map == nil ? nil : $game_map.map_id.to_i) == map_id_before &&
      ($game_player == nil ? nil : [$game_player.x.to_i, $game_player.y.to_i, $game_player.direction.to_i]) == player_pos_before &&
      ($game_party == nil ? nil : $game_party.gold.to_i) == gold_before &&
      (defined?(FS_NORMAL_MINIMAP) != nil ? FS_NORMAL_MINIMAP.visible? : nil) == minimap_visible_before &&
      (defined?(FS_NORMAL_MINIMAP) != nil ? FS_NORMAL_MINIMAP.fullmap_visible? : nil) == minimap_full_before
    rng_ready = (defined?(FS_AI_RANDOM) != nil ? FS_AI_RANDOM.enabled? : nil) == ai_before &&
      (defined?(FS_COMBAT_RANDOM) != nil ? FS_COMBAT_RANDOM.enabled? : nil) == combat_before
    restore_ready = identities_ready && temp_ready && semantic_ready && rng_ready
    log("[PHASE49J_RESTORE_DETAIL] identities=#{identities_ready} temp=#{temp_ready} semantic=#{semantic_ready} rng=#{rng_ready} frame=#{Graphics.frame_count}/#{frame_before}")
    assert("Phase49J reverse replay preserves formal global identities/state/Graphics/RNG baseline",
           restore_ready)

    ready = replay_ready && restore_ready && @fail_count.to_i == fail_before
    log("[PHASE49J_RUNTIME_IX] replay=#{replay_ready} restore=#{restore_ready} ready=#{ready}")
    assert("Phase49J Integrated Nonbattle Repeatability Soak IX completed", ready,
           "fail_delta=#{@fail_count.to_i - fail_before}")
    return ready
  end

  #--------------------------------------------------------------------------
  # ● Shift+F9：非戰鬥回歸
  #--------------------------------------------------------------------------
  def self.run_nonbattle
    return false unless test_mode?
    begin_suite("NONBATTLE")
    assert("TEST mode", test_mode?)
    idle = true
    begin
      idle = !$game_map.interpreter.running?
    rescue
      idle = true
    end
    assert("Map interpreter idle", idle,
           idle ? nil : "請在事件未執行時啟動測試")
    unless idle
      return finish_suite("FAIL")
    end

    if defined?(FS_AI_RANDOM)
      assert("AI deterministic RNG self-test", FS_AI_RANDOM.self_test)
      assert("AI deterministic RNG default OFF", !FS_AI_RANDOM.enabled?)
    else
      assert("AI deterministic RNG exists", false)
    end

    run_authority_fixtures
    phase49b_ready = run_phase49b_vehicle_overlay_semantic
    phase49c_ready = run_phase49c_nonbattle_runtime_semantic_ii
    phase49d_ready = run_phase49d_random_dungeon_map_event_semantic_iii
    phase49e_ready = run_phase49e_real_transfer_lifecycle_iv
    phase49f_ready = run_phase49f_save_load_runtime_semantic_v
    phase49g_ready = run_phase49g_economy_shop_craft_runtime_semantic_vi
    phase49h_ready = run_phase49h_map_event_runtime_semantic_vii
    phase49i_ready = run_phase49i_scene_ui_lifecycle_soak_viii
    phase49j_ready = run_phase49j_integrated_nonbattle_repeatability_soak_ix

    if defined?(FS_NONBATTLE_VALIDATION)
      lines = FS_NONBATTLE_VALIDATION.run
      warn_count = 0
      ok_count = 0
      unexpected = []
      advisory_prefixes = [
        "WARN Vehicle script also writes switches 202, 203, 204"
      ]
      for line in lines
        text = line.to_s
        if text.index("OK   ") == 0
          ok_count += 1
        elsif text.index("INFO Shop price audit skipped") == 0
          if phase49g_ready
            log("[VALIDATION_RESOLVED] Shop price audit skipped | Phase49G current Shop/Economy Authority runtime semantic PASS")
          end
        elsif text.index("WARN ") == 0
          warn_count += 1
          advisory = advisory_prefixes.any? { |prefix| text.index(prefix) == 0 }
          if advisory
            if phase49b_ready
              log("[VALIDATION_RESOLVED] #{text.sub(/^WARN\s+/, "")} | Phase49B runtime semantic PASS")
            else
              warn("Validation advisory", text.sub(/^WARN\s+/, ""))
            end
          else
            unexpected << text
          end
        end
        log("[VALIDATION] #{text}")
      end
      assert("FS_NonBattleValidation returned lines", lines.size > 0, lines.size)
      assert("FS_NonBattleValidation unexpected warnings = 0", unexpected.empty?,
             unexpected.empty? ? "ok=#{ok_count} advisory=#{warn_count}" : unexpected[0, 8].join(" || "))
    else
      assert("FS_NonBattleValidation exists", false)
    end

    return finish_suite
  rescue Exception => e
    exception(e, "run_nonbattle")
    return finish_suite("FAIL")
  end

  #--------------------------------------------------------------------------
  # ● Battle Trace 輔助
  #--------------------------------------------------------------------------
  def self.object_label(obj)
    return "nil" if obj == nil
    name = nil
    begin
      name = obj.name if obj.respond_to?(:name)
    rescue
      name = nil
    end
    id = nil
    begin
      if obj.respond_to?(:actor?) && obj.actor? && obj.respond_to?(:id)
        id = obj.id
      elsif obj.respond_to?(:enemy_id)
        id = obj.enemy_id
      elsif obj.respond_to?(:id)
        id = obj.id
      end
    rescue
      id = nil
    end
    text = obj.class.to_s
    text += "##{id}" if id != nil
    text += "(#{name})" if name != nil && name.to_s != ""
    return text
  end

  def self.battler_snapshot(battler)
    return "nil" if battler == nil
    hp = battler.respond_to?(:hp) ? battler.hp : nil
    maxhp = battler.respond_to?(:maxhp) ? battler.maxhp : nil
    mp = battler.respond_to?(:mp) ? battler.mp : nil
    maxmp = battler.respond_to?(:maxmp) ? battler.maxmp : nil
    states = []
    begin
      states = battler.states.collect { |s| s.id }
    rescue
      states = []
    end
    return "#{object_label(battler)} hp=#{hp}/#{maxhp} mp=#{mp}/#{maxmp} states=#{states.inspect}"
  end

  #--------------------------------------------------------------------------
  # ● Battle Smoke：snapshot / fixture
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  # ● Battle Snapshot：序列化安全層
  #--------------------------------------------------------------------------
  # RGSS 的 Sprite / Bitmap / Viewport 不能 Marshal。地圖型專案常有插件把這些
  # Native Object 暫存在 Runtime 物件中，因此不能再把所有全域物件塞進同一個
  # Marshal.dump。核心戰鬥資料必須可保存；附加／顯示資料則逐項嘗試。
  def self.snapshot_dump(label, object, required = true)
    begin
      data = Marshal.dump(object)
      log("[SNAPSHOT] OK #{label} bytes=#{data.size}")
      return data
    rescue Exception => e
      detail = "#{label} #{e.class}: #{e.message}"
      if required
        log("[SNAPSHOT] FAIL #{detail}")
        raise RuntimeError, "Battle Snapshot 無法保存必要資料：#{detail}"
      else
        log("[SNAPSHOT] SKIP #{detail}")
        return nil
      end
    end
  end

  def self.snapshot_load(data)
    return nil if data == nil
    return Marshal.load(data)
  end

  def self.make_snapshot
    snapshot = {}
    snapshot[:frame_count] = Graphics.frame_count

    # 這些是戰鬥真正可能修改、而且正常 Save Data 本來就必須可 Marshal 的核心物件。
    snapshot[:game_system]        = snapshot_dump("$game_system",        $game_system, true)
    snapshot[:game_message]       = snapshot_dump("$game_message",       $game_message, true)
    snapshot[:game_switches]      = snapshot_dump("$game_switches",      $game_switches, true)
    snapshot[:game_variables]     = snapshot_dump("$game_variables",     $game_variables, true)
    snapshot[:game_self_switches] = snapshot_dump("$game_self_switches", $game_self_switches, true)
    snapshot[:game_actors]        = snapshot_dump("$game_actors",        $game_actors, true)
    snapshot[:game_party]         = snapshot_dump("$game_party",         $game_party, true)
    snapshot[:game_troop]         = snapshot_dump("$game_troop",         $game_troop, true)

    # Map / Player 正常 VX Save 也會保存，但部分地圖插件可能在 Runtime 掛入 Native
    # 顯示物件。Battle Smoke 本身不移動地圖或玩家，因此序列化失敗時可安全略過。
    snapshot[:game_map]    = snapshot_dump("$game_map(optional)",    $game_map, false)
    snapshot[:game_player] = snapshot_dump("$game_player(optional)", $game_player, false)

    # 專案額外 Save Payload。逐項保存，不能讓其中一個顯示型插件拖垮整個 Snapshot。
    if defined?($self_var)
      snapshot[:self_var] = snapshot_dump("$self_var(optional)", $self_var, false)
    end
    if defined?($fog_data)
      snapshot[:fog_data] = snapshot_dump("$fog_data(optional)", $fog_data, false)
    end
    if defined?($fog_transition)
      snapshot[:fog_transition] = snapshot_dump("$fog_transition(optional)", $fog_transition, false)
    end
    if defined?($game_ats)
      snapshot[:game_ats] = snapshot_dump("$game_ats(optional)", $game_ats, false)
    end

    # $game_ring_cm 故意不保存：FS_RingMenuActions 會把 Cache.picture 的 Bitmap
    # 放進 command cache。它是可重建的 UI Cache，且 Battle 不會修改，不屬於 Save State。
    log("[SNAPSHOT] EXCLUDE $game_ring_cm reason=runtime UI bitmap cache")
    return snapshot
  end

  def self.restore_snapshot
    return false if @battle_snapshot == nil
    snapshot = @battle_snapshot

    Graphics.frame_count = snapshot[:frame_count] if snapshot.has_key?(:frame_count)
    $game_system        = snapshot_load(snapshot[:game_system])
    $game_message       = snapshot_load(snapshot[:game_message])
    $game_switches      = snapshot_load(snapshot[:game_switches])
    $game_variables     = snapshot_load(snapshot[:game_variables])
    $game_self_switches = snapshot_load(snapshot[:game_self_switches])
    $game_actors        = snapshot_load(snapshot[:game_actors])
    $game_party         = snapshot_load(snapshot[:game_party])
    $game_troop         = snapshot_load(snapshot[:game_troop])

    map = snapshot_load(snapshot[:game_map])
    player = snapshot_load(snapshot[:game_player])
    $game_map = map if map != nil
    $game_player = player if player != nil

    if snapshot.has_key?(:self_var) && snapshot[:self_var] != nil
      $self_var = snapshot_load(snapshot[:self_var])
    end
    if snapshot.has_key?(:fog_data) && snapshot[:fog_data] != nil
      $fog_data = snapshot_load(snapshot[:fog_data])
    end
    if snapshot.has_key?(:fog_transition) && snapshot[:fog_transition] != nil
      $fog_transition = snapshot_load(snapshot[:fog_transition])
    end
    if snapshot.has_key?(:game_ats) && snapshot[:game_ats] != nil
      $game_ats = snapshot_load(snapshot[:game_ats])
      $ats_default = $game_ats if defined?($ats_default)
    end

    # Runtime UI Cache 不做 Marshal；若未來測試流程使其遺失，使用正式 Builder 重建。
    if defined?(FS_RING_MENU_ACTIONS) &&
       FS_RING_MENU_ACTIONS.respond_to?(:build_commands) &&
       (!defined?($game_ring_cm) || $game_ring_cm == nil || $game_ring_cm.empty?)
      FS_RING_MENU_ACTIONS.build_commands
    end
    return true
  end

  def self.first_valid_actor_id
    return nil unless defined?($data_actors) && $data_actors != nil
    for id in 1...$data_actors.size
      return id if $data_actors[id] != nil
    end
    return nil
  end

  def self.first_valid_troop_id
    return nil unless defined?($data_troops) && $data_troops != nil
    return nil unless defined?($data_enemies) && $data_enemies != nil
    for id in 1...$data_troops.size
      troop = $data_troops[id]
      next if troop == nil || troop.members == nil || troop.members.empty?
      valid = false
      for member in troop.members
        enemy_id = member.enemy_id.to_i rescue 0
        if enemy_id > 0 && enemy_id < $data_enemies.size && $data_enemies[enemy_id] != nil
          valid = true
          break
        end
      end
      return id if valid
    end
    return nil
  end

  #--------------------------------------------------------------------------
  # ● Battle Fixture：Scene_Map 前置準備／等待 Generic Hook
  #--------------------------------------------------------------------------
  # 子 Fixture 可覆寫 prepare_battle_fixture_on_map，於 Snapshot 建立後配置
  # 裝備／物品；prebattle_wait_frames > 0 時，Harness 會保持 Scene_Map，
  # 等指定 frame 數後才真正要求 Scene_Battle。
  def self.prepare_battle_fixture_on_map
    return true
  end

  def self.prebattle_wait_frames
    return 0
  end

  # Snapshot 已還原、Summary 尚未輸出時呼叫。子 Fixture 可覆寫做還原 ASSERT。
  def self.after_battle_snapshot_restore
    return true
  end

  def self.begin_battle_transition_after_wait
    frames = prebattle_wait_frames.to_i
    if frames <= 0
      $game_temp.next_scene = "battle"
      log("[BATTLE] transition requested")
      return true
    end

    @battle_transition_pending = true
    @battle_transition_wait_total = frames
    @battle_transition_wait_done = 0
    @battle_transition_started_frame = Graphics.frame_count
    $game_temp.next_scene = nil
    log("[WAIT] prebattle scheduled frames=#{frames} start_frame=#{@battle_transition_started_frame}")
    return true
  end

  def self.update_prebattle_transition(scene)
    return false unless @battle_transition_pending
    return false unless test_mode?
    return false unless scene.is_a?(Scene_Map)
    current_frame = Graphics.frame_count
    return false if @battle_transition_started_frame != nil &&
                    current_frame <= @battle_transition_started_frame

    @battle_transition_wait_done += 1
    log("[WAIT] prebattle frame #{@battle_transition_wait_done}/#{@battle_transition_wait_total} scene=Scene_Map graphics_frame=#{current_frame}")
    if @battle_transition_wait_done >= @battle_transition_wait_total
      @battle_transition_pending = false
      $game_temp.next_scene = "battle"
      log("[BATTLE] transition requested after prebattle wait frames=#{@battle_transition_wait_total}")
    end
    return true
  rescue Exception => e
    exception(e, "update_prebattle_transition")
    @pending_restore = true
    restore_pending_snapshot_if_needed
    return false
  end

  def self.prepare_party_for_smoke
    if $game_party.members.empty?
      actor_id = first_valid_actor_id
      raise RuntimeError, "Battle Smoke 找不到有效 Actor" if actor_id == nil
      $game_party.add_actor(actor_id)
    end
    for actor in $game_party.members
      if actor.respond_to?(:recover_all)
        actor.recover_all
      else
        actor.hp = actor.maxhp
        actor.mp = actor.maxmp
      end
      actor.clear_actions if actor.respond_to?(:clear_actions)
    end
  end

  def self.run_battle_smoke
    return false unless test_mode?
    return false if @battle_active
    begin_suite("BATTLE_SMOKE")
    assert("TEST mode", test_mode?)

    idle = true
    begin
      idle = !$game_map.interpreter.running?
    rescue
      idle = true
    end
    assert("Map interpreter idle", idle,
           idle ? nil : "請在事件未執行時啟動測試")
    unless idle
      return finish_suite("FAIL")
    end

    @battle_snapshot = make_snapshot
    assert("Battle snapshot created", @battle_snapshot != nil && @battle_snapshot.size > 0,
           @battle_snapshot == nil ? 0 : @battle_snapshot.size)

    prepare_party_for_smoke

    # Phase37C 起，所有需要裝備／物品的 Fixture 都必須在 Scene_Map
    # 先完成正式前置鏈，且任何 ASSERT 失敗都不得進入 Scene_Battle。
    log("[PREBATTLE] fixture preparation begin scene=#{$scene.class} graphics_frame=#{Graphics.frame_count}")
    prep_fail_before = @fail_count.to_i
    prepared = prepare_battle_fixture_on_map
    assert("Prebattle fixture preparation completed", prepared == true,
           "fail_delta=#{@fail_count.to_i - prep_fail_before}")
    if prepared != true || @fail_count.to_i > prep_fail_before
      @pending_restore = true
      restore_pending_snapshot_if_needed
      return false
    end
    log("[PREBATTLE] fixture preparation ready graphics_frame=#{Graphics.frame_count}")

    troop_id = first_valid_troop_id
    assert("Valid Troop fixture found", troop_id != nil, troop_id)
    if troop_id == nil
      @pending_restore = true
      restore_pending_snapshot_if_needed
      return false
    end

    $game_troop.setup(troop_id)
    $game_troop.can_escape = true
    $game_troop.can_lose = true
    assert("Fixture party has battler", $game_party.members.size > 0, $game_party.members.size)
    assert("Fixture troop has enemy", $game_troop.members.size > 0, $game_troop.members.size)

    log("[FIXTURE] troop_id=#{troop_id} party=#{$game_party.members.collect { |a| a.id }.inspect}")
    log("[FIXTURE] enemies=#{$game_troop.members.collect { |e| e.enemy_id rescue 0 }.inspect}")

    if defined?(FS_AI_RANDOM)
      FS_AI_RANDOM.enable(AI_SEED)
      log("[RNG] AI deterministic seed=#{AI_SEED}")
    end

    @battle_active = true
    @battle_frame = 0
    @battle_result = nil
    @battle_fixture_queued = false
    @battle_action_executed = false
    @battle_action_complete_frame = nil
    @battle_forced_subject_object_id = nil
    @battle_forced_target_object_id = nil
    @battle_damage_seen = false
    @battle_combat_rng_count = 0
    @battle_combat_rng_trace = []
    @battle_exit_requested_by_harness = false
    @battle_exit_in_progress = false
    @pending_restore = false
    $game_temp.battle_proc = Proc.new { |result| FS_TEST_HARNESS.on_battle_result(result) }
    begin_battle_transition_after_wait
    return true
  rescue Exception => e
    exception(e, "run_battle_smoke")
    @pending_restore = true
    restore_pending_snapshot_if_needed
    return false
  end

  def self.battle_active?
    return @battle_active == true
  end

  #--------------------------------------------------------------------------
  # ● Phase 34：真正的 Battle Action Driver Smoke
  #--------------------------------------------------------------------------
  def self.queue_forced_attack_fixture(scene)
    return false unless battle_active?
    return true if @battle_fixture_queued
    assert("ForceAction Bridge exists", defined?(FS_FORCE_ACTION_BRIDGE) != nil)
    return false unless defined?(FS_FORCE_ACTION_BRIDGE)

    members = FS_FORCE_ACTION_BRIDGE.party_battle_members
    subject = nil
    for battler in members
      if battler != nil && battler.exist?
        subject = battler
        break
      end
    end
    target = nil
    for enemy in $game_troop.members
      if enemy != nil && enemy.exist?
        target = enemy
        break
      end
    end
    assert("Battle action subject exists", subject != nil,
           subject == nil ? "nil" : object_label(subject))
    assert("Battle action target exists", target != nil,
           target == nil ? "nil" : object_label(target))
    return false if subject == nil || target == nil

    target_index = target.respond_to?(:index) ? target.index : 0
    ok = FS_FORCE_ACTION_BRIDGE.setup_action(subject, 0, 0, target_index)
    assert("Forced normal attack setup", ok,
           "subject=#{object_label(subject)} target=#{object_label(target)} index=#{target_index}")
    return false unless ok

    $game_troop.fs_force_action_queue ||= []
    $game_troop.fs_force_action_queue << subject
    @battle_fixture_queued = true
    @battle_forced_subject_object_id = subject.object_id
    @battle_forced_target_object_id = target.object_id
    log("[ACTION] QUEUED #{object_label(subject)} -> ATTACK -> #{object_label(target)}")
    log("[TARGET] before #{battler_snapshot(target)}")
    return true
  rescue Exception => e
    exception(e, "queue_forced_attack_fixture")
    return false
  end

  def self.test_forced_subject?(battler)
    return false if battler == nil || @battle_forced_subject_object_id == nil
    return battler.object_id == @battle_forced_subject_object_id
  end

  def self.on_execute_action_attack_start(scene, battler)
    return unless battle_active?
    return unless test_forced_subject?(battler)
    log("[ACTION] EXECUTE_ATTACK START subject=#{object_label(battler)} frame=#{@battle_frame}")
  end

  def self.on_execute_action_attack_end(scene, battler)
    return unless battle_active?
    return unless test_forced_subject?(battler)
    @battle_action_executed = true
    @battle_action_complete_frame = @battle_frame
    log("[ACTION] EXECUTE_ATTACK END subject=#{object_label(battler)} frame=#{@battle_frame}")
    assert("Forced attack entered Scene_Battle#execute_action_attack", true,
           object_label(battler))
  end

  def self.before_execute_damage(target, user)
    return nil unless battle_active?
    return nil unless test_forced_subject?(user)
    hp = target.respond_to?(:hp) ? target.hp : nil
    mp = target.respond_to?(:mp) ? target.mp : nil
    return [hp, mp]
  end

  def self.after_execute_damage(target, user, before)
    return unless battle_active?
    return unless test_forced_subject?(user)
    @battle_damage_seen = true
    hp_before = before == nil ? nil : before[0]
    mp_before = before == nil ? nil : before[1]
    hp_after = target.respond_to?(:hp) ? target.hp : nil
    mp_after = target.respond_to?(:mp) ? target.mp : nil
    hp_damage = target.respond_to?(:hp_damage) ? target.hp_damage : nil
    mp_damage = target.respond_to?(:mp_damage) ? target.mp_damage : nil
    log("[DAMAGE] user=#{object_label(user)} target=#{object_label(target)} " +
        "hp=#{hp_before}->#{hp_after} mp=#{mp_before}->#{mp_after} " +
        "hp_damage=#{hp_damage} mp_damage=#{mp_damage}")
  end

  #--------------------------------------------------------------------------
  # ● Phase 35：Combat RNG scope / trace
  #--------------------------------------------------------------------------
  def self.combat_rng_attack_scope?(target, attacker)
    return false unless battle_active?
    return false unless test_forced_subject?(attacker)
    return false unless defined?(FS_COMBAT_RANDOM)
    return true
  end

  def self.begin_combat_rng_scope(label)
    return false unless defined?(FS_COMBAT_RANDOM)
    FS_COMBAT_RANDOM.enable(COMBAT_SEED)
    log("[COMBAT_RNG] ENABLE seed=#{COMBAT_SEED} scope=#{label}")
    return true
  rescue Exception => e
    exception(e, "begin_combat_rng_scope")
    return false
  end

  def self.end_combat_rng_scope(label)
    return false unless defined?(FS_COMBAT_RANDOM)
    if FS_COMBAT_RANDOM.enabled?
      lines = FS_COMBAT_RANDOM.trace_lines
      @battle_combat_rng_count = FS_COMBAT_RANDOM.count
      @battle_combat_rng_trace = lines.dup
      for line in lines
        log("[COMBAT_RNG] #{line}")
      end
      log("[COMBAT_RNG] DISABLE scope=#{label} count=#{@battle_combat_rng_count}")
      FS_COMBAT_RANDOM.disable
    end
    return true
  rescue Exception => e
    exception(e, "end_combat_rng_scope")
    begin
      FS_COMBAT_RANDOM.disable if defined?(FS_COMBAT_RANDOM)
    rescue
    end
    return false
  end

  def self.request_battle_smoke_exit(scene, reason)
    return if @battle_exit_in_progress
    @battle_exit_in_progress = true
    @battle_exit_requested_by_harness = true
    log("[BATTLE] exit requested reason=#{reason} frame=#{@battle_frame}")
    scene.battle_end(1)
  end

  def self.on_battle_scene_start(scene)
    return unless battle_active?
    log("[BATTLE] Scene_Battle start")
    assert("$game_temp.in_battle", $game_temp.in_battle == true)
    assert("Battle party present", $game_party.members.size > 0, $game_party.members.size)
    assert("Battle enemies present", $game_troop.members.size > 0, $game_troop.members.size)
    assert("Combat RNG provider exists", defined?(FS_COMBAT_RANDOM) != nil)
    if defined?(FS_COMBAT_RANDOM)
      assert("Combat RNG self-test", FS_COMBAT_RANDOM.self_test, "seed=#{COMBAT_SEED}")
      assert("Combat RNG default OFF", !FS_COMBAT_RANDOM.enabled?)
    end
  end

  def self.on_battle_scene_update(scene)
    return unless battle_active?
    @battle_frame += 1
    log("[BATTLE] update entered") if @battle_frame == 1

    if @battle_frame == ACTION_QUEUE_FRAME && !@battle_fixture_queued
      queue_forced_attack_fixture(scene)
    end

    if @battle_action_executed && @battle_action_complete_frame != nil
      if @battle_frame >= @battle_action_complete_frame + POST_ACTION_SETTLE_FRAMES
        assert("Battle Action Driver executed", true,
               "damage_trace=#{@battle_damage_seen}")
        assert("Forced deterministic attack produced execute_damage", @battle_damage_seen,
               "combat_seed=#{COMBAT_SEED}")
        assert("Combat RNG consumed", @battle_combat_rng_count.to_i > 0,
               "count=#{@battle_combat_rng_count}")
        if defined?(FS_COMBAT_RANDOM)
          assert("Combat RNG restored OFF after action", !FS_COMBAT_RANDOM.enabled?)
        end
        if defined?(FS_AI_RANDOM) && FS_AI_RANDOM.enabled?
          for line in FS_AI_RANDOM.trace_lines
            log("[RNG] #{line}")
          end
        end
        request_battle_smoke_exit(scene, "forced_action_complete")
        return
      end
    end

    if @battle_frame >= BATTLE_SMOKE_FRAMES
      assert("Battle Action Driver timeout", false,
             "queued=#{@battle_fixture_queued} executed=#{@battle_action_executed}")
      request_battle_smoke_exit(scene, "timeout")
    end
  end

  def self.on_battle_result(result)
    return unless battle_active?
    @battle_result = result
    assert("Battle result callback", true, result)
    if @battle_exit_requested_by_harness
      assert("Battle smoke exited by harness", result.to_i == 1, result)
    elsif result.to_i == 0 && @battle_action_executed
      assert("Battle smoke natural victory after forced action", true, result)
    else
      assert("Unexpected battle termination", false,
             "result=#{result} action_executed=#{@battle_action_executed}")
    end
    log("[BATTLE] battle_proc result=#{result}")
    @pending_restore = true
  end

  def self.handle_battle_exception(error, where)
    return false unless battle_active?
    exception(error, where)
    @pending_restore = true
    begin
      $game_temp.in_battle = false if $game_temp != nil
      $game_temp.next_scene = nil if $game_temp != nil
      $scene = Scene_Map.new
    rescue Exception => inner
      exception(inner, "battle_exception_recovery")
    end
    return true
  end

  def self.restore_pending_snapshot_if_needed
    return false unless @pending_restore
    begin
      restored = restore_snapshot
      assert("Battle snapshot restored", restored)
    rescue Exception => e
      exception(e, "restore_snapshot")
    end

    begin
      FS_AI_RANDOM.disable if defined?(FS_AI_RANDOM)
    rescue
    end
    begin
      FS_COMBAT_RANDOM.disable if defined?(FS_COMBAT_RANDOM)
    rescue
    end
    begin
      $game_temp.battle_proc = nil if $game_temp != nil
      $game_temp.next_scene = nil if $game_temp != nil
      $game_temp.in_battle = false if $game_temp != nil
    rescue
    end

    @pending_restore = false
    @battle_active = false
    @battle_frame = 0
    @battle_snapshot = nil
    @battle_fixture_queued = false
    @battle_action_executed = false
    @battle_action_complete_frame = nil
    @battle_forced_subject_object_id = nil
    @battle_forced_target_object_id = nil
    @battle_damage_seen = false
    @battle_combat_rng_count = 0
    @battle_combat_rng_trace = []
    @battle_exit_requested_by_harness = false
    @battle_exit_in_progress = false
    @battle_transition_pending = false
    @battle_transition_wait_total = 0
    @battle_transition_wait_done = 0
    @battle_transition_started_frame = nil

    begin
      after_battle_snapshot_restore
    rescue Exception => e
      exception(e, "after_battle_snapshot_restore")
      assert("Post-restore fixture verification completed", false, e.message)
    end

    status = @fail_count.to_i == 0 ? "PASS" : "FAIL"
    finish_suite(status)
    return true
  end
end

#==============================================================================
# ■ Scene_Map：測試快捷鍵與 Battle Snapshot 還原
#==============================================================================
if defined?(Scene_Map)
  class Scene_Map < Scene_Base
    # Test-only 前置熱鍵探測：不再受 Game_Message.visible 對 update_call_debug 的
    # VX 原生 gate 影響。原 update 仍完整執行，因此 next_scene 會照正常流程切換。
    unless method_defined?(:fs_test_harness_map_update_pre_hotkey)
      alias fs_test_harness_map_update_pre_hotkey update
    end
    def update
      FS_TEST_HARNESS.pre_map_update_hotkey(self)
      FS_TEST_HARNESS.update_prebattle_transition(self)
      fs_test_harness_map_update_pre_hotkey
    end

    unless method_defined?(:fs_test_harness_update_call_debug)
      alias fs_test_harness_update_call_debug update_call_debug
    end
    def update_call_debug
      return if FS_TEST_HARNESS.handle_map_debug_hotkey(self)
      fs_test_harness_update_call_debug
    end

    unless method_defined?(:fs_test_harness_start)
      alias fs_test_harness_start start
    end
    def start
      FS_TEST_HARNESS.restore_pending_snapshot_if_needed
      fs_test_harness_start
    end
  end
end

#==============================================================================
# ■ Scene_Battle：Smoke lifecycle / 例外捕捉
#==============================================================================
if defined?(Scene_Battle)
  class Scene_Battle < Scene_Base
    unless method_defined?(:fs_test_harness_battle_start)
      alias fs_test_harness_battle_start start
    end
    def start
      begin
        fs_test_harness_battle_start
        FS_TEST_HARNESS.on_battle_scene_start(self)
      rescue Exception => e
        handled = FS_TEST_HARNESS.handle_battle_exception(e, "Scene_Battle#start")
        raise e unless handled
      end
    end

    unless method_defined?(:fs_test_harness_battle_update)
      alias fs_test_harness_battle_update update
    end
    def update
      begin
        fs_test_harness_battle_update
        FS_TEST_HARNESS.on_battle_scene_update(self)
      rescue Exception => e
        handled = FS_TEST_HARNESS.handle_battle_exception(e, "Scene_Battle#update")
        raise e unless handled
      end
    end
  end
end

#==============================================================================
# ■ Phase 34 TEST-only Trace：Action / Damage
#------------------------------------------------------------------------------
# 只有 RPG Maker VX Test Play 時才建立這兩個最後 wrapper；正式遊戲完全不載入。
#==============================================================================
if (defined?($TEST) != nil && $TEST == true)
  if defined?(Scene_Battle)
    class Scene_Battle < Scene_Base
      unless method_defined?(:fs_test_harness_execute_action_attack)
        alias fs_test_harness_execute_action_attack execute_action_attack
      end
      def execute_action_attack(*args)
        battler = @active_battler
        FS_TEST_HARNESS.on_execute_action_attack_start(self, battler)
        result = fs_test_harness_execute_action_attack(*args)
        FS_TEST_HARNESS.on_execute_action_attack_end(self, battler)
        return result
      end
    end
  end

  if defined?(Game_Battler)
    class Game_Battler
      unless method_defined?(:fs_test_harness_attack_effect_combat_rng)
        alias fs_test_harness_attack_effect_combat_rng attack_effect
      end
      def attack_effect(attacker)
        unless FS_TEST_HARNESS.combat_rng_attack_scope?(self, attacker)
          return fs_test_harness_attack_effect_combat_rng(attacker)
        end
        FS_TEST_HARNESS.begin_combat_rng_scope("attack_effect")
        begin
          return fs_test_harness_attack_effect_combat_rng(attacker)
        ensure
          FS_TEST_HARNESS.end_combat_rng_scope("attack_effect")
        end
      end

      unless method_defined?(:fs_test_harness_execute_damage)
        alias fs_test_harness_execute_damage execute_damage
      end
      def execute_damage(user)
        before = FS_TEST_HARNESS.before_execute_damage(self, user)
        result = fs_test_harness_execute_damage(user)
        FS_TEST_HARNESS.after_execute_damage(self, user, before)
        return result
      end
    end
  end
end
