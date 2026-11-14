# Forest Symphony Godot｜Boot-final Database Import Gate (2026-11-14)

## Why raw RVData is NOT production-ready
The original `FS_MasterSetup_18｜Apply Bridge` states that its script-load work replaces adapters/constants, while `Scene_Title` invokes `FS_DB_AUTOSET.apply_all` **after** loading the RPG database. Thus the original `Actors/Skills/Items/Weapons/... .rvdata` is an input, not the complete effective game DB. `FS_SkillCost_Authority_v2.0.0` modifies cost logic separately. This is source-verified; don't treat plain `rvdata_to_json.py` output as final combat truth.

## Gate implemented
`FSDatabase.load_all("res://data")` requires:
- All 11 database tables as UTF-8 JSON under `res://data/actors.json`, `.../animations.json`.
- A sibling `res://data/fs_boot_final_authority.json` manifest.
- `schema="fs-boot-final-authority-v1"`, `stage="post_FS_DB_AUTOSET.apply_all"`.
- `rgss2_script_sections=505`, `master_setup_pages=22` (00–20, including 06.5).
- `vx_runtime_trace_verified=true`, `vx_runtime_witness_sha256` a 64 lowercase hex SHA256 of a separately retained original VX runtime witness.
- `database_sha256` dictionary with lowercase SHA256 of all 11 JSON files in `FSDatabase.NAMES`.

An absent/invalid manifest or any per-file SHA mismatch causes `load_all` to return false and discard the partial `tables`. This proves a consistent **evidence structure**, not the human-truth of the witness or execution parity. Do not set `vx_runtime_trace_verified` without actual VX evidence.

Illustrative manifest that is **intentionally NOT ACCEPTED**:
```json
{
  "schema": "fs-boot-final-authority-v1",
  "stage": "post_FS_DB_AUTOSET.apply_all",
  "rgss2_script_sections": 505,
  "master_setup_pages": 22,
  "vx_runtime_trace_verified": false,
  "vx_runtime_witness_sha256": "",
  "database_sha256": {}
}
```

## Reproduction procedure / next engineering step
1. Keep original `E:\遊戲專案開發\三大項目現行專案\FS project` read-only, no PC permanent artifact copies. Gather original raw .rvdata and source hashes in memory.
2. Use original VX in a controlled environment to capture the **post-Scene_Title `FS_DB_AUTOSET.apply_all`** effective data, plus skill/equipment/state runtime behavior, without overwriting the user's FS installation. A test-only export instrument would have to be reviewed for source protection first.
3. Persist complete boot-final JSON + images/voice/audio to **private Google Drive**, with SHA manifest and readback verification. Drive connector currently accepts connector file references and cannot directly accept an arbitrary user's E:\\ path; a safe approved local-file-to-Drive method is still missing. Never silently write a new output to E:\\ or publish the private graphics/binaries in this public repository.
4. Link approved Drive-source assets into an isolated private Godot assembly and run post-boot roster [1,2,5], 6 hero skills, enemies and combat trace comparisons.
5. Only then set verified fields and allow `FSScreen` to run source-real game database. Continue tracing 505 alias order, ATB, OD, Break, Cover, AI and special item effects, and compare MENU/BATTLE against real 544×416 original screenshots.

## Static method evidence
- Scanner: `godot_port/tools/rgss2_authority_scan.py`
- GitHub Actions successful run: https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43547941870
- 505 ordered sections, per-source SHA, 19 tracked method candidate chains and alias line addresses; MasterSetup 22, explicit apply_all call 1.
- Index artifact `fs-rgss2-static-authority-index` retained in GitHub Actions for 30 days. This tool does not execute Ruby and is **not** a runtime authority resolver.

## Parity status
`FSItemRules.gd` and current MENU/BATTLE recovery are only a conservative **stock VX subdomain** and have synthetic native test passes. They are NOT verification of the effective FS combat calculation, remaining arbitrary item Note behavior or custom cost. P1 seal **NO**.
