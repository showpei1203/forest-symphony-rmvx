# FS source-based combat rules checkpoint (2026-11-14)

## Scope and truth boundaries
This is **partial migration** of verified original RGSS2 source with native Godot tests, **not** a claim of whole-game or final-runtime parity. Original source remains read-only; no private media in public repo.

### FS SkillCost v2.0.0: script #411
- Source lines 324–496: parse `<costo mp: N>`, `<costo mp: N%>` note tags. Fixed value overrides `skill.mp_cost` ONLY if positive. Percentage adds `maxmp × N / 100` with integer truncation.
- Source lines 586–594: half cost if battler `half_mp_cost`.
- Source lines 1291–1315: apply percentage after base, halve then clamp to 0..999999, with possible `apply_level_cost` modifier.
- Implemented as `FSSkillCostRules.preview`, used for both MENU and BATTLE. Extra resource costs, unknown notes, flagged pending level modifiers refuse before MP debit.
- Unresolved: all other effective RGSS2 aliases, `YEZ` modifiers, post-MasterSetup final skill records, HP/Gold/OD/Var/Item/State cost timing. Current battle ability effect formula is still an earlier candidate and NOT source-final.

### FS ATB DynamicResistance v1.0.0: script #377
- Source lines 155–205 and 259–335: rates 100/70/45/25/10%; Boss note `<atb_dynamic_resist>`, optional start/max/floor/recover.
- Source lines 653–772: only intercept direct negative ComboCore ATB shift without State. Apply resistance, Aizhuo penetration reclaiming resisted share, floor, then increase level only after actually reducing >=10 ATB units out of 1000. Level gain calculated from theoretical reduction before resistance (0/1/2).
- Source lines 807–860: recover resistance level only after valid enemy action.
- Implemented as `FSATBResistance.gd` + `FSBattle.apply_combo_atb_shift` and `FSBattle.enemy_valid_action_completed`; basic `advance_atb` is still a placeholder and no actual Combo effect activation yet.

### QA
- `test_fs_skill_cost_authority.gd`: MP note parsing, half cost, actual MENU/BATTLE quoting and deduction, unknown cost rejection.
- `test_fs_atb_dynamic_resistance.gd`: Boss note, rates, stack/floor, Aizhuo piercing, valid enemy action recovery, State bypass, ordinary enemy.
- Godot 4.7.2 CI PASS: https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43549022785
- Phase 1 seal: NO.
