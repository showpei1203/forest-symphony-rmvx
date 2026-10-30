from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED
from hashlib import sha256
import shutil
root=Path(__file__).resolve().parent
dest=root/'FS_ROUTE_B_STAGE6_ACTOR_OCCLUSION_20261031.zip'
required=[
 'project.godot','render_scene.gd','render_stage2.gd',
 'render_terrain_stage4.gd','render_tree_stage5.gd','cottage_prefab.gd',
 'FS_Elf_Cottage.tscn','qa.py','audit_tree_contact.py','author_ground_stage5.py',
 'test_actor_occlusion.py','TERRAIN_STAGE5_SOURCE.json',
 'ASSET_MANIFEST.json','FANTASY_LICENSE.txt','CURRENT_HANDOFF_ROUTE_B_STAGE6_20261031.md'
]
paths=[root/x for x in required]
paths.extend((root/'assets').rglob('*.glb'))
paths.extend((root/'assets').rglob('*.png'))
paths.extend((root/'out').rglob('*.png'))
paths.extend((root/'out').rglob('*.json'))
missing=[str(x.relative_to(root)) for x in paths if not x.is_file()]
assert not missing,missing
with ZipFile(dest,'w',ZIP_DEFLATED,compresslevel=6) as f:
 for p in sorted(paths): f.write(p,p.relative_to(root).as_posix())
with ZipFile(dest) as f:
 assert f.testzip() is None
 for p in ('out/STAGE6_ACTOR_OCCLUSION_6PANEL.png','out/STAGE6_ACTOR_OCCLUSION_QA.json','out/TREE_CONTACT_MASK.png','out/GROUND.png','out/PAR.png','FS_Elf_Cottage.tscn'):
  assert p in f.namelist(),p
 cold=Path('E:/FS_ROUTE_B_STAGE6_COLD_CHECK')
 if cold.exists(): shutil.rmtree(cold)
 cold.mkdir()
 f.extractall(cold)
 print('ZIP',dest.name,'file_count',len(f.namelist()),'bytes',dest.stat().st_size,'sha256',sha256(dest.read_bytes()).hexdigest())
 print('COLD_SOURCE',cold)