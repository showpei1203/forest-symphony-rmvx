from pathlib import Path
import shutil, json, hashlib, re, zlib, struct, collections
import numpy as np
from rubymarshal.reader import loads
from rubymarshal.writer import writes
F=Path(r"E:\FS_STAGE16_A36F_ELF_FOREST_REWORK_20261103")
G=Path(r"E:\FS_STAGE16_A36G_INTEGRATED_REGIONS_20261104")
V0=Path(r"E:\FS_STAGE16_A36F_ELF_FOREST_VX_NATIVE_20261103")
V=Path(r"E:\FS_STAGE16_A36G_PIXELLAB_R3B_VX_NATIVE_20261104")
D0=F/"GODOT_A36F_ELF_FOREST_40x29"
D=G/"GODOT_A36G_PIXELLAB_R3B_40x29"
S=G/"SOURCE_INDEPENDENT_RGBA"
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
m=json.loads((G/"A36G_SCENE_MANIFEST.json").read_text("utf8"))
obj=m["objects"];assert len(obj)==len({o["filename"] for o in obj})
assert len(obj)>400 and len(obj)<468
old=json.loads((F/"A36F_SCENE_MANIFEST.json").read_text("utf8"))
# Recompute new geometrical house collision tiles, not assume old footprint.
def collision(a):
  x0,y0,x1,y1=a
  return {(x,y) for y in range(29) for x in range(40) if x0<=x*32+16<=x1 and y0<=y*32+16<=y1}
blocked={(x,y) for y,row in enumerate(old["collision_map_29x40"]) for x,b in enumerate(row) if b}
oldhouse=next(o for o in old["objects"] if o["id"]=="A36F_ELF_COTTAGE_A")
newhouse=next(o for o in obj if o["id"]=="A36G_ELF_HOUSE_AND_WORKSHOP")
blocked=(blocked-collision(oldhouse["blocking_footprint_px"]))|collision(newhouse["blocking_footprint_px"])
free={(x,y) for y in range(29) for x in range(40) if (x,y) not in blocked}
Q=collections.deque([tuple(m["spawn_tile"])]); seen=set(Q)
while Q:
 x,y=Q.popleft()
 for a in ((x-1,y),(x+1,y),(x,y-1),(x,y+1)):
  if a in free and a not in seen:seen.add(a);Q.append(a)
m["collision_map_29x40"]=[[int((x,y) in blocked) for x in range(40)] for y in range(29)]
m["blocked_cells"]=len(blocked);m["free_cells"]=len(free);m["free_reachable_cells"]=len(seen)
m["collision_geometry_gate"]="BFS_PASS" if len(seen)==len(free) else "FAIL"
assert len(seen)==len(free),(len(seen),len(free))
assert (11,11) in free and (11,12) in blocked and (11,8) in free and (12,8) in free
(G/"A36G_SCENE_MANIFEST.json").write_text(json.dumps(m,ensure_ascii=False,indent=2),"utf8")
assert V0.exists() and D0.exists()
if V.exists() or D.exists():raise RuntimeError("New isolated engine already exists; no overwrite")
shutil.copytree(V0,V)
shutil.copytree(D0,D)
ov=V/"Overlays"
for p in ov.glob("*.png"):
 if p.name.endswith("RGBA.png") or p.name in ("ground50.png","Par50.png"):p.unlink()
for o in obj:
 p=S/o["filename"]
 assert sha(p)==o["sha256"],o["id"]
 shutil.copy2(p,ov/o["filename"])
shutil.copy2(G/"A36G_GROUND_1280x928.png",ov/"ground50.png")
shutil.copy2(G/"A36G_PAR50_RGBA_1280x928.png",ov/"Par50.png")
mapfile=V/"Data"/"Map050.rvdata"
ma=loads(mapfile.read_bytes());arr=np.zeros((3,29,40),dtype=np.uint16);arr[2]=769
for x,y in blocked:arr[2,y,x]=768
ma.attributes["@data"]._private_data=struct.pack("<5i",3,40,29,3,3480)+arr.astype("<u2").tobytes()
mapfile.write_bytes(writes(ma))
sp=V/"Data"/"Scripts.rvdata";r=loads(sp.read_bytes())
s=zlib.decompress(r[483][2]).decode("utf8")
assert "module A36F_MAP" in s
for key,v in (("OBJECTS",[[o["filename"].removesuffix(".png"),o["x"],o["y"],o["foot"][1]] for o in obj]),
              ("BLOCKS",[list(z) for z in sorted(blocked)])):
 line=next(z for z in s.splitlines() if z.startswith("  "+key+" = "))
 s=s.replace(line,"  "+key+" = "+json.dumps(v,separators=(",",":")))
# Preserve source filenames but update runtime evidence text namespace.
s=s.replace("module A36F_MAP","module A36G_MAP")
s=s.replace("A36F_MAP.", "A36G_MAP.").replace("A36F_MAP::", "A36G_MAP::")
for x in ("AUTO","ENTER","BLOCK","ROAD","MAP_OBJECTS"):
 s=s.replace("A36F_"+x,"A36G_"+x)
s=s.replace("A36F_VX_ACTUAL_FULL_MAP.log","A36G_VX_ACTUAL_FULL_MAP.log")
assert 'module A36G_MAP' in s
r[483][2]=zlib.compress(s.encode("utf8"));sp.write_bytes(writes(r))
assets=D/"assets";out=D/"out"
for p in assets.glob("A36F_*"):p.unlink()
for p in out.iterdir():
 if p.is_file():p.unlink()
shutil.copy2(G/"A36G_GROUND_1280x928.png",assets/"A36G_GROUND_1280x928.png")
for o in obj:shutil.copy2(S/o["filename"],assets/o["filename"])
(assets/"A36G_GODOT_SOURCE_SCENE.json").write_text(
 json.dumps({"meta":{"size_px":[1280,928]},"objects":obj},ensure_ascii=False),"utf8")
gd=(D/"a36f_godot_native_render.gd").read_text("utf8")
gd=gd.replace("A36F_GROUND_GRASS_FLOWERS_ROAD_1280x928.png","A36G_GROUND_1280x928.png")
gd=gd.replace("A36F_GODOT_SOURCE_SCENE.json","A36G_GODOT_SOURCE_SCENE.json")
gd=gd.replace("assert(count==468 and trees==222)",
              f"assert(count=={len(obj)} and trees=={sum(o['type']=='tree' for o in obj)})")
gd=gd.replace("A36F_GODOT_","A36G_GODOT_").replace('"stage":"A36F"','"stage":"A36G_R1"')
gd=gd.replace("A36F_GODOT_FULL_MAP_NATIVE_PASS","A36G_GODOT_FULL_MAP_NATIVE_PASS")
gds=D/"a36g_godot_native_render.gd";gds.write_text(gd,"utf8")
qa={"stage":m["stage"],"scene_objects":len(obj),"trees":sum(o["type"]=="tree" for o in obj),
 "roots_in_region":len(m.get("forest_region_blueprint",{}).get("collision_root_anchors",[])),
 "block_count":len(blocked),"free":len(free),"free_reachable":len(seen),
 "engine_dir":str(V),"godot_dir":str(D),"engine_status":"BUILD_ONLY_NOT_TESTED",
 "forest_art_status":"FAIL_R1_R2","house_art_status":"PENDING_ART","formal_seal":"NO"}
(G/"A36G_ENGINE_BUILD_QA.json").write_text(json.dumps(qa,indent=2,ensure_ascii=False),"utf8")
print(json.dumps(qa,indent=2,ensure_ascii=False))