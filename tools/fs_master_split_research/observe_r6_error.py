from PIL import ImageGrab
from pathlib import Path
import ctypes,subprocess,time,json
base=Path(__file__).resolve().parent/"R6_SAME_SESSION_ISOLATED"
w=base/"FULL505";d=base/"ERROR_DIAG";d.mkdir(exist_ok=True)
proc=subprocess.Popen([str(w/"Game.exe")],cwd=w)
try:
 for sec in [3,6]:
  time.sleep(3)
  for cls,tag in [("#32770","dialog"),("RGSS Player","game")]:
   h=ctypes.windll.user32.FindWindowW(cls,"FS_R6_VX_SAME_SESSION")
   print(sec,tag,h,flush=True)
   if h:
    ImageGrab.grab(window=h).save(d/f"R6_{tag}_{sec}.png")
  print((w/"R6_A_B_A_NATIVE.log").read_text(errors="replace")[-900:],flush=True)
finally:
 proc.terminate()