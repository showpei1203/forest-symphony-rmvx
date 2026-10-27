#!/usr/bin/env python3
"""Native R6 in-process A/B/A captures with same actor pose and same game session."""
from pathlib import Path
from PIL import ImageGrab,Image
import subprocess,ctypes,time,json,re
ROOT=Path(__file__).resolve().parent
W=ROOT/"R7_NATIVE_FULL_MASTER"/"FULL505"
OUT=ROOT/"R7_NATIVE_FULL_MASTER"/"NATIVE_ABA"
OUT.mkdir(exist_ok=True,parents=True)
cases=['LEFT_CONIFER_FRONT', 'HOUSE_FRONT_X8', 'HOUSE_FRONT_X9', 'RIGHT_MARKER_FRONT', 'CLEAR']
marks=[(a,b) for a in cases for b in ["A1","B","A2"]]
log=W/"R6_A_B_A_NATIVE.log"
log.write_text("R6_START_NATIVE_PROCESS\n",encoding="ascii")
process=subprocess.Popen([str(W/"Game.exe")],cwd=W,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
screens={}
try:
 hwnd=0
 deadline=time.monotonic()+45
 while time.monotonic()<deadline:
  time.sleep(.024)
  s=log.read_text(encoding="ascii",errors="replace") if log.exists() else ""
  if not hwnd:hwnd=ctypes.windll.user32.FindWindowW(None,"FS_R7_PAR_SAME_SESSION")
  for case,code in marks:
   key=case+"__"+code
   needle="R6_SHOT "+case+" "+code+" "
   if key not in screens and needle in s and hwnd:
    path=OUT/(key+".png")
    try:ImageGrab.grab(window=hwnd).save(path)
    except Exception as e:
     print("R6_CAPTURE_ERROR",key,str(e),flush=True)
     continue
    if Image.open(path).size!=(544,416):raise RuntimeError(f"Bad image {key} size={Image.open(path).size}")
    screens[key]=path.name
    print("R6_SHOT_CAPTURED",key,len(screens),flush=True)
  if len(screens)==len(marks) and "R6_SAME_SESSION_A_B_A_COMPLETE" in s:break
  if process.poll() is not None:break
 (OUT/"GAME_LOG.txt").write_text(s,encoding="ascii",errors="replace")
 report={"status":"R6_NATIVE_CAPTURE_PASS" if len(screens)==15 and "R6_SAME_SESSION_A_B_A_COMPLETE" in s else "R6_CAPTURE_FAIL",
  "files":screens,"window_seen":bool(hwnd),"process_poll":process.poll(),"same_single_pid":process.pid,
  "all_five_cases":cases,"log_tail":s[-3200:],
  "original_505_boot_regression_disabled_in_isolated_copy":True}
 (OUT/"R6_CAPTURE_MANIFEST.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
 print("R6_CAPTURE_VERDICT",report["status"],len(screens),flush=True)
 if report["status"]!="R6_NATIVE_CAPTURE_PASS":raise SystemExit(2)
finally:
 if process.poll() is None:
  process.terminate()
  try:process.wait(timeout=3)
  except subprocess.TimeoutExpired:process.kill()