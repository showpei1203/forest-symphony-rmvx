#!/usr/bin/env python3
"""R10 curated private research, contains no full K4 project, Game.exe or sealed 505 scripts."""
from pathlib import Path
from zipfile import ZipFile,ZIP_DEFLATED
import json,hashlib
R=Path(__file__).resolve().parent
zfile=R/"FS_R10_SCENE21_FORMAL_MAP_COLLISION_NATIVE_PRIVATE_20261028.zip"
base=[
"RESEARCH_REPORT_R10.md","CURRENT_HANDOFF_R10.md","RUN_R10_MAP050_SOURCE_AND_COLLISION.cmd",
"r10_formal_map_match_audit.py","r10_formal_map050_tile_audit.py",
"build_r10_actual_formal_map050.py","capture_r10_actual_map050.py",
"r10_compile_scene21_collision_candidate.py","build_r10_collision_candidate_native.py",
"prepare_r10_candidate_capture.py","capture_r10_collision_candidate.py",
"r10_final_gate.py","r10_make_native_comparison.py",
"SCENE21_GUIDED_SAM2_CANDIDATE/MASTER_RGBA.png",
"R8_USER_ANNOTATION_20261028/R8_USER_ANNOTATION_AUTHORITY.json",
"R8_USER_ANNOTATION_20261028/PAR_R8_USER_RED_BLUE_SOURCE_ALIGNED.png",
"R10_ORIGINAL_MAP050_NATIVE/R10_BUILD.json",
"R10_COLLISION_NATIVE_CANDIDATE/R10_CANDIDATE_BUILD.json",
"R10_COLLISION_NATIVE_CANDIDATE/R10_FINAL_GATE.json",
"R10_FORMAL_MAP_AUTHORITY/Map050_SCENE21_COLLISION_CANDIDATE.rvdata",
]
for k in ["R10_FORMAL_MAP_AUTHORITY","R10_ORIGINAL_MAP050_NATIVE/NATIVE_MAP050",
 "R10_COLLISION_NATIVE_CANDIDATE/NATIVE_REPLAY1",
 "R10_COLLISION_NATIVE_CANDIDATE/NATIVE_CANDIDATE"]:
 d=R/k;assert d.is_dir(),k
 base += [str(f.relative_to(R)).replace("\\","/") for f in d.iterdir() if f.is_file()]
files=sorted(set(base));checks={}
with ZipFile(zfile,"w",ZIP_DEFLATED,compresslevel=6) as z:
 for f in files:
  p=R/f
  assert p.is_file(),f
  checks[f]={"bytes":p.stat().st_size,"sha256":hashlib.sha256(p.read_bytes()).hexdigest()}
  z.write(p,f)
 z.writestr("R10_PRIVATE_MANIFEST.json",json.dumps({
 "status":"ISOLATED_NATIVE_COLLISION_COMPILER_TECH_PASS_FORMAL_SCRIPT_BOOT_AND_ART_HOLD",
 "project_source":"FS K4 SHA256 5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa",
 "original_Map050_sha256":"55bed528d21644de4d840949614163b35a21b9b39fba7e85951b862b84693c26",
 "private_file_contents":True,"no_Game_exe_or_formal_Scripts_dump":True,
 "art_gate_F":False,"files":checks},ensure_ascii=False,indent=2))
with ZipFile(zfile,"r") as z:
 assert z.testzip() is None
r={"zip":str(zfile),"bytes":zfile.stat().st_size,"files":len(files)+1,
 "sha256":hashlib.sha256(zfile.read_bytes()).hexdigest(),
 "package_integrity":"PASS"}
(R/"R10_PRIVATE_RELEASE_SHA256.json").write_text(json.dumps(r,ensure_ascii=False,indent=2),encoding="utf8")
print("R10_PRIVATE_PACKAGE",json.dumps(r,ensure_ascii=False),flush=True)