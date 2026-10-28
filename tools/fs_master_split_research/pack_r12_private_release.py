#!/usr/bin/env python3
"""R12 private incremental release: R12 new Master, 18 test masks, selected source PAR,
collision + native evidence, without K4 original full FS sealed scripts and Game.exe.
"""
from pathlib import Path
from zipfile import ZipFile,ZIP_DEFLATED
import json,hashlib
R=Path(__file__).resolve().parent
D=R/"R12_NEW_ELF_VILLAGE_001"
out=R/"FS_R12_NEW_ELF_VILLAGE_001_MASTER_PAR14_NATIVE_PRIVATE_20261028.zip"
files=["RESEARCH_REPORT_R12.md","CURRENT_HANDOFF_R12.md","R12_NEW_VILLAGE_001_PRODUCTION_GATES.md",
"RUN_R12_FULL_NATIVE_GATE.cmd",
"r12_new_village_sam2_source_par.py","r12_filter_source_par_and_collision.py",
"r12_fix_map_injection_build.py","build_r12_native_village.py",
"capture_r12_native_village.py","r12_final_gate.py","r12_make_visual_review.py",
"r12_update_state.py",
"R12_NEW_ELF_VILLAGE_NATIVE/R12_BUILD_MANIFEST.json","R12_NEW_ELF_VILLAGE_NATIVE/R12_FINAL_GATE.json"]
for folder in ["R12_NEW_ELF_VILLAGE_001","R12_NEW_ELF_VILLAGE_NATIVE/NATIVE","R12_NEW_ELF_VILLAGE_NATIVE/NATIVE_REPLAY1"]:
 d=R/folder;assert d.is_dir(),folder
 files += [str(p.relative_to(R)).replace("\\","/") for p in d.iterdir() if p.is_file()]
files=sorted(set(files))
hashes={}
with ZipFile(out,"w",ZIP_DEFLATED,compresslevel=6) as z:
 for f in files:
  p=R/f
  assert p.is_file(),f
  hashes[f]={"bytes":p.stat().st_size,"sha256":hashlib.sha256(p.read_bytes()).hexdigest()}
  z.write(p,f)
 z.writestr("R12_PRIVATE_RELEASE_MANIFEST.json",json.dumps({
  "status":"NEW_MASTER_1280x928_AND_14_SOURCE_PAR_2NATIVE_RUN_TECH_PASS_ART_HOLD",
  "new_master_SHA256":"eda8fa28b537d9a96ee839f8c5c667c466bd55102731d41a7a9e560362854c80",
  "source_ground_new_generated":True,
  "user_par_approval":"PENDING_LATER_REVIEW",
  "formal_K4_files_modified":False,
  "known_issues":["only 14 of 18 guided masks selected, incomplete full occlusion","native test-only resource alias ground3","art gate A/F unapproved","generated 32px style native crispness unapproved","no formal Map.rvdata export due Ruby Marshal forward ref"],
  "private":True,"no_original_K4_Scripts_or_GameExe":True,"files":hashes
 },ensure_ascii=False,indent=2))
with ZipFile(out,"r") as z: assert z.testzip() is None
result={"status":"R12_PRIVATE_PACKAGE_CRC_SHA_OK","path":str(out),
        "size_bytes":out.stat().st_size,"filecount":len(files)+1,
        "sha256":hashlib.sha256(out.read_bytes()).hexdigest(),
        "formal_seal":False}
(R/"R12_PRIVATE_RELEASE_SHA256.json").write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding="utf8")
print("R12_PRIVATE_PACKAGE",json.dumps(result,ensure_ascii=False),flush=True)