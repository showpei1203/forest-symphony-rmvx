# FS Godot｜Tankentai ATB 1.2c Source Core Gate（2026-11-14）

**Status: MODEL-LEVEL SOURCE-FORMULA PASS / COMPLETE BATTLE ATB NOT DONE**

## Evidence
- Source `exported_scripts/230__id55188000__ATB_Configurations.rb`: `ATB_SPEED=10`, `ATB_BASE_SPEED=1`, `ATB_ABSOLUTE_SPEED=100`, `ATB_BASE_ADD=5`, initial 10% actor/enemy except Actor01 30%, wait/pause default behavior, post-action 20% attack / 0% guard/item/default skill; Skill ID1 = 30% reset and 1% charge.
- Source `exported_scripts/231__id21262629__ATB_(1.2c)-0627.rb` exact code areas: 68–83 surprise/preemptive, 176–197 ready dispatch, 1863–1885 gauge init/AGI extremes, 1997–2011 initial gauge and equipment fallback, 2057–2109 change_atb/change_act integer base, 2115–2167 waits, 2227–2263 gauge advance, 606–622 action reset.
- Source `exported_scripts/374__id21601036__FS_ComboCore_v1.1.1_OD.rb`: 2603–2645 negative shift clears act_count/active/ready flags and restarts source ATB.
- Source `exported_scripts/377__id65670378__FS_ATB_DynamicResistance_v1.0.0.rb`: only direct negative ComboCore shifts to Boss with dynamic resistance, not Tankentai State damage.

## Implemented
- `scripts/FSTankentaiATBCore.gd`: source-frame 60Hz integer and native double gauges, initial rolls [0,4], highest-AGI scaling, sourced actor/weapon/armor start, preemptive/surprise, ACT charge, source post-action reset.
- `FSBattle`: source gauge initialize once and frame-progress from `advance_atb(delta)`; no more invented continuous placeholder; explicit `begin_source_atb_charge`, `source_action_charged`, `finish_source_atb_action`, readiness queries.
- `FSScreen`: BATTLE Control `_process` ticking source model and displaying ATB/ACT for all party/enemies; MENU freeze.
- `FSATBResistance`: synchronize authoritative `source_atb_count` and float UI projection; negative ComboCore shift interrupts ACT charging per source #374.

## Automated QA
1. `test_fs_tankentai_atb_core.gd`: exact actor AGI 40/20/enemy50 gains 8/4/10 ticks/frame, initial values 300/200/100, readiness frame 88/90, charge phases, source Skill1 reset30%, weapon1 attack reset20%, waiting pauses, preemptive/surprise, ComboCore negative shift then next tick persistence.
2. `test_fs_tankentai_ui_tick.gd`: live BATTLE UI runs 30 source frames for 0.5s, labels ATB 54/40%, returning to MENU freezes, later ready labels update.
3. Existing 19 regression tests for battle skills, equipment, item recovery, dynamic Boss resistance, Event Studio untouched.
4. CI native runner: Godot **4.7.2** fixed official distribution; 21 native scripts + 505 RGSS2 scan. Successful run: https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43550617123

## Strict remaining blockers
- No original post-`FS_DB_AUTOSET.apply_all` canonical private assets/database & original VX witness, so neither absolute source-resolved formulas nor real FS original party are yet checked.
- **Command queues do NOT yet gate combat action buttons on ATB/ACT readiness.** The new gauge progresses and has APIs, but full command selection wait, action charging, execution, ability payment timing, turn update, enemy AI, force action, cover/OD/Break are unresolved. This is especially important before claiming a playable original battle system.
- New project is still P1 candidate; original 544×416 MENU/BATTLE artwork, 6 actors/monsters and variable-frame animations still require private imports and manual screenshot QA.
- User PC original FS directory remained read-only. All new source/QA docs are in GitHub feature branch only.
