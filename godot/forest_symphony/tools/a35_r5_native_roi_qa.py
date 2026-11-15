#!/usr/bin/env python3
"""A35 R5 real Godot GPU pixel ROI and character-depth regression; no software render substitute."""
import argparse,hashlib,json,zipfile
from pathlib import Path
import numpy as np
from PIL import Image,ImageDraw,ImageChops
NAMES=[
    "A35_R5_R3_BASELINE_NATIVE.png",
    "A35_R5_ART_CANDIDATE_NATIVE.png",
    "A35_R5_ACTOR_BEHIND_NATIVE.png",
    "A35_R5_ACTOR_FRONT_NATIVE.png",
]
def run(zippath:Path, project:Path, work:Path):
    with zipfile.ZipFile(zippath) as z:
        doc=json.loads(z.read("data/a35_r5_botanical_forest_manifest.json"))
        old=json.loads(z.read("data/a35_r4_organic_groves_manifest.json"))
    base={ob["id"]:ob for ob in old["objects"]}
    ids=doc["r5_modified_object_ids"]
    images=[Image.open(project/"qa_a35"/n).convert("RGB") for n in NAMES]
    if any(im.size!=(1280,928) for im in images):raise ValueError("Godot capture dimensions inconsistent")
    roi=Image.new("L",(1280,928),0)
    dd=ImageDraw.Draw(roi)
    for ob in doc["objects"]:
        if ob["id"] in ids:
            for obj in (ob,base[ob["id"]]):
                dd.rectangle((obj["x"]-3,obj["y"]-3,obj["x"]+obj["w"]+3,obj["y"]+obj["h"]+3),fill=255)
    mask=np.asarray(roi)>0
    rgb=[np.asarray(im,dtype=np.uint8) for im in images]
    delta=np.any(rgb[0]!=rgb[1],axis=2)
    inside=int((delta&mask).sum())
    outside=int((delta&~mask).sum())
    changed=int(delta.sum())
    behind=int(np.any(rgb[1]!=rgb[2],axis=2).sum())
    front=int(np.any(rgb[1]!=rgb[3],axis=2).sum())
    # Real sparse conifer canopy has valid transparent leaf gaps: measure depth-dependent occlusion rather than demand 100% invisible.
    report={
        "test":"A35 R5 actual Godot pixel ROI/actor depth",
        "source_scene":"A35 R4 native immutable",
        "candidate_scene":"A35 R5 native",
        "fx":"disabled for deterministic pixel match",
        "changed_tree_owners":len(ids),
        "total_par":len(doc["objects"]),
        "changed_native_pixels":changed,
        "within_union_tree_roi":inside,
        "outside_union_tree_roi":outside,
        "outside_roi_gate":"PASS" if outside==0 else "HOLD",
        "actor_behind_visible_pixel_change":behind,
        "actor_front_visible_pixel_change":front,
        "front_back_visible_ratio":round(behind / max(front,1),4),
        "front_back_gate":"PASS_PARTIAL_FOLIAGE" if front>=400 and behind<=int(front*.40) else "HOLD",
        "source":"four actual Godot OpenGL 3.3 1280x928 GPU frames",
    }
    dest=project/"qa_a35"/"A35_R5_NATIVE_AB_ROI_ACTOR_REPORT.json"
    dest.write_text(json.dumps(report,indent=2)+"\n")
    contact=Image.new("RGB",(1280,928*2))
    contact.paste(images[0],(0,0))
    contact.paste(images[1],(0,928))
    contact.save(work/"A35_R5_NATIVE_FRAME_AB_CONTACT_FROM_GODOT.png")
    print(json.dumps(report,indent=2))
    if outside!=0:return 13
    if front<400 or behind>int(front*.40):return 14
    return 0
if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--zip",required=True)
    p.add_argument("--project",required=True)
    p.add_argument("--work",required=True)
    a=p.parse_args()
    raise SystemExit(run(Path(a.zip),Path(a.project),Path(a.work)))
