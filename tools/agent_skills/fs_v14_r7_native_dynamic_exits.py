"""Forest Symphony V9: Real RPG Maker VX movement and native ParSwitch203 trials.
Works ONLY in a new standalone clone; protects existing source and app instances.
"""
from __future__ import annotations
from pathlib import Path
from PIL import Image, ImageGrab, ImageChops
from rubymarshal.reader import loads
from rubymarshal.writer import writes
import ctypes,ctypes.wintypes as w,subprocess,time,re,json,hashlib,shutil,zlib
import numpy as np
ROOT=Path(r"E:\FS_AGENT_SKILLS_PILOT_20261106\A36G_V7_REAL_NATIVE_MOVEMENT_V14_20261107")
ROOT.mkdir(parents=True,exist_ok=True)
SRC=Path(r"E:\FS_AI_STUDIO_PILOT_20261104_R2\VX_NATIVE_SWITCH203_TEST")
SCENE=Path(r"E:\FS_STAGE16_A36G_R5_HOUSE_STYLE_UNIFICATION_20261104\A36G_R5_SCENE_MANIFEST.json")
OVERLAY=Path(r"E:\FS_AGENT_SKILLS_PILOT_20261106\A36G_R7_C1_FIVE_OBJECT_REAL_SOURCE_20261107\R7_RUNTIME_PAR50_5OBJECTS.png")
DEST=ROOT/"VX_MOVEMENT_AND_203_FRESH_CLONE"
if DEST.exists():raise RuntimeError("REFUSED: destination already exists, no overwrites: "+str(DEST))
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
protect=["Data/Scripts.rvdata","Data/Map050.rvdata","Overlays/Par50.png","Overlays/ground50.png"]
before={n:sha(SRC/n) for n in protect}
manifest=json.loads(SCENE.read_text(encoding="utf8"))
blocked=manifest["collision_map_29x40"]
# cardinal directions follow RGSS2: 2-down, 4-left, 6-right, 8-up
cases=[
 ("RIGHT_ROOF_EXIT",24,15,4),
 ("TREE_093_EXIT",12,5,4),
 ("TREE_010_EXIT",26,8,2),
 ("TREE_020_EXIT",35,4,4),
 ("LEFT_ROOF_EXIT",14,8,4),
]
def dest(x,y,d):
 return x+(1 if d==6 else -1 if d==4 else 0),y+(1 if d==2 else -1 if d==8 else 0)
targets={}
alpha=np.asarray(Image.open(OVERLAY).convert("RGBA"))[:,:,3]
def overlap(x,y):
 cx=x*32+16;cy=y*32+32
 return round(float(np.mean(alpha[cy-32:cy,cx-12:cx+12]>200)),4)
for name,x,y,d in cases:
 xx,yy=dest(x,y,d)
 if not (0<=xx<40 and 0<=yy<29):raise RuntimeError("out of bounds")
 if blocked[y][x] or blocked[yy][xx]:raise RuntimeError("planned sample walk is blocked "+name)
 targets[name]={"start":[x,y],"direction":d,"dest":[xx,yy],
                 "manifest_destination_blocked":bool(blocked[yy][xx]),
                 "expected_movement":not bool(blocked[yy][xx]),
                 "start_actor_mask_overlap":overlap(x,y),
                 "end_actor_mask_overlap":overlap(xx,yy)}
print("PLANNED",json.dumps(targets,ensure_ascii=False),flush=True)
shutil.copytree(SRC,DEST)
# Modify only cloned Map050 and native layers: genuine R5 tile TABLE from V12 independently proven.
root7=Path(r"E:\FS_AGENT_SKILLS_PILOT_20261106")
map50=root7/"A36G_V7_R5_NATIVE_COLLISION_REAL_MAP50_20261107"/"VX_NATIVE_40x29_COLLISION_GRID_PROBE"/"Data/Map050.rvdata"
layers=root7/"A36G_R7_C1_FIVE_OBJECT_REAL_SOURCE_20261107"
shutil.copy2(map50,DEST/"Data/Map050.rvdata")
shutil.copy2(layers/"R7_RUNTIME_PAR50_5OBJECTS.png",DEST/"Overlays/Par50.png")
shutil.copy2(layers/"R7_RUNTIME_FULL_SCENE_GROUND50.png",DEST/"Overlays/ground50.png")
assert sha(DEST/"Data/Map050.rvdata")==sha(map50)
assert sha(DEST/"Overlays/Par50.png")==sha(layers/"R7_RUNTIME_PAR50_5OBJECTS.png")
sp=DEST/"Data/Scripts.rvdata"
scripts=loads(sp.read_bytes())
ruby=zlib.decompress(scripts[483][2]).decode("utf8")
assert ruby.count("slot=(@a36f_frame-1)/frame_step")==1
assert ruby.count("    substep=(@a36f_frame-1)%frame_step")==1
ruby=ruby.replace("slot=(@a36f_frame-1)/frame_step","slot=999")
# Leave the original R2 case logic permanently inactive by choosing slot 999.
ruby_cases="["+", ".join('["%s",%d,%d,%d]' % item for item in cases)+"]"
injection=f'''
    # FS_AGENT_V14: isolated native actor movement / actual par switch verification.
    fs_cases={ruby_cases}
    fs_span=230
    fs_age=(@a36f_frame-1)-280
    fs_idx=fs_age/fs_span
    fs_phase=fs_age%fs_span
    if fs_age>=0 && fs_idx < fs_cases.size
      fs_case=fs_cases[fs_idx]
      fs_label,fs_x,fs_y,fs_dir=fs_case
      if fs_phase==0
        $game_switches[203]=false
        $game_player.moveto(fs_x,fs_y)
        $game_player.transparent=false
        A36G_MAP.log("V14_BEGIN case="+fs_label+" at="+fs_x.to_s+","+fs_y.to_s+" dir="+fs_dir.to_s)
      elsif fs_phase==30
        sp=$OverlayMap.instance_variable_get(:@par)
        A36G_MAP.log("V14_SHOT case="+fs_label+" state=OFF pos="+$game_player.x.to_s+","+$game_player.y.to_s+" par_visible="+(sp && sp.visible).to_s+" display="+$game_map.display_x.to_s+","+$game_map.display_y.to_s)
      elsif fs_phase==50
        $game_switches[203]=true
      elsif fs_phase==80
        sp=$OverlayMap.instance_variable_get(:@par)
        A36G_MAP.log("V14_SHOT case="+fs_label+" state=ON pos="+$game_player.x.to_s+","+$game_player.y.to_s+" par_visible="+(sp && sp.visible).to_s+" display="+$game_map.display_x.to_s+","+$game_map.display_y.to_s)
      elsif fs_phase==90
        bx=$game_player.x; by=$game_player.y
        tx=bx+(fs_dir==6 ? 1 : fs_dir==4 ? -1 : 0)
        ty=by+(fs_dir==2 ? 1 : fs_dir==8 ? -1 : 0)
        pass=$game_player.move_passable?(bx,by,tx,ty)
        case fs_dir
        when 2; $game_player.move_down
        when 4; $game_player.move_left
        when 6; $game_player.move_right
        when 8; $game_player.move_up
        end
        A36G_MAP.log("V14_MOVE case="+fs_label+" before="+bx.to_s+","+by.to_s+" after="+$game_player.x.to_s+","+$game_player.y.to_s+" passable="+pass.to_s+" dir="+fs_dir.to_s)
      elsif fs_phase==120
        sp=$OverlayMap.instance_variable_get(:@par)
        A36G_MAP.log("V14_SHOT case="+fs_label+" state=AFTER pos="+$game_player.x.to_s+","+$game_player.y.to_s+" par_visible="+(sp && sp.visible).to_s+" display="+$game_map.display_x.to_s+","+$game_map.display_y.to_s)
      elsif fs_phase==138
        $game_switches[203]=false
      elsif fs_phase==166
        sp=$OverlayMap.instance_variable_get(:@par)
        A36G_MAP.log("V14_SHOT case="+fs_label+" state=END_OFF pos="+$game_player.x.to_s+","+$game_player.y.to_s+" par_visible="+(sp && sp.visible).to_s+" display="+$game_map.display_x.to_s+","+$game_map.display_y.to_s)
      elsif fs_phase==184
        $game_switches[203]=true
      elsif fs_phase==205
        sp=$OverlayMap.instance_variable_get(:@par)
        A36G_MAP.log("V14_SHOT case="+fs_label+" state=END_ON pos="+$game_player.x.to_s+","+$game_player.y.to_s+" par_visible="+(sp && sp.visible).to_s+" display="+$game_map.display_x.to_s+","+$game_map.display_y.to_s)
      end
    elsif fs_age>=0 && fs_idx==fs_cases.size && fs_phase==0
      A36G_MAP.log("V14_ALL_CASES_COMPLETED")
    end
'''
ruby=ruby.replace("    substep=(@a36f_frame-1)%frame_step","    substep=(@a36f_frame-1)%frame_step\n"+injection)
scripts[483][2]=zlib.compress(ruby.encode("utf8"))
sp.write_bytes(writes(scripts))
if not all(before[n]==sha(DEST/n) for n in protect if n not in ("Data/Scripts.rvdata","Data/Map050.rvdata","Overlays/Par50.png","Overlays/ground50.png")):
 raise RuntimeError("Unsafe clone: non-script file hashes changed")
log=DEST/"A36G_VX_ACTUAL_FULL_MAP.log"
if log.exists():log.unlink()
u=ctypes.windll.user32
CB=ctypes.WINFUNCTYPE(w.BOOL,w.HWND,w.LPARAM)
def windows(pid):
 out=[]
 def cb(hwnd,lp):
  p=w.DWORD();u.GetWindowThreadProcessId(hwnd,ctypes.byref(p))
  if p.value==pid and u.IsWindowVisible(hwnd):
   s=ctypes.create_unicode_buffer(120);u.GetClassNameW(hwnd,s,119)
   out.append((int(hwnd),s.value))
  return True
 u.EnumWindows(CB(cb),0)
 return out
proc=None;found={};moves={};events=[];errors=[];ended=False
try:
 proc=subprocess.Popen([str(DEST/"Game.exe")],cwd=str(DEST))
 start=time.monotonic();seen=0
 while time.monotonic()-start < 135:
  time.sleep(.11)
  ws=windows(proc.pid)
  if any(cl=="#32770" for _,cl in ws):
   errors=ws;print("MODAL",errors,flush=True);break
  if proc.poll() is not None:
   print("PROC_EXIT",proc.returncode,flush=True);break
  if not log.exists():continue
  lines=log.read_text("utf8",errors="replace").splitlines()
  delta=lines[seen:];seen=len(lines)
  for line in delta:
   if not line.startswith("V14_"):continue
   events.append(line)
   if line.startswith("V14_ALL_CASES_COMPLETED"):
    ended=True
   shot=re.search(r"V14_SHOT case=(\w+) state=(OFF|ON|AFTER|END_OFF|END_ON) pos=(\d+),(\d+) par_visible=(\w+) display=(\d+),(\d+)",line)
   if shot:
    name,state,x,y,visible,dx,dy=shot.groups()
    hwnd=next((h for h,c in ws if c=="RGSS Player"),None)
    info={"source_log":line,"actor_tile":[int(x),int(y)],"par_visible":visible=="true",
          "display":[int(dx),int(dy)],"capture_ok":False}
    if hwnd:
     im=ImageGrab.grab(window=hwnd).convert("RGB")
     if im.size==(544,416):
      file=ROOT/(f"V14_{name}_{state}.png")
      im.save(file);info["image"]=file.name;info["sha256"]=sha(file);info["capture_ok"]=True
    found.setdefault(name,{})[state]=info
    print("SHOT",name,state,"pos",x,y,"visible",visible,"captured",info["capture_ok"],flush=True)
   movement=re.search(r"V14_MOVE case=(\w+) before=(\d+),(\d+) after=(\d+),(\d+) passable=(\w+) dir=(\d+)",line)
   if movement:
    name,bx,by,ax,ay,pas,dr=movement.groups()
    moves[name]={"before":[int(bx),int(by)],"after":[int(ax),int(ay)],"runtime_passable":pas=="true","dir":int(dr)}
    print("MOVE",name,"from",bx,by,"to",ax,ay,"passable",pas,flush=True)
  if ended and all(len(found.get(name,{}))==5 and name in moves for name in targets):break
finally:
 if proc and proc.poll() is None:
  proc.terminate()
  try:proc.wait(timeout=5)
  except subprocess.TimeoutExpired:proc.kill()
after={n:sha(SRC/n) for n in protect}
tested={}
for name,t in targets.items():
 move=moves.get(name,{})
 start=t["start"];dst=t["dest"]
 actual=move.get("after")
 expected=dst if t["expected_movement"] else start
 move_pass=move.get("before")==start and actual==expected
 screens=found.get(name,{})
 off,on,arr=screens.get("OFF"),screens.get("ON"),screens.get("AFTER")
 compare={}
 if off and on and off["capture_ok"] and on["capture_ok"]:
  a=Image.open(ROOT/off["image"]).convert("RGB")
  b=Image.open(ROOT/on["image"]).convert("RGB")
  delta=ImageChops.difference(a,b)
  bb=delta.getbbox()
  count=int(np.count_nonzero(np.any(np.asarray(delta)!=0,axis=2)))
  compare={"change_pixels":count,"diff_bbox":list(bb) if bb else None,
           "within_actor_region":bool(bb and bb[2]-bb[0]<=64 and bb[3]-bb[1]<=64)}
  combo=Image.new("RGB",(1088,416));combo.paste(a,(0,0));combo.paste(b,(544,0))
  combo.save(ROOT/f"V14_{name}_OFF_ON.png")
 state_pass=bool(off and on and off["par_visible"] is False and on["par_visible"] is True)
 tested[name]={"plan":t,"native_move":move,"movement_matches_manifest":move_pass,
   "state_203_transition":state_pass,"screens":screens,"off_on_diff":compare,
   "snapshot_camera_stable":bool(off and on and off["display"]==on["display"])}
report={"test":"A36G R7 5 real visible-source masks on actual R5 native collision Map050 + HK UOM switch203",
 "status":"COMPLETE" if ended else "PARTIAL",
 "completed_all":ended,
 "source_hashes_unchanged":before==after,"R5_Map050_verified":sha(DEST/"Data/Map050.rvdata")==sha(map50),
 "native_game_exe_started":True,
 "cases":tested,"errors":errors,"raw_runtime_events":events,
 "limitations":["manifest collision expected behavior may be inconsistent with runtime, no assumptions of PASS",
                "screenshots are timed external grabs; camera comparisons must be stable to count",
                "art quality / user acceptance not tested"],
 "formal_seal":"NO"}
report["movement_cases_match"]=sum(x["movement_matches_manifest"] for x in tested.values())
report["movement_total"]=len(tested)
report["camera_stable_OFF_ON"]=sum(x["snapshot_camera_stable"] for x in tested.values())
report["switch_203_transitions"]=sum(x["state_203_transition"] for x in tested.values())
report["status_gate"]="PASS" if ended and before==after and not errors and all(x["movement_matches_manifest"] and x["state_203_transition"] and x["snapshot_camera_stable"] for x in tested.values()) else "FAIL"
(ROOT/"FS_V14_A36G_R7_NATIVE_EXIT_QA.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print("V14_SUMMARY",json.dumps({k:report[k] for k in ["status_gate","movement_cases_match","movement_total","camera_stable_OFF_ON","switch_203_transitions","source_hashes_unchanged","completed_all","errors"]},ensure_ascii=False),flush=True)