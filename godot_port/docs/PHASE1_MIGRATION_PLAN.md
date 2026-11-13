# FS Godot Phase 1 — implementation / acceptance contract (2026-11-14)

## Facts from READ-ONLY source audit
- Correct source: `E:\遊戲專案開發\三大項目現行專案\FS project`
- 505 ordered RGSS2 script sections in `All_Scripts_Export.txt` (10,927,067 bytes), binary `Data/Scripts.rvdata` (2,457,490 bytes)
- Database files: Actors, Classes, Skills, Items, Weapons, Armors, Enemies, States, Troops, System, Animations, plus CommonEvents/Maps
- `Graphics/Menu` 41 files, `Graphics/System` 142 files, `Graphics/Windows` 21 files
- Candidate native scripts include AutoSetup_01..08; EnemyActionPattern_Core v8.02; ActorActionPattern_Bridge v2.10; SBS Config; ATB (1.2c)-0627; KGC_OverDrive; BattleStatusHUD_Core; KGC Steal/Guide; EnemySummon_Core; YERD TargetEffects; Skill Activation; H87 SkillDelay/Cost; Cover; additional 100-04 DB Authority, 100-06 Build/Combo, 100-07 Enemy AI etc.
- Latest successful VX logs are reference witnesses, not Godot pass evidence.
- Source graphics are local historic files; PC is NOT an output destination.

## Non-negotiable Phase 1 delivered features
1. **Data/identity**: lossless export including IDs, original attributes, notes/tags, classes parameter tables, enemy action data, animation frames, and source count + SHA manifest.
2. **Combat numerical parity**: derive effective actor stats with class/level/equipment/states; accuracy/evade/critical/guard, elements/variance, skill formulas, MP/HP cost, item and passive effects, state stacking, immunities, OD/Break/Cover, summoning, target selection, enemy AI, BattleResult XP/gold/drops. Deterministic input seed.
3. **Movement**: preserve original 16 Kaduki action types, 3-frame rows and SBS weapon/icon transforms; actor/enemy pose control from actual action definitions, not placeholder movement.
4. **ATB**: exact ATB (1.2c)-0627 flow, actor/enemy action window, cancel/target, pause mode and timing. Record tick/frame counts.
5. **MENU UI**: items, skills, equipment, status, party/formation, save/load when required, actual navigation/selection/confirm/cancel/disabled semantics.
6. **BATTLE UI**: actor status/ATB/OD/HP/MP, actor commands, target selection, skill/item info, battle message, animations, battle result.
7. **Preservation**: original UI imagery, icon sprites, faces, battlers, sound and animations, with documented licenses and checksums.

## Risk/priority
P0 original-source protection and cloud-only.
P1 verify last-wins method chain. Do **not** derive FS final formulas only from stock VX; late aliases/overrides in scripts 505 entries may change semantics.
P2 map custom tags and DB patches (AutoSetup) before extracting rules.
P3 parallel UI surfaces reuse the source image assets with pixel dimensions unchanged.
P4 deterministic parity fixtures from actual VX tests, not arbitrary mock numbers.
P5 native engine test on Godot 4.7.2 stable and original VX screenshot comparisons.

## Sequence / gates
- **G0 Inventory + storage**: DONE for folder inventory, repo branch created. Unknown rights/audit details remain.
- **G1 Raw RVData parser**: candidate present in `tools/rvdata_to_json.py`, requires full source read-only inspection; never export files to the user's PC.
- **G2 Data parity**: counts, representative actor/skill/weapon/state/equip/AI fixtures, raw notes; verify IDs and hashes.
- **G3 Functional battle**: action queue and exact formulas, equip/skills/items/state/OD/Break/Cover, 10+ trace scenarios and multiple boss benchmark comparisons.
- **G4 UI parity**: MENU+BATTLE full view acceptance, source image assets, click/key/gamepad navigation and original screenshots.
- **G5 Native Godot test**: Godot 4.7.2 headless start, real UI gameplay QA, screenshot/video evidence to private Drive; user visual approval.
- **G6 Phase1 seal**: zero unverified functional or visual TODOs in committed scope. Current seal **NO**.

## Architectural choice
Place candidate separately at `godot_port` on `feature/fs-godot-phase1`; do not overwrite SEALED main or clean Tankentai baseline repo. Original Ruby scripts are **references**, not executable Godot scripts. Link baseline Tankentai character/SBS adapter only after separate compatibility proof; do not silently treat it as FS code.

## 2026-11-14 updated scope: first-class NEW Event Studio, compatibility-only OLD events
User explicitly clarified: **original RMVX story events need not be bulk-migrated**. However, VX opcode-compatible execution should remain available. A graphical authoring workflow for **new** Godot story events is now a priority; it may run in parallel with (not replace) the original P1 combat/MENU/BATTLE parity gates.

- New FS Event Studio on the same `feature/fs-godot-phase1` branch: graphical pages, conditions, editable VX-compatible steps, JSON save/load, no eval.
- Legacy VX events can run through `FSStoryRuntime.interact_legacy_vx` using the same fail-closed interpreter; this is partial compatibility, not comprehensive conversion.
- Map Marker and treasure-chest synthetic fixture included, with Godot 4.7.2 native headless tests PASS. New work is NOT an original UI/ATB acceptance signal.
- Due GLOBAL HARD RULE 001, native editor's ordinary Save button creates `res://` files wherever Godot runs. On user's PC, it is prohibited as a durable destination; interim use Copy JSON + GitHub workflow, or cloud isolated tools. See `FS_EVENT_STUDIO_V01_20261114.md`.
- Full plot/story/map/quest **legacy bulk port** remains out of scope. New event studio, game dialogue preview and actual map interaction become new focused deliverables in subsequent phases.

