from pathlib import Path
import sys,json,hashlib
import numpy as np
from PIL import Image
R=Path(__file__).resolve().parent
repo=R/'upstream'/'PXG-Tiny-AI'
sys.path.insert(0,str(repo/'src'))
from pxg_tiny.pipeline import PXGPipeline
from pxg_tiny.render import grid_to_rgba
def sha(n):return hashlib.sha256((R/n).read_bytes()).hexdigest()
q=json.loads((R/'A17_PXG_MODEL_TRIAL.json').read_text(encoding='utf8'))
assert q['repo_commit']=='c813f5b3d1a391ebef8695c77151abd17670a9d8'
assert q['max_resolution_model']==[16,16]
assert q['formal_seal']=='NO'
for n,hash_ in q['weight_files_sha256'].items():
 assert hashlib.sha256((repo/'weights'/n).read_bytes()).hexdigest()==hash_,n
model=PXGPipeline(repo/'weights')
for case in q['generations']:
 grid,meta=model.generate_pixels(case['prompt'],seed=case['seed'],enforce_quality=True)
 assert meta==case['meta'],(case['id'],meta,case['meta'])
 if case['native']:
  assert grid.shape==(16,16)
  actual=grid_to_rgba(grid)
  with Image.open(R/case['file']) as im:
   assert im.size==(16,16)
   expected=np.asarray(im.convert('RGBA'))
   assert np.array_equal(actual,expected),case['id']
  assert sha(case['file'])==case['sha256']
 else:
  assert grid is None and meta.get('gate')=='clarify'
cmp=json.loads((R/'A17_NATIVE16_ART_QA.json').read_text(encoding='utf8'))
assert cmp['original_ground3_reference']['unique_rgb']==256
assert cmp['PXG_model_grass_native16']['unique_rgb']==3
assert cmp['godot']=='NOT_RUN' and cmp['vx']=='NOT_RUN' and cmp['formal_seal']=='NO'
assert sha('A17_GROUND3_GRASS_REFERENCE_64_INPUT.png')=='b185fbbccd5f84a58f12144b906d7a5fe71809b59a8f75ac385c92b2c5543407'
print('A17_COLD_MODEL_REPLAY_PASS two real native16 sprites exact RGBA pixels, flower intent unsupported')
print('A17_GATE native_model_PASS / Ground3_ART_FAIL / 544x416_NOT_RUN / Godot_NOT_RUN / VX_NOT_RUN / Formal_Seal_NO')
