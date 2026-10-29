#!/usr/bin/env python3
"""R17 Stage9: brand-new from source TILES, not an old Ground raster.
Two material variants drawn with original 32px independent grass/path tiles,
atlas-derived *ground-level* flowers/foliage, and irregular paths.
Do not claim art pass automatically.
"""
from PIL import Image,ImageDraw,ImageFilter,ImageChops
from pathlib import Path
import numpy as np, math, random, json,hashlib
root=Path(__file__).resolve().parent
folder=root/'sources'; W,H=544,416
SEED=920261029
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
grass=Image.open(folder/'grass_tile.png').convert('RGB')
dirt=Image.open(folder/'path_tile.png').convert('RGB')
par=Image.open(root/'PAR.png').convert('RGBA')
assert grass.size==(32,32) and dirt.size==(32,32) and par.size==(W,H)
# Newly authored world terrain from original source texture tiles only.
def tile(texture):
 a=np.asarray(texture)
 return np.tile(a,(math.ceil(H/texture.height),math.ceil(W/texture.width),1))[:H,:W].copy()
def field(seed,span):
 rng=np.random.default_rng(seed)
 a=(rng.random((math.ceil(H/span)+3,math.ceil(W/span)+3))*255).astype('uint8')
 return np.asarray(Image.fromarray(a).resize((W,H),Image.Resampling.BICUBIC),dtype=np.float32)/255
def mix(a,b,t):
 return np.clip(a*(1-t)+b*t,0,255).astype('uint8')
def bezier(points,steps=220):
 a,b,c,d=points
 return [(round((1-t)**3*a[0]+3*(1-t)**2*t*b[0]+3*(1-t)*t*t*c[0]+t**3*d[0]),
          round((1-t)**3*a[1]+3*(1-t)**2*t*b[1]+3*(1-t)*t*t*c[1]+t**3*d[1]))
          for t in [i/steps for i in range(steps+1)]]
# Same physical world positions as PAR source at 544x416.
blueprint={
 "canvas":[W,H],"grid":32,
 "door_blue_approx":[338,285],"door_ochre_approx":[433,151],
 "tree_foot_approx":[133,293],
 "ground_sources":["grass_tile.png","path_tile.png","legacy_tileD.png","legacy_tileE.png"],
 "source_rule":"new Ground authored from source grass/path tiles and original vegetation atlas, never from old Ground or full Master",
 "par_unchanged_sha256":sha(root/'PAR.png'),
 "par_authoring_history":"Stage5 separately generated alpha PAR, repaired and nearest-scaled in Stage7; still precomposed and not per-object editable",
 "ground_vegetation_max_nominal_px":[16,13],
 "no_tall_objects_on_ground":True,
 "tree_bottom_pixel_ownership":"Ground shadow-only in candidate, historic bark tile rule HOLD (avoid isolated stump)"
}
# Collect ONLY small independently authored foliage elements from original TileD/E source atlases.
sprites=[]
atlas_info=[]
for file in ['legacy_tileD.png']:
 im=Image.open(folder/file).convert('RGBA')
 rgba=np.asarray(im)
 # Source mini sprites located in atlas; never inspect an old scene/ground image.
 if file=='legacy_tileD.png':
    region=(445,220,512,399)
 else:
    region=(110,0,238,87)
 x0,y0,x1,y1=region
 sub=rgba[y0:y1,x0:x1]
 mask=np.where(sub[:,:,3]>128,255,0).astype('uint8')
 # Pure NumPy/Python source-atlas connected components, no OpenCV dependency.
 labels=np.zeros(mask.shape,dtype=np.int32);stat=[[0,0,0,0,0]];n=1
 for yy in range(mask.shape[0]):
  for xx in range(mask.shape[1]):
   if mask[yy,xx]==0 or labels[yy,xx]!=0:continue
   stack=[(xx,yy)];labels[yy,xx]=n;pixels=[]
   while stack:
    cx,cy=stack.pop();pixels.append((cx,cy))
    for dy in (-1,0,1):
     for dx in (-1,0,1):
      ax=cx+dx;ay=cy+dy
      if 0<=ax<mask.shape[1] and 0<=ay<mask.shape[0] and labels[ay,ax]==0 and mask[ay,ax]>0:
       labels[ay,ax]=n;stack.append((ax,ay))
   bx0=min(v[0] for v in pixels);by0=min(v[1] for v in pixels)
   bx1=max(v[0] for v in pixels);by1=max(v[1] for v in pixels)
   stat.append([bx0,by0,bx1-bx0+1,by1-by0+1,len(pixels)]);n+=1
 accepted=0
 for i in range(1,n):
    x,y,w,h,area=map(int,stat[i])
    if not (5<=w<=42 and 5<=h<=40 and 24<=area<=600):continue
    # Don't collect sprites touching the atlas crop boundaries or intersect neighbouring atlas cells.
    if x<2 or y<2 or x+w>=x1-x0-2 or y+h>=y1-y0-2:continue
    patch=Image.fromarray(sub[y:y+h,x:x+w].copy(),'RGBA')
    a=np.asarray(patch).copy()
    a[labels[y:y+h,x:x+w]!=i,3]=0
    patch=Image.fromarray(a,'RGBA')
    # Reject anything brown/gray or white stone, favor garden greens.
    arr=np.asarray(patch)
    visible=arr[arr[:,:,3]>160,:3].astype('float32')
    if len(visible)<20:continue
    vivid=((visible[:,1]>visible[:,0]*.72)&(visible[:,1]>visible[:,2]*.85)).mean()
    dark_fraction=((visible[:,0]<75)&(visible[:,1]<75)&(visible[:,2]<65)).mean()
    brown_fraction=((visible[:,0]>visible[:,1]*1.13)&(visible[:,1]>visible[:,2]*.9)).mean()
    if vivid <.66 or dark_fraction>.12 or brown_fraction>.29: continue
    patch.thumbnail((16,13),Image.Resampling.NEAREST)
    if patch.getchannel('A').getbbox():
        sprites.append((file,patch))
        accepted+=1
 atlas_info.append({'source':file,'components_kept':accepted})
# Backup tiny decorative source micro components, not derived from ground scenes.
print('FOLIAGE_SOURCE_COMPONENTS',atlas_info,'TOTAL',len(sprites))
if len(sprites)<2:
 # fallback hand-art cluster for native pixel sprite, no style theft
 for typ in range(5):
    m=Image.new('RGBA',(12,9))
    d=ImageDraw.Draw(m)
    rng=random.Random(typ+29)
    for i in range(18):
        x=rng.randrange(2,10);y=rng.randrange(2,8)
        d.rectangle((x,y,x+1,y+1),fill=rng.choice([(51,132,58),(77,158,63),(133,178,77),(197,199,113)]))
    sprites.append(('GENERATED_NATIVE_FLOWER',m))
# Path from independent source; controlling physical anchors
paths=[
 (bezier(((322,434),(320,386),(331,327),(336,281))),32),
 (bezier(((336,281),(367,243),(407,178),(435,147))),29),
 (bezier(((-20,360),(95,363),(210,332),(336,281))),29),
 (bezier(((335,284),(404,323),(485,307),(570,334))),24),
]
p=Image.new('L',(W,H),0);pd=ImageDraw.Draw(p)
for points,width in paths:
 pd.line(points,fill=255,width=width,joint='curve')
 for x,y in points[::9]:pd.ellipse((x-width//2,y-width//2,x+width//2,y+width//2),fill=255)
pblur=np.asarray(p.filter(ImageFilter.GaussianBlur(3.5)),dtype=np.float32)
micro=field(SEED+1,4);macro=field(SEED+2,27)
path_mask=pblur>(105+(micro-.5)*66+(macro-.5)*25)
path_margin=np.asarray(p.filter(ImageFilter.GaussianBlur(8)),dtype=np.float32)/255.
f1=field(SEED+3,17);f2=field(SEED+4,83)
ridge=field(SEED+5,3)
# Direct tile source mosaic variant A and texture-enhanced variant B.
out=[]
for variant in ('A_SOURCE_TILE','B_LAYERED_SOURCE_TEXTURE'):
 rnd=random.Random(SEED+(11 if variant[0]=='A' else 42))
 grassbase=tile(grass).astype('float32')
 # Patch-wise independent tile source variation with feathery edge: avoids repeated raw tiles.
 shifted=grassbase.copy()
 if variant[0]=='B':
    for jy in range(0,H,48):
     for jx in range(0,W,48):
       patch=grass.rotate(rnd.choice([0,90,180,270]),expand=False).convert('RGB')
       color=np.asarray(patch.resize((48,48),Image.Resampling.NEAREST),dtype='float32')
       top=min(48,H-jy);left=min(48,W-jx)
       shifted[jy:jy+top,jx:jx+left]=(grassbase[jy:jy+top,jx:jx+left]*.65+color[:top,:left]*.35)
 grassbase=shifted
 tint=np.dstack([(-7+f1*8+f2*10),(-10+f1*12+f2*14),(-6+f1*7+f2*4)])
 meadow=np.clip(grassbase+tint,0,255)
 # Palette range drawn from source, tiny shadow areas and sunlight; no large grass "bush".
 luma=(((f1-.5)*8 + (f2-.5)*12) if variant[0]=='A' else ((f1-.5)*14+(f2-.5)*20))
 meadow=np.clip(meadow+luma[...,None],0,255)
 pathtex=tile(dirt).astype('float32')
 pathcolor=pathtex.copy()
 pathcolor*=np.clip(0.90+f1[...,None]*.22,0,2)
 pathcolor=np.clip(pathcolor+np.dstack([f2*12,f2*11,f2*3]),0,255)
 darkrim=np.array([86.,89.,44.],dtype='float32')
 rimstrength=(np.clip(path_margin-0.28,0,0.45)*.45)[...,None]
 meadow=meadow*(1-rimstrength)+darkrim*rimstrength
 rgb=meadow.copy()
 rgb[path_mask]=pathcolor[path_mask]
 # Coherent irregular slabs: only 60-115, not a repeating 8px pebble strip.
 pic=Image.fromarray(np.uint8(np.clip(rgb,0,255)),'RGB').convert('RGBA')
 dr=ImageDraw.Draw(pic,'RGBA')
 stones=0
 for _ in range(3100):
    x=rnd.randrange(W); y=rnd.randrange(H)
    if not path_mask[y,x] or rnd.random()>(.32 if variant[0]=='A' else .41):continue
    r1=rnd.randint(3,7);r2=rnd.randint(2,5)
    if not all(0<=a<W and 0<=b<H and path_mask[b,a] for a,b in ((x-r1,y),(x+r1,y),(x,y-r2),(x,y+r2))):continue
    v=rnd.randint(-20,18)
    dr.polygon(((x-r1,y),(x-r1+1,y-r2),(x+2,y-r2-1),(x+r1,y),(x+r1-1,y+r2),(x-2,y+r2)),fill=(max(0,123+v),max(0,117+v),max(0,77+v),128))
    dr.line((x-r1+1,y-r2+1,x+1,y-r2),fill=(205,190,129,95),width=1)
    stones+=1
 # Genuine low ground-scale vegetations source atlas, away from paths and building doors.
 patch_positions=[]
 candidates=[(x,y) for x in range(18,W-20,28) for y in range(12,H-18,28)]
 rnd.shuffle(candidates)
 for x,y in candidates:
    if len(patch_positions)>= (51 if variant[0]=='A' else 68):break
    px=x+rnd.randint(-10,10);py=y+rnd.randint(-8,8)
    if path_mask[py,px] or path_margin[py,px]>.2:continue
    # avoid tree root staging and door anchors
    if (abs(px-338)<25 and abs(py-285)<24) or (abs(px-433)<24 and abs(py-151)<22):continue
    kind,spr=rnd.choice(sprites)
    # Mild palette harmonization avoids bright sprite-tile greens clashing with original dark meadow
    tile_arr=np.asarray(spr).copy()
    tile_arr[:,:,0]=np.asarray(np.clip(tile_arr[:,:,0]*.85,0,255),dtype=np.uint8)
    tile_arr[:,:,1]=np.asarray(np.clip(tile_arr[:,:,1]*.81,0,255),dtype=np.uint8)
    tile_arr[:,:,2]=np.asarray(np.clip(tile_arr[:,:,2]*.87,0,255),dtype=np.uint8)
    tile_arr[:,:,3]=np.asarray(tile_arr[:,:,3]*.86,dtype=np.uint8)
    spr=Image.fromarray(tile_arr,'RGBA')
    ox=px-spr.width//2;oy=py-spr.height//2
    if ox<0 or oy<0 or ox+spr.width>=W or oy+spr.height>=H:continue
    pic.alpha_composite(spr,(ox,oy))
    patch_positions.append([px,py,kind])
 # Tiny authored micro flowers, avoid noisy thick turf.
 for j in range(190 if variant[0]=='A' else 285):
    x=rnd.randint(4,W-5);y=rnd.randint(4,H-5)
    if path_mask[y,x] or path_margin[y,x]>.2:continue
    col=rnd.choice([(234,228,188,215),(242,240,229,230),(218,185,206,195),(194,206,154,210)])
    dr.point((x,y),fill=col)
 # Shadows authored for tall objects, not discrete "tree trunk" on Ground.
 shadow=Image.new('RGBA',(W,H),(0,0,0,0)); sd=ImageDraw.Draw(shadow)
 for x,y,rx,ry,alpha in [(127,294,62,11,52),(344,292,68,9,36),(424,164,48,8,38)]:
    sd.ellipse((x-rx,y-ry,x+rx,y+ry),fill=(15,37,17,alpha))
 pic=Image.alpha_composite(pic,shadow.filter(ImageFilter.GaussianBlur(5)))
 output=pic.convert('RGB')
 outfilename=f'GROUND_{variant}.png'
 output.save(root/outfilename,optimize=True)
 comp=Image.alpha_composite(output.convert('RGBA'),par).convert('RGB')
 comp.save(root/f'QA_{variant}.png',optimize=True)
 out.append({"variant":variant,"ground_sha256":sha(root/outfilename),"paths":len(paths),"stone_shapes":stones,
       "micro_flora_source_count":len(patch_positions),"micro_flora_max_px":[16,13],
       "ground_only_tree_pixels":False,"component_atlas_clean_filter":"green-vivid >.66 dark<.12 brown<.29",
       "native_544x416":output.size==(W,H)})
# Primary candidate chosen independently of PASS claims; both are test images.
preferred="B_LAYERED_SOURCE_TEXTURE"
(root/'GROUND.png').write_bytes((root/f'GROUND_{preferred}.png').read_bytes())
(root/'COMPOSITE_QA_ONLY.png').write_bytes((root/f'QA_{preferred}.png').read_bytes())
meta={"schema":"R17_STAGE9_ORIGINAL_TILE_MATERIAL_SOURCE","scene_blueprint":blueprint,"variants":out,
"stage8_ground_source_used":False,"par_unchanged_sha256":sha(root/'PAR.png'),
"ground_sha256":sha(root/'GROUND.png'),"art_status":"HOLD_REQUIRES_HUMAN_SOURCE_ART_REVIEW",
"formal_seal":"NO"}
(root/'STAGE9_SOURCE_AND_SCALE_AUDIT.json').write_text(json.dumps(meta,ensure_ascii=False,indent=2),encoding='utf8')
print(json.dumps({"status":"TECH_CANDIDATE_ART_UNREVIEWED","variants":out,
"floral_atlas":atlas_info,"preferred":preferred,"ground_sha":sha(root/'GROUND.png')},ensure_ascii=False))
