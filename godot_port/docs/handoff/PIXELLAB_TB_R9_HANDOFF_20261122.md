# Forest Symphony | T-B R9 Source-Locked Monster Battle Presentation Handoff
Date 2026-11-22 Asia/Taipei | Owner branch `feat/fs-pixellab-tb-monster-20261121` | Linear SHO-37.

## Scope and user approvals
- PMD0001 frog V6 Attack: USER_ART_ACCEPTED, unchanged.
- TB02 Leaf Bat R8 mouth-bite Attack: user explicitly said `可以。繼續` after reviewing R8 native GIF, so USER_ART_ACCEPTED. Preserve original 11F 128px PixelLab sprite. R7 phantom-claw attack remains REJECTED.
- The subsequent stage2 and stage3 generative illustrations are *references*, **NOT** validated PixelLab sprites or a native monster-family release. No false claim that the illustrated 1448x1086 sheets are source-locked Godot sprite sheets.

## What has actually been implemented
1. New `FS_TBMonsterBattlePresentation.gd` Node2D source-locked component that reads approved R8 sprite and Idle sheets and verifies exact SHA256 + geometry. It binds only to battlers explicitly tagged `fs_monster_visual_id=TB02_LEAF_BAT`, not guessed IDs or name matches.
2. Passive battle event bridge: watches the actual `FSActionQueue.completed` receipt stream, selects only successful `side=enemy, kind=attack` for bound enemy, deduplicates on enemy index + action serial, queues overlapping animations, and emits visual Rush/F5-mouth/Return with the existing source-derived 11-frame 28-tick timeline. No effect on combat HP, MP, RNG, ACT, source target, or damage; no illegal second hit at F5.
3. In T-B branch only, optional `_mount_tb_monster_visual_if_authorized` in the **real `FSScreen.gd` BATTLE UI**. It installs the pixel-art stage only when the explicit monster visual ID is in the battle record AND real validated private art is present. Existing gameplay without a TB02 tag is unchanged. Switching MENU tears down the bridge.
4. Existing Godot `FSBattle`, `FSActionQueue`, and original source-shaped enemy ATB/ACT test remain intact. CI creates synthetic images ONLY and runs with the actual full FS codebase. The `tb_monster_visual_synthetic_qa` flag is OFF by default and only on in explicit CI fixtures.

## Verified native evidence
- **PUBLIC native FS code integration**: Official Godot 4.7.2 in GitHub Actions [run #44962397741](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44962397741) completed/success; job `137023852226` log confirms original enemy AI/ATB/ACT regression, `FS_TB_R9_REAL_FS_ATB_ACT_472_PASS` (synthetic battle hero HP 500 to 430, visual 1 cue, extra HP loss zero), `FS_TB_R9_FS_SCREEN_OPTIN_472_PASS` (real FS BATTLE UI opt-in visual, MENU teardown).
- **PRIVATE real provider art**: Isolated real Godot 4.7.2 (official `4.7.2.stable.official.ed1daf0bf`) loaded original R8 Attack SHA256 `b258678a7a4b59251b13126ed905c47afd9b9dffd0a618fbb64f584ad9ceeee7` and Idle SHA256 `5153e58ccf29dee9d924937fb185169f45e2d0f748a36373cc2f53d4eb72e0a2`. Native headless test `TB_R9_PRIVATE_GODOT_472_PASS`: ignores wrong actor/skill/failed receipts, F5 once per actual serial, no HP/MP changes, missing visual ID fails closed. Native Xvfb Mesa llvmpipe OpenGL capture `TB_R9_472_NATIVE_PRIVATE_544x416_CAPTURE_PASS` with real R8 PNG at original FS **544×416 resolution**.
- Private real art and public full-FS native CI are **two separate test environments**. Do not combine the claims into "user's full private original BattleScape production render PASS".

## Exact remaining gates (not DONE)
- Original VX Enemy ID, Troop, and authorized 505-alias/db-to-TB02 mapping is NOT verified. The opt-in visual ID is only assigned in explicitly labeled synthetic fixtures. No forged production enemy mapping.
- Original FS BattleScape background and source-authored 45-degree combat camera positioning have NOT been integrated or visually approved. The new 544×416 screenshot uses an intentionally neutral schematic arena, not original BattleScape. No final production ART gate claim.
- ACT damage currently commits in the authoritative FS queue BEFORE the presentation-only F5 VFX cue. In order to move the real HP mutation to animation F5, T-A/core-source work is required to implement a source-verified deferred settlement handshake. **Do not silently do this in T-B**, as it could cause duplicate attacks and break ATB parity.
- PixelLab R9 jobs=0; new subscription generations=0; no new private sprite edits.

## Next complete unit
1. Coordinate verified FS enemy source DB binding with T-A and project control tower, assign canonical creature profile without guessing Enemy ID.
2. Import private R8 atlas through strict source SHA gate into actual FS runtime, render real battle UI under original BattleScape (not mocked arena), test actual camera 45-degree placement, all Rush F2/Hit F5/Return F7 transitions.
3. Keep R8 approved, PNGs private Drive, source/QA/Handoff GitHub T-B, avoid main/T-A/T-C edits, require Failure Log and native evidence for any new outcome.
