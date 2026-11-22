#!/usr/bin/env python3
"""R13 audit: confirm authentic LPC diagonal 8-direction SOURCE sprites.
This does NOT invent 8-dir attack frames, render new attack, or put in a weapon.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import hashlib,zipfile,json
ROOT=Path(r"E:\LPC_Original_20261121\LPC_8DIR_ORIGINAL_DIAGONAL")
ZIP=ROOT/"LPC_diagonalwalknruncycle.zip"
SOURCE=ROOT/"extracted"/"LPC_male_diagonal_walkcycle.png"
OUT=ROOT/"FS_R13_EIGHT_DIRECTION_SOURCE_REFERENCE"
OUT.mkdir(parents=True,exist_ok=True)
def checksum(file):
 h=hashlib.sha256()
 with open(file,"rb") as f:
  for b in iter(lambda:f.read(1<<20),b""):h.update(b)
 return h.hexdigest()
assert checksum(ZIP)=="278bba048b4f25b8c8d9601b2cc27402c298cf1c68c554be9e68c8e11c2ee716"
with zipfile.ZipFile(ZIP) as z:
 assert z.testzip() is None
 file_names=z.namelist()
 assert len(file_names)==13
 image_names=[n for n in file_names if n.lower().endswith('.png')]
 assert any("diagonal_walkcycle" in n for n in image_names)
 assert all(not any(word in n.lower() for word in ("slash","attack","punch")) for n in file_names)
ora=ROOT/"extracted"/"LPC_male_diagonal_walkcycle.ora"
with zipfile.ZipFile(ora) as o:
 assert o.testzip() is None
 ora_layers=[n for n in o.namelist() if n.startswith("data/") and n.endswith(".png")]
image=Image.open(SOURCE).convert("RGBA")
assert image.size==(576,512),image.size
assert image.width//64==9 and image.height//64==8
def contact(rows,scale):
 cols=9
 result=Image.new("RGBA",(cols*64*scale,len(rows)*(64*scale+22)),(23,26,31,255))
 d=ImageDraw.Draw(result)
 for pos,row in enumerate(rows):
  for f in range(9):
   crop=image.crop((f*64,row*64,(f+1)*64,(row+1)*64))
   result.alpha_composite(crop.resize((64*scale,64*scale),Image.Resampling.NEAREST),(f*64*scale,pos*(64*scale+22)+22))
   d.text((f*64*scale+4,pos*(64*scale+22)+3),f"Dir{row} F{f}",fill=(248,245,235,255))
 return result
all8=OUT/"LPC_OFFICIAL_EIGHT_DIRECTIONS_9FRAMES_EACH_2X.png"
diag4=OUT/"LPC_OFFICIAL_FOUR_DIAGONAL_ROWS_9FRAMES_3X.png"
contact(range(8),2).save(all8)
contact([1,3,5,7],3).save(diag4)
audit={
 "source_page":"https://opengameart.org/content/lpc-runcycle-and-diagonal-walkcycle",
 "author":"Wolthera van Hövell tot Westerflier (TheraHedwig)",
 "source_original_zip":str(ZIP),"source_archive_sha256":checksum(ZIP),
 "archive_members":len(file_names),"archive_crc_pass":True,
 "original_male_diagonal_png":str(SOURCE),"male_diagonal_png_sha256":checksum(SOURCE),
 "male_diagonal_png_shape":list(image.size),"original_tile_size":[64,64],
 "original_direction_rows":8,"original_frames_per_direction":9,
 "diagonal_rows_for_reference":[1,3,5,7],
 "contains_diagonal_walk":True,"contains_8_direction_attack":False,
 "editable_ORA_original_layers":len(ora_layers),"editable_ORA_original_layer_names":ora_layers[:60],
 "source_license":"CC BY-SA 3.0/GPL 3.0/OGA-BY 3.0; preserve credits and compatible derivative terms",
 "status":"SOURCE VERIFIED, 45-degree attack art still not confirmed."
}
file=OUT/"FS_R13_SOURCE_VERIFICATION_MANIFEST.json"
file.write_text(json.dumps(audit,indent=2,ensure_ascii=False),encoding="utf-8")
print(json.dumps({k:v for k,v in audit.items() if k not in ("editable_ORA_original_layer_names",)},ensure_ascii=True))
