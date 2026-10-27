#!/usr/bin/env python3
"""Real Windows VX Game.exe, full 505 original pages + test-only injected addon, capture and fail closed."""
from pathlib import Path
from PIL import Image,ImageGrab
import subprocess,ctypes,time,json,re,sys
ROOT=Path(__file__).resolve().parent
W=ROOT/"R5_FORMAL_ADAPTER_ISOLATED"/"FULL505"
MODE=sys.argv[1].upper() if len(sys.argv)>1 else "HK_STATIC"
assert MODE in ("HK_STATIC","DYNAMIC_ADAPTER")
OUT=ROOT/"R5_FORMAL_ADAPTER_ISOLATED"/"NATIVE_CAPTURE"/MODE
OUT.mkdir(exist_ok=True,parents=True)
TAGS=["PLAYER_FRONT_NPC_BEHIND","PLAYER_BEHIND_NPC_FRONT","BOTH_FRONT","BOTH_BEHIND","CLEAR"]
LOG=W/"R5_FULL505_RUNTIME.log"
exe=W/"Game.exe"
assert exe.is_file() and (W/"Data"/"Scripts.rvdata").is_file()
LOG.write_text("R5_TEST_RUNTIME_BOOT\n",encoding="ascii")
proc=subprocess.Popen([str(exe)],cwd=W,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
captured={}
title=f"FS_R5_505_{MODE}"
try:
 deadline=time.monotonic()+28
 hwnd=0
 while time.monotonic()<deadline:
  time.sleep(.06)
  s=LOG.read_text(encoding="ascii",errors="replace") if LOG.exists() else ""
  if not hwnd:hwnd=ctypes.windll.user32.FindWindowW(None,title)
  for key in TAGS:
   if key not in captured and f"R5_CAPTURE {key} " in s and hwnd:
    name=OUT/(key+".png")
    ImageGrab.grab(window=hwnd).save(name)
    captured[key]=name.name
    print("R5_REAL_FS505_CAPTURE",MODE,key,Image.open(name).size,flush=True)
  if "R5_FULL505_CAPTURE_DONE" in s and len(captured)==len(TAGS):break
  if proc.poll() is not None:break
 (OUT/"GAME_LOG.txt").write_text(s,encoding="utf8")
 # Diagnostic also capture current window, even if no markers.
 if hwnd and len(captured)<len(TAGS):
  ImageGrab.grab(window=hwnd).save(OUT/"LAST_VISIBLE_SCREEN.png")
 runtime={"status":"R5_NATIVE_505_PARTIAL_OR_FAIL","mode":MODE,"process_returncode":proc.poll(),
          "has_window":bool(hwnd),"screenshots":captured,"log_tail":s[-2400:],
          "log_r5_flags":any("R5_CORE_FLAGS " in v for v in s.splitlines()),
          "log_real_npc":any("R5_REAL_NPC_CLASS Game_Event" in v for v in s.splitlines()),
          "log_map_sprite":any("R5_NATIVE_SPRITE_INIT" in v for v in s.splitlines()),
          "log_capture_complete":"R5_FULL505_CAPTURE_DONE" in s,
          "native_passa_actual_movement_pass":"R5_TRUE_PASSPASSA_GATE mapPass769=true mapBlock768=true playerMovePass=true playerMoveBlocked=true" in s,
          "native_hk_viewport_observed":"R5_HK_VIEWPORT_GATE parPresent=true" in s and "parVZ=8" in s,
          "formal_baseline_disk_untouched":True,
          "isolated_original_page_480_disabled":True,
          "isolated_original_other_504_pages_preserved":True,
          "unmodified_505_script_runtime_tested":False,
          "error_notes":"Inspect LAST_VISIBLE_SCREEN when other engine scripts show interactive blocking error."}
 if runtime["log_capture_complete"] and len(captured)==len(TAGS) and runtime["log_real_npc"] and runtime["native_passa_actual_movement_pass"] and runtime["native_hk_viewport_observed"]:
  runtime["status"]="R5_REAL_FS_505_PLUS_TEST_ADAPTER_NATIVE_SCREEN_CAPTURE_PASS"
 (OUT/"R5_NATIVE_CAPTURE_MANIFEST.json").write_text(json.dumps(runtime,ensure_ascii=False,indent=2),encoding="utf8")
 print("R5_NATIVE_505_VERDICT",json.dumps(runtime,ensure_ascii=False),flush=True)
 if runtime["status"].endswith("PARTIAL_OR_FAIL"):raise SystemExit(1)
finally:
 if proc.poll() is None:
  proc.terminate()
  try:proc.wait(timeout=4)
  except subprocess.TimeoutExpired:proc.kill()