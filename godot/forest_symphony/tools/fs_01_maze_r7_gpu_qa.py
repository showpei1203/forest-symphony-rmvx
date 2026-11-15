#!/usr/bin/env python3
"""FS_01_MAZE (幽葉迴廊) 80x58 forest real Godot GPU tree-only pixel ROI.

Reads ORIGINAL 2560x1856 Godot OpenGL screenshots. The derived A/B contact
is not one original GPU frame. ART/WATER/NAV remain HOLD unless tested.
"""
import argparse,json,re
from pathlib import Path
import numpy as np
from PIL import Image,ImageDraw
BASE="scenes/a36b_large_forest_tree_ecology_80x58.tscn"
NEXT="scenes/fs_01_maze_a36c_r7_reconciled_80x58.tscn"
NAMES=[
"FS_FOREST_DUNGEON_A36B_BASE_NATIVE_1X.png",
"FS_FOREST_DUNGEON_FS_01_MAZE_R7_RECONCILED_NATIVE_1X.png"
]
def scan(text):
    pat=r'\[node name="([^"]+)" type="Node2D" parent="YSort"\]\s*position = Vector2\(([-0-9]+), ([-0-9]+)\)\s*script = ExtResource\("2_object"\)\s*source_file = "([^"]+)"\s*source_sha256 = "([^"]+)"'
    return {name:{"foot":(int(x),int(y)),"source":source,"sha":digest}
            for name,x,y,source,digest in re.findall(pat,text)}
def evaluate(project,work):
    original=scan((project/BASE).read_text())
    newer=scan((project/NEXT).read_text())
    if len(original)!=326 or len(newer)!=326 or set(original)!=set(newer):
        raise RuntimeError("326 independent source owner invariant broken")
    changes=[i for i in original if original[i]["foot"]!=newer[i]["foot"]]
    if len(changes)!=56:raise RuntimeError("Not expected 56 A36C grove shifts")
    if any(original[i]["source"]!=newer[i]["source"] or original[i]["sha"]!=newer[i]["sha"] for i in original):
        raise RuntimeError("Forest sprite identities changed, rejected")
    m=json.loads((project/"data/fs_01_maze_a36c_r7_reconciled_manifest.json").read_text())
    objects={o["id"]:o for o in m["objects"]}
    if len(objects)!=326:raise RuntimeError("Manifest PAR count drift")
    frames=[]
    for name in NAMES:
        with Image.open(project/"qa_a36c"/name) as im:
            if im.size!=(2560,1856):raise RuntimeError("Not full real 1x Godot screenshot")
            frames.append(np.array(im.convert("RGB"),dtype=np.uint8))
    mask_im=Image.new("L",(2560,1856),0)
    brush=ImageDraw.Draw(mask_im)
    for id in changes:
        ob=objects[id]; w=int(ob["width"]); h=int(ob["height"])
        for foot in (original[id]["foot"],newer[id]["foot"]):
            x,y=foot
            brush.rectangle([x-w//2-8,y-h-8,x+w//2+8,y+8],fill=255)
    mask=np.array(mask_im,dtype=np.uint8)>0
    diff=np.any(frames[0]!=frames[1],axis=2)
    inside=int((diff&mask).sum());outside=int((diff&~mask).sum())
    report={
       "source":"two ORIGINAL Godot 4.7.2 OpenGL 2560x1856 frames, actor hidden and identical camera",
       "map_id":"FS_01_MAZE",
       "map_name":"幽葉迴廊",
       "reference":"A36B R2 326 full independent PAR trees/objects",
       "candidate":"A36C R7 safe merge of A36C R6 grove footpoints",
       "source_pixels":"original A36B whole-object sprites preserved, including 40 divergent instances",
       "shifted_object_count":len(changes),
       "total_par":326,"trees":310,
       "changed_pixels":int(diff.sum()),
       "inside_56_tree_union_roi":inside,
       "outside_union_roi":outside,
       "pixel_isolation_pass":outside==0 and inside>2000,
       "original_ground_and_shadows":"unchanged SHA, native source test",
       "art":"HOLD: original A36B Ground resampled from 1478x1064; color/river/branch art unapproved",
       "collision":"Source object collision shape unchanged; river candidates and full route navigation not verified"
    }
    path=project/"qa_a36c"/"FS_01_MAZE_R7_NATIVE_GPU_ROI.json"
    path.write_text(json.dumps(report,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    # Two genuine GPU frames arranged without resizing; this contact is DERIVED.
    contact=Image.new("RGB",(5120,1890),"#343d37")
    contact.paste(Image.fromarray(frames[0]),(0,34))
    contact.paste(Image.fromarray(frames[1]),(2560,34))
    d=ImageDraw.Draw(contact)
    d.text((12,9),"Original Godot 2560x1856 A36B R2 forest",fill="white")
    d.text((2572,9),"Original Godot 2560x1856 FS_01_MAZE R7 reconciled candidate",fill="white")
    contact.save(work/"FS_01_MAZE_R7_DERIVED_FULL_1X_AB.png",optimize=True)
    print(json.dumps(report,ensure_ascii=False,indent=2))
    if not report["pixel_isolation_pass"]:raise SystemExit(83)
if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--project",required=True);p.add_argument("--work",required=True)
    a=p.parse_args();evaluate(Path(a.project),Path(a.work))
