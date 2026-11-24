#!/usr/bin/env python3
"""Build a REAL transparent CompletePAR from an independently authored chroma plate.

NOT a scene/Master extraction tool. The source plate must contain ALL non-ground
objects, arranged in locked world XY, on a flat single-color chroma background.
No Ground pixels or finished city backgrounds may appear in that plate.

The converter ONLY makes the known chroma background transparent. It cannot
invent props, infer object placement, or certify visual registration / ART PASS.
Private PNGs belong in the owner's Drive, never this repository.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from PIL import Image


def digest(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as file:
        for chunk in iter(lambda: file.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def parse_hex_color(value: str) -> tuple[int, int, int]:
    value = value.lstrip("#")
    if len(value) != 6:
        raise ValueError("Chroma key must be 6-digit RRGGBB")
    try:
        return tuple(bytes.fromhex(value))  # type: ignore[return-value]
    except ValueError as error:
        raise ValueError("Invalid hex chroma key") from error


def convert_chroma_par(
    ground_path: Path,
    chroma_plate_path: Path,
    out_dir: Path,
    expected_ground_sha256: str,
    *,
    scene_id: str = "FS_04_VILLAGE",
    key: tuple[int, int, int] = (0, 255, 0),
    tolerance: int = 0,
    min_background_fraction: float = 0.25,
) -> dict:
    ground_path = Path(ground_path)
    chroma_plate_path = Path(chroma_plate_path)
    out_dir = Path(out_dir)
    if ground_path.resolve() == chroma_plate_path.resolve():
        raise ValueError("Ground and plate must be INDEPENDENT sources")
    if not 0 <= tolerance <= 24:
        raise ValueError("Chroma tolerance must be 0..24; broad color removal is forbidden")
    if not 0 < min_background_fraction < 1:
        raise ValueError("Invalid minimum chroma coverage")
    if len(expected_ground_sha256) != 64 or digest(ground_path) != expected_ground_sha256.lower():
        raise ValueError("Ground SHA lock mismatch; original Ground must not change")
    with Image.open(ground_path) as ground, Image.open(chroma_plate_path) as source:
        if ground.mode != "RGB":
            raise ValueError("Locked Ground must be an opaque RGB PNG")
        if source.mode not in ("RGB", "RGBA"):
            raise ValueError("Chroma plate must be RGB or opaque RGBA")
        if ground.size != source.size:
            raise ValueError("Plate must match Ground's exact pixel world size")
        width, height = ground.size
        if width % 32 or height % 32:
            raise ValueError("Ground does not align to the 32-pixel grid")
        if source.mode == "RGBA" and source.getchannel("A").getextrema() != (255, 255):
            raise ValueError("Use the existing RGBA PAR validator for transparent sources")
        # Only the purpose-built chroma background is removed. We do NOT
        # segment or classify city scenery, rocks, lava, buildings or sprites.
        rgb = source.convert("RGB")
        pixels = list(rgb.getdata())
        def is_key(c: tuple[int, int, int]) -> bool:
            return max(abs(c[i] - key[i]) for i in range(3)) <= tolerance
        mask = [is_key(c) for c in pixels]
        key_count = sum(mask)
        total = width * height
        if key_count < total * min_background_fraction:
            raise ValueError("REJECT opaque Master / scene: not a flat chroma plate")
        if key_count == total:
            raise ValueError("REJECT empty plate: no CompletePAR objects")
        # Empty corners are mandatory as independent proof of a keyed canvas.
        side = min(4, width, height)
        for cx, cy in ((0, 0), (width-side, 0),
                       (0, height-side), (width-side, height-side)):
            for y in range(cy, cy + side):
                for x in range(cx, cx + side):
                    if not mask[y * width + x]:
                        raise ValueError("REJECT scene background/corner props: chroma corners must be flat")
        alpha_pixels = [(r, g, b, 0 if cut else 255)
                        for (r, g, b), cut in zip(pixels, mask)]
        result = Image.new("RGBA", (width, height))
        result.putdata(alpha_pixels)
        # Reject suspect chroma remnants at image corners and reject overlays
        # where less than 1 percent of the image is actually visible.
        visible = total - key_count
        if visible < total * 0.01:
            raise ValueError("REJECT almost-empty CompletePAR")
        out_dir.mkdir(parents=True, exist_ok=True)
        par_path = out_dir / "PAR_ALL_NON_GROUND_CHROMA_CONVERTED.png"
        if par_path.resolve() in (ground_path.resolve(), chroma_plate_path.resolve()):
            raise ValueError("Never overwrite original sources")
        result.save(par_path)
        composite_path = out_dir / "GROUND_PLUS_PAR_PREVIEW_ONLY.png"
        Image.alpha_composite(ground.convert("RGBA"), result).save(composite_path)
    report = {
        "scene_id": scene_id,
        "method": "INDEPENDENT_ALL_NON_GROUND_CHROMA_PLATE_TO_REAL_RGBA",
        "not_master_reverse_extraction": True,
        "ground_sha256": digest(ground_path),
        "chroma_plate_sha256": digest(chroma_plate_path),
        "par_sha256": digest(par_path),
        "composite_preview_sha256": digest(composite_path),
        "canvas": [width, height],
        "chroma_rgb": list(key),
        "tolerance": tolerance,
        "alpha_zero_pixels": key_count,
        "alpha_255_pixels": visible,
        "alpha_nonbinary_pixels": 0,
        "transparency_contract": "PASS",
        "source_provenance": "MUST_REVIEW_INDEPENDENT_NON_GROUND_PLATE",
        "same_world_xy": "MUST_VISUALLY_VALIDATE",
        "all_non_ground_classes": "MUST_VISUALLY_VALIDATE",
        "Godot_4_7_2_native": "NOT_RUN",
        "formal_ART_GATE": "HOLD",
        "warning": "Do not confuse successful chroma-to-alpha conversion with an authored, aligned, complete PAR or ART PASS",
    }
    (out_dir / "CHROMA_PAR_QA.json").write_text(
        json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return report


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ground", type=Path, required=True)
    parser.add_argument("--plate", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--ground-sha256", required=True)
    parser.add_argument("--scene-id", default="FS_04_VILLAGE")
    parser.add_argument("--chroma", default="00FF00")
    parser.add_argument("--tolerance", type=int, default=0)
    args = parser.parse_args()
    report = convert_chroma_par(
        args.ground, args.plate, args.out, args.ground_sha256,
        scene_id=args.scene_id, key=parse_hex_color(args.chroma),
        tolerance=args.tolerance)
    print(json.dumps(report, ensure_ascii=False))


if __name__ == "__main__":
    main()
