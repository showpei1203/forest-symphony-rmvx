#!/usr/bin/env python3
"""R12 candidate subset + independent 40x29 semantic COLLISION for new generated Master.
User will review PAR; no art Gate F or whole-world completion claim.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,cv2,json,hashlib,struct,collections
R=Path(__file__).resolve().parent;D=R/"R12_NEW_ELF_VILLAGE_001"
report=json.loads((D/"R12_SAM2_18OBJECT_GATE.json").read_text(encoding="utf8"))
src=np.asarray(Image.open(D/"MASTER_NEW_ELF_VILLAGE_001_R12_CANDIDATE.png").convert("RGB")).copy()
H,W=src.shape[:2];assert (W,H)==(1280,928)
rejected=[];kept=[]
for obj in report["objects"]:
 px=obj["source_alpha_pixels"]
 frac=obj["overlap_owner_conflict_pixels"]/max(1,px)
 if not obj["prompt_gate"] or frac>=.35:
  rejected.append({"id":obj["id"],"reason":"PROMPT_FAIL" if not obj["prompt_gate"] else "OVERLAP_GT_35PCT","overlap_ratio":round(frac,4)})
 else:kept.append(obj)
assert len(kept)==14,(len(kept),rejected)
# Stable ownership: only first selected instance owns overlap. Manual review may change.
union=np.zeros((H,W),np.uint8);owner=np.zeros((H,W),np.uint8)
for i,o in enumerate(kept,1):
 v=np.asarray(Image.open(D/o["provisional_file"]).convert("RGBA"))[:,:,3]>0
 new=v&(owner==0)
 owner[new]=i;union[new]=255
par=np.zeros((H,W,4),np.uint8);sel=union>0
par[sel,:3]=src[sel];par[sel,3]=255
Image.fromarray(par,"RGBA").save(D/"PAR_R12_VX_SELECTED14_SOURCE_ONLY.png")
Image.fromarray(owner,"L").save(D/"R12_SELECTED14_OWNER.png")
# Collision is independent from PAR alpha.
# Draw hand-defined candidate building footprints, water and cliffs on a 1280x928 mask;
# annotate these as provisional, not ground truth.
layers=Image.new("L",(W,H),0);pen=ImageDraw.Draw(layers)
solid=[
 ("chapel_body",[(139,16),(305,16),(305,139),(288,160),(155,154)]),
 ("top_red_cottage",[(426,31),(609,31),(609,128),(432,129)]),
 ("ne_workshop",[(715,66),(879,74),(876,223),(718,226)]),
 ("blue_inn",[(448,213),(604,216),(605,363),(450,362)]),
 ("red_cafe",[(702,297),(853,300),(854,453),(705,449)]),
 ("left_round_house",[(6,327),(194,327),(190,458),(7,456)]),
 ("mill",[(1116,388),(1276,385),(1276,593),(1145,612)]),
 ("sw_house",[(161,659),(330,656),(330,754),(164,754)]),
 ("se_house",[(914,579),(1090,574),(1086,738),(921,735)]),
 ("left_big_tree_trunk",[(261,473),(320,466),(325,530),(259,528)]),
 ("se_tree_trunk",[(1163,684),(1222,686),(1222,736),(1166,735)]),
 ("fountain_base",[(484,519),(612,517),(621,580),(498,593)]),
]
water=[
 ("east_waterfall_and_lake",[(1072,0),(1279,0),(1279,426),(1047,439),(1045,342),(1003,310),(1004,166),(1073,151)]),
 ("central_canal",[(677,608),(822,605),(829,752),(792,927),(622,927),(654,737)]),
 ("southeast_stream",[(1125,856),(1279,820),(1279,927),(1065,927)])
]
terrain=[
 ("west_terrace_cliff",[(0,142),(398,133),(386,232),(0,233)]),
 ("upper_center_cliff",[(366,132),(786,143),(787,220),(373,235)]),
 ("right_upper_cliff",[(826,200),(1030,191),(1036,305),(825,307)]),
 ("south_terrace_cliff",[(0,596),(653,590),(661,673),(0,681)]),
]
for tag,shape in solid+water+terrain:
 pen.polygon(shape,fill=255)
# User policy explicit: floor and stairs and bridge walk areas always ground, even when inside cliff/water polygons.
walk=[
 ("chapel_stairs",[(183,142),(260,140),(257,256),(175,256)]),
 ("middle_terrace_stairs",[(380,131),(427,139),(431,240),(374,241)]),
 ("right_terrace_stairs",[(866,208),(914,204),(912,407),(871,415)]),
 ("left_middle_access",[(305,184),(370,181),(375,322),(307,322)]),
 ("central_bridge",[(655,651),(848,647),(849,709),(649,711)]),
 ("right_wood_bridge",[(979,187),(1238,184),(1240,241),(981,247)]),
 ("right_dock",[(1030,299),(1226,307),(1223,381),(1024,376)]),
 ("south_cottage_steps",[(210,748),(256,747),(254,791),(209,794)]),
 ("south_east_steps",[(992,731),(1042,729),(1041,772),(991,770)]),
]
for _,shape in walk:pen.polygon(shape,fill=0)
arr=np.asarray(layers)>0
# sample tile center + majority to reduce 1px boundary artifacts
grid=[]
for ty in range(29):
 for tx in range(40):
  patch=arr[ty*32:(ty+1)*32,tx*32:(tx+1)*32]
  center=bool(arr[ty*32+16,tx*32+16]);cover=float(patch.mean())
  grid.append(768 if center or cover>=.45 else 769)
assert len(grid)==1160
# Find connected components and candidate path reachability; disconnected areas are art/navigation review.
g=np.array(grid,np.int32).reshape(29,40)
visited=set();sizes=[]
for y in range(29):
 for x in range(40):
  if g[y,x]!=769 or (x,y) in visited:continue
  queue=collections.deque([(x,y)]);visited.add((x,y));n=0
  while queue:
   px,py=queue.popleft();n+=1
   for nx,ny in [(px-1,py),(px+1,py),(px,py-1),(px,py+1)]:
    if 0<=nx<40 and 0<=ny<29 and g[ny,nx]==769 and (nx,ny) not in visited:
     visited.add((nx,ny));queue.append((nx,ny))
  sizes.append(n)
# Serialize original VX Map on Windows with rubymarshal; WSL SAM2 runtime writes authoritative grid JSON.
(D/"R12_TILE_GRID_40x29.json").write_text(json.dumps({"width":40,"height":29,"third_layer_values":grid,"source":"R12 geometry polygons independent of PAR alpha"},ensure_ascii=False,indent=2),encoding="utf8")
# diagnostics 1x
over=Image.fromarray(src,"RGB").convert("RGBA");draw=ImageDraw.Draw(over,"RGBA")
for y in range(29):
 for x in range(40):
  if g[y,x]==768:draw.rectangle((x*32+1,y*32+1,x*32+30,y*32+30),fill=(245,26,56,65),outline=(255,15,26,185),width=1)
  else:draw.rectangle((x*32,y*32,x*32+31,y*32+31),outline=(46,195,100,50),width=1)
over.save(D/"R12_COLLISION_GRID_CANDIDATE_QA.png")
reg={"status":"R12_SOURCE_PAR_14_SELECTED_COLLISION_40x29_CANDIDATE_HUMAN_ART_HOLD",
 "master_sha256":hashlib.sha256((D/"MASTER_NEW_ELF_VILLAGE_001_R12_CANDIDATE.png").read_bytes()).hexdigest(),
 "source_exact_selected14_rgb":True,"generated_new_master":True,
 "candidate_source_objects":len(kept),"rejected_prompt_or_overlap":rejected,
 "selected_objects":kept,
 "PAR_alpha_opaque_pixels":int(sel.sum()),
 "passable_769_tile_count":int((g==769).sum()),"blocked_768_tile_count":int((g==768).sum()),
 "passable_connected_component_sizes_desc":sorted(sizes,reverse=True),
 "collision_geometry_source":"MANUAL_BBOX_POLYGONS_AND_WATER_ZONES_CANDIDATE_NOT_APPROVED",
 "solid_geometry_polygons":solid,"water_polygons":water,"terrain_cliff_polygons":terrain,"ground_stairs_bridge_exclusions":walk,
 "formal_K4_Map003_unmodified":True,
 "collision_professional_visual_approved":False,
 "master_art_visual_gate_A":"HOLD","PAR_art_visual_gate_F":"PENDING_USER",
 "native_passability_compiler_tested":False}
(D/"R12_SELECTED14_AND_COLLISION_GATE.json").write_text(json.dumps(reg,ensure_ascii=False,indent=2),encoding="utf8")
print("R12_COLLISION",json.dumps({"selected":len(kept),"rejected":rejected,"alpha":int(sel.sum()),"walk":int((g==769).sum()),"block":int((g==768).sum()),"component_sizes":sorted(sizes,reverse=True)[:8]},ensure_ascii=False),flush=True)