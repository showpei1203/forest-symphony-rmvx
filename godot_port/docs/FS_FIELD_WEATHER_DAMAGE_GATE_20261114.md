# Forest Symphony｜Field Weather #404 + Actor ElementSet #015 Source Gate

**Date:** 2026-11-14
**Branch:** `feature/fs-godot-phase1`
**Status:** 33/33 native Godot 4.7.2 source-shaped tests PASS. Source formulas are implemented in candidate battle flow. Original FS effective 505-script runtime parity **NOT CERTIFIED**.

## Source evidence

- `exported_scripts/404__id60402587__SetupRuntime_11｜Field_Weather_Authority_v1.3.rb` lines 55–141: `WEATHER_IDS=[153,154,155,156,157,158]`, `CONTEXT_WEATHER={554=>153,555=>154,556=>155}`, `MIN_RATE=25`, `MAX_RATE=175`, `set_field/clear_field/source_alive?`, field data parser (`field_priority`, `field_damage`, `field_target_type_damage`).
- Source #404 lines 154–185: altar Boss510 selects LOWEST LIVING core of 554..556 for contextual weather; `<field effect: n>` overrides `<field_context_weather>`; context weather source follows living core.
- Source #404 lines 189–231: target primary/secondary element types; element adjustments summed on same E; all non-negative deltas use max; all non-positive deltas use min; mixed deltas round average; final rate `clamp(100+delta,25,175)`; positive HP and MP damages round-scale, negative healing unchanged.
- Source #404 lines 248–324: normal attacks use attacker.element_set; skill/object uses object.element_set; `rate_damage?` bypass; Field skill/item effect fires AFTER base effect; skill_can_use refuses setting same or lower-priority global weather. Global Field is `Game_Temp` and intentionally NOT placed in individual character State arrays.
- `exported_scripts/440__id28368523__FS_MasterSetup_15｜Runtime_Boss___Weather.rb` lines 65–71: same WEATHER_IDS/CONTEXT/MIN/MAX values.
- `exported_scripts/015__id93706232__Game_Actor.rb` lines 210–219: actor unarmed [1], weapon element_set union, including dual wield. `exported_scripts/013__id52884295__Game_Battler.rb` lines 398–400 default empty []; `#016 Game_Enemy` does not overwrite stock element_set. **Later 505-script overrides remain an external witness gate.**

## Implementation and integration

1. `scripts/FSFieldWeather.gd`: exact bounded Field ID/source and priority; parses original Weather State Notes, field setting/context, non-heal HP/MP element multiplier, target-type requires explicit `fs_element_types_verified`, rejects corrupted/unverified State/element data. Activated by `FSBattle` ONLY if `FSDatabase.boot_final_verified` true; synthetic tests opt-in explicitly.
2. `FSBossSummonRuntime.tick`: #401 Boss548..550's existing PhaseWeather intent now optionally force-updates global Field (after source Phase ID selection) if Field runtime is authorized. No fake state effects for 122..127.
3. `FSBattle.skill_preflight/attack_preflight`: validates source element data and legal Field change BEFORE MP payment or queued attack; `attack/use_skill` apply #404 modifier to existing preliminary damage. Field-changing skills apply damage under OLD global Field, then set NEW Field after successful hit and MP payment. `FSActionQueue` and `FSEnemyAIDecision` call same guard.
4. `FSSkillCostRules` whitelists only source #404's exact Field Note tags as MP-neutral, keeps other unknown Notes blocked. `FSScreen` visually separates actual limited `Field#404` weather scaling from unimplemented Boss State effects.
5. `FSDatabase.apply_equipment` captures source #015 actor attack elements (unarmed [1], equipped weapon ordered union; missing element_set invalidates source-verified flag), `FSBattle.equip` refreshes the set on gear swaps, `FSDatabase.enemy_stats` stock source default [] with source witness caveat.

## Automated tests and real failures

- `test_fs_field_weather_source_404.gd`: source field priority/force, source death, contextual altar, target types, rounding, clamp, KGC ratio skip.
- `test_fs_field_weather_battle_404.gd`: actual candidate attack/skill +25%/−25%, ACT-late weather & MP, unknown metadata preflight, Boss548 real global field while phase State122 pending, BATTLE UI shows both truth values.
- `test_fs_actor_attack_elements_015.gd`: unarmed, dual weapon union, missing source weapon metadata fails closed, two actual equipment changes alter damage 22/68/66/34.
- Original 30 native regressions remain green; **33/33 official Godot4.7.2 headless smoke PASS**: https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43557813518. Python 505 RGSS2 public-script static source-index artifact remains in CI.
- Fixes: CI 43557119074 was a newly added test missing a typed return in `_check`; CI 43557197991 was an incorrect new fixture assuming all skills have ACT1 frame. Source #230 says only Skill1 has ACT1, Skill2 ACT10. Both fixed without relaxing engine behavior.

## Unresolved hard gates

- Real original FS **post-`FS_DB_AUTOSET.apply_all` 11 effective tables**, private Drive material, hash manifest and actual VX runtime witness; cannot declare real game ready.
- `FSBattle` baseline damage is still a SOURCE CANDIDATE, not full Tankentai/505 Alias parity. Port final `#358` classes/enemy primary/secondary types and `#414` ElementRate, plus OD/Break/Cover, status, hit, variance, rates and late source wrappers. Field Weather's sourced modifier is now functional **over provisional damage**.
- Boss State 77/128/129/140–143/150–152 and Weather Phase States122–127 remain intent-only, no original StateEffects/turn/immune/field sprites yet.
- FS 6 actor sprites, enemy animated art and Battle/UI screenshot parity still incomplete. P1 SEAL = **NO**.

## Storage

Only code, public RGSS2 source references, synthetic test data and QA/Handoff docs are in GitHub `feature/fs-godot-phase1`; no original private RVData/PNG/audio and no local user E: writes. Main/develop branches remain immutable.
