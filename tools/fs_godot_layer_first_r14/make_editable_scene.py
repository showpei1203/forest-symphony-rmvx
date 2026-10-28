#!/usr/bin/env python3
"""Generate editable native Godot 4 scene Sprite2D hierarchy, not flattened PNG masks.
The same scene exports FULL / BASE / PAR with zero floor sprites in PAR.
"""
from pathlib import Path
import json,hashlib
D=Path(__file__).resolve().parent
G=D/"godot_project";G.mkdir(parents=True,exist_ok=True)
placed=[]
def add(label,kind,x,y,layer,foot=None):
 placed.append({"id":label,"asset":kind,"xy":[x,y],"layer":layer,"foot_y":foot if foot is not None else y})
# 17x13 grass/dirt maps: atlas-like ground sprites separate and true, no rendering into PAR
for yy in range(13):
 for xx in range(17):
  path=(xx in (7,8) and yy in range(13)) or (yy in (6,7) and 2<=xx<=15) or (yy in (10,11) and 4<=xx<=12) or (xx in (12,13) and 5<=yy<=10)
  add("floor_%02d_%02d"%(xx,yy),"path" if path else "grass",xx*32,yy*32,"GROUND")
# furniture and physical standing bases: independently represented pixel art
for i,(x,y) in enumerate([(30,328),(65,110),(210,285),(450,360),(130,42),(440,30),(10,250)],1):
 add(f"low_tuft_{i}","tuft",x,y,"GROUND")
# houses, fence and lamp assets are FULL RGBA source objects, never rectangles from Master
add("House","house",340,36,"PAR",196)
add("Market","market",12,178,"PAR",345)
add("TreeA_contact","tree_A_base",102,136,"CONTACT",200)
add("TreeA_crown","tree_A_par",102,136,"PAR",200)
add("TreeB_contact","tree_B_base",230,14,"CONTACT",78)
add("TreeB_crown","tree_B_par",230,14,"PAR",78)
add("Conifer_contact","conifer_base",463,115,"CONTACT",188)
add("Conifer_crown","conifer_par",463,115,"PAR",188)
add("Broadleaf_contact","broadleaf_base",365,260,"CONTACT",325)
add("Broadleaf_crown","broadleaf_par",365,260,"PAR",325)
for i,(x,y) in enumerate([(284,120),(291,308),(476,298)],1):
 add(f"Lamp_{i}","lamp",x,y,"PAR",y+50)
for i,(x,y) in enumerate([(185,245),(379,231),(120,300)],1):
 add(f"Fence_{i}","fence",x,y,"PAR",y+53)
add("Sign","sign",455,197,"PAR",245)
# Ground-only rock to demonstrate nonoccluder independent of visually raised assets
add("RockLow","rock",322,341,"GROUND")
def section(head,values):
 return "\n".join(f"{k}={v}" for k,v in values.items())
(G/"project.godot").write_text('''config_version=5

[application]
config/name="FS R14 Godot Layer First Pilot"
run/main_scene="res://LayeredPilot.tscn"

[display]
window/size/viewport_width=544
window/size/viewport_height=416
window/stretch/mode="canvas_items"

[rendering]
renderer/rendering_method="gl_compatibility"
renderer/rendering_method.mobile="gl_compatibility"
textures/default_filters/use_nearest_mipmap_filter=false
''',encoding="utf8")
textures=sorted(set(z["asset"] for z in placed)|{"actor32"})
texids={s:str(i+2) for i,s in enumerate(textures)}
h=['[gd_scene load_steps=%d format=3]'%(len(textures)+2),'',
   '[ext_resource type="Script" path="res://LayeredPilot.gd" id="1"]']
h += ['[ext_resource type="Texture2D" path="res://assets/%s.png" id="%s"]'%(k,texids[k]) for k in textures]
h += ['','[node name="LayeredPilot" type="Node2D"]','script = ExtResource("1")','',
  '[node name="GROUND" type="Node2D" parent="."]','',
  '[node name="CONTACT" type="Node2D" parent="."]','',
  '[node name="PAR" type="Node2D" parent="."]','',
  '[node name="ACTOR" type="Sprite2D" parent="."]',
  'position = Vector2(120, 174)',
  'z_index = 180',
  'centered = false',
  'texture_filter = 1',
  'texture = ExtResource("%s")'%texids["actor32"],'']
for v in placed:
 label,asset=v["id"],v["asset"];x,y=v["xy"];layer=v["layer"];foot=v["foot_y"]
 h+=['[node name="%s" type="Sprite2D" parent="%s"]'%(label,layer),
     'position = Vector2(%d, %d)'%(x,y),'centered = false',
     'texture_filter = 1','texture = ExtResource("%s")'%texids[asset]]
 if layer=="PAR":h+=['z_index = %d'%foot]
 elif layer=="CONTACT":h+=['z_index = 1']
 h.append('')
(G/"LayeredPilot.tscn").write_text("\n".join(h),encoding="utf8")
(D/"SCENE_LAYER_MANIFEST.json").write_text(json.dumps({
 "type":"SOURCE_FIRST_LAYERS_NOT_MASTER_SPLIT","width":544,"height":416,"tile":32,
 "source_package":"FS_ElfVillage_RichPilot_20261023/source",
 "objects":placed,"count_by_layer":{k:sum(x["layer"]==k for x in placed) for k in ["GROUND","CONTACT","PAR"]},
 "critical_rule":"PAR nodes own ONLY individual transparent source assets, never background tiles",
 "tree_rule":"Tree contact root 32px tile in CONTACT, all remaining tree pixels in PAR",
 "notes":"Pilot proves compositing / engine authoring; art richness does not equal ground3 target"
 },ensure_ascii=False,indent=2),encoding="utf8")
print("R14_EDITABLE_GODOT_SCENE",json.dumps({"nodes":len(placed),"layer_counts":{k:sum(x["layer"]==k for x in placed) for k in ["GROUND","CONTACT","PAR"]}}))