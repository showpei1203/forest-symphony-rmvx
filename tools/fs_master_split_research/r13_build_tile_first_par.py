#!/usr/bin/env python3
"""R13: 32x32 tile-first occlusion rescue, source-exact 1280x928 RGBA.
Retain R12 as immutable baseline. New added zones tree/lantern/rail and micro features.
PROVISIONAL: tile snapping intentionally errs on covering object cells, may over-occlude ground.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,json,hashlib,collections,math
R=Path(__file__).resolve().parent
D=R/"R12_NEW_ELF_VILLAGE_001"
OUT=R/"R13_TILE_OCCLUSION_PAR_20261028";OUT.mkdir(exist_ok=True)
SRC=D/"MASTER_NEW_ELF_VILLAGE_001_R12_CANDIDATE.png"
src=np.asarray(Image.open(SRC).convert("RGB"));H,W=src.shape[:2]
assert (W,H)==(1280,928)
sel=json.loads((D/"R12_SELECTED14_AND_COLLISION_GATE.json").read_text(encoding="utf8"))
selection=sel["selected_objects"];assert len(selection)==14
# Object semantically registered candidate regions, not final artist-traced pixel silhouettes.
# Polygons are on native Master 1280x928; must review 1x actual object boundaries.
zones=[
# tree canopies: all raised parts through every intersected 32px tile. Exclude only root-base tile.
("TREE01_WEST_GROVE","tree",[(0,0),(215,0),(239,119),(180,201),(60,221),(0,171)],(116,201)),
("TREE02_MIDDLE_NORTH","tree",[(311,0),(489,0),(499,129),(458,194),(347,195),(307,100)],(405,192)),
("TREE03_NORTHEAST_GROVE","tree",[(977,0),(1251,0),(1269,192),(1180,224),(1006,174)],(1114,211)),
("TREE04_CENTRAL_LEFT","tree",[(323,311),(410,314),(460,398),(460,511),(409,550),(304,545),(264,479),(275,381)],(353,534)),
("TREE05_CENTRAL_RIGHT_GARDEN","tree",[(715,491),(808,504),(842,552),(852,623),(805,657),(721,637),(682,570)],(778,633)),
("TREE06_SOUTH_WEST","tree",[(0,741),(207,737),(258,828),(239,927),(0,927)],(123,916)),
("TREE07_SOUTH_EAST","tree",[(1108,655),(1261,645),(1279,736),(1279,927),(1121,927),(1063,827)],(1202,878)),
("TREE08_EAST_BANK","tree",[(1180,287),(1279,271),(1279,479),(1229,488),(1157,398)],(1227,468)),
("TREE09_TOP_RIGHT_WATER","tree",[(1148,0),(1279,0),(1279,153),(1213,178),(1140,117)],(1227,157)),
# lamp posts: include thin verticals even when SAM2 would classify as ground.
("LAMP01_LEFT_STEPS","lamp",[(138,242),(172,241),(178,323),(139,327)],(155,318)),
("LAMP02_UPPER_PLAZA","lamp",[(367,232),(403,232),(410,329),(371,331)],(392,323)),
("LAMP03_FOUNTAIN_NW","lamp",[(430,390),(467,392),(471,489),(433,493)],(452,488)),
("LAMP04_FOUNTAIN_NE","lamp",[(669,400),(699,403),(703,492),(666,497)],(687,487)),
("LAMP05_CENTER_SE","lamp",[(795,420),(832,426),(832,518),(796,517)],(811,509)),
("LAMP06_SOUTH_INN","lamp",[(610,491),(643,494),(643,567),(608,570)],(628,559)),
("LAMP07_EAST_BRIDGE","lamp",[(1079,261),(1112,259),(1119,340),(1079,339)],(1097,334)),
("LAMP08_LEFT_GARDEN","lamp",[(197,494),(224,494),(228,572),(193,574)],(210,567)),
("LAMP09_SOUTH_GARDEN","lamp",[(858,638),(894,635),(898,717),(858,717)],(878,708)),
# Raised fences, railings, bridge side rails, terrace retaining-wall top strips.
("RAIL01_CHAPEL_LEFT","rail",[(49,121),(185,139),(193,177),(64,170)],(121,177)),
("RAIL02_CHAPEL_RIGHT","rail",[(245,144),(373,121),(389,170),(263,190)],(311,188)),
("RAIL03_NORTH_TERRACE","rail",[(348,139),(691,129),(694,187),(353,185)],(517,180)),
("RAIL04_EAST_UPPER_EDGE","rail",[(744,205),(1018,198),(1022,256),(742,263)],(885,251)),
("RAIL05_CENTER_LEFT_TERRACE","rail",[(0,571),(345,562),(374,612),(0,632)],(222,611)),
("RAIL06_CENTRAL_SOUTH_EDGE","rail",[(346,588),(689,583),(690,658),(352,659)],(528,652)),
("RAIL07_BRIDGE_NORTH","rail",[(1070,146),(1205,145),(1209,182),(1077,185)],(1152,180)),
("RAIL08_BRIDGE_SOUTH","rail",[(1061,209),(1209,210),(1210,247),(1061,252)],(1145,245)),
("RAIL09_EAST_DOCK","rail",[(1042,315),(1221,310),(1225,357),(1040,361)],(1134,353)),
("RAIL10_FOUNTAIN_FENCE_E","rail",[(806,496),(921,490),(938,541),(808,558)],(868,553)),
("RAIL11_SOUTH_EAST_FLOWER","rail",[(914,799),(1238,789),(1252,842),(911,852)],(1085,845)),
("RAIL12_CENTER_BRIDGE_LEFT","rail",[(614,638),(679,632),(690,724),(634,740)],(661,731)),
("RAIL13_CENTER_BRIDGE_RIGHT","rail",[(821,626),(873,614),(893,732),(844,735)],(860,724)),
("RAIL14_LEFT_GARDEN_FENCE","rail",[(34,519),(333,520),(346,569),(32,574)],(180,565)),
("RAIL15_RIGHT_VILLAGE_FENCE","rail",[(878,471),(1058,469),(1075,515),(877,533)],(970,520)),
("RAIL16_SOUTH_COTTAGE_FENCE","rail",[(64,775),(439,767),(447,815),(61,826)],(259,817)),
# Important independent upright small features missing from selected 14
("SMALL01_SIGN_WEST","sign",[(191,298),(240,301),(245,375),(188,377)],(220,370)),
("SMALL02_SIGN_INN","sign",[(487,310),(537,309),(543,392),(485,394)],(518,389)),
("SMALL03_STATUE_SIDE","sculpture",[(525,425),(625,423),(639,574),(520,569)],(574,562)),
("SMALL04_SE_COTTAGE_LANTERN","lamp",[(1003,706),(1035,704),(1039,784),(1003,791)],(1024,785))
]
exclusions=[
 ("GROUND_CHAPEL_STAIR",[(363,260),(430,260),(431,482),(358,483)]),
 ("GROUND_NORTH_STAIR",[(868,258),(933,258),(935,406),(867,403)]),
 ("GROUND_SOUTH_STAIR",[(589,665),(646,661),(643,791),(589,791)]),
 ("GROUND_CENTER_BRIDGE_DECK",[(693,644),(817,646),(817,713),(694,712)]),
 ("GROUND_EAST_BRIDGE_DECK",[(1098,183),(1195,183),(1194,208),(1099,208)]),
 ("GROUND_PLAZA_PATH",[(397,505),(479,505),(485,580),(397,579)])]
# PER-object tree base exclusion: only contact tile of that tree; do not globally strip all objects in cell.
def polyMask(points):
 im=Image.new("L",(W,H),0);ImageDraw.Draw(im).polygon(points,fill=255)
 return np.asarray(im)>0
def binaryFromPng(path):
 return np.asarray(Image.open(path).convert("RGBA"))[:,:,3]>0
def tileSnap(mask,area_min=.065):
 out=np.zeros_like(mask,dtype=bool);coords=[]
 for ty in range(29):
  for tx in range(40):
   block=mask[ty*32:(ty+1)*32,tx*32:(tx+1)*32]
   if float(block.mean())>=area_min or (block.any() and float(block.sum())>=4):
    out[ty*32:(ty+1)*32,tx*32:(tx+1)*32]=True
    coords.append([tx,ty])
 return out,coords
def sourceRGBA(mask):
 img=np.zeros((H,W,4),np.uint8);img[mask,:3]=src[mask];img[mask,3]=255
 return img
objects=[]
for old in selection:
 mask=binaryFromPng(D/old["provisional_file"])
 is_tree="TREE" in old["id"] or old["kind"] in ("major_tree","tree")
 if is_tree:
  # Restore raised tree body/crown, but exclude ONLY tree root's one 32px tile.
  mask,tiles=tileSnap(mask,area_min=.06)
  tx=min(39,max(0,old["foot_anchor"][0]//32));ty=min(28,max(0,old["foot_anchor"][1]//32))
  mask[ty*32:(ty+1)*32,tx*32:(tx+1)*32]=False
  root=[tx,ty]
 else:
  tiles=[];root=None
 objects.append({"id":old["id"],"category":"R12_BASE_TREE_TILE_ENFORCED" if is_tree else "R12_SOURCE_MASK",
  "mask":mask,"tile_candidates":tiles,"foot":old["foot_anchor"],
  "root_exclusion":root,"provenance":"R12_selected14_source"})
for oid,kind,polygon,foot in zones:
 full=polyMask(polygon)
 if kind=="tree":
  mask,tiles=tileSnap(full,area_min=.11)
  # Only THIS object's contact tile excluded. Tree canopy at neighboring x remains.
  tx=min(39,max(0,foot[0]//32));ty=min(28,max(0,foot[1]//32))
  mask[ty*32:(ty+1)*32,tx*32:(tx+1)*32]=False
  root=[tx,ty]
 else:
  # Tile registry marks every intersecting 32px cell, but source alpha is restricted
  # to the actual upright structure polygon. Entire opaque 32px boxes would obscure
  # plaza ground when lamps/railings occupy only narrow columns.
  mask=full
  _,tiles=tileSnap(full,area_min=.18)
  root=None
 objects.append({"id":oid,"category":kind,"mask":mask,"tile_candidates":tiles,
  "foot":list(foot),"root_exclusion":root,"provenance":"R13_manual_logic_32grid"})
excludedMask=np.zeros((H,W),bool)
for name,pts in exclusions:excludedMask |= polyMask(pts)
# Scope blanket hard excludes only for ground-only polygons; the rail is separately above it.
# Stairs can overlap rail cells; keep R13 rail category there as independent foreground.
for o in objects:
 if o["category"] not in ("rail","lamp","sign","sculpture"):
  o["mask"] &= ~excludedMask
owner=np.zeros((H,W),np.uint16);combined=np.zeros((H,W),bool)
grid=collections.defaultdict(lambda:{"object_ids":[],"categories":[],"alpha_coverage_px":0,"review_needed":False})
manifest=[]
for n,o in enumerate(objects,1):
 mask=o["mask"]
 # Preserve per-object independent PAR; merged copy owner uses first-cover precedence.
 Image.fromarray(sourceRGBA(mask),"RGBA").save(OUT/(o["id"]+"_PAR.png"))
 for ty in range(29):
  for tx in range(40):
   v=mask[ty*32:(ty+1)*32,tx*32:(tx+1)*32]
   if v.any():
    k=(tx,ty)
    grid[k]["object_ids"].append(o["id"])
    if o["category"] not in grid[k]["categories"]:grid[k]["categories"].append(o["category"])
    grid[k]["review_needed"]|=o["category"] in ("rail","lamp","sign","sculpture","tree")
 taken=mask&~combined
 combined|=mask;owner[taken]=n
 area=int(mask.sum())
 info={k:v for k,v in o.items() if k!="mask"}
 info.update({"nontransparent_pixels":area,"full_tile_selection":len(o["tile_candidates"]),
  "source_RGB_exact":True,"art_user_accepted":False})
 manifest.append(info)
par=sourceRGBA(combined)
Image.fromarray(par,"RGBA").save(OUT/"PAR_R13_GRID_FIRST_SOURCE_CANDIDATE.png")
Image.fromarray(owner,"I;16").save(OUT/"R13_OBJECT_OWNER_16BIT.png")
baseline=binaryFromPng(D/"PAR_R12_VX_SELECTED14_SOURCE_ONLY.png")
counts={"old_alpha_px":int(baseline.sum()),"new_alpha_px":int(combined.sum()),
        "new_only_px":int((combined&~baseline).sum()),"lost_vs_R12_px":int((baseline&~combined).sum()),
        "total_objects":len(objects),"R13_new_semantic_objects":len(zones),
        "tree_objects":sum(o["category"]=="tree" for o in objects),
        "lamp_objects":sum(o["category"]=="lamp" for o in objects),
        "rail_objects":sum(o["category"]=="rail" for o in objects)}
# redraw visual at native pixel, avoid losing image sharpness by default.
qa=Image.fromarray(src.copy(),"RGB")
p=np.asarray(qa).copy()
p[combined]=(p[combined].astype(np.float32)*.62+np.array([255,10,171])*.38).astype(np.uint8)
Image.fromarray(p,"RGB").save(OUT/"R13_MASTER_PINK_PAR_COVERAGE.png")
plot=Image.fromarray(src.copy(),"RGB")
draw=ImageDraw.Draw(plot,"RGBA")
tiles_out=[]
for ty in range(29):
 for tx in range(40):
  record=grid.get((tx,ty))
  n=int(combined[ty*32:(ty+1)*32,tx*32:(tx+1)*32].sum())
  if record:
   record["alpha_coverage_px"]=n
   record["include"]=True
   record["tile"]=[tx,ty]
   tiles_out.append(record)
   outline=(252,18,135,255) if record["review_needed"] else (247,158,48,220)
   draw.rectangle((tx*32,ty*32,tx*32+31,ty*32+31),outline=outline,width=1)
  elif n>0:
   raise AssertionError(f"missing registry at {(tx,ty)}")
draw.text((12,900),f"R13 32px semantic tile PAR: {len(tiles_out)} candidate cells; human Gate F HOLD",fill=(255,255,255))
plot.save(OUT/"R13_32PX_OCCLUSION_GRID_QA.png")
# 32px tiles above tree root by manual semantic logic checked by output registry, not automated truth.
assert np.array_equal(par[combined,:3],src[combined,:3])
for ob in manifest:
 if ob["category"] in ("tree","R12_BASE_TREE_TILE_ENFORCED"):
  assert ob["root_exclusion"] is not None
  x,y=ob["root_exclusion"]
  layer=binaryFromPng(OUT/(ob["id"]+"_PAR.png"))
  assert layer[y*32:(y+1)*32,x*32:(x+1)*32].sum()==0,ob["id"]
payload={
 "status":"R13_TILE_FIRST_PAR_32PX_SOURCE_PIXEL_TECH_CANDIDATE_VISUAL_HOLD",
 "rule_authority":"FS_R13_PAR_32PX_OCCLUSION_TILE_RULES_20261028.md",
 "master_sha256":hashlib.sha256(SRC.read_bytes()).hexdigest(),
 "canvas_px":[W,H],"grid_tiles":[40,29],"master_unchanged":True,
 "R12_old_par_untouched":True,
 "rgb_source_exact":True,
 "counts":counts,
 "include_tile_count":len(tiles_out),
 "exclude_ground_polygons":[{"id":x,"polygon":pts} for x,pts in exclusions],
 "full_tile_overcapture_review_required":True,
 "tree_complete_canopy_verified_by_human":False,
 "all_lamps_railings_semantic_exhaustive":False,
 "all_objects_complete_exhaustive":False,
 "native_game_tested":False,"art_gate_F":"HOLD",
 "objects":manifest,
 "candidate_tiles":tiles_out}
(OUT/"R13_GRID_PAR_CANDIDATE_REGISTRY.json").write_text(json.dumps(payload,ensure_ascii=False,indent=2),encoding="utf8")
print("R13_GRID_PAR",json.dumps({**counts,"include_tile_count":len(tiles_out)},ensure_ascii=False),flush=True)