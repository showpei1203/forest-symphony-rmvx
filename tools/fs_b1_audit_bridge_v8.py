from pathlib import Path
from collections import deque
from shutil import copytree,copy2,rmtree
from PIL import Image
import hashlib,json,subprocess,sys
R=Path(__file__).resolve().parent.parent
m=json.loads((R/"scene_manifest.json").read_text(encoding="utf8"))
old=json.loads((R/"scene_manifest_v7_baseline.json").read_text(encoding="utf8"))
def hashfile(p):return hashlib.sha256(p.read_bytes()).hexdigest()
objs=m["instances"];old_obj={o["id"]:o for o in old["instances"]}
assert len(objs)==49 and len(old["instances"])==48
added=[o for o in objs if o["id"] not in old_obj]
assert len(added)==1 and added[0]["id"]=="ford_timber_bridge"
assert all(o==old_obj[o["id"]] for o in objs if o["id"] in old_obj)
assert len(m["ground_decor"])==len(old["ground_decor"])==43
changed_flowers=[o["id"] for o,p in zip(m["ground_decor"],old["ground_decor"]) if o!=p]
assert changed_flowers==["flower_f"],changed_flowers
ledger=json.loads((R/"input"/"V8_BRIDGE_AND_RIVER_LEDGER.json").read_text(encoding="utf8"))
water=m["water_semantics"];upper=m["height_layers"]["timber_bridge"]
assert hashfile(R/water["source"])==water["sha256"]==ledger["river_sha256"]
bridge=added[0]
assert hashfile(R/bridge["source"])==bridge["sha256"]==ledger["bridge_sha256"]
assert bridge["draw_order"]==bridge["y"]+bridge["dimensions"][1]==527
assert (bridge["x"],bridge["y"],bridge["dimensions"])==(448,419,[160,108])
assert bridge["collision_local"]==[[3,87,15,107],[146,87,157,107]]
assert upper["level"]==2 and upper["platform_walkable_tiles"]==[[15,15],[16,15],[17,15]]
assert upper["approach_west"]==[14,15] and upper["approach_east"]==[18,15]
assert upper["actor_z"]==820 and upper["actor_visual_elevation_px"]==30
assert upper["same_xy_independent_level_at"]==[16,15]
assert set(map(tuple,water["water_deep_tiles"]))=={(x,y) for x in (15,17) for y in range(14,18)}
assert water["lower_ford_tiles"]==[[16,y] for y in range(14,18)]
assert m["height_layers"]["treehouse_deck"]==old["height_layers"]["treehouse_deck"]
master=Image.open(R/"build"/"FS_ELF_RICH_Master.png").convert("RGBA")
ground=Image.open(R/"build"/"FS_ELF_RICH_Ground.png").convert("RGBA")
par=Image.open(R/"build"/"FS_ELF_RICH_Par_COMPLETE.png").convert("RGBA")
coll=Image.open(R/"build"/"FS_ELF_RICH_Collision.png").convert("L")
prev_master=Image.open(R/"baseline"/"v7_Master.png").convert("RGBA")
prev_ground=Image.open(R/"baseline"/"v7_Ground.png").convert("RGBA")
assert ground.size==par.size==master.size==coll.size==(864,640)
assert ground.getchannel("A").getextrema()==(255,255)
assert all(ground.getpixel((x,y))==prev_ground.getpixel((x,y)) for y in range(0,420,20) for x in range(0,864,32))
tmp=ground.copy();tmp.alpha_composite(par)
assert tmp.tobytes()==master.tobytes(),("GROUND_PAR_MASTER_COMPOSITE_DIFFERENCE",)
ground_diff=sum(x!=y for x,y in zip(ground.getdata(),prev_ground.getdata()))
master_diff=sum(x!=y for x,y in zip(master.getdata(),prev_master.getdata()))
assert ground_diff>2000 and master_diff>2000
# Water is an opaque source terrain material, including the part hidden by the bridge.
surface=Image.open(R/water["source"]).convert("RGBA")
assert surface.getpixel((528,490))[3]==255
assert ground.getpixel((528,490))!=prev_ground.getpixel((528,490))
owner=Image.open(R/"outputs"/"PIXEL_OWNER_ID.png")
idx=json.loads((R/"outputs"/"INSTANCE_ID_INDEX.json").read_text(encoding="utf8"))
bridge_id=int(next(i for i,o in idx.items() if o["id"]=="ford_timber_bridge"))
visible_bridge=sum(1 for px in owner.getdata() if px==bridge_id)
assert visible_bridge>300
# Collision is generated from the same deep-water mask; ford must remain clear.
for tx,ty in water["water_deep_tiles"]:
 assert coll.getpixel((tx*32+16,ty*32+16))==255,("DEEP_WATER_COLLISION_OPEN",tx,ty)
for tx,ty in water["lower_ford_tiles"]:
 assert coll.getpixel((tx*32+16,ty*32+16))==0,("SHALLOW_FORD_CLOSED",tx,ty)
def passable(tx,ty):
 if tx<0 or ty<0 or tx>=27 or ty>=20:return False
 cx,cy=tx*32+16,ty*32+16
 return all(coll.getpixel((px,py))==0 for py in range(cy-8,cy+9) for px in range(cx-8,cx+9))
for tile in ((14,15),(18,15),(16,13),(16,14),(16,15),(16,16),(16,17),(16,18)):
 assert passable(*tile),("REQUIRED_BANK_OR_FORD_BLOCKED",tile)
def legal_lower_move(a,b):
 ax,ay=a;bx,by=b
 if abs(ax-bx)+abs(ay-by)!=1:return False
 if not passable(bx,by):return False
 if a in (tuple(t) for t in water["lower_ford_tiles"]) or b in (tuple(t) for t in water["lower_ford_tiles"]):
  return ax==bx and abs(ay-by)==1
 return True
assert legal_lower_move((16,14),(16,15))
assert legal_lower_move((16,15),(16,16))
assert not legal_lower_move((16,15),(15,15))
assert not legal_lower_move((16,15),(17,15))
assert not legal_lower_move((14,15),(15,15))
valid={(x,y) for y in range(20) for x in range(27) if passable(x,y)}
spawn=(m["spawn"]["x"]//32,m["spawn"]["y"]//32)
assert spawn in valid
q=deque([spawn]);vis={spawn:0}
while q:
 p=q.popleft()
 for cand in ((p[0]-1,p[1]),(p[0]+1,p[1]),(p[0],p[1]-1),(p[0],p[1]+1)):
  if cand not in vis and legal_lower_move(p,cand):vis[cand]=vis[p]+1;q.append(cand)
for pt in ((14,15),(18,15),(16,13),(16,14),(16,15),(16,16),(16,17),(16,18)):
 assert pt in vis,("BANK_UNREACHABLE_FROM_SPAWN",pt)
assert not any(tuple(p) in map(tuple,water["water_deep_tiles"]) for p in vis)
# Test all 49 source provenance hashes.
for o in objs+m["ground_decor"]:
 assert hashfile(R/"source"/"clean"/(o["asset_id"]+".png"))==o["sha256"],("SOURCE_CHANGED",o["id"])
# Keep old level1 upper canopy pixel owner mask native contract intact.
mask=json.loads((R/"logs"/"V7_HEIGHT_OCCLUDER_GATE.json").read_text(encoding="utf8"))
assert mask["status"]=="B1_V7_SOURCE_BACKED_UPPER_OCCLUDER_MASK_PASS"
assert mask["generated"][0]["visible_owner_pixels"]==610
assert hashfile(R/mask["generated"][0]["path"])==mask["generated"][0]["mask_sha256"]
# NEGATIVE 1: move bridge one pixel, regenerate from authoritative scene with real source.
neg=R/"negative"/"V8_TEMP_REALSHIFT"
for dn in ("source/clean","source/terrain","scripts","build/semantic_masks","work"):
 (neg/dn).mkdir(parents=True,exist_ok=True)
copytree(R/"source"/"clean",neg/"source"/"clean",dirs_exist_ok=True)
copytree(R/"source"/"terrain",neg/"source"/"terrain",dirs_exist_ok=True)
copy2(R/"scripts"/"compile_scene_v8.py",neg/"scripts"/"compile_scene_v8.py")
mut=json.loads((R/"scene_manifest.json").read_text(encoding="utf8"))
next(o for o in mut["instances"] if o["id"]=="ford_timber_bridge")["x"]+=1
(neg/"scene_manifest.json").write_text(json.dumps(mut,ensure_ascii=False),encoding="utf8")
p=subprocess.run([sys.executable,str(neg/"scripts"/"compile_scene_v8.py")],cwd=neg,capture_output=True,text=True,timeout=55)
assert p.returncode==0,("NEGATIVE_BRIDGE_RECOMPILE_ERROR",p.stderr)
shifted=Image.open(neg/"build"/"FS_ELF_RICH_Master.png").convert("RGBA")
drift=sum(a!=b for a,b in zip(shifted.getdata(),master.getdata()))
assert drift>400
# NEGATIVE 2: fake source SHA must be rejected for water and bridge.
hash_errors={}
for k in ("river","bridge"):
 mutation=json.loads((R/"scene_manifest.json").read_text(encoding="utf8"))
 if k=="river":mutation["water_semantics"]["sha256"]="0"*64
 else:next(o for o in mutation["instances"] if o["id"]=="ford_timber_bridge")["sha256"]="0"*64
 (neg/"scene_manifest.json").write_text(json.dumps(mutation,ensure_ascii=False),encoding="utf8")
 pr=subprocess.run([sys.executable,str(neg/"scripts"/"compile_scene_v8.py")],cwd=neg,capture_output=True,text=True,timeout=55)
 hash_errors[k]=pr.returncode!=0
 assert hash_errors[k],("TAMPERED_SOURCE_HASH_ACCEPTED",k)
rmtree(neg)
# Native RGSS2 real Game.exe tests check state separation and visual owner invariants.
native=json.loads((R/"logs"/"V8_NATIVE_DUAL_BRIDGE_AUDIT.json").read_text(encoding="utf8"))
assert native["status"]=="B1_V8_ISOLATED_NATIVE_DUAL_LEVEL_CROSSING_PASS_NOT_SEALED_FS"
assert len(native["bridge_interactive_gates"])==17
assert len(native["level1_interactive_gates"])==8
assert len(native["automated_native_screen_audit"])==13
assert all(v["outside_actor_mismatches"]==0 and v["wrongly_overdrawn_occlusion_pixels"]==0
 for v in native["automated_native_screen_audit"].values())
assert native["automated_native_screen_audit"]["UNDERPASS"]["occluding_object_pixels_in_actor_bbox"]>200
assert native["automated_native_screen_audit"]["UNDERPASS"]["changed_pixels_actor"]>50
assert native["automated_native_screen_audit"]["BRIDGE_UPPER_CENTRE"]["changed_pixels_actor"]>300
assert native["automated_native_screen_audit"]["BRIDGE_UPPER_CENTRE"]["foot_y"]==482
assert native["automated_native_screen_audit"]["UNDERPASS"]["foot_y"]==512
v4audit=json.loads((R/"logs"/"V4_VISUAL_MASTER_GATE.json").read_text(encoding="utf8"))
assert v4audit["independent_tiled_vs_master"]["different_pixels"]==0
assert v4audit["visual_master_positive_rgba"]["different_pixels"]==0
report={"status":"V8_BRIDGE_LAYER_PASS_ISOLATED_NOT_FORMAL",
"scene_instances":49,"ground_flora":43,
"source_bridge_sha256":bridge["sha256"],"source_water_sha256":water["sha256"],
"source_types_with_sha":len(set(o["asset_id"] for o in objs+m["ground_decor"])),
"ground_diff_from_v7":ground_diff,"master_diff_from_v7":master_diff,
"ground_plus_par_exact_rgba_diff":0,"visible_bridge_owner_pixels":visible_bridge,
"deep_water_cells":len(water["water_deep_tiles"]),"shallow_ford_cells":len(water["lower_ford_tiles"]),
"reachable_ground_lower_cells":len(vis),"reachable_from_spawn":{
 str(pt):vis[pt] for pt in ((14,15),(18,15),(16,13),(16,14),(16,15),(16,16),(16,17),(16,18))},
"upper_bridge_reachable_cells":len(upper["platform_walkable_tiles"]),
"negative_shift_bridge_1px_master_rgba_diff":drift,
"negative_sha_water_rejected":hash_errors["river"],
"negative_sha_bridge_rejected":hash_errors["bridge"],
"native_legacy_treehouse_gates":8,"native_bridge_gates":17,"native_screens":13,
"native_background_mismatch":0,"native_illegal_occlusion_mismatch":0,
"formal_fs_runtime":"NOT_RUN","human_gate_f":"NOT_RUN",
"reference_visual":"NOT_PASS","water_rights":"PRIVATE_SOURCE_TEST"}
(R/"logs"/"V8_DUAL_BRIDGE_CONTRACT_GATE.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print("V8_DUAL_BRIDGE_SOURCE_COLLISION_NATIVE_PASS",json.dumps({
 "ground_diff":ground_diff,"master_diff":master_diff,
 "lower_reachable":len(vis),"bridge_owner_px":visible_bridge,
 "negative_shift_px":drift,"native_probes":13,"native_bridge_gates":17,
 "source_rejection":hash_errors},ensure_ascii=False),flush=True)
