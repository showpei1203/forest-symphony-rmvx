from pathlib import Path
from PIL import Image,ImageGrab
from rubymarshal.reader import load
import hashlib,json,subprocess,ctypes,time,re,zlib
R=Path(__file__).resolve().parent.parent
M=json.loads((R/"scene_manifest.json").read_text(encoding="utf8"))
RUN=R/"VX_V22_SACRED_GROVE_MANUAL_PLAYABLE"
AUTO=R/"VX_V22_SACRED_GROVE_AUTOPROBE"
LOG=R/"logs";LOG.mkdir(exist_ok=True)
objects=sorted(M["objects"],key=lambda x:(x["foot_anchor"][1],x["instance_id"]))
picdir=RUN/"Graphics"/"Pictures"
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
assert sha(picdir/"FS_ELF_RICH_Ground.png")==M["source_ground_sha256"]
for o in objects:
 assert sha(R/o["authoritative_asset_path"])==o["source_sha256"]
 assert sha(picdir/("FSOBJ_"+o["asset_id"]+".png"))==o["source_sha256"]
assert len(objects)==9 and any(o["kind"]=="sacred_tree" for o in objects)
game_script=load((RUN/"Data"/"Scripts.rvdata").open("rb"))
src=zlib.decompress(next(t[2] for t in game_script if t[1]==b"B1 OWNER NATIVE V3")).decode("ascii")
assert "STYLE_V22_NATIVE_4_GATES_PASS" in src and "V22_SACRED_8_DIRECTIONS_4_DENIALS_DONE" in src
assert sha(R/"build"/"Ground.png")==M["source_ground_sha256"]
master=Image.open(R/"build"/"Recomposed.png").convert("RGB")
owner=Image.open(R/"build"/"PixelOwner16.png")
assert master.size==owner.size==(544,416)
px=owner.load()
markers={
 "WEST_BEHIND":"STYLE_CAPTURE_BEHIND_WEST",
 "WEST_FRONT":"STYLE_CAPTURE_FRONT_WEST",
 "SACRED_PREVIEW_BEHIND":"STYLE_CAPTURE_BEHIND_EAST",
 "SACRED_PREVIEW_FRONT":"STYLE_CAPTURE_FRONT_EAST",
 "SPAWN":"STYLE_CAPTURE_SPAWN",
 "WELL_BEHIND":"V22_WELL_BEHIND",
 "WELL_FRONT":"V22_WELL_FRONT",
}
routes=json.loads((R/"input"/"V22_SACRED_8WAY_ROUTES.json").read_text())["routes"]
for route in routes:
 if not route.get("deny_move"):markers["RING_"+route["name"]]="V22_SACRED_RING_"+route["name"]+"_SCREEN"
assert len(markers)==15
points={
 "WEST_BEHIND":[2,2],"WEST_FRONT":[2,5],
 "SACRED_PREVIEW_BEHIND":[14,2],"SACRED_PREVIEW_FRONT":[14,5],
 "SPAWN":[8,11],"WELL_BEHIND":[6,6],"WELL_FRONT":[6,9]
}
for r in routes:
 if not r.get("deny_move"):points["RING_"+r["name"]]=r["tile"]
def run(p,need,capture,timeout=140):
 log=p/"FS_RICH_VX_LOG.txt";log.write_text("V22_RUN_START\n",encoding="ascii")
 h=0;snaps={}
 proc=subprocess.Popen([str(p/"Game.exe")],cwd=p,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
 try:
  end=time.monotonic()+timeout
  content=""
  while time.monotonic()<end:
   time.sleep(.06)
   content=log.read_text(encoding="ascii",errors="replace")
   if capture:
    if not h:h=ctypes.windll.user32.FindWindowW(None,"FS_STYLE_FIRST_V22_SACRED_GROVE")
    for key,mark in markers.items():
     if key not in snaps and mark in content and h:
      out=LOG/("V22_NATIVE_"+key+".png")
      ImageGrab.grab(window=h).save(out)
      snaps[key]=out
      print("V22_REAL_NATIVE_FRAME",key,flush=True)
   if all(t in content for t in need) and (not capture or len(snaps)==len(markers)):break
   if proc.poll() is not None:break
  missing=[t for t in need if t not in content]
  assert not missing,("V22_GAME_NOT_RUNNING_OR_LOG_MISSING",missing,content[-1600:])
  if capture:assert len(snaps)==len(markers),("NATIVE_SCREENSHOT_CAPTURE_MISSING",set(markers)-set(snaps))
  return content,snaps
 finally:
  if proc.poll() is None:
   proc.terminate()
   try:proc.wait(timeout=3)
   except subprocess.TimeoutExpired:proc.kill()
assert not (RUN/"ENABLE_AUTO_PROBE.flag").exists()
manual,_=run(RUN,["STYLE_V22_NATIVE_4_GATES_PASS","RICH_RUNTIME_100_FRAMES"],False,timeout=18)
assert "STYLE_CAPTURE_" not in manual
assert "STYLE_VX_LAYERS ground=544x416 props=9" in manual
(LOG/"V22_MANUAL_BOOT.txt").write_text(manual,encoding="utf8")
print("V22_MANUAL_VX_9_REAL_SPRITES_PASS",flush=True)
auto,images=run(AUTO,["STYLE_V22_NATIVE_4_GATES_PASS","V22_WELL_BODY_BLOCKED_PASS",
 "V22_SACRED_8_DIRECTIONS_4_DENIALS_DONE"],True,timeout=150)
(LOG/"V22_NATIVE_AUTOLOG.txt").write_text(auto,encoding="utf8")
assert "V22_ROUTE_MOVE_FAIL" not in auto
assert "V22_SACRED_RING_" in auto and "_ARRIVED_FAIL" not in auto
for item in routes:
 n=item["name"]
 if item.get("deny_move"):
  assert "V22_SACRED_"+n+"_PASS target="+",".join(map(str,item["deny_tile"])) in auto,("TRUNK_COLLISION_REAL_NATIVE_FAIL",item)
 else:
  assert "V22_SACRED_RING_"+n+"_ARRIVED_PASS tile="+",".join(map(str,item["tile"])) in auto,("TRUNK_EIGHT_WAY_REAL_MOVE_FAIL",item)
assert auto.count("V22_ROUTE_MOVE_PASS ")==sum(len(r["moves"]) for r in routes)
assert "V22_WELL_BODY_BLOCKED_PASS" in auto
results={}
for key,(tx,ty) in points.items():
 mark=markers[key]
 m=re.search(re.escape(mark)+r" camera=(\d+),(\d+) foot=(\d+)",auto)
 assert m,("ACTUAL_NATIVE_COORD_LOG_ABSENT",key)
 cx,cy,foot=map(int,m.groups())
 assert (cx,cy)==(0,0) and foot==(ty+1)*32,(key,cx,cy,foot)
 img=Image.open(images[key]).convert("RGB")
 assert img.size==(544,416)
 live=img.load();expected=master.load()
 actor_center=tx*32+16
 wrong_background=0;wrong_overdraw=0;cover=0;changed=0
 for y in range(416):
  for x in range(544):
   actor=(actor_center-32<=x<actor_center+32 and foot-72<=y<foot+8)
   if live[x,y]!=expected[x,y]:
    changed+=1
    if not actor:wrong_background+=1
   if actor:
    idx=px[x,y]
    if idx and objects[idx-1]["foot_anchor"][1]>=foot:
     cover+=1
     if live[x,y]!=expected[x,y]:wrong_overdraw+=1
 assert wrong_background==0,("NEW_STYLE_GROUND_PIXEL_MISMATCH",key,wrong_background)
 assert wrong_overdraw==0,("SACRED_CANOPY_UNAUTHORIZED_OVERDRAW",key,wrong_overdraw)
 if key=="RING_N":assert cover>=300,("SACRED_CANOPY_NOT_COVERING_ACTOR",cover)
 if key=="RING_S":assert changed>=100,("ACTOR_NOT_VISIBLE_IN_FRONT",changed)
 results[key]={"tile":[tx,ty],"actor_foot":foot,"changed_actor_pixels":changed,
  "source_occluding_owner_pixels":cover,"background_mismatch_pixels":wrong_background,
  "invalid_occlusion_pixels":wrong_overdraw}
 print("V22_REAL_VX_PIXEL_GATE",key,"changed",changed,"covered",cover,flush=True)
report={"status":"V22_SACRED_GROVE_NEW_STYLE_TRUE_NATIVE_VX_PASS_ISOLATED_NOT_FORMAL",
 "actual_new_source_in_game":True,"gameexe":str(RUN/"Game.exe"),
 "source_manifest_sha256":sha(R/"scene_manifest.json"),
 "new_sacred_source_sha256":next(o["source_sha256"] for o in objects if o["kind"]=="sacred_tree"),
 "native_source_png_sha_verified":9,
 "real_native_frames":len(results),"native_pixel_gates":results,
 "actual_walk_steps":sum(len(r["moves"]) for r in routes),
 "eight_legal_sacred_surroundings":"PASS",
 "four_illegal_trunk_intrusions":"PASS",
 "v21_well_body_collision_regression":"PASS",
 "native_wrong_background_pixels":0,"native_wrong_occlusion_pixels":0,
 "native_manual_gameexe_boot":"PASS",
 "reused_style_ground":"V21_USER_ACCEPTED",
 "sealed_FS":"NOT_TESTED","human_new_sacred_visual":"NOT_RUN",
 "height_level1_2":"NOT_INTEGRATED","rights":"PRIVATE_TEST_ONLY"}
(LOG/"V22_NATIVE_VALIDATION.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print("V22_SACRED_REAL_NATIVE_VX_PASS",json.dumps({"frames":len(results),
 "true_walk_steps":report["actual_walk_steps"],"denials":4,
 "well_retest":"PASS","background_mismatch":0},ensure_ascii=False),flush=True)
