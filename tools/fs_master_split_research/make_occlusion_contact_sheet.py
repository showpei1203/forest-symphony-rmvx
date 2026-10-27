from PIL import Image, ImageDraw, ImageFont
from pathlib import Path
import json
root=Path(__file__).resolve().parent
out=root/"OCCLUSION_GRID_R1_20261027"
d=json.loads((out/"OCCLUSION_GRID_R1_METRICS.json").read_text(encoding="utf-8"))
points=[1,4,7]
W=1100;H=3*276+66
sheet=Image.new("RGB",(W,H),"#202027")
dr=ImageDraw.Draw(sheet)
dr.text((14,9),"FS PAR: Ground FULL scene unchanged | 32px full tile vs semantic alpha",fill="#FFFFFF")
dr.text((14,30),"Source SCENE21; demo crops at nearest-neighbor 3x; prototype masks require manual QA",fill="#B8C5CF")
for row,i in enumerate(points):
 item=d["actor_positions"][i]
 fx,fy=item["foot"]
 # centre crop 150x78, visible actor
 x0=max(0,min(544-160,fx-80));y0=max(0,min(416-76,fy-58))
 a=Image.open(out/f"ACTOR_{i}_FULL_TILE.png").convert("RGB").crop((x0,y0,x0+160,y0+76))
 b=Image.open(out/f"ACTOR_{i}_SEMANTIC.png").convert("RGB").crop((x0,y0,x0+160,y0+76))
 Y=66+row*276
 dr.text((16,Y),f"Player foot=({fx},{fy})   Overdraw extra hidden actor pixels: {item['extra_actor_pixels_occluded_by_full_grid']}",fill="#FFFFFF")
 sheet.paste(a.resize((480,228),Image.Resampling.NEAREST),(13,Y+25))
 sheet.paste(b.resize((480,228),Image.Resampling.NEAREST),(565,Y+25))
 dr.text((19,Y+25),"",fill="#ffffff")
 dr.text((15,Y+251),"LEFT: copy entire selected 32px tile",fill="#ffb0b0")
 dr.text((570,Y+251),"RIGHT: source-pixel semantic PAR mask",fill="#92d2f1")
sheet.save(out/"FS_R1_ACTOR_OCCLUSION_COMPARE_CONTACT_SHEET.png")
print("OK",out/"FS_R1_ACTOR_OCCLUSION_COMPARE_CONTACT_SHEET.png")