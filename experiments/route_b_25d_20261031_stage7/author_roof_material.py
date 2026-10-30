from PIL import Image,ImageDraw
from pathlib import Path
import random,hashlib,json
root=Path(__file__).resolve().parent
assets=root/'assets'
assets.mkdir(exist_ok=True)
rnd=random.Random(70931)
N=512
image=Image.new('RGB',(N,N),(161,128,80))
d=ImageDraw.Draw(image)
palette=[(184,148,94),(203,161,91),(222,187,113),(167,127,73),(143,104,58),(196,152,89)]
for row in range(0,N,15):
 # Deep under-eave boundary and cross-staggered woven reed rows
 d.rectangle([0,row+12,N-1,row+14],fill=(116,86,48))
 d.line((0,row,N,row),fill=(229,189,120),width=1)
 for col in range(-6,N+14,11):
  jx=rnd.randrange(-3,3)
  length=rnd.randrange(8,15)
  y=row+rnd.randrange(1,5)
  tint=palette[rnd.randrange(len(palette))]
  d.line((col+jx,y,col+jx+2,length+y),fill=tint,width=rnd.choice([1,2,2,3]))
  if rnd.randrange(9)==0:
   d.line((col+jx+4,y+2,col+jx+4,y+9),fill=(241,202,136),width=1)
# Small dark reed tips add legible spatial texture at 1x instead of blur.
for k in range(780):
 x=rnd.randrange(N);y=rnd.randrange(N)
 d.point((x,y),fill=rnd.choice([(116,85,44),(143,112,68),(223,187,125)]))
p=assets/'roof_thatch_stage7.png'
image.save(p)
(root/'STAGE7_ROOF_TEXTURE_MANIFEST.json').write_text(json.dumps({'authoring':'deterministic source texture, no finished 2D map reverse crop','size':[N,N],'seed':70931,'license':'original authored in this Stage7 test','sha256':hashlib.sha256(p.read_bytes()).hexdigest()},indent=2),encoding='utf-8')
print('ROOF_TEXTURE',p,p.stat().st_size)