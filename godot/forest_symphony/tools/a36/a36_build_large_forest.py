from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np, shutil,hashlib,json,random,math,os
from collections import Counter
S=Path(os.environ.get('FS_A36_BASE_PROJECT','/mnt/data/fs_godot_a35')); D=Path(os.environ.get('FS_A36_OUT_DIR','/mnt/data/fs_godot_a36'))
if D.exists(): shutil.rmtree(D)
shutil.copytree(S,D,ignore=shutil.ignore_patterns('.godot','qa_a29','qa_a30','qa_a31','qa_a32','qa_a33','qa_a34','qa_a35','*.log','*.uid','qa_*'))
for p in ['qa_a36','tools/a36']:(D/p).mkdir(parents=True,exist_ok=True)
world_w,world_h=2560,1856
source=Path(os.environ.get('FS_A36_GROUND_SOURCE','/mnt/data/a_highly_detailed_top_down_isometric_3_4_ground.png'))
p=D/'private_assets/a36_ground_original_1478x1064.png'
shutil.copy2(source,p)
orig=Image.open(p).convert('RGB')
assert orig.size==(1478,1064),orig.size
scaled=orig.resize((world_w,world_h),Image.Resampling.NEAREST)
groundfile=D/'private_assets/a36_ground_only_2560x1856.png'
scaled.save(groundfile,optimize=True)
pix=np.array(scaled)
def sha(fp):return hashlib.sha256(Path(fp).read_bytes()).hexdigest()
# Need source-independent full assets from A35; never crop a flattened world.
assets=[]
for name in ('a35_oak_summer_176x174.png','a35_oak_golden_176x174.png','a35_birch_blush_122x170.png','a35_birch_cream_122x170.png',
             'a34_elf_workshop_house_complete_288x282.png','a34_elf_residence_atelier_complete_252x252.png',
             'a33_ornate_lantern_complete_52x124.png','fsobj_well.png','fsobj_rock_cluster.png'):
 file=D/'private_assets/independent_par'/name
 assert file.exists(),file
 im=Image.open(file)
 assets.append(dict(name=name,w=im.width,h=im.height,sha=sha(file),file='res://private_assets/independent_par/'+name))
lookup={a['name']:a for a in assets}
# Probe a potential tree's Ground contact near foot; this rejects blue river, dirt routes and building lawns.
def green_frac(cx,cy,r=24):
 x1=max(0,int(cx-r));x2=min(world_w,int(cx+r));y1=max(0,int(cy-r));y2=min(world_h,int(cy+r))
 if x1>=x2 or y1>=y2:return 0.0
 q=pix[y1:y2:4,x1:x2:4,:].astype(np.int16)
 green=(q[:,:,1]>q[:,:,0]*0.90)&(q[:,:,1]>q[:,:,2]*1.12)&(q[:,:,1]>52)
 blue=(q[:,:,2]>q[:,:,0]*1.1)&(q[:,:,2]>q[:,:,1]*0.80)
 return float((green&~blue).mean())
# House plots are naturally rendered as broad compacted soil clearings in the ORIGINAL Ground image.
# Do not paint a house footprint into the original Ground; placement is independent world-XY.
house_plots=[(610,803,300),(1840,468,310),(2120,1315,290)]
def protected(x,y):
 for hx,hy,r in house_plots:
  if ((x-hx)/r)**2 + ((y-hy)/(r*.65))**2<1:return True
 # keep main path clear with green threshold anyway
 return False
random.seed(360058)
# zone probabilities: dense forest around scene edges, and several offset groves.
def importance(x,y):
 edge=min(x,world_w-x,y,world_h-y)
 e=max(0,1-edge/410)
 c=0.0
 for cx,cy,r in [(600,250,380),(2100,210,490),(2270,930,350),(400,1390,470),(2050,1720,440),(1370,1550,340),(1160,420,290)]:
  c=max(c,math.exp(-((x-cx)**2+(y-cy)**2)/(r*r)))
 return max(0.04,min(1.0,.13+0.83*e+0.76*c))
# Candidate points spanning entire contiguous world, never tiled/mirrored from A34.
points=[]
for k in range(4000):
 x=random.randrange(-30,world_w+30)
 y=random.randrange(80,world_h+40)
 if protected(x,y):continue
 if green_frac(x,y)<0.54:continue
 if random.random()>importance(x,y):continue
 if any((x-u)**2+(y-v)**2 < (58 if (i%6) else 76)**2 for i,(u,v) in enumerate(points)):
  continue
 points.append((x,y))
 if len(points)>=310:break
assert len(points)>=180,len(points)
# Add a few trees with full physical shape deliberately continuing past scene edge; source sprites remain complete.
# The game window simply clips the world rendering; this is legitimate forest-boundary foliage.
objects=[]
for i,(x,y) in enumerate(points):
 if i%6==0:asset=assets[2]
 elif i%13==0:asset=assets[3]
 elif i%3==0:asset=assets[1]
 else:asset=assets[0]
 objects.append(dict(id=f'a36_tree_{i+1:03d}',family=asset['name'],semantic='tree',foot=[x,y],width=asset['w'],height=asset['h'],footprint=[22 if asset['w']<150 else 32,12 if asset['w']<150 else 18],asset_sha256=asset['sha']))
# Houses independently previously generated, not cut from scene master.
for i,(assetname,x,y) in enumerate([('a34_elf_workshop_house_complete_288x282.png',590,780),('a34_elf_residence_atelier_complete_252x252.png',1810,460)]):
 a=lookup[assetname]
 objects.append(dict(id=f'a36_house_{i+1:02d}',family=assetname,semantic='house',foot=[x,y],width=a['w'],height=a['h'],footprint=[136 if i else 160,38],asset_sha256=a['sha']))
# Ornate lamps, complete alpha sprites; footpoint labels remain editable; avoid the river.
lamps=[(930,380),(1400,650),(1050,1040),(1780,1005),(1600,1420),(900,1520)]
for i,(x,y) in enumerate(lamps):
 a=lookup['a33_ornate_lantern_complete_52x124.png']
 objects.append(dict(id=f'a36_lamp_{i+1:02d}',family=a['name'],semantic='lamp',foot=[x,y],width=a['w'],height=a['h'],footprint=[14,13],asset_sha256=a['sha']))
# Meaningful accent props on natural shoulders, never change main Ground.
well=lookup['fsobj_well.png']
objects.append(dict(id='a36_well_01',family=well['name'],semantic='well',foot=[1250,1030],width=well['w'],height=well['h'],footprint=[29,22],asset_sha256=well['sha']))
rock=lookup['fsobj_rock_cluster.png']
for i,(x,y) in enumerate([(450,300),(1190,390),(1610,790),(2210,1050),(560,1150),(1870,1570),(1150,1700)]):
 objects.append(dict(id=f'a36_rock_{i+1:02d}',family=rock['name'],semantic='rock',foot=[x,y],width=rock['w'],height=rock['h'],footprint=[21,10],asset_sha256=rock['sha']))
# Editor scene uses current object script and distinct footpoint pivots with YSort.
scene=["[gd_scene load_steps=4 format=3]",'[ext_resource type="Script" path="res://scripts/a36_world.gd" id="1_world"]',
'[ext_resource type="Script" path="res://scripts/a32_par_instance.gd" id="2_object"]',
'[ext_resource type="Script" path="res://scripts/a36_player.gd" id="3_player"]',
'[sub_resource type="RectangleShape2D" id="actor_foot"]','size = Vector2(13, 9)',
'[node name="FS_A36_LargeForest_GroundFirst" type="Node2D"]','script = ExtResource("1_world")',
'[node name="FullGround" type="Sprite2D" parent="."]','centered = false','texture_filter = 1',
'[node name="ContactShadows" type="Sprite2D" parent="."]','centered = false','texture_filter = 1',
'[node name="YSort" type="Node2D" parent="."]','y_sort_enabled = true',
'[node name="Player" type="CharacterBody2D" parent="YSort"]','position = Vector2(1340, 1050)','script = ExtResource("3_player")',
'[node name="Sprite" type="Sprite2D" parent="YSort/Player"]','centered = false',
'[node name="BodyCollision" type="CollisionShape2D" parent="YSort/Player"]','shape = SubResource("actor_foot")','position = Vector2(0, -4)',
'[node name="Camera2D" type="Camera2D" parent="YSort/Player"]','zoom = Vector2(1.35, 1.35)','enabled = true',
'[node name="EditorGrid" type="Node2D" parent="."]','visible = false']
for o in objects:
 n=o['id'];a=lookup[o['family']];x,y=o['foot']
 scene += [f'[node name="{n}" type="Node2D" parent="YSort"]',f'position = Vector2({x}, {y})','script = ExtResource("2_object")',
 f'source_file = "{a["file"]}"',f'source_sha256 = "{a["sha"]}"',f'source_semantic = "{o["semantic"]}"',f'source_object_id = "{n}"',
 f'footprint_width_px = {o["footprint"][0]}.0',f'footprint_height_px = {o["footprint"][1]}.0',
 f'[node name="Sprite" type="Sprite2D" parent="YSort/{n}"]','centered = false',f'[node name="Body" type="StaticBody2D" parent="YSort/{n}"]',
 f'[node name="Collision" type="CollisionShape2D" parent="YSort/{n}/Body"]']
scene_path=D/'scenes/a36_large_verdant_forest_80x58.tscn'
scene_path.write_text('\n'.join(scene)+'\n',encoding='utf8')
# Draw each contact shadow separately on aligned RGBA, never on original Ground.
shadows=Image.new('RGBA',(world_w,world_h),(0,0,0,0));draw=ImageDraw.Draw(shadows,'RGBA')
for o in objects:
 if o['semantic'] not in ('tree','house','lamp') :continue
 x,y=o['foot'];fx,fy=o['footprint'];alpha=52 if o['semantic']=='tree' else 42
 draw.ellipse((x-fx*1.3,y-fy*.85,x+fx*1.3,y+fy*.75),fill=(18,38,16,alpha))
shadow_path=D/'private_assets/a36_contact_shadows_2560x1856.png';shadows.save(shadow_path,optimize=True)
# 32px river semantics CANDIDATES. Blue threshold and tile water fraction prevents assuming every decorative blue flower is water.
water=[]
for ty in range(world_h//32):
 for tx in range(world_w//32):
  tile=pix[ty*32:(ty+1)*32,tx*32:(tx+1)*32,:].astype(np.int16)
  b=tile[:,:,2];g=tile[:,:,1];r=tile[:,:,0]
  isblue=(b>r*1.2)&(b>g*.98)&(b>70)&(r<170)
  if float(isblue.mean())>0.40:water.append([tx,ty])
# Logical candidate overlay separate from art, not approved passability.
logic={'schema':'fs-a36-terrain-collision-candidate/v1','world_grid':[80,58],'tile_px':32,'status':'WATER_CANDIDATE_NOT_VALIDATED_NAVIGATION','river_blocked_cells':water,'river_cell_count':len(water),'ground_sha256':sha(groundfile)}
(D/'data/a36_terrain_semantic_candidates.json').write_text(json.dumps(logic,ensure_ascii=False,indent=2),encoding='utf8')
# Editor-readable world manifest.
manifest={'schema':'fs-a36-ground-first-large-continuous-world/v1','status':'REAL_GROUND_FIRST_NATIVE_PENDING_ART_HOLD',
 'scene_id':'FS_A36_LARGE_FOREST','world_px':[world_w,world_h],'logical_grid':[80,58], 'cell_px':32,
 'source_ground':{'file':p.name,'size':list(orig.size),'sha256':sha(p),'authoring':'FRESH_SINGLE_CONTINUOUS_IMAGE_GENERATION','generated_not_native_32px':True},
 'runtime_ground':{'file':groundfile.name,'size':[world_w,world_h],'sha256':sha(groundfile),'transform':'PIL.Image.resize NEAREST (1478x1064 to 2560x1856); nonuniform 0.7%-scale distortion, ART HOLD','source_is_not_a34':True},
 'shadow':{'file':shadow_path.name,'sha256':sha(shadow_path),'ownership':'separate source-only generated contact shade; source ground unchanged'},
 'objects':objects,'assets':{a['name']:a for a in assets},'object_count':len(objects),'counts':dict(Counter(o['semantic'] for o in objects)),
 'river_collision_status':'CANDIDATE_ONLY','events':'OUT_OF_SCOPE_OTHER_CONVERSATION','art_gate':'HOLD_NEEDS_NATIVE_1X_USER_REVIEW',
 'quality_contract':{'no_old_ground_tiling':True,'full_independent_par_sources':True,'world_render_native_required':True,'water_animation':'NOT_IMPLEMENTED','par_shadow_light_layers':['GROUND','CONTACT_SHADOW','PAR','LIGHT_NOT_IMPLEMENTED','ANIMATED_WATER_NOT_IMPLEMENTED']}}
mp=D/'data/a36_large_verdant_forest_manifest.json';mp.write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf8')
(D/'scripts/a36_world.gd').write_text('''@tool
extends Node2D
## A36 continuous Ground-first large forest, 80x58 at 32px. Events are NOT part of this art project.
const WORLD_SIZE := Vector2i(2560,1856)
const GROUND_FILE := "res://private_assets/a36_ground_only_2560x1856.png"
const SHADOW_FILE := "res://private_assets/a36_contact_shadows_2560x1856.png"
const GROUND_SHA := "'''+sha(groundfile)+'''"
const SHADOW_SHA := "'''+sha(shadow_path)+'''"
const EXPECTED_OBJECTS := '''+str(len(objects))+'''
@onready var ground: Sprite2D = $FullGround
@onready var contact_shadows: Sprite2D = $ContactShadows
@onready var owner_layer: Node2D = $YSort
@onready var grid: Node2D = $EditorGrid
func _ready() -> void:
    ground.centered = false
    ground.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    contact_shadows.centered = false
    contact_shadows.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    if FileAccess.file_exists(GROUND_FILE):
        if FileAccess.get_sha256(GROUND_FILE) != GROUND_SHA:
            push_error("A36 source Ground SHA mismatch"); return
        ground.texture = load(GROUND_FILE)
    elif not Engine.is_editor_hint():
        push_error("Owner-only A36 Ground missing: use the private project ZIP"); get_tree().quit(3); return
    if FileAccess.file_exists(SHADOW_FILE):
        if FileAccess.get_sha256(SHADOW_FILE) != SHADOW_SHA:
            push_error("A36 contact shadow SHA mismatch");return
        contact_shadows.texture = load(SHADOW_FILE)
    if Engine.is_editor_hint(): return
    if owner_layer.get_child_count() - 1 != EXPECTED_OBJECTS:
        push_error("A36 expected full independent object count mismatch");get_tree().quit(4);return
    print("FS A36 GODOT REAL GROUND-FIRST: 80x58 world; "+str(EXPECTED_OBJECTS)+" individually editable full-source PAR instances")
    print("ART HOLD; river candidate, not nav approved; no NPC/events in this art scene")
func _unhandled_key_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_G:
        grid.visible = not grid.visible
        queue_redraw()
func _draw() -> void:
    if grid.visible:
        for x in range(0, WORLD_SIZE.x+1, 32):
            draw_line(Vector2(x,0),Vector2(x,WORLD_SIZE.y),Color(1,1,1,.14))
        for y in range(0, WORLD_SIZE.y+1, 32):
            draw_line(Vector2(0,y),Vector2(WORLD_SIZE.x,y),Color(1,1,1,.14))
''',encoding='utf8')
(D/'scripts/a36_player.gd').write_text('''extends CharacterBody2D
## F0 original 45-degree battle actor is only scale/occlusion proxy, NOT approved four-way overworld.
@export var speed: float=115.0
const ACTOR_PATH := "res://private_assets/actor_f0.png"
const ACTOR_SHA := "a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba"
func _ready()->void:
    var visual: Sprite2D=$Sprite
    visual.centered=false
    visual.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
    if FileAccess.file_exists(ACTOR_PATH):
        if FileAccess.get_sha256(ACTOR_PATH)!=ACTOR_SHA:push_error("A36 actor F0 original mismatch");return
        visual.texture=load(ACTOR_PATH)
        visual.position=Vector2(-24,-47)
func _physics_process(_delta:float)->void:
    velocity=Input.get_vector("ui_left","ui_right","ui_up","ui_down") *speed
    move_and_slide()
    global_position.x=clampf(global_position.x,7,2553)
    global_position.y=clampf(global_position.y,7,1849)
''',encoding='utf8')
project=D/'project.godot';s=project.read_text();s=s.replace('run/main_scene="res://scenes/a35_independent_tree_family_scene.tscn"','run/main_scene="res://scenes/a36_large_verdant_forest_80x58.tscn"').replace('Godot-first A35 full independent house family','Godot-first A36 80x58 large continuous Ground-first forest');project.write_text(s)
print(json.dumps({'source_pixels':orig.size,'world_pixels':[world_w,world_h],'object_counts':manifest['counts'],'source_sha':sha(p),'ground_sha':sha(groundfile),'shadow_sha':sha(shadow_path),'water_candidate_cells':len(water),'assets':len(assets)},indent=2))
