#!/usr/bin/env python3
"""FS_01_MAZE R9: seal actual native-Godot foot collision route survey evidence.

Owner-only DELTA artifact, not full playable project. Keep 91.98MB R8 private
project and original Godot PNGs separate; do not put user art on public GitHub.
"""
import argparse,hashlib,json,zipfile
from pathlib import Path
from PIL import Image
BASE_SHA="bcafbe212c101ddcfbdb5de5d31d3bf69ee9d2e3c6c447fcc90f8f50a972895b"
BASE="FS_01_MAZE_R8_WATER_NATIVE_FULL_GODOT_PRIVATE_20261116.zip"
FINAL="FS_01_MAZE_R9_NATIVE_PHYSICS_ROUTE_SURVEY_PRIVATE_20261116.zip"
def sha(b):return hashlib.sha256(b).hexdigest()
def log_bytes(p):
    d=p.read_bytes()
    if d.startswith((b"\xff\xfe",b"\xfe\xff")):
        return d.decode("utf16",errors="replace").encode("utf8")
    return d
def seal(root:Path,work:Path,docs:Path):
    if sha((root/BASE).read_bytes())!=BASE_SHA:
        raise ValueError("Original full R8 owner-only Godot source SHA mismatch")
    survey=work/"FS_01_MAZE_R9_ACTUAL_PHYSICS_ROUTE_SURVEY.json"
    report=json.loads(survey.read_text(encoding="utf8"))
    if len(report["obstacle_rows_water_tilde_other_collision_hash_clear_dot"])!=58:
        raise RuntimeError("Native 80x58 physics collision scan incomplete")
    if report["water_physics_tiles"]!=148 or report["candidate_test_count"]!=5 or report["connected_candidate_routes"]!=5:
        raise RuntimeError("Godot candidate route regression")
    for item in report["candidate_routes"]:
        if not item["pass"] or item["length_cells"]!=len(item["path"]):
            raise RuntimeError("Bad route length/provenance "+repr(item["from"]))
    stdout=log_bytes(work/"FS_01_MAZE_R9_ROUTE_SURVEY_STDOUT.log")
    if b"FS_01_MAZE R9 GODOT PHYSICS SURVEY PASS" not in stdout or b"4640" not in stdout:
        raise RuntimeError("No actual Godot official route PASS log")
    preview=work/"FS_01_MAZE_R9_GODOT_PHYSICS_ROUTES_DERIVED_1X.png"
    with Image.open(preview) as im:
        if im.size!=(2560,1856):raise ValueError("Derived route debug must use full native map resolution")
    files={
      "README.txt":(
       "Forest Symphony FS_01_MAZE R9: Godot ACTUAL PHYSICS GRID SURVEY.\n"
       "This ZIP is EVIDENCE ONLY, NOT a standalone Godot project.\n"
       "Full original owner-only R8 Godot project: https://drive.google.com/file/d/19uk8jdZTTkLWVky1qbnD08vMiDzjPDLI/view\n"
       "Original Godot full project SHA256 "+BASE_SHA+"\n"
       "5/5 CONNECTED candidates do NOT equal formal visually accurate roads.\n"
       "The PNG route overlay is DERIVED debug, NOT original game art/GPU framebuffer.\n"
       "Important visual issue: some raw AStar shortest paths cut through vegetation instead of painted winding roads.\n"
      ).encode(),
      "native_Godot_QA/FS_01_MAZE_R9_ACTUAL_PHYSICS_ROUTE_SURVEY.json":survey.read_bytes(),
      "native_Godot_QA/FS_01_MAZE_R9_ROUTE_SURVEY_STDOUT.log":stdout,
      "source/test_fs_01_maze_r9_route_survey.gd":(work/"R8_FULL_COLD_REBUILD_VALIDATION/tests/test_fs_01_maze_r9_route_survey.gd").read_bytes(),
      "source/fs_01_maze_r9_route_overlay.py":(work/"fs_01_maze_r9_route_overlay.py").read_bytes(),
      "DERIVED_ART_DEBUG_NOT_GAME_FRAME/FS_01_MAZE_R9_GODOT_PHYSICS_ROUTES_DERIVED_1X.png":preview.read_bytes(),
      "docs/FS_01_MAZE_R9_ROUTE_SURVEY_HANDOFF_20261116.md":(docs/"FS_01_MAZE_R9_ROUTE_SURVEY_HANDOFF_20261116.md").read_bytes(),
      "docs/FS_01_MAZE_R9_ROUTE_FAILURE_LOG_20261116.md":(docs/"FS_01_MAZE_R9_ROUTE_FAILURE_LOG_20261116.md").read_bytes()
    }
    manifest={
      "original_Godot_4_7_2_footprint_grid_samples":4640,
      "footprint_pixels":[13,9],
      "river_collision_tiles":148,
      "candidate_route_connections":5,
      "candidate_route_total":5,
      "full_source_R8_SHA256":BASE_SHA,
      "semantic_roads":"HOLD (visual inspection found cut-through shortcuts)",
      "formal_route_navigation":"HOLD",
      "art":"HOLD",
      "standalone":False
    }
    files["FS_01_MAZE_R9_EVIDENCE_MANIFEST.json"]=(json.dumps(manifest,indent=2)+"\n").encode()
    output=root/FINAL
    with zipfile.ZipFile(output,"w",compression=zipfile.ZIP_DEFLATED,compresslevel=6) as z:
        for p,b in files.items():z.writestr(p,b)
    with zipfile.ZipFile(output) as z:
        if z.testzip() is not None:raise RuntimeError("R9 evidence ZIP CRC failure")
    print(json.dumps({"output":str(output),"entries":len(files),"bytes":output.stat().st_size,
        "sha256":sha(output.read_bytes()),"evidence":manifest},ensure_ascii=False,indent=2))
if __name__=="__main__":
    p=argparse.ArgumentParser()
    for n in ("root","work","docs"):p.add_argument("--"+n,required=True)
    a=p.parse_args()
    seal(Path(a.root),Path(a.work),Path(a.docs))
