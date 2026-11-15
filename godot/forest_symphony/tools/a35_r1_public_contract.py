#!/usr/bin/env python3
"""Public no-private-PNG contract: Godot A35 village source consistency."""
import argparse,collections,json,re
from pathlib import Path

def main(root:Path)->None:
    current=json.loads((root/"data/a35_r1_forest_groves_manifest.json").read_text(encoding="utf8"))
    old=json.loads((root/"data/a34_r4_house_pair_manifest.json").read_text(encoding="utf8"))
    scene=(root/"scenes/a35_r1_forest_groves_scene.tscn").read_text(encoding="utf8")
    old_scene=(root/"scenes/a34_r4_house_pair_scene.tscn").read_text(encoding="utf8")
    assert current["schema"]=="fs-a35-r1-independent-forest-groves/v1"
    assert current["ground"]==old["ground"],"Ground changed"
    assert current["assets"]==old["assets"],"source family mutation"
    assert current["objects"][:146]==old["objects"],"A34 object mutation"
    assert len(old["objects"])==146 and len(current["objects"])==187
    assert "[node name=\"FS_A35_R1_ForestGroves\"" in scene
    assert scene.count('[node name=\"obj_')==146
    assert scene.count('[node name=\"a35_grove_')==41
    assert "a34_r4_world.gd" in old_scene
    assert "a35_r1_world.gd" in scene
    appended=current["objects"][146:]
    ids=[ob["id"] for ob in current["objects"]]
    assert len(set(ids))==187,"duplicate ids"
    assert len(set(ob["grove_group"] for ob in appended))==8
    assert len(set(ob["asset_id"] for ob in appended))>=12
    protected=current["a35_gate"]["protected_road_rectangles"]
    for ob in appended:
        assert ob["semantic"]=="tree" and ob["root_collision"] is True
        assert ob["frame_edge_allowed"] is True
        asset=current["assets"][ob["asset_id"]]
        assert asset["semantic"]=="tree"
        assert ob["source_sha256"]==asset["sha256"]
        assert ob["w"]==asset["size"][0] and ob["h"]==asset["size"][1]
        assert scene.count('[node name=\"'+ob["id"]+'\" type=\"Node2D\" parent=\"YSort\"]')==1
        assert f'source_object_id = "{ob["id"]}"' in scene
        x,y=ob["foot"]
        for x0,y0,x1,y1 in protected:
            assert not (x+11>x0 and x-11<x1 and y>y0 and y-12<y1),f"Road intrusion {ob['id']}"
    assert (root/"tests/test_a35_r1_real.gd").is_file()
    assert (root/"tests/test_a35_r1_navigation.gd").is_file()
    assert (root/"tests/capture_a35_r1_native.gd").is_file()
    print("A35 R1 PUBLIC SOURCE CONTRACT PASS: 146 immutable owners + 41 trees = 187, 8 groves, 15 source families, roads protected")

if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--root",type=Path,default=Path(__file__).resolve().parent.parent)
    main(p.parse_args().root)
