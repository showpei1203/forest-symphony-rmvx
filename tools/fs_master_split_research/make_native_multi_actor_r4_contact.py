#!/usr/bin/env python3
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json
root=Path(__file__).resolve().parent;d=root/"R4_NATIVE_SCREENSHOTS"
cases=[("PLAYER_FRONT_NPC_BEHIND","Player front, NPC behind"),
       ("PLAYER_BEHIND_NPC_FRONT","NPC front, player behind"),
       ("BOTH_FRONT","Both in front"),
       ("BOTH_BEHIND","Both behind"),
       ("CLEAR","Open ground")]
W,H=1050,5*236+48
canvas=Image.new("RGB",(W,H),(23,25,30));draw=ImageDraw.Draw(canvas)
draw.text((10,8),"R4 REAL VX GAME.EXE | Master Ground unchanged, per-actor PAR occlusion",fill=(250,250,250))
draw.text((10,28),"LEFT static overlay (z=900) | RIGHT depth-aware overlay | scene near left tree, nearest-neighbor 3x",fill=(170,188,200))
for i,(t,caption) in enumerate(cases):
 top=48+i*236
 draw.text((12,top),caption+" | "+t,fill=(238,238,238))
 for j,mode in enumerate(["STATIC","DEPTH"]):
  src=Image.open(d/(mode+"_"+t+".png")).convert("RGB")
  if t=="CLEAR": crop=(196,226,356,290)
  else:crop=(74,112,234,176)
  im=src.crop(crop).resize((480,192),Image.Resampling.NEAREST)
  canvas.paste(im,(12+j*523,top+22))
  draw.text((12+j*523,top+215),mode,fill=(240,178,178) if not j else (155,212,255))
out=d/"R4_NATIVE_MULTI_ACTOR_VISUAL_COMPARE.png";canvas.save(out)
print(str(out),out.stat().st_size)