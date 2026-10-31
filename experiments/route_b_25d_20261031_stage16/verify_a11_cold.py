from pathlib import Path
import hashlib,json,numpy as np,subprocess,sys
from PIL import Image
R=Path(__file__).resolve().parent
sha=lambda n: hashlib.sha256((R/n).read_bytes()).hexdigest()
expected_input="20bb55e2b9212b45204a885cb34c0a59ba77fa2e5d0c0754d8eb62a956e33e5a"
expected_result="4a02bed8d2e8b12cb3b35a5561ba27509d08d0abca1ef76c326c053c4929c51f"
assert sha("A11_INPUT_A10_GROUND_544x416.png")==expected_input
with Image.open(R/"A11_INPUT_A10_GROUND_544x416.png") as i:orig=np.asarray(i.convert("RGB")).copy()
with Image.open(R/"A11_INPUT_A10_ROAD_MASK_544x416.png") as i:road=np.asarray(i.convert("L"))>0
with Image.open(R/"A11_INPUT_A10_EDGE_BAND_544x416.png") as i:band=np.asarray(i.convert("L"))>0
assert orig.shape==(416,544,3)
assert int(road.sum())==44321 and int(band.sum())==3328
assert not (road&band).any()
p=R/"A11_ECOLOGY_CANDIDATE_544x416.png"
if p.exists():p.unlink()
regen=subprocess.run([sys.executable,str(R/"a11_generate_ecology.py")],cwd=R,capture_output=True,text=True,encoding="utf8",errors="replace",timeout=100)
assert regen.returncode==0,(regen.stdout,regen.stderr)
assert sha("A11_ECOLOGY_CANDIDATE_544x416.png")==expected_result,"Image not pixel-reproducible"
with Image.open(R/"A11_ECOLOGY_CANDIDATE_544x416.png") as i:out=np.asarray(i.convert("RGB")).copy()
changed=np.any(orig!=out,axis=2)
protected=road|band
assert int((changed&protected).sum())==0
assert int((changed&~protected).sum())==142642
for f,count in [("A11_TUFT_PIXEL_MASK.png",739),("A11_FLOWER_PIXEL_MASK.png",58)]:
 with Image.open(R/f) as i:mask=np.asarray(i.convert("L"))>0
 assert int(mask.sum())==count and not (mask&protected).any()
m=json.loads((R/"A11_ECOLOGY_MANIFEST.json").read_text(encoding="utf8"))
assert m["formal_seal"]=="NO" and m["godot"]=="NOT_RUN" and m["vx"]=="NOT_RUN"
print("A11_COLD_PIXEL_REPRO_PASS: 544x416 from archived input, sha="+expected_result)
print("A11_COLD_GATE: road+edge 47649 unchanged, 142642 editable changed, art NOT_APPROVED, Formal Seal NO")
