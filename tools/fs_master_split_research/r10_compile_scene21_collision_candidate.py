#!/usr/bin/env python3
"""R10 compile candidate 17x13 third-layer 768/769 from formal Map050 + PAR object foot anchors.
Passability independent of alpha (occlusion is NOT collision). Preserves original formal map exact.
Test-only; visual object footprints and player approval remain HOLD.
"""
from pathlib import Path
from rubymarshal.reader import load
from rubymarshal.writer import write
from PIL import Image,ImageDraw
import json,hashlib,struct
R=Path(__file__).resolve().parent
SRC=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE\Data\Map050.rvdata")
OUT=R/"R10_FORMAL_MAP_AUTHORITY";OUT.mkdir(exist_ok=True)
r7=json.loads((R/"R7_SEMANTIC_MASK_CANDIDATES"/"R7_SAM2_PROMPT_REGISTRY_GATE.json").read_text(encoding="utf8"))
r8=json.loads((R/"R8_USER_ANNOTATION_20261028"/"R8_USER_ANNOTATION_AUTHORITY.json").read_text(encoding="utf8"))
v=load(SRC.open("rb"))
w=int(v.attributes["@width"]);h=int(v.attributes["@height"])
assert (w,h)==(17,13)
raw=v.attributes["@data"]._private_data
dim,x,y,depth,n=struct.unpack_from("<5i",raw,0)
ids=list(struct.unpack_from("<"+str(n)+"H",raw,20))
assert (dim,x,y,depth,n)==(3,17,13,3,663)
assert all(t==0 for t in ids)
orig_map_sha=hashlib.sha256(SRC.read_bytes()).hexdigest()
objects=[{**ob,"origin":"R7","id":ob["id"]} for ob in r7["objects"]]+[{**ob,"origin":"USER_RED_R8","id":ob["id"]} for ob in r8["user_red"]]
# Semantics: visual occlusion (PAR) does not automatically mean blocking.
# MAJOR vegetation, buildings and stone monuments => foot-grid candidate block.
# Small low plants have occlusion but tentative passable by default. Dense shrubs candidate block.
blocks={"building","tree","stone","structure","major_tree","micro_shrub","micro_bush","micro_flower_bush"}
# Other kinds from R7: bush needs review: likely dense enough, candidate block.
blocks.add("bush")
policies=[]
cell_users={}
for ob in objects:
 fx,fy=ob["foot"]
 cx=int(fx)//32;cy=int(fy)//32
 assert 0<=cx<w and 0<=cy<h,(ob["id"],ob["foot"])
 kind=ob.get("kind","unknown")
 policy="BLOCK_CANDIDATE" if kind in blocks else "PASSABLE_CANDIDATE_REVIEW"
 owner={"id":ob["id"],"kind":kind,"origin":ob["origin"],
        "foot":[fx,fy],"cell":[cx,cy],"collision_policy":policy,
        "par_occlusion":True,"needs_user_footprint_approval":True}
 policies.append(owner)
 if policy=="BLOCK_CANDIDATE":cell_users.setdefault((cx,cy),[]).append(owner["id"])
# Explicit blue step walkability only at the target actual actor foot tile,
# not blanket pass all grid cells touched by an exclusion ellipse.
step_center=(9,6)
conflicts=cell_users.pop(step_center,[])
blue_cells=[step_center]
# By default ALL ground tiles are passable; exceptions only explicit collision candidates.
for ty in range(h):
 for tx in range(w):
  ids[2*w*h +tx+ty*w]=768 if (tx,ty) in cell_users else 769
assert ids[2*w*h + 9+6*w]==769
assert ids[2*w*h +13+5*w]==768 # user red high conifer
assert ids[2*w*h +15+7*w]==768 # user red far conifer
assert ids[2*w*h +2+8*w]==769 # grass movement case
assert ids[2*w*h +5+6*w]==769
table=v.attributes["@data"]
table._private_data=struct.pack("<5i",dim,x,y,depth,n)+struct.pack("<"+str(n)+"H",*ids)
file=OUT/"Map050_SCENE21_COLLISION_CANDIDATE.rvdata"
with file.open("wb") as f:write(f,v)
new=load(file.open("rb"));assert new.attributes["@parallax_name"]==b"SCENE21"
raw2=new.attributes["@data"]._private_data
layer=list(struct.unpack_from("<663H",raw2,20))[442:]
assert layer.count(769)+layer.count(768)==w*h
# Authoring diagnostic full grid. Blocked tiles on top of Source complete master. No art image edited.
master=Image.open(R/"SCENE21_GUIDED_SAM2_CANDIDATE"/"MASTER_RGBA.png").convert("RGBA")
visual=master.copy();d=ImageDraw.Draw(visual,"RGBA")
for y in range(h):
 for x in range(w):
  if layer[x+y*w]==768:
   d.rectangle((x*32+1,y*32+1,x*32+31,y*32+31),fill=(250,44,64,70),outline=(255,55,60,235),width=2)
  else:
   d.rectangle((x*32,y*32,x*32+31,y*32+31),outline=(65,210,125,48),width=1)
for cx,cy in blue_cells:
 d.rectangle((cx*32+2,cy*32+2,cx*32+30,cy*32+30),outline=(45,80,255,255),width=2)
visual.save(OUT/"R10_SOURCE_SCENE21_COLLISION_CANDIDATE_GRID.png")
manifest={"status":"R10_AUTO_COLLISION_CANDIDATE_SEMANTIC_FOOTPRINT_APPROVAL_HOLD",
"map050_formal_sha256":orig_map_sha,"map050_original_source_byte_unmodified":True,
"test_candidate_map_sha256":hashlib.sha256(file.read_bytes()).hexdigest(),
"source_visual_unchanged":True,
"ground_default_walkable_769_count":layer.count(769),
"candidate_blocked_768_count":layer.count(768),
"separate_PARA_occlusion_from_collision_policy":True,
"auto_generated_from_20_source_object_foot_anchors":True,
"blocking_candidate_cells":[{"tile":[x,y],"owners":v} for (x,y),v in sorted(cell_users.items())],
"blue_steps_tile_walkable":[list(c) for c in blue_cells],
"blue_foot_collision_conflict_owners_removed":conflicts,
"objects":policies,"original_3_Map050_events_preserved_in_candidate_file":True,
"candidate_collision_accuracy_fully_verified":False,
"warning":"Only object foot CELL candidates; not full house geometry, passability routes or human-verified depth anchors.",
"formal_project_edit":False}
(OUT/"R10_COLLISION_POLICY_CANDIDATE.json").write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding="utf8")
print("R10_COLLISION_COMPILER",json.dumps({"walk":layer.count(769),"block":layer.count(768),"blue_step":list(step_center),"conflicts":conflicts,"blocking_cells":manifest["blocking_candidate_cells"]},ensure_ascii=False),flush=True)