#!/usr/bin/env python3
from pathlib import Path
from PIL import Image
import json, hashlib, subprocess, sys, numpy as np
R=Path(__file__).resolve().parent
sha=lambda n:hashlib.sha256((R/n).read_bytes()).hexdigest()
q=json.loads((R/'A15_PIXEL_GRID_QA.json').read_text(encoding='utf8'))
up=json.loads((R/'A15_EXTERNAL_UPSTREAM_SIZE_QA.json').read_text(encoding='utf8'))
assert q['formal_seal']=='NO' and q['source_grid_detected'] is False
assert sha('A14_GENUINE_AI_SOURCE_1435x1096.png')=='4701511907354048515a969f88f18b77bd5608f6259c286335c7c78f29c6dca7'
assert sha('A14_SOURCE_ASPECT_CROP_1433x1096.png')=='f710d7d4e35d91a6b87fbc30caafcb282c3e52e90eb2ab8992e959dfc7ab3db6'
assert up['ComfyUI_node_executed'] is False
names=list(q['native_544x416_grid_variants'])
before={n:sha(n) for n in names}
r=subprocess.run([sys.executable,str(R/'build_a15.py')],cwd=R,capture_output=True,text=True,timeout=150,encoding='utf8',errors='replace')
assert r.returncode==0,(r.stdout,r.stderr)
for n in names:
 assert sha(n)==before[n]==q['native_544x416_grid_variants'][n]['sha256'],n
for item in up['core_upstream_outputs']:
 p=next((f for f in R.glob('A15_UPSTREAM_PERFECTPIXEL_GRID*x*_RGB.png') if Image.open(f).size==tuple(item['actual'])),None)
 assert p and sha(p.name)==item['sha256'],item
 assert item['manual_grid_contract_pass'] is False and item['valid_upscale_to_544x416'] is False
for n,p in [('A15_GRID272_ROBUST_PALETTE128_NEAREST2X.png',2),('A15_GRID136_ROBUST_PALETTE64_NEAREST4X.png',4)]:
 a=np.asarray(Image.open(R/n).convert('RGB'))
 blocks=a.reshape(416//p,p,544//p,p,3)
 assert bool(np.all(blocks==blocks[:,0:1,:,0:1,:])),n
print('A15_COLD_PASS: A14 original authentic SHA, independent four fixed-grid outputs exactly regenerated, real upstream outputs SHA-verified')
print('A15_FAIL_CLOSED: source lattice NOT_DETECTED, upstream manual grid CONTRACT_FAIL, target ART_FAIL, Godot/VX NOT_RUN, Formal Seal NO')
