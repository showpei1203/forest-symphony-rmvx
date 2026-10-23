from pathlib import Path
from PIL import Image,ImageChops
import hashlib,json,collections,subprocess,sys
root=Path(r"E:\GameAssetToolLab_20261023\FS_ForestSplit_v3_2")
build=root/"build";source=root/"sources";work=root/"work";logs=root/"logs"
manifest=json.loads((root/"scene_manifest.json").read_text(encoding="utf8"))
w,h=manifest["canvas"]["width"],manifest["canvas"]["height"]
imgs={key:Image.open(build/("FS_FOREST_V32_"+name+".png")).convert("RGBA") for key,name in {
 "ground":"Ground","par":"Par_COMPLETE","base":"Par_BASE","occlusion":"Occlusion",
 "master":"Master_FromScene","runtime":"RuntimeComposite","tiled":"TiledIndependentRender"}.items()}
checks={}
def add(gate,name,passed,note=""):
    checks.setdefault(gate,[]).append({"check":name,"pass":bool(passed),"note":str(note)})
def strict(a,b):return a.size==b.size and a.mode==b.mode and a.tobytes()==b.tobytes()
# A: Canvas, true alpha, hard geometry.
for label,im in imgs.items():add("A",label+"_canvas",im.size==(w,h),im.size)
add("A","ground_opaque",imgs["ground"].getchannel("A").getextrema()==(255,255))
add("A","par_true_alpha",imgs["par"].getchannel("A").getextrema()==(0,255))
add("A","integer_world_grid",w%32==0 and h%32==0)
# B: Manifest, source provenance, references.
ids=[x["instance_id"] for x in manifest["instances"]]
add("B","instance_unique",len(ids)==len(set(ids)),len(ids))
add("B","instances_exact",len(ids)==6 and len([x for x in ids if x.startswith("tree_")])==3 and len([x for x in ids if x.startswith("rock_")])==2 and "sign_01" in ids)
for obj in manifest["instances"]:
    p=source/(obj["asset_id"]+".png")
    valid=p.is_file()
    if valid:
      im=Image.open(p).convert("RGBA")
      valid=(list(im.size)==obj["source_dimensions"] and hashlib.sha256(p.read_bytes()).hexdigest()==obj["source_sha256"])
      valid=valid and isinstance(obj["x"],int) and isinstance(obj["y"],int) and obj["anchor"]=="top_left"
      valid=valid and all((build/"semantic_masks"/(obj["instance_id"]+"_"+x+".png")).exists() for x in ("base","occlusion","par_complete","base_rgba","occlusion_rgba"))
    add("B",obj["instance_id"]+"_assets_masks",valid)
# C: Independent Tiled rasterizer and manifest-derived parity.
add("C","independent_tiled_strict_rgba",strict(imgs["master"],imgs["tiled"]))
expected=imgs["ground"].copy(); expected.alpha_composite(imgs["par"])
add("C","master_derived_strict_rgba",strict(expected,imgs["master"]))
# Verify each instance source pixels map exactly onto PAR where no overlaps, no other source.
direct=Image.new("RGBA",(w,h))
for obj in sorted(manifest["instances"],key=lambda q:q["z_order"]):
    im=Image.open(source/(obj["asset_id"]+".png")).convert("RGBA")
    direct.alpha_composite(im,(obj["x"],obj["y"]))
add("C","all_non_ground_source_registration",strict(direct,imgs["par"]))
# Ground must be only repeated terrain sources and declared path; compare to deterministic independent reconstruction.
grass=Image.open(source/"grass_tile.png").convert("RGBA")
dirt=Image.open(source/"path_tile.png").convert("RGBA")
terrain_colors={grass.getpixel((x,y)) for y in range(32) for x in range(32)} | {dirt.getpixel((x,y)) for y in range(32) for x in range(32)}
nonterrain=sum(1 for pix in imgs["ground"].getdata() if pix not in terrain_colors)
add("C","ground_contains_only_declared_terrain",nonterrain==0,nonterrain)
# D: strict layer recomposition not subjective approximate alignment.
runtime=imgs["ground"].copy();runtime.alpha_composite(imgs["base"]);runtime.alpha_composite(imgs["occlusion"])
add("D","ground_base_occlusion_exact_recombine",strict(runtime,imgs["master"]))
add("D","compiler_runtime_preview_byte_exact",strict(runtime,imgs["runtime"]))
# E: actor semantic footprint witnesses.
witnesses=json.loads((work/"semantic_witnesses.json").read_text(encoding="utf8"))
for t in witnesses:
    layer={"PAR":imgs["par"],"BASE":imgs["base"],"OCCLUSION":imgs["occlusion"]}[t["kind"]]
    add("E","witness_"+t["instance_id"]+"_"+t["kind"],layer.getpixel((t["x"],t["y"]))[3]>=t["expect_alpha_min"])
for obj in manifest["instances"]:
    name=obj["instance_id"];al=Image.open(build/"semantic_masks"/(name+"_par_complete.png")).convert("L")
    ba=Image.open(build/"semantic_masks"/(name+"_base.png")).convert("L")
    oc=Image.open(build/"semantic_masks"/(name+"_occlusion.png")).convert("L")
    add("E","partition_"+name,bytes(al.getdata())==bytes(ImageChops.add(ba,oc).getdata()))
    if name.startswith("tree_"):
        add("E","tree_has_base_and_occlusion_"+name,ba.getbbox() is not None and oc.getbbox() is not None)
coll=Image.open(build/"FS_FOREST_V32_CollisionMask.png").convert("L")
spawn=manifest["spawn"];sx,sy=spawn["x"],spawn["y"];rad=spawn["actor_foot_radius"]
def free(x,y):
    if not rad<=x<w-rad or not rad<=y<h-rad:return False
    return all(coll.getpixel((xx,yy))==0 for yy in range(y-rad,y+rad+1) for xx in range(x-rad,x+rad+1))
add("E","spawn_not_blocked",free(sx,sy))
# Tile-center BFS: spawn -> top entrance, avoiding all collision geometry.
step=32
start=(sx//step,sy//step)
valid_tiles={(x,y) for y in range(h//step) for x in range(w//step) if free(x*32+16,y*32+16)}
visited={start};q=collections.deque([start]);goal=None
while q:
    tx,ty=q.popleft()
    if ty==0:goal=(tx,ty);break
    for nxt in ((tx+1,ty),(tx-1,ty),(tx,ty+1),(tx,ty-1)):
        if nxt in valid_tiles and nxt not in visited:visited.add(nxt);q.append(nxt)
add("E","spawn_to_top_route",goal is not None,{"visited":len(visited),"goal":goal})
# F requires separate evidence. Fail closed until engine exercise.
status={g:all(z["pass"] for z in rows) for g,rows in checks.items()}
report={"candidate":"FS_FOREST_V32","gate_results":status,"checks":checks,
        "gate_F_godot":"PENDING_ACTUAL_SCENE_EXERCISE",
        "gate_F_vx":"UNVERIFIED_NO_RUNTIME_INSTALL",
        "formal_status":"COMPILED CANDIDATE" if all(status.values()) else "FAIL"}
(logs/"GATES_A_TO_E.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print("GATES",status,"CHECKS",sum(len(z) for z in checks.values()),"STATUS",report["formal_status"])
for gate,rows in checks.items():
 for v in rows:
  if not v["pass"]:print("GATE_FAIL",gate,v)
if not all(status.values()):sys.exit(2)
