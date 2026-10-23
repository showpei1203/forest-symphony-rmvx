from pathlib import Path
from shutil import copy2
r=Path(r"E:\GameAssetToolLab_20261023\ToolValidation_v3_20261024")
g=r/"godot"/"B0NormalCrossTool";g.mkdir(parents=True,exist_ok=True)
(g/"captures").mkdir(exist_ok=True)
src=r/"inputs"/"tree.png"
copy2(src,g/"tree.png")
copy2(r/"outputs"/"spritenormals"/"tree_n.png",g/"tree_cli_n.png")
copy2(r/"outputs"/"laigter"/"tree_n.png",g/"tree_laigter_n.png")
(g/"project.godot").write_text('config_version=5\n\n[application]\nconfig/name="FS_B0_CrossTool_Normal_GPU"\nrun/main_scene="res://main.tscn"\n\n[display]\nwindow/size/viewport_width=320\nwindow/size/viewport_height=180\n\n[rendering]\nrenderer/rendering_method="gl_compatibility"\nrenderer/rendering_method.mobile="gl_compatibility"\ntextures/default_filters/use_nearest_mipmap_filter=false\n',encoding="utf8")
(g/"main.tscn").write_text('[gd_scene load_steps=2 format=3]\n\n[ext_resource type="Script" path="res://main.gd" id="1"]\n\n[node name="B0NormalCrossTool" type="Node"]\nscript = ExtResource("1")\n',encoding="utf8")
print("T13_PROJECT_PREPARED",list(z.name for z in g.glob("*.png")))
