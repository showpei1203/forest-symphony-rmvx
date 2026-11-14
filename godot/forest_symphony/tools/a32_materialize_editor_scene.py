import json, argparse
from pathlib import Path
ap=argparse.ArgumentParser(); ap.add_argument('--project',default='/mnt/data/fs_godot_a32'); args=ap.parse_args()
D=Path(args.project);j=json.loads((D/'data/a32_groundfirst_manifest.json').read_text())
# Avoid public GitHub broken ext resources to private art: scripts load by user-owned source file path at edit/runtime.
parts=['[gd_scene load_steps=4 format=3]',
 '[ext_resource type="Script" path="res://scripts/a32_world.gd" id="1_world"]',
 '[ext_resource type="Script" path="res://scripts/a32_par_instance.gd" id="2_object"]',
 '[ext_resource type="Script" path="res://scripts/a32_player.gd" id="3_player"]',
 '[node name="FS_A32_GroundFirst" type="Node2D"]','script = ExtResource("1_world")',
 '[node name="FullGround" type="Sprite2D" parent="."]','centered = false','texture_filter = 1',
 '[node name="YSort" type="Node2D" parent="."]','y_sort_enabled = true',
 '[node name="Player" type="CharacterBody2D" parent="YSort"]','position = Vector2(663, 568)','script = ExtResource("3_player")',
 '[node name="Sprite" type="Sprite2D" parent="YSort/Player"]','centered = false',
 '[node name="BodyCollision" type="CollisionShape2D" parent="YSort/Player"]',
 '[sub_resource type="RectangleShape2D" id="actor_foot"]','size = Vector2(13, 9)',
 '[node name="Camera2D" type="Camera2D" parent="YSort/Player"]','zoom = Vector2(1.35, 1.35)','enabled = true',
 '[node name="EditorGrid" type="Node2D" parent="."]','visible = false',
 ]
# Must define sub_resource before node references for loading behavior, insert before nodes.
substart=parts.index('[sub_resource type="RectangleShape2D" id="actor_foot"]');sub=parts[substart:substart+2];del parts[substart:substart+2];parts[4:4]=sub
ix=parts.index('[node name="BodyCollision" type="CollisionShape2D" parent="YSort/Player"]')
parts.insert(ix+1,'shape = SubResource("actor_foot")')
parts.insert(ix+2,'position = Vector2(0, -4)')
for item in j['objects']:
  stem=item['id'];f=item['asset_id'];src=j['assets'][f];w,h=src['size']
  pivot_x=item['x'] + w/2.0;pivot_y=item['y']+h-1
  # all Sprite2D nodes are editor-editable, with full independent PNG as dynamically loaded texture.
  parts += [f'[node name="{stem}" type="Node2D" parent="YSort"]',
            f'position = Vector2({pivot_x:g}, {pivot_y:g})',
            'script = ExtResource("2_object")',
            f'source_file = "res://{src["file"]}"',
            f'source_sha256 = "{src["sha256"]}"',
            f'source_semantic = "{item["semantic"]}"',
            f'source_object_id = "{item["id"]}"']
  if item['semantic']=='tree': dims=(22,12)
  elif item['semantic']=='house':dims=(max(80,w*.62),34)
  else:dims=(0,0)
  parts += [f'footprint_width_px = {dims[0]:g}',f'footprint_height_px = {dims[1]:g}',
            f'[node name="Sprite" type="Sprite2D" parent="YSort/{stem}"]', 'centered = false',
            f'[node name="Body" type="StaticBody2D" parent="YSort/{stem}"]',
            f'[node name="Collision" type="CollisionShape2D" parent="YSort/{stem}/Body"]']
# Add dynamically-loaded source images only in private package; GitHub source path strings are safe.
out='\n'.join(parts)+'\n'
(D/'scenes/a32_groundfirst_scene.tscn').write_text(out)
p=(D/'project.godot');t=p.read_text();t=t.replace('run/main_scene="res://scenes/elf_forest_map.tscn"','run/main_scene="res://scenes/a32_groundfirst_scene.tscn"')
t=t.replace('Forest Symphony | Godot-first Map+Collision Pilot A30','Forest Symphony | Godot-first A32 independent PAR').replace('Forest Symphony | Godot-first A29 real A21 map','Forest Symphony | Godot-first A32 independent PAR');p.write_text(t)
print('scene lines',len(parts),'bytes',len(out),'project',t[:340])
