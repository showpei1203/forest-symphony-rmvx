#!/usr/bin/env python3
"""Generate PUBLICLY HARMLESS SYNTHETIC source images to test Godot D14 native renderer.

Do not confuse this with a true FS_04_VILLAGE artwork test. Real PNGs stay
in the owner-only Drive and must be supplied privately to native probe.
"""
from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path

from PIL import Image, ImageDraw


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def make(out: Path) -> dict:
    out.mkdir(parents=True, exist_ok=True)
    width, height = 1280, 928
    ground = Image.new("RGB", (width, height), (45, 43, 49))
    d = ImageDraw.Draw(ground)
    d.rectangle((0, 360, width - 1, 550), fill=(92, 86, 97))
    d.rectangle((530, 0, 730, height - 1), fill=(92, 86, 97))
    d.ellipse((534, 364, 727, 557), fill=(112, 104, 118))
    d.rectangle((825, 610, 1140, 660), fill=(242, 83, 18))
    ground_path = out / "SYNTHETIC_GROUND.png"
    ground.save(ground_path)

    par = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    d = ImageDraw.Draw(par)
    d.rectangle((120, 130, 400, 310), fill=(76, 70, 91, 255))
    d.rectangle((140, 180, 380, 310), outline=(240, 162, 66, 255), width=6)
    d.rectangle((900, 105, 1155, 305), fill=(81, 74, 89, 255))
    d.rectangle((930, 220, 1010, 305), fill=(241, 106, 36, 255))
    d.rectangle((815, 570, 1150, 603), fill=(114, 115, 122, 255))
    d.rectangle((180, 705, 420, 890), fill=(78, 71, 87, 255))
    d.rectangle((790, 725, 1090, 890), fill=(78, 71, 87, 255))
    par_path = out / "SYNTHETIC_ALL_NON_GROUND_PAR.png"
    par.save(par_path)

    bad_path = out / "SYNTHETIC_BAD_PAR_SIZE.png"
    par.crop((0, 0, 1279, 928)).save(bad_path)
    qa = {
        "scene_id": "FS_TC_TEST_ONLY",
        "source_type": "SYNTHETIC_ART_UNFIT_FOR_GAME",
        "ground": str(ground_path),
        "par": str(par_path),
        "wrong_size_par": str(bad_path),
        "ground_sha256": sha(ground_path),
        "par_sha256": sha(par_path),
        "world_size": [width, height],
        "art_gate": "HOLD",
    }
    (out / "FS_TC_D14_FIXTURE_MANIFEST.json").write_text(
        json.dumps(qa, indent=2) + "\n", encoding="utf-8")
    return qa


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", type=Path, required=True)
    args = ap.parse_args()
    print(json.dumps(make(args.out)))
