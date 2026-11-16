#!/usr/bin/env python3
"""FS_01_MAZE R10 derived QA: R9 straight shortest vs R10 Ground-road weighted.

Uses actual Godot GPU 2560x1856 frame; does NOT alter or redistribute the
private original user art in public GitHub. Output is an OWNER-ONLY derived
side-by-side debug illustration, not a newly authored Godot screenshot.
"""
import argparse,json,hashlib
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont

COLORS=[(232,66,55,255),(248,198,38,255),(36,219,132,255),(61,153,253,255),(220,82,242,255)]
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()

def run(root:Path,work:Path):
    old=json.loads((root/"qa_a36c/FS_01_MAZE_R9_ACTUAL_PHYSICS_ROUTE_SURVEY.json").read_text(encoding="utf-8"))
    current=json.loads((root/"qa_a36c/FS_01_MAZE_R10_GODOT_ROAD_WEIGHTED_ROUTES.json").read_text(encoding="utf-8"))
    road=json.loads((root/"data/fs_01_maze_r10_ground_road_confidence.json").read_text(encoding="utf-8"))
    if current["route_candidate_pass_count"]!=5 or len(current["routes"])!=5:
        raise RuntimeError("R10 did not pass actual Godot 5-route test")
    with Image.open(work/"godot_project/qa_a36c/FS_FOREST_DUNGEON_WATER_FS_01_MAZE_R8_WATER_NATIVE_1X.png") as im:
        if im.size!=(2560,1856):raise RuntimeError("Invalid original 1x Godot GPU frame")
        background=im.convert("RGBA")
    out=Image.new("RGB",(2560,995),"#262d27")
    panel_font=ImageFont.load_default()
    labels=["A. R9 native physical shortest (ignores painted roads)","B. R10 native physical plus original Ground-only road preference"]
    stats=[]
    for panel_i,source_routes in enumerate([old["candidate_routes"],current["routes"]]):
        paint=Image.new("RGBA",background.size,(0,0,0,0))
        d=ImageDraw.Draw(paint,"RGBA")
        for i,item in enumerate(source_routes):
            route=item["path"] if panel_i==0 else item["weighted_route_grid"]
            coords=[(int(x)*32+16,int(y)*32+16) for x,y in route]
            if len(coords)<2:raise RuntimeError("Empty route cannot be inspected")
            color=COLORS[i]
            d.line(coords,fill=(0,0,0,250),width=13,joint="curve")
            d.line(coords,fill=color,width=8,joint="curve")
            start,end=coords[0],coords[-1]
            d.ellipse([start[0]-12,start[1]-12,start[0]+12,start[1]+12],fill=color,outline=(0,0,0,255),width=3)
            d.ellipse([end[0]-10,end[1]-10,end[0]+10,end[1]+10],fill=(255,255,255,255),outline=color,width=3)
            if panel_i==1:
                stats.append({"from":item["from"],"to":item["to"],
                    "R9_cells":old["candidate_routes"][i]["length_cells"],
                    "R10_cells":len(route),
                    "ground_road_confidence_gain":item["road_score_gain"]})
        scaled=Image.alpha_composite(background,paint).convert("RGB").resize((1280,928),resample=Image.Resampling.LANCZOS)
        out.paste(scaled,(panel_i*1280,50))
        d2=ImageDraw.Draw(out)
        d2.rectangle((panel_i*1280,0,(panel_i+1)*1280,48),fill="#202820")
        d2.text((panel_i*1280+20,15),labels[panel_i],fill="white",font=panel_font)
    output=work/"FS_01_MAZE_R10_ROAD_ALIGNED_DERIVED_GPU_AB.png"
    out.save(output,optimize=True)
    report={
      "engine":"Original Godot native R8 full 2560x1856 GPU used for both panels",
      "status":"DERIVED private route QA visual, not original single frame; no original Ground or PAR changes",
      "R9":"physical shortest paths from actual foot physics",
      "R10":"real Godot physical-weighted paths with semantic confidence from untouched Ground-only",
      "all_five_actual_Godot_native_routes":"PASS",
      "R10_5_road_confidence_improvements":stats,
      "road_confidence_sha":sha(root/"data/fs_01_maze_r10_ground_road_confidence.json"),
      "pending":["manual assessment of visual paths","moving-actor continuous sweep","explicit entrance/exit","actual gameplay MAZE NAV PASS","art approval"]
    }
    (work/"FS_01_MAZE_R10_VISUAL_ROUTE_QA.json").write_bytes((json.dumps(report,ensure_ascii=False,indent=2)+"\n").encode("utf-8"))
    print(json.dumps({"image":str(output),"image_bytes":output.stat().st_size,"report":report},ensure_ascii=False,indent=2))
if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--project",required=True)
    p.add_argument("--work",required=True)
    a=p.parse_args()
    run(Path(a.project),Path(a.work))
