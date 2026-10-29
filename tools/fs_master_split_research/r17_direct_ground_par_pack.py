#!/usr/bin/env python3
"""Archive rule correction + provenance test, no new art certification and no sealed FS binaries."""
from pathlib import Path
from zipfile import ZipFile,ZIP_DEFLATED
import hashlib,json
R=Path(__file__).resolve().parent;D=R/"R17_DIRECT_DUAL_OUTPUT_CORRECTION_20261029"
files=[R/"r17_direct_ground_par_pair_gate.py",R/"r17_direct_ground_par_pack.py"]
files += [x for x in D.iterdir() if x.is_file() and x.suffix.lower() in (".md",".json",".png") and x.name!="R17_DIRECT_DUAL_PACKAGE_SHA256.json"]
files=sorted(set(files))
dest=D/"FS_R17_USER_DIRECT_GROUND_PAR_CORRECTION_20261029.zip"
with ZipFile(dest,"w",ZIP_DEFLATED,compresslevel=6) as z:
 checks={}
 for f in files:
  rel=f.relative_to(R).as_posix()
  z.write(f,rel)
  checks[rel]={"sha256":hashlib.sha256(f.read_bytes()).hexdigest(),"bytes":f.stat().st_size}
 z.writestr("R17_DIRECT_LAYER_PACKAGE_MANIFEST.json",json.dumps({
 "status":"DIRECT_LAYER_USER_CORRECTION_RULES_AND_TESTS_ONLY",
 "art_qualified_source_first_pair_available":False,
 "user_generates_final_full_ground_from_pair":True,
 "user_sets_collision_on_FS":True,
 "original_Fs_K4_unchanged":True,
 "files":checks},ensure_ascii=False,indent=2))
with ZipFile(dest,"r") as z:assert z.testzip() is None
v={"zip":dest.name,"bytes":dest.stat().st_size,"sha256":hashlib.sha256(dest.read_bytes()).hexdigest(),
"file_count":len(files)+1,"status":"ZIP_CRC_PASS","formal_seal":False}
(D/"R17_DIRECT_DUAL_PACKAGE_SHA256.json").write_text(json.dumps(v,ensure_ascii=False,indent=2),encoding="utf8")
print("R17_DIRECT_PACKAGE",json.dumps(v,ensure_ascii=False),flush=True)