from pathlib import Path
from PIL import Image,ImageGrab
from collections import Counter
import subprocess,ctypes,time,re,hashlib,json
R=Path(__file__).resolve().parent.parent
P=R.parent
MAN=R/"VX_STYLE_FIRST_V21_WELL_FIXED_PLAYABLE"
AUTO=R/"VX_STYLE_FIRST_V21_WELL_FIXED_AUTOPROBE"
LOG=R/"logs"
LOG.mkdir(exist_ok=True)
master=Image.open(R/"build"/"Recomposed.png").convert("RGB")
manifest=json.loads((R/"scene_manifest.json").read_text(encoding="utf8"))
assert master.size==(544,416)
objs=sorted(manifest["objects"],key=lambda ob:(ob["foot_anchor"][1],ob["instance_id"]))
# Native source picture integrity is mandatory, not optional.
g=MAN/"Graphics"/"Pictures"/"FS_ELF_RICH_Ground.png"
p=R/"build"/"Ground.png"
assert hashlib.sha256(g.read_bytes()).digest()==hashlib.sha256(p.read_bytes()).digest()
for ob in objs:
 actual=MAN/"Graphics"/"Pictures"/("FSOBJ_"+ob["asset_id"]+".png")
 assert hashlib.sha256(actual.read_bytes()).hexdigest()==ob["source_sha256"]
print("STYLE_NATIVE_SPRITE_SOURCE_HASHED",len(objs),flush=True)
# Pixel Owner must be derived from the exact same source pixels and depth order.
owner=Image.new("I",(544,416),0)
px=owner.load()
for idx,o in enumerate(objs,1):
 sprite=Image.open(R/o["authoritative_asset_path"]).convert("RGBA")
 alpha=sprite.getchannel("A").load()
 for y in range(sprite.height):
  for x in range(sprite.width):
   wx,wy=o["x"]+x,o["y"]+y
   if 0<=wx<544 and 0<=wy<416 and alpha[x,y]:
    px[wx,wy]=idx

def run(where,need,capture=False,timeout=35):
 f=where/"FS_RICH_VX_LOG.txt"
 if f.is_file():f.write_text("STYLE_RUN_START\n",encoding="ascii")
 proc=subprocess.Popen([str(where/"Game.exe")],cwd=where,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
 shots={}
 hwnd=0
 marks={
  "BEHIND_WEST":"STYLE_CAPTURE_BEHIND_WEST",
  "FRONT_WEST":"STYLE_CAPTURE_FRONT_WEST",
  "BEHIND_EAST":"STYLE_CAPTURE_BEHIND_EAST",
  "FRONT_EAST":"STYLE_CAPTURE_FRONT_EAST",
  "SPAWN":"STYLE_CAPTURE_SPAWN",
  "WELL_BEHIND":"STYLE_V2_CAPTURE_WELL_BEHIND",
  "WELL_FRONT":"STYLE_V2_CAPTURE_WELL_FRONT",
  "BOARD_BEHIND":"STYLE_V2_CAPTURE_BOARD_BEHIND",
  "BOARD_FRONT":"STYLE_V2_CAPTURE_BOARD_FRONT",
  "HEDGE_BEHIND":"STYLE_V2_CAPTURE_HEDGE_BEHIND",
  "HEDGE_FRONT":"STYLE_V2_CAPTURE_HEDGE_FRONT",
  "WELL_RING_N":"STYLE_V21_WELL_RING_N_CAPTURE",
  "WELL_RING_NE":"STYLE_V21_WELL_RING_NE_CAPTURE",
  "WELL_RING_E":"STYLE_V21_WELL_RING_E_CAPTURE",
  "WELL_RING_SE":"STYLE_V21_WELL_RING_SE_CAPTURE",
  "WELL_RING_S":"STYLE_V21_WELL_RING_S_CAPTURE",
  "WELL_RING_SW":"STYLE_V21_WELL_RING_SW_CAPTURE",
  "WELL_RING_W":"STYLE_V21_WELL_RING_W_CAPTURE",
  "WELL_RING_NW":"STYLE_V21_WELL_RING_NW_CAPTURE"}
 try:
  deadline=time.monotonic()+timeout
  s=""
  while time.monotonic()<deadline:
   time.sleep(.06)
   s=f.read_text(encoding="ascii",errors="replace")
   if capture:
    if not hwnd:hwnd=ctypes.windll.user32.FindWindowW(None,"FS_STYLE_FIRST_V21_WELL_FIXED_PLAYABLE")
    for key,mark in marks.items():
     if key not in shots and mark in s and hwnd:
      path=LOG/("STYLE_V21_NATIVE_"+key+".png")
      ImageGrab.grab(window=hwnd).save(path)
      shots[key]=path
      print("STYLE_VX_NATIVE_SCREENSHOT",key,flush=True)
   if all(mark in s for mark in need) and (not capture or len(shots)==len(marks)): break
   if proc.poll() is not None:break
  assert all(mark in s for mark in need),("GAME_CRASH_OR_MISSING_LOG",where.name,s[-1700:])
  if capture:assert len(shots)==19,("CAPTURE_MISSING",list(shots))
  return s,shots
 finally:
  if proc.poll() is None:
   proc.terminate()
   try:proc.wait(timeout=3)
   except subprocess.TimeoutExpired:proc.kill()

manual,discard=run(MAN,["STYLE_V2_NATIVE_4_GATES_PASS","RICH_RUNTIME_100_FRAMES"],timeout=15)
assert "STYLE_CAPTURE_" not in manual, "MANUAL_UNWANTED_AUTO_TELEPORT"
assert "STYLE_VX_LAYERS ground=544x416 props=9" in manual
(LOG/"STYLE_MANUAL_SMOKE.txt").write_text(manual,encoding="utf8")
print("STYLE_VX_MANUAL_BOOT_MOVEMENT_COLLISION_PASS",flush=True)
automated,images=run(AUTO,["STYLE_V2_NATIVE_4_GATES_PASS", "STYLE_V2_WELL_COLLISION_BLOCKED_PASS","STYLE_V2_NATIVE_PROBES_DONE",
  "STYLE_V21_WELL_8_STANDS_AND_4_INTRUSIONS_DONE"],capture=True,timeout=135)
(LOG/"STYLE_AUTOLOG.txt").write_text(automated,encoding="utf8")
# Exact RGSS2 8-direction path gates are proved by actual move_up/down/left/right
# from start tile, checking each coordinate and four denied moves.
routes=json.loads((R/"input"/"V21_WELL_8_DIRECTION_NATIVE_ROUTES.json").read_text())["routes"]
for item in routes:
 name=item["name"];x,y=item["tile"]
 if name.startswith("BLOCK_FROM"):
  assert ("STYLE_V21_WELL_"+name+"_PASS target="+",".join(map(str,item["deny_tile"]))) in automated,("ILLEGAL_PENETRATION_UNDETECTED",item)
 else:
  assert ("STYLE_V21_WELL_RING_"+name+"_ARRIVED_PASS tile="+str(x)+","+str(y)) in automated,("REAL_MOVEMENT_8_DIRECTION_FAILED",item)
assert "STYLE_V21_WELL_ROUTE_MOVE_FAIL" not in automated, "REAL_WALK_PATH_CONTAINS_A_BLOCKED_STEP"
assert "STYLE_V21_WELL_RING_" in automated and "ARRIVED_FAIL" not in automated
assert "STYLE_V21_WELL_8_STANDS_AND_4_INTRUSIONS_DONE" in automated
results={}
pts={"BEHIND_WEST":(2,2),"FRONT_WEST":(2,5),
      "BEHIND_EAST":(14,2),"FRONT_EAST":(14,5),"SPAWN":(8,11),
     "WELL_BEHIND":(6,6),"WELL_FRONT":(6,9),
     "BOARD_BEHIND":(11,5),"BOARD_FRONT":(11,8),
     "HEDGE_BEHIND":(5,10),"HEDGE_FRONT":(5,12),
      "WELL_RING_N":(6,6),
      "WELL_RING_NE":(8,6),
      "WELL_RING_E":(8,8),
      "WELL_RING_SE":(8,9),
      "WELL_RING_S":(6,9),
      "WELL_RING_SW":(4,9),
      "WELL_RING_W":(4,8),
      "WELL_RING_NW":(4,6)}
for key,(tx,ty) in pts.items():
 actual=Image.open(images[key]).convert("RGB")
 assert actual.size==(544,416),(key,actual.size)
 prefix=("STYLE_V21_WELL_RING_" if key.startswith("WELL_RING_") else
         ("STYLE_V2_CAPTURE_" if key.startswith(("WELL_","BOARD_","HEDGE_")) else "STYLE_CAPTURE_"))
 m=re.search((("STYLE_V21_WELL_RING_"+key[10:]+"_CAPTURE") if key.startswith("WELL_RING_") else prefix+key)
             +r" camera=(\d+),(\d+) foot=(\d+)",automated)
 assert m,("MISSING_EXACT_NATIVE_COORDS",key)
 camx,camy,foot=map(int,m.groups())
 assert (camx,camy)==(0,0),(key,camx,camy)
 assert foot==(ty+1)*32,(key,foot)
 cx=tx*32+16
 a=actual.load();b=master.load()
 outside=0;wrong_foreground=0;covered=0;changed=0
 for y in range(416):
  for x in range(544):
   actor=(cx-32<=x<cx+32 and foot-72<=y<foot+8)
   if a[x,y]!=b[x,y]:
    changed+=1
    if not actor:outside+=1
   if actor:
    owner_index=px[x,y]
    if owner_index and objs[owner_index-1]["foot_anchor"][1] >= foot:
     covered+=1
     if a[x,y]!=b[x,y]:wrong_foreground+=1
 assert outside==0,("NATIVE_NEW_STYLE_BACKGROUND_MISMATCH",key,outside)
 assert wrong_foreground==0,("NATIVE_OWNER_DEPTH_MISMATCH",key,wrong_foreground)
 if key.startswith("BEHIND"):assert covered>=100,("TREE_CANOPY_OCCLUSION_NOT_TESTED",key,covered)
 if key.startswith("FRONT"):assert changed>130,("PLAYER_NOT_VISIBLE_FRONT",key,changed)
 if key.endswith("_BEHIND"):assert covered>30,("NEW_PROP_OCCLUSION_NOT_TESTED",key,covered)
 if key.endswith("_FRONT"):assert changed>100,("NEW_PROP_FRONT_NOT_VISIBLE",key,changed)
 results[key]={"tile":[tx,ty],"foot_y":foot,"actual_changed_pixels":changed,
   "outside_actor_mismatches":outside,"occluding_source_owner_pixels":covered,
   "wrong_occlusion_pixels":wrong_foreground}
 print("STYLE_VX_IMAGE_PIXEL_GATE",key,changed,"covered",covered,flush=True)
report={
 "status":"STYLE_FIRST_V21_COMPLETE_WELL_8_DIR_NATIVE_VX_PASS_NOT_FORMAL",
 "native_game_exe":str(MAN/"Game.exe"),
 "template_from":"Style-first v1 approved native source template; all 9 objects and Ground re-imported from v2 Manifest",
 "manifest_sha256":hashlib.sha256((R/"scene_manifest.json").read_bytes()).hexdigest(),
 "source_ground_sha256":hashlib.sha256(p.read_bytes()).hexdigest(),
  "new_source_images":9,"new_ground_patches":3,"actual_eight_direction_route_count":8,
 "actual_four_blocked_intrusion_count":4,"ground_size":[544,416],
 "manual_runtime_gate":"PASS","native_move_and_collision":"PASS",
 "native_pixel_probe_count":19,
 "native_probes":results,"new_ground_actual_in_game":True,
 "new_props_actual_in_game":True,"complete_well_source_in_game":True,
 "sealed_fs_runtime":"NOT_TESTED","human_gate_f":"NOT_TESTED",
 "visual_benchmark":"NOT_FORMAL_PASS",
}
(LOG/"STYLE_V21_NATIVE_VX_VALIDATION.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print("STYLE_FIRST_NATIVE_VX_PASS",json.dumps({"probes":len(results),"mismatch":sum(a["outside_actor_mismatches"] for a in results.values()),"wrong_occlusion":sum(a["wrong_occlusion_pixels"] for a in results.values()),"new_source_assets":9,"real_eight_way_routes":8},ensure_ascii=False),flush=True)
