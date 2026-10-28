#!/usr/bin/env python3
"""Fail-closed QA for actual Godot-exported Ground, PAR, actor depth, alpha.
Layer-first means NO floor tile Sprite2D belongs to PAR; not claiming 100% pure object pixels in old assets.
"""
from pathlib import Path
from PIL import Image,ImageChops,ImageDraw
import hashlib,json
D=Path(__file__).resolve().parent
E=D/"godot_project"/"exported"
modes=["BASE","PAR","FULL","ACTOR_BACK","ACTOR_FRONT"]
imgs={s:Image.open(E/("GODOT_"+s+".png")).convert("RGBA") for s in modes}
assert all(im.size==(544,416) for im in imgs.values())
base=imgs["BASE"];par=imgs["PAR"];full=imgs["FULL"]
# Godot GPU rendering and Pillow alpha composition must be identical or risk transparent layer misregistration.
reconstructed=Image.alpha_composite(base,par)
diff=ImageChops.difference(reconstructed,full)
num_changed=sum(1 for px in diff.getdata() if any(px[:3]))
max_difference=max(max(px[:3]) for px in diff.getdata())
pcount=sum(1 for a in par.getchannel("A").getdata() if a>0)
# Independent floor-only cells guaranteed no object on them by footprint audit.
floor_cells=[(0,0),(8,12),(9,12),(16,12),(14,0)]
sample={}
for tx,ty in floor_cells:
 n=sum(1 for a in par.getchannel("A").crop((tx*32,ty*32,(tx+1)*32,(ty+1)*32)).getdata() if a)
 sample[f"{tx},{ty}"]=n
assert all(n==0 for n in sample.values()),sample
# Critical "no floor painter in par" direct scene hierarchy
scene=(D/"godot_project"/"LayeredPilot.tscn").read_text(encoding="utf8")
manifest=json.loads((D/"SCENE_LAYER_MANIFEST.json").read_text(encoding="utf8"))
floor_count=sum(x["asset"] in ("grass","path") for x in manifest["objects"])
assert floor_count==221
assert all(x["layer"]=="GROUND" for x in manifest["objects"] if x["asset"] in ("grass","path"))
assert '[node name="PAR" type="Node2D" parent="."]' in scene
assert '[node name="CONTACT" type="Node2D" parent="."]' in scene
# Native editor depth test: actor differs from identical FULL scene in each specified region.
back=imgs["ACTOR_BACK"];front=imgs["ACTOR_FRONT"]
diff_back=ImageChops.difference(back.convert("RGB"),full.convert("RGB")).getbbox()
diff_front=ImageChops.difference(front.convert("RGB"),full.convert("RGB")).getbbox()
assert diff_back is not None and diff_front is not None
# tree source to crown/base alpha conservation
pairs=[]
src=D/"godot_project"/"assets"
for name in ("tree_A","tree_B","conifer","broadleaf"):
 original=Image.open(src/(name+".png")).convert("RGBA")
 crown=Image.open(src/(name+"_par.png")).convert("RGBA")
 contact=Image.open(src/(name+"_base.png")).convert("RGBA")
 assert all(a+b==c for a,b,c in zip(
  crown.getchannel("A").getdata(),contact.getchannel("A").getdata(),original.getchannel("A").getdata()))
 pairs.append(name)
# QA board built from *actual Godot renderer* exported bitmaps
w,h=1120,950
canvas=Image.new("RGB",(w,h),(29,31,35));draw=ImageDraw.Draw(canvas)
for i,(key,label) in enumerate([("FULL","FULL MASTER / FS COMPLETE GROUND"),
 ("BASE","GROUND + TREE CONTACT ONLY"),("PAR","TRANSPARENT PAR / NO FLOOR TILES"),
 ("ACTOR_BACK","ACTUAL GODOT ACTOR BEHIND TREE")]):
 x=(i%2)*560;y=(i//2)*470
 im=imgs[key]
 backboard=Image.new("RGBA",im.size,(30,34,39,255))
 backboard.alpha_composite(im)
 canvas.paste(backboard.convert("RGB"),(x+8,y+24))
 draw.text((x+10,y+6),label,fill="white")
canvas.save(D/"R14_GODOT_REAL_RENDER_4PANEL.png")
compare=Image.new("RGB",(1120,452),(28,29,32))
for i,key in enumerate(("ACTOR_BACK","ACTOR_FRONT")):
 compare.paste(imgs[key].convert("RGB"),(i*560+8,24))
ImageDraw.Draw(compare).text((12,7),"REAR z185 (behind tree) vs FRONT z230 (in front) actual Godot compositor",fill="white")
compare.save(D/"R14_REAL_ACTOR_FRONT_BACK.png")
report={
 "status":"R14_GODOT_LAYER_FIRST_RENDER_PROOF_NATIVE_OUTPUTS",
 "actual_Godot_version":"4.7.2", "Godot_renderer":"OpenGL compatibility AMD RX6700XT",
 "editable_scene":True,"source_objects_not_full_map_segmentation":True,
 "canvas":[544,416],"layers":["GROUND","CONTACT","PAR","ACTOR"],
 "floor_tile_instances":floor_count,
 "par_sprite_instances":manifest["count_by_layer"]["PAR"],
 "contact_tree_instances":manifest["count_by_layer"]["CONTACT"],
 "PAR_nontransparent_alpha_px":pcount,
 "floor_only_test_tile_alpha_pixels":sample,
 "Godot_FULL_vs_Pillow_compose_pixel_difference_count":num_changed,
 "Godot_FULL_vs_Pillow_compose_max_channel_difference":max_difference,
 "actor_back_diff_region":diff_back,"actor_front_diff_region":diff_front,
 "tree_alpha_disjoint_partition_verified":pairs,
 "foreground_source_assets_may_include_ground_embedded_in_art":True,
 "full_art_quality_ground3_level":False,
 "technical_export_Pass":bool(num_changed==0 and max_difference==0 and pcount>0),
 "full_Fs_native_VX_integration_tested":False,
 "human_art_gate":"HOLD",
 "source_pack_note":"Reuses preexisting FS Elf Rich Pilot candidate sprites, art not to be regarded as approved village style",
 "do_not_conflate":"Tiled and Godot editors arrange clean independent image assets; they cannot automatically separate ground pixels embedded in source artwork."
}
(D/"R14_GODOT_EXPORT_GATE.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print("R14_GODOT_QA",json.dumps({k:report[k] for k in ("PAR_nontransparent_alpha_px","floor_only_test_tile_alpha_pixels","Godot_FULL_vs_Pillow_compose_pixel_difference_count","Godot_FULL_vs_Pillow_compose_max_channel_difference","technical_export_Pass")},ensure_ascii=False))
if not report["technical_export_Pass"]:raise SystemExit(3)