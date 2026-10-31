from pathlib import Path
from PIL import Image,ImageDraw,ImageFilter
import numpy as np, random,math,hashlib,json
R=Path(__file__).resolve().parent; S=R/'source'; E=R/'evidence';S.mkdir(exist_ok=True);E.mkdir(exist_ok=True)
W,H=544,576
rng=random.Random(130042)
nr=np.random.default_rng(130042)
def noise(gx,gy):
    small=nr.random((gy,gx)).astype('float32')
    return np.asarray(Image.fromarray((small*255).astype('uint8')).resize((W,H),Image.Resampling.BILINEAR)).astype('float32')/255.
n1=noise(18,19);n2=noise(55,62);n3=noise(135,144)
ys,xs=np.indices((H,W),dtype='float32')
# Mid-green old fantasy forest ground palette, manual color specification; no source pixels copied.
grass=np.array([
 [70,119,64],[76,128,67],[84,137,75],[94,145,77],
 [102,151,82],[113,160,88],[122,164,91],[135,173,102],
 [91,136,75],[105,145,82],[113,154,82],[125,170,91]
],dtype=np.uint8)
v=0.5*n1+0.35*n2+0.15*n3
index=np.clip(np.floor(v*11.0+np.sin(xs/73)*.45).astype('int32'),0,11)
ground=grass[index].copy()
# Author dirt trails as semantic world surface, irregular organic edges, no bridge or raised objects.
center1=205+46*np.sin(ys/76.0+0.55)+14*np.sin(ys/31.0+0.8)
dist1=np.abs(xs-center1)
width1=41+7*np.sin(ys/58.0)+5*(n1-.5)
center2=373+25*np.cos(ys/93.0)
dist2=np.abs(xs-center2)
width2=20+4*np.sin(ys/28.0)
# One main winding walkable path, one subtle side branch.
path_raw=(dist1<width1-5+6*(n2-.5))
branch=(ys>250)&(ys<465)&(np.abs(xs-(center1 + (ys-250)*.57))<width2)
path_raw |= branch
border=(np.abs(dist1-width1)<6) | ((ys>250)&(ys<465)&(np.abs(np.abs(xs-(center1+(ys-250)*.57))-width2)<5))
dirt_palette=np.array([[173,147,103],[180,152,110],[188,160,113],[199,169,121],[208,178,131],[169,142,103],[194,164,115]],dtype=np.uint8)
dv=(n1*.40+n2*.48+n3*.12)
di=np.minimum(6,(dv*7).astype('int32'))
ground[path_raw]=dirt_palette[di[path_raw]]
# Edge broken soil sparse moss clumps.
edge_patches=border & (n2>.55) & (n3>.38)
ground[edge_patches]=np.array([137,151,89],np.uint8)
# Random artisanal short brush marks, ground-level weeds and flat floral texture.
img=Image.fromarray(ground,'RGB');dr=ImageDraw.Draw(img)
flower_colors=[(219,178,184),(224,206,160),(228,229,206),(180,182,224),(245,212,135)]
green_leaf=[(49,102,54),(69,123,65),(77,136,68),(153,177,98),(173,192,113),(97,153,72)]
path_overlay=Image.fromarray((path_raw.astype('uint8')*255),'L')
for k in range(5100):
    x=rng.randrange(4,W-5);y=rng.randrange(3,H-5)
    onpath=bool(path_raw[y,x])
    if onpath:
        if k%3==0:
            c=rng.choice([(152,132,100),(217,190,149),(154,132,95),(199,177,136)])
            dr.line((x,y,x+rng.randrange(1,4),y+rng.randrange(0,2)),fill=c,width=1)
        continue
    t=rng.random()
    if t<.22:
        c=rng.choice(green_leaf)
        # grass silhouette is seated on the floor, not a standing object.
        dr.line((x,y,x-1,y-2),fill=c,width=1)
        dr.line((x,y,x+1,y-3),fill=c,width=1)
        dr.line((x,y,x+2,y-1),fill=c,width=1)
    elif t<.37:
        c=rng.choice(green_leaf[1:])
        dr.ellipse((x,y,x+1,y+1),fill=c)
    elif t<.45:
        c=rng.choice(flower_colors)
        dr.point((x,y),fill=c)
        if rng.random()<.18:
            dr.point((x+1,y),fill=(232,222,190))
# Small grounded low ferns: no height/occlusion in map.
for k in range(88):
    x=rng.randrange(5,W-9);y=rng.randrange(5,H-8)
    if path_raw[y,x]:continue
    c=rng.choice([(55,112,62),(67,126,66),(87,142,72)])
    for a in range(4):
        dr.line([(x,y),(x+int(4*math.cos(a*math.pi/2)),y+int(3*math.sin(a*math.pi/2)))],fill=c,width=1)
# A few embedded pebbles, no elevated collision object, all semantically Ground.
for k in range(95):
    x=rng.randrange(3,W-4);y=rng.randrange(3,H-4)
    c=(135,136,111) if bool(path_raw[y,x]) else (104,137,101)
    dr.ellipse((x,y,x+1+rng.randrange(0,2),y+1),fill=c)
target=S/'ground_long.png'
img.save(target)
# Explicit source masks, map semantics as separate data, not retro segmentation of art.
Image.fromarray((path_raw.astype('uint8')*255),'L').save(S/'PATH_SEMANTIC_MASK.png')
Image.fromarray((np.ones((H,W),np.uint8)*255),'L').save(S/'WALKABLE_MASK.png')
meta={'stage':'13','author':'deterministic new procedural Ground ONLY, not generative image model','source':'author_stage13_ground.py','seed':130042,
'dimensions':[W,H],'classes':['grass','walkable_earthen_path','ground_level_flowers','ground_level_weeds','embedded_pebbles'],
'forbidden_high_objects_zero_by_authoring':True,'original_image_copied':False,
'path_pct':round(100*path_raw.mean(),2),'path_count':int(path_raw.sum()),
'walkable_pct':100.0,'source_sha256':hashlib.sha256(target.read_bytes()).hexdigest(),
'style_gate':'NOT_APPROVED','note':'New Ground is algorithmic art used to validate generation-from-zero. Not a new AI-painted high-fidelity ground3 equivalent.'}
(E/'STAGE13_NEW_GROUND_AUTHORITY.json').write_text(json.dumps(meta,ensure_ascii=False,indent=2),encoding='utf8')
print(json.dumps(meta,ensure_ascii=False,indent=2))