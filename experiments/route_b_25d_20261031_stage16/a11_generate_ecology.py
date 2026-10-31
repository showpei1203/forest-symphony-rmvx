from pathlib import Path
from PIL import Image, ImageDraw
import numpy as np, json, hashlib, math
ROOT=Path(__file__).resolve().parent
A10=Path(r'E:\FS_ROUTE_B_STAGE16_A10_PIXELSPACE_20261031')
W,H=544,416
SEEDS={'field':11031,'tufts':11032,'flowers':11033}
def sh(path):return hashlib.sha256(Path(path).read_bytes()).hexdigest()
assert sh(ROOT/'A11_INPUT_A10_GROUND_544x416.png')=='20bb55e2b9212b45204a885cb34c0a59ba77fa2e5d0c0754d8eb62a956e33e5a'
img=Image.open(ROOT/'A11_INPUT_A10_GROUND_544x416.png').convert('RGB')
original=np.asarray(img,dtype=np.uint8)
road=np.asarray(Image.open(ROOT/'A11_INPUT_A10_ROAD_MASK_544x416.png').convert('L'))==255
band=np.asarray(Image.open(ROOT/'A11_INPUT_A10_EDGE_BAND_544x416.png').convert('L'))==255
protected=road|band
editable=~protected
assert (int(road.sum()),int(band.sum()),int(editable.sum()))==(44321,3328,178655)
def smooth_random(size, rng):
  ch=math.ceil(H/size)+3;cw=math.ceil(W/size)+3
  grid=np.clip(rng.normal(loc=128,scale=42,size=(ch,cw)),0,255).astype(np.uint8)
  a=Image.fromarray(grid,'L').resize((cw*size,ch*size),Image.Resampling.BICUBIC)
  cropped=np.asarray(a.crop((size, size, size+W,size+H)),dtype=np.float64)
  return (cropped-cropped.mean())/(cropped.std()+1e-8)
rng=np.random.default_rng(SEEDS['field'])
f1=smooth_random(82,rng);f2=smooth_random(39,rng);f3=smooth_random(17,rng)
vegetation=(.53*f1+.33*f2+.14*f3)
vegetation=(vegetation-vegetation.mean())/(vegetation.std()+1e-8)
lush=np.clip((vegetation-.20)/1.2,0,1)
dry=np.clip((-vegetation-.35)/1.0,0,1)
delta=np.zeros((H,W,3),dtype=np.float64)
delta+=lush[:,:,None]*np.array([-7.,5.,-4.])[None,None,:]
delta+=dry[:,:,None]*np.array([7.,-3.,-1.])[None,None,:]
# The underlying pixel-space material is never blurred; modulate only local color in spatially varied patches.
colored=np.clip(original.astype(np.float64)+delta,0,255).astype(np.uint8)
out=original.copy()
out[editable]=colored[editable]
tint_only=out.copy()
tint=np.any(tint_only!=original,axis=2)
# Ground-level sprites: seeded 1px strokes.  No copies of pre-existing tall props.
t_rng=np.random.default_rng(SEEDS['tufts'])
tmask=np.zeros((H,W),dtype=np.uint8)
used=[]
attempts=0
while len(used)<185 and attempts<25000:
 attempts+=1
 x=int(t_rng.integers(7,W-7));y=int(t_rng.integers(7,H-7))
 if not editable[y,x]:continue
 if vegetation[y,x]<-.45:continue
 if any(abs(x-a)<6 and abs(y-b)<6 for a,b in used):continue
 used.append((x,y))
 base=original[y,x].astype(int)
 # Fine leaf fragments are 1x2 or 1x3 px and stay on ground. No 32px bushes.
 shade=np.uint8(np.clip(base+np.array([-18.,0.,-8.]),0,255))
 light=np.uint8(np.clip(base+np.array([10.,19.,-6.]),0,255))
 for xx,yy,c in [(x,y,shade),(x+1,y-1,shade),(x-1,y+1,light),(x+2,y,light)]:
  if 0<=xx<W and 0<=yy<H and editable[yy,xx]:
   out[yy,xx]=c
   tmask[yy,xx]=255
flower_rng=np.random.default_rng(SEEDS['flowers'])
flowermask=np.zeros((H,W),dtype=np.uint8)
flowers=[]
attempts=0
while len(flowers)<25 and attempts<12000:
 attempts+=1
 x=int(flower_rng.integers(10,W-10));y=int(flower_rng.integers(10,H-10))
 if not editable[y,x] or vegetation[y,x]<.05:continue
 if any((x-a)**2+(y-b)**2<16**2 for a,b in flowers):continue
 flowers.append((x,y))
 palette=([236,223,165] if len(flowers)%4 else [239,238,211])
 # Exactly 2 or 3 painted ground pixels. Never tall flowers.
 pts=[(x,y),(x+1,y)]
 if len(flowers)%3==0:pts.append((x,y+1))
 for xx,yy in pts:
  if editable[yy,xx]:
   out[yy,xx]=palette
   flowermask[yy,xx]=255
assert np.array_equal(out[protected],original[protected])
assert np.all((tmask>0)<=editable) and np.all((flowermask>0)<=editable)
Image.fromarray(out,'RGB').save(ROOT/'A11_ECOLOGY_CANDIDATE_544x416.png')
Image.fromarray(tint_only,'RGB').save(ROOT/'A11_INTERMEDIATE_TINT_ONLY_544x416.png')
Image.fromarray((np.clip(lush*255,0,255)).astype(np.uint8),'L').save(ROOT/'A11_LUSH_FIELD_MASK.png')
Image.fromarray((np.clip(dry*255,0,255)).astype(np.uint8),'L').save(ROOT/'A11_DRY_FIELD_MASK.png')
Image.fromarray(tmask,'L').save(ROOT/'A11_TUFT_PIXEL_MASK.png')
Image.fromarray(flowermask,'L').save(ROOT/'A11_FLOWER_PIXEL_MASK.png')
Image.fromarray((protected*255).astype(np.uint8),'L').save(ROOT/'A11_PROTECTED_ROAD_AND_EDGE_MASK.png')
changed=np.any(out!=original,axis=2)
manifest={'stage':'A11','baseline_file':'A11_INPUT_A10_GROUND_544x416.png','baseline_sha256':sh(ROOT/'A11_INPUT_A10_GROUND_544x416.png'),'candidate_sha256':sh(ROOT/'A11_ECOLOGY_CANDIDATE_544x416.png'),'resolution':[W,H],'algorithm':'deterministic multi-scale correlated eco-color field with separately seeded 1px-3px ground-level vegetation/flower pixels','seed':SEEDS,'road_pixels':int(road.sum()),'edge_band_pixels':int(band.sum()),'protected_pixels':int(protected.sum()),'protected_pixels_changed':int(np.count_nonzero(changed&protected)),'editable_pixels':int(editable.sum()),'editable_pixels_changed':int(np.count_nonzero(changed&editable)),'tint_changed_pixels':int(np.count_nonzero(tint&editable)),'turf_groups':len(used),'tuft_pixels':int(np.count_nonzero(tmask)),'flower_groups':len(flowers),'flower_pixels':int(np.count_nonzero(flowermask)),'input_reference_source':'original A10 new 544x416 native pixel-space generated ground; no new original ground3 crops','no_standing_objects_added':True,'no_neural_model_executed':True,'art':'NOT_EVALUATED','godot':'NOT_RUN','vx':'NOT_RUN','formal_seal':'NO'}
(ROOT/'A11_ECOLOGY_MANIFEST.json').write_text(json.dumps(manifest,indent=2,ensure_ascii=False),encoding='utf8')
print('A11_GENERATED',json.dumps(manifest,indent=2),flush=True)
