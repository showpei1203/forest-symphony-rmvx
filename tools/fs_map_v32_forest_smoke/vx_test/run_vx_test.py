from pathlib import Path
import subprocess,time,sys,json
root=Path(r"E:\GameAssetToolLab_20261023\FS_ForestSplit_v3_2")
v=root/"vx_test"
p=v/"FS_VX_ISOLATED_TEST"
logs=root/"logs"
result={"candidate":"FS_FOREST_V32_VX_ISOLATED","template":"C:\\Users\\User\\Documents\\RPGVX\\Project1",
"steps":[],"formal_status":"PENDING"}
def check_step(name,pass_,detail=""):
  result["steps"].append({"name":name,"pass":bool(pass_),"detail":detail})
  print(("PASS " if pass_ else "FAIL ")+name+" "+detail,flush=True)
  if not pass_:raise RuntimeError("FAIL "+name)
proc=None
try:
  b=subprocess.run([sys.executable,str(v/"build_vx_test.py")],capture_output=True,text=True,timeout=30)
  check_step("isolated_build",b.returncode==0,b.stdout[-380:])
  proc=subprocess.Popen([str(p/"Game.exe")],cwd=p,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
  required=("FS_TEST_SCRIPT_LOADED","VX_TEST_BOOT","VX_LAYERS_CREATED","VX_RUNTIME_FRAME_100","VX_GATE_F_LOGIC_PASS","VX_MOVEMENT_GATES_PASS")
  deadline=time.time()+22
  logtext=""
  while time.time()<deadline:
    time.sleep(0.35)
    if (p/"FS_VX_TEST_LOG.txt").exists():logtext=(p/"FS_VX_TEST_LOG.txt").read_text(encoding="ascii",errors="replace")
    if all(needle in logtext for needle in required):break
    if proc.poll() is not None:break
  check_step("vx_runtime_log",all(needle in logtext for needle in required)," / ".join([f"{needle}={needle in logtext}" for needle in required]))
  capture=subprocess.run(["powershell.exe","-NoProfile","-ExecutionPolicy","Bypass","-File",str(v/"printwindow.ps1")],capture_output=True,text=True,errors="replace",timeout=20)
  check_step("vx_real_window_capture",capture.returncode==0 and "WINDOW_CAPTURE_OK=True" in capture.stdout,capture.stdout[-200:])
  qa=subprocess.run([sys.executable,str(v/"audit_screenshot.py")],capture_output=True,text=True,errors="replace",timeout=60)
  audit=json.loads((logs/"VX_SCREENSHOT_PIXEL_AUDIT.json").read_text(encoding="utf8")) if (logs/"VX_SCREENSHOT_PIXEL_AUDIT.json").exists() else {}
  check_step("real_vx_screenshot_pixel_exact",audit.get("strict_background_match",False) and audit.get("best",{}).get("offset")==[3,26],"pixels_different="+str(audit.get("best",{}).get("differing_pixels","unknown")))
  result["smoke_status"]="PASS"
  result["formal_status"]="VX_RUNTIME_SCRIPT+SCREENSHOT_PIXEL_PASS; HUMAN_MOVEMENT_VISUAL_PENDING"
except Exception as e:
  result["smoke_status"]="FAIL"
  result["formal_status"]="VX_RUNTIME_FAIL_CLOSED"
  result["error"]=str(e)
finally:
  if proc is not None and proc.poll() is None:
    proc.terminate()
    try:proc.wait(timeout=5)
    except subprocess.TimeoutExpired:proc.kill()
  (logs/"VX_RUNNER_SUMMARY.json").write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding="utf8")
  print("VX_RUNNER",result["smoke_status"],result["formal_status"],flush=True)
if result["smoke_status"]!="PASS":sys.exit(2)
