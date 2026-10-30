from pathlib import Path
from PIL import ImageGrab
import subprocess,time,ctypes,json,hashlib
root=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031")
proj=root/"VX_A09_4_N5_CONTROL"
qa=root/"vx_real_actor_20261031"/"a09_4"
log=proj/"ASF_A094_DIAGNOSTIC.log"
if log.exists():log.unlink()
pid=None;proc=subprocess.Popen([str(proj/"Game.exe")],cwd=proj,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
pid=proc.pid;start=time.monotonic()
status={"pid":pid,"found_log":False,"frame_test":False,"log":None,"screenshot":None}
try:
 while time.monotonic()-start<25:
  if log.exists():
   t=log.read_text(encoding="ascii",errors="replace")
   if "A094_MAP_FRAME_35" in t:
    status["frame_test"]=True
    break
  if proc.poll() is not None:break
  time.sleep(.08)
 if log.exists():
  status["found_log"]=True
  status["log"]=log.read_text(encoding="ascii",errors="replace")
 hwnd=ctypes.windll.user32.FindWindowW(None,"ASF_A094_N5_CONTROL")
 if hwnd:
  try:
   im=ImageGrab.grab(window=hwnd).convert("RGB")
   f=qa/"A094_N5_NATIVE_WINDOW.png"
   im.save(f)
   status["screenshot"]={"size":list(im.size),"nonblack_fraction":round(sum(1 for p in im.getdata() if max(p)>8)/(im.width*im.height),4),"sha256":hashlib.sha256(f.read_bytes()).hexdigest()}
  except Exception as e:status["screenshot"]={"error":str(e)}
 status["process_exit_before_terminate"]=proc.poll()
finally:
 if proc.poll() is None:
  proc.terminate()
  try:proc.wait(timeout=3)
  except:proc.kill()
status["seconds"]=round(time.monotonic()-start,2)
(qa/"stage0_run.json").write_text(json.dumps(status,ensure_ascii=False,indent=2),encoding="utf-8")
print(json.dumps(status,ensure_ascii=False,indent=2))