from PIL import Image,ImageDraw
from pathlib import Path
import json
r=Path(__file__).resolve().parent
items=[("witch_cottage","ORIGINAL"),("CORRECT_thatch","TRIPLANAR"),("CORRECT_shader","WORLD-SHADER")]
W,H=544,416
im=Image.new("RGB",(W*3,H+35),(30,38,44))
dr=ImageDraw.Draw(im)
for i,(name,label) in enumerate(items):
 pic=Image.open(r/"candidates"/name/"COMPOSITE_PREVIEW.png").convert("RGB")
 im.paste(pic,(W*i,35))
 dr.text((W*i+10,10),label,fill=(248,244,222))
im.save(r/"out"/"STAGE7_FIXED_ROOF_COMPARE.png")
print("MONTAGE",r/"out"/"STAGE7_FIXED_ROOF_COMPARE.png")