# -*- coding: utf-8 -*-
from pathlib import Path
from PIL import Image
import urllib.request, hashlib, json, csv, io, zipfile
ROOT=Path(__file__).resolve().parent
IN=ROOT/"inputs";OUT=ROOT/"outputs";IN.mkdir(exist_ok=True);OUT.mkdir(exist_ok=True)
SRC_COMMIT="9bf06be193b053db256b2536824af426de046aa2"
RAW="https://raw.githubusercontent.com/LiberatedPixelCup/Universal-LPC-Spritesheet-Character-Generator/"+SRC_COMMIT+"/"
files={
"body_slash_64.png":"spritesheets/body/bodies/male/slash.png",
"steel_behind_128.png":"spritesheets/weapon/sword/arming/attack_slash/bg/steel.png",
"steel_front_128.png":"spritesheets/weapon/sword/arming/attack_slash/fg/steel.png",
}
def load(p):
    with urllib.request.urlopen(urllib.request.Request(p,headers={"User-Agent":"FS-T17C-Audit"}),timeout=20) as r:return r.read()
for name,path in files.items():
    target=IN/name
    if not target.exists():target.write_bytes(load(RAW+path))
credits_path=IN/"CREDITS.csv"
if not credits_path.exists():credits_path.write_bytes(load(RAW+"CREDITS.csv"))
credits=list(csv.DictReader(io.StringIO(credits_path.read_text(encoding="utf-8-sig"))))
must=["body/bodies/male/slash.png","weapon/sword/arming/attack_slash/bg/slash_128.png","weapon/sword/arming/attack_slash/fg/slash_128.png"]
rows=[next((r for r in credits if r["filename"]==p),None) for p in must]
assert all(rows),must
assert all("OGA-BY 3.0" in r["licenses"] for r in rows)
(IN/"ASSET_CREDITS_SELECTED.json").write_text(json.dumps({"source_commit":SRC_COMMIT,"logical_credit_keys":must,"rows":rows},ensure_ascii=False,indent=2),encoding="utf8")
B=Image.open(IN/"body_slash_64.png").convert("RGBA")
BG=Image.open(IN/"steel_behind_128.png").convert("RGBA")
FG=Image.open(IN/"steel_front_128.png").convert("RGBA")
assert B.size==(384,256) and BG.size==FG.size==(768,512)
# Four placements, all 1:1 source pixels; intentionally NO image scaling
offsets=[(0,0),(32,0),(32,32),(32,64),(32,48),(32,16)]
samples=[]
for ox,oy in offsets:
    dest=Image.new("RGBA",(768,512))
    for row in range(4):
        for col in range(6):
            face=B.crop((col*64,row*64,(col+1)*64,(row+1)*64))
            dest.alpha_composite(face,(col*128+ox,row*128+oy))
    merged=Image.alpha_composite(Image.alpha_composite(BG,dest),FG)
    file=OUT/(f"candidate_x{ox}_y{oy}.png");merged.save(file)
    preview=Image.new("RGBA",(768,512),(33,39,48,255))
    preview.alpha_composite(merged)
    preview.resize((768,512),Image.Resampling.NEAREST).save(OUT/(f"preview_x{ox}_y{oy}.png"))
    # measure overlap with weapon visible pixels and silhouette for guidance only
    overlaps=sum(1 for px,wy in zip(dest.getchannel("A").get_flattened_data(),BG.getchannel("A").get_flattened_data()) if px and wy)
    overlaps_fg=sum(1 for px,wy in zip(dest.getchannel("A").get_flattened_data(),FG.getchannel("A").get_flattened_data()) if px and wy)
    samples.append({"offset":[ox,oy],"bg_body_overlap_pixels":overlaps,"fg_body_overlap_pixels":overlaps_fg})
    print(ox,oy,"overlap",overlaps,overlaps_fg,flush=True)
# Summary of nonempty cells
nonempty=[]
for row in range(4):
    for col in range(6):
        rect=(col*128,row*128,(col+1)*128,(row+1)*128)
        c=Image.alpha_composite(BG.crop(rect),FG.crop(rect))
        nonempty.append({"dir":row,"frame":col,"bbox":c.getbbox(),"alpha_nonempty":c.getchannel("A").getbbox() is not None})
report={"status":"T17C_ANCHOR_CANDIDATES_GENERATED","source_commit":SRC_COMMIT,
        "images":files,"credits":rows,"offset_samples":samples,
        "nonempty_weapon_frames":sum(x["alpha_nonempty"] for x in nonempty),
        "frame_weapon_info":nonempty}
(ROOT/"T17C_ANCHOR_RESEARCH.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
