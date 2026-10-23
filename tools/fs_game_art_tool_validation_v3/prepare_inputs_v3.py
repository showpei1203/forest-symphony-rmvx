from pathlib import Path
from shutil import copy2
from PIL import Image,ImageDraw
import json,hashlib,random
ROOT=Path(r"E:\GameAssetToolLab_20261023\ToolValidation_v3_20261024")
B0=Path(r"E:\GameAssetToolLab_20261023\FS_B0_SCENE04_HEIGHT_20261023")
src=ROOT/"inputs";src.mkdir(exist_ok=True)
for name in ("tree","rock","sign","cliff_face","stair_face"):
 copy2(B0/"source"/(name+".png"),src/(name+".png"))
source=Image.open(src/"tree.png").convert("RGBA")
w,h=source.size
sheet=Image.new("RGBA",(w*6,h),(0,0,0,0))
for i in range(6):
 im=source.copy()
 p=im.load()
 for y in range(9,62):
  for x in range(2,62):
   red,green,blue,alpha=p[x,y]
   if alpha>0 and green>red and green>blue:
    red=min(255,max(0,red+(i-2)*2))
    green=min(255,max(0,green+(i-2)*4))
    p[x,y]=(red,green,blue,alpha)
 d=ImageDraw.Draw(im)
 # An explicit moving light-reflection mark on opaque upper canopy.
 d.rectangle((16+i*3,25,18+i*3,26),fill=(181,201,106,255))
 im.save(src/(f"tree_frame_{i:02d}.png"))
 sheet.paste(im,(i*w,0))
sheet.save(src/"tree_animation_6frames.png")
j={"scene":"B0","license":"project-created procedural test-only","sprite_frames":6,"tile":[w,h],
"names":[p.name for p in sorted(src.glob("*.png"))],"sha256":{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in src.glob("*.png")}}
(ROOT/"reports"/"V3_INPUT_MANIFEST.json").write_text(json.dumps(j,indent=2),encoding="utf8")
print("T09_INPUTS_PREPARED",len(j["names"]),"sheet",sheet.size,flush=True)
