from pathlib import Path
from PIL import Image
import json,zipfile,hashlib
R=Path(r"E:\GameAssetToolLab_20261023\A36_FS_ACTION_3FRAME_FORMAL_20261101")
q=json.loads((R/"A36_FORMAL_3FRAME_QA.json").read_text(encoding="utf8"))
# Every _3FRAME_*.png candidate, the actual formal one, waiting/walk/nothing all EXACTLY 3 frame cells.
checks=[
"A36_DODGING_FORMAL_3FRAME_CANDIDATE.png",
"A36_WALK_3FRAME_APPROVED_A31.png",
"A36_WAITING_3FRAME_STATIC_REPEATED.png",
"A36_NOTHING_3FRAME_TRANSPARENT.png",
"T1_READY_TUCK_RECOVER_3FRAME_40.png",
"T2_READY_MIDROLL_RECOVER_3FRAME_40.png",
"T3_READY_LOW_EVADE_RECOVER_3FRAME_40.png",
"T4_ANTICIPATE_ROLL_LAND_3FRAME_40.png"
]
for f in checks:
 p=R/f;im=Image.open(p).convert("RGBA")
 assert im.size==(120,40),f
 assert im.mode=="RGBA"
G=Image.open(R/"A36_DODGING_FORMAL_3FRAME_ONESHOT.gif")
assert G.n_frames==3 and G.info.get("loop") is None
z=R/"A36_FS_3FRAME_ONLY_PRIVATE.zip"
with zipfile.ZipFile(z,"w",zipfile.ZIP_DEFLATED) as arc:
 for p in sorted(R.rglob("*")):
  if p.is_file() and p!=z:arc.write(p,p.relative_to(R))
with zipfile.ZipFile(z) as arc:
 assert arc.testzip() is None
 print("ZIP_FILES",len(arc.namelist()),flush=True)
print("ZIP_SIZE",z.stat().st_size,"ZIP_SHA",hashlib.sha256(z.read_bytes()).hexdigest(),flush=True)
print("FORMAL_SHEET",q["candidate"],q["action_dimensions"],flush=True)
