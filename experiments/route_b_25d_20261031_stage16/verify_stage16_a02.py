#!/usr/bin/env python3
"""Stage 16 A02 reproducibility gate. Private artifact required; no art PASS inferred."""
from pathlib import Path
import json,hashlib
from PIL import Image,ImageChops
root=Path(__file__).resolve().parents[0]
if not (root/'source').exists(): root=root.parents[0]  # run from private ZIP root when copied to tools/
if not (root/'source').exists(): raise SystemExit('Source unavailable: extract private A02 ZIP, not public repo alone.')
q=json.loads((root/'evidence/STAGE16_A02_SOURCE_QA.json').read_text(encoding='utf8'))
for name, meta in q['measurements'].items():
 p=root/'source'/name
 assert p.is_file() and p.read_bytes()[:8]==bytes.fromhex('89504e470d0a1a0a'), name
 assert hashlib.sha256(p.read_bytes()).hexdigest()==meta['sha256'],name
 with Image.open(p) as im: assert list(im.size)==meta['size'] and im.mode==meta['mode'],name
orig=Image.open(root/'source/STAGE16_AI_ORIGINAL_NATIVE_B.png')
long=Image.open(root/'source/GROUND_CANDIDATE_B_544x576_CROP_ONLY.png')
roi=Image.open(root/'source/GROUND_CANDIDATE_B_544x416_ROI.png')
assert ImageChops.difference(orig.crop((448,224,992,800)),long).getbbox() is None
assert ImageChops.difference(long.crop((0,80,544,496)),roi).getbbox() is None
assert q['formal_seal']=='NO' and q['godot_actual_gpu']=='NOT_RUN_BY_ART_GATE'
print('Stage16 A02: PNG/CROP PASS, art NOT APPROVED, native game NOT RUN, seal NO')