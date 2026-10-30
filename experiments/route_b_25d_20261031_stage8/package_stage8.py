from pathlib import Path
from zipfile import ZipFile,ZIP_DEFLATED
from hashlib import sha256
import shutil
r=Path(__file__).resolve().parent
zip_file=r/'FS_ROUTE_B_STAGE8_DETAILED_TREE_20261031.zip'
base=[
 'project.godot','render_scene.gd','render_stage2.gd','render_terrain_stage4.gd','render_tree_stage5.gd',
 'render_stage7_cottage.gd','render_stage8_oak.gd','render_stage8_first_candidate.gd',
 'FS_Elf_Cottage.tscn','cottage_prefab.gd','author_ground_stage5.py','author_roof_material.py',
 'qa.py','audit_tree_contact.py','test_actor_occlusion.py','audit_actor_stage8.py',
 'compare_stage8.py','RUN_STAGE8_ALL_CHECKS.ps1','fetch_oak_stage8.py',
 'STAGE8_OAK_SOURCE_MANIFEST.json','STAGE7_SOURCE_PROVENANCE.json',
 'STAGE7_ROOF_TEXTURE_MANIFEST.json','TERRAIN_STAGE5_SOURCE.json','FANTASY_LICENSE.txt',
 'CURRENT_HANDOFF_ROUTE_B_STAGE8_20261031.md'
]
paths=[r/p for p in base]
for path in ['assets','source_raw','out','candidates','baseline_stage7']:
 for p in (r/path).rglob('*'):
  if p.is_file() and (p.suffix.lower() in ('.glb','.png','.json') or p.name=='.gdignore'):
   paths.append(p)
assert all(x.is_file() for x in paths)
with ZipFile(zip_file,'w',ZIP_DEFLATED,compresslevel=6) as z:
 for p in sorted(set(paths)):
  z.write(p,p.relative_to(r).as_posix())
with ZipFile(zip_file) as z:
 assert z.testzip() is None
 for n in ['assets/oak_detailed_innerscene.glb','out/GROUND.png','out/PAR.png','out/TREE_CONTACT_MASK.png','out/STAGE8_TREE_ABC_1X.png','out/STAGE8_ACTOR_OCCLUSION_6PANEL.png','RUN_STAGE8_ALL_CHECKS.ps1','candidates/B_BOTH_TREES_FRONT_FAIL/STAGE6_ACTOR_OCCLUSION_QA.json']:
  assert n in z.namelist(),n
 cold=Path("E:/FS_ROUTE_B_STAGE8_COLD_CHECK")
 if cold.exists():shutil.rmtree(cold)
 cold.mkdir()
 z.extractall(cold)
 print('ZIP',zip_file,'BYTES',zip_file.stat().st_size,'FILES',len(z.namelist()),'SHA256',sha256(zip_file.read_bytes()).hexdigest(),flush=True)
 print('COLD_EXTRACT',cold,flush=True)