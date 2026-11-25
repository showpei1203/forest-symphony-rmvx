#!/usr/bin/env python3
"""Generate shared synthetic rehashed boot-final fixtures; never export VX data."""
import argparse
import copy
import json
import shutil
from unittest import mock
from pathlib import Path
from verify_boot_final_bundle import NAMES, ARRAY_NAMES, sha256, validate_bundle

def base():
    d = {n: [None, {"id": 1}] for n in ARRAY_NAMES}
    d["system"] = {"party_members": [1]}
    d["actors"][1].update(class_id=1, initial_level=1, parameters={
        "xsize": 6, "ysize": 2, "zsize": 1, "data_int16": [1]*12})
    d["classes"][1]["learnings"] = [{"skill_id": 1}]
    d["troops"][1]["members"] = [{"enemy_id": 1}]
    return d

def put(d, path, value):
    for k in path[:-1]:
        d = d[k]
    if value == "__DELETE_FIELD__":
        del d[path[-1]]
    else:
        d[path[-1]] = value

CASES = [
    ("valid", [], None, True),
    ("zsize_2", ["actors",1,"parameters"], {"xsize":6,"ysize":2,"zsize":2,"data_int16":[1]*24}, False),
    ("party_null", ["system","party_members"], None, False),
    ("party_empty", ["system","party_members"], [], False),
    ("party_scalar", ["system","party_members"], 1, False),
    ("troop_null", ["troops",1,"members"], None, False),
    ("troop_scalar", ["troops",1,"members"], 1, False),
    ("id_bool", ["items",1,"id"], True, False),
    ("id_string", ["items",1,"id"], "1", False),
    ("id_fraction", ["items",1,"id"], 1.5, False),
    ("class_bool", ["actors",1,"class_id"], True, False),
    ("class_string", ["actors",1,"class_id"], "1", False),
    ("class_fraction", ["actors",1,"class_id"], 1.5, False),
    ("enemy_bool", ["troops",1,"members",0,"enemy_id"], True, False),
    ("skill_string", ["classes",1,"learnings",0,"skill_id"], "1", False),
    ("integral_decimal", ["actors",1,"class_id"], 1.0, True),
    ("level_missing", ["actors",1,"initial_level"], "__DELETE_FIELD__", False),
    ("level_negative", ["actors",1,"initial_level"], -1, False),
    ("level_zero", ["actors",1,"initial_level"], 0, False),
    ("level_at_height", ["actors",1,"initial_level"], 2, False),
    ("level_huge", ["actors",1,"initial_level"], 9007199254740991, False),
    ("level_fraction", ["actors",1,"initial_level"], 1.5, False),
    ("level_bool", ["actors",1,"initial_level"], True, False),
    ("level_string", ["actors",1,"initial_level"], "1", False),
    ("members_missing", ["troops",1,"members"], "__DELETE_FIELD__", False),
    ("learnings_missing", ["classes",1,"learnings"], "__DELETE_FIELD__", False),
    ("members_explicit_empty", ["troops",1,"members"], [], True),
    ("learnings_explicit_empty", ["classes",1,"learnings"], [], True),
    ("table_bad_hash_malformed", [], None, False),
    ("witness_bad_hash_malformed", [], None, False),
]
def write_json(p, value):
    p.write_text(json.dumps(value), encoding="utf-8")

def run(root, enforce=False):
    root.mkdir(parents=True, exist_ok=False)
    index = []
    problems = []
    for name, path, value, expected in CASES:
        d = base()
        if path:
            put(d, path, copy.deepcopy(value))
        folder = root / name
        folder.mkdir()
        for n in NAMES:
            write_json(folder / (n+".json"), d[n])
        w = {"stage":"post_FS_DB_AUTOSET.apply_all", "engine":"RPG Maker VX RGSS2",
             "party_actor_ids":d["system"]["party_members"],
             "table_counts":{n:1 for n in ARRAY_NAMES}}
        wp = folder / "fs_boot_final_runtime_witness.json"
        write_json(wp,w)
        write_json(folder / "fs_boot_final_authority.json", {
            "schema":"fs-boot-final-authority-v1","stage":w["stage"],
            "rgss2_script_sections":505,"master_setup_pages":22,
            "vx_runtime_trace_verified":True,"vx_runtime_witness_sha256":sha256(wp),
            "database_sha256":{n:sha256(folder/(n+".json")) for n in NAMES}})
        hash_case = name in ("table_bad_hash_malformed", "witness_bad_hash_malformed")
        if hash_case:
            target_path = folder / "actors.json" if name.startswith("table") else wp
            target_path.write_bytes(b"{malformed JSON")
        try:
            errors = validate_bundle(folder)
            actual = "REJECT" if errors else "ACCEPT"
            if hash_case and (not any("SHA256 mismatch" in e for e in errors) or
                              any("invalid JSON" in e or "invalid provenance JSON" in e for e in errors)):
                actual = "WRONG_REJECTION"
        except Exception as exc:
            actual = "ERROR_"+type(exc).__name__
        target = "ACCEPT" if expected else "REJECT"
        print("EGM_PYTHON", name, actual, "expected="+target, flush=True)
        if actual != target:
            problems.append(name)
        index.append({"name":name,"expected":expected,"hash_before_parse":hash_case})
    write_json(root/"index.json", index)
    # Deterministically replace a file immediately after the verified snapshot read.
    # The first load must use the original bytes; a later load must reject the changed file.
    race = root / "snapshot_mutation"
    shutil.copytree(root / "valid", race)
    target = race / "actors.json"
    original_read = Path.read_bytes
    reads = 0
    def read_then_mutate(path):
        nonlocal reads
        raw = original_read(path)
        if path == target:
            reads += 1
            if reads == 1:
                path.write_bytes(b"{malformed JSON")
        return raw
    with mock.patch.object(Path, "read_bytes", read_then_mutate):
        first = validate_bundle(race)
    second = validate_bundle(race)
    snapshot_ok = not first and reads == 1 and any("SHA256 mismatch" in e for e in second)
    print("EGM_PYTHON_SNAPSHOT_MUTATION", "PASS" if snapshot_ok else "FAIL", flush=True)
    if not snapshot_ok:
        problems.append("snapshot_mutation")
    print("EGM_PYTHON_DISAGREEMENTS",len(problems),",".join(problems),flush=True)
    if enforce and problems:
        raise SystemExit(1)

if __name__=="__main__":
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("root",type=Path)
    p.add_argument("--enforce",action="store_true")
    a=p.parse_args()
    run(a.root,a.enforce)
