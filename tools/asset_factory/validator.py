"""Fail-closed static QA for *candidates*; never certifies native VX or visual art.

Manifest schema: fs-asset-candidate/v1. No private source assets are bundled.
Pure offline PNG validator; intended for a cloud CI runner or isolated agent.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from collections import deque
from pathlib import Path
from typing import Any

from PIL import Image, ImageChops

SCHEMA = "fs-asset-candidate/v1"
MAP_LAYERS = (
    "authoring_ground_only",
    "authoring_complete_par",
    "runtime_full_ground",
    "runtime_occlusion_par",
)


def _problem(items: list[dict[str, str]], gate: str, detail: str) -> None:
    items.append({"gate": gate, "detail": detail})


def _within(root: Path, relative: str) -> Path:
    if not isinstance(relative, str) or not relative:
        raise ValueError("asset path must be a nonempty relative string")
    p = Path(relative)
    if p.is_absolute() or p.drive:
        raise ValueError("absolute file paths are forbidden")
    full = (root / p).resolve()
    if full != root and root not in full.parents:
        raise ValueError("asset path escapes approved source root")
    return full


def _read_image(
    root: Path, relative: str, issues: list[dict[str, str]], gate: str
) -> Image.Image | None:
    try:
        path = _within(root, relative)
        with Image.open(path) as source:
            if source.format != "PNG":
                raise ValueError("not PNG")
            if source.mode not in ("RGB", "RGBA"):
                raise ValueError(f"mode {source.mode}: RGB/RGBA PNG required")
            return source.convert("RGBA")
    except (OSError, ValueError, TypeError) as exc:
        _problem(issues, gate, f"{relative!r}: {exc}")
        return None


def _dimensions(raw: Any, issues: list[dict[str, str]], gate: str) -> tuple[int, int] | None:
    try:
        w, h = raw["width"], raw["height"]
        if type(w) is not int or type(h) is not int or not (1 <= w <= 16384 and 1 <= h <= 16384):
            raise ValueError("dimensions must be positive integer pixels <=16384")
        return w, h
    except (ValueError, TypeError, KeyError):
        _problem(issues, gate, "missing/invalid width or height")
        return None


def _sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def _validate_sprite(data: dict, root: Path, issues: list[dict[str, str]]) -> None:
    dims = _dimensions(data.get("frame"), issues, "S_FRAME")
    animations = data.get("animations")
    if not isinstance(animations, list) or not animations:
        _problem(issues, "S_ANIMATIONS", "animations must be a nonempty array")
        return
    seen: set[tuple[str, str]] = set()
    for entry in animations:
        if not isinstance(entry, dict):
            _problem(issues, "S_ANIMATION", "each animation must be an object")
            continue
        name, direction = entry.get("name"), entry.get("direction")
        if not isinstance(name, str) or not name or not isinstance(direction, str) or not direction:
            _problem(issues, "S_ANIMATION", "name and direction must be nonempty strings")
            continue
        key = name, direction
        if key in seen:
            _problem(issues, "S_ANIMATION", f"duplicate animation/direction: {key}")
        seen.add(key)
        paths = entry.get("frame_paths")
        expected = entry.get("expected_frames")
        if not isinstance(paths, list) or not paths or any(not isinstance(p, str) for p in paths):
            _problem(issues, "S_FRAMES", f"{key}: nonempty frame_paths string array required")
            continue
        if type(expected) is not int or expected < 1 or len(paths) != expected:
            _problem(issues, "S_NATIVE_COUNT", f"{key}: expected_frames must match actual paths")
        if len(set(paths)) != len(paths):
            _problem(issues, "S_DUP_PATH", f"{key}: repeated file paths")
        previous: Image.Image | None = None
        require_distinct = entry.get("require_distinct_adjacent", False)
        if type(require_distinct) is not bool:
            _problem(issues, "S_CONFIG", f"{key}: require_distinct_adjacent must be boolean")
            require_distinct = False
        for index, raw in enumerate(paths):
            image = _read_image(root, raw, issues, "S_SOURCE")
            if image is None:
                continue
            if dims and image.size != dims:
                _problem(issues, "S_DIMENSIONS", f"{key}[{index}] {image.size} != {dims}")
            alpha = image.getchannel("A")
            if alpha.getbbox() is None:
                _problem(issues, "S_EMPTY", f"{key}[{index}] has no visible pixels")
            if data.get("require_binary_alpha") is True:
                if any(0 < a < 255 for count, a in enumerate(alpha.getdata()) if 0 < a < 255):
                    _problem(issues, "S_ALPHA", f"{key}[{index}] non-binary alpha")
            if require_distinct and previous is not None and previous.size == image.size:
                if ImageChops.difference(previous, image).getbbox() is None:
                    _problem(issues, "S_DUP_FRAME", f"{key}[{index}] identical to prior frame")
            previous = image


def _validate_map(data: dict, root: Path, issues: list[dict[str, str]]) -> None:
    canvas = _dimensions(data.get("canvas"), issues, "M_CANVAS")
    if canvas is None:
        return
    tile = (data.get("canvas") or {}).get("tile_px")
    if type(tile) is not int or tile <= 0 or canvas[0] % tile or canvas[1] % tile:
        _problem(issues, "M_GRID", "tile_px must divide canvas width/height")
        return

    declared_hash = data.get("master_sha256")
    if not isinstance(declared_hash, str) or len(declared_hash) != 64:
        _problem(issues, "M_SOURCE_SHA", "64-char master_sha256 is required")

    layers = data.get("layers")
    if not isinstance(layers, dict):
        _problem(issues, "M_LAYERS", "four-layer mapping required")
        return
    images: dict[str, Image.Image] = {}
    for key in MAP_LAYERS:
        filename = layers.get(key)
        if not isinstance(filename, str):
            _problem(issues, "M_LAYER", f"missing layer {key}")
            continue
        image = _read_image(root, filename, issues, f"M_LAYER_{key}")
        if image is not None:
            images[key] = image
            if image.size != canvas:
                _problem(issues, "M_DIMENSIONS", f"{key}: {image.size} != {canvas}")
    if "runtime_full_ground" in images and isinstance(layers.get("runtime_full_ground"), str):
        try:
            actual = _sha(_within(root, layers["runtime_full_ground"]))
            if actual != declared_hash:
                _problem(issues, "M_SOURCE_SHA", "runtime full ground bytes differ from locked master SHA")
        except (OSError, ValueError) as exc:
            _problem(issues, "M_SOURCE_SHA", str(exc))

    if len(images) == len(MAP_LAYERS) and all(im.size == canvas for im in images.values()):
        master = images["runtime_full_ground"]
        if master.getchannel("A").getextrema() != (255, 255):
            _problem(issues, "M_MASTER_ALPHA", "runtime full ground must be opaque")
        for layer in ("authoring_complete_par", "runtime_occlusion_par"):
            candidate = images[layer]
            mismatches = sum(
                1
                for src, over in zip(master.getdata(), candidate.getdata())
                if over[3] and src[:3] != over[:3]
            )
            if mismatches:
                _problem(issues, "M_SOURCE_RGB", f"{layer}: {mismatches} non-source-registered RGB pixels")
        combined = Image.alpha_composite(images["authoring_ground_only"], images["authoring_complete_par"])
        if ImageChops.difference(combined.convert("RGB"), master.convert("RGB")).getbbox() is not None:
            _problem(issues, "M_AUTHOR_RECOMPOSE", "authoring GroundOnly+CompletePAR != full master RGB")
        if ImageChops.difference(
            Image.alpha_composite(master, images["runtime_occlusion_par"]).convert("RGB"),
            master.convert("RGB"),
        ).getbbox() is not None:
            _problem(issues, "M_RUNTIME_RECOMPOSE", "runtime overlay modifies master RGB")

    collision = data.get("collision")
    gx, gy = canvas[0] // tile, canvas[1] // tile
    if not isinstance(collision, dict):
        _problem(issues, "M_COLLISION", "collision object is mandatory")
        return
    grid = collision.get("walkable")
    if not isinstance(grid, list) or len(grid) != gy or any(
        not isinstance(row, list)
        or len(row) != gx
        or any(type(val) is not int or val not in (0, 1) for val in row)
        for row in grid
    ):
        _problem(issues, "M_COLLISION", f"walkable grid must be {gy} rows x {gx} columns of 0 or 1")
        return

    def valid_point(raw: Any) -> bool:
        return (
            isinstance(raw, list)
            and len(raw) == 2
            and all(type(x) is int for x in raw)
            and 0 <= raw[0] < gx
            and 0 <= raw[1] < gy
            and grid[raw[1]][raw[0]] == 1
        )

    spawn, goal = collision.get("spawn"), collision.get("goal")
    if not valid_point(spawn):
        _problem(issues, "M_SPAWN", "spawn must be a walkable in-bounds grid cell")
        return
    if goal is not None:
        if not valid_point(goal):
            _problem(issues, "M_GOAL", "goal must be a walkable in-bounds grid cell")
            return
        queue: deque[tuple[int, int]] = deque([(spawn[0], spawn[1])])
        visited = {(spawn[0], spawn[1])}
        target = goal[0], goal[1]
        while queue:
            x, y = queue.popleft()
            for a, b in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
                if 0 <= a < gx and 0 <= b < gy and grid[b][a] and (a, b) not in visited:
                    visited.add((a, b))
                    queue.append((a, b))
        if target not in visited:
            _problem(issues, "M_REACHABILITY", "goal unreachable from spawn")


def validate_manifest_file(path: str | Path, root: str | Path | None = None) -> dict[str, Any]:
    p = Path(path).resolve()
    source_root = Path(root).resolve() if root is not None else p.parent
    issues: list[dict[str, str]] = []
    try:
        data = json.loads(p.read_text("utf-8"))
        if not isinstance(data, dict):
            raise ValueError("manifest must be JSON object")
    except (ValueError, OSError, UnicodeError) as exc:
        _problem(issues, "MANIFEST", str(exc))
        return {"status": "FAIL", "artifact": str(p.name), "issues": issues}
    if data.get("schema") != SCHEMA:
        _problem(issues, "SCHEMA", f"schema must be {SCHEMA}")
    if not isinstance(data.get("asset_id"), str) or not data["asset_id"]:
        _problem(issues, "ASSET_ID", "nonempty asset_id required")
    kind = data.get("kind")
    if kind == "sprite":
        _validate_sprite(data, source_root, issues)
    elif kind == "map":
        _validate_map(data, source_root, issues)
    else:
        _problem(issues, "KIND", "kind must be sprite or map")
    return {
        "status": "FAIL" if issues else "PASS_STATIC_ONLY",
        "artifact": str(p.name),
        "kind": kind,
        "issues": issues,
        "native_vx": "NOT_RUN",
        "user_art": "PENDING",
        "formal_seal": "NO",
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Fail-closed static QA (not a VX engine test)")
    parser.add_argument("manifest", type=Path)
    parser.add_argument("--root", type=Path, default=None)
    args = parser.parse_args()
    result = validate_manifest_file(args.manifest, args.root)
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0 if result["status"] == "PASS_STATIC_ONLY" else 1


if __name__ == "__main__":
    raise SystemExit(main())
