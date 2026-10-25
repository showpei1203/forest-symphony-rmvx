from pathlib import Path
import subprocess,time,json,hashlib
R=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
P=R/"outputs/F2_R3_G4_VX_REAL_GAME_20261026"
G=P/"Game.exe"
log=P/"FS_RICH_VX_LOG.txt"
assert G.is_file()
log.write_text("F2G4_NATIVE_45x34_TEST_START\n",encoding="ascii")
p=subprocess.Popen([str(G)],cwd=str(P),stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
try:
 content=""
 for i in range(90):
  time.sleep(.5)
  content=log.read_text(encoding="ascii",errors="replace")
  if "F2G4_VX_NATIVE_1530_1530_PASS" in content or "F2G4_VX_NATIVE_1530_1530_FAIL" in content:break
  if p.poll() is not None:break
finally:
 if p.poll() is None:
  p.terminate()
  try:p.wait(timeout=5)
  except subprocess.TimeoutExpired:p.kill();p.wait(timeout=4)
needed=["RICH_SCRIPT_LOADED","RICH_VX_BOOT spawn=[24, 23]",
"STYLE_VX_LAYERS ground=1440x1088 props=9",
"F2G4_VX_TILEGRID wrong=0 blocked=711 free=819",
"F2G4_VX_DOOR adjacent_front=true closed_door_denies=true",
"F2G4_VX_CAMERA long_right=true center=true props=true",
"F2G4_VX_NATIVE_1530_1530_PASS"]
miss=[x for x in needed if x not in content]
bad=["F2G4_VX_NATIVE_1530_1530_FAIL","STYLE_NATIVE_4_GATES_FAIL"]
state={"status":"PASS" if not miss and not any(x in content for x in bad) else "FAIL",
"missing":miss,"process_id":p.pid,"native_engine":"RPG Maker VX RGSS2 Game.exe",
"game_script_sha256":hashlib.sha256((P/"Data/Scripts.rvdata").read_bytes()).hexdigest(),
"test_scope":"1530 full map grid, door adjacent pass/deny, 45x34 pan camera, 9 scene props",
"visual_art":"FAIL",
"original_accepted_f1r1":"UNCHANGED"}
(R/"reports/F2G4_NATIVE_VX_REAL_TEST_RESULT.json").write_text(json.dumps(state,indent=2),encoding="utf-8")
(R/"reports/F2G4_NATIVE_VX_REAL_TEST.log").write_text(content,encoding="utf-8")
print("F2G4_REAL_VX_RESULT",json.dumps(state),flush=True)
print("F2G4_REAL_VX_TAIL",content[-1000:].encode("ascii","backslashreplace").decode("ascii"),flush=True)
if state["status"]!="PASS":raise SystemExit(1)
