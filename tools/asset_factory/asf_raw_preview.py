"""ASF / PixelLab / arbitrary-generator first-pass sprite preview (size-agnostic).

Preserve source-sized PNGs, display them on a common transparent canvas and
build a contact sheet / GIF for ART review. This is *not* a native VX export.
Run after a real provider has produced PNG bytes, not instead of generation.
"""
from __future__ import annotations

import hashlib
import io
from typing import Sequence

from PIL import Image


class SpritePreviewError(ValueError):
    pass


def _png(data: bytes, label: str) -> Image.Image:
    try:
        with Image.open(io.BytesIO(data)) as im:
            if im.format != "PNG":
                raise SpritePreviewError(f"{label}: PNG required")
            im.load()
            image = im.convert("RGBA")
    except (OSError, ValueError) as exc:
        raise SpritePreviewError(f"{label}: unreadable source: {exc}") from exc
    if image.width < 1 or image.height < 1:
        raise SpritePreviewError(f"{label}: empty geometry")
    if image.getchannel("A").getbbox() is None:
        raise SpritePreviewError(f"{label}: fully transparent frame")
    return image


def preview_frames(
    frame_pngs: Sequence[bytes],
    *,
    duration_ms: int = 150,
    background: tuple[int, int, int, int] = (0, 0, 0, 0),
) -> dict:
    """Make a lossless same-pixel-size sheet plus animated GIF preview.

    Arbitrary source width/height and different frames' crops are legal.
    Each source frame is placed at bottom-centre for display ONLY; this
    is not a verified foot/actor anchor or a VX-ready sheet.
    """
    if not frame_pngs:
        raise SpritePreviewError("need at least one actual PNG frame")
    if len(frame_pngs) > 256:
        raise SpritePreviewError("preview cap 256 frames; split into batches")
    if not 50 <= duration_ms <= 5000:
        raise SpritePreviewError("duration_ms must be 50..5000 for inspectable playback")

    source = [_png(payload, f"frame{i}") for i, payload in enumerate(frame_pngs)]
    w = max(im.width for im in source)
    h = max(im.height for im in source)
    if w * h * len(source) > 40_000_000:
        raise SpritePreviewError("preview memory safety limit; use smaller batch")
    aligned = []
    coords = []
    for im in source:
        frame = Image.new("RGBA", (w, h), background)
        x, y = (w - im.width) // 2, h - im.height
        frame.alpha_composite(im, (x, y))
        aligned.append(frame)
        coords.append((x, y))

    sheet = Image.new("RGBA", (w * len(source), h), background)
    for index, frame in enumerate(aligned):
        sheet.paste(frame, (index * w, 0))

    sheet_bytes = io.BytesIO()
    sheet.save(sheet_bytes, format="PNG")
    gif_bytes = io.BytesIO()
    aligned[0].save(
        gif_bytes, format="GIF", save_all=True, append_images=aligned[1:],
        duration=duration_ms, loop=0, disposal=2, optimize=False,
    )
    # We report comparison evidence, never assert motion/anatomy has passed.
    duplicates = [
        [i, j] for i in range(len(aligned)) for j in range(i + 1, len(aligned))
        if aligned[i].tobytes() == aligned[j].tobytes()
    ]
    return {
        "status": "PREVIEW_ONLY_NEEDS_ART_REVIEW",
        "frame_count": len(source),
        "original_sizes": [[im.width, im.height] for im in source],
        "display_cell": [w, h],
        "sheet_size": [w * len(source), h],
        "bottom_center_offsets": [list(xy) for xy in coords],
        "duplicate_pairs": duplicates,
        "source_sha256": [hashlib.sha256(payload).hexdigest() for payload in frame_pngs],
        "sheet_png": sheet_bytes.getvalue(),
        "preview_gif": gif_bytes.getvalue(),
        "source_art_changed": False,
        "native_vx": "NOT_RUN",
        "user_art": "NOT_RUN",
        "formal_seal": "NO",
    }
