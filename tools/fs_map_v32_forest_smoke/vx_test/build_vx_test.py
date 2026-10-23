from pathlib import Path
from shutil import copytree,copy2
from rubymarshal.reader import load
from rubymarshal.writer import write
from PIL import Image
import zlib,json,hashlib
root=Path(r"E:\GameAssetToolLab_20261023\FS_ForestSplit_v3_2")
template=Path(r"C:\Users\User\Documents\RPGVX\Project1")
dest=root/"vx_test"/"FS_VX_ISOLATED_TEST"
assert (template/"Data/Scripts.rvdata").is_file()
if not dest.exists():copytree(template,dest)
pic=dest/"Graphics"/"Pictures";pic.mkdir(parents=True,exist_ok=True)
for fn in ("FS_FOREST_V32_Ground.png","FS_FOREST_V32_Par_BASE.png","FS_FOREST_V32_Par_COMPLETE.png"):
 copy2(root/"build"/fn,pic/fn)
m=json.loads((root/"scene_manifest.json").read_text(encoding="utf8"))
for i,obj in enumerate((x for x in m["instances"] if x["instance_id"].startswith("tree_")),1):
 copy2(root/"build"/"semantic_masks"/(obj["instance_id"]+"_occlusion_rgba.png"),pic/("FS_TREE_OCCLUSION_"+str(i)+".png"))
coll=Image.open(root/"build"/"FS_FOREST_V32_CollisionMask.png").convert("L")
blocked=[]
for ty in range(13):
 for tx in range(17):
  # VX tile-granular collision: conservative around sprite's 18x18 footbox.
  cx,cy=tx*32+16,ty*32+16
  hit=any(coll.getpixel((x,y))>0 for y in range(cy-9,cy+10) for x in range(cx-9,cx+10))
  if hit:blocked.append((tx,ty))
script=(root/"vx_test"/"FS_TEST_LAYER_SCRIPT.rb").read_text(encoding="utf8").replace("__BLOCKED__",json.dumps(blocked))
scripts=load((template/"Data"/"Scripts.rvdata").open("rb"))
names=[s[1] for s in scripts]
assert b"Main" in names and b"FS TEST LAYER" not in names
main=names.index(b"Main")
new_script=[988000, b"FS TEST LAYER", zlib.compress(script.encode("ascii"))]
scripts.insert(main,new_script)
with (dest/"Data"/"Scripts.rvdata").open("wb") as f:write(f,scripts)
chk=load((dest/"Data"/"Scripts.rvdata").open("rb"))
assert len(chk)==len(scripts) and zlib.decompress(chk[main][2]).decode("ascii")==script
ini=(dest/"Game.ini").read_text(errors="replace")
ini=ini.replace("Title=Project1","Title=FS_VX_Isolated_Ground_PAR_TEST")
(dest/"Game.ini").write_text(ini)
(dest/"FS_VX_TEST_LOG.txt").write_text("BUILD_CREATED\n",encoding="ascii")
(root/"logs"/"VX_ISOLATED_BUILD_REPORT.json").write_text(json.dumps({
 "template":str(template),"isolated_path":str(dest),"source_script_sha256":hashlib.sha256((template/"Data/Scripts.rvdata").read_bytes()).hexdigest(),
 "test_script_sha256":hashlib.sha256((dest/"Data/Scripts.rvdata").read_bytes()).hexdigest(),
 "scripts":len(chk),"blocked_tiles":blocked,"textures":[p.name for p in pic.glob("FS_*.png")],
 "status":"BUILD_CREATED_UNVERIFIED_RUNTIME"},indent=2),encoding="utf8")
print("VX_ISOLATED_BUILD_CREATED",dest,"scripts",len(chk),"blocked_tiles",blocked,"pictures",len(list(pic.glob("FS_*.png"))))
