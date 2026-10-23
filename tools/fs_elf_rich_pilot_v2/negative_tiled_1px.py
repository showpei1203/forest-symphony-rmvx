from pathlib import Path
from PIL import Image,ImageChops
import xml.etree.ElementTree as ET,subprocess,json
r=Path(r"E:\GameAssetToolLab_20261023\FS_ElfVillage_RichPilot_20261023")
tmx=r/"work"/"FS_ELF_RICH_scene.tmx"
out=r/"work"/"FS_ELF_RICH_negative_1px.tmx"
tree=ET.parse(tmx)
item=tree.find('.//object[@name="sign_spawn"]')
assert item is not None
item.set("x",str(float(item.get("x"))+1))
tree.write(out,encoding="utf8",xml_declaration=True)
raster=r.parent/"tools"/"Tiled"/"tmxrasterizer.exe"
capture=r/"build"/"FS_ELF_RICH_NEGATIVE_1PX.png"
proc=subprocess.run([str(raster),str(out),str(capture)],capture_output=True,text=True,errors="replace",timeout=35)
assert proc.returncode==0,proc.stderr
a=Image.open(capture).convert("RGBA")
b=Image.open(r/"build"/"FS_ELF_RICH_Master.png").convert("RGBA")
count=sum(x!=y for x,y in zip(a.getdata(),b.getdata()))
record={"negative_injection":"sign_spawn world X plus 1px","raster_exit":proc.returncode,"different_pixels":count,"status":"NEGATIVE_DETECTED" if count>0 else "FAIL_NOT_DETECTED"}
(r/"logs"/"RICH_V2_NEGATIVE_1PX.json").write_text(json.dumps(record,indent=2),encoding="utf8")
print(record)
if not count:raise SystemExit(2)
