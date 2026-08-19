#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Render witness candidates on the Castle Master for visual confirmation."""
from __future__ import annotations
import argparse, json
from pathlib import Path
from PIL import Image, ImageDraw


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--master", required=True, type=Path)
    p.add_argument("--witnesses", required=True, type=Path)
    p.add_argument("--out", required=True, type=Path)
    args = p.parse_args()
    manifest = json.loads(args.witnesses.read_text(encoding="utf-8"))
    img = Image.open(args.master).convert("RGBA")
    expected = tuple(manifest.get("canvas", img.size))
    if img.size != expected:
        raise SystemExit(f"canvas mismatch: master={img.size} witness={expected}")
    draw = ImageDraw.Draw(img)
    for obj in manifest.get("objects", []):
        oid = str(obj.get("id", "?"))
        box = obj.get("source_box")
        if isinstance(box, list) and len(box) == 4:
            draw.rectangle(tuple(box), outline=(255, 255, 0, 255), width=2)
            draw.text((box[0] + 2, box[1] + 2), oid, fill=(255, 255, 0, 255))
        for i, wp in enumerate(obj.get("witnesses", []), 1):
            x, y = int(wp["x"]), int(wp["y"])
            confirmed = bool(wp.get("visual_confirmed", obj.get("visual_confirmed", False)))
            color = (0, 255, 0, 255) if confirmed else (255, 64, 64, 255)
            r = 6
            draw.ellipse((x-r, y-r, x+r, y+r), outline=color, width=2)
            draw.line((x-r-2, y, x+r+2, y), fill=color, width=1)
            draw.line((x, y-r-2, x, y+r+2), fill=color, width=1)
            draw.text((x + 8, y - 6), f"{oid}.{i}", fill=color)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    img.save(args.out)
    print(args.out)
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
