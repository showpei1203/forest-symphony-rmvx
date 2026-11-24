#!/usr/bin/env python3
"""Generate shared synthetic rehashed boot-final fixtures; never export VX data."""
import argparse
import copy
import json
from pathlib import Path
from verify_boot_final_bundle import NAMES, ARRAY_NAMES, sha256, validate_bundle

def base():
    d = {n: [None, {"id": 1}] for n in ARRAY_NAMES}
    d["system"] = {"party_members": [1]}
    d["actors"][1].update(class_id=1, parameters={
        "xsize": 6, "ysize": 2, "zsize": 1, "data_int16": [1]*12})
    d["classes"][1]["learnings"] = [{"skill_id": 1}]
    d["troops"][1]["members"] = [{"enemy_id": 1}]
    return d

def put(d, path, value):
    for k in path[:-1]:
        d = d[k]
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
        try:
            errors = validate_bundle(folder)
            actual = "REJECT" if errors else "ACCEPT"
        except Exception as exc:
            actual = "ERROR_"+type(exc).__name__
        target = "ACCEPT" if expected else "REJECT"
        print("EGM_PYTHON", name, actual, "expected="+target, flush=True)
        if actual != target:
            problems.append(name)
        index.append({"name":name,"expected":expected})
    write_json(root/"index.json", index)
    print("EGM_PYTHON_DISAGREEMENTS",len(problems),",".join(problems),flush=True)
    if enforce and problems:
        raise SystemExit(1)

if __name__=="__main__":
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("root",type=Path)
    p.add_argument("--enforce",action="store_true")
    a=p.parse_args()
    run(a.root,a.enforce)
