from pathlib import Path
from zipfile import ZipFile,ZIP_DEFLATED
from hashlib import sha256
import shutil
r=Path(__file__).resolve().parent
z=r/'FS_ROUTE_B_STAGE9_CROWN_ART_20261031.zip'
files=[
 'project.godot','render_scene.gd','render_stage2.gd','render_terrain_stage4.gd',
 'render_tree_stage5.gd','render_stage7_cottage.gd','render_stage8_oak.gd',
 'render_stage9_crown.gd','cottage_prefab.gd','FS_Elf_Cottage.tscn',
 'author_ground_stage5.py','author_roof_material.py','qa.py','audit_tree_contact.py',
 'test_actor_occlusion.py','compare_stage9.py','run_variants_stage9.ps1','RUN_STAGE9_ALL_CHECKS.ps1',
 'package_stage9.py','STAGE8_OAK_SOURCE_MANIFEST.json','STAGE7_SOURCE_PROVENANCE.json',
 'STAGE7_ROOF_TEXTURE_MANIFEST.json','TERRAIN_STAGE5_SOURCE.json','FANTASY_LICENSE.txt',
 'CURRENT_HANDOFF_ROUTE_B_STAGE9_20261031.md'
]
paths=[r/f for f in files]
for folder in ['assets','source_raw','out','candidates','baseline_stage8']:
 for f in (r/folder).rglob('*'):
  if f.is_file() and (f.suffix.lower() in ('.glb','.png','.json') or f.name=='.gdignore'):
   paths.append(f)
missing=[str(f.relative_to(r)) for f in paths if not f.is_file()]
assert not missing,missing
with ZipFile(z,'w',ZIP_DEFLATED,compresslevel=6) as pack:
 for f in sorted(set(paths)):pack.write(f,f.relative_to(r).as_posix())
with ZipFile(z) as pack:
 assert pack.testzip() is None
 for name in [
 'render_stage9_crown.gd','out/STAGE9_STYLE_ABC_1X.png',
 'out/STAGE9_CROWN_DETAIL_4WAY.png','out/STAGE9_ART_COMPARE_QA.json',
 'candidates/bands/PAR.png','candidates/clusters/PAR.png',
 'candidates/clusters_too_bright/PAR.png','baseline_stage8/PAR.png',
 'assets/oak_detailed_innerscene.glb','out/GROUND.png','out/PAR.png'
 ]: assert name in pack.namelist(),name
 cold=Path('E:/FS_ROUTE_B_STAGE9_COLD_CHECK')
 if cold.exists():shutil.rmtree(cold)
 cold.mkdir()
 pack.extractall(cold)
 print('ZIP',z.name,'FILE_COUNT',len(pack.namelist()),'BYTES',z.stat().st_size,'SHA256',sha256(z.read_bytes()).hexdigest())
 print('EXTRACTED',cold)