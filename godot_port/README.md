# Forest Symphony → Godot 4.7.2｜Phase 1

**Status (2026-11-16): WIP / PHASE1 NOT SEALED. Godot 4.7.2 full native P532–P534 CI is PASS, but true private A35 artwork has NOT been integrated or GPU-verified on this branch, and original post-Apply 11-table database/505 runtime authority remains gated.** The original RPG Maker VX source is read-only.

## Scope
Phase 1 must include original database-backed combat stats, equipment, inventory, skill costs/effects, 16-action Kaduki sprite player, ATB/SBS battle flow, and usable MENU/BATTLE interfaces. All script overrides and note tags must be traced before numerical equivalence is declared.

## Source
Read only: `E:\遊戲專案開發\三大項目現行專案\FS project`; 505 ordered RGSS2 script sections, VX `Data/*.rvdata`, and existing `Graphics/*`. **Do not edit this path.**

## Open
Open `godot_port/project.godot` in Godot **4.7.2 stable**. It will show a missing-data screen until actual converted database files are present. This is intentional: a fabricated demo is not a migrated game.

## Data conversion
`python godot_port/tools/rvdata_to_json.py "<source>/Data"` checks data **read only** and prints table counts, without creating files. The explicit `--output` mode exports JSON. Do NOT use output on the user's PC without prior authorization, per cloud-only rule. Perform full export in isolated/cloud workspace and store binary/private assets on Google Drive.

The JSON contract preserves RPG classes, native IDs, raw note fields and Table data. **Do not renumber IDs** or flatten features that still require authority parsing.

## Assets
Only small, user-owned/cleared UI and sprites should be imported to private Drive. See `docs/ASSET_CONTRACT.md`. Until imported, UI uses Godot controls and a conspicuous asset-missing fallback, not a claimed visual match.

## Development boundaries
- `scripts/FSDatabase.gd`: data loader and VX parameter table access
- `scripts/FSBattle.gd`: isolated combat candidate, currently intentionally limited to core attacks and one basic skill
- `scripts/FSActionSprite.gd`: 16-row / 3-frame texture-slicing adapter for four 96×128 Kaduki sheets
- `scripts/FSScreen.gd`: functional Phase-1 menu/battle smoke UI with no imported proprietary images
- All formulas/ATB/AI/OD/cover/scene effects must be compared with current last-wins Ruby scripts before QA approval.

Read `docs/PHASE1_MIGRATION_PLAN.md` and `docs/HANDOFF_20261114.md` before expanding.

## P534｜Private A35 village scene staging (ART HOLD, not yet final FS gameplay)

Owner-only A35 R8 R3 ZIP stays in Drive. The new namespace-isolated importer stages it only in an authorized **ephemeral** build environment, never on the user's PC as a permanent file:

```bash
python3 godot_port/tools/stage_private_a35_534.py --archive /private/a35_r8_r3.zip --dry-run
python3 godot_port/tools/stage_private_a35_534.py --archive /private/a35_r8_r3.zip --output godot_port/a35_private
```

This validates archive SHA/CRC and unmodified Ground SHA, rewrites only Godot resource paths into `res://a35_private/`, and prevents private assets entering GitHub (`.gitignore`). With verified private assets present and Godot 4.7.2 import completed, the boot menu offers a **village art/physics preview only**, not native story+ACT integration. Without assets it refuses to pretend the map exists. [P534 Handoff](docs/HANDOFF_20261116_A35_BRIDGE_P534.md), [P534 Failure Log](docs/FAIL_LOG_A35_BRIDGE_P534_20261116.md), [native full code QA](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43818163395).
