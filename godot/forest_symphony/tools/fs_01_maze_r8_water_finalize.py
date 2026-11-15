#!/usr/bin/env python3
"""FS_01_MAZE R8 owner-only Godot water collision patch / actual GPU evidence.

Apply this patch over sealed R7B FULL Godot project. Not standalone.
The original PNG artwork remains in the separate verified R7B archive.
"""
import argparse,hashlib,json,zipfile
from pathlib import Path
from PIL import Image

BASE="FS_12_MAP_FACTORY_V1_FS01_MAZE_R7B_UTF8_NATIVE_PRIVATE_20261116.zip"
BASE_SHA="de0e2039327b234b3adffa2ab110fbaf7620022f566febb5c66cf618c912ded5"
OUT="FS_01_MAZE_R8_WATER_PHYSICS_NATIVE_PATCH_PRIVATE_20261116.zip"
GROUND="private_assets/a36_ground_only_2560x1856.png"
GROUND_SHA="ac591877b05c00543e6756e44e6ba81f6fea7e36086049e35de81e2610e0c911"
OLD="scenes/fs_01_maze_a36c_r7_reconciled_80x58.tscn"
NEW="scenes/fs_01_maze_r8_water_collision_80x58.tscn"
GPU=[
 "FS_FOREST_DUNGEON_WATER_FS_01_MAZE_R7_BASE_NATIVE_1X.png",
 "FS_FOREST_DUNGEON_WATER_FS_01_MAZE_R8_WATER_NATIVE_1X.png"
]
LOGS=[
 "FS_01_MAZE_R8_IMPORT_STDOUT.log",
 "FS_01_MAZE_R8_PHYSICS_STDOUT.log",
 "FS_01_MAZE_R8_GPU_STDOUT.log"
]
def sha(b):return hashlib.sha256(b).hexdigest()
def readlog(path):
    raw=path.read_bytes()
    if raw.startswith((b"\xff\xfe",b"\xfe\xff")):
        return raw.decode("utf-16",errors="replace").encode("utf-8")
    return raw
def pack(root:Path,work:Path,docs:Path):
    project=work/"godot_project"
    base=root/BASE
    if sha(base.read_bytes())!=BASE_SHA:raise RuntimeError("Verified private baseline R7B ZIP changed")
    with zipfile.ZipFile(base) as z:
        if z.testzip() is not None:raise RuntimeError("Original complete forest project ZIP CRC error")
        prior=z.read(OLD)
        prior_ground=z.read(GROUND)
    if sha(prior_ground)!=GROUND_SHA or project.joinpath(OLD).read_bytes()!=prior:
        raise RuntimeError("Original Ground or original R7 source scene drift")
    files={
      "RELEASE_README.txt":(
       "FS_01_MAZE R8 | Godot 4.7.2 water physics patch, NOT STANDALONE.\n"
       "Download owner-only R7B complete private project:\n"
       "https://drive.google.com/file/d/1vCUPIBc6Yv3vtc3Wy7cDRBvI8Y65-9wf/view\n"
       "Original full ZIP SHA256 "+BASE_SHA+"\n"
       "Overlay these files onto R7B project, then set main scene to "+NEW+"\n"
       "No original Ground/shadow/whole-object PAR files included or overwritten.\n"
       "Collision=148 candidate river tiles / all physics center queries PASS.\n"
       "Complete maze entrances/exits/bridges and WATER ART are still HOLD.\n"
      ).encode("utf-8"),
      NEW:project.joinpath(NEW).read_bytes(),
      "scripts/fs_01_maze_r8_water_collision.gd":project.joinpath("scripts/fs_01_maze_r8_water_collision.gd").read_bytes(),
      "data/fs_01_maze_r8_water_collision_manifest.json":project.joinpath("data/fs_01_maze_r8_water_collision_manifest.json").read_bytes(),
      "tests/test_fs_01_maze_r8_water_native.gd":project.joinpath("tests/test_fs_01_maze_r8_water_native.gd").read_bytes(),
      "tests/capture_fs_01_maze_r8_water_native.gd":project.joinpath("tests/capture_fs_01_maze_r8_water_native.gd").read_bytes(),
      "qa/FS_01_MAZE_R8_WATER_NATIVE_GPU_QA.json":project.joinpath("qa_a36c/FS_01_MAZE_R8_WATER_NATIVE_GPU_QA.json").read_bytes(),
      "docs/FS_01_MAZE_R8_WATER_NATIVE_HANDOFF_20261116.md":(docs/"FS_01_MAZE_R8_WATER_NATIVE_HANDOFF_20261116.md").read_bytes(),
      "docs/FS_01_MAZE_R8_WATER_FAILURE_LOG_20261116.md":(docs/"FS_01_MAZE_R8_WATER_FAILURE_LOG_20261116.md").read_bytes(),
      "data/fs_12_map_catalog.json":(docs/"fs_12_map_catalog.json").read_bytes()
    }
    for n in ("fs_01_maze_r8_water_build.py","fs_01_maze_r8_water_gpu_qa.py"):
        files["tools/"+n]=(work/n).read_bytes()
    for n in GPU:
        frame=project/"qa_a36c"/n
        with Image.open(frame) as im:
            if im.size!=(2560,1856):raise RuntimeError("Not true 2560x1856 Godot GPU frame")
        files["original_Godot_GPU/"+n]=frame.read_bytes()
    for n in LOGS:
        text=readlog(work/n)
        if n.endswith("_PHYSICS_STDOUT.log"):
            if b"148/148" not in text or b"GODOT WATER PHYSICS PASS" not in text:
                raise RuntimeError("Godot 148/148 physical hit proof missing")
        if n.endswith("_GPU_STDOUT.log") and b"PASS 2/2" not in text:
            raise RuntimeError("Original Godot R7/R8 GPU proof missing")
        files["native_logs/"+n]=text
    report=json.loads(files["qa/FS_01_MAZE_R8_WATER_NATIVE_GPU_QA.json"])
    if report["original_GPU_changed_pixels"]!=0 or report["river_semantic_original_cells"]!=148 or not report["river_unique_and_in_bounds"]:
        raise RuntimeError("Physics-only visual or water cell QA regression")
    water=json.loads(files["data/fs_01_maze_r8_water_collision_manifest.json"])
    if water["water_candidate_tiles"]!=148:
        raise RuntimeError("148-water manifest missing")
    manifest={
       "scene_id":"FS_01_MAZE","canonical_name":"幽葉迴廊",
       "full_original_R7B_archive":BASE,"full_original_R7B_sha256":BASE_SHA,
       "original_R7_scene_sha256":sha(prior),
       "new_R8_scene_sha256":sha(files[NEW]),
       "original_Ground_SHA256":GROUND_SHA,
       "actual_Godot_148_of_148_water_physics":"PASS",
       "original_native_GPU_two_frames":"PASS",
       "visual_R7_vs_R8_changed_pixels":0,
       "original_owner_PAR":326,"trees":310,"art":"HOLD",
       "maze_routes":"HOLD","bridge_crossing":"HOLD","animated_water":"NOT_IMPLEMENTED",
       "standalone":False,"owner_only":True
    }
    files["FS_01_MAZE_R8_PATCH_MANIFEST.json"]=(json.dumps(manifest,ensure_ascii=False,indent=2)+"\n").encode("utf-8")
    output=root/OUT
    with zipfile.ZipFile(output,"w",zipfile.ZIP_DEFLATED,compresslevel=6) as z:
        for n,b in files.items():z.writestr(n,b)
    with zipfile.ZipFile(output) as z:
        if z.testzip() is not None:raise RuntimeError("Water patch CRC error")
        if sha(z.read(NEW))!=manifest["new_R8_scene_sha256"]:
            raise RuntimeError("Water patch scene integrity error")
    print(json.dumps({"file":str(output),"members":len(files),"bytes":output.stat().st_size,
        "sha256":sha(output.read_bytes()),"release":manifest},ensure_ascii=False,indent=2))

if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--root",required=True);p.add_argument("--work",required=True);p.add_argument("--docs",required=True)
    a=p.parse_args()
    pack(Path(a.root),Path(a.work),Path(a.docs))
