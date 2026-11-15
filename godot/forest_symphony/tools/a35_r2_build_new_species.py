#!/usr/bin/env python3
"""Forest Symphony A35 R2: eight new native-pixel tree silhouettes, Godot PAR replacement.

No sprite dimensions are resampled. The silhouette outlines and trunks are authored
at final resolution. Foliage internal texture is synthesized using *unscaled* native
pixel micro-patches from the owner-only A35 reference tree family. No Master crop.
"""
import argparse, collections, hashlib, io, json, math, random, re, zipfile
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont,ImageChops

BASE='/mnt/data/FS_A35_R1_COMPLETE_NATIVE_PRIVATE_20261115.zip'
OUT='/mnt/data/FS_A35_R2_NEW_SILHOUETTES_PRIVATE_20261115.zip'
R=Path.cwd()
BASE_SCENE='scenes/a35_r1_forest_groves_scene.tscn'
NEW_SCENE='scenes/a35_r2_new_species_scene.tscn'
BASE_MAN='data/a35_r1_forest_groves_manifest.json'
NEW_MAN='data/a35_r2_new_species_manifest.json'
GALLERY='qa_a35/A35_R2_8_NATIVE_SILHOUETTES.png'
SPECIES=[
 ('cypress', 92,172,'a36f_dense_tree_131_rgba',[(46,75,25,63)], 'column'),
 ('willow',154,174,'a36f_dense_tree_042_rgba',[(50,70,45,35),(108,67,41,32),(77,95,61,34)], 'willow'),
 ('elder',162,158,'a36f_dense_tree_021_rgba',[(48,57,36,35),(111,54,42,35),(78,87,65,36)],'broad'),
 ('fir',108,185,'a36f_dense_tree_082_rgba',[(52,80,25,65)],'fir'),
 ('birch',122,171,'a36f_dense_tree_092_rgba',[(37,65,30,42),(88,75,34,44)],'birch'),
 ('oak',172,159,'a36f_dense_tree_073_rgba',[(48,67,51,37),(125,64,42,35),(83,84,61,34)],'oak'),
 ('needle',90,179,'fsobj_tree_blue_02',[(45,82,29,72)],'needle'),
 ('maple',142,152,'fsobj_tree_moss_01',[(47,51,36,35),(95,52,42,38),(70,78,52,33)],'maple'),
]

def sha(data):return hashlib.sha256(data).hexdigest()
def load(z,p):return Image.open(io.BytesIO(z.read(p))).convert('RGBA')
def png_bytes(img):
 b=io.BytesIO();img.save(b,format='PNG',optimize=True);return b.getvalue()

def patches(reference,seed):
 """Capture full-opacity original native foliage texels in 8px patches."""
 w,h=reference.size; rr=random.Random(seed);a=reference.getchannel('A')
 res=[]
 for _ in range(1400):
  x=rr.randrange(0,max(1,w-9));y=rr.randrange(0,max(1,int(h*.72)-9))
  if sum(v>220 for v in a.crop((x,y,x+8,y+8)).getdata())>=52:
   res.append(reference.crop((x,y,x+8,y+8)).convert('RGBA'))
  if len(res)>=80:break
 if not res:raise ValueError('No native foliage atlas')
 return res

def mask_shape(w,h,kind,lobes,rng):
 mask=Image.new('L',(w,h));d=ImageDraw.Draw(mask)
 # Broad crowns formed by uneven overlapping lobes; no perfect circular boundary.
 if kind in ('column','fir','needle'):
  cx=w//2;peak=12;foot=int(h*.79)
  for yy in range(peak,foot):
   t=(yy-peak)/(foot-peak)
   if kind=='column':extent=int(3+29*math.sin(t*math.pi*.75)**.9)
   else:extent=int(3+min(t*2,1)*((w*.39)*(0.70+0.30*math.sin(yy*.16)**2)))
   jag=int(3*math.sin(yy*.61)+2*math.sin(yy*.23))
   d.line((cx-extent-jag,yy,cx+extent+int(jag*.7),yy),fill=255,width=1)
  if kind!='column':
   for level in range(4):
    y=int(36+level*29); radius=int(18+level*7)
    d.polygon([(cx,y-18),(cx-radius,y+11),(cx-radius+5,y+15),(cx+radius-4,y+15),(cx+radius,y+8)],fill=255)
 elif kind=='willow':
  for cx,cy,rx,ry in lobes:
   d.ellipse((cx-rx,cy-ry,cx+rx,cy+ry),fill=255)
  # flowing willow fronds extending well below the canopy
  for i in range(38):
   x=rng.randrange(15,w-12);from_y=rng.randrange(73,96)
   length=rng.randrange(20,57)
   d.line([(x,from_y),(x+rng.randrange(-13,14),min(h-22,from_y+length))],fill=255,width=rng.randint(2,4))
 else:
  for cx,cy,rx,ry in lobes:
   d.ellipse((cx-rx,cy-ry,cx+rx,cy+ry),fill=255)
  # Irregular lobe contour and gaps
  for i in range(105):
   x=rng.randrange(7,w-7);y=rng.randrange(19,int(h*.78))
   if mask.getpixel((x,y)):
    size=rng.randrange(3,9)
    d.ellipse((x-size,y-size//2,x+size,y+size//2),fill=255)
 # notched leaf edges and needle ends
 if kind in ('column','fir','needle'):
  for i in range(65):
   y=rng.randrange(24,int(h*.78));x=rng.randrange(5,w-5)
   if mask.getpixel((x,y)):
    d.line((x,y,x+rng.choice([-1,1])*rng.randrange(4,9),y+rng.randrange(1,6)),fill=255,width=1)
 return mask

def draw_wood(img,kind,rng):
 d=ImageDraw.Draw(img)
 w,h=img.size;cx=w//2;bottom=h-9
 if kind=='birch':
  trunks=[(cx-22,9),(cx+17,8)]
 else:trunks=[(cx,12)]
 for px,tw in trunks:
  y0=round(h*.46) if kind not in ('fir','column','needle') else round(h*.63)
  tipx=px+rng.randrange(-5,6)
  # roots, dark edges, warm interior, cool lower shaded side
  d.polygon([(tipx-tw//2,y0),(tipx+tw//2,y0),(px+tw//2,bottom-4),(px+tw//2+13,bottom),
             (px+tw//2-3,bottom),(px,bottom-5),(px-tw//2-15,bottom),(px-tw//2,bottom-6)],fill='#322817')
  main='#8b8c66' if kind=='birch' else '#5d4829'
  left='#b0aa84' if kind=='birch' else '#8a6240'
  d.polygon([(tipx-tw//2+2,y0+3),(tipx+tw//2-2,y0+3),(px+tw//2-2,bottom-6),(px+tw//2-10,bottom-8),(px,bottom-10),(px-tw//2+1,bottom-6)],fill=main)
  d.line([(tipx-1,y0+7),(px-3,bottom-14)],fill=left,width=2)
  d.line([(tipx+tw//2-3,y0+12),(px+tw//2-4,bottom-11)],fill='#43311e',width=2)
  for i in range(19):
   yy=rng.randrange(y0+8,bottom-12);xx=px+rng.randint(-tw//3,tw//3)
   d.line((xx,yy,xx+rng.randint(-3,3),yy+rng.randint(2,7)),fill='#3b3226' if i%3 else '#ad8660',width=1)
  if kind=='birch':
   for i in range(12):
    yy=rng.randrange(y0+6,bottom-8);d.line((px-tw//3,yy,px+tw//3,yy+2),fill='#2b3227')
  # branching before canopy layer, thin winding wood
  for sign in (-1,1):
   d.line([(tipx,y0+36),(tipx+sign*11,y0+20),(tipx+sign*19,y0+11)],fill='#3f3121',width=4)
   d.line([(tipx,y0+35),(tipx+sign*10,y0+19)],fill='#88603a',width=1)

def render_species(spec,refs):
 name,w,h,ref,lobes,kind=spec;rng=random.Random('A35R2'+name)
 im=Image.new('RGBA',(w,h),(0,0,0,0));draw_wood(im,kind,rng)
 m=mask_shape(w,h,kind,lobes,rng)
 tex=Image.new('RGBA',(w,h),(0,0,0,0)); atlas=patches(refs[ref],name)
 # Pixel mosaics at final native resolution, with no image resizing.
 for y in range(0,h,8):
  for x in range(0,w,8):
   p=rng.choice(atlas)
   tex.paste(p,(x,y))
 # Recolor foliage selectively with dark / light native clusters; alpha mask shaped.
 color=Image.new('RGBA',(w,h));outpx=color.load();tx=tex.load();mk=m.load()
 for y in range(h):
  for x in range(w):
   if not mk[x,y]:continue
   r,g,b,a=tx[x,y]
   if a<90:r,g,b=35,65,23
   # upper-left highlights / lower-right shadow, plus subtle organic leaf shade
   shade=1.02-0.22*(y/max(1,h))+0.085*((w-x)/w)
   if kind in ('column','needle'):shade*=.82
   if kind=='birch':shade*=1.12
   if kind=='maple':shade*=1.04
   outpx[x,y]=(int(min(240,r*shade)),int(min(242,g*shade)),int(min(190,b*shade)),255)
 # extra clustered texture along scalloped crowns, no antialias / resample
 d=ImageDraw.Draw(color,'RGBA')
 for _ in range(280):
  x=rng.randrange(3,w-3);y=rng.randrange(10,int(h*.83))
  if mk[x,y]:
   col=rng.choice(['#97b544','#86a839','#b5bf65','#587c28','#456723','#314b20'])
   sz=rng.choice([1,1,1,2,3]);
   if kind in ('column','needle','fir'):d.line((x,y,x+rng.randrange(-2,3),y+rng.randint(1,4)),fill=col,width=1)
   else:d.polygon([(x,y),(x+sz+1,y-1),(x+sz+3,y),(x+sz,y+sz),(x-1,y+sz)],fill=col)
 # enforce original silhouette mask, suppress decoration outside foliage edge
 color.putalpha(m)
 im.alpha_composite(color)
 if kind=='willow':
  d=ImageDraw.Draw(im)
  for i in range(43):
   x=rng.randrange(12,w-12);y=rng.randrange(78,98)
   if im.getpixel((x,y))[3]==0:continue
   end=min(h-20,y+rng.randrange(13,45))
   d.line((x,y,x+rng.randint(-9,9),end),fill=rng.choice(['#557629','#8aa83c','#254b28']),width=rng.randint(1,2))
 if kind=='maple':
  d=ImageDraw.Draw(im)
  for i in range(80):
   x=rng.randrange(8,w-8);y=rng.randrange(18,int(h*.7))
   if im.getpixel((x,y))[3]>0 and rng.random()<.7:
    d.point((x,y),fill=rng.choice(['#dbba68','#d1ac4b','#b9a254']))
 # no hole canvas wider than asset dimensions, fully independent RGBA
 assert im.getbbox() is not None
 assert im.getpixel((0,0))[3]==0
 assert im.getpixel((w-1,0))[3]==0
 return im

def build(basezip=BASE,outzip=OUT):
 with zipfile.ZipFile(basezip) as z:
  assert z.testzip() is None
  files={n:z.read(n) for n in z.namelist()}
 base_sha=sha(Path(basezip).read_bytes())
 d=json.loads(files[BASE_MAN]);objs=d['objects'];assert len(objs)==187
 assert len([o for o in objs if o['semantic']=='tree'])==175
 refs={k:load_data(files[a['file']]) for k,a in d['assets'].items() if a.get('semantic')=='tree'}
 gallery=Image.new('RGB',(4*216,2*246),'#4a594a');dd=ImageDraw.Draw(gallery)
 assets_new={};source_imgs={}
 for index,s in enumerate(SPECIES):
  name,w,h,ref,lobes,kind=s
  im=render_species(s,refs)
  nameid='a35r2_'+name;path=f'private_assets/independent_par/{nameid}.png';bytes_=png_bytes(im)
  assert path not in files
  files[path]=bytes_
  assets_new[nameid]={'id':nameid,'file':path,'sha256':sha(bytes_),'size':[w,h],'semantic':'tree','from':'A35_R2_NATIVE_PIXEL_NEW_SILHOUETTE','source_texture_ref':ref,'full_independent_art':True,'no_resampling':True,'species':name}
  x=(index%4)*216+(216-w)//2;y=(index//4)*246+14
  gallery.paste(im,(x,y),im);dd.text(((index%4)*216+18,(index//4)*246+211),name,fill='white')
  source_imgs[nameid]=im
 gallery.save(R/'A35_R2_NEW_SPECIES_GALLERY.png')
 files[GALLERY]=png_bytes(gallery)
 scene=files[BASE_SCENE].decode()
 assert scene.count('[node name="a35_grove_')==41
 changed=[];from_to=[]
 for idx,o in enumerate(objs):
  if not o['id'].startswith('a35_grove_'):continue
  # Replace 32/41 newly appended grove trees, preserving 9 original R1 foliage assets for continuity.
  index=int(o['id'].split('_')[2]);
  if index%5==0 or index>=40: continue
  new_asset=list(assets_new.keys())[(index*7+index//4)%8]
  a=assets_new[new_asset]
  old_source='res://'+d['assets'][o['asset_id']]['file'];old_sha=o['source_sha256']
  new_source='res://'+a['file'];new_sha=a['sha256']
  # Match per-node exact reference, never global text replacement.
  esc=re.escape(o['id'])
  pattern=r'(\[node name="'+esc+r'" type="Node2D" parent="YSort"\]\n.*?source_file = ")'+re.escape(old_source)+r'("\nsource_sha256 = ")'+old_sha+r'("\n)'
  result,repl_count=re.subn(pattern,lambda m:m.group(1)+new_source+m.group(2)+new_sha+m.group(3),scene,flags=re.S)
  assert repl_count==1,(o['id'],repl_count)
  scene=result
  size=a['size'];o['asset_id']=new_asset;o['source_sha256']=new_sha;o['w']=size[0];o['h']=size[1]
  o['x']=int(o['foot'][0]-size[0]/2);o['y']=int(o['foot'][1]-size[1]+1)
  o['added_in']='A35_R2_REPLACEMENT';o['original_a35_r1_asset']=old_source
  changed.append(o['id']);from_to.append((old_source,new_source))
 assert len(changed)==32,len(changed)
 # Keep original R1 scene intact; only make additive new world and new scene.
 scene=scene.replace('res://scripts/a35_r1_world.gd','res://scripts/a35_r2_world.gd',1)
 scene=scene.replace('[node name="FS_A35_R1_ForestGroves" type="Node2D"]','[node name="FS_A35_R2_EightNewTreeSpecies" type="Node2D"]',1)
 scene=scene.replace('load_steps=4','load_steps=4',1)
 assert scene.count('[node name="a35_grove_')==41
 files[NEW_SCENE]=scene.encode()
 world=files['scripts/a35_r1_world.gd'].decode().replace('A35 R1','A35 R2').replace('A35 R1 GODOT','A35 R2 GODOT')
 files['scripts/a35_r2_world.gd']=world.encode()
 d['assets'].update(assets_new)
 d.update({'schema':'fs-a35-r2-native-new-species/v1','status':'ENGINE_CANDIDATE_ART_HOLD','origin_scene':BASE_SCENE,'base_sha256':sha(files[BASE_SCENE]),'a35_r2_gate':{'native_original_silhouettes':8,'new_png_count':8,'replaced_r1_trees':len(changed),'old_par_owners':187,'new_par_owners':187,'total_trees':175,'original_ground_sha256':d['ground']['sha256'],'art':'HOLD','godot_native':'NOT_RUN_AT_BUILD','source_generation':'native-resolution procedural pixel shapes with unscaled original foliage texture patches'}})
 d['objects']=objs
 files[NEW_MAN]=(json.dumps(d,ensure_ascii=False,indent=2)+'\n').encode()
 # Native dimension and alpha source QA
 for k,v in assets_new.items():
  im=load_data(files[v['file']]);assert list(im.size)==v['size']
  assert sha(files[v['file']])==v['sha256']
  assert im.getchannel('A').getbbox()
 assert sha(files['private_assets/ground_only.png'])==d['ground']['sha256']
 assert len([o for o in objs if o['semantic']=='tree'])==175
 # Switch candidate main scene; originals immutable.
 pg=files['project.godot'].decode().replace('res://'+BASE_SCENE,'res://'+NEW_SCENE)
 assert NEW_SCENE in pg
 files['project.godot']=pg.encode()
 report={'phase':'A35_R2','source_zip_sha256':base_sha,'original_A35_scene_sha256':sha(files[BASE_SCENE]),'ground_sha256':d['ground']['sha256'],'new_tree_species':8,'replaced_trees':len(changed),'all_par_owners':len(objs),'all_trees':175,'scene_path':NEW_SCENE,'new_assets':assets_new,'source_contract':'PASS','native_engine':'NOT_RUN_AT_BUILD','art':'HOLD'}
 files['qa_a35/A35_R2_SOURCE_QA.json']=(json.dumps(report,indent=2)+'\n').encode()
 # A/B software only, never mislabeled as native Godot.
 def composite(doc):
  im=load_data(files['private_assets/ground_only.png']).crop((0,0,1280,928))
  for o in sorted(doc['objects'],key=lambda x:(x['foot'][1],x['id'])):
   a=doc['assets'][o['asset_id']];sprite=load_data(files[a['file']])
   im.alpha_composite(sprite,(round(o['foot'][0]-sprite.width/2),round(o['foot'][1]-sprite.height+1)))
  return im.convert('RGB')
 old_d=json.loads(files[BASE_MAN]);old_frame=composite(old_d);new_frame=composite(d)
 old_frame.save(R/'A35_R2_OLD_SOFTWARE_PREVIEW.png');new_frame.save(R/'A35_R2_NEW_SOFTWARE_PREVIEW.png')
 bbox=ImageChops.difference(old_frame,new_frame).getbbox();assert bbox
 # safe change ROI: only R1 objects whose species changed
 mask=Image.new('1',(1280,928),0);mm=ImageDraw.Draw(mask)
 for o in objs:
  if o['id'] not in changed:continue
  old=next(b for b in old_d['objects'] if b['id']==o['id'])
  for q in (o,old):
   mm.rectangle((q['x']-2,q['y']-2,q['x']+q['w']+2,q['y']+q['h']+2),fill=1)
 ap=old_frame.load();bp=new_frame.load();mp=mask.load()
 inside=outside=0
 for y in range(928):
  for x in range(1280):
   if ap[x,y]!=bp[x,y]:
    if mp[x,y]:inside+=1
    else:outside+=1
 assert outside==0,(inside,outside)
 report['software_preview_changed_inside']=inside;report['software_preview_changed_outside']=outside
 files['qa_a35/A35_R2_SOURCE_QA.json']=(json.dumps(report,indent=2)+'\n').encode()
 files['qa_a35/A35_R2_NEW_SOFTWARE_PREVIEW_NOT_NATIVE.png']=png_bytes(new_frame)
 # Native QA script from original A35 R1 using variant, new ROI masking old and new dims.
 script='''extends SceneTree
## A35 R2: real in-Godot source/SHA/scene contract. Exit nonzero on mismatch.
const NEW := "res://scenes/a35_r2_new_species_scene.tscn"
const MAN := "res://data/a35_r2_new_species_manifest.json"
func _initialize() -> void:call_deferred("_run")
func _run() -> void:
    var raw:=FileAccess.get_file_as_string(MAN)
    var doc=JSON.parse_string(raw)
    if typeof(doc)!=TYPE_DICTIONARY:push_error("Manifest missing");quit(20);return
    var world:Node=load(NEW).instantiate()
    root.add_child(world)
    await process_frame
    var owners:Node=world.get_node("YSort")
    if owners.get_child_count()-1 != 187:push_error("PAR count changed");quit(21);return
    var count:=0
    for ob in doc["objects"]:
        if not str(ob["id"]).begins_with("a35_grove_"):continue
        var node=owners.get_node(str(ob["id"]))
        if node.source_sha256 != ob["source_sha256"]:push_error("SHA binding mismatch "+str(ob["id"]));quit(22);return
        if FileAccess.get_sha256(str(node.source_file)) != str(ob["source_sha256"]):push_error("PNG bytes differ "+str(ob["id"]));quit(23);return
        if node.get_node("Body/Collision").shape==null:push_error("Missing root collision");quit(24);return
        count+=1
    if count != 41:push_error("Grove count mismatch");quit(25);return
    print("FS A35 R2 GODOT native 41 grove source SHA, 8 new species, 187 PAR and root-collision PASS")
    quit(0)
'''
 files['tests/test_a35_r2_real.gd']=script.encode()
 files['qa_a35/A35_R2_FAILURE_LOG.md']=(f'''# A35 R2 source checkpoint\n\n- 8 new native-resolution full RGBA species silhouettes generated with per-pixel foliage textures; no artwork resizing.\n- 32 A35 R1 border-grove tree source bindings changed; original A35 R1 scene and all original assets remain.\n- Source SHA binding PASS; source outside ROI delta zero.\n- Native Godot test: NOT_RUN at build; art visual review HOLD.\n- No physical navigation claim until separate Godot real-physics test.\n''').encode()
 with zipfile.ZipFile(outzip,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
  for n,b in files.items():z.writestr(n,b)
 with zipfile.ZipFile(outzip) as z:
  assert z.testzip() is None
  assert z.read(BASE_SCENE)==files[BASE_SCENE]
  assert z.read('private_assets/ground_only.png')==files['private_assets/ground_only.png']
 final={'zip':outzip,'bytes':Path(outzip).stat().st_size,'sha256':sha(Path(outzip).read_bytes()),'members':len(files),'species':len(SPECIES),'replaced':len(changed),'software_pixel_inside':inside,'software_pixel_outside':outside}
 (R/'A35_R2_BUILD_REPORT.json').write_text(json.dumps(final,indent=2))
 print(json.dumps(final,indent=2))

def load_data(b):return Image.open(io.BytesIO(b)).convert('RGBA')
if __name__=='__main__':
 parser=argparse.ArgumentParser(description='A35 R2 reproducible private Godot tree sprite builder')
 parser.add_argument('--base',required=True,help='Owner-only sealed A35 R1 ZIP')
 parser.add_argument('--output',required=True,help='Output private Godot ZIP')
 opts=parser.parse_args()
 build(opts.base,opts.output)