"""FS A14: approved 48px F0 -> 64px provider guide -> honest output geometry gate.

NO API calls, no payment, no art validation. Private images remain in private
Drive; this module is pure image processing for the later provider result.
"""
from __future__ import annotations

from hashlib import sha256
from PIL import Image
import numpy as np

APPROVED_F0_SHA256 = "a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba"


class FSArtGateError(ValueError):
    pass


def verified_f0(f0_png: bytes) -> Image.Image:
    if sha256(f0_png).hexdigest() != APPROVED_F0_SHA256:
        raise FSArtGateError("A14 input is not the original approved white-haired Actor01 F0")
    from io import BytesIO
    f0 = Image.open(BytesIO(f0_png)).convert("RGBA")
    if f0.size != (48, 48):
        raise FSArtGateError("FS A62 combat cell must be 48x48")
    return f0


def pad_to_provider_64(f0: Image.Image) -> Image.Image:
    if f0.size != (48, 48):
        raise FSArtGateError("source F0 must be exactly 48x48")
    out = Image.new("RGBA", (64, 64))
    out.alpha_composite(f0.convert("RGBA"), (8, 8))
    return out


def coordinates_from_source48(joint_48: tuple[float, float]) -> dict[str, float]:
    x,y=joint_48
    if not (0 <= x < 48 and 0 <= y < 48):
        raise FSArtGateError("joint outside 48px source")
    return {"x": round((x+8)/64, 6), "y": round((y+8)/64, 6)}


def normalize_generated_frame(frame: Image.Image) -> Image.Image:
    if frame.size == (64, 64):
        a=np.asarray(frame.convert("RGBA"))
        outside=np.array(a[:,:,3],copy=True)
        outside[8:56,8:56]=0
        if np.any(outside):
            raise FSArtGateError("provider generated pixels outside original 48px crop")
        return frame.convert("RGBA").crop((8, 8, 56, 56))
    if frame.size == (48, 48):
        return frame.convert("RGBA")
    raise FSArtGateError(f"not a 48/64px sprite: {frame.size}")


def validate_three_frames(f0: Image.Image, frames: list[Image.Image]) -> dict:
    if len(frames) != 3:
        raise FSArtGateError("Actor SBS requires three STORED poses, not an infographic")
    poses=[normalize_generated_frame(p) for p in frames]
    if f0.size != (48,48):
        raise FSArtGateError("unapproved source")
    a=[np.asarray(p) for p in poses]
    alpha=[int((p[:,:,3]>0).sum()) for p in a]
    if any(x < 180 or x > 1350 for x in alpha):
        raise FSArtGateError("wrong body silhouette footprint; source identity may be wrong")
    if np.array_equal(a[1],a[2]):
        raise FSArtGateError("the two stride frames are identical")
    if np.any(a[0] != np.asarray(f0.convert("RGBA"))):
        raise FSArtGateError("approved first frame changed; keep the immutable F0")
    return {
        "schema": "fs-a14-format-gate/v1",
        "frame_geometry": "PASS",
        "stored_frames": 3,
        "alpha_pixels": alpha,
        "human_motion_review": "REQUIRED",
        "human_art_review": "REQUIRED",
        "native_game_exe": "NOT_RUN",
        "pixel_lab_calls_here": 0,
        "formal_seal": "NO",
    }
