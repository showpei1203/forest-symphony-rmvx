from pathlib import Path
from shutil import copy2
import hashlib
r=Path(r"E:\GameAssetToolLab_20261023\ToolValidation_v3_20261024")
p=r/"godot"/"NormalLightB0"
(p/"captures").mkdir(exist_ok=True,parents=True)
for sprite in ("tree","rock"):
 sources={
 sprite+".png":r/"inputs"/(sprite+".png"),
 sprite+"_spritefusion_normal.png":r/"outputs"/"sprite_normals"/(sprite+"_n.png"),
 sprite+"_laigter_normal.png":r/"outputs"/"laigter"/(sprite+"_n.png"),
 }
 for name,src in sources.items():
  assert src.exists(),src
  dst=p/name
  copy2(src,dst)
main=p/"main.gd"
assert main.is_file(),"Native GPU comparison main.gd missing; do not fake a visual PASS"
(p/"project.godot").write_text('config_version=5\n\n[application]\nconfig/name="B0 Normal Cross Tool GPU Test"\nrun/main_scene="res://main.tscn"\n\n[rendering]\nrenderer/rendering_method="gl_compatibility"\nrenderer/rendering_method.mobile="gl_compatibility"\ntextures/default_filters/use_nearest_mipmap_filter=false\n',encoding="utf8")
(p/"main.tscn").write_text('[gd_scene load_steps=2 format=3]\n\n[ext_resource type="Script" path="res://main.gd" id="1"]\n\n[node name="NormalCrossB0" type="Node"]\nscript = ExtResource("1")\n',encoding="utf8")
print("T13_CROSS_TOOL_GPU_PROJECT_READY",str(p),"assets",6,flush=True)
