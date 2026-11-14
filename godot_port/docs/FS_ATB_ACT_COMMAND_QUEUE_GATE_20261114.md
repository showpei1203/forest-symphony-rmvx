# Forest Symphony｜ATB→ACT Player Command Queue Gate｜2026-11-14

## Source evidence and scope
- `exported_scripts/230__id55188000__ATB_Configurations.rb` source settings: item #1 charge [4,20,0,""], all other items [4,0,0,""]; skill #1 [4,1,0,""], others [4,10,0,""]; after-action attack recharge20%, guard0%, skill #1 30% (else 0%), item0%; ATB command/target/item selection flags default Wait.
- `exported_scripts/231__id21262629__ATB_(1.2c)-0627.rb` source section lines 176–224: ACT charged battlers queue first, then ATB actors ready for command input, enemies choose their AI automatically. Lines 1359–1382: command completion switches ATB to ACT charge. Lines 559–622: completed action recharges ATB. Lines 2115–2167: gauge waits when input-select flags are active in default Wait mode.
- `exported_scripts/374__id21601036__FS_ComboCore_v1.1.1_OD.rb` lines 2603–2645: negative direct ATB shift cancels ACT count/active and re-enables ATB accumulation. Dynamic Boss resistance in script #377 intercepts only tagged enemy's negative direct shifts.
- `exported_scripts/411__id61621387__FS_SkillCost_Authority_v2.0.0.rb`: fixed/percentage/half MP quote. Other resource costs and tags remain guarded, not silently guessed.
- Original VX effective 505 RGSS2 alias chain, special source animation, damage formula, status/AI/OD/Cover/Break may modify this behavior. **Synthetic source-shaped proof, not verified end-to-end VX parity**.

## Implemented
1. `FSActionQueue.gd`: ATB ready required; actor-target-side/index snapshot, pending serial; one command per actor, one ACT completion per battle tick; no debit at selection.
2. `FSBattle.skill_preflight` reuses the exact existing legality/MP-cost validation before command begins and at ACT completion; `FSBattle.advance_atb` progresses original 60fps gauges and resolves queued commands. New public `queue_actor_action`, `has_actor_pending_action`, `apply_combo_atb_shift_to_actor`. Direct legacy API `FSBattle.attack/use_skill/use_item` remains a candidate test primitive and is **not** a fully source-authorized gameplay entrypoint.
3. `FSTankentaiATBCore.begin_charge` implements source Item1 ACT20%, other item ACT0%, attack/guard ACT0%, Skill1 ACT1%, other skill ACT10%, with documented absence of custom weapon/state charge bonuses.
4. `FSScreen`: BATTLE action buttons disable until actor source ATB Ready; attack/guard/skill/item target selection queues an action rather than directly applying effects. Source Wait mode freezes gauge during target/skill/item selection. MENU items retain immediate non-battle use.
5. `FSActionQueue.cancel_interrupted`: negative ComboCore shift clears actor command immediately, no cost paid on aborted ACT. Revalidation at execution protects if target dead or resources unavailable.

## CI tests
- Existing 21 native Godot 4.7.2 scripts retained.
- Added `godot_port/tests/test_fs_atb_action_queue.gd`: premature command rejected, no duplicate pending, MP 25 charge after Skill1 ACT frame1, Item1 20 source ACT frames before consumption, physical attack and guard recharge, incoming -100 ComboCore shift cancel/no MP or damage, dead target revalidation fails closed.
- Updated `test_fs_menu_battle_ui.gd`, `test_fs_item_ui.gd` to assert queued ACT rather than instant skill/item effects.
- **22 native script tests PASS** via `https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43551938441`; 505 RGSS2 source-order evidence still emitted as GitHub cloud artifact.

## Non-negotiable blockers
Enemy AI auto-actions/forced/union multiple simultaneous actions and the final battle resolver are not yet implemented; attack damage and simple recoveries still use incomplete candidate/source-subset implementation. Source `#231` action queue uses extra forcing/turn rules not yet ported. Real post-`FS_DB_AUTOSET.apply_all` source DB JSON and original VX runtime witness remain unavailable; mandatory manifest gate rejects production load. Final source asset art and screenshot QA also unfulfilled. **Phase 1 Seal: NO.**

## Storage and source protection
This checkout is the public `feature/fs-godot-phase1` branch: only program/test/synthetic fixtures/docs committed. E:\ original FS is read-only; original binaries and private sprite/png stay off public GitHub and belong in private Google Drive once safe import is verified. Keep `main` and `develop` untouched.
