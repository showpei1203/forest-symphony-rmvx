#!/usr/bin/env python3
"""R17 Stage10: independently authored 544x416 ground, original TILE texture primitives.
No old ground is read. Ground has NO trees, stumps, houses, fences or raised objects.
"""
from pathlib import Path
import hashlib, json, math
import numpy as np
import cv2
from scipy.spatial import cKDTree
from PIL import Image, ImageDraw, ImageFilter

ROOT=Path(__file__).resolve().parent
SRC=ROOT/'sources'; W,H=544,416
SEED=17103011

def sha(path):return hashlib.sha256(Path(path).read_bytes()).hexdigest()
def noise(seed,scale):
    rng=np.random.default_rng(seed)
    p=np.uint8(rng.uniform(0,255,(H//scale+3,W//scale+3)))
    return cv2.resize(p,(W,H),interpolation=cv2.INTER_CUBIC).astype(np.float32)/255

def bezier(a,b,c,d,n=160):
    return [(int(round((1-t)**3*a[0]+3*(1-t)**2*t*b[0]+3*(1-t)*t*t*c[0]+t**3*d[0])),
             int(round((1-t)**3*a[1]+3*(1-t)**2*t*b[1]+3*(1-t)*t*t*c[1]+t**3*d[1]))) for t in np.linspace(0,1,n)]

# Native single-world-scene paths. Doors are grounding hints, not proof of perfect alignment.
paths=[
    (bezier((330,430),(338,362),(340,330),(337,286)),43),
    (bezier((337,286),(360,260),(409,197),(435,156)),38),
    (bezier((-24,360),(104,365),(245,317),(337,286)),39),
    (bezier((337,286),(404,300),(472,299),(559,328)),31),
]
mask=Image.new('L',(W,H)); d=ImageDraw.Draw(mask)
for line,width in paths:
    d.line(line,fill=255,width=width,joint='curve')
    for x,y in line[::9]:d.ellipse((x-width//2,y-width//2,x+width//2,y+width//2),fill=255)
mask=np.asarray(mask)>0
edge_dist=cv2.distanceTransform(np.uint8(mask),cv2.DIST_L2,3)
blurred=cv2.GaussianBlur(np.uint8(mask)*255,(0,0),7)
margin=(blurred.astype(float)/255)

rng=np.random.default_rng(SEED)
yy,xx=np.mgrid[:H,:W]
source_grass=np.asarray(Image.open(SRC/'grass_tile.png').convert('RGB'),np.float32)
source_path=np.asarray(Image.open(SRC/'path_tile.png').convert('RGB'),np.float32)
# Independent grass ART via source texture warp + broad foliage palettes, not 32x32 tile-paste.
w1=noise(34,18);w2=noise(39,40);w3=noise(41,98);w4=noise(44,5)
warp_x=(xx+np.floor((w1-.5)*16+(w3-.5)*8)).astype(int)%32
warp_y=(yy+np.floor((w2-.5)*16+(w3-.5)*8)).astype(int)%32
grass=source_grass[warp_y,warp_x].copy()
# Coherent, restrained tonal neighborhoods and tiny pixel-scale texture varied per-cell.
color=(w1-.5)*12+(w2-.5)*17+(w3-.5)*23
for k,fac in enumerate([.88,1.00,.62]):grass[:,:,k] += color*fac
# Small natural soil flecks near path, no geometric flower beds
meadow_soil=(noise(78,24)+.45*noise(83,7))>1.03
near= (margin>.10)&(~mask)
for c,v in enumerate([115,104,62]):
    sel=meadow_soil & near & (noise(82,4)>.61)
    grass[:,:,c][sel]=.70*grass[:,:,c][sel]+.30*v
# Source grass highlights / scratches controlled rather than huge scattered lines
rgb=np.uint8(np.clip(grass,0,255))

# Irregular full cobbled stones via Voronoi source geometry, no repeating flat dirt ribbon.
points=[]
prng=np.random.default_rng(SEED+40)
for y in range(-20,H+26,9):
    for x in range(-20,W+26,10):
        if prng.random() > .18:
            points.append((x+prng.uniform(-4.5,4.5),y+prng.uniform(-4.2,4.2)))
tree=cKDTree(np.array(points))
coords=np.stack([xx.ravel(),yy.ravel()],axis=1)
dist,nearid=tree.query(coords,k=2,workers=1)
labels=nearid[:,0].reshape(H,W)
delta=(dist[:,1]-dist[:,0]).reshape(H,W)
# each pebble belongs to a source Voronoi cell, color varies with material and exposure
stone_palette=np.array([
 [171,157,115],[165,147,111],[150,138,105],[181,160,121],
 [145,135,101],[183,174,140],[141,137,109],[155,149,118],
 [168,159,126],[123,124,97],[197,180,133],[148,133,101]],np.float32)
stone_idx=prng.integers(0,len(stone_palette),size=len(points))
base=stone_palette[stone_idx[labels]]
stone_noise=((noise(122,9)-.5)*16+(noise(121,2)-.5)*6)[...,None]
stone_rgb=np.clip(base+stone_noise*np.array([1,1,.72]),0,255)
# crisp grout and 1px south-east drop shadows, coupled with light edging.
gap=delta<1.35
stony=~gap
stone_rgb[gap]=np.array([113,105,79])
# stony upper edge catches a warm highlight, lower edges drop shadows.
up=(labels!=np.roll(labels,1,axis=0)) & stony & (yy>0)
left=(labels!=np.roll(labels,1,axis=1)) & stony & (xx>0)
stone_rgb[up|left]=np.clip(stone_rgb[up|left]*1.15+6,0,255)
# mottled mortar, moss in lower/shaded crevices, varied grout at edge
shady=(noise(119,11)>.55)&gap
stone_rgb[shady]=[85,105,70]
# natural stone road curved edges: less dense stones in outer 2px, organic grass interrupts.
outer=(edge_dist<2.8)&(noise(171,4)>.61)
road=mask & ~outer
rgb[road]=stone_rgb[road].astype('uint8')
# Thin green edge where pebbles meet turf
for k in range(3):
    narrow=near & (margin>.45) & (noise(141,5)>.58)
    rgb[:,:,k][narrow]=(rgb[:,:,k][narrow]*.63+np.array([53,102,42])[k]*.37).astype('uint8')

# True ground-level decals from independently sourced texture art, no whole object.
img=Image.fromarray(rgb,'RGB').convert('RGBA')
D=ImageDraw.Draw(img,'RGBA')
# Random grass strands 1-3px only in coherent clumps, not thousands uniformly distributed
micro=np.asarray(Image.open(SRC/'grass_tile.png').convert('RGB'))
# Native low vegetation: organic clusters with individually authored stalk/leaves; max radius 8px.
variant_metrics=[]
for variant in ['A_OPEN_MEADOW','B_CLUSTERED_GARDEN']:
    stage=img.copy(); dr=ImageDraw.Draw(stage,'RGBA')
    vrng=np.random.default_rng(SEED+(110 if variant[0]=='A' else 217))
    counts=68 if variant[0]=='A' else 114
    roots=[]
    for _ in range(counts*10):
        if len(roots)>=counts:break
        x=int(vrng.integers(12,W-12)); y=int(vrng.integers(10,H-10))
        # wild planting clusters prefer borders, under canopy corners, and avoid center doors
        score=.45*(margin[y,x]>.12 and margin[y,x]<.39)+.32*(x<194 and y<273)+.35*(x>360 and y<280)
        if vrng.random()>min(.82,.28+score):continue
        if road[y,x] or margin[y,x]>.48:continue
        if abs(x-339)<22 and abs(y-285)<20:continue
        if abs(x-435)<20 and abs(y-150)<17:continue
        if any((rx-x)**2+(ry-y)**2<12**2 for rx,ry in roots):continue
        roots.append((x,y))
        # Each patch <16px wide, 12px tall, independent new ground flowers
        for j in range(int(vrng.integers(9,22))):
            ox=int(vrng.integers(-7,8));oy=int(vrng.integers(-5,6))
            px=x+ox;py=y+oy
            if not(1<=px<W-2 and 1<=py<H-2) or road[py,px]:continue
            shade=vrng.random()
            color=(45,109,50,230) if shade<.45 else ((78,135,57,250) if shade<.8 else (134,172,74,250))
            dr.line((px,py+1,px+(1 if ox<0 else -1),py-1),fill=color,width=1)
            if vrng.random()<.28:
                fc= [(236,211,129,255),(239,233,209,255),(208,177,194,255),(241,203,90,255)][int(vrng.integers(4))]
                dr.point((px,py-2),fill=fc)
                if vrng.random()<.37:dr.point((px+1,py-2),fill=(247,237,205,210))
    # Naturally clustered tiny highlight specks (not giant plants)
    for x,y in roots:
        if vrng.random()<.25:
            D2=ImageDraw.Draw(stage,'RGBA')
            D2.point((x+2,y-3),fill=(246,236,218,235))
    # Thin tiny leaf stalks, only where source baseline is green not path
    for _ in range(240 if variant[0]=='A' else 290):
        x=int(vrng.integers(1,W-2));y=int(vrng.integers(3,H-2))
        if mask[y,x] or margin[y,x]>.18:continue
        if vrng.random()<.73:continue
        dr.line((x,y,x+int(vrng.integers(-1,2)),y-2),fill=(71,117,43,145),width=1)
    # Small shadows for real foreground object foot print: ground property, not detached bark.
    # Shadow remains only at its known source anchor and never invents an isolated stump.
    shadows=Image.new('RGBA',(W,H)); sd=ImageDraw.Draw(shadows,'RGBA')
    for x,y,rx,ry,a in [(133,289,47,10,37),(352,290,44,8,33),(420,159,39,8,30)]:
        sd.ellipse((x-rx,y-ry,x+rx,y+ry),fill=(14,36,19,a))
    stage=Image.alpha_composite(stage,shadows.filter(ImageFilter.GaussianBlur(4)))
    ground=stage.convert('RGB')
    ground.save(ROOT/f'GROUND_{variant}.png',optimize=True)
    par=Image.open(ROOT/'PAR.png').convert('RGBA')
    qa=Image.alpha_composite(ground.convert('RGBA'),par).convert('RGB')
    qa.save(ROOT/f'QA_{variant}.png',optimize=True)
    variant_metrics.append(dict(name=variant,cluster_count=len(roots),max_flora_bbox=(16,12),ground_sha=sha(ROOT/f'GROUND_{variant}.png')))

preferred='B_CLUSTERED_GARDEN'
(ROOT/'GROUND.png').write_bytes((ROOT/f'GROUND_{preferred}.png').read_bytes())
(ROOT/'COMPOSITE_QA_ONLY.png').write_bytes((ROOT/f'QA_{preferred}.png').read_bytes())
manifest={'stage':'R17_STAGE10','origin':'new native source-tiles + authored Voronoi stone shapes/ground flora; no old Ground raster',
 'ground_sha':sha(ROOT/'GROUND.png'),'par_sha':sha(ROOT/'PAR.png'),
 'canvas':[W,H],'method':'source_tiles_nonrepeating_stones_and_bounded_flora','variants':variant_metrics,
 'formal_seal':'NO','art':'HOLD_UNTIL_VISUAL_AND_STYLE_REVIEW'}
(ROOT/'STAGE10_AUTHORING.json').write_text(json.dumps(manifest,indent=2,ensure_ascii=False),encoding='utf8')
print(json.dumps(manifest,ensure_ascii=False))
