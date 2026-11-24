#!/usr/bin/env python3
"""Fail-closed, read-only FS lane + Skill/Tool routing. This NEVER executes provider tasks.

It returns paths and explicit LIVE_READ_REQUIRED gates; it cannot prove remote
apps actually invoked or that a particular GitHub/Drive file is the latest.
"""
from __future__ import annotations
import argparse
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent
KNOWN_LANES = ("T-C", "T-A", "T-B", "GODOT", "CONTROL")


def load_manifest(filename: Path | None = None) -> dict:
    data = json.loads((filename or ROOT / "routing_manifest.json").read_text(encoding="utf-8"))
    if data.get("schema") != "fs-routing/v1" or data.get("formal_engine") != "Godot 4.7.2":
        raise ValueError("Unknown or stale FS routing manifest: fail closed")
    if not data.get("cloud_only") or not data.get("no_codex"):
        raise ValueError("FS P0/No-Codex gates missing: fail closed")
    if set(data["lanes"]) != set(KNOWN_LANES):
        raise ValueError("Expected exact five FS lane types")
    for lane, spec in data["lanes"].items():
        if not spec.get("branch") or not spec.get("handoff") or not spec.get("skills"):
            raise ValueError(f"Missing required current-ref reference for {lane}")
    return data


def infer_lane(task: str) -> str:
    text = task.casefold().strip()
    if not text:
        raise ValueError("Empty task: choose --lane explicitly")
    matches = []
    patterns = {
        "T-C": ("t-c", "ground", "par ", "地圖", "村莊", "地形", "森林"),
        "T-A": ("t-a", "actor", "角色", "紙娃娃", "拳擊動畫", "run/attack"),
        "T-B": ("t-b", "monster", "怪物", "進化", "熔岩蛙", "fenrir"),
        "GODOT": ("godot", "戰鬥系統", "atb", "fsbattle", "事件編輯器"),
        "CONTROL": ("總控", "全部進度", "三線同步", "協調調度", "control tower"),
    }
    for lane, terms in patterns.items():
        if any(word in text for word in terms):
            matches.append(lane)
    # An explicit control-tower command outranks incidental names of audited lanes.
    if "CONTROL" in matches and any(word in text for word in ("總控", "control tower")):
        return "CONTROL"
    # The word Godot often describes the engine of a T-A/B/C task, not another lane.
    if "GODOT" in matches and len(matches) == 2:
        matches.remove("GODOT")
    if len(matches) != 1:
        raise ValueError("Task lane is ambiguous or unknown; use --lane rather than guessing: " + ",".join(matches))
    return matches[0]


def route(lane: str, manifest: dict, task: str = "") -> dict:
    if lane not in KNOWN_LANES:
        raise ValueError("Unknown lane: fail closed")
    spec = manifest["lanes"][lane]
    repo = manifest["repository"]
    governance = manifest.get("governance_branch", "main")
    files = [{"repository": repo, "branch": governance, "path": entry["path"]}
             for entry in manifest["read_first"] if entry["kind"] == "github"]
    files.extend([
        {"repository": repo, "branch": spec["branch"], "path": spec["handoff"]},
    ])
    if spec.get("launch"):
        files.append({"repository": repo, "branch": spec["branch"], "path": spec["launch"]})
    if spec.get("protocol"):
        files.append({"repository": repo, "branch": spec["branch"], "path": spec["protocol"]})
    # Dedup while preserving order
    dedup = []
    seen = set()
    for entry in files:
        key = (entry["repository"], entry["branch"], entry["path"])
        if key not in seen:
            dedup.append(entry)
            seen.add(key)
    return {
        "lane": lane,
        "task": task,
        "formal_engine": manifest["formal_engine"],
        "line": spec["branch"],
        "linear_issue": spec.get("issue"),
        "files_to_fetch_live": dedup,
        "drive_global_rules": [i["url"] for i in manifest["read_first"] if i["kind"] == "drive"],
        "skills_to_load_explicitly": spec["skills"],
        "tool_priority": [x["tool"] for x in sorted(manifest["tool_routing"], key=lambda x: x["rank"])],
        "current_snapshot_ONLY_not_live": spec["current_snapshot"],
        "binding_contract": spec["contract"],
        "required_gates": spec["mandatory_gates"],
        "execution_allowed": False,
        "requires_live_fetch": True,
        "requires_current_PC_Bridge_allowlist": True,
        "requires_P0_local_temp_approval_if_needed": True,
        "auto_use_of_skills_verified": False,
        "can_claim_art_pass_without_owner": False,
        "full_gameplay_claim_requires_independent_native_evidence": True,
    }


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--lane", choices=KNOWN_LANES)
    parser.add_argument("--task", default="")
    parser.add_argument("--manifest", type=Path)
    args = parser.parse_args(argv)
    try:
        manifest = load_manifest(args.manifest)
        lane = args.lane or infer_lane(args.task)
        print(json.dumps(route(lane, manifest, args.task), ensure_ascii=False, indent=2))
        return 0
    except (ValueError, OSError, KeyError, TypeError, json.JSONDecodeError) as error:
        print(f"FS_ROUTING_HOLD: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
