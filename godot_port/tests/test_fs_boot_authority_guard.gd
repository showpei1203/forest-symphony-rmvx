extends SceneTree

# P1 gate: never mistake raw RVData JSON for post-FS_MasterSetup battle data.
# Entire test is in memory, no files created on the user's PC or CI disk.
const DB = preload("res://scripts/FSDatabase.gd")

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool, detail: String) -> bool:
    if not ok:
        push_error("FS post-boot authority gate FAIL: " + detail)
        quit(1)
        return false
    return true

func _run() -> void:
    var hashes: Dictionary = {}
    for name in DB.NAMES:
        hashes[name] = "a".repeat(64)
    var manifest: Dictionary = {
        "schema":"fs-boot-final-authority-v1",
        "stage":"post_FS_DB_AUTOSET.apply_all",
        "rgss2_script_sections":505,
        "master_setup_pages":22,
        "vx_runtime_trace_verified":true,
        "vx_runtime_witness_sha256":"b".repeat(64),
        "database_sha256":hashes.duplicate(true)
    }
    if not _check(DB.validate_boot_manifest(manifest,hashes).is_empty(),
            "fully substantiated structural fixture accepted"): return
    var raw: Dictionary = manifest.duplicate(true)
    raw["stage"] = "raw_RVData"
    raw["vx_runtime_trace_verified"] = false
    if not _check(not DB.validate_boot_manifest(raw,hashes).is_empty(),
            "raw RVData and missing runtime witness rejected"): return
    var mismatch: Dictionary = manifest.duplicate(true)
    mismatch["database_sha256"]["skills"] = "b".repeat(64)
    if not _check(not DB.validate_boot_manifest(mismatch,hashes).is_empty(),
            "mismatched skills table SHA rejected"): return
    var corrupt: Dictionary = manifest.duplicate(true)
    corrupt["database_sha256"].erase("armors")
    if not _check(not DB.validate_boot_manifest(corrupt,hashes).is_empty(),
            "missing armor table SHA rejected"): return
    var no_trace: Dictionary = manifest.duplicate(true)
    no_trace["vx_runtime_witness_sha256"] = "NOT_A_HASH"
    if not _check(not DB.validate_boot_manifest(no_trace,hashes).is_empty(),
            "fabricated or missing runtime witness hash rejected"): return
    var incomplete: Dictionary = manifest.duplicate(true)
    incomplete["master_setup_pages"] = 21
    if not _check(not DB.validate_boot_manifest(incomplete,hashes).is_empty(),
            "missing MasterSetup 06.5 or other page rejected"): return
    print("FS boot-final 505 scripts / 22 MasterSetup / eleven-table SHA witness fail-closed PASS")
    quit(0)
