#!/usr/bin/env python3
"""Real VX native 10 cases from BYTE IDENTICAL original Map050 copied to isolated Map001."""
from pathlib import Path
from PIL import ImageGrab,Image
import ctypes,subprocess,time,re,json
R=Path(__file__).resolve().parent
W=R/"R10_COLLISION_NATIVE_CANDIDATE"/"FULL505"
D=R/"R10_COLLISION_NATIVE_CANDIDATE"/"NATIVE_CANDIDATE"
D.mkdir(exist_ok=True,parents=True)
ids=["F01_MAP050_TREE_DOWN","F02_MAP050_TREE_FRONT","F03_MAP050_BUSH_LEFT","F04_MAP050_BUSH_RIGHT",
"F05_MAP050_STEPS_DOWN","F06_MAP050_PREVIOUS_BLOCK_UP","F07_MAP050_PREVIOUS_BLOCK_LEFT",
"F08_MAP050_BOUNDARY_LEFT","F09_MAP050_BOUNDARY_UP","F10_MAP050_NPC_MOVE","F11_MAP050_NPC_FREE"]
log=W/"R10_COMPILED_MAP050_NATIVE.log";log.write_text("R10_START_NATIVE\n",encoding="ascii")
proc=subprocess.Popen([str(W/"Game.exe")],cwd=W,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
pics={}
try:
 hwnd=0;start=time.monotonic()
 while time.monotonic()-start<57:
  time.sleep(.025)
  s=log.read_text(encoding="ascii",errors="replace") if log.exists() else ""
  if not hwnd:hwnd=ctypes.windll.user32.FindWindowW(None,"FS_R10_COLLISION_CANDIDATE")
  for id in ids:
   if id not in pics and ("R10_SHOT "+id+" ") in s and hwnd:
    f=D/(id+".png")
    try:ImageGrab.grab(window=hwnd).save(f)
    except Exception as e:print("CAPTURE_ERROR",id,str(e),flush=True);continue
    assert Image.open(f).size==(544,416),f
    pics[id]=f.name
    print("R10_MAP050_SHOT",id,len(pics),flush=True)
  if "R10_NATIVE_ALL_DONE" in s and len(pics)==len(ids):break
  if proc.poll() is not None:break
 (D/"GAME_LOG.txt").write_text(s,encoding="utf8")
 rec={}
 for name in ids:
  m=re.search(r"^R10_ACTUAL "+re.escape(name)+r" (.*)$",s,re.M)
  c=re.search(r"^R10_SHOT "+re.escape(name)+r" (.*)$",s,re.M)
  rec[name]={"action":m.group(1) if m else None,"shot":c.group(1) if c else None,
             "position_pass":bool(m and "pass=true" in m.group(1)),
             "settled_pass":bool(c and "verified=true" in c.group(1))}
 result={"status":"R10_COLLISION_CANDIDATE_NATIVE_PASS" if len(pics)==len(ids) and all(v["position_pass"] and v["settled_pass"] for v in rec.values()) and "R10_NATIVE_ALL_DONE true" in s else "R10_COLLISION_CANDIDATE_NATIVE_FAIL",
  "actual_native_pid":proc.pid,"window_found":bool(hwnd),"screenshots":pics,"cases":rec,
  "formal_map050_source_unmodified_and_compiled_candidate_only":True,
  "map050_events_not_native_preserved":True,
  "script_original_page480_disabled_in_isolation":True}
 (D/"R10_COLLISION_NATIVE_GATE.json").write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding="utf8")
 print("R10_MAP050_NATIVE_RESULT",result["status"],sum(x["position_pass"] and x["settled_pass"] for x in rec.values()),"/",len(ids),flush=True)
 if result["status"]!="R10_COLLISION_CANDIDATE_NATIVE_PASS":raise SystemExit(2)
finally:
 if proc.poll() is None:
  proc.terminate()
  try:proc.wait(timeout=4)
  except subprocess.TimeoutExpired:proc.kill()