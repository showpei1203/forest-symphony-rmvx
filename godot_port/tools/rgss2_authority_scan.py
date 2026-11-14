#!/usr/bin/env python3
"""Read-only audit of FS RGSS2 load-order and combat-method declarations.

IMPORTANT: Ruby alias/method definitions cannot be resolved safely from regex
alone. This tool creates *evidence and unresolved dependencies*, not an
'effective runtime formula'. It NEVER executes user-supplied Ruby.

Use GitHub Actions for JSON artifacts. A local PC file is never an output
destination; --output is fail-closed outside an explicitly allowed cloud
workspace (GITHUB_ACTIONS or FS_AUTHORIZED_CLOUD_WORKSPACE=true).
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
from typing import Iterable

TARGET_METHODS = (
    "make_attack_damage_value", "make_obj_damage_value",
    "attack_effect", "skill_effect", "item_effect",
    "calc_hit", "calc_eva", "calc_mp_cost", "skill_can_use?",
    "change_equip", "execute_action", "update_atb", "make_action",
    "state_probability", "add_state", "element_rate",
    "elements_max_rate", "apply_variance", "apply_guard",
)

METHOD_RX = re.compile(
    r"^\s*def\s+(?:self\.)?([a-zA-Z_]\w*[!?=]?)\b(?=\s|\(|$)"
)
# A question mark in Ruby method is not a word character: use a second pass.
METHOD_RX = re.compile(
    r"^\s*def\s+(?:self\.)?([a-zA-Z_]\w*[!?=]?)(?=\s|\(|$)"
)
ALIAS_RX = re.compile(r"^\s*alias(?:_method)?\b")
CONTEXT_RX = re.compile(r"^\s*(?:class|module)\s+([A-Za-z_]\w*(?:::[A-Za-z_]\w*)*)")
FILE_RX = re.compile(r"^(\d{3})__.*\.rb$")
DATA_TOUCH_RX = re.compile(r"\$data_(?:actors|classes|skills|items|weapons|armors|enemies|states|troops|animations)\b")
TEST_NAME_RX = re.compile(r"(?:TEST-only|_Test_|Regression|Fixtures|VALIDATION)",re.I)

def index_source(name: str, source: str) -> dict:
    match = FILE_RX.match(name)
    if match is None:
        raise ValueError(f"Not a numbered exported RGSS2 script: {name}")
    lines = source.splitlines()
    methods: list[dict] = []
    aliases: list[dict] = []
    class_hint = "(unknown)"
    for number, raw in enumerate(lines, 1):
        # Strip CR but preserve source line numbers; never store source body
        # or copied third-party Ruby code in the audit artifact.
        text = raw.strip()
        if not text or text.startswith("#"):
            continue
        context = CONTEXT_RX.match(raw)
        if context:
            class_hint = context.group(1)
        found = METHOD_RX.match(raw)
        if found:
            method = found.group(1)
            if method in TARGET_METHODS:
                methods.append({
                    "line": number, "method": method,
                    # Nearest preceding class/module only, NOT a parser.
                    "lexical_class_hint_untrusted": class_hint,
                })
        if ALIAS_RX.match(raw):
            # The original alias may run conditionally or inside an eval.
            # Save a short line location only, not an invented alias graph.
            aliases.append({"line":number,"lexical_class_hint_untrusted":class_hint})
    return {
        "section":int(match.group(1)),
        "file":name,
        "source_sha256":hashlib.sha256(source.encode("utf-8")).hexdigest(),
        "ruby_lines":len(lines),
        "test_or_fixture_name":bool(TEST_NAME_RX.search(name)),
        "direct_definitions":methods,
        "alias_statement_locations":aliases,
        "database_reference_lines":sum(
            1 for line in lines
            if not line.lstrip().startswith("#") and DATA_TOUCH_RX.search(line)
        ),
        "master_setup_section":bool(re.search(r"FS_MasterSetup",name,re.I)),
        "auto_setup_section":bool(re.search(r"AutoSetup",name,re.I)),
        "boot_apply_all_mentions":sum(
            1 for line in lines
            if not line.lstrip().startswith("#") and "FS_DB_AUTOSET.apply_all" in line
        ),
    }

def build_report(sources: Iterable[tuple[str,str]]) -> dict:
    rows = [index_source(name,text) for name,text in sources]
    rows.sort(key=lambda row:row["section"])
    indices = [row["section"] for row in rows]
    if len(indices) != len(set(indices)):
        raise ValueError("Duplicate exported script sequence; authority order ambiguous")
    targets: dict = {}
    for method in TARGET_METHODS:
        locations = [
            {"section":row["section"],"file":row["file"],
             "line":definition["line"],
             "lexical_class_hint_untrusted":definition["lexical_class_hint_untrusted"],
             "test_or_fixture_name":row["test_or_fixture_name"]}
            for row in rows for definition in row["direct_definitions"]
            if definition["method"] == method
        ]
        targets[method] = {
            "direct_definition_count":len(locations),
            "candidate_locations":locations,
            "last_lexical_location_is_NOT_effective_runtime_authority":
                locations[-1] if locations else None,
        }
    return {
        "schema":"fs-rgss2-static-authority-evidence-v1",
        "verified_limitations":[
            "Regex is NOT a Ruby parser, lexical class hint can be wrong.",
            "Alias chains, class reopening, eval, boot setup and conditionals are NOT resolved.",
            "Final effective combat rules REQUIRE a real VX runtime witness.",
            "Filename TEST-only/Fixture does NOT prove code is disabled at runtime.",
            "Raw RVData is not boot-final FS data: MasterSetup Apply Bridge modifies database.",
        ],
        "source_file_count":len(rows),
        "sections":[{
            "section":r["section"],"file":r["file"],
            "source_sha256":r["source_sha256"],
            "ruby_lines":r["ruby_lines"],
            "test_or_fixture_name":r["test_or_fixture_name"],
            "alias_statement_count":len(r["alias_statement_locations"]),
            "alias_statement_locations":r["alias_statement_locations"],
            "database_reference_lines":r["database_reference_lines"],
            "master_setup_section":r["master_setup_section"],
            "auto_setup_section":r["auto_setup_section"],
            "boot_apply_all_mentions":r["boot_apply_all_mentions"],
        } for r in rows],
        "methods":targets,
        "master_setup_order":[{"section":r["section"],"file":r["file"]}
                              for r in rows if r["master_setup_section"]],
        "auto_setup_order":[{"section":r["section"],"file":r["file"]}
                            for r in rows if r["auto_setup_section"]],
        "explicit_apply_all":[{"section":r["section"],"file":r["file"],"hits":r["boot_apply_all_mentions"]}
                              for r in rows if r["boot_apply_all_mentions"] > 0],
        "test_named_sections":[{"section":r["section"],"file":r["file"]}
                               for r in rows if r["test_or_fixture_name"]],
        "unresolved_boot_final_data":True,
        "unresolved_effective_alias_chain":True,
    }

def _selftest() -> None:
    stub = [
        ("013__Game_Battler.rb",
         "class Game_Battler\n  def calc_hit(user, obj=nil)\n    95\n  end\nend\n"),
        ("411__SkillCost.rb",
         "class Game_Battler\n alias old_calc_mp_cost calc_mp_cost\n"
         " def calc_mp_cost(skill)\n  3\n end\nend\n"),
        ("479__Fixture.rb",
         "module Fixture\n def calc_hit(user,obj=nil)\n 100\n end\nend\n"),
    ]
    index = build_report(stub)
    assert index["source_file_count"] == 3
    assert index["methods"]["calc_hit"]["direct_definition_count"] == 2
    assert index["methods"]["calc_mp_cost"]["direct_definition_count"] == 1
    assert index["sections"][1]["alias_statement_count"] == 1
    assert index["methods"]["calc_hit"]["candidate_locations"][-1]["test_or_fixture_name"]
    assert index["unresolved_effective_alias_chain"]
    try:
        build_report([stub[0],stub[0]])
    except ValueError:
        pass
    else:
        raise AssertionError("Must reject duplicate script section")
    print("FS RGSS2 static authority scanner synthetic selftest PASS")

def _files(root: Path) -> Iterable[tuple[str,str]]:
    for file in sorted(root.glob("*.rb")):
        if FILE_RX.match(file.name):
            yield file.name, file.read_text(encoding="utf-8-sig")

def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source",default="exported_scripts")
    parser.add_argument("--output",default=None,help="Cloud CI artifact path ONLY")
    parser.add_argument("--expect-count",type=int,default=0)
    parser.add_argument("--self-test",action="store_true")
    args=parser.parse_args()
    if args.self_test:
        _selftest()
        return 0
    path=Path(args.source)
    if not path.is_dir():
        parser.error("Cannot find exported RGSS2 source directory")
    report=build_report(_files(path))
    if args.expect_count and report["source_file_count"] != args.expect_count:
        parser.error(f"Expected {args.expect_count} scripts, found {report['source_file_count']}")
    print(f"FS source static audit: {report['source_file_count']} ordered RGSS2 sections")
    for name in TARGET_METHODS:
        item=report["methods"][name]
        n=item["direct_definition_count"]
        latest=item["last_lexical_location_is_NOT_effective_runtime_authority"]
        print(f"  {name}: {n} direct def(s), last lexical section {latest['section'] if latest else 'none'} "
              "(NOT runtime authority)")
    print(f"MasterSetup pages {len(report['master_setup_order'])}; "
          f"apply_all call sites {len(report['explicit_apply_all'])}; "
          "Runtime / boot alias still UNRESOLVED.")
    if args.output is not None:
        if os.environ.get("GITHUB_ACTIONS") != "true" and (
                os.environ.get("FS_AUTHORIZED_CLOUD_WORKSPACE") != "true"):
            parser.error("Blocked PC write: --output requires approved ephemeral cloud workspace")
        dest=Path(args.output)
        dest.parent.mkdir(parents=True,exist_ok=True)
        dest.write_text(json.dumps(report,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
        print(f"Cloud audit artifact written to runner: {dest}")
    return 0

if __name__=="__main__":
    raise SystemExit(main())
