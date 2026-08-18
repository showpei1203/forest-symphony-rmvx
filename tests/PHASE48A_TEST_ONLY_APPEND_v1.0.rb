
#==============================================================================
# 【Phase48A】AI Edge Coverage / Forced-Action Authority I
# TEST-only v1.0
#------------------------------------------------------------------------------
# 基準：Phase47B1 使用者 RPG Maker VX 實機 1363 PASS / 0 FAIL / 0 WARN SEALED。
# Formal Runtime：0 修改。本批只增加 deterministic AI / target / force-action evidence。
#
# Coverage：
# 1. Actor AI State priority：18 > 22 > 23 > 17 > 25。
# 2. Actor target preference equal-score tie：FS_AI_RANDOM deterministic target tie-break。
# 3. EnemyActionPattern equal-rating roulette：兩個 rating=5 basic actions 以 deterministic
#    :enemy_action_roulette 精確重播，不經 FinalDistribution 改寫。
# 4. EnemyActionDistribution replacement policy：urgent friend skill 不可被普通攻擊取代；
#    offensive skill 可取代；final-action damage recorder 與 normal non-forcing semantic 精確。
# 5. FS_ForceAction_Bridge + Boss summon interaction：Boss507 正式召喚 551 後，live add
#    可入 ATB forcing queue、重複 queue entry 去重、死亡 add 被 drain 拒絕；Scene/Troop queue exact restore。
#
# 永久規則：Fixture failure 只改 TEST；沒有實機證據不得修改 Formal Runtime。
#==============================================================================
if defined?(FS_TEST_HARNESS)
module FS_TEST_HARNESS
  @p48a_ai_edge_ran = false
  @p48a_ai_edge_ready = false

  class << self
    def p48a_detached_actor_priority
      ready = !!(defined?(AutoBattleAI) && defined?(ALBERT_AUTO_BATTLE_AI_FIX))
      assert("Phase48A Actor AI priority fixture providers ready", ready)
      return false unless ready
      actor = Game_Actor.new(1)
      formal = ($game_actors[1] rescue nil)
      detached = formal == nil || !actor.equal?(formal)
      assert("Phase48A Actor AI priority uses detached Actor identity", detached,
             "detached=#{actor.object_id} formal=#{formal == nil ? 'nil' : formal.object_id}")
      for state_id in [18,22,23,17,25]
        actor.add_state(state_id)
      end
      p1 = AutoBattleAI.get_actor_ai(actor)
      actor.remove_state(18)
      p2 = AutoBattleAI.get_actor_ai(actor)
      actor.remove_state(22)
      p3 = AutoBattleAI.get_actor_ai(actor)
      actor.remove_state(23)
      p4 = AutoBattleAI.get_actor_ai(actor)
      actor.remove_state(17)
      p5 = AutoBattleAI.get_actor_ai(actor)
      actor.remove_state(25)
      p6 = AutoBattleAI.get_actor_ai(actor)
      exact = p1 == :healy && p2 == :protect && p3 == :support &&
              p4 == :wild && p5 == :balanced && p6 == nil
      assert("Phase48A Actor AI multi-State priority chain exact", exact,
             "packages=#{[p1,p2,p3,p4,p5,p6].inspect} priority=#{ALBERT_AUTO_BATTLE_AI_FIX::AI_STATE_PRIORITY.inspect}")
      log("[AI_EDGE_ACTOR_PRIORITY] packages=#{[p1,p2,p3,p4,p5,p6].inspect} ready=#{exact}")
      return detached && exact
    rescue Exception => e
      exception(e, "p48a_detached_actor_priority")
      assert("Phase48A Actor AI priority fixture completed", false, e.message)
      return false
    end

    def p48a_actor_target_tie
      ready = !!(defined?(FS_AI_RANDOM) && defined?(ALBERT_MECHANIC_EXPANSION) &&
                 $game_troop != nil && $game_troop.existing_members.size >= 2)
      assert("Phase48A Actor deterministic target-tie fixture ready", ready,
             "targets=#{$game_troop == nil ? 0 : $game_troop.existing_members.size}")
      return false unless ready
      actor = Game_Actor.new(1)
      skill = RPG::Skill.new
      skill.instance_variable_set(:@scope, 1)
      skill.instance_variable_set(:@note, "<ai_bonus_vs_state 9999:100>")
      targets = actor.albert_mx_ai_valid_targets(skill)
      seed = 48002
      expected_roll = FS_AI_RANDOM.preview(seed, [targets.size])[0]
      expected = targets[expected_roll]
      actor.action.clear
      FS_AI_RANDOM.reset(seed)
      actor.albert_auto_ai_apply_mx_target_preference(skill)
      actual = targets.find { |target| target.index.to_i == actor.action.target_index.to_i }
      trace = FS_AI_RANDOM.trace
      tagged = trace.find { |entry| entry[1] == :actor_ai_best_target_tie }
      exact = targets.size >= 2 && expected != nil && actual != nil &&
              actual.equal?(expected) && tagged != nil && tagged[3].to_i == expected_roll.to_i
      assert("Phase48A Actor equal-score target tie follows deterministic RNG exactly", exact,
             "seed=#{seed} count=#{targets.size} expected_roll=#{expected_roll} target=#{actual == nil ? 'nil' : object_label(actual)} trace=#{trace.inspect}")
      log("[AI_EDGE_TARGET_TIE] seed=#{seed} count=#{targets.size} roll=#{expected_roll} target_index=#{actor.action.target_index} ready=#{exact}")
      actor.action.clear
      return exact
    rescue Exception => e
      exception(e, "p48a_actor_target_tie")
      assert("Phase48A Actor deterministic target-tie fixture completed", false, e.message)
      return false
    end

    def p48a_enemy_equal_rating_roulette
      ready = !!(defined?(FS_AI_RANDOM) && defined?(Extension_Action_Condition) &&
                 $data_enemies != nil && $data_enemies[609] != nil)
      assert("Phase48A Enemy equal-rating roulette fixture ready", ready)
      return false unless ready
      original = $data_enemies[609]
      original_bytes = Marshal.dump(original)
      exact = false
      replay = false
      roll_value = nil
      expected_basic = nil
      begin
        test_enemy = original.clone
        a1 = RPG::Enemy::Action.new
        a1.instance_variable_set(:@kind, 0)
        a1.instance_variable_set(:@basic, 0)
        a1.instance_variable_set(:@skill_id, 0)
        a1.instance_variable_set(:@condition_type, 0)
        a1.instance_variable_set(:@condition_param1, 0)
        a1.instance_variable_set(:@condition_param2, 0)
        a1.instance_variable_set(:@rating, 5)
        a1.conditions_arrays = []
        a2 = RPG::Enemy::Action.new
        a2.instance_variable_set(:@kind, 0)
        a2.instance_variable_set(:@basic, 1)
        a2.instance_variable_set(:@skill_id, 0)
        a2.instance_variable_set(:@condition_type, 0)
        a2.instance_variable_set(:@condition_param1, 0)
        a2.instance_variable_set(:@condition_param2, 0)
        a2.instance_variable_set(:@rating, 5)
        a2.conditions_arrays = []
        test_enemy.instance_variable_set(:@actions, [a1,a2])
        $data_enemies[609] = test_enemy
        p47a_with_troop_sandbox([609]) do |members|
          enemy = members[0]
          seed = 48003
          expected_roll = FS_AI_RANDOM.preview(seed, [10])[0]
          expected_basic = expected_roll.to_i < 5 ? 0 : 1
          FS_AI_RANDOM.reset(seed)
          enemy.eac_make_action(609)
          sig1 = p41a_action_signature(enemy)
          trace1 = FS_AI_RANDOM.trace
          roulette = trace1.find { |entry| entry[1] == :enemy_action_roulette }
          roll_value = roulette == nil ? nil : roulette[3].to_i
          exact = roulette != nil && roulette[2].to_i == 10 &&
                  roll_value.to_i == expected_roll.to_i &&
                  enemy.action.kind.to_i == 0 && enemy.action.basic.to_i == expected_basic.to_i &&
                  enemy.action.forcing != true
          enemy.action.clear
          FS_AI_RANDOM.reset(seed)
          enemy.eac_make_action(609)
          sig2 = p41a_action_signature(enemy)
          replay = (sig1 == sig2)
          assert("Phase48A Enemy equal-rating roulette follows deterministic 5-vs-5 tie exactly", exact,
                 "roll=#{roll_value.inspect}/#{expected_roll} basic=#{enemy.action.basic}/#{expected_basic} trace=#{trace1.inspect}")
          assert("Phase48A Enemy equal-rating roulette same-seed action replay exact", replay,
                 "first=#{sig1.inspect} second=#{sig2.inspect}")
          enemy.action.clear
        end
      ensure
        $data_enemies[609] = original
      end
      db_ok = $data_enemies[609].equal?(original) && Marshal.dump($data_enemies[609]) == original_bytes
      assert("Phase48A Enemy roulette TEST database slot restored exact", db_ok, "enemy_id=609")
      log("[AI_EDGE_ENEMY_TIE] roll=#{roll_value.inspect} expected_basic=#{expected_basic.inspect} exact=#{exact} replay=#{replay} db=#{db_ok}")
      return exact && replay && db_ok
    rescue Exception => e
      begin
        $data_enemies[609] = original if original != nil
      rescue
      end
      exception(e, "p48a_enemy_equal_rating_roulette")
      assert("Phase48A Enemy equal-rating roulette fixture completed", false, e.message)
      return false
    end

    def p48a_enemy_replacement_policy
      ready = !!(defined?(FS_ENEMY_ACTION_DIST) && $data_skills != nil)
      assert("Phase48A Enemy replacement-policy fixture provider ready", ready)
      return false unless ready
      urgent = nil
      offensive = nil
      for skill in $data_skills
        next if skill == nil
        urgent = skill if urgent == nil && FS_ENEMY_ACTION_DIST.urgent_friend_skill?(skill)
        offensive = skill if offensive == nil && skill.for_opponent? && skill.base_damage.to_i > 0
        break if urgent != nil && offensive != nil
      end
      candidates = urgent != nil && offensive != nil
      assert("Phase48A Enemy replacement-policy skill candidates resolved", candidates,
             "urgent=#{urgent == nil ? 'nil' : urgent.id} offensive=#{offensive == nil ? 'nil' : offensive.id}")
      return false unless candidates
      exact = false
      recorder = false
      normal_nonforcing = false
      p47a_with_troop_sandbox([609]) do |members|
        enemy = members[0]
        old_last = enemy.instance_variable_get(:@fs_ead_last_damage_skill)
        enemy.action.set_skill(urgent.id)
        urgent_replace = FS_ENEMY_ACTION_DIST.can_replace_with_attack?(enemy)
        enemy.action.set_skill(offensive.id)
        offensive_replace = FS_ENEMY_ACTION_DIST.can_replace_with_attack?(enemy)
        normal_nonforcing = enemy.action.forcing != true
        FS_ENEMY_ACTION_DIST.record_final_action(enemy)
        damage_record = enemy.instance_variable_get(:@fs_ead_last_damage_skill) == true
        enemy.action.set_attack
        FS_ENEMY_ACTION_DIST.record_final_action(enemy)
        attack_record = enemy.instance_variable_get(:@fs_ead_last_damage_skill) == false
        recorder = damage_record && attack_record
        exact = urgent_replace == false && offensive_replace == true
        assert("Phase48A Enemy Distribution preserves urgent friend skill but allows offensive replacement", exact,
               "urgent=#{urgent.id}:#{urgent.name} replace=#{urgent_replace} offensive=#{offensive.id}:#{offensive.name} replace=#{offensive_replace}")
        assert("Phase48A Enemy final-action recorder distinguishes damage skill vs normal attack", recorder,
               "damage=#{damage_record} attack=#{attack_record}")
        assert("Phase48A normal Enemy AI action remains non-forcing", normal_nonforcing,
               "forcing=#{enemy.action.forcing}")
        enemy.action.clear
        enemy.instance_variable_set(:@fs_ead_last_damage_skill, old_last)
      end
      log("[AI_EDGE_REPLACEMENT] urgent=#{urgent.id} offensive=#{offensive.id} policy=#{exact} recorder=#{recorder} normal_nonforcing=#{normal_nonforcing}")
      return exact && recorder && normal_nonforcing
    rescue Exception => e
      exception(e, "p48a_enemy_replacement_policy")
      assert("Phase48A Enemy replacement-policy fixture completed", false, e.message)
      return false
    end

    def p48a_force_action_summon_interaction
      scene = $scene
      ready = !!(defined?(FS_FORCE_ACTION_BRIDGE) && defined?(FS_DB_AUTOSET_BOSS_RUNTIME) &&
                 scene.is_a?(Scene_Battle) && scene.respond_to?(:fs_drain_force_action_queue))
      assert("Phase48A ForceAction / Boss summon interaction fixture ready", ready,
             "scene=#{scene == nil ? 'nil' : scene.class}")
      return false unless ready
      live_ok = false
      dedupe_ok = false
      dead_reject = false
      restore_ok = false
      forcing_snap = p46a_ivar_snapshot(scene, :@forcing_battlers)
      queue_snap = p46a_ivar_snapshot($game_troop, :@fs_force_action_queue)
      begin
        p47a_with_troop_sandbox([507]) do |members|
          boss = members[0]
          $game_troop.fs_db_autoset_boss_update(nil)
          adds = $game_troop.members.select { |enemy| enemy != nil && enemy.enemy_id == 551 }
          add = adds[0]
          assert("Phase48A Boss507 formal Runtime produces live 551 summon for ForceAction probe", add != nil && add.exist?,
                 "adds=#{adds.collect { |enemy| enemy.enemy_id }.inspect}")
          next if add == nil
          scene.instance_variable_set(:@forcing_battlers, [])
          $game_troop.fs_force_action_queue = []
          live_ok = FS_FORCE_ACTION_BRIDGE.setup_action(add, 0, 0, FS_FORCE_ACTION_BRIDGE::RANDOM_TARGET) &&
                    add.action.forcing == true
          assert("Phase48A ForceAction Bridge marks live summoned add action as forcing", live_ok,
                 "action=#{p41a_action_signature(add).inspect}")
          $game_troop.fs_force_action_queue << add
          $game_troop.fs_force_action_queue << add
          scene.fs_drain_force_action_queue
          forcing = scene.instance_variable_get(:@forcing_battlers)
          dedupe_ok = $game_troop.fs_force_action_queue.empty? &&
                      forcing.select { |battler| battler.equal?(add) }.size == 1
          assert("Phase48A ForceAction drain dedupes duplicate live summoned battler", dedupe_ok,
                 "queue=#{$game_troop.fs_force_action_queue.size} forcing=#{forcing.collect { |b| b.object_id }.inspect}")
          scene.instance_variable_set(:@forcing_battlers, [])
          add.hp = 0
          $game_troop.fs_force_action_queue = [add]
          scene.fs_drain_force_action_queue
          dead_forcing = scene.instance_variable_get(:@forcing_battlers)
          dead_reject = $game_troop.fs_force_action_queue.empty? &&
                        !dead_forcing.any? { |battler| battler.equal?(add) }
          assert("Phase48A ForceAction drain rejects dead summoned battler without queue leak", dead_reject,
                 "queue=#{$game_troop.fs_force_action_queue.size} forcing=#{dead_forcing.collect { |b| b.object_id }.inspect}")
        end
      ensure
        p46a_restore_ivar(scene, :@forcing_battlers, forcing_snap) if scene != nil && forcing_snap != nil
        p46a_restore_ivar($game_troop, :@fs_force_action_queue, queue_snap) if $game_troop != nil && queue_snap != nil
      end
      forcing_after = p46a_ivar_snapshot(scene, :@forcing_battlers)
      queue_after = p46a_ivar_snapshot($game_troop, :@fs_force_action_queue)
      restore_ok = forcing_after == forcing_snap && queue_after == queue_snap
      assert("Phase48A ForceAction TEST Scene/Troop queue state restored exact", restore_ok,
             "forcing=#{forcing_snap.inspect}->#{forcing_after.inspect} queue=#{queue_snap.inspect}->#{queue_after.inspect}")
      log("[AI_EDGE_FORCE_SUMMON] live=#{live_ok} dedupe=#{dedupe_ok} dead_reject=#{dead_reject} restore=#{restore_ok}")
      return live_ok && dedupe_ok && dead_reject && restore_ok
    rescue Exception => e
      begin
        p46a_restore_ivar(scene, :@forcing_battlers, forcing_snap) if scene != nil && forcing_snap != nil
        p46a_restore_ivar($game_troop, :@fs_force_action_queue, queue_snap) if $game_troop != nil && queue_snap != nil
      rescue
      end
      exception(e, "p48a_force_action_summon_interaction")
      assert("Phase48A ForceAction / Boss summon interaction fixture completed", false, e.message)
      return false
    end

    def p48a_run_ai_edge_batch
      return @p48a_ai_edge_ready if @p48a_ai_edge_ran
      @p48a_ai_edge_ran = true
      random_snap = p47b_runtime_random_snapshot
      priority = false
      target_tie = false
      enemy_tie = false
      replacement = false
      force_summon = false
      rng_restored = false
      begin
        priority = p48a_detached_actor_priority
        target_tie = p48a_actor_target_tie
        enemy_tie = p48a_enemy_equal_rating_roulette
        replacement = p48a_enemy_replacement_policy
        force_summon = p48a_force_action_summon_interaction
      ensure
        p47b_runtime_random_restore(random_snap)
      end
      rng_restored = p47b_runtime_random_matches_snapshot?(random_snap)
      assert("Phase48A AI deterministic RNG state restored exactly", rng_restored)
      ready = priority && target_tie && enemy_tie && replacement && force_summon && rng_restored
      @p48a_ai_edge_ready = ready
      log("[AI_EDGE_COVERAGE_I] actor_priority=#{priority} actor_target_tie=#{target_tie} enemy_rating_tie=#{enemy_tie} replacement=#{replacement} force_summon=#{force_summon} rng_restore=#{rng_restored} ready=#{ready}")
      assert("Phase48A AI Edge Coverage / Forced-Action Authority I completed", ready,
             "priority=#{priority} target=#{target_tie} enemy_tie=#{enemy_tie} replacement=#{replacement} force=#{force_summon} rng=#{rng_restored}")
      return ready
    rescue Exception => e
      p47b_runtime_random_restore(random_snap) if random_snap != nil
      exception(e, "p48a_run_ai_edge_batch")
      @p48a_ai_edge_ready = false
      assert("Phase48A AI Edge Coverage / Forced-Action Authority I completed", false, e.message)
      return false
    end

    unless method_defined?(:fs_phase48a_p46d_run_live_batch_base)
      alias fs_phase48a_p46d_run_live_batch_base p46d_run_live_batch
    end
    def p46d_run_live_batch
      retained = fs_phase48a_p46d_run_live_batch_base
      ai_edge = p48a_run_ai_edge_batch
      ready = retained && ai_edge
      log("[PHASE48A_INTEGRATED] retained_phase47b1=#{retained} ai_edge_i=#{ai_edge} ready=#{ready}")
      return ready
    end

    unless method_defined?(:fs_phase48a_restore_pending_snapshot_base)
      alias fs_phase48a_restore_pending_snapshot_base restore_pending_snapshot_if_needed
    end
    def restore_pending_snapshot_if_needed
      result = fs_phase48a_restore_pending_snapshot_base
      if result
        @p48a_ai_edge_ran = false
        @p48a_ai_edge_ready = false
      end
      return result
    end
  end
end
end
