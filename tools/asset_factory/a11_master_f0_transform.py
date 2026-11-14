"""A11 FS image-native conversion primitives: no re-generated Ground/PAR RGB.

This module handles *pixel provenance* (objective) only. It never asserts that
a supplied semantic alpha mask means correct foreground, nor that a new actor
pose is attractive, or that RPG Maker VX Game.exe has been executed.
PIL/numpy only, no PixelLab/Orca or network access.

Private source ZIP and art stay in restricted Drive. Public code contains no art.
"""
from __future__ import annotations

from dataclasses import dataclass
import hashlib

import numpy as np
from PIL import Image


class A11GateError(ValueError):
    pass


@dataclass(frozen=True)
class SourceAlignedResult:
    source_sha256: str
    canvas: tuple[int, int]
    par_alpha_pixels: int
    same_xy_rgb_mismatches: int
    deck_core_leak_pixels: int


def source_runtime_par(master: Image.Image, mask: Image.Image,
                       forbidden_deck_core: Image.Image | None = None,
                       *, require_zero_deck_leak: bool = True) -> tuple[Image.Image, SourceAlignedResult]:
    """Return full-source-coordinate RGBA PAR, never AI redrawn RGB.

    The *incoming mask* is an UNVERIFIED semantic proposal. This routine does
    not infer where the bridge, tree, eave, actor legal footpoint, or roof are.
    """
    if master.mode not in ("RGB", "RGBA"):
        raise A11GateError("master must be a pixel image in RGB or RGBA")
    if mask.mode not in ("L", "1"):
        raise A11GateError("mask must be an explicit L/1 semantic source, not color-derived RGB")
    if master.size != mask.size:
        raise A11GateError("all source pixels and semantic mask must share the ORIGINAL canvas and XY")
    m = np.asarray(master.convert("RGB"), dtype=np.uint8)
    a = np.asarray(mask.convert("L"), dtype=np.uint8)
    forbidden = np.zeros(a.shape, dtype=bool)
    if forbidden_deck_core is not None:
        if forbidden_deck_core.size != master.size:
            raise A11GateError("forbidden deck mask must have same original world XY")
        forbidden = np.asarray(forbidden_deck_core.convert("L")) > 0
    leak = int(((a > 0) & forbidden).sum())
    if leak and require_zero_deck_leak:
        raise A11GateError(f"semantic foreground includes {leak} forbidden bridge deck core pixels")
    if not np.any(a):
        raise A11GateError("empty PAR mask must not count as a passing positive witness")
    # RGB comes directly from exact Master(x,y). Mask alpha comes from mask(x,y).
    rgba = np.dstack([m, a])
    result = Image.fromarray(rgba, mode="RGBA")
    return result, SourceAlignedResult(
        source_sha256=hashlib.sha256(m.tobytes()).hexdigest(),
        canvas=master.size,
        par_alpha_pixels=int((a > 0).sum()),
        same_xy_rgb_mismatches=int(np.any(np.asarray(result)[:, :, :3] != m, axis=2)[a > 0].sum()),
        deck_core_leak_pixels=leak,
    )


def check_overlay_rgb(master: Image.Image, overlay: Image.Image) -> int:
    """Strictly reject any instance of material-shift or independent redrawing."""
    if master.size != overlay.size:
        raise A11GateError("world canvas differs")
    expected = np.asarray(master.convert("RGB"))
    got = np.asarray(overlay.convert("RGBA"))
    return int(np.any(expected != got[:, :, :3], axis=2)[got[:, :, 3] > 0].sum())


def strict_original_master_rgb(master_bytes: bytes, copied_bytes: bytes) -> bool:
    """Prove exact source PNG byte-preserving runtime FullGround copy."""
    return master_bytes == copied_bytes


def integer_f0_waiting(f0: Image.Image) -> tuple[Image.Image, Image.Image, Image.Image]:
    """Small three-keypose WAITING experiment, source colors only.

    A run/attack rig is NOT inferred from this. This is a minimal pixel-warp
    control to benchmark against image-based pose redraw. No artistic pass.
    """
    if f0.size != (48, 48):
        raise A11GateError("This pilot applies ONLY to existing A62 48px Actor source")
    arr = np.asarray(f0.convert("RGBA"))
    def warp(mode: str) -> Image.Image:
        out = np.zeros_like(arr)
        for y in range(48):
            for x in range(48):
                if mode == "UP_LEFT":
                    sy=y+(1 if 10 <= y <= 34 else 0)
                    sx=x+(1 if 9 <= y < 28 else 0)
                    if y >= 37 and x < 24: sx=min(47, x+1)
                else:
                    sy=y-(1 if 10 <= y <= 34 else 0)
                    sx=x-(1 if 9 <= y < 28 else 0)
                    if y >= 37 and x > 26: sx=max(0, x-1)
                if 0 <= sy < 48 and 0 <= sx < 48: out[y, x]=arr[sy, sx]
        return Image.fromarray(out, mode="RGBA")
    return f0.convert("RGBA"), warp("UP_LEFT"), warp("DOWN_RIGHT")


def verify_f0_palette_identity(f0: Image.Image, poses: tuple[Image.Image, ...]) -> dict:
    """Palette preservation is objective; identity and natural motion require ART."""
    src=np.asarray(f0.convert("RGBA"))
    palette=set(map(tuple, src.reshape(-1, 4)))
    metrics=[]
    for i,p in enumerate(poses):
        data=np.asarray(p.convert("RGBA"))
        if data.shape != src.shape or not set(map(tuple, data.reshape(-1, 4))).issubset(palette):
            raise A11GateError("pose uses colors outside the source F0 palette or changes canvas")
        metrics.append({"pose":i+1,"changed_pixel_positions":int(np.any(data!=src,axis=2).sum())})
    return {"f0_palette_preserved":True,"metrics":metrics,"art_user_approved":False,"native_game_exe_run":False}
