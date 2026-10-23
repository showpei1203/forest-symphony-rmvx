from pathlib import Path
from shutil import copy2
import json
root=Path(r"E:\GameAssetToolLab_20261023\FS_ForestSplit_v3_2")
target=root/"godot_test";b=root/"build"
target.mkdir(exist_ok=True)
for name in ("FS_FOREST_V32_Ground.png","FS_FOREST_V32_Par_BASE.png","TEST_ONLY_ACTOR.png"):
    copy2(b/name,target/name)
copy2(root/"scene_manifest.json",target/"scene_manifest.json")
(target/"semantic_masks").mkdir(exist_ok=True)
manifest=json.loads((root/"scene_manifest.json").read_text(encoding="utf8"))
for o in manifest["instances"]:
    if o["instance_id"].startswith("tree_"):
        name=o["instance_id"]+"_occlusion_rgba.png"
        copy2(b/"semantic_masks"/name,target/"semantic_masks"/name)
(target/"project.godot").write_text('config_version=5\n\n[application]\nconfig/name="FS v3.2 Ground PAR Test ONLY"\nrun/main_scene="res://main.tscn"\n\n[display]\nwindow/size/viewport_width=544\nwindow/size/viewport_height=416\nwindow/stretch/mode="canvas_items"\n\n[rendering]\nrenderer/rendering_method="gl_compatibility"\nrenderer/rendering_method.mobile="gl_compatibility"\ntextures/default_filters/use_nearest_mipmap_filter=false\n',encoding="utf-8")
(target/"main.tscn").write_text('[gd_scene load_steps=2 format=3]\n\n[ext_resource type="Script" path="res://main.gd" id="1"]\n\n[node name="FSForestSplitBenchmark" type="Node2D"]\nscript = ExtResource("1")\n',encoding="utf-8")
print("GODOT_TEST_BUILD_FILES",len(list(target.rglob("*"))))
