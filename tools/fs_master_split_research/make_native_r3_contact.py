from pathlib import Path
from PIL import Image,ImageDraw
import json
r=Path(__file__).resolve().parent
shots=r/"R3_NATIVE_SCREENSHOTS"
layout=[("TREE_BEHIND",144,128, "樹後"),("TREE_FRONT",144,192,"樹前"),("HOUSE_FRONT",336,224,"屋前"),("RIGHT_FRONT",464,256,"右樹前")]
base=Image.new("RGB",(1050,4*264+60),(26,29,33))
dr=ImageDraw.Draw(base)
dr.text((13,9),"FS native VX R3  |  Full Master Ground + source-pixel PAR",fill=(239,239,239))
dr.text((13,30),"LEFT static Par always over actor  |  RIGHT per-object Y-sorted PAR  |  nearest 3x",fill=(187,190,196))
for i,(key,x,y,name) in enumerate(layout):
 yo=60+i*264
 dr.text((13,yo),f"{key} : feet ({x},{y})  |  scene identical",fill=(245,245,245))
 x0=max(0,min(544-160,x-80));y0=max(0,min(416-72,y-52))
 for j,mode in enumerate(["STATIC","DEPTH"]):
  png=Image.open(shots/f"{mode}_{key}.png").convert("RGB").crop((x0,y0,x0+160,y0+72))
  large=png.resize((480,216),Image.Resampling.NEAREST)
  base.paste(large,(14+j*520,yo+28))
  dr.text((14+j*520,yo+247),mode,fill=(255,180,180) if j==0 else (170,215,255))
dst=shots/"FS_R3_NATIVE_VX_STATIC_VS_DEPTH_CONTACT.png"
base.save(dst)
print(dst, dst.stat().st_size)