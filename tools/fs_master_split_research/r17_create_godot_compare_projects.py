#!/usr/bin/env python3
"""R17 Godot editable scene pair B and C, SAME object assets and actor.
Full art comes from original R12 crop for B, inpainted candidate plate for C.
Original PNG and K4 never modified. Godot exports actual textures / front-back actor.
"""
from pathlib import Path
from PIL import Image
import hashlib,json,shutil
R=Path(__file__).resolve().parent;D=R/"R17_ELF_CORNER_TRIPLE_PATH_20261029"
B=D/"B_MASTER_FIRST";C=D/"C_OBJECT_FIRST_CONTINUOUS_PLATE"
manifest=json.loads((B/"OBJECT_REGISTER.json").read_text(encoding="utf8"))
tree=Image.open(B/"PAR_OBJECT_TREE_LEFT_MAJOR.png").convert("RGBA")
alpha=tree.getchannel("A")
# Search one 32x32 window with maximum overlap with the tree, choose no background where possible.
best=(-1,0,0)
for y in range(50,384,8):
 for x in range(10,510,8):
  n=sum(a>0 for a in alpha.crop((x,y,x+32,y+32)).getdata())
  if n>best[0]:best=(n,x,y)
print("R17_ACTOR_OCCLUDE_SPOT",best,flush=True)
manifest["actor_stand_top_left"]=[best[1],best[2]]
manifest["actor_tree_overlap_expected_alpha_px"]=best[0]
(B/"OBJECT_REGISTER.json").write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding="utf8")
ASSET=R/"R14_GODOT_LAYER_AUTHORING_20261028"/"godot_project"/"assets"/"actor32.png"
assert ASSET.exists()
godot_script=r'''extends Node2D
@onready var backdrop: Sprite2D = $PLATE
@onready var occluders: Node2D = $PAR
@onready var actor: Sprite2D = $ACTOR

func switch_mode(mode: String) -> void:
    backdrop.visible = mode != "PAR"
    occluders.visible = mode != "PLATE"
    actor.visible = mode == "ACTOR_BACK" or mode == "ACTOR_FRONT"
    if mode == "ACTOR_BACK":
        actor.z_index = 1
    elif mode == "ACTOR_FRONT":
        actor.z_index = 3000
'''
export_script=r'''extends SceneTree
const MODES := ["PLATE", "PAR", "FULL", "ACTOR_BACK", "ACTOR_FRONT"]
func _initialize() -> void:
    call_deferred("export_rendered")
func export_rendered() -> void:
    var port: SubViewport = SubViewport.new()
    port.size = Vector2i(544,416)
    port.transparent_bg = true
    port.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    root.add_child(port)
    var scene: Node2D = load("res://StreetCorner.tscn").instantiate()
    port.add_child(scene)
    var target: String = ProjectSettings.globalize_path("res://exported")
    DirAccess.make_dir_recursive_absolute(target)
    for mode in MODES:
        scene.switch_mode(mode)
        await process_frame
        await process_frame
        await create_timer(0.10).timeout
        var output: Image = port.get_texture().get_image()
        if output.is_empty() or output.get_size() != Vector2i(544,416):
            push_error("EMPTY_FRAME "+mode)
            quit(9)
            return
        var rc = output.save_png(target.path_join(mode+".png"))
        if rc != OK:
            push_error("EXPORT_ERR "+mode)
            quit(10)
            return
        print("R17_GODOT_TRUE_RENDER ",mode," 544x416")
    quit()
'''
for name,base,plate in [
 ("B_MASTER_FIRST",B,B/"GROUND_FULL.png"),
 ("C_OBJECT_FIRST_CONTINUOUS_PLATE",C,C/"CONTINUOUS_PLATE_PROPOSAL.png")]:
 gp=base/"godot_project";assets=gp/"assets";assets.mkdir(parents=True,exist_ok=True)
 shutil.copy2(plate,assets/"plate.png")
 shutil.copy2(ASSET,assets/"actor32.png")
 regs=[]
 for i,ob in enumerate(manifest["object_registry"],1):
  name_=ob["id"]
  full=Image.open(B/("PAR_OBJECT_"+name_+".png")).convert("RGBA")
  bbox=full.getchannel("A").getbbox();assert bbox,name_
  cropped=full.crop(bbox)
  cropped.save(assets/("obj_%02d.png"%i),optimize=True)
  z=int(ob["foot_benchmark"][1])
  regs.append({"id":name_,"asset":"obj_%02d.png"%i,"crop_xy":[bbox[0],bbox[1]],"world_y_foot":z,
   "origin":"B native R12 full Master original-coordinate alpha"})
 cfg='''config_version=5

[application]
config/name="FS R17 Benchmark / %s"
run/main_scene="res://StreetCorner.tscn"

[display]
window/size/viewport_width=544
window/size/viewport_height=416
window/stretch/mode="canvas_items"

[rendering]
renderer/rendering_method="gl_compatibility"
renderer/rendering_method.mobile="gl_compatibility"
textures/default_filters/use_nearest_mipmap_filter=false
'''%name
 (gp/"project.godot").write_text(cfg,encoding="utf8")
 (gp/"StreetCorner.gd").write_text(godot_script,encoding="utf8")
 (gp/"export.gd").write_text(export_script,encoding="utf8")
 listlines=['[gd_scene load_steps=%d format=3]'%(len(regs)+4),'',
 '[ext_resource type="Script" path="res://StreetCorner.gd" id="1"]',
 '[ext_resource type="Texture2D" path="res://assets/plate.png" id="2"]',
 '[ext_resource type="Texture2D" path="res://assets/actor32.png" id="3"]']
 for i,v in enumerate(regs,4):
  listlines.append('[ext_resource type="Texture2D" path="res://assets/%s" id="%d"]'%(v["asset"],i))
 listlines+=['','[node name="StreetCorner" type="Node2D"]','script = ExtResource("1")','',
 '[node name="PLATE" type="Sprite2D" parent="."]',
 'texture = ExtResource("2")','centered = false','texture_filter = 1','z_index = 0','',
 '[node name="PAR" type="Node2D" parent="."]','',
 '[node name="ACTOR" type="Sprite2D" parent="."]',
 'texture = ExtResource("3")',
 'position = Vector2(%d,%d)'%tuple(manifest["actor_stand_top_left"]),
 'texture_filter = 1','centered = false','z_index = 1','']
 for i,v in enumerate(regs,4):
  listlines+=['[node name="%s" type="Sprite2D" parent="PAR"]'%v["id"],
     'texture = ExtResource("%d")'%i,
     'position = Vector2(%d,%d)'%tuple(v["crop_xy"]),
     'texture_filter = 1','centered = false','z_index = %d'%v["world_y_foot"],'']
 (gp/"StreetCorner.tscn").write_text("\n".join(listlines),encoding="utf8")
 (base/"GODOT_SCENE_OBJECTS.json").write_text(json.dumps({"method":name,"node_count":len(regs),
 "items":regs,"actor_top_left":manifest["actor_stand_top_left"],
 "actor_tree_mask_overlap_px":best[0],"source_plate":str(plate.relative_to(R)),
 "art_gate":"HOLD"},ensure_ascii=False,indent=2),encoding="utf8")
 print("R17_GODOT_READY",name,len(regs),flush=True)