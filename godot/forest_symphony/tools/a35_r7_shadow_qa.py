#!/usr/bin/env python3
"""QA of two REAL Godot 4.7.2 GPU frames with same forest lamp shadow OFF/ON.

This script does NOT render any Godot pixels. Its optional contact/difference
visualizations are clearly labeled DERIVED and never substitute native images.
"""
import argparse,json
from pathlib import Path
import numpy as np
from PIL import Image,ImageDraw

def run(project:Path,work:Path):
    files=[project/"qa_a35"/"A35_R7_SHADOW_OFF_NATIVE.png",
           project/"qa_a35"/"A35_R7_SHADOW_ON_NATIVE.png"]
    images=[]
    for p in files:
        with Image.open(p) as im:
            if im.size!=(1280,928):raise ValueError("Godot original GPU dimensions invalid")
            images.append(np.asarray(im.convert("RGB"),dtype=np.uint8))
    a,b=images
    delta=np.abs(a.astype(np.int16)-b.astype(np.int16))
    changed=np.any(delta>0,axis=2)
    yy,xx=np.mgrid[0:928,0:1280]
    near=(xx-260)**2+(yy-785)**2<=263**2
    inside=int((changed&near).sum())
    outside=int((changed&~near).sum())
    report={
      "frames":"original Godot GPU shadow OFF vs ON, 1280x928",
      "test_light_world_point":[260,785],
      "tree_light_occluders":175,
      "changed_pixels":int(changed.sum()),
      "changed_within_lamp_radius263":inside,
      "changed_outside_lamp_radius263":outside,
      "rgb_mean_absolute_delta":round(float(delta.mean()),5),
      "rgb_peak_delta":int(delta.max()),
      "shadow_switch_visible":bool(inside>250 and inside>outside*8),
      "art":"HOLD; occluders are simple tree trunk polygons, not canopy shadows or volumetric 3D"
    }
    (project/"qa_a35"/"A35_R7_SHADOW_GPU_PIXEL_QA.json").write_text(
        json.dumps(report,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    # Private derivative annotated A/B, 1x pixels, no resizing.
    compare=Image.new("RGB",(2560,962),"#292f2e")
    compare.paste(Image.fromarray(a),(0,34))
    compare.paste(Image.fromarray(b),(1280,34))
    label=ImageDraw.Draw(compare)
    label.text((20,9),"Godot original frame: shadow OFF",fill="white")
    label.text((1300,9),"Godot original frame: shadow ON",fill="white")
    compare.save(work/"A35_R7_SHADOW_DERIVED_AB_CONTACT.png",optimize=True)
    print(json.dumps(report,ensure_ascii=False,indent=2))
    if not report["shadow_switch_visible"]:raise SystemExit(71)

if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--project",required=True)
    p.add_argument("--work",required=True)
    a=p.parse_args()
    run(Path(a.project),Path(a.work))
