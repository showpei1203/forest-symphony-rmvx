"""Object-owned Master-first mask proof, independent of art and native occlusion."""
from __future__ import annotations

import hashlib
from io import BytesIO
import re
from typing import Mapping
from PIL import Image


class ObjectMaskError(ValueError):
    pass


def _image(payload: bytes, label: str) -> Image.Image:
    try:
        with Image.open(BytesIO(payload)) as im:
            if im.format != "PNG":
                raise ObjectMaskError(f"{label}: expected PNG")
            return im.copy()
    except (ValueError, OSError) as exc:
        raise ObjectMaskError(f"{label}: invalid PNG {exc}") from exc


def inspect_object_masks(
    canvas: tuple[int, int],
    complete_par_png: bytes,
    runtime_par_png: bytes,
    objects: list[dict],
    private_sources: Mapping[str, bytes],
    mask_pngs: Mapping[str, bytes],
) -> dict:
    """Fail closed unless every PAR alpha pixel has exactly one object owner.

    All masks are full-canvas binary PNG L/RGBA, same XY as frozen Master.
    private_sources are used only in isolated execution, never public CI.
    """
    if (not isinstance(canvas, tuple) or len(canvas) != 2 or
            any(type(d) is not int or not 1 <= d <= 16384 for d in canvas)):
        raise ObjectMaskError("invalid canvas")
    full = _image(complete_par_png, "complete PAR").convert("RGBA")
    overlay = _image(runtime_par_png, "runtime PAR").convert("RGBA")
    if full.size != canvas or overlay.size != canvas:
        raise ObjectMaskError("PAR canvas mismatch")
    if not isinstance(objects, list) or not objects:
        raise ObjectMaskError("object inventory required")
    complete_expected = bytearray(canvas[0] * canvas[1])
    runtime_expected = bytearray(canvas[0] * canvas[1])
    seen = set()
    for item in objects:
        if not isinstance(item, dict):
            raise ObjectMaskError("object must be a record")
        oid = item.get("id")
        if not isinstance(oid, str) or not re.fullmatch(r"[A-Za-z0-9_-]{1,80}", oid) or oid in seen:
            raise ObjectMaskError("duplicate/unsafe object id")
        seen.add(oid)
        source = item.get("source")
        digest = item.get("source_sha256")
        if source not in private_sources or not isinstance(digest, str) or not re.fullmatch(r"[0-9a-f]{64}", digest):
            raise ObjectMaskError(f"{oid}: private source and SHA required")
        if hashlib.sha256(private_sources[source]).hexdigest() != digest:
            raise ObjectMaskError(f"{oid}: private source SHA mismatch")
        masks = []
        for key in ("complete_mask", "occlusion_mask"):
            name = item.get(key)
            if name not in mask_pngs:
                raise ObjectMaskError(f"{oid}: {key} missing")
            im = _image(mask_pngs[name], key)
            if im.size != canvas or im.mode not in ("L", "RGBA"):
                raise ObjectMaskError(f"{oid}: mask size/mode mismatch")
            values = im.tobytes() if im.mode == "L" else im.getchannel("A").tobytes()
            if set(values) - {0, 255}:
                raise ObjectMaskError(f"{oid}: mask must be binary")
            masks.append(values)
        complete, occ = masks
        if not any(complete):
            raise ObjectMaskError(f"{oid}: empty complete mask")
        for i, (c, o) in enumerate(zip(complete, occ)):
            if o and not c:
                raise ObjectMaskError(f"{oid}: occlusion not subset of owner")
            if c and complete_expected[i]:
                raise ObjectMaskError(f"{oid}: overlapping complete-PAR object ownership")
            if o and runtime_expected[i]:
                raise ObjectMaskError(f"{oid}: overlapping occlusion ownership")
            if c: complete_expected[i] = 255
            if o: runtime_expected[i] = 255
    if bytes(complete_expected) != full.getchannel("A").tobytes():
        raise ObjectMaskError("complete PAR alpha not fully explained by object inventory")
    if bytes(runtime_expected) != overlay.getchannel("A").tobytes():
        raise ObjectMaskError("runtime PAR alpha not fully explained by object inventory")
    return {
        "status": "PASS_STATIC_ONLY", "schema": "fs-master-objects/v1",
        "object_count": len(objects), "source_integrity": "PASS_PRIVATE_BYTES",
        "rgb_registration": "NOT_TESTED_HERE", "occlusion_semantics": "PENDING",
        "native_vx": "NOT_RUN", "user_art": "PENDING", "formal_seal": "NO",
    }
