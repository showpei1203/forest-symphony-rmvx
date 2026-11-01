from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
B=Path(r"E:\GameAssetToolLab_20261023")
R=B/"A43_FS_RUN_LOOP_3FRAME_20261101";R.mkdir(exist_ok=True)
items=[
("A31 WALK APPROVED",B/"A31_FS_ORIGINAL_MOTION_TRANSFER_20261101"/"A31_SE45_NATIVE_4FRAME_CYCLE_CANDIDATE.png"),
("A36 3-FRAME WALK",B/"A36_FS_ACTION_3FRAME_FORMAL_20261101"/"A36_WALK_3FRAME_APPROVED_A31.png"),
("A42 REJECTED",B/"A42_APPROACH_CLOSE_ATTACK_SKELETON_3F_20261101"/"A42_SOURCE_ANCHORED_APPROACH_3F_CANDIDATE.png")]
f=ImageFont.truetype(r"C:\Windows\Fonts\arial.ttf",20)
out=Image.new("RGB",(4*235,3*268),(239,242,246))
d=ImageDraw.Draw(out)
for k,(name,p) in enumerate(items):
 im=Image.open(p).convert("RGBA");assert im.height==40 and im.width in (120,160)
 d.text((10,268*k+5),name,font=f,fill=(24,39,56))
 for i in range(im.width//40):
  cell=im.crop((40*i,0,40*(i+1),40))
  bg=Image.new("RGBA",(40,40),(239,242,246,255));bg.alpha_composite(cell)
  out.paste(bg.convert("RGB").resize((223,223),Image.Resampling.NEAREST),(10+235*i,268*k+34))
  d.text((235*i+18,268*k+240),"F"+str(i),font=f,fill=(32,42,60))
out.save(R/"A43_A31_APPROVED_WALK_VS_A42_REJECTED.png")
print("SAVED",R)
