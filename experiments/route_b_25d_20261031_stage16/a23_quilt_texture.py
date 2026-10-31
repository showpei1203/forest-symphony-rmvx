from pathlib import Path
import json,hashlib
import numpy as np
from PIL import Image,ImageDraw
R=Path(__file__).resolve().parent
A22=R if (R/'A22_CLEAN_STYLE_NATIVE128_VARIANT_01.png').exists() else Path(r'E:\FS_ROUTE_B_STAGE16_A22_CLEAN_STYLE_AB_20261101')
GRASS=R/'A10_GROUND3_GRASS_SOURCE_64.png' if (R/'A10_GROUND3_GRASS_SOURCE_64.png').exists() else Path(r'E:\FS_ROUTE_B_STAGE16_A10_PIXELSPACE_20261031\A10_GROUND3_GRASS_SOURCE_64.png')
SAND=R/'A09_GROUND3_ORIGINAL_48.png' if (R/'A09_GROUND3_ORIGINAL_48.png').exists() else Path(r'E:\FS_ROUTE_B_STAGE16_A09_TEXTURE_SCALE_20261031\A09_GROUND3_ORIGINAL_48.png')
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
assert sha(GRASS)=='b185fbbccd5f84a58f12144b906d7a5fe71809b59a8f75ac385c92b2c5543407'
assert sha(SAND)=='ca7c4ea242a9b81ab39113acdad1de47ed193117d1f5db6c6d2dea5383548adb'
g=np.asarray(Image.open(GRASS).convert('RGB'),dtype=np.uint8)
s=np.asarray(Image.open(SAND).convert('RGB'),dtype=np.uint8)
assert g.shape==(64,64,3) and s.shape==(48,48,3)
def periodic(t,h=128,w=128,offs=(0,0)):
 y=np.arange(h)[:,None]+offs[0];x=np.arange(w)[None,:]+offs[1]
 return np.asarray(t)[y%t.shape[0],x%t.shape[1]].copy()
def minpath(cost):
 # Find one-pixel wide short seam crossing N rows with column movement max +/-1
 n,m=cost.shape
 cost=cost.astype(np.float64)
 val=np.empty((n,m),np.float64); prev=np.zeros((n,m),np.int16)
 val[0]=cost[0]
 for y in range(1,n):
  for x in range(m):
   opts=list(range(max(0,x-1),min(m,x+2)))
   best=min(opts,key=lambda p:val[y-1,p])
   val[y,x]=cost[y,x]+val[y-1,best]
   prev[y,x]=best
 x=int(val[-1].argmin());path=np.empty(n,np.int16)
 for y in range(n-1,-1,-1):
  path[y]=x
  if y>0:x=int(prev[y,x])
 return path
def quilt(src,seed=1,step=16,patchsize=24,tries=35):
 rng=np.random.default_rng(seed)
 H=W=128
 out=np.zeros((H,W,3),np.uint8)
 seen=np.zeros((H,W),dtype=bool)
 meta={'trials':0,'matched_seams':0,'patches':0}
 for y in range(0,H,step):
  for x in range(0,W,step):
   h=min(patchsize,H-y);w=min(patchsize,W-x)
   l=max(0,w-step) if x else 0
   t=max(0,h-step) if y else 0
   # Pixels may be already filled from one or two adjacent candidate patches.
   old=out[y:y+h,x:x+w];occupied=seen[y:y+h,x:x+w]
   best=None;bestScore=float('inf')
   for _ in range(tries):
    sy=int(rng.integers(0,src.shape[0]-h+1));sx=int(rng.integers(0,src.shape[1]-w+1))
    tile=src[sy:sy+h,sx:sx+w]
    if occupied.any():
     d=np.abs(tile.astype(np.int16)-old.astype(np.int16)).mean(axis=2)
     cost=float(d[occupied].mean())
    else:cost=0
    if cost<bestScore:best=tile.copy();bestScore=cost
   # Build graph seam against already filled area; no interpolation across source pixels.
   place=np.ones((h,w),bool)
   if x and l>0:
    diff=np.abs(best[:,:l].astype(np.int16)-old[:,:l].astype(np.int16)).mean(axis=2)
    seam=minpath(diff)
    place&=np.arange(w)[None,:]>=seam[:,None]
    meta['matched_seams']+=1
   if y and t>0:
    diff=np.abs(best[:t].astype(np.int16)-old[:t].astype(np.int16)).mean(axis=2)
    seam=minpath(diff.T)
    place&=np.arange(h)[:,None]>=seam[None,:]
    meta['matched_seams']+=1
   place|=~occupied
   old[place]=best[place];occupied[place]=True
   meta['patches']+=1
 assert seen.all()
 return out,meta
def dilate(m,r=8):
 o=np.zeros(m.shape,bool)
 pad=np.pad(m,r,mode='constant')
 for dy in range(2*r+1):
  for dx in range(2*r+1):o|=pad[dy:dy+m.shape[0],dx:dx+m.shape[1]]
 return o
def flower_mask(img,road):
 a=img.astype(np.int16);r,g,b=a[:,:,0],a[:,:,1],a[:,:,2]
 white=(r>164)&(g>165)&(b>129)&(r-g<45)&(~road)
 yellow=(r>153)&(g>112)&(b<105)&(r>g+14)&(~road)
 petal=(white|yellow)&(~road)
 near=dilate(petal,6)
 plant=(g<113)&(g>r*1.04)&(r<95)&(b<78)&(~road)&near
 return petal|plant,{'petal_pixels':int(petal.sum()),'preserved_plant_pixels':int(plant.sum())}
def palette_match_ratio(img,lookups):
 a=img.reshape(-1,3);code=(a[:,0].astype(np.int32)<<16)|(a[:,1].astype(np.int32)<<8)|(a[:,2].astype(np.int32))
 return float(np.isin(code,np.asarray(lookups,dtype=np.int32)).mean())
gset=np.unique((g[:,:,0].astype(np.int32)<<16)|(g[:,:,1].astype(np.int32)<<8)|g[:,:,2].astype(np.int32))
sset=np.unique((s[:,:,0].astype(np.int32)<<16)|(s[:,:,1].astype(np.int32)<<8)|s[:,:,2].astype(np.int32))
report=[]
for i in range(1,5):
 src=np.asarray(Image.open(A22/f'A22_CLEAN_STYLE_NATIVE128_VARIANT_{i:02d}.png').convert('RGB'),dtype=np.uint8)
 road=np.asarray(Image.open(R/f'A23_VARIANT_{i:02d}_CONNECTED_SAND_MASK.png').convert('L'))>127
 assert src.shape==(128,128,3) and road.shape==(128,128)
 grass0=periodic(g,offs=(i*7,i*11));sand0=periodic(s,offs=(i*5,i*3))
 periodic_map=np.where(road[:,:,None],sand0,grass0).astype(np.uint8)
 grass1,mg=quilt(g,seed=2301+10*i)
 sand1,ms=quilt(s,seed=2302+10*i)
 quilt_map=np.where(road[:,:,None],sand1,grass1).astype(np.uint8)
 petals,counts=flower_mask(src,road)
 botanical_map=quilt_map.copy()
 botanical_map[petals]=src[petals]
 # Source provenance: all background pixels come from original verified FS source material.
 assert palette_match_ratio(quilt_map[road],sset)==1.0
 assert palette_match_ratio(quilt_map[~road],gset)==1.0
 for kind,img in [('PERIODIC_BASELINE',periodic_map),('QUILTED_GROUND',quilt_map),('QUILT_PLUS_SAVED_BOTANICALS',botanical_map)]:
  Image.fromarray(img,'RGB').save(R/f'A23_{kind}_V{i:02d}_128.png')
 def metric(a,m):
  x=a.astype(np.int16)
  return round(float((np.abs(x[1:]-x[:-1])[m[1:]&m[:-1]].mean() if np.any(m[1:]&m[:-1]) else 0)+
                     (np.abs(x[:,1:]-x[:,:-1])[m[:,1:]&m[:,:-1]].mean() if np.any(m[:,1:]&m[:,:-1]) else 0))/2,3)
 record={'variant':i,'road_fraction':round(float(road.mean()),4),'original_grass_L1':metric(src,~road),'original_road_L1':metric(src,road),
 'periodic_grass_L1':metric(periodic_map,~road),'periodic_road_L1':metric(periodic_map,road),
 'quilt_grass_L1':metric(quilt_map,~road),'quilt_road_L1':metric(quilt_map,road),
 'source_color_provenance':'ALL_BG_PIXELS_FROM_VERIFIED_FS_SOURCE_RGB','flora_pixels':int(petals.sum()),
 'petals_and_plants':counts,'quilt_methods':{'grass':mg,'sand':ms},
 'output_SHA256':{n:sha(R/f'A23_{n}_V{i:02d}_128.png') for n in ('PERIODIC_BASELINE','QUILTED_GROUND','QUILT_PLUS_SAVED_BOTANICALS')}}
 report.append(record)
 print('A23_QA',json.dumps({k:v for k,v in record.items() if k not in ('quilt_methods','output_SHA256')},ensure_ascii=False),flush=True)
(R/'A23_TEXTURE_TRANSFER_QA.json').write_text(json.dumps({'stage':'A23','date':'2026-11-01','subject':'diagnostic source texture quilting applied to PixelLab scene masks, NOT direct AI full art','FS_source_grass_sha256':sha(GRASS),'FS_source_sand_sha256':sha(SAND),'generations_used':0,'variants':report,'art':'PENDING_VISUAL_AUDIT','formal_seal':'NO'},indent=2,ensure_ascii=False),encoding='utf8')
sheet=Image.new('RGB',(4*260,4*170),(21,23,26));dr=ImageDraw.Draw(sheet)
for i in range(1,5):
 orig=Image.open(A22/f'A22_CLEAN_STYLE_NATIVE128_VARIANT_{i:02d}.png').convert('RGB')
 kinds=[('PIXELLAB ORIGINAL',orig)]
 kinds.extend([(name,Image.open(R/f'A23_{name}_V{i:02d}_128.png').convert('RGB')) for name in ('PERIODIC_BASELINE','QUILTED_GROUND','QUILT_PLUS_SAVED_BOTANICALS')])
 for row,(name,im)in enumerate(kinds):
  x=(i-1)*260;y=row*170
  dr.text((x+2,y+4),f'{i} {name}',fill='white')
  sheet.paste(im,(x+4,y+26))
sheet.save(R/'A23_FOUR_VARIANT_FOUR_METHOD_NATIVE1X.png')
print('A23_TEXTURE_TRANSFER_DONE',flush=True)
