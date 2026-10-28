#!/usr/bin/env python3
"""R15 high-fidelity Master FIRST Godot editorial scene.
No tile splicing at all; source full 1280x928 art is immutable.
Precise (but still artist-review-pending) object masks only as independent editor candidates.
"""
from pathlib import Path
from PIL import Image
import json,shutil,hashlib
R=Path(__file__).resolve().parent
D=R/"R15_MULTISCALE_MASK_RESEARCH_20261028"
G=D/"godot_art_first";AS=G/"assets";AS.mkdir(parents=True,exist_ok=True)
original=R/"R12_NEW_ELF_VILLAGE_001"/"MASTER_NEW_ELF_VILLAGE_001_R12_CANDIDATE.png"
manifest=json.loads((D/"R15_ROI_SAM2_PILOT_GATE.json").read_text(encoding="utf8"))
assert len(manifest["results"])==3
shutil.copy2(original,AS/"R12_ORIGINAL_MASTER.png")
actor=R/"R14_GODOT_LAYER_AUTHORING_20261028"/"godot_project"/"assets"/"actor32.png"
assert actor.is_file()
shutil.copy2(actor,AS/"FS_ACTOR32.png")
views=[]
for row in manifest["results"]:
 inp=D/(row["id"]+"_SAM2_EXACT_RGBA.png")
 im=Image.open(inp).convert("RGBA")
 bbox=im.getchannel("A").getbbox();assert bbox
 cropped=im.crop(bbox)
 target=AS/(row["id"]+"_CROP.png");cropped.save(target)
 views.append({"name":row["id"],"basename":target.name,
 "bbox":list(bbox),"world_foot_y":row["foot"][1],
 "candidate_prompt_gate":row["prompt_consistency_pass"],
 "source_image_RGB_provenance":"original R12 Master, true coordinates",
 "art_correction_review_required":True})
meta={"status":"R15_ART_FIRST_GODOT_SCENE_3_MASKS_CANDIDATE",
 "full_original_R12_Master_px":[1280,928],
 "no_tile_nodes":True,
 "original_full_Master_source_exact":True,
 "candidate_masks":views,
 "user_final_art_gate":"HOLD",
 "SAM3_or_Qwen_layered":"NOT_RUN",
 "editor":"Godot 4.7.2"}
(D/"R15_ART_FIRST_GODOT_MANIFEST.json").write_text(json.dumps(meta,ensure_ascii=False,indent=2),encoding="utf8")
(G/"project.godot").write_text('''config_version=5

[application]
config/name="FS R15 Art First Exact Master Candidate Masks"
run/main_scene="res://ArtFirstVillage.tscn"

[display]
window/size/viewport_width=1280
window/size/viewport_height=928
window/stretch/mode="canvas_items"

[rendering]
renderer/rendering_method="gl_compatibility"
renderer/rendering_method.mobile="gl_compatibility"
textures/default_filters/use_nearest_mipmap_filter=false
''',encoding="utf8")
items=['[gd_scene load_steps=7 format=3]','',
 '[ext_resource type="Script" path="res://ArtFirstVillage.gd" id="1"]',
 '[ext_resource type="Texture2D" path="res://assets/R12_ORIGINAL_MASTER.png" id="2"]',
 '[ext_resource type="Texture2D" path="res://assets/FS_ACTOR32.png" id="3"]']
for k,v in enumerate(views,4):items.append(f'[ext_resource type="Texture2D" path="res://assets/{v["basename"]}" id="{k}"]')
items+=['','[node name="ArtFirstVillage" type="Node2D"]','script = ExtResource("1")','',
'[node name="MASTER" type="Sprite2D" parent="."]',
'texture = ExtResource("2")','centered = false','texture_filter = 1','z_index = 0','',
'[node name="PAR" type="Node2D" parent="."]','',
'[node name="ACTOR" type="Sprite2D" parent="."]',
'position = Vector2(290, 436)',
'texture = ExtResource("3")',
'centered = false','texture_filter = 1','z_index = 448','']
for i,v in enumerate(views,4):
 x0,y0,x1,y1=v["bbox"]
 items+=['[node name="%s" type="Sprite2D" parent="PAR"]'%v["name"],
  'texture = ExtResource("%d")'%i,
  'position = Vector2(%d, %d)'%(x0,y0),
  'texture_filter = 1',
  'centered = false',
  'z_index = %d'%v["world_foot_y"],'']
(G/"ArtFirstVillage.tscn").write_text("\n".join(items),encoding="utf8")
print("R15_GODOT_ART_FIRST_STAGED",json.dumps({"nodes":len(views),"full_png_sha256":hashlib.sha256(original.read_bytes()).hexdigest()},ensure_ascii=False),flush=True)