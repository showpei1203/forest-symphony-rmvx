# -*- coding: utf-8 -*-
"""Build portable evidence ZIP from isolated T15 workspace with integrity manifest."""
from pathlib import Path
import json,hashlib,zipfile,shutil
root=Path(r"E:\GameAssetToolLab_20261023\ToolValidation_T15_20261024")
base=root.parent/"ToolValidation_v3_20261024"
dst=root.parent/"deliveries"/"FS_PIXELORAMA_GPU_SHADER_T15_T15B_20261024.zip"
fdir=root/"fixtures";fdir.mkdir(exist_ok=True)
fixtures={
"official_animated_layer_effect.pxo":base/"inputs/pixelorama/official_animated_layer_effect.pxo",
"b0_tree_six_unique.pxo":base/"inputs/pixelorama/b0_tree_six_unique.pxo",
"tree_animation_6frames.png":base/"inputs/tree_animation_6frames.png",
}
for name,src in fixtures.items():
    assert src.is_file(),src
    shutil.copyfile(src,fdir/name)
required=["T15_PIXELORAMA_GPU_DIAGNOSTIC.json","T15B_PIXELORAMA_B0_SHADER.json","README_繁體中文.md","RUN_T15_GPU_TEST.cmd"]
for name in required: assert (root/name).is_file(),name
a=json.loads((root/required[0]).read_text(encoding="utf-8"))
b=json.loads((root/required[1]).read_text(encoding="utf-8"))
assert a["status"]=="T15_EFFECTS_RENDER_EXPORT_PASS" and b["status"]=="T15B_B0_SIX_UNIQUE_FRAMES_EFFECT_GPU_PASS"
files=sorted(p for p in root.rglob("*") if p.is_file() and p.suffix.lower() in (".json",".log",".py",".cmd",".png",".pxo",".md") and p.name!="DELIVERY_INTEGRITY.json")
entries=[{"path":p.relative_to(root).as_posix(),"size":p.stat().st_size,"sha256":hashlib.sha256(p.read_bytes()).hexdigest()} for p in files]
manifest={"name":dst.name,"status":"T15_T15B_REAL_GPU_SHADER_EXPORT_PASS","entries":entries,"total_files":len(entries),"notes":"Contains official Pixelorama sample for private tool study; use external art-license gate before distributing source images."}
(root/"DELIVERY_INTEGRITY.json").write_text(json.dumps(manifest,indent=2,ensure_ascii=False),encoding="utf-8")
with zipfile.ZipFile(dst,"w",zipfile.ZIP_DEFLATED,compresslevel=9) as out:
    for p in files+[root/"DELIVERY_INTEGRITY.json"]:
        out.write(p,p.relative_to(root).as_posix())
with zipfile.ZipFile(dst) as z:
    assert z.testzip() is None
    assert len(z.namelist())==len(files)+1
print(json.dumps({"path":str(dst),"files":len(files)+1,"bytes":dst.stat().st_size,"sha256":hashlib.sha256(dst.read_bytes()).hexdigest(),
                  "T15":a["status"],"T15B":b["status"]},ensure_ascii=False))
