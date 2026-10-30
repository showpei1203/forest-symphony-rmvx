from pathlib import Path
from zipfile import ZipFile,ZIP_DEFLATED
from hashlib import sha256
import shutil
r=Path(__file__).resolve().parent
z=r/'FS_ROUTE_B_STAGE11_CROWN_COMPONENTS_20261031.zip'
needed=[
 'project.godot','render_scene.gd','render_stage2.gd','render_terrain_stage4.gd',
 'render_tree_stage5.gd','render_stage7_cottage.gd','render_stage8_oak.gd',
 'render_stage9_crown.gd','render_stage10_geometry.gd','render_stage11_components.gd',
 'FS_Elf_Cottage.tscn','cottage_prefab.gd','author_ground_stage5.py','author_roof_material.py',
 'qa.py','audit_tree_contact.py','test_actor_occlusion.py','audit_walk_stage11.py',
 'compare_stage11.py','RUN_STAGE11_ALL_CHECKS.ps1','package_stage11.py',
 'STAGE8_OAK_SOURCE_MANIFEST.json','STAGE7_SOURCE_PROVENANCE.json','FANTASY_LICENSE.txt',
 'CURRENT_HANDOFF_ROUTE_B_STAGE11_20261031.md']
files=[r/n for n in needed]
for dir in ('assets','source_raw','baseline_stage10','candidates','out'):
 for p in (r/dir).rglob('*'):
  if p.is_file() and (p.suffix.lower() in ('.png','.json','.glb') or p.name=='.gdignore'):
   files.append(p)
missing=[str(p.relative_to(r)) for p in files if not p.is_file()]
assert not missing,missing
with ZipFile(z,'w',ZIP_DEFLATED,compresslevel=6) as archive:
 for p in sorted(set(files)):archive.write(p,p.relative_to(r).as_posix())
with ZipFile(z) as archive:
 assert archive.testzip() is None
 for name in [
 'render_stage11_components.gd','RUN_STAGE11_ALL_CHECKS.ps1',
 'out/STAGE11_4WAY_NATIVE_1X.png','out/STAGE11_GEOMETRY_QA.json',
 'out/STAGE11_ACTOR_WALK_SWEEP_70.png',
 'candidates/A_BROAD/PAR.png','candidates/B_FINE/PAR.png','candidates/C_PRUNED/PAR.png',
 'baseline_stage10/PAR.png','assets/oak_detailed_innerscene.glb'
 ]:assert name in archive.namelist(),name
 cold=Path('E:/FS_ROUTE_B_STAGE11_COLD_CHECK')
 if cold.exists():shutil.rmtree(cold)
 cold.mkdir(parents=True)
 archive.extractall(cold)
 print('ZIP',z.name,'FILES',len(archive.namelist()),'BYTES',z.stat().st_size,'SHA256',sha256(z.read_bytes()).hexdigest(),flush=True)
 print('COLD_ROOT',cold,flush=True)