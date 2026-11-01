from pathlib import Path
from PIL import Image
import hashlib,json,zipfile
R=Path(r"E:\GameAssetToolLab_20261023\A43_FS_RUN_LOOP_3FRAME_20261101")
sheet=Image.open(R/"A43_MOVING_TO_CLOSE_ATTACK_RUN_3FRAME_120x40.png").convert("RGBA")
gif=Image.open(R/"A43_RUN_LOOP_PLAYBACK_0_1_0_2_8X.gif")
assert sheet.size==(120,40)
assert gif.size==(640,392) and gif.n_frames==4 and gif.info.get("loop")==0
for i in range(3):
 assert sheet.crop((40*i,0,40*(i+1),40)).size==(40,40)
q=json.loads((R/"A43_RUN_LOOP_QA.json").read_text(encoding="utf8"))
assert q["loop_sequence"]==[0,1,0,2]
assert not any(v["right_touch"] or v["bottom_touch"] for v in q["individual_frames"])
z=R/"A43_FS_MOVING_CLOSE_ATTACK_REAL_RUN_LOOP_PRIVATE.zip"
with zipfile.ZipFile(z,"w",zipfile.ZIP_DEFLATED) as arc:
 for p in sorted(R.rglob("*")):
  if p.is_file() and p!=z:arc.write(p,p.relative_to(R))
with zipfile.ZipFile(z) as arc:
 assert arc.testzip() is None
 print("ZIP_COUNT",len(arc.namelist()),flush=True)
print("ZIP_SIZE",z.stat().st_size,"ZIP_SHA256",hashlib.sha256(z.read_bytes()).hexdigest(),flush=True)
for name in ["A43_RUN_LOOP_PLAYBACK_0_1_0_2_8X.gif","A43_MOVING_TO_CLOSE_ATTACK_3FRAME_LARGE_PREVIEW.png","A43_A42_FAIL_VS_CORRECT_RUN_LOOP.png","A43_MOVING_TO_CLOSE_ATTACK_RUN_3FRAME_120x40.png"]:
 p=R/name;print("FILE",name,p.stat().st_size)
