#!/usr/bin/env python3
"""R17 Stage2 NEW art authored exact-Master PAR11, physically run native Godot 4.7.2.
Individual per-object RGBA from source pixel alpha, cropped Sprite2D coordinates.
No claim accepted semantic masks; all masked objects are research candidates.
"""
from pathlib import Path
from PIL import Image
import json,hashlib,shutil
R=Path(__file__).resolve().parent;D=R/"R17_STAGE2_NEW_ART_20261029"
G=D/"godot_project";A=G/"assets";A.mkdir(parents=True,exist_ok=True)
MASTER=D/"MASTER_STAGE2_NEW_GENERATED.png"
m=Image.open(MASTER).convert("RGBA");assert m.size==(544,416)
shutil.copy2(MASTER,A/"MASTER.png")
ACTOR=R/"R14_GODOT_LAYER_AUTHORING_20261028"/"godot_project"/"assets"/"actor32.png"
shutil.copy2(ACTOR,A/"ACTOR.png")
r1=json.loads((D/"R17_STAGE2_NEW_ART_SAM2_GATE.json").read_text(encoding="utf8"))["candidate_objects"]
r2=json.loads((D/"R17_STAGE2_R2_11OBJECT_GATE.json").read_text(encoding="utf8"))["objects_new"]
arr=r1+r2;assert len(arr)==11
spec=[]
for i,o in enumerate(arr,1):
 name=o["id"]
 if name=="BRIDGE_RAILING":file=D/"R17_STAGE2_BRIDGE_RAILING_V2_SELECTED.png"
 else:file=D/("R17_STAGE2_"+name+"_PAR_CANDIDATE.png")
 img=Image.open(file).convert("RGBA")
 bbox=img.getchannel("A").getbbox()
 if not bbox:raise RuntimeError(name+" EMPTY")
 target=A/f"PAR_{i:02d}.png";img.crop(bbox).save(target)
 foot=o["foot"];spec.append({"id":name,"file":target.name,"bbox":list(bbox),
   "source":"SAM2.1 + GrabCut if selected, original new Master sourceRGB",
   "foot":foot,"category":o["category"],"z":int(foot[1]),
   "mask_user_approved":False})
# actor rear spot should overlap tree large PAR; pick full 32x32 interior if available
tree=Image.open(D/"R17_STAGE2_TREE_LARGE_EAST_PAR_CANDIDATE.png").getchannel("A")
best=(-1,0,0)
for y in range(160,298,4):
 for x in range(409,512,4):
  n=sum(v>0 for v in tree.crop((x,y,x+32,y+32)).getdata())
  if n>best[0]:best=(n,x,y)
actorXY=[best[1],best[2]]
(G/"project.godot").write_text('''config_version=5
[application]
config/name="FS R17 Stage2 NEW ART source locked masks 11"
run/main_scene="res://Stage2Village.tscn"
[display]
window/size/viewport_width=544
window/size/viewport_height=416
window/stretch/mode="canvas_items"
[rendering]
renderer/rendering_method="gl_compatibility"
renderer/rendering_method.mobile="gl_compatibility"
textures/default_filters/use_nearest_mipmap_filter=false
''',encoding="utf8")
(G/"Stage2Village.gd").write_text('''extends Node2D
@onready var layer_master: Sprite2D = $MASTER
@onready var layer_par: Node2D = $PAR
@onready var player: Sprite2D = $ACTOR
func export_mode(mode: String) -> void:
    layer_master.visible = mode != "PAR"
    layer_par.visible = mode != "MASTER"
    player.visible = mode.begins_with("ACTOR")
    if mode == "ACTOR_BACK":
        player.z_index = 1
    elif mode == "ACTOR_FRONT":
        player.z_index = 3000
''',encoding="utf8")
(G/"export.gd").write_text('''extends SceneTree
const MODES: Array[String] = ["MASTER", "PAR", "FULL", "ACTOR_BACK", "ACTOR_FRONT"]
func _initialize() -> void:
    call_deferred("render_modes")
func render_modes() -> void:
    var viewport: SubViewport = SubViewport.new()
    viewport.size = Vector2i(544, 416)
    viewport.transparent_bg = true
    viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    root.add_child(viewport)
    var scene: Node2D = load("res://Stage2Village.tscn").instantiate()
    viewport.add_child(scene)
    var export_dir: String = ProjectSettings.globalize_path("res://exported")
    DirAccess.make_dir_recursive_absolute(export_dir)
    for mode in MODES:
        scene.export_mode(mode)
        await process_frame
        await process_frame
        await create_timer(0.13).timeout
        var bitmap: Image = viewport.get_texture().get_image()
        if bitmap.is_empty() or bitmap.get_size() != Vector2i(544,416):
            push_error("Render missing: " + mode)
            quit(3)
            return
        var output: String = export_dir.path_join("R17_STAGE2_" + mode + ".png")
        var rc: Error = bitmap.save_png(output)
        if rc != OK:
            push_error("Save failed "+mode)
            quit(4)
            return
        print("R17_STAGE2_REAL_GODOT_FRAME "+mode+" 544x416")
    quit()
''',encoding="utf8")
nodes=['[gd_scene load_steps=%d format=3]'%(len(spec)+4),'',
'[ext_resource type="Script" path="res://Stage2Village.gd" id="1"]',
'[ext_resource type="Texture2D" path="res://assets/MASTER.png" id="2"]',
'[ext_resource type="Texture2D" path="res://assets/ACTOR.png" id="3"]']
for i,o in enumerate(spec,4):
 nodes.append('[ext_resource type="Texture2D" path="res://assets/%s" id="%d"]'%(o["file"],i))
nodes+=['','[node name="Stage2Village" type="Node2D"]','script = ExtResource("1")','',
'[node name="MASTER" type="Sprite2D" parent="."]',
'texture = ExtResource("2")','centered = false','texture_filter = 1','z_index = 0','',
'[node name="PAR" type="Node2D" parent="."]','',
'[node name="ACTOR" type="Sprite2D" parent="."]',
'texture = ExtResource("3")','centered = false','texture_filter = 1',
'position = Vector2(%d,%d)'%tuple(actorXY),'z_index = 1','']
for i,o in enumerate(spec,4):
 nodes+=['[node name="%s" type="Sprite2D" parent="PAR"]'%o["id"],
 'texture = ExtResource("%d")'%i,
 'centered = false','texture_filter = 1',
 'position = Vector2(%d,%d)'%(o["bbox"][0],o["bbox"][1]),
 'z_index = %d'%o["z"],'']
(G/"Stage2Village.tscn").write_text("\n".join(nodes),encoding="utf8")
data={"status":"R17_STAGE2_NEW_ART_11OBJECT_EDITABLE_GODOT_READY",
"objects":spec,"actor_reference_xy":actorXY,"actor_overlapping_tree_alpha_px":int(best[0]),
"scene":"godot_project/Stage2Village.tscn","master_SHA256":hashlib.sha256(MASTER.read_bytes()).hexdigest(),
"native_game_VX_executed":False,"art_gate":"HOLD"}
(D/"R17_STAGE2_GODOT_SCENE_MANIFEST.json").write_text(json.dumps(data,ensure_ascii=False,indent=2),encoding="utf8")
print("R17_STAGE2_GODOT_PREPARED",json.dumps({"objects":len(spec),"actor":actorXY,"overlap":int(best[0])}),flush=True)