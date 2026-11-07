"""A36H R3 independent source trees to enrich forest boundary
No invented canopy / no rescaling. Native R2 tree SOURCE RGBA originals only.
Try FIVE blocked-cell tree roots, each a standalone per-source PNG; candidate visual composite only.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import json,hashlib,numpy as np
R=Path(r"E:\FS_AGENT_SKILLS_PILOT_20261106\A36H_VISUAL_ART_REPAIR_20261107")
R1=R/"A36H_R1_TRUE_GROUND_PAR_RECOMPILE"
R2=R/"A36H_R2_GROUND3_PALETTE_MATCH"
O=R/"A36H_R3_FIVE_FOREST_EDGE_TREES_TEST"
if O.exists():raise RuntimeError("Output already exists")
O.mkdir()
S=R1/"SOURCE_INDEPENDENT_RGBA"
M=json.loads((R2/"A36H_R2_SCENE_MANIFEST.json").read_text("utf8"))
T={o["id"]:o for o in M["objects"] if o["type"]=="tree"}
root_places=[
 ("NORTHWEST_EDGE","tree_093",(176,144),False),
 ("NORTHEAST_EDGE","tree_010",(976,176),True),
 ("EAST_EDGE","tree_020",(1168,464),False),
 ("SOUTHEAST_EDGE","tree_020",(944,784),True),
 ("SOUTHWEST_EDGE","tree_093",(144,784),True)
]
blocked=M["collision_map_29x40"]
im=Image.open(R2/"A36H_R2_RUNTIME_FULL_SCENE_GROUND.png").convert("RGBA")
orig=im.copy()
chosen=[]
for id,ref,foot,mirror in root_places:
 o=T[ref]
 assert blocked[foot[1]//32][foot[0]//32]==1,(id,foot)
 src=Image.open(S/o["filename"]).convert("RGBA")
 if mirror:src=src.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
 x=foot[0]-(o["foot"][0]-o["x"]);y=foot[1]-(o["foot"][1]-o["y"])
 if x>=1280 or x+src.width<=0 or y>=928 or y+src.height<=0:raise RuntimeError(id+" out")
 # WYSIWYG: 1x original tree source paint; no smoothing/resampling or invented content.
 p=O/("A36H_R3_TREE_"+id+"_SOURCE_RGBA.png")
 src.save(p)
 im.alpha_composite(src,(x,y))
 chosen.append({"id":"a36h_r3_tree_"+id.lower(),"type":"tree","source_parent_id":ref,
 "source_filename":o["filename"],"filename":p.name,
 "x":x,"y":y,"w":src.width,"h":src.height,"foot":list(foot),
 "source_flip_horizontal":mirror,"source_alpha_sha256":hashlib.sha256(p.read_bytes()).hexdigest(),
 "foot_blocked_existing_native_map":True,
 "source_visual_gate":"DRAFT_NO_HUMAN_SIGNOFF"})
full=im.convert("RGB")
full.save(O/"R3_FIVE_EDGE_TREE_TOPLAYER_ONLY_TEST_MASTER.png")
out=Image.new("RGB",(1280,493),(22,26,29))
out.paste(orig.convert("RGB").resize((640,464),Image.Resampling.NEAREST),(0,29))
out.paste(full.resize((640,464),Image.Resampling.NEAREST),(640,29))
dr=ImageDraw.Draw(out)
dr.text((8,8),"R2 forest ORIGINAL",fill="white");dr.text((649,8),"R3 5 native source trees DRAFT",fill="white")
out.save(O/"R2_VS_R3_TREE_DRAFT_640.png")
(O/"TREE_PLACEMENTS.json").write_text(json.dumps(chosen,ensure_ascii=False,indent=2),encoding="utf8")
print(json.dumps(chosen,ensure_ascii=False))