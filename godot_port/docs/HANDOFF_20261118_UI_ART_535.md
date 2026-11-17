# FS Godot 4.7.2｜P535 BATTLE / MENU / UI ORIGINAL ART Handoff
Date 2026-11-18 Asia/Taipei; Phase1 SEAL NO; ART HOLD.

## Owner priority override
**BATTLE combat systems and original art FIRST; then MENU and UI original art.** A35 R8 R3 forest map integration is deferred, NOT removed. Continue Godot 4.7.2 only; original VX E: is read-only. Don't reset from the real P532-P534 playable slice.

## Actual private source asset delivery
- 202 original FS PNG files read-only from VX Graphics: Menu 40 / System 141 / Windows 21.
- Complete owner-only Google Drive archive: https://drive.google.com/file/d/1OCeiV5ZZyxBUrZypIxI8UJv2ytHywbnT/view
- Google Drive returned ID 1OCeiV5ZZyxBUrZypIxI8UJv2ytHywbnT, 8,371,041 bytes, shared=false, owner-only.
- ZIP CRC PASS; complete archive SHA256 c08ea693542e30f66586c6031016e7d7765f52c61ea5515c001e00079aeee9f6.
- Internal fs_ui_source_manifest.json includes 202 original PNG paths, per-image SHA256, dimensions, and bytes.
- Key sizes: MenuBack_a 544x416; GaugeHP/MP 120x48; atb_bar 55x19; iconset 384x15096 with original 24px cells; six original protagonist portraits 251/252x312.
- Do NOT push original PNG or private ZIP to GitHub, never modify original E: VX. Private source remains on Drive.

## Actual code integrated on feature/fs-godot-phase1
1. tools/stage_private_ui_535.py SHA-locked private source importer: ZIP SHA/CRC, every 202 source PNG hash/dimension and safe path, refuse overwrites, stages only in authorized ephemeral godot_port/assets/ui. Gitignore excludes private output.
2. scripts/ui/FSUIArtLibrary.gd: strict imported manifest check, every PNG original SHA/size check, source images only (no fabricated substitute); iconset maps actual DB icon_index to 24x24 AtlasTexture bounds.
3. scripts/ui/FSUIBattleHUD.gd: native Godot HFlowContainer with live true battle HP/MP/ATB progress, refreshes from FSBattle party. When original art is staged, shows Btskin_main, GaugeHP, GaugeMP and atb_bar_skin as source decorative images, NOT unverified original gauge frame slicing.
4. scripts/FSScreen.gd: MENU backgrounds now source-verification gated; live battle HUD integrated; item icons only when original DB explicitly holds icon_index; STATUS/SKILLS/EQUIP show matching private source portraits of 喬伊/泰勒/米亞/艾卓/艾薇/薇娜. Existing MENU/BATTLE item, equip, actor target, ACT actions and original story branch unaffected.
5. Native tests: tests/test_fs_original_ui_535.gd checks fail-closed missing-private, native controls and changing HP/MP/ATB, IconSet atlas bounds; tests/test_private_ui_stage_535.py validates source ZIP importer via 202 fully synthetic fixtures, corruption/unsafe path/refusal. Both added to full Godot CI.

## Verification without false art claims
- Code commit: https://github.com/showpei1203/forest-symphony-rmvx/commit/b792e2d3a410c8d462db95b0b90dfe544811bdeb
- Portrait/Gauge extension: https://github.com/showpei1203/forest-symphony-rmvx/commit/7c36fafad0663437da63b119bcd58444ff860805
- Full Godot 4.7.2 code/native CI #44134048481: SUCCESS, 79/79 completed steps, 0 failed.
- Full Godot 4.7.2 portrait/gauge follow-up CI #44134508271: SUCCESS, 79/79 completed steps, 0 failed.
- Private original PNGs in the SAME Godot project native GPU screenshot and matching VX UI comparison: NOT RUN.
- Original GaugeHP/MP image frame layout semantics, BattleScape layered backgrounds, UI windows 9-slice, MENU buttons Menu01..08 meanings, real multi-frame character/monster art: HOLD; DO NOT call this original pixel-perfect parity.
- Original post-Apply 11 tables and 505 RGSS2 last-wins runtime authority still incomplete, so actual FS combat data is not sealed.

## Explicit next priority: P536 > P537 > P538 > A35 map
P536: In owner-authorized transient build env, stage private 202 PNG originals and run actual Godot 4.7.2 OpenGL 544x416 and 1088x832 MENU/BATTLE screenshots; compare with VX same-screen source, audit 9-slice and gauge atlas semantics. Preserve all private pixels in owner-only Drive.
P537: BATTLE full screen source composition, actor/enemy 6/12+ frame animations, weapon/FX/ACT/hit timings and full native GPU QA. Read latest A52/A54 animation branch Handoff rather than reset to VX 3 frames.
P538: all six protagonists' STATUS/SKILL/EQUIP / ITEM / FORMATION original UI composition and operability native screenshots.
Later: original postApply DB and A35 first real playable map/event bridge. Every phase needs changed code/asset + native QA + Failure Log + GitHub/Drive Handoff. Phase1 SEAL NO.
