"""PMD native AnimData.xml adapter. Parses each species' actual contract; no images bundled."""
from __future__ import annotations

import hashlib
from io import BytesIO
import re
import xml.etree.ElementTree as ET
from typing import Mapping

from PIL import Image


class PMDContractError(ValueError):
    """Unsafe, incomplete, or contradictory native PMD source."""


def _positive_int(text: str | None, label: str) -> int:
    try:
        value = int(text) if text is not None else 0
    except (ValueError, TypeError):
        raise PMDContractError(f"{label}: integer required") from None
    if not 1 <= value <= 16384:
        raise PMDContractError(f"{label}: positive integer <=16384 required")
    return value


def _nonnegative_int(text: str | None, label: str) -> int:
    try:
        value = int(text) if text is not None else -1
    except (ValueError, TypeError):
        raise PMDContractError(f"{label}: integer required") from None
    if not 0 <= value <= 16384:
        raise PMDContractError(f"{label}: nonnegative integer <=16384 required")
    return value


def inspect_pmd_xml(xml_bytes: bytes) -> dict:
    """Inspect original XML bytes; CopyOf actions are aliases, never invented atlases."""
    if not isinstance(xml_bytes, bytes) or not 0 < len(xml_bytes) <= 4_000_000:
        raise PMDContractError("XML bytes missing or too large")
    if re.search(br"<!\s*(?:DOCTYPE|ENTITY)\b", xml_bytes, re.I):
        raise PMDContractError("DTD/entities forbidden")
    try:
        root = ET.fromstring(xml_bytes)
    except ET.ParseError as exc:
        raise PMDContractError(f"malformed XML: {exc}") from exc
    if root.tag != "AnimData" or root.find("Anims") is None:
        raise PMDContractError("root AnimData/Anims required")
    shadow_size = _positive_int(root.findtext("ShadowSize"), "ShadowSize")
    actions: dict[str, dict] = {}
    indices: set[int] = set()
    for item in root.findall("./Anims/Anim"):
        name = item.findtext("Name")
        if not name or not re.fullmatch(r"[A-Za-z][A-Za-z0-9_]*", name) or name in actions:
            raise PMDContractError("missing, duplicate, or unsafe action Name")
        alias = item.findtext("CopyOf")
        if alias:
            if item.find("Durations") is not None:
                raise PMDContractError(f"{name}: alias may not define own durations")
            actions[name] = {"copy_of": alias}
            continue
        width = _positive_int(item.findtext("FrameWidth"), f"{name}.FrameWidth")
        height = _positive_int(item.findtext("FrameHeight"), f"{name}.FrameHeight")
        index = _nonnegative_int(item.findtext("Index"), f"{name}.Index")
        if index in indices:
            raise PMDContractError(f"{name}: duplicate action Index")
        indices.add(index)
        durations = [_positive_int(d.text, f"{name}.Duration") for d in item.findall("./Durations/Duration")]
        if not durations:
            raise PMDContractError(f"{name}: no durations")
        frames = {}
        for tag in ("RushFrame", "HitFrame", "ReturnFrame"):
            raw = item.findtext(tag)
            if raw is not None:
                point = _nonnegative_int(raw, f"{name}.{tag}")
                if point >= len(durations):
                    raise PMDContractError(f"{name}.{tag}: out of frame range")
                frames[tag] = point
        actions[name] = {
            "index": index, "frame_width": width, "frame_height": height,
            "frame_count": len(durations), "durations": durations,
            "events": frames,
        }
    if not actions or not any("copy_of" not in a for a in actions.values()):
        raise PMDContractError("no concrete actions")
    for name, spec in actions.items():
        seen = {name}
        cur = spec
        while "copy_of" in cur:
            target = cur["copy_of"]
            if target in seen or target not in actions:
                raise PMDContractError(f"{name}: invalid/cyclic CopyOf target")
            seen.add(target)
            cur = actions[target]
    return {
        "schema": "pmd-native-inspection/v1",
        "xml_sha256": hashlib.sha256(xml_bytes).hexdigest(),
        "shadow_size": shadow_size,
        "actions": actions,
    }


def inspect_pmd_assets(xml_bytes: bytes, png_bytes: Mapping[str, bytes]) -> dict:
    """Require original -Anim/-Offsets/-Shadow pairs and 1 or 8 raster rows.

    Byte mapping keys: Walk-Anim.png, Walk-Offsets.png, Walk-Shadow.png...
    This static inspection does NOT certify directions or live game behavior.
    """
    inspection = inspect_pmd_xml(xml_bytes)
    sheets: dict[str, dict] = {}
    for name, spec in inspection["actions"].items():
        if "copy_of" in spec:
            continue
        width = spec["frame_width"] * spec["frame_count"]
        actual_sizes = {}
        for suffix in ("Anim", "Offsets", "Shadow"):
            filename = f"{name}-{suffix}.png"
            if filename not in png_bytes:
                raise PMDContractError(f"{filename}: missing native PNG")
            payload = png_bytes[filename]
            try:
                with Image.open(BytesIO(payload)) as im:
                    if im.format != "PNG":
                        raise PMDContractError(f"{filename}: not PNG")
                    w, h = im.size
            except (OSError, ValueError) as exc:
                raise PMDContractError(f"{filename}: invalid image {exc}") from exc
            if w != width or h % spec["frame_height"]:
                raise PMDContractError(f"{filename}: invalid native atlas geometry {(w, h)}")
            rows = h // spec["frame_height"]
            if rows not in (1, 8):
                raise PMDContractError(f"{filename}: expected native 1 or 8 rows, got {rows}")
            actual_sizes[suffix] = (w, h)
        if len(set(actual_sizes.values())) != 1:
            raise PMDContractError(f"{name}: Anim/Offsets/Shadow geometry mismatch")
        sheets[name] = {
            "rows": actual_sizes["Anim"][1] // spec["frame_height"],
            "atlas_size": list(actual_sizes["Anim"]),
        }
    inspection["sheets"] = sheets
    inspection["status"] = "PASS_STATIC_ONLY"
    inspection["native_vx"] = "NOT_RUN"
    inspection["user_art"] = "PENDING"
    inspection["formal_seal"] = "NO"
    return inspection
