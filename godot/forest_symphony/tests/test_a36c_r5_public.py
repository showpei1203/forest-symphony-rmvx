"""A36C R5 Godot scene/manifest integrity test, stdlib, no private art.
python3 godot/forest_symphony/tests/test_a36c_r5_public.py
"""
import json
from pathlib import Path
P=Path(__file__).resolve().parents[1]
read=lambda p:json.loads((P/"data"/p).read_text())
a=read("a36c_r2_ecology_variant_manifest.json")
b=read("a36c_r5_natural_forest_clusters_manifest.json")
s=(P/"scenes/a36c_r5_natural_forest_clusters_80x58.tscn").read_text()
before={o["id"]:o for o in a["objects"]}
after={o["id"]:o for o in b["objects"]}
assert before.keys()==after.keys() and len(after)==326
assert a["runtime_ground"]==b["runtime_ground"] and a["shadow"]==b["shadow"]
assert a["assets"]==b["assets"]
changes=b["a36c_r5"]["changes"]
assert len(changes)==28 and len({c["id"] for c in changes})==28
moved=set(c["id"] for c in changes)
r4move={c["id"] for c in b["a36c_r4"]["changes"]}
assert len(r4move)==1
for id,x in before.items():
    y=after[id]
    if id not in moved|r4move:
        assert x==y,id
    else:
        assert x["family"]==y["family"] and x["asset_sha256"]==y["asset_sha256"]
        for key in ("width","height","footprint","semantic"):
            assert x[key]==y[key],(id,key)
    if id in moved:
        block=s.split('[node name="'+id+'" type="Node2D" parent="YSort"]',1)[1].split('[node name="Sprite"',1)[0]
        assert 'position = Vector2('+str(y["foot"][0])+', '+str(y["foot"][1])+')' in block
assert s.count('source_object_id = "')==326
assert s.count('type="StaticBody2D"')==326
print("A36C R5 SOURCE SCENE CONTRACT PASS: 29 moved tree instances; 326 independent owners; Godot native NOT RUN")
