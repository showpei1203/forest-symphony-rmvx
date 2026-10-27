from pathlib import Path
from PIL import Image,ImageDraw
R=Path(__file__).resolve().parent
out=R/"R7_NATIVE_FULL_MASTER"/"NATIVE_ABA"
items=[
 ("LEFT_CONIFER_FRONT",(3,6),"Conifer"),
 ("HOUSE_FRONT_X8",(8,6),"House A"),
 ("HOUSE_FRONT_X9",(9,6),"House B"),
 ("RIGHT_MARKER_FRONT",(12,7),"Marker"),
 ("CLEAR",(8,9),"Clear")
]
wide=1080;cellh=280
sheet=Image.new("RGB",(wide,len(items)*cellh+60),(22,26,31))
d=ImageDraw.Draw(sheet)
d.text((15,12),"FS R7 | real native VX: same Ground & actor positions  A1 STATIC / B DYNAMIC",fill=(255,255,255))
d.text((15,31),"Actual 544x416 Game.exe captures. 4x NEAREST. Candidate masks: 12 objects, no independently redrawn PAR.",fill=(175,190,205))
for j,(tag,(tx,ty),short) in enumerate(items):
 y=60+j*cellh;d.text((15,y+1),tag,fill=(225,230,240))
 fx=tx*32+16;fy=(ty+1)*32
 x0=max(0,min(544-122,fx-61));y0=max(0,min(416-55,fy-43))
 for side,mode in enumerate(["A1","B"]):
  png=Image.open(out/(tag+"__"+mode+".png")).convert("RGB")
  crop=png.crop((x0,y0,x0+122,y0+55))
  large=crop.resize((488,220),Image.Resampling.NEAREST)
  px=15+side*539
  sheet.paste(large,(px,y+25))
  d.text((px,y+247),("STATIC PAR" if mode=="A1" else "DYNAMIC DEPTH PAR"),fill=(255,170,170) if mode=="A1" else (170,213,245))
dst=out/"R7_12OBJECT_NATIVE_STATIC_DYNAMIC_VISUAL_QA.png"
sheet.save(dst)
print("R7_NATIVE_VISUAL_CONTACT_CREATED",dst,flush=True)