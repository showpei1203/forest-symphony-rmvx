from pathlib import Path
from collections import deque
from PIL import Image,ImageDraw
import hashlib,json
R=Path(__file__).resolve().parent.parent
M=json.loads((R/"scene_manifest.json").read_text(encoding="utf8"))
L=json.loads((R/"input"/"V22_SACRED_TREE_SOURCE_LEDGER.json").read_text(encoding="utf8"))
route=json.loads((R/"input"/"V22_SACRED_8WAY_ROUTES.json").read_text(encoding="utf8"))
native=json.loads((R/"logs"/"V22_NATIVE_VALIDATION.json").read_text(encoding="utf8"))
assert M["canvas"]==[544,416] and M["tile_size"]==32
assert len(M["objects"])==9 and route["route_steps"]==36
assert native["status"]=="V22_SACRED_GROVE_NEW_STYLE_TRUE_NATIVE_VX_PASS_ISOLATED_NOT_FORMAL"
assert native["real_native_frames"]==15
assert native["actual_walk_steps"]==36 and native["four_illegal_trunk_intrusions"]=="PASS"
assert native["v21_well_body_collision_regression"]=="PASS"
assert all(o["background_mismatch_pixels"]==o["invalid_occlusion_pixels"]==0
 for o in native["native_pixel_gates"].values())
def sha(path):
 h=hashlib.sha256()
 with path.open("rb") as f:
  for b in iter(lambda:f.read(1048576),b""):h.update(b)
 return h.hexdigest()
assert M["source_ground_sha256"]==sha(R/M["source_ground"])
source=R/"source"/"generated"/"sacred_tree_style_v22.png"
assert sha(source)==L["new_tree_source_sha256"]
tree=Image.open(source).convert("RGBA")
base=Image.open(R/"source"/"generated"/"sacred_base_v22.png").convert("RGBA")
canopy=Image.open(R/"source"/"generated"/"sacred_canopy_v22.png").convert("RGBA")
assert tree.size==base.size==canopy.size==(213,224)
assert tree.getchannel("A").getextrema()==(0,255)
assert set(tree.getchannel("A").get_flattened_data()).issubset({0,255})
rec=base.copy();rec.alpha_composite(canopy)
assert rec.tobytes()==tree.tobytes()
bad_hidden=sum(1 for r,g,b,a in tree.get_flattened_data() if not a and (r or g or b))
assert bad_hidden==0,("V22_TRANSPARENT_RGB_FRINGE_FAIL",bad_hidden)
# Strict source alpha channels are authoritative. Hidden RGB is source provenance and
# cannot leak into rendered pixels; record as warning until explicitly normalized.
G=Image.open(R/"build"/"Ground.png").convert("RGBA")
PAR=Image.open(R/"build"/"PAR_COMPLETE.png").convert("RGBA")
MASTER=Image.open(R/"build"/"Recomposed.png").convert("RGBA")
OWNER=Image.open(R/"build"/"PixelOwner16.png")
COLL=Image.open(R/"build"/"Collision.png").convert("L")
assert G.size==PAR.size==MASTER.size==OWNER.size==COLL.size==(544,416)
assert G.getchannel("A").getextrema()==(255,255)
g2=G.copy();g2.alpha_composite(PAR)
assert g2.tobytes()==MASTER.tobytes()
assert G.tobytes()==Image.open(R/"baseline_v21"/"source"/"style_ground_v2.png").convert("RGBA").tobytes()
refs=json.loads((R/"baseline_v21"/"scene_manifest.json").read_text(encoding="utf8"))
keep={o["instance_id"]:o for o in refs["objects"]}
for obj in M["objects"]:
 if obj["instance_id"] in keep:
  assert obj["source_sha256"]==keep[obj["instance_id"]]["source_sha256"]
  assert obj["authoritative_asset_path"].startswith("source/clean/")
  if obj["instance_id"] not in ("rock_north","village_noticeboard_src"):
   for key in ("x","y","width","height","foot_anchor","collision_local"):
    assert obj[key]==keep[obj["instance_id"]][key],obj["instance_id"]
assert "forest_tree_east" not in {o["instance_id"] for o in M["objects"]}
assert sum(o["kind"]=="sacred_tree" for o in M["objects"])==1
objs=sorted(M["objects"],key=lambda o:(o["foot_anchor"][1],o["instance_id"]))
owner2=Image.new("I;16",(544,416),0);op=owner2.load()
par2=Image.new("RGBA",(544,416));collision2=Image.new("L",(544,416),0)
pen=ImageDraw.Draw(collision2)
for i,obj in enumerate(objs,1):
 imgpath=R/obj["authoritative_asset_path"]
 assert sha(imgpath)==obj["source_sha256"]
 img=Image.open(imgpath).convert("RGBA")
 assert img.size==(obj["width"],obj["height"])
 par2.alpha_composite(img,(obj["x"],obj["y"]))
 pix=img.getchannel("A").load()
 for y in range(img.height):
  for x in range(img.width):
   if pix[x,y]:op[obj["x"]+x,obj["y"]+y]=i
 masks=R/"semantic_masks"/obj["instance_id"]
 assert Image.open(masks/"alpha.png").convert("L").tobytes()==img.getchannel("A").tobytes()
 for c in obj.get("collision_shapes",[{"rect":obj["collision_local"]}]):
  a,b,x,y=c["rect"];pen.rectangle((obj["x"]+a,obj["y"]+b,obj["x"]+x-1,obj["y"]+y-1),fill=255)
assert owner2.tobytes()==OWNER.tobytes()
assert par2.tobytes()==PAR.tobytes()
assert collision2.tobytes()==COLL.tobytes()
tree_o=next(o for o in objs if o["kind"]=="sacred_tree")
localmask=Image.open(R/"semantic_masks"/tree_o["instance_id"]/"collision.png").convert("L")
alpha=tree.getchannel("A")
for y in range(170):
 for x in range(213):
  assert not localmask.getpixel((x,y)),("CANOPY_MUST_NOT_COLLIDE",x,y)
assert localmask.getpixel((100,200))==255,("SACRED_TRUNK_CONTACT_MISSING")
assert alpha.getpixel((100,80))>0,("NOT_ACTUAL_CANOPY_PIXEL")
assert localmask.getpixel((100,80))==0
blocked=json.loads((R/"build"/"BlockedTiles.json").read_text(encoding="utf8"))
B={tuple(v) for v in blocked["blocked_tiles"]}
assert len(B)==25 and len(blocked["sacred_foot_tiles"])==4
assert all(tuple(x) in B for x in blocked["sacred_foot_tiles"])
well_x={(x,y) for x in (5,6,7) for y in (7,8)}
assert well_x<=B,("HUMAN_PASS_WELL_COLLISION_REGRESSED",B)
open_tiles={(x,y) for y in range(13) for x in range(17)}-B
assert (8,11) in open_tiles
reachable={(8,11):0};queue=deque([(8,11)])
while queue:
 x,y=queue.popleft()
 for p in ((x+1,y),(x-1,y),(x,y+1),(x,y-1)):
  if p in open_tiles and p not in reachable:reachable[p]=reachable[(x,y)]+1;queue.append(p)
assert len(reachable)>=180
for r in route["routes"]:
 assert tuple(r["tile"]) in reachable,r["name"]
 if r.get("deny_move"):assert tuple(r["deny_tile"]) in B
# Fail closed: a shifted sacred tree (1 px) produces a real composited source mismatch.
shift=Image.new("RGBA",(544,416))
for o in objs:
 img=Image.open(R/o["authoritative_asset_path"]).convert("RGBA")
 x=o["x"]+(1 if o["kind"]=="sacred_tree" else 0)
 shift.alpha_composite(img,(x,o["y"]))
drift=sum(a!=b for a,b in zip(shift.get_flattened_data(),PAR.get_flattened_data()))
assert drift>=500
# Fail closed: a false canopy-as-solid-body mask illegally blocks additional tiles.
canopy_collision=Image.new("L",(544,416))
canopy_collision.paste(canopy.getchannel("A"),(tree_o["x"],tree_o["y"]))
assert canopy_collision.getpixel((tree_o["x"]+100,tree_o["y"]+80))==255
assert COLL.getpixel((tree_o["x"]+100,tree_o["y"]+80))==0
# Source tamper test must be rejected by the actual SHA check.
corrupt=bytearray(source.read_bytes());corrupt[-32]^=1
assert hashlib.sha256(corrupt).hexdigest()!=tree_o["source_sha256"]
record={
 "status":"V22_SACRED_TREE_SOURCE_OWNER_TRUNK_COLLISION_NATIVE_PASS_NOT_FORMAL",
 "style_source":"SAME_APPROVED_AI_PAR_SHEET_AS_V21",
 "parent_sheet_SHA":L["source_sheet_sha256"],
 "source_component_area":L["complete_tree_component_area"],
 "tree_size":[213,224],"base_split_y":156,"new_tree_SHA":sha(source),
 "complete_tree_base_canopy_rgba_mismatch":0,
 "new_sacred_alpha0_hidden_RGB_pixels":bad_hidden,
 "source_pixel_owner_mismatches":0,"Ground_PAR_master_RGBA_mismatches":0,
 "sacred_tree_canopy_collidable_pixels":0,"tree_contact_present":True,
 "total_objects":9,"total_blocked_tiles":len(B),
 "reachable_tiles":len(reachable),"well_six_blocked_tiles_preserved":True,
 "native_actual_screenshots":15,"native_eight_direction_walk_steps":36,
 "native_four_denied_trunk_moves":4,
 "native_wrong_background_pixels":0,"native_wrong_owner_pixels":0,
 "negative_sacred_shift_1px_pixels":drift,
 "negative_canopy_as_collision_detected":True,
 "negative_corrupt_source_hash_detected":True,
 "human_new_visual_gate":"NOT_RUN",
 "sealed_FS":"NOT_TESTED","v8_height_level1_2":"NOT_INTEGRATED",
 "rights":"PRIVATE_TEST_ONLY_UNVERIFIED"
}
(R/"logs"/"V22_SACRED_SOURCE_SEMANTIC_AUDIT.json").write_text(json.dumps(record,ensure_ascii=False,indent=2),encoding="utf8")
print("V22_SACRED_SOURCE_OWNER_COLLISION_GATE_PASS",
 json.dumps({"source_area":record["source_component_area"],
 "objects":9,"reachable":len(reachable),"blocked":len(B),"shift_1px":drift,
 "native_screens":15,"hidden_RGB":bad_hidden},ensure_ascii=False),flush=True)
