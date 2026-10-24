# -*- coding: utf-8 -*-
"""Exact local evidence ZIP T17C. Only folder being tested, does not touch game."""
import hashlib,zipfile,json
from pathlib import Path
root=Path(__file__).resolve().parent
dest=root.parent/"deliveries"/"FS_LPC_ARMING_SWORD_128_T17C_20261024.zip"
r=json.loads((root/"T17C_128_ARMING_WEAPON_VALIDATION.json").read_text(encoding="utf8"))
assert r["status"]=="T17C_128_CELL_WEAPON_24_FRAME_STRUCTURAL_PASS_HUMAN_PENDING"
assert r["total_frames"]==24 and r["weapon_edge_alpha_pixels_total"]==0 and r["cell_vs_sheet_rgba_identical"]
for name in ("RUN_T17C.cmd","T17C_RUN.log","inputs/CREDITS.csv","outputs/T17C_ARMING_STEEL_128_MASTER.png"):
 assert (root/name).is_file(),name
files=sorted(p for p in root.rglob("*") if p.is_file() and p.name!="DELIVERY_INTEGRITY.json")
index=[{"path":p.relative_to(root).as_posix(),"bytes":p.stat().st_size,"sha256":hashlib.sha256(p.read_bytes()).hexdigest()} for p in files]
(root/"DELIVERY_INTEGRITY.json").write_text(json.dumps({"source":"T17C_128_LPC_20261024","status":r["status"],"files":index,"note":"Private tool technical evaluation. Source licensing needs author attribution and usage review; not approved for production."},ensure_ascii=False,indent=2),encoding="utf8")
with zipfile.ZipFile(dest,"w",zipfile.ZIP_DEFLATED,compresslevel=9) as z:
 for p in files+[root/"DELIVERY_INTEGRITY.json"]:z.write(p,p.relative_to(root).as_posix())
with zipfile.ZipFile(dest) as z:
 assert z.testzip() is None
 assert len(z.namelist())==len(files)+1
 for row in index:assert hashlib.sha256(z.read(row["path"])).hexdigest()==row["sha256"],row["path"]
print(json.dumps({"path":str(dest),"count":len(files)+1,"bytes":dest.stat().st_size,"sha256":hashlib.sha256(dest.read_bytes()).hexdigest(),"status":r["status"]},ensure_ascii=False))
