#!/usr/bin/env python3
"""Build R17 private reproducible evidence for source-first 544x416 B/C comparison.
Do not include user original sealed K4 binary, no model weights. False A status is preserved.
"""
from pathlib import Path
from zipfile import ZipFile,ZIP_DEFLATED
from PIL import Image
import json,hashlib
ROOT=Path(__file__).resolve().parent
D=ROOT/"R17_ELF_CORNER_TRIPLE_PATH_20261029"
basefiles=["R17_GROUND_PAR_DUAL_GATE_AUTHORITY.md","R17_RESEARCH_REPORT.md",
"CURRENT_HANDOFF_R17.md",
"R17_REFERENCE_R12_HIGH_DETAIL_CROP.png",
"R17_STAGE1_EVIDENCE_GATE.json","R17_NATIVE_GODOT_AND_ART_GATE.json",
"R17_B_C_TRUE_GODOT_6_PANEL.png"]
files=[D/f for f in basefiles]
files += [ROOT/f for f in ("r17_benchmark_three_path_stage1.py","r17_create_godot_compare_projects.py","r17_validate_dual_gate.py")]
for name in ("A_PAIR_GENERATION","B_MASTER_FIRST","C_OBJECT_FIRST_CONTINUOUS_PLATE"):
 for file in (D/name).rglob("*"):
  if not file.is_file():continue
  if file.name.endswith(".import") or ".godot" in file.parts or file.name=="godot_import.log":continue
  files.append(file)
files=sorted(set(files))
checks={}
out=D/"FS_R17_ELF_GROUND_PAR_DUAL_GATE_STAGE1_PRIVATE_20261029.zip"
with ZipFile(out,"w",ZIP_DEFLATED,compresslevel=6) as z:
 for p in files:
  assert p.is_file(),str(p)
  rel=p.relative_to(ROOT).as_posix()
  checks[rel]={"sha256":hashlib.sha256(p.read_bytes()).hexdigest(),"bytes":p.stat().st_size}
  z.write(p,rel)
 z.writestr("R17_SEALED_PRIVATE_RESEARCH_MANIFEST.json",json.dumps({
 "status":"R17_STAGE1_BC_GODOT_NATIVE_TECH_PASS_ART_HOLD_A_NOT_RUN",
 "user_art_GateF":"HOLD",
 "production_Fs_Seal":False,
 "formal_K4_untouched":True,
 "no_pretend_A_pair_generation":True,
 "No_sealed_RPGMaker_scripts_or_binary":True,
 "files":checks},ensure_ascii=False,indent=2))
with ZipFile(out,"r") as z:assert z.testzip() is None
expected={
 "R17_GROUND_PAR_DUAL_GATE_AUTHORITY.md",
 "CURRENT_HANDOFF_R17.md",
 "R17_RESEARCH_REPORT.md"}
assert expected.issubset(set(basefiles))
m={"status":"ZIP_CRC_AND_SHA256_OK",
 "filename":out.name,"sha256":hashlib.sha256(out.read_bytes()).hexdigest(),
 "bytes":out.stat().st_size,"files":len(files)+1,"original_fs_k4_sealed_modified":False,
 "human_ART_GateF":"HOLD"}
(D/"R17_PRIVATE_PACKAGE_SHA256.json").write_text(json.dumps(m,ensure_ascii=False,indent=2),encoding="utf8")
print("R17_PRIVATE_PACKAGE",json.dumps(m,ensure_ascii=False),flush=True)