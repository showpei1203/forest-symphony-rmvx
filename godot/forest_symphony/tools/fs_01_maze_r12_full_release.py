#!/usr/bin/env python3
"""FS_01_MAZE R12 FULL standalone private Godot release from immutable R8 source.

Maintains all original privately owned Ground, Shadow and full whole-object
PAR asset bytes. Includes actual R9-R12 physics, original GPU and runtime QA,
real R12 LIVE RoadNavigator scene and private road-semantic data.
"""
import argparse,hashlib,json,zipfile
from pathlib import Path
from PIL import Image

BASE="FS_01_MAZE_R8_WATER_NATIVE_FULL_GODOT_PRIVATE_20261116.zip"
BASE_SHA="bcafbe212c101ddcfbdb5de5d31d3bf69ee9d2e3c6c447fcc90f8f50a972895b"
OUT="FS_01_MAZE_R12_LIVE_ROAD_NAV_FULL_GODOT_PRIVATE_20261116.zip"
GROUND="private_assets/a36_ground_only_2560x1856.png"
GROUND_SHA="ac591877b05c00543e6756e44e6ba81f6fea7e36086049e35de81e2610e0c911"
SHADOW="private_assets/a36b_contact_shadows_2560x1856.png"
SHADOW_SHA="752c252b0ac48961a164943749b421172ad775d2fe0e1329faa748219ff63ffa"
R8="scenes/fs_01_maze_r8_water_collision_80x58.tscn"
R8_SHA="bb7f1b565419977c0851e4a188531b3426128758a098251bd151805e0e9fbfec"
R12="scenes/fs_01_maze_r12_live_road_navigation_80x58.tscn"
R12_SHA="54224083a741bf4d451c9d44674d48fae68e399eac856c31b31c15c10457c392"
ROAD="data/fs_01_maze_r10_ground_road_confidence.json"
ROAD_SHA="d442540efe2b45389aed99e77a3ddc81129201ec891404cbf785dc02234f54ec"

ADDITIONAL_PROJECT=[
 R12,
 "scripts/fs_01_maze_r12_runtime_road_navigator.gd",
 ROAD,
 "data/fs_01_maze_r12_navigation_manifest.json",
 "tests/test_fs_01_maze_r9_route_survey.gd",
 "tests/test_fs_01_maze_r10_road_weighted_native.gd",
 "tests/test_fs_01_maze_r11_actor_sweep_native.gd",
 "tests/test_fs_01_maze_r12_runtime_navigation_native.gd",
 "tests/capture_fs_01_maze_r12_native.gd",
 "qa_a36c/FS_01_MAZE_R9_ACTUAL_PHYSICS_ROUTE_SURVEY.json",
 "qa_a36c/FS_01_MAZE_R10_GODOT_ROAD_WEIGHTED_ROUTES.json",
 "qa_a36c/FS_01_MAZE_R11_ACTUAL_GODOT_ACTOR_SWEEP.json",
 "qa_a36c/FS_01_MAZE_R12_ORIGINAL_GPU_PIXEL_QA.json",
 "qa_a36c/FS_01_MAZE_R12_R8_BASE_NATIVE_GPU_1X.png",
 "qa_a36c/FS_01_MAZE_R12_R12_LIVE_NAV_NATIVE_GPU_1X.png"
]
ADDITIONAL_WORK=[
 "fs_01_maze_r10_road_confidence.py",
 "fs_01_maze_r10_visual_qa.py",
 "fs_01_maze_r12_navigation_scene_build.py",
 "fs_01_maze_r12_gpu_pixel_qa.py",
 "fs_01_maze_r9_route_overlay.py"
]
LOGS=[
 "FS_01_MAZE_R9_ROUTE_SURVEY_STDOUT.log",
 "FS_01_MAZE_R10_NATIVE_STDOUT.log",
 "FS_01_MAZE_R11_PLAYER_SWEEP_NATIVE_STDOUT.log",
 "FS_01_MAZE_R12_RUNTIME_STDOUT.log",
 "FS_01_MAZE_R12_GPU_STDOUT.log"
]
DOCS=[
 "FS_12_MAP_ACTIVE_MASTER_20261116.md",
 "FS_01_MAZE_R12_LIVE_NAV_NATIVE_HANDOFF_20261116.md",
 "FS_01_MAZE_R12_LIVE_NAV_FAILURE_LOG_20261116.md",
 "fs_12_map_catalog.json"
]
def sha(b):return hashlib.sha256(b).hexdigest()
def log_utf8(path):
    b=path.read_bytes()
    if b.startswith((b"\xff\xfe",b"\xfe\xff")):
        return b.decode("utf16",errors="replace").encode("utf8")
    return b

def run(root:Path,work:Path,docs:Path):
    base=root/BASE
    if sha(base.read_bytes())!=BASE_SHA:
        raise RuntimeError("Sealed original private R8 full Godot ZIP source SHA changed")
    with zipfile.ZipFile(base) as z:
        if z.testzip() is not None:raise RuntimeError("Original sealed R8 zip CRC failed")
        members={n:z.read(n) for n in z.namelist()}
    original={k:members[k] for k in (GROUND,SHADOW,R8)}
    if sha(original[GROUND])!=GROUND_SHA or sha(original[SHADOW])!=SHADOW_SHA or sha(original[R8])!=R8_SHA:
        raise RuntimeError("Original Ground/Shadow/R8 scene byte integrity failed")
    project=work/"R8_FULL_COLD_REBUILD_VALIDATION"
    for path in ADDITIONAL_PROJECT:
        src=project/path
        if not src.exists():raise RuntimeError("Missing reproducible project source: "+path)
        if path in members and members[path]!=src.read_bytes():
            raise RuntimeError("R12 accidentally attempts to overwrite prior source "+path)
        members[path]=src.read_bytes()
    if sha(members[R12])!=R12_SHA or sha(members[ROAD])!=ROAD_SHA:
        raise RuntimeError("R12 scene or Ground-derived road SHA mismatch")
    for name in ADDITIONAL_WORK:
        src=work/name
        if not src.exists():raise RuntimeError("Missing authored reproducible script "+name)
        members["tools/"+name]=src.read_bytes()
    for name in LOGS:
        log=log_utf8(work/name)
        if name.endswith("R10_NATIVE_STDOUT.log") and b"GODOT NATIVE ROAD WEIGHT PASS" not in log:
            raise RuntimeError("R10 real native road test missing")
        if name.endswith("R11_PLAYER_SWEEP_NATIVE_STDOUT.log") and b"231 complete" not in log:
            raise RuntimeError("R11 real Player 231 movement test missing")
        if name.endswith("R12_RUNTIME_STDOUT.log") and b"NATIVE LIVE ROAD NAV PASS" not in log:
            raise RuntimeError("R12 actual runtime API integration test missing")
        if name.endswith("R12_GPU_STDOUT.log") and b"PASS 2/2" not in log:
            raise RuntimeError("R12 two original GPU frames missing")
        members["qa_a36c/native_logs/"+name]=log
    for name in DOCS:
        fp=docs/name
        if not fp.exists():raise RuntimeError("Missing official Handoff "+name)
        key=("data/" if name.endswith(".json") else "docs/")+name
        members[key]=fp.read_bytes()
    # Confirm native artifact semantics, do not promote ART or route statuses.
    r10=json.loads(members["qa_a36c/FS_01_MAZE_R10_GODOT_ROAD_WEIGHTED_ROUTES.json"])
    r11=json.loads(members["qa_a36c/FS_01_MAZE_R11_ACTUAL_GODOT_ACTOR_SWEEP.json"])
    gpu=json.loads(members["qa_a36c/FS_01_MAZE_R12_ORIGINAL_GPU_PIXEL_QA.json"])
    catalog=json.loads(members["data/fs_12_map_catalog.json"])
    forest=next(x for x in catalog["maps"] if x["id"]=="forest_dungeon")
    if (
       r10["route_candidate_pass_count"]!=5 or
       r11["segments_checked"]!=231 or r11["colliding_segments"]!=0 or
       gpu["rgb_changed_pixel_count"]!=0 or
       forest["gates"]["live_runtime_navigator"]!="PASS_5_OF_5" or
       forest["gates"]["final_seal"]!=False
    ):
        raise RuntimeError("R12 release tries to upgrade incomplete art or lacks native QA")
    for n in ("qa_a36c/FS_01_MAZE_R12_R8_BASE_NATIVE_GPU_1X.png",
              "qa_a36c/FS_01_MAZE_R12_R12_LIVE_NAV_NATIVE_GPU_1X.png"):
        with Image.open(project/n) as image:
            if image.size!=(2560,1856):
                raise RuntimeError("Invalid original full Godot GPU screenshot "+n)
    # Original R9/R10 visual comparison only, a DERIVED review preview.
    original_art=work/"FS_01_MAZE_R10_ROAD_ALIGNED_DERIVED_GPU_AB.png"
    if original_art.exists():
        members["qa_a36c/DERIVED_NOT_ORIGINAL_GPU/FS_01_MAZE_R10_ROAD_ALIGNED_DERIVED_GPU_AB.png"]=original_art.read_bytes()
    visual_report=work/"FS_01_MAZE_R10_VISUAL_ROUTE_QA.json"
    if visual_report.exists():
        members["qa_a36c/FS_01_MAZE_R10_VISUAL_ROUTE_QA.json"]=visual_report.read_bytes()
    main=project/"project.godot"
    if ("res://"+R12).encode() not in main.read_bytes():
        raise RuntimeError("R12 is not main live Godot scene")
    members["project.godot"]=main.read_bytes()
    release={
       "engine":"Godot 4.7.2",
       "canonical_scene":"FS_01_MAZE 幽葉迴廊",
       "canonical_six_biome_total_maps":12,
       "full_prior_R8_sha256":BASE_SHA,
       "original_Ground_sha256":GROUND_SHA,
       "original_Shadow_sha256":SHADOW_SHA,
       "original_R8_scene_sha256":R8_SHA,
       "new_R12_scene_sha256":R12_SHA,
       "road_semantic_ground_confidence_sha256":ROAD_SHA,
       "real_Godot_physics_grid":4640,
       "actual_water_StaticBody2D":148,
       "native_road_aligned_routes":5,
       "native_original_Player_test_move_segments":231,
       "native_Player_sweep_collision":0,
       "native_live_runtime_route_api":"PASS 5/5 exact paths",
       "actual_Godot_GPU_frames":2,
       "GPU_pixels_changed":0,
       "formal_maze_entrance_exit":"HOLD",
       "ART":"HOLD",
       "remaining_10_biome_village_dungeon_maps":"PLANNED",
       "private_owner_only":True
    }
    members["qa_a36c/FS_01_MAZE_R12_FULL_RELEASE_MANIFEST.json"]=(json.dumps(release,ensure_ascii=False,indent=2)+"\n").encode("utf8")
    top=(
       "# Forest Symphony | FS_01_MAZE R12 | 2026-11-16\n"
       "ENGINE/LIVE GODOT RUNTIME PASS · 4640 foot physics · 148 river · 5 roads · "
       "231 real Player sweeps · R8/R12 ORIGINAL GPU zero pixel difference.\n"
       "ART HOLD · formal maze path entrance/exit and gameplay event integration HOLD.\n"
       "Read docs/FS_01_MAZE_R12_LIVE_NAV_NATIVE_HANDOFF_20261116.md and "
       "docs/FS_01_MAZE_R12_LIVE_NAV_FAILURE_LOG_20261116.md.\n"
       "Original full A36B Ground, Shadow, R8 scenes and independent PAR are unchanged. "
       "Six biome pairs = 12 required core maps, 10 others not yet authored.\n\n---\n"
    )
    members["CURRENT_HANDOFF.md"]=top.encode("utf8")+members.get("CURRENT_HANDOFF.md",b"")
    output=root/OUT
    with zipfile.ZipFile(output,"w",zipfile.ZIP_DEFLATED,compresslevel=6) as z:
        for n,b in members.items():
            z.writestr(n,b)
    with zipfile.ZipFile(output) as z:
        if z.testzip() is not None:raise RuntimeError("R12 FULL ZIP CRC failed")
        for n,b in original.items():
            if z.read(n)!=b:raise RuntimeError("Historical original scene/art silently overwritten "+n)
        if sha(z.read(R12))!=R12_SHA:raise RuntimeError("R12 scene packed SHA mismatch")
    print(json.dumps({"file":str(output),"entries":len(members),"bytes":output.stat().st_size,
       "sha256":sha(output.read_bytes()),"qa_release":release},ensure_ascii=False,indent=2))
if __name__=="__main__":
    p=argparse.ArgumentParser()
    for n in ("root","work","docs"):p.add_argument("--"+n,required=True)
    a=p.parse_args()
    run(Path(a.root),Path(a.work),Path(a.docs))
