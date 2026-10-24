from pathlib import Path
from PIL import Image,ImageGrab
from rubymarshal.reader import load
from collections import Counter
import hashlib,json,zlib,ctypes,subprocess,time,re
R=Path(__file__).resolve().parent.parent
P=R.parent
M=json.loads((R/"scene_manifest.json").read_text(encoding="utf8"))
PATHS=json.loads((R/"input"/"V231_HOUSE_REAL_WALK_ROUTES.json").read_text(encoding="utf8"))
MAN=R/"VX_V231_COTTAGE_MANUAL_PLAYABLE"
AUTO=R/"VX_V231_COTTAGE_AUTOPROBE"
L=R/"logs";L.mkdir(exist_ok=True)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
objs=sorted(M["objects"],key=lambda x:(x["foot_anchor"][1],x["instance_id"]))
G=MAN/"Graphics"/"Pictures"/"FS_ELF_RICH_Ground.png"
assert sha(G)==M["source_ground_sha256"]
for o in objs:
 assert sha(R/o["authoritative_asset_path"])==o["source_sha256"]
 assert sha(MAN/"Graphics"/"Pictures"/("FSOBJ_"+o["asset_id"]+".png"))==o["source_sha256"]
assert len(objs)==7
ruby=zlib.decompress(next(x[2] for x in load((MAN/"Data"/"Scripts.rvdata").open("rb"))
 if x[1]==b"B1 OWNER NATIVE V3")).decode("ascii")
assert "V231_COTTAGES_ALL_16_STANDS_8_INTRUSIONS_2_REGRESSIONS_DONE" in ruby
assert "V231_COTTAGES_NATIVE_BASE_GATES_PASS" in ruby
marks={r["name"]:"V231_SCREEN_"+r["name"] for r in PATHS["routes"] if not r.get("deny_move")}
assert len(marks)==16
def run(where,required,capture=False,timeout=130):
 logfile=where/"FS_RICH_VX_LOG.txt"
 logfile.write_text("V231_RUN_BEGIN\n",encoding="ascii")
 proc=subprocess.Popen([str(where/"Game.exe")],cwd=where,
    stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
 frames={};hwnd=0;content=""
 try:
  deadline=time.monotonic()+timeout
  while time.monotonic()<deadline:
   time.sleep(.045)
   content=logfile.read_text(encoding="ascii",errors="replace")
   if capture:
    if not hwnd:hwnd=ctypes.windll.user32.FindWindowW(None,"FS_STYLE_FIRST_V2311_COTTAGE_PILOT")
    for name,mark in marks.items():
     if name not in frames and mark+" camera=" in content and hwnd:
      img=L/("V231_NATIVE_"+name+".png")
      ImageGrab.grab(window=hwnd).save(img);frames[name]=img
      print("V231_NATIVE_SCREENSHOT",name,flush=True)
   if all(x in content for x in required) and (not capture or len(frames)==len(marks)):break
   if proc.poll() is not None:break
  missing=[x for x in required if x not in content]
  assert not missing,("GAME_CRASH_OR_NATIVE_GATE_MISSING",where.name,missing,content[-1600:])
  if capture:assert len(frames)==len(marks),("MISSING_SCENE_IMAGES",set(marks)-set(frames))
  return content,frames
 finally:
  if proc.poll() is None:
   proc.terminate()
   try:proc.wait(timeout=3)
   except subprocess.TimeoutExpired:proc.kill()
assert not (MAN/"ENABLE_AUTO_PROBE.flag").exists()
manual,_=run(MAN,["V231_COTTAGES_NATIVE_BASE_GATES_PASS","RICH_RUNTIME_100_FRAMES"],False,timeout=22)
assert "V231_SCREEN_" not in manual
assert "STYLE_VX_LAYERS ground=544x416 props=7" in manual
(L/"V231_MANUAL_LOG.txt").write_text(manual,encoding="utf8")
print("V231_NATIVE_MANUAL_PLAYABLE_BOOT_PASS",flush=True)
auto,images=run(AUTO,["V231_COTTAGES_NATIVE_BASE_GATES_PASS",
 "V231_COTTAGES_ALL_16_STANDS_8_INTRUSIONS_2_REGRESSIONS_DONE"],True,timeout=155)
(L/"V231_NATIVE_AUTOLOG.txt").write_text(auto,encoding="utf8")
assert "V231_STEP_FAIL" not in auto and "V231_STAND_" in auto and "_FAIL tile=" not in auto
assert "V231_BAD_DIRECTION" not in auto
steps=sum(len(r["moves"]) for r in PATHS["routes"])
assert auto.count("V231_STEP_PASS ")==steps,(auto.count("V231_STEP_PASS "),steps)
for r in PATHS["routes"]:
 name=r["name"]
 if r.get("deny_move"):
  expected="V231_"+name+"_PASS forbidden="+",".join(map(str,r["deny_tile"]))
 else:
  expected="V231_STAND_"+name+"_PASS tile="+",".join(map(str,r["tile"]))
 assert expected in auto,("NATIVE_REAL_WALK_OR_COLLISION_FAILED",r)
master=Image.open(R/"build"/"Master.png").convert("RGB")
owner=Image.open(R/"build"/"PixelOwner16.png")
pixels=owner.load()
assert master.size==owner.size==(544,416)
audit={}
for r in PATHS["routes"]:
 if r.get("deny_move"):continue
 key=r["name"];tx,ty=r["tile"]
 m=re.search(re.escape(marks[key])+r" camera=(\d+),(\d+) foot=(\d+)",auto)
 assert m,("NATIVE_COORD_MISSING",key)
 camx,camy,foot=map(int,m.groups())
 assert (camx,camy)==(0,0) and foot==(ty+1)*32,(key,camx,camy,foot)
 real=Image.open(images[key]).convert("RGB")
 assert real.size==master.size
 pix=real.load();base=master.load()
 center=tx*32+16
 bg=wrong=cover=changed=0
 for y in range(416):
  for x in range(544):
   actor=(center-32<=x<center+32 and foot-72<=y<foot+12)
   if pix[x,y]!=base[x,y]:
    changed+=1
    if not actor:bg+=1
   if actor:
    idx=pixels[x,y]
    if idx and objs[idx-1]["foot_anchor"][1]>=foot:
     cover+=1
     if pix[x,y]!=base[x,y]:wrong+=1
 assert bg==0,("V231_BACKGROUND_MISMATCH",key,bg)
 assert wrong==0,("V231_FOREGROUND_OWNER_MISMATCH",key,wrong)
 if key in ("BLUE_N","OCHRE_N"):assert cover>100,("HOUSE_ROOF_OCCLUSION_NOT_TESTED",key,cover)
 if key in ("BLUE_S","OCHRE_S"):assert changed>100,("DOOR_APPROACH_CHARACTER_HIDDEN",key,changed)
 audit[key]={"tile":[tx,ty],"native_actor_foot":foot,"changed_actor_pixels":changed,
             "occluding_owner_pixels":cover,"background_mismatch_pixels":bg,
             "invalid_occlusion_pixels":wrong}
 print("V231_REAL_NATIVE_PIXEL_GATE",key,"changed",changed,"occluded",cover,flush=True)
report={
 "status":"V231_TWO_NEW_AI_COTTAGES_REAL_NATIVE_VX_TECH_PASS_USER_VISUAL_PENDING",
 "real_gameexe":str(MAN/"Game.exe"),"v22_ground_reused":True,
 "new_cottages":2,"total_source_PAR":7,"native_screen_count":len(audit),"source_crop_and_scale":"V231_FULL_MASTER_RECROPPED",
 "native_screen_gates":audit,"real_native_direction_moves":steps,
 "real_eight_way_stands_per_cottage":8,"house_collision_denials":8,
 "v22_sacred_trunk_collision_regression":"PASS",
 "v21_well_body_collision_regression":"PASS",
 "source_png_verified":7,"native_background_mismatch":0,
 "native_wrong_foreground_pixel":0,
 "manual_no_automated_teleport":True,"human_v23_visual":"NOT_RUN",
 "full_village":"NOT_FORMAL_PASS","formal_FS":"NOT_TESTED","rights":"PRIVATE_TEST_ONLY"
}
(L/"V231_NATIVE_VALIDATION.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print("V231_REAL_NATIVE_VX_ARCHITECTURE_PASS",json.dumps({
 "frames":len(audit),"actual_steps":steps,"denied_entries":10,
 "houses":2,"wrong_bg":0,"wrong_owner":0},ensure_ascii=False),flush=True)
