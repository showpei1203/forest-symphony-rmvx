# FS Godot P538B Failure Log｜2026-11-23

Branch: `feature/fs-godot-phase1`. Applies to Godot migration only, not T-A/T-B/T-C.

## Authority/source preflight
- Read `authority/FS_CURRENT_RULES_INDEX_20261107.md`, `AGENTS.md`, `.agents/skills/fs-rmvx-router/SKILL.md` **via GitHub** (Windows Skill NOT auto-loaded), `docs/FS_CLOUD_ONLY_STORAGE_POLICY_20261107.md`, Godot CURRENT_HANDOFF, P538A Handoff/FailureLog, 2026-11-14 Roadmap, P1 contract and Drive GLOBAL HARD RULES.
- Confirmed 202 source-original UI PNG ZIP on PRIVATE Drive, `1OCeiV5ZZyxBUrZypIxI8UJv2ytHywbnT` (8,371,041 bytes, shared=false), historical SHA `c08ea693542e30f66586c6031016e7d7765f52c61ea5515c001e00079aeee9f6`. Private P538A 14-image ZIP `19x7wqwVbXInCR2OWWbbx9OGkafXrJ05B` (1,965,809 bytes, shared=false). Neither ZIP was modified or advertised as fresh P538B native evidence.
- Tool router: GitHub and Drive connectors; official GitHub-hosted Godot 4.7.2 CI for executable tests. GitHub PC Bridge reviewed: its allowlisted Godot task targets T-A workspace, NOT the Godot migration branch. Desktop Remote 0, Codex 0, user-PC write 0, PC Bridge 0. No arbitrary Windows or GUI permission.

## R0 full candidate, not final art acceptance
- New `scripts/ui/FSOriginalMenuPage.gd`, separate original background + 60×20 tab + original portrait UI with STATUS, SKILLS, ITEMS, EQUIPMENT, FORMATION, and ITEM TARGET/EQUIPMENT OPTIONS. SHA-gated source or original functional fallback; no private pixels on public GitHub.
- `FSScreen.gd` presents source pages but **keeps** `FSMenuModel` as gameplay/data authority for equipment legality, inventory, party and formation. Source page navigation preserves existing battle/ATB/HUD logic and legacy page fallback.
- Dedicated `test_fs_p538b_original_pages.gd` plus CI gate; private screenshot harness `capture_fs_p538b_private.gd` requires owner-only source and pre-existing authorized PRIVATE QA output; never run on user PC automatically.
- CI `45114810650`, head `46e242a`, **SUCCESS**, 98/98 completed steps (includes P538B native and all retained regression tests). https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45114810650
- After that success, strengthened second actor sample (id2, synthetic level7), 544×416/1088×832 viewport-layout assertions, and added the private capture harness; **a newer CI run must pass before claiming these new changes are native verified**.

## M3 actual failure/repair policy
- P538B first fully tested candidate (head `46e242a`) had **zero observed Godot native CI failures**. Do not invent a bug/fix to fill M3.
- Additional strengthened M4 test outcomes must be taken from its **own** GitHub Actions run; if failed, record genuine error, fix code and rerun. Earlier P538A R1 Battle HUD regression and R2 missing actor fixture remain correctly documented in `FAIL_LOG_20261123_P538A_ORIGINAL_MENU.md`.
- Safety risk avoided: presenting source-styled pages as verified original VX layout. Source image identity is checked; window coordinates, font, VX parity, state and all menu submode semantics require a real comparison before art PASS.

## Explicit HOLD (not FAIL disguised as PASS)
1. Original PRIVATE 202 PNG **P538B native screenshot** at 544×416 and 1088×832: new harness committed, **NOT RUN** because private source ZIP is not staged in current authorized isolated execution environment. Do not reuse P538A ZIP as proof.
2. Actual original VX versus Godot same-state full-page screenshot, typeface/window skin/spacing/pixel parity: **NOT RUN**.
3. Original post-`FS_DB_AUTOSET.apply_all` 11-table witness / 505 RGSS2 final effective runtime: **HOLD**. Current menu actor numbers remain synthetic, correctly labeled.
4. Other tabs in Status/Skill/Item/Equip are SHA-original images but advanced sub-actions are intentionally disabled until their effective source routes are verified. Quest/Save/System menu commands remain intentionally disabled.
5. User art acceptance and physical RX6700XT on P538B: **ART HOLD**. Phase1 SEAL NO.

## Next full acceptance unit
Stage original 202 UI ZIP into a permissioned **isolated cloud** Godot 4.7.2 build; run `capture_fs_p538b_private.gd` at `FS_UI_QA_WIDTH=544` and `1088`; inspect ten source screenshots per width, original window/tab/portrait layout and second independent actor; fix source mismatch, save private QA ZIP with manifest/SHA in Drive, verify metadata; then compare actual owner VX same-state source once available. Never run a script requiring PC files without explicit advance authorization.
