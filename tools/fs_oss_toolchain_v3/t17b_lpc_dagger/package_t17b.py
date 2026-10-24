# -*- coding: utf-8 -*-
import hashlib,json,zipfile
from pathlib import Path
root=Path(__file__).resolve().parent
dest=root.parent/"deliveries"/"FS_LPC_DAGGER_WEAPON_T17B_20261024.zip"
r=json.loads((root/"T17B_LPC_WEAPON_LAYER_ALIGNMENT.json").read_text(encoding="utf-8"))
assert r["status"]=="T17B_LPC_DAGGER_TWO_DEPTH_24FRAME_STRUCTURAL_PASS"
assert r["frame_count"]==24 and r["perframe_vs_full_rgba_exact"]
for name in ("lpc_base_assets.zip","README_繁體中文.md","RUN_T17B.cmd","run_t17b.py","T17B_RUN.log"):
 assert (root/name).is_file(),name
src=(root/"inputs"/"dagger_front_slash.png").read_bytes()
assert hashlib.sha256(src).hexdigest()=="238792746ed9d90148ac9a85c88d224f1ea81ea2376fcb85228b26fdf1159cd1"
files=sorted(p for p in root.rglob("*") if p.is_file() and p!=dest and p.name!="DELIVERY_INTEGRITY.json")
listing=[{"path":p.relative_to(root).as_posix(),"size":p.stat().st_size,"sha256":hashlib.sha256(p.read_bytes()).hexdigest()} for p in files]
manifest={"status":r["status"],"file_count":len(listing)+1,"files":listing,"release_role":"PERSONAL_TECH_TEST_NOT_SHIPPING_ASSETS"}
(root/"DELIVERY_INTEGRITY.json").write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding="utf-8")
with zipfile.ZipFile(dest,"w",zipfile.ZIP_DEFLATED,compresslevel=9) as out:
 for p in files+[root/"DELIVERY_INTEGRITY.json"]:out.write(p,p.relative_to(root).as_posix())
with zipfile.ZipFile(dest) as check:
 assert check.testzip() is None
 assert len(check.namelist())==len(listing)+1
 for row in listing:
  assert hashlib.sha256(check.read(row["path"])).hexdigest()==row["sha256"]
print(json.dumps({"archive":str(dest),"files":len(listing)+1,"bytes":dest.stat().st_size,"sha256":hashlib.sha256(dest.read_bytes()).hexdigest(),"result":r["status"]},ensure_ascii=False))
