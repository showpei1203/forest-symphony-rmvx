from pathlib import Path
from PIL import Image,ImageDraw
import json,hashlib
root=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031")
pics=root/"VX_A09_4_N5_RUNTIME"/"ASF_A094_NATIVE_PROOFS"
dest=root/"vx_real_actor_20261031"/"a09_4"
canvas=Image.new("RGB",(4*276,3*354),(245,247,249))
draw=ImageDraw.Draw(canvas)
rows=[]
for i,name in enumerate(["p01 attack1","p03 attack2","p05 standby"]):
 for tick in range(4):
  im=Image.open(pics/f"weapon_{i}_tick_{tick}.ppm").convert("RGB")
  s=im.resize((270,315),Image.Resampling.NEAREST)
  x=tick*276+3;y=i*354+30
  canvas.paste(s,(x,y))
  draw.text((x+5,i*354+8),f"{name}  native tick={tick}",fill=(25,45,65))
  raw=im.tobytes()
  rows.append({"profile":name,"tick":tick,"size":im.size,"sha256_rgb":hashlib.sha256(raw).hexdigest(),"non_background":sum(1 for p in im.getdata() if p!=(237,242,246))})
canvas.save(dest/"A094_VX_REAL_NATIVE_12_FRAMES_CONTACT.png")
(dest/"A094_NATIVE_FRAME_AUDIT.json").write_text(json.dumps(rows,indent=2))
print(json.dumps({"frame_counts":len(rows),"non_background":[r["non_background"] for r in rows],"contact":str(dest/"A094_VX_REAL_NATIVE_12_FRAMES_CONTACT.png")},indent=2))