"""FS A27: source-locked, actor-silhouette-aware 2.5D occlusion prototype.

Uses a documented screen-row depth *hint*, not inferred 3D geometry. All PAR
pixels are copied from the same XY coordinates of the unchanged master. The
output is a per-actor Pillow preview, NOT an RPG Maker VX runtime integration.

Private image inputs/outputs belong in owner-only Drive, never in public GitHub.
"""
from __future__ import annotations

from dataclasses import dataclass
import hashlib
import io
from typing import Iterable

import numpy as np
from PIL import Image

ALLOWED = frozenset({"tree_canopy", "roof_front_eave", "bridge_near_rail", "cliff_top"})
FORBIDDEN = frozenset({"grass", "flower", "path", "bridge_deck", "water", "low_vegetation", "shadow", "ground"})

class A27Error(ValueError):
    """Fail-closed source, ownership, or depth geometry validation."""

@dataclass(frozen=True)
class DepthOwner:
    object_id: str
    semantic: str
    mask_png: bytes
    mask_sha256: str
    x_min: int
    x_max: int
    far_foot_y: int  # foot Y below this => the entire object's mask is in front
    near_foot_y: int # foot Y at/above this can still occlude its nearest pixels
    source_label: str


def _png(data: bytes, label: str) -> Image.Image:
    try:
        with Image.open(io.BytesIO(data)) as image:
            if image.format != "PNG":
                raise A27Error(f"{label}: only PNG accepted")
            return image.copy()
    except (OSError, ValueError) as exc:
        raise A27Error(f"{label}: invalid PNG") from exc


def png_bytes(image: Image.Image) -> bytes:
    out = io.BytesIO()
    image.save(out, format="PNG", optimize=False)
    return out.getvalue()


def _mask_bytes(data: bytes, expected_sha: str, size: tuple[int, int], label: str) -> np.ndarray:
    if len(expected_sha) != 64 or hashlib.sha256(data).hexdigest() != expected_sha:
        raise A27Error(f"{label}: SHA mismatch")
    image = _png(data, label)
    if image.mode not in ("L", "RGBA") or image.size != size:
        raise A27Error(f"{label}: full-canvas L/RGBA mask required")
    values = np.asarray(image if image.mode == "L" else image.getchannel("A"))
    if not np.isin(values, [0,255]).all() or not np.any(values == 255):
        raise A27Error(f"{label}: non-empty binary mask required")
    return values == 255


def render_actor_case(
    master_png: bytes,
    master_sha256: str,
    actor_png: bytes,
    actor_top_left: tuple[int, int],
    actor_foot: tuple[int, int],
    objects: Iterable[DepthOwner],
    *,
    negative_mask_png: bytes | None = None,
) -> tuple[bytes, bytes, bytes, dict]:
    """Return byte-identical full Ground, same-XY PAR, Pillow preview, QA.

    Projection model: for a masked source pixel at Y, its actor-foot occlusion
    limit increases linearly from far_foot_y at the mask's top edge to
    near_foot_y at its bottom edge. The model is an explicit ART-PENDING hint.
    It is intentionally conservative about mask ownership and source purity.
    """
    if len(master_sha256) != 64 or hashlib.sha256(master_png).hexdigest() != master_sha256:
        raise A27Error("Master SHA mismatch")
    src = _png(master_png, "Master")
    master = src.convert("RGBA")
    w, h = master.size
    if w % 32 or h % 32 or master.getchannel("A").getextrema() != (255, 255):
        raise A27Error("Master must be opaque and 32px-world-grid aligned")
    actor = _png(actor_png, "Actor").convert("RGBA")
    ax, ay = actor_top_left
    fx, fy = actor_foot
    if not all(type(t) is int for t in (ax, ay, fx, fy)):
        raise A27Error("Actor geometry must use integer world pixel coordinates")
    aw, ah = actor.size
    if aw < 1 or ah < 1 or ax < 0 or ay < 0 or ax + aw > w or ay + ah > h:
        raise A27Error("Actor sprite must be fully within Master")
    if not ax <= fx < ax + aw or not ay <= fy < ay + ah:
        raise A27Error("Actor foot must be within actor bounds")
    alpha = np.asarray(actor.getchannel("A")) > 0
    if not alpha.any():
        raise A27Error("Actor has no opaque pixels")
    actor_world = np.zeros((h, w), dtype=bool)
    actor_world[ay:ay+ah, ax:ax+aw] = alpha

    owners = list(objects)
    if not owners or len({o.object_id for o in owners}) != len(owners):
        raise A27Error("Unique nonempty object ownership required")
    used = np.zeros((h, w), dtype=bool)
    par = np.zeros((h, w), dtype=bool)
    per_owner = []
    yy = np.arange(h, dtype=np.float64)[:, None]
    banned = None
    if negative_mask_png is not None:
        negative_img = _png(negative_mask_png, "negative zone")
        if negative_img.size != (w, h) or negative_img.mode not in ("L", "RGBA"):
            raise A27Error("negative zone: full canvas mask required")
        negative_array = np.asarray(negative_img if negative_img.mode == "L" else negative_img.getchannel("A"))
        if not np.isin(negative_array, [0, 255]).all():
            raise A27Error("negative zone must use binary 0/255")
        banned = negative_array > 0
    for obj in owners:
        if not obj.object_id or obj.semantic not in ALLOWED or obj.semantic in FORBIDDEN:
            raise A27Error(f"{obj.object_id}: unsafe semantic")
        if not obj.source_label:
            raise A27Error(f"{obj.object_id}: missing source provenance")
        if not (0 <= obj.x_min < obj.x_max <= w and
                0 <= obj.far_foot_y <= obj.near_foot_y <= h):
            raise A27Error(f"{obj.object_id}: unsafe geometry")
        owner = _mask_bytes(obj.mask_png, obj.mask_sha256, (w, h), obj.object_id)
        ys, xs = np.where(owner)
        if np.any(xs < obj.x_min) or np.any(xs >= obj.x_max):
            raise A27Error(f"{obj.object_id}: mask extends beyond declared x span")
        if np.any(owner & used):
            raise A27Error(f"{obj.object_id}: ownership overlap")
        if banned is not None and np.any(owner & banned):
            raise A27Error(f"{obj.object_id}: mask includes forbidden ground/deck")
        used |= owner
        top, bottom = int(ys.min()), int(ys.max())
        fraction = np.clip((yy - top) / max(1, bottom - top), 0.0, 1.0)
        per_pixel_threshold = obj.far_foot_y + (obj.near_foot_y - obj.far_foot_y) * fraction
        visible_in_front = owner & actor_world & (fy < per_pixel_threshold)
        par |= visible_in_front
        per_owner.append({"object_id":obj.object_id, "semantic":obj.semantic,
                          "source_label":obj.source_label,"mask_pixels":int(owner.sum()),
                          "actor_overlap_pixels":int((owner & actor_world).sum()),
                          "occlusion_pixels":int(visible_in_front.sum()),
                          "mask_y_extent":[top,bottom],
                          "foot_y_limits":[obj.far_foot_y,obj.near_foot_y]})
    source = np.asarray(master)
    par_rgba = np.zeros_like(source)
    par_rgba[par] = source[par]
    par_png = png_bytes(Image.fromarray(par_rgba, "RGBA"))
    preview_img = master.copy()
    preview_img.alpha_composite(actor, dest=(ax, ay))
    preview_img.alpha_composite(Image.fromarray(par_rgba, "RGBA"))
    preview_png = png_bytes(preview_img)
    par_pixels = np.asarray(_png(par_png, "PAR"))
    mismatch = int(np.any(par_pixels[par] != source[par], axis=-1).sum())
    if mismatch:
        raise A27Error("PAR does not contain byte-identical same-XY Master pixels")
    actor_pixels = int(actor_world.sum())
    qa = {
        "schema":"fs-a27-semantic-geometry-depth/v1",
        "status":"TECHNICAL_PREVIEW_ONLY",
        "source_master_sha256":master_sha256,
        "master_ground_bytes_unchanged":True,
        "canvas":[w,h], "actor_top_left":[ax,ay],
        "actor_foot":[fx,fy],"actor_opaque_pixels":actor_pixels,
        "occlusion_pixels":int(par.sum()),
        "occluded_actor_ratio":round(float(par.sum()/actor_pixels),6),
        "par_sha256":hashlib.sha256(par_png).hexdigest(),
        "source_same_xy_rgba_mismatch_pixels":mismatch,
        "owners":per_owner,
        "model":"linear_screen_row_depth_hint_not_inferred_3d",
        "art_result":"HOLD", "native_vx":"NOT_RUN", "switch203":"NOT_RUN",
        "formal_seal":"NO",
    }
    return master_png, par_png, preview_png, qa
