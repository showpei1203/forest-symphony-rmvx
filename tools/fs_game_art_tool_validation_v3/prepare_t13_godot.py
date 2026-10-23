from pathlib import Path
from shutil import copy2
r=Path(r"E:\GameAssetToolLab_20261023\ToolValidation_v3_20261024")
p=r/"godot"/"NormalAnimation6";p.mkdir(exist_ok=True,parents=True)
(p/"captures").mkdir(exist_ok=True)
copy2(r/"inputs"/"tree_animation_6frames.png",p/"diffuse_6.png")
copy2(r/"outputs"/"sprite_normals"/"tree_animation_6frames_n.png",p/"normal_6.png")
(p/"project.godot").write_text('config_version=5\n\n[application]\nconfig/name="FS_B0_SpriteNormal_6Frame_Light_Test"\nrun/main_scene="res://main.tscn"\n\n[rendering]\nrenderer/rendering_method="gl_compatibility"\nrenderer/rendering_method.mobile="gl_compatibility"\ntextures/default_filters/use_nearest_mipmap_filter=false\n',encoding="utf8")
(p/"main.tscn").write_text('[gd_scene load_steps=2 format=3]\n\n[ext_resource type="Script" path="res://main.gd" id="1"]\n\n[node name="B0Normal6" type="Node"]\nscript = ExtResource("1")\n',encoding="utf8")
print("T13_GODOT_SETUP",str(p),flush=True)
