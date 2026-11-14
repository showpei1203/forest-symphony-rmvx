"""Fail-closed translation of ASF's three registered pixel-motion frames into FS Actor SBS.

- F0 is exactly the approved source. Never take a provider-redrawn F0 as canon.
- Forge frames are moved on a single immutable root, no resampling, recolour or scale.
- Distinct motion and palette/alpha checks are mechanical only: user art and VX remain HOLD.
- This module does not call a model, fetch keys, publish art, or touch original files.
"""
from __future__ import annotations

import hashlib
import io
import math
from typing import Sequence

from PIL import Image

NATIVE_SIZE = (48, 48)
SHEET_SIZE = (144, 48)


class ASFActorContractError(ValueError):
    """A proposed source/animation is not safe to put into a native candidate."""


def _rgba(data: bytes, label: str) -> Image.Image:
    try:
        with Image.open(io.BytesIO(data)) as im:
            if im.format != "PNG":
                raise ASFActorContractError(f"{label}: PNG required")
            image = im.convert("RGBA")
    except (OSError, ValueError) as exc:
        raise ASFActorContractError(f"{label}: unreadable PNG: {exc}") from exc
    if any(px[3] not in (0, 255) for px in image.getdata()):
        raise ASFActorContractError(f"{label}: alpha must be binary")
    return image


def _anchor(position: Sequence[float], label: str) -> tuple[float, float]:
    if len(position) != 2 or not all(
        isinstance(v, (float, int)) and not isinstance(v, bool) and math.isfinite(v)
        for v in position
    ):
        raise ASFActorContractError(f"{label}: finite x,y required")
    return float(position[0]), float(position[1])


def _translated_frame(image: Image.Image, offset: tuple[int, int]) -> Image.Image:
    x, y = offset
    box = image.getchannel("A").getbbox()
    if not box:
        raise ASFActorContractError("no actor on source frame")
    # Only the real actor silhouette may be inside the FS 48x48 canvas.
    if not (0 <= x + box[0] < x + box[2] <= 48
            and 0 <= y + box[1] < y + box[3] <= 48):
        raise ASFActorContractError("actor visible pixels would be cropped by native 48x48")
    native = Image.new("RGBA", NATIVE_SIZE, (0, 0, 0, 0))
    native.paste(image, (x, y))
    return native


def compile_asf_actor_three_frame(
    approved_f0_png: bytes,
    approved_f0_sha256: str,
    forge_pngs: Sequence[bytes],
    *,
    forge_anchor: Sequence[float],
    native_source_anchor: Sequence[float],
    action: str = "RUN",
    minimum_distinct_pixels: int = 8,
) -> dict:
    if action not in ("RUN", "WAITING"):
        raise ASFActorContractError("only independently reviewed RUN and WAITING contracts are supported")
    if hashlib.sha256(approved_f0_png).hexdigest() != approved_f0_sha256:
        raise ASFActorContractError("approved F0 SHA mismatch; forbid invisible source substitution")
    base = _rgba(approved_f0_png, "approved F0")
    if base.size != NATIVE_SIZE:
        raise ASFActorContractError("approved F0 must be 48x48")
    if len(forge_pngs) != 3:
        raise ASFActorContractError("exactly three provider frames are required; no reusing key poses")
    native_root = _anchor(native_source_anchor, "original native root")
    forge_root = _anchor(forge_anchor, "ASF registered root")
    dx, dy = native_root[0] - forge_root[0], native_root[1] - forge_root[1]
    if abs(dx - round(dx)) > 0.001 or abs(dy - round(dy)) > 0.001:
        raise ASFActorContractError("non-integer anchor translation would blur pixel grid")
    offset = (round(dx), round(dy))
    palette = {p[:3] for p in base.getdata() if p[3] == 255}

    # Index 0 from the model is read/checked, but never becomes the approved F0.
    converted = []
    for i, data in enumerate(forge_pngs):
        source = _rgba(data, f"ASF frame {i}")
        if source.size[0] > 48 or source.size[1] > 48:
            raise ASFActorContractError("ASF frame too large; no downscale permission")
        view = _translated_frame(source, offset)
        colours = {p[:3] for p in view.getdata() if p[3] == 255}
        if not colours.issubset(palette):
            raise ASFActorContractError(f"ASF frame {i}: outside approved F0 palette")
        converted.append(view)

    # Actor sheet's F0 is source-exact, even if the model's first frame drifted.
    frames = [base, converted[1], converted[2]]
    raw = [im.tobytes() for im in frames]
    changed = []
    for i in (1, 2):
        lhs, rhs = frames[0], frames[i]
        diff_count = sum(1 for a, b in zip(lhs.getdata(), rhs.getdata()) if a != b)
        changed.append(diff_count)
        if diff_count < minimum_distinct_pixels:
            raise ASFActorContractError(f"F{i} has no meaningful distinct motion: {diff_count} pixels")
    between = sum(1 for a, b in zip(frames[1].getdata(), frames[2].getdata()) if a != b)
    if between < minimum_distinct_pixels:
        raise ASFActorContractError("F1/F2 are duplicates or nearly identical")

    sheet = Image.new("RGBA", SHEET_SIZE, (0, 0, 0, 0))
    for i, frame in enumerate(frames):
        sheet.paste(frame, (i * 48, 0))
    encoded = io.BytesIO()
    sheet.save(encoded, format="PNG")
    return {
        "status": "STATIC_NATIVE_FORMAT_PASS_ONLY",
        "new_art_provider_verified": False,
        "original_f0_bytes_unchanged_in_sheet": True,
        "frame0_exact": raw[0] == base.tobytes(),
        "frame_count": 3,
        "frame_size": [48, 48],
        "native_sheet": [144, 48],
        "translation": list(offset),
        "difference_from_f0": changed,
        "difference_f1_vs_f2": between,
        "source_sha256": approved_f0_sha256,
        "native_sheet_png": encoded.getvalue(),
        "user_art": "NOT_RUN",
        "camera_angle": "NEEDS_VISUAL_REVIEW",
        "leg_counterphase": "NEEDS_VISUAL_REVIEW",
        "vx_game_exe": "NOT_RUN",
        "formal_seal": "NO",
    }
