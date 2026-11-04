from pathlib import Path
from PIL import Image,ImageGrab
import json,hashlib,shutil,time,subprocess,ctypes,ctypes.wintypes as w
C=Path(r"E:\FS_STAGE16_A36G_R5_HOUSE_STYLE_UNIFICATION_20261104")
V=Path(r"E:\FS_STAGE16_A36G_R5_VX_NATIVE_20261104")
D=Path(r"E:\FS_STAGE16_A36G_R5_VX_COLD_20261104")
assert V.exists() and not D.exists()
shutil.copytree(V,D)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
files=sorted(p.relative_to(V) for p in V.rglob("*") if p.is_file())
matches=sum(sha(V/x)==sha(D/x) for x in files)
assert matches==len(files)
log=D/"A36G_VX_ACTUAL_FULL_MAP.log"
if log.exists():log.unlink()
user32=ctypes.windll.user32
CB=ctypes.WINFUNCTYPE(w.BOOL,w.HWND,w.LPARAM)
def class_name(h):
 b=ctypes.create_unicode_buffer(200);user32.GetClassNameW(h,b,199);return b.value
process=subprocess.Popen([str(D/"Game.exe")],cwd=str(D))
start=time.time();events=[];screens=[];modal=False;hwnd=None
try:
 while time.time()-start<50:
  time.sleep(.5);screens=[]
  def cb(h,p):
   v=w.DWORD();user32.GetWindowThreadProcessId(h,ctypes.byref(v))
   if v.value==process.pid and user32.IsWindowVisible(h):screens.append((int(h),class_name(h)))
   return True
  user32.EnumWindows(CB(cb),0)
  modal=any(k=="#32770" for h,k in screens)
  if modal:break
  if log.exists():events=log.read_text("utf8",errors="replace").splitlines()
  if any("A36G_ENTER id=50 size=40x29" in x for x in events) and any("A36G_MAP_OBJECTS count=192" in x for x in events):break
 hwnd=next((h for h,k in screens if k=="RGSS Player"),None)
 if hwnd:
  img=ImageGrab.grab(window=hwnd).convert("RGB")
  assert img.size==(544,416)
  img.save(C/"A36G_R5_NATIVE_INDEPENDENT_COLD_544x416.png")
 finally_dummy=False
finally:
 if process.poll() is None:
  process.terminate()
  try:process.wait(timeout=5)
  except subprocess.TimeoutExpired:process.kill()
qa={"stage":"A36G_R5","cold_cloned":str(D),"source_file_count":len(files),"matching_SHA256":matches,"mismatches":len(files)-matches,
 "RGSS_game_window":bool(hwnd),"has_modal_error":modal,"native_544x416_saved":bool(hwnd),
 "objects_192_loaded":any("A36G_MAP_OBJECTS count=192" in s for s in events),
 "Map050_entered":any("A36G_ENTER id=50" in s for s in events),"first_runtime_logs":events[:7],
 "elapsed_sec":round(time.time()-start,2),"formal_seal":"NO"}
(C/"A36G_R5_NATIVE_VX_COLD_REBUILD_QA.json").write_text(json.dumps(qa,ensure_ascii=False,indent=2),"utf8")
print(json.dumps(qa,ensure_ascii=False,indent=2),flush=True)
assert qa["mismatches"]==0 and qa["RGSS_game_window"] and not qa["has_modal_error"] and qa["objects_192_loaded"] and qa["Map050_entered"]
