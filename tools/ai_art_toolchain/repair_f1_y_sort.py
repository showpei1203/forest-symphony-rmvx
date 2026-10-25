from pathlib import Path
from PIL import Image
import shutil,json,numpy as np
R=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
src=R/"outputs/FS_F1_ORIGINAL_GROUND_SOURCE_FIRST_20261025"
dst=R/"outputs/FS_F1R1_GROUND_SORTY_REPAIR_20261025"
if dst.exists():raise SystemExit("Refusing revision overwrite")
shutil.copytree(src,dst)
m=json.loads((dst/"scene_manifest.json").read_text(encoding="utf-8"))
ground=Image.open(dst/"build/Ground.png").convert("RGBA")
composed=ground.copy();par=Image.new("RGBA",ground.size)
for o in sorted(m["objects"],key=lambda o:o["foot_anchor"][1]):
 art=Image.open(dst/o["source"]).convert("RGBA")
 par.alpha_composite(art,dest=(o["x"],o["y"]))
 composed.alpha_composite(art,dest=(o["x"],o["y"]))
par.save(dst/"build/PAR_COMPLETE.png")
composed.save(dst/"build/Recomposed.png")
m["revision"]="F1R1_SORTY_CANONICAL"
m["occlusion_authority"]="SORT_ASCENDING_FOOT_ANCHOR_Y"
m["previous_failure"]="F1 v1 original preview art order contradicted y-sort; 191px mismatch near tree and well"
(dst/"scene_manifest.json").write_text(json.dumps(m,ensure_ascii=False,indent=2),encoding="utf-8")
print("REPAIRED",dst)
