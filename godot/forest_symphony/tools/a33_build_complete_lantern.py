"""Forest Symphony A33 | Build original independently generated lamp PAR PNG.

Input is the separately generated full-object alpha art, NOT a flattened
Ground/Master pixel source. Source art stays only in owner-only Drive.

Output 52x124 game pixel art, complete cap+shaft+base. No stretch of A32 16x41.

Run (with source present in private-assets ZIP):
    python tools/a33_build_complete_lantern.py

Dependencies: Pillow, numpy. This tool is deterministic for Pillow version
recorded in the private QA manifest; re-check SHA when changing dependencies.
"""
from __future__ import annotations

from pathlib import Path
import hashlib
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "private_assets/a33_new_generator_source_full_rgba.png"
TARGET = ROOT / "private_assets/independent_par/a33_ornate_lantern_complete_52x124.png"
EXPECTED_SOURCE_SHA256 = "f051f4cf6f59d0f9555faf021c4affcf4e75123aae2220f7003b06ccf1e8a9d3"
EXPECTED_TARGET_SHA256 = "6e0bed07a735cba3c908a5da4c81863222363cab01325aeeaaf1f821d63a6991"


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def build(src: Path = SOURCE, dst: Path = TARGET) -> str:
    if sha(src) != EXPECTED_SOURCE_SHA256:
        raise ValueError("Unexpected independent source artwork; no silent regeneration")
    image = Image.open(src).convert("RGBA")
    channel = np.array(image)[:, :, 3]
    ys, xs = np.where(channel > 15)
    if len(xs) == 0:
        raise ValueError("No actual lantern alpha pixels")
    bbox = (
        max(0, int(xs.min()) - 14), max(0, int(ys.min()) - 12),
        min(image.width, int(xs.max()) + 15), min(image.height, int(ys.max()) + 15),
    )
    body = image.crop(bbox).resize((44, 114), Image.Resampling.LANCZOS)
    pixels = np.array(body.convert("RGBA"))
    mask = pixels[:, :, 3]
    mask = np.where(mask < 29, 0, mask).astype(np.uint8)
    pixels[mask == 0, :3] = 0
    pixels[:, :, 3] = mask
    body = Image.fromarray(pixels, "RGBA")
    palette_rgb = body.convert("RGB").quantize(
        colors=84, method=Image.Quantize.MEDIANCUT,
        dither=Image.Dither.NONE,
    ).convert("RGB")
    pixels = Image.merge("RGBA", (*palette_rgb.split(), body.getchannel("A")))
    result = Image.new("RGBA", (52, 124), (0, 0, 0, 0))
    result.alpha_composite(pixels, (4, 3))
    rgba = np.array(result)
    rgba[rgba[:, :, 3] == 0, :3] = 0
    result = Image.fromarray(rgba, "RGBA")
    if not (result.getbbox()[1] < 15 and result.getbbox()[3] > 108):
        raise ValueError("Missing top finial or bottom base")
    dst.parent.mkdir(parents=True, exist_ok=True)
    result.save(dst, optimize=True)
    digest = sha(dst)
    if digest != EXPECTED_TARGET_SHA256:
        raise ValueError("Non-reproducible output SHA mismatch: " + digest)
    return digest


if __name__ == "__main__":
    print("A33 independent complete lamp SHA256:", build())
