from pathlib import Path
from shutil import copy2
import subprocess,sys,json,hashlib
from PIL import Image
r=Path(r"E:\GameAssetToolLab_20261023\FS_ElfVillage_RichPilot_20261023")
snapshot=r/"work"/"baseline_rich_v1"
snapshot.mkdir(exist_ok=True,parents=True)
if not (snapshot/"scene_manifest.json").exists():
 copy2(r/"scene_manifest.json",snapshot/"scene_manifest.json")
 for p in (r/"build").glob("FS_ELF_RICH_*.png"):copy2(p,snapshot/p.name)
p=subprocess.run([sys.executable,str(r/"scripts"/"make_scene.py")],capture_output=True,text=True,timeout=30)
assert p.returncode==0,p.stderr
m=json.loads((r/"scene_manifest.json").read_text(encoding="utf8"))
market=next(x for x in m["instances"] if x["id"]=="market_east")
market["y"]=148
market["z"]=market["draw_order"]=market["y"]+market["dimensions"][1]
# Image objects retain source native size, integer top-left anchors, SHA and exact masks.
new=[
 ("edge_pine_west_a","conifer_pine",8,155,"tree"),
 ("edge_pine_west_b","conifer_pine",94,30,"tree"),
 ("edge_pine_east_a","conifer_pine",733,44,"tree"),
 ("edge_pine_east_b","conifer_pine",795,238,"tree"),
 ("edge_pine_south_a","conifer_pine",22,520,"tree"),
 ("edge_pine_south_b","conifer_pine",665,445,"tree"),
 ("grove_oak_northwest","broadleaf_oak",210,55,"tree"),
 ("grove_oak_northeast","broadleaf_oak",737,207,"tree"),
 ("grove_oak_east_south","broadleaf_oak",741,454,"tree"),
 ("grove_oak_bottomwest","broadleaf_oak",283,528,"tree"),
 ("grove_dead_southwest","dead_tree",24,558,"tree"),
 ("grove_dead_northeast","dead_tree",610,16,"tree"),
 ("hedge_west_gateway","bush_sprout",248,486,"bush"),
 ("hedge_east_track","bush_sprout",607,464,"bush"),
 ("hedge_market","bush_sprout",694,377,"bush"),
 ("stone_west_shoulder","rock_cluster",110,199,"rock"),
 ("stone_south_east","rock_cluster",696,518,"rock"),
 ("log_west_south","log_moss",196,482,"rock"),
]
base=m["instances"]
def source_info(aid):
 p=r/"source"/"clean"/(aid+".png")
 im=Image.open(p).convert("RGBA")
 return p,im
for iid,aid,x,y,role in new:
 p,im=source_info(aid);w,h=im.size
 assert x>=0 and y>=0 and x+w<=864 and y+h<=640,(iid,x,y,w,h)
 if role=="tree":
  box=[[round(w*.34),h-20,round(w*.67),h-1]];cut=round(h*.73)
 elif role=="bush":box=[[2,h-9,w-2,h-1]];cut=round(h*.45)
 else:box=[[3,h-21,w-3,h-2]];cut=round(h*.25)
 base.append({"id":iid,"asset_id":aid,"source":"source/clean/"+aid+".png","sha256":hashlib.sha256(p.read_bytes()).hexdigest(),
  "dimensions":[w,h],"x":x,"y":y,"anchor":"top_left","z":y+h,"draw_order":y+h,"role":role,
  "base_cut_y":cut,"collision_local":box,"interact_id":None,
  "semantic_masks":{"par_complete":"source_alpha","base":"source_alpha_including_lower_part","occlusion":"source_alpha_including_upper_part"},
  "transform":{"scale":1,"rotation":0,"flip_x":False,"flip_y":False}})
added_decor=[
 ("flower_j","flower_low",111,85),("flower_k","flower_field",251,125),
 ("flower_l","flower_low",703,121),("flower_m","flower_field",30,455),
 ("flower_n","flower_low",304,475),("flower_o","flower_field",660,490),
 ("flower_p","flower_low",832,298),("flower_q","flower_field",520,85),
 ("flower_r","flower_low",232,512),("flower_s","flower_field",797,475)
]
for iid,aid,x,y in added_decor:
 p,im=source_info(aid)
 assert x+im.width<=864 and y+im.height<=640
 m["ground_decor"].append({"id":iid,"asset_id":aid,"x":x,"y":y,
  "source":"source/clean/"+aid+".png","sha256":hashlib.sha256(p.read_bytes()).hexdigest(),
  "dimensions":list(im.size),"category":"GROUND_FLORA","collision":False})
m["interactions"][2]["y"]=330
m["status"]="COMPILED_CANDIDATE_V2_UNAPPROVED_PENDING_VISUAL_ENGINE"
m["source_scope"]="Stage8A source witnesses / legacy candidate graphics; shop palette variant, market single-level crop; NOT approved for production"
m["variant_notes"]={"new_objects":len(new),"new_ground_decor":len(added_decor),"market_crop":"128x155 instead of 128x255","house_shop":"palette-recolored witness, test-only, no geometry/resample"}
ids=[x["id"] for x in base]+[x["id"] for x in m["ground_decor"]]
assert len(ids)==len(set(ids))
(r/"scene_manifest.json").write_text(json.dumps(m,ensure_ascii=False,indent=2),encoding="utf8")
print("RICH_BLUEPRINT_V2",len(base),"PAR",len(m["ground_decor"]),"GROUND",len(m["interactions"]),"INTERACTIONS")
