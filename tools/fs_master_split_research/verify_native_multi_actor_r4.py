#!/usr/bin/env python3
from pathlib import Path
from PIL import Image, ImageGrab
import subprocess,ctypes,time,json
ROOT=Path(__file__).resolve().parent
WORK=ROOT/"R4_NATIVE_VX";OUT=ROOT/"R4_NATIVE_SCREENSHOTS";OUT.mkdir(exist_ok=True)
TAGS=["PLAYER_FRONT_NPC_BEHIND","PLAYER_BEHIND_NPC_FRONT","BOTH_FRONT","BOTH_BEHIND","CLEAR"]
def run(mode,timeout=48):
 path=WORK/mode
 f=path/"FS_RICH_VX_LOG.txt";f.write_text("R4_RUN_BEGIN\n",encoding="ascii")
 process=subprocess.Popen([str(path/"Game.exe")],cwd=path,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
 captured={};hwnd=0
 try:
  start=time.monotonic()
  while time.monotonic()-start<timeout:
   time.sleep(.04)
   s=f.read_text(encoding="ascii",errors="replace") if f.is_file() else ""
   if not hwnd:hwnd=ctypes.windll.user32.FindWindowW(None,f"FS_R4_NPC_{mode}_20261027")
   for name in TAGS:
    if name not in captured and f"R4_CAPTURE {name} " in s and hwnd:
     png=OUT/f"{mode}_{name}.png"
     ImageGrab.grab(window=hwnd).save(png)
     captured[name]=str(png)
     print("R4_CAPTURED",mode,name,Image.open(png).size,flush=True)
   if "R4_MULTI_ACTOR_CAPTURE_DONE" in s and len(captured)==len(TAGS):break
   if process.poll() is not None:break
  (OUT/f"{mode}_ENGINE_LOG.txt").write_text(s,encoding="utf8")
  if "R4_REAL_GAME_EVENT_CREATED class=Game_Event" not in s:raise ValueError("R4_EVENT_NOT_CONSTRUCTED: "+s[-1500:])
  if "R3_NATIVE_BASIC_PASS" not in s:raise ValueError("BASE_NATIVE_GATE_FAIL: "+s[-1500:])
  if len(captured)!=len(TAGS):raise ValueError(f"R4_SCREENSHOT_MISSING mode={mode} captured={list(captured)} logs={s[-1500:]}")
  for name in TAGS:
   line=next((line for line in s.splitlines() if line.startswith("R4_CAPTURE "+name+" ")),None)
   if line is None or "npcCount=1" not in line:raise AssertionError("NPC_SPRITE_NOT_READY "+str(line))
  return {"mode":mode,"native_event":True,"real_vx":True,"images":captured}
 finally:
  if process.poll() is None:
   process.terminate()
   try:process.wait(timeout=3)
   except subprocess.TimeoutExpired:process.kill()
if __name__=="__main__":
 out=[]
 for mode in ["STATIC","DEPTH"]:out.append(run(mode))
 (OUT/"R4_CAPTURE_MANIFEST.json").write_text(json.dumps({"status":"NATIVE_CAPTURE_PASS_NOT_VISUAL_PASS","runs":out},indent=2),encoding="utf8")
 print("R4_NATIVE_EVENT_SCREENSHOTS_10_PASS",flush=True)