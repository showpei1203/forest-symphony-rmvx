#!/usr/bin/env python3
"""FS_01_MAZE R8: reversible real Godot collision-only WATER layer.

Adds a separate water component on top of provenance-safe R7, does not alter
any 1x art or historical PAR coordinates/footprints. This is candidate
collision for 148 source water cells, NOT validated maze walkability.
"""
import argparse,hashlib,json
from pathlib import Path
PREV="scenes/fs_01_maze_a36c_r7_reconciled_80x58.tscn"
NEXT="scenes/fs_01_maze_r8_water_collision_80x58.tscn"
SCRIPT="scripts/fs_01_maze_r8_water_collision.gd"
GROUND="private_assets/a36_ground_only_2560x1856.png"
GROUND_SHA="ac591877b05c00543e6756e44e6ba81f6fea7e36086049e35de81e2610e0c911"
def sha(b):return hashlib.sha256(b).hexdigest()
def build(root:Path,script:Path):
    previous=(root/PREV).read_bytes()
    if sha((root/GROUND).read_bytes())!=GROUND_SHA:
        raise RuntimeError("Ground bytes changed before water collision")
    src=previous.decode("utf-8")
    old='[ext_resource type="Script" path="res://scripts/a36_player.gd" id="3_player"]'
    if src.count(old)!=1:
        raise RuntimeError("Expected 3-player script reference missing")
    new=src.replace(old,old+'\n[ext_resource type="Script" path="res://'+SCRIPT+'" id="4_water"]')
    new=new.replace("load_steps=4","load_steps=5",1)
    new=new.replace("FS_01_MAZE_A36C_R7_ProvenanceSafeForest","FS_01_MAZE_R8_IndependentWaterCollision",1)
    if new==src:raise RuntimeError("R8 new scene construction failed")
    new+='\n[node name="WaterSemanticHazards" type="Node2D" parent="."]\nscript = ExtResource("4_water")\n'
    (root/NEXT).write_bytes(new.encode("utf-8"))
    (root/SCRIPT).parent.mkdir(parents=True,exist_ok=True)
    (root/SCRIPT).write_bytes(script.read_bytes())
    project=root/"project.godot"
    main=project.read_bytes()
    oldmain=('res://'+PREV).encode()
    if oldmain not in main:raise RuntimeError("R7 main scene not selected")
    project.write_bytes(main.replace(oldmain,('res://'+NEXT).encode()))
    sem=json.loads((root/"data/a36_terrain_semantic_candidates.json").read_text(encoding="utf8"))
    if sem["river_cell_count"]!=148 or len(sem["river_blocked_cells"])!=148:
        raise RuntimeError("Original water semantic mask missing")
    info={
      "scene_id":"FS_01_MAZE","scene_name":"幽葉迴廊",
      "schema":"fs-01-maze-r8-independent-water-collision/v1",
      "base_R7_scene_SHA256":sha(previous),
      "candidate_R8_scene_SHA256":sha(new.encode()),
      "Ground_SHA256":GROUND_SHA,"water_candidate_tiles":148,
      "tiled_water_collision":"146? NO: 148 unique 32px real static-body tiles",
      "navigation":"NOT_RUN","art":"HOLD","water_approval":"HOLD",
      "source":"A36 original semantic candidates separate from full Ground/Shadow"
    }
    info["tiled_water_collision"]="148 individual collision rectangles"
    (root/"data/fs_01_maze_r8_water_collision_manifest.json").write_bytes((json.dumps(info,ensure_ascii=False,indent=2)+"\n").encode())
    print(json.dumps({"source_scene":NEXT,"bytes":len(new.encode()),"scene_SHA256":sha(new.encode()),
        "original_R7_SHA":sha(previous),"water_tiles":148,"status":"NATIVE NOT_RUN / NAV HOLD / ART HOLD"},ensure_ascii=False,indent=2))
if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--project",required=True);p.add_argument("--script",required=True)
    a=p.parse_args();build(Path(a.project),Path(a.script))
