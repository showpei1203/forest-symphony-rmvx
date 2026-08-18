# MASTER_PROJECT_STATE.md

## Project Identity
- Project Name: Forest Symphony / RPG Maker VX
- Engine: RPG Maker VX / RGSS2 / Ruby 1.8-era
- Development Program: Script Cleanup + Authority Refactor + deterministic AutoRegression + Runtime semantic validation
- Infrastructure Migration Priority: ACTIVE. Gameplay feature development is frozen until migration audit is complete.

## Authority Model
- Binary Authority: Google Drive / `01_Current_Baseline`
- Source Authority: GitHub / `main` after repository access is established. Until then, the byte-verified local Git bootstrap bundle stored in Google Drive is the staged source authority.
- Development Authority: Linear / Forest Symphony project
- Runtime Authority: Windows / RPG Maker VX real-machine LOG evidence
- Test Authority: AutoRegression LOG + Validation Report + explicit PASS/FAIL classification

## Current Version / Baseline / Candidate
- Current Version: Phase49K5 candidate / Harness v0.4k5
- Current Baseline: Phase49J Integrated Nonbattle Repeatability Soak IX SEALED source snapshot; `Scripts.rvdata` SHA-256 `4c05eef2b8c887cebff59754c7d5e658160999aa39f75bf1ed947a5fd33c89ac`
- Current Candidate: Phase49K5 Cross-Suite Frame Monotonic candidate; `Scripts.rvdata` SHA-256 `ac8ebb85b2686c34a2715a3a656d2f3c4b4bffc09c377f9bdb0e580a33862917`
- Candidate ZIP SHA-256: `c9f2c4ce147131ca33c4160760213c0fc69aa55539ab0453e1156e41738bc9d4`
- Candidate Status: STATIC PASS only; NOT promoted to Baseline; awaiting RPG Maker VX real-machine Ctrl+Shift+F9.

## Latest PASS
- Battle standalone: Phase48A SEALED, `1388 PASS / 0 FAIL / 0 WARN`.
- Nonbattle standalone: Phase49J SEALED, `411 PASS / 0 FAIL / 0 WARN`.
- Phase49B–J: SEALED.

## Latest Test Result
- Latest real-machine Cross-Suite: Phase49K4, `1851 PASS / 3 FAIL / 0 WARN`.
- Classification: all 3 FAIL are one TEST-only frame invariant defect. Formal Runtime leakage is not supported by the evidence.
- K4 guard diagnostic: stable gameplay/scene/temp/RNG keys exact; only `Graphics.frame_count` advanced `205 -> 236`.
- K5 static change: page478 only; frame invariant is monotonic non-decreasing (`actual >= expected`); frame regression reports `:frame_regressed`; Formal Runtime delta = 0.
- K5 target: `1854 PASS / 0 FAIL / 0 WARN`.

## Completed / SEALED Work
- Phase48A AI Edge Coverage / Forced-Action Authority I: Battle 1388/0/0 SEALED.
- Phase49B Vehicle / Overlay / Fog Runtime Semantic: SEALED.
- Phase49C Ring / Quest / EnemyBook / Minimap / RandomDungeon: SEALED.
- Phase49D RandomDungeon Map/Event lifecycle: SEALED.
- Phase49E perform_transfer lifecycle: SEALED; Formal page467 one-shot `fs_rd_suppress_exit_reset` fix retained.
- Phase49F Save/Load Runtime Semantic: SEALED.
- Phase49G Economy / Shop / Craft: SEALED.
- Phase49H SelfVariable / Event / ObjectPlacement / Minimap marker: SEALED.
- Phase49I Scene/UI Lifecycle two-cycle soak: SEALED.
- Phase49J Integrated Nonbattle Repeatability Soak IX: SEALED.

## SEALED / Protected Runtime
- Formal Runtime changes require real-machine evidence of a Formal defect.
- TEST fixture / expectation / cleanup defects remain TEST-only.
- Protected script pages are byte-exact unless explicitly authorized:
  - page482 `Main` source SHA-256 `15ad656d6e155c5ea33e54377ad04a2146f25dfd48ccc02688a79df0aa499b0f`
  - page483 `全腳本導出工具` source SHA-256 `1f59c96c7d900b653682d10073126a880566fd4dd73ffc382a65dffd5b4f19cb`
  - page484 `標題Final-0714` source SHA-256 `1342dd1b76dbd77ade55d81890eb87900d4f92caef99da9375c4082d404eeac4`
- Battle page479 source SHA-256 `e097ea8dfa3fc579212d6260d69bf23e21b84884e4a998a9f299257ac976cbac`.
- Battle page480 source SHA-256 `8671b0ff9cdda9b0737e6be6704b44a5bf99f08ac93681a4f934ad3737e45be8`.

## Permanent Engineering Rules
- RPG Maker VX / RGSS2 / Ruby 1.8 compatibility is mandatory.
- `Scripts.rvdata` basename remains literal `Scripts.rvdata`.
- Shift+F9 = Nonbattle; Ctrl+F9 = Battle; Ctrl+Shift+F9 = Cross-Suite; F9 = native VX Debug.
- Do not use `Thread.new` to touch `$game_*`, Scene, Sprite, or Bitmap state.
- Do not return to whole-root Marshal clone detection.
- Preserve current Battle snapshot design.
- Do not weaken gameplay expectations merely to make tests green.
- Do not use `learn_skill` to fake equipment / Soul Art ownership.
- Do not add Class Change gameplay/tests.
- Native Tankentai popup recolor remains rejected; preserve native color.
- Every candidate lives in a new folder; do not overwrite old candidates or baselines.
- No candidate becomes Baseline until real-machine PASS.

## Known Issues
1. Phase49K4 Cross-Suite frame equality expectation was semantically wrong; K5 candidate contains the TEST-only monotonic fix and still needs real-machine acceptance.
2. Full current runnable RPG Maker VX project source is not available in this migration session. Game.exe, complete `Data/*.rvdata`, current Graphics, Audio, System and other runtime assets therefore cannot yet be certified or migrated as a complete executable Binary Authority.
3. GitHub identity is connected as `showpei1203`, but the GitHub App currently exposes zero installed accounts / zero accessible repositories. Repository creation/push is blocked until repository access is granted.
4. ChatGPT File Library contains same-name historical artifacts such as multiple `All_Scripts_Export.txt` and duplicated manual PDF titles. Their bytes are not available through the migration runtime for direct hashing, so they are indexed as `NEEDS_REVIEW` instead of overwritten.
5. Existing 2020 files in the Drive Forest Symphony folder are legacy project material and are not assumed to be current Runtime Authority.

## Pending Issues
- Complete infrastructure migration audit.
- Establish GitHub repository access and push staged Git `main` / `develop` history.
- Obtain current complete RPG Maker VX project directory/ZIP for full Binary Authority coverage.
- Execute K5 real-machine Cross-Suite acceptance.
- Final Integrated Soak XI after K5 PASS.
- Release-mode / TEST isolation audit.
- Save / old-save end-to-end acceptance.
- Visual acceptance.
- Final Authority / dead-wrapper audit.
- Final release packaging.

## Current Development Target
Infrastructure migration and authority integrity only. No Runtime/gameplay modification is authorized during this gate.

After Migration Audit is complete, the next Runtime acceptance target is Phase49K5: idle Scene_Map -> Ctrl+Shift+F9 -> expected Cross-Suite `1854/0/0`.

## Future Roadmap
1. Phase49K5 acceptance and Phase49K seal.
2. Final Integrated Soak XI using fresh processes: Nonbattle 411/0/0; Battle 1388/0/0; Cross-Suite 1854/0/0.
3. Release-mode / TEST Isolation Audit.
4. Save / Old-Save End-to-End Acceptance using copies, never official Save1–9.
5. Visual Acceptance.
6. Final Authority / Dead Wrapper Audit.
7. Final Release Package from the user's current full project source.

## Naming Rules
- Binary database filename: `Scripts.rvdata`.
- Version / Phase belongs in folder, ZIP and documentation names, not the rvdata basename.
- PASS/SEALED must reflect real-machine evidence.
- `CURRENT_*` files are pointers/indexes, not substitutes for immutable historical evidence.

## Folder Rules
- `01_Current_Baseline`: only currently recognized PASS / SEALED artifacts.
- `02_Current_Development`: current unsealed candidate and development metadata.
- `03_Test_Builds`: packages intended for Windows / RPG Maker VX real-machine testing.
- `04_Test_Logs`: immutable test and validation evidence.
- `09_Archive`: superseded but potentially useful history; uncertain files are preserved and flagged.

## Infrastructure Links
- Google Drive Project Folder: https://drive.google.com/drive/folders/1FMDwuFeyzseu_UK7FKDt_rrl9CQwi-IH
- GitHub Repository: `PENDING / NEEDS_REVIEW` — authenticated profile `showpei1203`, but no repository installation/access is exposed to the connector.
- Linear Project: https://linear.app/showpei/project/forest-symphony-f0bfaea8775f

## Last Updated
2026-08-18 08:23 +08:00
