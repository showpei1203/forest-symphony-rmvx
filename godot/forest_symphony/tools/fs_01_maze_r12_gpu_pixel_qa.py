#!/usr/bin/env python3
"""FS_01_MAZE R12 real Godot GPU before/after pixel regression.

Both images are ORIGINAL 2560x1856 Godot 4.7.2 OpenGL framebuffers, actor
hidden and fixed camera. This does not draw/add/remove any visual pixels.
All input private screenshots remain only in owner-only Google Drive.
"""
import argparse,hashlib,json
from pathlib import Path
import numpy as np
from PIL import Image

BEFORE="FS_01_MAZE_R12_R8_BASE_NATIVE_GPU_1X.png"
AFTER="FS_01_MAZE_R12_R12_LIVE_NAV_NATIVE_GPU_1X.png"
OUT="FS_01_MAZE_R12_ORIGINAL_GPU_PIXEL_QA.json"
GROUND_SHA="ac591877b05c00543e6756e44e6ba81f6fea7e36086049e35de81e2610e0c911"
R8_SHA="bb7f1b565419977c0851e4a188531b3426128758a098251bd151805e0e9fbfec"
R12_SHA="54224083a741bf4d451c9d44674d48fae68e399eac856c31b31c15c10457c392"
def sha(path:Path)->str:return hashlib.sha256(path.read_bytes()).hexdigest()
def run(project:Path):
    checks={
      "original_ground_sha":sha(project/"private_assets/a36_ground_only_2560x1856.png"),
      "original_r8_scene_sha":sha(project/"scenes/fs_01_maze_r8_water_collision_80x58.tscn"),
      "new_r12_scene_sha":sha(project/"scenes/fs_01_maze_r12_live_road_navigation_80x58.tscn")
    }
    if checks["original_ground_sha"]!=GROUND_SHA or checks["original_r8_scene_sha"]!=R8_SHA or checks["new_r12_scene_sha"]!=R12_SHA:
        raise RuntimeError("Source Ground/R8/R12 scene SHA mismatch")
    images=[]
    for name in (BEFORE,AFTER):
        with Image.open(project/"qa_a36c"/name) as im:
            if im.size!=(2560,1856):raise ValueError("Not original full 2560x1856 Godot frame")
            images.append(np.asarray(im.convert("RGB"),dtype=np.uint8))
    changed=int(np.any(images[0]!=images[1],axis=2).sum())
    report={
       "engine":"Godot 4.7.2 official OpenGL compatibility Radeon RX 6700 XT",
       "source":"two ORIGINAL 2560x1856 Godot GPU framebuffers, same camera and actor hidden",
       "base_scene":"FS_01_MAZE R8 148 river colliders",
       "new_scene":"FS_01_MAZE R12 live road runtime navigator",
       "total_tested_pixels":2560*1856,
       "rgb_changed_pixel_count":changed,
       "source_sha":checks,
       "GPU_visual_regression":"PASS" if changed==0 else "FAIL",
       "native_R12_runtime_nav":"native source test and actual 231-player-foot sweep separately required",
       "ART":"HOLD (new navigation is not improved original pixel artwork)"
    }
    (project/"qa_a36c"/OUT).write_bytes((json.dumps(report,indent=2)+"\n").encode("utf8"))
    print(json.dumps(report,indent=2))
    if changed!=0:raise SystemExit(83)
if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--project",required=True)
    run(Path(p.parse_args().project))
