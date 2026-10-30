#!/usr/bin/env python3
"""FS R17 Stage12: fresh authoring from independent art-source textures.
Never opens a previous GROUND.png or finished Master. True PAR stays unchanged.
Source art: A2_VSCliff (native terrain atlas), grass_tile (legacy source tile).
Formal art PASS is NEVER inferred from the machine checks.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFilter,ImageChops
import numpy as np,random,math,json,hashlib
ROOT=Path(__file__).resolve().parent
S=ROOT/"sources"
W,H=544,416
def hashfile(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
atlas=Image.open(S/"A2_VSCliff.png").convert("RGB")
legacy=Image.open(S/"grass_tile.png").convert("RGB")
par=Image.open(S/"PAR_original.png").convert("RGBA")
assert atlas.size==(512,384) and legacy.size==(32,32) and par.size==(W,H)
def field(seed,s):
    r=np.random.default_rng(seed)
    a=(r.random((math.ceil(H/s)+3,math.ceil(W/s)+3))*255).astype("uint8")
    return np.asarray(Image.fromarray(a).resize((W,H),Image.Resampling.BICUBIC),dtype="float32")/255
def bezier(a,b,c,d,n=170):
    return [(round((1-t)**3*a[0]+3*(1-t)**2*t*b[0]+3*(1-t)*t*t*c[0]+t**3*d[0]),
             round((1-t)**3*a[1]+3*(1-t)**2*t*b[1]+3*(1-t)*t*t*c[1]+t**3*d[1]))
            for t in (i/n for i in range(n+1))]
def quilt(source,seed,tile=28,overlap=7,attempts=32):
    """Overlap-match original source-ART patches, not tile-iterate old ground.
    Preserve 1px detail by selecting random best matching source crops."""
    src=np.asarray(source.convert("RGB"),dtype=np.uint8)
    sh,sw=src.shape[:2]
    out=np.zeros((H,W,3),dtype=np.float32)
    r=random.Random(seed); stride=tile-overlap
    for yy in range(0,H,stride):
      for xx in range(0,W,stride):
        hh=min(tile,H-yy);ww=min(tile,W-xx)
        if hh<3 or ww<3:continue
        cs=[]
        for k in range(attempts):
          sy=r.randint(0,sh-hh);sx=r.randint(0,sw-ww)
          patch=src[sy:sy+hh,sx:sx+ww].astype(np.float32)
          err=0.
          if xx:
            o=min(overlap,ww)
            err+=np.abs(patch[:,:o]-out[yy:yy+hh,xx:xx+o]).mean()
          if yy:
            o=min(overlap,hh)
            err+=np.abs(patch[:o,:]-out[yy:yy+o,xx:xx+ww]).mean()
          cs.append((err,k,patch))
        cs.sort(key=lambda a:a[0])
        patch=r.choice(cs[:min(3,len(cs))])[2]
        blend=np.ones((hh,ww),dtype=np.float32)
        if xx:
          o=min(overlap,ww)
          blend[:,:o]*=np.arange(1,o+1)/float(o+1)
        if yy:
          o=min(overlap,hh)
          blend[:o,:]*=(np.arange(1,o+1)/float(o+1))[:,None]
        dst=out[yy:yy+hh,xx:xx+ww]
        out[yy:yy+hh,xx:xx+ww]=dst*(1-blend[:,:,None])+patch*blend[:,:,None]
    return np.clip(out,0,255).astype(np.uint8)
# Source "grass_tile" is standalone; A2 source grass crops avoid edges/large bushes
a2grass=atlas.crop((257,1,319,74))
a2stone=atlas.crop((1,132,63,190))
baseA=quilt(legacy.resize((64,64),Image.Resampling.NEAREST),171,24,6,22)
baseB=quilt(a2grass,182,26,7,40)
baseC=np.uint8(np.clip(.86*baseA.astype('float32')+.14*baseB.astype('float32'),0,255))
stones=quilt(a2stone,193,26,7,45)
# Field color harmonization based on Stage7 PAR palette (not copying PAR pixels).
n1=field(200,13);n2=field(201,72);n3=field(202,4)
# All paths are authored from one coordinate blueprint; no changes to 17x13 ground canvas.
paths=[
 (bezier((-25,352),(115,365),(235,311),(343,289)),48),
 (bezier((343,289),(374,240),(425,197),(441,148)),46),
 (bezier((343,289),(332,348),(347,380),(347,441)),45),
 (bezier((343,290),(412,299),(494,337),(571,334)),36)
]
pm=Image.new("L",(W,H),0);dr=ImageDraw.Draw(pm)
for pts,width in paths:
  dr.line(pts,fill=255,width=width,joint="curve")
  for x,y in pts[::9]:dr.ellipse((x-width//2,y-width//2,x+width//2,y+width//2),fill=255)
pathblur=np.array(pm.filter(ImageFilter.GaussianBlur(2)),dtype="float32")
irreg=n3*40+n1*30-35
pathmask=pathblur>100+irreg
r=random.Random(84719)
outmetadata=[]
for label,base,variant in [
 ("A_SOFT_SOURCE_QUILT",baseA,1),
 ("B_ARTISAN_A2_QUILT",baseB,2),
 ("C_RESTRAINED_ART_MIX",baseC,3)]:
   # Each variant is reauthored from material sources, not derived from older ground.
   ground=base.astype("float32")
   if variant==2:
     # Lift dense A2 grass toward the reference golden-olive palette while
     # retaining source-artist leaves and pixel clusters.
     mul=np.array([1.03,0.93,0.83],dtype="float32")
     ground*=mul
   ground+=((n1-.5)*7+(n2-.5)*12)[:,:,None]
   ground=np.clip(ground,0,255)
   stone=stones.astype("float32").copy()
   stone*=np.array([1.04,1.035,.92],dtype="float32")
   stone+=((n1-.5)*12)[:,:,None]
   ground[pathmask]=np.clip(stone,0,255)[pathmask]
   # Rough grass fringe is a ground element; irregularity follows path mask.
   edge=np.asarray(pm.filter(ImageFilter.GaussianBlur(6)),dtype="float32")/255
   edge_band=(edge>.18)&(~pathmask)
   ground[edge_band]=np.clip(.78*ground[edge_band]+.22*np.array([105,110,57]),0,255)
   im=Image.fromarray(np.uint8(ground),"RGB").convert("RGBA")
   draw=ImageDraw.Draw(im,"RGBA")
   # Restrained low-profile flowers, planted IN GROUPS near trail shoulders.
   # Every flower head <= 6x6 px; groups are ground pattern, not huge elevated shrubs.
   clusters=[(48,286),(111,306),(193,300),(241,249),(275,349),
            (470,283),(500,370),(468,170),(401,113),
            (232,84),(173,131),(73,141),(390,390),(515,75)]
   flora=0
   for cx,cy in clusters:
     for _ in range(6 if variant==1 else 10):
       fx=cx+r.randint(-13,13);fy=cy+r.randint(-9,9)
       if not (4<fx<W-5 and 5<fy<H-5) or pathmask[fy,fx]:continue
       petals=r.choice([(228,215,158,235),(236,235,223,220),(180,177,209,240),(228,175,141,235)])
       draw.line((fx-1,fy+1,fx+2,fy-2),fill=(46,112,42,210),width=1)
       draw.point((fx-2,fy),fill=petals)
       draw.point((fx+1,fy-1),fill=petals)
       draw.point((fx,fy-2),fill=petals)
       draw.point((fx,fy+1),fill=petals)
       draw.point((fx,fy-1),fill=(232,193,87,255))
       flora+=1
   # Small ground stones only, never tall rocks or detached tree trunk.
   for _ in range(155):
     x=r.randrange(4,W-4);y=r.randrange(4,H-4)
     if pathmask[y,x] or edge[y,x]<.1:continue
     gray=r.choice([(155,149,119,130),(117,124,99,130),(196,180,138,100)])
     draw.ellipse((x-2,y-1,x+2,y+1),fill=gray)
   # Ground-contact diffuse shadow, NOT bark stump.
   shadow=Image.new("RGBA",(W,H),(0,0,0,0));sdraw=ImageDraw.Draw(shadow)
   for x,y,rx,ry,opacity in [(135,291,54,10,50),(347,289,58,8,36),(446,169,48,8,36)]:
     sdraw.ellipse((x-rx,y-ry,x+rx,y+ry),fill=(18,29,11,opacity))
   im=Image.alpha_composite(im,shadow.filter(ImageFilter.GaussianBlur(5)))
   g=im.convert("RGB")
   gp=ROOT/("GROUND_"+label+".png")
   g.save(gp,optimize=True)
   qp=ROOT/("QA_"+label+".png")
   Image.alpha_composite(g.convert("RGBA"),par).convert("RGB").save(qp,optimize=True)
   outmetadata.append({"variant":label,"ground_sha256":hashfile(gp),"ground_flora_count":flora,
                       "path_curves":len(paths),"max_flower_pixels":[6,6],
                       "one_to_one_canvas":list(g.size)})
# Variant B selected as technical candidate, NOT as Art Pass.
(ROOT/"GROUND.png").write_bytes((ROOT/"GROUND_C_RESTRAINED_ART_MIX.png").read_bytes())
(ROOT/"PAR.png").write_bytes((S/"PAR_original.png").read_bytes())
(ROOT/"COMPOSITE_QA_ONLY.png").write_bytes((ROOT/"QA_C_RESTRAINED_ART_MIX.png").read_bytes())
audit={"stage":"FS_R17_STAGE12_SOURCE_QUILT","canvas":[W,H],
 "source_files":{f.name:hashfile(f) for f in S.iterdir() if f.is_file()},
 "variants":outmetadata,"ground_authoring":"source-atlas overlap-matched stone and soft grass quilt; corrected cubic Bezier paths; 14 percent high-fidelity green material in C; no tall plant blocks or old Ground",
 "ground_selected":"C_RESTRAINED_ART_MIX","par_source":"unchanged Stage7 independent high-detail precomposed PAR; per-object editability HOLD",
 "formal_seal":"NO","human_art_gate":"PENDING_HUMAN_NOT_MATHEMATICALLY_INFERRED"}
(ROOT/"STAGE12_SOURCE_SCENE.json").write_text(json.dumps(audit,indent=2,ensure_ascii=False),encoding="utf8")
print(json.dumps({"status":"SOURCE_ART_GENERATED_FOR_INSPECTION", "ground_sha":hashfile(ROOT/"GROUND.png"),
 "par_sha":hashfile(ROOT/"PAR.png"),"variants":outmetadata},ensure_ascii=False))
