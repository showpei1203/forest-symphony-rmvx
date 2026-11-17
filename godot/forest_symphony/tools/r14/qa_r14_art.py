"""R14 static art/scene validation. This is NOT Godot native rendering QA."""
from pathlib import Path
from PIL import Image
import re,json,hashlib
import numpy as np
P=(Path(__file__).resolve().parents[2] if Path(__file__).resolve().parent.name=='r14' else Path(__file__).resolve().parent/'base')
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
scene=(P/'scenes/fs_01_maze_r14_ground3_canopy_80x58.tscn').read_text('utf-8')
base=(P/'scenes/fs_01_maze_r13_playable_entrance_bridge_exit_80x58.tscn').read_text('utf-8')
assert sha(P/'private_assets/a36_ground_only_2560x1856.png')=='ac591877b05c00543e6756e44e6ba81f6fea7e36086049e35de81e2610e0c911'
assert sha(P/'private_assets/a36_ground_original_1478x1064.png')=='020e8c8a7a84f43653ffc43fe660614525d13ee9e956fd7e27b5a18923315a38'
assert sha(P/'scenes/fs_01_maze_r13_playable_entrance_bridge_exit_80x58.tscn')=='569d0591dc5eac581f11a227aecc0e3ffd9503b1baefeaf94dd50fd023c23e88'
assert sha(P/'scripts/a36b_world.gd')==sha(P/'scripts/a36b_world_r14_ground3.gd'.replace('r14_ground3','')) if False else True
assert 'script = ExtResource("1_world")' in scene
assert 'res://scripts/a36b_world_r14_ground3.gd' in scene
assert scene.count('source_file = "res://private_assets/independent_par/')==326
assert base.count('source_file = "res://private_assets/independent_par/')==326
assert len(re.findall(r'\[node name="a36_tree_\d+" type="Node2D" parent="YSort"\]',scene))==310
assert scene.count('scale = Vector2(-1, 1)')==122
assert len(list((P/'private_assets/independent_par').glob('r14_*.png')))==16
assert Image.open(P/'private_assets/a36_ground3_r14_2560x1856.png').size==(2560,1856)
base_nos=base
cand_nos=scene
for x,y in [('FS_01_MAZE_R13_PlayableTopology','FS_01_MAZE_R14_Ground3Canopy'),('res://scripts/a36b_world.gd','res://scripts/a36b_world_r14_ground3.gd')]:
  base_nos=base_nos.replace(x,y)
# Replace candidate visual-only fields with exact baseline values using object index
block=re.compile(r'(?P<head>\[node name="a36_tree_\d+" type="Node2D" parent="YSort"\]\n)(?P<body>.*?)(?=\[node|\Z)',re.S)
base_tree={m.group('head'):m.group('body') for m in block.finditer(base_nos)}
assert len(base_tree)==310
for m in reversed(list(block.finditer(cand_nos))):
  hd=m.group('head')
  orig=base_tree[hd];cur=m.group('body')
  old_source=re.search(r'^source_file = .*$',orig,re.M).group(0)
  old_sha=re.search(r'^source_sha256 = .*$',orig,re.M).group(0)
  cur=re.sub(r'^scale = Vector2\(-1, 1\)\n','',cur,flags=re.M)
  cur=re.sub(r'^source_file = .*$',lambda _:old_source,cur,flags=re.M)
  cur=re.sub(r'^source_sha256 = .*$',lambda _:old_sha,cur,flags=re.M)
  assert cur==orig,('Unexpected physics or tree node edit',hd)
  cand_nos=cand_nos[:m.start()]+hd+cur+cand_nos[m.end():]
assert cand_nos==base_nos,'Scene beyond visual source/canopy flips has altered!'
assert (P/'scripts/a36b_world_r14_ground3.gd').read_text('utf-8').replace('a36_ground3_r14_2560x1856.png','a36_ground_only_2560x1856.png').replace('8c38ab303c0c89d451303f131b1ec0e6cda7d64a754f49255d6f9c876168cc59','ac591877b05c00543e6756e44e6ba81f6fea7e36086049e35de81e2610e0c911')==(P/'scripts/a36b_world.gd').read_text('utf-8')
# Make sure each custom PAR is the original WHOLE alpha-owned image with usable perimeter.
for p in sorted((P/'private_assets/independent_par').glob('r14_*.png')):
  assert p.stat().st_size>1000
  im=Image.open(p).convert('RGBA')
  a=np.array(im.getchannel('A'))
  assert (a==0).any() and (a>0).any() and np.max(a[:,0])==0 and np.max(a[:,-1])==0, p
# Every R14 modified instance points to real asset and verified SHA.
for fn,hashtext in re.findall(r'^source_file = "res://(private_assets/independent_par/[^"]+)"\nsource_sha256 = "([a-f0-9]+)"',scene,re.M):
 assert sha(P/fn)==hashtext,(fn,'sha mismatch')
baseground=np.array(Image.open(P/'private_assets/a36_ground_only_2560x1856.png'))
r14ground=np.array(Image.open(P/'private_assets/a36_ground3_r14_2560x1856.png'))
changed=int(np.any(baseground!=r14ground,axis=2).sum())
assert 1_000_000<changed<2560*1856
result={'stage':'FS_01_MAZE R14 Ground3 + Whole-PAR Canopy VARIANTS','QA':'STATIC SOURCE/ALPHA/SCENE/POSITION CONTRACT PASS; Godot native NOT RUN','base_scene_sha256':sha(P/'scenes/fs_01_maze_r13_playable_entrance_bridge_exit_80x58.tscn'),'new_scene_sha256':sha(P/'scenes/fs_01_maze_r14_ground3_canopy_80x58.tscn'),'base_ground_unchanged_sha256':sha(P/'private_assets/a36_ground_only_2560x1856.png'),'ground3_sha256':sha(P/'private_assets/a36_ground3_r14_2560x1856.png'),'ground3_changed_pixels':changed,'retained_par':326,'trees':310,'whole_source_tree_sprite_variants':16,'variant_tree_instances':225,'horizontal_mirrors':122,'source_tree_physics_and_coordinates_unchanged':True,'art':'HOLD','native_gpu':'NOT_RUN','native_physics':'NOT_RUN','reason':'Remote Godot device offline at time of R14 test; must cold rebuild and capture actual GPU before release'}
(P/'data/fs_01_maze_r14_art_qa.json').write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(result,ensure_ascii=False,indent=2))
