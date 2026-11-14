# Forest Symphony｜Enemy AI / Tankentai ATB→ACT Gate（2026-11-14）

## Source and actual implementation

**Status: source-subset + native integration PASS; effective original VX runtime parity NOT certified.** Only new code/test/synthetic data on GitHub feature branch, private original source in read-only Windows E: remains untouched.

Original script evidence:
- `exported_scripts/016__...Game_Enemy.rb` lines 235–295: Enemy.actions fields `condition_type/param1/param2`, basic/skill and initial weighted choice.
- `exported_scripts/210__...FS_AI_DeterministicRandom_v1.0.rb`: test-exclusive LCG with multiplier 1103515245, increment12345, mask 0x7fffffff; reference seed12345 yields [6,5,3,573]; production uses nondeterministic RNG.
- `exported_scripts/211__...EnemyActionPattern_Core_v8.02.rb` lines 114–128 and 396–469: **CONDITION_ROULETTE=true**, record choices in source order; if rating falls below previous high rating skip, otherwise weight each remaining action by its rating; select via `FS_AI_RANDOM.rand(total)`. Source Skill83 means chained extra conditions; do not strip or treat as real ability.
- `exported_scripts/372__...FS_RandomTarget_Authority_v1.2.rb` lines 637–689: source weighted random target with provoke/disappear/priority/target odds; this P1 subset only handles simple source actor odds from `4 - class.position`. Any nonempty target states/Notes or unverified target handling causes refusal, not invented target.
- `exported_scripts/401__...SetupRuntime_09_Boss_Runtime_AI_Provider.rb` lines 168–231: Boss context dynamically replaces core 551–565 actions, so those IDs are explicitly BLOCKED until provider state and source troop setup are translated.
- `exported_scripts/406__...FS_EnemyActionDistribution_FinalAuthority_v1.1.rb` lines 76–255: Enemy IDs 600..745 eligible, `<enemy_action_dist_off>` disables; source party attack rates 70/55/45/35% by living party count; break threshold bands and outnumbered bonus, last damaging skill +20%, fixed/add note tags, clamp15..90; replace eligible skill with basic attack only on roll below chance, while preserving urgent friend skills.
- `exported_scripts/231__...ATB_(1.2c)-0627.rb` lines 176–224, 1359–1382, 559–622: ready enemies decide action automatically, ACT charge before execution, then source recharge.

Implemented modules:
1. `scripts/FSAIRandom.gd` explicit deterministic TEST seed toggle and tagged trace, nondeterministic production.
2. `scripts/FSEnemyAIDecision.gd` limited conditions 0, HP%, MP%, states, max actor level, ordinary switch, and original roulette plus #406 distribution. Turn count, Switch 121..130, complex condition arrays, Skill83 and special AI/target tags fail closed. Missing skills or unsupported effects do NOT redirect probabilities toward a guessed basic attack.
3. `scripts/FSActionQueue.gd` `schedule_enemy`, `_resolve_enemy_ready` and enemy pending/interruption. Enemies only pick at source ATB READY, use ACT charge, pay MP after successful execution, process one ACT completion per source frame; blocked AI reports once and does not spam or do arbitrary attack.
4. `scripts/FSBattle.gd` source 60Hz **per-frame** progression then ACT completion then enemy choice (next frame required for zero-charge ACT); ComboCore negative ATB immediate enemy ACT cancellation, and scope1/7 targets relative to the acting side.
5. `scripts/FSDatabase.gd` computes original VX actor `odds=4-class.position` used by simple source random weighted targeting.

## Godot 4.7.2 native tests
- `tests/test_fs_enemy_ai_source.gd`: #210 reference RNG, #211 source roulette and rating order, #406 source attack rates and NOTE variations, conditions/extended Skill83/turn/Boss fail closed.
- `tests/test_fs_enemy_atb_queue.gd`: Enemy frame90 ready & queued, frame91 attack + recharge20%; enemy Skill scope1 ACT10 frames and MP debit only on frame10; enemy Scope7 friend heal, interruption via -ATB, dead target before ACT -> no cost; two ready enemies source frame91/92 no duplication; empty actions never invented.
- All previous 22 native tests retained. **24/24 PASS**: https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43553309465. 505-script scanner and uploaded GitHub Actions artifact retained.

## Still blocking P1 seal
No real private original FS `FS_DB_AUTOSET.apply_all` post-boot database/11 tables/runtime witness in Godot. Original effective Enemy AI includes dynamic Boss context, advanced state/switch/turn target handling, Threat/Provoke, summoning, forcing, multi-action, OD/Break/Cover and final 505-script alias effects, none certified. Actual MENU/BATTLE original art and 6 hero animations not yet integrated. Current enemy attack damage remains preliminary formula and can only be used as a **test candidate**, not an authoritative original FS balancing claim.

Strict next steps: reproduce original post-Apply source data in private Drive without user-PC persistent writes; port #401 dynamic Boss encounter context, #372 priority targeting and #211 extended conditions; compare actual original VX battle traces and screenshot QA. Event Studio remains longer-term.
