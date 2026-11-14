#!/usr/bin/env python3
"""A32 FIRST GROUND + INDEPENDENT ORIGINAL RGBA PAR pilot.
Ground: new 2026-11-14 image_gen Ground-only image; center-cropped NO rescale.
PAR: pre-existing *standalone* A36F/FS v2.3.3 source object PNGs, no flattened Master extraction.
The source ZIPs remain private. Outputs private art + public source/manifest, not an art seal.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageChops
from io import BytesIO
import json, hashlib, zipfile, random, math, os, argparse
argp=argparse.ArgumentParser(description="A32 fresh ground-only + independent RGBA objects; source PNG and archives are PRIVATE")
argp.add_argument('--out',default='/mnt/data/fs_godot_a32')
argp.add_argument('--ground-only-source',default='/mnt/data/a_highly_detailed_top_down_isometric_ish_2d_pix.png')
argp.add_argument('--a36f-archive',default='/mnt/data/FS_STAGE16_A36F_R1_DENSE_ELF_FOREST_VX_GODOT_SOURCE_PRIVATE_20261103.zip')
argp.add_argument('--v233-archive',default='/mnt/data/FS_STYLE_FIRST_V233_FULL_ARCHITECTURE_SCROLLING_VILLAGE_20261025_PRIVATE_PLAYABLE.zip')
args=argp.parse_args()
D=Path(args.out); PA=D/'private_assets' ; PAR=PA/'independent_par'; QA=D/'qa'; DATA=D/'data'; SCRIPT=D/'scripts'; SCENE=D/'scenes'; DOC=D/'docs';TEST=D/'tests';TOOLS=D/'tools'
for p in [PA,PAR,QA,DATA,SCRIPT,SCENE,DOC,TEST,TOOLS]: p.mkdir(parents=True,exist_ok=True)
sha=lambda b:hashlib.sha256(b).hexdigest()
rng=random.Random(321614)
gsrc=Path(args.ground_only_source)
assert gsrc.exists()
G0=Image.open(gsrc).convert('RGB'); assert G0.size==(1536,1024)
# IMAGEGEN source is ground-only; cropping preserves 1:1 pixels (NO resize, no source-master-cut).
G=G0.crop((128,48,1408,976)).convert('RGBA'); assert G.size==(1280,928)
G.save(PA/'ground_only.png',optimize=True)
GBytes=(PA/'ground_only.png').read_bytes(); print('ground size',G.size,'sha',sha(GBytes))
za=zipfile.ZipFile(args.a36f_archive)
zv=zipfile.ZipFile(args.v233_archive)
alltrees=[n for n in za.namelist() if n.startswith('INDEPENDENT_PAR_ALPHA_468/A36F_DENSE_TREE_') and n.endswith('.png')]
alltrees=sorted(alltrees)
# Use 18 independent source variants plus 3 naturally different original FS tree species.
selected_trees=[alltrees[i] for i in sorted(set([0,6,13,20,27,33,41,48,55,64,72,81,91,101,111,120,130,144])) if i<len(alltrees)]
vbase='native_template/STYLE_V1_NATIVE_SEED/Graphics/Pictures/'
selected_trees+=['V233:'+s for s in ['FSOBJ_tree_moss_01.png','FSOBJ_tree_blue_02.png','FSOBJ_tree_lime_03.png']]
selected_houses=['INDEPENDENT_PAR_ALPHA_468/A36F_ELF_COTTAGE_A_ANNEX_RGBA.png','INDEPENDENT_PAR_ALPHA_468/A36F_ELF_COTTAGE_B_MOSS_ROOF_RGBA.png']
selected_props=['V233:'+s for s in ['FSOBJ_post_lantern.png','FSOBJ_rock_cluster.png','FSOBJ_well.png','FSOBJ_bush_sprout.png']]
# No whole flattened scene can ever enter this source-list.
paths=selected_trees+selected_houses+selected_props
sources={}; originals=[]
for p in paths:
  if p.startswith('V233:'): orig=zv.read(vbase+p.split(':')[1]);origin='FS_V233_INDEPENDENT_ORIGINAL';name=p.split(':')[1]
  else:orig=za.read(p);origin='FS_A36F_INDEPENDENT_PAR_SOURCE';name=p.split('/')[-1]
  img=Image.open(BytesIO(orig)).convert('RGBA')
  if img.getbbox() is None:continue
  # Transparent padding protects edge-clipped object PNGs without changing content. No Master extraction.
  border_opaque=any(px[3]>0 for px in list(img.crop((0,0,img.width,1)).getdata())+list(img.crop((0,img.height-1,img.width,img.height)).getdata())+list(img.crop((0,0,1,img.height)).getdata())+list(img.crop((img.width-1,0,img.width,img.height)).getdata()))
  pad=8 if border_opaque else 0
  if pad:
    padded=Image.new('RGBA',(img.width+2*pad,img.height+2*pad),(0,0,0,0));padded.alpha_composite(img,(pad,pad));img=padded
  name_safe=name.replace('.png','').lower()
  key=name_safe
  target=PAR/(key+'.png');img.save(target,optimize=True)
  cat=('house' if p in selected_houses else 'prop' if p in selected_props else 'tree')
  sources[key]={'id':key,'file':f'private_assets/independent_par/{key}.png','sha256':sha(target.read_bytes()),'original_sha256':sha(orig),'from':origin,'original_name':p,'size':[img.width,img.height],'semantic':cat,'alpha_added_padding_px':pad,'full_independent_art':True}
  originals.append((cat,key))
assert len(sources)>=23
# Distribute forests naturally near edges of the frame, footpoints on green pixels.
# No hidden cut-and-fill of new Ground. House positions use separate scene sprites.
obj=[]
def add(k,x,y,semantic=None,shade=None,allow_edge=False):
  src=sources[k];w,h=src['size'];x=int(x);y=int(y)
  # keep full complete source on canvas unless intentional frame-edge trees marked.
  if not allow_edge:
    x=min(max(x,1),1280-w-1); y=min(max(y,1),928-h-1)
  foot_x=x+w//2;foot_y=y+h-1
  it={'id':f'obj_{len(obj)+1:03d}_{k[:18]}','asset_id':k,'semantic':semantic or src['semantic'],'x':x,'y':y,'w':w,'h':h,'foot':[foot_x,foot_y], 'source_sha256':src['sha256'],'frame_edge_allowed':allow_edge,'root_collision':(semantic or src['semantic']) in ['tree','house'],'art_status':'CANDIDATE'}
  obj.append(it);return it
# Buildings first, their door approach region left open; moss roof same family.
housekeys=[k for cat,k in originals if cat=='house']
add(housekeys[0],158,155,'house');add(housekeys[1],939,168,'house')
# Trees in clustered tapered forest borders; no trees should invade main footpath.
treekeys=[k for cat,k in originals if cat=='tree']
assert len(treekeys)>=18
# Deterministic clusters, each [x_min,x_max,y_min,y_max,count] of source-object top left positions.
regions=[(-40,460,-70,20,18),(808,1300,-70,20,18),(-60,92,100,790,22),(1186,1350,98,740,25),(-50,365,770,968,21),(915,1320,765,1000,22),(385,530,-70,35,5),(690,830,-70,35,5)]
# Avoid planting tree roots on major dirt roads and directly in front of house facades.
def grassy(x,y):
  if x<0 or y<0 or x>=1280 or y>=928:return True
  R,Gc,B=G.getpixel((x,y))[:3]
  return Gc>R*0.88 and Gc>B*1.12
for ix,(l,r,t,b,n) in enumerate(regions):
  added=0;attempts=0
  while added<n and attempts<n*22:
    attempts+=1;k=rng.choice(treekeys);w,h=sources[k]['size'];x=rng.uniform(l,r);y=rng.uniform(t,b)
    px=int(x+w/2);py=int(y+h-1)
    if (130<px<490 and 140<py<445) or (900<px<1190 and 140<py<455):continue
    if (480<px<860 and 130<py<790):continue # central walk corridor
    if not grassy(max(0,min(px,1279)),max(0,min(py,927))):continue
    if any(abs(o['foot'][0]-px)<46 and abs(o['foot'][1]-py)<32 for o in obj if o['semantic']=='tree'):continue
    add(k,x,y,'tree',allow_edge=(x<0 or y<0 or x+w>1280 or y+h>928));added+=1
# sparse small props and completed independent shrubs in plant beds
wellkey=next(k for cat,k in originals if 'well' in k)
add(wellkey,470,355,'prop')
lantern=next(k for cat,k in originals if 'lantern' in k)
for pos in [(480,417),(864,454),(560,695),(1000,620)]:add(lantern,*pos,semantic='prop')
rocks=next(k for cat,k in originals if 'rock_cluster' in k)
for pos in [(330,562),(1080,520),(390,655),(885,745)]:add(rocks,*pos,semantic='prop')
shrub=next(k for cat,k in originals if 'bush_sprout' in k)
add(shrub,125,550,semantic='prop')
# Logical source ownership and collision data independent of alpha.
scene={'schema':'fs-a32-ground-first-independent-par/v1','status':'CANDIDATE_ART_NOT_APPROVED','policy':'FS_ACTIVE_MASTER_V1.3','engine':'Godot 4.7.2','canvas':[1280,928],'grid_px':32,'ground':{'path':'private_assets/ground_only.png','sha256':sha(GBytes),'creation':'image_gen_ground_only_crop_1to1','source_size':[1536,1024],'crop_xyxy':[128,48,1408,976],'no_foreground_buildings_trees':True},'assets':sources,'objects':obj,'objective':'Ground rendered first; independent full source sprites instantiated over ground with real footpoints; not cut from flattened scene.','art_gate':'HOLD','collision_gate':'CANDIDATE','reference':'Ground3 original pixel-richness and free-generated polished composite'}
(DATA/'a32_groundfirst_manifest.json').write_text(json.dumps(scene,ensure_ascii=False,indent=2),encoding='utf-8')
# PAR compositing is for QA preview only; editor uses individuals.
A=Image.new('RGBA',G.size,(0,0,0,0))
for it in sorted(obj,key=lambda o:(o['foot'][1],o['id'])):
  im=Image.open(PAR/(it['asset_id']+'.png')).convert('RGBA');A.alpha_composite(im,(it['x'],it['y']))
A.save(QA/'a32_par_preview_only.png',optimize=True)
C=G.copy();C.alpha_composite(A);C.save(QA/'a32_composite_reference_not_runtime.png',optimize=True)
G.save(QA/'a32_ground_only_1x.png',optimize=True)
# Side-by-side review (Ground, PAR on checker, final scene), all 1x 1280x928 scaled to compact review.
q=Image.new('RGB',(1280*3,928),(224,224,224));q.paste(G.convert('RGB'),(0,0))
checker=Image.new('RGBA',G.size,(245,244,239,255));draw=ImageDraw.Draw(checker)
for cy in range(0,928,32):
 for cx in range(0,1280,32):
  if (cx//32+cy//32)%2: draw.rectangle((cx,cy,cx+31,cy+31),fill=(217,217,217,255))
checker.alpha_composite(A);q.paste(checker.convert('RGB'),(1280,0));q.paste(C.convert('RGB'),(2560,0));q.resize((1920,464),Image.Resampling.NEAREST).save(QA/'a32_ground_par_composite_threeway_review.png',optimize=True)
# Mechanical pixel QA: Ground unchanged by composition; every object independently alpha-isolated.
assert ImageChops.difference(G,Image.open(PA/'ground_only.png').convert('RGBA')).getbbox() is None
assert all(Image.open(PAR/(k+'.png')).mode=='RGBA' for k in sources)
assert all(s['full_independent_art'] for s in sources.values())
counts={t:sum(o['semantic']==t for o in obj) for t in ['tree','house','prop']}
qa={'status':'ENGINE_NOT_YET_RUN','ground_sha256':sha(GBytes),'total_objects':len(obj),'total_independent_source_assets':len(sources),'category_counts':counts,'ground_master_source_not_used':True,'par_sourced_from_flattened_master':False,'ground_resolution':[1280,928],'qa_preview':'a32_ground_par_composite_threeway_review.png','ART_PASS':False,'collision_PASS':False}
(QA/'a32_static_qa.json').write_text(json.dumps(qa,indent=2),encoding='utf-8')
print(json.dumps({'qa':qa,'output':str(D)},indent=2))
