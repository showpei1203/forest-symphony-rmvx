#!/usr/bin/env python3
"""R16: actual editable full 1280x928 Godot compositor, with image-locked generated
SAM2 -> constrained GrabCut selected masks, retaining original R12 visual master unchanged.
This does NOT declare occlusion semantic pass.
"""
from pathlib import Path
from PIL import Image
import json,hashlib,shutil
R=Path(__file__).resolve().parent;D=R/"R16_MODEL_TOOL_EVAL_20261028"
G=D/"godot_selected3";A=G/"assets";A.mkdir(parents=True,exist_ok=True)
SRC=R/"R12_NEW_ELF_VILLAGE_001"/"MASTER_NEW_ELF_VILLAGE_001_R12_CANDIDATE.png"
assert hashlib.sha256(SRC.read_bytes()).hexdigest()=="eda8fa28b537d9a96ee839f8c5c667c466bd55102731d41a7a9e560362854c80"
shutil.copy2(SRC,A/"R12_ORIGINAL_MASTER.png")
FS=R/"R14_GODOT_LAYER_AUTHORING_20261028"/"godot_project"/"assets"/"actor32.png"
shutil.copy2(FS,A/"FS_ACTOR32.png")
prior=json.loads((R/"R15_MULTISCALE_MASK_RESEARCH_20261028"/"R15_ROI_SAM2_PILOT_GATE.json").read_text(encoding="utf8"))
selected=json.loads((D/"R16_GRABCUT_SAM2_GATE.json").read_text(encoding="utf8"))
rows={x["id"]:x for x in selected["cases"]}
items=[];summary=[]
for p in prior["results"]:
 name=p["id"];state=rows[name]
 src=D/(name+"_R16_SELECTED_SOURCE_RGBA.png")
 im=Image.open(src).convert("RGBA")
 box=im.getchannel("A").getbbox();assert box
 cropped=A/(name+"_CROP.png");im.crop(box).save(cropped)
 summary.append({"id":name,"roi_bbox":list(box),"old_area":state["sam2_area"],
 "r16_area":state["grabcut_area"],"chosen":state["exported_choice"],
 "mask_source":"R12_Master","art_human_approved":False,"foot":p["foot"]})
 items.append([name,box,p["foot"]])
G.joinpath("project.godot").write_text("""config_version=5

[application]
config/name="FS R16 SAM2 GrabCut Refined Art First"
run/main_scene="res://ArtFirstVillage.tscn"

[display]
window/size/viewport_width=1280
window/size/viewport_height=928
window/stretch/mode="canvas_items"

[rendering]
renderer/rendering_method="gl_compatibility"
renderer/rendering_method.mobile="gl_compatibility"
textures/default_filters/use_nearest_mipmap_filter=false
""",encoding="utf8")
prior_g=R/"R15_MULTISCALE_MASK_RESEARCH_20261028"/"godot_art_first"
for name in ("ArtFirstVillage.gd","export.gd"):
 shutil.copy2(prior_g/name,G/name)
part=['[gd_scene load_steps=7 format=3]','',
 '[ext_resource type="Script" path="res://ArtFirstVillage.gd" id="1"]',
 '[ext_resource type="Texture2D" path="res://assets/R12_ORIGINAL_MASTER.png" id="2"]',
 '[ext_resource type="Texture2D" path="res://assets/FS_ACTOR32.png" id="3"]']
for i,(name,b,foot) in enumerate(items,4):
 part.append(f'[ext_resource type="Texture2D" path="res://assets/{name}_CROP.png" id="{i}"]')
part+=['','[node name="ArtFirstVillage" type="Node2D"]','script = ExtResource("1")','',
'[node name="MASTER" type="Sprite2D" parent="."]','texture = ExtResource("2")',
'centered = false','texture_filter = 1','z_index = 0','',
'[node name="PAR" type="Node2D" parent="."]','',
'[node name="ACTOR" type="Sprite2D" parent="."]',
'position = Vector2(290, 436)','texture = ExtResource("3")',
'centered = false','texture_filter = 1','z_index = 448','']
for i,(name,b,foot) in enumerate(items,4):
 part+=['[node name="%s" type="Sprite2D" parent="PAR"]'%name,
 'texture = ExtResource("%d")'%i,
 'position = Vector2(%d, %d)'%(b[0],b[1]),
 'texture_filter = 1','centered = false','z_index = %d'%foot[1],'']
(G/"ArtFirstVillage.tscn").write_text("\n".join(part),encoding="utf8")
(D/"R16_GODOT_SOURCE_MASK_MANIFEST.json").write_text(json.dumps({
 "status":"R16_SELECTED3_EDTABLE_GODOT_SCENE_READY",
 "master_SHA256":hashlib.sha256(SRC.read_bytes()).hexdigest(),
 "no_tile_nodes":True,"candidate_masks":summary,
 "human_visual_ART_gate":"HOLD"},ensure_ascii=False,indent=2),encoding="utf8")
print("R16_GODOT_SCENE_STAGED",json.dumps({x["id"]:x["chosen"] for x in summary}),flush=True)