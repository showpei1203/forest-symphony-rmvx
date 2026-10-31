from pathlib import Path
from PIL import Image
import numpy as np,json,hashlib,ast
root=Path(__file__).resolve().parent
def require(p):assert p.is_file(),p;return p
def source_func(filename,name):
 p=require(root/filename)
 tree=ast.parse(p.read_text(encoding='utf8'))
 matches=[node for node in tree.body if isinstance(node,ast.FunctionDef) and node.name==name]
 assert len(matches)==1,(filename,name)
 module=ast.Module(body=matches,type_ignores=[])
 exec(compile(module,str(p),'exec'),globals())
for f,n in [('a10_spectral_synthesis.py','fmodel'),('a10_soft_edge_native_benchmark.py','mask_at'),('a10_soft_edge_native_benchmark.py','shift_adjacent'),('a10_soft_edge_native_benchmark.py','add_soft_transition')]:
 source_func(f,n)
gsrc=Image.open(root/'A10_GROUND3_GRASS_SOURCE_64.png').convert('RGB')
ssrc=Image.open(root/'A10_GROUND3_SAND_SOURCE_48.png').convert('RGB')
assert gsrc.size==(64,64) and ssrc.size==(48,48)
assert hashlib.sha256((root/'A10_GROUND3_GRASS_SOURCE_64.png').read_bytes()).hexdigest()=='b185fbbccd5f84a58f12144b906d7a5fe71809b59a8f75ac385c92b2c5543407'
assert hashlib.sha256((root/'A10_GROUND3_SAND_SOURCE_48.png').read_bytes()).hexdigest()=='ca7c4ea242a9b81ab39113acdad1de47ed193117d1f5db6c6d2dea5383548adb'
def check_array(array,name):
 with Image.open(require(root/name)) as im:
  target=np.asarray(im.convert('RGB'),dtype=np.uint8)
 assert np.array_equal(target,array),name+' pixel mismatch after fresh generation'
def check_mask(array,name):
 with Image.open(require(root/name)) as im:target=np.asarray(im.convert('L'))==255
 assert np.array_equal(array,target),name
for H,W in [(384,384),(416,544)]:
 g=fmodel(gsrc,H,W,101064)
 s=fmodel(ssrc,H,W,101048)
 if H==384:
  check_array(g,'A10_NEW_GRASS_SPECTRAL_384.png')
  check_array(s,'A10_NEW_SAND_SPECTRAL_384.png')
  m=np.asarray(Image.open(root/'A10_ORIGINAL_ROAD_GEOMETRY_384.png').convert('L'))==255
 else:
  m=mask_at(H,W)
  check_mask(m,'A10_BENCHMARK_ROAD_MASK_544x416.png')
 out,ring=add_soft_transition(g,s,m)
 if H==384:
  check_array(out,'A10_R2_SOFT_TRANSITION_384.png')
  check_mask(ring,'A10_R2_ALLOWED_EDGE_BAND_384.png')
 else:
  check_array(out,'A10_BENCHMARK_GROUND_544x416.png')
  check_array(g,'A10_BENCHMARK_GRASS_544x416.png')
  check_array(s,'A10_BENCHMARK_SAND_544x416.png')
  check_mask(ring,'A10_BENCHMARK_EDGE_BAND_544x416.png')
 assert np.array_equal(out[~(m|ring)],g[~(m|ring)]),(H,W)
 assert all(np.where(m[y])[0].size==np.ptp(np.where(m[y])[0])+1 for y in range(H))
 print('PIXEL_EXACT_REGENERATION_PASS',W,H,'road',int(m.sum()),'transition',int(ring.sum()))
r2=json.loads((root/'A10_R2_EDGE_QA.json').read_text(encoding='utf8'))
assert r2['road_R1_vs_R2_changed']==0 and r2['protected_exterior_changed']==0
n=json.loads((root/'A10_BENCHMARK_NATIVE_QA.json').read_text(encoding='utf8'))
assert n['output_sha256']==hashlib.sha256((root/'A10_BENCHMARK_GROUND_544x416.png').read_bytes()).hexdigest()
assert n['formal_seal']=='NO' and n['vx']=='NOT_RUN'
print('A10_COLD_PIXEL_REPRO_PASS; VISUAL_ART_NOT_SEALED; VX_NOT_RUN; Formal Seal NO')
