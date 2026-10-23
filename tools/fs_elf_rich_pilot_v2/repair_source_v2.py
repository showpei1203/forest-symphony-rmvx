from pathlib import Path
from PIL import Image,ImageDraw
from shutil import copy2
import colorsys,json,hashlib
r=Path(r"E:\GameAssetToolLab_20261023\FS_ElfVillage_RichPilot_20261023")
clean=r/"source"/"clean";archive=r/"source"/"candidate_v1_original"
archive.mkdir(parents=True,exist_ok=True)
for name in ("house_shop.png","market_full.png"):
 source=clean/name
 if not (archive/name).exists():copy2(source,archive/name)
orig=Image.open(clean/"house_A.png").convert("RGBA")
assert orig.size==(96,160)
shop=orig.copy()
# Recolor only the teal rooftop (no scaling, no geometry edits).
px=shop.load(); changed=0
for y in range(0,121):
 for x in range(96):
  rr,gg,bb,aa=px[x,y]
  if aa==0:continue
  h,s,v=colorsys.rgb_to_hsv(rr/255,gg/255,bb/255)
  # jade/slate blue pixels belonging to roof; protect timber and shadow.
  if .43<=h<=.64 and s>.19 and v>.12:
   hue,sat,val=.04,min(.94,s*1.08),min(1.,v*.99)
   a,b,c=colorsys.hsv_to_rgb(hue,sat,val)
   px[x,y]=(round(a*255),round(b*255),round(c*255),aa);changed+=1
# Merchant wood banner overlay, from canonical TileB. Only real source pixels, no invented smoothing.
tileb=Image.open(r/"source"/"legacy_tileB.png").convert("RGBA")
# 16x18 potion/sign emblem from canonical tile, placed adjacent to cottage entrance as hanging sign.
sign=tileb.crop((323,0,345,27))
if sign.getchannel("A").getbbox():
 shop.alpha_composite(sign,(66,116))
shop.save(clean/"house_shop.png")
# One-level market rather than the double-stack 255px-tall object.
market=Image.open(archive/"market_full.png").convert("RGBA")
single=market.crop((0,0,128,155))
single.save(clean/"market_full.png")
checks={}
for name in ("house_A.png","house_shop.png","market_full.png"):
 p=clean/name;im=Image.open(p).convert("RGBA")
 checks[name]={"size":list(im.size),"sha256":hashlib.sha256(p.read_bytes()).hexdigest(),"alpha_bbox":list(im.getchannel("A").getbbox() or ())}
assert checks["house_A.png"]["sha256"]!=checks["house_shop.png"]["sha256"]
assert checks["market_full.png"]["size"]==[128,155]
# Visual two-image sample, near their true natural sizes.
display=Image.new("RGBA",(460,225),(38,43,42,255))
positions=(("house_A.png",25),("house_shop.png",180),("market_full.png",310))
d=ImageDraw.Draw(display)
for name,x in positions:
 im=Image.open(clean/name).convert("RGBA");display.alpha_composite(im,(x,32))
 d.text((x,10),name,fill="white")
display.save(r/"build"/"ASSET_REPAIR_V2_REVIEW.png")
record={"status":"SOURCE_REPAIR_CANDIDATE_NOT_APPROVED","changes":[
 {"target":"house_shop.png","type":"hue_swap_teal_roof_to_terracotta_plus_tileB_emblem","changed_roof_pixels":changed,"no_resampling":True},
 {"target":"market_full.png","type":"removed_unwanted_second_story_by_source_crop","crop":[0,0,128,155],"no_resampling":True}
 ],"files":checks}
(r/"logs"/"SOURCE_REPAIR_V2.json").write_text(json.dumps(record,ensure_ascii=False,indent=2),encoding="utf8")
print("SOURCE_REPAIR_V2",json.dumps(record,ensure_ascii=False))
