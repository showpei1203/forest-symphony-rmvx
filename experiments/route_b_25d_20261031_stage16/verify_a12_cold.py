from pathlib import Path
import numpy as np,hashlib,json,subprocess,sys
from PIL import Image
R=Path(__file__).resolve().parent
sha=lambda p:hashlib.sha256((R/p).read_bytes()).hexdigest()
assert sha("A12_INPUT_A10_BENCHMARK_GROUND_544x416.png")=="20bb55e2b9212b45204a885cb34c0a59ba77fa2e5d0c0754d8eb62a956e33e5a"
assert sha("A12_ECOLOGICAL_CLUSTERS_544x416.png")=="174fbcd122acb5cf99117e048a42834975d5780d8d9b87380a01219823774d00"
def load_rgb(n):
 with Image.open(R/n) as im:
  assert im.size==(544,416)
  return np.asarray(im.convert("RGB"),dtype=np.uint8).copy()
def mask(n):
 with Image.open(R/n) as im:
  assert im.size==(544,416)
  return np.asarray(im.convert("L"))>0
base=load_rgb("A12_INPUT_A10_BENCHMARK_GROUND_544x416.png")
out=load_rgb("A12_ECOLOGICAL_CLUSTERS_544x416.png")
road=mask("A12_INPUT_A10_BENCHMARK_ROAD_MASK_544x416.png")
edge=mask("A12_INPUT_A10_BENCHMARK_EDGE_BAND_544x416.png")
protect=road|edge;allowed=~protect
assert int(road.sum())==44321 and int(edge.sum())==3328 and not (road&edge).any()
diff=np.any(base!=out,axis=2)
assert int((diff&protect).sum())==0
assert int((diff&allowed).sum())==108189
for n,count in [("A12_LEAF_PIXELS_MASK.png",2910),("A12_FLOWER_PIXELS_MASK.png",360),("A12_SOIL_PIXELS_MASK.png",900)]:
 m=mask(n)
 assert int(m.sum())==count and not (m&protect).any()
q=json.loads((R/"A12_A10_A11_COMPARATIVE_QA.json").read_text(encoding="utf8"))
assert q["art_status"]=="FAIL_INTERNAL_VISUAL_GROUND3" and q["formal_seal"]=="NO"
manifest=json.loads((R/"A12_EXECUTION_MANIFEST.json").read_text(encoding="utf8"))
assert manifest["output_sha256"]==sha("A12_ECOLOGICAL_CLUSTERS_544x416.png")
assert manifest["art"]=="FAIL_INTERNAL_VISUAL_GROUND3"
# Recreate in cold extraction exactly from archived baseline and authored blueprint.
generated=["A12_ECOLOGICAL_CLUSTERS_544x416.png","A12_TINT_ONLY_544x416.png","A12_DENSE_BLUEPRINT_MASK.png","A12_DRY_BLUEPRINT_MASK.png","A12_FLOWER_BLUEPRINT_MASK.png","A12_LEAF_PIXELS_MASK.png","A12_FLOWER_PIXELS_MASK.png","A12_SOIL_PIXELS_MASK.png","A12_PROTECTED_MASK.png","A12_EXECUTION_MANIFEST.json"]
expected={n:sha(n) for n in generated}
r=subprocess.run([sys.executable,str(R/"a12_generate_clusters.py")],cwd=R,capture_output=True,text=True,encoding="utf8",errors="replace",timeout=120)
assert r.returncode==0,(r.stdout,r.stderr)
for n,h in expected.items():assert sha(n)==h,"Regen SHA mismatch: "+n
check=subprocess.run([sys.executable,str(R/"a12_compare_qa.py")],cwd=R,capture_output=True,text=True,encoding="utf8",errors="replace",timeout=90)
assert check.returncode==0,(check.stdout,check.stderr)
assert q==json.loads((R/"A12_A10_A11_COMPARATIVE_QA.json").read_text(encoding="utf8"))
print("A12_COLD_PASS: 544x416 source+blueprint regenerated exact SHA and all layer masks; protected 47649 unchanged")
print("A12_ART=FAIL, NO_GODOT, NO_VX, FORMAL_SEAL=NO")
