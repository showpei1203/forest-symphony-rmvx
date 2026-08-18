# MIGRATION_INVENTORY.md

## Scope
Inventory compiled from current-conversation attachments, the K4 handoff package, extracted SEALED baseline packages, K5 candidate contents, File Library search results, existing Google Drive Forest Symphony contents, and current authority documents.

## Verified Current Artifacts Available as Bytes
### Current handoff / evidence
- Forest_Symphony_HANDOFF_PHASE49K4_1851_3_0_20260818 ZIP — available locally; contains current K4 docs/evidence plus Phase48A and Phase49J SEALED ZIPs.
- K4 `CURRENT/Scripts.rvdata` — SHA-256 `5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa`.
- K4 AutoRegression and Nonbattle Validation evidence.
- K4 Handoff, Roadmap, Final Log Analysis, NEXT_CHAT_PROMPT.

### SEALED scoped baselines
- Phase48A Battle SEALED package: `1388/0/0`.
- Phase49J Nonbattle SEALED package: `411/0/0`.
- Phase49J `Scripts.rvdata` SHA-256 `4c05eef2b8c887cebff59754c7d5e658160999aa39f75bf1ed947a5fd33c89ac`.
- Script comparison: Phase48A -> Phase49J changes only script indexes 467 and 478; page467 is the known Formal RandomDungeon one-shot transfer fix and page478 is TEST harness evolution. Battle pages 479/480 are unchanged.

### Current unverified candidate
- Phase49K5 candidate ZIP — SHA-256 `c9f2c4ce147131ca33c4160760213c0fc69aa55539ab0453e1156e41738bc9d4`.
- K5 literal `Scripts.rvdata` — SHA-256 `ac8ebb85b2686c34a2715a3a656d2f3c4b4bffc09c377f9bdb0e580a33862917`.
- K5 static validation, page478 patch, page478 source, change note and test guide.
- Script comparison Phase49J -> K5: only index478 differs. Formal Runtime delta = 0.

## Source Export Audit
- Script entries: 505.
- Raw script contents exported byte-for-byte from Phase49J SEALED baseline.
- Index preserves order, Script ID, original Script Name (UTF-8 display plus Base64 original bytes), source filename, source SHA-256 and source byte count.
- Protected pages 482/483/484 source hashes are recorded in MASTER_PROJECT_STATE.

## File Library Historical / Documentation Inventory
File Library search surfaced valuable Forest Symphony history including:
- historical `All_Scripts_Export.txt` copies from multiple dates;
- Phase43G / Phase45F1 / Phase46E handoffs and NEXT_CHAT_PROMPT files;
- `Forest_Symphony_6Heroes_5Clones_5Robots_Database_Manual_v2_3_2_Copyable_Indexed_Verified.pdf` under more than one File Library file ID/date;
- older v2.0 Rebuilt manual copies;
- historical AutoRegression / Validation evidence.

These historical File Library references are NOT silently deduplicated. The connector available for File Library search exposes references/content, not the original transferable bytes in the active filesystem. They are therefore indexed as `NEEDS_REVIEW` for byte-level migration rather than recreated and mislabeled as originals.

## Existing Google Drive Legacy Material
The pre-existing Drive `Forest Symphony` folder contained:
- `FS劇情文檔0504.docx` (2020)
- `FS_Schedule.xlsx` (2020)
- `人物表情/` folder (2020)

These are preserved in place. They are legacy project material and are not promoted into `01_Current_Baseline` without current Runtime linkage.

## Missing Current Binary Source
The following current-project materials were not found as verified current bytes in this migration session:
- complete runnable game ZIP / current Game.exe;
- complete current `Data/*.rvdata` set beyond Scripts.rvdata;
- current Graphics directory;
- current Audio directory;
- current System/other runtime asset directories.

Status: `NEEDS_REVIEW / MISSING CURRENT SOURCE`.
The K4 handoff explicitly states it is a Scripts/test-engineering handoff and that final executable packaging requires the user's current full RPG Maker VX project source.

## Conflict Rules Applied
- Newer filename/version does not override PASS status.
- K5 is newer than Phase49J but remains Current Development because no real-machine PASS exists.
- Same-name File Library artifacts are treated as separate until byte hashes prove equality.
- No uncertain source is deleted.
