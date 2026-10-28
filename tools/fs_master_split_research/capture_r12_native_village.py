#!/usr/bin/env python3
"""Real RPG Maker VX new generated 1280x928 village, 14 source PAR and collision move tests."""
from pathlib import Path
from PIL import Image,ImageGrab
import ctypes,subprocess,time,json,re
R=Path(__file__).resolve().parent;D=R/"R12_NEW_ELF_VILLAGE_001"
W=R/"R12_NEW_ELF_VILLAGE_NATIVE"/"FULL505";O=R/"R12_NEW_ELF_VILLAGE_NATIVE"/"NATIVE"
O.mkdir(parents=True,exist_ok=True)
cases=json.loads((D/"R12_NATIVE_TEST_CASES.json").read_text(encoding="utf8"))
ids=[c["id"] for c in cases]
log=W/"R12_NEW_VILLAGE_NATIVE.log"
log.write_text("R12_REAL_VX_START\n",encoding="ascii")
proc=subprocess.Popen([str(W/"Game.exe")],cwd=W,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
pics={}
try:
 hwnd=0;start=time.monotonic()
 while time.monotonic()-start<80:
  time.sleep(.03)
  s=log.read_text(encoding="ascii",errors="replace") if log.exists() else ""
  if not hwnd:hwnd=ctypes.windll.user32.FindWindowW(None,"FS_R12_ELF_VILLAGE_001")
  for item in ids:
   if item not in pics and ("R12_SCREEN "+item+" ") in s and hwnd:
    file=O/(item+".png")
    try:ImageGrab.grab(window=hwnd).save(file)
    except Exception as e:print("R12_NATIVE_CAPTURE_ERROR",item,str(e),flush=True);continue
    assert Image.open(file).size==(544,416)
    pics[item]=file.name
    print("R12_REAL_NATIVE_SCREEN",item,len(pics),flush=True)
  if "R12_ALL_CASES_COMPLETE" in s and len(pics)==len(ids):break
  if proc.poll() is not None:break
 (O/"GAME_LOG.txt").write_text(s,encoding="utf8")
 records=[]
 for item in ids:
  action=re.search(r"^R12_REAL_MOVE "+re.escape(item)+r" (.+)$",s,re.M)
  screen=re.search(r"^R12_SCREEN "+re.escape(item)+r" (.+)$",s,re.M)
  records.append({"id":item,"action":action.group(1) if action else None,"screen":screen.group(1) if screen else None,
   "gate":bool(action and "pass=true" in action.group(1) and screen and "verified=true" in screen.group(1))})
 result={"status":"R12_NEW_MASTER_14_PAR_NATIVE_TECH_PASS" if len(pics)==len(ids) and all(x["gate"] for x in records) and "R12_ALL_CASES_COMPLETE true" in s else "R12_NEW_MASTER_NATIVE_HOLD",
 "game_pid":proc.pid,"captures":pics,"tests":records,
 "native_new_image_master":True,"new_image_source_PAR_14_objects":True,
 "real_original_formal_505_boot":False,
 "visual_art_gate_F":"HOLD"}
 (O/"R12_NATIVE_GATE.json").write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding="utf8")
 print("R12_NATIVE_TEST_RESULT",result["status"],sum(x["gate"] for x in records),"/",len(records),flush=True)
 if result["status"]!="R12_NEW_MASTER_14_PAR_NATIVE_TECH_PASS":raise SystemExit(2)
finally:
 if proc.poll() is None:
  proc.terminate()
  try:proc.wait(timeout=4)
  except subprocess.TimeoutExpired:proc.kill()