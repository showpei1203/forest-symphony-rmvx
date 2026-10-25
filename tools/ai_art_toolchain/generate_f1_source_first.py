from pathlib import Path
import numpy as np, json, hashlib, math, shutil
from scipy.ndimage import gaussian_filter,uniform_filter
from PIL import Image
ROOT=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
FS=Path(r"E:\GameAssetToolLab_20261023\FS_STYLE_FIRST_V21_WELL_CROP_COLLISION_20261024")
DEST=ROOT/"outputs/FS_F1_ORIGINAL_GROUND_SOURCE_FIRST_20261025"
SEED=20261025
def digest(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def mk(path):
 path.parent.mkdir(parents=True,exist_ok=True)
 return path
def read(p):return np.asarray(Image.open(p).convert("RGB"),dtype=np.uint8)
def candidates(img,typ,patch=32,limit=1000):
 r,g,b=np.moveaxis(img.astype(np.float32),2,0)
 if typ=="grass":mask=(g>r*1.06)&(g>b*1.13)&(g>55)
 else:mask=(r>g*1.065)&(r>b*1.55)&(r>90)
 rat=uniform_filter(mask.astype(np.float32),size=patch,mode="constant")
 ys,xs=np.where(rat[patch//2:-patch//2+1:4,patch//2:-patch//2+1:4]>.84)
 ys=ys*4+patch//2
 xs=xs*4+patch//2
 positions=[(int(x-patch//2),int(y-patch//2)) for x,y in zip(xs,ys)
            if x-patch//2>=0 and x+patch//2<=img.shape[1] and y-patch//2>=0 and y+patch//2<=img.shape[0]]
 rng=np.random.default_rng(SEED+(0 if typ=="grass" else 6))
 if len(positions)>limit:positions=[positions[i] for i in rng.choice(len(positions),limit,replace=False)]
 items=np.stack([img[y:y+patch,x:x+patch] for x,y in positions])
 if len(items)<40:raise RuntimeError(f"Insufficient {typ} patches {len(items)}")
 print("PATCH_POOL",typ,len(items))
 return items,positions
def seam(error,vertical=True):
 # Along rows; choose cut location in col 0..overlap-1
 h,w=error.shape
 costs=error.copy().astype(np.float64)
 back=np.zeros((h,w),dtype=np.int16)
 for yy in range(1,h):
  for xx in range(w):
   options=[max(0,xx-1),xx,min(w-1,xx+1)]
   jj=min(options,key=lambda j:costs[yy-1,j])
   costs[yy,xx]+=costs[yy-1,jj];back[yy,xx]=jj
 x=int(np.argmin(costs[-1]));line=np.zeros(h,np.int32)
 for y in range(h-1,-1,-1):
  line[y]=x
  if y:x=int(back[y,x])
 return line
def quilt(patches,w=544,h=416,patch=32,overlap=8,seed=3):
 rng=np.random.default_rng(seed)
 stride=patch-overlap
 canvas=np.zeros((h+patch,w+patch,3),np.uint8)
 used=np.zeros((h+patch,w+patch),np.bool_)
 last=-1
 for y in range(0,h,stride):
  for x in range(0,w,stride):
   count=min(160,len(patches))
   picks=rng.choice(len(patches),count,replace=False)
   sub=patches[picks]
   scores=np.zeros(count,np.float64)
   if x:
    ref=canvas[y:y+patch,x:x+overlap].astype(np.int16)
    scores+=np.mean((sub[:,:,:overlap].astype(np.int16)-ref)**2,axis=(1,2,3))
   if y:
    ref=canvas[y:y+overlap,x:x+patch].astype(np.int16)
    scores+=np.mean((sub[:,:overlap].astype(np.int16)-ref)**2,axis=(1,2,3))
   if last>=0:scores+=np.where(picks==last,8000,0)
   k=max(2,int(count*.07))
   elite=np.argpartition(scores,k)[:k]
   weights=1/(np.maximum(scores[elite]-scores[elite].min(),1)+8)**.4
   selected=int(rng.choice(elite,p=weights/weights.sum()))
   last=int(picks[selected])
   art=sub[selected]
   # pixel assignment: own new region, selective ownership in overlap; no interpolation/blurring.
   mask=np.ones((patch,patch),bool)
   if x:
    old=canvas[y:y+patch,x:x+overlap].astype(np.int16)
    cost=np.mean((old-art[:,:overlap].astype(np.int16))**2,axis=2)
    path=seam(cost)
    mask[:,:overlap]=np.arange(overlap)[None,:]>=path[:,None]
   if y:
    old=canvas[y:y+overlap,x:x+patch].astype(np.int16)
    cost=np.mean((old-art[:overlap].astype(np.int16))**2,axis=2)
    horizontal=seam(cost.T)
    mask[:overlap,:]&=np.arange(overlap)[:,None]>=horizontal[None,:]
   roi=canvas[y:y+patch,x:x+patch]
   roi[mask]=art[mask]
 return canvas[:h,:w]
def polyline_distance(xx,yy,nodes):
 d=np.full(xx.shape,1e9,np.float32)
 for (ax,ay),(bx,by) in zip(nodes[:-1],nodes[1:]):
  vx,vy=bx-ax,by-ay
  t=np.clip(((xx-ax)*vx+(yy-ay)*vy)/(vx*vx+vy*vy),0,1)
  v=np.sqrt((xx-(ax+t*vx))**2+(yy-(ay+t*vy))**2)
  d=np.minimum(d,v)
 return d
def compose_new_ground(src):
 rng=np.random.default_rng(SEED+39)
 grass,p1=candidates(src,"grass")
 dirt,p2=candidates(src,"dirt")
 g=quilt(grass,seed=SEED+201)
 d=quilt(dirt,seed=SEED+444)
 y,x=np.mgrid[0:416,0:544].astype(np.float32)
 nodes=[(-80,277),(40,266),(150,247),(245,263),(325,225),(445,229),(605,198)]
 road=polyline_distance(x,y,nodes)
 spur=polyline_distance(x,y,[(244,-35),(238,40),(259,115),(264,170),(245,263)])
 road=np.minimum(road,spur+8.5)
 # Spur breaks off road; entrance patches are naturally irregular by spatial noise.
 macro=gaussian_filter(rng.standard_normal((416,544)).astype(np.float32),14)
 macro=macro/(macro.std()+1e-8)*2.8
 micro=gaussian_filter(rng.standard_normal((416,544)).astype(np.float32),3.0)
 micro=micro/(micro.std()+1e-8)*2.2
 field=road+macro+micro
 # Road thickness: meadow path main +-31px, spur +-22px; blend ragged edges
 spur_e=polyline_distance(x,y,[(244,-35),(238,40),(259,115),(264,170),(245,263)])
 is_road=(road+macro+micro < np.where(spur_e<road+2,24,31))
 fringe=np.clip((31-field)/16+.5,0,1)
 # Dither fringe in exact pixels, use source-true sampled RGB without interpolation
 pick=rng.random((416,544))<fringe
 mask=is_road | ((field>25)&(field<41)&pick)
 result=g.copy();result[mask]=d[mask]
 # A few low-res soil/grass inclusions instead of gradient blur
 pebbles=gaussian_filter(rng.standard_normal((416,544)).astype(np.float32),1.5)
 spot=(pebbles>1.2)&(field>15)&(field<50)
 result[spot]=d[spot]
 result[~mask & (pebbles < -2.2)]=g[~mask&(pebbles<-2.2)]
 return result,mask,{"grass_patch_pool":len(p1),"dirt_patch_pool":len(p2),"road_pixels":int(mask.sum())}
def main():
 if DEST.exists():raise RuntimeError("No overwrites: "+str(DEST))
 DEST.mkdir(parents=True)
 training=FS/"build/Ground.png"
 master=read(training)
 rgb,road,stats=compose_new_ground(master)
 gr=mk(DEST/"source/ground_procedural_F1.png")
 Image.fromarray(rgb).save(gr)
 # Ground decorations remain Ground-only; reference patches are original with alpha.
 approved=json.loads((FS/"scene_manifest.json").read_text(encoding="utf-8-sig"))
 decor=[(FS/"source/patches/grass_decal_01.png",39,338),
        (FS/"source/patches/grass_decal_02.png",428,100)]
 composition=Image.open(gr).convert("RGBA")
 for f,x,y in decor:
  im=Image.open(f).convert("RGBA")
  composition.alpha_composite(im,dest=(x,y))
 composition.convert("RGB").save(gr)
 assets=[
  ("tree_moss_01.png","tree","tree_west",22,20),
  ("tree_blue_02.png","tree","tree_east",393,28),
  ("tree_lime_03.png","tree","tree_south",392,291),
  ("rock_meadow_01.png","rock","rock_north",294,35),
  ("rock_meadow_02.png","rock","rock_west",24,306),
  ("stone_well_src.png","well","well_east",332,260),
  ("sign_wood_01.png","sign","sign_crossroads",275,138),
  ("flower_hedge_src.png","hedge","hedge_south",137,323),
 ]
 objs=[];prop_ledger=[];final=composition.copy()
 outpro=DEST/"source/props"
 for name,kind,oid,px,py in assets:
  ref=FS/"source/clean"/name
  assert ref.exists()
  pic=Image.open(ref).convert("RGBA");sz=pic.size
  cp=mk(outpro/(oid+".png"));shutil.copy2(ref,cp)
  src_match=next((o for o in approved["objects"] if o["asset_id"]==Path(name).stem),None)
  if src_match is None:
   # Find by actual path, choose tail fixture for tree lime / rock variant.
   src_match=next((o for o in approved["objects"] if Path(o["authoritative_asset_path"]).name==name),None)
  if src_match is None:
   # Conservative contact at base of asset, no automatically blocking entire sprite
   contact=[int(sz[0]*.25),int(sz[1]*.79),int(sz[0]*.75),sz[1]]
   localfoot=[sz[0]//2,sz[1]-2]
  else:
   contact=src_match["collision_local"];localfoot=[src_match["foot_anchor"][0]-src_match["x"],src_match["foot_anchor"][1]-src_match["y"]]
  objs.append({"id":oid,"kind":kind,"x":px,"y":py,"width":sz[0],"height":sz[1],
               "source":"source/props/"+oid+".png","source_sha256":digest(cp),
               "foot_anchor":[px+localfoot[0],py+localfoot[1]],
               "foot_local":localfoot,"contact_local":contact,"occlusion_local":[0,0,sz[0],max(1,contact[1])]})
  prop_ledger.append({"id":oid,"original":str(ref),"sha256":digest(ref),"copyright":"PRIVATE TEST / ORIGINAL SOURCE RIGHTS"})
  final.alpha_composite(pic,dest=(px,py))
 final.save(mk(DEST/"build/Recomposed.png"))
 composition.save(mk(DEST/"build/Ground.png"))
 Image.new("RGBA",(544,416)).save(mk(DEST/"build/PAR_COMPLETE.png"))
 layer=Image.open(DEST/"build/PAR_COMPLETE.png")
 for o in objs:layer.alpha_composite(Image.open(DEST/o["source"]).convert("RGBA"),dest=(o["x"],o["y"]))
 layer.save(DEST/"build/PAR_COMPLETE.png")
 assert np.array_equal(np.array(Image.alpha_composite(composition,layer)),np.array(final))
 (DEST/"source/road_mask.npy").write_bytes(np.packbits(road.astype(np.uint8)).tobytes())
 # Collision tile grid: all ground walkable, object-local contact blocks only its affected footbox.
 blocked=set()
 for row in range(13):
  for col in range(17):
   # 16x12 actor foot sample near the tile bottom at tile-centered x.
   ax0=col*32+8;ax1=ax0+16;ay0=row*32+20;ay1=ay0+12
   for o in objs:
    cx0,cy0,cx1,cy1=o["contact_local"]
    if ax0<o["x"]+cx1 and ax1>o["x"]+cx0 and ay0<o["y"]+cy1 and ay1>o["y"]+cy0:
     blocked.add((col,row));break
 spawn=[8*32+16,11*32+25]
 sc=(spawn[0]//32,spawn[1]//32)
 if sc in blocked:raise RuntimeError("Spawn blocked")
 manifest={"schema":"FS_F1_SOURCE_FIRST_NEW_GROUND_V1","canvas":[544,416],"tile_size":32,
          "ground_generation":"seeded 32px patch-quilting from approved source color samples + NEW path geometry, hard pixel seams; no interpolation",
          "ground_new_source":"source/ground_procedural_F1.png","ground_sha256":digest(gr),
          "reference_training_sha256":digest(training),"seed":SEED,
          "objects":objs,"spawn_world":spawn,
          "collision":{"default_ground_walkable":True,"blocked_tiles":sorted(blocked),"actor_footbox":[16,12],"obstacles":"ONLY independent props contact, no automatic blocking by grass/dirt"},"training_statistics":stats,
          "art_rights":"PRIVATE_TEST_CANDIDATE_NOT_COMMERCIAL_APPROVED","human_visual":"NOT_YET_APPROVED"}
 (DEST/"scene_manifest.json").write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding="utf-8")
 (DEST/"source/reference_ledger.json").write_text(json.dumps(prop_ledger,indent=2),encoding="utf-8")
 print(json.dumps({"generated_ground_sha256":digest(gr),"training_sha256":digest(training),"identical":digest(gr)==digest(training),"objects":len(objs),"blocked":len(blocked),"stats":stats,"dest":str(DEST)},ensure_ascii=True))
if __name__=="__main__":main()
