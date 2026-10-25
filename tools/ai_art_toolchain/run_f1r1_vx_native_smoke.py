from pathlib import Path
import subprocess,time,json,hashlib,os
R=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
P=R/"outputs/FS_F1R1_NATIVE_VX_ISOLATED_20261025"
log=P/"FS_RICH_VX_LOG.txt"
exe=P/"Game.exe"
assert exe.exists()
process=None
try:
 process=subprocess.Popen([str(exe)],cwd=str(P),stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
 print("NATIVE_PROCESS_STARTED",process.pid,flush=True)
 text=""
 for tick in range(80):
  time.sleep(0.5)
  if log.exists():text=log.read_text(encoding="ascii",errors="replace")
  if "F1R1_VX_NATIVE_221_221_PASS" in text or "F1R1_VX_NATIVE_221_221_FAIL" in text:break
  if process.poll() is not None:
   print("NATIVE_PROCESS_EXIT",process.returncode,flush=True)
   break
 finally_text=text
finally:
 if process is not None and process.poll() is None:
  process.terminate()
  try:process.wait(timeout=6)
  except subprocess.TimeoutExpired:process.kill();process.wait(timeout=4)
if "finally_text" not in globals():finally_text=log.read_text(encoding="ascii",errors="replace")
print("NATIVE_LOG_START")
print(finally_text[-2000:])
print("NATIVE_LOG_END")
required=["RICH_SCRIPT_LOADED","RICH_VX_BOOT","STYLE_VX_LAYERS ground=544x416 props=8","F1R1_VX_TILE_GRID result=0 blocked=18 walkable=203","F1R1_VX_NATIVE_221_221_PASS"]
missing=[s for s in required if s not in finally_text]
negative=["F1R1_VX_NATIVE_221_221_FAIL","RICH_VX_RUNTIME_GATE_FAIL","STYLE_NATIVE_4_GATES_FAIL"]
bad=[s for s in negative if s in finally_text]
result={"status":"PASS" if not missing and not bad else "FAIL","native_runner":"RPG_Maker_VX_RGSS2_windows_Game.exe","pid":process.pid if process else None,"required":required,"missing":missing,"fail_marker":bad,"process_exit":process.returncode if process else None,"script_sha":hashlib.sha256((P/"Data/Scripts.rvdata").read_bytes()).hexdigest()}
(R/"reports/F1R1_VX_NATIVE_ACTUAL_SMOKE.json").write_text(json.dumps(result,indent=2),encoding="utf-8")
(R/"reports/F1R1_VX_NATIVE_ACTUAL_LOG.txt").write_text(finally_text,encoding="utf-8")
print(json.dumps(result,ensure_ascii=True))
if result["status"]!="PASS":raise SystemExit(1)
