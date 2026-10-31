from PIL import Image,ImageDraw
import numpy as np,hashlib,json
from pathlib import Path
r=Path(r'E:\\FS_ROUTE_B_STAGE16_A10_PIXELSPACE_20261031')
src=Path(r'E:\\GameAssetToolLab_20261023\\ASF_Test_20261031\\VX_A09_3_INENGINE_BRIDGE\\Graphics\\Parallaxes\\ground3.png')
im=Image.open(src).convert('RGB'); assert im.size==(1280,928)
assert hashlib.sha256(src.read_bytes()).hexdigest()=='ddc1f21e1d23dcb8258a20baa2acb106d1c0e56683a4dc280faedc23bcd47a13'
a=np.asarray(im,dtype=np.float64);R,G,B=a[:,:,0],a[:,:,1],a[:,:,2]
green=(G>R*1.09)&(G>B*1.08)&(G>54)&(G<209)
candidates=[]
for y in range(30,850,28):
 for x in range(24,1180,28):
  px=a[y:y+64,x:x+64]
  if px.shape!=(64,64,3):continue
  g=green[y:y+64,x:x+64];frac=float(g.mean())
  if frac<.86:continue
  bright=px.mean(axis=2)
  bad=(bright<39).mean()
  # reject smooth roofs or walls, especially low-frequency dominant gradients
  variation=float(px.std(axis=(0,1)).mean())
  score=frac*100 - bad*130 -abs(variation-29)*.3
  candidates.append((score,x,y,frac,variation))
candidates.sort(reverse=True)
chosen=[]
for v in candidates:
 if all(abs(v[1]-p[1])+abs(v[2]-p[2])>130 for p in chosen):
  chosen.append(v)
 if len(chosen)==12:break
if len(chosen)<6:raise RuntimeError('insufficient clean green candidate crops '+str(len(chosen)))
sheet=Image.new('RGB',(4*258,3*275),(20,22,25));draw=ImageDraw.Draw(sheet)
for i,(score,x,y,frac,var) in enumerate(chosen):
 tile=im.crop((x,y,x+64,y+64))
 sx=(i%4)*258;sy=(i//4)*275
 draw.text((sx+2,sy+2),f'#{i} {x},{y} G={frac:.3f}',fill='white')
 sheet.paste(tile.resize((256,256),Image.Resampling.NEAREST),(sx,sy+18))
sheet.save(r/'A10_GROUND3_GRASS_CANDIDATE_AUDIT.png')
(r/'A10_GRASS_CANDIDATE_STATS.json').write_text(json.dumps([{'index':i,'score':v[0],'crop':[v[1],v[2],v[1]+64,v[2]+64],'green_frac':v[3],'std':v[4]} for i,v in enumerate(chosen)],indent=2))
print('SAMPLES',len(chosen),'BEST',chosen[0])
