#!/usr/bin/env python3
"""FS_01_MAZE R12: new additive Godot forest scene with LIVE road navigator.

Preserves sealed R8 scene, A36B original Ground/Shadow, 326 complete PAR and
148 semantic water shapes; adds runtime RoadNavigator via Godot Node2D. Does not
silently modify old R8, A36C branch, elven village, or third-party combat.
"""
import argparse,hashlib,json
from pathlib import Path

R8="scenes/fs_01_maze_r8_water_collision_80x58.tscn"
R12="scenes/fs_01_maze_r12_live_road_navigation_80x58.tscn"
NAV="scripts/fs_01_maze_r12_runtime_road_navigator.gd"
ROAD="data/fs_01_maze_r10_ground_road_confidence.json"
R10="qa_a36c/FS_01_MAZE_R10_GODOT_ROAD_WEIGHTED_ROUTES.json"
R11="qa_a36c/FS_01_MAZE_R11_ACTUAL_GODOT_ACTOR_SWEEP.json"
R8_SHA="bb7f1b565419977c0851e4a188531b3426128758a098251bd151805e0e9fbfec"
GROUND="private_assets/a36_ground_only_2560x1856.png"
GROUND_SHA="ac591877b05c00543e6756e44e6ba81f6fea7e36086049e35de81e2610e0c911"
def sha(data):return hashlib.sha256(data).hexdigest()
def run(project:Path,script:Path):
    source=(project/R8).read_bytes()
    if sha(source)!=R8_SHA:raise RuntimeError("Verified R8 scene was overwritten")
    if sha((project/GROUND).read_bytes())!=GROUND_SHA:
        raise RuntimeError("Original forest Ground corruption")
    road=json.loads((project/ROAD).read_text(encoding="utf8"))
    r10=json.loads((project/R10).read_text(encoding="utf8"))
    r11=json.loads((project/R11).read_text(encoding="utf8"))
    if road["grid"]!=[80,58] or len(road["road_confidence"])!=58:
        raise RuntimeError("No authentic original 80x58 road confidence map")
    if r10["route_candidate_pass_count"]!=5 or r11["fully_clear_continuous_sweep_routes"]!=5 or r11["colliding_segments"]!=0:
        raise RuntimeError("Missing Godot R10 road route / R11 actor sweep native QA")
    text=source.decode("utf8")
    old='[ext_resource type="Script" path="res://scripts/fs_01_maze_r8_water_collision.gd" id="4_water"]'
    if text.count(old)!=1 or "load_steps=5" not in text:
        raise RuntimeError("R8 expected independent water scene structure changed")
    text=text.replace(old,old+'\n[ext_resource type="Script" path="res://'+NAV+'" id="5_nav"]',1)
    text=text.replace("load_steps=5","load_steps=6",1)
    text=text.replace("FS_01_MAZE_R8_IndependentWaterCollision","FS_01_MAZE_R12_LiveRoadNavigation",1)
    text+='\n[node name="RoadNavigator" type="Node2D" parent="."]\nscript = ExtResource("5_nav")\n'
    (project/R12).write_bytes(text.encode("utf8"))
    (project/NAV).write_bytes(script.read_bytes())
    main=project/"project.godot"
    before=main.read_bytes()
    if ("res://"+R8).encode() not in before:
        raise RuntimeError("Baseline main scene is not R8, abort")
    main.write_bytes(before.replace(("res://"+R8).encode(),("res://"+R12).encode()))
    status={
      "schema":"fs-01-maze-r12-live-road-navigation/v1",
      "canonical_scene_id":"FS_01_MAZE",
      "title":"幽葉迴廊",
      "scene":"res://"+R12,
      "original_R8_scene_SHA256":R8_SHA,
      "new_R12_scene_SHA256":sha(text.encode()),
      "original_Ground_SHA256":GROUND_SHA,
      "road_semantics_ground_sha256":sha((project/ROAD).read_bytes()),
      "original_par_count":326,
      "original_tree_count":310,
      "original_river_collision_cells":148,
      "R10_native_road_weighted_paths":"PASS 5/5",
      "R11_native_Player_CharacterBody2D_sweeps":"PASS 231/231 segments, 0 collisions",
      "runtime_navigator_native":"NOT_RUN",
      "role":"Live road-aligned path provider for future Godot gameplay/NPC/events",
      "art":"HOLD",
      "maze_entrance_exit":"HOLD",
      "water_art":"HOLD",
      "other_biomes":"Five more maze/village pairs in original Nov14 six-biome world bible"
    }
    (project/"data/fs_01_maze_r12_navigation_manifest.json").write_bytes((json.dumps(status,ensure_ascii=False,indent=2)+"\n").encode("utf8"))
    print(json.dumps({"scene":R12,"scene_sha256":status["new_R12_scene_SHA256"],
                      "baseline_R8_sha256":R8_SHA,"source_ground_sha256":GROUND_SHA,
                      "runtime_nav":"PENDING_NATIVE_TEST","prior_actor_sweep_pass":True},ensure_ascii=False,indent=2))
if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--project",required=True)
    p.add_argument("--nav-script",required=True)
    a=p.parse_args()
    run(Path(a.project),Path(a.nav_script))
