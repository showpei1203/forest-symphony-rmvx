#!/usr/bin/env python3
"""A54: read-only, fail-closed asset audit for the A53 clean Godot GPU test.

Never writes to the user's PC. Feed the asset filenames from a verified Drive
folder listing, or pass the real project's assets directory during an
authorized native run. No private textures are required for metadata-only QA.
"""
import argparse
import json
import re
from pathlib import Path

CANONICAL = {
    "actor01_a53_body_12frames.png",
    "actor01_a53_body_only_composite_reference.png",
}
OBSOLETE = "actor01_a53_empty_weapon_and_fx_12frames.png"
REF_RE = re.compile(r"res://assets/([A-Za-z0-9_.-]+)")


def audit(source: str, available_assets: set[str], require_clean_clock: bool = True) -> dict:
    refs = sorted(set(REF_RE.findall(source)))
    missing = sorted(set(refs) - available_assets)
    obsolete = sorted(set(refs) & {OBSOLETE})
    absent_baseline = sorted(CANONICAL - available_assets)
    has_three_tracks = (
        'timing.get_track_count() == 3' in source
        or 'timing.get_track_count()==3' in source
    )
    failures = []
    if missing:
        failures.append("referenced-but-missing-assets")
    if obsolete:
        failures.append("deleted-weapon-fx-placeholder-still-referenced")
    if absent_baseline:
        failures.append("canonical-a53-body-or-reference-absent")
    if require_clean_clock and not has_three_tracks:
        failures.append("missing-exact-3-track-clock-gate")
    return {
        "stage": "A54",
        "status": "PASS" if not failures else "FAIL",
        "references": refs,
        "missing_assets": missing,
        "obsolete_references": obsolete,
        "missing_baseline": absent_baseline,
        "clock_3track_assertion": has_three_tracks,
        "failures": failures,
        "scope": "STATIC ONLY; Godot GPU, real hit, and ART approval remain independent",
    }


def selftest() -> None:
    assets = set(CANONICAL)
    broken = 'load("res://assets/' + OBSOLETE + '")'
    fixed = ('load("res://assets/actor01_a53_body_12frames.png")\n'
             'gate(timing.get_track_count() == 3, "three-track")')
    bad = audit(broken, assets)
    good = audit(fixed, assets)
    assert bad["status"] == "FAIL", bad
    assert bad["missing_assets"] == [OBSOLETE], bad
    assert good["status"] == "PASS", good
    assert good["clock_3track_assertion"], good
    print("A54_CONTRACT_SELFTEST PASS")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--qa", type=Path, help="GPU QA GDScript source")
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--assets-dir", type=Path, help="verified local Godot assets dir")
    group.add_argument("--assets-json", type=Path, help="JSON list of Drive asset filenames")
    parser.add_argument("--selftest", action="store_true")
    args = parser.parse_args()
    if args.selftest:
        selftest()
        return 0
    if not args.qa or not (args.assets_dir or args.assets_json):
        parser.error("provide --qa and --assets-dir or --assets-json")
    if args.assets_dir:
        names = {p.name for p in args.assets_dir.iterdir() if p.is_file()}
    else:
        data = json.loads(args.assets_json.read_text(encoding="utf-8"))
        names = set(data["file_names"] if isinstance(data, dict) else data)
    report = audit(args.qa.read_text(encoding="utf-8-sig"), names)
    print(json.dumps(report, indent=2, ensure_ascii=False))
    return 0 if report["status"] == "PASS" else 1


if __name__ == "__main__":
    raise SystemExit(main())
