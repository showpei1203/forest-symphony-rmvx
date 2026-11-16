#!/usr/bin/env python3
"""Zero-credit upstream Agent Sprite Forge integration smoke.

Public fixture is deliberately synthetic. Never fetches or uploads private FS F0.
This tests real upstream CLI operations, not art generation or native VX.
"""
from __future__ import annotations
import argparse
import hashlib
import json
import subprocess
import sys
from pathlib import Path
from PIL import Image, ImageDraw

PIN = "25203d03900b46b444bdd72a75768c33d1895ad6"


def run(argv: list[str]) -> dict:
    completed = subprocess.run(argv, capture_output=True, text=True)
    if completed.returncode != 0:
        raise RuntimeError(
            f"command failed ({completed.returncode}): {' '.join(argv)}\n"
            f"stdout={completed.stdout[-6000:]}\nstderr={completed.stderr[-6000:]}"
        )
    lines = [line for line in completed.stdout.splitlines() if line.strip()]
    try:
        return json.loads(lines[-1]) if lines else {"status": "no_output"}
    except json.JSONDecodeError as error:
        raise RuntimeError(f"upstream CLI did not emit final JSON: {lines[-1]}") from error


def synthetic_master(destination: Path) -> None:
    """Intentionally simple synthetic 48px character with joined legs and obvious shoes."""
    im = Image.new("RGBA", (48, 48))
    d = ImageDraw.Draw(im)
    d.rectangle((17, 4, 30, 15), fill=(220, 206, 168, 255))
    d.rectangle((18, 3, 30, 6), fill=(60, 75, 85, 255))
    d.rectangle((14, 16, 33, 30), fill=(32, 119, 116, 255))
    d.rectangle((10, 19, 15, 29), fill=(55, 92, 105, 255))
    d.rectangle((32, 19, 37, 29), fill=(55, 92, 105, 255))
    d.rectangle((17, 29, 21, 43), fill=(46, 57, 78, 255))
    d.rectangle((26, 29, 30, 43), fill=(46, 57, 78, 255))
    d.rectangle((15, 42, 22, 44), fill=(95, 60, 43, 255))
    d.rectangle((25, 42, 32, 44), fill=(95, 60, 43, 255))
    im.save(destination)


def main() -> None:
    cli = argparse.ArgumentParser()
    cli.add_argument("--upstream-root", type=Path, required=True)
    cli.add_argument("--output-dir", type=Path, required=True)
    args = cli.parse_args()
    out = args.output_dir.resolve()
    out.mkdir(parents=True, exist_ok=True)
    source = args.upstream_root.resolve()
    tool = source / "skills/video2dsprite/scripts/pixel_motion.py"
    if not tool.is_file():
        raise SystemExit("upstream pixel_motion.py missing")
    rev = subprocess.check_output(["git", "-C", str(source), "rev-parse", "HEAD"], text=True).strip()
    if rev != PIN:
        raise SystemExit(f"unreviewed upstream revision: {rev}")
    master = out / "synthetic_48px_rgba.png"
    synthetic_master(master)
    python = sys.executable
    common = [python, str(tool)]

    breath = run(common + ["breath", "--sprite", str(master), "--name", "smoke_breath",
                           "--output-dir", str(out / "breath"), "--no-package"])
    assert breath.get("frames") == 2, breath

    prepared = run(common + ["prepare", "--sprite", str(master), "--action", "walk",
                             "--subject", "synthetic forest guardian",
                             "--facing", "south-west 3/4 view", "--canvas", "1280,720",
                             "--scale", "8", "--duration", "2",
                             "--output-dir", str(out / "prepared")])
    frame = out / "prepared/input.png"
    if not frame.is_file():
        raise SystemExit("real upstream prepare did not create input.png")
    clip = out / "source_still_replay.mp4"
    subprocess.run(
        ["ffmpeg", "-hide_banner", "-loglevel", "error", "-y", "-loop", "1", "-framerate", "12",
         "-i", str(frame), "-t", "2", "-c:v", "libx264", "-crf", "18",
         "-pix_fmt", "yuv420p", str(clip)], check=True
    )

    extracted = run(common + ["frames", "--clip", str(clip), "--job", str(out / "prepared"),
                              "--output-dir", str(out / "frames")])
    finished = run(common + ["finish", "--frames-dir", str(out / "frames"),
                             "--name", "smoke_replayed", "--pick", "0,4,8",
                             "--output-dir", str(out / "finish"), "--no-package"])

    report = {
        "test": "A24 upstream ASF exact CLI smoke, no provider",
        "repository_commit": rev,
        "synthetic_only": True,
        "private_user_art": False,
        "generated_new_art": False,
        "paid_calls": 0,
        "native_vx": "NOT_RUN",
        "user_art": "NOT_RUN",
        "steps": {"breath": breath, "prepare": prepared,
                  "frames": extracted, "finish": finished},
        "fixture_sha256": hashlib.sha256(master.read_bytes()).hexdigest(),
        "source_replay_clip": str(clip)
    }
    (out / "A24_UPSTREAM_SMOKE_QA.json").write_text(
        json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8"
    )
    print(json.dumps({"status": "PASS", "revision": rev,
                      "steps": sorted(report["steps"]), "no_new_art": True}))


if __name__ == "__main__":
    main()
