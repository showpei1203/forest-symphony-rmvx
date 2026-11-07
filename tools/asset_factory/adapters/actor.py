"""FS battle Actor _1/_2/_3 keyframe contract, separate from RPG VX walk sheet."""
from __future__ import annotations
from io import BytesIO
import hashlib
import re
from typing import Mapping
from PIL import Image


class ActorContractError(ValueError):
    pass


def inspect_actor_action(
    asset_id: str,
    action: str,
    frame_bytes: Mapping[str, bytes],
    frame_size: tuple[int, int],
    source_sha256: str,
    playback: tuple[int, ...],
) -> dict:
    """Check export geometry and loop order, not semantic footsteps or native Tankentai."""
    if not re.fullmatch(r"[A-Za-z0-9_-]{1,80}", asset_id):
        raise ActorContractError("unsafe asset_id")
    if not re.fullmatch(r"[A-Za-z][A-Za-z0-9_]{0,60}", action):
        raise ActorContractError("unsafe action")
    if not isinstance(source_sha256, str) or not re.fullmatch(r"[0-9a-f]{64}", source_sha256):
        raise ActorContractError("approved source SHA256 required")
    if (not isinstance(frame_size, tuple) or len(frame_size) != 2 or
            any(type(d) is not int or not 1 <= d <= 512 for d in frame_size)):
        raise ActorContractError("explicit positive frame dimensions required")
    if not isinstance(playback, tuple) or len(playback) < 3 or any(type(i) is not int or i not in (0, 1, 2) for i in playback):
        raise ActorContractError("playback must use 3 stored frame indexes")
    hashes = []
    for n in (1, 2, 3):
        key = f"{action}_{n}.png"
        if key not in frame_bytes:
            raise ActorContractError(f"{key} missing (exact _1/_2/_3 required)")
        data = frame_bytes[key]
        try:
            with Image.open(BytesIO(data)) as im:
                if im.format != "PNG" or im.mode not in ("RGB", "RGBA") or im.size != frame_size:
                    raise ActorContractError(f"{key}: invalid PNG/mode/geometry")
                rgba = im.convert("RGBA")
                if rgba.getchannel("A").getbbox() is None:
                    raise ActorContractError(f"{key}: blank frame")
                hashes.append(hashlib.sha256(rgba.tobytes()).hexdigest())
        except (OSError, ValueError) as exc:
            raise ActorContractError(f"{key}: image read failed: {exc}") from exc
    if len(set(hashes)) != 3:
        raise ActorContractError("collapsed or duplicated keyframe")
    return {
        "schema": "fs-actor-action/v1", "asset_id": asset_id,
        "action": action, "frame_size": list(frame_size),
        "source_sha256": source_sha256, "playback": list(playback),
        "stored_frames": 3, "status": "PASS_STATIC_ONLY",
        "direction_art": "PENDING", "weapon_anchor": "PENDING",
        "native_vx": "NOT_RUN", "user_art": "PENDING", "formal_seal": "NO",
    }
