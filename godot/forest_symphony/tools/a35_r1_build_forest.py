#!/usr/bin/env python3
"""FS A35 R1: protected A34 village -> independent PAR grove continuations.

Input is the owner-only A34 R4 complete ZIP. This creates an additive scene,
source-only GDScript/test/manifest and a candidate owner-only ZIP. It NEVER
resamples Ground or merges independent tree sprites into a flattened overlay.
"""
import argparse, collections, hashlib, io, json, random, re, zipfile
from PIL import Image
from pathlib import Path

BASE_SHA='dd2ecf7612e45d65c8fbb04515e0f0c94a69af449c941f6d9a7db71787f9d6f0'
SCENE_BASE='scenes/a34_r4_house_pair_scene.tscn'
SCENE_NEW='scenes/a35_r1_forest_groves_scene.tscn'
MANIFEST_BASE='data/a34_r4_house_pair_manifest.json'
MANIFEST_NEW='data/a35_r1_forest_groves_manifest.json'
WORLD_NEW='scripts/a35_r1_world.gd'
TEST_NEW='tests/test_a35_r1_real.gd'
CAPTURE_NEW='tests/capture_a35_r1_native.gd'

# Curated cluster anchors selected on the *native A34 R4 1280x928 frame*.
# Groves grow beyond top/left/right/bottom viewport, but leave the central road,
# west/east exits, both house portals, lamps and well unobstructed.
GROUPS={
'NW_CANOPY':[(10,81),(72,101),(140,118),(194,117),(268,95),(326,114),(393,79),(442,92)],
'NE_CANOPY':[(849,108),(905,91),(963,115),(1021,85),(1104,121),(1164,115),(1245,133),(1305,106)],
'WEST_UPPER_EDGE':[(-32,213),(39,248),(83,310),(-25,318),(109,335),(10,370)],
'WEST_LOWER_EDGE':[(-30,634),(43,659),(89,698),(-19,739),(22,784),(103,814),(161,798)],
'SW_FOREST_CONTINUATION':[(205,831),(278,841),(341,877),(376,935),(268,922),(179,947),(76,929),(-25,880)],
'EAST_UPPER_EDGE':[(1290,200),(1247,243),(1330,287),(1231,326),(1304,361)],
'EAST_LOWER_EDGE':[(1307,679),(1257,720),(1327,755),(1183,814),(1108,830),(1022,857),(1284,857),(1230,919),(1086,955)],
'SOUTH_EAST_OUTSIDE':[(1073,1000),(1163,1014),(1305,997),(984,984)],
}
ROAD_PROTECTED=[ # trunk exclusion rectangles only (x0,y0,x1,y1)
 (485,0,765,360), # central north approach
 (0,385,145,595), # west road entrance
 (1115,480,1280,665), # east road entrance
 (410,655,905,928), # southern road continuation
 (183,356,390,444), # west cottage door/footprint safety
 (955,356,1134,451), # east cottage door/footprint safety
]

def sha(b):return hashlib.sha256(b).hexdigest()
def png(z,file):return Image.open(io.BytesIO(z.read(file))).convert('RGBA')
def safe_anchor(x,y,objects):
    # Root collisions must not intersect protected navigation areas.
    root=(x-11,y-12,x+11,y)
    for x0,y0,x1,y1 in ROAD_PROTECTED:
        if max(root[0],x0)<min(root[2],x1) and max(root[1],y0)<min(root[3],y1):return False
    for o in objects:
        if o['semantic']!='tree':continue
        fx,fy=o['foot']
        if abs(fx-x)<19 and abs(fy-y)<17:return False
    return True

def build(inzip,outzip,preview):
    original=Path(inzip).read_bytes()
    assert sha(original)==BASE_SHA,'A34 baseline input ZIP SHA differs from sealed delivery'
    with zipfile.ZipFile(io.BytesIO(original)) as z:
        assert z.testzip() is None,'A34 CRC failure'
        files={k:z.read(k) for k in z.namelist()}
    d=json.loads(files[MANIFEST_BASE]); scene=files[SCENE_BASE].decode()
    assert len(d['objects'])==146 and len([o for o in d['objects'] if o['semantic']=='tree'])==134
    assert d['ground']['sha256']==sha(files['private_assets/ground_only.png'])
    assert scene.count('[node name="obj_')==146
    tree_assets=[(k,a) for k,a in d['assets'].items() if a.get('semantic')=='tree' and a.get('size',[0,0])[1]>=72]
    tree_assets.sort(key=lambda p:p[0]); assert len(tree_assets)>=15
    rng=random.Random(35011115)
    planned=[(group,x,y) for group,anchors in GROUPS.items() for x,y in anchors]
    new_objects=[]
    usage=collections.Counter(o['asset_id'] for o in d['objects'] if o['semantic']=='tree')
    last_by_group={}
    for group,x,y in planned:
        if not safe_anchor(x,y,d['objects']+new_objects):continue
        # Prefer underused species while reducing same-neighbor repeats.
        choices=[(a_id,a) for a_id,a in tree_assets if a_id!=last_by_group.get(group)]
        choices.sort(key=lambda v:(usage[v[0]],rng.random()))
        asset_id,asset=choices[0]
        usage[asset_id]+=1;last_by_group[group]=asset_id
        w,h=asset['size'];id=f"a35_grove_{len(new_objects)+1:03d}_{asset_id}"
        o={'id':id,'asset_id':asset_id,'semantic':'tree','x':round(x-w/2), 'y':y-h+1,'w':w,'h':h,'foot':[x,y],'source_sha256':asset['sha256'],'frame_edge_allowed':True,'root_collision':True,'grove_group':group,'added_in':'A35_R1'}
        new_objects.append(o)
    assert len(new_objects)>=40, f'too few safe trees: {len(new_objects)}'
    original_scene=scene
    # Keep all old PAR nodes, resource links and their positions byte-exact.
    scene=scene.replace('res://scripts/a34_r4_world.gd','res://scripts/a35_r1_world.gd',1)
    scene=scene.replace('[node name="FS_A34_R4_HousePair" type="Node2D"]','[node name="FS_A35_R1_ForestGroves" type="Node2D"]',1)
    blocks=[]
    for o in new_objects:
        a=d['assets'][o['asset_id']]
        block=f'''\n[node name="{o['id']}" type="Node2D" parent="YSort"]
position = Vector2({o['foot'][0]}, {o['foot'][1]})
script = ExtResource("2_object")
source_file = "res://{a['file']}"
source_sha256 = "{a['sha256']}"
source_semantic = "tree"
source_object_id = "{o['id']}"
footprint_width_px = 22.0
footprint_height_px = 12.0
[node name="Sprite" type="Sprite2D" parent="YSort/{o['id']}"]
centered = false
[node name="Body" type="StaticBody2D" parent="YSort/{o['id']}"]
[node name="Collision" type="CollisionShape2D" parent="YSort/{o['id']}/Body"]
'''
        blocks.append(block)
    scene+='\n'+''.join(blocks)
    assert scene.count('[node name="obj_')==146
    assert scene.count('[node name="a35_grove_')==len(new_objects)
    out=dict(d)
    out.update({'schema':'fs-a35-r1-independent-forest-groves/v1','status':'ENGINE_CANDIDATE_ART_HOLD','origin_scene':SCENE_BASE,'base_sha256':sha(files[SCENE_BASE]),'art_gate':'HOLD_NATIVE_1X_REVIEW','a35_gate':{'stage':'R1','grove_groups':len(GROUPS),'tree_new':len(new_objects),'tree_total':134+len(new_objects),'owners_total':146+len(new_objects),'native':'NOT_RUN_AT_BUILD','source_reuse_only':True,'protected_road_rectangles':ROAD_PROTECTED,'immutable_a34_scene_sha256':sha(files[SCENE_BASE])}})
    out['objects']=d['objects']+new_objects
    world=f'''@tool
extends Node2D
## A35 R1: A34 complete source, additive groves. Original 146 owners preserved.
const GROUND_FILE := "res://private_assets/ground_only.png"
const GROUND_SHA := "3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000"
const OBJECTS_EXPECTED := {len(out['objects'])}
@onready var ground_sprite: Sprite2D = $FullGround
@onready var owner_layer: Node2D = $YSort
@onready var grid: Node2D = $EditorGrid
func _ready() -> void:
    ground_sprite.centered = false
    ground_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    if FileAccess.file_exists(GROUND_FILE):
        if FileAccess.get_sha256(GROUND_FILE) != GROUND_SHA:
            push_error("A35 sealed Ground SHA mismatch")
            if not Engine.is_editor_hint():get_tree().quit(3)
            return
        ground_sprite.texture = load(GROUND_FILE)
    elif not Engine.is_editor_hint():
        push_error("A35 private Ground missing")
        get_tree().quit(3)
        return
    if Engine.is_editor_hint():return
    if owner_layer.get_child_count()-1 != OBJECTS_EXPECTED:
        push_error("A35 independent PAR owner count mismatch")
        get_tree().quit(4)
        return
    print("FS A35 R1 GODOT forest groves: "+str(OBJECTS_EXPECTED)+" independent PAR, "+str({len(new_objects)})+" appended trees, original Ground SHA preserved")
func _unhandled_key_input(event: InputEvent) -> void:
    if Engine.is_editor_hint():return
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_G:
        grid.visible = not grid.visible
        queue_redraw()
func _draw() -> void:
    if not Engine.is_editor_hint() and grid.visible:
        for x in range(0,1281,32):draw_line(Vector2(x,0),Vector2(x,928),Color(1,1,1,0.18))
        for y in range(0,929,32):draw_line(Vector2(0,y),Vector2(1280,y),Color(1,1,1,0.18))
'''
    # Update project main scene only in *candidate*, sealed A34 scene still available.
    pg=files['project.godot'].decode()
    pg=pg.replace('A34 R4 two independent houses','A35 R1 independent forest groves').replace('res://scenes/a34_r4_house_pair_scene.tscn','res://'+SCENE_NEW)
    assert SCENE_NEW in pg
    files['project.godot']=pg.encode()
    files[SCENE_NEW]=scene.encode()
    files[WORLD_NEW]=world.encode()
    files[MANIFEST_NEW]=(json.dumps(out,ensure_ascii=False,indent=2)+'\n').encode()
    # Source audit summaries for Godot test/CI (non-private facts only)
    report={'schema':out['schema'],'source_archive_sha256':BASE_SHA,'scene_base_sha256':sha(files[SCENE_BASE]),'ground_sha256':out['ground']['sha256'],'old_objects':146,'added':len(new_objects),'total':len(out['objects']),'groves':collections.Counter(o['grove_group'] for o in new_objects),'assets_used':len(set(o['asset_id'] for o in new_objects)),'status':'SOURCE_PASS_NATIVE_NOT_RUN_ART_HOLD'}
    files['qa_a35/A35_R1_SOURCE_QA.json']=(json.dumps(report,indent=2)+'\n').encode()
    # Create a scene preview which is NOT passed off as a native Godot capture.
    def image_from_manifest(objs):
        canvas=png_bytes(files['private_assets/ground_only.png'])
        canvas=canvas.crop((0,0,1280,928))
        for o in sorted(objs,key=lambda v:(v['foot'][1],v['id'])):
            a=d['assets'][o['asset_id']]
            im=png_bytes(files[a['file']]);x=round(o['foot'][0]-im.width/2);y=round(o['foot'][1]-im.height+1)
            canvas.alpha_composite(im,(x,y))
        return canvas.convert('RGB')
    def png_bytes(buf):return Image.open(io.BytesIO(buf)).convert('RGBA')
    old_img=image_from_manifest(d['objects']);new_img=image_from_manifest(out['objects'])
    old_img.save('/mnt/data/A35_R1_BASELINE_SOFTWARE_PREVIEW.png')
    new_img.save(preview)
    # Difference can ONLY occur in the union of the new tree RGBA bounding boxes
    # for software compositing; native ROI checked independently in Godot.
    import numpy as np
    diff=np.any(np.array(old_img)!=np.array(new_img),axis=2)
    mask=np.zeros((928,1280),dtype=bool)
    for o in new_objects:
        x,y,w,h=o['x'],o['y'],o['w'],o['h']
        xl=max(0,x);yt=max(0,y);xr=min(1280,x+w+2);yb=min(928,y+h+2)
        if xl<xr and yt<yb:mask[yt:yb,xl:xr]=True
    outside=int(np.count_nonzero(diff & ~mask))
    changed=int(np.count_nonzero(diff))
    assert changed>2000 and outside==0,(changed,outside)
    report.update({'software_preview_changed_rgb_pixels':changed,'software_preview_outside_new_tree_rois':outside})
    files['qa_a35/A35_R1_SOURCE_QA.json']=(json.dumps(report,indent=2)+'\n').encode()
    with zipfile.ZipFile(outzip,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as zp:
        for n in sorted(files):zp.writestr(n,files[n])
    with zipfile.ZipFile(outzip) as check:
        assert check.testzip() is None
        assert check.read(SCENE_BASE)==files[SCENE_BASE]
        assert check.read('scenes/a33_groundfirst_lantern_scene.tscn')==files['scenes/a33_groundfirst_lantern_scene.tscn']
        assert sha(check.read('private_assets/ground_only.png'))==out['ground']['sha256']
    print(json.dumps({'a35_zip':str(outzip),'zip_size':Path(outzip).stat().st_size,'zip_sha256':sha(Path(outzip).read_bytes()),**report},ensure_ascii=False,indent=2))
    Path('/mnt/data/A35_R1_BUILD_REPORT.json').write_text(json.dumps({'a35_zip':str(outzip),'zip_sha256':sha(Path(outzip).read_bytes()),'zip_size':Path(outzip).stat().st_size,**report},indent=2),encoding='utf-8')
    return out

if __name__=='__main__':
    ap=argparse.ArgumentParser();ap.add_argument('input');ap.add_argument('output');ap.add_argument('--preview',default='/mnt/data/A35_R1_NEW_SOFTWARE_PREVIEW.png'); args=ap.parse_args()
    build(args.input,args.output,args.preview)
