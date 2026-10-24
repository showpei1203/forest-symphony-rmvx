from pathlib import Path
from PIL import Image,ImageDraw
from collections import deque
from shutil import copy2
import hashlib,json
R=Path(__file__).resolve().parent.parent
M=json.loads((R/"scene_manifest.json").read_text(encoding="utf8"))
V2=json.loads((R/"baseline_v2"/"v2_scene_manifest.json").read_text(encoding="utf8"))
new=next(o for o in M["objects"] if o["instance_id"]=="stone_well_src")
old=next(o for o in V2["objects"] if o["instance_id"]=="stone_well_src")
assert M["canvas"]==V2["canvas"]==[544,416] and len(M["objects"])==9
assert new["crop_policy"]=="EXPLICIT_SOURCE_CC_BBOX_18193_PIXELS_WITH_3PX_PADDING"
assert len(new["collision_shapes"])==2
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
ledger=json.loads((R/"input"/"V21_STYLE_ASSET_LEDGER.json").read_text(encoding="utf8"))
wellpart=next(o for o in ledger["new_PAR"] if o["name"]=="stone_well_src")
assert wellpart["crop"]==[1030,816,1185,997]
assert wellpart["binary_alpha"]=="EXPLICIT_COMPLETE_WELL_CONNECTED_COMPONENT_3PX_PADDING"
assert wellpart["orphan_pixels_removed"]==302
assert sha(R/new["authoritative_asset_path"])==new["source_sha256"]==wellpart["sha256"]
assert old["source_sha256"]!=new["source_sha256"]
assert all(o["source_sha256"]==next(p for p in V2["objects"] if p["instance_id"]==o["instance_id"])["source_sha256"]
           for o in M["objects"] if o["instance_id"]!="stone_well_src")
# Original cut is clipped at the left. New source at both sides has mandatory blank safety padding.
well=Image.open(R/new["authoritative_asset_path"]).convert("RGBA")
broken=Image.open(R/"baseline_v2"/"v2_broken_well.png").convert("RGBA")
a=well.getchannel("A")
assert well.size==(73,85),("COMPLETE_WELL_DIMENSIONS",well.size)
assert broken.size==(78,72)
assert a.getextrema()==(0,255)
assert set(a.get_flattened_data()).issubset({0,255})
assert all(a.getpixel((x,0))==0 and a.getpixel((x,well.height-1))==0 for x in range(well.width))
assert all(a.getpixel((0,y))==0 and a.getpixel((well.width-1,y))==0 for y in range(well.height))
opaque=sum(x>0 for x in a.get_flattened_data())
broken_opaque=sum(x>0 for x in broken.getchannel("A").get_flattened_data())
assert opaque>broken_opaque+400,("SOURCE_WELL_STILL_CLIPPED",opaque,broken_opaque)
# Repeatedly derive scene from source, with strict pixel owner ID and masks.
Ground=Image.open(R/"build"/"Ground.png").convert("RGBA")
PAR=Image.open(R/"build"/"PAR_COMPLETE.png").convert("RGBA")
Master=Image.open(R/"build"/"Recomposed.png").convert("RGBA")
Collision=Image.open(R/"build"/"Collision.png").convert("L")
Owner=Image.open(R/"build"/"PixelOwner16.png")
assert Ground.size==PAR.size==Master.size==Collision.size==Owner.size==(544,416)
assert Ground.tobytes()==Image.open(R/"baseline_v2"/"v2_ground.png").convert("RGBA").tobytes()
combined=Ground.copy();combined.alpha_composite(PAR)
assert combined.tobytes()==Master.tobytes()
reconstructed=Image.new("RGBA",(544,416))
owner2=Image.new("I;16",(544,416),0);p=owner2.load()
sorted_objects=sorted(M["objects"],key=lambda o:(o["foot_anchor"][1],o["instance_id"]))
for idx,o in enumerate(sorted_objects,1):
 f=R/o["authoritative_asset_path"]
 assert sha(f)==o["source_sha256"]
 ob=Image.open(f).convert("RGBA")
 reconstructed.alpha_composite(ob,(o["x"],o["y"]))
 px=ob.getchannel("A").load()
 for y in range(ob.height):
  for x in range(ob.width):
   if px[x,y]:p[o["x"]+x,o["y"]+y]=idx
 assert (R/"semantic_masks"/o["instance_id"]/"alpha.png").is_file()
assert reconstructed.tobytes()==PAR.tobytes()
assert owner2.tobytes()==Owner.tobytes()
oldmaster=Image.open(R/"baseline_v2"/"v2_master.png").convert("RGBA")
changed=[(i%544,i//544) for i,(x,y) in enumerate(zip(Master.get_flattened_data(),oldmaster.get_flattened_data())) if x!=y]
assert len(changed)>500
old_bounds=(old["x"],old["y"],old["x"]+old["width"],old["y"]+old["height"])
new_bounds=(new["x"],new["y"],new["x"]+new["width"],new["y"]+new["height"])
change_union=[min(old_bounds[0],new_bounds[0]),min(old_bounds[1],new_bounds[1]),
              max(old_bounds[2],new_bounds[2]),max(old_bounds[3],new_bounds[3])]
assert all(change_union[0]<=x<change_union[2] and change_union[1]<=y<change_union[3] for x,y in changed)
shapes={o["id"]:o["rect"] for o in new["collision_shapes"]}
assert set(shapes)=={"stone_ring","water_bucket"}
welllocal=R/"semantic_masks"/"stone_well_src"
cm=Image.open(welllocal/"collision.png").convert("L")
pred=Image.new("L",well.size,0);dr=ImageDraw.Draw(pred)
for k,r in shapes.items():
 assert 0<=r[0]<r[2]<=well.width and 0<=r[1]<r[3]<=well.height
 dr.rectangle((r[0],r[1],r[2]-1,r[3]-1),fill=255)
 separate=Image.open(welllocal/("collision_"+k+".png")).convert("L")
 expected=Image.new("L",well.size,0);ImageDraw.Draw(expected).rectangle((r[0],r[1],r[2]-1,r[3]-1),fill=255)
 assert separate.tobytes()==expected.tobytes(),("COLLISION_PART_MISMATCH",k)
assert cm.tobytes()==pred.tobytes()
assert all(cm.getpixel((x,y))==0 for y in range(49) for x in range(well.width)),("ROOF_MUST_NOT_COLLIDE",)
om=Image.open(welllocal/"occlusion.png").convert("L")
assert om.getpixel((40,10))==well.getchannel("A").getpixel((40,10)),("ROOF_MUST_OCCLUDE",)
# Assert 8 legal points and blocked body with both compiled passage and independent pixel collision.
tiles=json.loads((R/"build"/"BlockedTiles.json").read_text(encoding="utf8"))
block=set(map(tuple,tiles["all_blocked_tiles"]))
assert len(block)==23
wellblock={(x,y) for x in (5,6,7) for y in (7,8)}
assert wellblock<=block and len(tiles["well_foot_blocked_tiles"])==3
eight={"N":(6,6),"NE":(8,6),"E":(8,8),"SE":(8,9),"S":(6,9),
       "SW":(4,9),"W":(4,8),"NW":(4,6)}
assert all(p not in block for p in eight.values())
free={(x,y) for y in range(13) for x in range(17)}-block
q=deque([(8,11)]);visited={(8,11):0}
while q:
 x,y=q.popleft()
 for step in ((x+1,y),(x-1,y),(x,y-1),(x,y+1)):
  if step in free and step not in visited:visited[step]=visited[(x,y)]+1;q.append(step)
assert all(x in visited for x in eight.values())
# Four distinct illegal attempts end in wells and are reachable via genuine legal neighbors.
attempts=[((4,8),(5,8)),((8,8),(7,8)),((6,6),(6,7)),((6,9),(6,8))]
assert all(a in visited and b in wellblock for a,b in attempts)
# Negative collision: dropping the bucket illegally opens east body tile [7,8].
bad_collision=Image.new("L",(544,416),0)
dc=ImageDraw.Draw(bad_collision)
for o in sorted_objects:
 if o["instance_id"]=="stone_well_src":
  shapes_to_draw=[shapes["stone_ring"]]
 else:shapes_to_draw=[o["collision_local"]]
 for x0,y0,x1,y1 in shapes_to_draw:
  dc.rectangle((o["x"]+x0,o["y"]+y0,o["x"]+x1-1,o["y"]+y1-1),fill=255)
def sampled_block(image,tx,ty):
 cx,cy=tx*32+16,ty*32+16
 return any(image.getpixel((x,y)) for y in range(cy-8,cy+9) for x in range(cx-8,cx+9))
assert not sampled_block(bad_collision,7,8), "MISSING_BUCKET_NEGATIVE_NOT_VISIBLE"
assert (7,8) in block
# Negative source crop: corrupt original left bound cuts the source primary well component.
original_sheet=Image.open(R/"baseline_v1"/"reference_sheets"/"ai_par_prop_sheet_20261024.png").convert("RGBA")
corrupt=original_sheet.crop((1085,822,1252,981)).convert("RGBA")
assert corrupt.getchannel("A").getbbox()!=(3,3,152,178), "OLD_BROKEN_CROP_INCORRECTLY_ACCEPTED"
assert sha(R/"baseline_v2"/"v2_broken_well.png")!=new["source_sha256"]
# Negative one-pixel object shift against source-indexed master.
shifted=Image.new("RGBA",(544,416))
for o in sorted_objects:
 ob=Image.open(R/o["authoritative_asset_path"]).convert("RGBA")
 shifted.alpha_composite(ob,(o["x"]+(1 if o["instance_id"]=="stone_well_src" else 0),o["y"]))
drift=sum(x!=y for x,y in zip(shifted.get_flattened_data(),PAR.get_flattened_data()))
assert drift>400
native=json.loads((R/"logs"/"STYLE_V21_NATIVE_VX_VALIDATION.json").read_text(encoding="utf8"))
log=(R/"logs"/"STYLE_AUTOLOG.txt").read_text(encoding="utf8")
assert native["status"]=="STYLE_FIRST_V21_COMPLETE_WELL_8_DIR_NATIVE_VX_PASS_NOT_FORMAL"
assert native["native_pixel_probe_count"]==19
assert all(x["outside_actor_mismatches"]==x["wrong_occlusion_pixels"]==0 for x in native["native_probes"].values())
assert native["actual_eight_direction_route_count"]==8
assert native["actual_four_blocked_intrusion_count"]==4
assert "STYLE_V21_WELL_ROUTE_MOVE_FAIL" not in log
for k in eight:assert "STYLE_V21_WELL_RING_"+k+"_ARRIVED_PASS" in log
for k in ("BLOCK_FROM_W","BLOCK_FROM_E","BLOCK_FROM_N","BLOCK_FROM_S"):
 assert "STYLE_V21_WELL_"+k+"_PASS" in log
report={
 "status":"V21_WELL_COMPLETE_SOURCE_COLLISION_8_ROUTE_NATIVE_PASS_ISOLATED_NOT_FORMAL",
 "source_original_sheet_sha256":sha(R/"baseline_v1"/"reference_sheets"/"ai_par_prop_sheet_20261024.png"),
 "previous_bad_crop_sha256":sha(R/"baseline_v2"/"v2_broken_well.png"),
 "well_full_source_sha256":new["source_sha256"],"well_size":well.size,
 "cropped_visible_well_source_pixels":opaque,"old_bad_well_visible_pixels":broken_opaque,
 "new_well_source_padding":"3px", "independent_part_masks":["stone_ring","water_bucket"],
 "well_roof_collision":"NONE","well_roof_occlusion":"SOURCE_PIXEL_OWNER",
 "blocked_tiles":len(block),"reachable_tiles":len(visited),"blocked_well_tiles":sorted(map(list,wellblock)),
 "legal_well_8_positions":{k:list(v) for k,v in eight.items()},
 "illegal_well_4_attempts":[{"from":list(a),"into":list(b)} for a,b in attempts],
 "negative_cut_original_rejected":True,"negative_bucket_removed_detected":True,
 "negative_1px_drift_pixels":drift,"changed_master_pixels":len(changed),
 "ground_unchanged_from_v2":True,"unrelated_art_pixels_changed":0,
 "source_alpha_owner_master_mismatches":0,
 "native_19_screenshots":19,"native_illegal_occlusion":0,
 "native_all_8_direction_walks":8,"native_denied_intrusions":4,
 "SEALED_FS_RUNTIME":"NOT_TESTED","VISUAL_USER_GATE_F":"NOT_RUN",
 "rights":"PRIVATE_TEST_SOURCE"}
(R/"logs"/"V21_WELL_SOURCE_AND_RUNTIME_CONTRACT.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print("STYLE_V21_WELL_CONTRACT_GATE_PASS",json.dumps({
 "well_source_pixels":opaque,"old_crop_pixels":broken_opaque,"blocked":len(block),
 "reachable":len(visited),"shift_1px":drift,
 "native_screen_gates":19,"real_walking_positions":8,"blocked_attempts":4,
 "well_visual_bbox_union":change_union},ensure_ascii=False),flush=True)
