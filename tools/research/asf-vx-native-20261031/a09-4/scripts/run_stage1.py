from pathlib import Path
from PIL import ImageGrab
import subprocess,time,ctypes,json,hashlib
r=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031")
g=r/"VX_A09_4_N5_RUNTIME";qa=r/"vx_real_actor_20261031"/"a09_4"
log=g/"ASF_A094_DIAGNOSTIC.log"
if log.exists():log.unlink()
proofs=g/"ASF_A094_NATIVE_PROOFS"
if proofs.exists(): 
 for p in proofs.glob("*.ppm"):p.unlink()
proc=subprocess.Popen([str(g/"Game.exe")],cwd=g,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
start=time.monotonic()
result={"pid":proc.pid,"status":"TIMEOUT_OR_CRASH","log":None,"ppm_files":[]}
try:
 while time.monotonic()-start<28:
  if log.exists():
   t=log.read_text(encoding="ascii",errors="replace")
   if "A094_CAPTURE_DONE" in t:
    result["status"]="CAPTURE_DONE_MARKER"
    break
   if "A094_INIT_FAIL" in t or "A094_TICK_FAIL" in t or "A094_SNAP_FAIL" in t:
    result["status"]="ERROR_MARKER"
    break
  if proc.poll() is not None:
   result["status"]="EXE_EXITED"
   break
  time.sleep(.1)
 if log.exists():result["log"]=log.read_text(encoding="ascii",errors="replace")
 if proofs.exists():
  result["ppm_files"]=[{"name":f.name,"bytes":f.stat().st_size,"sha":hashlib.sha256(f.read_bytes()).hexdigest()} for f in sorted(proofs.glob("*.ppm"))]
 hwnd=ctypes.windll.user32.FindWindowW(None,"ASF_A094_N5_CONTROL")
 if hwnd:
  try:
   im=ImageGrab.grab(window=hwnd).convert("RGB")
   f=qa/"A094_STAGE1_NATIVE_SCREEN.png"
   im.save(f)
   result["screen"]={"size":list(im.size),"sha256":hashlib.sha256(f.read_bytes()).hexdigest()}
  except Exception as e:result["screen_error"]=str(e)
finally:
 if proc.poll() is None:
  proc.terminate()
  try:proc.wait(timeout=3)
  except subprocess.TimeoutExpired:proc.kill()
result["elapsed_sec"]=round(time.monotonic()-start,2)
(qa/"stage1_run.json").write_text(json.dumps(result,indent=2))
print(json.dumps(result,indent=2)[:11000])