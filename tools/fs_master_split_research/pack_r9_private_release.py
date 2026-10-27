#!/usr/bin/env python3
"""R9 PRIVATE incremental native real walk and edge art-risk ZIP (exclude full 531MB K4 and Game.exe)."""
from pathlib import Path
from zipfile import ZipFile,ZIP_DEFLATED
import json,hashlib
R=Path(__file__).resolve().parent
out=R/"FS_R9_NATIVE_WALK_EDGE_AUDIT_PRIVATE_20261028.zip"
files=[
"RESEARCH_REPORT_R9.md","CURRENT_HANDOFF_R9.md","RUN_R9_NATIVE_WALK.cmd",
"build_r9_native_walking.py","capture_r9_native_walk.py",
"r9_edge_semantic_risk_audit.py","r9_final_gate.py","r9_make_native_walking_contact.py",
"R8_USER_ANNOTATION_20261028/R8_USER_ANNOTATION_AUTHORITY.json",
"R8_USER_ANNOTATION_20261028/PAR_R8_USER_RED_BLUE_SOURCE_ALIGNED.png",
"R9_NATIVE_WALKING_ISOLATED/R9_FINAL_GATE.json","R9_NATIVE_WALKING_ISOLATED/R9_WALK_BUILD.json",
"R9_EDGE_SEMANTIC_AUDIT/R9_EDGE_RISK_AUDIT.json",
"R9_EDGE_SEMANTIC_AUDIT/R9_8_RED_SOURCE_ALPHA_BOUNDARY_REVIEW.png"]
for item in ["NATIVE_WALK","NATIVE_WALK_REPLAY1"]:
 d=R/"R9_NATIVE_WALKING_ISOLATED"/item
 assert d.is_dir()
 files += [str(p.relative_to(R)).replace("\\","/") for p in d.iterdir() if p.is_file()]
for d in (R/"R8_USER_ANNOTATION_20261028").glob("RED_R0*_SAM2_SOURCE_PAR.png"):
 files.append(str(d.relative_to(R)).replace("\\","/"))
files=sorted(set(files))
list_sha={}
with ZipFile(out,"w",ZIP_DEFLATED,compresslevel=6) as zip:
 for f in files:
  p=R/f
  assert p.is_file(),f
  list_sha[f]={"bytes":p.stat().st_size,"sha256":hashlib.sha256(p.read_bytes()).hexdigest()}
  zip.write(p,f)
 zip.writestr("R9_PRIVATE_PACKAGE_MANIFEST.json",json.dumps({"status":"NATIVE_R9_TECH_PASS_SEMANTIC_ART_HOLD",
  "formal_505_scripts_not_included":True,"sealed_master_untouched":True,"private":True,
  "formal_scripts_source_SHA256":"5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa",
  "files":list_sha},ensure_ascii=False,indent=2))
with ZipFile(out,"r") as z:
 assert z.testzip() is None
v={"status":"R9_INCREMENTAL_PRIVATE_BACKUP_VERIFIED","path":str(out),"size":out.stat().st_size,
 "sha256":hashlib.sha256(out.read_bytes()).hexdigest(),"filecount":len(files)+1}
(R/"R9_PRIVATE_PACKAGE_CHECKSUM.json").write_text(json.dumps(v,ensure_ascii=False,indent=2),encoding="utf8")
print("R9_RELEASE",json.dumps(v,ensure_ascii=False),flush=True)