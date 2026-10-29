#!/usr/bin/env python3
"""R17 Stage3: independent, reproducible Ground and PAR authored from original sources.
NOT a back-extraction from an illustrated Master. No collisions/VX edits."""
import json, math, hashlib, random, subprocess, sys, zipfile
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

W,H=544,416
SEED=170330
rng=random.Random(SEED)
root=Path(__file__).resolve().parent
src=Path(__file__).resolve().parent/"native_asset_sources"
assert src.is_dir(), src
def sha(p): return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def cl(v): return int(max(0,min(255,round(v))))
def field(w,h,scale,seed):
    nr=np.random.default_rng(seed)
    a=nr.random((math.ceil(h/scale)+2,math.ceil(w/scale)+2))
    a=(a*255).astype('uint8')
    return np.asarray(Image.fromarray(a).resize((w,h),Image.Resampling.BILINEAR),dtype=np.float64)/255
s0=field(W,H,7,711)
s1=field(W,H,19,712)
s2=field(W,H,61,713)
s3=field(W,H,117,714)
yy,xx=np.mgrid[0:H,0:W]
noise=.34*s0+.28*s1+.24*s2+.14*s3
# Ground directly created first: NO buildings/raised objects drawn into the terrain.
base=np.empty((H,W,3),dtype=np.uint8)
region=np.sin(xx*.016)*.07+np.cos(yy*.022)*.06
for c,(lo,hi) in enumerate([(60,139),(92,160),(32,84)]):
    base[:,:,c]=np.clip(lo+(noise+region)* (hi-lo),0,255).astype('uint8')
ground=Image.fromarray(base,'RGB').convert('RGBA')
gd=ImageDraw.Draw(ground)
# Dappled non-repeating terrain color (not tiled).
for i in range(780):
    x=rng.randrange(W);y=rng.randrange(H);r=rng.choice([1,1,2,2,3,4,5,7])
    v=rng.choice([-20,-15,-10,6,8,13,21])
    gd.ellipse((x-r,y-r//2,x+r,y+r//2),fill=(cl(85+v),cl(126+v),cl(51+v//2),rng.randrange(20,70)))
# Organic flower-garden ground patches, not raised flowers.
patch=Image.new('L',(W,H),0);pd=ImageDraw.Draw(patch)
for x,y,rx,ry in [(169,190,44,27),(358,190,39,29),(110,334,45,24),(451,265,32,31),(356,344,53,26),(55,70,31,24)]:
    pd.ellipse((x-rx,y-ry,x+rx,y+ry),fill=95)
patch=patch.filter(ImageFilter.GaussianBlur(10))
overlay=Image.new('RGBA',(W,H),(85,111,34,0));overlay.putalpha(patch)
ground=Image.alpha_composite(ground,overlay)
# Two intersecting organically curved footpaths; authored in world coordinate system.
trailmask=Image.new('L',(W,H),0);td=ImageDraw.Draw(trailmask)
def bezier(points,steps=120):
    a,b,c,d=points
    out=[]
    for i in range(steps+1):
        t=i/steps;u=1-t
        out.append((int(u*u*u*a[0]+3*u*u*t*b[0]+3*u*t*t*c[0]+t*t*t*d[0]),
                    int(u*u*u*a[1]+3*u*u*t*b[1]+3*u*t*t*c[1]+t*t*t*d[1])))
    return out
p1=bezier([(250,416),(277,350),(259,268),(268,185)])
p2=bezier([(0,294),(85,287),(137,247),(267,256)])
p3=bezier([(267,256),(349,251),(420,211),(544,228)])
for points,width in [(p1,52),(p2,45),(p3,46)]:
    td.line(points,fill=255,width=width,joint='curve')
    for x,y in points[::7]:td.ellipse((x-width//2,y-width//2,x+width//2,y+width//2),fill=255)
# feather only a few pixels for an organic dirt border, never resize the image
edged=trailmask.filter(ImageFilter.GaussianBlur(4))
edge_layer=Image.new('RGBA',(W,H),(80,77,40,0))
edge_layer.putalpha(edged.point(lambda n: n//3))
ground=Image.alpha_composite(ground,edge_layer)
pathnoise=.52*field(W,H,4,201)+.26*field(W,H,11,202)+.22*field(W,H,41,203)
pathmask=np.asarray(trailmask)>0
pixels=np.asarray(ground.convert('RGB')).copy()
for c,(lo,delta) in enumerate([(118,59),(102,48),(64,37)]):
    chan=pixels[:,:,c]
    chan[pathmask]=np.clip(lo+pathnoise[pathmask]*delta,0,255).astype('uint8')
ground=Image.fromarray(pixels,'RGB').convert('RGBA')
gd=ImageDraw.Draw(ground,'RGBA')
# Unique individually authored cobbles with multi-shade rims: no repeated pattern tiles.
for i in range(2400):
    x=rng.randrange(W); y=rng.randrange(H)
    if not pathmask[y,x]:continue
    rx=rng.choice([2,2,3,3,4,5,6]);ry=rng.choice([1,2,2,3,4])
    v=rng.randrange(-18,20)
    gd.ellipse((x-rx,y-ry,x+rx,y+ry),outline=(cl(74+v),cl(66+v),cl(46+v),rng.randrange(85,160)),width=1)
    if rng.random()<.54:gd.line((x-rx+1,y-ry+1,x+rx-1,y-ry+1),fill=(cl(167+v),cl(146+v),cl(92+v),90),width=1)
# Dry grass and tiny stone/flowers, omitted from walkway.
for i in range(2300):
    x=rng.randrange(W);y=rng.randrange(H)
    if pathmask[y,x]:continue
    kind=rng.random()
    if kind<.65:
        t=rng.randrange(0,3)
        gd.line((x,y,x+rng.choice([-2,-1,0,1]),y-rng.randrange(1,4)),fill=rng.choice([(46,101,39,155),(104,157,61,125),(153,162,65,115),(38,86,30,120)]),width=1)
    elif kind<.92:
        c=rng.choice([(173,164,97,120),(93,124,55,130),(44,82,37,150)])
        gd.point((x,y),fill=c)
    else:
        # ground-level isolated flecks; keeps dense detail but no baked tall object
        col=rng.choice([(232,198,109,255),(245,233,201,255),(196,170,207,255),(113,170,214,255)])
        gd.point((x,y),fill=col);gd.point((x+1,y),fill=(227,211,165,90))
# Painted low vegetation borders around entrance, small ground geometry.
for cx,cy,rad in [(205,208,15),(332,205,16),(111,335,12),(456,256,12)]:
    for i in range(125):
        x=int(cx+rng.gauss(0,rad));y=int(cy+rng.gauss(0,rad*.65))
        if x<1 or y<1 or x>=W-1 or y>=H-1 or pathmask[y,x]: continue
        gd.point((x,y), fill=rng.choice([(49,101,34,250),(39,86,30,250),(142,185,63,220)]))
        if rng.random()<.2:gd.point((x,y-1),fill=rng.choice([(238,210,94,255),(243,231,208,255),(209,137,166,255)]))
# Ground-only shadows belong to the ground authoring pass (not extracted from PAR).
shadow=Image.new('RGBA',(W,H),(0,0,0,0))
sd=ImageDraw.Draw(shadow,'RGBA')
objects=[
  {'id':'HOUSE_01','asset':'house.png','x':242,'y':48,'layer':'PAR','kind':'house'},
  {'id':'TREE_01','asset':'tree_A','x':69,'y':64,'layer':'split source sprite','kind':'tree'},
  {'id':'TREE_02','asset':'conifer','x':416,'y':38,'layer':'split source sprite','kind':'tree'},
  {'id':'TREE_03','asset':'tree_B','x':429,'y':279,'layer':'split source sprite','kind':'tree'},
  {'id':'LAMP_01','asset':'lamp.png','x':210,'y':209,'layer':'PAR','kind':'lamp'},
  {'id':'LAMP_02','asset':'lamp.png','x':354,'y':185,'layer':'PAR','kind':'lamp'},
  {'id':'SIGN_01','asset':'sign.png','x':311,'y':254,'layer':'PAR','kind':'sign'},
  {'id':'FENCE_01','asset':'fence.png','x':119,'y':335,'layer':'PAR','kind':'fence'},
  {'id':'FENCE_02','asset':'fence.png','x':361,'y':338,'layer':'PAR','kind':'fence'},

]
# Market 128x167 at x45 y150; visually may cover western path. All inside frame.
for ob in objects:
    x,y=ob['x'],ob['y']
    if ob['kind']=='house':box=(x+8,y+141,x+88,y+164)
    elif ob['kind']=='market':box=(x+5,y+149,x+123,y+169)
    elif ob['kind']=='tree':box=(x+16,y+48,x+56,y+64)
    else:box=(x+3,y+28,x+23,y+39)
    sd.ellipse(box,fill=(18,37,15,45))
shadow=shadow.filter(ImageFilter.GaussianBlur(4))
ground=Image.alpha_composite(ground,shadow)

def independent_tree_art(kind, tw=74, th=100):
    # Each tree has independent Ground Contact art and PAR foreground,
    # both authored in a common world coordinate, *not* cut from any Master image.
    rr=random.Random(10090+{'tree_A':1,'conifer':2,'tree_B':3}[kind])
    contact=Image.new('RGBA',(tw,th),(0,0,0,0))
    canopy=Image.new('RGBA',(tw,th),(0,0,0,0))
    cp=ImageDraw.Draw(contact,'RGBA')
    d=ImageDraw.Draw(canopy,'RGBA')
    bx=tw//2
    # Only the last 18px of contact trunk is in GROUND; remainder begins 19px higher in PAR.
    cp.polygon([(bx-5,th-26),(bx+5,th-26),(bx+6,th-10),(bx+13,th-5),
               (bx+8,th-5),(bx,th-11),(bx-10,th-5),(bx-13,th-7),(bx-6,th-15)],fill=(101,70,43,255))
    cp.line([(bx-2,th-23),(bx-2,th-13),(bx-9,th-7)],fill=(153,116,66,255),width=2)
    cp.line([(bx+3,th-23),(bx+3,th-11),(bx+7,th-7)],fill=(55,43,33,255),width=2)
    d.polygon([(bx-5,th-59),(bx+5,th-59),(bx+5,th-25),(bx-5,th-25)],fill=(111,78,49,255))
    d.line([(bx-3,th-56),(bx-3,th-25)],fill=(175,129,73,255),width=2)
    d.line([(bx+4,th-59),(bx+4,th-26)],fill=(58,43,31,255),width=2)
    if kind=='conifer':
        # Layered pine tiers, no opaque rectangular texture or mismatched dirt square.
        for j,(top,bottom,half) in enumerate([(5,43,25),(22,58,31),(42,76,34)]):
            c=[(21,77,59,255),(21,87,61,255),(29,95,56,255)][j]
            d.polygon([(bx,top),(bx-half,bottom),(bx+half,bottom)],fill=(11,58,49,255))
            d.polygon([(bx,top+4),(bx-half+5,bottom-3),(bx+half-5,bottom-3)],fill=c)
            for k in range(100):
                x=rr.randrange(bx-half+7,bx+half-6)
                y=rr.randrange(top+8,bottom-3)
                if canopy.getpixel((x,y))[3]>0:
                    d.point((x,y),fill=rr.choice([(41,126,83,255),(64,147,99,255),(75,149,78,255),(11,65,52,255)]))
    else:
        # Broadleaf and flowering elm use irregular overlapping leaf clusters.
        shape = ([(20,30,20,20),(37,19,24,21),(52,32,19,22),(23,53,22,18),(49,51,22,20)]
                 if kind=='tree_A' else [(17,37,15,17),(31,21,19,22),(51,27,19,17),(56,49,17,16),(29,50,25,22)])
        for cx,cy,rx,ry in shape:
            d.ellipse((cx-rx,cy-ry,cx+rx,cy+ry),fill=(15,72,45,255))
            d.ellipse((cx-rx+3,cy-ry+2,cx+rx-3,cy+ry-4),fill=(38,117,63,255))
            for k in range(250):
                x=int(rr.gauss(cx,rx*.47));y=int(rr.gauss(cy,ry*.45))
                if x<0 or y<0 or x>=tw or y>=th:continue
                if canopy.getpixel((x,y))[3]>0:
                    if kind=='tree_B' and rr.random()<.28:
                        color=rr.choice([(228,166,169,255),(244,216,191,255),(183,117,150,255)])
                    else:
                        color=rr.choice([(73,156,73,255),(99,184,80,255),(138,185,79,255),(20,82,43,255)])
                    d.rectangle((x,y,x+rr.choice([0,1,2]),y),fill=color)
    return contact,canopy

# Native source-first contact is drawn directly into GROUND, canopy and raised trunk into PAR.
par=Image.new('RGBA',(W,H),(0,0,0,0))
registry=[]
def load(name):
    im=Image.open(src/name).convert('RGBA')
    return im
def paste_layer(layer,source,x,y):
    layer.alpha_composite(source,(x,y))
for ob in objects:
    x,y=ob['x'],ob['y']
    if ob['kind']=='tree':
        b,foreground=independent_tree_art(ob['asset'])
        paste_layer(ground,b,x,y)
        paste_layer(par,foreground,x,y)
        assets=[]
        # Source artifacts are saved before final two full-canvas exports.
        source_dir=root/'native_source_sprites'
        source_dir.mkdir(exist_ok=True)
        b.save(source_dir/(ob['id']+'_GROUND_CONTACT.png'))
        foreground.save(source_dir/(ob['id']+'_PAR_SOURCE.png'))
    else:
        im=load(ob['asset'])
        paste_layer(par,im,x,y)
        assets=[ob['asset']]
    registry.append({**ob,'source_files':[{'path':str(src/n),'sha256':sha(src/n)} for n in assets]})
# Real PNGs: full shared world canvas. Ground FULLY opaque, PAR alpha 0 outside objects.
ground=ground.convert('RGB')
ground_path=root/'GROUND.png'
par_path=root/'PAR.png'
ground.save(ground_path,optimize=True)
par.save(par_path,optimize=True)
# QA preview is explicitly not an output in the user's VX pipeline.
preview=Image.alpha_composite(ground.convert('RGBA'),par)
preview.convert('RGB').save(root/'COMPOSITE_QA_ONLY.png',optimize=True)
checker=Image.new('RGBA',(W,H),(0,0,0,255))
ck=ImageDraw.Draw(checker)
for y in range(0,H,16):
    for x in range(0,W,16):
        if ((x+y)//16)%2:ck.rectangle((x,y,x+15,y+15),fill=(213,213,213,255))
Image.alpha_composite(checker,par).convert('RGB').save(root/'PAR_CHECKER_QA_ONLY.png',optimize=True)
manifest={
    'source_mode':'independent_direct_layers',
    'ground':{'source_artifact_id':'FS_R17_S3_GROUND_NATIVE_DIRECT_TERRAIN_V2','creation_method':'direct_ground','scene_blueprint_id':'FS_R17_S3_ELF_CORNER_V1',
              'style_lock_id':'FS_R17_1X_PIXEL_FANTASY_V1','world_origin_xy':[0,0],'sha256':sha(ground_path),
              'generator_source_file':'build_r17_stage3_source_first_v2.py'},
    'par':{'source_artifact_id':'FS_R17_S3_PAR_NEW_NATIVE_TREE_SOURCE_V2','creation_method':'direct_par','scene_blueprint_id':'FS_R17_S3_ELF_CORNER_V1',
           'style_lock_id':'FS_R17_1X_PIXEL_FANTASY_V1','world_origin_xy':[0,0],'sha256':sha(par_path),
           'registry_file':'R17_STAGE3_SCENE_BLUEPRINT.json'},
}
(root/'PAIR_SOURCE_MANIFEST.json').write_text(json.dumps(manifest,indent=2,ensure_ascii=False),encoding='utf-8')
blueprint={'w':W,'h':H,'pixel_scale':'1:1','seed':SEED,'coordinate_frame':'top_left_px',
           'terrain_method':'independent continuous procedural 4 scale noise + organic painted paths + unique cobble + per pixel foliage, NO tile patches',
           'par_method':'composition of existing independent PNG sprites with new tree canopy and contact separately authored from pixel primitives; independent house/lamp/fence source sprites',
           'art_status':'CANDIDATE_HUMAN_ART_REVIEW_REQUIRED',
           'objects':registry,
           'restriction':'No Master-first segmentation, no VX scripts, no Map.rvdata changes, no collision auto compilation'}
(root/'R17_STAGE3_SCENE_BLUEPRINT.json').write_text(json.dumps(blueprint,indent=2,ensure_ascii=False),encoding='utf-8')
# run published fail-closed validator
validator=Path.home()/'AppData'/'Local'/'Temp'/'fs_r17_source_validator_20261029.py'
if validator.exists():
    p=subprocess.run([sys.executable,str(validator),'--ground',str(ground_path),'--par',str(par_path),
                      '--manifest',str(root/'PAIR_SOURCE_MANIFEST.json'),'--report',str(root/'R17_STAGE3_TECH_GATE.json')],
                     capture_output=True,text=True)
    print('VALIDATOR_EXIT',p.returncode,p.stdout[-1200:])
else:
    print('VALIDATOR_NOT_FOUND',validator)
details={'ground_sha256':sha(ground_path),'par_sha256':sha(par_path),
         'size':list(ground.size),'par_transparent_pixels':par.getchannel('A').histogram()[0],
         'par_opaque_pixels':par.getchannel('A').histogram()[255],
         'ground_32px_odd_signature_count':len({ground.crop((x,y,x+32,y+32)).tobytes() for y in range(0,H-32,32) for x in range(0,W-32,32)}),
         'generated_with':'independent artistic terrain and source sprite assembly',
         'art_gate':'HOLD_UNTIL_VISUAL_REVIEW',
         'final_seal':'NO'}
(root/'R17_STAGE3_QA_METRICS.json').write_text(json.dumps(details,indent=2),encoding='utf-8')
# ZIP all files in this new workspace, including reproducible original script and QA.
z=root/'FS_R17_DIRECT_STAGE3_SOURCE_FIRST_20261029.zip'
with zipfile.ZipFile(z,'w',zipfile.ZIP_DEFLATED,compresslevel=8) as outf:
    for f in sorted(root.rglob('*')):
        if f.is_file() and f!=z and f.name not in ('FS_R17_DIRECT_STAGE3_SOURCE_FIRST_20261029.zip',):outf.write(f,str(f.relative_to(root)))
print('DONE',json.dumps(details), 'ZIP',z,z.stat().st_size)
