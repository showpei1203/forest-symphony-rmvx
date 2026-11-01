from pathlib import Path
from PIL import Image
import json,hashlib
R=Path(r"E:\GameAssetToolLab_20261023\A29_FS45_UNARMED_PIXELLAB_LOOP_20261101")
p=R/"PIXELLAB_8_DIRECTIONS_V3"/"00_SOUTH_64.png"
im=Image.open(p).convert("RGBA")
box=im.getbbox();assert box and box[0]>=12 and box[1]>=12 and box[2]<=52 and box[3]<=52
crop=im.crop((12,12,52,52))
target=R/"A29_SELECTED_SE_VISUAL_45_UNARMED_40.png"
crop.save(target)
meta={"stage":"A29","selected_output":str(p),
 "provider_file_label":"index0 from V3, directional nomenclature uncertain; VISUAL selection only",
 "selected_for":"southeast visual 3/4 candidate, unarmed",
 "unaltered_pixel_art":"YES only lossless crop (12,12..52,52)",
 "selected_bbox":crop.getbbox(),
 "source_approved":"A26 approval, A29 Pixen edit via source and 8-dir preview",
 "formal_art_acceptance":"PENDING USER",
 "SBS_weapon_layer":"KEEP EMPTY, paper-doll separate",
 "loops_to_test":["IDLE","WALK"]}
(R/"A29_DIRECTION_SELECTION_AUDIT.json").write_text(json.dumps(meta,ensure_ascii=False,indent=2),encoding="utf8")
print("SELECTED",target,"BBOX",crop.getbbox())
