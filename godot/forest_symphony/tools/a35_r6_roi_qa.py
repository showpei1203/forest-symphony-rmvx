#!/usr/bin/env python3
"""A35 R6 fixed-camera real Godot 1:1 ROI regression + actor depth.
Images MUST originate in Godot 4.7.2 SubViewport GPU output; this Python code
analyzes captures only, not a substitute renderer.
"""
import argparse,json,zipfile
from pathlib import Path
import numpy as np
from PIL import Image,ImageDraw

NAMES=[
"A35_R6_R5_BASELINE_NATIVE.png",
"A35_R6_ART_CANDIDATE_NATIVE.png",
"A35_R6_ACTOR_BEHIND_NATIVE.png",
"A35_R6_ACTOR_FRONT_NATIVE.png"
]
def run(archive,project,workspace):
    with zipfile.ZipFile(archive) as z:
        d=json.loads(z.read("data/a35_r6_conifer_manifest.json"))
        old=json.loads(z.read("data/a35_r5_botanical_forest_manifest.json"))
    ids=set(d["r6_modified_object_ids"])
    if len(ids)!=13:raise ValueError("Expected 13 conifer tree instances")
    current={o["id"]:o for o in d["objects"]}
    original={o["id"]:o for o in old["objects"]}
    if set(current)!=set(original) or len(current)!=187:
        raise ValueError("PAR count/ids changed")
    for id in set(current)-ids:
        if current[id]["source_sha256"]!=original[id]["source_sha256"]:
            raise ValueError("Nonconifer tree/PAR changed "+id)
    mask_im=Image.new("L",(1280,928),0)
    draw=ImageDraw.Draw(mask_im)
    for id in ids:
        for ob in (current[id],original[id]):
            x,y,w,h=(int(ob[k]) for k in ("x","y","w","h"))
            draw.rectangle((x-3,y-3,x+w+3,y+h+3),fill=255)
    mask=np.asarray(mask_im)>0
    src=[]
    for n in NAMES:
        name=project/"qa_a35"/n
        im=Image.open(name).convert("RGB")
        if im.size!=(1280,928):raise ValueError("Original GPU dimensions inconsistent")
        src.append(np.asarray(im,dtype=np.uint8))
    different=np.any(src[0]!=src[1],axis=2)
    within=int((different&mask).sum())
    outside=int((different&~mask).sum())
    behind=int(np.any(src[1]!=src[2],axis=2).sum())
    front=int(np.any(src[1]!=src[3],axis=2).sum())
    report={
        "source":"actual Godot 4.7.2 native OpenGL GPU frames at identical camera, atmosphere disabled",
        "previous":"A35 R5","candidate":"A35 R6","modified_owners":len(ids),
        "retained_PAR":187-len(ids),"tree_total":175,
        "changed_native_pixels":int(different.sum()),
        "inside_union_tree_roi":within,
        "outside_union_tree_roi":outside,
        "roi_pass":outside==0 and within>1000,
        "actor_rear_pixels_visible":behind,
        "actor_front_pixels_visible":front,
        "rear_visible_ratio":round(behind/max(front,1),4),
        "occlusion_pass_at_test_point":front>=400 and behind<=int(front*.4),
        "art":"HOLD; pixel tests are engineering evidence, not aesthetic acceptance"
    }
    path=project/"qa_a35"/"A35_R6_REAL_GPU_ROI.json"
    path.write_text(json.dumps(report,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    print(json.dumps(report,indent=2))
    if not report["roi_pass"]:raise SystemExit(20)
    if not report["occlusion_pass_at_test_point"]:raise SystemExit(21)

if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--zip",required=True)
    p.add_argument("--project",required=True)
    p.add_argument("--work",required=True)
    a=p.parse_args()
    run(Path(a.zip),Path(a.project),Path(a.work))
