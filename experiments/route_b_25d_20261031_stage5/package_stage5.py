from pathlib import Path
from zipfile import ZipFile,ZIP_DEFLATED
from hashlib import sha256
import shutil,json
r=Path(__file__).resolve().parent
z=r/"FS_ROUTE_B_STAGE5_NATIVE_32PX_TREE_GROUND_20261031.zip"
files=[
 "project.godot","render_scene.gd","render_stage2.gd","render_terrain_stage4.gd",
 "render_tree_stage5.gd","FS_Elf_Cottage.tscn","cottage_prefab.gd",
 "qa.py","audit_tree_contact.py","author_ground_stage5.py",
 "author_ground_stage5_dense_variant.py",
 "TERRAIN_STAGE5_SOURCE.json","ASSET_MANIFEST.json","FANTASY_LICENSE.txt",
 "CURRENT_HANDOFF_ROUTE_B_STAGE5_20261031.md"
]
paths=[r/f for f in files]
paths.extend((r/"assets").rglob("*.glb"))
paths.extend((r/"assets").rglob("*.png"))
paths.extend((r/"out").rglob("*.png"))
paths.extend((r/"out").rglob("*.json"))
missing=[str(p.relative_to(r)) for p in paths if not p.is_file()]
assert not missing, missing
with ZipFile(z,"w",ZIP_DEFLATED,compresslevel=6) as f:
 for p in sorted(paths):f.write(p,p.relative_to(r).as_posix())
with ZipFile(z) as f:
 assert f.testzip() is None
 for n in ["assets/terrain_stage5.png","out/GROUND.png","out/PAR.png","out/TREE_CONTACT_MASK.png","out/CONTACT_32_GRID_AUDIT.json","out/QA_4PANEL.png","render_tree_stage5.gd"]:
  assert n in f.namelist(),n
 cold=Path("E:/FS_ROUTE_B_STAGE5_COLD_CHECK")
 if cold.exists():shutil.rmtree(cold)
 cold.mkdir(parents=True)
 f.extractall(cold)
 print("ZIP",z.name,"files",len(f.namelist()),"bytes",z.stat().st_size,"sha256",sha256(z.read_bytes()).hexdigest())
 print("COLD_EXTRACT",cold)