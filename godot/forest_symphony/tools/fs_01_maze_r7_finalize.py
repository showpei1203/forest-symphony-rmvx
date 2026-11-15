#!/usr/bin/env python3
"""FS_01_MAZE R7 portable owner-only Godot native source+GPU QA release.

Reuses exact private A36B R2 173 ZIP members and adds R7 reconciled source,
two original Godot 2560x1856 GPU captures, actual original GPU pixel QA, test
sources, errors and Handoff. No original private PNG ever enters public GitHub.
"""
import argparse,hashlib,json,zipfile
from pathlib import Path
from PIL import Image
BASE_NAME="FS_A36B_GODOT_80x58_TREE_ECOLOGY_PRIVATE_20261114.zip"
OUT_NAME="FS_12_MAP_FACTORY_V1_FS01_MAZE_R7_NATIVE_PRIVATE_20261116.zip"
SHA_BASE="7e1cd53397aeb76deb09ceed0dc3002b5b7cc56c0a7fe40fac684a32eda6ac2b"
GROUND="private_assets/a36_ground_only_2560x1856.png"
SHADOW="private_assets/a36b_contact_shadows_2560x1856.png"
GROUND_SHA="ac591877b05c00543e6756e44e6ba81f6fea7e36086049e35de81e2610e0c911"
SHADOW_SHA="752c252b0ac48961a164943749b421172ad775d2fe0e1329faa748219ff63ffa"
BASE_SCENE="scenes/a36b_large_forest_tree_ecology_80x58.tscn"
R6_SCENE="scenes/a36c_r6_forest_groves_80x58.tscn"
R7_SCENE="scenes/fs_01_maze_a36c_r7_reconciled_80x58.tscn"
QA_FILES=[
"FS_FOREST_DUNGEON_A36B_BASE_NATIVE_1X.png",
"FS_FOREST_DUNGEON_FS_01_MAZE_R7_RECONCILED_NATIVE_1X.png",
"FS_01_MAZE_R7_NATIVE_GPU_ROI.json",
"FS_01_MAZE_R7_SOURCE_QA.json"
]
LOGS=[
"FS_01_MAZE_R7_SOURCE_STDOUT.log",
"FS_01_MAZE_R7_GPU_STDOUT.log"
]
def sha(x):return hashlib.sha256(x).hexdigest()
def logbytes(p):
    b=p.read_bytes()
    return b.decode("utf-16",errors="replace").encode("utf-8") if b.startswith((b"\xff\xfe",b"\xfe\xff")) else b

def pack(root,work,repo_texts):
    source=root/BASE_NAME
    if sha(source.read_bytes())!=SHA_BASE:
        raise RuntimeError("A36B private archive checksum mismatch")
    project=work/"godot_project"
    with zipfile.ZipFile(source) as z:
        if z.testzip() is not None:raise RuntimeError("A36B archive CRC failed")
        members={name:z.read(name) for name in z.namelist()}
    baseline_scene=members[BASE_SCENE]
    ground_bytes=members[GROUND]
    shadow_bytes=members[SHADOW]
    if sha(ground_bytes)!=GROUND_SHA or sha(shadow_bytes)!=SHADOW_SHA:
        raise RuntimeError("Historical map Ground or SHADOW altered")
    # Versioned source scene + manifest (A36C R6 and the safe reconciled R7).
    source_paths=[
        "scenes/a36c_r6_forest_groves_80x58.tscn",
        R7_SCENE,
        "data/a36c_r6_forest_groves_manifest.json",
        "data/fs_01_maze_a36c_r7_reconciled_manifest.json",
        "tests/test_fs_01_maze_r7_native.gd",
        "tests/capture_fs_01_maze_r7_native.gd"
    ]
    for f in source_paths:members[f]=(project/f).read_bytes()
    for name in QA_FILES:
        path=project/"qa_a36c"/name
        if name.endswith(".png"):
            with Image.open(path) as im:
                if im.size!=(2560,1856):raise RuntimeError("Actual Godot original 1x image invalid")
        members["qa_a36c/"+name]=path.read_bytes()
    roi=json.loads(members["qa_a36c/FS_01_MAZE_R7_NATIVE_GPU_ROI.json"])
    if (roi.get("shifted_object_count")!=56 or roi.get("outside_union_roi")!=0 or
        roi.get("inside_56_tree_union_roi")!=910809 or not roi.get("pixel_isolation_pass")):
        raise RuntimeError("R7 actual-GPU ROI no longer matches sealed source")
    for name in LOGS:
        logs=logbytes(work/name)
        need="PASS"
        if need.encode() not in logs:raise RuntimeError("Native Godot success log missing "+name)
        members["qa_a36c/"+name]=logs
    for name in ("fs_01_maze_a36c_r7_merge.py","fs_01_maze_r7_gpu_qa.py","fs_01_maze_r7_finalize.py"):
        members["tools/"+name]=(work/name).read_bytes()
    for name in ("FS_12_MAP_ACTIVE_MASTER_20261116.md",
                 "FS_12_MAP_FACTORY_V1_NATIVE_HANDOFF_20261116.md",
                 "FS_12_MAP_FACTORY_V1_FAILURE_LOG_20261116.md"):
        members["docs/"+name]=(repo_texts/name).read_bytes()
    members["data/fs_12_map_catalog.json"]=(repo_texts/"fs_12_map_catalog.json").read_bytes()
    original_project=members["project.godot"]
    project_out=(project/"project.godot").read_bytes()
    if ("res://"+R7_SCENE).encode() not in project_out:
        raise RuntimeError("Full R7 project main scene wrong")
    members["project.godot"]=project_out
    # A36B baseline is immutable byte for byte. R7 only adds a new scene.
    handoff=members.get("CURRENT_HANDOFF.md",b"")
    release_info={
      "scene_id":"FS_01_MAZE","name":"幽葉迴廊",
      "source":"A36B R2 private + A36C R6 footprint moves only",
      "original_A36B_archive_SHA256":SHA_BASE,
      "original_A36B_scene_SHA256":sha(baseline_scene),
      "original_original_project_SHA256":sha(original_project),
      "R7_new_scene_SHA256":sha(members[R7_SCENE]),
      "Ground_SHA256":GROUND_SHA,"Shadow_SHA256":SHADOW_SHA,
      "asset_source_conflicts_prevented":40,
      "moved_tree_footpoints":56,"independent_PAR":326,"trees":310,
      "real_Godot_GPU_original_frames":2,"pixel_changed_inside_ROI":910809,
      "pixel_changed_outside_ROI":0,
      "source":"PASS","native_gpu":"PASS","navigation":"HOLD",
      "water":"HOLD","art":"HOLD","formal_map_seal":False
    }
    members["qa_a36c/FS_01_MAZE_R7_RELEASE_MANIFEST.json"]=(json.dumps(release_info,ensure_ascii=False,indent=2)+"\n").encode()
    members["CURRENT_HANDOFF.md"]=(
        "# FS_01_MAZE R7 | 2026-11-16 | GODOT NATIVE GPU PASS, ART/ROUTE/WATER HOLD\n"
        "Second of twelve canonical map slots, first large forest dungeon source candidate.\n"
        "Read docs/FS_12_MAP_FACTORY_V1_NATIVE_HANDOFF_20261116.md and "
        "docs/FS_12_MAP_FACTORY_V1_FAILURE_LOG_20261116.md before any edits.\n"
        "Do not overwrite A36B historical baseline, A36C parallel branch or R8 R3 village.\n"
        "Actual Godot full 2560x1856 GPU x2, 56 moved tree owners, 326 PAR, "
        "910809 changed pixels all inside tree ROI and 0 outside.\n"
        "Still lacks river hazard, maze routes and visual art approval.\n\n---\n"
    ).encode()+handoff
    out=root/OUT_NAME
    with zipfile.ZipFile(out,"w",compression=zipfile.ZIP_DEFLATED,compresslevel=6) as z:
        for name,payload in members.items():z.writestr(name,payload)
    with zipfile.ZipFile(out) as z:
        if z.testzip() is not None:raise RuntimeError("Final ZIP CRC fail")
        if z.read(BASE_SCENE)!=baseline_scene or z.read(GROUND)!=ground_bytes or z.read(SHADOW)!=shadow_bytes:
            raise RuntimeError("Historical private assets not byte-identical")
        if z.read(R7_SCENE)!=members[R7_SCENE]:raise RuntimeError("R7 scene was not packaged")
    print(json.dumps({"output":str(out),"members":len(members),"bytes":out.stat().st_size,
       "sha256":sha(out.read_bytes()),"qa":release_info},ensure_ascii=False,indent=2))

if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--root",required=True);p.add_argument("--work",required=True);p.add_argument("--repo-texts",required=True)
    a=p.parse_args();pack(Path(a.root),Path(a.work),Path(a.repo_texts))
