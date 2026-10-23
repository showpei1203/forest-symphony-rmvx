from pathlib import Path
from PIL import ImageGrab
from shutil import copy2
import subprocess,sys,time,ctypes,json
r=Path(r"E:\GameAssetToolLab_20261023\FS_ElfVillage_RichPilot_20261023")
logs=r/"logs"
reports=[]
def execute(tag,command,timeout=75,contains=None):
 started=time.monotonic()
 p=subprocess.run(list(map(str,command)),cwd=r,capture_output=True,text=True,errors="replace",timeout=timeout)
 transcript=p.stdout+"\n"+p.stderr
 (logs/(tag+".log")).write_text(transcript,encoding="utf8")
 success=p.returncode==0 and (contains is None or contains in transcript)
 item={"step":tag,"pass":success,"exit":p.returncode,"elapsed_ms":int((time.monotonic()-started)*1000),"log":tag+".log","tail":transcript[-1100:]}
 reports.append(item)
 print(("PASS " if success else "FAIL ")+tag,flush=True)
 if not success:raise RuntimeError(tag+" FAILED: "+transcript[-550:])
 return item
def stage():
 execute("00_source_repair",[sys.executable,r/"scripts"/"repair_source_v2.py"],20)
 execute("01_scene_blueprint",[sys.executable,r/"scripts"/"make_scene_v2.py"],20)
 execute("02_ground_par_compile",[sys.executable,r/"scripts"/"compile_rich_scene.py"],30)
 execute("03_pixel_owner",[sys.executable,r/"scripts"/"partition_visible_owner.py"],20)
 execute("04_source_and_layer_gates",[sys.executable,r/"scripts"/"validate_rich_v2.py"],40,"RICH_V2_GATES PASS")
 execute("05_tiled_negative_1px",[sys.executable,r/"scripts"/"negative_tiled_1px.py"],35,"NEGATIVE_DETECTED")
 execute("06_prepare_godot",[sys.executable,r/"scripts"/"prepare_godot_v2.py"],25)
def run_engines():
 godot=Path(r"E:\Godot\4.7.2\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe")
 godotdir=r/"godot_test"
 execute("07_godot_asset_import",[godot,"--headless","--path",godotdir,"--editor","--import","--quit"],50)
 execute("08_godot_native_gpu",[godot,"--path",godotdir,"--quit-after","250","--","--smoke"],45,"GODOT_RICH_GATE_F_LOGIC_PASS")
 assert (godotdir/"captures"/"RICH_GODOT_V2_NATIVE.png").is_file()
 execute("09_build_independent_vx",[sys.executable,r/"vx_test"/"build_rich_vx.py"],40,"RICH_VX_ISOLATED_BUILD")
 test=r/"vx_test"/"FS_RICH_VX_ISOLATED"
 # Restrict cleanup to the uniquely named isolated game test.
 ps="Get-Process Game -ErrorAction SilentlyContinue | Where-Object {$_.MainWindowTitle -eq 'FS_ELF_RICH_VX_TEST_V2'} | Stop-Process -Force -ErrorAction SilentlyContinue"
 subprocess.run(["powershell.exe","-NoProfile","-Command",ps],timeout=15)
 (test/"FS_RICH_VX_LOG.txt").write_text("RICH_TEST_BEGIN\n",encoding="ascii")
 proc=subprocess.Popen([str(test/"Game.exe")],cwd=test,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
 try:
  required=("RICH_SCRIPT_LOADED","RICH_VX_RUNTIME_GATE_PASS","RICH_RUNTIME_100_FRAMES")
  deadline=time.monotonic()+22
  contents=""
  while time.monotonic()<deadline:
   time.sleep(.4)
   contents=(test/"FS_RICH_VX_LOG.txt").read_text(encoding="ascii",errors="replace")
   if all(x in contents for x in required):break
   if proc.poll() is not None:break
  passed=all(x in contents for x in required)
  copy2(test/"FS_RICH_VX_LOG.txt",logs/"VX_ENGINE_NATIVE.log")
  reports.append({"step":"10_vx_native_runtime","pass":passed,"native_log":contents[-1200:]})
  print(("PASS " if passed else "FAIL ")+"10_vx_native_runtime",flush=True)
  if not passed:raise RuntimeError("native VX runtime missing Gate marker")
  hwnd=ctypes.windll.user32.FindWindowW(None,"FS_ELF_RICH_VX_TEST_V2")
  if not hwnd:raise RuntimeError("native VX window not found")
  ImageGrab.grab(window=hwnd).save(logs/"RICH_VX_NATIVE_FRAME.png")
  execute("11_vx_native_rgb_audit",[sys.executable,r/"vx_test"/"audit_pixel.py"],35,"NATIVE_BACKGROUND_PIXEL_PASS")
 finally:
  if proc.poll() is None:
   proc.terminate()
   try:proc.wait(timeout=4)
   except subprocess.TimeoutExpired:proc.kill()

try:
 stage()
 run_engines()
 status="DUAL_ENGINE_NATIVE_SMOKE_PASS_FORMAL_FS_RUNTIME_AND_HUMAN_GATE_F_PENDING"
except Exception as ex:
 status="FAIL_CLOSED"
 reports.append({"step":"error","pass":False,"detail":str(ex)})
 summary={"status":status,"steps":reports,"village":["48 non-ground props","19 ground flora","5 interactions","864x640 world"],"formal":"PENDING"}
 (logs/"RICH_V2_FINAL_REGRESSION.json").write_text(json.dumps(summary,ensure_ascii=False,indent=2),encoding="utf8")
 print("RICH_RUNNER",status,str(ex),flush=True)
 raise SystemExit(2)
summary={"status":status,"steps":reports,"formal":"PENDING HUMAN GATE F AND SEALED FOREST SYMPHONY RUNTIME COMPATIBILITY"}
(logs/"RICH_V2_FINAL_REGRESSION.json").write_text(json.dumps(summary,ensure_ascii=False,indent=2),encoding="utf8")
print("RICH_RUNNER",status,flush=True)
