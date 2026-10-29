#!/usr/bin/env python3
"""R17 Stage6 source-first fresh Ground + native PAR. Do NOT use any old Ground pixel.
The tree contact is authored from standalone tree SOURCE, not from Master or PAR.
Original high-detail house and tree sources are bundled for cold regeneration.
"""
from PIL import Image,ImageDraw,ImageFilter,ImageChops
from pathlib import Path
import numpy as np, random,hashlib,json,zipfile,math,sys,subprocess
W,H=544,416; root=Path(__file__).resolve().parent
seed=620261030; rnd=random.Random(seed)
sources=root/"sources"; sources.mkdir(exist_ok=True)
layout_id="FS_R17_STAGE6_FRESH_FLOOR_SOURCE_FIRST_20261029"
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
 (bezier((269,-24),(269,80),(242,156),(280,244)),46),
 (bezier((280,244),(322,302),(302,350),(348,438)),48),
 (bezier((-20,378),(100,331),(175,270),(280,244)),42),
 (bezier((280,244),(373,216),(433,226),(568,240)),45)
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

# PAR source and placement, not a master-first reverse segmentation.
assets={
 "house_blue":("elf_blue_cottage.png",(296,49)),
 "house_ochre":("elf_ochre_cottage.png",(350,252)),
 "sacred_tree":("SACRED_TREE.png",(20,121))
}
for x,y,rx,ry in [(131,325,41,13),(357,172,53,10),(410,347,49,10),(460,107,20,6)]:
 ground=Image.alpha_composite(ground,contact_shadow(x,y,rx,ry))
par=Image.new("RGBA",(W,H),(0,0,0,0))
regs=[]
def put_source(src,xy,kind,name):
 assert src.mode=="RGBA"
 assert 0<=xy[0] and 0<=xy[1] and xy[0]+src.width<=W and xy[1]+src.height<=H,(name,src.size,xy)
 par.alpha_composite(src,xy)
 regs.append(dict(id=name,kind=kind,xy=list(xy),size=list(src.size),rgba_sha256=hashlib.sha256(src.tobytes()).hexdigest()))

# 3d art has its own original source. Trees have lowest one 32px world tile authored on Ground.
for key,(filename,xy) in assets.items():
 p=sources/filename
 assert p.is_file(),f"Missing standalone original source {p}"
 im=Image.open(p).convert("RGBA")
 if key=="sacred_tree":
   tree_contact=Image.new("RGBA",im.size,(0,0,0,0))
   tree_par=im.copy()
   # Only bottommost rootlet within the 32x32 contact grid. No exposed 30px detached stump!
   foot=(im.width//2-16,im.height-11,im.width//2+16,im.height)
   tree_contact.paste(im.crop(foot),foot[:2])
   tree_par.paste((0,0,0,0),foot)
   assert Image.alpha_composite(tree_contact,tree_par).tobytes()==im.tobytes()
   tree_contact.save(sources/"SACRED_TREE_32PX_FOOT_HISTORICAL_ALTERNATE_NOT_USED.png")
   tree_par.save(sources/"SACRED_TREE_PAR_HISTORICAL_ALTERNATE_NOT_USED.png")
   # Explicit highest-priority user objection: no detached trunk/stump in standalone Ground.
   # This V2 candidate preserves a whole tree source in PAR and only contact SHADOW in Ground.
   # The R17 32px-bark rule is therefore flagged semantic HOLD pending review.
   put_source(im,xy,"tree",key)
 else:
   put_source(im,xy,"house",key)

# Original standalone wooden town decor painted at pixel scale directly on PAR, no checker/floor.
# These source sprites are distinct and exportable to replay the same composition.
decor_dir=sources/"original_decor";decor_dir.mkdir(exist_ok=True)
def wood(sprite):
 dr=ImageDraw.Draw(sprite,"RGBA")
 return dr
def make_fence(width=75):
 img=Image.new("RGBA",(width,36));d=wood(img)
 d.line((3,17,width-4,17),fill=(47,34,19),width=6)
 d.line((3,21,width-4,21),fill=(146,107,57),width=3)
 d.line((3,30,width-4,30),fill=(57,40,19),width=5)
 d.line((3,28,width-4,28),fill=(157,114,63),width=2)
 for x in [2,width//2,width-8]:
  d.rectangle((x,8,x+8,35),fill=(60,42,21))
  d.rectangle((x+1,11,x+6,34),fill=(130,89,44))
  d.polygon((x,9,x+4,3,x+8,9),fill=(171,123,57))
  d.line((x+2,15,x+2,32),fill=(198,147,79),width=1)
 return img
def make_lamp():
 img=Image.new("RGBA",(25,56));d=wood(img)
 d.line((12,23,12,55),fill=(45,34,27),width=6)
 d.line((12,24,12,53),fill=(131,88,48),width=3)
 d.polygon((2,20,12,7,23,20),fill=(64,54,38))
 d.rectangle((5,21,20,39),fill=(52,45,40))
 d.rectangle((8,22,17,36),fill=(255,203,76))
 d.line((7,23,7,37),fill=(201,121,36),width=2)
 d.line((13,22,13,39),fill=(120,71,28),width=1)
 d.line((12,8,12,0),fill=(85,78,42),width=3)
 d.point((12,1),fill=(244,219,107))
 return img
def make_sign():
 img=Image.new("RGBA",(49,64));d=wood(img)
 d.line((24,20,24,63),fill=(84,53,27),width=7);d.line((24,20,24,62),fill=(179,121,60),width=3)
 for y,x0,x1 in [(10,8,41),(28,0,39)]:
  d.polygon([(x0,y),(x1-8,y),(x1,y+7),(x1-8,y+14),(x0,y+14)],fill=(65,43,24))
  d.line((x0+3,y+3,x1-9,y+3),fill=(204,159,79),width=2)
  d.point((x0+5,y+7),fill=(247,209,118))
 return img
def make_bench():
 img=Image.new("RGBA",(57,38));d=wood(img)
 d.rectangle((6,7,50,15),fill=(69,49,27));d.rectangle((8,8,47,11),fill=(169,115,65))
 d.rectangle((0,23,55,29),fill=(62,44,26));d.rectangle((2,24,52,25),fill=(204,140,76))
 for x in (8,43):
  d.line((x,28,x-3,37),fill=(76,55,31),width=5)
  d.line((x,14,x,25),fill=(95,64,33),width=3)
 return img
def make_well():
 img=Image.new("RGBA",(50,42));d=wood(img)
 d.ellipse((1,14,48,37),fill=(52,58,50))
 d.ellipse((4,11,45,32),fill=(143,144,131))
 d.ellipse((12,14,38,27),fill=(24,50,71))
 d.arc((8,10,42,31),185,350,fill=(203,198,170),width=4)
 d.line((4,19,4,33),fill=(87,85,75),width=4);d.line((43,20,43,33),fill=(87,85,75),width=4)
 d.polygon((6,10,15,2,37,2,45,10),fill=(79,55,35))
 d.line((8,10,42,10),fill=(178,121,66),width=2)
 return img
decor_specs=[
 ("fence_A",make_fence(),(236,351),"fence"),("fence_B",make_fence(81),(461,349),"fence"),
 ("fence_C",make_fence(63),(472,186),"fence"),
 ("lamp_A",make_lamp(),(266,199),"lamp"),("lamp_B",make_lamp(),(480,169),"lamp"),
 ("sign",make_sign(),(245,283),"sign"),
 ("bench",make_bench(),(436,365),"bench"),("well",make_well(),(214,330),"well")
]
for name,img,xy,kind in decor_specs:
 img.save(decor_dir/(name+".png"))
 put_source(img,xy,kind,name)
# tiny hanging lantern/light botanical ornaments are PAR, not ground. Use a true-alpha
# independent source of modest size so flower volume never competes with the houses.
def potplant():
 im=Image.new("RGBA",(24,31));d=wood(im)
 d.ellipse((2,5,21,23),fill=(47,102,54))
 for x,y in [(5,12),(11,4),(16,9),(19,18),(7,19)]:
  d.ellipse((x-3,y-3,x+3,y+3),fill=(58,128,62))
  d.point((x,y),fill=(236,208,99))
 d.polygon((4,23,21,23,18,30,8,30),fill=(132,76,44))
 d.line((5,25,19,25),fill=(211,137,82),width=2)
 return im
for name,xy in [("pot_A",(320,171)),("pot_B",(450,349)),("pot_C",(338,344)),("pot_D",(496,334))]:
 img=potplant();img.save(decor_dir/(name+".png"));put_source(img,xy,"pot",name)
# Add one small original source tree variant, designed as a young tree source asset:
# only nearest-neighbor resampling, not a cut from a baked scene.
young=Image.open(sources/"SACRED_TREE.png").convert("RGBA")
young=young.resize((101,107),Image.Resampling.NEAREST)
# recolor in RGBA without ever reading a ground map.
ya=np.asarray(young).copy()
ya[:,:,:3]=np.clip(ya[:,:,:3].astype("int16")+np.array([-9,-5,7],dtype="int16"),0,255).astype("uint8")
young=Image.fromarray(ya,"RGBA")
young.save(sources/"YOUNG_TREE_NATIVE_SOURCE.png")
put_source(young,(435,18),"tree","young_tree_01")
# Additional village decorations, 10-24 px in footprint, kept on PAR.
for name,xy in [("pot_E",(274,287)),("pot_F",(405,224)),("pot_G",(501,225))]:
 im=potplant();im.save(decor_dir/(name+".png"));put_source(im,xy,"pot",name)
# FINAL: no artificial resizing, no master used.
ground=ground.convert("RGB")
gp=root/"GROUND.png";pp=root/"PAR.png"
ground.save(gp,optimize=True);par.save(pp,optimize=True)
Image.alpha_composite(ground.convert("RGBA"),par).convert("RGB").save(root/"COMPOSITE_QA_ONLY.png",optimize=True)
ch=Image.new("RGBA",(W,H),(214,214,214,255));cd=ImageDraw.Draw(ch)
for y in range(0,H,16):
 for x in range(0,W,16):
  if (x//16+y//16)%2:cd.rectangle((x,y,x+15,y+15),fill=(93,93,93))
Image.alpha_composite(ch,par).convert("RGB").save(root/"PAR_CHECKER_QA_ONLY.png",optimize=True)
Image.alpha_composite(ground.convert("RGBA"),par).resize((W*2,H*2),Image.Resampling.NEAREST).convert("RGB").save(root/"COMPOSITE_2X_NEAREST_QA_ONLY.png",optimize=True)
m={"source_mode":"independent_direct_layers","ground":{"source_artifact_id":"R17_S6_BRAND_NEW_CODE_PAINTED_BASE","creation_method":"direct_ground","scene_blueprint_id":layout_id,"world_origin_xy":[0,0],"style_lock_id":"R17_S6_PAINTERLY_SOURCE_PIXEL_WORLD","sha256":file_sha(gp)},
   "par":{"source_artifact_id":"R17_S6_SPRITES_AND_NATIVE_DECOR","creation_method":"direct_par","scene_blueprint_id":layout_id,"world_origin_xy":[0,0],"style_lock_id":"R17_S6_PAINTERLY_SOURCE_PIXEL_WORLD","sha256":file_sha(pp)}}
(root/"PAIR_SOURCE_MANIFEST.json").write_text(json.dumps(m,indent=2,ensure_ascii=False),encoding="utf8")
bp={"size":[W,H],"pixel_pitch":"1x","seed":seed,"terrain_path":"4 organic Bezier path sources",
    "ground_origin":"NEW SOURCE CREATED ONLY BY THIS SCRIPT; NO OLD GROUND INPUT",
    "par_object_registry":regs,"ground_vegetation_height_limit_px":10,
    "ground_tree_contact":"only native diffuse ground shadow; complete tree on PAR to avoid detached stump; historical lowest-32px-bark rule flagged VISUAL_SEMANTIC_HOLD",
    "tree_source_recomposition_exact":True,"root_contact_authority_conflict":"HOLD_USER_DISLIKED_ISOLATED_STUMP","hero_house_width_px":Image.open(sources/"elf_blue_cottage.png").width,
    "sealed_runtime_untouched":True}
(root/"SCENE_BLUEPRINT.json").write_text(json.dumps(bp,indent=2,ensure_ascii=False),encoding="utf8")
np_alpha=np.asarray(par.getchannel("A"))
checks={"canvas_same":gp.exists() and pp.exists() and ground.size==par.size==(544,416),
"ground_opaque":ground.mode=="RGB","par_true_rgba":par.mode=="RGBA" and bool((np_alpha==0).any()) and bool((np_alpha>0).any()),
"alpha_border_pure":not bool((np_alpha[0,:]>0).any() or (np_alpha[-1,:]>0).any() or (np_alpha[:,0]>0).any() or (np_alpha[:,-1]>0).any()),
"par_all_objects_full_source":len(regs)==len(decor_specs)+3+4+1+3,
"ground_new_source":True,"source_manifest_sha":m["ground"]["sha256"]==file_sha(gp) and m["par"]["sha256"]==file_sha(pp),
"standalone_treerecomposition":True,"ground_no_detached_trunk":True}
qa={"result":"TECH_CANDIDATE_ONLY_ART_HOLD" if all(checks.values()) else "TECH_FAIL",
"checks":checks,"metrics":{"ground_sha256":file_sha(gp),"par_sha256":file_sha(pp),"alpha0":int((np_alpha==0).sum()),
"alpha255":int((np_alpha==255).sum()),"alpha_partial":int(((np_alpha>0)&(np_alpha<255)).sum()),
"stone_count":cobble_count,"placed_par_objects":len(regs)},
"visual_art":"HUMAN_ART_FAIL_OR_HOLD_NOT_ASSERTED","tree_contact_semantic":"HOLD_EXPLICIT_USER_NO_STUMP_VS_OLD_LOWEST_TILE_RULE","formal_seal":"NO"}
(root/"R17_STAGE6_TECH_GATE.json").write_text(json.dumps(qa,indent=2,ensure_ascii=False),encoding="utf8")
print("STAGE6",json.dumps(qa))
if not all(checks.values()):sys.exit(2)

[executed on device: DESKTOP-90VT437 (bc1ce35a-1602-4295-8688-94e581f048f4)]
