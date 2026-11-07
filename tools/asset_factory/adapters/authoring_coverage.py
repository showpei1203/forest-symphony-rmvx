"""Quantify Master-first authoring-vs-runtime coverage; no fake semantic ownership claims.

A smaller Runtime PAR mask is normal: not every Authoring PAR pixel should occlude
the actor. This diagnostic measures what remains unregistered, not what to copy.
"""
from __future__ import annotations
from io import BytesIO
from hashlib import sha256
from typing import Sequence
from PIL import Image, ImageChops


class CoverageError(ValueError):
    pass


def _rgba(data: bytes, label: str) -> Image.Image:
    if not isinstance(data, bytes) or not data:
        raise CoverageError(f"{label}: PNG bytes missing")
    try:
        with Image.open(BytesIO(data)) as im:
            if im.format != "PNG":
                raise CoverageError(f"{label}: PNG required")
            return im.convert("RGBA")
    except (OSError, ValueError) as exc:
        raise CoverageError(f"{label}: unreadable PNG: {exc}") from exc


def _support(mask: Image.Image) -> Image.Image:
    return mask.point(lambda x: 255 if x else 0)


def _count(mask: Image.Image) -> int:
    return mask.histogram()[255]


def audit_authoring_runtime_gap(
    master_png: bytes,
    authoring_complete_par_png: bytes,
    runtime_par_png: bytes,
    master_sha256: str,
    collision_blocked: Sequence[Sequence[int]] | None = None,
) -> dict:
    """Measure source-registered scope without promoting art, source owners or VX.

    If collision is given, only tabulate alpha on draft walkable tiles.
    This does NOT infer correct occlusion or the source identity of any pixel.
    """
    if sha256(master_png).hexdigest() != master_sha256:
        raise CoverageError("frozen Master SHA256 mismatch")
    m = _rgba(master_png, "Master")
    author = _rgba(authoring_complete_par_png, "Authoring CompletePAR")
    run = _rgba(runtime_par_png, "Runtime PAR")
    if m.size != author.size or m.size != run.size or m.size[0] % 32 or m.size[1] % 32:
        raise CoverageError("all layers must use same 32px-aligned Master canvas")
    w, h = m.size
    if m.getchannel("A").getextrema() != (255, 255):
        raise CoverageError("Master must have solid alpha")
    a, r = _support(author.getchannel("A")), _support(run.getchannel("A"))
    # Real runtime visual must be sourced from Master same world XY, no repaint.
    for layer, support, label in ((author, a, "Authoring"), (run, r, "Runtime")):
        d = ImageChops.difference(m.convert("RGB"), layer.convert("RGB"))
        rgb_support = Image.merge("RGB", (support, support, support))
        if ImageChops.multiply(d, rgb_support).getbbox():
            raise CoverageError(f"{label} RGB not registered with Master")
    outside = ImageChops.subtract(r, a)
    if outside.getbbox():
        raise CoverageError("Runtime PAR alpha outside Authoring CompletePAR source")
    only_author = ImageChops.subtract(a, r)
    both = ImageChops.multiply(a, r)
    tiles_x, tiles_y = w // 32, h // 32
    if collision_blocked is not None:
        if len(collision_blocked) != tiles_y or any(len(row) != tiles_x for row in collision_blocked):
            raise CoverageError("collision grid does not match canvas")
        if any(v not in (0, 1) for row in collision_blocked for v in row):
            raise CoverageError("collision grid must be binary draft only")
    unregistered_walkable = 0
    unregistered_tiles = 0
    hotspots = []
    for y in range(tiles_y):
        for x in range(tiles_x):
            n = _count(only_author.crop((32*x, 32*y, 32*(x+1), 32*(y+1))))
            if n:
                unregistered_tiles += 1
                walkable = collision_blocked is not None and collision_blocked[y][x] == 0
                if walkable:
                    unregistered_walkable += n
                hotspots.append((n, x, y, walkable))
    hotspots.sort(reverse=True)
    return {
        "schema": "fs-authoring-runtime-gap/v1",
        "status": "PASS_SOURCE_GEOMETRY_ONLY",
        "master_sha256": master_sha256,
        "authoring_sha256": sha256(authoring_complete_par_png).hexdigest(),
        "runtime_sha256": sha256(runtime_par_png).hexdigest(),
        "canvas": list(m.size),
        "authoring_alpha_pixels": _count(a),
        "runtime_alpha_pixels": _count(r),
        "runtime_inside_authoring_pixels": _count(both),
        "authoring_only_alpha_pixels": _count(only_author),
        "authoring_only_tiles": unregistered_tiles,
        "authoring_only_alpha_on_draft_walkable_tiles": unregistered_walkable if collision_blocked is not None else None,
        "hotspots": [
            {"tile": [x,y], "authoring_only_pixels": n,
             "draft_walkable": b if collision_blocked is not None else None}
            for n,x,y,b in hotspots[:20]
        ],
        "authoring_object_source_inventory": "NOT_VERIFIED",
        "runtime_occlusion_semantics": "NOT_TESTED",
        "native_vx": "NOT_RUN",
        "user_art": "PENDING",
        "formal_seal": "NO",
    }
