#!/usr/bin/env python3
"""FS A35 R8: prove true Godot pixel-aligned canopy shadows + quantify scope.

Consumes two original native Godot GPU frames. This is a QA analyzer, not a
renderer and not evidence of final ART quality.
"""
import argparse,hashlib,json
from pathlib import Path
import numpy as np
from PIL import Image,ImageDraw

def analyze(project:Path,work:Path):
    sources=[
      project/"qa_a35"/"A35_R8_CANOPY_SHADOW_OFF_NATIVE.png",
      project/"qa_a35"/"A35_R8_CANOPY_SHADOW_ON_NATIVE.png"
    ]
    frames=[]
    for path in sources:
        with Image.open(path) as im:
            if im.size!=(1280,928):raise RuntimeError("Original Godot GPU frame dimensions invalid")
            frames.append(np.array(im.convert("RGB"),dtype=np.uint8))
    delta=np.abs(frames[0].astype(np.int16)-frames[1].astype(np.int16))
    diff=np.any(delta>0,axis=2)
    xx,yy=np.meshgrid(np.arange(1280),np.arange(928))
    in_lamp=((xx-260)**2+(yy-785)**2)<=263**2
    # Region expected to be illuminated by original R7 test PointLight2D.
    inside=int(np.count_nonzero(diff&in_lamp))
    outside=int(np.count_nonzero(diff&(~in_lamp)))
    changed=int(np.count_nonzero(diff))
    report={
      "phase":"A35 R8 REAL GODOT PIXEL QA",
      "engine_frames":"two ORIGINAL Godot 4.7.2 OpenGL Compatibility 1280x928 GPU screenshots",
      "difference":"R8 canopy occlusion OFF vs ON, trunk shadows kept ON in both",
      "canopy_occluders":175,
      "test_lamp_xy":[260,785],
      "lamp_study_radius":263,
      "changed_pixels":changed,
      "changed_inside_lamp":inside,
      "changed_outside_lamp":outside,
      "mean_abs_RGB_delta":round(float(delta.mean()),6),
      "max_RGB_delta":int(delta.max()),
      "canopy_shadow_visible":bool(changed>300 and inside>=changed*.98),
      "canopy_shadow_scope_pass":bool(outside<=max(20,int(changed*.02))),
      "art":"HOLD; real 2D canopy polygons, not photoreal 3D DOF/volumetrics"
    }
    out=project/"qa_a35"/"A35_R8_CANOPY_GPU_PIXEL_QA.json"
    out.write_text(json.dumps(report,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    contact=Image.new("RGB",(2560,964),"#292f2e")
    contact.paste(Image.fromarray(frames[0]),(0,36))
    contact.paste(Image.fromarray(frames[1]),(1280,36))
    d=ImageDraw.Draw(contact)
    d.text((20,10),"R8 TRUNK SHADOWS ONLY - ORIGINAL GODOT GPU",fill="white")
    d.text((1300,10),"R8 TRUNK + PIXEL CANOPY SHADOWS - ORIGINAL GODOT GPU",fill="white")
    contact.save(work/"A35_R8_AB_DERIVED_FROM_NATIVE_GPU.png",optimize=True)
    print(json.dumps(report,ensure_ascii=False,indent=2))
    if not report["canopy_shadow_visible"] or not report["canopy_shadow_scope_pass"]:
        raise SystemExit(61)

if __name__=="__main__":
    a=argparse.ArgumentParser()
    a.add_argument("--project",required=True)
    a.add_argument("--work",required=True)
    x=a.parse_args()
    analyze(Path(x.project),Path(x.work))
