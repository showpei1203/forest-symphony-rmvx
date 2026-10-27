from pathlib import Path
from PIL import Image,ImageDraw
import json,numpy as np
root=Path(__file__).resolve().parent/"R6_SAME_SESSION_ISOLATED"/"NATIVE_ABA"
cases=[("PLAYER_FRONT_NPC_BEHIND",(4,5),(4,3)),
       ("PLAYER_BEHIND_NPC_FRONT",(4,3),(4,5)),
       ("BOTH_FRONT",(4,5),(5,5)),("BOTH_BEHIND",(4,3),(5,3)),("CLEAR",(8,9),(9,9))]
out=Image.new("RGB",(1080,100+len(cases)*232),(26,29,31));dr=ImageDraw.Draw(out)
dr.text((17,10),"FS R6 native VX SAME Game.exe session | exact freeze A1-B-A2 (15 shots)",fill=(255,255,255))
dr.text((17,31),"A1 STATIC / B DYNAMIC. Unchanged full Ground. Original 504 FS source pages untouched in isolated copy.",fill=(175,201,215))
for i,(key,p,n) in enumerate(cases):
 y=80+i*232
 dr.text((18,y-18),key,fill=(229,236,234))
 x=min(544-144,max(0,min(p[0],n[0])*32-48))
 yy=min(416-63,max(0,min(p[1],n[1])*32-13))
 for col,mode in enumerate(["A1","B"]):
  png=Image.open(root/(key+"__"+mode+".png")).convert("RGB")
  crop=png.crop((x,yy,x+144,yy+63)).resize((504,220),Image.Resampling.NEAREST)
  out.paste(crop,(18+col*535,y))
  dr.text((22+col*535,y+196),mode if col==0 else "B (dynamic)",fill=(255,255,255))
out.save(root/"R6_FS_NATIVE_STATIC_DYNAMIC_CONTACT.png")
print("saved",root/"R6_FS_NATIVE_STATIC_DYNAMIC_CONTACT.png")