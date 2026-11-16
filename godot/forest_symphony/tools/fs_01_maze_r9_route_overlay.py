#!/usr/bin/env python3
"""FS_01_MAZE R9 80x58 route survey debug overlay, ORIGINAL-Godot-frame-derived.

Colors/labeled paths are QA annotations, NOT game artwork or original Godot GPU.
Render uses actual 2560x1856 native GPU background and path cells produced by
Godot real 13x9 footprint PhysicsDirectSpaceState2D queries.
"""
import argparse,json
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
PALETTE=[(240,62,51,245),(255,221,65,245),(54,219,143,245),(80,176,255,245),(218,95,247,250)]
def run(report:Path,native:Path,out:Path):
    data=json.loads(report.read_text(encoding="utf8"))
    if data.get("candidate_test_count")!=5:
        raise RuntimeError("R9 route survey incomplete")
    with Image.open(native) as image:
        if image.size!=(2560,1856):raise ValueError("Not actual native full Godot forest screenshot")
        base=image.convert("RGBA")
    overlay=Image.new("RGBA",base.size,(0,0,0,0))
    draw=ImageDraw.Draw(overlay,"RGBA")
    font=ImageFont.load_default()
    for n,route in enumerate(data["candidate_routes"]):
        points=[(int(x)*32+16,int(y)*32+16) for x,y in route["path"]]
        if not route["pass"] or len(points)<2:raise RuntimeError("Expected five real connected routes")
        color=PALETTE[n]
        draw.line(points,fill=(0,0,0,215),width=11,joint="curve")
        draw.line(points,fill=color,width=6,joint="curve")
        start=points[0];end=points[-1]
        draw.ellipse((start[0]-9,start[1]-9,start[0]+9,start[1]+9),fill=color,outline=(15,15,15,240),width=2)
        draw.ellipse((end[0]-7,end[1]-7,end[0]+7,end[1]+7),fill=(255,255,255,245),outline=color,width=3)
        label=f"{n+1}: {route['from']} -> {route['to']} ({route['length_cells']} cells)"
        draw.text((36,30+n*27),label,font=font,fill=(255,255,255,255),stroke_fill=(0,0,0,255),stroke_width=2)
    result=Image.alpha_composite(base,overlay).convert("RGB")
    result.save(out,optimize=True)
    print(json.dumps({"file":str(out),"bytes":out.stat().st_size,
      "native_background":"original full 2560x1856 Godot GPU frame",
      "overlay":"DERIVED QA only, colored 5 actual Godot physics-grid route candidates",
      "route_count":len(data["candidate_routes"]),"formal_nav":"HOLD"},
      ensure_ascii=False,indent=2))
if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--report",required=True);p.add_argument("--native",required=True);p.add_argument("--output",required=True)
    a=p.parse_args();run(Path(a.report),Path(a.native),Path(a.output))
