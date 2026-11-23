# Forest Symphony｜P538B source-original MENU full pages Handoff｜2026-11-23

Scope: **Godot main migration only** on `feature/fs-godot-phase1`. Not T-A animation, T-B monsters, T-C maps or historical VX main.

## M1 complete candidate delivered
- Added `godot_port/scripts/ui/FSOriginalMenuPage.gd`: source SHA-gated page scene (not mock original VX pixel parity) using private verified 544×416 backgrounds, original 60×20 Status/Skill/Item/Equip tabs and original six-name portrait mapping. Functional STATUS/SKILLS/ITEMS/EQUIPMENT/FORMATION plus ITEM TARGET and EQUIPMENT CANDIDATES. Unported tabs remain disabled, never silently respond with invented gameplay.
- Updated existing `godot_port/scripts/FSScreen.gd`: original-page view handling & signals route to existing `FSMenuModel` for real party, learned skills and MP-cost quotes, inventory, equipment legal mutations and formation; callbacks reuse existing `battle.use_item` validation. Source-less mode retains old functional Godot controls, with no misleading original visual badge.
- Kept source SHA locks in `FSUIArtLibrary.gd`; no original art pixels were added to public GitHub. Original source ZIP remains owner-only Drive (size 8,371,041 bytes; archive SHA256 `c08ea693542e30f66586c6031016e7d7765f52c61ea5515c001e00079aeee9f6`): https://drive.google.com/file/d/1OCeiV5ZZyxBUrZypIxI8UJv2ytHywbnT/view
- Code commits `f15e0fb54f73d826e5048966531eb8ba184ba5c4` (new page), `6d28eaae89ee343b0a5fce918cfa387af1cb55fa` (screen integration), `08022729ae0cff7772b42d1d795be2a0a0f0a90c` (native test), `46e242a4859ca43516c1484e8f861439393ad823` (CI test), `d806165e04d246e6d63a12636bbcfc014ae97b39` (source-private QA capture harness), `d0bb5e79aab04deaa4b48b54a4413a279c2ec362` (M4 synthetic second source-shaped actor + dual-size gating).

## M2 native Godot QA
- Official source-only Godot 4.7.2 CI https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45114810650 **SUCCESS**, 98/98 job steps. This head at `46e242a` includes native project import, P538A/P538B menu tests and existing source-combat, ATB, BATTLE, event, map regression.
- **Final native validation after M4 additions:** official Godot 4.7.2 CI #45115275149, head `224a72353cd2d0fcddecc4fb211175251a2299b5` **SUCCESS 98/98**, including independent synthetic second actor level7 and 544/1088 native layout gate. https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45115275149 . The private-only capture harness script is committed but remains **NOT RUN** without staged owner-only original images.
- `test_fs_p538b_original_pages.gd` tests all five pages, absent private art fail-closed, actor switching, item targets and failed unverified item consumption, equipment UI and actual shared party formation. M4 additions test distinct synthetic Actor#2 (name 米亞, level 7, original-art identity when source present) and both 544×416 and 1088×832 layout coordinates.

## M3 defects and corrections
- First native source-less P538B candidate had no observed regression failures (98/98). No fake FAIL→FIX. On any later regression, record observed error and repair with matching commit. Historical P538A actual Battle HUD regression and invalid actor2 fixture remain in prior Failure Log and are NOT reclassified.

## M4 second fixture / source art separation
- Two **synthetic** actor records (喬伊 vs 米亞) now have distinct IDs and levels, different formation order, two viewport widths. They are not 11 original post-Apply tables.
- `godot_port/tests/capture_fs_p538b_private.gd` is committed for genuinely original sprites. Only after approved isolated private setup, it outputs 10 544×416 or 1088×832 source-backed screenshots per run (MENU, STATUS, SKILLS, ITEMS, EQUIPMENT, FORMATION, MIA STATUS, item target, equipment candidates, post-swap formation). Source-driven output and SHA logs are for PRIVATE Drive, never public repo or user PC. **NOT RUN this session**.
- Prior P538A screenshot QA ZIP metadata read back from Drive: https://drive.google.com/file/d/19x7wqwVbXInCR2OWWbbx9OGkafXrJ05B/view (1,965,809 bytes, private shared=false). That is historical reference only, NOT new P538B art proof.

## Official HOLD
- Owner/private source P538B screenshots (both viewports), original VX same-state 1:1 page comparison, authentic postApply actor data/11 tables + 505 effective Ruby semantics, physical AMD RX GPU, second private original portrait visual and source WindowSkin alignment: **NOT RUN / ART HOLD**.
- Skill effects, sub-tab actions, Quest/Save/System have not gained unsupported source semantics; disabled/fail closed.
- Original Godot Phase 1 **SEAL NO**; synthetic input can prove code behavior, not source numerical parity or final art.
- File policy: source/version/QA text GitHub; owner binary/original art private Drive; no PC writes; no Codex/Remote calls. Windows FS Skill read via GitHub explicitly, not auto-loaded. Original E: VX read-only.

## Real next full unit P538B-private-source-visual-acceptance → P538C
1. On a permissioned isolated cloud environment, SHA-stage unchanged owner-only 202 UI PNG ZIP, official Godot 4.7.2 source import; use P538B capture harness at 544/1088.
2. Inspect actual screenshot pixels and original VX same-state references, adjust only source-backed layout/skin/coordinates, record failures, compare second actor and alternate equip/item/formation states. Save source screenshots+manifest+SHA to PRIVATE Drive with provider readback; user art approval independent.
3. In parallel, isolate boot-final `FS_DB_AUTOSET.apply_all` witness from original VX with explicit authorization, no user-PC temporary data silently retained. Only after those gates pass can a full original MENU page claim parity.
