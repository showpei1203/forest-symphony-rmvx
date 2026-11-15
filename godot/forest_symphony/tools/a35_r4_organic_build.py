#!/usr/bin/env python3
"""Forest Symphony A35 R4: native-pixel, source-based organic crown recovery.

Builds owner-only new R4 scene from immutable private R3. Outputs PNGs only
inside owner-only private ZIP; public GitHub contains only this reproducible code.
Uses whole approved FS A36F artworks, not repeating 8x8 patches.
"""
import argparse,copy,hashlib,io,json,random,zipfile
from pathlib import Path
import numpy as np
from PIL import Image,ImageDraw,ImageOps

SRC='scenes/a35_r3_hd2d_layered_scene.tscn'
DST='scenes/a35_r4_organic_groves_hd2d_scene.tscn'
MAN='data/a35_r2_new_species_manifest.json'
NEW_MAN='data/a35_r4_organic_groves_manifest.json'
GROUND='private_assets/ground_only.png'
GROUND_SHA='3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000'
# Native-size, source-derived candidates. Botanical distinctness remains ART HOLD.
STYLES={
 'cypress':('a36f_dense_tree_102_rgba',(92,172),-.012,.89),
 'willow':('a36f_dense_tree_073_rgba',(154,174),+.013,.90),
 'elder':('a36f_dense_tree_121_rgba',(162,158),-.022,.94),
 'fir':('a36f_dense_tree_049_rgba',(108,185),-.034,.87),
 'birch':('a36f_dense_tree_007_rgba',(122,171),+.015,1.04),
 'oak':('a36f_dense_tree_056_rgba',(172,159),-.014,.86),
 'needle':('a36f_dense_tree_082_rgba',(90,179),-.042,.81),
 'maple':('a36f_dense_tree_028_rgba',(142,152),+.042,1.06)
}

def sha(x):return hashlib.sha256(x).hexdigest()
def img(x):return Image.open(io.BytesIO(x)).convert('RGBA')
def png(i):
    b=io.BytesIO();i.save(b,'PNG',optimize=True);return b.getvalue()

def sprite(spec,info,assets,files):
    ref,size,hue,saturation=info
    source=img(files[assets[ref]['file']]);w,h=source.size
    if w>size[0] or h>size[1]:raise ValueError('native art too large '+spec)
    data=np.asarray(source,dtype=np.uint8).copy()
    rgb=data[:,:,:3].astype(np.float32)
    r,g,b=rgb[:,:,0],rgb[:,:,1],rgb[:,:,2]
    leaf=(data[:,:,3]>30)&(g>r*1.08)&(g>b*1.08)&(g>30)
    yy,xx=np.mgrid[0:h,0:w]
    rng=random.Random(1013+sum(ord(c) for c in spec))
    shade=hue
    for _ in range(5):
        cx=rng.uniform(-20,w+20);cy=rng.uniform(0,h*.78)
        sx=rng.uniform(15,45);sy=rng.uniform(16,43)
        shade=shade+rng.uniform(-.065,.045)*np.exp(-((xx-cx)**2/sx**2+(yy-cy)**2/sy**2))
    rgb[:,:,0]=np.where(leaf,np.clip(r*(1+shade*.5),0,255),r)
    rgb[:,:,1]=np.where(leaf,np.clip(g*(1+shade*.2)*saturation,0,255),g)
    rgb[:,:,2]=np.where(leaf,np.clip(b*(1-shade*.7)+5*(spec in ('needle','fir')),0,255),b)
    data[:,:,:3]=np.uint8(np.clip(rgb,0,255))
    art=Image.fromarray(data,'RGBA')
    a=np.asarray(art.getchannel('A'))
    draw=ImageDraw.Draw(art,'RGBA')
    rng=random.Random(31817+len(spec))
    if spec=='willow':
        positions=[]
        for x in range(6,w-6,4):
            ys=np.flatnonzero(a[:int(h*.60),x]>180)
            if len(ys)>5:positions.append((x,int(ys[-1])))
        rng.shuffle(positions)
        for x,y in positions[:24]:
            if y>h*.7:continue
            span=rng.randint(10,24);end=min(h-27,y+span)
            if end<=y:continue
            drift=rng.choice((-5,-3,-2,2,3,5))
            color=rng.choice([(49,91,37,228),(71,112,39,231),(95,132,43,225),(45,81,38,225)])
            draw.line([(x,y),(x+drift//2,y+span//2),(x+drift,end)],fill=color,width=rng.choice([1,1,2]))
    if spec in ('birch','maple'):
        for _ in range(95 if spec=='birch' else 150):
            x=rng.randint(3,w-4);y=rng.randint(3,round(h*.72))
            if a[y,x]>225:
                color=rng.choice([(159,184,86,220),(183,190,101,220),(129,160,75,190)]) if spec=='birch' else rng.choice([(185,167,65,205),(197,172,84,185),(146,155,59,225)])
                draw.rectangle((x,y,x+1,y+1),fill=color)
    if spec in ('elder','oak','maple'):art=ImageOps.mirror(art)
    canvas=Image.new('RGBA',size,(0,0,0,0))
    canvas.alpha_composite(art,((size[0]-w)//2,size[1]-h))
    return canvas

def native_test():
    return '''extends SceneTree
const OLD := "res://scenes/a35_r3_hd2d_layered_scene.tscn"
const NEW := "res://scenes/a35_r4_organic_groves_hd2d_scene.tscn"
const MAN := "res://data/a35_r4_organic_groves_manifest.json"
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
    if FileAccess.get_sha256("res://private_assets/ground_only.png")!="3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000":
        push_error("R4 Ground mismatch");quit(40);return
    var data=JSON.parse_string(FileAccess.get_file_as_string(MAN))
    var a=load(OLD).instantiate()
    var b=load(NEW).instantiate()
    root.add_child(a);root.add_child(b)
    await process_frame
    var x=a.get_node("YSort")
    var y=b.get_node("YSort")
    if x.get_child_count()!=y.get_child_count():
        push_error("R4 owner count changed");quit(41);return
    var changed:=0
    var retained:=0
    for entry in data["objects"]:
        var name=NodePath(str(entry["id"]))
        var left=x.get_node_or_null(name)
        var right=y.get_node_or_null(name)
        if left==null or right==null or left.position!=right.position:
            push_error("R4 owner drift "+str(name));quit(42);return
        if right.source_sha256!=entry["source_sha256"] or FileAccess.get_sha256(str(right.source_file))!=entry["source_sha256"]:
            push_error("R4 source SHA mismatch "+str(name));quit(43);return
        var l:CollisionShape2D=left.get_node("Body/Collision")
        var r:CollisionShape2D=right.get_node("Body/Collision")
        if (l.shape==null)!=(r.shape==null) or l.disabled!=r.disabled:
            push_error("R4 collision presence changed "+str(name));quit(44);return
        if l.shape!=null and l.shape.get_rect()!=r.shape.get_rect():
            push_error("R4 collision size changed "+str(name));quit(44);return
        if left.source_file==right.source_file:retained+=1
        else:changed+=1
    if changed!=32 or retained!=155:
        push_error("R4 changed="+str(changed)+" kept="+str(retained));quit(45);return
    print("FS A35 R4 GODOT PASS: 32 replaced, 155 retained, unchanged 187 PAR positions/collisions, Ground SHA stable")
    quit(0)
'''

def build(base:Path,out:Path,work:Path):
    work.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(base) as z:
        if z.testzip() is not None:raise ValueError('Base CRC failed')
        files={k:z.read(k) for k in z.namelist()}
    if sha(files[GROUND])!=GROUND_SHA:raise ValueError('Ground hash not original')
    base_scene=files[SRC]
    doc=json.loads(files[MAN]);changed=[]
    if len(doc['objects'])!=187:raise ValueError('Not R3 187 PAR')
    source_scene=base_scene.decode()
    catalog={}
    for species,style in STYLES.items():
        art=sprite(species,style,doc['assets'],files)
        new_id='a35r4_'+species;old_id='a35r2_'+species
        dst='private_assets/independent_par/'+new_id+'.png'
        bitmap=png(art);files[dst]=bitmap
        catalog[new_id]={'id':new_id,'file':dst,'sha256':sha(bitmap),'size':list(art.size),
            'semantic':'tree','source_asset':style[0],'species':species,
            'method':'1:1 entire FS painted source art with color fields and optional native-pixel accents',
            'no_resampling':True,'no_tiled_patches':True}
        old=doc['assets'][old_id]
        old_src='source_file = "res://'+old['file']+'"'
        if old_src not in source_scene:raise ValueError('R2 original source not in scene '+old_src)
        source_scene=source_scene.replace(old_src,'source_file = "res://'+dst+'"')
        source_scene=source_scene.replace('source_sha256 = "'+old['sha256']+'"','source_sha256 = "'+sha(bitmap)+'"')
        for item in doc['objects']:
            if item['asset_id']==old_id:
                item.update(asset_id=new_id,source_sha256=sha(bitmap),previous_R2_asset=old_id)
                changed.append(item['id'])
    if len(changed)!=32:raise ValueError('Not exactly 32 R2 instances: '+str(len(changed)))
    doc['assets'].update(catalog)
    doc.update(schema='fs-a35-r4-source-organic/v1',r4_replaced=32,
        r4_original_ground_sha=GROUND_SHA,r4_original_scene_sha=sha(base_scene),
        r4_modified_object_ids=changed,r4_art='HOLD',r4_native='NOT_RUN')
    files[DST]=source_scene.replace('FS_A35_R3_HD2D_Layered','FS_A35_R4_OrganicGrovesHD2D').encode()
    files[NEW_MAN]=(json.dumps(doc,ensure_ascii=False,indent=2)+'\n').encode()
    files['project.godot']=files['project.godot'].replace(('res://'+SRC).encode(),('res://'+DST).encode())
    files['tests/test_a35_r4_native.gd']=native_test().encode()
    nav=files['tests/test_a35_r2_navigation.gd'].decode()
    nav=nav.replace('res://scenes/a35_r2_new_species_scene.tscn','res://'+DST)
    nav=nav.replace('res://data/a35_r2_new_species_manifest.json','res://'+NEW_MAN)
    nav=nav.replace('A35 R2 NATIVE PHYSICAL NAV PASS','A35 R4 NATIVE PHYSICAL NAV PASS')
    files['tests/test_a35_r4_navigation.gd']=nav.encode()
    cap=files['tests/capture_a35_r3_hd2d_native.gd'].decode()
    cap=cap.replace('res://'+SRC,'res://'+DST).replace('A35_R3_HD2D_','A35_R4_ORGANIC_')
    files['tests/capture_a35_r4_native.gd']=cap.encode()
    gallery=Image.new('RGB',(4*228,2*235),'#707e67');pen=ImageDraw.Draw(gallery)
    for i,(species,_) in enumerate(STYLES.items()):
        sprite_img=img(files['private_assets/independent_par/a35r4_'+species+'.png'])
        x=(i%4)*228+(228-sprite_img.width)//2;y=(i//4)*235+13
        gallery.paste(sprite_img,(x,y),sprite_img)
        pen.text(((i%4)*228+13,(i//4)*235+208),'A35R4 '+species,fill='#fff')
    files['qa_a35/A35_R4_SOURCE_GALLERY_NOT_NATIVE.png']=png(gallery)
    (work/'A35_R4_SOURCE_GALLERY_NOT_NATIVE.png').write_bytes(png(gallery))
    files['docs/A35_R4_HANDOFF.md']=(f'''# FS A35 R4 | organic source-art candidate
- R3 source ZIP SHA {sha(base.read_bytes())}
- 8 source-derived variants, 32 swapped, 155 unchanged, original 187 PAR anchors and 175 trees.
- Original R2/R3 scenes and Ground SHA {GROUND_SHA} immutable.
- Native tests: tests/test_a35_r4_native.gd and tests/test_a35_r4_navigation.gd; native 3-phase GPU: tests/capture_a35_r4_native.gd.
- Synthetic source gallery is NOT Godot native proof. Engine and ART HOLD until tests.
- Limitation: source-inspired, not bespoke new species anatomies. No 8x8 foliage mosaics.
''').encode()
    files['docs/A35_R4_FAILURE_LOG.md']=('''# FS A35 R4 | Failure Log
- R2 crown repeated 8px leaf patches visibly; replaced by coherent whole-tree FS source pixels.
- Source candidate must pass Godot native QA, actual physics navigation and front/back occlusion.
- New species silhouettes partially similar to source trees; ART HOLD until 1x review.
- No private sprites or ZIP on public GitHub.
''').encode()
    with zipfile.ZipFile(out,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
        for k,v in files.items():z.writestr(k,v)
    with zipfile.ZipFile(out) as z:
        if z.testzip() is not None:raise ValueError('Final CRC failed')
        if z.read(SRC)!=base_scene or sha(z.read(GROUND))!=GROUND_SHA:
            raise ValueError('Source mutation')
    print(json.dumps({'file':str(out),'members':len(files),'bytes':out.stat().st_size,
        'sha256':sha(out.read_bytes()),'changed_instances':len(changed),'Ground':GROUND_SHA},indent=2))

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--base',required=True);p.add_argument('--output',required=True);p.add_argument('--work',required=True)
    a=p.parse_args();build(Path(a.base),Path(a.output),Path(a.work))
