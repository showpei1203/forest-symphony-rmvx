from pathlib import Path
from shutil import copy2
import json,hashlib
R=Path(r"E:\GameAssetToolLab_20261023\ToolValidation_v3_20261024")
project=R/"godot"/"AnimatedNormalsB0"
(project/"captures").mkdir(parents=True,exist_ok=True)
for src,dst in [(R/"inputs"/"tree_animation_6frames.png",project/"diffuse_atlas.png"),
 (R/"outputs"/"t14_per_frame"/"tree_6frame_normal_perframe.png",project/"normal_atlas.png")]:
 assert src.is_file(),src
 copy2(src,dst)
manifest=json.loads((R/"outputs"/"t14_per_frame"/"NORMAL_ANIMATION_MANIFEST.json").read_text(encoding="utf8"))
(project/"timing_manifest.json").write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding="utf8")
(project/"project.godot").write_text('config_version=5\n\n[application]\nconfig/name="T16 Six Frame Pixel Normal Animation"\nrun/main_scene="res://main.tscn"\n\n[rendering]\nrenderer/rendering_method="gl_compatibility"\nrenderer/rendering_method.mobile="gl_compatibility"\n',encoding="utf8")
(project/"main.tscn").write_text('[gd_scene load_steps=2 format=3]\n\n[ext_resource type="Script" path="res://main.gd" id="1"]\n\n[node name="T16Animation" type="Node"]\nscript = ExtResource("1")\n',encoding="utf8")
print("T16_PREPARED",project,"diffuse",hashlib.sha256((project/"diffuse_atlas.png").read_bytes()).hexdigest(),"normal",hashlib.sha256((project/"normal_atlas.png").read_bytes()).hexdigest())
