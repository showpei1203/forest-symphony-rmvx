"""Lossless-in-pixel-space PMD native atlas patch compiler. Memory-only.

No rotations, resampling, fabricated directions, duration rewrite or auto PixelLab calls.
An accepted 45-degree sprite is NOT eight-direction art. Output remains a candidate.
"""
from __future__ import annotations

import hashlib
from io import BytesIO
from typing import Mapping

from PIL import Image

from tools.asset_factory.adapters.pmd import (
    PMDContractError, inspect_pmd_assets,
)


class NativeExportError(ValueError):
    """Refuse an unsafe or incomplete native PMD patch."""


def _png(payload: bytes, label: str) -> Image.Image:
    try:
        with Image.open(BytesIO(payload)) as im:
            if im.format != "PNG":
                raise NativeExportError(f"{label}: PNG required")
            return im.convert("RGBA")
    except (ValueError, OSError) as exc:
        raise NativeExportError(f"{label}: unreadable native PNG {exc}") from exc


def compile_native_action(
    xml_bytes: bytes,
    native_pngs: Mapping[str, bytes],
    source_shas: Mapping[str, str],
    action: str,
    direction_rows: Mapping[int, Mapping[str, list[bytes]]],
) -> dict:
    """Patch approved per-frame art into real XML-sized native sheets.

    direction_rows: {actual_native_row_index: {'Anim':[PNG...],
                                              'Offsets':[PNG...],
                                              'Shadow':[PNG...]}}
    Existing untargeted rows are preserved pixel-exactly; other actions untouched.
    Caller must separately certify camera, identity, lighting and animation.
    """
    if not isinstance(source_shas, Mapping) or not isinstance(native_pngs, Mapping):
        raise NativeExportError("source inventory required")
    if set(native_pngs) != set(source_shas):
        raise NativeExportError("every native input must have SHA256 lock")
    if not isinstance(direction_rows, Mapping) or not direction_rows:
        raise NativeExportError("at least one explicit native direction row required")
    for key, data in native_pngs.items():
        actual = hashlib.sha256(data).hexdigest()
        if source_shas.get(key) != actual:
            raise NativeExportError(f"{key}: source hash mismatch")

    try:
        contract = inspect_pmd_assets(xml_bytes, native_pngs)
    except PMDContractError as exc:
        raise NativeExportError(f"native source is invalid: {exc}") from exc
    actions = contract["actions"]
    if action not in actions or "copy_of" in actions[action]:
        raise NativeExportError("action missing or is an XML CopyOf alias")
    spec = actions[action]
    fcount, fw, fh = spec["frame_count"], spec["frame_width"], spec["frame_height"]
    rows = contract["sheets"][action]["rows"]
    edited = {s: _png(native_pngs[f"{action}-{s}.png"], s) for s in ("Anim", "Offsets", "Shadow")}
    source = {s: im.copy() for s, im in edited.items()}
    changed_rows = sorted(direction_rows)
    if any(type(i) is not int or not 0 <= i < rows for i in changed_rows):
        raise NativeExportError("invalid native row index; no inferred direction order")
    for row in changed_rows:
        supplied = direction_rows[row]
        if not isinstance(supplied, Mapping) or set(supplied) != {"Anim", "Offsets", "Shadow"}:
            raise NativeExportError("must supply source-matched Anim, Offsets, Shadow for every patch")
        for suffix in ("Anim", "Offsets", "Shadow"):
            frames = supplied[suffix]
            if not isinstance(frames, list) or len(frames) != fcount:
                raise NativeExportError(f"{action}/{row}/{suffix}: XML frame count mismatch")
            for index, data in enumerate(frames):
                image = _png(data, f"{action}/{row}/{suffix}/{index}")
                if image.size != (fw, fh):
                    raise NativeExportError(f"{action}/{row}/{suffix}/{index}: XML cell dimensions mismatch")
                edited[suffix].paste(image, (index * fw, row * fh))
    # Prove no edit outside submitted exact row areas, each sheet separately.
    for suffix, before in source.items():
        after = edited[suffix]
        for row in range(rows):
            if row in changed_rows:
                continue
            bounds = (0, row * fh, fcount * fw, (row + 1) * fh)
            if before.crop(bounds).tobytes() != after.crop(bounds).tobytes():
                raise NativeExportError(f"{suffix}: unmodified native row was touched")
    encoded = {}
    for suffix, im in edited.items():
        b = BytesIO()
        im.save(b, format="PNG")
        encoded[f"{action}-{suffix}.png"] = b.getvalue()
    result_pngs = dict(native_pngs)
    result_pngs.update(encoded)
    try:
        inspect_pmd_assets(xml_bytes, result_pngs)
    except PMDContractError as exc:
        raise NativeExportError(f"compiled native atlas fails: {exc}") from exc

    changed = sorted(direction_rows)
    return {
        "status": "PASS_NATIVE_ATLAS_STATIC_ONLY",
        "native_action": action,
        "frame_cell": [fw, fh],
        "frames_per_row": fcount,
        "source_xml_sha256": contract["xml_sha256"],
        "patched_native_row_indices": changed,
        "untouched_native_row_indices": [i for i in range(rows) if i not in changed],
        "complete_eight_direction_art": "NOT_CERTIFIED",
        "direction_camera_identity": "PENDING",
        "native_game_exe": "NOT_RUN",
        "user_art": "PENDING",
        "formal_seal": "NO",
        "compiled_pngs": encoded,
        "compiled_sha256": {k: hashlib.sha256(v).hexdigest() for k, v in encoded.items()},
    }
