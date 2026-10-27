#!/usr/bin/env python3
"""Run isolated native Game.exe for static and depth PAR; capture shots and compare pixel geometry."""
from pathlib import Path
from PIL import Image,ImageGrab
import subprocess,ctypes,time,json,hashlib,os
ROOT=Path(__file__).resolve().parent
NATIVE=ROOT/"R3_NATIVE_VX"
LOG=ROOT/"R3_NATIVE_SCREENSHOTS";LOG.mkdir(exist_ok=True)
TAGS=["TREE_BEHIND","TREE_FRONT","HOUSE_BEHIND","HOUSE_FRONT","RIGHT_BEHIND","RIGHT_FRONT","CLEAR"]
SOURCE=Image.open(ROOT/"SCENE21_GUIDED_SAM2_CANDIDATE"/"MASTER_RGBA.png").convert("RGB")
def run(mode,timeout=36):
 work=NATIVE/mode
 f=work/"FS_RICH_VX_LOG.txt"
 f.write_text("R3_NATIVE_EXECUTING\n")
 proc=subprocess.Popen([str(work/"Game.exe")],cwd=work,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
 cap={};hwnd=0;current=""
 try:
  deadline=time.monotonic()+timeout
  while time.monotonic()<deadline:
   time.sleep(.05)
   if f.exists():current=f.read_text(encoding="ascii",errors="replace")
   if not hwnd:hwnd=ctypes.windll.user32.FindWindowW(None,f"FS_PAR_R3_{mode}_20261027")
   for t in TAGS:
    if t not in cap and f"R3_CAPTURE {t} " in current and hwnd:
     path=LOG/f"{mode}_{t}.png"
     ImageGrab.grab(window=hwnd).save(path)
     cap[t]=path
     print("R3_NATIVE_SCREENSHOT",mode,t,Image.open(path).size,flush=True)
   if "R3_CAPTURE_DONE" in current and len(cap)==len(TAGS):break
   if proc.poll() is not None: break
  (LOG/f"{mode}_GAME_LOG.txt").write_text(current,encoding="utf8")
  if "R3_NATIVE_BASIC_PASS" not in current:
   raise RuntimeError(f"BASIC_FAILED mode={mode} logtail={current[-1800:]}")
  if len(cap)<len(TAGS):raise RuntimeError(f"CAPTURE_FAILED mode={mode} hwnd={hwnd} screenshots={list(cap)} logfile={current[-1800:]}")
  return cap,current
 finally:
  if proc.poll() is None:
   proc.terminate()
   try:proc.wait(timeout=4)
   except subprocess.TimeoutExpired:proc.kill()
def main():
 for mode in ["STATIC","DEPTH"]:
  run(mode)
 print("R3_CAPTURED_NATIVE_14_FRAMES",flush=True)
 analyzer=Path(__file__).resolve().parent/"analyze_native_r3_screenshots.py"
 cmd=["wsl.exe","--cd","/home/user/sam2",
      "/home/user/sam2/.venv/bin/python",
      "/mnt/e/GameAssetToolLab_20261023/FS_MasterSplit_Research_20261027/analyze_native_r3_screenshots.py"]
 subprocess.run(cmd,check=True)
if __name__=="__main__":main()