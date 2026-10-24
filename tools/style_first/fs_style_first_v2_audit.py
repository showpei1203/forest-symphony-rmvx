from pathlib import Path
from PIL import Image
from collections import deque
import hashlib,json
R=Path(__file__).resolve().parent.parent
M=json.loads((R/"scene_manifest.json").read_text(encoding="utf8"))
V1=json.loads((R/"baseline_v1"/"source_candidate"/"scene_manifest.json").read_text(encoding="utf8"))
ledger=json.loads((R/"input"/"V2_STYLE_ASSET_LEDGER.json").read_text(encoding="utf8"))
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
assert M["canvas"]==[544,416] and M["tile_size"]==32
assert len(M["objects"])==9 and len(V1["objects"])==6
assert [x["instance_id"] for x in M["objects"] if x["instance_id"] not in [o["instance_id"] for o in V1["objects"]]]==[
 "village_noticeboard_src","stone_well_src","flower_hedge_src"] or \
 set(x["instance_id"] for x in M["objects"])-set(x["instance_id"] for x in V1["objects"])=={"stone_well_src","village_noticeboard_src","flower_hedge_src"}
original={ob["instance_id"]:ob for ob in V1["objects"]}
for obj in M["objects"]:
 assert digest(R/obj["authoritative_asset_path"])==obj["source_sha256"],("SOURCE_HASH_CHANGED",obj["instance_id"])
 if obj["instance_id"] in original:
  v=original[obj["instance_id"]]
  assert all(obj[k]==v[k] for k in ("asset_id","x","y","width","height","foot_anchor","z_order","collision_local")),obj["instance_id"]
for asset in ledger["new_PAR"]:
 match=next(o for o in M["objects"] if o["asset_id"]==asset["name"])
 assert match["source_sha256"]==asset["sha256"] and match["width"]==asset["dimensions"][0]
assert M["source_ground_sha256"]==digest(R/"source"/"style_ground_v2.png")
G=Image.open(R/"build"/"Ground.png").convert("RGBA")
P=Image.open(R/"build"/"PAR_COMPLETE.png").convert("RGBA")
O=Image.open(R/"build"/"PixelOwner16.png")
C=Image.open(R/"build"/"Collision.png").convert("L")
A=Image.open(R/"build"/"Recomposed.png").convert("RGBA")
assert G.size==P.size==O.size==C.size==A.size==(544,416)
assert G.getchannel("A").getextrema()==(255,255)
assert G.tobytes()==Image.open(R/"source"/"style_ground_v2.png").convert("RGBA").tobytes()
tmp=G.copy();tmp.alpha_composite(P)
assert tmp.tobytes()==A.tobytes()
ground_rebuild=Image.open(R/"baseline_v1"/"source_candidate"/"build"/"Ground.png").convert("RGBA")
for item in M["ground_decor"]:
 assert digest(R/item["source"])==item["sha256"]
 patch=Image.open(R/item["source"]).convert("RGBA")
 ground_rebuild.alpha_composite(patch,(item["x"],item["y"]))
assert ground_rebuild.tobytes()==G.tobytes()
ordered=sorted(M["objects"],key=lambda o:(o["foot_anchor"][1],o["instance_id"]))
reconstruct_par=Image.new("RGBA",(544,416))
owner=Image.new("I;16",(544,416));op=owner.load()
for i,ob in enumerate(ordered,1):
 src=Image.open(R/ob["authoritative_asset_path"]).convert("RGBA")
 assert set(src.getchannel("A").get_flattened_data()).issubset({0,255}),ob["instance_id"]
 assert src.size==(ob["width"],ob["height"])
 x,y=ob["x"],ob["y"]
 reconstruct_par.alpha_composite(src,(x,y))
 a=src.getchannel("A").load()
 for yy in range(src.height):
  for xx in range(src.width):
   if a[xx,yy]:op[x+xx,y+yy]=i
 assert (R/"semantic_masks"/ob["instance_id"]/"alpha.png").is_file()
assert reconstruct_par.tobytes()==P.tobytes()
assert owner.tobytes()==O.tobytes()
# Movement and collision from actual compiled pixels (tile-foot 17x13).
blocked=[]
for ty in range(13):
 for tx in range(17):
  cx,cy=tx*32+16,ty*32+16
  if any(C.getpixel((x,y))>0 for y in range(cy-8,cy+9) for x in range(cx-8,cx+9)):blocked.append((tx,ty))
assert len(blocked)==19
spawn=(8,11)
assert spawn not in blocked and (6,8) in blocked
valid={(x,y) for y in range(13) for x in range(17)}-set(blocked)
steps={spawn:0};q=deque([spawn])
while q:
 x,y=q.popleft()
 for v in ((x+1,y),(x-1,y),(x,y+1),(x,y-1)):
  if v in valid and v not in steps:steps[v]=steps[(x,y)]+1;q.append(v)
for pos in ((2,5),(14,5),(5,8),(11,8),(5,12)):
 assert pos in steps,("NEW_PROP_POSITION_UNREACHABLE",pos)
# Negative: moved prop breaks 1:1 manifest-coordinate regression.
shifted=Image.new("RGBA",(544,416))
for ob in ordered:
 img=Image.open(R/ob["authoritative_asset_path"]).convert("RGBA")
 x=ob["x"]+(1 if ob["instance_id"]=="stone_well_src" else 0)
 shifted.alpha_composite(img,(x,ob["y"]))
shift_pixels=sum(a!=b for a,b in zip(shifted.get_flattened_data(),P.get_flattened_data()))
assert shift_pixels>50
# Negative: move one ground patch 1 px to catch Ground placement drift.
alternative=Image.open(R/"baseline_v1"/"source_candidate"/"build"/"Ground.png").convert("RGBA")
for index,item in enumerate(M["ground_decor"]):
 alternative.alpha_composite(Image.open(R/item["source"]).convert("RGBA"),
  (item["x"]+(1 if index==0 else 0),item["y"]))
ground_shift=sum(a!=b for a,b in zip(alternative.get_flattened_data(),G.get_flattened_data()))
assert ground_shift>50
native=json.loads((R/"logs"/"STYLE_V2_NATIVE_VX_VALIDATION.json").read_text(encoding="utf8"))
assert native["status"]=="STYLE_FIRST_V2_NEW_GROUND_PAR_REAL_NATIVE_VX_PASS_NOT_FORMAL"
assert native["native_pixel_probe_count"]==11 and native["new_source_images"]==9
assert all(v["outside_actor_mismatches"]==0 and v["wrong_occlusion_pixels"]==0 for v in native["native_probes"].values())
report={
 "status":"V2_STYLE_SOURCE_GROUND_PAR_NATIVE_CONTRACT_PASS_NOT_FORMAL",
 "v1_user_feedback":"POSITIVE_STYLE_REFERENCE","source_object_count":9,
 "new_PAR_objects":3,"new_Ground_patches":3,
 "ground_source_sha":M["source_ground_sha256"],
 "Ground_plus_PAR_master_exact_mismatch":0,
 "ground_decal_provenance_recompose_pixel_mismatch":0,
 "PAR_source_manifest_recompose_pixel_mismatch":0,
 "Owner_source_manifest_pixel_mismatch":0,
 "native_screenshot_checks":11,"native_background_mismatch":0,"native_illegal_occlusion_mismatch":0,
 "collision_blocked_tiles":len(blocked),"reachability_cells":len(steps),
 "negative_PAR_shift_1px_changed_pixels":shift_pixels,
 "negative_GROUND_shift_1px_changed_pixels":ground_shift,
 "formal_FS_runtime":"NOT_TESTED","visual_reference_full_village":"NOT_PASS",
 "Human_Gate_F":"NOT_RUN","rights":"PRIVATE_TEST_ONLY_NOT_COMMERCIALLY_CLEARED"
}
(R/"logs"/"V2_STYLE_SOURCE_NATIVE_CONTRACT.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print("STYLE_V2_CONTRACT_PASS",json.dumps({"objects":9,"ground_patches":3,
 "reachable":len(steps),"shift_PAR":shift_pixels,"shift_Ground":ground_shift,
 "native_screenshots":11},ensure_ascii=False),flush=True)
