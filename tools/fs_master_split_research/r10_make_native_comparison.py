from pathlib import Path
from PIL import Image,ImageDraw
R=Path(__file__).resolve().parent
A=R/"R10_ORIGINAL_MAP050_NATIVE"/"NATIVE_MAP050"
B=R/"R10_COLLISION_NATIVE_CANDIDATE"/"NATIVE_CANDIDATE"
OUT=R/"R10_FORMAL_MAP_AUTHORITY";OUT.mkdir(exist_ok=True)
ids=[("F01_MAP050_TREE_DOWN",(13,4),"Tree rear: native unconfigured vs passable"),
("F05_MAP050_STEPS_DOWN",(9,6),"Blue step: original blocked vs compiler walk"),
("F06_MAP050_PREVIOUS_BLOCK_UP",(5,6),"Clear dirt: original blocked vs compiler walk"),
("F04_MAP050_BUSH_RIGHT",(3,8),"Small obstacle: candidate blocks destination"),
("F10_MAP050_NPC_MOVE",(12,7),"NPC obstacle: candidate still blocks")]
w,h=1050,54+len(ids)*185
sheet=Image.new("RGB",(w,h),(26,29,32))
d=ImageDraw.Draw(sheet)
d.text((16,10),"FS R10 actual Map050 vs compiled isolated collision candidate | Real native VX screenshots",fill="white")
d.text((16,29),"First col: original source all tile 0. Second: candidate 204 walkable / 17 blocked. 2x nearest.",fill=(173,196,216))
for i,(key,pos,caption) in enumerate(ids):
 top=54+i*185
 d.text((14,top),key+"  "+caption,fill=(235,237,240))
 x,y=pos;fx=x*32+16;fy=(y+1)*32
 x0=max(0,min(544-240,fx-120));y0=max(0,min(416-75,fy-53))
 for j,root in enumerate([A,B]):
  pic=Image.open(root/(key+".png")).convert("RGB")
  crop=pic.crop((x0,y0,x0+240,y0+75))
  sheet.paste(crop.resize((480,150),Image.Resampling.NEAREST),(16+520*j,top+22))
  d.text((16+520*j,top+174),"ORIGINAL" if j==0 else "COMPILED CANDIDATE",fill=(250,177,177) if j==0 else (160,223,177))
dest=OUT/"R10_REAL_FS_VX_ORIGINAL_VS_COMPILED_COLLISION.png"
sheet.save(dest)
print("R10_COMPARE_IMAGE",dest,dest.stat().st_size,flush=True)