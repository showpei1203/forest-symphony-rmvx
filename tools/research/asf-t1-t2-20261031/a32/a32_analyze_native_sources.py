from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json,hashlib
S=Path(r"E:\RPG MAKER\260724桌面\rpg maker 2024\RPG MAKER\綠曲-V2.9\Graphics\Characters")
A31=Path(r"E:\GameAssetToolLab_20261023\A31_FS_ORIGINAL_MOTION_TRANSFER_20261101")
O=Path(r"E:\GameAssetToolLab_20261023\A32_FS_BATTLE45_NATIVE_REFERENCES_20261101")
O.mkdir(parents=True,exist_ok=True)
F=ImageFont.truetype(r"C:\Windows\Fonts\arial.ttf",16)
groups=["$actor01.png","$actor01_1.png","$actor01_2.png","$actor01_3.png"]
report={}
sheet=Image.new("RGB",(4*860,4*238),(238,240,243));d=ImageDraw.Draw(sheet)
for g,n in enumerate(groups):
 src=S/n; im=Image.open(src).convert("RGBA")
 assert im.size==(96,128)
 report[n]={"sha256":hashlib.sha256(src.read_bytes()).hexdigest(),"cells":[]}
 d.text((g*860+12,5),n,font=F,fill=(20,29,45))
 for row in range(4):
  y=row*238; d.text((g*860+12,y+35),f"ROW {row}",font=F,fill=(22,31,46))
  for col in range(3):
   x=g*860+col*235+95
   cell=im.crop((col*32,row*32,col*32+32,row*32+32))
   bg=Image.new("RGBA",(32,32),(238,240,243,255));bg.alpha_composite(cell)
   sheet.paste(bg.convert("RGB").resize((196,196),Image.Resampling.NEAREST),(x,y+22))
   d.text((x+70,y+216),f"c{col}",font=F,fill=(32,43,62))
   report[n]["cells"].append({"row":row,"col":col,"bbox":cell.getbbox(),"alpha":sum(p[3]>0 for p in cell.getdata())})
sheet.save(O/"A32_ALL_NATIVE_ACTOR01_BASE_1_2_3_45_VIEW_GRID.png")
walk=Image.open(A31/"A31_SE45_NATIVE_4FRAME_CYCLE_CANDIDATE.png").convert("RGBA")
ref=Image.new("RGB",(1200,550),(240,242,246));d=ImageDraw.Draw(ref)
d.text((12,9),"A31 90deg FACE / NEW 45deg DONORS from ORIGINAL $actor01_1/2/3",font=F,fill=(26,33,49))
for i in range(4):
 fr=walk.crop((i*40,0,(i+1)*40,40))
 bg=Image.new("RGBA",(40,40),(240,242,246,255));bg.alpha_composite(fr)
 ref.paste(bg.convert("RGB").resize((190,190),Image.Resampling.NEAREST),(i*270+20,35))
 d.text((i*270+20,230),"A31 F"+str(i),font=F,fill=(30,40,52))
for i,(g,row,col) in enumerate([("_1",1,1),("_1",2,1),("_2",1,1),("_3",1,1)]):
 image=Image.open(S/("$actor01"+g+".png")).convert("RGBA")
 fr=image.crop((col*32,row*32,col*32+32,row*32+32))
 bg=Image.new("RGBA",(32,32),(240,242,246,255));bg.alpha_composite(fr)
 ref.paste(bg.convert("RGB").resize((196,196),Image.Resampling.NEAREST),(i*270+20,295))
 d.text((i*270+15,500),f"{g} r{row} c{col}",font=F,fill=(28,42,55))
ref.save(O/"A32_A31_FACE_VS_NATIVE_BATTLE_45_CLOSEUP.png")
(O/"A32_SOURCE_MANIFEST.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print(json.dumps({x:{"sha256":v["sha256"],"bbox_rows":[[z["bbox"] for z in v["cells"][row*3:row*3+3]] for row in range(4)]} for x,v in report.items()},ensure_ascii=False))
print("SAVED",O,"MONTAGE",sheet.size,ref.size)
