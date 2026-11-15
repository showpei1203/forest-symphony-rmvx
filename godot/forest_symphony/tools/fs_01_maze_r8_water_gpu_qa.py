#!/usr/bin/env python3
"""FS_01_MAZE R8 physical-water integration exact Godot GPU art regression.

R7/R8 original native Godot 2560x1856 frame pixels must be identical because
water is collision ONLY. Creates clearly labeled DERIVED water grid debug.
"""
import argparse,json
from pathlib import Path
import numpy as np
from PIL import Image,ImageDraw
OLD="FS_FOREST_DUNGEON_WATER_FS_01_MAZE_R7_BASE_NATIVE_1X.png"
NEW="FS_FOREST_DUNGEON_WATER_FS_01_MAZE_R8_WATER_NATIVE_1X.png"
def run(project,work):
    imgs=[]
    for name in [OLD,NEW]:
        with Image.open(project/"qa_a36c"/name) as im:
            if im.size!=(2560,1856):raise ValueError("Not original 1x Godot GPU frame")
            imgs.append(np.asarray(im.convert("RGB"),dtype=np.uint8))
    delta=np.any(imgs[0]!=imgs[1],axis=2)
    pixels=int(delta.sum())
    m=json.loads((project/"data/a36_terrain_semantic_candidates.json").read_text(encoding="utf8"))
    cells=[(int(x),int(y)) for x,y in m["river_blocked_cells"]]
    unique=len(set(cells))
    if len(cells)!=148 or unique!=148:raise ValueError("Nonunique or missing 148 original river tiles")
    if any(x<0 or x>=80 or y<0 or y>=58 for x,y in cells):
        raise ValueError("River tile out of 80x58 bounds")
    summary={
        "engine":"Godot 4.7.2 native OpenGL compatibility real 2560x1856 GPU",
        "before":"FS_01_MAZE R7 original forest without semantic water blockers",
        "after":"FS_01_MAZE R8 with 148 exact StaticBody2D collision tiles",
        "original_GPU_changed_pixels":pixels,
        "pixel_gate":"PASS" if pixels==0 else "FAIL",
        "river_semantic_original_cells":len(cells),
        "river_unique_and_in_bounds":unique==148,
        "actual_native_physics_query":"148/148 center locations on collision layer passed separately in original Godot test",
        "route_gate":"HOLD: no proven maze start/end, bridge crossing or river-edge walkability",
        "art":"HOLD: candidate blue mask debug is a derived overlay, never part of actual Ground"
    }
    (project/"qa_a36c"/"FS_01_MAZE_R8_WATER_NATIVE_GPU_QA.json").write_text(
        json.dumps(summary,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    # DERIVED overlay, not a Godot rendering: visualize source water collision.
    source=Image.fromarray(imgs[1]).convert("RGBA")
    layer=Image.new("RGBA",source.size,(0,0,0,0))
    brush=ImageDraw.Draw(layer,"RGBA")
    for x,y in cells:
        px=x*32;py=y*32
        brush.rectangle([px,py,px+31,py+31],fill=(11,95,240,74),outline=(0,175,255,220),width=2)
    result=Image.alpha_composite(source,layer).convert("RGB")
    result.save(work/"FS_01_MAZE_R8_WATER_148_GRID_DEBUG_DERIVED.png",optimize=True)
    print(json.dumps(summary,ensure_ascii=False,indent=2))
    if pixels!=0:raise SystemExit(81)
if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--project",required=True);p.add_argument("--work",required=True)
    a=p.parse_args()
    run(Path(a.project),Path(a.work))
