from pathlib import Path
from zipfile import ZipFile,ZIP_DEFLATED
from hashlib import sha256
import shutil
root=Path(__file__).resolve().parent
z=root/"FS_ROUTE_B_STAGE4_GROUND_PIXEL_STYLE_20261031.zip"
base=["project.godot","render_scene.gd","render_stage2.gd","render_terrain_stage4.gd","FS_Elf_Cottage.tscn","cottage_prefab.gd","qa.py","style_abc.py","author_terrain_stage4.py","CURRENT_HANDOFF_ROUTE_B_STAGE4_20261031.md","TERRAIN_STAGE4_SOURCE.json","ASSET_MANIFEST.json","FANTASY_LICENSE.txt"]
paths=[root/x for x in base]
paths+=list((root/"assets").rglob("*.glb"))
paths+=list((root/"assets").rglob("*.png"))
paths+=list((root/"out").rglob("*.png"))+list((root/"out").rglob("*.json"))
assert all(p.is_file() for p in paths)
with ZipFile(z,"w",ZIP_DEFLATED,compresslevel=6) as f:
 for p in sorted(paths):f.write(p,p.relative_to(root).as_posix())
with ZipFile(z) as f:
 assert f.testzip() is None
 for n in ["FS_Elf_Cottage.tscn","assets/terrain_stage4.png","out/GROUND.png","out/PAR.png","out/STAGE4_STYLE_ABC.png","out/C_PALETTE_1X/PAR.png"]:
  assert n in f.namelist(),n
 cold=Path("E:/FS_ROUTE_B_STAGE4_COLD_CHECK")
 if cold.exists():shutil.rmtree(cold)
 cold.mkdir()
 f.extractall(cold)
 print("ZIP",z.name,"size",z.stat().st_size,"files",len(f.namelist()),"SHA256",sha256(z.read_bytes()).hexdigest())
 print("COLD_EXTRACT",(cold/"assets/terrain_stage4.png").stat().st_size)