#!/usr/bin/env python3
"""R17 Stage2 private archive: genuinely new generated art crop and source RGB exact 11-object masks.
Only real tested outputs, no external model weights, no K4 original scripts.
"""
from pathlib import Path
from zipfile import ZipFile,ZIP_DEFLATED
import json,hashlib
R=Path(__file__).resolve().parent;D=R/"R17_STAGE2_NEW_ART_20261029"
files=[R/f for f in ("r17_stage2_new_master_sam2.py",
 "r17_stage2_sam2_rescue_v2.py","r17_stage2_build_godot_native.py",
 "r17_stage2_godot_final_gate.py")]
files += [f for f in D.rglob("*") if f.is_file() and not (".godot" in f.parts or f.name.endswith(".import") or f.name=="import.log")]
# exclude actual ZIP if rerun
files=[f for f in files if f.suffix.lower()!=".zip"]
files=sorted(set(files))
checks={}
zipfile=D/"FS_R17_STAGE2_NEW_ART_11PAR_NATIVE_GODOT_PRIVATE_20261029.zip"
with ZipFile(zipfile,"w",ZIP_DEFLATED,compresslevel=6) as z:
 for f in files:
  rel=f.relative_to(R).as_posix();z.write(f,rel)
  checks[rel]={"bytes":f.stat().st_size,"sha256":hashlib.sha256(f.read_bytes()).hexdigest()}
 z.writestr("R17_STAGE2_ARCHIVE_MANIFEST.json",json.dumps({
 "status":"NEW_GENERATED_ART_SAM2_11_PAR_GODOT_NATIVE_TECH_PASS_ART_HOLD",
 "no_R12_old_master_used":True,"source_image_board_crop_not_real_layer_generator":True,
 "not_all_hard_art_gates_passed":True,"missing_seed_mask_count":2,
 "known_81_px_market_stall_ground_conflict":True,
 "FS_original_project_untouched":True,"files":checks},ensure_ascii=False,indent=2))
with ZipFile(zipfile,"r") as z:assert z.testzip() is None
release={"status":"R17_STAGE2_CRC_SHA_PASS","zip":zipfile.name,
"sha256":hashlib.sha256(zipfile.read_bytes()).hexdigest(),
"bytes":zipfile.stat().st_size,"files":len(files)+1,
"Formal_Seal":False,"art_GATE_F":"HOLD"}
(D/"R17_STAGE2_RELEASE_SHA256.json").write_text(json.dumps(release,ensure_ascii=False,indent=2),encoding="utf8")
print("R17_STAGE2_ARCHIVE",json.dumps(release,ensure_ascii=False),flush=True)