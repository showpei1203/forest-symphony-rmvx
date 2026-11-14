#!/usr/bin/env python3
"""Read-only original VX database cross-reference audit for FS M2.

Reports aggregate counts and unresolved source references only. It never
exports names, notes, original records, art or game data. Raw source is NOT
post-FS_DB_AUTOSET.apply_all authority.
"""
import argparse
import json
from pathlib import Path
from rvdata_to_json import RubyMarshal48, DATA_NAMES

ARRAYS = tuple(n for n in DATA_NAMES if n != "System")


def inspect_tables(tables):
    problems = []
    stats = {}
    for name in DATA_NAMES:
        rows = tables.get(name)
        if name == "System":
            if not isinstance(rows, dict):
                problems.append("System: expected object")
            stats[name] = 1 if isinstance(rows, dict) else 0
        elif not isinstance(rows, list):
            problems.append(name + ": expected array")
            stats[name] = 0
        else:
            stats[name] = sum(x is not None for x in rows)
            for i, row in enumerate(rows):
                if row is not None and (not isinstance(row, dict) or row.get("id") != i):
                    problems.append("%s[%d]: record ID/index mismatch" % (name, i))
                    break
    def valid(table, ident):
        rows = tables.get(table)
        return isinstance(ident, int) and isinstance(rows, list) and (
            0 < ident < len(rows) and isinstance(rows[ident], dict))
    actors = tables.get("Actors", [])
    for row in actors if isinstance(actors, list) else []:
        if not isinstance(row, dict):
            continue
        if not valid("Classes", row.get("class_id")):
            problems.append("Actor %d: missing Class %s" % (row["id"],row.get("class_id")))
        params = row.get("parameters", {})
        if not isinstance(params, dict) or params.get("xsize") != 6 or (
                not isinstance(params.get("data_int16"), list)):
            problems.append("Actor %d: invalid six-stat parameter Table" % row["id"])
    troops = tables.get("Troops", [])
    for troop in troops if isinstance(troops, list) else []:
        if not isinstance(troop, dict):
            continue
        for member in troop.get("members", []):
            ident = member.get("enemy_id") if isinstance(member, dict) else None
            if not valid("Enemies", ident):
                problems.append("Troop %d: missing Enemy %s" % (troop["id"], ident))
    system = tables.get("System", {})
    if isinstance(system, dict):
        for ident in system.get("party_members", []):
            if not valid("Actors", ident):
                problems.append("System: missing initial Actor %s" % ident)
    return {"schema":"fs-raw-rvdata-reference-audit-v1",
            "authority":"raw_RVData_only_NOT_post_Apply",
            "counts":stats, "issues":problems}


def audit_source(data_dir):
    root = Path(data_dir)
    tables = {}
    for name in DATA_NAMES:
        path = root / (name + ".rvdata")
        tables[name] = RubyMarshal48(path.read_bytes()).parse()
    return inspect_tables(tables)


def self_test():
    tables = {name:[None,{"id":1}] for name in ARRAYS}
    tables["Actors"][1].update({"class_id":1,
        "parameters":{"xsize":6,"data_int16":[1]*6}})
    tables["Troops"][1]["members"] = [{"enemy_id":1}]
    tables["System"] = {"party_members":[1]}
    assert inspect_tables(tables)["issues"] == []
    tables["Actors"][1]["class_id"] = 999
    tables["Troops"][1]["members"][0]["enemy_id"] = 999
    tables["System"]["party_members"] = [999]
    issues = inspect_tables(tables)["issues"]
    assert any("missing Class" in x for x in issues)
    assert any("missing Enemy" in x for x in issues)
    assert any("missing initial Actor" in x for x in issues)
    print("FS raw RVData read-only reference audit self-test PASS")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("data_dir", nargs="?")
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    if args.self_test:
        self_test()
        return
    if not args.data_dir:
        parser.error("Data directory required")
    result = audit_source(args.data_dir)
    print(json.dumps(result,ensure_ascii=False,indent=2))
    if result["issues"]:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
