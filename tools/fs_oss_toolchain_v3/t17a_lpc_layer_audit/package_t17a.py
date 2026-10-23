# -*- coding: utf-8 -*-
from pathlib import Path
import hashlib,json,zipfile
root=Path(r"E:\GameAssetToolLab_20261023\ToolValidation_T17_20261024")
dest=root.parent/"deliveries"/"FS_LPC_NATIVE_4DIR_LAYER_T17A_20261024.zip"
r=json.loads((root/"T17A_LPC_LAYER_ALIGNMENT.json").read_text(encoding="utf-8"))
assert r["status"]=="T17A_LPC_3_ACTION_4D_88FRAMES_PASS" and r["total_frames"]==88
files=sorted(x for x in root.rglob("*") if x.is_file() and x.suffix.lower() in {".zip",".txt",".json",".png",".py",".cmd",".md"} and x.name!="DELIVERY_INTEGRITY.json")
entries=[{"path":p.relative_to(root).as_posix(),"size":p.stat().st_size,"sha256":hashlib.sha256(p.read_bytes()).hexdigest()} for p in files]
(root/"DELIVERY_INTEGRITY.json").write_text(json.dumps({"status":r["status"],"entries":entries,"note":"Original LPC credits and license accompany sources; for private technical test, not approved shipping assets."},ensure_ascii=False,indent=2),encoding="utf-8")
with zipfile.ZipFile(dest,"w",zipfile.ZIP_DEFLATED,compresslevel=9) as out:
 for p in files+[root/"DELIVERY_INTEGRITY.json"]:out.write(p,p.relative_to(root).as_posix())
with zipfile.ZipFile(dest) as z:
 assert z.testzip() is None
print(json.dumps({"zip":str(dest),"count":len(files)+1,"bytes":dest.stat().st_size,"sha256":hashlib.sha256(dest.read_bytes()).hexdigest(),"status":r["status"]}))
