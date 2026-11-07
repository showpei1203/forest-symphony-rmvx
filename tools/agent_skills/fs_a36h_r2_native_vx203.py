"""A36G R7 five-source native RGSS2 ParSwitch203 real walkable tile tests.
One isolated clone; full R5 collision Map050 (V12 native-verified), original R5 RGB full scene, 5 object source-owned RGB mask.
A positive test must be on a manifest-walkable tile, 203 OFF/ON and same camera.
"""
from pathlib import Path
from PIL import Image,ImageGrab,ImageChops,ImageDraw
from rubymarshal.reader import loads
from rubymarshal.writer import writes
import ctypes,ctypes.wintypes as w,subprocess,time,re,json,hashlib,shutil,zlib
import numpy as np
BASE=Path(r"E:\FS_AGENT_SKILLS_PILOT_20261106")
ROOT=BASE/"A36H_R2_NATIVE_VISUAL_203_QA_20261107"
SRC=Path(r"E:\FS_AI_STUDIO_PILOT_20261104_R2\VX_NATIVE_SWITCH203_TEST")
NEW=BASE/"A36H_VISUAL_ART_REPAIR_20261107"/"A36H_R2_GROUND3_PALETTE_MATCH"
SAMPLES=BASE/"A36G_R7_C1_FIVE_OBJECT_REAL_SOURCE_20261107"
R5=Path(r"E:\FS_STAGE16_A36G_R5_HOUSE_STYLE_UNIFICATION_20261104")
MAP=BASE/"A36G_V7_R5_NATIVE_COLLISION_REAL_MAP50_20261107"/"VX_NATIVE_40x29_COLLISION_GRID_PROBE"/"Data/Map050.rvdata"
if ROOT.exists():raise RuntimeError("FAIL CLOSED: native proof directory already exists")
ROOT.mkdir(parents=True)
r=json.loads((SAMPLES/"R7_C1_FIVE_OBJECTS_SOURCE_QA.json").read_text("utf8"))
m=json.loads((R5/"A36G_R5_SCENE_MANIFEST.json").read_text("utf8"))
blocked=m["collision_map_29x40"]
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
protected=[SRC/p for p in ("Data/Scripts.rvdata","Data/Map050.rvdata","Overlays/ground50.png","Overlays/Par50.png")]
original_sha={str(p):sha(p) for p in protected}
all_source_sha={o["id"]:o["source_sha256"] for o in r["selected_sources"]}
test_cases=[]
for ob in r["selected_sources"]:
 id=ob["id"]
 best=r["walkable_test_candidates"][id]["walkable_top10"]
 assert best and best[0]["overlap"]>=.25,id
 x,y=best[0]["tile"]
 assert blocked[y][x]==0
 test_cases.append((id,x,y,round(best[0]["overlap"],4)))
test_cases.append(("CLEAR_NEGATIVE",20,14,0))
assert blocked[14][20]==0
alpha=np.asarray(Image.open(NEW/"A36H_R2_RUNTIME_SOURCE_OWNED_5_PAR.png").convert("RGBA"))[:,:,3]
assert not np.any(alpha[14*32:15*32,20*32:21*32]),"negative control not empty"
# clone and replace only its local Map50, Ground50, PAR50 and test logic.
dest=ROOT/"VX_H2_REAL_NATIVE_5OBJECTS_R5_COLLISION"
shutil.copytree(SRC,dest)
shutil.copy2(MAP,dest/"Data/Map050.rvdata")
shutil.copy2(NEW/"A36H_R2_RUNTIME_FULL_SCENE_GROUND.png",dest/"Overlays/ground50.png")
shutil.copy2(NEW/"A36H_R2_RUNTIME_SOURCE_OWNED_5_PAR.png",dest/"Overlays/Par50.png")
assert sha(dest/"Overlays/Par50.png")==sha(NEW/"A36H_R2_RUNTIME_SOURCE_OWNED_5_PAR.png")
assert sha(dest/"Data/Map050.rvdata")==sha(MAP)
# verify native tile binary Map050 is actually R5, not A36F
import struct
table=loads((dest/"Data/Map050.rvdata").read_bytes()).attributes["@data"]._private_data
assert struct.unpack("<5I",table[:20])==(3,40,29,3,3480)
ids=struct.unpack("<3480H",table[20:])
assert all(ids[x+40*y+2320]==(768 if blocked[y][x] else 769) for y in range(29) for x in range(40))
sfile=dest/"Data/Scripts.rvdata"
scripts=loads(sfile.read_bytes())
ruby=zlib.decompress(scripts[483][2]).decode("utf8")
assert ruby.count("slot=(@a36f_frame-1)/frame_step")==1
assert ruby.count("    @a36f_frame+=1")==1
ruby=ruby.replace("slot=(@a36f_frame-1)/frame_step","slot=999")
data="[ "+",".join('["%s",%d,%d]'%(name,x,y) for name,x,y,_ in test_cases)+" ]"
injection=f'''
    fs7_cases={data}
    fs7_age=(@a36f_frame-1)-300
    fs7_span=210
    fs7_idx=fs7_age/fs7_span
    fs7_phase=fs7_age%fs7_span
    if fs7_age>=0 && fs7_idx<fs7_cases.size
      fs7_case=fs7_cases[fs7_idx]
      fs7_name,fs7_x,fs7_y=fs7_case
      if fs7_phase==0
        $game_player.moveto(fs7_x,fs7_y)
        $game_player.transparent=false
        $game_switches[203]=false
        A36G_MAP.log("H2_INIT case="+fs7_name+" tile="+fs7_x.to_s+","+fs7_y.to_s)
      elsif fs7_phase==48
        sp=$OverlayMap.instance_variable_get(:@par)
        A36G_MAP.log("H2_SHOT case="+fs7_name+" state=OFF pos="+$game_player.x.to_s+","+$game_player.y.to_s+" display="+$game_map.display_x.to_s+","+$game_map.display_y.to_s+" sprite="+(!sp.nil?).to_s+" visible="+(sp && sp.visible).to_s)
      elsif fs7_phase==85
        $game_switches[203]=true
      elsif fs7_phase==125
        sp=$OverlayMap.instance_variable_get(:@par)
        A36G_MAP.log("H2_SHOT case="+fs7_name+" state=ON pos="+$game_player.x.to_s+","+$game_player.y.to_s+" display="+$game_map.display_x.to_s+","+$game_map.display_y.to_s+" sprite="+(!sp.nil?).to_s+" visible="+(sp && sp.visible).to_s)
      end
    elsif fs7_age>=0 && fs7_idx==fs7_cases.size && fs7_phase==0
      A36G_MAP.log("H2_ALL_CASES_DONE")
    end
'''
ruby=ruby.replace("    @a36f_frame+=1","    @a36f_frame+=1\n"+injection)
scripts[483][2]=zlib.compress(ruby.encode("utf8"))
sfile.write_bytes(writes(scripts))
u=ctypes.windll.user32
CB=ctypes.WINFUNCTYPE(w.BOOL,w.HWND,w.LPARAM)
def windows(pid):
 out=[]
 def cb(hwnd,lp):
  proc=w.DWORD();u.GetWindowThreadProcessId(hwnd,ctypes.byref(proc))
  if proc.value==pid and u.IsWindowVisible(hwnd):
   cl=ctypes.create_unicode_buffer(100);u.GetClassNameW(hwnd,cl,99)
   out.append((int(hwnd),cl.value))
  return True
 u.EnumWindows(CB(cb),0);return out
log=dest/"A36G_VX_ACTUAL_FULL_MAP.log"
if log.exists():log.unlink()
shots={};events=[];errors=[];complete=False;proc=None
try:
 proc=subprocess.Popen([str(dest/"Game.exe")],cwd=str(dest))
 start=time.monotonic();nread=0
 while time.monotonic()-start<105:
  time.sleep(.13)
  ws=windows(proc.pid)
  if any(cl=="#32770" for _,cl in ws):
   errors=ws;print("VX_MODAL",errors,flush=True);break
  if proc.poll() is not None:
   print("VX_EXIT",proc.returncode,flush=True);break
  if not log.exists():continue
  lines=log.read_text("utf8",errors="replace").splitlines()
  delta=lines[nread:];nread=len(lines)
  for line in delta:
   if not line.startswith("H2_"):continue
   events.append(line)
   if "H2_ALL_CASES_DONE" in line:complete=True
   mt=re.search(r"H2_SHOT case=(\S+) state=(OFF|ON) pos=(\d+),(\d+) display=(\d+),(\d+) sprite=(\w+) visible=(\w+)",line)
   if not mt:continue
   name,state,px,py,dx,dy,sp,vis=mt.groups()
   rec={"actor_tile":[int(px),int(py)],"camera":[int(dx),int(dy)],"sprite_exists":sp=="true","par_visible":vis=="true","screenshot":False}
   hwnd=next((h for h,cl in ws if cl=="RGSS Player"),None)
   if hwnd:
    img=ImageGrab.grab(window=hwnd).convert("RGB")
    if img.size==(544,416):
     file=ROOT/(f"H2_{name}_{state}.png")
     img.save(file)
     rec.update({"screenshot":True,"file":file.name,"sha256":sha(file)})
   shots.setdefault(name,{})[state]=rec
   print("H2_SHOT",name,state,"camera",rec["camera"],"visible",vis,"screen",rec["screenshot"],flush=True)
  if complete and all(set(shots.get(n,{}))=={"OFF","ON"} for n,*_ in test_cases):break
finally:
 if proc and proc.poll() is None:
  proc.terminate()
  try:proc.wait(timeout=5)
  except subprocess.TimeoutExpired:proc.kill()
results={}
for name,x,y,f in test_cases:
 a=shots.get(name,{}).get("OFF",{});b=shots.get(name,{}).get("ON",{})
 diff={}
 if a.get("screenshot") and b.get("screenshot"):
  off=Image.open(ROOT/a["file"]).convert("RGB");on=Image.open(ROOT/b["file"]).convert("RGB")
  delta=ImageChops.difference(off,on);bbox=delta.getbbox()
  count=int(np.any(np.asarray(delta)!=0,axis=2).sum())
  diff={"changed_pixels":count,"bbox":list(bbox) if bbox else None,"actor_local":bool(bbox and bbox[2]-bbox[0]<=70 and bbox[3]-bbox[1]<=70)}
  merged=Image.new("RGB",(1088,416),(20,24,28));merged.paste(off,(0,0));merged.paste(on,(544,0))
  merged.save(ROOT/f"H2_{name}_OFF_ON.png")
 status=bool(a.get("screenshot") and b.get("screenshot") and a["actor_tile"]==b["actor_tile"]==[x,y] and
             a["camera"]==b["camera"] and a["sprite_exists"] and b["sprite_exists"] and
             a["par_visible"] is False and b["par_visible"] is True and
             ((diff.get("changed_pixels",0)>=120 and diff.get("actor_local")) if f else diff.get("changed_pixels")==0))
 results[name]={"source_owned":name!="CLEAR_NEGATIVE","tile":[x,y],"walkable":blocked[y][x]==0,
                "source_alpha_actor_overlap":f,"off":a,"on":b,"diff":diff,"gate":"PASS" if status else "FAIL"}
 print("CASE",name,"GATE",results[name]["gate"],"DELTA",diff,flush=True)
# Contact sheet with actual Game.exe captures
sheet=Image.new("RGB",(1088,6*452),(24,25,28));dr=ImageDraw.Draw(sheet)
for i,(name,*_) in enumerate(test_cases):
 p=ROOT/f"H2_{name}_OFF_ON.png"
 if p.exists():sheet.paste(Image.open(p).convert("RGB"),(0,i*452+36))
 dr.text((12,i*452+9),name+" | "+results[name]["gate"]+" (R5 collision, real Game.exe)",fill="white")
sheet.save(ROOT/"A36H_R2_NATIVE_5OBJECTS_6CASES_OFF_ON_CONTACT.png")
source_untouched=all(sha(p)==original_sha[str(p)] for p in protected)
report={"stage":"FS_A36H_R2_ACTUAL_RESTYLED_GROUND_PAR_ON_A36G_R5_NATIVE_COLLISION",
 "native_engine":"RPG Maker VX RGSS2, HK UOM par switch203",
 "R5_map050_real_native_map_id_data_SHA256":sha(MAP),
 "R5_native_map050_tile_ids_verified":True,"R5_collision_grid_919free_241blocked":True,
 "original_source_SHA_unchanged":source_untouched,
 "runtime_completed":complete,"cases":results,"runtime_events":events,"errors":errors,
 "sample_gate":"PASS" if complete and not errors and source_untouched and all(v["gate"]=="PASS" for v in results.values()) else "FAIL",
 "limitations":["Sampled stationary actors only on tiles marked walkable by R5 manifest",
                "No complete tree crown/roof visual approval; user rejected R5 style remains",
                "This is a 5-source occlusion subset of 192 manifest objects, not complete PAR",
                "No Godot test this round"],
 "art_gate":"A36H R2 candidate VISUAL UNAPPROVED","formal_seal":"NO"}
(ROOT/"A36H_R2_NATIVE_203_REAL_R5_COLLISION_QA.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print("FINAL",json.dumps({"gate":report["sample_gate"],"complete":complete,
  "source_sha_unchanged":source_untouched,"cases":{k:{"gate":v["gate"],"pixels":v["diff"].get("changed_pixels")} for k,v in results.items()}},ensure_ascii=False),flush=True)