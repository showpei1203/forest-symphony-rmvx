from pathlib import Path
from PIL import Image
import hashlib,json
r=Path(r"E:\GameAssetToolLab_20261023\FS_B0_SCENE04_HEIGHT_20261023")
registry=json.loads((r/"SOURCE_REGISTRY.json").read_text(encoding="utf8"))["assets"]
width,height=17,13
left={(x,y) for x in range(1,7) for y in range(1,5)}
right={(x,y) for x in range(11,16) for y in range(1,5)}
stairs={(5,5),(12,5)}
faces={(x,5) for x in range(1,7)} | {(x,5) for x in range(11,16)}
blocking_faces=faces-stairs
water={(x,y) for x in range(width) for y in (11,12)}
terrain=[]
for ty in range(height):
 row=[]
 for tx in range(width):
  pos=(tx,ty)
  if pos in water: ground,heightid,walk="water",-1,False
  elif pos in left|right:ground,heightid,walk="upper_grass",1,True
  elif pos in stairs:ground,heightid,walk="path",0,True
  elif pos in blocking_faces:ground,heightid,walk="grass",0,False
  elif ty==10:ground,heightid,walk="shore",0,True
  elif (ty in (6,7,8) and tx in (5,8,12)) or (ty==8 and 4<=tx<=13):
   ground,heightid,walk="path",0,True
  else:ground,heightid,walk="grass",0,True
  row.append({"ground":ground,"height":heightid,"walkable":walk,"region": "UPPER_LEFT" if pos in left else "UPPER_RIGHT" if pos in right else "LOWER"})
 terrain.append(row)
objects=[]
def add(i,aid,x,y,role,collision=None,topcut=None):
 o=registry[aid];w,h=o["width"],o["height"]
 assert 0<=x and 0<=y and x+w<=width*32 and y+h<=height*32,(i,x,y,w,h)
 objects.append({"id":i,"asset_id":aid,"source":o["path"],"source_sha256":o["sha256"],
 "x":x,"y":y,"width":w,"height":h,"z":y+h,"anchor":"top_left",
 "role":role,"cut_y":topcut if topcut is not None else max(0,h-15),
 "collision_local":collision or []})
for tx in range(1,7):
 if (tx,5) in stairs:add("stairs_left","stair_face",tx*32,5*32,"STAIR_VISIBLE",[],24)
 else:add("left_wall_"+str(tx),"cliff_face",tx*32,5*32,"CLIFF_FACE",[[0,0,32,32]],16)
for tx in range(11,16):
 if (tx,5) in stairs:add("stairs_right","stair_face",tx*32,5*32,"STAIR_VISIBLE",[],24)
 else:add("right_wall_"+str(tx),"cliff_face",tx*32,5*32,"CLIFF_FACE",[[0,0,32,32]],16)
add("tree_left","tree",42,14,"TREE",[[24,78,41,95]],52)
add("tree_right","tree",422,7,"TREE",[[24,78,41,95]],52)
add("tree_low","tree",30,252,"TREE",[[24,78,41,95]],52)
add("rock_north","rock",303,209,"ROCK",[[4,10,30,23]],6)
add("rock_south","rock",371,304,"ROCK",[[4,10,30,23]],6)
add("sign_center","sign",259,204,"SIGN",[[13,33,20,39]],18)
m={"id":"FS_SCENE04_HEIGHT_B0_SOURCE_TEST_V1","class":"COMPILE_INPUT","authority":"FS_MAP_ASSET_PRODUCTION_AUTHORITY_V3_2",
 "reference_image":"SCENE04.png / concept only; source art is independently authored procedural 10-tile kit",
 "license_gate":"PROJECT_OWNED_PROCEDURAL_TEST_ONLY","tile":32,"canvas":{"width":544,"height":416},"grid":{"w":width,"h":height},
 "source_registry":"SOURCE_REGISTRY.json","terrain":terrain,"objects":objects,
 "stairs":[{"id":"LEFT","tile":[5,5],"low_neighbor":[5,6],"high_neighbor":[5,4]},
           {"id":"RIGHT","tile":[12,5],"low_neighbor":[12,6],"high_neighbor":[12,4]}],
 "spawn":[8,8],"targets":{"left_plateau":[5,4],"right_plateau":[12,4]},
 "draw_rule":"terrain Ground from source. non-ground sources PAR. actual actor world height from grid+explicit stair edges, not global Y-only",
 "formal_status":"DRAFT_NOT_FORMAL"}
(r/"SCENE_MANIFEST_B0.json").write_text(json.dumps(m,ensure_ascii=False,indent=2),encoding="utf8")
print("B0_MANIFEST",len(objects),"source objects",width*height,"tiles","stairs",len(m["stairs"]))
