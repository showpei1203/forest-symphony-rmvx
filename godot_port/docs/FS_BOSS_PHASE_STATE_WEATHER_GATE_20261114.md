# Forest Symphony｜Boss Phase State / Global Weather Source Gate

Date: 2026-11-14. Branch: `feature/fs-godot-phase1`.

**Current truth: 30 Godot 4.7.2 native source-shaped tests cover phase triggers and ID intents. No original VX battle-effect parity is certified. Phase 1 seal = NO.**

## Read-only original source verified

- `exported_scripts/401__id72365482__SetupRuntime_09｜Boss_Runtime___AI_Provider_v1.4.1.rb` lines 415–489 implements `fs_db_autoset_phase_states`, `fs_db_autoset_core_exposure`, and the order initial summons → threshold summons → phase → exposure. Lines 492–498 wrap `Scene_Battle.update`, so phase triggers should not stop merely because ATB command selection is in Wait mode.
- `exported_scripts/440__id28368523__FS_MasterSetup_15｜Runtime_Boss___Weather.rb`: `PHASE_WEATHER = {548:[122,125,153,156], 549:[123,126,154,157], 550:[124,127,155,158]}`; mapping verified equal to #401.
- `exported_scripts/404__id60402587__SetupRuntime_11｜Field_Weather_Authority_v1.3.rb` lines 29–46 and 55–141: Field IDs 153–158 are SINGLE GLOBAL `Game_Temp.field_effect`, never duplicated into individual battler States. Priority, weather source, positive elemental damage scaling and target types are separate unported runtime semantics.
- Boss524 source: initialize State150, at HP≤70% remove150/add151 and call law-cycle initializer iff `respond_to?` and Law140–143 all absent; at HP≤35% remove150/151/140–143 and add152. Source does **not** revoke152 on healing above threshold; common mutually exclusive phase FSM is not authoritative here.
- Boss530/531 source: any corresponding Core alive causes State77 intent, absence removes77; HP≤45% state128; once a Start or Threshold summon flag has been set and no Core remains alive, exposure129 only once for each CoreGroup.

## Runtime implementation

- `scripts/FSBossPhaseRuntime.gd` stores `enemy.fs_phase_state_intents`, `enemy.fs_boss_phase_effects_pending`, `enemy.fs_law_cycle_authority_pending` separately from actual `enemy.states`. State-definition presence checked in original boot-final `FSDatabase` before recording add intents; phase transition preflight is atomic for all added State IDs.
- `phase_runtime.weather_request={field_id,source_boss_id,force:true,stage:intent_only}` records selected field request in Boss548/549/550 insertion order and records dead-field-source clear requests; it deliberately does NOT call source #404 damage hooks or apply unverified Field weather effects.
- `FSBossSummonRuntime.tick` now calls phase_runtime immediately after initial and threshold summons, exposing once-only Core129 only if source Start/Threshold flags already exist. `FSBattle.advance_atb` lets boss update run in ATB command WAIT, while ATB/ACT charge remains paused.
- `FSEnemyAIDecision.choose` refuses Boss AI when source phase effects are merely pending. `FSActionQueue.request` and its ACT resolution reject illegal hits or skills against pending Boss shield/phase effects. Legacy `FSBattle.attack` directly invoked in isolated synthetic tests remains a provisional primitive, NOT an approved source gameplay path.
- `FSScreen._refresh_battle_status` shows actual pending State IDs and pending Field ID/source with explicit “效果未套用／未實裝傷害效果” so this is not mistaken for complete State implementation.

## Native CI / witness boundaries

1. `test_fs_boss_phase_state_intents.gd`: Boss524 70%/35% boundary, law absence not fabricated, sticky/healing 152 +151, missing State151 refusal, WAIT phase update, target/AI refusal, Boss530 Core561x2 and Boss531 Core562–565 Shield77/Awakening128/Exposure129 once with correct flags.
2. `test_fs_boss_weather_intents.gd`: Boss548 HP55% exact, State122→125, Field153→156, phase state stickiness and field reversion on healing, multi-Boss Field override ordering, dead-field-source clear, missing State158 fail-closed, native Control BATTLE label.
3. Former 28 scripts retained; total **30 official Godot 4.7.2 native script tests**, plus Python static analyzer indexing original 505 RGSS2 public scripts and GitHub Actions artifact.
4. Passing original phase test CI: https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43556057604. The latest commit’s UI+Docs CI supersedes this once completed.

## Formal blockers (Phase1 Seal NO)

- **No real post-`FS_DB_AUTOSET.apply_all` 11-JSON effective database + actual VX runtime witness / private Drive import**, despite guards; synthetic tests are not original gameplay.
- No actual State add/remove/immune/stack/time and 505 RGSS2 alias resolution for 77/128/129/140–143/150–152, no original ant Law initializer/cycle. Boss Phase IDs are intentions, not combat effects.
- No #404 Weather actual Field state, elemental scaling/target type, global priority/clear aliases or source weather sprite parity.
- No OD/Break/Cover, Force/Union/target redirect, original damage formulas/animation sheets/MENU+BATTLE art and VX screenshots.

Storage policy honored: code + synthetic fixtures + QA docs only on GitHub feature branch; original Windows E: project read-only, no private RVData/PNG/Audio in public repo. Main and develop must not be touched.
