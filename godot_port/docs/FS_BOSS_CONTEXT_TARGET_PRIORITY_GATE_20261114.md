# Forest Symphony Godot｜Boss Context AI + TargetPriority Source Gate

**Date:** 2026-11-14  
**Scope:** Real source-anchored SUBSET on GitHub `feature/fs-godot-phase1`; **not** whole-game or effective-VX-runtime parity. Original FS E: remains read-only; no private assets in public GitHub.

## Exact source authority

### Boss dynamic `CONTEXT_ACTIONS` table
- `exported_scripts/401__...SetupRuntime_09｜Boss_Runtime___AI_Provider_v1.4.1.rb`, source lines 39–43, 168–180, 201–231.
- `exported_scripts/440__...FS_MasterSetup_15｜Runtime_Boss___Weather.rb`, source lines 33–49.
- `CONTEXT_ACTIONS` mapping (15 cores, IDs 551–565) confirmed **byte-identical** across 401 and 440. `FSBossContext.gd` contains this exact mapping. Source loops boss keys in **ascending numeric ID**, matches all `troop.members` regardless of death, and replaces base Enemy.actions with `(kind, basic=0, skill_id, rating, condition_type/params=0, conditions_arrays=[])`; otherwise delegates to original `candidate_actions_enemy`.
- Verified cases: Core551 with Boss507/540; Core558 with Boss521/548; Core565 with Boss531; Core553 with Boss542 including its basic attack entry. Boss summon/weather/exposure/stat growth remains **NOT PORTED**.

### TargetPriority / RandomTarget
- `exported_scripts/372__...FS_RandomTarget_Authority_v1.2｜TargetPriority___Provoke.rb`, lines 52–129, 136–155, 163–215, 490–689.
- Player-selected enemy: `<target priority:n>` (`_`, `-` and Chinese aliases), max of enemy Note and supported State Notes; source Provoke State14 priority 1000. `<ignore target priority>` on skills bypasses the max-priority restriction.
- Enemy random-target narrow subset: Provoke State14 group first, then normal legal group, then limited all-disappear fallback; source-weighted odds, with original `Game_Actor#odds = 4 - class.position` and `Game_Enemy#odds = 1`. Unknown actor states and target-altering Notes FAIL CLOSED; full TargetFix weighted threat/Disappear runtime not certified.
- `FSScreen._select_enemy_target` and `FSActionQueue.request` share legal targets. Queue completion also revalidates to guard an outdated target when Provoke changes while charging. This fallback rejects the old action with no MP debit, but the precise original VX automatic retarget behavior still needs a runtime witness.
- `FSSkillCostRules.preview` now explicitly strips **only** the two known #372 target bypass Note aliases from MP cost scanning; other unported gameplay tags still reject.

## Native automated QA
- `test_fs_boss_context_ai.gd`: 15 core mappings, ID priority includes dead bosses, exact Boss-to-skill cases, core raw fallback when no Boss, Boss skill actually queued and paid ONLY after ACT.
- `test_fs_target_priority_372.gd`: enemy Note priority, State14 Provoke and synthetic State22 note, unknown State fail-closed, target UI and direct Queue gating, stale target rejection on Provoke appearing mid-ACT, ignore-priority skill accepted/paid only after ACT, enemy random Provoke and other status guards.
- `test_fs_skill_cost_authority.gd` + `test_fs_enemy_ai_source.gd` updated to match source #372 cross-rule and #401 correct fallback.
- 26/26 native script tests, pinned official Godot 4.7.2, plus 505-RGSS2 static scanner and artifact: https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43554328368

## Blocking items before P1 seal
- **NO** real post-`FS_DB_AUTOSET.apply_all` 11-table private data import + original VX witness; provisional actor/enemy stats, animation, assets and battle UI screenshot parity.
- **NO** Boss #401 START_SUMMONS, CORE_GROUPS/Phase Weather, threshold summons, dynamic stats, summon guard, forced/multi-action, full #211 Skill83 conditions, #372 TargetFix/Disappear/DynamicThreat integration, OD/Break/Cover and final 505 RGSS2 alias effect chain.
- **NO** final original FS game playable certification; 26/26 are synthetic/source-shaped engine tests, not player-released content.

User original project and PC files were not written; only code/tests/QA/docs saved into the specified GitHub feature branch. Never modify `main`/`develop`.
