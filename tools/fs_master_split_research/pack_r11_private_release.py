#!/usr/bin/env python3
"""R11 ground3 source private incremental research. K4 Scripts.rvdata/Game.exe excluded.
Source ground3 user asset stored in user's private Drive only.
"""
from pathlib import Path
from zipfile import ZipFile,ZIP_DEFLATED
import json,hashlib
R=Path(__file__).resolve().parent
out=R/"FS_R11_GROUND3_40x29_PAR5_NATIVE_PRIVATE_20261028.zip"
files=["RESEARCH_REPORT_R11.md","CURRENT_HANDOFF_R11.md",
"R12_NEW_VILLAGE_001_PRODUCTION_GATES.md","R12_NEW_ELF_VILLAGE_001/R12_PROJECT_STATE.json",
"RUN_R11_LARGE_NATIVE.cmd",
"r11_ground3_authority_audit.py","build_r11_ground3_native.py","capture_r11_ground3_native.py",
"r11_ground3_large_source_par_experiment.py","build_r11_ground3_5object_native.py",
"prepare_r11_5par_capture.py","capture_r11_ground3_5par.py","r11_final_gate.py",
"R11_GROUND3_40x29_NATIVE/R11_GROUND3_BUILD.json",
"R11_GROUND3_5OBJECT_NATIVE/R11_5PAR_BUILD.json"]
for folder in ["R11_VILLAGE_SIZE_TECH",
               "R11_GROUND3_40x29_NATIVE/NATIVE","R11_GROUND3_40x29_NATIVE/NATIVE_REPLAY1",
               "R11_GROUND3_5OBJECT_NATIVE/NATIVE","R11_GROUND3_5OBJECT_NATIVE/NATIVE_REPLAY1"]:
 d=R/folder
 assert d.is_dir(),folder
 files += [str(p.relative_to(R)).replace("\\","/") for p in d.iterdir() if p.is_file()]
source=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE\Graphics\Parallaxes\ground3.png")
assert source.is_file()
files=sorted(set(files))
c={}
with ZipFile(out,"w",ZIP_DEFLATED,compresslevel=6) as z:
 for f in files:
  p=R/f;assert p.is_file(),f
  c[f]={"bytes":p.stat().st_size,"sha256":hashlib.sha256(p.read_bytes()).hexdigest()}
  z.write(p,f)
 z.write(source,"ORIGINAL_K4_PRIVATE/ground3.png")
 c["ORIGINAL_K4_PRIVATE/ground3.png"]={"bytes":source.stat().st_size,"sha256":hashlib.sha256(source.read_bytes()).hexdigest()}
 z.writestr("R11_PRIVATE_MANIFEST.json",json.dumps({"status":"TECH_PASS_40x29_NATIVE_PLUS_5_OBJECTS_ART_NEW_VILLAGE_NOT_CREATED",
    "formal_scripts_not_included":True,"formal_project_not_modified":True,
    "source_art_is_EXISTING_ground3_not_newly_generated":True,
    "original_25_Map003_events_not_tested":True,"private":True,"files":c},ensure_ascii=False,indent=2))
with ZipFile(out,"r") as z:assert z.testzip() is None
result={"status":"R11_PRIVATE_INCREMENTAL_BACKUP_VERIFIED",
"zip":str(out),"bytes":out.stat().st_size,"files_count":len(c)+1,
"sha256":hashlib.sha256(out.read_bytes()).hexdigest(),
"zip_crc_check":"PASS"}
(R/"R11_PACKAGE_CHECKSUM.json").write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding="utf8")
print("R11_PRIVATE_PACKAGE",json.dumps(result,ensure_ascii=False),flush=True)