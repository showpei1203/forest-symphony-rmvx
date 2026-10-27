#!/usr/bin/env python3
"""Capture 10 actual Game_Player move attempts on real isolated RPG Maker VX.
No A/B pixel claims while animated scene is live. Fail closed if log missing.
"""
from pathlib import Path
from PIL import ImageGrab,Image
import ctypes,subprocess,time,re,json
R=Path(__file__).resolve().parent
W=R/"R9_NATIVE_WALKING_ISOLATED"/"FULL505"
D=R/"R9_NATIVE_WALKING_ISOLATED"/"NATIVE_WALK"
D.mkdir(exist_ok=True,parents=True)
ids=["T01_TREE_DOWN_BACK","T02_TREE_DOWN_FRONT","T03_TREE_UP","T04_BUSH_LEFT","T05_BUSH_RIGHT",
     "T06_FAR_CONIFER_DOWN","T07_FAR_CONIFER_UP","T08_STEPS_DOWN","T09_BLOCKED_UP","T10_BLOCKED_LEFT"]
log=W/"R9_NATIVE_MOVEMENT.log"
log.write_text("R9_NATIVE_START\n",encoding="ascii")
proc=subprocess.Popen([str(W/"Game.exe")],cwd=W,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
found={}
try:
 hwnd=0;deadline=time.monotonic()+52
 while time.monotonic()<deadline:
  time.sleep(.035)
  s=log.read_text(encoding="ascii",errors="replace") if log.exists() else ""
  if not hwnd:hwnd=ctypes.windll.user32.FindWindowW(None,"FS_R9_VX_WALK_TEST")
  for id in ids:
   if id not in found and "R9_WALK_CAPTURE "+id+" " in s and hwnd:
    img=D/(id+".png")
    try:ImageGrab.grab(window=hwnd).save(img)
    except Exception as e:print("SCREEN_CAPTURE_ERROR",id,str(e),flush=True);continue
    assert Image.open(img).size==(544,416)
    found[id]=img.name
    print("NATIVE_WALK_SCREEN",id,len(found),flush=True)
  if "R9_WALK_GATES_COMPLETE" in s and len(found)==len(ids):break
  if proc.poll() is not None:break
 (D/"GAME_LOG.txt").write_text(s,encoding="utf8")
 records={}
 for id in ids:
  m=re.search(r"^R9_ACTUAL_MOVE "+re.escape(id)+r" (.+)$",s,re.M)
  shot=re.search(r"^R9_WALK_CAPTURE "+re.escape(id)+r" (.+)$",s,re.M)
  records[id]={"actual_move":m.group(1) if m else None,
               "capture":shot.group(1) if shot else None,
               "move_gate":bool(m and "pass=true" in m.group(1)),
               "capture_gate":bool(shot and "verified=true" in shot.group(1))}
 result={"status":"R9_NATIVE_WALK_PASS" if all(v["move_gate"] and v["capture_gate"] for v in records.values()) and len(found)==10 and "R9_WALK_GATES_COMPLETE true" in s else "R9_NATIVE_WALK_FAIL",
         "one_native_game_pid":proc.pid,"windows_seen":bool(hwnd),"captures":found,"cases":records,
         "formal_505_original_boot_tested":False,"R9_isolated_504_unmodified_pages":True}
 (D/"R9_NATIVE_WALK_GATE.json").write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding="utf8")
 print("R9_WALK_VERDICT",result["status"],"pass",sum(v["move_gate"] and v["capture_gate"] for v in records.values()),"/",len(ids),flush=True)
 if result["status"]!="R9_NATIVE_WALK_PASS":raise SystemExit(1)
finally:
 if proc.poll() is None:
  proc.terminate()
  try:proc.wait(timeout=3)
  except subprocess.TimeoutExpired:proc.kill()