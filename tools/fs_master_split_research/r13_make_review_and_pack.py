#!/usr/bin/env python3
"""R13 review board + private reproducible deliverable (no original FS 505 or Game.exe)."""
from pathlib import Path
from PIL import Image,ImageDraw
from zipfile import ZipFile,ZIP_DEFLATED
import json,hashlib
R=Path(__file__).resolve().parent
D=R/"R13_TILE_OCCLUSION_PAR_20261028"
V=R/"R12_NEW_ELF_VILLAGE_001";N=R/"R13_NEW_ELF_VILLAGE_NATIVE"
master=Image.open(V/"MASTER_NEW_ELF_VILLAGE_001_R12_CANDIDATE.png").convert("RGB")
arr=[
("01 NEW ELF VILLAGE MASTER",master),
("02 R12 PAR14 OLD COVERAGE",Image.open(V/"R12_SELECTED14_PINK_COVERAGE_QA.png").convert("RGB")),
("03 R13 PAR52 NEW COVERAGE",Image.open(D/"R13_MASTER_PINK_PAR_COVERAGE.png").convert("RGB")),
("04 R13 32PX OCCLUSION TILE REGISTRY",Image.open(D/"R13_32PX_OCCLUSION_GRID_QA.png").convert("RGB"))]
sheet=Image.new("RGB",(1300,995),(22,26,33));pen=ImageDraw.Draw(sheet)
for i,(name,im) in enumerate(arr):
 x=(i%2)*650;y=(i//2)*495
 sheet.paste(im.resize((640,464),Image.Resampling.NEAREST),(x+5,y+24))
 pen.text((x+12,y+6),name,fill=(244,244,248))
sheet.save(D/"R13_R12_VS_R13_MASTER_PAR_TILE_4PANEL.png")
# Paired native screenshots in R12 vs new R13 same scene, diagnostic only, cannot prove foreground art correctness.
old=R/"R12_NEW_ELF_VILLAGE_NATIVE"/"NATIVE";fresh=N/"NATIVE"
for tag in ["R12_PLAZA_WEST","R12_NPC_WALK","R12_CENTER_INN_WALL"]:
 o=Image.open(old/(tag+".png")).convert("RGB")
 n=Image.open(fresh/(tag+".png")).convert("RGB")
 compare=Image.new("RGB",(1100,448),(17,21,28))
 compare.paste(o,(6,28));compare.paste(n,(550,28))
 d=ImageDraw.Draw(compare)
 d.text((8,10),"R12 BASELINE SOURCE PAR14",fill=(240,240,245))
 d.text((551,10),"R13 NEW 32TILE PAR52 CANDIDATE",fill=(240,240,245))
 compare.save(D/("R13_NATIVE_COMPARE_"+tag+".png"))
# curated complete private archive
files=["RESEARCH_REPORT_R13.md","CURRENT_HANDOFF_R13.md",
 "R13_PAR_OCCLUSION_TILE_RULES_20261028.md",
 "r13_build_tile_first_par.py","r13_optimize_par_crop.py",
 "build_r13_native_par.py","prepare_r13_capture.py",
 "capture_r13_native_par.py","r13_final_gate.py","r13_make_review_and_pack.py",
 "R13_NEW_ELF_VILLAGE_NATIVE/R13_NATIVE_BUILD.json",
 "R13_NEW_ELF_VILLAGE_NATIVE/R13_FINAL_GATE.json",
 "R12_NEW_ELF_VILLAGE_001/MASTER_NEW_ELF_VILLAGE_001_R12_CANDIDATE.png",
 "R12_NEW_ELF_VILLAGE_001/R12_SELECTED14_AND_COLLISION_GATE.json"]
for folder in ["R13_TILE_OCCLUSION_PAR_20261028",
 "R13_NEW_ELF_VILLAGE_NATIVE/NATIVE","R13_NEW_ELF_VILLAGE_NATIVE/REPLAY1"]:
 d=R/folder
 files += [str(z.relative_to(R)).replace("\\","/") for z in d.iterdir() if z.is_file()]
files=sorted(set(files))
name="FS_R13_TILE_FIRST_PAR52_NATIVE_PRIVATE_20261028.zip"
out=R/name
checks={}
with ZipFile(out,"w",ZIP_DEFLATED,compresslevel=6) as z:
 for fn in files:
  p=R/fn
  assert p.is_file(),fn
  z.write(p,fn)
  checks[fn]={"bytes":p.stat().st_size,"sha256":hashlib.sha256(p.read_bytes()).hexdigest()}
 z.writestr("R13_PRIVATE_MANIFEST.json",json.dumps({
  "status":"R13_32PX_PAR52_2NATIVE_SESSIONS_TECH_PASS_USER_ART_HOLD",
  "master_source_original_new_art_not_K4_ground3":True,
  "official_FS_sealed_files_untouched":True,
  "no_executable_or_505_scripts_in_archive":True,
  "full_52_crop_and_source_masks_included":True,
  "scene_visual_ART_approved":False,"files":checks
 },ensure_ascii=False,indent=2))
with ZipFile(out,"r") as z:assert z.testzip() is None
v={"status":"R13_ZIP_CRC_OK","zip":name,"size_bytes":out.stat().st_size,
 "SHA256":hashlib.sha256(out.read_bytes()).hexdigest(),"filecount":len(files)+1}
(R/"R13_PRIVATE_PACKAGE_SHA256.json").write_text(json.dumps(v,ensure_ascii=False,indent=2),encoding="utf8")
print("R13_PRIVATE_PACKAGE",json.dumps(v,ensure_ascii=False),flush=True)