from pathlib import Path
from zipfile import ZipFile,ZIP_DEFLATED
from hashlib import sha256
import shutil
root=Path(__file__).resolve().parent
z=root/'FS_ROUTE_B_STAGE10_CROWN_GEOMETRY_20261031.zip'
required=[
 'project.godot','render_scene.gd','render_stage2.gd','render_terrain_stage4.gd',
 'render_tree_stage5.gd','render_stage7_cottage.gd','render_stage8_oak.gd',
 'render_stage9_crown.gd','render_stage10_geometry.gd',
 'cottage_prefab.gd','FS_Elf_Cottage.tscn',
 'author_ground_stage5.py','author_roof_material.py',
 'qa.py','audit_tree_contact.py','test_actor_occlusion.py',
 'compare_stage10.py','audit_walk_stage10.py',
 'RUN_STAGE10_ALL_CHECKS.ps1','package_stage10.py',
 'STAGE8_OAK_SOURCE_MANIFEST.json','STAGE7_SOURCE_PROVENANCE.json','FANTASY_LICENSE.txt',
 'CURRENT_HANDOFF_ROUTE_B_STAGE10_20261031.md'
]
files=[root/p for p in required]
for directory in ['assets','source_raw','baseline_stage9','candidates','out']:
 for file in (root/directory).rglob('*'):
  if file.is_file() and (file.suffix.lower() in ('.glb','.png','.json') or file.name=='.gdignore'):
   files.append(file)
missing=[str(f.relative_to(root)) for f in files if not f.exists()]
assert not missing, missing
with ZipFile(z,'w',ZIP_DEFLATED,compresslevel=6) as archive:
 for file in sorted(set(files)): archive.write(file,file.relative_to(root).as_posix())
with ZipFile(z) as archive:
 assert archive.testzip() is None
 for n in ['render_stage10_geometry.gd','RUN_STAGE10_ALL_CHECKS.ps1','out/STAGE10_GEOMETRY_ABCD_1X.png','out/STAGE10_ACTOR_WALK_SWEEP_70.png','out/STAGE10_GEOMETRY_QA.json','candidates/A_LOBES/PAR.png','candidates/B_SPRAYS_SCATTERED/PAR.png','candidates/C_WOVEN_LEAF_ROSETTES/PAR.png','assets/oak_detailed_innerscene.glb']:
  assert n in archive.namelist(),n
 cold=Path('E:/FS_ROUTE_B_STAGE10_COLD_CHECK')
 if cold.exists():shutil.rmtree(cold)
 cold.mkdir(parents=True)
 archive.extractall(cold)
 print('ZIP',z.name,'file_count',len(archive.namelist()),'bytes',z.stat().st_size,'sha256',sha256(z.read_bytes()).hexdigest(),flush=True)
 print('COLD_ROOT',cold,flush=True)