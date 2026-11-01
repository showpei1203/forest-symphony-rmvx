from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
S=Path(r"E:\RPG MAKER\260724桌面\rpg maker 2024\RPG MAKER\綠曲-V2.9\Graphics\Characters")
R=Path(r"E:\GameAssetToolLab_20261023\A34_FS_BATTLE45_F0_CORRECTION_20261101")
F=ImageFont.truetype(r"C:\Windows\Fonts\arial.ttf",16)
page=Image.new("RGB",(3*310,4*320),(238,242,246));d=ImageDraw.Draw(page)
for col,n in enumerate(["$actor01_1.png","$actor01_2.png","$actor01_3.png"]):
 src=Image.open(S/n).convert("RGBA")
 for row in range(4):
  tile=src.crop((32,row*32,64,(row+1)*32))
  bg=Image.new("RGBA",(32,32),(238,242,246,255));bg.alpha_composite(tile)
  page.paste(bg.convert("RGB").resize((270,270),Image.Resampling.NEAREST),(col*310+15,row*320+30))
  d.text((col*310+15,row*320+6),n+"  row"+str(row)+" col1",font=F,fill=(24,35,49))
page.save(R/"A34_NATIVE_BATTLE_DIRECTIONS_ALL_ROWS_8X.png")
print("SAVED",R)
