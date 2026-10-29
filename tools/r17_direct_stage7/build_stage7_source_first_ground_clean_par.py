#!/usr/bin/env python3
"""R17 Stage7 independently painted Ground + original-image PAR alpha repair. Do NOT use any old Ground pixel.
The tree contact is authored from standalone tree SOURCE, not from Master or PAR.
Original high-detail house and tree sources are bundled for cold regeneration.
"""
from PIL import Image,ImageDraw,ImageFilter,ImageChops
from pathlib import Path
import numpy as np, random,hashlib,json,zipfile,math,sys,subprocess
W,H=544,416; root=Path(__file__).resolve().parent
seed=720261029; rnd=random.Random(seed)
sources=root/"sources"; sources.mkdir(exist_ok=True)
layout_id="FS_R17_STAGE7_FRESH_FLOOR_RICH_PAR_20261029"
def file_sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def multi_noise(seed,scale):
    rng=np.random.default_rng(seed)
    a=rng.random((math.ceil(H/scale)+2,math.ceil(W/scale)+2))
    return np.asarray(Image.fromarray(np.uint8(a*255)).resize((W,H),Image.Resampling.BILINEAR),np.float32)/255.
def clip(x):return max(0,min(255,round(x)))
def rgba(c,a=255):return (*c,a)

# ORIGINAL independently drawn base; never reads GROUND_B or Stage4 GROUND.
n2=multi_noise(125,2);n7=multi_noise(126,7);n27=multi_noise(127,27);n91=multi_noise(128,91)
yy,xx=np.mgrid[0:H,0:W]
v=.35*n2+.29*n7+.23*n27+.13*n91
meadow=np.sin(xx/51.4+yy/85.)*.07+np.cos((xx+yy*0.3)/105.)*.07
v=np.clip(v+meadow,0,1)
g=np.zeros((H,W,3),dtype=np.uint8)
for k,(base,spread) in enumerate([(51,96),(91,93),(24,55)]):
 g[:,:,k]=np.clip(base+v*spread,0,255).astype(np.uint8)
ground=Image.fromarray(g,"RGB").convert("RGBA")

# FRESH organic 32px world-aware stone walkway. All drawing done ground only.
terrain_path=Image.new("L",(W,H),0)
d=ImageDraw.Draw(terrain_path)
def bezier(a,b,c,e,n=160):
    return [(round((1-t)**3*a[0]+3*(1-t)**2*t*b[0]+3*(1-t)*t*t*c[0]+t**3*e[0]),
             round((1-t)**3*a[1]+3*(1-t)**2*t*b[1]+3*(1-t)*t*t*c[1]+t**3*e[1])) for t in (i/n for i in range(n+1))]
paths=[
 (bezier((270,-24),(247,75),(251,164),(255,242)),40),
 (bezier((255,242),(242,307),(258,366),(278,438)),41),
 (bezier((-20,378),(85,338),(159,265),(255,242)),39),
 (bezier((255,242),(348,257),(433,215),(567,235)),39)
]
for line,width in paths:
 d.line(line,fill=255,width=width,joint="curve")
 for x,y in line[::12]:d.ellipse((x-width//2,y-width//2,x+width//2,y+width//2),fill=255)
# Dirt fringe around path separately
fringe=terrain_path.filter(ImageFilter.GaussianBlur(7))
edgergba=Image.new("RGBA",(W,H),(108,104,54,0))
edgergba.putalpha(fringe.point(lambda q:int(q*.42)))
ground=Image.alpha_composite(ground,edgergba)
pnoise=.22*multi_noise(306,2)+.30*multi_noise(304,7)+.48*multi_noise(303,21)
bm=np.asarray(terrain_path)>0
arr=np.asarray(ground.convert("RGB")).copy()
for i,(lo,span) in enumerate(((112,50),(95,43),(53,30))):
 arr[:,:,i][bm]=np.clip(lo+pnoise[bm]*span,0,255).astype("uint8")
ground=Image.fromarray(arr,"RGB").convert("RGBA")
pd=ImageDraw.Draw(ground,"RGBA")
# Organic small hand-placed cobble pieces, filled surfaces rather than Stage3 bad outlines.
cobble_count=0
for y in range(3,H,6):
 for x in range(3,W,7):
    if not bm[y,x] or rnd.random()<.34:continue
    cx=x+rnd.randint(-3,3);cy=y+rnd.randint(-3,3)
    if not(5<=cx<W-5 and 5<=cy<H-5 and bm[cy,cx]):continue
    rad=rnd.randint(1,4);rh=rnd.randint(1,3)
    grey=rnd.randint(-17,20)
    outline=(clip(109+grey),clip(96+grey),clip(60+grey))
    fill=(clip(144+grey),clip(128+grey),clip(86+grey))
    pd.ellipse((cx-rad,cy-rh+1,cx+rad,cy+rh+1),fill=(*outline,155))
    pd.ellipse((cx-rad+1,cy-rh,cx+rad-1,cy+rh-1),fill=(*fill,170))
    pd.line((cx-rad+1,cy-rh+1,cx+rad-1,cy-rh+1),fill=(190,164,104,70),width=1)
    cobble_count+=1
# Fine grass scatter: clumps are SINGLE under 12px rather than 50px decorative blobs.
for i in range(5800):
 x=rnd.randrange(W);y=rnd.randrange(H)
 if bm[y,x] and rnd.random()<.92:continue
 if rnd.random()<.67:
    c=rnd.choice([(43,106,43,220),(95,164,62,160),(134,169,66,160),(47,96,39,200)])
    pd.line((x,y,x+rnd.choice([-2,-1,0,1,2]),y-rnd.randint(1,4)),fill=c,width=1)
 else:
    c=rnd.choice([(68,119,40,170),(111,166,61,140),(150,176,73,120)])
    pd.point((x,y),fill=c)
# Tiny flowers: clustered but no giant ground bush. Max patch width 15px, height 12px.
patches=[(25,46),(153,43),(383,32),(501,92),(480,206),(72,372),(142,312),(332,381),
         (386,331),(432,374),(80,255),(277,341),(182,194),(378,182),(501,296)]
for cx,cy in patches:
 for j in range(rnd.randint(5,14)):
    x=cx+rnd.randint(-9,9);y=cy+rnd.randint(-6,6)
    if 2<x<W-2 and 2<y<H-2 and not bm[y,x]:
      pd.point((x,y),fill=rnd.choice([(249,231,169,255),(242,243,231,255),
         (247,173,179,255),(185,207,247,255),(242,201,73,255)]))
      if rnd.random()<.5:pd.point((x,y+1),fill=(44,91,32,255))
# Tiny transition shadows planted at same independent world coords; no art patch copied from prior Ground.
def contact_shadow(x,y,rx,ry):
 layer=Image.new("RGBA",(W,H),(0,0,0,0));draw=ImageDraw.Draw(layer)
 draw.ellipse((x-rx,y-ry,x+rx,y+ry),fill=(14,27,16,75))
 return layer.filter(ImageFilter.GaussianBlur(3))


for x,y,rx,ry in [(116,284,36,9),(339,290,29,8),(441,186,36,8),(397,330,19,6)]:
 ground=Image.alpha_composite(ground,contact_shadow(x,y,rx,ry))

# PAR is the originally generated, independent, transparent PAR source, NOT a flattened Master.
# A *uniform* single nearest-neighbor downscale and alpha clean-up are still visible in provenance.
original_par_path=sources/"PAR_ORIGINAL_INDEPENDENT_STAGE5.png"
assert original_par_path.exists(),original_par_path
image=Image.open(original_par_path).convert("RGBA")
assert image.size==(1448,1086)
arr=np.asarray(image).copy()
alpha=arr[:,:,3].astype(np.float32)
arr[:,:,3]=np.clip((alpha-70.0)/145.0*255.,0,255).astype("uint8")
source_cleaned=Image.fromarray(arr,"RGBA")
# 521/1448=0.3598 and 391/1086=0.3600, preserving a single world scale to ~0.04%.
new_size=(521,391)
scaled=source_cleaned.resize(new_size,Image.Resampling.NEAREST)
par=Image.new("RGBA",(W,H),(0,0,0,0))
par.alpha_composite(scaled,(11,12))
# Existing rich PAR original source has houses/tree/fence/signs bundled in its alpha source;
# per-object editable origins are not recoverable, and Source Component Gate remains HOLD.
ground=ground.convert("RGB")
gpath=root/"GROUND.png";ppath=root/"PAR.png"
ground.save(gpath,optimize=True);par.save(ppath,optimize=True)
comp=Image.alpha_composite(ground.convert("RGBA"),par)
comp.convert("RGB").save(root/"COMPOSITE_QA_ONLY.png",optimize=True)
checker=Image.new("RGBA",(W,H),(210,210,210,255));ck=ImageDraw.Draw(checker)
for yy in range(0,H,16):
 for xx in range(0,W,16):
  if ((yy//16+xx//16)%2)==0:ck.rectangle((xx,yy,xx+15,yy+15),fill=(103,103,103,255))
Image.alpha_composite(checker,par).convert("RGB").save(root/"PAR_ALPHA_CHECKER_QA_ONLY.png")
alpha_out=np.asarray(par.getchannel("A"))
manifest={
"source_mode":"independent_direct_layers",
"ground":{"source_artifact_id":"FS_STAGE7_FRESH_TERRAIN_PAINTER_SOURCE","creation_method":"direct_ground","scene_blueprint_id":layout_id,"world_origin_xy":[0,0],"style_lock_id":"STAGE7_RICH_FOREST_STANDALONE","sha256":file_sha(gpath)},
"par":{"source_artifact_id":"FS_STAGE7_CLEANED_INDEPENDENT_PAR_IMAGE","creation_method":"direct_par","scene_blueprint_id":layout_id,"world_origin_xy":[0,0],"style_lock_id":"STAGE7_RICH_FOREST_STANDALONE","sha256":file_sha(ppath),
"source_independent_par_sha256":file_sha(original_par_path),
"derivation":"independently generated standalone PAR image; alpha 70-215 remap; uniform nearest downscale, not Master extraction; artistic/per-object source acceptance pending"}}
(root/"PAIR_SOURCE_MANIFEST.json").write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding="utf8")
blueprint={"canvas":[W,H],"ground_authoring":"brand new algorithmic original from source code; never read old GROUND.png",
"par_source":"independent ImageGen PAR image only, not previous composite/Master",
"par_source_canvas":[1448,1086],"par_uniform_scale_x":521/1448,"par_uniform_scale_y":391/1086,"par_offset":[11,12],
"par_resampling":"NEAREST; native original source was NOT 544x416",
"par_placed_assets_in_original_source":"two cottages, mature tree, fences, signpost, lanterns, benches, potted shrubs and flowerbeds",
"provenance_semantic":"one independent PAR render containing multiple precomposed objects; editable individual objects UNVERIFIED",
"tree_foot_contact":"Ground shadow only, source 32x32 bark ownership HOLD",
"source_quality_gate":"VISUAL PENDING; no art PASS based on richness"}
(root/"SCENE_BLUEPRINT.json").write_text(json.dumps(blueprint,ensure_ascii=False,indent=2),encoding="utf8")
qa={"size":[W,H],"ground_sha256":file_sha(gpath),"par_sha256":file_sha(ppath),
 "par_alpha0":int((alpha_out==0).sum()),"par_alpha255":int((alpha_out==255).sum()),"par_partial":int(((alpha_out>0)&(alpha_out<255)).sum()),
 "par_visible":int((alpha_out>0).sum()),"border_alpha_nonzero":int((alpha_out[0,:]>0).sum()+(alpha_out[-1,:]>0).sum()+(alpha_out[:,0]>0).sum()+(alpha_out[:,-1]>0).sum()),
 "source_par_alpha_remap":True,"source_original_par_sha256":file_sha(original_par_path),
 "source_editability":"UNVERIFIED_SOURCE_NOT_PER_OBJECT",
 "style":"VISUAL_CANDIDATE_NO_USER_PASS",
 "technical":"PENDING_STRICT_GATES","formal_seal":"NO"}
(root/"STAGE7_PRELIM_QA.json").write_text(json.dumps(qa,ensure_ascii=False,indent=2),encoding="utf8")
print("STAGE7_DONE",json.dumps(qa))

[executed on device: DESKTOP-90VT437 (bc1ce35a-1602-4295-8688-94e581f048f4)]
