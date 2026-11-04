from pathlib import Path
import subprocess,time,ctypes,ctypes.wintypes as w,hashlib,json,re,collections
from PIL import ImageGrab,Image,ImageChops,ImageDraw
base=Path(r"E:\FS_STAGE16_A36G_R4_ALL_REGION_FORESTS_20261104\R4_R3_VX_CAPTURES")
vx=Path(r"E:\FS_STAGE16_A36G_R4_R3_VX_NATIVE_20261104")
log=vx/"A36G_VX_ACTUAL_FULL_MAP.log"
if log.exists():log.rename(base/("A36G_NATIVE_PREVIOUS_LOG_%d.txt"%int(time.time())))
U=ctypes.windll.user32
CB=ctypes.WINFUNCTYPE(w.BOOL,w.HWND,w.LPARAM)
def get_hwnd(pid):
 found=[]
 def cb(hwnd,param):
  v=w.DWORD();U.GetWindowThreadProcessId(hwnd,ctypes.byref(v))
  if v.value==pid and U.IsWindowVisible(hwnd):
   c=ctypes.create_unicode_buffer(100);U.GetClassNameW(hwnd,c,99)
   found.append((int(hwnd),c.value))
  return True
 U.EnumWindows(CB(cb),0)
 return found
proc=None
images={}
events=[]
error_windows=[]
try:
 proc=subprocess.Popen([str(vx/"Game.exe")],cwd=str(vx))
 started=time.time();seen=0
 while time.time()-started<100:
  time.sleep(.26)
  windows=get_hwnd(proc.pid)
  if any(v=="#32770" for h,v in windows):
   error_windows=windows
   break
  if proc.poll() is not None:break
  if not log.exists(): continue
  lines=log.read_text(encoding="utf-8",errors="replace").splitlines()
  pending=lines[seen:];seen=len(lines)
  if not pending:continue
  for line in pending:
   events.append(line)
   m=re.search(r"CASE (\d+) (\w+) phase=(hidden|actor)",line)
   if m:
    case=int(m.group(1));name=m.group(2);phase=m.group(3)
    hwnd=next((h for h,v in windows if v=="RGSS Player"),None)
    if hwnd is None:continue
    time.sleep(.20)
    im=ImageGrab.grab(window=hwnd).convert("RGB")
    if im.size!=(544,416):raise RuntimeError("Native client dimensions "+str(im.size))
    filename=f"A36G_VX_NATIVE_CASE_{case:02d}_{name}_{phase}.png"
    path=base/filename;im.save(path)
    images[f"{case:02d}_{name}_{phase}"]={"file":filename,"sha256":hashlib.sha256(path.read_bytes()).hexdigest(),"size":list(im.size)}
    print("CAPTURE",filename,flush=True)
  if len(images)>=22 and any("A36G_ROAD before=" in x for x in events):break
finally:
 if proc and proc.poll() is None:
  proc.terminate()
  try:proc.wait(timeout=5)
  except subprocess.TimeoutExpired:proc.kill()
pairs={}
for case in range(11):
 keys=[k for k in images if k.startswith(f"{case:02d}_")]
 aa=next((images[k]["file"] for k in keys if k.endswith("_actor")),None)
 bb=next((images[k]["file"] for k in keys if k.endswith("_hidden")),None)
 if aa and bb:
  actor=Image.open(base/aa).convert("RGB");hidden=Image.open(base/bb).convert("RGB")
  diff=ImageChops.difference(actor,hidden)
  hist=diff.convert("RGB").getbbox()
  pixels=sum(any(v!=0 for v in px) for px in diff.getdata())
  pairs[case]={"actor":aa,"hidden":bb,"rgb_changed_coordinates":pixels,"difference_bounds":list(hist) if hist else None}
result={"stage":"A36G","native_exec":"RGSS Player","client_size":[544,416],"actual_runtime_scenario_lines":events,"screenshot_frames":images,"paired_differences":pairs,"modal_windows":error_windows,"unique_capture_count":len(images),"actor_test_count":len(pairs),"move_blocked_log":next((x for x in events if "A36G_BLOCK" in x),None),"move_road_log":next((x for x in events if "A36G_ROAD" in x),None),"runtime_map_enter":any("A36G_ENTER id=50 size=40x29" in x for x in events),"runtime_obj_loaded":any("A36G_MAP_OBJECTS count=192" in x for x in events),"source":"Pillow window=actual RGSS Player hwnd, not desktop foreground","formal_seal":"NO"}
(base/"A36G_VX_NATIVE_11_CASES_SCREEN_QA.json").write_text(json.dumps(result,indent=2,ensure_ascii=False),encoding="utf-8")
print(json.dumps({"screens":len(images),"cases":len(pairs),"modal":error_windows,"map_enter":result["runtime_map_enter"],"blocks":result["move_blocked_log"],"road":result["move_road_log"],"pairs":{k:v["rgb_changed_coordinates"] for k,v in pairs.items()}},indent=2))
