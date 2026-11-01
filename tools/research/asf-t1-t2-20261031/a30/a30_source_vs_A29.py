from pathlib import Path
from PIL import Image
import json,statistics
R=Path(r"E:\GameAssetToolLab_20261023\A30_FS_SOURCE_MOTION_RIG_LOOP_20261101")
src=json.loads((R/"A30_SOURCE_KINEMATICS.json").read_text(encoding="utf8"))
p=src["$actor01.png"]["rows"][2]
def rg(x,k):return x.get(k,{}).get("bbox")
print("NATIVE_R2_3FRAME (left step, idle, right step)")
for c,stats in enumerate(p):
 print("phase",c,"head",rg(stats,"head"),"shoulders",rg(stats,"chest"),"hips",rg(stats,"hips"),"feet",rg(stats,"feet"),"full",stats["bbox"])
print("source foot bottom", [s["feet"]["bbox"][3] for s in p])
a29=Path(r"E:\GameAssetToolLab_20261023\A29_FS45_UNARMED_PIXELLAB_LOOP_20261101")
for act in ("IDLE","WALK"):
 rec=json.loads((a29/act/"SUBMISSION_LOCK.json").read_text(encoding="utf8"))
 print("A29",act,"top",[b[1] for b in rec["metrics"]["bboxes"]],"bottom",[b[3] for b in rec["metrics"]["bboxes"]])
 print("source head top range",max(s["head"]["bbox"][1] for s in p)-min(s["head"]["bbox"][1] for s in p))
