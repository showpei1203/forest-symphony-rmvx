#!/usr/bin/env python3
"""PRIVATE incremental R8. Exclude executable, formal Scripts.rvdata and large 505 source clone."""
from pathlib import Path
from zipfile import ZipFile,ZIP_DEFLATED
import hashlib,json
R=Path(__file__).resolve().parent
out=R/"FS_R8_USER_RED_BLUE_NATIVE_PRIVATE_20261028.zip"
files=["RESEARCH_REPORT_R8.md","CURRENT_HANDOFF_R8.md","RUN_R8_USER_ANNOTATED_TEST.cmd",
 "r8_red_blue_baseline_audit.py","r8_sam2_user_red_blue.py","r8_four_direction_real_footprint_scan.py",
 "build_r8_native_user_override.py","prepare_r8_native_capture.py",
 "capture_r8_native_scene.py","analyze_r8_native_scene.py",
 "r8_make_native_visual_contact.py","r8_final_gate.py",
 "SCENE21_GUIDED_SAM2_CANDIDATE/MASTER_RGBA.png",
 "R8_NATIVE_FULL_MASTER/R8_FINAL_GATE.json","R8_NATIVE_FULL_MASTER/R8_BUILD_MANIFEST.json",
 "R8_NATIVE_FULL_MASTER/FULL505/Overlays/Par1.png"]
for branch in ["R8_USER_ANNOTATION_20261028","R8_NATIVE_FULL_MASTER/NATIVE_ABA","R8_NATIVE_FULL_MASTER/REPLAY1_NATIVE_ABA"]:
 folder=R/branch
 assert folder.is_dir()
 files += [str(p.relative_to(R)).replace("\\","/") for p in folder.iterdir() if p.is_file()]
source_ids=["house","left_deciduous","right_deciduous","mid_conifer_A","mid_conifer_B",
 "upper_right_conifer","left_conifer","left_front_bush","left_shrine","right_marker","right_flower_bush","front_edge_bush"]
source_ids+=["RED_R0"+str(k) for k in range(1,9)]
for obj in source_ids:
 files.append("R8_NATIVE_FULL_MASTER/FULL505/Graphics/Pictures/R5_OC_"+obj+".png")
files=sorted(set(files))
manifest={}
with ZipFile(out,"w",ZIP_DEFLATED,compresslevel=6) as z:
 for f in files:
  p=R/f
  assert p.is_file(),f
  manifest[f]={"bytes":p.stat().st_size,"sha256":hashlib.sha256(p.read_bytes()).hexdigest()}
  z.write(p,f)
 info={"status":"TECH_PASS_ISOLATED_PAR_SEMANTIC_ART_HOLD","user_screenshot_annotation_source":"548x400 user uploaded image, derived registry; original uploaded image not re-bundled",
       "reference":"K4 formal original FS Scripts SHA256 5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa",
       "private":True,"does_not_include_formal_505_scripts_or_Game.exe":True,
       "incremental_dependency":"Existing R7 + test-only FS K4 local authority","files":manifest}
 z.writestr("R8_PRIVATE_PACKAGE_MANIFEST.json",json.dumps(info,ensure_ascii=False,indent=2))
with ZipFile(out,"r") as z:assert z.testzip() is None
s={"status":"R8_PRIVATE_BACKUP_VERIFIED","zip":str(out),"bytes":out.stat().st_size,
   "sha256":hashlib.sha256(out.read_bytes()).hexdigest(),"filecount":len(files)+1}
(R/"R8_PRIVATE_PACKAGE_CHECKSUM.json").write_text(json.dumps(s,ensure_ascii=False,indent=2),encoding="utf8")
print("R8_PRIVATE_ZIP",json.dumps(s,ensure_ascii=False),flush=True)