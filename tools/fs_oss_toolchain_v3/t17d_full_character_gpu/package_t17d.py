# -*- coding: utf-8 -*-
"""Package T17D 24 actual GPU captures + source + all logs; fail-closed."""
from pathlib import Path
import json,hashlib,zipfile
root=Path(__file__).resolve().parent
report=json.loads((root/"T17D_INCREMENTAL_REGRESSION.json").read_text(encoding="utf-8"))
gpu=json.loads((root/"T17D2_GODOT_GPU_RENDER_AUDIT.json").read_text(encoding="utf-8"))
assert report["status"]=="T17D1_T17D2_REAL_GPU_5_OF_5_PASS"
assert report["sealed_scripts_unchanged"] and gpu["captured_frames"]==gpu["distinct_screenshot_hashes"]==24
assert gpu["max_rgb_channel_error_vs_expected_blend"]==gpu["outside_drawregion_total_changed"]==0
assert len(list((root/"godot/LPC128_24frame/captures").glob("T17D2_?_?.png")))==24
dest=root.parent/"deliveries"/"FS_LPC_FULLCHAR_WEAPON_GODOT_T17D_20261024.zip"
dest.parent.mkdir(parents=True,exist_ok=True)
ignore_dirs={".godot","__pycache__"}
files=sorted(p for p in root.rglob("*") if p.is_file() and not set(p.parts)&ignore_dirs and p.name!="DELIVERY_INTEGRITY.json")
need={"run_t17d1.py","prepare_t17d2_godot.py","audit_t17d2_gpu.py","run_all_t17d.py","RUN_T17D.cmd","T17D2_GPU.log","README_繁體中文.md"}
assert need.issubset({p.name for p in files})
item=[{"path":p.relative_to(root).as_posix(),"size":p.stat().st_size,"sha256":hashlib.sha256(p.read_bytes()).hexdigest()} for p in files]
(root/"DELIVERY_INTEGRITY.json").write_text(json.dumps({"status":report["status"],"file_count":len(files)+1,"files":item,
 "license":"TECHNICAL TEST, official LPC licensed media with attribution, NOT game approved commercial assets",
 "SBS_test":"NOT_TESTED","artistic_gate":"PENDING"},ensure_ascii=False,indent=2),encoding="utf8")
with zipfile.ZipFile(dest,"w",zipfile.ZIP_DEFLATED,compresslevel=9) as z:
 for p in files+[root/"DELIVERY_INTEGRITY.json"]:z.write(p,p.relative_to(root).as_posix())
with zipfile.ZipFile(dest) as z:
 assert z.testzip() is None and len(z.namelist())==len(files)+1
 for ent in item:assert hashlib.sha256(z.read(ent["path"])).hexdigest()==ent["sha256"]
print(json.dumps({"path":str(dest),"files":len(files)+1,"size":dest.stat().st_size,
"sha256":hashlib.sha256(dest.read_bytes()).hexdigest(),"result":report["status"]},ensure_ascii=False))
