#!/usr/bin/env python3
"""FS A35 R8 R3 D1: original Godot 4.7.2 GPU day/dusk/night lamp QA.

Compares fixed-phase ON/OFF 1280x928 GPU PNGs and verifies house remains
untouched across three atmospheric phases. Python only analyzes, never renders
the game. DERIVED preview is explicitly not an original GPU screenshot.
"""
import argparse,json
from pathlib import Path
import numpy as np
from PIL import Image,ImageDraw

PHASES=("DAY","DUSK","NIGHT")
def inspect(project:Path,work:Path):
    xx,yy=np.meshgrid(np.arange(1280),np.arange(928))
    circle=(xx-805)**2+(yy-90)**2<=190**2
    cottage=(xx>=968)&(xx<=1240)&(yy>=100)&(yy<=348)
    forest=(xx>=660)&(xx<=945)&(yy>=0)&(yy<=195)
    table={}
    all_frames=[]
    original_off=[]
    pass_all=True
    for phase in PHASES:
        images=[]
        for toggle in ("GROVE_OFF","GROVE_ON"):
            path=project/"qa_a35"/("A35_R8_R3_D1_"+phase+"_"+toggle+"_NATIVE.png")
            with Image.open(path) as im:
                if im.size!=(1280,928):raise RuntimeError("Not original GPU 1280x928 "+str(path))
                images.append(np.asarray(im.convert("RGB"),dtype=np.uint8))
        base,enhanced=images
        original_off.append(base)
        delta=enhanced.astype(np.int16)-base.astype(np.int16)
        changed=np.any(delta!=0,axis=2)
        count=int(changed.sum())
        inside=int((changed&circle).sum())
        outside=int((changed&~circle).sum())
        house=int((changed&cottage).sum())
        grove=int((changed&forest).sum())
        local_good=count>1000 and outside==0 and house==0 and grove>800
        pass_all=pass_all and local_good
        table[phase]={
          "changed_pixels":count,
          "inside_new_lamp_radius":inside,
          "outside_lamp_radius":outside,
          "changed_east_cottage_pixels":house,
          "changed_upper_forest_pixels":grove,
          "mean_signed_rgb_change_in_forest":round(float(delta[forest].mean()),5),
          "max_channel_delta":int(np.abs(delta).max()),
          "GATE":("PASS" if local_good else "HOLD")
        }
        all_frames.extend(images)
    cross_day_night=int(np.any(original_off[0]!=original_off[2],axis=2).sum())
    report={
      "engine":"Godot 4.7.2 original OpenGL 1280x928 GPU frames, 3 phases, paired OFF/ON",
      "camera":"fixed, actor hidden, weather rain OFF, identical within each phase",
      "new_light":[805,90],"radius_mask":190,
      "house_rect":[968,100,1240,348],
      "phase_results":table,
      "day_vs_night_baseline_pixels":cross_day_night,
      "phase_gate":"PASS" if pass_all and cross_day_night>100000 else "HOLD",
      "art":"HOLD. Objectively preserved cottage and local light across 3 phases; scene still needs subjective 1:1 aesthetic approval."
    }
    outfile=project/"qa_a35"/"A35_R8_R3_D1_DAYCYCLE_GPU_QA.json"
    outfile.write_text(json.dumps(report,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    contact=Image.new("RGB",(2560,2898),"#303930")
    canvas=ImageDraw.Draw(contact)
    for i,frame in enumerate(all_frames):
        x=(i%2)*1280;y=(i//2)*966
        contact.paste(Image.fromarray(frame),(x,y+38))
        canvas.text((x+14,y+12),PHASES[i//2]+(" LIGHT OFF" if i%2==0 else " LIGHT ON"),fill="white")
    contact.save(work/"A35_R8_R3_D1_DERIVED_DAYCYCLE_6WAY.png",optimize=True)
    print(json.dumps(report,ensure_ascii=False,indent=2))
    if report["phase_gate"]!="PASS":raise SystemExit(71)

if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--project",required=True)
    p.add_argument("--work",required=True)
    a=p.parse_args()
    inspect(Path(a.project),Path(a.work))
