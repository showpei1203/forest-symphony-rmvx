# -*- coding: utf-8 -*-
from pathlib import Path
import zipfile,json,hashlib,time
R=Path(__file__).resolve().parent
assert json.loads((R/"DENSE_DEPTH_RESULT.json").read_text(encoding="utf8"))["static_mismatch_positions"]==450
aud=json.loads((R/"DEPTH_GODOT_GPU_AUDIT.json").read_text(encoding="utf8"))
assert aud["status"]=="FS_MAP_DYNAMIC_YDEPTH_GODOT_GPU_PASS" and aud["matching_four_png"]==4
assert (R/"RUN_DEPTH_GATE.cmd").is_file() and len(list((R/"godot_depth_probe"/"GPU_PROBES").glob("*.png")))==4
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
prefix="FS_GROUND_PAR_DYNAMIC_DEPTH_SOURCE_FIRST_V1_20261024"
dest=R.parent/"deliveries"/(prefix+".zip")
assert not dest.exists(),"Do not overwrite existing delivery"
skip={".godot","__pycache__",".git"}
files=sorted(p for p in R.rglob("*") if p.is_file() and
    not skip.intersection(p.relative_to(R).parts) and
    not p.name.endswith(".import") and p.name not in ("PACKAGE_INTEGRITY.json",))
entry=[{"path":p.relative_to(R).as_posix(),"size":p.stat().st_size,"sha256":sha(p)} for p in files]
assert len({x["path"] for x in entry})==len(entry)
manifest={"status":"FS_MAP_DEPTH_SEPARATION_TEST_4_REAL_GPU_PASS_ART_F_PENDING",
  "master_immutable":True,"formal_FS_505_scripts_unchanged":True,
  "rich_pilot_assets":"PRIVATE_SOURCE_CANDIDATE_LICENSE_UNVERIFIED",
  "walkable_static_wrong_positions":450,
  "max_static_wrong_actor_pixels":193,
  "native_godot_gpu_4_exact":True,
  "vx_dynamic_runtime":"NOT_TESTED",
  "pixel_art_fidelity":"DOES_NOT_MATCH_SCENE04",
  "file_count":len(entry)+1,"files":entry}
intfile=R/"PACKAGE_INTEGRITY.json"
intfile.write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding="utf8")
entry.append({"path":intfile.name,"size":intfile.stat().st_size,"sha256":sha(intfile)})
t=time.monotonic()
with zipfile.ZipFile(dest,"w",zipfile.ZIP_DEFLATED,compresslevel=6,allowZip64=True) as z:
 for i,x in enumerate(entry):
  z.write(R/x["path"],prefix+"/"+x["path"])
  if i%80==0:print("ZIP_ITEMS",i+1,flush=True)
with zipfile.ZipFile(dest) as z:
 assert z.testzip() is None
 assert len(z.namelist())==len(entry)
 for x in entry:
  assert hashlib.sha256(z.read(prefix+"/"+x["path"])).hexdigest()==x["sha256"],x["path"]
report={"status":manifest["status"],"zip":str(dest),"sha256":sha(dest),"bytes":dest.stat().st_size,
    "files":len(entry),"native_exact_gpu":4,"python_and_native_quick_test":"PASS", "elapsed":round(time.monotonic()-t,2)}
(R/"FINAL_PACKAGE_REPORT.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print("DEPTH_ZIP_PASS",json.dumps(report,ensure_ascii=False),flush=True)
