"""A43 targeted geometric QA for the sword-tip trail, without re-running A42 engine tests."""
from pathlib import Path
from PIL import Image
import json

ROOT=Path(__file__).resolve().parents[1]
rig=json.loads((ROOT/"qa/A42_POSE_RIG_45DEG_V1.json").read_text("utf-8"))
src=ROOT/"assets/actor01_a42_fx_12frames.png"
dst=ROOT/"assets/actor01_a43_fx_tiptrail_candidate_12frames.png"
assert src.exists() and dst.exists(), "A42 private atlases and generated A43 candidate required"
a=Image.open(src).convert("RGBA")
b=Image.open(dst).convert("RGBA")
assert a.size==b.size==(256,192)
assert len(rig["poses"])==12
for i in range(12):
    box=((i%4)*64,(i//4)*64,(i%4+1)*64,(i//4+1)*64)
    old=a.crop(box)
    new=b.crop(box)
    changed=sum(p!=q for p,q in zip(old.getdata(),new.getdata()))
    active=i in (4,5,6,7,8)
    assert (new.getbbox() is not None)==active,(i,"activity mismatch")
    if i in (0,1,2,3,9,10,11):
        assert new.getbbox() is None,(i,"unexpected FX")
    if active:
        assert changed>0,(i,"no visible edit")
        tip=rig["poses"][i]["sword_tip_px"]
        assert tip is not None
        # The sword tip must touch a non-transparent FX pixel in the actual atlas.
        assert new.getpixel(tuple(tip))[3]>0,(i,"detached tip")
    assert all(px[3] in (0,255) or 0<px[3]<255 for px in new.getdata())
    print(f"F{i:02d}: {'ACTIVE' if active else 'CLEAR'} changed_pixels={changed}")
print("A43_CANDIDATE_GEOMETRY_PASS; ART HOLD; GODOT NATIVE NOT RUN")
