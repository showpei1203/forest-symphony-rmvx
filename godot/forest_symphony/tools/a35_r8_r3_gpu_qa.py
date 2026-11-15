#!/usr/bin/env python3
"""A35 R8 R3 exact native Godot GPU QA: save cottage from experimental glare.

Only reads original Godot 4.7.2 GPU frames, does not render scene in Python.
Tests full OFF equivalence, bounded new-grove effect and actual cottage ROI.
"""
import argparse,json
from pathlib import Path
import numpy as np
from PIL import Image,ImageDraw

NAMES=[
"A35_R8_R3_R2_FILL_ONLY_NATIVE.png",
"A35_R8_R3_R3_OFF_CONTROL_NATIVE.png",
"A35_R8_R3_R3_GROVE_ON_NATIVE.png",
"A35_R8_R3_R2_HOUSE_GLARE_NATIVE.png"]
def check(project:Path,work:Path):
    frames=[]
    for name in NAMES:
        with Image.open(project/"qa_a35"/name) as png:
            if png.size!=(1280,928):raise RuntimeError("Not original 1280x928 Godot frame: "+name)
            frames.append(np.asarray(png.convert("RGB"),dtype=np.uint8))
    old,off,new,original_glare=frames
    y,x=np.mgrid[:928,:1280]
    groove=(x-805)**2+(y-90)**2<=190**2
    cottage=(x>=968)&(x<=1240)&(y>=100)&(y<=348)
    forest=(x>=660)&(x<=945)&(y>=0)&(y<=195)
    def delta(a,b):
        d=b.astype(np.int16)-a.astype(np.int16)
        return np.any(d!=0,axis=2),np.mean(d,axis=2),np.max(np.abs(d))
    zero,zero_rgb,zero_peak=delta(old,off)
    changed,d,peak=delta(off,new)
    old_changed,old_d,old_peak=delta(old,original_glare)
    grove_count=int((changed&groove).sum())
    forest_count=int((changed&forest).sum())
    new_cottage=int((changed&cottage).sum())
    old_cottage=int((old_changed&cottage).sum())
    report={
      "source":"four ORIGINAL Godot 4.7.2 OpenGL GPU 1280x928 frames, night, identical camera and scene except R8 R2/R3 light script",
      "controls":{
        "R2_fill_only_vs_R3_grove_OFF_changed_pixels":int(zero.sum()),
        "peak_abs_rgb_difference":int(zero_peak),
        "zero_control_pass":bool(zero.sum()==0)
      },
      "new_grove_light":{
        "center":[805,90],"mask_radius_px":190,
        "changed_pixels_total":int(changed.sum()),
        "inside_lamp_roi":grove_count,
        "outside_lamp_roi":int((changed&~groove).sum()),
        "forest_pixels_changed":forest_count,
        "forest_rgb_mean_signed_delta":round(float(d[forest].mean()),5),
        "peak_abs_rgb_delta":int(peak)
      },
      "east_cottage":{
        "pixel_roi":[968,100,1240,348],
        "R8_R2_OLD_NE_LIGHT_CHANGED_COTTAGE_PIXELS":old_cottage,
        "R8_R3_RELOCATED_LIGHT_CHANGED_COTTAGE_PIXELS":new_cottage,
        "old_glare_max_abs_rgb_delta":int(old_peak),
        "glare_reduction_ratio":round((old_cottage-new_cottage)/max(old_cottage,1),4)
      },
      "gates":{
        "zero_state_pixel_identical":bool(zero.sum()==0),
        "forest_visible":bool(forest_count>1500),
        "new_light_localized":bool(grove_count>2000 and (changed&~groove).sum()==0),
        "cottage_unchanged":bool(new_cottage==0),
        "old_cottage_glare_reduced":bool(old_cottage>new_cottage+200)
      },
      "ART":"HOLD until owner accepts original Godot 1x scene. Experimental 2D lamps are not full HD-2D."
    }
    qa=project/"qa_a35"/"A35_R8_R3_GPU_COTTAGE_GROVE_QA.json"
    qa.write_text(json.dumps(report,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    sheet=Image.new("RGB",(2560,1932),"#303b34")
    pen=ImageDraw.Draw(sheet)
    labels=[
      "R8 R2: primary 24% fill (baseline)",
      "R8 R3: new grove light OFF (must match baseline)",
      "R8 R3: lower-energy light near forest canopy",
      "R8 R2: old lamp overbrightens right cottage"]
    for i,img in enumerate(frames):
        px=(i%2)*1280
        py=(i//2)*966
        sheet.paste(Image.fromarray(img),(px,py+38))
        pen.text((px+16,py+12),labels[i],fill="white")
    sheet.save(work/"A35_R8_R3_DERIVED_4WAY_GPU_COMPARE.png",optimize=True)
    print(json.dumps(report,ensure_ascii=False,indent=2))
    bad=[k for k,v in report["gates"].items() if not v]
    if bad:raise SystemExit("R8 R3 GPU QA HOLD: "+", ".join(bad))
if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--project",required=True);p.add_argument("--work",required=True)
    a=p.parse_args()
    check(Path(a.project),Path(a.work))
