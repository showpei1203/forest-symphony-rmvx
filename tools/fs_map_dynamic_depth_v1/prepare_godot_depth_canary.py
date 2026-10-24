# -*- coding: utf-8 -*-
from pathlib import Path
import json,shutil
R=Path(__file__).resolve().parent
S=R.parent/"FS_ElfVillage_RichPilot_20261023/godot_test"
T=R/"godot_depth_probe"
assert S.is_dir()
assert not T.exists()
shutil.copytree(S,T,ignore=shutil.ignore_patterns(".godot","*.import","captures"))
(T/"GPU_PROBES").mkdir()
audit=json.loads((R/"DEPTH_PROBE_RESULT.json").read_text(encoding="utf8"))
assert len(audit["probes"])==4
(T/"probe_positions.json").write_text(json.dumps([p["actor"] for p in audit["probes"]],ensure_ascii=False),encoding="utf8")
gd=r'''extends Node
const POS_PATH := "res://probe_positions.json"
var stage: SubViewport
var player: Sprite2D
func _ready() -> void:
    var source = JSON.parse_string(FileAccess.get_file_as_string("res://scene_manifest.json"))
    var points = JSON.parse_string(FileAccess.get_file_as_string(POS_PATH))
    if source == null or points == null or points.size() != 4:
        push_error("Bad native probe input")
        get_tree().quit(2)
        return
    stage = SubViewport.new()
    stage.size = Vector2i(864,640)
    stage.disable_3d = true
    stage.transparent_bg = false
    stage.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    add_child(stage)
    var world := Node2D.new()
    stage.add_child(world)
    var ground := Sprite2D.new()
    ground.texture = load("res://FS_ELF_RICH_Ground.png")
    ground.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    ground.centered = false
    ground.z_index=-1000
    world.add_child(ground)
    for ob in source["instances"]:
        var spr := Sprite2D.new()
        spr.texture = load("res://sprites/"+str(ob["asset_id"])+".png")
        if spr.texture == null:
            push_error("Missing sprite "+str(ob["asset_id"]))
            get_tree().quit(3)
            return
        spr.centered=false
        spr.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
        spr.position=Vector2(float(ob["x"]),float(ob["y"]))
        spr.z_index=int(ob["draw_order"])
        world.add_child(spr)
    player = Sprite2D.new()
    player.texture = load("res://actor.png")
    player.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    player.centered=false
    world.add_child(player)
    for i in range(points.size()):
        var pt=points[i]
        player.position=Vector2(float(pt[0])-10.0,float(pt[1])-28.0)
        player.z_index=int(pt[1])
        await RenderingServer.frame_post_draw
        await RenderingServer.frame_post_draw
        var png:Image=stage.get_texture().get_image()
        if png.get_size()!=Vector2i(864,640):
            push_error("Wrong GPU canvas size")
            get_tree().quit(4)
            return
        var rc=png.save_png("res://GPU_PROBES/NATIVE_ZSORT_"+str(i)+".png")
        if rc!=OK:
            push_error("GPU save failed")
            get_tree().quit(5)
            return
        print("FS_DEPTH_GPU_PROBE ",i)
    print("FS_DYNAMIC_SOURCE_DEPTH_NATIVE_GPU_FOUR_PROBES_DONE")
    get_tree().quit(0)
'''
(T/"depth_canary.gd").write_text(gd,encoding="utf8")
(T/"depth_canary.tscn").write_text('[gd_scene load_steps=2 format=3]\n[ext_resource type="Script" path="res://depth_canary.gd" id="1"]\n[node name="DepthProbe" type="Node"]\nscript = ExtResource("1")\n',encoding="utf8")
print("PREPARED_FOUR_REAL_GPU_SAMPLES",T,flush=True)
