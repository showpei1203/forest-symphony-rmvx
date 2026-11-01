from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json,hashlib,statistics
ROOT=Path(r"E:\GameAssetToolLab_20261023\A30_FS_SOURCE_MOTION_RIG_LOOP_20261101")
ROOT.mkdir(exist_ok=True)
ORIGINAL=Path(r"E:\RPG MAKER\260724桌面\rpg maker 2024\RPG MAKER\綠曲-V2.9\Graphics\Characters")
SRC=["$actor01.png","$actor01_1.png","$actor01_2.png","$actor01_3.png"]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def bboxpoints(im):
 im=im.convert("RGBA")
 pts=[(x,y) for y in range(im.height) for x in range(im.width) if im.getpixel((x,y))[3]>0]
 if not pts:return {}
 box=im.getbbox()
 def band(lo,hi):
  p=[(x,y) for x,y in pts if lo<=y<hi]
  return {"count":len(p),"cx":round(sum(x for x,y in p)/max(1,len(p)),2),
          "cy":round(sum(y for x,y in p)/max(1,len(p)),2),
          "bbox":(min(x for x,y in p),min(y for x,y in p),max(x for x,y in p)+1,max(y for x,y in p)+1)} if p else {}
 return {"bbox":box,"head":band(0,16),"chest":band(16,23),"hips":band(23,28),"feet":band(28,32),
 "alpha_pixels":len(pts),"bottom":box[3] if box else 0}
data={}
panels=Image.new("RGB",(4*4*132,4*175),(236,240,244))
d=ImageDraw.Draw(panels)
for g,name in enumerate(SRC):
 p=ORIGINAL/name
 im=Image.open(p).convert("RGBA")
 print(name,"SOURCE",im.size,"SHA",sha(p),flush=True)
 if im.size!=(96,128):
  print("UNEXPECTED_GEO",name,im.size,flush=True);raise SystemExit(4)
 stat=[]
 for row in range(4):
  line=[]
  for col in range(3):
   tile=im.crop((col*32,row*32,(col+1)*32,(row+1)*32))
   m=bboxpoints(tile);line.append(m)
   bg=Image.new("RGBA",(32,32),(236,240,244,255));bg.alpha_composite(tile)
   px=g*4*132+row*132+4;py=col*175+20
   panels.paste(bg.convert("RGB").resize((128,128),Image.Resampling.NEAREST),(px,py))
   d.text((px,py-16),f"{name[-5:-4]} r{row} c{col}",fill=(25,30,38))
  stat.append(line)
 data[name]={"path":str(p),"sha256":sha(p),"size":im.size,"rows":stat}
# Show 3 walking frames source r2 and base idle center r2; and other direction rows from $actor01
p=ORIGINAL/"$actor01.png";im=Image.open(p).convert("RGBA")
S=Image.new("RGB",(6*196,295),(235,239,243));d=ImageDraw.Draw(S)
for i,(label,source) in enumerate([
 ("WALK step A (R2,C0)",im.crop((0,64,32,96))),
 ("IDLE center (R2,C1)",im.crop((32,64,64,96))),
 ("WALK step B (R2,C2)",im.crop((64,64,96,96))),
 ("S direction idle (R0,C1)",im.crop((32,0,64,32))),
 ("N idle (R3,C1)",im.crop((32,96,64,128))),
 ("SOURCE A26 approved later",Image.open(r"E:\GameAssetToolLab_20261023\A26_PMD0001_APPROVED_SHEETS_FS_RATIO_REPAIR_20261101\FS_NATIVE_PIXEN_RATIO_FIX\PIXEL_LAB_FS_NATIVE_RATIO_CANDIDATE_40.png").convert("RGBA"))
]):
 base=Image.new("RGBA",source.size,(235,239,243,255));base.alpha_composite(source)
 S.paste(base.convert("RGB").resize((184,184),Image.Resampling.NEAREST),(i*196+5,25))
 d.text((i*196+7,7),label,fill=(20,29,44))
S.save(ROOT/"A30_REAL_ACTOR01_ORIGINAL_WALK_IDLE_REFERENCE.png")
panels.save(ROOT/"A30_FOUR_NATIVE_ACTOR01_SHEETS_SOURCE_ATLAS.png")
(ROOT/"A30_SOURCE_KINEMATICS.json").write_text(json.dumps(data,ensure_ascii=False,indent=2),encoding="utf8")
for f in SRC:
 a=data[f]["rows"][2];print("RIGHT_FACING",f,[(v["bbox"] if v else None,v.get("head",{}).get("bbox"),v.get("feet",{}).get("bbox")) for v in a],flush=True)
print("SAVED",ROOT,flush=True)
