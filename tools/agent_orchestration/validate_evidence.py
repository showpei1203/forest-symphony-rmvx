#!/usr/bin/env python3
"""FS evidence contract validator; structural truth gate, NOT a remote auditor."""
from __future__ import annotations
import argparse
import json
from pathlib import Path
import re
import sys

GATES = ("source", "technical", "godot_native", "owner_art", "full_gameplay", "cloud_readback")
STATES = {"PASS", "FAIL", "HOLD", "ART_HOLD", "AWAIT_USER_ART", "NOT_RUN"}
CLAIMS = {"NOT_RUN", "ACTIVE", "BLOCKED", "TECH_PASS", "ART_HOLD", "AWAIT_USER_ART", "VERIFIED_PASS"}
LANES = {"T-A", "T-B", "T-C", "GODOT", "CONTROL"}
SHA256 = re.compile(r"^[0-9a-f]{64}$")
SHA_GIT = re.compile(r"^[0-9a-f]{40}$")


def present(obj: dict, key: str) -> bool:
    return isinstance(obj.get(key), str) and bool(obj[key].strip())


def is_url(value: object) -> bool:
    return isinstance(value, str) and value.startswith(("https://github.com/", "https://drive.google.com/", "https://docs.google.com/"))


def validate(record: dict) -> list[str]:
    errors: list[str] = []
    if not isinstance(record, dict):
        return ["Record must be a JSON object"]
    if record.get("schema") != "fs-handoff-evidence/v1":
        errors.append("Unknown evidence schema")
    if record.get("target") not in LANES:
        errors.append("target must name a known lane")
    if record.get("claim") not in CLAIMS:
        errors.append("invalid claim status")
    for name in ("branch", "stage"):
        if not present(record, name):
            errors.append(f"missing {name}")
    qa = record.get("qa")
    if not isinstance(qa, dict):
        return errors + ["Missing qa object"]
    for gate in GATES:
        if qa.get(gate) not in STATES:
            errors.append(f"missing or unknown qa.{gate}")
    source = record.get("source", {})
    art = record.get("artifacts", {})
    owner = record.get("owner_approval", {})
    independent = record.get("independent_verification", {})
    temp = record.get("pc_temp", {})
    if not all(isinstance(o, dict) for o in (source, art, owner, independent, temp)):
        return errors + ["Malformed evidence sections"]
    skills = record.get("skills_loaded", [])
    tools = record.get("tools_invoked", [])
    if not isinstance(skills, list) or not isinstance(tools, list):
        return errors + ["skills_loaded/tools_invoked must be arrays"]
    for i, s in enumerate(skills):
        if not isinstance(s, dict) or not all(present(s, k) for k in ("name", "source_ref", "version_or_sha")):
            errors.append(f"skills_loaded[{i}] must identify actual content/version read")
    for i, t in enumerate(tools):
        if not isinstance(t, dict) or not all(present(t, k) for k in ("tool", "operation", "evidence_url")):
            errors.append(f"tools_invoked[{i}] must identify exact invocation with evidence URL")
        elif not is_url(t["evidence_url"]):
            errors.append(f"tools_invoked[{i}] evidence must be authoritative cloud URL")
    for i, job in enumerate(record.get("model_jobs", [])):
        if not isinstance(job, dict) or not all(present(job, k) for k in ("provider", "job_id", "record_url")):
            errors.append(f"model_jobs[{i}] missing true provider/job provenance")
        elif not is_url(job["record_url"]):
            errors.append(f"model_jobs[{i}] invalid source URL")
    if temp.get("used") is True and temp.get("preapproved") is not True:
        errors.append("P0: owner PC temporary files used without prior authorization")
    if record.get("claim") != "NOT_RUN" and not present(record, "actual_delta"):
        errors.append("non-NOT_RUN claim requires observable actual_delta")
    if qa.get("source") == "PASS" or any(qa.get(x) == "PASS" for x in GATES if x != "source"):
        if not SHA256.fullmatch(str(source.get("sha256", ""))) or not is_url(source.get("drive_url")):
            errors.append("PASS requires real 64-digit source SHA256 and cloud source URL")
        if source.get("license_checked") is not True:
            errors.append("PASS requires source license/rights checked")
    if qa.get("technical") == "PASS":
        if not tools or not is_url(art.get("github_commit_url")):
            errors.append("technical PASS requires logged actual tools and GitHub commit evidence")
    if qa.get("godot_native") == "PASS":
        if qa.get("technical") != "PASS" or not is_url(art.get("native_run_url")) or not is_url(art.get("native_log_url")):
            errors.append("Godot PASS requires technical PASS, actual native run URL and native log")
        if not present(art, "native_marker") or not SHA_GIT.fullmatch(str(art.get("source_commit_sha", ""))):
            errors.append("Godot PASS requires explicit native marker and pinned 40-digit commit")
        if independent.get("native_marker_checked") is not True:
            errors.append("Godot PASS requires independent native marker readback")
    if qa.get("owner_art") == "PASS":
        if qa.get("godot_native") != "PASS" or owner.get("explicit") is not True or not is_url(owner.get("evidence_url")):
            errors.append("ART PASS requires native PASS and explicit owner-approved visual evidence")
        if not is_url(art.get("godot_preview_url")):
            errors.append("ART PASS requires a real native visual preview link")
    if qa.get("full_gameplay") == "PASS":
        if qa.get("godot_native") != "PASS" or not is_url(art.get("gameplay_run_url")):
            errors.append("Full gameplay PASS requires native PASS and an actual game scene run")
    if qa.get("cloud_readback") == "PASS":
        if not is_url(art.get("github_commit_url")) or not is_url(art.get("drive_url")):
            errors.append("Delivery PASS requires actual GitHub + correct private Drive URLs")
        if independent.get("github_readback") is not True or independent.get("drive_readback") is not True:
            errors.append("Delivery PASS requires independent readback of both providers")
        if temp.get("used") is True and temp.get("cleanup_verified") is not True:
            errors.append("P0 delivery cannot PASS with owner PC temporary cleanup unverified")
    claim = record.get("claim")
    if claim == "TECH_PASS" and not all(qa.get(x) == "PASS" for x in ("source", "technical")):
        errors.append("TECH_PASS claim requires source and technical PASS")
    if claim in ("ART_HOLD", "AWAIT_USER_ART") and qa.get("owner_art") == "PASS":
        errors.append("HOLD claim contradicts owner ART PASS")
    if claim == "VERIFIED_PASS" and any(qa.get(x) != "PASS" for x in GATES):
        errors.append("VERIFIED_PASS requires ALL six independent gates PASS")
    if claim == "VERIFIED_PASS" and (not skills or not tools):
        errors.append("VERIFIED_PASS requires recorded actual Skill loads and tool calls")
    return errors


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("json_file", type=Path)
    args = parser.parse_args(argv)
    try:
        errors = validate(json.loads(args.json_file.read_text(encoding="utf-8")))
    except (OSError, ValueError, json.JSONDecodeError) as error:
        print(f"FS_EVIDENCE_HOLD: {error}", file=sys.stderr)
        return 2
    if errors:
        for error in errors:
            print(f"FS_EVIDENCE_HOLD: {error}", file=sys.stderr)
        return 2
    print("FS_EVIDENCE_STRUCTURAL_PASS (NOT proof of remote run or user ART approval)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
