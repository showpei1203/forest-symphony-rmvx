#!/usr/bin/env python3
"""FS_01_MAZE R10: deterministic original-Ground-only road confidence.

Road pixels are measured from owner-only ORIGINAL Ground RGB, never the
composited forest screenshot. Produces private 80x58 per-cell road confidence
for Godot 4.7.2 weighted AStarGrid2D while retaining real physical blockers.
No image pixels, PNGs, user artwork, or private source are published to GitHub.
This is route-semantic QA, not ART acceptance or a finished maze.
"""
import argparse,hashlib,json
from pathlib import Path
import numpy as np
from PIL import Image

GROUND_FILE="private_assets/a36_ground_only_2560x1856.png"
GROUND_SHA="ac591877b05c00543e6756e44e6ba81f6fea7e36086049e35de81e2610e0c911"
REPORT_FILE="qa_a36c/FS_01_MAZE_R9_ACTUAL_PHYSICS_ROUTE_SURVEY.json"
OUTPUT="data/fs_01_maze_r10_ground_road_confidence.json"
GRID=(80,58)
CELL=32

def digest(p:Path)->str:
    return hashlib.sha256(p.read_bytes()).hexdigest()

def confidence(project:Path):
    source=project/GROUND_FILE
    if digest(source)!=GROUND_SHA:
        raise ValueError("R10 must use byte-identical 2560x1856 original Ground-only source")
    with Image.open(source) as im:
        if im.size!=(2560,1856) or im.mode!="RGB":
            raise ValueError("Expected original RGB Ground at native runtime size")
        p=np.asarray(im,dtype=np.uint8).astype(np.float32)
    r,g,b=p[:,:,0],p[:,:,1],p[:,:,2]
    # Natural warm tan-brown gravel paths/clearings, not saturated green
    # vegetation nor blue water. Empirically audited with original 1x Ground.
    # Purely visual preference: physical collision is always authoritative.
    mask=(r>g*1.10)&(g>b*1.22)&(r>b*1.55)&(r>82)&(g>53)
    raw=mask.reshape(58,32,80,32).mean(axis=(1,3)).astype(np.float32)
    padded=np.pad(raw,((1,1),(1,1)),mode="edge")
    kernel=np.asarray(((1,2,1),(2,4,2),(1,2,1)),dtype=np.float32)/16.0
    smooth=np.zeros((58,80),dtype=np.float32)
    for dy in range(3):
        for dx in range(3):
            smooth+=padded[dy:dy+58,dx:dx+80]*kernel[dy,dx]
    smooth=np.clip(smooth,0,1)
    return raw,smooth

def main(project:Path):
    raw,smoothed=confidence(project)
    report_path=project/REPORT_FILE
    native=json.loads(report_path.read_text(encoding="utf-8"))
    if native["grid"]!=[80,58] or len(native["obstacle_rows_water_tilde_other_collision_hash_clear_dot"])!=58:
        raise ValueError("R9 native physics survey missing: do not invent physical collision map")
    old_scores={}
    for route in native["candidate_routes"]:
        path=route["path"]
        if not path:raise ValueError("No original R9 route path")
        old_scores[route["from"]+"__"+route["to"]]={
            "length":len(path),
            "mean_road_confidence":round(float(np.mean([smoothed[y,x] for x,y in path])),5),
            "mean_raw_ground_tan_fraction":round(float(np.mean([raw[y,x] for x,y in path])),5)
        }
    contents={
       "schema":"fs-01-maze-r10-ground-road-confidence/v1",
       "map_id":"FS_01_MAZE",
       "canonical_title":"幽葉迴廊",
       "grid":[80,58],
       "cell_px":32,
       "full_Ground_only_original_sha256":GROUND_SHA,
       "full_original_Ground_pixels":[2560,1856],
       "source_stage":"Original A36B R2 Ground preserved through R7 and R8; no artwork edited",
       "classification":"warm tan gravel/soil pixels with RGB r>1.10*g; g>1.22*b; r>1.55*b; r>82,g>53; 32x32 fractional coverage then 3x3 Gaussian-like kernel",
       "blur_kernel":"1 2 1 / 2 4 2 / 1 2 1, normalized 16",
       "native_physical_blockers":"DO NOT OVERRIDE: Godot 13x9 foot collision tests and actual 148 water blockers still mandatory",
       "weight_formula":"1 + 8 * max(0, 0.55 - road_confidence) / 0.55",
       "road_confidence":np.round(smoothed,5).tolist(),
       "baseline_R9_physics_route_scores":old_scores,
       "ground_art":"HOLD (original enlarged Ground); do not claim approved visual roads",
       "maze_design":"HOLD (entrances/exits/bridge crossings require formal QA)"
    }
    dest=project/OUTPUT
    dest.parent.mkdir(parents=True,exist_ok=True)
    dest.write_bytes((json.dumps(contents,ensure_ascii=False,indent=2)+"\n").encode("utf-8"))
    sample={
      "output":str(dest),"bytes":dest.stat().st_size,"sha256":digest(dest),
      "cells":80*58,"source_ground_sha256":GROUND_SHA,
      "road_confidence_quantiles":{str(q):round(float(np.quantile(smoothed,q)),5) for q in (0,.25,.5,.75,.9,1)},
      "original_physics_route_scores":old_scores,
      "note":"Ground visual semantic preference only; native Godot weighted path and real collision test NOT yet run"
    }
    print(json.dumps(sample,ensure_ascii=False,indent=2))
if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--project",required=True)
    main(Path(p.parse_args().project))
