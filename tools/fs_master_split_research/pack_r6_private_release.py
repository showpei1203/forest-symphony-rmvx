#!/usr/bin/env python3
"""R6 standalone incremental private package, excludes full 531MB original K4 and engine files."""
from pathlib import Path
from zipfile import ZipFile,ZIP_DEFLATED
import hashlib,json
R=Path(__file__).resolve().parent
out=R/"FS_R6_NATIVE_PAR_ABA_PRIVATE_20261027.zip"
files=[
"RESEARCH_REPORT_R6.md","CURRENT_HANDOFF_R6.md","RUN_R6_NATIVE_2REPLAY.cmd",
"build_r6_same_session_vx.py","capture_r6_same_session_vx.py",
"analyze_r6_same_session.py","diagnose_r6_temporal.py",
"observe_r6_error.py","make_r6_contact.py","r6_final_gate.py",
"R6_SAME_SESSION_ISOLATED/R6_BUILD_GATE.json",
"R6_SAME_SESSION_ISOLATED/R6_FINAL_GATE.json",
"R6_SAME_SESSION_ISOLATED/ERROR_DIAG/R6_dialog_6.png",
"R6_SAME_SESSION_ISOLATED/ERROR_DIAG/R6_game_6.png",
"R5_FORMAL_ADAPTER_ISOLATED/R5_FINAL_GATE.json",
"R5_FORMAL_READONLY_AUDIT/R5_TRUE_FORMAL_PASSPASSA_THIRDLAYER_USAGE.json",
"MASTER_OPAQUE_BLACK_MATTE.png",
]
for folder in ("R6_UNFROZEN_BASELINE_R0","R6_FROZEN_PASS_REPLAY_1","NATIVE_ABA"):
 root=R/"R6_SAME_SESSION_ISOLATED"/folder
 assert root.is_dir()
 files += [str(p.relative_to(R)).replace("\\","/") for p in root.rglob("*") if p.is_file()]
files=sorted(set(files))
sha={}
with ZipFile(out,"w",ZIP_DEFLATED,compresslevel=6) as z:
 for f in files:
  p=R/f
  assert p.is_file(),f
  sha[f]={"sha256":hashlib.sha256(p.read_bytes()).hexdigest(),"bytes":p.stat().st_size}
  z.write(p,f)
 manifest={
 "status":"R6_ISOLATED_RENDERER_TECH_PASS_SEMANTIC_ART_HOLD_FORMAL505_BOOT_FAIL",
 "confidential":True,"source_authority_sha256":"5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa",
 "source_requirement":"Existing K4_BASELINE local full FS project + R5 documented research set; 531MB FS source not packed",
 "R6_2_independent_sessions":True,"total_R6_native_shots_verified":30,
 "files":sha}
 z.writestr("R6_PACKAGE_MANIFEST.json",json.dumps(manifest,ensure_ascii=False,indent=2))
with ZipFile(out,"r") as check:
 assert check.testzip() is None
report={"zip":str(out),"bytes":out.stat().st_size,"sha256":hashlib.sha256(out.read_bytes()).hexdigest(),
 "file_count":len(files)+1,"self_test":True}
(R/"R6_PRIVATE_PACKAGE_CHECKSUM.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print(json.dumps(report,ensure_ascii=False),flush=True)