from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
B=Path(r"E:\GameAssetToolLab_20261023")
R=B/"A34_FS_BATTLE45_F0_CORRECTION_20261101"
R.mkdir(exist_ok=True)
S=Path(r"E:\RPG MAKER\260724桌面\rpg maker 2024\RPG MAKER\綠曲-V2.9\Graphics\Characters")
A33=B/"A33_HUMANOID_DIRECT_POSE_20261101"
F=ImageFont.truetype(r"C:\Windows\Fonts\arial.ttf",15)
page=Image.new("RGB",(4*330,4*370),(234,239,244));d=ImageDraw.Draw(page)
for row,name in enumerate(["$actor01.png","$actor01_1.png","$actor01_2.png","$actor01_3.png"]):
 img=Image.open(S/name).convert("RGBA")
 for col in range(4):
  if col==0: frame=img.crop((32,64,64,96))
  else: frame=img.crop(((col-1)*32,64,col*32,96))
  bg=Image.new("RGBA",(32,32),(234,239,244,255));bg.alpha_composite(frame)
  page.paste(bg.convert("RGB").resize((285,285),Image.Resampling.NEAREST),(col*330+15,row*370+32))
  d.text((col*330+15,row*370+8),name+(" ROW2 CENTER" if col==0 else " ROW2 C"+str(col-1)),font=F,fill=(26,40,55))
page.save(R/"A34_ACTOR01_BATTLE_SIDE_VIEW_NATIVE_REFERENCE_10X.png")
old=Image.new("RGB",(1100,350),(235,238,242));dd=ImageDraw.Draw(old)
for i,p in enumerate([
 A33/"B_DODGING_DIRECT_POSES"/"PIXELLAB_B_DODGE_FRAME_00.png",
 A33/"C_DODGE_45_CORRECTION"/"PIXELLAB_C_FRAME_00.png",
 B/"A31_FS_ORIGINAL_MOTION_TRANSFER_20261101"/"A31_SE45_ORIGINAL_POLICY_STATIC_IDLE.png",
 S/"$actor01_1.png"]):
 im=Image.open(p).convert("RGBA")
 if im.size!=(40,40):
  im=im.crop((32,64,64,96))
  pad=Image.new("RGBA",(40,40));pad.alpha_composite(im,(4,6));im=pad
 bg=Image.new("RGBA",(40,40),(235,238,242,255));bg.alpha_composite(im)
 old.paste(bg.convert("RGB").resize((265,265),Image.Resampling.NEAREST),(i*275+5,38))
 dd.text((i*275+7,10),["B-DODGE F0 WRONG","C-DODGE F0 WRONG","A31 UNARMED IDENTITY","FS NATIVE _1 FACING"][i],fill=(25,37,50),font=F)
old.save(R/"A34_F0_FAILURE_VS_REAL_NATIVE_VIEW.png")
print("REFERENCE_SAVED",R)
