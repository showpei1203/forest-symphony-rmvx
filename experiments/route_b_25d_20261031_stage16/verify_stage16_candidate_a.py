#!/usr/bin/env python3
"""Stage 16 fail-closed PNG source integrity and crop exactness."""
from pathlib import Path
from PIL import Image, ImageChops
import json, hashlib

root = Path(__file__).resolve().parents[0]
qa = json.loads((root / "evidence" / "STAGE16_SOURCE_QA.json").read_text(encoding="utf-8"))
for name, spec in qa["measurements"].items():
    f = root / "source" / name
    assert f.is_file(), f"Missing file: {f}"
    assert f.read_bytes()[:8] == b"\x89PNG\r\n\x1a\n", f"Invalid PNG signature: {f}"
    assert hashlib.sha256(f.read_bytes()).hexdigest() == spec["sha256"], f"Hash mismatch: {f}"
    with Image.open(f) as img:
        assert list(img.size) == spec["size"] and img.mode == spec["mode"], f"Metadata mismatch: {f}"

orig = Image.open(root / "source/STAGE16_AI_ORIGINAL_NATIVE_SOURCE.png")
crop = Image.open(root / "source/GROUND_CANDIDATE_A_544x576_CROP_ONLY.png")
roi = Image.open(root / "source/GROUND_CANDIDATE_A_544x416_ROI.png")
assert orig.size == (1474, 1067), "Original format unexpected"
assert crop.size == (544, 576) and roi.size == (544, 416), "Wrong native size"
assert ImageChops.difference(orig.crop((448,224,992,800)), crop).getbbox() is None, "Crop pixel mismatch"
assert ImageChops.difference(crop.crop((0,80,544,496)), roi).getbbox() is None, "ROI pixel mismatch"
assert qa["formal_seal"] == "NO", "Do not seal without art and native runtime gates"
print("STAGE16_A01_SOURCE_PNG_PASS | CROP_EXACT_PASS | ART_PENDING | VX_NOT_RUN | FORMAL_SEAL_NO")
