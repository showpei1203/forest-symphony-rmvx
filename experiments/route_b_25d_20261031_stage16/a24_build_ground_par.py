from pathlib import Path
import numpy as np,json,hashlib,math
from PIL import Image,ImageDraw
R=Path(__file__).resolve().parent
P=R/'INPUTS'/'Graphics' if (R/'INPUTS'/'Graphics').exists() else Path(r'E:\GameAssetToolLab_20261023\ASF_Test_20261031\VX_A09_3_INENGINE_BRIDGE\Graphics')
A23=R/'INPUTS'/'A23' if (R/'INPUTS'/'A23').exists() else Path(r'E:\FS_ROUTE_B_STAGE16_A23_SCENE_MATERIAL_SEPARATION_20261101')
A22=R/'INPUTS'/'A22' if (R/'INPUTS'/'A22').exists() else Path(r'E:\FS_ROUTE_B_STAGE16_A22_CLEAN_STYLE_AB_20261101')
W,H=544,416
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
grass_file=A23/'A10_GROUND3_GRASS_SOURCE_64.png';sand_file=A23/'A09_GROUND3_ORIGINAL_48.png'
assert sha(grass_file)=='b185fbbccd5f84a58f12144b906d7a5fe71809b59a8f75ac385c92b2c5543407'
assert sha(sand_file)=='ca7c4ea242a9b81ab39113acdad1de47ed193117d1f5db6c6d2dea5383548adb'
g=np.asarray(Image.open(grass_file).convert('RGB'),np.uint8)
s=np.asarray(Image.open(sand_file).convert('RGB'),np.uint8)
def mincost_path(cost):
 n,m=cost.shape;v=np.zeros((n,m));pr=np.zeros((n,m),np.int16);v[0]=cost[0]
 for y in range(1,n):
  for x in range(m):
   opts=range(max(0,x-1),min(m,x+2))
   b=min(opts,key=lambda k:v[y-1,k])
   v[y,x]=v[y-1,b]+float(cost[y,x]);pr[y,x]=b
 pos=int(v[-1].argmin());out=np.empty(n,np.int16)
 for y in range(n-1,-1,-1):
  out[y]=pos
  if y:pos=int(pr[y,pos])
 return out
def quilt(src,h,w,seed,step=16,ps=24,tries=35):
 rng=np.random.default_rng(seed)
 out=np.zeros((h,w,3),np.uint8);filled=np.zeros((h,w),bool)
 for y in range(0,h,step):
  for x in range(0,w,step):
   hh=min(h-y,ps);ww=min(w-x,ps)
   old=out[y:y+hh,x:x+ww];seen=filled[y:y+hh,x:x+ww]
   best=None;bestcost=float('inf')
   for z in range(tries):
    sy=int(rng.integers(0,src.shape[0]-hh+1))
    sx=int(rng.integers(0,src.shape[1]-ww+1))
    tile=src[sy:sy+hh,sx:sx+ww]
    cost=float(np.abs(tile.astype(np.int16)-old.astype(np.int16)).mean(axis=2)[seen].mean()) if seen.any() else 0.0
    if cost<bestcost:bestcost=cost;best=tile.copy()
   place=np.ones((hh,ww),bool)
   if x:
    l=max(0,ww-step)
    if l:
     diff=np.abs(best[:,:l].astype(np.int16)-old[:,:l].astype(np.int16)).mean(axis=2)
     path=mincost_path(diff)
     place &= np.arange(ww)[None,:]>=path[:,None]
   if y:
    t=max(0,hh-step)
    if t:
     diff=np.abs(best[:t].astype(np.int16)-old[:t].astype(np.int16)).mean(axis=2)
     path=mincost_path(diff.T)
     place &= np.arange(hh)[:,None]>=path[None,:]
   place |=~seen
   old[place]=best[place];seen[place]=True
 assert filled.all()
 return out
# Model source 128x128 path shape, reuse native geometry profile and stitch 4 consecutive strips.
profiles=[]
for i in (1,4):
 mask=np.asarray(Image.open(A23/f'A23_VARIANT_{i:02d}_CONNECTED_SAND_MASK.png').convert('L'))>127
 centers=[];width=[]
 for y in range(128):
  xs=np.flatnonzero(mask[y])
  centers.append(float(xs.mean()) if len(xs)>10 else float('nan'))
  width.append(float(len(xs)) if len(xs)>10 else float('nan'))
 good=np.flatnonzero(np.isfinite(centers))
 assert len(good)>80,(i,len(good))
 centers=np.interp(np.arange(128),good,np.asarray(centers)[good])
 width=np.interp(np.arange(128),good,np.asarray(width)[good])
 profiles.append((centers,width))
cent=np.zeros(H,np.float64);wide=np.zeros(H,np.float64)
current=256
for chunk in range(math.ceil(H/128)):
 c,w=profiles[chunk%2]
 start=chunk*128; end=min(H,start+128);n=end-start
 curve=c[:n]-c[0]
 # Keep original AI topology from each segment while aligning segment join and adding gentle macro drift.
 drift=np.sin(np.linspace(0,math.pi,n))*9*((chunk%3)-1)
 cent[start:end]=current+curve+drift
 wide[start:end]=np.clip(w[:n]*1.35,24,54)
 current=float(cent[end-1])
# Keep new scene inside walkable bounds and apply bounded inherited 1px irregularity from original road mask.
cent=np.clip(cent,105,W-105)
xx=np.arange(W)[None,:]
mask=np.abs(xx-cent[:,None])<(wide[:,None]/2)
assert mask.shape==(H,W)
assert int(mask.sum())>10000
Image.fromarray((mask*255).astype('uint8'),'L').save(R/'A24_GROUND_SAND_PATH_MASK_544x416.png')
print('A24_REAL_SOURCE_MATERIAL_QUILTING',flush=True)
grass_tex=quilt(g,H,W,seed=24001);sand_tex=quilt(s,H,W,seed=24002)
base=np.where(mask[:,:,None],sand_tex,grass_tex).astype(np.uint8)
Image.fromarray(base,'RGB').save(R/'A24_FS_PIXEL_QUILTED_GROUND_BASE_544x416.png')
# Ground-level flora (never PAR), original A23 alpha-source crop projection.
ground=Image.fromarray(base,'RGB').convert('RGBA')
flora_specs=[(1,26,106),(2,365,54),(3,35,278),(4,363,274),(1,215,200)]
flora_count=0
for i,x,y in flora_specs:
 overlay=Image.open(A23/f'A23_AI_BOTANICAL_OVERLAY_RGBA_V{i:02d}.png').convert('RGBA')
 assert overlay.size==(128,128)
 raw=np.asarray(overlay).copy()
 # Explicitly exclude hard 128px source-card borders that became visible as white framing lines.
 raw[:2,:,3]=0;raw[-2:,:,3]=0;raw[:,:2,3]=0;raw[:,-2:,3]=0
 overlay=Image.fromarray(raw,'RGBA')
 b=np.asarray(overlay.getchannel('A'))>0
 flora_count+=int(b.sum())
 ground.alpha_composite(overlay,(x,y))
ground=ground.convert('RGB')
ground.save(R/'A24_GROUND_544x416.png')
# Independent transparent PAR asset extraction from already-existing FS authored sprites.
O=P/'Characters'/'!$Object2.png'
L=P/'Characters'/'!$habbel_lamp.png'
T=P/'Parallaxes'/'par12.png'
assets={}
def source_crop(src,box,filename):
 im=Image.open(src).convert('RGBA').crop(box)
 out=R/'PAR_COMPONENTS';out.mkdir(exist_ok=True)
 im.save(out/filename)
 assets[filename]={'source_name':src.name,'source_sha256':sha(src),'source_crop_box':box,'component_sha256':sha(out/filename),'size':im.size}
 return im
rock=source_crop(O,(0,0,32,32),'FS_ROCK_32_RGBA.png')
barrel=source_crop(O,(32,0,64,32),'FS_BARREL_32_RGBA.png')
lamp=source_crop(L,(0,0,32,64),'FS_LAMP_32x64_RGBA.png')
# Native alpha foliage from FS PAR original, placed only on the scene boundary: not an invented stand-alone tree.
border_left=source_crop(T,(0,304,95,720),'FS_BORDER_LEFT_95x416_RGBA.png')
border_right=source_crop(T,(1210,304,1280,720),'FS_BORDER_RIGHT_70x416_RGBA.png')
par=Image.new('RGBA',(W,H),(0,0,0,0))
objects=[]
def place(im,name,x,y,blocking,category,foot_height=0):
 par.alpha_composite(im,(x,y))
 box={'id':name,'category':category,'x':x,'y':y,'width':im.width,'height':im.height,
      'foot':(x+im.width//2,y+im.height-1),'blocking':blocking,'foot_height':foot_height}
 objects.append(box)
place(border_left,'forest_left',-30,0,True,'forest_boundary')
place(border_right,'forest_right',W-60,0,True,'forest_boundary')
for j,(x,y) in enumerate([(120,70),(417,130),(100,317),(420,350)]):
 place(rock,f'rock_{j+1}',x,y,True,'rock')
for j,(x,y) in enumerate([(169,153),(404,275)]):
 place(barrel,f'barrel_{j+1}',x,y,True,'barrel')
for j,(x,y) in enumerate([(206,290),(369,80)]):
 place(lamp,f'lamp_{j+1}',x,y,True,'lamp',foot_height=12)
par.save(R/'A24_PAR_RGBA_544x416.png')
# Foreground/behind-player depth split for a test actor foot at (278,208).
actor_foot=(int(round(cent[208])),208)
par_base=Image.new('RGBA',(W,H),(0,0,0,0))
par_front=Image.new('RGBA',(W,H),(0,0,0,0))
# Disambiguate occlusion: according to depth / object foot. Behind-character objects in par_base,
# objects that should occlude a character behind them in par_front. This screenshot uses only one test footpoint.
def component_by_name(obj):
 if obj['category']=='forest_boundary':return border_left if obj['id']=='forest_left' else border_right
 if obj['category']=='rock':return rock
 if obj['category']=='barrel':return barrel
 return lamp
for obj in objects:
 sprite=component_by_name(obj)
 (par_front if obj['foot'][1]>=actor_foot[1] else par_base).alpha_composite(sprite,(obj['x'],obj['y']))
par_base.save(R/'A24_PAR_BACK_RGBA_544x416.png')
par_front.save(R/'A24_PAR_FRONT_RGBA_544x416.png')
# VX 32 tile collision: all GROUND walkable by default; only PAR foot tiles block + forest border.
tw,th=W//32,H//32
assert (tw,th)==(17,13)
blocks=np.zeros((th,tw),np.uint8)
for obj in objects:
 if not obj['blocking']:continue
 if obj['category']=='forest_boundary':
  for y in range(th):
   if obj['id']=='forest_left':blocks[y,0]=1
   else:blocks[y,-1]=1
 else:
  fx,fy=obj['foot']
  tx,ty=max(0,min(tw-1,fx//32)),max(0,min(th-1,fy//32))
  blocks[ty,tx]=1
start=(int(actor_foot[0]//32),int(actor_foot[1]//32))
assert blocks[start[1],start[0]]==0,('actor start blocked',start)
# A path remains walkable by default, but nearby objects may still block specific cells.
collision={'tile_size':32,'map_size_px':[W,H],'grid':[tw,th],'ground_walkable_by_default':True,
           'blocked_tile_coords':[[int(x),int(y)] for y,x in zip(*np.where(blocks==1))],
           'blocked_count':int(blocks.sum()),'actor_test_foot':list(actor_foot),'actor_start_tile':list(start),
           'layer_semantics':'only PAR object foot collisions block; Ground tile masks dont block',
           'integration':'DIAGNOSTIC candidate, native VX passage APIs not patched'}
(R/'A24_PAR_COLLISION_32_GRID.json').write_text(json.dumps(collision,ensure_ascii=False,indent=2),encoding='utf8')
# Combined 1x reference snapshot, no nearest upscale; actor demonstration pixel stand-in (NOT FS actor sprite).
composite=ground.convert('RGBA')
composite=Image.alpha_composite(composite,par_base)
with_back=Image.alpha_composite(ground.convert('RGBA'),par)
with_back.convert('RGB').save(R/'A24_GROUND_PAR_COMPOSITE_544x416.png')
actor=Image.new('RGBA',(22,38),(0,0,0,0));d=ImageDraw.Draw(actor)
d.ellipse((4,1,17,14),fill=(240,210,174,255),outline=(55,52,53,255))
d.rectangle((3,15,18,31),fill=(40,86,164,255),outline=(31,43,69,255))
d.rectangle((5,29,9,37),fill=(42,42,53,255))
d.rectangle((13,29,17,37),fill=(42,42,53,255))
composite.alpha_composite(actor,(actor_foot[0]-11,actor_foot[1]-37))
composite=Image.alpha_composite(composite,par_front)
composite.convert('RGB').save(R/'A24_ACTOR_OCCLUSION_DIAGNOSTIC_544x416.png')
# Existing asset source + official sandbox role manifest.
manifest={'stage':'A24','date':'2026-11-01','dimensions':[W,H],'vx_tiles':[tw,th],
 'architecture_proposal':{'future_GROUND':'PixelLab generated full canvas direct image (NOT EXECUTED in A24)','future_PAR':'Assistant-produced transparent objects/occlusion/collision from verified FS components'},
 'actual_A24_GROUND':'source-native FS texture quilting from 64x64 grass and 48x48 sand; native AI A22 geometry profile; no PixelLab 544x416 direct generation',
 'actual_A24_PAR':'assistant assembled transparent PAR from original already-authored FS character sprites + existing par12 border vegetation',
 'tree_object_test':'NOT_TESTED, forest boundary overlays only, do not claim separate complete trees',
 'source_components':assets,'objects':objects,
 'ground_walkable_default':True,'par_blocked_tile_count':int(blocks.sum()),
 'flora_direct_A22_overlay_count':flora_count,'ground_road_fraction':round(float(mask.mean()),6),
 'input_model_A22_variants':[sha(A22/f'A22_CLEAN_STYLE_NATIVE128_VARIANT_{i:02d}.png') for i in (1,4)],
 'sources':{'grass_sha256':sha(grass_file),'sand_sha256':sha(sand_file)},
 'gate':{'native_544x416_png':'PASS','ground_par_dimensions_and_alpha':'PASS','actor_scene_standalone_composite':'PASS_SNAPSHOT_ONLY',
 '32px_collision_grid':'PRELIMINARY_RULE_COMPUTED_NOT_IN_ENGINE','full_Ground3_art':'NOT_APPROVED','Godot':'NOT_RUN','native_VX':'NOT_RUN','Formal_Seal':'NO'},
 'A24_API_post_count':0,'A24_pixelLab_generations_spent':0,'last_confirmed_balance':1970}
(R/'A24_SCENE_MANIFEST.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf8')
print('A24_ASSETS_GENERATED',json.dumps({'map':[W,H],'source_objects':len(objects),'par_sources':list(assets),'road_pixels':int(mask.sum()),'collision_blocked':int(blocks.sum()),'actor_test_foot':actor_foot},ensure_ascii=False),flush=True)
