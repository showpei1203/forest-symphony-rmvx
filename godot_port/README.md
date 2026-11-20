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

## P535｜Source-original BATTLE / MENU / UI artwork priority (2026-11-18)
202 original FS Menu/System/Windows PNGs sealed privately in Drive: https://drive.google.com/file/d/1OCeiV5ZZyxBUrZypIxI8UJv2ytHywbnT/view (provider shared=false, CRC/SHA PASS). The SHA-locked stage_private_ui_535.py imports only to gitignored assets/ui in an authorized ephemeral workspace. FSUIArtLibrary handles true original 24px IconSet, original MENU backgrounds and six original character portraits, FSUIBattleHUD displays live HP/MP/ATB with original HUD ornaments if present. Full Godot CI #44134508271 SUCCESS; actual native GPU source-asset parity NOT RUN; Phase1 SEAL NO. See docs/HANDOFF_20261118_UI_ART_535.md.

## P536｜原始 FS UI PNG 真正 Godot 4.7.2 native GPU 6/6 PASS（2026-11-18）

從 owner-only Drive 的 202 PNG ZIP 在隔離工作環境 stage，Godot 4.7.2 native editor import + OpenGL 544×416 和 1088×832 的 MENU/STATUS/BATTLE 6 張源圖片真 GPU capture PASS。修復 original GaugeHP/MP/OD 120×48 atlas 全圖顯示問題，改由 Btskin 135×40 搭配 72×6 真 source strip HP/MP/OD 動態填充，STATUS 立繪與數值並排，並以 source-locked SHA 校驗。Godot public GitHub full CI #44189891079 83/83 PASS。真正原 VX 完整同畫面 parity/正式戰鬥數值/多幀動畫仍 HOLD，Phase1 SEAL NO。[完整 P536 Handoff](docs/HANDOFF_20261118_P536_ORIGINAL_UI_NATIVE.md)，[Failure Log](docs/FAIL_LOG_UI_ART_536_20261118.md)。Private QA ZIP：https://drive.google.com/file/d/17BwXCHAlhAEDZBUyH8fntmhPZiAyBGV5/view ，shared=false。

## P537｜原版 54×48 戰鬥指令 2×2、真 ATB 變色與 native Godot 真原圖 6/6（2026-11-18）

Source original `Graphics/Menu/Battle01..05`（攻擊／技能／防禦／道具／逃跑）與各 `a` 版灰圖均已 source SHA 固定；FSScreen 正式接 Attack/Skill/Defend/Item 01–04，並由真 `FSBattle.ready_actors()` 控制灰色 disabled→彩色 enabled；05 Escape 尚沒有已驗證原遊戲機制因此只封存美術不偽造指令。4 張 source art 已改用 2×2 Grid，544×416 真 OpenGL 可同時看到。隔離 PRIVATE source 真 202 PNG Godot Editor Import + 原生角色 ATB 測試與 6 張 GPU PNG（兩種解析度×inactive/ready/select_target）PASS，私人證據：https://drive.google.com/file/d/1CM3cQRXFT_-9TJm4v0t_Z2qDE58lvXiE/view 。本輪仍缺 BattleScape/角色動畫/原版資料 parity，ART HOLD, Phase1 SEAL NO。[P537 Handoff](docs/HANDOFF_20261118_P537_BATTLE_ICONS_NATIVE.md)／[Failure Log](docs/FAIL_LOG_UI_ART_537_20261118.md)。

## P537B｜A52 genuine 12-frame actor01 battle animation connection (2026-11-21)
FSScreen now owns an isolated right-side visual presenter triggered only by actual FSBattle FSActionQueue actor01 attack serial. It uses three **SHA-locked private A52 Body/Weapon/FX 256x192 atlases**, and falls closed when original files are absent. Source actor artwork stays owner-only Drive. The 0.630s F7 contact is VISUAL only: no damage/MP/real hitstop wiring until source ACT timing reconciliation. Stage using `tools/stage_private_actor01_attack_537b.py` in an authorized ephemeral test build; public code/test fixture contains no private pixels. See docs/HANDOFF_20261121_P537B_ACTOR01_BATTLE_VISUAL.md. T-A RUN12 remains ART HOLD. Native private source GPU STILL NOT RUN on this line.
