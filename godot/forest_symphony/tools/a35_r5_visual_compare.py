#!/usr/bin/env python3
"""Build purely illustrative A/B contacts from actual GPU PNG frames.

These are DERIVATIVE comparisons; never label them as original Godot framebuffer.
Raw 1280x928 original GPU screenshots remain authoritative and are retained.
"""
import argparse
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
def run(work):
    base=Image.open(work/"A35_R5_R4_BASELINE_NATIVE.png").convert("RGB")
    new=Image.open(work/"A35_R5_ART_CANDIDATE_NATIVE.png").convert("RGB")
    if base.size!=(1280,928) or new.size!=base.size:raise ValueError("Native dimensions invalid")
    full=Image.new("RGB",(2560,965),"#2f3433")
    full.paste(base,(0,36));full.paste(new,(1280,36))
    d=ImageDraw.Draw(full)
    d.text((18,10),"R4  |  ORIGINAL GODOT FRAME",fill="white")
    d.text((1298,10),"R5  |  ORIGINAL GODOT FRAME",fill="white")
    full.save(work/"A35_R5_AB_NATIVE_FRAMES_CONTACT_NOT_ORIGINAL.png",optimize=True)
    cases=[
      ("Southwest tree grove",(0,605,475,928)),
      ("Northeast tree grove",(1010,0,1280,350)),
      ("Northwest canopy",(0,0,450,325))
    ]
    cropcanvas=Image.new("RGB",(1050,1250),"#2f3433")
    d=ImageDraw.Draw(cropcanvas)
    y=16
    for title,rect in cases:
        left=base.crop(rect);right=new.crop(rect)
        x0=30
        d.text((x0,y),title+"  |  R4 baseline (left) / R5 botany (right)",fill="#e4e9e1")
        y+=25
        cropcanvas.paste(left,(x0,y));cropcanvas.paste(right,(x0+500,y))
        y+=max(left.height,right.height)+29
    cropcanvas.crop((0,0,1050,min(cropcanvas.height,y+4))).save(work/"A35_R5_NATIVE_1X_TREE_CLOSEUPS_CONTACT.png",optimize=True)
    print("A35 R5 A/B contact from 7 Godot original native frames; derivative only")
if __name__=="__main__":
    p=argparse.ArgumentParser();p.add_argument("--work",required=True)
    run(Path(p.parse_args().work))
