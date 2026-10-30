from pathlib import Path
import subprocess,time,json,hashlib
d=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\VX_A09_3_INENGINE_BRIDGE")
log=d/"A09_3_ENGINE_TEST.log"
if log.exists():log.unlink()
p=subprocess.Popen([str(d/"Game.exe")],cwd=d,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
started=time.monotonic()
try:
 while time.monotonic()-started<65:
  if log.exists():
   t=log.read_text(encoding="ascii",errors="replace")
   if "A093_BRIDGE_FINISHED" in t or "A093_BRIDGE_FAIL" in t:break
  if p.poll() is not None:break
  time.sleep(.25)
finally:
 if p.poll() is None:
  p.terminate()
  try:p.wait(timeout=4)
  except subprocess.TimeoutExpired:p.kill()
out={"engine_pid":p.pid,"log":log.read_text(encoding="ascii",errors="replace") if log.exists() else None,"exit_after_termination":p.returncode,"seconds":round(time.monotonic()-started,2),"files":[{"name":q.name,"size":q.stat().st_size,"sha256":hashlib.sha256(q.read_bytes()).hexdigest()} for q in (d/"A09_3_ENGINE_NATIVE").glob("*")] if (d/"A09_3_ENGINE_NATIVE").exists() else []}
p2=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\vx_real_actor_20261031\a09_3\bridge_runtime_report.json")
p2.write_text(json.dumps(out,indent=2),encoding="utf-8")
print(json.dumps(out,indent=2)[:4000])