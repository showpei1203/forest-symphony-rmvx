#!/usr/bin/env python3
"""Extract a verified reference-only 128x128 region from private Ground3; not output Ground."""
from pathlib import Path
from PIL import Image
import hashlib, sys
src = Path(sys.argv[1]); out = Path(sys.argv[2])
assert hashlib.sha256(src.read_bytes()).hexdigest() == 'ddc1f21e1d23dcb8258a20baa2acb106d1c0e56683a4dc280faedc23bcd47a13'
with Image.open(src) as im:
    assert im.size == (1280,928) and im.mode == 'RGB'
    im.crop((930,260,1058,388)).save(out)
assert hashlib.sha256(out.read_bytes()).hexdigest() == '943c7c7aa16f12f15e0f298f5963b91283f4c8bb19fb234c2e48825059fb1928'
print('Private reference input verified. Never treat source crop as newly generated Ground.')