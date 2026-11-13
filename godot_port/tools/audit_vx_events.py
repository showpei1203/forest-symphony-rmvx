#!/usr/bin/env python3
"""Read-only coverage inventory of original RPG Maker VX map/common event opcodes.

Without --output: prints aggregate counts; NEVER writes to the source PC.
This does NOT export private story text nor imply Godot support.
"""
import argparse
import collections
import json
from pathlib import Path

from rvdata_to_json import RubyMarshal48

def commands_of(row):
    return row.get("list", []) if isinstance(row, dict) else []

def audit(source):
    source = Path(source)
    codes = collections.Counter()
    map_events = 0
    map_pages = 0
    common_events = 0
    map_files = 0
    triggers = collections.Counter()

    def count_commands(commands):
        for cmd in commands:
            if isinstance(cmd, dict):
                codes[int(cmd.get("code", -1))] += 1

    for file in sorted(source.glob("Map[0-9][0-9][0-9].rvdata")):
        data = RubyMarshal48(file.read_bytes()).parse()
        events = data.get("events", {}).get("__ruby_hash_pairs__", [])
        map_files += 1
        for _event_id, event in events:
            if not isinstance(event, dict):
                continue
            map_events += 1
            for page in event.get("pages", []):
                map_pages += 1
                triggers[int(page.get("trigger", -1))] += 1
                count_commands(commands_of(page))

    common = RubyMarshal48((source / "CommonEvents.rvdata").read_bytes()).parse()
    for item in common:
        if isinstance(item, dict):
            common_events += 1
            count_commands(commands_of(item))

    return {
        "map_files": map_files,
        "events": map_events,
        "event_pages": map_pages,
        "common_events": common_events,
        "commands_total": sum(codes.values()),
        "commands_by_code": dict(sorted(codes.items())),
        "event_pages_by_trigger": dict(sorted(triggers.items())),
        "special_script_commands_355_655": codes[355] + codes[655],
        "scope_note": "Aggregate code frequencies only. No story text or Ruby script exported."
    }

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("data_dir", help="Folder containing Data/MapNNN.rvdata and CommonEvents.rvdata")
    p.add_argument("--output", help="Do not use local PC for output without prior authorization")
    args = p.parse_args()
    result = audit(args.data_dir)
    serialized = json.dumps(result, ensure_ascii=False, indent=2)
    print(serialized)
    if args.output:
        Path(args.output).write_text(serialized + "\n", encoding="utf-8")

if __name__ == "__main__":
    main()
