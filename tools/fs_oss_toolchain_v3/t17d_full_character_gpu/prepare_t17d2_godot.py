# -*- coding: utf-8 -*-
"""Prepare isolated Godot 4.7.2 LPC GPU scene, do not modify sealed games."""
from pathlib import Path
import shutil,hashlib
ROOT=Path(__file__).resolve().parent
project=ROOT/"godot"/"LPC128_24frame"
asset=project/"assets";asset.mkdir(parents=True,exist_ok=True)
(project/"captures").mkdir(exist_ok=True)
image=ROOT/"outputs"/"T17D1_ARMING_SWORD_HEAD_HAIR_128.png"
assert image.is_file()
shutil.copyfile(image,asset/image.name)
(project/"project.godot").write_text('''config_version=5
[application]
config/name="FS_T17D2_LPC_128_24"
run/main_scene="res://Main.tscn"
[display]
window/size/viewport_width=160
window/size/viewport_height=160
window/size/window_width_override=160
window/size/window_height_override=160
[rendering]
renderer/rendering_method="gl_compatibility"
renderer/rendering_method.mobile="gl_compatibility"
textures/default_filters/use_nearest_mipmap_filter=false
''',encoding="utf-8")
(project/"Main.tscn").write_text('''[gd_scene load_steps=2 format=3]
[ext_resource type="Script" path="res://main.gd" id="1_lpc"]
[node name="LPC_128_GPU_Test" type="Node2D"]
script = ExtResource("1_lpc")
''',encoding="utf-8")
(project/"main.gd").write_text(r'''extends Node2D
var sprite: Sprite2D
var texture_sheet: Texture2D
func _ready() -> void:
    sprite = Sprite2D.new()
    sprite.centered = false
    sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    sprite.position = Vector2(16.0, 16.0)
    add_child(sprite)
    texture_sheet = load("res://assets/T17D1_ARMING_SWORD_HEAD_HAIR_128.png")
    if texture_sheet == null:
        push_error("T17D2 ERROR source image missing")
        get_tree().quit(3)
        return
    await render_all()
func render_all() -> void:
    for row in range(4):
        for frame in range(6):
            var piece: AtlasTexture = AtlasTexture.new()
            piece.atlas = texture_sheet
            piece.region = Rect2(frame*128, row*128, 128, 128)
            piece.filter_clip = true
            sprite.texture = piece
            await RenderingServer.frame_post_draw
            var img: Image = get_viewport().get_texture().get_image()
            if img.get_width() != 160 or img.get_height() != 160:
                push_error("T17D2 viewport mismatch")
                get_tree().quit(4)
                return
            var path: String = "res://captures/T17D2_%d_%d.png" % [row, frame]
            if img.save_png(path) != OK:
                push_error("T17D2 save screenshot failed")
                get_tree().quit(5)
                return
            print("T17D2_CAPTURE_%d_%d" % [row, frame])
    print("T17D2_NATIVE_GPU_24_CAPTURES_PASS")
    get_tree().quit(0)
''',encoding="utf-8")
SEAL=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\N5_RUNTIME_CLONE\Data\Scripts.rvdata")
assert hashlib.sha256(SEAL.read_bytes()).hexdigest()=="3271f5653a7f53cb55c0762d3b047e2300fbb6d6547257bef1fb2328be2b3ea9"
print("T17D2_PREPARED, project",project)
