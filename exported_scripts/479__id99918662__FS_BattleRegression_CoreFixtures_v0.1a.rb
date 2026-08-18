#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_BattleRegression_CoreFixtures v0.1a
# 【用途】Phase 36 第一批完整戰鬥自動回歸 Fixture。建立在已實機 PASS 的
#         FS_AutoRegression_Harness v0.4 之上，不修改正式戰鬥 Runtime。
# 【目前案例】Ctrl+F9 的 Battle Regression 會依序自動驗證：
#   1. 普通攻擊：ForceAction → execute_action_attack → execute_damage。
#   2. 技能 100「森芽斬」：技能進入 Scene_Battle、MP 成本正確支付、造成實際傷害。
#   3. 技能 101「共鳴標記」：MP 成本正確支付、實際傷害、State 40 確實套用。
# 【測試角色】固定 Actor 1（喬伊）。測試開始後暫時確保 Actor 1 在 Battle Members、
#         回滿 HP/MP，並暫時學會 Skill 100/101；Battle Snapshot 結束後完整還原存檔狀態。
# 【測試敵人】使用既有有效 Troop 中至少三個 Enemy。State Fixture 會暫時提高該測試
#         Enemy MaxHP，避免因技能傷害先死亡而無法驗證 State；Snapshot 後不會留下變更。
# 【Combat RNG】普通攻擊及本頁指定技能的最外層 attack_effect / skill_effect 會使用
#         FS_COMBAT_RANDOM 固定 seed；正常遊戲與非 Fixture 行動完全不固定亂數。
# 【LOG】沿用 FS_AutoRegression_LATEST.log，新增 [FIXTURE] [SKILL] [STATE] [ELEMENT]。
# 【依賴／載入順序】必須位於 FS_Combat_DeterministicRandom、
#         FS_AutoRegression_Harness 之後，Main 之前。
# 【呼叫方式】Test Play 地圖 Ctrl+F9；不需要玩家操作戰鬥。
# 【相關素材】全部使用現有 Actor／Enemy／Skill／SBS 素材，不新增圖檔與音效。
# 【安全規則】本頁只在 $TEST=true 時建立 Scene_Battle / Game_Battler Trace wrapper。
# 【來源／授權】Forest Symphony 專案自製自動回歸測試腳本。
#==============================================================================

$imported = {} if $imported == nil
$imported["FS BattleRegression CoreFixtures"] = "0.1a"

module FS_TEST_HARNESS
  CORE_FIXTURE_VERSION = "0.1"
  CORE_FIXTURE_ACTOR_ID = 1
  CORE_FIXTURE_SKILL_DAMAGE = 100
  CORE_FIXTURE_SKILL_STATE  = 101
  CORE_FIXTURE_STATE_ID = 40
  CORE_FIXTURE_SETTLE_FRAMES = 12

  @core_fixture_plan = nil
  @core_fixture_index = 0
  @core_current_fixture = nil
  @core_next_queue_frame = nil
  @core_subject_mp_before = nil
  @core_expected_mp_cost = nil
  @core_target_state_before = nil
  @core_action_damage = 0
  @core_target_object_id = nil
  @core_skill_entered = false

  class << self
    #--------------------------------------------------------------------------
    # ● Phase 36：Fixture 專用 Party 準備
    #--------------------------------------------------------------------------
    unless method_defined?(:fs_phase36_prepare_party_base)
      alias fs_phase36_prepare_party_base prepare_party_for_smoke
    end
    def prepare_party_for_smoke
      fs_phase36_prepare_party_base
      actor = nil
      begin
        actor = $game_actors[CORE_FIXTURE_ACTOR_ID]
      rescue
        actor = nil
      end
      raise RuntimeError, "Phase36 找不到 Actor #{CORE_FIXTURE_ACTOR_ID}" if actor == nil

      all = $game_party.respond_to?(:all_members) ? $game_party.all_members : $game_party.members
      unless all.include?(actor)
        $game_party.add_actor(CORE_FIXTURE_ACTOR_ID)
      end
      if $game_party.respond_to?(:set_battle_member)
        $game_party.set_battle_member([actor])
      end
      actor.recover_all if actor.respond_to?(:recover_all)
      actor.learn_skill(CORE_FIXTURE_SKILL_DAMAGE) if actor.respond_to?(:learn_skill)
      actor.learn_skill(CORE_FIXTURE_SKILL_STATE)  if actor.respond_to?(:learn_skill)
      actor.clear_actions if actor.respond_to?(:clear_actions)
      return true
    end

    #--------------------------------------------------------------------------
    # ● 需要至少三個 Enemy 的 Troop
    #--------------------------------------------------------------------------
    def core_first_valid_troop_id(min_enemies = 3)
      return nil unless defined?($data_troops) && $data_troops != nil
      return nil unless defined?($data_enemies) && $data_enemies != nil
      for id in 1...$data_troops.size
        troop = $data_troops[id]
        next if troop == nil || troop.members == nil
        count = 0
        for member in troop.members
          enemy_id = member.enemy_id.to_i rescue 0
          if enemy_id > 0 && enemy_id < $data_enemies.size && $data_enemies[enemy_id] != nil
            count += 1
          end
        end
        return id if count >= min_enemies
      end
      return nil
    end

    def core_reset_fixture_state
      @core_fixture_plan = nil
      @core_fixture_index = 0
      @core_current_fixture = nil
      @core_next_queue_frame = nil
      @core_subject_mp_before = nil
      @core_expected_mp_cost = nil
      @core_target_state_before = nil
      @core_action_damage = 0
      @core_target_object_id = nil
      @core_skill_entered = false
    end

    def core_build_fixture_plan
      enemies = $game_troop.members.select { |e| e != nil && e.exist? }
      raise RuntimeError, "Phase36 Fixture 需要至少三個有效 Enemy" if enemies.size < 3

      attack_target = enemies[0]
      damage_target = enemies[1]
      state_candidates = enemies[2, enemies.size - 2]
      state_target = state_candidates.sort_by { |e| -(e.maxhp rescue 0) }[0]
      state_target = enemies[2] if state_target == nil

      @core_fixture_plan = [
        {:name=>"NORMAL_ATTACK", :kind=>:attack,
         :target_index=>attack_target.index, :target_oid=>attack_target.object_id},
        {:name=>"SKILL100_COST_DAMAGE", :kind=>:skill,
         :skill_id=>CORE_FIXTURE_SKILL_DAMAGE,
         :target_index=>damage_target.index, :target_oid=>damage_target.object_id},
        {:name=>"SKILL101_STATE40", :kind=>:skill,
         :skill_id=>CORE_FIXTURE_SKILL_STATE,
         :expected_state=>CORE_FIXTURE_STATE_ID,
         :boost_hp=>true,
         :target_index=>state_target.index, :target_oid=>state_target.object_id}
      ]
      @core_fixture_index = 0
      @core_next_queue_frame = ACTION_QUEUE_FRAME
      log("[FIXTURE] CORE-BATTLE plan=#{@core_fixture_plan.collect { |f| f[:name] }.inspect}")
      return @core_fixture_plan
    end

    def core_current_subject
      begin
        actor = $game_actors[CORE_FIXTURE_ACTOR_ID]
        return actor if actor != nil && actor.exist?
      rescue
      end
      return nil
    end

    def core_target_by_index(index)
      for enemy in $game_troop.members
        next if enemy == nil
        begin
          return enemy if enemy.index == index
        rescue
        end
      end
      return nil
    end

    def core_prepare_action_state(fixture, subject, target)
      @battle_fixture_queued = false
      @battle_action_executed = false
      @battle_action_complete_frame = nil
      @battle_damage_seen = false
      @battle_combat_rng_count = 0
      @battle_combat_rng_trace = []
      @battle_forced_subject_object_id = subject.object_id
      @battle_forced_target_object_id = target.object_id
      @core_current_fixture = fixture
      @core_target_object_id = target.object_id
      @core_action_damage = 0
      @core_skill_entered = false
      @core_subject_mp_before = nil
      @core_expected_mp_cost = nil
      @core_target_state_before = nil
    end

    def core_queue_current_fixture
      return false if @core_fixture_plan == nil
      fixture = @core_fixture_plan[@core_fixture_index]
      return false if fixture == nil
      subject = core_current_subject
      target = core_target_by_index(fixture[:target_index])
      assert("Core fixture subject exists", subject != nil,
             subject == nil ? "nil" : object_label(subject))
      assert("Core fixture target exists", target != nil,
             target == nil ? "nil" : object_label(target))
      return false if subject == nil || target == nil

      core_prepare_action_state(fixture, subject, target)
      target.hp = target.maxhp if target.respond_to?(:hp=)

      if fixture[:boost_hp]
        begin
          target.maxhp = 9999 if target.respond_to?(:maxhp=) && target.maxhp < 9999
          target.hp = target.maxhp
        rescue
        end
      end

      action_type = 0
      action_id = 0
      if fixture[:kind] == :skill
        action_type = 1
        action_id = fixture[:skill_id].to_i
        skill = $data_skills[action_id]
        assert("Fixture skill exists", skill != nil,
               "id=#{action_id}")
        return false if skill == nil
        # Phase39A：若技能已由正式裝備／其他 Runtime provider 提供，不再 learn_skill 偷塞。
        # 一般純測試技能若角色原本沒有，才保留既有 Fixture learn 行為。
        already_provided = false
        begin
          already_provided = subject.skills.any? do |entry|
            entry != nil && entry.id.to_i == action_id
          end
        rescue
          already_provided = false
        end
        if !already_provided && subject.respond_to?(:learn_skill)
          subject.learn_skill(action_id)
          log("[SKILL_SOURCE] fixture_learn skill=#{action_id}")
        else
          log("[SKILL_SOURCE] existing_provider skill=#{action_id}")
        end
        subject.mp = subject.maxmp if subject.respond_to?(:mp=)
        @core_subject_mp_before = subject.mp
        @core_expected_mp_cost = subject.calc_mp_cost(skill)
        if fixture[:expected_state]
          begin
            target.remove_state(fixture[:expected_state])
          rescue
          end
          @core_target_state_before = target.state?(fixture[:expected_state]) rescue false
        end
        rate = nil
        begin
          rate = target.elements_max_rate(skill.element_set)
        rescue
          rate = nil
        end
        log("[SKILL] queue id=#{skill.id} name=#{skill.name} mp_before=#{@core_subject_mp_before} expected_cost=#{@core_expected_mp_cost}")
        log("[ELEMENT] skill=#{skill.id} elements=#{skill.element_set.inspect} target_rate=#{rate.inspect}")
      end

      ok = FS_FORCE_ACTION_BRIDGE.setup_action(subject, action_type, action_id, target.index)
      assert("Core fixture action setup", ok,
             "fixture=#{fixture[:name]} subject=#{object_label(subject)} target=#{object_label(target)}")
      return false unless ok
      $game_troop.fs_force_action_queue ||= []
      $game_troop.fs_force_action_queue << subject
      @battle_fixture_queued = true
      log("[FIXTURE] START index=#{@core_fixture_index + 1}/#{@core_fixture_plan.size} name=#{fixture[:name]}")
      log("[ACTION] QUEUED #{object_label(subject)} -> #{fixture[:kind] == :skill ? 'SKILL '+action_id.to_s : 'ATTACK'} -> #{object_label(target)}")
      log("[TARGET] before #{battler_snapshot(target)}")
      return true
    rescue Exception => e
      exception(e, "core_queue_current_fixture")
      return false
    end

    #--------------------------------------------------------------------------
    # ● Ctrl+F9：沿用已 PASS 的 Sandbox，只替換 Troop 與 Fixture Plan
    #--------------------------------------------------------------------------
    unless method_defined?(:fs_phase36_run_battle_base)
      alias fs_phase36_run_battle_base run_battle_smoke
    end
    def run_battle_smoke
      core_reset_fixture_state
      # 原 Harness 會自行選第一個有效 Troop；Phase36 需要 >=3 Enemy。
      # 暫時以 method wrapper 將 first_valid_troop_id 導向本頁選擇器。
      result = nil
      begin
        singleton = class << self; self; end
        unless singleton.method_defined?(:fs_phase36_first_valid_troop_base)
          singleton.send(:alias_method, :fs_phase36_first_valid_troop_base, :first_valid_troop_id)
        end
        singleton.send(:define_method, :first_valid_troop_id) { core_first_valid_troop_id(3) }
        result = fs_phase36_run_battle_base
      ensure
        begin
          singleton = class << self; self; end
          if singleton.method_defined?(:fs_phase36_first_valid_troop_base)
            singleton.send(:alias_method, :first_valid_troop_id, :fs_phase36_first_valid_troop_base)
          end
        rescue
        end
      end
      if result && battle_active?
        core_build_fixture_plan
      end
      return result
    end

    #--------------------------------------------------------------------------
    # ● Damage Trace：累積目前 Fixture 的實際 HP 傷害
    #--------------------------------------------------------------------------
    unless method_defined?(:fs_phase36_after_execute_damage_base)
      alias fs_phase36_after_execute_damage_base after_execute_damage
    end
    def after_execute_damage(target, user, before)
      hp_before = before == nil ? nil : before[0]
      fs_phase36_after_execute_damage_base(target, user, before)
      if battle_active? && test_forced_subject?(user) &&
         @core_target_object_id != nil && target.object_id == @core_target_object_id
        hp_after = target.respond_to?(:hp) ? target.hp : nil
        if hp_before != nil && hp_after != nil
          delta = hp_before.to_i - hp_after.to_i
          @core_action_damage += delta if delta > 0
        end
      end
    end

    #--------------------------------------------------------------------------
    # ● Skill Action Trace
    #--------------------------------------------------------------------------
    def core_test_skill?(battler, skill)
      return false unless battle_active?
      return false unless test_forced_subject?(battler)
      return false if @core_current_fixture == nil || @core_current_fixture[:kind] != :skill
      return false if skill == nil
      return skill.id.to_i == @core_current_fixture[:skill_id].to_i
    end

    def on_execute_action_skill_start(scene, battler, skill)
      return unless core_test_skill?(battler, skill)
      @core_skill_entered = true
      log("[ACTION] EXECUTE_SKILL START subject=#{object_label(battler)} skill=#{skill.id}:#{skill.name} frame=#{@battle_frame}")
    end

    def on_execute_action_skill_end(scene, battler, skill)
      return unless core_test_skill?(battler, skill)
      @battle_action_executed = true
      @battle_action_complete_frame = @battle_frame
      log("[ACTION] EXECUTE_SKILL END subject=#{object_label(battler)} skill=#{skill.id}:#{skill.name} frame=#{@battle_frame}")
      assert("Forced skill entered Scene_Battle#execute_action_skill", true,
             "skill=#{skill.id}:#{skill.name}")
    end

    def combat_rng_skill_scope?(target, user, skill)
      return false unless battle_active?
      return false unless defined?(FS_COMBAT_RANDOM)
      return false unless test_forced_subject?(user)
      return false if @core_current_fixture == nil || @core_current_fixture[:kind] != :skill
      return false if skill == nil || skill.id.to_i != @core_current_fixture[:skill_id].to_i
      return false if @core_target_object_id != nil && target.object_id != @core_target_object_id
      return true
    end

    #--------------------------------------------------------------------------
    # ● 完成單一 Fixture 的 ASSERT
    #--------------------------------------------------------------------------
    def core_finalize_current_fixture
      fixture = @core_current_fixture
      return false if fixture == nil
      subject = core_current_subject
      target = core_target_by_index(fixture[:target_index])
      assert("Fixture action executed", @battle_action_executed == true,
             fixture[:name])
      assert("Fixture execute_damage observed", @battle_damage_seen == true,
             "fixture=#{fixture[:name]} damage=#{@core_action_damage}")
      assert("Fixture positive HP damage", @core_action_damage.to_i > 0,
             "fixture=#{fixture[:name]} damage=#{@core_action_damage}")
      assert("Fixture Combat RNG consumed", @battle_combat_rng_count.to_i > 0,
             "fixture=#{fixture[:name]} count=#{@battle_combat_rng_count}")
      if defined?(FS_COMBAT_RANDOM)
        assert("Fixture Combat RNG restored OFF", !FS_COMBAT_RANDOM.enabled?, fixture[:name])
      end

      if fixture[:kind] == :skill
        actual_cost = @core_subject_mp_before.to_i - (subject == nil ? 0 : subject.mp.to_i)
        assert_equal("Skill MP cost paid exactly", @core_expected_mp_cost.to_i, actual_cost)
        if fixture[:expected_state] != nil
          applied = false
          begin
            applied = target != nil && target.state?(fixture[:expected_state])
          rescue
            applied = false
          end
          log("[STATE] target=#{object_label(target)} state=#{fixture[:expected_state]} before=#{@core_target_state_before.inspect} after=#{applied.inspect}")
          assert("Expected state applied", applied == true,
                 "state=#{fixture[:expected_state]} target=#{object_label(target)}")
        end
      end
      log("[FIXTURE] PASS-CHECK name=#{fixture[:name]} damage=#{@core_action_damage}")
      return true
    end

    #--------------------------------------------------------------------------
    # ● Phase 36 多 Fixture Scene_Battle Driver
    #--------------------------------------------------------------------------
    def on_battle_scene_update(scene)
      return unless battle_active?
      @battle_frame += 1
      log("[BATTLE] update entered") if @battle_frame == 1

      if @core_fixture_plan == nil
        core_build_fixture_plan
      end
      if @core_next_queue_frame != nil && @battle_frame >= @core_next_queue_frame &&
         !@battle_fixture_queued
        core_queue_current_fixture
        @core_next_queue_frame = nil
      end

      if @battle_action_executed && @battle_action_complete_frame != nil
        if @battle_frame >= @battle_action_complete_frame + CORE_FIXTURE_SETTLE_FRAMES
          core_finalize_current_fixture
          @core_fixture_index += 1
          if @core_fixture_index >= @core_fixture_plan.size
            assert("Core Battle Fixture plan completed", true,
                   "count=#{@core_fixture_plan.size}")
            request_battle_smoke_exit(scene, "core_fixture_plan_complete")
            return
          end
          @battle_fixture_queued = false
          @battle_action_executed = false
          @battle_action_complete_frame = nil
          @core_current_fixture = nil
          @core_next_queue_frame = @battle_frame + 2
        end
      end

      if @battle_frame >= BATTLE_SMOKE_FRAMES
        assert("Core Battle Fixture timeout", false,
               "index=#{@core_fixture_index} queued=#{@battle_fixture_queued} executed=#{@battle_action_executed}")
        request_battle_smoke_exit(scene, "timeout")
      end
    end

    #--------------------------------------------------------------------------
    # ● Snapshot Restore 後清理本頁狀態
    #--------------------------------------------------------------------------
    unless method_defined?(:fs_phase36_restore_pending_base)
      alias fs_phase36_restore_pending_base restore_pending_snapshot_if_needed
    end
    def restore_pending_snapshot_if_needed
      result = fs_phase36_restore_pending_base
      core_reset_fixture_state if result
      return result
    end
  end
end

#==============================================================================
# ■ TEST-only：Skill Action / Skill Effect Combat RNG
#==============================================================================
if (defined?($TEST) != nil && $TEST == true)
  if defined?(Scene_Battle)
    class Scene_Battle < Scene_Base
      unless method_defined?(:fs_phase36_execute_action_skill)
        alias fs_phase36_execute_action_skill execute_action_skill
      end
      def execute_action_skill(*args)
        battler = @active_battler
        skill = nil
        begin
          skill = battler.action.skill if battler != nil && battler.action != nil
        rescue
          skill = nil
        end
        FS_TEST_HARNESS.on_execute_action_skill_start(self, battler, skill)
        result = fs_phase36_execute_action_skill(*args)
        FS_TEST_HARNESS.on_execute_action_skill_end(self, battler, skill)
        return result
      end
    end
  end

  if defined?(Game_Battler)
    class Game_Battler
      unless method_defined?(:fs_phase36_skill_effect_combat_rng)
        alias fs_phase36_skill_effect_combat_rng skill_effect
      end
      def skill_effect(user, skill)
        unless FS_TEST_HARNESS.combat_rng_skill_scope?(self, user, skill)
          return fs_phase36_skill_effect_combat_rng(user, skill)
        end
        FS_TEST_HARNESS.begin_combat_rng_scope("skill_effect:#{skill.id}")
        begin
          return fs_phase36_skill_effect_combat_rng(user, skill)
        ensure
          FS_TEST_HARNESS.end_combat_rng_scope("skill_effect:#{skill.id}")
        end
      end
    end
  end
end
