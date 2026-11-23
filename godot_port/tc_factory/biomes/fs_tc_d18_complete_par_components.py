#!/usr/bin/env python3
"""D18 FS_04_MAZE: Ground-locked independent PAR authoring from intact alpha islands.

This is a SCENE-SPECIFIC whole-foreground staging pass, not inverse segmentation
of a mixed Master or a generic pixel-masking system. All 6 independently
created foreground groups are retained 1x. No polygon trimming, object scaling
or changes to the frozen original Ground. No inference of actor occlusion.

Input private PNGs belong in owner-only Drive, never public GitHub.
Success of the source/alpha contract is NOT a Godot native test or ART PASS.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

import numpy as np
from PIL import Image
from scipy.ndimage import find_objects, label

SCENE_ID = "FS_04_MAZE"
CANVAS = (1280, 928)
SOURCE_CANVAS = (1474, 1067)
MIN_ALPHA = 8
MIN_COMPONENT_SIZE = 3000
N_COMPONENTS = 6
# Locked world positions for coherent full-map composition, with complete
# unmodified image-object silhouettes (not polygon cutouts).
POSITIONS = {
    "A_FORGE_MARKET": (0, 0),
    "B_WHOLE_BRIDGE": (554, 334),
    "C_SOUTH_WORKSHOP": (0, 570),
    "D_SOUTH_FOUNDRY": (643, 574),
    "E_FULL_LAMP": (539, 747),
    "F_FULL_BANNER": (544, 410),
}


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with Path(path).open("rb") as stream:
        for part in iter(lambda: stream.read(2**20), b""):
            h.update(part)
    return h.hexdigest()


def render(ground_path: Path, original_par_path: Path, out_dir: Path,
           ground_sha256: str, par_source_sha256: str,
           placements: dict[str, tuple[int, int]] | None = None,
           phase: str = "D18_INTACT_ALPHA_ISLANDS_ALL_NON_GROUND") -> dict:
    ground_path, original_par_path, out_dir = (
        Path(ground_path), Path(original_par_path), Path(out_dir))
    if ground_path.resolve() == original_par_path.resolve():
        raise ValueError("Must have separate Ground and PAR source files")
    if sha256(ground_path) != ground_sha256.lower():
        raise ValueError("Ground source SHA mismatch; forbidden to replace frozen Ground")
    if sha256(original_par_path) != par_source_sha256.lower():
        raise ValueError("Independent PAR source SHA mismatch")
    if out_dir.exists() and any(out_dir.iterdir()):
        raise ValueError("Output must be a new empty directory; no overwrite")
    with Image.open(ground_path) as gsrc:
        if gsrc.size != CANVAS or gsrc.mode != "RGB":
            raise ValueError("Frozen 1280x928 RGB Ground-only PNG required")
        ground = gsrc.copy()
    with Image.open(original_par_path) as psrc:
        if psrc.size != SOURCE_CANVAS or psrc.mode != "RGBA":
            raise ValueError("Independent full-scene RGBA PAR source 1474x1067 required")
        original = psrc.copy()
    alpha = np.asarray(original.getchannel("A"))
    if not np.any(alpha == 0):
        raise ValueError("Opaque Master rejected; must be true transparent PAR")
    active_positions = POSITIONS if placements is None else placements
    if set(active_positions) != set(POSITIONS):
        raise ValueError("All 6 independent object families must have positions")
    names = list(POSITIONS)
    labels, count = label(alpha > MIN_ALPHA, structure=np.ones((3, 3), dtype=bool))
    counts = np.bincount(labels.ravel())[1:]
    if len(counts) < N_COMPONENTS:
        raise ValueError("Missing independent non-ground families")
    indices = np.argsort(counts)[::-1][:N_COMPONENTS]
    if any(int(counts[i]) < MIN_COMPONENT_SIZE for i in indices):
        raise ValueError("Missing substantial foreground source island")
    regions = find_objects(labels)
    out = Image.new("RGBA", CANVAS, (0, 0, 0, 0))
    ground_lock = sha256(ground_path)
    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / "GROUND_LOCK_BEFORE_PAR.json").write_text(json.dumps({
        "scene_id": SCENE_ID, "stage": "GROUND_FIRST_SHA_LOCKED",
        "ground_sha256": ground_lock, "native_size": list(CANVAS),
        "PAR_at_this_stage": "NOT_BUILT", "ART": "HOLD"
    }, indent=2) + "\n", encoding="utf-8")
    occupied = np.zeros((CANVAS[1], CANVAS[0]), dtype=bool)
    combined_intersections = 0
    ledger = []
    for name, i in zip(names, indices):
        r = regions[i]
        if r is None:
            raise ValueError("Missing alpha source bounding box")
        y0, y1 = r[0].start, r[0].stop
        x0, x1 = r[1].start, r[1].stop
        raw = np.asarray(original.crop((x0, y0, x1, y1))).copy()
        component = labels[r] == i + 1
        source_count = int(np.count_nonzero(component))
        raw[:, :, 3][~component] = 0
        raw[:, :, 3][raw[:, :, 3] <= MIN_ALPHA] = 0
        raw[:, :, 3][raw[:, :, 3] >= 240] = 255
        visible = raw[:, :, 3] > MIN_ALPHA
        if int(np.count_nonzero(visible)) != source_count:
            raise ValueError("Source-positive pixels lost by segmentation")
        x, y = active_positions[name]
        height, width = visible.shape
        if not (0 <= x and 0 <= y and x + width <= CANVAS[0] and y + height <= CANVAS[1]):
            raise ValueError("Incomplete whole object falls outside world canvas: " + name)
        combined_intersections += int(np.count_nonzero(
            occupied[y:y+height, x:x+width] & visible))
        occupied[y:y+height, x:x+width] |= visible
        layer = Image.new("RGBA", CANVAS, (0, 0, 0, 0))
        layer.paste(Image.fromarray(raw, "RGBA"), (x, y))
        out = Image.alpha_composite(out, layer)
        ledger.append({
            "family": name, "source_cc_label": int(i + 1),
            "source_full_bbox": [x0, y0, x1, y1], "native_world_xy": [x, y],
            "original_visible_px": source_count, "visible_px_preserved_in_island": source_count,
            "polygon_trim_px": 0, "resampling": "NONE_1X", "world_bbox": [x, y, x+width, y+height]
        })
    dest = out_dir / "PAR_ALL_NON_GROUND_1280x928.png"
    out.save(dest, optimize=True)
    combined = out_dir / "GROUND_PLUS_PAR_STATIC_QA_1280x928.png"
    Image.alpha_composite(ground.convert("RGBA"), out).save(combined, optimize=True)
    a = np.asarray(out.getchannel("A"))
    border = {
        "top_4px_high_alpha": int(np.count_nonzero(a[:4, :] > 224)),
        "bottom_4px_high_alpha": int(np.count_nonzero(a[-4:, :] > 224)),
        "left_4px_high_alpha": int(np.count_nonzero(a[:, :4] > 224)),
        "right_4px_high_alpha": int(np.count_nonzero(a[:, -4:] > 224)),
    }
    report = {
        "scene_id": SCENE_ID, "phase": phase,
        "original_par_source_sha256": sha256(original_par_path),
        "locked_ground_sha256": sha256(ground_path),
        "PAR_sha256": sha256(dest), "composite_sha256": sha256(combined),
        "world_pixels": list(CANVAS), "world_tiles": [40, 29],
        "ground_mode": "RGB", "par_mode": "RGBA", "par_is_independent_of_ground": True,
        "source_object_scale": "1x_no_resample", "polygon_trim_pixels": 0,
        "all_six_independent_source_components_preserved": True,
        "source_significant_pixels_preserved": sum(x["original_visible_px"] for x in ledger),
        "source_significant_pixels_lost_to_polygon_trim": 0,
        "source_object_overlap_pixels_before_composite": combined_intersections,
        "alpha_zero_pixels": int(np.count_nonzero(a == 0)),
        "edge_contact_qa": border, "source_family_ledger": ledger,
        "private_art_Godot_4_7_2_native": "NOT_RUN",
        "visual_art": "HOLD_SOURCE_TOP_SMOKE_BORDER_FOOTPOINT_HUMAN_REVIEW",
        "integration": "NOT_RUN", "formal_ART_PASS": "0/12"
    }
    (out_dir / "D18_SOURCE_QA.json").write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    if sha256(ground_path) != ground_lock:
        raise AssertionError("Ground mutated")
    return report


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--ground", type=Path, required=True)
    p.add_argument("--par-source", type=Path, required=True)
    p.add_argument("--out", type=Path, required=True)
    p.add_argument("--ground-sha256", required=True)
    p.add_argument("--par-sha256", required=True)
    a = p.parse_args()
    result = render(a.ground, a.par_source, a.out, a.ground_sha256, a.par_sha256)
    print(json.dumps({k: result[k] for k in (
        "scene_id", "PAR_sha256", "alpha_zero_pixels",
        "polygon_trim_pixels", "private_art_Godot_4_7_2_native")}, ensure_ascii=False))


if __name__ == "__main__":
    main()
