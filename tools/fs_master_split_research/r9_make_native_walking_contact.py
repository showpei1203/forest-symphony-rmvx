#!/usr/bin/env python3
"""Native Game.exe actual one-step walk contact. Enlargements nearest neighbour only."""
from pathlib import Path
from PIL import Image,ImageDraw
R=Path(__file__).resolve().parent
D=R/"R9_NATIVE_WALKING_ISOLATED"/"NATIVE_WALK"
items=[
 ("T01_TREE_DOWN_BACK",(13,4),"Tree rear step DOWN"),
 ("T03_TREE_UP",(13,4),"Tree step UP"),
 ("T04_BUSH_LEFT",(2,8),"Shrub step LEFT"),
 ("T05_BUSH_RIGHT",(3,8),"Shrub step RIGHT"),
 ("T08_STEPS_DOWN",(9,6),"Blue-excluded stairs DOWN"),
 ("T09_BLOCKED_UP",(5,7),"Blocked cell UP: must stay"),
 ("T10_BLOCKED_LEFT",(6,6),"Blocked cell LEFT: must stay")
]
out=Image.new("RGB",(1100,30+len(items)*190),(21,24,28))
draw=ImageDraw.Draw(out)
draw.text((14,10),"R9 FS VX / REAL Game_Player one-tile movements | 2x native nearest crop | 2 independent runs",fill=(245,245,245))
for i,(name,pos,label) in enumerate(items):
 y=30+i*190
 a=Image.open(D/(name+".png")).convert("RGB")
 b=Image.open(R/"R9_NATIVE_WALKING_ISOLATED"/"NATIVE_WALK_REPLAY1"/(name+".png")).convert("RGB")
 x1=max(0,min(544-136,pos[0]*32+16-68))
 y1=max(0,min(416-66,(pos[1]+1)*32-55))
 box=(x1,y1,x1+136,y1+66)
 for j,pic in enumerate([a,b]):
  crop=pic.crop(box).resize((510,150),Image.Resampling.NEAREST)
  out.paste(crop,(14+j*540,y+22))
  draw.text((16+j*540,y+174),"RUN A" if j==0 else "RUN B",fill=(180,190,220))
 draw.text((14,y+4),name+" / "+label,fill=(246,232,198))
path=D/"R9_REAL_NATIVE_MOVEMENT_TWO_RUNS_QA.png"
out.save(path)
print("R9_WALK_CONTACT",path,path.stat().st_size,flush=True)