#!/usr/bin/env python3
"""Real native VX Map003 full 40x29 and ground3.png 1280x928, one-step and scrolling evidence.
Ground3 is EXISTING user source; this test is technical scale harness, not new art.
"""
from pathlib import Path
from PIL import ImageGrab,Image
import ctypes,subprocess,time,re,json
R=Path(__file__).resolve().parent;W=R/"R11_GROUND3_40x29_NATIVE"/"FULL505"
D=R/"R11_GROUND3_40x29_NATIVE"/"NATIVE";D.mkdir(parents=True,exist_ok=True)
ids=["L01_CENTER_RIGHT","L02_CENTER_DOWN_BLOCK","L03_EAST_UPPER_RIGHT",
"L04_EAST_MID_DOWN","L05_WEST_WALK","L06_WEST_BLOCK",
"L07_SOUTH_RIGHT","L08_SOUTH_WALK","L09_SOUTH_BLOCK","L10_LEFT_BORDER"]
log=W/"R11_GROUND3_NATIVE.log";log.write_text("R11_NATIVE_CAPTURE_START\n",encoding="ascii")
proc=subprocess.Popen([str(W/"Game.exe")],cwd=W,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
pictures={}
try:
 hwnd=0;start=time.monotonic()
 while time.monotonic()-start<70:
  time.sleep(.025)
  s=log.read_text(encoding="ascii",errors="replace") if log.exists() else ""
  if not hwnd: hwnd=ctypes.windll.user32.FindWindowW(None,"FS_R11_GROUND3_40x29")
  for name in ids:
   if name not in pictures and "R11_SHOT "+name+" " in s and hwnd:
    path=D/(name+".png")
    try: ImageGrab.grab(window=hwnd).save(path)
    except Exception as e:
     print("R11_IMG_ERROR",name,str(e),flush=True);continue
    assert Image.open(path).size==(544,416)
    pictures[name]=path.name
    print("R11_LARGE_NATIVE_SCREEN",name,len(pictures),flush=True)
  if "R11_ALL_CASES_DONE" in s and len(pictures)==len(ids):break
  if proc.poll() is not None:break
 (D/"GAME_LOG.txt").write_text(s,encoding="utf8")
 cases=[]
 for name in ids:
  m=re.search(r"^R11_MOVE "+re.escape(name)+r" (.+)$",s,re.M)
  shot=re.search(r"^R11_SHOT "+re.escape(name)+r" (.+)$",s,re.M)
  cases.append({"id":name,"actual":m.group(1) if m else None,"shot":shot.group(1) if shot else None,
    "pass":bool(m and "same=true" in m.group(1) and shot and "complete=true" in shot.group(1))})
 meta={"status":"R11_MAP003_LARGE_NATIVE_PASS" if len(pictures)==len(ids) and all(x["pass"] for x in cases) else "R11_MAP003_LARGE_NATIVE_HOLD",
 "game_pid":proc.pid,"window_found":bool(hwnd),"shots":pictures,"cases":cases,
 "map003_full_orig_events_preserved":False,"art_new_village_generated":False,
 "real_ground3_1280x928_used":True,
 "script_original_505_full_boot":False}
 (D/"R11_NATIVE_GATE.json").write_text(json.dumps(meta,ensure_ascii=False,indent=2),encoding="utf8")
 print("R11_LARGE_NATIVE_STATUS",meta["status"],sum(x["pass"] for x in cases),"/",len(cases),flush=True)
 if meta["status"]!="R11_MAP003_LARGE_NATIVE_PASS":raise SystemExit(2)
finally:
 if proc.poll() is None:
  proc.terminate()
  try:proc.wait(timeout=3)
  except subprocess.TimeoutExpired:proc.kill()