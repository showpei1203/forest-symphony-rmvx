from PIL import Image, ImageDraw
from pathlib import Path
import hashlib, json
root = Path(__file__).resolve().parent
assets = root/"assets"
src = Image.open(assets/"A38_A62_RUN1_APPROVED.png").convert("RGBA")
peak = Image.open(assets/"A38_A23_WAITING_2.png").convert("RGBA")
assert src.size == peak.size == (48,48)
a=lambda f: Image.new("RGBA",(64,64),(0,0,0,0))
s64=a(src); s64.paste(src,(8,8))
p64=a(peak); p64.paste(peak,(8,8))
s64.save(assets/"A38_IDLE_REST_APPROVED_64.png")
p64.save(assets/"A38_IDLE_INHALE_A23_MECHANICAL_64.png")
pixdiff=sum(1 for x,y in zip(src.getdata(),peak.getdata()) if x!=y)
head=(12,5,42,24)
head_diff=sum(1 for x,y in zip(src.crop(head).getdata(),peak.crop(head).getdata()) if x!=y)
alpha=lambda f: sorted(set(f.getchannel("A").getdata()))
info={"source_48_sha256":hashlib.sha256((assets/"A38_A62_RUN1_APPROVED.png").read_bytes()).hexdigest(),"source_64_sha256":hashlib.sha256((assets/"A38_IDLE_REST_APPROVED_64.png").read_bytes()).hexdigest(),"peak_64_sha256":hashlib.sha256((assets/"A38_IDLE_INHALE_A23_MECHANICAL_64.png").read_bytes()).hexdigest(),"breath_change_pixels":pixdiff,"head_region_change_pixels":head_diff,"rest_bbox":src.getchannel("A").getbbox(),"inhale_bbox":peak.getchannel("A").getbbox(),"rest_alpha":alpha(src),"inhale_alpha":alpha(peak)}
(root/"A38_INPUT_QA.json").write_text(json.dumps(info,indent=2),encoding="utf-8")
size=64*8
canvas=Image.new("RGB",(size*2, size+32),(25,34,46))
dr=ImageDraw.Draw(canvas)
for i,(frame,text) in enumerate([(s64,"F0 A62 APPROVED IDLE REST"),(p64,"A23 MECHANICAL INHALE (ART HOLD)")]):
 x=i*size
 dr.text((x+12,10),text,fill=(250,250,245))
 bg=Image.new("RGBA",(64,64),(45,54,66,255));bg.alpha_composite(frame)
 canvas.paste(bg.convert("RGB").resize((size,size),Image.Resampling.NEAREST),(x,32))
canvas.save(root/"A38_REST_VS_INHALE_INPUT_CONTACT_8X.png")
for k,v in info.items(): print("A38_PREP",k,v)
