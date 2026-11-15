#!/usr/bin/env python3
"""A35 R8 R2: exact real Godot GPU source/fill/second-light comparison.
Reads original OpenGL frames only. Derivative contact is never a native frame.
"""
import argparse,json
from pathlib import Path
import numpy as np
from PIL import Image,ImageDraw

NAMES=[
"A35_R8_R2_R8_HARD_BASELINE_NATIVE.png",
"A35_R8_R2_R2_ZERO_FILL_NATIVE.png",
"A35_R8_R2_R2_CANOPY_FILL_NATIVE.png",
"A35_R8_R2_R2_TWO_LIGHTS_NATIVE.png"
]

def run(project,workspace):
    arr=[]
    for n in NAMES:
        with Image.open(project/"qa_a35"/n) as im:
            if im.size!=(1280,928):raise ValueError("Not original Godot GPU 1280x928: "+n)
            arr.append(np.asarray(im.convert("RGB"),dtype=np.uint8))
    xx,yy=np.meshgrid(np.arange(1280),np.arange(928))
    primary=(xx-260)**2+(yy-785)**2<=263**2
    secondary=(xx-1090)**2+(yy-280)**2<=263**2
    def compare(a,b,mask):
        x=arr[a].astype(np.int16)
        y=arr[b].astype(np.int16)
        changed=np.any(x!=y,axis=2)
        d=np.mean(y-x,axis=2)
        return {
          "changed_pixels":int(changed.sum()),
          "inside_light_roi":int((changed&mask).sum()),
          "outside_light_roi":int((changed&~mask).sum()),
          "brightened_luminance_pixels":int((d>1.0).sum()),
          "darkened_luminance_pixels":int((d<-1.0).sum()),
          "average_rgb_signed_delta":round(float((y-x).mean()),6),
          "max_abs_RGB_delta":int(np.abs(y-x).max())
        }
    zero=compare(0,1,primary)
    fill=compare(1,2,primary)
    dual=compare(2,3,secondary)
    report={
     "source":"FOUR original Godot 4.7.2 1280x928 compatibility GPU frames",
     "baseline":"R8 source with hard canopy shadows and one forest lamp",
     "cases":["R8 baseline","R2 zero fill","R2 24% canopy fill","R2 24% fill + second northeast light"],
     "primary_light":[260,785],"secondary_light":[1090,280],
     "zero_fill_vs_original_R8":zero,
     "fill_24pct_vs_no_fill":fill,
     "second_light_vs_single":dual,
     "zero_fill_baseline_equal":zero["changed_pixels"]==0,
     "fill_locally_visible":fill["inside_light_roi"]>500 and fill["outside_light_roi"]<150,
     "second_light_locally_visible":dual["inside_light_roi"]>500 and dual["outside_light_roi"]<150,
     "art":"HOLD; unshadowed fill is a lighting approximation, not physical translucency"
    }
    (project/"qa_a35"/"A35_R8_R2_GPU_LIGHT_QA.json").write_text(
        json.dumps(report,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    canvas=Image.new("RGB",(2560,1928),"#29312f")
    pen=ImageDraw.Draw(canvas)
    for i,image in enumerate(arr):
        x=i%2*1280
        y=i//2*964
        canvas.paste(Image.fromarray(image),(x,y+36))
        pen.text((x+14,y+10),["Original R8 / hard shadows","R2 / no fill (control)","R2 / 24% fill","R2 / fill + secondary"][i],fill="white")
    canvas.save(workspace/"A35_R8_R2_4WAY_DERIVED_GPU_COMPARE.png",optimize=True)
    print(json.dumps(report,ensure_ascii=False,indent=2))
    if not report["zero_fill_baseline_equal"]:raise SystemExit(61)
    if not report["fill_locally_visible"]:raise SystemExit(62)
    if not report["second_light_locally_visible"]:raise SystemExit(63)

if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--project",required=True);p.add_argument("--work",required=True)
    a=p.parse_args();run(Path(a.project),Path(a.work))
