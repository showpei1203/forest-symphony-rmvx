from pathlib import Path
from shutil import copytree,copy2
from rubymarshal.reader import load
from rubymarshal.writer import write
from PIL import Image
import hashlib,json,zlib
r=Path(r"E:\GameAssetToolLab_20261023\FS_ElfVillage_RichPilot_20261023")
template=Path(r"C:\Users\User\Documents\RPGVX\Project1")
target=r/"vx_test"/"FS_RICH_VX_ISOLATED"
assert (template/"Data"/"Scripts.rvdata").is_file()
copytree(template,target,dirs_exist_ok=True)
m=json.loads((r/"scene_manifest.json").read_text(encoding="utf8"))
graphics=target/"Graphics"/"Pictures";graphics.mkdir(parents=True,exist_ok=True)
copy2(r/"build"/"FS_ELF_RICH_Ground.png",graphics/"FS_ELF_RICH_Ground.png")
assets=sorted(set(z["asset_id"] for z in m["instances"]))
for aid in assets:copy2(r/"source"/"clean"/(aid+".png"),graphics/("FSOBJ_"+aid+".png"))
coll=Image.open(r/"build"/"FS_ELF_RICH_Collision.png").convert("L")
blocked=[]
for y in range(20):
 for x in range(27):
  cx=x*32+16;cy=y*32+16
  if any(coll.getpixel((xx,yy))>0 for yy in range(cy-9,cy+10) for xx in range(cx-9,cx+10)):
   blocked.append([x,y])
objects=[[o["id"],o["asset_id"],o["x"],o["y"],o["draw_order"],o["role"]] for o in sorted(m["instances"],key=lambda z:(z["draw_order"],z["id"]))]
events=[[e["id"],e["x"],e["y"]] for e in m["interactions"]]
sha=hashlib.sha256((r/"scene_manifest.json").read_bytes()).hexdigest()
script=(r/"vx_test"/"FS_RICH_VX_LAYER.rb").read_text(encoding="utf8")
script=script.replace("__MANIFEST_SHA__",sha).replace("__OBJECTS__",json.dumps(objects)).replace("__BLOCKED__",json.dumps(blocked)).replace("__EVENTS__",json.dumps(events))
assert "__" not in script or "__" in "RICH_NO_PLACEHOLDER"
assert script.isascii()
original=load((template/"Data"/"Scripts.rvdata").open("rb"))
names=[x[1] for x in original]
assert b"Main" in names
main=names.index(b"Main")
original.insert(main,[988002,b"FS RICH V2 TEST",zlib.compress(script.encode("ascii"))])
with (target/"Data"/"Scripts.rvdata").open("wb") as file:write(file,original)
check=load((target/"Data"/"Scripts.rvdata").open("rb"))
assert zlib.decompress(check[main][2]).decode("ascii")==script
ini=(target/"Game.ini").read_text(errors="replace")
ini=ini.replace("Title=Project1","Title=FS_ELF_RICH_VX_TEST_V2")
(target/"Game.ini").write_text(ini)
(target/"FS_RICH_VX_LOG.txt").write_text("RICH_VX_TEST_BUILD_READY\n",encoding="utf8")
report={"status":"BUILD_CREATED_NOT_RUNTIME_PASS","template":str(template),"target":str(target),
"objects":len(objects),"unique_assets":len(assets),"blocked_tiles":len(blocked),"events":len(events),"script_count":len(check),
"template_script_sha":hashlib.sha256((template/"Data"/"Scripts.rvdata").read_bytes()).hexdigest(),
"isolated_script_sha":hashlib.sha256((target/"Data"/"Scripts.rvdata").read_bytes()).hexdigest(),
"scene_sha256":sha}
(r/"logs"/"RICH_VX_BUILD_REPORT.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print("RICH_VX_ISOLATED_BUILD",len(objects),"props",len(assets),"types","blocked",len(blocked))
