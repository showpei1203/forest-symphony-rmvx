#!/usr/bin/env python3
"""R14 Godot source-first layered FS pilot, not AI segmentation.
Every raised object starts as an individual existing RGBA sprite, never a full image with floor.
"""
from pathlib import Path
from PIL import Image
import hashlib,json,shutil
D=Path(__file__).resolve().parent
SRC=Path(r"E:\GameAssetToolLab_20261023\FS_ElfVillage_RichPilot_20261023\source")
OUT=D/"godot_project"/"assets";OUT.mkdir(parents=True,exist_ok=True)
assets={
 "grass":"grass_tile.png","path":"path_tile.png","house":"house_witness.png",
 "tree_A":"tree_A.png","tree_B":"tree_B.png",
 "conifer":"candidates/conifer_01.png","broadleaf":"candidates/broadleaf_03.png",
 "lamp":"candidates/post_lantern.png","fence":"candidates/fence_horizontal.png",
 "market":"candidates/market_stall.png","sign":"sign_A.png","flower":"candidates/flower_pink.png",
 "tuft":"candidates/grass_tuft.png","rock":"rock_A.png"}
man={"status":"SOURCE_FIRST_GODOT_LAYERED_PILOT","canvas":[544,416],"tile_size":32,"assets":[]}
for k,rel in assets.items():
 f=SRC/rel
 assert f.is_file(),f
 art=Image.open(f).convert("RGBA")
 p=OUT/(k+".png")
 shutil.copy2(f,p)
 man["assets"].append({"name":k,"file":"assets/"+k+".png","source":rel,
    "dimensions":list(art.size),"sha256":hashlib.sha256(p.read_bytes()).hexdigest()})
# Tree canopy/source split by only contact LOCAL bottom 32px cell, not global y clip.
for stem in ["tree_A","tree_B","conifer","broadleaf"]:
 im=Image.open(OUT/(stem+".png")).convert("RGBA")
 width,height=im.size
 bx=(width//2)//32*32
 bx=max(0,min(width-32,bx))
 box=(bx,max(0,height-32),min(width,bx+32),height)
 crown=im.copy()
 base=Image.new("RGBA",im.size,(0,0,0,0))
 base.paste(im.crop(box),(box[0],box[1]))
 crown.paste((0,0,0,0),box)
 # All RGBA pixels conserved across the disjoint alpha objects
 original_alpha=list(im.getchannel("A").getdata())
 crown_alpha=list(crown.getchannel("A").getdata())
 base_alpha=list(base.getchannel("A").getdata())
 assert all(a+b==z for a,b,z in zip(crown_alpha,base_alpha,original_alpha))
 crown.save(OUT/(stem+"_par.png"))
 base.save(OUT/(stem+"_base.png"))
 man["assets"].append({"name":stem+"_par","file":"assets/"+stem+"_par.png","role":"occluder_tree_minus_contact_tile","base_box":box})
 man["assets"].append({"name":stem+"_base","file":"assets/"+stem+"_base.png","role":"ground_tree_contact_only","base_box":box})
# Actor sourced from existing FS, 32x32 source frame, don't fabricate proportions
actor=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE\Graphics\Characters\$001.png")
if actor.is_file():
 a=Image.open(actor).convert("RGBA");frame=a.crop((32,0,64,32))
else:
 a=Image.open(actor) # MUST fail closed
frame.save(OUT/"actor32.png")
man["actor_frame_source"]=str(actor)
(D/"SOURCE_ASSET_MANIFEST.json").write_text(json.dumps(man,ensure_ascii=False,indent=2),encoding="utf8")
print("LAYER_SOURCE_PREPARED",json.dumps({"assets":len(man["assets"]),"actor":list(frame.size)},ensure_ascii=False),flush=True)