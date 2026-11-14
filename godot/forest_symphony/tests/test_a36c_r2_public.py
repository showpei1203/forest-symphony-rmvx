"""A36C R2 immutable baseline / Godot scene variant contract. Python stdlib.
Run: python tests/test_a36c_r2_public.py
"""
import json
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
base = json.loads((ROOT/"data/a36b_ecological_tree_manifest.json").read_text())
new = json.loads((ROOT/"data/a36c_r2_ecology_variant_manifest.json").read_text())
scene = (ROOT/"scenes/a36c_r2_ecology_variant_80x58.tscn").read_text()
old_scene = (ROOT/"scenes/a36b_large_forest_tree_ecology_80x58.tscn").read_text()
assert base["world_px"] == new["world_px"] == [2560,1856]
assert base["runtime_ground"] == new["runtime_ground"]
assert base["shadow"] == new["shadow"]
assert base["assets"] == new["assets"]
assert len(base["objects"]) == len(new["objects"]) == 326
changes = new["a36c_r2"]["changes"]
assert len(changes) == 40
old_by_id = {o["id"]:o for o in base["objects"]}
new_by_id = {o["id"]:o for o in new["objects"]}
assert old_by_id.keys() == new_by_id.keys()
assert len({c["id"] for c in changes}) == len(changes)
changed_ids = {c["id"] for c in changes}
for oid, old in old_by_id.items():
    updated = new_by_id[oid]
    if oid not in changed_ids:
        assert old == updated, oid
    else:
        assert old["semantic"] == updated["semantic"] == "tree"
        for k in ("id","foot","width","height","footprint"):
            assert old[k] == updated[k], (oid,k)
        assert old["family"] != updated["family"]
        assert updated["asset_sha256"] == new["assets"][updated["family"]]["sha"]
        assert (old["width"],old["height"]) == (new["assets"][updated["family"]]["w"],new["assets"][updated["family"]]["h"])
        block = scene.split('[node name="'+oid+'" type="Node2D" parent="YSort"]',1)[1].split('[node name="Sprite"',1)[0]
        assert 'source_file = "res://private_assets/independent_par/'+updated["family"]+'"' in block
        assert 'source_sha256 = "'+updated["asset_sha256"]+'"' in block
assert scene.count('source_object_id = "') == old_scene.count('source_object_id = "') == 326
assert scene.count('type="StaticBody2D"') == old_scene.count('type="StaticBody2D"')
assert scene.count('type="CollisionShape2D"') == old_scene.count('type="CollisionShape2D"')
print("A36C R2 manifest/scene static source contract PASS; native Godot/render NOT RUN")
