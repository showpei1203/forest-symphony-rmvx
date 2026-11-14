# Forest Symphony｜Boss Summon Runtime Source Gate

**Date:** 2026-11-14
**Branch:** `feature/fs-godot-phase1`
**Status:** Source-subset Boss summon logic + native synthetic QA **PASS**; original FS 505-script runtime parity and full Phase 1 **NOT DONE**.

## Primary authoritative Ruby source
- `exported_scripts/401__id72365482__SetupRuntime_09｜Boss_Runtime___AI_Provider_v1.4.1.rb`: constants lines 39–44; `stat_mode` lines 52–99; summoned stat scaling lines 235–260; `Game_Troop` 325–414 and update 484–499.
- `exported_scripts/440__id28368523__FS_MasterSetup_15｜Runtime_Boss___Weather.rb`: lines 33–49, **byte-identical** `START_SUMMONS` and `CORE_GROUPS` to #401.
- `exported_scripts/231__id21262629__ATB_(1.2c)-0627.rb`: lines 1863–1885, 1997–2011, 2057–2079; a newly spawned battler's ATB sprite gets its own initial gauge and source frame gain. This module never resets existing gauges during summons.
- Existing `FSBossContext.gd` (#401/#440) and `FSEnemyAIDecision.gd` (#211/#406) determine summoned core AI once in troop.

## Implementation
`scripts/FSBossSummonRuntime.gd`:
- exact source `START_SUMMONS` / `CORE_GROUPS` dictionaries; 8-slot troop cap; roster counts include dead enemies; boss source must be alive; boss iteration asc ID; start/threshold flags once per battle.
- special Boss 503 source count self; Boss510 random 554/555/556 with `FS_AI_RANDOM.rand(3,:boss_altar_pick)`; Boss511 random unique first/second from 500..510 with 72% scale; threshold Boss520 HP≤70% -> 557; Boss547 HP≤60% -> 558×2.
- `prepare_summoned` validates the real enemy DB row, `fs_fixed_enemy_stats` or `fs_growth_enemy_stats` / `fs_growth_source` or 590..745 stat mode; calculates source fixed/database/growth stats and scale with integer truncation, restores full HP/MP. Growth without explicit *Game_Enemy.level source witness* refuses. No synthetic guessed Pokémon levels are silently injected into production.
- preflights planned rows before append: missing DB or invalid stat cannot leave a partial wave; source full-roster capacity can legitimately allow some but not all requested spawns.
- `FSBattle.boss_runtime` calls `tick` after each source 60Hz ATB/ACT and AI step, mirroring #401 Scene_Battle update alias placement; production opt-in requires actual `FSDatabase.boot_final_verified` manifest gate. In-memory synthetic cases explicitly activate runtime.
- `FSTankentaiATBCore.initialize_summoned` creates **only** a new enemy's source gauge and gain, without replaying `prepare` on whole roster.

## Native QA
- `godot_port/tests/test_fs_boss_start_summons.gd`: source start case Boss507→Core551, already-preplaced count; context skills316/317 after summon; independent gauge; Boss503 self; Boss510 FS_AI_RANDOM altar; Boss511 distinct pair and 72% scale; no duplicate source flags.
- `godot_port/tests/test_fs_boss_threshold_growth.gd`: Boss520/547 source HP threshold exact boundaries; Pokemon600 fails closed without runtime level and succeeds with explicit synthetic verified level10; source HP×6.5 and MP×2.2 formula; no half-wave when DB missing; roster cap8.
- Godot **4.7.2** pinned official Actions runner 28 native tests total; Python 505 RGSS2 static evidence scan and artifact.
- Successful full CI: https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43555104501

## Explicitly out of scope
- `ma_call_ally` actual screen position, EnemySummon SafePosition sprite arrangement, summon animation/Audio/Effect and original Battle screenshot QA.
- `fs_db_autoset_phase_states`: Boss524 150/151/152 Law140–143; Weather Boss548–550 weather IDs; Boss530/531 Shield State77 and awaken 128/129; source final State engine and automatic law-cycle not yet verified.
- Real FS raw RVData is NOT effective boot-final DB: needs original post-`FS_DB_AUTOSET.apply_all` authority 11 tables, verified runtime trace, and private Drive import before actual FS can be played. CI fixtures are NOT real FS units.
- Last-wins 505 RGSS2 aliases, OD/Break/Cover/advanced targeting remain unverified; Phase1 Seal **NO**.

Storage: original E:\ project read-only; all new *code and synthetic QA* in feature branch. Main and develop must not be modified.
