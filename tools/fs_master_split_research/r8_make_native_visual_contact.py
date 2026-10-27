from pathlib import Path
from PIL import Image,ImageDraw
R=Path(__file__).resolve().parent
D=R/"R8_NATIVE_FULL_MASTER"/"NATIVE_ABA"
items=[
("RED_HOUSE_CONIFER",(13,5),"House-side conifer"),
("RED_FAR_RIGHT_CONIFER",(15,7),"Far-right conifer"),
("RED_LEFT_INNER_MICRO",(3,8),"Left micro-occluder"),
("RED_BOTTOM_MICRO",(12,10),"Bottom shrub"),
("BLUE_STEPS",(9,6),"User-excluded step"),
("CLEAR",(8,9),"Clear baseline")]
W,H=1050,48+len(items)*240
im=Image.new("RGB",(W,H),(23,26,31));d=ImageDraw.Draw(im)
d.text((15,9),"FS R8 native VX | Ground intact + 20 SOURCE-PAR sprites + user RED/BLUE overrides",fill=(255,255,255))
d.text((15,26),"STATIC vs DYNAMIC, 2x native crop enlarged nearest 4x; isolated test NOT art seal",fill=(182,198,214))
for i,(tag,(tx,ty),name) in enumerate(items):
 top=48+i*240
 d.text((14,top),tag+" / "+name,fill=(235,235,240))
 foot=(tx*32+16,(ty+1)*32)
 ox=max(0,min(544-123,foot[0]-62));oy=max(0,min(416-53,foot[1]-38))
 for j,mode in enumerate(["A1","B"]):
  src=Image.open(D/(tag+"__"+mode+".png")).convert("RGB")
  crop=src.crop((ox,oy,ox+123,oy+53)).resize((492,212),Image.Resampling.NEAREST)
  x=15+j*520
  im.paste(crop,(x,top+20))
  d.text((x,top+215),"STATIC PAR" if mode=="A1" else "DYNAMIC PAR",fill=(255,175,175) if not j else (148,206,255))
path=D/"R8_NATIVE_ANNOTATED_RED_BLUE_VISUAL_CONTACT.png"
im.save(path)
print("R8_CONTACT",path,path.stat().st_size,flush=True)