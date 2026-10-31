from pathlib import Path
from PIL import Image
import numpy as np, hashlib, json
root=Path(__file__).resolve().parent
def img(name, size):
    p=root/name
    assert p.is_file(), name
    assert p.read_bytes()[:8]==bytes.fromhex("89504e470d0a1a0a")
    with Image.open(p) as im:
        assert im.size==size,(name,im.size)
        return np.asarray(im.convert("RGB"),dtype=np.uint8).copy()
r=img("A08_GROUND3_SAND_INPUT_48.png",(48,48))
assert hashlib.sha256((root/"A08_GROUND3_SAND_INPUT_48.png").read_bytes()).hexdigest()=="ca7c4ea242a9b81ab39113acdad1de47ed193117d1f5db6c6d2dea5383548adb"
base=img("A08_BASE_GRASS_INPUT.png",(384,384))
a07=img("A08_A07_BASELINE_FINAL.png",(384,384))
rep=json.loads((root/"A08_EXECUTION_REPORT.json").read_text(encoding="utf8"))
assert rep["status"]=="PASS_REAL_MODEL_OUTPUT",rep
native="A08_COMFY_NATIVE_"+rep["output_17"]["name"]
a08=img(native,(384,384))
mask=np.asarray(Image.open(root/"A08_ROAD_TARGET_MASK_384.png").convert("L"))==255
assert int(mask.sum())==28818
sem=img("A08_SEGMENTATION_INPUT.png",(384,384))
assert np.all(sem[mask]==[0,10,255]) and np.all(sem[~mask]==[4,250,7])
d=np.any(base!=a08,axis=2)
assert int((d&mask).sum())==28818 and int((d&~mask).sum())==0
w=json.loads((root/"A08_CONTROLLED_COMBINED_WORKFLOW.json").read_text(encoding="utf8"))
b=json.loads((root/"A08_A07_BASELINE_WORKFLOW.json").read_text(encoding="utf8"))
changes=[(n,k) for n in w for k in w[n]["inputs"] if w[n]["inputs"][k]!=b[n]["inputs"][k]]
assert sorted(changes)==sorted([("5","model"),("8","image"),("7","filename_prefix"),("17","filename_prefix")]),changes
assert w["5"]["inputs"]["model"]==["11",0] and w["20"]["class_type"]=="ControlNetApplyAdvanced"
assert w["5"]["inputs"]["seed"]==b["5"]["inputs"]["seed"]==160406
assert w["5"]["inputs"]["positive"]==b["5"]["inputs"]["positive"] and w["5"]["inputs"]["negative"]==b["5"]["inputs"]["negative"]
assert w["11"]["inputs"]["weight"]==.65
assert hashlib.sha256((root/native).read_bytes()).hexdigest()=="44da9c703de1bba22985510a5d1ff342c0f67e68388ab80231133cd36083620a"
q=json.loads((root/"A08_COMPARATIVE_PIXEL_QA.json").read_text(encoding="utf8"))
assert q["outside_changed"]==0 and q["formal_seal"]=="NO"
print("A08_COLD_PASS: true ControlNet+IPAdapter full raw PNG, condition only change, road 28818 / outside 0, ART FAIL, Formal Seal NO")
