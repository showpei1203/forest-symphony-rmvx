#!/usr/bin/env python3
"""T-C C3 full-sized 1280x928 FS_01_VILLAGE composition candidate.

NOT the preserved A35 R8 R3 production scene. Uses independent historic A36G
PixelLab scene source, same master-first derivation; no guessed private assets.
Only ephemeral output; images/QA must be moved to owner-only Drive.
"""
from pathlib import Path
import argparse
import json
import build_tc_village_pilot as pilot

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--source", type=Path, default=pilot.SOURCE)
    args = parser.parse_args()
    pilot.W, pilot.H = 1280, 928
    pilot.CROP = (0, 0, 1280, 928)
    qa = pilot.build(args.out, args.source)
    qa["phase"] = "C3 full-sized village candidate, inherited A36G PixelLab style"
    qa["target"] = "FS_01_VILLAGE"
    qa["production_a35_preserved"] = True
    qa["collision_native"] = "SEPARATE_STATIC_HOUSE_FOOTPRINT_PENDING"
    qa["human_art_approval"] = "ART_HOLD"
    (args.out/"TC_PILOT_SOURCE_QA.json").write_text(json.dumps(qa, ensure_ascii=False, indent=2), encoding="utf-8")
    print("FS_TC_FULL_VILLAGE_CANDIDATE", json.dumps({"canvas":qa["canvas"],"source_reg":qa["source_registration"],"art":qa["art_gate"]}))
