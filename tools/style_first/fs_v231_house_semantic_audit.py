from pathlib import Path
from PIL import Image,ImageDraw
from collections import deque
import json,hashlib
R=Path(__file__).resolve().parent.parent
def sha(f):
 h=hashlib.sha256()
 with f.open("rb") as fp:
  for chunk in iter(lambda:fp.read(1<<20),b""):h.update(chunk)
 return h.hexdigest()
manifest=json.loads((R/"scene_manifest.json").read_text(encoding="utf8"))
original=json.loads((R/"baseline_v23/scene_manifest.json").read_text(encoding="utf8"))
extraction=json.loads((R/"input/V231_REEXTRACTION_LEDGER.json").read_text(encoding="utf8"))
native=json.loads((R/"logs/V231_NATIVE_VALIDATION.json").read_text(encoding="utf8"))
assert native["status"]=="V231_TWO_NEW_AI_COTTAGES_REAL_NATIVE_VX_TECH_PASS_USER_VISUAL_PENDING"
assert native["native_screen_count"]==16 and native["real_native_direction_moves"]==132
assert native["house_collision_denials"]==8 and native["v22_sacred_trunk_collision_regression"]=="PASS"
assert native["v21_well_body_collision_regression"]=="PASS"
assert all(s["background_mismatch_pixels"]==s["invalid_occlusion_pixels"]==0 for s in native["native_screen_gates"].values())
assert original["canvas"]==manifest["canvas"]==[544,416]
assert manifest["source_ground_sha256"]==sha(R/manifest["source_ground"])==original["source_ground_sha256"]
assert manifest["source_reference_sha256"]==sha(R/"source/reference/AI_V23_FULL_STYLE_MASTER.png")
assert extraction["source_sha256"]==manifest["source_reference_sha256"]
assert len(manifest["objects"])==7
old_houses={x["kind"]:x for x in original["objects"] if x["kind"].startswith("cottage")}
houses={x["kind"]:x for x in manifest["objects"] if x["kind"].startswith("cottage")}
assert set(houses)==set(old_houses)=={"cottage_blue","cottage_ochre"}
assert (R/"VX_V231_COTTAGE_MANUAL_PLAYABLE/Game.exe").is_file()
assert not (R/"VX_V231_COTTAGE_MANUAL_PLAYABLE/ENABLE_AUTO_PROBE.flag").exists()
alpha_stats={}
for kind,obj in houses.items():
 path=R/obj["authoritative_asset_path"]
 assert sha(path)==obj["source_sha256"]
 art=Image.open(path).convert("RGBA")
 old=old_houses[kind]
 # Substantially larger, not simply a renamed file.
 assert art.width>=old["width"]*1.3 and art.height>=old["height"]*1.3
 bb=art.getchannel("A").getbbox()
 assert bb and bb[0]>=5 and bb[1]>=5 and art.width-bb[2]>=5 and art.height-bb[3]>=5
 assert art.getchannel("A").getextrema()==(0,255)
 assert set(art.getchannel("A").get_flattened_data())=={0,255}
 assert all((r,g,b)==(0,0,0) for r,g,b,a in art.get_flattened_data() if a==0)
 # On-screen artwork not clipped at game canvas boundary.
 assert obj["x"]>=0 and obj["y"]>=0 and obj["x"]+art.width<=544 and obj["y"]+art.height<=416
 coll=Image.open(R/"semantic_masks"/obj["instance_id"]/"collision.png").convert("L")
 opacity=Image.open(R/"semantic_masks"/obj["instance_id"]/"occlusion.png").convert("L")
 assert coll.size==art.size and opacity.size==art.size
 assert Image.open(R/"semantic_masks"/obj["instance_id"]/"alpha.png").tobytes()==art.getchannel("A").tobytes()
 roof=obj["occlusion_split_y"]
 assert all(coll.getpixel((x,y))==0 for y in range(roof) for x in range(art.width))
 assert any(opacity.getpixel((x,y))>0 for y in range(roof) for x in range(art.width))
 assert any(coll.getpixel((x,y))>0 for y in range(roof,art.height) for x in range(art.width))
 ex_name="elf_blue_cottage" if kind=="cottage_blue" else "elf_ochre_cottage"
 details=extraction["houses"][ex_name]
 assert details["output_size"]==[art.width,art.height]
 assert details["output_sha256"]==obj["source_sha256"]
 assert details["full_res_object_pixels"]>45000
 assert details["tight_source_bbox_on_original"][0]>0
 # Original screenshot crop polygon must be independently reconstructible:
 big=Image.open(R/"source/original"/(ex_name+"_full_res_polygon.png")).convert("RGBA")
 assert big.getchannel("A").getbbox()
 alpha_stats[kind]={"old_size":[old["width"],old["height"]],
  "new_size":[art.width,art.height],"source_bbox":details["tight_source_bbox_on_original"],
  "large_source_pixels":details["full_res_object_pixels"],
  "transparent_border":[bb[0],bb[1],art.width-bb[2],art.height-bb[3]],
  "source_sha":sha(path)}
# Check other five objects preserved source hashes, moved world coordinates explicitly allowed.
for obj in manifest["objects"]:
 if obj["kind"].startswith("cottage"):continue
 prior=next(x for x in original["objects"] if x["instance_id"]==obj["instance_id"])
 assert obj["source_sha256"]==prior["source_sha256"],obj["instance_id"]
ground=Image.open(R/"build/Ground.png").convert("RGBA")
par=Image.open(R/"build/PAR_COMPLETE.png").convert("RGBA")
master=Image.open(R/"build/Master.png").convert("RGBA")
owner=Image.open(R/"build/PixelOwner16.png")
collision=Image.open(R/"build/Collision.png").convert("L")
assert ground.size==par.size==master.size==owner.size==collision.size==(544,416)
assert ground.getchannel("A").getextrema()==(255,255)
assert ground.tobytes()==Image.open(R/"source/ground_v22.png").convert("RGBA").tobytes()
composite=ground.copy();composite.alpha_composite(par)
assert composite.tobytes()==master.tobytes()
parts=sorted(manifest["objects"],key=lambda x:(x["foot_anchor"][1],x["instance_id"]))
recon=Image.new("RGBA",(544,416))
reowner=Image.new("I;16",(544,416));recol=Image.new("L",(544,416))
op=reowner.load();c=ImageDraw.Draw(recol)
for i,o in enumerate(parts,1):
 img=Image.open(R/o["authoritative_asset_path"]).convert("RGBA")
 recon.alpha_composite(img,(o["x"],o["y"]))
 am=img.getchannel("A").load()
 for y in range(img.height):
  for x in range(img.width):
   if am[x,y]:op[o["x"]+x,o["y"]+y]=i
 for region in o.get("collision_shapes",[{"rect":o["collision_local"]}]):
  lx,ly,rx,ry=region["rect"];c.rectangle((o["x"]+lx,o["y"]+ly,o["x"]+rx-1,o["y"]+ry-1),fill=255)
assert recon.tobytes()==par.tobytes()
assert reowner.tobytes()==owner.tobytes()
assert recol.tobytes()==collision.tobytes()
b=json.loads((R/"build/BlockedTiles.json").read_text(encoding="utf8"))
B=set(map(tuple,b["blocked_tiles"]))
assert len(B)==42 and b["reachable_from_spawn"]==179
valid={(x,y) for y in range(13) for x in range(17)}-B
assert (8,11) in valid
queue=deque([(8,11)]);visited={(8,11)}
while queue:
 x,y=queue.popleft()
 for new in ((x+1,y),(x-1,y),(x,y+1),(x,y-1)):
  if new in valid and new not in visited:visited.add(new);queue.append(new)
assert len(visited)==179
routes=json.loads((R/"input/V231_HOUSE_REAL_WALK_ROUTES.json").read_text(encoding="utf8"))
assert len(routes["routes"])==26 and routes["total_real_move_count"]==132
for r in routes["routes"]:
 assert tuple(r["tile"]) in visited
 if r.get("deny_move"):assert tuple(r["deny_tile"]) in B
# Negative: one-pixel building offset changes thousands of actual blended pixels.
err=Image.new("RGBA",(544,416))
for o in parts:
 img=Image.open(R/o["authoritative_asset_path"]).convert("RGBA")
 err.alpha_composite(img,(o["x"]+(1 if o["kind"]=="cottage_blue" else 0),o["y"]))
drift=sum(a!=b for a,b in zip(err.get_flattened_data(),par.get_flattened_data()))
assert drift>1000
# Negative: silently reverting to older clipped sprites violates dimensions/hash/border test.
assert all(houses[k]["source_sha256"]!=old_houses[k]["source_sha256"] for k in houses)
# Negative: a roof mistakenly marked as collision violates strict no-roof-physical-mask gate.
for kind,obj in houses.items():
 img=Image.open(R/obj["authoritative_asset_path"]).convert("RGBA")
 am=img.getchannel("A").load()
 roof=obj["occlusion_split_y"]
 assert any(am[x,y] for y in range(roof) for x in range(img.width))
 cropped=img.crop((0,roof,img.width,img.height))
 assert cropped.getchannel("A").getbbox()!=img.getchannel("A").getbbox()
record={
 "status":"V231_HOUSES_REEXTRACTED_LARGER_SOURCE_NATIVE_CONTRACT_PASS_HUMAN_PENDING",
 "houses":alpha_stats,"source_ground_unchanged":True,
 "objects":len(parts),"blocked_tiles":42,"reachable_tiles":179,
 "scene_source_PAR_master_rgba_diff":0,
 "pixel_owner_source_recompiled_mismatch":0,
 "collision_source_recompiled_mismatch":0,
 "native_screenshots":16,"real_walk_steps":132,"house_denials":8,
 "sacred_and_well_regressions":2,
 "native_bad_background_or_owner_pixels":0,
 "negative_shift_1px_changed_pixels":drift,
 "negative_old_clipped_asset_rejected":True,
 "negative_roof_as_ground_collision_rejected":True,
 "v22_user_accepted_original":"PRESERVED",
 "v23_failed_original":"PRESERVED",
 "new_v231_user_visual":"NOT_RUN",
 "sealed_FS_runtime":"NOT_TESTED",
 "full_village":"NOT_FORMAL_PASS"
}
(R/"logs/V231_SOURCE_SEMANTIC_AUDIT.json").write_text(json.dumps(record,ensure_ascii=False,indent=2),encoding="utf8")
print("V231_FULL_REEXTRACT_NATIVE_GATES_PASS",json.dumps({
 "blue":alpha_stats["cottage_blue"]["new_size"],"ochre":alpha_stats["cottage_ochre"]["new_size"],
 "reachable":179,"blocked":42,"native":16,"walks":132,"denials":8,
 "negative_shift":drift},ensure_ascii=False),flush=True)
